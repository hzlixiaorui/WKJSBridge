# WKJSBridge

A type-safe JSBridge for WKWebView build on pure Swift.  
一个用 Swift 实现的用于WKWebView的 类型安全的 JSBridge。

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

Install:  
创建 JSBridge，并注册 webview

```swift
import WebKit
import WKJSBridge

let webview = WKWebView(frame: .zero)
let jsbridge = WKJSBridge()

jsbridge.register(webview)
```

Declare your module or handler:  
声明一个调用 JS 的模块逻辑和一个处理 JS 逻辑的模块

```swift
// your native module
final class PreferenceControl: WKJSModuleType {

    static func makeModule(_ bridge: WKJSBridge) -> PreferenceControl {
        return PreferenceControl()
    }
    
    // tell JS scroll to some area
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

    // register handle
    func config(with container: WKJSHandleContainer) {
        container.register("getCurrentTheme", for: self.getCurrentTheme)
    }

    // handle JS getCurrentTheme action and resopons
    func getCurrentTheme(_ response: @escaping WKJSResponse) {
        let currentTheme = hostVC?.view.effectiveAppearance.theme ?? .aqua
        response(currentTheme.rawValue.encodeWKJSParams, nil)
    }

}
```

Register module & handler:  
将声明好的模块注册到 bridge

```swift
jsbridge.register(PreferenceControl.self)
jsbridge.register(ThemePrefHandler.self)
```

Native call JS:
native 在合适的时机调用模块的方法

```swift
jsbridge.postFrom(PreferenceControl.self) { $0.scroll(to: .about) }
```
## Your js code

Declear handler:  
JS 声明 native 模块的处理逻辑，类似 NodeJS 的 Event，支持注册多次

```js
window.wkjsbridge.on("PreferenceControl", "scrollToArea", function() {
    // handle action
});
```

JS call Native:  
JS 调用 native 的 handler 模块

```js
window.wkjsbridge.postMessageToNative("ThemePrefHandler", "getCurrentTheme", function(message) {
    console.log(message.code);
    console.log(message.message);
    console.log(message.params);
});
```

## What's more?

* Parameters: 参数类型安全，调用参数符合`Codable`协议即可，response参数使用`encodeWKJSParams`
* Response: 支持双向回调
* Pendings on JSReady: 支持 JSReady 逻辑，JS 逻辑准备完成后可以通过`window.wkjsbridge.notiJSReady();`通知 native
* Type safe: 类型安全
* ...

## TODO:

* 支持 native 与 JS 模块及方法实现双向查询
* 默认 handler 模块支持更多 JS 生命周期逻辑
* ...

