# kubernetes 

## kubernetes 架构

kubernetes 由 master 和 node 组成, 节点上运行着若干 kubernetes 服务.

Kubernetes 的系统组件都被放到 kube-system 命名空间中, 如 kube-dns 组件, 是在执行 kubeadm init 作为附加组件安装的,为 Cluster 提供 DNS 服务. 

kubelet 是唯一没有以容器形式运行的 kubernetes 组件, 通过 systemd 服务运行.

### master

master 是 kubernetes 的大脑, 运行的服务有 kube-apiserver, kub-scheduler, kube-controller-manager, etcd, Pod 网络(如 flabbel).

- kube-apiserver
    
    API Server 提供 HTTP/HTTPS RESTful API, 即 Kubernetes API. API Server 是 Kubernetes Cluster 的前端接口, 各种客户端工 以及 kubernetes 其他组件可以通过他管理 cluster 的各种资源.

- kube-scheduler
    
    scheduler 决定 将 Pod 放到那个 Node 上运行. scheduler 在调度时, 会充分考虑 Cluster 的拓扑结构, 当前各节点的负载, 以及应用对高可用, 性能, 数据亲和性的需求.

- kube-controller-manager
        
    Controller Manager 负责管理 Cluster 各种资源, 保证资源处于预期状态. Controller Manager 由多种 controlelr 组成, 不同的 controller 管理不同的资源, 如

    - replication controller : 管理 Deployment, StatefulSet, DaemonSet 的生命周期
    - endpoints controller
    - namespace controller : 管理 Namespace 资源
    - serviceaccounts controller

- etcd 

    负责保存 Kubernetes Cluster 的配置信息和各种资源的状态信息, 当数据放生变化时, etcd 会快速的通知 Kubernetes 相关组件.

- Pod 网络
    
    Pod 之间相互通信, 必须部署 Pod 网络, 如 flannel, calile 等.


### Node 节点

Node 是 Pod 运行的地方, Kubernetes 支持 Docker, rkt 等容器 Runtime.

- kubelet
    
    kubelet 是 Node 的 aget, 当 Scheduler 确定在某个 Node 上运行 Pod 后, 会将 Pod 的具体配置信息(Volume, image等) 发送给该节点的 kubelet, kubelet 会根据这些信息创建和运行 Pod, 并向 master 报告运行状态.

- kube-proxy
    
    service 在逻辑上代表了后端的多个 pod, 外界通过 service 访问 pod. service 接收到的请求 通过 kube-proxy 状态到 pod.

- Pod 网络
    
    Pod 之间相互通信.

## kubeadm 安装

### 1. 在 master 操作
```
$ kubeadm init --apiserver-advertise-address 172.16.0.105 --pod-network-cidr=10.244.0.0/16
    --apiserver-advertise-address 指明 master 使用 那个 interface 与其他节点 通信
    --pod-network-cidr : 制动 pod 网络的范围. k8s 支持多种网络方案, 且不同网络方案对 --pod-network-cidr 有自己的要求, 此处使用 flannel 方案, 必须设置为 CIDR.
```
返回信息:
```
I0715 18:33:03.371488   20968 feature_gate.go:230] feature gates: &{map[]}
[init] using Kubernetes version: v1.11.0
[preflight] running pre-flight checks
    [WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
I0715 18:33:03.391128   20968 kernel_validator.go:81] Validating kernel version
I0715 18:33:03.391182   20968 kernel_validator.go:96] Validating kernel config
    [WARNING SystemVerification]: docker version is greater than the most recently validated version. Docker version: 18.03.1-ce. Max validated version: 17.03
    [WARNING Hostname]: hostname "izj6c4v865pdzr9a5004a2z" could not be reached
    [WARNING Hostname]: hostname "izj6c4v865pdzr9a5004a2z" lookup izj6c4v865pdzr9a5004a2z on 100.100.2.138:53: no such host
    [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
[preflight/images] Pulling images required for setting up a Kubernetes cluster
[preflight/images] This might take a minute or two, depending on the speed of your internet connection
[preflight/images] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[preflight] Activating the kubelet service
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [izj6c4v865pdzr9a5004a2z kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.16.0.105]
[certificates] Generated apiserver-kubelet-client certificate and key.
[certificates] Generated sa key and public key.
[certificates] Generated front-proxy-ca certificate and key.
[certificates] Generated front-proxy-client certificate and key.
[certificates] Generated etcd/ca certificate and key.
[certificates] Generated etcd/server certificate and key.
[certificates] etcd/server serving cert is signed for DNS names [izj6c4v865pdzr9a5004a2z localhost] and IPs [127.0.0.1 ::1]
[certificates] Generated etcd/peer certificate and key.
[certificates] etcd/peer serving cert is signed for DNS names [izj6c4v865pdzr9a5004a2z localhost] and IPs [172.16.0.105 127.0.0.1 ::1]
[certificates] Generated etcd/healthcheck-client certificate and key.
[certificates] Generated apiserver-etcd-client certificate and key.
[certificates] valid certificates and keys now exist in "/etc/kubernetes/pki"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/scheduler.conf"
[controlplane] wrote Static Pod manifest for component kube-apiserver to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[controlplane] wrote Static Pod manifest for component kube-controller-manager to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[controlplane] wrote Static Pod manifest for component kube-scheduler to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[etcd] Wrote Static Pod manifest for a local etcd instance to "/etc/kubernetes/manifests/etcd.yaml"
[init] waiting for the kubelet to boot up the control plane as Static Pods from directory "/etc/kubernetes/manifests"
[init] this might take a minute or longer if the control plane images have to be pulled
[apiclient] All control plane components are healthy after 41.001733 seconds
[uploadconfig] storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.11" in namespace kube-system with the configuration for the kubelets in the cluster
[markmaster] Marking the node izj6c4v865pdzr9a5004a2z as master by adding the label "node-role.kubernetes.io/master=''"
[markmaster] Marking the node izj6c4v865pdzr9a5004a2z as master by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[patchnode] Uploading the CRI Socket information "/var/run/dockershim.sock" to the Node API object "izj6c4v865pdzr9a5004a2z" as an annotation
[bootstraptoken] using token: 41efly.f8cnstm6ao7iz422
[bootstraptoken] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstraptoken] creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 172.16.0.105:6443 --token 41efly.f8cnstm6ao7iz422 --discovery-token-ca-cert-hash sha256:eb68f28368883e8c3789da0927d6a70f4ef06526f5a350c5276373dd4bb91cc6
```

以上 cmd 主要做一下几件事:

- kubeadm 执行初始化前的检查,
- 生成 token 和 证书
- 生成 KubeConfig 文件, kubelet 需要用该文件与 Master 通信
- 安装 Master 组件, 会从 Google 的 Registry 下载组件的 docker 镜像, 该步骤会花费一些时间, 取决于网络质量.
- 安装附件组件 kube-proxy 和 kube-dns
- Kubernetes master 初始化成功
- 提示如何配置 kubectl
- 提示如何安装 Pod 网络.
- 提示如何注册其他节点到 Cluster .

配置 kubectl 

```
## bob 是运行 kubectl 的普通用户.
# mkdir /home/bob/.kube
# cp -i /etc/kubernetes/admin.conf /home/bob/.kube/config
# chown bob.bob /home/bob/.kube/config

## 添加自动补全功能, 使用 bob 用户
$ echo "source <(kubectl completion bash)" >> ~/.bashrc
```

安装 pod 网络

```
## 使用 bob 用户
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    clusterrole.rbac.authorization.k8s.io/flannel created
    clusterrolebinding.rbac.authorization.k8s.io/flannel created
    serviceaccount/flannel created
    configmap/kube-flannel-cfg created
    daemonset.extensions/kube-flannel-ds-amd64 created
    daemonset.extensions/kube-flannel-ds-arm64 created
    daemonset.extensions/kube-flannel-ds-arm created
    daemonset.extensions/kube-flannel-ds-ppc64le created
    daemonset.extensions/kube-flannel-ds-s390x created
```

### 2. node 节点注册到 集群

下面的命令由 在 master 上执行 `kubeadm` 是生成.
```
$ kubeadm join 172.16.0.105:6443 --token 41efly.f8cnstm6ao7iz422 --discovery-token-ca-cert-hash sha256:eb68f28368883e8c3789da0927d6a70f4ef06526f5a350c5276373dd4bb91cc6
```

如果没有记录下 token, 可以使用如下命令查看:
```
$ kubeadm token list
```

在 master 查看 node 是否注册到 master:
```
$ kubectl get nodes
    NAME                      STATUS    ROLES     AGE       VERSION
    izj6c4v865pdzr9a5004a2z   Ready     master    29m       v1.11.0
    izj6c9a51n762uyn3wfi5qz   Ready     <none>    1m        v1.11.0
    izj6cdt5e7ronl6vi6qwkrz   Ready     <none>    1m        v1.11.0


一个节点的 ROLE 只是一个 label, 其格式为 `node-role.kubernetes.io/<role>`, 可以手动添加:

$ kubectl label nodes

```

如果 节点处于 NotReady 状态, 则可能是因为, 每个节点需要启动若干组件, 这些组件都在 Pod 中运行, 而这些镜像需要从 Google 下载, 如果尚处于下载中, 则可能处于 NotReady 状态.

```
## 查看 Pod 状态
$ kubelet get pod --all-namespaces

$ kubectl get pod --namespace=default -o wide   ## 指定 namespace, 并拓展输出信息.

## 查看 Pod 的具体状态
$ kubectl describe pod POD_NAME --namespace=kube-system

```

### 3. kubernetes master 节点 pod 调度

出于安全考虑, 默认配置下, Kubernetes 不会讲 Pod 调度到 master, 如果希望将 k8s-master 也当做 Node 使用, 可执行如下命令:
`$ kubectl taint node k8s-master node-role.kubernetes.io/master-`

取消 k8s-master 调度 pod:
`$ kubectl taint node izj6c4v865pdzr9a5004a2z node-role.kubernetes.io/master="":NoSchedule`

**取消调度, 并不会使 在k8s-master 可调度期间运行在 k8s-master 上的 pod 停止**.
停止运行在 master 节点上的 pod 有两种方式: 

- 强制杀掉在 master 上运行的 pod 重新调度. 

    `$ kubectl delete pod nginx-deployment-cfg-5799655d4d-xrqhz`

- 在 deployment 缩容时, 取消 taint 的 master 节点上的 pod 优先被停止.

## kubernetes 运行应用.

kubernetes 中对象的命名方式是: **子对象名字 = 父对象名字 + 随机字符串**.

kubernetes 支持两种创建资源的方式, 

1. 使用 kubectl 命令直接创建, 在命令行中通过参数执行资源的属性.
    
    简单, 直观, 快捷, 适合临时测试或者实验.

2. 通过配置文件和 `kubectl apply` 创建, 配置文件采用 YAML 格式.
    
    配置文件描述了最终的状态, 并可以提供创建资源的模板, 可以重复使用.
    可以做版本控制和管理, 适合正式的, 跨环境的, 规模化部署.

    `kubectl apply` 不仅能够创建资源, 也能够对资源进行更新, 非常方便. 同时, Kubernetes 还提供了类似的其他命令, 如 `kubectl create`, `kubectl replace`, `kubectl edit`, `kubectl patch`.

### Deployment

```
## 运行一个 deployment
$ kuberctl run nginx-deployment --image=nginx --replicas=2

## 查看运行结果
$ kubectl get deployment nginx-deployment
```

查看 deployment 详细信息
```
$ kubectl describe deployment nginx-deployment
    OldReplicaSets:  <none>
    NewReplicaSet:   nginx-deployment-75d95848db (2/2 replicas created)
    Events:
      Type    Reason             Age   From                   Message
      ----    ------             ----  ----                   -------
      Normal  ScalingReplicaSet  3m    deployment-controller  Scaled up replica set nginx-deployment-75d95848db to 2
```

如上的 deployment 信息, 可以看到创建了一个 ReplicaSet `nginx-deployment-75d95848db` , Events 是 Deployment 的日志, 记录了 ReplicaSet 的启动过程. 即 Deployment 是通过 ReplicaSet 来管理 Pod 的. 可以执行 `kubectl describe replicaset nginx-deployment-75d95848db` 得到印证.

```
$ kubectl describe replicaset nginx-deployment-75d95848db
Name:           nginx-deployment-75d95848db
... ...
Controlled By:  Deployment/nginx-deployment
... ...
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  7m    replicaset-controller  Created pod: nginx-deployment-75d95848db-tdfcs
  Normal  SuccessfulCreate  7m    replicaset-controller  Created pod: nginx-deployment-75d95848db-58f9t

$ kubectl get pods
NAME                                READY     STATUS    RESTARTS   AGE
nginx-deployment-75d95848db-58f9t   1/1       Running   0          11m
nginx-deployment-75d95848db-tdfcs   1/1       Running   0          11m

$ kubectl describe pod nginx-deployment-75d95848db-58f9t
Name:           nginx-deployment-75d95848db-58f9t
Namespace:      default
Node:           izj6c9a51n762uyn3wfi5qz/172.16.0.106
... ...
Controlled By:  ReplicaSet/nginx-deployment-75d95848db
... ... 
Events:
  Type    Reason     Age   From                              Message
  ----    ------     ----  ----                              -------
  Normal  Scheduled  12m   default-scheduler                 Successfully assigned default/nginx-deployment-75d95848db-58f9t to izj6c9a51n762uyn3wfi5qz
  Normal  Pulling    12m   kubelet, izj6c9a51n762uyn3wfi5qz  pulling image "nginx"
  Normal  Pulled     12m   kubelet, izj6c9a51n762uyn3wfi5qz  Successfully pulled image "nginx"
  Normal  Created    12m   kubelet, izj6c9a51n762uyn3wfi5qz  Created container
  Normal  Started    12m   kubelet, izj6c9a51n762uyn3wfi5qz  Started container
```

deployment , replicaset, pod 关系如下:

```
    deployment                                 nginx-deployment
        |                                              |
    replicaset  ==>                       nginx-deployment-75d95848db
       / \                                       /               \
    pod  pod         nginx-deployment-75d95848db-58f9t     nginx-deployment-75d95848db-tdfcs   

```

#### Deployment 配置文件

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment-cfg
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: web_server
    spec:
      containers:
      - name: nginx
        image: nginx

-- 配置选项说明:

