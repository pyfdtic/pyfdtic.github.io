---
title: Flask 扩展之--flask-sse
date: 2018-03-16 16:45:09
categories:
- Python
tags:
- Flask
- Flask 扩展
- sse
- Server-Sent Event 
---
flask-sse


## 1. Server-Sent Events, SSE 
Server-Sent Events 让服务器向客户端流式发送文本消息, 如服务器生生成的实时通知或者更新.

SSE 提供的是一个高效, 跨浏览器的 XHR 流实现, 消息交付只使用一个长 HTTP 连接. 与我们自己实现的 XHR 流不同, 浏览器会帮我们管理连接, 解析消息, 从而让我们只关注业务逻辑.


### 1.1 SSE 组件
- 浏览器中的 EventSource API : 可以让客户端以 DOM 事件的形式, 接收到服务器推送的通知.
- `事件流` 数据格式 : 新数据格式用于交付每一次更新.

#### 1.1.1 EventSource API
##### 1.1.1.1 API 
EventSource 接口通过一个简单的浏览器 API 隐藏了所有的底层细节: 包括建立链接和解析消息.

使用 SSE , 只需指定 SSE 事件流资源的 URL, 并在该对象上注册响应的 Javascript 事件监听器即可.
    
    // 示例代码
    // 打开到流终点的 SSE 连接
    var source = new EventSource("/path/to/stream-url")     

    // 可选回调, 建立连接时调用
    source.onopen = function () { ... }

    // 可选回调, 连接失败时调用
    source.operrpr = function () { ... }

    // 监听 "foo" 事件, 调用自定义代码
    source.addEventListener("foo", function (event) {
        processFoo(event.data);
    })

    // 监听所有事件, 不明确指定事件类型.
    source.onmessage = function (event) {
        log_message(event.id, event.data);

        // 如果 服务器发送 "CLOSE" 消息 ID, 关闭 SSE 连接.
        if (event.id == "CLOSE") {
            source.close();
        }
    }

**EventSource 可以像常规 XHR 一样利用 CORS 许可及选择同意机制, 实现客户端到远程服务器的流式事件数据传输**.

以上是 客户端API 的全部. 浏览器会帮我们处理一切: 协商建立连接, 接受并递增的解析数据, 标识消息范围, 最终触发 DOM 事件.

##### 1.1.1.2 自动重连机制
EventSource 接口能自动重新连接并跟踪最近接受的消息: 如果链接断开了, EventSource 会自动重新连接到服务器, 还可以向服务器发送上一次收到的消息 ID, 一遍服务器重传跌势的消失并恢复流.

浏览器如何确定每个消息的 ID, 类型 和 范围: 使用**事件流协议**. EventSource API 和 定义完善的数据格式, 密切协同, 使得浏览器中的应用完全不必理会底层数据协议.

#### 1.1.2 Event Strema 协议
SSE 事件流是以**流式 HTTP 响应**形式交付的: 客户端发起常规 HTTP 请求, 服务器以自定义的 "text/event-stream" 内容类型响应, 然后交付 UTF-8 编码的事件数据.

    => 请求
    GET /stream HTTP/1.1        # 客户端通过 EventSource 接口发起连接
    Host: example.com
    Accept: text/event-stream

    <= 响应
    HTTP/1.1 200 OK 
    Connection: keep-alive
    Content-Type: text/event-stream     # 服务器以 "text/event-stream" 内容类型响应
    Transfer-Encoding: chunked     
 
    retry: 15000        # 服务器设置连接中断后重新连接的时间间隔

    data: First message is a simple string  # 不带消息类型的简单文本事件

    data: {'message': 'JSON payload'}   # 不带消息类型的 JSON 数据载荷

    evnet: foo      # 类型为 foo 的简单文本事件
    data: Message of type "foo"

    id: 42          # 带消息 ID 和类型的多行时间
    event: bar
    data: Multi-line message of
    data: type "bar" and id "42"

    id: 43          # 带可选 ID 的简单文本事件
    data: Last message, id "43"

