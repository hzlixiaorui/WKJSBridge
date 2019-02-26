

internal struct WKJSResponseMessage: Codable {

    internal let code: Int

    internal let responseId: Int

    internal let params: String?

    internal let message: String?

    internal init(code: Int, responseId: Int, params: String? = nil, message: String? = nil) {
        self.code = code
        self.responseId = responseId
        self.params = params
        self.message = message
    }

    static func errorMessage(responseId: Int, error: WKJSError) -> WKJSResponseMessage {
        return WKJSResponseMessage(code: error.code, responseId: responseId, message: error.message)
    }

    static func message(responseId: Int, params: String? = nil) -> WKJSResponseMessage {
        return WKJSResponseMessage(code: 200, responseId: responseId, params: params)
    }

}

extension WKJSResponseMessage {

    internal var hasParams: Bool {
        return params != nil && !(params?.isEmpty ?? true)
    }

    internal var isSuccess: Bool {
        return code == 200
    }

}
