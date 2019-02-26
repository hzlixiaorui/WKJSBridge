

public protocol WKJSModule {

    static var name: String { get }

}

extension WKJSModule {

    public static var name: String   {
        return String(describing: Self.self)
    }

    public func makeMessage(action: String, params: Codable? = nil, response: WKJSResponse? = nil) -> WKJSMessageMeta {
        return WKJSMessageMeta(module: Self.name, action: action, params: params, response: response)
    }

}

public protocol WKJSModuleType: WKJSModule {

    static func makeModule(_ bridge: WKJSBridge) -> Self

}
