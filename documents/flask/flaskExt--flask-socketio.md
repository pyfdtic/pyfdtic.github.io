---
title: Flask 扩展之--flask-socketio
date: 2018-03-16 16:43:43
categories:
- Python
tags:
- Flask
- Flask 扩展
- socketio
- websocket
---

WebSocket 可以实现客户端与服务器之间的双向的, 基于消息的文本或二进制数据传输. 其极简的 API 可以让我们在客户端和服务器之间以数据流的形式实现各种应用数据交换(包含JSON 及自定义的二进制消息格式). 自定义数据交换协议的问题通常也在于自定义, 因为应用必须考虑状态,压缩,缓存及其原来有浏览器提供的服务.

功能:

- 连接协商和同源策略
- 与既有HTTP基础设施的互操作
- 基于消息的通信和高效消息分帧
- 子协议协商及可扩展能力

WebSocket 由多个标准组成:
- WebSocket API 有 W3C 定义;
- WebSocket 协议(RFC 6455) 及其扩展由 IETF 定义

# 一. WebSocket 协议
## 1. WebSocket API

### 1.1 代码示例
    
    var ws = new WebSocket("wss://example.com/socket")  // 建立安全的 ws 连接
    ws.onerror = function(error) { ... }        // 可选回调, 在连接出错时调用
    ws.oncloes = function() { ... }             // 可选回调, 在连接关闭时调用

    ws.onopen = function () {                   // 可选回调, 在连接建立时调用
        ws.send("Connection established, Hello Server!")    // 客户端向服务器发送一条消息
    }

    ws.onmessage = function(msg) {          // 回调函数, 服务器每发送一条消息就调用一次.
        if (msg.data instanceof Blob) {     // 判断接收到的消息是二进制还是文本处理.
            processBlob(msg.data)
        } else {
            processText(msg.data)
        }
    }

在选择 Socket.IO 这样的腻子脚本或"实时框架"时, 一定要留心其底层实现, 以及客户端和服务器的配置: 保证尽可能利用原生 WebSocket 接口以求最佳性能, 然后确保备用传输机制能满足你的性能要求.


### 1.2 WS 与 WSS
WebSocket 资源 URL 采用了自定义模式:

1. ws 表示 存文本 通信.
2. wss 表示使用加密信道通信(TCP+TLS)

### 1.3 接收文本和二进制数据
WebSocket 通信只涉及消息, 应用代码无需担心缓冲,解析,重建接收到的数据. 如 服务器发送一个 1MB 的净荷, 应用的 `onmessage` 回调只会在客户端接收到全部数据时才会被调用.

WebSocket 协议不做格式假设, 对应用的净荷也没有后限制: 文本或者二进制数据都可以. 从内部看, 协议只关注消息的两个信息: **净荷长度(一个可变长度字段)** 和 **数据类型**, 据以区别 UTF-8 数据和 二进制数据.

- 文本数据 : 浏览器会自动将其转换为 DOMString 对象.
- 二进制数据或 Blob 对象: 将其直接转交给应用. 或者 告诉浏览器把接收到的二进制数据转换成 ArrayBuffer 而非 Blob.

        var ws = new WebSocket('wss://example.com/socket');
        // 如果接收到二进制数据, 则强制转换为 ArrayBuffer.
        ws.binaryType = "arraybuffer";      

        ws.onmessage = function(msg) {
            if (msg.data instanceof ArrayBuffer) {
                processArrayBuffer(msg.data);
            } else {
                processText(msg.data);
            }
        }

Blob 代表一个不可变的文件对象或者原始数据. 通常用于处理**无需修改或者切分**的数据块.

ArrayBuffer 表示一个普通的,固定长度的二进制数据缓冲, 通常用于接受需要**再次处理的二进制数据**. 可以用 ArrayBuffer 创建一个或多个 ArrayBufferView 对喜爱那个, 每一个都可以通过特定的格式来展示缓冲中的内容.

