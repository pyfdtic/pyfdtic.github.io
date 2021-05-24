## 配置文件

```yaml
admin:
static_resources:
listeners:
clusters:
```

### 查看 admin 配置
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