apiVersion : 当前配置格式版本
kind : 要创建的资源类型, 此处为 Deployment
metadata : 该类型资源的元数据, name 为 必选项.
spec : 该 Deployment 的规格说明.
replicas : 指明副本数量, 默认为 1
template : 定义 Pod 的模板, 这个配置文件的重要部分.
metadata : 定义 Pod 的元数据, 至少需要定义一个 label. label 的 key 和 value 可以任意指定.
spec : 描述 Pod 的规格, 此部分定义 Pod 中每一个容器的属性, name 和 image 是 必选项.
```

使用配置文件创建 deployment

```
$ kubectl apply -f deployment/nginx-deployment.yml
    deployment.extensions/nginx-deployment-cfg created

$ kubectl get deployments
    NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    nginx-deployment-cfg   2         2         2            2           17s

$ kubectl get replicaset
    NAME                              DESIRED   CURRENT   READY     AGE
    nginx-deployment-cfg-5799655d4d   2         2         2         51s

$ kubectl get pod -o wide
    NAME                                    READY     STATUS    RESTARTS   AGE       IP           NODE
    nginx-deployment-cfg-5799655d4d-krxnl   1/1       Running   0          59s       10.244.2.4   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-5799655d4d-x95hb   1/1       Running   0          59s       10.244.1.4   izj6c9a51n762uyn3wfi5qz
```

#### 删除 deployment

```
$ kubectl delete deployment nginx-deployment-cfg

或者

$ kubectl delete -f deployment/nginx-deployment.yml
```

#### 扩缩容

编辑 deployment 的配置文件, 修改 `replicas` 配置项, 就可以实现.

```
$ kubectl get deployments
    NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    nginx-deployment   2         2         2            2           41m

$ kubectl get pods -o wide
    NAME                                    READY     STATUS    RESTARTS   AGE       IP           NODE
    nginx-deployment-cfg-5799655d4d-9qwvx   1/1       Running   0          1m        10.244.2.5   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-5799655d4d-lw7g6   1/1       Running   0          1m        10.244.1.5   izj6c9a51n762uyn3wfi5qz

$ vim deployment/nginx-deployment.yml
    spec:
      replicas: 5

$ kubectl apply -f deployment/nginx-deployment.yml

$ kubectl get pods -o wide
    NAME                                    READY     STATUS              RESTARTS   AGE       IP           NODE
    nginx-deployment-cfg-5799655d4d-2xc42   0/1       ContainerCreating   0          8s        <none>       izj6c9a51n762uyn3wfi5qz
    nginx-deployment-cfg-5799655d4d-5jr7d   1/1       Running             0          8s        10.244.1.7   izj6c9a51n762uyn3wfi5qz
    nginx-deployment-cfg-5799655d4d-92rp6   1/1       Running             0          8s        10.244.2.8   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-5799655d4d-9qwvx   1/1       Running             0          2m        10.244.2.5   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-5799655d4d-lw7g6   1/1       Running             0          2m        10.244.1.5   izj6c9a51n762uyn3wfi5qz

```

#### Failover

当集群中的 node 应某种原因故障时, kubernetes 会自动检测到 node 节点不可用, 并将该节点上的 pod 标记为 `Unknown` 状态, 同时, 在集群中的其他节点上创建 (与故障 node 节点上 pod)数量相同的 pod, 维持配置的副本数量.

当 故障节点**恢复**后, 故障节点回自动注册回 kubernetes 集群. 同时, kubernetes 会将 状态为 UNknown 的 pod 删除掉, 但是, 已经在运行的 Pod **不会**重现调度回 故障节点.

```
$ kubectl get nodes
    NAME                      STATUS     ROLES     AGE       VERSION
    izj6c4v865pdzr9a5004a2z   Ready      master    4h        v1.11.0
    izj6c9a51n762uyn3wfi5qz   Ready      <none>    3h        v1.11.0
    izj6cdt5e7ronl6vi6qwkrz   NotReady   <none>    3h        v1.11.0

$ kubectl get pods -o wide
    NAME                                    READY     STATUS    RESTARTS   AGE       IP            NODE
    nginx-deployment-cfg-5799655d4d-5jr7d   1/1       Running   0          27m       10.244.1.7    izj6c9a51n762uyn3wfi5qz
    nginx-deployment-cfg-5799655d4d-6gfnz   1/1       Running   0          14s       10.244.1.10   izj6c9a51n762uyn3wfi5qz
    nginx-deployment-cfg-5799655d4d-92rp6   1/1       Unknown   0          27m       10.244.2.8    izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-5799655d4d-9qwvx   1/1       Unknown   0          30m       10.244.2.5    izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-5799655d4d-kdk88   1/1       Running   0          14s       10.244.1.9    izj6c9a51n762uyn3wfi5qz
    nginx-deployment-cfg-5799655d4d-lw7g6   1/1       Running   0          30m       10.244.1.5    izj6c9a51n762uyn3wfi5qz

-- 节点恢复后, 
$ kubectl get nodes
    NAME                      STATUS    ROLES     AGE       VERSION
    izj6c4v865pdzr9a5004a2z   Ready     master    4h        v1.11.0
    izj6c9a51n762uyn3wfi5qz   Ready     <none>    3h        v1.11.0
    izj6cdt5e7ronl6vi6qwkrz   Ready     <none>    3h        v1.11.0
    
$ kubectl get pods -o wide
    NAME                                    READY     STATUS    RESTARTS   AGE       IP            NODE
    nginx-deployment-cfg-5799655d4d-5jr7d   1/1       Running   0          31m       10.244.1.7    izj6c9a51n762uyn3wfi5qz
    nginx-deployment-cfg-5799655d4d-6gfnz   1/1       Running   0          4m        10.244.1.10   izj6c9a51n762uyn3wfi5qz
    nginx-deployment-cfg-5799655d4d-kdk88   1/1       Running   0          4m        10.244.1.9    izj6c9a51n762uyn3wfi5qz
    nginx-deployment-cfg-5799655d4d-lw7g6   1/1       Running   0          34m       10.244.1.5    izj6c9a51n762uyn3wfi5qz
```

#### 使用 label 控制 pod 的位置
默认情况下, Scheduleler 会将 Pod 调度到所有可用的 Node, 但在有些情况下, 可能希望将 Pod 部署到指定的 Node, 如将有大量磁盘 IO 的 Pod 部署到配置了 SSD 的 Node.

Kubernetes 通过 label 来实现这个功能. label 是 键值对, 各种资源都可以设置 label, 灵活的添加各种自定义属性. Kubernetes 也会 维护有自己预定义的 label. 

```
-- 标记某个节点是配置了 SSD 的节点

$ kubectl label node izj6cdt5e7ronl6vi6qwkrz disktype=ssd
    node/izj6cdt5e7ronl6vi6qwkrz labeled

$ kubectl get nodes --show-labels
    NAME                      STATUS    ROLES     AGE       VERSION   LABELS
    izj6c4v865pdzr9a5004a2z   Ready     master    4h        v1.11.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=izj6c4v865pdzr9a5004a2z,node-role.kubernetes.io/master=
    izj6c9a51n762uyn3wfi5qz   Ready     <none>    3h        v1.11.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=izj6c9a51n762uyn3wfi5qz,shouldrun=here
    izj6cdt5e7ronl6vi6qwkrz   Ready     <none>    3h        v1.11.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,disktype=ssd,kubernetes.io/hostname=izj6cdt5e7ronl6vi6qwkrz
```

指定将 Pod 部署到 具有某个 label 的 node 上: 通过在 Pod 模板的 spec 里通过 nodeSelector 指定 pod 部署到具有 label disktype=ssd 的 node 上.

如果直接修改了 deployment 的配置文件, 则 apply 配置文件之后, 会立即生效, 之前在其他节点上运行的 pod 会被杀掉, 并调度到指定 label 的节点上.

```
$ kubectl get pods -o wide
    NAME                                    READY     STATUS    RESTARTS   AGE       IP            NODE
    nginx-deployment-cfg-5799655d4d-5jr7d   1/1       Running   0          42m       10.244.1.7    izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-5799655d4d-6gfnz   1/1       Running   0          15m       10.244.1.10   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-5799655d4d-kdk88   1/1       Running   0          15m       10.244.1.9    izj6c9a51n762uyn3wfi5qz
    nginx-deployment-cfg-5799655d4d-lw7g6   1/1       Running   0          45m       10.244.1.5    izj6c9a51n762uyn3wfi5qz

$ vim nginx-label-deployment.yml
    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      name: nginx-deployment-cfg
    spec:
      replicas: 4
      template:
        metadata:
          labels:
            app: web_server
        spec:
          containers:
          - name: nginx
            image: nginx
          nodeSelector:
            disktype: ssd

$ kubectl apply -f nginx-label-deployment.yml
    deployment.extensions/nginx-deployment-cfg configured

$ kubectl get pods -o wide
    NAME                                   READY     STATUS    RESTARTS   AGE       IP            NODE
    nginx-deployment-cfg-f9795f88b-627h8   1/1       Running   0          25s       10.244.2.13   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-f9795f88b-7xkhj   1/1       Running   0          21s       10.244.2.14   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-f9795f88b-826xh   1/1       Running   0          30s       10.244.2.12   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-f9795f88b-z8nhm   1/1       Running   0          30s       10.244.2.11   izj6cdt5e7ronl6vi6qwkrz

```
删除 node 上的 label, `-` 即删除. 删除 label 之后, pod 并不会重新部署, 依然在 原节点运行, 除非在 deployment 的配置文件中删除掉 nodeSelector 配置重新部署, kubernetes 才会删除之前的 pod, 重新调度.
**如果 deployment 配置中的 nodeSelector 配置被删除, 并且 deployment 被重新部署, 则原有 deployment 的所有 pod 都会被杀掉, 并重新调度和运行新 pod**

```
$ kubectl label node izj6cdt5e7ronl6vi6qwkrz disktype-

-- 示例
$ kubectl get nodes --show-labels
    NAME                      STATUS    ROLES     AGE       VERSION   LABELS
    izj6c4v865pdzr9a5004a2z   Ready     master    4h        v1.11.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=izj6c4v865pdzr9a5004a2z,node-role.kubernetes.io/master=
    izj6c9a51n762uyn3wfi5qz   Ready     <none>    4h        v1.11.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=izj6c9a51n762uyn3wfi5qz,shouldrun=here
    izj6cdt5e7ronl6vi6qwkrz   Ready     <none>    4h        v1.11.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,disktype=ssd,kubernetes.io/hostname=izj6cdt5e7ronl6vi6qwkrz

$ kubectl label node izj6cdt5e7ronl6vi6qwkrz disktype-
    node/izj6cdt5e7ronl6vi6qwkrz labeled

$ kubectl get nodes --show-labels
    NAME                      STATUS    ROLES     AGE       VERSION   LABELS
    izj6c4v865pdzr9a5004a2z   Ready     master    4h        v1.11.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=izj6c4v865pdzr9a5004a2z,node-role.kubernetes.io/master=
    izj6c9a51n762uyn3wfi5qz   Ready     <none>    4h        v1.11.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=izj6c9a51n762uyn3wfi5qz,shouldrun=here
    izj6cdt5e7ronl6vi6qwkrz   Ready     <none>    4h        v1.11.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=izj6cdt5e7ronl6vi6qwkrz


-- 单纯删除 pod 并不会使得 pod 被调度到其他节点上, 应为 deployment 的配置没变.
$ kubectl delete pod nginx-deployment-cfg-f9795f88b-627h8
    pod "nginx-deployment-cfg-f9795f88b-627h8" deleted

$ kubectl get pods -o wide
    NAME                                   READY     STATUS    RESTARTS   AGE       IP            NODE
    nginx-deployment-cfg-f9795f88b-7xkhj   1/1       Running   0          12m       10.244.2.14   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-f9795f88b-826xh   1/1       Running   0          12m       10.244.2.12   izj6cdt5e7ronl6vi6qwkrz
    nginx-deployment-cfg-f9795f88b-8zg2l   0/1       Pending   0          1m        <none>        <none>
    nginx-deployment-cfg-f9795f88b-z8nhm   1/1       Running   0          12m       10.244.2.11   izj6cdt5e7ronl6vi6qwkrz

$ vim nginx-label-deployment.yml
    -- 删除 nodeSelector 配置

$ kubectl apply -f nginx-label-deployment.yml       -- 重新配置 deployment.
```

### DaemonSet

DaemonSet 在每个 node 上**最多**只能运行一个副本. 其典型应用场景有:

- 在集群的每个节点上运行**存储** DaemonSet, 如 glusterd 或 ceph.
- 在每个节点上运行**日志收集** DaemonSet, 如 flunentd 或者 logstash.
- 在每个节点上运行**监控** DaemonSet, 如 Prometheus 或者 collectd.

实际上, kubernetes 自己就在用 DaemonSet 运行系统组件, kube-flannel-ds 和 kube-proxy 分别在每个节点上运行 flannel 和 kube-proxy 组件.
应为 flannel 和 kube-proxy 属于系统组件, 需要制定 `--namespace=kube-system`.

```
$ kubectl get daemonsets --namespace=kube-system
    NAME                      DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR                     AGE
    kube-flannel-ds-amd64     3         3         3         3            3           beta.kubernetes.io/arch=amd64     4h
    kube-flannel-ds-arm       0         0         0         0            0           beta.kubernetes.io/arch=arm       4h
    kube-flannel-ds-arm64     0         0         0         0            0           beta.kubernetes.io/arch=arm64     4h
    kube-flannel-ds-ppc64le   0         0         0         0            0           beta.kubernetes.io/arch=ppc64le   4h
    kube-flannel-ds-s390x     0         0         0         0            0           beta.kubernetes.io/arch=s390x     4h
    kube-proxy                3         3         3         3            3           beta.kubernetes.io/arch=amd64     4h