所有二进制数据类型只是为了简化 API :  在传输中, 只通过一位 (bit) 即可将 WebSocket 帧标记为二进制或文本. 假如应用或服务器需要传输其他的内容类型, 就必须通过其他机制来沟通这个信息.

### 1.4 发送文本和二进制数据
WebSocket 提供的是一个双向通信的信道, 即, 在同一个 TCP 连接上, 可以双向传输数据.

    var ws = new WebSocket("wss://example.com/socket")

    ws.open = function() {
        socket.send("hello server!");
        socket.send(JSON.stringify({'msg': 'payload'}));

        var buffer = new ArrayBuffer(128);
        socket.send(buffer);

        var intview = new Unit32Array(buffer):
        socket.send(intview)

        var blob = new Blob(buffer);
        socket.send(blob);
    }

这里 `send()` 方法是异步的: 提供的数据会在客户端排队, 而函数则立即返回. 特别是在传输大文件的时候, 千万别因为返回快, 就错误的以为数据已经发送出去了. 要监控在浏览器中排队的数据量, 可以查询套接字的 `bufferdAmount` 属性
    
    var ws = new WebSocket("wss://example.com/socket")

    ws.onopen = function() {
        subscribeToApplicationUpodates(function(env) {
            if (ws.bufferedAmount == 0)
                ws.send(evt.data);
        });
    };

所有 WebSocket 消息都会按照他们在客户端排队的次序逐个发送. 因此, 大量排队的消息, 甚至一个大消息, 都可能导致排在他后面的消息延迟-- **队首阻塞**.

为解决该问题, 应用可以将大消息切分成小块, 通过监控`bufferedAmount`的值来避免队首阻塞. 甚至还可以实现自己的优先队列, 而不是盲目都把他们送到套接字上排队. 要实现最优化传输, 应用必须关心任意时刻在套接字上排队的是什么消息.


### 1.5 子协议协商

#### 1.5.1 子协议协商实现策略

WebSocket 协议对每条消息的格式实现不做任何假设, 仅用一位标记消息是文本还是二进制, 以便客户端和服务器有效的解码数据, 除此之外的消息内容就是未知的.

WebSocket 没有实现元数据沟通的机制, 如果需要沟通关于消息的元数据, 客户端和服务器必须达成沟通这一数据的子协议. 可以有以下实现方式:

- 客户端和服务器可以提前确定一种固定的消息格式.而 必要的元数据作为这种数据结构的一部分.
- 如果客户端和服务器要发送不同的数据类型, 那么他们可以确定一个双发都知道的消息首部, 利用它来沟通说明信息或有关净荷的其他解码信息.
- 混合使用文本和二进制消息, 可以沟通净荷和元数据, 比如用文本消息实现 HTTP 首部的功能, 后跟包含应用净荷的二进制消息.


#### 1.5.2 子协议协商API
客户端可以在初次链接握手时, 告诉服务器自己支持那种协议.

    var ws = new WebSocket('wss://example.com/socket', ['appProtocol', 'appProtocol-v2'])       // 在 WebSocket 握手期间发送子协议数组.

    ws.onopen = function () {
        if (ws.protocol == "appProtocol-v2") {  // 检查服务器选择了那个子协议
            // ...
        } else {
            // ...
        }
    }

子协议有应用自己定义, 且在初次 HTTP 握手期间发送给服务器, 除此之外, 指定的子协议对核心 WebSocket API 不会有任何影响.

如果子协议协商成功, 会触发客户端的 `onopen` 回调, 应用可以查询 WebSocket 对象上的 `protocol` 属性, 从而得知服务器选定的协议. 另一方面, 服务器如果不支持客户端声明的任何一个协议, 则 WebSocket 握手时不完整的, 此时会触发 `onerror` 回调, 连接断开.  
## 2. WebSocket 协议
WebSocket 协议包含两个高层组件:
1. 开放性 HTTP 握手 , 用于协商连接参数
2. 二进制消息分帧, 用于支持低开销的基于消息的文本和二进制数据传输.

