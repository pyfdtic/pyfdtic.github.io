## Coredns 自定义域名解析
### 1. 增加 hosts 解析
```
    hosts {
        47.92.41.111 blog.mydomain.com
        fallthrough 
    }
```

### 2. 增加 自定义域名解析服务
```
    dev.mydomain.com:53 {
        errors
        cache 30
        forward . 10.9.10.8     # 自定义域名解析服务器地址.
    }
```

### 3. 完整 dns 解析配置
```
apiVersion: v1
kind: ConfigMap
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            upstream 10.9.10.8
            fallthrough in-addr.arpa ip6.arpa
        }
        hosts {
            47.92.41.111 blog.mydomain.com
            fallthrough 
        }
        prometheus :9153
        forward . 10.9.10.8
        cache 30
        loop
        reload
        loadbalance
    }
    dev.mydomain.com:53 {
        errors
        cache 30
        forward . 10.9.10.8     # 自定义域名解析服务器地址.
    }
metadata:
  name: coredns
  namespace: kube-system
```