$ kubectl get pods --namespace=kube-system -o wide
    NAME                                              READY     STATUS    RESTARTS   AGE       IP             NODE
    coredns-78fcdf6894-ctcks                          1/1       Running   0          4h        10.244.0.3     izj6c4v865pdzr9a5004a2z
    coredns-78fcdf6894-dnzrz                          1/1       Running   0          4h        10.244.0.2     izj6c4v865pdzr9a5004a2z
    etcd-izj6c4v865pdzr9a5004a2z                      1/1       Running   0          4h        172.16.0.105   izj6c4v865pdzr9a5004a2z
    kube-apiserver-izj6c4v865pdzr9a5004a2z            1/1       Running   0          4h        172.16.0.105   izj6c4v865pdzr9a5004a2z
    kube-controller-manager-izj6c4v865pdzr9a5004a2z   1/1       Running   0          4h        172.16.0.105   izj6c4v865pdzr9a5004a2z
    kube-flannel-ds-amd64-8wf4n                       1/1       Running   0          4h        172.16.0.105   izj6c4v865pdzr9a5004a2z
    kube-flannel-ds-amd64-kzx6v                       1/1       Running   1          4h        172.16.0.106   izj6c9a51n762uyn3wfi5qz
    kube-flannel-ds-amd64-szsr2                       1/1       Running   1          4h        172.16.0.107   izj6cdt5e7ronl6vi6qwkrz
    kube-proxy-d2hsl                                  1/1       Running   0          4h        172.16.0.106   izj6c9a51n762uyn3wfi5qz
    kube-proxy-q4jjm                                  1/1       Running   0          4h        172.16.0.105   izj6c4v865pdzr9a5004a2z
    kube-proxy-z96c4                                  1/1       Running   1          4h        172.16.0.107   izj6cdt5e7ronl6vi6qwkrz
    kube-scheduler-izj6c4v865pdzr9a5004a2z            1/1       Running   0          4h        172.16.0.105   izj6c4v865pdzr9a5004a2z
```

flannel 配置文件

```
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

$ curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    apiVersion: extensions/v1beta1
    kind: DaemonSet
    metadata:
      name: kube-flannel-ds-arm64
      namespace: kube-system
      labels:
        tier: node
        app: flannel
    spec:
      template:
        metadata:
          labels:
            tier: node
            app: flannel
        spec:
          hostNetwork: true
          nodeSelector:
            beta.kubernetes.io/arch: arm64
          tolerations:
          - key: node-role.kubernetes.io/master
            operator: Exists
            effect: NoSchedule
          serviceAccountName: flannel
          initContainers:
          - name: install-cni
            image: quay.io/coreos/flannel:v0.10.0-arm64
            command:
            - cp
            args:
            - -f
            - /etc/kube-flannel/cni-conf.json
            - /etc/cni/net.d/10-flannel.conflist
            volumeMounts:
            - name: cni
              mountPath: /etc/cni/net.d
            - name: flannel-cfg
              mountPath: /etc/kube-flannel/
          containers:
          - name: kube-flannel
            image: quay.io/coreos/flannel:v0.10.0-arm64
            command:
            - /opt/bin/flanneld
            args:
            - --ip-masq
            - --kube-subnet-mgr
            resources:
              requests:
                cpu: "100m"
                memory: "50Mi"
              limits:
                cpu: "100m"
                memory: "50Mi"
            securityContext:
              privileged: true
            env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            volumeMounts:
            - name: run
              mountPath: /run
            - name: flannel-cfg
              mountPath: /etc/kube-flannel/
          volumes:
            - name: run
              hostPath:
                path: /run
            - name: cni
              hostPath:
                path: /etc/cni/net.d
            - name: flannel-cfg
              configMap:
                name: kube-flannel-cfg


-- 配置参数: DaemonSet 配置文件的语法结构与 Deployment 几乎完全一致, 只是将 kind 设置为 DaemonSet.

hostName : 指定 Pod 直接用的是 Node 网络, 相当于 docker run --network=host. 考虑到 flannel 需要为 集群提供网络链接, 这个需求是合理的.
containers : 定义了运行 flannel 服务的两个容器.

```

kube-proxy 配置文件

```
-- 可以通过 kubectl edit 查看 kube-proxy 配置.

$ kubectl edit daemonset kube-proxy --namespace=kube-system

    apiVersion: extensions/v1beta1
    kind: DaemonSet
    metadata:
      creationTimestamp: 2018-07-15T10:34:18Z
      generation: 1
      labels:
        k8s-app: kube-proxy
      name: kube-proxy
      namespace: kube-system
      resourceVersion: "21828"
      selfLink: /apis/extensions/v1beta1/namespaces/kube-system/daemonsets/kube-proxy
      uid: a1198958-881a-11e8-8f99-00163e02febc
    spec:
      revisionHistoryLimit: 10
      selector:
        matchLabels:
          k8s-app: kube-proxy
      template:
        metadata:
          creationTimestamp: null
          labels:
            k8s-app: kube-proxy
        spec:
          containers:
          - command:
            - /usr/local/bin/kube-proxy
            - --config=/var/lib/kube-proxy/config.conf
            image: k8s.gcr.io/kube-proxy-amd64:v1.11.0
            imagePullPolicy: IfNotPresent
            name: kube-proxy

    ... ...
    status:
      currentNumberScheduled: 3
      desiredNumberScheduled: 3
      numberAvailable: 3
      numberMisscheduled: 0
      numberReady: 3
      observedGeneration: 1
      updatedNumberScheduled: 3

-- 配置参数: 
kind : DaemonSet 指定类型
containers : 定义 kube-proxy 容器
status : 为当前 DaemonSet 的运行时状态, 为 kubectl edit 独有, 其实 kubernetes 集群中的每个当前运行的资源, 都可以通过 kubectl edit 查看其配置和运行状态.

```

#### Prometheus Node Exporter DaemonSet

Prometheus 是流行的系统监控方案, Node Exporter 是 Prometheus 的 agent, 以 DaemonSet 的形式运行在每个被监控的节点上.

如果直接在 docker 中运行 Node Exporter 容器, 命令为:
`$ docker run -d -v "/proc:/host/proc" -v "/sys:/host/sys" -v "/:/rootfs" --net=host prom/node-exporter --path.procfs /host/proc --path.sysfs /host/sys --colector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"`

当使用 DaemonSet 时, 其配置文件 node-exporter.yml 为:
```
$ vim node-exporter.yml

    apiVersion: extensions/v1beta1
    kind: DaemonSet
    metadata:
      name: node-exporter-daemonset
    spec:
      template:
        metadata:
          labels:
            app: prometheus
        spec:
          hostNetwork: true
          containers:
          - name: node-exporter
            image: prom/node-exporter
            imagePullPolicy: IfNotPresent
            command:
            - /bin/node_exporter
            - --path.procfs
            - /host/proc
            - --path.sysfs
            - /host/sys
            - --collector.filesystem.ignored-mount-points 
            - ^/(sys|proc|dev|host|etc)($|/)
            volumeMounts:
            - name: proc
              mountPath: /host/proc
            - name: sys
              mountPath: /host/sys
            - name: root
              mountPath: /rootfs
          volumes:
          - name: proc
            hostPath:
              path: /proc
          - name: sys
            hostPath:
              path: /sys
          - name: root
            hostPath:
              path: /


-- 参数配置说明:

hostNetwork: true  直接使用 Host 网络
command 设置容器启动命令
volumeMounts 通过 Volume 将 Host 路径 /proc, /sys 和 / 映射到容器中.
```

运行 DaemonSet

```
$ kubectl apply -f node-exporter.yml
    daemonset.extensions/node-exporter-daemonset created

$ kubectl get pod -o wide
    NAME                                    READY     STATUS              RESTARTS   AGE       IP             NODE
    node-exporter-daemonset-74dzs           0/1       RunContainerError   0          17s       172.16.0.106   izj6c9a51n762uyn3wfi5qz
    node-exporter-daemonset-t2ds9           0/1       RunContainerError   0          17s       172.16.0.107   izj6cdt5e7ronl6vi6qwkrz

```
### Job
容器按照持续运行时间, 可以分为两类:

- 服务类容器 : 需要持续提供服务, 如 Deployment, ReplicaSet, DaemonSet 都用于管理 服务类容器.
- 工作类容器 : 一次性任务, 如 批处理, 完成后容器退出, 使用 Job.

#### job 配置

```
apiVersion: batch/v1
kind: Job
metadata:
  name: myjob
spce:
  template:
    metadata: 
      nema: myjob
    spec:
      containers:
      - name: hello
        image: busybox
        command: ["echo", "hello k8s job"]
      restartPolicy: Never


-- 配置参数说明:
betch/v1 当前 Job 的 apiVersion
kind: Job 指明当前资源的类型为 Job
restartPolicy 指定什么情况下需要重启容器. 对于 Job 只能设置为 Never 或 OnFailure. 对于其他 controller(如 Deployment) 可以设置为 Always.
```

启动 job
```
$ kubectl apply -f job.yml
    job.batch/mynewjob created

$ kubectl get jobs
    NAME       DESIRED   SUCCESSFUL   AGE
    myjob      1         1            2h
    mynewjob   1         0            26s

$ kubectl get pods
    NAME                                    READY     STATUS      RESTARTS   AGE
    myjob-dh5hm                             0/1       Completed   0          2h
    mynewjob-72c6v                          1/1       Running     0          16s
```

删除 job
```
$ kubectl delete job myjob
    job.batch "myjob" deleted
```

#### job 并行运行
同时运行多个 pod , 提供 job 的执行效率. 

- `parallelism: NUM` 表示 pod 的并行的数量, 默认为 1.
- `completions: NUM` 表示 设置 job 成功完成 pod 的总数, 默认为 1.

```
$ vim job/hello.yml

$ cat job/hello.yml

    apiVersion: batch/v1
    kind: Job
    metadata:
      name: mynewjob
    spec:
      completions: 6
      parallelism: 2
      template:
        metadata:
          name: myjob
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["sleep", "10"]
          restartPolicy: OnFailure

$ kubectl apply -f job/hello.yml
    job.batch/mynewjob created

$ kubectl get jobs
    NAME       DESIRED   SUCCESSFUL   AGE
    mynewjob   6         4            37s

$ kubectl get pods
    NAME                                    READY     STATUS      RESTARTS   AGE
    mynewjob-bz9rn                          0/1       Completed   0          26s
    mynewjob-bzt65                          1/1       Running     0          11s
    mynewjob-c72qc                          1/1       Running     0          11s
    mynewjob-lgbrn                          0/1       Completed   0          26s

$ kubectl get pods
    NAME                                    READY     STATUS      RESTARTS   AGE
    mynewjob-9kqqs                          0/1       Completed   0          1m
    mynewjob-bz9rn                          0/1       Completed   0          2m
    mynewjob-bzt65                          0/1       Completed   0          1m
    mynewjob-c72qc                          0/1       Completed   0          1m
    mynewjob-lfp4p                          0/1       Completed   0          1m
    mynewjob-lgbrn                          0/1       Completed   0          2m

```

#### job 状态
- 成功
    
    当 DESIRED 和 SUCCESSFUL 都为 1, 表示按预期启动了一个 Pod, 并且已经成功执行.
    
    ```
    $ kubectl get jobs
        NAME       DESIRED   SUCCESSFUL   AGE
        myjob      1         1            2h
    ```

- 失败
    
    当 SUCCESSFUL 的 pod 数量为 0 时, 可以看到很多 pod 状态均不正常. 可以通过 kubectl describte pod 查看 pod 的启动日志.

    之所以会出现多个 pod 的情况, 是因为 依据 `restartPolicy: Never` , 失败的容器不会被重启, 但是 Job 的 DESIRED 是 1, 且目前的 SUCCESSFUL 为 0, 不能满足需求, 所以 Job controller 会一致创建新的 Pod, 终止该行为只能删除 job.

    ```
    $ kubectl get job
        NAME       DESIRED   SUCCESSFUL   AGE
        mynewjob   1         0            2m

    $ kubectl get pods
        NAME                                    READY     STATUS               RESTARTS   AGE
        mynewjob-5d6rt                          0/1       ContainerCannotRun   0          1m
        mynewjob-6mfln                          0/1       ContainerCannotRun   0          2m
        mynewjob-6wdnb                          0/1       ContainerCannotRun   0          2m
        mynewjob-jrgtz                          0/1       ContainerCannotRun   0          2m
        mynewjob-rj7qv                          0/1       ContainerCannotRun   0          2m

    $ kubectl describe pod mynewjob-5d6rt
        ... ...
        Events:
          Type     Reason     Age   From                              Message
          ----     ------     ----  ----                              -------
          Normal   Scheduled  2m    default-scheduler                 Successfully assigned default/mynewjob-5d6rt to izj6cdt5e7ronl6vi6qwkrz
          Normal   Pulling    2m    kubelet, izj6cdt5e7ronl6vi6qwkrz  pulling image "busybox"
          Normal   Pulled     2m    kubelet, izj6cdt5e7ronl6vi6qwkrz  Successfully pulled image "busybox"
          Normal   Created    2m    kubelet, izj6cdt5e7ronl6vi6qwkrz  Created container
          Warning  Failed     2m    kubelet, izj6cdt5e7ronl6vi6qwkrz  Error: failed to start container "hello": Error response from daemon: OCI runtime create failed: container_linux.go:348: starting container process caused "exec: \"no such sleep\": executable file not found in $PATH": unknown

    ```

    也可以修改 job 配置文件中的 `restartPolicy: OnFailure`, 此时, 当 job 失败时, 不是创建新的 pod 的, 而是在原来的基础上重新启动, 即 `RESTARTS` 增加.

    ```
    $ kubectl apply -f job/hello.yml
        job.batch/mynewjob created

    $ kubectl get jobs -o wide
        NAME       DESIRED   SUCCESSFUL   AGE       CONTAINERS   IMAGES    SELECTOR
        mynewjob   1         0            8s        hello        busybox   controller-uid=70f9a7f0-88be-11e8-8f99-00163e02febc

    $ kubectl get pods
        NAME                                    READY     STATUS             RESTARTS   AGE
        mynewjob-bsmw4                          0/1       CrashLoopBackOff   3          1m    
    ```

### CronJob
```
apiVersion: batch/v2alpha1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["echo", "hello k8s jobs!"]
          restartPolicy: OnFailure
```

启动 cronjob 与查看详情

```
$ kubectl apply -f job/hello_cronjob.yml
    cronjob.batch/hello created

$ kubectl get cronjob
    NAME      SCHEDULE      SUSPEND   ACTIVE    LAST SCHEDULE   AGE
    hello     */1 * * * *   False     0         <none>          9s

$ kubectl get pods
    NAME                                    READY     STATUS      RESTARTS   AGE
    hello-1531722900-2qsfj                  0/1       Completed   0          2m
    hello-1531722960-dc2q7                  0/1       Completed   0          1m
    hello-1531723020-r8c97                  0/1       Completed   0          12s

---- 查看运行日志
$ kubectl logs hello-1531723020-r8c97
    hello k8s jobs!
```

CronJob 是基于 Job 实现的, 如下:

