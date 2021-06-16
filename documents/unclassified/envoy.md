## 配置文件

![envoy-arch](imgs/envoy-arch.png)

![envoyfilter-arch](imgs/envoyfilter-arch.png)

![envoy-listener-filter-arch](imgs/envoy-listener-filter-arch.png)

```json
{
  "node": "{...}",
  "static_resources": "{...}",
  "dynamic_resources": "{...}",
  "cluster_manager": "{...}",
  "hds_config": "{...}",
  "flags_path": "...",
  "stats_sinks": [],
  "stats_config": "{...}",
  "stats_flush_interval": "{...}",
  "watchdog": "{...}",
  "tracing": "{...}",
  "runtime": "{...}",
  "layered_runtime": "{...}",
  "admin": "{...}",
  "overload_manager": "{...}",
  "enable_dispatcher_stats": "...",
  "header_prefix": "...",
  "stats_server_version_override": "{...}",
  "use_tcp_for_dns_lookups": "..."
}
```

- `node` : 节点标识，配置的是 Envoy 的标记信息，`management server` 利用它来标识不同的 Envoy 实例. 
- `static_resources` : 定义**静态**配置，是 Envoy 核心工作需要的资源，由 Listener、Cluster 和 Secret 三部分组成. 
  - `Listener`
  - `Cluster`
  - `Secret`
- `dynamic_resources` : 定义**动态**配置，通过 `xDS` 来获取配置. 可以同时配置动态和静态. 
- `cluster_manager` : 管理所有的上游集群. 它封装了连接后端服务的操作，当 `Filter` 认为可以建立连接时，便调用 `cluster_manager` 的 API 来建立连接. `cluster_manager` 负责处理负载均衡、健康检查等细节. 
- `hds_config` : 健康检查服务发现动态配置. 
- `stats_sinks` : 状态输出插件. 可以将状态数据输出到多种采集系统中. 一般通过 Envoy 的管理接口 `/stats/prometheus` 就可以获取 Prometheus 格式的指标，这里的配置应该是为了支持其他的监控系统. 
- `stats_config` : 状态指标配置. 
- `stats_flush_interval` : 状态指标刷新时间. 
- `watchdog` : 看门狗配置. Envoy 内置了一个看门狗系统，可以在 Envoy 没有响应时增加相应的计数器，并根据计数来决定是否关闭 Envoy 服务. 
- `tracing` : 分布式追踪相关配置. 
- `layered_runtime` : **层级化**的运行时状态配置. 如层级目录树. 可以静态配置，也可以通过 `RTDS` 动态加载配置. 
- `admin` : 管理接口. 
- `overload_manager` : 过载过滤器. 
- `header_prefix` : `Header` 字段前缀修改. 例如，如果将该字段设为 `X-Foo`，那么 `Header` 中的 `x-envoy-retry-on` 将被会变成 `x-foo-retry-on`. 
- `use_tcp_for_dns_lookups` : 强制使用 TCP 查询 DNS. 可以在 `Cluster` 的配置中覆盖此配置. 

### 查看 admin 配置
0. 启动 `admin` 监听

    ```yaml
    admin:
      access_log_path: /dev/null
      address:
        socket_address:
          address: 127.0.0.1
          port_value: 19000
    ```

1. `config_dump`

    ```shell
    $ curl -s http://localhost:9901/config_dump | jq -r '.configs[] | .["@type"]'
        type.googleapis.com/envoy.admin.v3.BootstrapConfigDump
        type.googleapis.com/envoy.admin.v3.ClustersConfigDump
        type.googleapis.com/envoy.admin.v3.ListenersConfigDump
        type.googleapis.com/envoy.admin.v3.ScopedRoutesConfigDump
        type.googleapis.com/envoy.admin.v3.RoutesConfigDump
        type.googleapis.com/envoy.admin.v3.SecretsConfigDump
    ```

2. 监控相关:

    ```
    /stats: print server stats
    /stats/prometheus: print server stats in prometheus format
    ```

    ```bash
    $ curl -s http://localhost:9901/stats | cut -d. -f1 | sort | uniq
        cluster
        cluster_manager
        filesystem
        http
        http1
        listener
        listener_manager
        main_thread
        runtime
        server
        vhost
        workers
    
    $ curl -s http://localhost:9901/stats?filter='^http\.ingress_http'
    $ curl -s "http://localhost:9901/stats?filter=http.ingress_http.rq&format=json" | jq '.stats'
    ```

3. 服务状态信息
    ```
    /server_info
    /memory
    /contention
    /init_dump
    /hot_restart_version
    ```

4. 监听配置
    ```
    /config_dump
    /clusters
    /listeners
    /certs
    ```

5. 健康检查
    ```
    /healthcheck/fail: cause the server to fail health checks
    /healthcheck/ok: cause the server to pass health checks
    /ready
    ```