WebSocket 协议尝试在既有 HTTP 基础设施中实现双向的 HTTP 通信, 因此, 也是用 HTTP 的 80 和 443 端口. WebSocket 协议是一个独立完善的协议, 可以在浏览器之外实现.

### 2.1 二进制分帧
客户端和服务器 WebSocket 应用通过基于**消息**的 API 通信: 发送端提供任意 UTF-8 或二进制的净荷, 接收端**整个**消息可用时收到通知. 为此, WebSocket 使用了自定义的二进制分帧格式, 把每个应用消息切分成一个或多个帧, 发送到目的地之后再组装起来, 等接收到完整的消息后, 再通知接收端.

所有 WebSocket 通信都是通过交换帧实现的, 而帧将净荷视为不透明的应用数据块.

![WebSocket帧格式: 2-14字节 + 净荷](http://oluv2yxz6.bkt.clouddn.com/websocket%E4%BA%8C%E8%BF%9B%E5%88%B6%E5%88%86%E5%B8%A7.PNG)

- 帧 : 最小的通信单位, 包含可变长度的帧首部和净荷部分, 净荷可能包含完整或部分应用消息. 是否把消息分帧由客户端和服务器实现决定.
- 消息, 一系列帧, 与应用消息对等.
- 每一帧的第一位(FIN), 表示当前帧是不是消息的最后一帧, 一条消息有可能只有对应一帧.
- 操作码(4位), 表示被传输帧的类型, 
    
    - 传输应用数据时
        - 1 : 文本
        - 2 : 二进制数据

    - 连接有效性检查时
        - 8 : 关闭
        - 9 : 呼叫(ping)
        - 10 : 回应(pong)
- 掩码位, 表示净荷是否有掩码(只适用于客户端发送给服务器的消息)
- 净荷长度, 有可可变长度字段表示
    - 1 ~ 125 : 净荷长度
    - 126 : 则接下来的 2 字节表示的 16 位无符号整数才是这一帧的长度
    - 127 : 则接下来的 8 字节表示的 64 位无符号整数才是这一帧的长度

- 掩码键, 包含 32 位值, 用于给净荷加掩护
- 净荷包含应用数据, 如果客户端和服务器在建立连接时协商过, 也可以包含自定义的扩展数据.

### 2.2 协议扩展
WebSocket 规范允许对协议进行扩展: 数据格式和 WebSocket 协议的语义可以通过新的操作码和数据字段扩展. 即, 允许客户端和服务器在基本的 WebSocket 分帧层之上实现更多的功能, 而无需应用代码介入或协作.

协议扩展:
- 多路复用扩展 : 可以将 WebSocket 的逻辑链接独立出来, 实现共享底层的 TCP 链接.
- 压缩扩展 : 为 WebSocket 协议添加了压缩功能.

### 2.3 HTTP 协议(握手)协商

利用 HTTP 完成握手, 有多个好处:
- 让 WebSocket 与现有 HTTP 协议基础设置兼容. 让 WebSocket 可以运行在 80 或 443 端口.
- 可以重用并扩展 HTTP 的 Upgrade 流, 为其添加自定义的 WebSocket 首部, 已完成协商.

#### 2.3.1 可用 HTTP 首部
以下协商字段, 用于在客户端和服务器之间进行 HTTP Upgrade 并协商新的 WebSocket 连接 : 

- Sec-WebSocket-Version : 客户端发送, 表示其使用的 WebSocket 协议版本(13 表示 RFC 6455). 如服务器不支持该版本, 则必须回应自己支持的版本.

- Sec-WebSocket-Key : 客户端发送, 自动生成的一个键, 作为一个对服务器的"挑战", 以验证服务器支持的协议版本.

- Sec-WebSocket-Accept : 服务器响应, 包含 Sec-WebSocket-Key 的签名值, 证明他支持请求的协议版本.

- Sec-WebSocket-Protocol : 用于协商应用子协议: 客户端发送支持的协议列表, 服务器必须只回应一个协议名.

- Sec-WebSocket-Extensions : 用于 协商本次链接要使用的 WebSocket 扩展: 客户端发送支持的扩展, 服务器通过返回相同的首部, 确认自己支持一个或多个扩展.

HTTP 协商示例:
    
    GET /socket HTTP/1.1
    Host: thirdparty.com
    Origin: http://example.com
    Connection: Upgrade             
    Upgrade: websocket              // 请求升级到 WebSocket
    Sec-WebSocket-Version: 13       // 客户端使用的 WebSocket 协议版本
    Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==  // 自动生成的键, 以验证服务器对协议的支持.
    Sec-WebSocket-Protocol: appProtocol, appProtocol-v2     // 可选的应用指定的子协议列表
    Sec-WebSocket-Extensions: x-webkit-deflate-message,x-custom-extension   // 可选的客户端支持的协议扩展列表.

WebSocket 请求也必须遵守同源策略: 浏览器会自动在升级握手请求中追加 Origin 首部, 远程服务器可能使用 CORS 判断接受或拒绝跨源请求. 

要完成握手, 服务器必须返回一个成功的 "Switching Protocols(切换协议)"  响应, 并确认选择了客户端发送的那个选项:
    
    HTTP/1.1 101 Switching Protocol     // 101 响应确认升级到 websocket 协议.
    Upgrade: websocket
    Connection: Upgrade
    Acess-Control-Allow-Origin: http://example.com  // CORS 首部表示选择同意跨源链接
    Sec-WebSocket-Accept: s3pPLmBiTxaQ9kYGzzhZRbk+x0o   // 签名的键值验证协议支持.
    Sec-WebSocket-Protocol: appProtocol-v2  // 服务器选择的应用子协议
    Sec-WebSocket-Extensions: x-custom-extension    // 服务器选择的 WebSocket 扩展.

所有兼容 RFC 6455 的 WebSocket 服务器都使用相同的算法计算客户端挑战的答案: 将 Sec-WebSocket-Key 的内容与标准定义的唯一的 GUID 字符串拼接起来, 计算出 SHA1 散列值, 结果是一个 base-64 编码的字符串, 将这个字符串发送给客户端即可.

握手成功后, 该连接就可以作为双向通信信道交换 WebSocket 消息, 客户端和服务器之间的通信有 WebSocket 协议接管.

## 3. 性能检查表

- 使用安全 WebSocket 
- 密切关注 腻子脚本的性能
- 利用子协议协商确定应用协议
- 优化二进制净荷以最小化传输数据
- 考虑压缩 UTF-8 内容
- 设置正确的二进制类型以接受二进制净荷
- 监控客户端缓冲数据的量
- 切分应用消息以避免队首阻塞
- 合用的情况下, 利用其它传输机制.


# 二. Flask-socketio
## 1. [初始化](https://flask-socketio.readthedocs.io/en/latest/)

    from flask import Flask, render_template
    from flask_socketio import SocketIO

    app = Flask(__name__)
    app.config["SECRET_KEY"] = 'secret!'
    socketio = SocketIO(app)

    if __name__ == "__main__":
        socketio.run(app[,host="0.0.0.0"])


The `init_app()` style of initialization is also supported.

**Note the way the web server is starded.**

The `socketio.run()` function encapsulates the start up of the web server and replaces the `app.run()` standard Flask development server start up. 

When the application is in debug mode the Werkzeug development server is still uead and configured properly inside `socketio.run()`.

In production mode the eventlet web server is used if available , else the gevent web server is used. If eventlet and gevent are not installed , the Werkzeug development web server is used.

client page:

    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/socket.io/1.3.6/socket.io.min.js"></script>
    <script type="text/javascript" charset="utf-8">
        var socket = io.connect('http://' + document.domain + ':' + location.port);
        socket.on('connect', function() {
            socket.emit('my event', {data: 'I\'m connected!'});
        });
    </script>

## 2. socketio handler function
### 2.1 装饰器模式
    
    @socketio.on("my event")
    def handle_my_custom_event(json):
        print "Reveived json: " + str(json)

### 2.2 on_event() 方法
    
    def my_function_handler(data):
        pass

    socketio.on_event("my event", my_function_handler, namespace="/test")


## 3. 接受消息
When using SocketIO, messages are received by both parties as **events**. On the client side Javascript callbacks are used. With Flask-SocketIO the server needs to register handlers for these events, similarly to how routes are hanled by view function.

### 3.1 unnamed events
#### 3.1.1 String date
    
    @socketio.on('message')
    def hanle_message(message):
        print "Received message:" + message

#### 3.1.2 JSON data
    
    @socketio.on('json')
    def handle_json(json):
        print "Received JSON:" + str(JSON)

### 3.2 Custom Names events
The message data for these events can be string, byes, int, or JSON.

    @socketio.on("my event")
    def handle_my_custom_event(json):
        print "Received json": str(json)


    # multiple arguments:
    @socketio.on("my event")
    def handle_my_custom_event(arg1,arg2,arg3):
        print "Received args: " + arg1 + arg2 + arg3

Names events are the most flexible , as they eliminate the need to include additional metadata to describe the message type.

Event names `connect`, `disconnect`, `message`, `json` are special events generated by SocketIO. Any other event names are considered custom events.

The `connect` and `disconnect` events are self-explanatory. The `message` event delivers a payload of type string, and the `json` and custom events deliver a JSON payload, in the form of a Python dictionary.

### 3.3 SocketIO namespaces

Namespaces allow a client to open multiple connections to the server that are multiplexed on a single socket. When a namespace is not specified the events are attached to the default global namespace.

#### 3.3.1 Decorator-Based Namespace
SocketIO namespace allow the client to multiplex several independent connections on the same physical socket:
    
    @socketio.on("my event", namespace="/test")
    def handle_my_custom_namespace_event(json):
        print "Received json: " + str(json)

When a namespace is not specified a default global namespace with the name '/' is used.

#### 3.3.2 Class-Based Namespaces
The events handlers that belong to a namespace cna be created as methods of a class. The `flask_socketio.Namespace()` is provided as a base class to create class-based namespaces:
    
    from flask_socketio import Namespace, emit

    class MyCustomNamespace(Namespace):
        def on_connect(self):
            pass

        def on_disconnect(self):
            pass

        def on_my_event(self, data):
            emit("my_response", data)

    socketio.on_namespace(MyCustomNamespace("/test"))

当使用基于类的名称空间时, 所有服务器收到的 events 都会被分发给 **on_EVENT-NAME** 的方法去处理. 没有该方法, 则该 events 被忽略. 因此, 在基于类的名称空间中,所有 evnet 的名称必须同时也是合法的方法名称.

As a convenience to methods defied in a class-based namespace, the namespace instance includes versions of several of the methods in the `flask_socketio.SocketIO` class that default to the proper namespace when the `namespace` argument is not given.

如果一个 event 同时被 基于类的名称空间和 基于装饰器的名称空间 所定义, 则 **基于装饰器的名称空间拥有更高的优先级**.

### 3.4 return && client callback function

Clients may request an acknowledgement callback that confirm receipt of a message . **Any values returned from the handler function will be passed to the client as arguments  in the callbak function**:
    
    @socketio.on("my event")
    def handle_my_custom_event(json):
        print "received json: " + str(json)
        return "one", 2

In the above exampel, the client callback function will be invoked with two arguments, "one" and 2. If a handler function does not return any values, the client callback function will be invoked without arguments.


## 4. 发送消息
SocketIO event handlers defined as shown in the previous section can send reply message to the connected client using the `send()` and `emit()` functions.

- send() : sends a standard message of string or JSON type to the client.
- emit() : sends a message under a custom event name.

### 4.1 working with unnamed and named events

    # 回音壁

    from flask_socketio import send, emit

    @socketio.on("message")
    def handle_messgae(message):
        send(message)

    @socketio.on("json")
    def handle_json(json):
        send(json, json=True)

    @socketio.on("my event")
    def handle_my_event(json):
        emit("my response", json)


### 4.2 working with namespaces.

By default `send()` and `emit()` use the namespace of the incoming message by default. 

A different namespace can be specified with the optional `namespace` argumenbt.

    
    @socketio.on("message")
    def handler_message(message):
        send(message, namespace="/chat")


    @socketio.on("my event")
    def handler_my_event(json):
        emit('my response', json, namespace="/chat")


    # emit with multiple arguments, send a tuple
    @socketio.on("my event")
    def handle_my_event(json):
        emit("my response", ('foo', 'bar', json), namespace="/chat")

### 4.3 acknowledgement callback
SockIO supports acknowledgement callbacks that confirm that a message war received by the client.
    
    def ack():
        print "Message war receiverd"

    @socketio.on("my event")
    def handle_my_custom_event(json):
        emit("My response", json, callback=ack)

When using callbacks the Javascript client receives a callback function to invoke upon receipt of the message. After the client application invokes the callback function the server invokes the corresponding server-side callback. If the client-side callback returns any values, these are provided as arguments to servier-side callback.

The client application can also request an acknoledgement callback for an event sent to the server. If the server wants to provide arguments for this callback, it must return them from the event handler function:
    
    @socketio.on("My event")
    def handle_my_custom_event(json):
        # ... handle the event

        # client callback will reveive these 3 arguments.
        return 'foo','bar', 123     

## 5. 广播: Broadcasting
Flask-SocketIO supports broadcasting with the `broadcast=True` optional argument to `send()` and `emit()`
    
    @socketio.on("my event")
    def handle_my_custom_event(data):
        emit("my response", data, broadcast=True)

When a message is sent with the broadcast option enabled, all clients connected  to the namespace receive it, including the sender. When namespaces are not used, the clients connected to the global namespace receive the message. **Note that callbacks are not invoked for broadcast message**.

In some scenes, the server needs to be the originator of a messag. This can be useful to send notifications to client of events that originated in the server, for example in a background thread. The `socketio.send()` and `socketio.emit()` methods can be used to broadcast to all connected clients:
    
    def some_function():
        socketio.emit("Some event", {'data': 42})

**Note that `socketio.send()` and `socketio.emit()` are not the same functions as the context-aware `send()` and `emit()`**

## 6. Rooms
For many applications it is necessary to group users into subsets that can be addressed together. Flask-SocketIO supports this concept of rooms through the `join_room()` and `leave_room()` functions.

    from flask_socketio import join_room, leave_room

    @socketio.on("join")
    def on_join(data):
        username = data["username"]
        room = data["room"]
        join_room(room)
        send(username + " has entered the room.", room=room)

    @socketio.on("leave")
    def on_leave(data):
        username = data["username"]
        room = data["room"]
        leave_room(room)
        send(username + " has left the room.", room=room)

The `send()` and `emit()` functions accept an optional `room` argument that cause the message to be send to all clients that are in the given room.

All client are assigned a room when they connect , nameed with the session ID of the connection, which can be obtained from `request.sid`. A givent client can join any rooms, which can be given any names. 

When a client disconnects it is removed from all the rooms it was in. The context-free `socketio.send()` and `socketio.emit()` functions also accept a `room` argument to broadcast to all clients in a room.

Since all clients are assigned a personal room, to address a message to a single client, the session ID of the client can be used as the room argument.

## 7. Connection Events
Flask-SocketIO also dispatches connection and disconnection events. 

    @socket.on('connect', namespace="/chat")
    def test_connect():
        emit("my response", {'data': 42})

    @socketio.on("disconnect", namespace="/chat")
    def test_disconnect():
        print "Client disconnected."

The connection event handler can optionally return `False` to reject the connection. This is so that the client can be authenticated at this point.

Note that connection and disconnection events are sent individually on each namespace used.


## 8. Error Handling
Flask-SocketIO can also deal with exceptions.

Error handler functions take the exception object as an argument.
 
    # handles the default namespace
    @socketio.on_error()
    def error_handler(e):
        pass

    # handler the '/chat' namespace
    @socketio.on_error("/chat")
    def error_handler_chat(e):
        pass

    # handlers all namespace without an sxplicit error handler
    @socketio.on_error_default
    def default_error_handler(e):
        pass


The message and data arguments of the current request can also be inspected with the `request.event` variables, which is useful for error logging and debugging outside the event handler.

    from flask import request

    @socketio.on("my error event")
    def on_my_event(data):
        raise RuntimeError()

    @socketio.on_error_default
    def default_error_default(e):
        print request.event["message"]  # my error event
        print request.event["args"]     # (data, )


## 9. Access to Flask's Context Globals

All SocketIO events generatred for a client occur in the context of a single long running request.

Flask-SocketIO 上下文变量与 常规 HTTP 上下文异同

- An **application context** is pushed before invoking an event handler making `current_app` and `g` available to the handler.

- A **request context** is also pushed before invoking a handler, also making `request` and `session` available. But note that WebSocket events do **not** have individual requests associated with them, so the request context that started the connection is pushed for all the events that are dispatched during the life of the connection.

- `request.sid` is set to a unique session ID for the connection. This value is used as an initial room where the client is added.

- `request.namespace` contain the currently handled namespace.

- `request.event` contain the event arguments , which is a dict with `message` and `args` keys.

- The `session` context global behaves in a different way than in regular requests. A copy of the user session at the time the SocketIO connettion is established is made available to handlers invoke in the context oif that connection. If a SocketIO handler modifies the session , the modified session will be preserved for future SocketIO handlers, but regular HTTP route handlers will not see these changes. Effectively, when a SocketIO handler modifies the session , a *fork* of the session is created exclusively for these handlers. The technical reason for this limitation is that to save the user session a cookie needs to be sent to the client, and that requires HTTP request and response, which do not exist in a SocketIO connection. When using server-side sessions such as those provieded by the Flask-Session or Flask-KVSession extensions, changes make to the session in HTTP route handlers can be seen by SocketIO handlers , as long as the session is not modified in the SocketIO handlers.

- the `before_request` and `after_request` hooks are not invoked for SocketIO event handlers.

- SocketIO handlers can take custom decorators , but most Flask decorators will not be appropriate to use for a SocketIO handler, givent that there is no concept of a `Response` object during a SocketIO connection.

## 10. Authentication
In most cases it is more convenient to perform the traditional authentication process(using web form and HTTP requests) before the SocketIO connection is established . The user's identify can then be recorded in the user session or in a cookie, and later when the SocketIO connettin is established that informatin will be accessible to SocketIO event handlers.

### 10.1 Using Flask-Login with Flask-SocketIO
Flask-SocketIO can access login information maintained by Flask-Login . After a regular Flask-Login authentication is performed and the `login_user()` function is called to record the user in the user session, any SocketIO connections will have access to the `current_user` context variable:

    @socketio.on('connect')
    def connect_handler():
        if current_user.is_authenticated:
            emit("My response", {'message': "{0} has joined".format(current_user.name)}, broadcast=True)

        else:
            return False    # not allowed here

**Note that the login_required decorator cannot be used with SocketIO event handlers**, but a custom decorator that disconnects non-authticated users can be created as follow:
    
    import functools
    from flask import request
    from flask_login import current_user
    from flask_socketio import disconnect

    def authenticated_only(f):
        @functools.wraps(f)
        def wrapped(*args, **kwargs):
            if not current_user.is_authenticated:
                disconnect()
            else:
                return f(*args, **kwargs)

        return wrapped

    @socketio.on('my event')
    @authenticated_only
    def handle_my_custom_event(data):
        emit("my response", {'message': "{0} has joined".format(current_user.name)}, broadcast=True)

## 11. Deployment
### 11.1 Embedded Server

The simplest deployment strategy is to have eventlet or gevent installed, and start the web server by calling socketio.run(app) as shown in examples above. This will run the application on the eventlet or gevent web servers, whichever is installed.

Note that socketio.run(app) runs a production ready server **when eventlet or gevent are installed**. If neither of these are installed, then the application runs on Flask’s development web server, which is not appropriate for production use.

Unfortunately this option is **not available** when using gevent with uWSGI. See the uWSGI section below for information on this option.

### 11.2 Gunicorn Web Server
**module** is the Python module or package that defines the application instance, and **app** is the application instance itself.   

    # start eventlet server via gunicorn
    $ gunicorn --worker-class eventlet -w 1 module:app

    # use gevent
    $ gunicorn -k gevent -w 1 module:app


### 11.3 uWSGI Web Server
When using the uWSGI server in combination with gevent , the SocketIO server can take advantage if uWSGI's native WebSocket support.

    $ uwsgi --http :5000 --gevent 1000 --http-websockets --master --wsgi-file app.py --callable app

### 11.4 Using nginx as a WebSocket Reverse Proxy
Only releases of nginx 1.4 and newer support proxying of the WebSocket protocol.
    
    # single WebSocket service
    server {

        listen 80;
        server_name _;

        locatioin / {
            include proxy_params;
            proxy_pass http://127.0.0.1:5000;
        }

        location /socket.io {
            include proxy_params;
            proxy_http_version 1.1;
            proxy_buffering off;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_pass http://127.0.0.1:5000/socket.io;
        }
    }

    # multi WebSocket service
    upstream socketio_nodes {
        ip_hash;

        server 127.0.0.1:5000;
        server 127.0.0.1:5001;
        server 127.0.0.1:5002;
        # to scale the app, just add more nodes here!
    }

    server {
        listen 80;
        server_name _;

        location / {
            include proxy_params;
            proxy_pass http://127.0.0.1:5000;
        }

        location /socket.io {
            include proxy_params;
            proxy_http_version 1.1;
            proxy_buffering off;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_pass http://socketio_nodes/socket.io;
        }
    }
### 11.5 Using Multiple Workers
Flask-SocketIO supports multiple workers behind a load balancer starting with release 2.0.

Deploying multiple workers gives applications that use Flask-SocketIO the ability to spread the client connections among multiple processes and hosts, and in this way scale to support very large numbers of concurrent clients.

**Requirements**
- The LB must be configured to forward all HTTP request from a given client always to the worker. This is sometimes referenced as **sticky sessions**. For nginx , use the ip_hash directive to archieve this. Gunicorn cannot be used with multiple workers because its LB algorithm does not support sticky session.
    
        $ pip install redis
- Since each of the servers owns only a subset of the client connections , a message queue such as Redis or RabbitMQ is used by the servers to coordinate complex operations such as broadcasting and rooms.
    
        $ pip install kombu

- If eventlet or gevent are used , then monkey patching the Python standard library is normally required to force the message queue package to use coroutine friendly functions and classes.

**Useage**
    
    socketio = SocketIO(app, message_queue='redis://')

### 11.6 Emitting from an External Process
For many types of applications, it is necessary to emit events from a process that is not the SocketIO server, for a example a Celery worker. If the SocketIO server or servers are configured to listen on a message queue as shown in the previous section, then any other process can create its own SocketIO instance and use it to emit events in the same way the server does.

For example, for an application that runs on an eventlet web server and uses a Redis message queue, the following Python script broadcasts an event to all clients:

    socketio = SocketIO(message_queue='redis://')
    socketio.emit('my event', {'data': 'foo'}, namespace='/test')
    
When using the SocketIO instance in this way, the Flask application instance is not passed to the constructor.

The channel argument to SocketIO can be used to select a specific channel of communication through the message queue. Using a custom channel name is necessary when there are multiple independent SocketIO services sharing the same queue.

Flask-SocketIO does not apply monkey patching when eventlet or gevent are used. But when working with a message queue, it is very likely that the Python package that talks to the message queue service will hang if the Python standard library is not monkey patched.

It is important to note that an external process that wants to connect to a SocketIO server does not need to use eventlet or gevent like the main server. Having a server use a coroutine framework, while an external process does not is not a problem. For example, Celery workers do not need to be configured to use eventlet or gevent just because the main server does. But if your external process does use a coroutine framework for whatever reason, then monkey patching is likely required, so that the message queue accesses coroutine friendly functions and classes.