
/// 发送至 JS 的 message
public struct WKJSMessageMeta {

    /// 模块名
    public let module: String

    /// 方法名
    public let action: String

    /// 参数
    public let params: Codable?

    /// 回调
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

    /// 转换为真正的 message
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

