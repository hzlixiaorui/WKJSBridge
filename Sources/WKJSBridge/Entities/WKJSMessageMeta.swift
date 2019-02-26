
public struct WKJSMessageMeta {

    public let module: String

    public let action: String

    public let params: Codable?

    public let response: WKJSResponse?

    public init(module: String, action: String, params: Codable? = nil, response: WKJSResponse? = nil) {
        self.module = module
        self.action = action
        self.params = params
        self.response = response
    }

}

extension WKJSMessageMeta {

    internal var hasParams: Bool {
        return params != nil
    }

    internal var hasResponse: Bool {
        return response != nil
    }

    internal func makeMessage(with responseCacher: (@escaping WKJSResponse) -> Int) -> WKJSMessage {
        let paramsString = params?.encodeWKJSParams
        if let response = response {
            let resposneId = responseCacher(response)
            return WKJSMessage(module: module, action: action, params: paramsString, responseId: resposneId)
        } else {
            return WKJSMessage(module: module, action: action, params: paramsString, responseId: nil)
        }
    }

}