以上事件流协议, 容易理解, 容易实现:

- 事件载荷就是一个或多个相邻 data 字段的值
- 事件可以带 ID 和 event 表示事件类型
- 事件边界用换行符标识

在接收端, EventSource API 通过检查换行分割符来解析到来的数据流, 从 data 字段中提取有效载荷, 检查可选的 ID 和类型, 最后再分派一个 DOM 事件告知应用. 如果存在某个类型, 那么就会触发自定义的 DOM 事件处理程序, 否则, 就会调动通用的 onmessage 回调.


EventSource 不会对实际载荷进行任何额外处理, 从多个 data 字段中提取出的消息, 会被拼接起来直接交给应用. 因此, 服务器可以推送任何文本格式(字符串, JSON等), 应用必须自己解码. 所有事件源数据都是 UTF-8 编码的, SSE 不是传输 二进制载荷 而设计的, 但可以把二进制对象编码为 base64 格式, 然后使用 SSE, 但会导致很高(33%)的开销.

SSE 连接本质上是 HTTP 流式响应, 因此响应时可以压缩的, 就跟压缩其他 HTTP 响应一样, 而且是动态压缩. 

除了自动解析事件数据, SSE 还内置支持**断线重连**, 以及恢复客户端因断线而丢失的消息. 默认情况下, 如果连接中断, 浏览器会自动重新连接, SSE 规范建议间隔时间为 2~3 s, 这也是大多数浏览器采用的默认值. 服务器也可以设置一个自定义的时间间隔, 只要在推送任何消息时, 向客户端发送一个 retry 命令即可.

服务器还可以给每条消息关联任意 ID 字符串. 浏览器会自定记录最后一次收到的消息ID, 并在发送重连请求时自动在 HTTP 首部追加 **Last-Event-ID** 值.

    # 既有 SSE 连接
    retry: 4500         // 服务器将客户端的重连事件设置为 4.5s

    id: 43              // 简单文本事件, ID 43
    data: Lorem ipsum  

    # 连接断开, 4500 ms 之后
    
    => 请求
    GET /stream HTTP/1.1    // 带 Last-Event-ID 的客户端重连请求.
    Host: example.com
    Accept: text/event-stream
    Last-Event-ID: 43

    <= 响应
    HTTP/1.1 200 OK     // 服务器响应.
    Content-Type: text/event-stream
    Connection: keep-alive
    Transfer-Encoding: chunked

    id: 44              // 简单文本事件, ID 44
    data: dolor sit amet

浏览器负责重新连接和记录上一次事件 ID , 然后服务器根据应用的要求和数据流, 采取不同实现策略来恢复:

- 如果丢失消息可以接受, 就无需事件 ID 或特殊逻辑, 只要让客户端重连并恢复数据流即可.
- 如果必须恢复消息. 同样, 服务器也需要实现某种形式的本地缓存, 以便恢复并向客户端重传错过的数据.



### 1.2 特点 与局限
1. 特点

- 通过一个长连接低延迟交付
- 高效的浏览器消息解析, 不会出现无限缓冲
- 自动跟踪最后看到的消息及自动重新连接.
- 消息通知在客户端以 DOM 事件形式呈现.

2. 局限

- 只能从服务器向客户端发送数据, 不能满足需要请求流的场景.
- 事件流协议设计为只能传输 UTF-8 数据, 即使可以传输二进制数据, 效率也不高. 
- SSE 在服务端和客户端都比较容易实现, 但网络中间设备如 代理, 防火墙等不支持 SSE, 因此, 中间设备可能会缓冲事件流数据, 导致额外延迟, 甚至彻底毁掉 SSE 链接, 可以考虑通过 TLS 发送 SSE 事件流.


## 2. flask-sse