```
$ kubectl get cronjob
    NAME      SCHEDULE      SUSPEND   ACTIVE    LAST SCHEDULE   AGE
    hello     */1 * * * *   False     1         7s              25m

$ kubectl get jobs
    NAME               DESIRED   SUCCESSFUL   AGE
    hello-1531724700   1         1            2m
    hello-1531724760   1         1            1m
    hello-1531724820   1         1            55s

```

#### debug: 
运行 `kubectl apply -f job/hello_cronjob.yml` 时, 出现如下报错:

```
$ kubectl apply -f job/hello_cronjob.yml
    error: unable to recognize "job/hello_cronjob.yml": no matches for kind "CronJob" in version "batch/v2alpha1"
```

其原因是, Kubernetes 默认没有 enable CronJob 功能, 需要在 kube-apiserver 中加入这个功能, 方法如下:

修改 kube-apiserver 的配置文件, kube-apiserver 本身也是一个 pod, 在启动参数上, 加上 `--runtime-config=batch/v2alpha1=true` 配置, 再次创建 CronJob 即可.

```
$ vim /etc/kubernetes/manifests/kube-apiserver.yaml

    apiVersion: v1
    kind: Pod
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ""
      creationTimestamp: null
      labels:
        component: kube-apiserver
        tier: control-plane
      name: kube-apiserver
      namespace: kube-system
    spec:
      containers:
      - command:
        - kube-apiserver
        - --runtime-config=batch/v2alpha1=true      --> 添加 该行.

-- 重启 kube-apiserver 服务
$ systemctl restart kubelet 

-- 确认 kube-apiserver 已经支持 batch/v2alpha1
$ kubectl api-versions | grep batch
    batch/v1
    batch/v1beta1
    batch/v2alpha1

-- 重新运行 CronJob
$ kubectl apply -f job/hello_cronjob.yml
    cronjob.batch/hello created

$ kubectl get cronjob
    NAME      SCHEDULE      SUSPEND   ACTIVE    LAST SCHEDULE   AGE
    hello     */1 * * * *   False     0         <none>          9s

$ kubectl get cronjob
    NAME      SCHEDULE      SUSPEND   ACTIVE    LAST SCHEDULE   AGE
    hello     */1 * * * *   False     0         36s             4m
```

### ReplicaSet

### StatefulSet

## Service
我们不应当期望 Kubernetes Pod 是健壮的, 而要假设 Pod 中的容器很可能应为各种原因发生故障而死掉. Deployment 等 Controller 通过动态创建和销毁 Pod 来保证应用整体的健壮性. 换句话说, **Pod 是脆弱的, 但 应用是健壮的**.

Kubernetes Service 从逻辑上代表了一组 Pod, 具体是哪些 Pod 则由 label 来选择. Service 由自己的 IP, 而且这个 IP 是不变的. 客户端只需要访问 Service 的 IP, Kubernetes 则负责建立和维护 Service 与 Pod 的映射关系. 无论后端 Pod 如何变化, 对客户端不会有任何影响, 因为 service 没有变.

```
-- deployment

    apiVersion: apps/v1beta1
    kind: Deployment
    metadata:
      name: httpd
    spec:
      replicas: 3
      template:
        metadata:
          labels:
            run: httpd-label
        spec:
          containers:
          - name: httpd
            image: httpd
            ports:
            - containerPort: 80

-- service

    apiVersion: v1
    kind: Service
    metadata:
      name: httpd-srv
    spec:
      selector:
        run: httpd
      ports:
      - protocol: TCP
        port: 8080
        targetPort: 80

-- 配置参数说明:

apiVersion: v1  Service 的 apiVersion
kind: Service 资源类型
selector 指明挑选那些 label 为 `run: httpd` 的 Pod 作为 Service 的后端.
将 Service 的 8080 端口映射到 Pod 的 80 端口, 使用 TCP 协议.

```

启动 service

```
$ kubectl apply -f service.yml
    service/httpd-srv created

$ kubectl get service
    NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    httpd-srv    ClusterIP   10.107.68.152   <none>        8080/TCP   7s
    kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP    20h

$ kubectl get pods -o wide
    NAME                            READY     STATUS    RESTARTS   AGE       IP             NODE
    httpd-569ff4d8c4-6jcp2          1/1       Running   0          17m       10.244.2.60    izj6cdt5e7ronl6vi6qwkrz
    httpd-569ff4d8c4-8qblv          1/1       Running   0          17m       10.244.1.50    izj6c9a51n762uyn3wfi5qz
    httpd-569ff4d8c4-mfk52          1/1       Running   0          18m       10.244.2.59    izj6cdt5e7ronl6vi6qwkrz

$ kubectl describe service httpd
    Name:              httpd-srv
    Namespace:         default
    Labels:            <none>
    Annotations:       kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"httpd-srv","namespace":"default"},"spec":{"ports":[{"port":8080,"protocol":"TC...
    Selector:          run=httpd-label
    Type:              ClusterIP
    IP:                10.107.68.152
    Port:              <unset>  8080/TCP
    TargetPort:        80/TCP
    Endpoints:         10.244.1.50:80,10.244.2.59:80,10.244.2.60:80         --> 此处为 3 个 pod 的地址.
    Session Affinity:  None
    Events:            <none>

$ curl 10.107.68.152:8080
    <html><body><h1>It works!</h1></body></html>

```

Endpoints `Endpoints: 10.244.1.50:80,10.244.2.59:80,10.244.2.60:80` 指明了 service 与 pod 的对应关系, Pod 的 IP 是在 容器 中配置的, Service 的 Cluster IP 以及 Cluster IP 映射到 Pod IP 都是通过 **iptables**.

### Cluster IP 底层实现
Cluster IP 是一个 虚拟的 IP, 是由 Kubernetes 节点上的 iptables 规则管理的. 可以通过 iptables-save 打印出 当前

```
$ iptables-save | grep 10.107.68.152
    -A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.107.68.152/32 -p tcp -m comment --comment "default/httpd-srv: cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ
    -A KUBE-SERVICES -d 10.107.68.152/32 -p tcp -m comment --comment "default/httpd-srv: cluster IP" -m tcp --dport 8080 -j KUBE-SVC-NUOBVGD4YU5WFXTP

-- 以上两条规则的含义是:
如果 cluster 内的 pod (源地址来自 10.244.0.0/16) 要访问 httpd-srv, 则允许;
其他源地址访问 httpd-srv, 跳转到规则 KUBE-SVC-NUOBVGD4YU5WFXTP.

```
KUBE-SVC-NUOBVGD4YU5WFXTP 规则如下:

```
$ iptables-save | grep KUBE-SVC-NUOBVGD4YU5WFXTP
    -A KUBE-SVC-NUOBVGD4YU5WFXTP -m comment --comment "default/httpd-srv:" -m statistic --mode random --probability 0.33332999982 -j KUBE-SEP-TFCNH7ADCCFCQCVZ
    -A KUBE-SVC-NUOBVGD4YU5WFXTP -m comment --comment "default/httpd-srv:" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-UUSZIG4YUC7TJE2H
    -A KUBE-SVC-NUOBVGD4YU5WFXTP -m comment --comment "default/httpd-srv:" -j KUBE-SEP-XPIJMUYGFWX5JR3B

-- 以上规则的含义是:
1/3 的概率 跳转到 规则 KUBE-SEP-TFCNH7ADCCFCQCVZ
1/3 的概率(剩下 2/3 的一般) 跳转到规则 KUBE-SEP-UUSZIG4YUC7TJE2H
1/3 的概率跳转到规则 KUBE-SEP-XPIJMUYGFWX5JR3B
```
KUBE-SEP-TFCNH7ADCCFCQCVZ, KUBE-SEP-UUSZIG4YUC7TJE2H, KUBE-SEP-XPIJMUYGFWX5JR3B 规则如下:

```
$ iptables-save | grep KUBE-SEP-TFCNH7ADCCFCQCVZ
-A KUBE-SEP-TFCNH7ADCCFCQCVZ -s 10.244.1.50/32 -m comment --comment "default/httpd-srv:" -j KUBE-MARK-MASQ
-A KUBE-SEP-TFCNH7ADCCFCQCVZ -p tcp -m comment --comment "default/httpd-srv:" -m tcp -j DNAT --to-destination 10.244.1.50:80

$ iptables-save | grep KUBE-SEP-UUSZIG4YUC7TJE2H
-A KUBE-SEP-UUSZIG4YUC7TJE2H -s 10.244.2.59/32 -m comment --comment "default/httpd-srv:" -j KUBE-MARK-MASQ
-A KUBE-SEP-UUSZIG4YUC7TJE2H -p tcp -m comment --comment "default/httpd-srv:" -m tcp -j DNAT --to-destination 10.244.2.59:80

$ iptables-save | grep KUBE-SEP-XPIJMUYGFWX5JR3B
-A KUBE-SEP-XPIJMUYGFWX5JR3B -s 10.244.2.60/32 -m comment --comment "default/httpd-srv:" -j KUBE-MARK-MASQ
-A KUBE-SEP-XPIJMUYGFWX5JR3B -p tcp -m comment --comment "default/httpd-srv:" -m tcp -j DNAT --to-destination 10.244.2.60:80

-- 以上规则含义是:
将请求分别转发到后端的三个 Pod.

```

综上, iptables 将访问 service 的流量转发到后端 pod, 而且使用类似 轮训 的负载均衡策略. 需要补充的是, cluster 的每个节点上都配置了相同的 iptables 规则, 这样就确保了整个 Cluster 都能通过 service 的 Cluster IP 访问 service .

### DNS 访问 Service
在 Cluster 中, 除了可以通过 Cluster IP 访问 Service, 还可以通过 DNS 来访问, 使用 kubeadm 部署时, 会默认安装 kube-dns 组件.
```
$ kubectl get deployment --namespace=kube-system
```

kubeadm 部署时, 会默认安装 kube-dns 组件, kube-dns 是一个 DNS 服务器. 每当有新的 servic 被创建, kube-dns 会添加该 Service 的 DNS 记录. Cluster 中的 Pod 可以通过 **<SERVICE)NAME>.<NAMESPACE_NAME>**访问 Service.

```
$ kubectl run busybox --rm -ti --image=busybox sh

/ # wget httpd-srv.default:8080
    Connecting to httpd-srv.default:8080 (10.107.68.152:8080)
    index.html           100% |*************************************|    45   0:00:00 ETA

/ # cat index.html
    <html><body><h1>It works!</h1></body></html>

/ # nslookup httpd-srv
    Server:    10.96.0.10
    Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

    Name:      httpd-srv
    Address 1: 10.107.68.152 httpd-srv.default.svc.cluster.local
```

DNS 服务器是 `kube-dns.kube-system.svc.cluster.local`, 这实际上就是 kube-dns 组件, 它本身是部署在 kube-system namespace 中的一个 service. `httpd-srv.default.svc.cluster.local` 是 httpd-srv 的完整域名, 如果要访问其他 namespace 中的 Service , 就必须带上 namespace 了.

```
-- 查看 namespace
$ kubectl get namespace

```

在一个文件中指定, Deployment 和 service, 使用 `---` 分割.

```
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: httpd2
  namespace: kube-public
spec:
  replicas: 2
  template:
    metadata:
      labels:
        run: httpd2
    spec:
      containers:
      - name: httpd2
        image: httpd
        ports:
        - containerPort: 80
--- 分割线
apiVersion: v1
kind: Service
metadata:
  name: httpd2-srv
  namespace: kube-public
spec:
  selector:
    run: httpd2
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80

```

### 外网访问 Service
为了将 service 暴露给 Cluster 外部, Kubernetes 提供了多种类型的 Service, 默认是 ClusterIP.

- ClusterIP
    
    Service 通过 Cluster 内部的 IP 对外提供服务, 只有 Cluster 内的节点和 Pod 可以访问, 这是默认的 Service 类型.

- NodePort
    
    Service 通过 Cluster 节点的 静态端口对外提供服务. Cluster 外部可以通过 **<NodeIP>:<NodePort>** 访问 Service.

    使用 NodePort 方式, 需要在 service 的配置文件中指定 `type: NodePort`, 其中, PORT(S) 是  Service 在节点上监听的端口, Kubernetes 会从 3000 ~ 32767 中分配一个可用的端口, 每个节点都会监听此端口, 并将请求转发给 Service.
    如下:

    ```
    $ cat node-port-service.yml
        apiVersion: v1
        kind: Service
        metadata:
          name: httpd-svc
        spec:
          type: NodePort
          selector:
            run: httpd-label
          ports:
          - protocol: TCP
            port: 8080
            targetPort: 80
    
    $ kubectl apply -f node-port-service.yml

    $ kubectl get service
        NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
        httpd-svc    NodePort    10.96.163.102   <none>        8080:30182/TCP   4h

    -- 在 三个节点 , 都可以访问 httpd-svc
    $ curl 172.16.0.105:30182
        <html><body><h1>It works!</h1></body></html>

    $ curl 172.16.0.106:30182
        <html><body><h1>It works!</h1></body></html>

    $ curl 172.16.0.107:30182
        <html><body><h1>It works!</h1></body></html>
    ```

    Kubernetes 同样使用 iptables 将 **<NodeIP>:<NodePort>** 映射到 pod. Kubernetes 在每个节点都增加了下面两条 iptables 规则:
    ```
    -A KUBE-NODEPORTS -p tcp -m comment --comment "default/httpd-svc:" -m tcp --dport 30182 -j KUBE-MARK-MASQ
    -A KUBE-NODEPORTS -p tcp -m comment --comment "default/httpd-svc:" -m tcp --dport 30182 -j KUBE-SVC-RL3JAE4GN7VOGDGP
    ```
    KUBE-SVC-RL3JAE4GN7VOGDGP 相关规则如下, 其作用就是 负载均衡到每一个 Pod.
    ```
    -A KUBE-SVC-RL3JAE4GN7VOGDGP -m comment --comment "default/httpd-svc:" -m statistic --mode random --probability 0.33332999982 -j KUBE-SEP-HBIHS6NV3RF2B77B
    -A KUBE-SVC-RL3JAE4GN7VOGDGP -m comment --comment "default/httpd-svc:" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-HANJX3KI6JYOOOTA
    -A KUBE-SVC-RL3JAE4GN7VOGDGP -m comment --comment "default/httpd-svc:" -j KUBE-SEP-NKMRAHPRFQ6XNLLG
    ```

    NodePort 默认**随机**选择, 但是可以通过 `nodePort` 指定某个特定端口. 最终, Node 和 ClusterIP 在各自端口上接收到的请求都会通过 iptables 转发到 Pod 的 targetPort. 如:
    ```
    ports:
    - protocol: TCP
      nodePort: 31111   --> Node 节点上监听的端口,
      port: 8080        --> ClusterIP 上监听的端口
      targetPort: 80    --> Pod 上监听的端口.
    ```

