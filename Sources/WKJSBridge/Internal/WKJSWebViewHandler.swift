
/// WKJSWebViewHandler 处理 WKJSWebView 与 WKJSBridged 的交互逻辑
internal class WKJSWebViewHandler: NSObject, WKScriptMessageHandler {

    /// 挂载在 JS 环境中的 host 名称
    let hostname: String

    private var handle: ((WKJSMessage) -> Void)?
    private var responseHandle: ((WKJSResponseMessage) -> Void)?

    private weak var webview: WKWebView?

    internal init(hostname: String) {
        self.hostname = hostname
        super.init()
    }

    internal func register(_ webview: WKWebView) {
        self.webview = webview
        self.webview?.configuration.userContentController.add(self, name: hostname)
    }

    internal func register(handle: @escaping (WKJSMessage) -> Void) {
        self.handle = handle
    }

    internal func register(responseHandle: @escaping (WKJSResponseMessage) -> Void) {
        self.responseHandle = responseHandle
    }

    internal func invoke(message: WKJSMessage) {
        guard let data = try? WKJSBridge.jsonEncoder.encode(message),
              let messageString = String(data: data, encoding: .utf8) else { return }
        let script = "window.wkjsbridge.postMessageToJS(\(messageString));"
        self.webview?.evaluateJavaScript(script, completionHandler: { _, error in
            if error != nil {
                print("[WKJSBridge]: invoke message \(message) with error: \(error!)")
            }
        })
    }

    internal func invoke(responseMessage: WKJSResponseMessage) {
        guard let data = try? WKJSBridge.jsonEncoder.encode(responseMessage),
              let messageString = String(data: data, encoding: .utf8) else { return }
        let script = "window.wkjsbridge.postMessageToJSResponse(\(messageString));"
        self.webview?.evaluateJavaScript(script, completionHandler: { _, error in
            if error != nil {
                print("[WKJSBridge]: invoke message \(responseMessage) with error: \(error!)")
            }
        })
    }

    internal func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == hostname { /* js call native */
            _handleMessage(message)
        }
        if message.name == hostname + "Response" { /* js call native response */
            _handleResponseMessage(message)
        }
    }

    private func _handleMessage(_ message: WKScriptMessage) {
        guard let messageString = message.body as? String,
              let data = messageString.data(using: .utf8),
              let jsMessage = try? WKJSBridge.jsonDecoder.decode(WKJSMessage.self, from: data) else { return }
        handle?(jsMessage)
    }

    private func _handleResponseMessage(_ message: WKScriptMessage) {
        guard let messageString = message.body as? String,
            let data = messageString.data(using: .utf8),
            let jsMessage = try? WKJSBridge.jsonDecoder.decode(WKJSResponseMessage.self, from: data) else { return }
        responseHandle?(jsMessage)
    }

}