### 2.1 安装
Server-sent event **do not** work with Flask's built-in development server, because it handlers HTTP requests one at a time. The SSE stream is intended to be an infinite stream of events, so it will never complete. You must use a web server with asychronous workers, like gunicorn with gevent.

You will also need a Redis server running locally for this example to work.
    
    $ pip install gunicorn flask flask-sse gevent

### 2.2 简单示例
    
    # cat sse.py
    from flask import Flask, render_template
    from flask_sse import sse

    app = Flask(__name__)
    app.config["REDIS_URL"] = "redis://localhost"
    app.register_blueprint(sse, url_prefix="/stream")

    @app.route("/")
    def index():
        return render_template('index.html')

    @app.route('/hello')
    def publish('/hello'):
        sse.publish({"message": "Hello!"}, type="greeting")
        return "Message Sent!"


    # cat templates/index.html
    <!DOCTYPE html>
    <html>
        <head>
            <title> Flask-SSE Quickstart </title>
        </head>
        <body>
            <h1>Flash-SSE Quickstart</h1>
            <script>
                var source = new EventSource("{{ url_for('sse.stream') }}")
                source.addEventListener('greeting', function(event){
                    var data = JSON.parse(event.data);
                    alert("The Server Says: " + data.message);
                }, false);

                source.addEventListener("error", function(event){
                    alert("Failed to connect to event stream.")
                }, false);

            </script>
        </body>
    </html>

    # run code
    $ gunicorn sse:app --worker-class gevent --bind 127.0.0.1:8000
    $ curl 127.0.0.1:8000

### 2.3 配置
#### 2.3.1 Redis
In order to use Flask-SSE , you need a Redis server to handle **pubsub**. Flask-SSE will search the application config for a Redis connection URL to use. It will try the following configuration values, in order:
- SSE_REDIS_URL
- REDIS_URL

If it doesn't find a Redis connection URL, Flask-SSE will raise a ***KeyError* any time a client tries to access the SSE stream.

If the Redis server has a password:
    
    app.config["REDIS_URL"] = "redis://:password@localhost"

#### 2.3.2 应用服务器

Flask-SSE **does not** work with Flask’s built-in development server, due to the nature of the server-sent events protocol. This protocol uses long-lived HTTP requests to push data from the server to the client, which means that an HTTP request to the event stream will effectively never complete.  Flask’s built-in development server is single threaded, so it can only handle one HTTP request at a time. Once a client connects to the event stream, it will not be able to make any other HTTP requests to your site.

Instead, you must use a web server with asychronous workers. Asynchronous workers allow one worker to continuously handle the long-lived HTTP request that server-sent events require, while other workers simultaneously handle other HTTP requests to the server. Gunicorn is an excellent choice for an application server, since it can work with gevent to use asychronous workers.

### 2.4 高级设置
#### 2.4.1 Channels
Sometimes, you may not want all events to be published to all clients. When  publishing an event, you can select which channel to direct the event to. If you do , only clients that are checking that particular channel will receive the event.
    
    # this event will be sent to the `users.social` channel
    sse.publish({'user': "alice", 'status': 'Life is short, I use python'}, channel="users.social")

Channel names can be any string you want, and are created dynamically as soon as they are referenced. The default channel name that Flask-SSE uses is "sse".

To subscribe to a channel , the client only needs to be provide a `channel` query parameter when connecting to the event stream. 

    # event stream is at /stream, and you channel is "users.social" the url is as follow:
    /stream?channel=users.social

    # url_for() function
    url_for("sse.stream", channel="users.social")

**By default, all channels are publicly accessible to all users**.

#### 2.4.2 Access Control
Since Flask-SSE is implemented as a blueprint, you can attach a **before_request()** handler to implement access control.
    
    @sse.before_request
    def check_access():
        if request.args.get("channel") == "analytucs" and not g.user.is_admin():
            abort(403)

## 3. [AngularJS & SSE](http://www.smartjava.org/content/html5-server-sent-events-angularjs-nodejs-and-expressjs)