- LoadBalancer
    
    Service 使用 cloud provider 特有的 load balancer 对外提供服务, cloud provider 负责将 load balancer 的流量导向 Service. 目前支持的 cloud provider 有 GCP, AWS, Azur 等.


## Rolling Update
滚动更新是一次只更新一小部分副本, 成功后再更新更多的副本, 最终完成所有副本的更新. 
滚动更新的最大好处是零停机, 整个更新过程始终有副本在运行, 从而保证业务的连续性.

通过设置 `maxSurge` 和 `maxUnavailable` 可以实现精确控制 Pod 替换的数量.

- `maxSurge` : 控制滚动更新过程中副本总数超过 DESIRED 的上限. maxSurge 可以是具体的**整数**(如 3), 也可以是**百分比**, 向上取整. maxSurge 默认值为 25%.
- `maxUnavailable` : 控制滚动升级过程中, 不可用的副本相占 DESIRED 的最大比例. maxUnavailable 可以使具体**整数**(如 3), 也可以是**百分数**, 向下取整. maxUnavailable 默认值为 25%.
- `maxSurge` 值越大, 初始创建的新副本数量就越多; `maxUnavailable` 值越大, 初始销毁的副本数量就越多.

`kubectl apply` 每次更新应用时, Kubernetes 都会记录下当前的配置, 保存为一个 revisoin, 这样就可以回滚到某个特定的 revision. 默认配置下, Kubernetes 只会保留最近的几个 revision, 可以在 Deployment 配置文件中, 通过 `revisionHistoryLimit` 属性增加 revision 数量.

```
$ kubectl apply -f httpd.v2.yml
  apiVersion: apps/v1beta1
  kind: Deployment
  metadata:
    name: httpd
  spec:
    strategy:
      rollingUpdate:
        maxSurge: 35%
        maxUnavailable: 35%
    revisionHistoryLimit: 10
    replicas: 3
    template:
      metadata:
        labels:
          run: httpd
      spec:
        containers:
        - name: httpd
          image: httpd:2.4.16
          ports:
          - containerPort: 80

-- `--record` 参数 可以将当前命令记录到 revision 记录中, 这样就可以知道每个 revision 对应的配置文件了.
$ kubectl apply -f httpd.v2.yml --record  

-- 查看 revision 历史, CHANGE-CAUSE 就是 --record 的结果.
$ kubectl rollout history deployment httpd
  REVISION    CHANGE-CAUSE
  1           kubectl apply --filename=httpd.v1.yml --record=true
  2           kubectl apply --filename=httpd.v2.yml --record=true
  3           kubectl apply --filename=httpd.v3.yml --record=true

-- 回滚到某个版本
$ kubectl rollout undo deployment httpd --to-revision=1

```

## Health Check
强大的自愈能力是 Kubernetes 这类容器编排殷勤的一个重要属性. 自愈的默认实现方式是自动重启发生故障的容器. 初次之外, 还可以利用 **Liveness** 和 **Readiness** 探测机制设置更精细的健康检查.从而, 实现如下需求:

- 零停机 部署;
- 避免部署无效的镜像;
- 更加安全的滚动升级.

Liveness 探测 和 Readiness 探测是独立执行的, 二者之间没有依赖, 所以可以单独使用, 也可以同时使用. 用 Liveness 探测判断容器是否需要重启以实现自愈; 用 Readiness 探测判断容器是否已经准备好对外提供服务.

### 默认的健康检查方式
每个容器启动时都会执行一个进程, 此进程由 Dockerfile 的 CMD 或 ENTRYPOINT 指定. 如果进程退出时, 返回码非零, 则认为容器发生故障, Kubernetes 会根据 `restartPolicy` 重启容器. `restartPolicy` 适用于 Pod 中的所有容器, `restartPolicy` 仅指通过同一节点上的 kubectl 重新启动容器. 失败的容器有 kubectl 以 **5 分钟** 为上限的指数退避延迟(10s, 20s, 40s ...)重新启动, 并在成功执行**十分钟**后重置.

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: healthcheck
  name: healthcheck
spec:
  restartPolicy: OnFailure
  containers:
  - name: healthcheck
    image: busybox
    args:
    - /bin/sh
    - -c 
    - sleep 10; exit 1
```

`restartPolicy` 可取值如下:

- `Always` : 默认
- `OnFailure`
- `Never`

### Liveness
Liveness 探测让用户可以自定义判断容器是否健康的条件. 如果判断失败, Kubernetes 就会删除该容器, 并根据容器的重启策略做相应的处理.

如果一个容器不包含 `livenessProbe` 探针, 那么 kubelet 认为该容器的的 livenessProbe 探针返回的值永远是 Success.

livenessProbe 包含如下三种实现方式:

- `ExecAction`: 在容器内部执行一个命令, 如果该命令的退出码为 0, 则表示容器健康.
- `TCPSocketAction`: 通过容器提供的 IP 地址和端口, 执行 TCP 检查, 如果端口能被访问, 则表示容器健康.
- `HTTPSocketAction`: 通过容器提供的 IP 地址, 端口 及 路径, 调用 HTTP GET 方法, 如果响应码 大于等于 200 且小于 400, 则认为容器状态健康.

```
$ cat liveness-example.yml

  apiVersion: v1
  kind: Pod
  metadata:
    labels:
      test: liveness
    name: liveness
  spec:
    restartPolicy: OnFailure
    containers:
    - name: liveness
      image: busybox
      args:
      - /bin/sh
      - -c
      - touch /tmp/healthcheck; sleep 30; rm -f /tmp/healthcheck ; sleep 600
      livenessProbe:
        exec:                     -- 通过检查文件是否存在, 执行探针. 如果返回为 0, 则成功, 否则失败.
          command:
          - cat
          - /tmp/healthcheck      
        initialDelaySeconds: 30   -- 指定容器启动 多少秒 之后 开始执行 Liveness 探测, 一般根据应用启动的准备时间来设置.
        periodSeconds: 5          -- 指针探测频率. 如果连续执行 3次 Liveness 失败, 则杀掉并重启容器.

-- 查看 liveness 探测状态
$ kubectl describe pod liveness
$ kuebctl get pod liveness
```

### Readiness
Readiness 告诉 Kubernetes 什么时候可以将容器加入到 Service 负载均衡池 中, 对外提供服务. 即 如果 ReadinessProbe 探针探测到失败, 则 Pod 的状态将被修改, Endpoint Controller 将从 Service 的 Endpoint 中删除包含该容器所在的 Pod 的 IP 地址的 Endpoint 条目.

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: readiness
  name: readiness
spec:
  restartPolicy: OnFailure
  containers:
  - name: readiness
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthcheck; sleep 30; rm -f /tmp/healthcheck; sleep 600
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/healthcheck
      initialDelaySeconds: 10
      periodSeconds: 5


-- 查看 Readiness 探测失败日志
$ kubectl describe pod readiness

```
### 使用方式

#### Health Check 在 Scale Up 中的应用
应用的重启需要一个准备阶段, 如加载缓存数据, 链接数据库等, 从容器启动到真正能够提供服务需要一段时间. 可以通过 Readiness 探测判断容器是否就绪, 避免将请求发送到还没有准备好的 backend.

```
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  template:
    metadata:
      labels:
        run: web
    spec:
      containers:
      - name: web
        image: myhttpd
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            scheme: HTTP      -- 指定 协议, 支持 HTTP(默认) 和 HTTPS
            path: /health     -- 指定访问路径
            port: 8080        -- 指定端口
          initialDelaySeconds: 10
          periodSeconds: 5
--- 分割线
apiVersion: v1
kind: Service
metadata:
  name: web-src
spec:
  selector:
    run: web
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
```

#### Health Check 在 滚动更新  中的应用
没有通过 Readiness 监测的副本, 不会被添加到 service 中, 现有副本不会被全部替换, 不影响业务运行.

```
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 10
  template:
    metadata:
      labels:
        run: app
    spec:
      containers:
      - name: app
        image: busybox
        args:
        - /bin/sh
        - -c
        - sleep 30; touch /tmp/healthcheck; sleep 300000
        readinessProbe:
          exec:
            command:
            - cat
            - /tmp/healthcheck
          initialDelaySeconds: 10
          periodSeconds: 5
```

## 数据管理, 数据持久化
### Volume
容器和 Pod 是短暂的, 其含义是他们的生命周期可能很短, 会被频繁的销毁和创建. 容器销毁时, 保存在容器内部文件系统中的数据都会被清除. 可以使用 Kubernetes Volume 持久化保存数据.

Volume 的生命周期独立于容器, Pod 中的容器可能被销毁和创建, 但 Volume 会被保存.

本质上, Kubernetes Volume 是一个目录, 这一点与 Docker Volume 类似. 当 Volume 被 mount 到 Pod, Pod 中的所有容器都可以访问这个 Volume. Volume 提供了对各种 backend 的抽象, 容器在使用 Volume 读写数据的时候不需要关心数据到底是存放在本地节点的文件系统中还是在云硬盘上. 对他来说, 所有类型的 Volume 都只是一个目录.

Kubernetes Volume 支持多种 backend 类型, 包括 emptyDir, hostPath, GCE Persistent Disk, AWS Elastic Block Store, NFS, Ceph 等.

#### 1. emptyDir
最基础的 Volume 类型, 是 Host 上的一个空目录. emptyDir Volume 对于容器来说是持久的, 对于 Pod 则不是. 当 Pod 从节点删除时, Volume 的内容也会被删除. 但如果只是容器被销毁, 而 Pod 仍在, 则 Volume 不受影响. 即 emptyDir Volume 的生命周期与 Pod 一致. Pod 中的所有容器都可以共享 Volume, 他们可以指定各自的 mount 路径.

```
apiVersion: v1
kind: Pod
metadata:
  name: producer-consumer
spec:
  containers:
  - image: busybox
    name: producer
    volumeMounts:
    - mountPath: /producer_dir      -- 将 shared-volume 挂载到 /producer_dir
      name: shared-volume
    args:
    - /bin/sh
    - -c 
    - echo "hello world" > /producer_dir/hello; sleep 300000

  - image: busybox
    name: consumer
    volumeMounts:
    - mountPath: /consumer_dir    -- 将 shared-volume 挂载到 /consumer_dir
      name: shared-volume
    args:
    - /bin/sh
    - -c
    - cat /consumer_dir/hello; sleep 30000

  volumes:
  - name: shared-volume
    emptyDir: {}
```

可以通过 `docker inspect` 查看容器的详细配置信息. emptyDir 是 Host 常见的临时目录, 其优点是能够方便的为 Pod 中的容器提供共享存储, 无需额外的配置. 他不具有持久性, 如果 Pod 不存在了, emptyDir 也就没有了. 适合 Pod 中的容器需要临时共享存储空间的场景.

#### 2. hostPath
hostPath 将 Docker Host 文件系统中已经存在的目录 mount 给 Pod 的容器. 大部分应用都不会使用 hostPath Volume, 应为会增加 Pod 与节点的耦合. 不过那些需要访问 Kubernetes 或 Docker 内部数据(配置文件和二进制库) 的应用则需要使用 hostPath. 如 kube-apiserver, kube-controller-manager, 可以通过 `kubectl edit --namespace=kube-system pod kube-apiserver-k8s-master`.

如果 Pod 被销毁了, hostPath 对应的目录还是会被**保留**, 从这一点来看, hostPath 的持久性比 emptyDir 强.


#### 3. 外部 Storage Provider
如果 Kubernetes 部署在诸如 AWS, GCE, Azure 等公有云上, 可以直接使用云硬盘作为 Volume. 

使用 AWS Elastic Block Store 的例子. 要在 Pod 中使用 EBS Volume , 必须现在 AWS 中创建, 然后通过`volume-id`引用. 其他云硬盘可以参考各个公有云的官方文档.

```
apiVersion: v1
kind: Pod
metadata:
  name: using-ebs
spec:
  containers:
  - images: busybox
    name: using-ebs
    volumeMounts:
    - mountPath: /test-ebs
      name: ebs-volume
  volumes:
  - name: ebs-volume
    awsElasticBlockStore:
      volumeID: <volume-id>     # This AWS EBS volume must already exist!
      fsType: ext4
```

Kubernetes Volume 也可以使用主流的分布式存储, 如 Ceph, GlusterFS. 下面是一个 Ceph 的例子. `/some/path/in/side/cephfs` 被挂载到容器路径 `/test-ceph`. 这些 Volume 类型的最大特点就是不依赖 Kubernetes . Volume 的底层基础设施由独立的存储系统管理, 与 Kubernetes 集群是分离的. 数据被持久化, 即使整个 Kubernetes 崩溃也不会受损. 当然, 运维这样的存储系统通常不是一项简单的工作, 特别是对可靠性, 可用性和扩展性有较高要求的时候.

``` 
apiVersion: v1
kind: Pod
metadata:
  name: using-ceph
spec:
  containers:
    - images: busybox
      name: using-ceph
      volumeMounts:
      - name: ceph-volume
        mountPath: /test-ceph
  volumes:
    - name: ceph-volume
      cephfs:
        path: /some/path/in/side/cephfs
        monitors: "10.16.154.78:6789"
        secretFile: "/etc/ceph/admin.secret"
```

Volume 提供了非常好的数据持久化方案, 不过在可管理性上还有不足. Pod 通常由应用的开发人员维护, 而 Volume 则通常是由存储系统的管理员维护. 开发人员需要获得上面的信息, 要么询问管理员, 要么自己就是管理员. 这样带来的问题就是: 应用开发人员和系统管理员的职责耦合在一起了. 当集群规模变大, 特别是对于生产环境, 考虑到效率和安全性, 这就成为必须要解决的问题. PersistentVolume 和 PersistentVolumeClaim 就是 Kubernetes 给出的解决方案.

### PersistentVolume & PersistentVolumeClaim
PersistentVolume(PV) 是外部存储系统中的一块存储空间, 由管理员创建和维护. 与 Volume 一样, PV 具有持久性, 生成周期独立于 Pod.

