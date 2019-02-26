
public final class WKJSBridge {

    internal var modules: [String: WKJSModule]
    internal var moduleTypes: [String: WKJSModuleType.Type]

    internal var handlers: [String: WKJSHandler]
    internal var handlerTypes: [String: WKJSHandlerType.Type]

    internal let jshostHandler: WKJSWebViewHandler

    internal let responseContainer = WKJSResponseContainer()
    internal var handleStorages: [String: WKJSHandleStorage] = [:]

    private let jsHandler = _WKJSHandler()
    internal var pendingMessages: [WKJSMessage] = []

    public weak var webview: WKWebView?

    public var jsready: Bool {
        return jsHandler.isReady
    }

    public init() {
        self.modules = [:]
        self.moduleTypes = [:]
        self.handlers = [:]
        self.handlerTypes = [:]
        self.jshostHandler = WKJSWebViewHandler(hostname: "jshost")
    }

}

extension WKJSBridge {

    public func register(_ webview: WKWebView) {
        self.webview = webview

        // 注入 js 脚本
        _injectWKJSBridge()

        // jshostHandler 注册 webview
        jshostHandler.register(webview)

        // 向 js 注册 host 处理逻辑
        jshostHandler.register(handle: self._handleAppHost)
        // 注册 native 对 jshost response 的处理
        jshostHandler.register(responseHandle: self._handleResponse)

        // 注册内部事件处理器
        register(jsHandler)
    }

    public func register<M>(_ instance: M) where M: WKJSModule {
        assert(self.modules[M.name] == nil)
        self.modules[M.name] = instance
    }

    public func register<M>(_ interface: M.Type = M.self) where M: WKJSModuleType {
        assert(self.moduleTypes[M.name] == nil)
        self.moduleTypes[M.name] = interface
    }

    public func register<M>(_ instances: [M]) where M: WKJSModule {
        instances.forEach({
            assert(self.modules[type(of: $0).name] == nil)
            self.modules[type(of: $0).name] = $0
        })
    }

    public func register<M>(_ interfaces: [M.Type]) where M: WKJSModuleType {
        interfaces.forEach({
            assert(self.moduleTypes[$0.name] == nil)
            self.moduleTypes[$0.name] = $0
        })
    }

    public func register<H>(_ instance: H) where H: WKJSHandler {
        assert(self.handlers[H.name] == nil)
        self.handlers[H.name] = instance

        assert(self.handleStorages[H.name] == nil)
        let storage = WKJSHandleStorage(name: H.name)
        self.handleStorages[H.name] = storage
        instance.config(with: storage)
    }

    public func register<H>(_ instances: [H]) where H: WKJSHandler {
        instances.forEach { instance in
            assert(self.handlers[type(of: instance).name] == nil)
            self.handlers[type(of: instance).name] = instance

            assert(self.handleStorages[type(of: instance).name] == nil)
            let storage = WKJSHandleStorage(name: type(of: instance).name)
            self.handleStorages[type(of: instance).name] = storage
            instance.config(with: storage)
        }
    }

    public func register<H>(_ interface: H.Type = H.self) where H: WKJSHandlerType {
        assert(self.handlerTypes[H.name] == nil)
        self.handlerTypes[H.name] = interface
    }

    public func register<H>(_ interfaces: [H.Type]) where H: WKJSHandlerType {
        interfaces.forEach({
            assert(self.handlerTypes[$0.name] == nil)
            self.handlerTypes[$0.name] = $0
        })
    }

}

extension WKJSBridge {

    internal static var jsonEncoder = { JSONEncoder() }()

    internal static var jsonDecoder = { JSONDecoder() }()

}

extension WKJSBridge {

    public func postFrom<M>(_ moduleInterface: M.Type = M.self, _ action: (M) -> WKJSMessageMeta?) where M: WKJSModule {
        guard let m = _module(for: moduleInterface.name) as? M,
              let messageMeta = action(m) else { return }

        // 存储 response 并 生成 message
        let message = messageMeta.makeMessage(with: { response in
            let responsePackage = responseContainer.cache(response: response)
            return responsePackage.responseId
        })

        // pending or invoke
        if jsHandler.isReady {
            jshostHandler.invoke(message: message)
        } else {
            pendingMessages.append(message)
        }
    }

