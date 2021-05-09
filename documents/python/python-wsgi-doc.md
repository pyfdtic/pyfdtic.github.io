
## 一. 背景知识

WSGI(The Python Web Server Gateway Interface) 为 Web Server 和 Python Web Application 之间提供了标准的数据通道. 是 Python 界的 一个广泛的可用的 WEB API 规范, 使 web server 提供更加规范的 API, 给 web Application, 从而使 开发者更加专注于业务逻辑.

WSGI 仅仅作为 Python Web 开发的一个标准, 开发者必须将 WSGI 实践到开始实践之中, 否则不会对现有的 web server 和 web Application 拥有实质影响.

## 二. WSGI 规则

WSGI 涉及到两个方面: ① web server, ② Web Application. 

WebServer 端需要调用一个 可调用对象, 该对象由 WebApplication 提供. 但是, 可调用对象如何进行调用, 取决于 WebServer. 但是, WebServer 在调用 WebApplication 提供的 可调用对象时, 不能有任何依赖或针对某种特定的 可调用对象类型.

一个可调用对象, 可以是一个 函数, 方法, 类, 或实现了 __call__ 方法的实例.

### 1. 字符串问题
一般来讲, HTTP 中, 字符串以字节流形式传输, 但是在 Python 中, 字符串使用 Unicode 编码, 而不是 bytes. 因此, 需要在可用 API 和 正确的字符串转换之间寻求平衡, 特别是当 python 有多重 str 类型时.

WSGI 定义了两种类型的 `string` :
1. `Native String`, 文本字符串, 可用`str()` 函数转换, 用于 请求/响应头 和 元数据.
2. `Bytestrings` , 用于 请求体/响应体.

尽管 Python 的 `str` 类型使用 Unicode 编码, 但是在底层, 文本字符串任然会被转换为 bytes , 使用 Latin-1 编码.

### 2. WebApplication/Framework 

WebApplication 对象应该是一个可调用对象, 它可以是一个 函数, 方法, 类, 或者一个实现了 __call__ 方法的实例. 同时, 要确保该可调用对象, 可以被多次调用. 因为事实上, 所有的 WebServer 都会产生这样的重复请求.

如下是两个 WebApplication 的示例, 其中一个是 funciton, 一个是 类.

```python
HELLO_WORLD = b'Hello world!\n'

def simple_app(environ, start_response):
    """ Simplest possible application object. """

    status = "200 OK"
    response_headers = [("Content-type", "text/plain")]

    start_response(status, response_headers)
    return [HELLO_WORLD]

class AppClass:
    """Produce the same output, but using a class
    *AppClass* is the 'application' here, so calling it returns an instance of 
    *AppClass*, which is then the iterable return value of the `application callable`
    as required by the spec. 

    If we wanted to use *instances* of *AppClass* as application objects instead,
    we would have to implement a `__call__` method, which would be invoked to excute
    the applications, and we should be invoked to execute the application, and we
    would need to create an instance for use by te server or gateway. 
    """

    def __init__(self, environ, start_response):
        self.environ = environ
        self.start = start_response

    def __iter__(self):
        status = "200 OK"
        response_headers = [("Content-type", "text/plain")]
        self.start(status, response_headers)

        yield HELLO_WORLD
```

WebApplication 必须接受两个位置参数, 惯例命名为 `environ` 和 `start_response`. WebServer 必须采用位置参数的方式, 调用 WebApplication 对象, 如 `result = application(environ, start_response)`

- `environ` : 
    
    是一个字典, 包含 CGI-style 的环境变量.

    该字典必须是一个 Python 原生字典, 而不能是 dict 的子类, 或 `UserDict` 其他模拟实现. WebApplication 可以使用 Python 字典支持的任何方法, 使用 `environ` 对象.

    `environ` 对象必须包含一些 WSGI 要求的变量, 和 WebServer 需要的其他扩展参数.

