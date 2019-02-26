/* wkjsbridge */
window.wkjsbridge = {};

// native jshost
const WK_HOST_NAME = "#MACRO_WK_HOST_NAME#";
const WK_HOST_RESPONSE_NAME = WK_HOST_NAME + "Response";

// wkjsbridge模块逻辑
window.wkjsbridge.modules = {}

/*
    @public native 调用 js

        window.wkjsbridge.postMessageToJS(message);
*/
Object.defineProperty(window.wkjsbridge, "postMessageToJS", {
    writable: false,
    value: function(message) {
        var moduleName = message.module;
        var actionName = message.action;
        var params = JSON.parse(message.params).data;
        var responseId = message.responseId;
        // 调用handler
        window.wkjsbridge.modules[moduleName][actionName].forEach(function(handler) {
            var args = []
            if (params) {
                args.push(params);
            }
            if (responseId) {
                 /* response: responseParams = {
                     responseId: Number,
                     code: Number,
                     params: { data: Object },
                     message: String
                 }
                 */
                args.push(function(responseParams) {
                    var responseMessage = {};
                    responseMessage.responseId = responseId;
                    responseMessage.code = responseParams.code;
                    responseMessage.params = JSON.stringify({ data: responseParams.params });
                    responseMessage.message = responseParams.message;
                    window.webkit.messageHandlers[WK_HOST_RESPONSE_NAME].postMessage(responseMessage);
                });
            }
            handler(...args);
        })
    }
});

/*
 @public native 调用 js response

 window.wkjsbridge.postMessageToJSResponse(responseMessage);
 */
Object.defineProperty(window.wkjsbridge, "postMessageToJSResponse", {
    writable: false,
    value: function(message) {
        var responseId = message.responseId;
        var responseHandler = window.wkjsbridge._responseStorage.popResponse(responseId);
        /* js responseHandler拿到的参数
            {
             code: Number,
             params: Object,
             message: String
            }
         */
        responseHandler({
            code: message.code,
            params: JSON.parse(message.params).data,
            message: message.message
        });
    }
});

/*
    @public js 注册处理逻辑，同一个module和action可以注册多个handler，类似 NodeJS 的 EventEmitter

        window.wkjsbridge.on("module", "action", function(params, callback) {
            // handle action
        });
*/
Object.defineProperty(window.wkjsbridge, "on", {
    writable: false,
    value: function(moduleName, actionName, handler) {
        var moduleDic = window.wkjsbridge.modules[moduleName];
        moduleDic = moduleDic ? moduleDic : {};

        var actionArray = moduleDic[actionName];
        actionArray = actionArray ? actionArray : [];

        actionArray.push(handler);
    }
});

/*
    @public js 调用 native

        window.wkjsbridge.postMessageToNative("module", "action", params, callback);
*/
Object.defineProperty(window.wkjsbridge, "postMessageToNative", {
    writable: false,
    value: function(moduleName, actionName, ...args) {
        /* WKJSBridge 传递 message = {
             module: String,
             action: String,
             responseId: Number,
             params: { data: Object }
         }
         */
        var message = {
            module: moduleName,
            action: actionName
        };
        args.forEach(function(arg) {
            if (typeof arg === "function") {
                // 存储response，传递responseId
                message.responseId = window.wkjsbridge._responseStorage.storeResponse(arg);
            } else {
                message.params = JSON.stringify({ data: params });
            }
        });
        window.webkit.messageHandlers[WK_HOST_NAME].postMessage(message);
    }
});

/*
 @public 通知 native js 准备好了
 */
Object.defineProperty(window.wkjsbridge, "notiJSReady", {
    writable: false,
    value: function() {
        window.wkjsbridge.postMessageToNative("_WKJSHandler", "notiJSReady");
    }
});

// response 存储逻辑
window.wkjsbridge._responseStorage = {};
window.wkjsbridge._responseStorage.id = 0;
window.wkjsbridge._responseStorage.handlers = {}

/*
 @private js 存储response
    @return responseId

     window.wkjsbridge.storeResponse(responseHandler);
 */
Object.defineProperty(window.wkjsbridge._responseStorage, "storeResponse", {
    writable: false,
    value: function(handler) {
        var currentId = ++window.wkjsbridge._responseStorage.id;
        window.wkjsbridge._responseStorage.handlers[currentId] = handlers;
        return currentId;
    }
});

/*
 @private 根据 id 返回 response
    @return response

     window.wkjsbridge.postMessageToNative("module", "action", params, callback);
 */
Object.defineProperty(window.wkjsbridge._responseStorage, "popResponse", {
    writable: false,
    value: function(id) {
        var handler = window.wkjsbridge._responseStorage.handlers[id];
        delete window.wkjsbridge._responseStorage.handlers[id];
        // 如果全部pop，则重置 id
        if (Object.keys(window.wkjsbridge._responseStorage.handlers).length === 0) {
            window.wkjsbridge._responseStorage.id = 0;
        }
        return handler;
    }
});
