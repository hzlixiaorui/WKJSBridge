
extension String {

    /// 将 String 解析为参数
    public func decodeWKJSParams<T>(to param: T.Type) -> T? where T: Decodable {
        guard let data = self.data(using: .utf8),
              let param = try? WKJSBridge.jsonDecoder.decode(WKJSDecodeParam<T>.self, from: data) else { return nil }
        return param.data
    }

}

extension Encodable {

    /// 编译参数为String
    public var encodeWKJSParams: String {
        return WKJSEncodeParam<Self>(data: self).encodeWKJSString
    }

}

fileprivate struct WKJSDecodeParam<Data>: Decodable where Data: Decodable {

    fileprivate let data: Data

}

fileprivate struct WKJSEncodeParam<Data>: Encodable where Data: Encodable {

    fileprivate let data: Data

}

extension WKJSEncodeParam {

    fileprivate var encodeWKJSString: String {
        guard let data = try? WKJSBridge.jsonEncoder.encode(self) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

}
