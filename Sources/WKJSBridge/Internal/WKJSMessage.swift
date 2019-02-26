

internal struct WKJSMessage: Codable {

    internal let module: String

    internal let action: String

    internal let params: String?

    internal let responseId: Int?

    internal init(module: String, action: String, params: String? = nil, responseId: Int? = nil) {
        self.module = module
        self.action = action
        self.params = params
        self.responseId = responseId
    }

}

extension WKJSMessage {

    internal var hasParams: Bool {
        return params != nil && !(params?.isEmpty ?? true)
    }

    internal var hasResponse: Bool {
        return responseId != nil
    }

    internal var paramsValue: String {
        return params ?? ""
    }

}