PersistentVolumeClaim(PVC) 是对 PV 的申请. PVC 通常由普通用户创建和维护, 用户可以创建一个 PVC, 指明存储资环的容量大小和访问模式(如只读)等信息, Kubernetes 会查找并提供满足条件的 PV. 有了 PVC, 用户只需要高数 Kubernetes 需要什么样的存储资源, 而不必关心真正的空间从哪里分配, 如何访问等底层细节信息. 这些 Storage Provider 的底层信息交给管理员来处理, 只有管理员才关心创建 PersistentVolume 的细节信息.

#### 静态供给(Static Provision)
Kubernetes 支持多种类型的 PersistentVolume , 如 AWS EBS, Ceph, NFS 等. 

使用 NFS 作为 PV 的实例:
```
$ cat nfs-pv.yml

  apiVersin: v1
  kind: PersistentVolume
  metadata:
    name: mypv1
  spec:
    capacity:             -- 指定 PV 容量大小
      storage: 1Gi
    accessModes:          -- 指定访问模式, 支持的访问模式有 3 种: ReadWriteOnce, ReadOnlyMony, ReadWriteMany.
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Recycle      -- 指定 PV 的回收策略为 Recycle.
    storageClassName: nfs     -- 指定 PV 的 class 为 nfs. 相当于为 PV 设置了一个分类, PVC 可以指定 class 申请相应 class 的 PV.
    nfs:
      path: /nfsdata/pv1      -- 指定 PV 在 NFS 服务器上对应的目录.
      server: 192.168.56.105

$ kubectl apply -f nfs-pv.yml

$ kubectl get pv
  NAME  CAPACITY    ACCESSMODES     RECLAIMPOLICY     STATUS    CLAIM   STORAGECLASS  REASON    AGE
  mypv1  1Gi        RWO           Recycle           Available           nfs                     15s
```

`accessModes` 访问模式有 3 种:

- `ReadOnlyMony` : 表示 PV 能以 read-only 模式 mount 到**多个节点**.
- `ReadWriteOnce` : 表示 PV 能以 read-write 模式 mount 到**单个节点**.
- `ReadWriteMany` : 表示 PV 能以 read-write 模式 mount 到**读个节点**.

`persistentVolumeReclaimPolicy` 有三种 回收策略:

- `Retain` : 表示需要管理员手工回收.
- `Recycle` : 清除 PV 中的数据, 相关相当与 rm -rf /the/volume.*
- `Delete` : 删除 Storage Provider 上对应的存储资源, 如 AWS EBS, GCE PD, Azure Disk, OpenstackCinder Volume 等.

创建使用 PVC 

```
$ cat nfs-pvc.yml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: mypvc1
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
    storageClassName: nfs

$ kubectl apply -f nfs-pvc.yml

$ kubectl get pvc
  NAME    STATUS    VOLUME    CAPACITY    ACCESSMODES       STORAGECLASS    AGE
  mypvc1  Bound     mypv1     1Gi         RWO               nfs             23s

$ kubectl get pv
  NAME    CAPACITY    ACCESSMODES     RECLAIMPOLICY     STATUS    CLAIM     STORAGECLASS  REASON    AGE
  mypv1   1Gi         RWO             Recycle           Bound     default/mypvc1  nfs               6m
```

在 Pod 中使用 pvc
```
apiVersion: v1
kind: Pod
metadata:
  name: mypod1
spec:
  containers:
    - name: mypod1
      image: busybox
      args:
      - /bin/sh
      - -c 
      - sleep 300000
      volumeMounts:
      - mountPath: "/mydata"
        name: mydata
  volumes:
    - name: mydata
      persistentVolumeClaim:
        claimName: mypvc1
```

回收 pv: 当 mypvc1 被删除后, Kubernetes 启动了一个新的 Pod recycle-for-mypvc1 , 这个 Pod 的作用就是清除 PV mypvc1 的数据. 此时 mypvc1 的状态为 Released, 表示已经解除了与 mypvc1 的 Bound, 正在清除数据, 不过此时还不可用. 

当数据清除完毕, mypvc1 的状态重新变为 Available, 此时可以被新的 PVC 申请.

```
-- 删除 pvc
$ kubectl delete pvc mypvc1

$ kubectl get pods -o wide
  NAME    READY     STATUS    RESTARTS    AGE    IP     NODE
  mypod1  1/1       Running   0         25min    10.244.4.68    k8s-node-1
  recycle-for-mypvc1 1/1  ContainerCreating   0 26s <none>      k8s-node-1

$ kubectl get pv
  NAME    CAPACITY    ACCESSMODES     RECLAIMPOLICY     STATUS    CLAIM     STORAGECLASS  REASON    AGE
  mypv1   1Gi         RWO             Recycle           Released     default/mypvc1  nfs               16m


$ kubectl get pv
  NAME    CAPACITY    ACCESSMODES     RECLAIMPOLICY     STATUS    CLAIM     STORAGECLASS  REASON    AGE
  mypv1   1Gi         RWO             Recycle           Available       nfs               16m
```

#### 动态供给(Dynamical Provision)
如果没有满足 PVC 条件的 PV, 则会动态创建 PV. 无需提前创建 PV, 更加高效.

动态供给是通过 **StorageClass** 实现的, StorageClass 定义了如何创建 PV. 如下两个示例, 会动态创建  AWS EBS.

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain

--- 分割线
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  zones: us-easy-1d, us-east-1d
  iopsPerGB: 10
```

StorageClass 支持两种 reclaimPolicy , 如下:
- Delete : 默认.
- Retain 

使用 动态供给, 与之前一样, PVC 在申请 PV 时, 只需指定 StorageClass, 容量 以及访问模式即可:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
```

除了 AWS EBS, Kubernetes 支持的 动态供给 PV Provisioner , 见链接(https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner)[https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner]

## Secret && ConfigMap 

### Secret
Secret 会以密文的方式存储数据, 避免了直接在配置文件中保存**敏感信息**. Secret 会以 Volume 的形式被 mount 到 Pod , 容器可通过文件的方式使用 Secret 中的敏感数据. 此外, 容器也可以变量的形式使用这些数据.

#### 1. Secret 创建方式
- `--from-literal`
  
  ```
  $ kubectl create secret generic mysecret --from-literal=username=admin --from-literal=password=123456
  ```

- `--from-file`
  
  每个文件内容对应一个信息条目:

  ```
  $ echo -n admin > ./username
  $ echo -n 123456 > ./password

  $ kubectl create secret generic mysecret --from-file=./username --from-file=./password
  ```
- `--from-env-file`
  
  env 文件中每行 key=value 对应一条信息条目.

  ```
  $ cat << EOF >> env.txt
    username=admin
    password=123456
    EOF

  $ kubectl create secret generic mysecret --from-env-file=env.txt
  ```
- 通过 yaml 配置文件
  
  **文件中的敏感信息必须是通过 base64 编码后的结果**

  ```
  apiVersion: v1
  kind: Secret
  metadata:
    name: mysecret
  data:
    username: YWRtaW4=
    password: MTIzNDUZ
    
  ---分割线
  $ echo -n admin | base64
  $ echo -n 123456 | base64

  -- 创建 secret
  $ kubectl apply -f mysecret.yml
  ```
  

查看 secret 信息

```
-- 查看存在的 secret
$ kubectl get secret mysecret
  NAME      TYPE      DATA    AGE
  mysecret  Opaque    2       5m

-- 查看 secret 条目的 Key
$ kubectl describe secret mysecret
  Name: mysecret
  Namespace: default
  Labels: <none>
  Annotations: <none>

  Type: Opaque

  Data
  ====
  password:   6 bytes
  username:   5 bytes

-- 查看 secret 的 value
$ kubectl edit secret mysecret
  apiVersion: v1
  data:
    username: YWRtaW4=
    password: MTIzNDUZ
  metadata:
    creationTimestamp: 2017-10-10T07:16:21Z
    name: mysecret
    namespace: default
    resoucreVersion: "1598872"
    selfLink: /api/v1/namespace/default/secrets/mysecret
    uid: xxxxxx-xxxxxxx-xxxxxxx
  type: Opaque

```

#### 2. 使用方式
- Volume 方式

  如下配置文件中, kubernetes 会在指定的路径 /etc/foo 下为每条敏感数据创建一个文件, 文件名就是数据条目的 key, 如 /etc/foo/username, /etc/foo/password, value 则以明文方式存放在文件中.
  
  ```
  apiVersion: v1
  kind: Pod
  metadata:
    name: mypod
  spec:
    containers:
    - name: mypod
      image: busybox
      args:
        - /bin/sh
        - -c
        - sleep 10; touch /tmp/healthy; sleep 3000000
      volumeMounts:
      - name: foo
        mountPath: /etc/foo
        readOnly: true
    volumes:
    - name: foo
      secret:
        secretName: mysecret
  ---分割线
  $ kubectl apply -f mypod.yml

  ```

  还可以自定义存放数据的文件名, 如下所示:

  ```
  apiVersion: v1
    kind: Pod
    metadata:
      name: mypod
    spec:
      containers:
      - name: mypod
        image: busybox
        args:
          - /bin/sh
          - -c
          - sleep 10; touch /tmp/healthy; sleep 3000000
        volumeMounts:
        - name: foo
          mountPath: /etc/foo
          readOnly: true
      volumes:
      - name: foo
        secret:
          secretName: mysecret
          items:
          - key: username
            path: my-group/my-username
          - key: password
            path: my-group/my-password
  ```

  以 Volume 形式使用的 Secret 支持**动态更新**: Secret 更新后, 容器中的数据也会更新.

- 环境变量方式
  
  环境变量读取 Secret 很方便, 但是不支持 Secret 动态更新.
  
  ```
  apiVersion: v1
  kind: Pod
  metadata:
    name: mypod
  spec:
    containers:
    - name: mypod
      image: busybox
      args:
        - /bin/sh
        - -c
        - sleep 10; touch /tmp/healthy; sleep 3000000
      env:
        - name: SECRET_USERNAME
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: username
        - name: SECRET_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: password

  --- 在容器中读取变量
  / # echo $SECRET_USERNAME
    admin
  / # echo $SECRET_PASSWORD
    123456
  ```

### ConfigMap
对于一些非敏感信息, 如应用的配置信息, 可以使用 ConfigMap. ConfigMap 的创建和使用方式与 Secret 非常类似, 主要的不同是数据以铭文的形式存放.

#### 1. 创建方式

- `--from-literal`
  每个 --from-literal 对应一个信息条目.

  ```
  $ kubectl create configmap myconfigmap --from-literal=config1=xxx --from-literal=config2=yyy
  ```

- `--from-file`
  每个文件内容对应一个信息条目

  ```
  $ echo -n xxx > ./config1
  $ echo -n yyy > ./config2

  $ kubectl create configmap myconfigmap --from-file=./config1 --from-file=./config2
  ```

- `--from-env-file`
  
  文件 env.txt 中每行 key=value 对应一个信息条目.
  
  ```
  $ cat << EOF >> env.txt
    config1=xxx
    config2=yyy
    EOD

  $ kubectl create configmap myconfigmap --from-env-file=env.txt
  ```

- 通过 YAML 配置文件.
  
  ```
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: myconfigmap
  data:
    config1: xxx
    config2: yyy
  ```

#### 2. 使用方式

- 通过 Volume 方式使用
  
  Volume 形式的 ConfigMap 支持动态更新.
  
  ```
  apiVersion: v1
  kind: Pod
  metadata:
    name: mypod
  spec:
    containers:
    - name: mypod
      image: busybox
      args:
        - /bin/sh
        - -c
        - sleep 10; touch /tmp/healthy; sleep 3000000
      volumeMounts:
      - name: foo
        mountPath: /etc/foo
        readOnly: true
    volumes:
    - name: foo
      configMap:
        name: myconfigmap
  ```

- 通过环境变量方式使用.

  ```
  apiVersion: v1
  kind: Pod
  metadata:
    name: mypod
  spec:
    containers:
    - name: mypod
      image: busybox
      args:
        - /bin/sh
        - -c
        - sleep 10; touch /tmp/healthy; sleep 3000000
      env:
        - name: CONFIG_1
          valueFrom:
            configMapKeyRef:
              name: myconfigmap
              key: config1

        - name: CONFIG_2
          valueFrom:
            configMapKeyRef:
              name: myconfigmap
              key: config2
  ```

#### 3. 最佳实践
大多数情况下, 配置信息都已文件形式提供, 所以在创建 ConfigMap 是通常采用 --from-file 或者 YAML 形式, 读取 ConfigMap 时通常采用 Volume 形式. 如下 给 Pod 传递如何记录日志的配置信息.

```
-- logging.conf
class: logging.handlers.RotatingFileHandler
formatter: precise
level: INFO
filename: %hostname-%timestamp.log
```
使用 --from-file 形式, 将其保存在文件 logging.conf 中, 然后执行如下命令:

```
$ kubectl create configmap myconfigmap --from-file=./logging.conf
```
如果采用 YAML 配置文件, 其内容如下:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: myconfigmap
data:
  logging.cong: |     -- 注意 此处 的 | 符号.
    class: logging.handlers.RotatingFileHandler
    formatter: precise
    level: INFO
    filename: %hostname-%timestamp.log
```

查看创建的 ConfigMap

```
$ kubectl apply -f myconfigmap.yml

$ kubectl get configmap myconfigmap

$ kubectl describe configmap myconfigmap
```

在 Pod 中使用此 ConfigMap, 如下所示:

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: busybox
    args:
      - /bin/sh
      - -c
      - sleep 10; touch /tmp/healthy; sleep 30000
    volumeMounts:
    - name: foo
      mountPath: "/etc"
  volumes:
  - name: foo
    configMap:
      name: muyconfigmap
      items:
        - key: logging.conf
          path: myapp/logging.conf
```

## Helm -- Kubernetes 包管理工具

Helm 是一个 Kubernetes 的更高层次的应用打包工具. 

一个 MySQL 服务, Kubernetes 需要部署 Service(负载均衡及外部访问), Secret(用户密码), PersistentVolumeClaim(持久化空间) , Deployment(部署 Pod, 并使用之前的服务) 等这些服务. 我们可以将这些配置保存到各自的文件中, 或者集中写进一个配置文件, 然后通过 kubectl apply -f 部署. 如果应用只有一个或者有限的几个, 这样的管理方式还可以, 但如果开发的是 微服务架构的应用, 组成应用的服务可能多达数十个甚至几百个. 这些将很能管理, 不容易将这些服务作为一个整体统一发布, 不能高效的共享和重用服务, 不支持应用级别的版本管理, 不支持对部署的应用状态进行验证.

