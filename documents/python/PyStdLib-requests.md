---
title: PyStdLib--requests
date: 2018-03-19 18:35:17
categories:
- Python
tags:
- python 标准库
---

<!-- MarkdownTOC -->

- [一. 安装](#%E4%B8%80-%E5%AE%89%E8%A3%85)
- [二. 用法](#%E4%BA%8C-%E7%94%A8%E6%B3%95)
    - [requests.get\(\)  : GET 请求](#requestsget--get-%E8%AF%B7%E6%B1%82)
    - [requests.post\(\) : POST 请求](#requestspost--post-%E8%AF%B7%E6%B1%82)
- [三. 文档摘抄](#%E4%B8%89-%E6%96%87%E6%A1%A3%E6%91%98%E6%8A%84)
    - [1. 功能特性](#1-%E5%8A%9F%E8%83%BD%E7%89%B9%E6%80%A7)
    - [2. 使用文档](#2-%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3)
        - [2.1 发送请求](#21-%E5%8F%91%E9%80%81%E8%AF%B7%E6%B1%82)
            - [2.1.1 传递 URL 参数](#211-%E4%BC%A0%E9%80%92-url-%E5%8F%82%E6%95%B0)
            - [2.1.2 定制请求头](#212-%E5%AE%9A%E5%88%B6%E8%AF%B7%E6%B1%82%E5%A4%B4)
            - [2.1.3 复杂的 POST 请求, 表单](#213-%E5%A4%8D%E6%9D%82%E7%9A%84-post-%E8%AF%B7%E6%B1%82-%E8%A1%A8%E5%8D%95)
            - [2.1.4 POST 一个 多部分编码的文件\( Multipart-Encoded \)的文件](#214-post-%E4%B8%80%E4%B8%AA-%E5%A4%9A%E9%83%A8%E5%88%86%E7%BC%96%E7%A0%81%E7%9A%84%E6%96%87%E4%BB%B6-multipart-encoded-%E7%9A%84%E6%96%87%E4%BB%B6)
        - [2.2 响应](#22-%E5%93%8D%E5%BA%94)
            - [2.2.1 响应内容](#221-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9)
                - [2.2.1.1 文本 响应内容与响应编码](#2211-%E6%96%87%E6%9C%AC-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9%E4%B8%8E%E5%93%8D%E5%BA%94%E7%BC%96%E7%A0%81)
                - [2.2.1.2 二进制 响应内容](#2212-%E4%BA%8C%E8%BF%9B%E5%88%B6-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9)
                - [2.2.1.3 json 响应内容](#2213-json-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9)
                - [2.2.1.4 原始 响应内容](#2214-%E5%8E%9F%E5%A7%8B-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9)
            - [2.2.2 响应状态码](#222-%E5%93%8D%E5%BA%94%E7%8A%B6%E6%80%81%E7%A0%81)
            - [2.2.3 响应首部](#223-%E5%93%8D%E5%BA%94%E9%A6%96%E9%83%A8)
        - [2.3 Cookie](#23-cookie)
        - [2.4 重定向与请求历史](#24-%E9%87%8D%E5%AE%9A%E5%90%91%E4%B8%8E%E8%AF%B7%E6%B1%82%E5%8E%86%E5%8F%B2)
        - [2.5 超时](#25-%E8%B6%85%E6%97%B6)
        - [2.6 错误与异常](#26-%E9%94%99%E8%AF%AF%E4%B8%8E%E5%BC%82%E5%B8%B8)
        - [2.7 会话对象](#27-%E4%BC%9A%E8%AF%9D%E5%AF%B9%E8%B1%A1)
    - [3. 高级特性](#3-%E9%AB%98%E7%BA%A7%E7%89%B9%E6%80%A7)
    - [4. Q&A](#4-qa)
        - [4.1 RequestsCookieJar: `CookieConflictError: There are multiple cookies with name`](#41-requestscookiejar-cookieconflicterror-there-are-multiple-cookies-with-name)

<!-- /MarkdownTOC -->


<a id="%E4%B8%80-%E5%AE%89%E8%A3%85"></a>
## 一. 安装
```    
$ pip install requests
```

**requests 并不是python 标准库, 但为了汇总方便, 将其放置于此.**

<a id="%E4%BA%8C-%E7%94%A8%E6%B3%95"></a>
## 二. 用法

<a id="requestsget--get-%E8%AF%B7%E6%B1%82"></a>
### requests.get()  : GET 请求
```Python
payload = {'key1': 'value1', 'key2': 'value2'}

ret = requests.get('http://www.example.com', params=payload)
ret.url     # 访问的 url
ret.text    # 访问结果
ret.content
ret.cookis
ret.headers
ret.json
ret.status_code
ret.ok
```
<a id="requestspost--post-%E8%AF%B7%E6%B1%82"></a>
### requests.post() : POST 请求
```Python
import requests
import json
 
url = 'http://httpbin.org/post'
payload = {'some': 'data'}
headers = {'content-type': 'application/json'}
 
ret = requests.post(url, data=json.dumps(payload), headers=headers)
 
print(ret.text)
print(ret.cookies)    
```
其他方法 :
```Python
requests.get(url, params=None, **kwargs)
requests.post(url, data=None, json=None, **kwargs)
requests.put(url, data=None, **kwargs)
requests.head(url, **kwargs)
requests.delete(url, **kwargs)
requests.patch(url, data=None, **kwargs)
requests.options(url, **kwargs)

# 以上方法都是在 此方法的基础上构建的
requests.request(method, url, **kwargs)
```
<a id="%E4%B8%89-%E6%96%87%E6%A1%A3%E6%91%98%E6%8A%84"></a>
## 三. 文档摘抄
<a id="1-%E5%8A%9F%E8%83%BD%E7%89%B9%E6%80%A7"></a>
### 1. 功能特性

Requests 支持 Python 2.6—2.7以及3.3—3.7，而且能在 PyPy 下完美运行。

- Keep-Alive & 连接池
- 国际化域名和 URL
- 带持久 Cookie 的会话
- 浏览器式的 SSL 认证
- 自动内容解码
- 基本/摘要式的身份认证
- 优雅的 key/value Cookie
- 自动解压
- Unicode 响应体
- HTTP(S) 代理支持
- 文件分块上传
- 流下载
- 连接超时
- 分块请求
- 支持 `.netrc`


<a id="2-%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3"></a>
### 2. 使用文档

**请求与响应对象**: 任何使用进行了类似`requests.get()` 调用, 都会做两件事:

- 构建一个 **Request 对象**, 该对象将被发送到某个服务器请求或查询一些资源.
- 一旦 requests 得到一个从服务器返回的响应就会产生一个 **Response 对象**, 该响应对象包含服务器返回的所有信息, 也包含原来创建的 **Request 对象**.

```
>>> r = requests.get('http://en.wikipedia.org/wiki/Monty_Python')
>>> r.headers           # 响应首部信息
>>> r.request.headers   # 请求首部信息
```

<a id="21-%E5%8F%91%E9%80%81%E8%AF%B7%E6%B1%82"></a>
#### 2.1 发送请求

```
>>> r = requests.get('https://api.github.com/events')
>>> r = requests.post('http://httpbin.org/post', data = {'key':'value'})
>>> r = requests.put('http://httpbin.org/put', data = {'key':'value'})
>>> r = requests.delete('http://httpbin.org/delete')
>>> r = requests.head('http://httpbin.org/get')
>>> r = requests.options('http://httpbin.org/get')
```

<a id="211-%E4%BC%A0%E9%80%92-url-%E5%8F%82%E6%95%B0"></a>
##### 2.1.1 传递 URL 参数

使用 URL 的查询字符串传递数据.

Requests 使用 `params` 关键词参数, 以一个字典来提供查询字符串. **字典里值为 None 的键都不会被添加到 URL 的查询字符串里**.

原始请求URL : `httpbin.org/get?key=val` 

```
>>> payload = {'key1': 'value1', 'key2': ['value2', 'value3']}
>>> r = requests.get("http://httpbin.org/get", params=payload)
>>> print r.url
    http://httpbin.org/get
```
<a id="212-%E5%AE%9A%E5%88%B6%E8%AF%B7%E6%B1%82%E5%A4%B4"></a>
##### 2.1.2 定制请求头
定制 HTTP 请求首部, 只需传递一个 `dict` 给 `headers` 参数即可.

定制 header 的优先级**低于**某些特定的信息源:

- 如果在 `.netrc` 中设置了用户认证信息, 使用 `headers=` 设置的授权就不会生效. 而如果设置 `auth=` 参数, `.netrc` 的设置就无效了.
- 如果被重定向到了别的主机, 授权 header 就会被删除.
- 代理授权 header 会被 URL 中提供的代理身份覆盖掉.
- 在可以判断内容长度的情况下, header 的 Content-Length 会被改写.

进一步讲, Request 不会基于定制 header 的具体情况改变自己的行为. 只不过在最后的请求中, 所有的 header 信息都会被传递进去.

**所有的 header 字典的值, 必须是 `string`, `bytestring` 或者 `unicode`**. 不建议 unicode.

```
>>> url = "http://httpbin.org/get"
>>> headers = {"user-agent": "my-app/1.0.1"}
>>> r = requests.get(url, headers=headers)

```

<a id="213-%E5%A4%8D%E6%9D%82%E7%9A%84-post-%E8%AF%B7%E6%B1%82-%E8%A1%A8%E5%8D%95"></a>
##### 2.1.3 复杂的 POST 请求, 表单
发送表单数据, 只需简单传递一个 `dict` 给 `data` 参数. 数据字典在发送请求时会自动编码为表单形式.

```
>>> payload = {'key1': 'value1', 'key2': 'value2'}
>>> r = requests.post("http://httpbin.org/post", data=payload)

>>> print(r.text)
    {
      ...
      "form": {
        "key2": "value2",
        "key1": "value1"
      },
      ...
    }
```

还可以为 `data` 参数传入一个**元组列表**, 在表单中**多个元素使用同一 key 的时候**, 这种方式尤其有效.

```
>>> payload = (('key1', 'value1'), ('key1', 'value2'))
>>> r = requests.post('http://httpbin.org/post', data=payload)
>>> print(r.text)
    {
      ...
      "form": {
        "key1": [
          "value1",
          "value2"
        ]
      },
      ...
    }
```

有些时候, 发送的数据并非编码为表单形式的, 如果传递一个 `string` 而不是一个 `dict`, 那么, 数值会被直接发布出去.

发送 json 编码的数据:

```
## POST/PATCH 编码为 JSON 的数据
>>> import json
>>> url = "https://api.github.com/some/endpoint"
>>> payload = {"some": "data"}

>>> r = requests.post(url, data=json.dumps(payload))

## 使用 json 参数直接传递 json 数据, 内容会被自动编码
>>> r = requests.post(url, json=payload)
```

<a id="214-post-%E4%B8%80%E4%B8%AA-%E5%A4%9A%E9%83%A8%E5%88%86%E7%BC%96%E7%A0%81%E7%9A%84%E6%96%87%E4%BB%B6-multipart-encoded-%E7%9A%84%E6%96%87%E4%BB%B6"></a>
##### 2.1.4 POST 一个 多部分编码的文件( Multipart-Encoded )的文件

上传 multipart-encoded 编码文件
```
>>> url = "http://httpbin.org/post"
>>> files = {"file": open("report.xml", "rb")}

>>> r = requests.post(url, files=files)
>>> r.text
    {
      ...
      "files": {
        "file": "<censored...binary...data>"
      },
      ...
    }
```
显式设置文件名, 文件类型和请求头:

```
>>> url = "http://httpbin.org/post"
>>> files = {'file': ('report.xls', open('report.xls', 'rb'), 'application/vnd.ms-excel', {'Expires': '0'})}

>>> r = requests.post(url, files=files)
>>> r.text
    {
      ...
      "files": {
        "file": "<censored...binary...data>"
      },
      ...
    }

```
发送作为文件来接受的字符串:

```
>>> url = 'http://httpbin.org/post'
>>> files = {'file': ('report.csv', 'some,data,to,send\nanother,row,to,send\n')}

>>> r = requests.post(url, files=files)
>>> r.text
    {
      ...
      "files": {
        "file": "some,data,to,send\\nanother,row,to,send\\n"
      },
      ...
    }
```

当发送一个非常大的文件作为 `multipart/form-data` 请求时, 可以将请求做成数据流. 默认下, `requests` 不支持, 但有个第三方包 [requests-toolbelt](http://toolbelt.readthedocs.io/en/latest/) 支持, 可以阅读其文档了解其使用方法.

强烈建议使用 **二进制模式** 打开文件. 这是 Requests 会视图提供 Content-Length 首部, 当使用 二进制模式 打开文件时, 该值会被设置为 文件的字节数; 如果使用文本模式打开, 可能会发生错误.

<a id="22-%E5%93%8D%E5%BA%94"></a>
#### 2.2 响应
<a id="221-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9"></a>
##### 2.2.1 响应内容
<a id="2211-%E6%96%87%E6%9C%AC-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9%E4%B8%8E%E5%93%8D%E5%BA%94%E7%BC%96%E7%A0%81"></a>
###### 2.2.1.1 文本 响应内容与响应编码

Requests 会自动解码来自服务器的内容, 大多数 unicode 字符集都能被正确的解码.

请求发出之后, Requests 会基于 HTTP 首部对响应的编码做出有根据的预测, 并且在使用 `r.text` 时, 使用其推测的文本编码. 

可以使用 `r.encoding` 来**查看/修改**响应内容使用的编码. 在改变 编码 之后, 再次访问 `r.text`, Requests 会使用新的编码.

```
>>> r = requests.get("http://httpbin.org/get")
>>> r.text
    u'{"args":{},"headers":{"Accept":"*/*","Accept-Encoding":"gzip, deflate","Connection":"close","Host":"httpbin.org","User-Agent":"python-requests/2.18.4"},"origin":"61.171.67.218","url":"http://httpbin.org/get"}\n'

>>> r.encoding
    "utf-8"
>>> r.encoding = "ISO-8859-1"       # 修改编码方式.
```

<a id="2212-%E4%BA%8C%E8%BF%9B%E5%88%B6-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9"></a>
###### 2.2.1.2 二进制 响应内容

Requests 能以 **字节** 的方式访问请求响应体, 使用 `r.content`. 同时, Requests 会自动解码 `gzip` 和 `deflate` 传输编码的响应数据.

```
# 以请求返回的二进制数据创建一张图片.
>>> from PIL import Image
>>> from io import BytesIO

>>> i = Image.open(BytesIO(r.content))
```
<a id="2213-json-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9"></a>
###### 2.2.1.3 json 响应内容
Requests 内置 JSON 解码器, 用于处理 JSON 数据. 如果 JSON 解码失败, `r.json()` 会抛出一个异常.

需要注意的是, `r.json()` 调用成功 **并不意味着**响应的成功. 有的服务器会在失败的响应中包含一个 JSON 对象, 如 HTTP 500 的错误细节. 如果需要检查请求是否成功, 请使用 `r.raise_for_status()` 或者检查 `r.status_code` .

```
>>> r = requests.get("http://httpbin.org/get")
>>> r.json()
    {u'args': {},
     u'headers': {u'Accept': u'*/*',
      u'Accept-Encoding': u'gzip, deflate',
      u'Connection': u'close',
      u'Host': u'httpbin.org',
      u'User-Agent': u'python-requests/2.18.4'},
     u'origin': u'61.171.67.218',
     u'url': u'http://httpbin.org/get'}
```
<a id="2214-%E5%8E%9F%E5%A7%8B-%E5%93%8D%E5%BA%94%E5%86%85%E5%AE%B9"></a>
###### 2.2.1.4 原始 响应内容
有些情况下, 需要获取来自服务器的原始套接字响应, 可以访问 `r.raw`. 需要确保在初始请求中设置 `stream=True`.

```
>>> r = requests.get('https://api.github.com/events', stream=True)
>>> r.raw
    <requests.packages.urllib3.response.HTTPResponse object at 0x101194810>
>>> r.raw.read(10)
    '\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\x03'
```
一般情况下, 使用下面的模式, **将文本流保存到文件**. 使用 `Response.iter_content` 将会隐藏处理大量 在直接使用 `Response.raw` 时需要处理的细节 ( Using `Reponse.iter_content` will handle a lot of waht you would otherwise have to handle when using `Response.raw` directly). 当使用 流 下载时, 这是优先推荐的获取内容方式.

```
with open(filename, "wb") as fd:
    for chunk in r.iter_content(chunk_size):    # 此处 chunk_size 根据实际大小调整.
        fd.write(chunk)
```
<a id="222-%E5%93%8D%E5%BA%94%E7%8A%B6%E6%80%81%E7%A0%81"></a>
##### 2.2.2 响应状态码

检测响应状态码
```
>>> r = requests.get("http://httpbin.org/get")
>>> r.status_code
    200
```
Requests 内置一个状态码查询对象
```
>>> r.status_code == requests.codes.ok
```
请求错误或失败时, 可以通过 `Response.raise_for_status()` 来抛出异常. 当请求的返回码为 200 时, `r.raise_for_status()` 返回 None.
```
>>> bad_r = requests.get("http://httpbin.org/status/404")
>>> bad_r.status_code
    404
>>> bad_r.raise_for_status()
    ... ...
    HTTPError: 404 Client Error: NOT FOUND for url: http://httpbin.org/status/404    
```

<a id="223-%E5%93%8D%E5%BA%94%E9%A6%96%E9%83%A8"></a>
##### 2.2.3 响应首部
Requests 使用字典形式展示服务器响应首部.且, HTTP 首部是大小写不敏感的.

服务器可以多次接受同一个 header, 每次都是用不同的值, 但是 Requests 会将他们合并, 这样他们就可用同一个映射来表示.

```
>>> r.headers
    {'Content-Length': '352', 'Via': '1.1 vegur', 'Server': 'gunicorn/19.8.1', 'Connection': 'keep-alive', 'Access-Control-Allow-Credentials': 'true', 'Date': 'Thu, 17 May 2018 15:11:48 GMT', 'Access-Control-Allow-Origin': '*', 'Content-Type': 'application/json'}

>>> r.headers["Content-Type"]
    'application/json'

>>> r.headers["Content-type"]
    'application/json'

>>> r.headers["content-type"]
    'application/json'
```
<a id="23-cookie"></a>
#### 2.3 Cookie

查看 cookie
```
>>> url = 'http://example.com/some/cookie/setting/url'
>>> r = requests.get(url)

>>> r.cookies['example_cookie_name']
    'example_cookie_value'
```

发送 cookies, 可以使用 `cookies` 参数
```
>>> url = 'http://httpbin.org/cookies'
>>> cookies = dict(cookies_are='working')

>>> r = requests.get(url, cookies=cookies)
>>> r.text
    '{"cookies": {"cookies_are": "working"}}'
```

Cookie 返回的对象为 `RequestsCookieJar`, 他的行为和字典类似, 但接口更为完整, 适合跨域名使用. 还可以吧 CookieJar 传到 Requests 中.

```
>>> jar = requests.cookies.RequestsCookieJar()
>>> jar.set('tasty_cookie', 'yum', domain='httpbin.org', path='/cookies')
>>> jar.set('gross_cookie', 'blech', domain='httpbin.org', path='/elsewhere')
>>> url = 'http://httpbin.org/cookies'
>>> r = requests.get(url, cookies=jar)
>>> r.text
    '{"cookies": {"tasty_cookie": "yum"}}'
```

<a id="24-%E9%87%8D%E5%AE%9A%E5%90%91%E4%B8%8E%E8%AF%B7%E6%B1%82%E5%8E%86%E5%8F%B2"></a>
#### 2.4 重定向与请求历史

默认情况下, 除了 HEAD, Requests 会自动处理所有重定向. 可以使用响应对象的 `r.history` 方法来追踪重定向. `Response.history` 是一个 Response 对象的列表, 为了完成请求而创建这小对象, 这个对象列表, 按照从最老到最新的请求进行排序.

```Python
>>> r = requests.get("http://httpbin.org/absolute-redirect/6")

>>> r.status_code
    200

>>> r.history
    [<Response [302]>,
     <Response [302]>,
     <Response [302]>,
     <Response [302]>,
     <Response [302]>,
     <Response [302]>]
```

如果使用 GET, OPTIONS, POST, PUT, PATCH, DELETE 方法, 可以通过 `allow_redirects` 参数禁用重定向处理.

```Python
>>> r = requests.get('http://github.com', allow_redirects=False)
>>> r.status_code
    301
>>> r.history
    []
```

如果使用 HEAD, 可以启动 重定向
```
>>> r = requests.head('http://github.com', allow_redirects=True)
>>> r.url
    'https://github.com/'
>>> r.history
    [<Response [301]>]
```
<a id="25-%E8%B6%85%E6%97%B6"></a>
#### 2.5 超时

使用 `timeout` 参数设定在 一定时间之后 Requests 停止等待响应. 如果没有设置 `timeout`, Requests 将永不超时.

`timeout` 进队连接过程有效, 与响应体的下载无关. timout 并不是整个下载响应的时间限制, 而是如果服务器在 timeout 时间内没有应答, 将会引发一个异常. 更精确的说, 是在 timeout 秒内没有从基础套接字上接受到任何字节的数据时.
```
>>> requests.get("http://github.com", timeout=0.001)
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
    requests.exceptions.Timeout: HTTPConnectionPool(host='github.com', port=80): Request timed out. (timeout=0.001)
```
<a id="26-%E9%94%99%E8%AF%AF%E4%B8%8E%E5%BC%82%E5%B8%B8"></a>
#### 2.6 错误与异常 
所有 Requests 抛出的异常, 继承自 `requests.exceptions.RequestException`.

- `ConnectionError` : 遇到网络连接问题, 如 DNS 查询失败, 拒绝连接.
- `HTTPError` : 如果 HTTP 请求返回了不成功的状态码, `Response.raise_for_status()` 抛出 `HTTPError` 异常.
- `Timeout` : 请求超时.
- `TooManyRedirects` : 请求超过了设定的最大重定向次数.

<a id="27-%E4%BC%9A%E8%AF%9D%E5%AF%B9%E8%B1%A1"></a>
#### 2.7 会话对象
会话对象能够跨请求保持某些参数, 他会在同一个 Session 实例发出的所有请求之间保持 cookie, 期间使用 `urllib3` 的 `connection pooling` 功能. 如果想同一主机发送多个请求, 底层的 TCP 连接会被重用, 从而带来显著的性能提升.

**会话对象具有主要的 Requests API 的所有方法**.

会话可用来跨请求保持 cookie
```
>>> s = requests.Session()

>>> s.get("http://httpbin.org/cookies/set/sessioncookie/123321")
    <Response [200]>

>>> r = s.get("http://httpbin.org/cookies")

>>> r.text
    u'{"cookies":{"sessioncookie":"123321"}}\n'

```
会话可用来为请求方法提供缺省数据, 这是通过为会话对象的属性好提供数据来实现的. 任何传递给请求方法的字典都会与以设置会话层数据合并. 方法层的参数覆盖会话的参数.

```
>>> s = requests.Session()
>>> s.auth = ('user', 'pass')
>>> s.headers.update({'x-test': 'true'})

    # both 'x-test' and 'x-test2' are sent
>>> s.get('http://httpbin.org/headers', headers={'x-test2': 'true'})
```

**注意**: 即使使用了会话, **方法级别的参数也不会被跨请求保持**. 下面示例中, 只会使用第一个请求发送的 cookie , 而非第二个. 如果手动为会话添加 cookie, 就需要使用 [Cookie utility 函数](http://docs.python-requests.org/zh_CN/latest/api.html#api-cookies) 来操纵 `Session.cookies`

```
>>> s = requests.Session()

>>> r = s.get('http://httpbin.org/cookies', cookies={'from-my': 'browser'})
>>> print(r.text)
    '{"cookies": {"from-my": "browser"}}'

>>> r = s.get('http://httpbin.org/cookies')
>>> print(r.text)
    '{"cookies": {}}'
```

会话可用作上下文管理器, 这样可以确保 `with` 区块退出后会话能被关闭, 即使发生了异常.
```
with requests.Session() as s:
    s.get('http://httpbin.org/cookies/set/sessioncookie/123456789')
```

如果想要省略字典参数中一些会话层的键, 只需简单的在方法层参数中将这个键的值设置为 None 即可, 该键会被自动省略掉.

包含在一个会话中的所有数据都可以直接使用, [会话 API 文档](http://docs.python-requests.org/zh_CN/latest/api.html#sessionapi).

<a id="3-%E9%AB%98%E7%BA%A7%E7%89%B9%E6%80%A7"></a>
### 3. 高级特性

待补充
`http://docs.python-requests.org/zh_CN/latest/user/advanced.html`

<a id="4-qa"></a>
### 4. Q&A

<a id="41-requestscookiejar-cookieconflicterror-there-are-multiple-cookies-with-name"></a>
#### 4.1 RequestsCookieJar: `CookieConflictError: There are multiple cookies with name`

`Session.cookies` 不是一个字典, 而是一个 `RequestsCookieJar`  类字典对象. `RequestsCookieJar.get()`源码定义如下:

```Python
def get(self, name, default=None, domain=None, path=None):
    """Dict-like get() that also supports optional domain and path args in
    order to resolve naming collisions from using one cookie jar over
    multiple domains. Caution: operation is O(n), not O(1)."""
    try:
        return self._find_no_duplicates(name, domain, path)
    except KeyError:
        return default
```

当 Cookie 的键唯一时, 可以直接 `RequestsCookieJar.get()`. 但是, 当有多个 Cookie 键相同时, 意味着 Cookie 的其他键不同, 因此可以使用 `RequestsCookieJar.get(key, domain=DOMAIN, path=Path)` 这样的方式来区分和获取.








