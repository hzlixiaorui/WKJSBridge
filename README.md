# WKJSBridge

A type-safe JSBridge for WKWebView with pure Swift.

# How to install

CocoaPods

```rb
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'WKJSBridge', '~> 0.0.1'
end
```

# How to usage

## Your native code:

Install

```swift
import WebKit
import WKJSBridge

let webview = WKWebView(frame: .zero)
let jsbridge = WKJSBridge()

jsbridge.register(webview)
```

Declare your module or handler:

```swift
// your native module
final class PreferenceControl: WKJSModuleType {

    static func makeModule(_ bridge: WKJSBridge) -> PreferenceControl {
        return PreferenceControl()
    }
    
    func scroll(to area: Area) -> WKJSMessageMeta {
        return self.makeMessage(action: "scrollToArea", params: area)
    }

}

// your js module handler
final class ThemePrefHandler: WKJSHandlerType {

    private weak var hostVC: NSViewController?

    static func makeHandler(_ bridge: WKJSBridge) -> ThemePrefHandler {
        let hostVC = bridge.webview?.window?.contentViewController
        return ThemePrefHandler(hostVC: hostVC)
    }

    init(hostVC: NSViewController?) {
        self.hostVC = hostVC
    }

    // register
    func config(with container: WKJSHandleContainer) {
        container.register("getCurrentTheme", for: self.getCurrentTheme)
    }

    func getCurrentTheme(_ response: @escaping WKJSResponse) {
        let currentTheme = hostVC?.view.effectiveAppearance.theme ?? .aqua
        response(currentTheme.rawValue.encodeWKJSParams, nil)
    }

}
```

Register module & handler:

```swift
jsbridge.register(PreferenceControl.self)
jsbridge.register(ThemePrefHandler.self)
```

Native call JS:

```swift
jsbridge.postFrom(PreferenceControl.self) { $0.scroll(to: .about) }
```
## Your js code

Declear handler:

```js
window.wkjsbridge.on("PreferenceControl", "scrollToArea", function() {
    // handle action
});
```

JS call Native:

```js
window.wkjsbridge.postMessageToNative("ThemePrefHandler", "getCurrentTheme", function(message) {
    console.log(message.code);
    console.log(message.message);
    console.log(message.params);
});
```

## What's more?

* Parameters
* Response
* Pendings on JSReady
* Type safe
* ...

