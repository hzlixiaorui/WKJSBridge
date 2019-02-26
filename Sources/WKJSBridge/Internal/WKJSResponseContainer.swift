

internal class WKJSResponseContainer {

    private var generator = WKJSIDGenerator()

    private var packages: [Int: WKJSResponsePackage] = [:]

    internal func cache(response: @escaping WKJSResponse) -> WKJSResponsePackage {
        let responseId = generator.next()
        let package = WKJSResponsePackage(responseId: responseId, response: response)
        packages[responseId] = package
        return package
    }

    internal func restoreResponse(_ id: Int) -> WKJSResponsePackage? {
        let package = packages.removeValue(forKey: id)
        if packages.isEmpty {
            generator.reset()
        }
        return package
    }

}

extension WKJSResponseContainer: CustomStringConvertible {

    internal var description: String {
        return """
        Generator: \(generator)
        CurrentResponses: \(packages.keys)
        """
    }

}

internal class WKJSIDGenerator {

    private var _storage: Int = 0

    internal func next() -> Int {
        defer { _storage += 1 }
        return _storage
    }

    @inline(__always)
    internal func reset() {
        _storage = 0
    }

}

extension WKJSIDGenerator: CustomStringConvertible {

    internal var description: String {
        return "currentId--\(_storage)"
    }

}