Heml 可以解决这些问题, Helm 帮助  Kubernetes 成为微服务架构应用理想的部署平台.

### 1. Helm 架构

Helm 有两个重要的概念: chart, release.

- `chart`: 是创建一个应用的信息集合, 包括各种 Kubernetes 对象的配置模板, 参数定义, 依赖关系, 文档说明等. chart 是应用部署的自包含逻辑单元. 可以将 chart 想象成 apt或中 yum 中的软件安装包.
- `release`: 是 chart 的运行实例, 代表一个正在运行的应用. 当 chart 被安装到 kubernetes 集群中, 就生成一个 release . chart 能够多次安装到同一个集群中, 每次安装都是一个 release.

helm 是包管理工具, 这里的包即指 chart. Helm 可以:
- 从 零 创建 chart.
- 与 存储 chart 的仓库交互, 拉取, 保存, 更新 chart
- 在 Kubernetes 集群中安装和卸载 release
- 更新, 回滚和测试 release.

Helm 包含两个组件: **Helm 客户端** 和 **Tiller 服务器**, 简单的讲, helm 客户端 负责管理 chart, tiller 服务器 负责管理 release.

![Helm 组件架构图](/imgs/k8s/k8s-architecture.png)

- helm 客户端是终端用户使用的命令工具.
  
  主要作用:

  - 在本地开发 chart
  - 管理 chart 仓库
  - 与 Tiller 仓库交互
  - 在远程 Kubernetes 集群上安装 chart
  - 查看 release 信息
  - 升级或卸载已有的 release.

- tiller 服务器运行在 kubernetes 集群中, 他会处理 helm 客户端的请求, 与 Kubernetes API server 交互.
  
  主要用作:

  - 监听来自 helm 客户端的请求
  - 通过 chart 构建 release
  - 在 Kubernetes 中安装 chart, 并跟踪 release 的状态
  - 通过 API Server 升级或卸载已有的 release.

### 2. 安装
#### 2.1 安装 helm 客户端
```shell
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

$ helm version

-- 创建 helm 命令补全脚本
$ helm completion bash > .helmrc 
$ echo "source .helmrc" >> .bashrc
```

#### 2.2 安装 tiller 服务器
Tiller 服务器安装非常简单, 只需要执行 `helm init` 即可.

Tiller 本身也是作为容器化应用运行在 Kubernetes Cluster 中的.

```
$ helm init


--- 查看 tiller 服务
$ kubectl get --namespace=kube-system svc tiller-deploy

$ kubectl get --namespace=kube-system deployment tiller-deploy

$ kubectl get --namespace=kube-system pod tiller-deploy-xxxx-xxxx

$ helm version
```

### 3. 使用 helm 
搜索当前可安装的 chart. helm 支持关键字搜索, 包括 DESCRIPTION 在内的所有信息, 只要跟 关键字匹配.
```
-- 列出所有的可用 chart
$ helm search

-- 搜索特定的 chart
$ helm search mysql
```

