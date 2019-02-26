

/// 回调
public typealias WKJSResponse = (String?, WKJSError?) -> Void

/// 完整的handle，带参数和response
public typealias WKJSHandle = (String, @escaping WKJSResponse) -> Void

/// 带参handle
public typealias WKJSParamHandle = (String) -> Void

/// 带response的handle
public typealias WKJSResponseHandle = (@escaping WKJSResponse) -> Void

/// 无参回调
public typealias WKJSEmptyHandle = () -> Void

/// handler注册逻辑
public protocol WKJSHandleContainer {

    func register(_ action: String, for handle: @escaping WKJSHandle)

    func register(_ action: String, for handle: @escaping WKJSParamHandle)

    func register(_ action: String, for handle: @escaping WKJSResponseHandle)

    func register(_ action: String, for handle: @escaping WKJSEmptyHandle)

}
