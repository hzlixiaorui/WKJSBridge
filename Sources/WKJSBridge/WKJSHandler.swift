

public protocol WKJSHandler {

    static var name: String { get }

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
