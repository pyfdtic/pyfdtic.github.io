## 安装配置

```shell
# 安装 linkerd 客户端
$ curl -sL run.linkerd.io/install | sh
$ linkerd version

# 安装前检查
$ linkerd check --pre

# 安装控制平面
$ linkerd install | kubectl apply -f -
$ linkerd check

# 安装插件 viz, 包含 prometheus, dashboard, metrics
$ linkerd viz install | kubectl apply -f - # on-cluster metrics stack

# 其他插件
$ linkerd jaeger install | kubectl apply -f - # Jaeger collector and UI
$ linkerd multicluster install | kubectl apply -f - # multi-cluster components

# 检查
$ linkerd check

# 禁止 kube-system 自动注入代理
$ kubectl label namespace kube-system config.linkerd.io/admission-webhooks=disabled

```

HA 模式安装
```shell
# 控制平面 HA
$ linkerd install --ha | kubectl apply -f -

# Viz 扩展 HA
$ linkerd viz install --ha | kubectl apply -f -

# 在已存在的 Linkerd 集群中开启 HA 模式
$ linkerd upgrade --ha | kubectl apply -f -

```

2.10.0 镜像列表
```txt
cr.l5d.io/linkerd/controller:stable-2.10.0
cr.l5d.io/linkerd/proxy-init:v1.3.9
cr.l5d.io/linkerd/proxy:stable-2.10.0
```

测试:
```shell
curl -sL https://run.linkerd.io/emojivoto.yml \
  | kubectl apply -f -

kubectl -n emojivoto port-forward svc/web-svc 8080:80

curl localhost:8080

# 注入 mesh
kubectl get -n emojivoto deploy -o yaml \
  | linkerd inject - \
  | kubectl apply -f -
# 检查注入结果
linkerd -n emojivoto check --proxy

# watch it run
$ linkerd -n emojivoto viz stat deploy
$ linkerd -n emojivoto viz top deploy
$ linkerd -n emojivoto viz tap deploy/web

```

删除安装

```shell
## 删除数据平面
## To remove the Linkerd data plane proxies, you should remove any Linkerd proxy injection annotations and roll the deployments. When Kubernetes recreates the pods, they will not have the Linkerd data plane attached.
$ kubectl get -n emojivoto deploy -o yaml \
  | linkerd uninject - \
  | kubectl apply -f -

## 删除扩展
$ linkerd viz uninstall | kubectl delete -f -   # To remove Linkerd Viz

$ linkerd jaeger uninstall | kubectl delete -f -    # To remove Linkerd Jaeger

$ linkerd multicluster uninstall | kubectl delete -f -  # To remove Linkerd Multicluster

## 删除控制平面
$ linkerd uninstall | kubectl delete -f -

```

## 特性
1. HTTP/HTTP2, gRPC 代理

    Linkerd 可以代理所有 TCP 链接, 并且会自动为 **HTTP/HTTP2/gRTPC协议**开启高级功能(metrics/lb/retries and more)

    Tips:
    - grpc-go 必须高于 v1.3
    - grpc-js 必须大于 v1.1.0

2. TCP 代理 和 协议监测

    Linkerd 可以代理所有 TCP 流量, 包括 TLS, WebSockets, 和 HTTP 隧道.


3. 超时重试

4. 自动 mTLS

5. ingress

6. 监控和遥测

7. 负载监控

8. 自动代理注入

9.  CNI 插件

10. 监控面板和 Grafana

11. 故障注入

12. 高可用

13. 多集群管理

14. Service Profile

15. Traffic Split(金丝雀/蓝绿部署)


## 参考
- [官方文档](https://linkerd.io/2.10/overview/)
- [Buoyant’s Linkerd Production Runbook](https://buoyant.io/linkerd-runbook#_ga=2.25297085.1005834114.1622285400-1223395688.1622285400)