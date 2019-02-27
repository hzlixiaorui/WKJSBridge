
/// WKJSModule
///
/// 用于声明一个 处理JS逻辑 的模块
public protocol WKJSHandler {

    static var name: String { get }

    /// 配置 container 用于注册 handler方法到 container中，WJSBridge会在合适时机调用
    func config(with container: WKJSHandleContainer)

}

extension WKJSHandler {

    public static var name: String {
        return String(describing: Self.self)
    }

    public func config(with container: WKJSHandleContainer) {}

}

public protocol WKJSHandlerType: WKJSHandler {

    static func makeHandler(_ bridge: WKJSBridge) -> Self

}