helm 仓库: helm 安装好之后, 默认配置了两个仓库: stable, local, 用户可以维护自己的私有仓库, 文档见 [https://docs.helm.sh](https://docs.helm.sh). 
stable 是官方仓库, 标识为 `stable/NAME`
local 是用户存放自己开的发 chart 的本地仓库, 标识为 `local/NAME`

```
$ helm repo list
  NAME      URL
  stable    https://kubernetes-charts.storage.googleapis.com
  local     http://127.0.0.1:8879/charts

-- 添加更多 仓库
$ helm repo add 
```
安装 chart

```
$ helm install stable/mysql
  Error: no available release name found    -- 这种错误, 常常是因为 Tiller 服务器权限不足导致的. 执行如下命令添加权限.

-- 添加权限
$ kubectl create serviceaccount --namespace kube-system tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec": {"template": {"spec": {"serviceAccount": "tiller"} }} }'

-- 再次执行
$ helm install stable/mysql
  
  -- 本次部署的描述信息
  NAME:   fun-zorse       -- release 的名字, 可以通过 -n 参数指定, 否则随机生成一个名字.     
  LAST DEPLOYUED:   2017年 7月28日 星期六 19时14分21秒 CST
  NAMESPACE: default      -- release 部署的 namespace , 默认是 default, 可以通过 --namespace 指定.
  STAUS: DEPLOYED         -- release 的状态. 

  -- 当前 release 包含的资源: Service, Deployment, Secret, PersistentVolumeClaim, 
  -- 其名称都是 fun-zorse-mysql, 命名格式为 ReleaseName-ChartName.
  RESOURCES:
  ==> v1/Service
  NAME    CLUSTER-IP  EXTERNAL-IP     PORT(S)   AGE
  fun-zorse-mysql   10.109.23.5   <none>  3306/TCP  0s

  ==> v1beat/Deployment
  NAME    DESIRED   CURRENT     UP-TO-DATE    AVAILABLE     AGE
  fun-zorse-mysql   1     1     1   0   0s

  ==> v1/Secret
  NAME      TYPE     DATE     AGE
  fun-zorse-mysql   Opaque  2   1s

  ==> v1/PersistentVolumeClaim
  NAME      STATUS      VOLUME    CAPACITY    ACCESSMODES     STORAGECLASS    AGE
  fun-zorse-mysql   Pending   1s


  -- 显示 release 的使用方法.
  NODES:
  MySQL can be accessed via port 3306 on the following DNS name from within your cluster:
    fun-zorse-mysql.default.svc.cluster.local

  To Get You root Password run:
    $ kubectl get secret --namespace default fun-zorse-mysql -o jsonpath="{.data.mysql-root-password}"

  To connect to you database:
  1. Run an Ubuntu pod that you can use as a client
      $ kubectl run -i --tty ubuntu --imag=ubuntu:16.4 --restart=Never -- bash -il

  2. Install the mysql client

      $ apt update && apit install mysql-client

  3. Connect using the mysql cli, then provider you password:

      $ mysql -h fun-zorse-mysql -p

-- chart 部署好之后, 可以通过 kubectl get 查看各个对象. 
-- chart 部署好之后, 可能因为 依赖没有部署好, 而 不可用, 如上面的部署中, PersistentVolume 没有部署, 所以当前的 release 是不可用的.
$ kubectl get service fun-zorse-mysql
$ kubectl get deployment fun-zorse-mysql
$ kubectl get pod fun-zorse-mysql-xxxx-xxxx-xxxx
$ kubectl get pvc fun-zorse-mysql
```
显示已经部署的 release

```
$ helm list 
```

显示 某个 release 的状态详情

```
$ helm status my
```

删除已经部署的 release
```
$ helm delete fun-zorse
```

查看 chart 的使用方法:
```
$ helm inspect values NAME
```

helm 传递参数 有两种方式:

- 指定 `values` 文件
    
    通常的做法是, 读取原始的 values.yaml 文件, 然后设置响应的参数, 然后, 在安装 chart 时, 指定自定义的 values 文件.

    ```
    $ helm inspect values mysql > my-values.yaml 

    -- 编辑设置自定义参数.
    
    $ helm install --values=my-values.yaml mysql
    ```

- 通过 `--set` 直接传入参数值: 
    
    ```
    $ helm install stable/mysql --set mysqlRootPassword=123456 -n mysql
    ```

#### 3.1 升级与回滚 release.

release 发布后可以指定 `helm upgrade` 对其进行升级, 通过 --values 或 --set 应用新的配置.

```
-- 升级 mysql 的版本
$ helm upgrade --set imageTag=5.7.15 my stable/mysql
```
查看 release 的所有版本

```
$ helm history my
  REVISION    UPDATE  STATUS  CHART     DESCRIPT 
  1   Sun Jul 15 23:53:16 2017  SUPERSEDED  mysql-0.3.0   Install
  2   Sun Jul 15 22:53:16 2017  DEPLOYED    mysql-0.3.0   Upgrade     
```
回滚到指定版本

```
-- 1 对应 helm history 返回的 REVCISION .
$ helm rollback my 1
```
### 4. chart 详解
Chart 是 helm 的应用打包格式. Chart 由一系列文件组成, 这些文件描述了 Kubernetes 部署应用时所需要的资源, 如 Service, Deployment, PersistentVolumeClaim, Secret, ConfigMap 等.

单个 Chart 可以非常简单, 只用于部署一个服务. 也可以很复杂, 部署整个应用, 如包含 HTTPServer, Database, 消息中间件, Cache 等.

Chart 将这些文件放置在预定义的目录中, 通常整个 chart 被打成 tar 包, 并标注版本信息, 便于 helm 部署.

#### 4.1 目录结构

一旦使用 helm 安装了某个 chart, 就可以在 `~/.helm/cache/archive` 中找到该 chart 的 tar 包.

https://console.cloud.google.com/storage/browser/kubernetes-charts-incubator

```
$ tree mysql
  mysql
  ├── Chart.yaml
  ├── README.md
  ├── templates
  │   ├── configurationFiles-configmap.yaml
  │   ├── deployment.yaml
  │   ├── _helpers.tpl
  │   ├── initializationFiles-configmap.yaml
  │   ├── NOTES.txt
  │   ├── pvc.yaml
  │   ├── secrets.yaml
  │   ├── svc.yaml
  │   └── tests
  │       ├── test-configmap.yaml
  │       └── test.yaml
  └── values.yaml
```

- `chart.yaml` : chart 的概要信息. name 和 version 是必须的, 其他的可选.
- `README.md` : README 文件, 相当于 Chart 的使用文档.
- `LICENSE` : chart 许可信息, 此文件可选
- `requirements.yaml` : chart 可能依赖其他 chart, requirements.yaml 指定依赖关系. 在安装过程中, 依赖的 chart 也会被安装.

  ```
  dependencies:
    - name: rabbitmq
      version: 1.2.3
      repository: http://example.com/charts
    - name: memcached
      version: 3.2.1
      repository: https://another.example.com/charts
  ```
- `values.yaml` : chart 支持在安装时根据参数进行定制化参数, 而 values.yaml 则提供了这些配置参数的默认值.
  
  ```
  ## mysql image version
  ## ref: https://hub.docker.com/r/library/mysql/tags/
  ##
  image: "mysql"
  imageTag: "5.7.14"

  ## Specify password for root user
  ##
  ## Default: random 10 character string
  # mysqlRootPassword: testing

  ## Create a database user
  ##
  # mysqlUser:
  ## Default: random 10 character string
  # mysqlPassword:

  ## Allow unauthenticated access, uncomment to enable
  ##
  # mysqlAllowEmptyPassword: true

  ## Create a database
  ##
  # mysqlDatabase:

  ## Specify an imagePullPolicy (Required)
  ## It's recommended to change this to 'Always' if the image tag is 'latest'
  ## ref: http://kubernetes.io/docs/user-guide/images/#updating-images
  ##
  imagePullPolicy: IfNotPresent

  # Optionally specify an array of imagePullSecrets.
  # Secrets must be manually created in the namespace.
  # ref: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod
  # imagePullSecrets:
    # - name: myRegistryKeySecretName

  ## Node selector
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector
  nodeSelector: {}

  livenessProbe:
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 3

  readinessProbe:
    initialDelaySeconds: 5
    periodSeconds: 10
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 3

  ## Persist data to a persistent volume
  persistence:
    enabled: true
    ## database data Persistent Volume Storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    # storageClass: "-"
    accessMode: ReadWriteOnce
    size: 8Gi

  ## Configure resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ##
  resources:
    requests:
      memory: 256Mi
      cpu: 100m

  # Custom mysql configuration files used to override default mysql settings
  configurationFiles: {}
  #  mysql.cnf: |-
  #    [mysqld]
  #    skip-name-resolve
  #    ssl-ca=/ssl/ca.pem
  #    ssl-cert=/ssl/server-cert.pem
  #    ssl-key=/ssl/server-key.pem

  # Custom mysql init SQL files used to initialize the database
  initializationFiles: {}
  #  first-db.sql: |-
  #    CREATE DATABASE IF NOT EXISTS first DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
  #  second-db.sql: |-
  #    CREATE DATABASE IF NOT EXISTS second DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

  metrics:
    enabled: false
    image: prom/mysqld-exporter
    imageTag: v0.10.0
    imagePullPolicy: IfNotPresent
    resources: {}
    annotations: {}
      # prometheus.io/scrape: "true"
      # prometheus.io/port: "9104"

  ## Configure the service
  ## ref: http://kubernetes.io/docs/user-guide/services/
  service:
    ## Specify a service type
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types
    type: ClusterIP
    port: 3306
    # nodePort: 32000

  ssl:
    enabled: false
    secret: mysql-ssl-certs
    certificates:
  #  - name: mysql-ssl-certs
  #    ca: |-
  #      -----BEGIN CERTIFICATE-----
  #      ...
  #      -----END CERTIFICATE-----
  #    cert: |-
  #      -----BEGIN CERTIFICATE-----
  #      ...
  #      -----END CERTIFICATE-----
  #    key: |-
  #      -----BEGIN RSA PRIVATE KEY-----
  #      ...
  #      -----END RSA PRIVATE KEY-----
  ```

- `templates` : 各类 Kubernetes 资源的配置模板都放置在这里. Helm 会将 values.yaml 中的参数值注入到 模板中, 生产标准的 YAML 配置文件.
  
  模板是 chart 最重要的部分, 也是 helm 最强大的地方, 模板增加了应用部署的灵活性, 能够适应不同的环境.

- `templates/NOTES.txt` chart 的简易使用文档, chart 安装成功之后会显示此文档内容. 与模板一样, 可以在 NOTES.txt 中插入配置参数, helm 会动态注入参数值.

#### 4.2 chart 模板
Helm 通过模板创建 Kubernetes 能够理解的 YAML 格式的资源配置文件. Helm 使用了 Go 语言的模板来编写 chart . Go 模板非常强大, 支持 变量,对象,函数, 流控制等功能.

```
-- templates/secret.yaml
  { {- if not .Values.existingSecret } }
  apiVersion: v1
  kind: Secret
  metadata:
    name: { { template "mysql.fullname" . } }
    labels:
      app: { { template "mysql.fullname" . } }
      chart: "{ { .Chart.Name } }-{ { .Chart.Version } }"
      release: "{ { .Release.Name } }"
      heritage: "{ { .Release.Service } }"
  type: Opaque
  data:
    { { if .Values.mysqlRootPassword } }
    mysql-root-password:  { { .Values.mysqlRootPassword | b64enc | quote } }
    { { else } }
    mysql-root-password: { { randAlphaNum 10 | b64enc | quote } }
    { { end } }
    { { if .Values.mysqlPassword } }
    mysql-password:  { { .Values.mysqlPassword | b64enc | quote } }
    { { else } }
    mysql-password: { { randAlphaNum 10 | b64enc | quote } }
    { { end } }
  { {- if .Values.ssl.enabled } }
  { { if .Values.ssl.certificates } }
  { {- range .Values.ssl.certificates } }
  ---分割线
  apiVersion: v1
  kind: Secret
  metadata:
    name: { { .name } }
    labels:
      app: { { template "mysql.fullname" $ } }
      chart: "{ { $.Chart.Name } }-{ { $.Chart.Version } }"
      release: "{ { $.Release.Name } }"
      heritage: "{ { $.Release.Service } }"
  type: Opaque
  data:
    ca.pem: { { .ca | b64enc } }
    server-cert.pem: { { .cert | b64enc } }
    server-key.pem: { { .key | b64enc } }
  { {- end } }
  { {- end } }
  { {- end } }
  { {- end } } 
```

**如果存在一些信息多个模板都会用到, 则可在 `templates/_helpers.tpl` 中将其定义为子模板, 然后通过 `templates` 函数调用**

`{ { template "mysql.fullname" } }` 定义 secret 的 name, 关键字 template 的作用是引用一个字幕版 mysql.fullname, 这个子模板在 `templates/_helpers.tpl` 文件中定义. 这里的 mysql.fullname 是 release 与 chart 的二者名字拼接而成. **根据 chart 的最佳实践, 所有资源的名称都应该保持一致**

```
{ {- define "mysql.fullname" -} }
{ {- if .Values.fullnameOverride -} }
{ {- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -} }
{ {- else -} }
{ {- $name := default .Chart.Name .Values.nameOverride -} }
{ {- if contains $name .Release.Name -} }
{ {- printf .Release.Name | trunc 63 | trimSuffix "-" -} }
{ {- else -} }
{ {- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -} }
{ {- end -} }
{ {- end -} }
{ {- end -} }
```

`Chart` && `Release` 是 Helm **预定义对象**, 每个对象都由自己的属性, 可以在模板中使用.

```
$ helm install stable/mysql -n my

-- 对应的属性为:
  { { .Chart.Name } } --> mysql
  { { .Chart.Version } } : 0.3.1
  { { .Release.Name } } : my
  { { .Release.Service } } : 始终取值为 Tiller.
  { { template "mysql.fullname" } } : 计算结果为 my-mysql

```
`Values` 也是**预定义对象**, 代表 `values.yaml` 文件.

```
-- 下面这段模板代码的含义为, 如果 values.yaml 中定义了 mysqlRootPassword 参数, 则 使用 base64 加密之后的值.
-- 如果没有定义, 则随机生成一个 10 位 密码, base64 加密之后, 作为密码.

  { { if .Values.mysqlRootPassword } }
  mysql-root-password:  { { .Values.mysqlRootPassword | b64enc | quote } }
  { { else } }
  mysql-root-password: { { randAlphaNum 10 | b64enc | quote } }
  { { end } }
```

#### 4.3 开发自己的 chart
使用 `helm create` 创建 chart, helm 会创建目录 mychart, 并生成各类 chart 文件, 可以基于此基础开发自己的 chart.

在编写 chart 时, 建议参考官方 chart 中的 模板 values.yaml , Chart.yaml , 里面包含大量最佳实践 和 最常用的 函数, 流控制.

```
$ helm create mychart
```

helm 提供了 `helm lint` 和 `helm install --dry-run --debug` 工具 debug.

`helm lint` 会检查 chart 的语法错误.

```
-- mychart 目录 作为参数 传递.
$ helm lint mychart
```

`helm install --dry-run --debug` 会模拟安装 chart, 并输出 每个模板生成的 YAML 内容.

```
-- mychart 目录 作为参数传递.
$ helm install --dry-run --debug mychart
```
#### 4.4 安装 chart. 
Helm 支持 4 种安装方法:

- 安装 仓库中的 chart, 如 `helm install stable/nginx`
- 通过 tar 安装, 如 `helm install ./nginx-1.2.3.tgz`
- 通过 chart 本地目录安装, 如 `helm install ./nginx`
- 通过 url 安装, 如 `helm install https://example.com/charts/nginx-1.2.3.tgz`

#### 4.5 将 Chart 添加到 仓库.
chart 通过测试后就可以添加到 仓库中, 团队其他成员就能够使用了. **任何 HTTP Server 都可以用作 chart 仓库**.

通过 `helm package` 打包

```
$ helm package mychart
```
执行 `helm repo index` 生产仓库的 index 文件. helm 会扫描 myrepo 目录中的所有 tgz 包并生成 `index.yaml` 文件. `--url `指定的是新仓库的访问路径. 新生成的 index.yaml 记录了当前仓库中所有 chart 的信息. 生成这些信息之后, 将 chart 和 index.yaml 文件上传到 可以 使用 HTTP 访问的 web 根目录下, 即可.
```
$ mkdir myrepo

$ mv mychart-0.1.0.tgz mychart

$ helm repo index myrepo/ --url http://192.168.56.106:8080/charts

$ ls myrepo/
  index.yaml    mychart-0.1.0.tgz
```

最后, 通过 `helm repo add` 将新仓库添加到 Helm.

```
$ helm repo add newrepo http://192.168.56.106:8080/charts

$ helm repo list
  NAME    URL
  stable
  local
  newrepo   http://192.168.56.106:8080/charts

-- 搜索 mychart
$ helm search mychart

-- 安装 mychart
$ helm install newrepo/mychart
```

如果 仓库中添加了新的 chart, 则需要用 `helm repo update` 更新本地 index. 类似于 `apt upgrate`.

```
$ helm repo update
```

## 网络

Kubernetes 采用的基于扁平地址空间的网络模型, 集群中的每个 Pod 都只有自己的 IP 地址, Pod 之间不需要配置 NAT 就能直接通信. 另外, 同一个 Pod 中的容器共享 Pod 的 IP, 能够 通过 localhost 通信.

为了保证网络方案的标准化, 扩展性和灵活性, kubernetes 采用了 Container Networking Interface (CNI) 规范.

CNI 是由 CoreOS 提出的 容器网络规范, 使用插件模型创建容器的网络栈.
![CNI](/imgs/k8s/k8s-cni.png)
CNI 的有点是支持多种容器 runtime, 不仅仅是 Docker. CNI 的插件模型支持不同组织和公司开发的插件, 可以灵活的选择网络方案. 如 Flannel, Calico, Canal, Weave Net 等, 他们都实现了 CNI 规范, 区别在与不同的方案选择的底层实现不同, 有的采用基于 VxLAN 的 Overlay 实现, 有的则是 Underlay, 性能上有所差别. 再有就是是否支持 Network Policy.

这种网络模型对应用开发者和管理员都相当友好, 应用可以方便的从传统网络迁移到 Kubernetes. 每个 Pod 被看做一个独立的系统, 而 Pod 中的容器则被看做同一系统中的不同进程.

1. Pod 内容器之间的通信
    
    当 Pod 被调度到某个节点, Pod 中的所有容器都在这个节点上运行, 这些容器共享相同的 本地文件系统, IPC, 和网络命名空间.

    不同 Pod 之间不存在端口冲突的问题, 因为每个 Pod 都有自己的 IP 地址. 当某个容器使用 localhost 时, 意味着使用的是容器所属的 Pod 的地址空间.

2. Pod 之间的通信
    
    Pod 的 IP 是集群可见的, 即集群中的任何其他 Pod 和节点都可以通过 IP 直接与 Pod 通信, 这种通信无需借助任何网络地址转换, 隧道或代理技术. Pod 内部和外部使用的是同一个 IP, 这也意味着 标准的命名服务和发现机制, 如 DNS 可以直接使用.

3. Pod 与 Service 的通信
    
    Pod 间可以直接通过 IP 地址通信, 但前提是 Pod 知道对方的 IP. 在 Kubernetes 集群中, Pod 可能会频繁的销毁和创建, 也就是说 Pod 的 IP 不是固定的.

    Service 提供了 访问 Pod 的抽象层. 无论后端的 Pod 如何变化, Service 都做为稳定的前端对外提供服务. 

    同时, Service 还提供了高可用和负载均衡的功能, Service 负责将请求转发到正确的 Pod.

4. 外部访问
    
    无论 Pod 的 IP 还是 Service 的 ClusterIP, 他们只能在 Kubernetes 集群中可见, 对集群之外的世界, 这些 IP 都是私有的.

    Kubernetes 提供了两种方式, 让外界能够与 Pod 通信:

    - NodePort: Service 通过 Cluster 节点的静态端口对外提供服务. 外部可以通过 `<NodeIP>:<NodePort>` 访问 Service.

    - LoadBalancer : Service 利用 cloud provider 提供的 load balancer 对外提供服务, cloud provider 负责将 load balancer 的流量导向 Service. 目前支持的 cloud provider 有 GCP, AWS, Azur 等.


### 1. Network Policy

Network Policy 是 Kubernetes 的一种资源. Network Policy 通过 Label 选择 Pod, 并指定其他 Pod 或外界如果与这写 Pod 通信.

默认情况下, 所有的 Pod 都是非隔离的, 即任何来源的网络流量都能访问 Pod, 没有任何限制. 当为 Pod 定义了 Network Policy 时, 只有 Policy 允许的流量才能访问 Pod.

不过, 不是所有的 Kubernetes 网络方案都支持 Network Policy. 如 Flannel 不支持, Calico 支持.

```
apiVersion: networking.k8s.io/v1
kind:  NetworkPolicy
metadata:
  name: access-https
spec:
  podSelector:
    matchLabels:      -- 定义规则应用的 Pod.
      run: httpd
  ingress:            -- 通过 ingress 限制进入的流量, 通过 egress 限制外出的流量.
  - from:
    - podSelector:
      matchLabels:
        access: "true"    -- 只有 access: "true" 的 Pod 才能访问.
    - ipBlock:
      cidr: 192.168.56.0/24   -- 允许 该段的 IP 地址可以访问.
    ports:
    - protocol: TCP
      port: 80            -- 只能访问 80 端口.
```

## Dashboard
```
$ kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
    secret/kubernetes-dashboard-certs created
    serviceaccount/kubernetes-dashboard created
    role.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
    rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
    deployment.apps/kubernetes-dashboard created
    service/kubernetes-dashboard created
```

## Kubernetes 集群监控

### 1. Weave Scope
    
主要监控对象为 Node 和 Pod.

### 2. Heapster 是 Kubernetes 原生监控方案

主要监控对象为 Node 和 Pod

### 3. Prometheus Operator 
Prometheus Operator 是 CoreOS 开发的基于 Prometheus 的 Kubernetes 监控方案. 也是目前功能最全面的 Kubernetes 监控方案. 能监控 Node, Pod, 还支持集群的各种管理插件, 如 API Server, Scheduler, Controller Manager 等.

Prometheus Operator 通过 Grafana 展示监控数据, 与定义了一系列的 Dashboard. 支持 Kubernetes 集群的整体健康状态及资源使用情况, Kubernetes 各个管理组件的状态, 节点的资源使用情况, Deployment 的运行状态, Pod 的运行状态.

Prometheus 是一个非常优秀的监控工具(方案). 他提供了 数据搜集, 存储, 处理, 可视化及告警一整套完整的解决方案. Prometheus 的结构图如下:

![Prometheus 架构图](/imgs/prometheus/prometheus-architecture.svg)

- Prometheus Server : 负责从 Exporter 拉取和存储监控数据, 并提供一套灵活的查询语言( PromQL ).

- Exporter: 负责收集目标对象( host, container 等) 的性能数据, 并通过 HTTP 接口供 Prometheus Server 获取.

- 可视化组件: 页面展示, 一般使用 Grafana 代替.

- Alertmanager: 用户可以定义基于监控数据的报警规则, 规则会触发警告. 一旦 Alertmanager 收到告警, 就会通过预定义的方式发出告警通知, 支持的方式包括 Email, PagerDuty, Webhook 等.

Prometheus Operator 的目标是为了尽可能简化在 Kubernetes 中部署和维护 Prometheus 的工作.

![Prometheus Operator 架构图--图中每一个对象都是 Kubernetes 中运行的资源](/imgs/prometheus/prometheus-operator-architecture.svg)

- Operator : 即 Prometheus Operator, 在 Kubernetes 中以 Deployment 运行, 其职责是部署和管理 Prometheus Server, 根据 ServiceMonitor 动态更新 Prometheus Server 的监控对象. 
- Prometheus Server : 作为 Kubernetes 应用部署到集群中. 为了更好的在 Kubernetes 中管理 Prometheus, CoreOS 的开发人员专门定义了一个命名为 **Prometheus** 类型的 Kubernetes 定制化资源. 可以把 Prometheus 看做一种特殊的 Deployment , 他的用途就是专门部署 Prometheus Server.
- Service : 指 Cluster 中的 Service 资源, 也是 Prometheus 监控的对象, 在 Prometheus 中叫做 Target. 每个监控对象都有一个对应的 Service. 如要监控 Kubernetes Scheduler 就得有一个与 Scheduler 对应的 Service.  当然, Kubernetes 集群默认是没有这个 service 的, Prometheus Operator 会负责创建.
- ServiceMonitor : Operator 能够动态更新 Prometheus 的 Target 列表. ServiceMonitor 就是 Target 的抽象. 如监控 Kubernetes Scheduler, 用户可以创建一个与 Scheduler Service 相映射的 ServiceMonitor 对象. Operator 则会发现这个新的 ServiceMonitor, 并将 Scheduler 的 Target 添加到 Prometheus 的监控列表中. ServiceMonitor 也是 Prometheus Operator 专门开发的一种 Kubernetes 定制化资源类型.
- Alertmanager : Alertmanager 是 Operator 开发的第三种 Kubernetes 定制化资源. Alertmanager 是一种特殊的 Deployment , 他的用途就是专门部署 Alertmanager 组件.

[项目地址](https://github.com/coreos/prometheus-operator)
[其他资料](https://www.kancloud.cn/huyipow/prometheus/527093)
## Kubernetes 日志管理

Kubernetes 开发了一个 Elasticsearch 附加组件来实现集群的日志管理, 是 Elasticsearch, Fluentd 和 Kibana 的组合.

Fluentd 负责从 Kubernetes 搜集日志并发送给 Elasticsearch.

```
https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch
```









