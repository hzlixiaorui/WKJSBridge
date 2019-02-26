

internal class WKJSHandleStorage {

    internal let name: String

    internal var handles: [String: WKJSHandle] = [:]

    internal var paramHandles: [String: WKJSParamHandle] = [:]

    internal var responseHandles: [String: WKJSResponseHandle] = [:]

    internal var emptyHandles: [String: WKJSEmptyHandle] = [:]

    init(name: String) {
        self.name = name
    }

}

extension WKJSHandleStorage: WKJSHandleContainer {

    public func register(_ action: String, for handle: @escaping WKJSHandle) {
        handles[action] = handle
    }

    public func register(_ action: String, for handle: @escaping WKJSParamHandle) {
        paramHandles[action] = handle
    }

    public func register(_ action: String, for handle: @escaping WKJSResponseHandle) {
        responseHandles[action] = handle
    }

    public func register(_ action: String, for handle: @escaping WKJSEmptyHandle) {
        emptyHandles[action] = handle
    }

}

extension WKJSHandleStorage {

    func merge(_ storage: WKJSHandleStorage) {
        handles.merge(storage.handles, uniquingKeysWith: { $1 })
        paramHandles.merge(storage.paramHandles, uniquingKeysWith: { $1 })
        responseHandles.merge(storage.responseHandles, uniquingKeysWith: { $1 })
        emptyHandles.merge(storage.emptyHandles, uniquingKeysWith: { $1 })
    }

}

extension WKJSHandleStorage: CustomStringConvertible {

    var description: String {
        var desc: [String] = []

        let appendElements = { (name: String, elements: [String]) in
            desc.append(name)
            if elements.isEmpty {
                desc.append("- none")
            } else {
                desc.append(contentsOf: elements)
            }
        }
        appendElements("handles:", handles.keys.map({ " - \($0)" }))
        appendElements("paramHandles:", paramHandles.keys.map({ " - \($0)" }))
        appendElements("responseHandles", responseHandles.keys.map({ " - \($0)" }))
        appendElements("emptyHandles", emptyHandles.keys.map({ " - \($0)" }))

        return desc.joined(separator: "\n")
    }

}
