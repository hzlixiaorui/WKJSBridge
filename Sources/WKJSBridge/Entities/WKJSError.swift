
public struct WKJSError: LocalizedError, CustomStringConvertible {

    public let code: Int

    public let message: String

    public var errorDescription: String? {
        return description
    }

    public var description: String {
        return "[WKJSBridge]: Error code: \(code), message: \(message)"
    }

    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }

}