6. 修改配置
    ```
    /cpuprofiler: enable/disable the CPU profiler
    /drain_listeners: drain listeners

    /heapprofiler: enable/disable the heap profiler
    /logging: query/change logging levels

    /quitquitquit: exit the server

    /reopen_logs: reopen access logs
    /reset_counters: reset all counters to zero

    /runtime: print runtime values
    /runtime_modify: modify runtime values

    ```

### wasm

![envoy-wasm-arch](imgs/envoy-wasm-arch.jpg)

![envoy-wasm-operator-principle](imgs/envoy-wasm-operator-principle.png)

### Tips

```shell

RUN go env -w GOPROXY=https://goproxy.cn,direct

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

```

TODO:
```
https://www.envoyproxy.io/docs/envoy/v1.17.3/start/sandboxes/load_reporting_service


```

## HTTP Filter
### Lua Filter

HTTP Lua Filter 允许在 请求和响应 流中, 使用 [LuaJIT 运行时](https://luajit.org/), 执行 Lua 脚本代码.

> [moonjit](https://github.com/moonjit/moonjit/) 是新一代的 LuaJIT 运行时环境, 并且支持个多 5.2 版本 和 多平台的特性. Envoy 可以使用 `--//source/extensions/filters/common/lua:moonjit=1` 的 bazel 选项 来增加 Envoy 对 moonjit 的支持.

特点:
- 所有 Lua 脚本执行环境是每个 Envoy 线程独立的. 即 没有真正的全局数据, 任何全局的数据都是 envoy 线程独立的.
- 所有脚本都作为协程(coroutines)运行. 即 这些脚本使用同步模型写出来, 但在执行时, 仍然是异步的.
- 不要在脚本中执行阻塞操作. 这对 Envoy 的性能表现是灾难性的.


当前支持的高级特性:
- 在请求/响应流 中, 检查 header, body 和 trailers .
- 修改 headers, trailers
- 为检查(inspection), 阻塞和缓存整个 请求/响应的 body.
- 向 upstream host 执行异步的 HTTP 请求.
- 直接响应请求, 并且跳过后面的 filter 过滤.

默认情况下, `inline_code` 中定义的 lua 代码会被认为是 `GLOBAL` script, Envoy 会为每个 HTTP 请求执行 `inline_code` 中定义的代码.

#### 配置:
##### extensions.filters.http.lua.v3.Lua

```yaml
1. extensions.filters.http.lua.v3.Lua

{
  "inline_code": "...",
  "source_codes": "{...}"
}

# inline_code
  inline_code: |
    -- Called on the request path.
    function envoy_on_request(request_handle)
      -- Do something.
    end
    -- Called on the response path.
    function envoy_on_response(response_handle)
      -- Do something.
    end
    
# source_codes
source_codes:
  hello.lua:
    inline_string: |
      function envoy_on_response(response_handle)
        -- Do something.
      end
  world.lua:
    filename: /etc/lua/world.lua
```

示例:
```yaml
name: envoy.filters.http.lua
typed_config:
  "@type": type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua
  inline_code: |
    function envoy_on_request(request_handle)
      -- do something
    end
  source_codes:
    hello.lua:
      inline_string: |
        function envoy_on_request(request_handle)
          request_handle:logInfo("Hello World.")
        end
    bye.lua:
      inline_string: |
        function envoy_on_response(response_handle)
          response_handle:logInfo("Bye Bye.")
        end
```

##### extensions.filters.http.lua.v3.LuaPerRoute

通过提供 `LuaPerRoute` 配置, Lua HTTP filter 可以被 disable 或 overridden . 

`LuaPerRoute` 可以被定义在 如下配置部分:
- virtual host
- route
- weighted cluster 

`LuaPerRoute` 提供如下两种方式来负载 `GLOBAL` lua 脚本:
- 通过提供一个 lua 脚本的名字, 该名字定义于 `source_codes` 字段的字典配置当中.
- 通过提供 `source_code` 字段提供的 脚本代码. 此处允许脚本通过 **RDS** 获取.

```yaml
{
  "disabled": "...",    # bool, 为特定的 vhost 或 route 禁用 lua filter.
  "name": "...",        # 所使用的 lua 代码的名称, 列表存储在 Lua.source_codes 中.
  "source_code": "{...}" # lua 代码段, 可以为 RDS 发现 或者 文本代码段.
}

```

禁用 filter:
```yaml
typed_per_filter_config:
  envoy.filters.http.lua:
    "@type": type.googleapis.com/envoy.extensions.filters.http.lua.v3.LuaPerRoute
    disabled: true
```

使用 `source_code.inline_string` 覆盖 `GLOBAL` lua 脚本:
```yaml
typed_per_filter_config:
  envoy.filters.http.lua:
    "@type": type.googleapis.com/envoy.extensions.filters.http.lua.v3.LuaPerRoute
    source_code:
      inline_string: |
        function envoy_on_response(response_handle)
          response_handle:logInfo("Goodbye.")
        end
```
#### Envoy Lua API

##### Stream handle API
Envoy 会在 Lua Filter 中 寻找 并调用 如下两个函数, 在 Lua 脚本段可以定义 两个或者其中一个函数:
- `envoy_on_request(request_handle)`: 在请求流中, 作为协程(coroutine) 调用. 传入 `handle` 作为参数.
- `envoy_on_response(response_handle)`: 在响应流中, 作为协程(coroutine) 调用. 传入 `handle` 作为参数.

在 stream handle 中支持如下函数:
- `headers()` : 返回 请求/响应 首部.

    ```lua
    local headers = handle:headers()
    ```

- `body()`: 返回 请求/响应 body. 此处调用会阻塞脚本的执行, 直到 接收到所有的 body 内容到缓存.

    ```lua
    local body = handle:body(always_wrap_body)
    ```

    `always_wrap_body` 是个布尔参数, 用来要求 envoy 永远返回一个 body object, 即使 body 为 空.

- `bodyChunks()`: 返回一个迭代器, 用来迭代接受到的 body. Envoy 会在执行每次迭代中 暂停脚本执行, 直到收到结果, 但是不会缓存接受到的 body 内容. 主要用来接受流式数据.

    ```lua
    local iterator = handle:bodyChunks()
    ```

    示例:
    ```lua
    for chunk in request_handle:bodyChunks() do
        request_handle:log(0, chunk:length())
    end
    ```

- `trailers()`: 返回一个 stream 的 trailer 信息. 如果没有 trailer 信息, 可能返回 `nil`. 这些 trailer 信息可能被其他 filter 修改.

- `log*()`: 使用 envoy 的 application logging 打印日志.

    ```lua
    -- message is a string to log.
    handle:logTrace(message)
    handle:logDebug(message)
    handle:logInfo(message)
    handle:logWarn(message)
    handle:logErr(message)
    handle:logCritical(message)
    ```

- `httpCall()` 向 upstream host 发起 http 调用.

    ```lua
    local headers, body = handle:httpCall(cluster, headers, body, timeout, asynchronous)
    ```
    - cluster: 字符串, 为一个 cluster 的名字.
    - headers: 发送的 key/value 对, 作为请求首部.
        `:method`, `:path`, and `:authority` headers must be set.
    - body: 可选字段, 请求体.
    - timeout: int, 请求超时时间, 单位 milliseconds.
    - asynchronous: 布尔值, 

- `respond()`

- `metadata()`

- `streamInfo()`

- `connection()`

- `importPublicKey()`

- `verifySignature()`

- `base64Escape()`





##### Header object API


##### Buffer API


##### Metadata object API


##### Stream info object API


##### Dynamic metadata object API


##### Connection object API


##### SSL connection object API


#### Lua 脚本示例

修改 headers
```lua
-- Called on the request path.
function envoy_on_request(request_handle)
  -- Wait for the entire request body and add a request header with the body size.
  request_handle:headers():add("request_body_size", request_handle:body():length())
end

-- Called on the response path.
function envoy_on_response(response_handle)
  -- Wait for the entire response body and add a response header with the body size.
  response_handle:headers():add("response_body_size", response_handle:body():length())
  -- Remove a response header named 'foo'
  response_handle:headers():remove("foo")
end
```

向 upstream host 发起请求 http 请求
```lua
function envoy_on_request(request_handle)
  -- Make an HTTP call to an upstream host with the following headers, body, and timeout.
  local headers, body = request_handle:httpCall(
  "lua_cluster",
  {
    [":method"] = "POST",
    [":path"] = "/",
    [":authority"] = "lua_cluster"
  },
  "hello world",
  5000)

  -- Add information from the HTTP call into the headers that are about to be sent to the next
  -- filter in the filter chain.
  request_handle:headers():add("upstream_foo", headers["foo"])
  request_handle:headers():add("upstream_body_size", #body)
end
```

发启 upstream http 请求, 并直接响应客户端请求, 跳过其他的 filter:
```lua
function envoy_on_request(request_handle)
  -- Make an HTTP call.
  local headers, body = request_handle:httpCall(
  "lua_cluster",
  {
    [":method"] = "POST",
    [":path"] = "/",
    [":authority"] = "lua_cluster",
    ["set-cookie"] = { "lang=lua; Path=/", "type=binding; Path=/" }
  },
  "hello world",
  5000)

  -- Response directly and set a header from the HTTP call. No further filter iteration
  -- occurs.
  request_handle:respond(
    {[":status"] = "403",
     ["upstream_foo"] = headers["foo"]},
    "nope")
end
```

打印自定义日志:
```lua
function envoy_on_request(request_handle)
  -- Log information about the request
  request_handle:logInfo("Authority: "..request_handle:headers():get(":authority"))
  request_handle:logInfo("Method: "..request_handle:headers():get(":method"))
  request_handle:logInfo("Path: "..request_handle:headers():get(":path"))
end

function envoy_on_response(response_handle)
  -- Log response status code
  response_handle:logInfo("Status: "..response_handle:headers():get(":status"))
end
```