    private func _handleAppHost(_ message: WKJSMessage) {
        guard _handler(for: message.module) != nil else { return }

        if message.hasResponse {        // 有回调
            if message.hasParams {      // 含参调用
                let handle: WKJSHandle? = handleStorages[message.module]?.handles[message.action]
                handle?(message.paramsValue, { [weak self] in
                    self?._invokeJSResponse(responseId: message.responseId!, params: $0, error: $1)
                })
            } else {                    // 无参调用
                let handle: WKJSResponseHandle? = handleStorages[message.module]?.responseHandles[message.action]
                handle?({ [weak self] in
                    self?._invokeJSResponse(responseId: message.responseId!, params: $0, error: $1)
                })
            }
        } else {                        // 无回调
            if message.hasParams {      // 含参调用
                let handle: WKJSParamHandle? = handleStorages[message.module]?.paramHandles[message.action]
                handle?(message.paramsValue)
            } else {                    // 无参调用
                let handle: WKJSEmptyHandle? = handleStorages[message.module]?.emptyHandles[message.action]
                handle?()
            }
        }

        _handlePendingMessagesIfNeeded()
    }

    private func _handleResponse(_ message: WKJSResponseMessage) {
        guard let responsePackage = responseContainer.restoreResponse(message.responseId) else { return }
        if message.code == 200 {
            responsePackage.response(message.params, nil)
        } else {
            let error = WKJSError(code: message.code, message: message.message ?? "")
            responsePackage.response(nil, error)
        }
    }

    private func _invokeJSResponse(responseId: Int, params: String?, error: WKJSError?) {
        if let error = error {
            let message = WKJSResponseMessage.errorMessage(responseId: responseId, error: error)
            jshostHandler.invoke(responseMessage: message)
        } else {
            let message = WKJSResponseMessage.message(responseId: responseId, params: params)
            jshostHandler.invoke(responseMessage: message)
        }
    }

    private func _handlePendingMessagesIfNeeded() {
        guard jsHandler.isReady else { return }
        while !pendingMessages.isEmpty {
            let message = pendingMessages.removeFirst()
            jshostHandler.invoke(message: message)
        }
    }

}

extension WKJSBridge {

    private func _module(for name: String) -> WKJSModule? {
        var module = modules[name]
        if module == nil {
            module = moduleTypes[name]?.makeModule(self)
            if let moduleInstance = module {
                modules[type(of: moduleInstance).name] = moduleInstance
            }
        }
        return module
    }

    private func _handler(for name: String) -> WKJSHandler? {
        let handler = handlers[name] ?? handlerTypes[name]?.makeHandler(self)
        if let handlerInstance = handler {
            handlers[type(of: handlerInstance).name] = handlerInstance

            assert(handleStorages[type(of: handlerInstance).name] == nil)
            let storage = WKJSHandleStorage(name: type(of: handlerInstance).name)
            handleStorages[type(of: handlerInstance).name] = storage
        }
        return handler
    }

    private func _injectWKJSBridge() {
        let bundle = Bundle(for: WKJSBridge.self)
        let path = bundle.path(forResource: "WKJSBridge", ofType: "js", inDirectory: "Resources")!
        var script = try! String(contentsOfFile: path)
        script = script.replacingOccurrences(of: "#MACRO_WK_HOST_NAME#", with: jshostHandler.hostname)
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webview?.configuration.userContentController.addUserScript(userScript)
    }

}

extension WKJSBridge: CustomStringConvertible {

    public var description: String {
        var desc: [String] = []

        let appendElements = { (name: String, elements: [String]) in
            desc.append(name)
            if elements.isEmpty {
                desc.append("- none")
            } else {
                desc.append(contentsOf: elements)
            }
        }
        appendElements("Modules:", modules.values.map({ "- \(type(of: $0).name)" }))
        appendElements("ModuleTypes:", moduleTypes.values.map({ "- \($0.name)" }))
        appendElements("Handlers:", handlers.values.map({ "- \(type(of: $0).name)" }))
        appendElements("HandlerTypes:", handlerTypes.values.map({ "- \($0.name)" }))

        return desc.joined(separator: "\n")
    }

}