- `start_response` : 
    
    `start_response` 是一个可调用对象, 该对象可接受两个位置参数(惯例命名为 `status` 和 `response_headers`), 和一个可选参数(惯例命名为 `exc_info`).

    WebApplication 必须使用 上面的位置参数, 调用 `start_response` , 例如: `start_response(status, response_headers)`.

    `status` 参数是一个 `999 Message here` 格式的 字符串.
    `response_headers` 参数是一个 格式`(header_name, header_value)` 元组组成的列表, 用于描述 HTTP 响应头部信息.
    `exc_info` 参数只在 WebApplication 发生错误, 并试图显示错误信息时使用.

    `start_response` 可调用对象必须返回一个 `write(body_data)` 可调用对象, 其中 `body_data` 参数为一个 bytestring, 是 HTTP 响应体的一部分. (`write()` callable is provided only to support certain existing frameworks' imperative output APIs, it should not be used by new applications or frameworks if it can be avoided).

当 WebApplication 被 WebServer 调用时, 它必须返回一个 可迭代的返回 zero 或 bytestring 的可迭代对象. 这可以通过多种方式实现, 如 返回一个 bytestring 组成的列表, 一个生成器, 一个实现了迭代协议的类实例. WebServer 或 WebGateway 返回迭代的字符串给客户端, 并且不缓存任何数据.

WebApplication 或 WebGateway 将 WebApplication 返回的可迭代的字符串, 当做二进制字符数据来处理. 因此, WebApplication 必须保证其返回的字符串对于客户端是格式化的可显示的格式, 如换行符等.

如果对 WebApplication 返回的对象调用 `__len__(iterable)` 方法成功, 则该方法必须正确返回其 长度, 因为 `__len__()` 返回的值将作为 `Content-Length` 的值.

如果 WebApplication 返回的对象, 实现了 `__close__()` 方法, WebServer 必须在每次请求结束的时候, 调用该方法, 无论该次请求是否正确完成.


当 WebApplication 返回 生成器或自定义的迭代器时, 不应当假设该生成器或迭代器会被完全消费完, 因为, 它可能会被 WebServer 过早的关闭.

the application must invoke the `start_response()` callable before the iterable yields its first body bytestring, so that the server can send the headers before any body content. However, this invocation may be performed by the iterable's first iteration, so servers must not assume that `start_response` has been called before they negin iterating over the iterable.

Finally, server and gateways must not directly use any other attributes of the iterable returned by the application, unless it is an instance of a type specific to that server or gateway, such as a `file wrapper` return by `wsgi.file_wrapper`. In the general case, only attributes specified here, or accessed via e.g. the PEP 234 iteration APIs are acceptable.

#### 2.1 environ 变量
`environ` 必须包含如下的 CGI 环境变量.

- `REQUEST_METHOD`  : 必选, HTTP 请求方法
- `SCRIPT_NAME` : 请求的 URL 的 path 部分, 一般为 `/`
- `PATH_INFO` : 请求的 URL 的 path 部分, 
- `QUERY_STRING` : 可选, 请求 URL 中 `?`, 后面的部分.
- `CONTENT_TYPE` : 可选, HTTP Content-Type
- `CONTENT_LENGTH` : 可选, HTTP Content-Length
- `SERVER_NAME, SERVER_PORT` : 
- `SERVER_PROTOCOL` : "HTTP/1.0" 或 "HTTP/1.1" 
- `HTTP_Variables` : 其他对应的客户端支持的 HTTP 请求头.

一个 WebServer 应当竟可能多的提供 CGI 变量, 例如 HTTPs=on 等.

除此之外, `environ` 还可以提供 任意数量的 操作系统环境变量, 并且, 必须包含如下的 WSGI 规定的变量.

| Variable | Value |
| -- | -- |
| `wsgi.version` | 一个元组, WSGI 版本, 当前版本为 `(1, 0)` |
| `wsgi.url_scheme` | http 或 https |
| `wsgi.input` | An input stream (file-like object) from which the HTTP request body bytes can be read. |
| `wsgi.errors` | An output stream (file-like object) to which error output can be written, for the purpose of recording program o rother errors in a standardized and possibly centralized location. This should be a `text mode` stream, and assume that it will be converted to the correct line ending by the server/gateway. |
| `wsgi.multithread` | This value should evaluate true if the application object may be simultaneously invoked by another thread in the same process, and should evaluate false otherwise. |
| `wsgi.multiprocess` | This Value shoudl evaluate true if an equivalent application object may be simultaneously invoked another process, and should evaluate false otherwise. |
| `wsgi.run_once` | This value should evaluate true it the server or gateway expects(but not guatantee) that the application will only be invoked this one time during the life of its containing process. Normally, this will only be true for a gateway based on CGI (or something similar). |

最后, `environ` 变量字典可以包含任意的自定义变量, 这些变量应当只包含 小写字符, 数字, 点好, 下划线等, 而且应当使用一个唯一的自定义前缀.

#### 2.2 Input and Error Streams

WebServer 提供的 Input 和 Error 流, 必须支持如下的方法.

| Method | Stream | Notes |
| -- | -- | -- |
| `read(size)` | input | a |
| `readline()` | input | a,b |
| `readlines(hint)` | input | a,c |
| `__iter__()` | input |  |
| `flush()` | errors | d |
| `write(str)` | errors |  |
| `writelines(seq)` | errors |  |

- a : 
    
    WebServer 不要求获取传给客户端的 Content-Length, 但是需要提供一个 end-of-line 的条件测试, 方便 WebApplication 读取该字段的内容. 同时, WebApplication 不应当试图读取多于 CONTENT_LENGTH 变量规定大小的数据.

    WebServer 应当允许被无参数的调用 `read()` 方法, 并且返回客户端 input stream 数据流的大小.

    当 WebServer 接收到空的 input stream 或 大量耗尽资源的请求时, 应当返回空的 bytestrings .

- b : WebServer 应当提供支持可选参数 `size` 的方法 `readline()`.
- c : `readlines()` 方法 的 可选参数 `hint` 对于 调用者和实施者来说都是可选的. WebApplication 可以选择不支持 该方法, WebServer 也可以忽略它.
- d : since the `errors` stream may not be rewound, servers and gateways are free to forward write opertions immediately, without buffering. In this case, the `flush()` method may be a no-op. Portable applications, however, cannot assume that output is unbuffered or that `flush()` is a no-op. They must call `flush()` if they need to ensure that output has in fact been written.(For example, to minimize intermingling of data from multiple processes writing to the same error log).

对于考虑兼容性和普适性的 WebServer 来说, 上面表格中的方法必须要支持.

遵守这些规格实现的 WebApplication, 必须要保证不使用 `input` 和 `output` 对象的任何可调用方法和属性. 尤其的, WebApplication 一定不要尝试关闭这些 stream 对象, 即使该对象提供了 `close()` 方法.

#### 2.3 `start_response()` 可调用对象

调用方法 `start_response(status, response_headers, exc_info=None)`, 其中的参数, **必须为位置参数**, 而**不能是关键字参数**. 该方法调用返回的结果是一个 `write(body_data)` 的可调用对象, 用作 HTTP 响应.

`status` 参数是一个 HTTP `status` 字符串, 包含以空格分隔的 HTTP 响应码 和 HTTP 响应字符串, 类似: `200 OK`, `404 Not Found`. 该字符串 无需包含控制字符, 如换行符, 回车等.

`response_headers` 是一个由多个 `(header_name, header_value)` 元组组成的标准 Python 列表. WebServer 可以使用任何 Python List 支持的方法调用该列表. 

- 每个 `header_name` 必须是一个可用的 HTTP 头字段, 并且不包含 特殊标点符号.
- 每个 `header_value` 必须不能包含任何控制字符, 包括回车和换行.

通常情况下, WebServer 需要保证响应客户端的数据包含正确的响应头, 任何 WebApplication 遗漏的 HTTP 首部, WebServer 需要将该首部添加到 HTTP 响应中. 例如, HTTP 响应中的 `Data` 首部和 `Server` 首部通常由 WebServer 添加.

WebApplication 和 Middleware 应当禁止使用 HTTP/1.1 的 **hop-by-hop** 特性或首部, 同时, 任何等价的 HTTP/1.0 中的特性或首部, 都会影响到客户端到服务端的持久连接. 这些特性只有在特定领域的 web server 中才有, 因此, WebServer 应当将他作为一个 error 并 抛出草屋, 当 WebApplication 尝试发送这些信息的时候.

当 WebServer 调用 `start_response()` 时,  应当检查所有首部中的 error, 并在检查出错误时, 将这些 error 抛出.

然而, `start_response()` 必须禁止传输 来自 WebApplication 的首部. 反之, 它必须为 WebServer 保存这些信息, 并在 WebApplication 的完成首次迭代的时候返回这些信息 或 WebApplication 首次调用 `write()` 方法时. 即, 响应首部必须要在有真正的 响应体可用时, 或 WebApplication 返回的迭代器迭代完成之后, 才能返回. 这种延迟的相应首部传输是为了保证 直到最后时刻使用缓存的或者异步的 WebApplication 可以用 Error 信息替换原有的首部信息. 例如, 当一个错误在 WebApplication 缓存内部被抛出, WebApplication 可以把响应首部从 `200 OK` 修改为 `500 Internal Error`.

当提供 `exc_info` 参数时, 它必须是一个 Python 的 `sys.exc_info()` 元组. 只有当 `start_response()` 被一个错误处理器调用时, `exc_info` 参数才应该被提供. 如果提供 `exc_info` 参数, 并且 尚未生成 HTTP 首部时, `start_response()` 方法应当使用当前缓存的 HTTP 响应首部替换新的响应首部, 因此, 以此实现 在错误发生时, 允许 WebApplication 修改返回给客户端的响应内容.

然而, 当 `exc_info` 被提供, 并且 响应首部已经发送给客户端, `start_response()` 必须抛出一个错误, 同时使用 `exc_info` 元组再次抛出错误.

```Python
raise exc_info[1].with_traceback(exc_info[2])
```
上面的代码会再次抛出被 WebApplication 捕获的错误, 同时, 原则上会终止 WebApplication . 如果 WebApplication 带 `exc_info` 参数调用 `start_response` , WebApplication 一定不能捕获任何被 `start_response()` 抛出的异常. 相反, WebApplication 应当将这样的异常传递给 WebServer , 由它来处理.

只有当 `exc_info` 参数提供时, WebApplication 可能会多次调用 `start_response`. 更精确的讲, `start_response` 已经被 WebApplication 调用, 如果再次使用 不带 `exc_info` 的参数调用 `start_response` 方法, 将是致命的错误, 包括第一个调用 `start_response` 就抛出错误的情况.

```Python
def start_response(status, response_headers, exc_info=None):
    if exc_info:
        try:
            # do stuff w/exc_info here
        finally:
            exc_info = None     # Avoid circular ref.
```

#### 2.4 处理 `Content-Length` 首部

当 WebApplication 提供 `Content-Length` 首部时, WebServer 绝对不能传输多余此 `Content-Length` 指定数量的 bytes 给客户端, 而是在获取足够数据时, 停止迭代响应, 或者在 WebApplication 尝试抛出多个这个数量的数据时, 抛出一个异常. 当然, 如果 WebApplication 未能提供做够的数据符合 `Content-Length` 的数量时, WebServer 应当关闭链接或记录并报告错误.

如果 WebApplication 未能提供 `Context-Length` 首部, WebServer 应当使用适当的手段来处理这种情况. 最简单的办法是 当响应完成时, 关闭到 客户端的链接.

然而, 在某些情况下, WebServer 可能生成一个 `Content-Length` 首部或至少避免关闭一个到客户端的链接. 如果 WebApplication 没有调用 `write()` 可调用方法, 而是返回了一个可迭代的对象, 其长度`len()`为 1, 则 WebServer 可以自主决定使用迭代对象返回的第一个 bytestring 长度作为 `Content-Length`.

如果, WebServer 端和 客户端均支持 HTTP/1.1 **chunked encoding** 特性, WebServer 可能使用 **chunked encoding** 方式 为每次 `write()` 或 迭代器迭代 发送 chunk, 并为其生成适当的 `Content-Length` 首部. 这种方式, 将允许 WebServer 保持到客户端的长连接. 这种情况下, WebServer 必须完全遵守 [RFC 2616](http://www.faqs.org/rfcs/rfc2616.html) 规范, 或者使用其他的策略生成 `Content-Length`.

** WebApplication 决不能在其输出结果中, 生成任何类型的 `Transfer-Encoding`首部, 这些首部应当有 WebServer 生成**


#### 2.5 Buffering 和 Streaming

一般来讲, WebApplication 可以通过缓存其输出结果,并一次性发送给 WebServer 达到最佳性能. 现在 Zope 的常用方式是: 将输出缓存到一个 StringIO 或其他类似对象中, 然后一次 将生成的首部和所有结果 传输给 WebServer.

在 WSGI 中实现这种效果的方式是: 返回一个只包含一个结果的可迭代对象, 该可迭代对象包含 一个单独的 bytestring 形式的响应信息. 这也是一种给 WebApplication 的推荐方式.

对于大文件 或者 特殊用途的 HTTP streaming (如 multipart server push)来说, WebApplication 可能需要返回小块的相应结果(以避免一次加载太大的文件到内存中).  For large file, however, or for specialized uses of HTTP streaming (such as multipart 'server push'), an application may need to provide output in smaller blocks (e.g. to avoid loading a large file info memory). It's also sometimes the case that part of a response may be time-consuming to produce, but it would be useful to send ahead the portion of the response that precedes it.

这种情况下, WebApplication 通常返回一个迭代器(或生成器), 该迭代器使用 block-by-block 的方式生成响应体. These blocks may be broken to coincide with mulitpart boundaries (for server push), or just before time-consuming tasks (such as reading another block of another block of an on-disk file).

WebServer 绝对不能延迟传输任何 block, 它要么 一次传输所有的 block 给客户端, 或者保证 持续传输每个 block 给客户端知道 WebApplication 生成它的下一个 block. WebServer 可以采用如下的一种或多种方式实现这种保证:

- 在将控制权返回为 WebApplication 之前, 发送整个 block 给操作系统(并且要求 操作系统层级的缓存被清空).
- 在 WebApplication 生成下一个 block 的同时, 使用不同的线程来保证整个 block 被持续的传输给客户端, 
- 发送整个 block 给它的上层 WebServer 或 WebGateway, 这只适用于 Middleware .

WSGI 协议通过这种保证, 允许 WebApplication 保证, 其响应数据会被均衡的传输给任意节点. By providing this guarantee, WSGI allows applications to ensure that transmission will not become stalled at an arbitraty point in their output data. This is critical for proper functioning of e.g. multipart "server push" streaming, where data between multipart boundaries should be transmitted in full to the client.

#### 2.6 Middleware Handling of Block Boundaries

为了更好的支持异步 WebApplication 和 WebServer, Middleware 组件不能 在等待 WebApplication 迭代器返回多个值时, 阻塞迭代. 如果 Middleware 组件 在响应请求之前 需要积攒多个数据块, 他必须 yield 一个空的 bytestring.


这种要求的另一种实现方法是, 一个 Middleware 组件每次必须 从 WebApplication 返回的可迭代对象中 yield 至少一个值. 如果 Middleware 不能 yield 值, 则返回一个 空的 bytestring.

这种要求可以保证异步 WebApplication 和 WebServer 能够协同合作, 以便减少需要的线程数.

这种要求同事意味着, Middleware 必须 尽快的从 WebApplication 返回的迭代器中 返回可迭代对象. 这同时也禁止了 Middleware 使用 `write()` 可调用对象取传输数据. Middleware 组件只能使用其上游 WebServer 的 `write()` 可调用对象来传输数据.

#### 2.7 `write()` 可调用方法
一些也已存在的 WebApplication 框架 API 支持无缓存的 删除, 这种方式是与 WSGI 规定的方式不同的. 尤其是, 这些 WebApplication 提供一个 `write` 函数或方法, 用于写入无缓存的数据块, 或者他们也会提供一个 指出缓存的 `write` 方法和一个 `flush` 机制来情况缓存.

不幸的是, 这些 API 无法按照 遵循WSGI 的 WebApplication 返回的可迭代对象那样执行, 除非使用了线程或其他机制.

如果可以避免的话, 新的 WSGI WebApplication 不应该使用 `write` 可调用方法. `write()` 方法严格讲是一个 hack 方法, 用于支持必要的 streaming API. 通常来讲, WebApplication 应当通过他们返回的可迭代对象来使用其标准输出, 同时, 这也使得 WebApplication 在同一个 Python 线程中交叉运行task 成为可能, 潜在的为 WebServer 提升了更好的吞吐能力.

`write` 返回由 `start_response` 方法返回, 它只接受一个参数: 一个字节字符, 用作 HTTP 响应体的一部分. 这种处理方式和 WebApplication 返回的可迭代对象的处理方式是一样的. 换言之, 在 `write()` 返回之前, 必须保证已被传递的 字节字符, 要么完全被传输给客户端, 要么被 WebApplication 缓存.

一个 WebApplication 必须返回一个可迭代对象, 即使他使用 `write()` 来处理部分或全部的数据. 返回的 可迭代对象可以为空, 但是它 yield 非空字节字符, 这些非空的返回结果, 必须被 WebServer 正确的处理. WebApplication 必须不能调用 `write` 方法在他们的返回迭代器的内部. Applications must not invoke `write()` from within their return iterable, and therefore any bytestrings yielded by the iterable are transmitted after all bytestrings passed to `write` have been sent to the client.

#### 2.8 Unicode 引发的问题

HTTP 协议不支持 unicode 编码, 所有的 编码和解码 必须有 WebApplication 处理, 任何从 WebServer 传入或传出的字符必须是 `str` 或 `bytes` 类型, 而不是 `unicode`. 在应该使用 string 对象的地方使用 unicode 对象的结果是未定义的.

同时需要注意的是, 任何传给 `start_response` 作为 HTTP 响应码和响应首部的字符, 必须遵守 RFC 2616 的编码规定. 即, 这些字符要么是 ISO-8859 编码 或者是 RFC 2047 支持的 MIME 类型编码.

在 Python 平台中, 所有的 `str` 或 `StringType` 类型字符都是 Unicode-based 的. all `strings` referred to in this specification must contain only code points representable in ISO-885901 encoding. WebApplication 提供的字符包含其他 Unicode 字符串是一个致命的错误. 类似地, WebServer 和 WebGateway 必须不支持 WebApplication 中包含其他的 Unicode 字符.

Again, all objects referred to in this specification as `strings` must be of type `str` or `StringType`, and must not be of type `Unicode` or `UnicodeType`. And, even if a given platform allows for more than 8 bits per character in `str/StringType` objects, only the lower 8 bits may be used, for any value referred to in this specification as a 'string'.

#### 2.9 错误处理
通常情况下, WebApplication 应当捕获其内部的错误, 并在客户端浏览器展示相关的帮助信息.

然而, 为了展示这些帮助信息, WebApplication 必须尚未真正的发送任何数据给客户端, 或者 it risks corrupting the response. WSGI 因此提供一种机制, 可用于向允许 WebApplication 发送其错误帮助信息, 或者自动忽略 `start_response` 的 `exc_info` 参数.

```Python
try:
    # regular application code here
    status = "200 OK"
    response_headers = [("content-type", "text/plain")]
    start_response(status, response_headers)
    return ["normal body goes here"]
except:
    # XXX shoule trap runtime issues like MemoryError, KeyboardInterrupt 
    # in a separate handler before this bare `except:` ...
    status = "500 Oops"
    start_response(status, response_headers, sys.exc_info())
    return ["error body goes here"]
```

当一个异常发生时, 如果没有 输出被写入, 对 `start_response` 的调用将会正常返回, 并且 WebApplication 会返回错误信息给客户端浏览器. 然而, 如果有任何输出已经被传输给客户端, `start_response` 将会再次抛出该异常. 这种异常不应当被 WebApplication 捕获, 因此, WebApplication 应当忽略它. 然后又 WebServer 捕获该异常, 并忽略 WebApplication 的返回内容.

WebServer 应当捕获并记录任何 终止 WebApplication 或 终止 WebApplication 返会迭代对象迭代 的异常结果. 当 WebApplication 发生错误时, 如果响应内容的一部分已经发送给客户端, WebServer 或 WebGateway 可以尝试将错误信息添加到 返回给客户端的结果中. 另外, 如果已发送的响应中包含 `text/*` 类型内容, 则 WebApplication 知道如何干净的修改.

一些 Middleware 组件可能希望提供附加的 异常处理服务, 或者拦截并替代 WebApplication 的错误帮助信息. 这种情况下, Middleware 可能选择不再抛出 应用到 `start_response` 的 `exc_info` 异常, 取而代之的是, 抛出一个 Middleware 的自定义异常, 或者只是简单的返回不包含任何异常的响应. 这种处理方式, 将会导致 WebApplication 返回 可迭代的错误信息, 并允许 Middleware 捕获并修改这些错误输出信息. These techniques will work as long as appliocation authors.

- Always provide `exc_info` when beginning an error response.
- Never trap errors raised by `start_response` when `exc_info` is being provided.

#### 2.10 HTTP/1.1 Expect/Continue 机制

选择支持 HTTP/1.1 的 WebServer 必须要支持 HTTP/1.1 的 **Expect/continue** 机制, 可以有以下几种实现方式:

- Respond to request containing an `Expect: 100-continue` request with an immediate `100 continue` resposne, and proceed normally.
- Proceed with the request normally, but provide the application with a `wsgi.input` stream that will send the `100 continue` response if/when the application first attempts to read from the input stream. The read request must then remain blocked until the client responds.
- Wait until the client decides that the server does not support expect/continue, and sends the request body on its own (this is suboptimal, and is not recommended).

Not that these behavior restrictions do not apply for HTTP 1.0 requests, or for requests that are not directed to an application object. For more information on HTTP/1.1 Expect/Continue, see [RFC 2616](http://www.faqs.org/rfcs/rfc2616.html) sections 8.2.3 and 10.1.1 .

#### 2.11 其他 HTTP 特点
通常来讲, WebServer 应当 **paly dumb**, 并允许 WebApplication 完全控制它输出. WebServer 只有在不修改 WebApplication 返回结果的语义的情况下, 才可以修改 WebApplication 的原生的返回. WebApplication 开发者可以添加 Middleware 组件来支持额外的功能特性, 所以, WebServer 开发者应当在其开发计划中尽量保守. 某种意义上, WebServer 应当把自己当做 HTTP 的网关服务器, 而把 WebApplication 当做 '真正的' 服务器.

然而, 由于 WSGI WebServer 和 WebApplication 之间通讯不是走 HTTP 协议, 因此, [RFC 2616](http://www.faqs.org/rfcs/rfc2616.html) 中说明的 `hop-by-hop` 首部不支持 WSGI 组件之间的通讯. WSGI 的 WebApplication 一定不要生成任何 `hop-by-hop` 的首部, 尝试使用 这些HTTP 特性可能需要他们生成这些 首部, 或者依赖 传入的 `environ` 字典中包含 `hop-by-hop` 首部信息. WSGI WebServer 必须处理任何传入的 `hop-by-hop` 首部, 例如 编码传入的 `Transfer-Encoding`.

这些规则可以应用到多种 HTTP 特性, 应当清楚的是, WebServer 可能会处理缓存有效性, 通过 `If-None-Mathc` 和 `If-Modified-Since` 请求头和 `Last-Modified` 和 `Etag` 响应首部. 但是这些不是强制性的, WebApplication 应当自主的控制缓存的有效性来支持这些特性.


类似的, 一个 WebServer 可能会 重新编码 或 传输编码 WebApplication 的相应内容, 但是 WebApplication 应该选择一个适合自己的内容编码方式, 并且, 切忌应用 传输编码( transport encoding). A server may transmit byte ranges of the application's response if requestd by the client, and the application doesn't natively support byte ranges. Again, however, the application should perform this function on its own if desired.

需要注意的是, WebApplication 无需实现所有的 HTTP 特性, 并且有的 HTTP 特性可以部分或完全的 由 Middleware 组件实现.

#### 2.12 线程支持
线程支持是依赖于 WebServer 端的支持特性的. 支持并发处理多个请求的 WebServer 也应当同时提供 在一个单独的线程中运行 WebApplication 的方法. 这样, 费线程安全的 WebApplication 和 Web 框架也可以使用这些 WebServer.

#### 2.13 Application Configuration
WSGI 协议并不定义一个 WebServer 如何选择或者获取一个 WebApplication 来调用, 这些细则是 WebServer 高度定制化实现的. 因此, 只能期望 WebServer 开发者在文档中写清楚 WebServer 是如何执行一个特定的 WebApplication 对象的, 并且需要哪些选项和参数.

WebServer 开发者应当在文档中记录如何调用框架的功能函数创建一个 WebApplication.

最终, 一些 WebApplication , 框架, Middleware 可能希望使用 `environ` 字典来接受简单的字符串配置选项. WebServer 应当通过 允许一个 WebApplication 部署者提供存放在 `environ` 中的简单的 key-valu 对 来支持这种方式. 最简单的例子就是, 这种方式能支持从 `os.environ` 中得到的系统环境变量拷贝到 `environ` 字典中, 因为部署者可以自定义 WebApplication 运行环境的特定的变量, 或者 在使用 CGI 的环境中, 可以通过 WebServer 的环境变量来设置额外变量.

Application should try to keep such required variables to a minimum, since not all servers will support easy configuration of them. Of course, even in the worst case, persons deploying an application can create a script to supply the necessary configuration values:

```Python
from the_app import application

def new_app(environ, start_response):
    environ["the_app.configval1"] = "something"
    return application(environ, start_response)
```

但是, 目前已存的大多数 WebApplication 和 框架可能只是需要 从 `environ` 中获取一个简单的值, 来说明当前 WebApplication 的特定配置文件的位置, 然后, WebApplication 会缓存该值的结果.

#### 2.14 URL 重建
如果一个 WebApplication 希望重建一个请求的完整的 URL, 它可能使用下面的算法来实现:

```Python
from urllib.parse import quote
url = environ["wsgi.url_scheme"] + "://"

if environ.get("HTTP_HOST"):
    url += environ["HTTP_HOST"]
else:
    url += environ["SERVER_NAME"]

    if environ["wsgi.url_scheme"] == "https":
        if environ["SERVER_PORT"] != "443":
            url += ":" + environ["SERVER_PORT"]
    else:
        if environ["SERVER_PORT"] != "80":
            url += ":" + environ["SERVER_PORT"]

url += quote(environ.get("SCRIPT_NAME", ""))
url += quote(environ.get("PATH_INFO", ""))

if environ.get("QUERY_STRING"):
    url += "?" + environ["QUERY+STRING"]
```

需要注意的是, 上面算法重建出的 URL 可能并不精确的等于 用户请求的 URL. 例如, WebServer 重写的 URL 可能修改了客户单请求的原有的 URL, 并替换为 权威格式.

### 3. WebServer/Gateway

每当 WebServer 端从 HTTP 客户端接受到一个请求, 都会调用一个 WebApplication , 并指向该 WebApplication.

示例代码: 如下是一个 简单的 CGI gateway, 使用 function 实现, 以一个 application 作为参数.

```Python
import os, sys

enc, esc = sys.getfilesystemencoding(), "surrogateescape"

def unicode_to_wsgi(u):
    # Convert an environment variable to a WSGI 'bytes-as-unicode' string
    # return `u.encode(enc, esc).decode("iso-8859-1")`
    return u.encode(enc, esc).decode("iso-8859-1")

def wsgi_to_bytes(s):
    return s.encode("iso-8859-1")

def run_with_cgi(application):
    environ = {k: unicode_to_wsgi(v) for k,v in os.environ.items()}

    environ["wsgi.input"] = sys.stdin.buffer
    environ["wsgi.errors"] = sys.stderr
    environ["wsgi.version"] = (1, 0)
    environ["wsgi.multithread"] = False
    environ["wsgi.multiprocess"] = True
    environ["wsgi.run_once"] = True

    if environ.get("HTTPS", "off") in ("on", "1"):
        environ["wsgi.url_scheme"] = "https"
    else:
        environ["wsgi.url_scheme"] = "http"

    headers_set = []
    headers_sent = []

    def write(data):
        out = sys.stdout.buffer

        if not headers_set:
            raise AssertionError("Write() before start_response()")

        elif not headers_sent:
            # before the first output, send the stored headers.
            status, response_headers = headers_sent[:] = headers_set
            out.write(wsgi_to_bytes("Status: %s\r\n" % status))

            for header in response_headers:
                out.write(wsgi_to_bytes("%s: %s\r\n" % header))
            out.write(wsgi_to_bytes("\r\n"))

        out.write(data)
        out.flush()

    def start_response(status, response_headers, exc_info=None):
        if exc_info:
            try:
                if headers_sent:
                    # Re-raise original exception if headers sent
                    raise exc_info[1].with_traceback(exc_info[2])

            finally:
                exc_info = None     # avoid dangling circular ref
        elif headers_set:
            raise AssertionError("headers already set!")

        headers_set[:] = [status, response_headers]

        # Note: error checking on the headers should happen here, 
        # *after* the headers are set. That way, if an error occurs,
        # start_response can only be re-called with exc_info set. 

        return write 

    result = application(environ, start_response)   # 参见上面的 AppClass.

    try:
        for data in result:
            if data:        # don't send headers until body appears. 
                write(data)

        if not headers_sent:
            write("")       # sned headers now if body war empty

    finally:
        if hasattr(result, "close"):
            result.close()
```

#### 3.2 WebServer 的高级扩展 API

WebServer 开发者可以向 WebApplication 暴露特定的 API, 以便实现特殊的用途和目的. 

最简单的情况下, 只需定义一个 `environ` 变量即可, 比如 `mod_python.some_api`. 但是, 很多情况下, 可能存在 Middleware 组件会使 API 的暴露变得困难. 例如, 一个暴露 HTTP 首部的 API 可以定义的 `environ` 中, 但是, 他可能会 由于 Middleware 对 `environ` 的修改而返回不同的结果.

通常情况下, 任何复制,代替,绕过 WSGI 功能的 扩展 API 都可能会有与 Middleware 组件不兼容的风险. WebServer 的开发者不应该假设 没有人使用 Middleware 组件, 因为一些框架开发者尤其倾向于使用各种各样的 Middleware 组件组织或者重构框架.

所以为了最大的兼容性, 提供可以替代 WSGI 部分功能的扩展 API 的 WebServer ,必须设计这些 API, 这样才可以调用那些被替换的原生 API (So, to provide maximum compatibility, servers and gateways that provide extension APIs that replace some WSGI functionality, must design those APIs so that they are invoked using the portion of the APIs that they replace). For example, an extension API to access HTTP request headers must require the application to pass in its current `environ`, so that the server/gateway may verify that HTTP headers accessible via the API have not been altered by middleware. If the extension API cannot guarantee that it will always agree with `environ` about the contents of HTTP headers, it must refuse service to the application, e.g. by raising an error, returning `None` instead of a header collection, or whatever is appropriate to the API.

类似的, 如果一个扩展 API 提供一个 重写响应体和响应首部的替代方法, 它应当要求 `start_response()` 方法被传入调用, 在 WebApplication 可以包含这些扩展的服务. 如果传入的对象不是 WebServer 原生提供给 WebApplication 的那个对象, 则不能保证操作的正确性, 而且很可能拒绝为 WebApplication 提供扩展服务.

该指导方针同样适用于在 Middleware 中添加 cookie 解析, form 变量, session 和 `environ` 等其他信息. 特别的, Middleware 应当以 函数的方式提供这些 操作 `environ` 特性, 而不是简单的在 `environ` 中填充变量(键值对). 这将有助于保证 相关的信息是在经过经过其他 Middleware, 或者 URL 重写, 或者 `environ` 修改之后, 从 `environ` 中计算得来.

在 WebServer 和 Middleware 的开发过程中遵循 **安全扩展(safe extension)**的准则是十分重要的. in order to avoid a future in which middleware developers are forced to delete any and all extension APIs from `environ` to ensure that their mediation isn't being bypassed by applications using those extensions.


#### 3.3 Optional Platform-Specific File Handling
一个操作系统环境可能提供特殊的高性能的文件传输机制, 例如 Unix 系统的 `sendfile()` 调用. WebServer 可以通过一个`environ` 中的可选的 `wsgi.file_wrapper` 键值来暴露该功能. WebApplication 可以使用这个 *file wrapper* 来转换一个 文件或类文件对象 为一个可迭代对象:

```Python
if 'wsgi.file_wrapper' in environ:
    return environ["wsgi.file_wrapper"](filelike, block_size)
else:
    return iter(lambda: filelike.read(block_size), "")

```

如果 WebServer 支持 `wsgi.file_wrapper`, 对象必须是可调用的, 且支持一个必选的位置参数, 一个可选的位置参数. 第一个必选参数是一个要传输的 类文件对象, 第二个可选参数是 建议的 字节大小. 该可调用对象必须返回一个可迭代对象, 并且不能传递(transmission) 任何数据, 直到 WebServer 真正接受从 WebApplication 接到可迭代对象作为返回值.

被 WebApplication 支持的, 被称为 类文件的对象必须包含一个 `read()` 方法, 该方法接受一个可选的 *size* 参数. 该对象可能有一个 `close()` 方法, 如果有 `close()` 方法, 被 `wsgi.filr_wrapper` 返回的 可迭代对象必须包含一个 `close()` 方法来调用 类文件对象的原声的 `close()` 方法. 如果该类文件对象包含其他 与Python原声文件对象 相同的方法或属性(如 fileno()), 则 `wsgi.file_wrapper` 可以假设这些方法和属性与 Python 内置文件对象具有相同的语义.

任何平台特定的 file handling 实现必须在 WebApplication 返回之后才会发生(处理), 并且 WebServer 会检查 是否返回了该对象. 再次, 由于 Middleware, 错误处理程序等的存在, 不能保证 人恶化 file_wrapper 被真正的使用.

除了需要包含 `close()` 方法之外, WebApplication 返回的 file_wrapper 应当与 WebApplication 返回 `iter(filelike.read, "")` 一样. In other words, transmission should begin at the current position within the 'file' at the time that transmission begins, and continue until the end is reached, or until Content-Length bytes have been written.(If the application doesn't supply a Content-Length, the server may generate one from the file using its knowledge of the underlying file implemnentation).

主要注意的是, 即使 对象 不适合平台的 API, `wsgi.file_wrapper` 必须任然返回一个实现了 `read()` 方法和 `close()` 方法的迭代器. 这样, 使用 file_wrapper 的 WebApplication 就可以实现跨平台移植. 如下是一个简单的 平台无关的 file_wrapper 类, 适合 新老版本的 Python

```Python
class Filewrapper:
    def __init__(self, filelike, blksize=8192):
        self.filelike = filelike
        self.blksize = blksize

        if hasattr(filelike, "close"):
            self.close = filelike.close

    def __getitem__(self, key):

        data = self.filelike.read(self.blksize)

        if data:
            return data

        raise IndexError
```

如下是一个 WebServer 中的代码片段, 用于提供 到特定平台的 API

```Python
environ['wsfi.file_wrapper'] = Filewrapper

result = application(environ, start_response)

try:
    if isinstance(result, Filewrapper):
        # check if result.filelike is usable w/platform-specific 
        # API, and if so, use that API to transmit the result.
        # If not, fall through to normal iterable handling loop below.

    for data in result:
        # etc.

finally:
    if hasattr(result, "close"):
        result.close()
```

### 4. Middleware
Middleware 是一个组件, 它同时兼具 Server 和 Application 的角色. 对于 Application 来讲, 它是 Server; 对于 Server , 它又表现为一个 Application.

Middleware 可能具有如下功能:

1. 根据请求的 目标URL, 在重写相应的 `environ` 变量后, 将请求路由到指定的 Application;
2. 允许多个 Application 同时运行在一个 process 内部.
3. 通过网络转发请求和响应, 实现负载均衡或者远程处理.
4. 对内容进行后期处理, 比如应用 XSL 自定义模板.

Middleware 的存在对于 WebServer 端和 WebApplication 端来讲都应该是透明的, 并且没有特殊的依赖. 用户在使用 Middleware 时, 只需简单的将 Middleware 组件提供给 WebServer 即可, 就像他是一个 WebApplication 一样, 然后配置 Middleware 组件调用 WebApplication 即可. Of course, the "application" that the middleware wraps may in fact be another middleware component wrapping another application, and so on, creating what is referred to as a "middleware stack".

大多数情况下, Middleware 必须严格与 WebServer 和 WebApplication 适配, 因此, Middleware 的约束与依赖, 可能要比淡村的 WebServer 和 WebApplication 更多.

如下是一个 Middleware 示例代码, 用于将 `text/plain` 转换为 `pig Latin`.

```Python
from piglatin import piglatin

class LatinIter:
    """ Transform iterated output to piglation, if it's okey to do so 
    Note that the 'okayness' can change until the application yields its 
    first non-empty betestring, so `transform_ok` has to be a mutable 
    truth value.
    """
    def __init__(self, result, transform_ok):
        if hasattr(result, "close"):
            self.close = result.close

        self._next = iter(result).__next__
        self.transform_ok = transform_ok

    def __iter__(self):
        result self

    def __next__(self):
        if self.transform_ok:
            return piglatin(self._next)     # call must be byte-safe on Py3
        else:
            return self._next()


class Latinator:
    # by default, don't transform output.
    transform = False

    def __init__(self, application):
        self.application = application

    def __call__(self, environ, start_response):
        transform_ok = []

        def start_latin(status, response_handers, exc_info=None):
            # Reset ok flag,  in case this is a repeat call
            del transform_ok[:]

            for name, vlaue in response_handers:
                if name.lower() == "content-type" and value == "text/plain":
                    transform_ok.append(True)

                    # Strip context-length if present, else it'll be wrong.

                    response_handers = [(name, value) for name, value in response_handers if name.lower() != "content-length"]
                    break

            write = start_response(status, response_handers, exc_info)
            if transform_ok:
                def write_latin(data):
                    write(piglatin(data))   # call must be byte-safe on Py3

                return write_latin
            else:
                return write

        return LatinIter(self.application(environ, start_latin), transform_ok)


# Run foo_app under a Latinator's control, using the example CGI gateway

from foo_app import foo_app
run_with_cgi(Latinator(foo_app))
```

## 三. 杂项

### 1. pep-0333 和 pep-3333
pep-3333 是为了适用 python3 而对 pep-0333 的升级.

### 2. 生词
```
perface         : 前言 
abstract        : 摘要, 抽象. 
rationale       : 基本原理 
specification   : 规则, 说明书. 
reconstruction  : 重建, 再建, 改造. 
amendments      : 修正 
incorporate     : 包含, 吸收, 体现. 
procedural      : 程序性的 
revision        : 修正 
vice            : 恶习, 缺点, 代替的 
By contras      : 作为对比. 
implement       : 实现 
illustrate      : 举例说明 
surrogate       : 代理 
```

## 四. 文档地址:

- [PEP-3333](https://www.python.org/dev/peps/pep-3333/)
- [PEP-3333 中文](http://pep-3333-wsgi.readthedocs.io/en/latest/)
- [PEP-0333](https://www.python.org/dev/peps/pep-0333)


