
internal struct WKJSResponsePackage {

    let responseId: Int

    let response: WKJSResponse

}

extension WKJSResponsePackage: Hashable {

    static func == (lhs: WKJSResponsePackage, rhs: WKJSResponsePackage) -> Bool {
        return lhs.responseId == rhs.responseId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(responseId)
    }

}
