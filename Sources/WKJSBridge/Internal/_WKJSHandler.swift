
/// 默认注册的 handler，用于处理 JSReady 逻辑
internal final class _WKJSHandler: WKJSHandlerType {

    private(set) var isReady: Bool = false

    internal static func makeHandler(_ bridge: WKJSBridge) -> _WKJSHandler {
        return _WKJSHandler()
    }

    internal func config(with container: WKJSHandleContainer) {
        container.register("notiJSReady", for: self.notiJSReady)
    }

    internal func notiJSReady() {
        isReady = true
    }

}
