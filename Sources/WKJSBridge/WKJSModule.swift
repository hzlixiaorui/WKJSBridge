

/// WKJSModule
///
/// 用于声明一个调用 JS 的模块逻辑
public protocol WKJSModule {

    /// 模块名称
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
