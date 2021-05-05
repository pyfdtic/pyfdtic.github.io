
# kubernetes 

版本: 基于 Kubernetes v1.6 及以上.

主要功能:
1. 基于容器的应用部署, 维护和滚动升级
2. 负载均衡和服务发现
3. 跨机器和跨地区的集群调度
4. 自动伸缩
5. 无状态服务 和 有状态服务
6. 广泛的 Volume 支持
7. 插件机制保证扩展性.

## 1. 简介
### 1.1 核心组件:
1. etcd : 保存整个集群的状态;
2. apiserver : 提供资源的操作的唯一入口, 并提供认证,授权,访问控制, API 注册和发现等机制.
3. controller manager : 负责维护集群的状态, 如 故障检测, 自动扩展, 滚动更新;
4. scheduler : 负责资源的调度, 按照都预定的调度策略将 Pod 调度到相应的机器上.
5. kubelet : 负责维护容器的生命周期, 同时也负责 Volume(CVI) 和 网络(CNI) 的管理.
6. Container runtime : 负责镜像管理以及 Pod 和容器的真正运行(CRI)
7. kube-proxy : 负责为 Service 提供 cluster 内部的服务发现和负载均衡

![kubernetes architecture](imgs/k8s-architecture.png)

Add-ons 组件:
1. kube-dns : 负责为整个集群提供 DNS 服务.
2. Ingress Controller : 为服务提供外网入口.
3. Heapster : 提供资源监控
4. Dashboard : 提供 GUI.
5. Federation : 提供跨可用区的集群.
6. Fluentd-elasticsearch : 提供集群日志采集,存储与查询.


### 1.2 基本概念
#### manifest
在 kubernetes 中, 所有对象都使用 manifest (yaml 或 json) 来定义. 

编写 yaml 文件时, 可使用 `kubectl explain RESOURCR` , 获取所有关键字及其用法.
Valid resource types include: 

    * buildconfigs (aka 'bc')  
    * builds  
    * clusters (valid only for federation apiservers)  
    * componentstatuses (aka 'cs')  
    * configmaps (aka 'cm')  
    * daemonsets (aka 'ds')  
    * deployments (aka 'deploy')  
    * deploymentconfigs (aka 'dc')  
    * endpoints (aka 'ep')  
    * events (aka 'ev')  
    * horizontalpodautoscalers (aka 'hpa')  
    * imagestreamimages (aka 'isimage')  
    * imagestreams (aka 'is')  
    * imagestreamtags (aka 'istag')  
    * ingresses (aka 'ing')  
    * groups  
    * jobs  
    * limitranges (aka 'limits')  
    * namespaces (aka 'ns')  
    * networkpolicies  
    * nodes (aka 'no')  
    * persistentvolumeclaims (aka 'pvc')  
    * persistentvolumes (aka 'pv')  
    * pods (aka 'po')  
    * podsecuritypolicies (aka 'psp')  
    * podtemplates  
    * policies  
    * projects  
    * replicasets (aka 'rs')  
    * replicationcontrollers (aka 'rc')  
    * resourcequotas (aka 'quota')  
    * rolebindings  
    * routes  
    * secrets  
    * serviceaccounts (aka 'sa')  
    * services (aka 'svc')  
    * statefulsets  
    * users  
    * storageclasses  
    * thirdpartyresources 

如下是一个 nginx 服务定义:
    
    appVersion: v1
    kind: Pod
    metadata:
        name: nginx
        labels: 
            app: nginx
    spec:
        containers:
        - name: nginx
          images: nginx
          ports:
          - containerPort: 80

#### Pod

Pod 是一组紧密关联的容器集合, 他们共享 IPC, Network, UTC namespace. 是 Kubernetes 调度的基本单位.

Pod 的设计理念是支持多个容器在一个 Pod 中共享网络和文件系统, 可以通过进程间通信和文件共享这种简单高效的方式完成服务.

#### Node

Node 是 Pod 真正运行的主机, 可以是物理机, 也可为 虚拟机. 为了管理 Pod, 每个 Node 节点上至少要运行 container runtime(如 docker, rkt), kubelet 和 kube-proxy 服务.

#### Namespace
Namespace 是对一组资源和对象的抽象集合, 如可以用来将系统内部的对象划分为不同的项目组或用户组.

常见的 pods, services , replication controllers 和 deployments 等都是属于某一个 namespace 的 (默认为 default), 而 node/persistenVolumes 等则不属于任何 namespace .

#### Volume
Pod 的生命周期通常比较短, 主要出现异常, 就会创建一个新的 Pod 来代替他. 此时, 容器中产生的数据, 需要一个位置来保存.

Volume 就是为了持久化容器数据为产生的.
    
    apiVersion: v1
    kind: Pod
    metadata:
      name: redis
    spec:
      containers:
      - name: redis
        image: redis
        volumeMounts:
        - name: redis-persistent-storage
          mountPath: /data/redis
      volumes:
      - name: redis-persistent-storage
        hostPath:
          path: /data    

Kubernetes Volume 支持非常多的插件, 可以根据实际需要来选择:
- emptyDir
- hostPath
- gcePersistentDisk
- awsElasticBlockStore
- nfs
- iscsi
- flocker
- glusterfs
- rbd
- cephfs
- gitRepo
- secret
- persistentVolumeClaim
- downwardAPI
- azureFileVolume
- vsphereVolume

#### Service
Service 是应用服务的抽象, 通过 labels 为应用提供负载均衡和服务发现. 匹配 labels 的 Pod IP 和 端口列表组成 endpoints , 由 kube-proxy 负责将服务 IP 负载均衡到这些 endpoints 上.

每个 Service 都会自动分配一个 cluster IP (仅在集群内部可以访问的虚拟地址) 和 DNS 名, 其他容器可以通过该 地址或 DNS 来访问服务, 而不需要了解后端容器的运行.

![Service 结构](/images/14731220608865.png)

    apiVersion: v1
    kind: Service
    metadata: 
        name: nginx
    spec:
        ports:
        - ports: 8087           # the port that this service should server on
          name: http
          targetPort: 80        # the container on each pod to connect to, can be a name(e.g. 'www') or a number (e.g. 80)
          protocol: TCP
        selector:
          app: nginx

#### deployment


#### Label

Label 是识别 Kubernetes 对象的标签, 以 key/value 的方式附加到对象上(key < 63 字节, 0 <= value < 253 字节)

Label 不提供唯一性, 并且实际上经常是很多对象(如 Pods) 都使用相同的 label 来标识具体的应用.

Label 定义好之后, 其他对象可以使用 Label Selector 来选择一组相同 label 的对象(如 ReplicaSet 和 Service 用 label 来选择一组 Pod ). Label Selector 支持一下方式:

- 等式 : 如 `app=nginx` 和 `evn!=production`
- 集合 : 如 `env in (production, qa)`
- 多个 label (他们之间是 AND 关系) : 如 `app=nginx, env=test`

#### Annotations --> 注释
Annotations 是 key/value 形式附加与对象的注释. 

不同于 Labels 用于标识和选择对象, Annotations 则是用来记录一些附加信息, 用来辅助应用部署, 安全策略以及调度策略等. 如 deployment 使用 annotations 来记录 rolling update 的状态.

### 1.3 命令概览

命令概览:
    
    $ kubectl help

    Basic Commands (Beginner):
      create         Create a resource by filename or stdin
      expose         Take a replication controller, service, deployment or pod and expose it as a new Kubernetes Service
      run            Run a particular image on the cluster
      set            Set specific features on objects

    Basic Commands (Intermediate):
      get            Display one or many resources
      explain        Documentation of resources
      edit           Edit a resource on the server
      delete         Delete resources by filenames, stdin, resources and names, or by resources and label selector

    Deploy Commands:
      rollout        Manage a deployment rollout
      rolling-update Perform a rolling update of the given ReplicationController
      scale          Set a new size for a Deployment, ReplicaSet, Replication Controller, or Job
      autoscale      Auto-scale a Deployment, ReplicaSet, or ReplicationController

    Cluster Management Commands:
      certificate    Modify certificate resources.
      cluster-info   Display cluster info
      top            Display Resource (CPU/Memory/Storage) usage
      cordon         Mark node as unschedulable
      uncordon       Mark node as schedulable
      drain          Drain node in preparation for maintenance
      taint          Update the taints on one or more nodes

    Troubleshooting and Debugging Commands:
      describe       Show details of a specific resource or group of resources
      logs           Print the logs for a container in a pod
      attach         Attach to a running container
      exec           Execute a command in a container
      port-forward   Forward one or more local ports to a pod
      proxy          Run a proxy to the Kubernetes API server
      cp             Copy files and directories to and from containers.

    Advanced Commands:
      apply          Apply a configuration to a resource by filename or stdin
      patch          Update field(s) of a resource using strategic merge patch
      replace        Replace a resource by filename or stdin
      convert        Convert config files between different API versions

    Settings Commands:
      label          Update the labels on a resource
      annotate       Update the annotations on a resource
      completion     Output shell completion code for the given shell (bash or zsh)

    Other Commands:
      api-versions   Print the supported API versions on the server, in the form of "group/version"
      config         Modify kubeconfig files
      help           Help about any command
      version        Print the client and server version information

    Use "kubectl <command> --help" for more information about a given command.
    Use "kubectl options" for a list of global command-line options (applies to all commands).    


示例:

    # 创建单个容器, 实际上创建的是一个有 deployment 来管理的 Pod. `kubectl run` 先创建一个 Deployment 资源(replicas=1), 再由 Deployment 来自动创建 Pod . 但是 kubectl run 并不支持所有的功能.
    $ kubectl run --image=nginx nginx-app --port=80

    kubectl run 与如下的操作是等价的:
    $ vim single_nginx.yaml
        apiVersion: extensions/v1beta1
        kind: Deployment
        metadata:
          label:
            run: nginx-app
          name: nginx-app
          namespace: default
        spec:
          replicas: 1
          selector:
            matchLabels:
              run: nginx-app
          strategy:
            rollingUpdate:
              maxSurge: 1
              maxUnavailable: 1
            type: rollingUpdate
          template:
            metadata:
              labels:
                run: nginx-app
            spec:
              containers:
              - image: nginx
                name: nginx-app
                ports:
                - containerPort: 80
                  protocol: TCP
              dnsPolicy: ClusterFirst
              restartPolicy: Always

    $ kubectl create -f single_nginx.yaml    


    $ kubectl expose deployment nginx-app --type=NodePort --port=80 --target=80     # 将 deploy nginx-app 转变为 service

    $ kubectl describe service nginx-app


    # kubectl get           : 查询资源列表, 类似 docker ps
    # kubectl describe      : 获取资源的详细信息, 类似 docker inspect
    # kubectl logs          : 获取容器日志, 类似 docker logs
    # kubectl exec          : 在容器内部执行命令, 类似 docker exec. 
    $ kubectl exec -it POD_NAME /bin/bash   # 进入 pod 内部.

### 1.4 应用升级与扩展
1. 扩展应用: 
    
    修改 Deployment 中的副本的数量(replicas), 可以动态扩展或收缩应用.
    
        $ kubectl scal --replicas=3 deployment/nginx-app
        $ kubectl get deployment

2. 滚动升级
    
    滚动升级(Rolling Update) 通过逐个容器替代升级的方式来实现无中断的服务升级.

        $ kubectl rolling-update frontend-v1 frontend-v2 --image=image:v2

    在滚动升级的过程中, 如果发现失败或配置错误, 可以随时回滚:

        $ kubectl rolling-update frontend-v1 frontend-v2 --rollback

    **注意**: rolling-update 只针对 ReplicationController, 不能用在策略**不是RollingUpdate** 的 Deployment 上 (Deployment 可以在 spec 中设置更新策略为 RollingUpdate, 默认就是 RollingUpdate):

        spec:
          replicas: 3
          selector:
            matchLabels:
              run: nginx-app
            strategy:
              rollingUpdate:
                maxSurge: 1
                maxUnavailable: 1
              type: RollingUpdate        

    更新应用的话, 可以直接用 `kubectl set`:

        $ kubectl set image deployment/nginx-app nginx-app=nginx:1.9.1

    滚动升级的过程可以用 `rollout` 命令查看:

        $ kubectl rollout status deployment/nginx-app

    Deployment 回滚:

        # 显示版本历史
        $ kubectl rollout history deployment/nginx-app 

        # 回滚
        $ kubectl rollout undo deployment/nginx-app


### 1.5 资源限制
Kubernetes 通过 cgroups 提供容器资源管理功能, 可以限制每个容器的 CPU 和 内存使用.

1. 在 资源运行过程中, 动态修改 资源限制.

        # 限制 deployment 资源: 限制资源的更新, 将导致 容器重启.
        $ kubectl set resources deployment nginx-app -c=nginx --limits=cpu=500m,memory=123Mi

2. 在 manifest 中定义:
    
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            app: nginx
          name: nginx
        spec:
          containers:
            - image: nginx
              name: nginx
              resources:
                limits:
                  cpu: "500m"
                  memory: "128Mi"    

### 1.6 健康检查
Kubernetes 提供两种探针(Probe, 支持 exec, tcp, http 方式)来探测容器的状态:
1. LivenessProbe  : 探测应用是否处于健康状态, 如果不健康则删除重建容器.
2. ReadinessProbe : 探测应用是否启动完成并且处于正常服务状态, 如果不正常则更新容器状态.

manifest 示例:

        resources:
          limits:
            cpu: "500m"
            memory: "128Mi"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          timeoutSeconds: 1
        readinessProbe:
          httpGet:
            path: /ping
            port: 80
          initialDelaySeconds: 5
          timeoutSeconds: 1

对于已经部署的 deployment, 可以通过 `kubectl edit deployment/nginx-app` 来**动态更新**manifest.


### 1.7 集群联邦(Federation)
集群联邦用于跨可用区的 Kubernetes 集群, 需要配合云服务商(如 GCE, AWS) 一起实现.

![集群联邦](/imgs/cluster_federation.png)

### 1.8 Kubernetes 单机版
1. 手动安装
    
        $ yum install ectd kubernetes -y

2. 使用 minikube
    
        $ minikube start
        $ kubectl cluster-info

## 2. 核心原理
Kubernetes 提供了面向应用的容器集群部署和管理系统. Kubernetes 的目标旨在消除编排物理/虚拟计算,网络和存储基础设施的负担, 并使应用程序运行商和开发人员完全将重点放在以容器为中心的原语上进行自助运营.

Kubernetes 也提供稳定, 兼容的基础(平台), 用于构建定制化的 workflows 和更高的自动化任务.

Kubernetes 具备完善的集群管理能力, 
- 多层次的安全防护和准入机制, 
- 多租户应用支撑能力,
- 透明的服务注册和服务发现机制, 
- 内建负载均衡器, 
- 故障发现和自我修复能力, 
- 服务滚动升级和在线扩容, 
- 可扩展的资源换自动调度机制, 
- 多粒度的资源配额管理能力.

Kubernetes 还提供完善的管理工具, 涵盖开发, 部署测试和运维监控等各个环节.

**Kubernetes 分层架构**

0. Container Runtime, Network Plugin, Volume Plugin, Image Registry, Cloud Provider, Identify Provider.

1. Nuclens: API and Execution
    
    Kubernetes 最核心的功能, 对外提供 API 构建高层的应用, 对内提供插件式应用执行环境.

2. Application Layer: Deployment and Routing
    
    部署(无状态应用, 有状态应用, 批处理任务, 集群应用等)

    路由(服务发现, DNS 解析等)

3. Governance Layer: Automation and Policy Enforcement
    
    系统度量 : 如基础设施, 容器和网络的度量
    自动化 : 自动扩展, 动态 Provision
    策略管理 : RBAC, Quota, PSP, NetworkPolicy 等.

4. Interface Layer: Client Libraries and Tools.
    
    kubectl 命令行工具
    客户端 SDK
    集群联邦

5. Ecosystem 
    
    在接口层之上的庞大容器寄存管理调度的生态系统, 可以划分为两个范围:
    - Kubernetes 外部 : 日志, 监控, 配置管理, CI/CD, Workflow, Faas, OTS应用, ChatOps 等
    - Kubernetes 内部: CRI, CNI, CVI, 镜像仓库, CloudProvider, 集群自身的配置和管理等.

### 2.1 设计理念
未完成 : 2017年9月29日15:24:20

k8s 系统最核心的两个设计概念: 容错性 + 易扩展性

#### 2.1.1 API 设计原则
对于云计算系统, 系统 API 实际上处于系统和设计的统领地位. k8s 集群系统每支持一项新功能, 引入一项新技术, 一定回新引入对应的 API 对象, 支持对该功能的管理操作.

1. 所有 API 应该是声明式的
  
    声明式的操作, 相对于命令式的操作, 对于重复操作的效果是稳定的.这对于容易出现数据丢失或重复的分布式环境来说是很重要的.

    声明式操作更容易被用户使用, 可以使系统向用户隐藏实现的细节, 同时, 保留了系统未来持续优化的可能性.

    声明式 API 同时隐含了所有的 API 对象都是名词性质的, 如 Service, Volume 这些 API 都是名词, 这些名词描述了用户所期望得到的一个目标分布式对象.

2. API 对象是彼此互不而且可组合的
    
    API 对象尽量实现面向对象设计时的要求, 即 **高内聚, 松耦合**, 对业务相关的概念有一个合适的分解, 提高分解出来的对象的可重用性.

    事实上, k8s 这种分布式系统管理平台, 也是一种业务系统, 只不过它的业务就是调度和管理容器服务.

3. 高层 API 以操作意图为基础设计
    
    高层设计一定是从业务触发, 而不是过早的从技术实现出发. 因此, 针对 k8s 的高层 API 设计, 一定是以 k8s 的业务基础触发, 也就是以系统调度管理容器的操作意图为基础设计.

4. 低层 API 根据高层 API 的控制需要设计
    
    设计实现 低层API 的目的, 是为了被高层API使用, 考虑减少冗余, 提高重用性的目的, 低层API 的设计也要以需求为基础, 尽量抵抗受技术实现影响的诱惑.

5. 尽量避免简单封装, 不要有在外部 API 无法显式知道的内部隐藏的机制.
    
    简单的封装, 实际没有提供新的功能, 反而增加了对所封装API的依赖性. 内部隐藏的机制也是非常不利于系统维护的设计方式, 例如PetSet和ReplicaSet, 本来就是两种Pod集合, 那么K8s就用不同API对象来定义它们, 而不会说只用同一个ReplicaSet, 内部通过特殊的算法再来区分这个ReplicaSet是有状态的还是无状态. 

6. API 操作复杂度与对象数量成正比.

    这一条主要是从系统性能角度考虑, 要保证整个系统随着系统规模的扩大, 性能不会迅速变慢到无法使用, 那么最低的限定就是API的操作复杂度不能超过O(N), N是对象的数量, 否则系统就不具备水平伸缩性了. 

7. API 对象状态不能依赖于网络连接状态.
    
    由于众所周知, 在分布式环境下, 网络连接断开是经常发生的事情, 因此要保证API对象状态能应对网络的不稳定, API对象的状态就不能依赖于网络连接状态. 

8. 尽量避免让操作机制依赖于全局状态, 因为在分布式系统中要保证全局状态的同步是非常困难的.
    


#### 2.1.2 控制机制设计原则

1. 控制逻辑应该只依赖于当前状态
    
    这是为了保证分布式系统的稳定可靠, 对于经常出现局部错误的分布式系统, 如果控制逻辑只依赖当前状态, 那么就非常容易将一个暂时出现故障的系统恢复到正常状态, 因为你只要将该系统重置到某个稳定状态, 就可以自信的知道系统的所有控制逻辑会开始按照正常方式运行. 

2. 假设任何错误的可能, 并做容错处理
    
    在一个分布式系统中出现局部和临时错误是大概率事件. 错误可能来自于物理系统故障, 外部系统故障也可能来自于系统自身的代码错误, 依靠自己实现的代码不会出错来保证系统稳定其实也是难以实现的, 因此要设计对任何可能错误的容错处理. 

3. 尽量避免复杂状态机, 控制逻辑不要依赖无法监控的内部状态.
    
    因为分布式系统各个子系统都是不能严格通过程序内部保持同步的, 所以如果两个子系统的控制逻辑如果互相有影响, 那么子系统就一定要能互相访问到影响控制逻辑的状态, 否则, 就等同于系统里存在不确定的控制逻辑. 

4. 假设任何操作都可能被任何操作对象拒绝, 甚至被错误解析.
    
    由于分布式系统的复杂性以及各子系统的相对独立性, 不同子系统经常来自不同的开发团队, 所以不能奢望任何操作被另一个子系统以正确的方式处理, 要保证出现错误的时候, 操作级别的错误不会影响到系统稳定性. 

5. 每个模块都可以在出错后自动恢复.
    
    由于分布式系统中无法保证系统各个模块是始终连接的, 因此每个模块要有自我修复的能力, 保证不会因为连接不到其他模块而自我崩溃. 

6. 每个模块都可以在必要时优雅的降级服务.
    
    所谓优雅地降级服务, 是对系统鲁棒性的要求, 即要求在设计实现模块时划分清楚基本功能和高级功能, 保证基本功能不会依赖高级功能, 这样同时就保证了不会因为高级功能出现故障而导致整个模块崩溃. 根据这种理念实现的系统, 也更容易快速地增加新的高级功能, 以为不必担心引入高级功能影响原有的基本功能. 

#### 2.1.3 核心技术概念 和 API 对象

API 对象是 k8s 集群中的管理操作单元.

每个 API 对象都有 3 大类属性:
- metadata : 元数据
    
    用来标识 API 对象的, 每个对象至少有 3 个元数据:
    - namespace
    - name
    - uid

    各种各样的 labels.

- spec : 规范
    
    k8s 中所有的配置都是通过 API 对象 spec 去设置的, 也就是用户通过配置系统的理想状态来改变系统.

- status : 状态
    
    描述了系统实际当前达到的状态.

##### Pod

Pod的设计理念是支持多个容器在一个Pod中共享网络地址和文件系统, 可以通过进程间通信和文件共享这种简单高效的方式组合完成服务. 

Pod 是 k8s 集群中所有业务类型的基础. 目前 k8s 中的业务主要可以分为:
- Deployment : 长期伺服型 (long-running)
- Job : 批处理型 (batch)
- DaemonSet : 节点后台支撑型 (node-daemon)
- PetSet : 有状态应用型 (stateful application)

##### Replication Controller, RC : 复制控制器

RC是K8s集群中最早的保证Pod高可用的API对象. 通过监控运行中的Pod来保证集群中运行指定数目的Pod副本. 

RC是K8s较早期的技术概念, 只适用于长期伺服型的业务类型.

##### Replica Set, RS : 

RS是新一代RC, 提供同样的高可用能力, 区别主要在于RS后来居上, 能支持更多种类的匹配模式. 副本集对象一般不单独使用, 而是作为Deployment的理想状态参数使用. 

##### Deployment

部署表示用户对K8s集群的一次更新操作. 部署是一个比RS应用模式更广的API对象, 可以是创建一个新的服务, 更新一个新的服务, 也可以是滚动升级一个服务. 滚动升级一个服务, 实际是创建一个新的RS, 然后逐渐将新RS中副本数增加到理想状态, 将旧RS中的副本数减小到0的复合操作；这样一个复合操作用一个RS是不太好描述的, 所以用一个更通用的Deployment来描述. 以K8s的发展方向, 未来对所有长期伺服型的的业务的管理, 都会通过Deployment来管理. 

##### Service

RC、RS和Deployment只是保证了支撑服务的微服务Pod的数量, 但是没有解决如何访问这些服务的问题. 一个Pod只是一个运行服务的实例, 随时可能在一个节点上停止, 在另一个节点以一个新的IP启动一个新的Pod, 因此不能以确定的IP和端口号提供服务. 要稳定地提供服务需要服务发现和负载均衡能力. 服务发现完成的工作, 是针对客户端访问的服务, 找到对应的的后端服务实例. 在K8s集群中, 客户端需要访问的服务就是Service对象. 每个Service会对应一个集群内部有效的虚拟IP, 集群内部通过虚拟IP访问一个服务. 在K8s集群中微服务的负载均衡是由Kube-proxy实现的. Kube-proxy是K8s集群内部的负载均衡器. 它是一个分布式代理服务器, 在K8s的每个节点上都有一个；这一设计体现了它的伸缩性优势, 需要访问服务的节点越多, 提供负载均衡能力的Kube-proxy就越多, 高可用节点也随之增多. 与之相比, 我们平时在服务器端做个反向代理做负载均衡, 还要进一步解决反向代理的负载均衡和高可用问题. 

##### Job
Job 是 k8s 用来控制批处理型任务的 API 对象. 批处理业务与长期伺服业务的主要区别是批处理业务的运行有头有尾, 而长期伺服业务在用户不停止的情况下永远运行. Job管理的Pod根据用户的设置把任务成功完成就自动退出了. 成功完成的标志根据不同的`spec.completions`策略而不同：
- 单Pod型任务有一个Pod成功就标志完成；
- 定数成功型任务保证有N个任务全部成功；
- 工作队列型任务根据应用确认的全局成功而标志成功. 

##### DaemonSet
长期伺服型和批处理型服务的核心在业务应用, 可能有些节点运行多个同类业务的Pod, 有些节点上又没有这类Pod运行；

而**后台支撑型服务**的核心关注点在K8s集群中的节点（物理机或虚拟机）, 要保证每个节点上都有一个此类Pod运行. 节点可能是所有集群节点也可能是通过nodeSelector选定的一些特定节点. 

典型的后台支撑型服务包括, 存储, 日志和监控等在每个节点上支持K8s集群运行的服务. 

##### PetSet
K8s在1.3版本里发布了Alpha版的PetSet功能. 

在云原生应用的体系里, 有下面两组近义词；第一组是无状态（stateless）、牲畜（cattle）、无名（nameless）、可丢弃（disposable）；第二组是有状态（stateful）、宠物（pet）、有名（having name）、不可丢弃（non-disposable）. 

RC和RS主要是控制提供无状态服务的, 其所控制的Pod的名字是随机设置的, 一个Pod出故障了就被丢弃掉, 在另一个地方重启一个新的Pod, 名字变了、名字和启动在哪儿都不重要, 重要的只是Pod总数；

而PetSet是用来控制**有状态服务**, PetSet中的每个Pod的名字都是事先确定的, 不能更改. PetSet中Pod的名字的作用是关联与该Pod对应的状态. 

对于RC和RS中的Pod, 一般不挂载存储或者挂载共享存储, 保存的是所有Pod共享的状态, Pod像牲畜一样没有分别; 对于PetSet中的Pod, 每个Pod挂载自己独立的存储, 如果一个Pod出现故障, 从其他节点启动一个同样名字的Pod, 要挂载上原来Pod的存储继续以它的状态提供服务. 

适合于PetSet的业务包括数据库服务MySQL和PostgreSQL, 集群化管理服务Zookeeper、etcd等有状态服务. PetSet的另一种典型应用场景是作为一种比普通容器更稳定可靠的模拟虚拟机的机制. 传统的虚拟机正是一种有状态的宠物, 运维人员需要不断地维护它, 容器刚开始流行时, 我们用容器来模拟虚拟机使用, 所有状态都保存在容器里, 而这已被证明是非常不安全、不可靠的. 使用PetSet, Pod仍然可以通过漂移到不同节点提供高可用, 而存储也可以通过外挂的存储来提供高可靠性, PetSet做的只是将确定的Pod与确定的存储关联起来保证状态的连续性. 

PetSet还只在Alpha阶段, 后面的设计如何演变, 我们还要继续观察. 

##### Federation
K8s在1.3版本里发布了beta版的Federation功能. 

在云计算环境中, 服务的作用距离范围从近到远一般可以有：同主机（Host, Node）、跨主机同可用区（Available Zone）、跨可用区同地区（Region）、跨地区同服务商（Cloud Service Provider）、跨云平台. 

K8s的设计定位是单一集群在同一个地域内, 因为同一个地区的网络性能才能满足K8s的调度和计算存储连接要求. 而联合集群服务就是为提供跨Region跨服务商K8s集群服务而设计的. 

每个K8s Federation有自己的分布式存储、API Server和Controller Manager. 用户可以通过Federation的API Server注册该Federation的成员K8s Cluster. 当用户通过Federation的API Server创建、更改API对象时, Federation API Server会在自己所有注册的子K8s Cluster都创建一份对应的API对象. 在提供业务请求服务时, K8s Federation会先在自己的各个子Cluster之间做负载均衡, 而对于发送到某个具体K8s Cluster的业务请求, 会依照这个K8s Cluster独立提供服务时一样的调度模式去做K8s Cluster内部的负载均衡. 而Cluster之间的负载均衡是通过域名服务的负载均衡来实现的. 

所有的设计都尽量不影响K8s Cluster现有的工作机制, 这样对于每个子K8s集群来说, 并不需要更外层的有一个K8s Federation, 也就是意味着所有现有的K8s代码和机制不需要因为Federation功能有任何变化. 

##### Volume
K8s集群中的存储卷跟Docker的存储卷有些类似, 只不过Docker的存储卷作用范围为一个容器, 而K8s的存储卷的生命周期和作用范围是一个Pod. 每个Pod中声明的存储卷由Pod中的所有容器共享. 

K8s支持非常多的存储卷类型, 特别的, 支持多种公有云平台的存储, 包括AWS, Google和Azure云；支持多种分布式存储包括GlusterFS和Ceph；也支持较容易使用的主机本地目录hostPath和NFS. 

K8s还支持使用Persistent Volume Claim即PVC这种逻辑存储, 使用这种存储, 使得存储的使用者可以忽略后台的实际存储技术（例如AWS, Google或GlusterFS和Ceph）, 而将有关存储实际技术的配置交给存储管理员通过Persistent Volume来配置. 

总结:
k8s 支持的存储类型:
- 云存储 : AWS, Google, Azure
- 分布式存储 : GlusterFS, Ceph
- 本地存储 : hostPath, NFS
- Persistent Volume Claim : 逻辑存储, 后端可以使用以上任何一种存储.

##### Persistent Volume(PV, 持久存储卷) and Persistent Volume Claim(
PVC, 持久存储卷声明)

PV和PVC使得K8s集群具备了存储的逻辑抽象能力, 使得在配置Pod的逻辑里可以忽略对实际后台存储技术的配置, 而把这项配置的工作交给PV的配置者, 即集群的管理者. 

存储的PV和PVC的这种关系, 跟计算的Node和Pod的关系是非常类似的；PV和Node是资源的提供者, 根据集群的基础设施变化而变化, 由K8s集群管理员配置；而PVC和Pod是资源的使用者, 根据业务服务的需求变化而变化, 有K8s集群的使用者即服务的管理员来配置. 

##### Node
K8s集群中的计算能力由Node提供, 最初Node称为服务节点Minion, 后来改名为Node. 

K8s集群中的Node也就等同于Mesos集群中的Slave节点, 是所有Pod运行所在的工作主机, 可以是物理机也可以是虚拟机. 不论是物理机还是虚拟机, 工作主机的统一特征是上面要运行kubelet管理节点上运行的容器. 

##### Secret

Secret是用来保存和传递密码、密钥、认证凭证这些敏感信息的对象. 使用Secret的好处是可以避免把敏感信息明文写在配置文件里. 

在K8s集群中配置和使用服务不可避免的要用到各种敏感信息实现登录、认证等功能, 例如访问AWS存储的用户名密码. 为了避免将类似的敏感信息明文写在所有需要使用的配置文件中, 可以将这些信息存入一个Secret对象, 而在配置文件中通过Secret对象引用这些敏感信息. 

这种方式的好处包括：意图明确, 避免重复, 减少暴漏机会. 

##### User Account && Service Account

顾名思义, 用户帐户为人提供账户标识, 而服务账户为计算机进程和K8s集群中运行的Pod提供账户标识. 

用户帐户和服务帐户的一个区别是作用范围；用户帐户对应的是人的身份, 人的身份与服务的namespace无关, 所以用户账户是跨namespace的；而服务帐户对应的是一个运行中程序的身份, 与特定namespace是相关的. 

##### Namespace
名字空间为K8s集群提供虚拟的隔离作用, K8s集群初始有两个名字空间, 分别是**默认名字空间default**和**系统名字空间kube-system**, 除此以外, 管理员可以可以创建新的名字空间满足需要. 

##### RBAC 访问授权

K8s在1.3版本中发布了alpha版的基于角色的访问控制（Role-based Access Control, RBAC）的授权模式. 

相对于基于属性的访问控制（Attribute-based Access Control, ABAC）, RBAC主要是引入了角色（Role）和角色绑定（RoleBinding）的抽象概念. 

在ABAC中, K8s集群中的访问策略只能跟用户直接关联；而在RBAC中, 访问策略可以跟某个角色关联, 具体的用户在跟一个或多个角色相关联. 

显然, RBAC像其他新功能一样, 每次引入新功能, 都会引入新的API对象, 从而引入新的概念抽象, 而这一新的概念抽象一定会使集群服务管理和使用更容易扩展和重用. 

### 2.2 主要概念

#### Pod
Pod 是一组紧密关联的容器集合, 他们共享 IPC, Network, UTC namespace, 是 kubernetes 调度的基本单位. Pod 的设计理念是支持多个容器在一个 Pod 中共享网络和文件系统, 可以通过进程间通信和文件共享这种简单高效的方式组合完成服务.

##### Pod 特征
- 包含多个共享IPC、Network和UTC namespace的容器, 可直接通过localhost通信
- 所有Pod内容器都可以访问共享的Volume, 可以访问共享数据
- Pod一旦调度后就**跟Node绑定**, 即使Node挂掉也不会重新调度, 推荐使用Deployments、Daemonsets等控制器来容错
- 优雅终止：Pod删除的时候先给其内的进程发送SIGTERM, 等待一段时间（grace period）后才强制停止依然还在运行的进程
- 特权容器（通过SecurityContext配置）具有改变系统配置的权限（在网络插件中大量应用）

##### Pod 定义
通过 yaml 或 json 描述 pod 和其内 container 的运行环境以及期望状态.

一个简单的 nginx pod 定义:

    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80

##### 使用 Volume
Volume 可以为容器提供持久化存储.

    apiVersion: v1
    kind: Pod
    metadata:
      name: redis
    spec:
      containers:
      - name: redis
        image: redis
        volumeMounts:
        - name: redis-storage
          mountPath: /data/redis
      volumes:
      - name: redis-storage
        emptyDir: {}

##### RestartPolicy
支持三种 RestartPolicy: 此处重启指 在 Pod 所在 Node上本地重启, 而不会调度到其他 Node 上.

- Always : 只要退出就重启
- OnFailure : 失败退出(exit code 不等于 0)时重启
- Never : 只要退出就不再重启.

##### 资源限制
Kubernetes 通过 cgroups 提供容器资源管理的功能, 可以限制每个容器的 CPU 和内存使用等. 

CPU 的单位是 milicpu, 500mcpu=0.5cpu, 
内存单位包括 E,P,T,G,M,K,Ei,Pi,Ti,Gi,Mi,Ki 等.

    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        app: nginx
      name: nginx
    spec:
      containers:
        - image: nginx
          name: nginx
          resources:
            limits:
              cpu: "500m"
              memory: "128Mi"

##### 健康检查
为了确保容器在部署后确实处于正常运行状态, Kubernetes 提供了两种探针(Probe, 支持 exec, tcp 和 http 方式) 来探测容器的状态.

- LivenessProbe : 探测应用是否处于健康状态, 如果不健康则删除重建该容器.
- ReadinessProbe : 探测应用是否启动完成并且处于正常服务状态, 如果不正常则更新容器的状态.

        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            app: nginx
          name: nginx
        spec:
            containers:
            - image: nginx
            imagePullPolicy: Always
            name: http
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
            resources:
                limits:
                cpu: "500m"
                memory: "128Mi"
            livenessProbe:
                httpGet:
                path: /
                port: 80
                initialDelaySeconds: 15
                timeoutSeconds: 1
            readinessProbe:
                httpGet:
                path: /ping
                port: 80
                initialDelaySeconds: 5
                timeoutSeconds: 1

##### Init Container
Init Container 在所有容器运行之前执行(run-to-completion), 常用来初始化配置.

    apiVersion: v1
    kind: Pod
    metadata:
      name: init-demo
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: workdir
          mountPath: /usr/share/nginx/html
      # These containers are run during pod initialization
      initContainers:
      - name: install
        image: busybox
        command:
        - wget
        - "-O"
        - "/work-dir/index.html"
        - http://kubernetes.io
        volumeMounts:
        - name: workdir
          mountPath: "/work-dir"
      dnsPolicy: Default
      volumes:
      - name: workdir
        emptyDir: {}

##### Hooks
支持两种 Hook:
- postStart : 容器启动后执行, 注意由于是异步执行, 它无法保证一定在 ENTRYPOINT 之后执行.
- preStop : 容器停止前执行, 常用于资源清理.

示例 : 

    apiVersion: v1
    kind: Pod
    metadata:
      name: lifecycle-demo
    spec:
      containers:
      - name: lifecycle-demo-container
        image: nginx
        lifecycle:
          postStart:
            exec:
              command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
          preStop:
            exec:
              command: ["/usr/sbin/nginx","-s","quit"]

##### 指定 Node
通过 `nodeSelector` , 一个 Pod 可以指定它所想要运行的 Node 节点.

首先, 先给 Node 加上标签:
    
    $ kubectl label nodes <your-node-name> disktype=ssd

然后, 指定该 Pod 只运行在 lable 为 disktype=ssd 的 Node 上.
    
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
      labels:
        env: test
    spec:
      containers:
      - name: nginx
        image: nginx
        imagePullPolicy: IfNotPresent
      nodeSelector:
        disktype: ssd

##### 使用 [Capabilities](http://man7.org/linux/man-pages/man7/capabilities.7.html)

**Capabilities**
从2.1版开始,Linux内核有了能力(capability)的概念,即它打破了UNIX/LINUX操作系统中超级用户/普通用户的概念,由普通用户也可以做只有超级用户可以完成的工作.

capability可以作用在进程上(受限),也可以作用在程序文件上,它与sudo不同,sudo只针对用户/程序/文件的概述,即sudo可以配置某个用户可以执行某个命令,可以更改某个文件,而capability是让某个程序拥有某种能力. 例如: capability让/tmp/testkill程序可以kill掉其它进程,但它不能mount设备节点到目录,也不能重启系统,因为我们只指定了它kill的能力,即使程序有问题也不会超出能力范围.

每个进程有三个和能力有关的位图: `inheritable(I)`,`permitted(P)`和`effective(E)`, 对应进程描述符 `task_struct(include/linux/sched.h)` 里面的 `cap_effective`, `cap_inheritable`, `cap_permitted`,所以我们可以查看`/proc/PID/status`来查看进程的能力.

- `cap_effective` : 当一个进程要进行某个特权操作时,操作系统会检查cap_effective的对应位是否有效,而不再是检查进程的有效UID是否为0.
例如,如果一个进程要设置系统的时钟,Linux的内核就会检查cap_effective的CAP_SYS_TIME位(第25位)是否有效.
- `cap_permitted` : 表示进程能够使用的能力,在cap_permitted中可以包含cap_effective中没有的能力, 这些能力是被进程自己临时放弃的,也可以说cap_effective是cap_permitted的一个子集.
- `cap_inheritable` : 表示能够被当前进程执行的程序继承的能力.


默认情况下, 容器都是以非特权容器的方式运行, 比如, 不能在容器中创建虚拟网卡, 配置虚拟网络.

Kubernetes 提供了修改 Capabilities 的机制, 可以按需要给容器增加或删除, 如下配置中, 给容器增加了 `CAP_NET_ADMIN` 并 删除 `CAP_KILL` .

    apiVersion: v1
    kind: Pod
    metadata:
      name: hello-world
    spec:
      containers:
      - name: friendly-container
        image: "alpine:3.4"
        command: ["/bin/echo", "hello", "world"]
        securityContext:
          capabilities:
            add:
            - NET_ADMIN
            drop:
            - KILL

#### Namespace
Namespace 是对一组资源和对象的抽象集合, 比如可以用来将系统内部的对象划分为不同的项目组或用户组. 

常见的 pods, services, replication controller  和 deployments 等都是属于某一个 namespace 的(默认为 default), 而 node , persistentVolumes 等则不属于任何 namespace .

Namespace 常用来隔离不同的用户, 比如 Kubernetes 自带的服务一般运行在 kube-system namespace 中.

##### 操作

`kubectl` 可以通过 `--namespace` 或 `-n` 选项指定 namespace, 如果不指定, 则默认为 default.

##### 查询
    
    $ kubectl get namespace

##### 创建

    $ cat my-namespace.yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: new-namespace

    $ kubectl create -f ./my-namespace.yaml

##### 删除

**注意: 删除一个 namespace 会自动删除所有属于该 namespace 的资源**
    
    $ kubectl delete namespace new-namespace

#### Node
Node 是 Pod 真正运行的主机, 可以是 物理机, 也可以是虚拟机. 为了管理 Pod, 每个 Node 节点上至少要运行 Container runtime(如 docker/rkt), kubelet 和 kube-proxy .

##### Node 管理
Node 本质上不是 kubernetes 来创建的, kubernetes 只是管理 Node 上的资源.

默认情况下, kubelet 在启动时会向 master 注册自己, 并创建 Node 资源.

虽然可以通过 Manifest 创建一个 Node 对象, 但 Kubernetes 只是去检查 Node 是否可用, 如果检查失败, 则不会向上调度 Pod.

    {
      "kind": "Node",
      "apiVersion": "v1",
      "metadata": {
        "name": "10.240.79.157",
        "labels": {
          "name": "my-first-k8s-node"
        }
      }
    }

node 可用性检查是由 Node Controller 来完成的, Node Controller 负责:
1. 维护 Node 状态
2. 与 Cloud Provider 同步 Node
3. 给 Node 分配 CIDR
4. 删除带有 `NoExecute` taint 的 Node 上的 Pod.

##### Node 状态
每个 Node 都会包括以下状态信息:
1. 地址: 包括hostname, public IP, private IP
2. 条件(Condition): 包括 OutOfDisk, Ready, MemoryPressure, DiskPressure.
3. 容量(Capacity): Node 上的可用资源, 包括 CPU, 内存和 Pod 总数.
4. 基本信息(Info): 包括内核版本, 容器引擎版本, OS类型等.

##### [Taints 和 tolerations](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#taints-and-tolerations-beta-feature)


Taints 和 tolerations 用于保证 Pod 不被调度到不合适的 Node 上.

Taints 应用 Node 上;
tolerations 应用于 Pod 上, tolerations 是可选的.

如, 假设 node1 上应用以下几个 taint:
    
    $ kubectl taint nodes node1 key1=value1:NoSchedule
    $ kubectl taint nodes node1 key1=value1:NoExecute
    $ kubectl taint nodes node1 key2=value2:NoSchedule

##### Node 维护模式
维护模式表示 : Node 不可调度, 但不影响其上正在运行的 Pod, 这种在维护 Node 时是非常有用的.
    
    $ kubectl cordon NODE_NAME


#### 服务发现与负载均衡
kubernetes 在设计之初就充分考虑了针对容器的服务发现与负载均衡机制, 提供了 Service 资源, 并通过 kube-proxy 配合 cloud provider 来适应不同的场景. 随着 Kubernetes 用户的激增, 用户场景的不断丰富, 又产生了一些新的负载均衡机制, 每个机制都有其特定的应用场景:

##### 1. Service : 
直接使用 Service 提供 cluster 内部的负载均衡, 并借助 cloud provider 提供的 LB 提供外部访问.

Service 是对一组提供相同功能的 Pods 的抽象, 并为他们提供统一的入口. 借助 Service, 应用可以方便的实现服务发现与负载均衡, 并实现应用的零宕机升级.

Service 通过标签来选取服务后端, 一般配合 Replication Controller 或者 Deployment 来保证后端容器的正常运行. 这些匹配标签的 Pod IP 和端口列表组成 endpoints, 由 kube-proxy 负责将服务 IP 负载均衡到这些 endpoints.

###### 1.1 Service 类型
1. ClusterIP : 默认类型, 自动分配一个仅 cluster 内部可以访问的虚拟IP.
2. NodePort : 在 ClusterIP 基础上为 Service 在每台机器上绑定一个端口, 这样就可以通过 `<NodeIP>:NodePort` 来访问服务.
3. LoadBalancer : 在 NodePort 基础上, 基础 cloud provider 创建一个外部的负载均衡器, 并将请求转发到 `<NodeIP>:NodePort` .
4. ExternalName : 将服务通过 DNS CNAME 记录方式转达到指定的域名 (通过 `spec.externlName` 设定). 需要 kube-dns 版本 1.7 以上.

另外, 也可以将已有的服务以 Service 的形式加入到 Kubernetes 集群中, 只需要在创建 Service 的时候不指定 Label selector , 而是在 Service 创建好后手动为其添加 endpoint.

###### 1.2 Service 定义
Service 的定义也是通过 yaml 或 json ,

示例: 定义 nginx 服务, 并将服务的 80 端口装发到 default namespace 中 lable 为 `run=nginx` 的 Pod 的 80 端口.

    apiVersion: v1
    kind: Service
    metadata:
      labels:
        run: nginx
      name: nginx
      namespace: default
    spec:
      ports:
      - port: 80
        protocol: TCP
        targetPort: 80
      selector:
        run: nginx
      sessionAffinity: None
      type: ClusterIP

###### 1.3 查看 service 状态

    # 查看 service
    $ kubectl get service nginx

    # 查看 service 自动创建的 endpoints
    $ kubectl get endpoints nginx

    # Service nginx 自动关联 endpoints
    $ kubectl describe service nginx

###### 1.4 不指定 Selector 的服务
在创建 Service 的时候, 也可不指定 Selectors, 用来将 service 转发到 kubernetes 集群外部的服务(而不是 Pod). 目前支持两种方法:

1. 自定义 endpoints
    
    创建同名的 service 和 endpoints , 在 endpoints 中设置外部服务的 IP 和端口.

        kind: Service
        apiVersion: v1
        metadata:
          name: my-service
        spec:
          ports:
            - protocol: TCP
              port: 80
              targetPort: 9376

        ---
        kind: Endpoints
        apiVersion: v1
        metadata:
          name: my-service
        subsets:
          - addresses:
              - ip: 1.2.3.4
            ports:
              - port: 9376

2. 通过 DNS 转发

    在 service 定义中指定 externalName, 此时 DNS 服务会给 `<service-name>.<namespace>.svc.cluster.local` 创建一个 CNAME 记录, 其值为 `my.database.example.com`. 并且, 该服务不会自动分配 ClusterIP, 需要通过 service 的 DNS 来访问(这种服务也称为 Headless Service).

        kind: Service
        apiVersion: v1
        metadata:
          name: my-service
          namespace: default
        spec:
          type: ExternalName
          externalName: my.database.example.com

###### 1.5 Headless 服务

Headless 服务即不需要 Cluster IP 的服务, 即在创建服务的时候指定 `spec.clusterIP=None`, 包括两种类型:

1. 不指定 selector, 但设置 externalName, 即上面的 1.4.2 示例, 通过 CNAME 记录处理.

2. 指定 Selector, 通过 DNS A 记录设置后端 endpoint 列表.

##### 2. Ingress Controller : 
使用 Service 提供 cluster 内部的负载均衡, 但是通过自定义的 LB 提供外部访问.

Service 虽然解决了服务发现和负载均衡的问题, 但他在使用上还是有一些限制, 比如:
- 只支持 4 层负载均衡, 没有 7 层的功能;
- 对外访问的时候, NodePort 类型需要在外部搭建额外的负载均衡器, 而 LoadBalancer 要求 kubernetes 必须跑在支持的 cloud provider 上.

[Ingress Controller](file:///C:/Users/Administrator/AppData/Local/Temp/calibre_hkmj89/k7ift1_ebook_iter/ingress.html) 就是为了解决这些限制而引入的新资源, 主要用来将服务暴露在 cluster 外面, 并且可以自定义服务的访问策略. 如想要通过负载均衡器实现不同子域名到不同服务的访问.

    apiVersion: extensioins/v1beta1
    kind: Ingress
    metadata:
      name: test
    spec:
      rules:
      - host: foo.bar.com
        http:
          paths:
          - backend:
              serviceName: s1
              servicePort: 80
      - host: bar.foo.com
        http:
          paths:
          - backend:
              serviceName: s2
              servicePort: 80

**注意**Ingress 本身并不会自动创建负载均衡器, cluster 中需要运行一个 ingresses controller 来根据 Ingress 的定义来管理负载均衡器. 目前社区提供了 nginx 和 gce 的参考实现.


##### 3. Service Load Balance : 
把 load balancer 直接跑在容器中, 实现 Bare Metal 的 Service Load Balancer.

在 Ingress 出现之前, Service Load Balance 是推荐的解决 Service 局限性的方式. Service Load Balance 将 haproxy 跑在容器中, 并监控 service 和 endpoints 的变化, 通过容器 IP 对外提供 4 层和 7 层负载均衡服务.

社区提供的 Service Load Balance 支持四种负载均衡协议: TCP, HTTP, HTTPS, SSL TERMINATION , 并支持 ACL 访问控制.

##### 4. Custom Load Balance : 
自定义负载均衡, 并替代 kube-proxy, 一般在物理部署 kubernetes 时使用, 方便介入公司已有的外部服务.

基本的思路是监控 kubernetes 中 service 和 endpoints 的变化, 并根据这些变化来配置负载均衡器, 比如 weave flux, nginx plus, kube2haproxy 等.

#### Volume
Kubernetes 提供的强大的 Volume 机制和丰富的插件, 解决了容器数据持久化和容器间共享数据的问题.

Kubernetes Volume 的生命周期与 Pod 绑定. 容器挂掉后, kubelet 再次重启容器时, Volume 的数据依然还在; 而 Pod 删除时, Volume 才会清理. 数据是否丢失取决于具体的 Volume 类型, 比如 emptyDir 的数据会跌势, 而 PV 的数据则不会.

##### Volume 类型
- emptyDir
- hostPath
- gcePersistentDisk
- awsElasticBlockStore
- nfs
- [iscsi](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/iscsi)
- [flocker](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/flocker)
- [glusterfs](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/glusterfs)
- [rbd](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/rbd)
- [cephfs](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/cephfs)
- gitRepo
- [secret](file:///C:/Users/Administrator/AppData/Local/Temp/calibre_hkmj89/k7ift1_ebook_iter/secret.html#%E5%B0%86secret%E6%8C%82%E8%BD%BD%E5%88%B0volume%E4%B8%AD)
- persistentvolumes
- [downwardAPI](https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/)
- [azureFileVolume](https://github.com/kubernetes/kubernetes/blob/master/examples/volumes/azure_file/README.md)
- [azureDisk](https://github.com/kubernetes/kubernetes/blob/master/examples/volumes/azure_disk/README.md)
- vsphereVolume
- [Quobyte](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/quobyte)
- [PortworxVolume](https://github.com/kubernetes/kubernetes/blob/master/examples/volumes/portworx/README.md)
- [ScaleIO](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/scaleio)
- FlexVolume

这些 Volume 并非全部是持久化的, 比如 emptyDir, secret, gitRepo 等, 这些 volumes 会随着 Pod 的消亡而消失.

##### emptyDir
当 Pod 设置了 emptyDir 类型 Volume, Pod 被分配到 Node 上时, 会创建 emptyDir , 只要 Pod 运行在 Node 上, emptyDir 都会存在(容器挂掉不会导致 emptyDir 丢失数据), 但是如果 Pod 从 Node 上被删除(Pod被删除或者Pod 发生迁移), emptyDir 会被删除, 并且永远丢失.

    apiVersion: v1
    kind: Pod
    metadata:
      name: test-pd
    spec:
      containers:
      - image: gcr.io/google_containers/test-webserver
        name: test-container
        volumeMounts:
        - mountPath: /cache
          name: cache-volume
      volumes:
      - name: cache-volume
        emptyDir: {}

##### hostPath
hostPach 允许挂在 Node 上的文件系统到 Pod 里面, 如果 Pod 需要使用 Node 上的文件, 可以使用 hostPath.

    apiVersion: v1
    kind: Pod
    metadata:
      name: test-pd
    spec:
      containers:
      - image: gcr.io/google_containers/test-webserver
        name: test-container
        volumeMounts:
        - mountPath: /test-pd
          name: test-volume
      volumes:
      - name: test-volume
        hostPath:
          path: /data

##### NFS
NFS 即网络文件系统. Kubernetes 通过简单的配置就可以挂在 NFS 到 Pod 中, 而 NFS 中的数据是可以永久保存的, 同时 NFS 支持同时写操作.
    
    volumes:
    - name: nfs
      nfs:
        server: 192.168.1.100
        path: "/"


##### gcePersistentDisk
gcePersistentDisk 可以挂载 GCE 上的永久磁盘到容器, 需要 Kubernetes 运行在 GCE 的 VM 中.
    
    volumes:
      - name: test-volume
        gcePersistentDisk:
          pdName: my-data-disk      # this GCE PD must already exist.
          fsType: ext4

##### awsElasticBlockStore
awsElasticBlockStore 可以挂载 AWS 上的 EBS 盘到容器, 需要 Kubernetes 运行在 AWS 的 EC2 上.
    
    volumes:
      - name: test-volume
        awsElasticBlockStore:
          volumeID: MY_VOLUME_ID
          fsType: ext4

##### gitRepo
gitRepo volume 将 git 代码下拉到指定的容器路径中.

    volumes:
    - name: git-volume
      gitRepo:
        repository: "git@somewhere:me/my-git-repo.git"
        revision: "22f1d8406d464b0c0874075539c1f2e96c253775"

##### subPath
Pod 的多个容器使用同一个 Volume 时, subPath 非常有用.

    apiVersion: v1
    kind: Pod
    metadata:
      name: my-lamp-site
    spec:
      containers:
      - name: mysql
        image: mysql
        volumeMounts:
        - mountPath: /var/lib/mysql
          name: site-data
          subPath: mysql
      - name: php
        image: php
        volumeMounts:
        - mountPath: /var/www/html
          name: site-data
          subPath: html
      volumes:
      - name: site-data
        persistentVolumeClaim:
          claimName: my-lamp-site-data

##### FlexVolume
如果内置的 Volume 不满足需求, 则可以使用 FlexVolume 实现自己的 Volume 插件.

**注意**要把 volume plugin 放到 `/usr/libexec/kubernetes/kubelet-plugins/volume/exec/<vendor-driver>/<driver>`, plugin 要实现 `init/attach/detach/mount/umount` 等命令, 参考[LVM](https://github.com/kubernetes/community/blob/master/contributors/devel/flexvolume.md).
    
    - name: test
      flexVolume:
        driver: "kubernetes.io/lvm"
        fsType: "ext4"
        options:
          volumeID: "vol1"
          size: "1000m"
          volumegroup: "kube_vg"

#### Persistent Volume
PersistentVolumes(PV) 和 PersistentVolumeClaim(PVC) 提供了方便的持久化卷:
- PV 提供网络存储资源;
- PVC 请求存储资源.

因此, 设置持久化的工作流包括配置底层文件系统或者云数据卷, 创建持久性数据卷, 最后创建 claim 来将 Pod 跟数据卷关联起来.

PV 和 PVC 可以将 pod 和数据卷解耦, pod 不需要知道确切的文件系统或者支持他的持久化引擎.

##### Volume 生命周期 与 状态
Volume 的生命周期包括 5 个阶段:
1. Provisioning : PV 的创建, 可以直接创建 PV (静态方式), 也可以使用 StorageClass 动态创建.
2. Binding : 将 PV 分配给 PVC.
3. Using : Pod 通过 PVC 使用该 Volume.
4. Releasing : Pod 释放 Volume 并删除 PVC.
5. Reclaiming : 回收 PV, 可以保留 PV 以便下次使用, 也可以直接从云存储中删除.

根据以上 5 个阶段, Volume 的状态有以下 4 种:
- Available: 可用
- Bound: 已经分配给 PVC
- Released: PVC 解绑但尚未执行回收策略.
- Failed: 发生错误.

##### PV
PersistentVolume (PV) 是集群之中的一块网络存储, 跟 Node 一样, 也是集群的资源. PV 跟 Volume(卷) 类似, 不过会有独立于 Pod 的生命周期.
    
    # NFS PV
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv0003
    spec:
      capacity:
        storage: 5Gi
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Recycle
      nfs:
        path: /tmp
        server: 172.17.0.100

PV 的**访问方式(accessModes)** 有三种:
1. **ReadWriteOnce(RWO)** : 最基本方式, 可读可写, 但只支持被单个 Pod 挂在.
2. **ReadOnlyMany(ROX)** : 以只读方式被多个 Pod 挂载.
3. **ReadWriteMany(RWX)** : 以读写方式被多个 Pod 挂载.

不是每一种存储都支持这三种方式, 像共享方式, 目前支持的还比较少, 比较常用的是 NFS, 在PVC 绑定 PV 是通常根据两个条件来绑定: ① 存储大小; ② 访问模式.

PV 的**回收策略(persistentVolumeReclaimPolicy)**, 有三种:
1. **Retain** : 不清理, 保留 Volume (需要手动清理)
2. **Recycle** : 删除数据, 即 `rm -rf /thevolume/*`, **只有NFS和 HostPath支持**
3. **Delete** : 删除存储资源, 比如删除 AWS EBS 卷. **只有AWS EBS, GCE PD, Azure Disk 和 Cinder支持**

##### StorageClass
通过手动方式创建 Volume, 在管理很多 Volume 时不太方便, Kubernetes 提供 StorageClass 来动态创建 PV, 不仅节省管理员时间, 还可以封装不同类型的存储供 PVC 选用.

在使用 PVC 时, 可以通过 `DefaultStorageClass` Admission Controller 定义默认的 StorageClass, 以供为指定 storageClassName 的 PVC 使用.

**GCE** 示例
    
    kind: StorageClass
    apiVersion: storage.k8s.io/v1beta1
    metadata:
      name: slow
    provisioner: kubernetes.io/gce-pd
    parameters:
      type: pd-standard
      zone: us-central1-a

**Ceph RBD** 示例

    apiVersion: storage.k8s.io/v1beta1
    kind: StorageClass
    metadata:
      name: fast
    provisioner: kubernetes.io/rbd
    parameters:
      monitors: 10.16.153.105:6789
      adminId: kube
      adminSecretName: ceph-secret
      adminSecretNamespace: kube-system
      pool: kube
      userId: kube
      userSecretName: ceph-secret-user

**Glusterfs** 示例

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: slow
    provisioner: kubernetes.io/glusterfs
    parameters:
      resturl: "http://127.0.0.1:8081"
      clusterid: "630372ccdc720a92c681fb928f27b53f"
      restauthenabled: "true"
      restuser: "admin"
      secretNamespace: "default"
      secretName: "heketi-secret"
      gidMin: "40000"
      gidMax: "50000"
      volumetype: "replicate:3"

**OpenStack Cinder** 示例

    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: gold
    provisioner: kubernetes.io/cinder
    parameters:
      type: fast
      availability: nova

##### PVC
PV 是存储资源, 而 PersistentVolumeClaim(PVC) 是对 PV 的请求. 

PVC跟Pod类似:
- Pod 消费 Node 资源, PVC 消费 PV 资源;
- Pod 能够请求 CPU 和内存资源, 而 PVC 请求 特定大小和访问模式的数据卷.

示例:

    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: myclaim
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 8Gi
      storageClassName: slow
      selector:
        matchLabels:
          release: "stable"
        matchExpressions:
          - {key: environment, operator: In, values: [dev]}

PVC 可以直接挂载到 Pod 中:

    kind: Pod
    apiVersion: v1
    metadata:
      name: mypod
    spec:
      containers:
        - name: myfrontend
          image: dockerfile/nginx
          volumeMounts:
          - mountPath: "/var/www/html"
            name: mypd
      volumes:
        - name: mypd
          persistentVolumeClaim:
            claimName: myclaim

#### Deployment
##### 简述
Deployment 为 Pod 和 ReplicaSet 提供了一个声明式定义(declarative)方法, 用来替代以前的 ReplicationController 来方便的管理应用.

典型的**使用场景**包括:
- 定义 Deployment 来创建 Pod 和 ReplicaSet
- 滚动升级和回滚应用
- 扩容和缩容
- 暂停和继续 Deployment

使用示例:
1. 定义 nginx deployment
    
        apiVersion: extensions/v1beta1
        kind: Deployment
        metadata:
          name: nginx-deployment
        spec:
          replicas: 3
          template:
            metadata:
              labels:
                app: nginx
            spec:
              containers:
              - name: nginx
                image: nginx:1.7.9
                ports:
                - containerPort: 80

2. 扩容
    
        $ kubectl scale deployment nginx-deployment --replicas 10

3. 如果集群支持 horizontal pod autoscaling 的话, 可以设置 deployment 为自动扩展:
        
        $ kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80

4. 更新镜像
    
        $ kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1

5. 回滚
        
        $ kubectl rollout undo deployment/nginx-deployment

##### [Deployment 概念详细解析](https://github.com/kubernetes/kubernetes.github.io/blob/master/docs/concepts/workloads/controllers/deployment.md)

###### 使用场景
Deployment 为 Pod 和 Replica Set (下一代 Replication Controller) 提供声明式更新 : 只需要在 Deployment 中描述目标状态, Deployment Controller 就会将 Pod 和 Replica Set 的实际状态改变到目标状态. 也可以定义一个全新的 Deployment , 也可以创建一个新的替换旧的 Deployment.

典型用例:
- 使用 Deployment 来创建 ReplicaSet. ReplicaSet 在后台创建 Pod, 检查启动状态, 看是成功还是失败.
- 通过更新 Deployment 的 PodTemplateSpec 字段来声明 Pod 的新状态. 这会创建一个新的 ReplicaSet , Deployment 会按照控制的速率将 Pod 从旧的 ReplicaSet 移动到新的 ReplicaSet 中.
- 如果当前状态不稳定, 回滚到之前的 Deployment revision. 每次回滚都会更新 Deployment 的 revision.
- 扩容 Deployment 以满足更高的负载
- 暂定 Deployment 来应用 PodTemplateSpec 的多个修复, 然后恢复上线.
- 根据 Deployment 的状态判断上线是否 hang 住了.
- 清除旧的不必要的 ReplicaSet.

###### 创建 Deployment
    
    # 将 kubectl 的 --record 的 flag 设置为 true , 可以在 annotation 中记录当前命令创建或升级了该资源, 这在将来会很有用.
    $ kubectl create -f docs/user-guide/nginx-deployment.yaml --record deployment "nginx-deployment" created

    # 查看 deployment 状态
    $ kubectl get deployment

    # 查看创建 rs 和 pod 资源
    $ kubectl get rs        # rs 的名称总是 "<Deployment_Name>-<hash_of_pod_template>"
    $ kubectl get pods --show-labels


###### 更新 Deployment

**Deployment 的 rollout 当且仅当 Deployment 的 pod template (.spec.template) 中的 label 更新或镜像更改时被触发. 其他更新, 如扩容 Deployment 不会触发 rollout**

Deployment 可以保证在升级时只有一定数量的 Pod 是 down的. 默认的, 他会确保至少有比期望的 Pod 数量少一个 Pod 是 up 状态(最多一个不可用).

Deployment 同时也可以确保只创建出超过期望数量的一定数量的 Pod. 默认的, 他会确保最多比期望的 Pod 数量多一个的 Pod 是 up 的(虽多一个 surge).

在未来的 Kubernetes 版本中, 将从 1-1 变成 25% - 25%.

在如下的实例中, 会看到, 开始创建一个新的 Pod , 然后删除一些就的 Pod 在创建一个新的 . 当新的Pod 创建出来之前不会杀掉旧的 Pod. 这样就能确保可用的 Pod 数量至少有 2 个, Pod 的总数最多为 4 个.

    # 让 nginx pod 使用 nginx:1.9.1 的镜像来代替原来的 nginx:1.7.9 的镜像
    $ kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1 deployment "nginx-deployment" image updated

    # 也可以用 edit 来编辑 Deployment
    $ kubectl edit deployment/nginx-deployment

    # 查看 rollout 状态
    $ kubectl rollout status deployment/nginx-deployment

    # 查看 deployment 状态
    $ kubectl get deployments
        - UP-TO-DATE : replica 中已到达目标配置的数目
        - CURRENT : 当前 Deployment 管理的 replica 数量
        - AVAILABLE : 当前可用的 replica 数量
    $ kubectl describe deployment

    # 查看 ReplicaSet 状态 和 Pods 状态
    # rs 的更新 Pod 是通过创建一个新的 ReplicaSet 并扩容 3 个 replica , 同时将原来的 ReplicaSet 缩容到 0 个 replica.
    $ kubectl get rs    
    $ kubectl get pods

###### Rollover(多个 rollout 并行)
每当 Deployment controllers 观测到有新的 deployment 被创建时, 如果没有已存在的 ReplicaSet 来创阿金期望个数的 Pode 的话, 就会创建出一个新的 ReplicaSet 来做这件事. 已存在的 ReplicaSet 控制 label 匹配 `.spec.selector` 当 template 跟 `.spec.template` 不匹配的 Pod 缩容. 最终, 新的 ReplicaSet 会将扩容出 `.spec.replicas` 指定数目的 Pod, 旧的 ReplicaSet 会缩容到 0 .

如果你更新了一个的已存在并正在进行中的Deployment, 每次更新 Deployment 都会创建一个新的 ReplicaSet 并扩容它, 同时回滚之前扩容的 ReplicaSet -- 将它添加到旧的 ReplicaSet 列表, 开始缩容. 

例如, 假如你创建了一个有5个 niginx:1.7.9 replica 的 Deployment, 但是当还只有3个 nginx:1.7.9 的 replica 创建出来的时候你就开始更新含有5个 nginx:1.9.1 replica 的 Deployment . 在这种情况下, Deployment 会立即杀掉已创建的3个 nginx:1.7.9 的 Pod , 并开始创建 nginx:1.9.1 的 Pod . 它不会等到所有的5个 nginx:1.7.9 的 Pod 都创建完成后才开始改变航道.

###### 回退 Deployment

默认情况下, kubernetes 会在系统中保留两次的 deployment 的 rollout 历史记录, 一遍可以随时回退, 可以通过修改 `revision history limit` 来更改保存的 revision 数.

**注意** : 只要 Deployment 的 rollout 被触发就会创建一个 revision, 也就是说当且仅当 Deployment 的 Pod template (如 `.spec.template`) 被更改, 例如更新 template 中的 label 和容器镜像时, 就会创建出一个新的 revision.

其他的更新, 比如扩容 Deployment 不会创建 revision -- 因此我们可以方便的手动或自动扩容, 这意味着当你回退到历史 revision 时, 只有 Deployment 的 Pod template 部分才会回退.

    # 查看 rollout 状态
    $ kubectl rollout status deployment nginx-deployment
    $ kubectl describe deployment

###### 检查 Deployment 升级历史记录
    
    # 检查 deployment 的 revision
    # 如果在创建 deployment 时使用了 --recored 参数, 可以记录命令, 方便查看每次 revision 的变化
    $ kubectl rollout history deployment/nginx-deployment

    # 查看单个 revision 的详细信息
    $ kubectl rollout history deployment/nginx-deployment --revision=2

###### 回退到历史版本
    
    # 查看相关帮助信息
    $ kubectl rollout --help

    # 回退当前 rollout 到之前的版本
    $ kubectl rollout undo deployment/nginx-deployment

    # 回退到指定版本
    $ kubectl rollout undo deployment/nginx-deployment --revision=2

    # 查看 deployment 状态
    $ kubectl get deployment

    # deployment 回退到先前的稳定版, deployment controllers 产生一个回退到 revision_2 的 'DeploymentRollback' 的 event.
    $ kubectl describe deployment

###### 清理 Policy
可以通过设置 `.spec.revisionHistoryLimit` 项来志定 deployment 最多保留多少个 revision 历史记录. 默认会保留所有的 revision, 如果将该项设置为 0, 则 Deployment 不允许回退.

##### Deployment 扩容
使用如下命令, 扩容 Deployment

    $ kubectl scale deployment nginx-deployment --replicas 10

如果集群中启用了 **horizontal pod autoscaling**, 可以给 Deployment 设置一个 autoscaler , 基于当前 Pod 的 CPU 利用率选择最少和最多的 Pod 数.
    
    $ kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80

###### 比例扩容(灰度)

RollingUpdate Deployment 支持同时运行一个应用的多个版本. 当 autoscaler 扩容 RollingUpdate Deployment 的时候, 正在中途的 rollout (进行中或者已经暂停), 为了降低风险, Deployment controller将会平衡已存在的活动中的ReplicaSets（有Pod的ReplicaSets）和新加入的replicas. 这被称为比例扩容. 

例如, 你正在运行中含有10个replica的Deployment. maxSurge=3, maxUnavailable=2. 

    $ kubectl get deploy
    NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    nginx-deployment     10        10        10           10          50s

你更新了一个镜像, 而在集群内部无法解析. 

    $ kubectl set image deploy/nginx-deployment nginx=nginx:sometag
    deployment "nginx-deployment" image updated

镜像更新启动了一个包含ReplicaSet nginx-deployment-1989198191的新的rollout, 但是它被阻塞了, 因为我们上面提到的maxUnavailable. 

    $ kubectl get rs
    NAME                          DESIRED   CURRENT   READY     AGE
    nginx-deployment-1989198191   5         5         0         9s
    nginx-deployment-618515232    8         8         8         1m

然后发起了一个新的Deployment扩容请求. autoscaler将Deployment的repllica数目增加到了15个. Deployment controller需要判断在哪里增加这5个新的replica. 如果我们没有谁用比例扩容, 所有的5个replica都会加到一个新的ReplicaSet中. 如果使用比例扩容, 新添加的replica将传播到所有的ReplicaSet中. 大的部分加入replica数最多的ReplicaSet中, 小的部分加入到replica数少的ReplciaSet中. 0个replica的ReplicaSet不会被扩容. 

在我们上面的例子中, 3个replica将添加到旧的ReplicaSet中, 2个replica将添加到新的ReplicaSet中. rollout进程最终会将所有的replica移动到新的ReplicaSet中, 假设新的replica成为健康状态. 

    $ kubectl get deploy
    NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    nginx-deployment     15        18        7            8           7m
    $ kubectl get rs
    NAME                          DESIRED   CURRENT   READY     AGE
    nginx-deployment-1989198191   7         7         0         7m
    nginx-deployment-618515232    11        11        11        7m

###### 暂停和恢复 Deployment
可以在触发一次或多次更新前暂停一个 Deployment, 然后再恢复它. 这样就能多次暂停和恢复 Deployment, 在此期间进行一些修复工作, 而不会触发不必要的 rollout.

Deployment 暂停前的初始状态将继续他的功能, 而不会对 Deployment 的更新产生任何影响, 主要 Deployment 是暂停的.

**注意** : 在恢复 Deployment 之前, **无法回退**一个暂停了的 Deployment.

    # 查看刚创阿金的 Deployment
    $ kubectl get deploy
    $ kubectl get rs

    # 暂停 Deployment
    $ kubectl rollout pause deployment/nginx-deployment

    # 更新 Deployment 中的镜像, 新的 rollout 启动了
    $ kubectl set image deploy/nginx nginx=nginx:1.9.1 
    $ kubectl rollout history deploy/nginx
    $ kubectl get rs

    # 可以进行任意多次更新, 如更新使用的资源
    $ kubectl set resources deployment nginx -c=nginx --limits=cpu=200m,memory=512Mi

    # 恢复暂停的 Deployment
    $ kubectl rollout resume deploy nginx

    # 查看 最新状态
    $ kubectl get rs -w
    $ kubectl get rs


##### Deployment 状态
###### Progressing Deployment

可以使用 `kubectl rollout status` 监控 Deployment 的进度.

Kubernetes 将执行过下列任务之一的 Deployment 标记为 progressing 状态.

- Deployment 正在创建新的 ReplicaSet 过程中
- Deployment 正在扩容一个已有的 ReplicaSet.
- Deployment 正在速溶一个已有的 ReplicaSet.

###### Complete Deployment
Kubernetes 将包括以下特定的 Deployment 标记为 complete 状态:
- Deployment 最小可用. 最小可用意味着 Deployment 的可用 replica 个数等于或者超多 Deployment 策略中的期望个数.
- 所有与该 Deployment 相关的 replica 都被更新到指定版本, 也即更新完成.
- 该 Deployment 中没有旧的 Pod 的存在.

可以用 `kubectl rollout status` 命令查看 Deployment 是否完成, 如果 rollout 成功完成, `kubectl rollout status` 将返回一个 0 值的 exit code.
    
    $ kubectl rollout status deploy/nginx

###### Failed Deployment
Deployment 在尝试部署新的 ReplicaSet 的时候可能卡住, 也不会完成. 这可能是因为以下因素导致的:
- 无效的引用
- 不可读的 probe failure
- 镜像拉去错误
- 权限不够
- 范围限制
- 程序运行时配置错误

探测这种情况的一种方式是, 在 Deployment spec 中指定 `.spec.progressDeadlineSeconds`.  `.spec.progressDeadlineSeconds` 表示 Deployment controllers 等待多少秒才能确定(通过 Deployment status) Deployment 进程是卡住的.

    # 设置 progressDeadlineSeconds 使得 controller 在 Deployment 在进度卡住 10 分钟后报告
    $ kubectl patch deployment/nginx-deployment -p '{"spec":{"progressDeadlineSeconds": 600}}'

当超过截止时间后, Deployment controllers 会在 Deployment 的 `status.conditions` 中增加一条 DeploymentCondition , 它包含如下属性:
- Type=Progressing
- Status=False
- Reason=ProgressDeadlineExeceeded

**注意**: kubernetes 除了报告 `Reason=ProgressDeadlineExeceeded` 状态信息外不会对卡住的 Deployment 做任何操作. 更高层次的协调器可以利用它并采取相应行动, 例如, 回滚 Deployment 到之前的版本.

**注意**: 在暂停的 Deployment 中, Kubernetes 不会检查指定的 deadline. 可以在 Deployment 的 rollout 途中安全的暂停它, 然后在恢复, 这不会触发超过 deadline 的状态.


###### 操作失败的 Deployment
所有对完成的 Deployment 的操作都适用于失败的 Deployment , 可以对他括/缩容, 回退到历史版本, 甚至多次暂停它来应用 Deployment pod template.

###### 清理 Policy
设置 Deployment 中的 `spec.revisionHistoryLimit` 项来指定保留多少旧的 ReplicaSet. 余下的就在后台被当做垃圾收集.

默认所有 revision 历史都会被保留, 未来的版本会改为 2 .

**注意**: 将 `spec.revisionHistoryLimit` 设置为 0 , 将导致所有 Deployment 的历史记录都会被清除. 该 Deployment 无法回退.


##### 使用示例
###### [金丝雀 Deployment](https://github.com/kubernetes/kubernetes.github.io/blob/master/docs/concepts/cluster-administration/manage-deployment.md#canary-deployments)
如果想要使用 Deployment 对部分用户或服务器发布 release, 可以创建多个 Deployment , 每个对一个 release.

###### 编写 Deployment Spec

Deployment 也需要 `apiVersion`, `kind`, `metadata`, `spec` 这些配置项. 

1. Pod Template
    
    `.spec.template` 是 `.spec` 中唯一要求的字段. 它是 **Pod template** , 它跟 Pod 有一模一样的 schema, 除了他是嵌套的, 并且不需要 `apiVersion` 和 `kind` 字段.

    另外, 为了划分 Pod 的范围, Deployment 中的 pod template 必须制定适当的 label (不要跟其他 controllers 重复了) 和适当的重启策略.

    `.spec.template.spec.restartPolicy` 可以设为 `Always` , 如果不只定的话, 这就是默认设置.

2. Replicas
    
    `.spec.replicas` 可选字段, 指定期望的 Pod 数量, 默认是 1.

3. Selector
    
    `.spec.selector` 可选字段, 用来指定 label selector, 圈定 Deployment 管理的 Pod 范围.

    如果被指定, `.spec.selector` 必须匹配 `.spec.template.metadata.labels`, 否则, 将被 API 拒绝. 

    如果没有指定, `.spec.selector.matchLabels` 默认是 `.spec.template.metadata.labels`

    在 Pod 的 template 跟 `.spec.template` 不同或者数量超过了 `.spec.replicas` 规定的数量的情况下, Deployment 会杀掉 label 跟 selector 不同的 Pod.

    **注意**: 不应该再创建其他 label 跟这个 selector 匹配的 pod, 或者通过其他 Deployment, 或者通过其他 Controller, 如 ReplicaSet 和 ReplicationController. 否则 该 Deployment 会把他们都当成自己创建的.

    **注意**: 如果有多个 controllers 使用了重复的 selector, controllers 们可能会相互冲突, 并导致不正确的行为.

4. 策略
    
    `.spec.strategy` 指定新的 Pod 替换 旧的 Pod 的策略. 
    `.spec.strategy.type` 可以是 `Recreate` 或 `RollingUpdate`. 其中 `RollingUpdate` 是默认值.

    - `.spec.strategy.type=Recreate`: 在创建新的 Pod 之前会先杀掉所有已存在的 Pod.
    
    - `.spec.strategy.type=RollingUpdate`: Deployment 使用 rolling update 的方式更新 Pod, 可以指定 `maxUnavailable` 和 `maxSurge` 来控制 rolling update 进程, 这两个值不能同时为 0.

        - `.spec.strategy.rollingupdate.maxUnavailable`

            可选配置, 用来指定在升级过程中, 不可用 Pod 的最大数量值.

            该值可以为一个绝对数值(如 5), 也可以是期望 Pod 数量的百分比(如 10%), 通过计算百分比的绝对值向下取整.

            如果 `.spec.strategy.rollingupdate.maxSurge` 为 0 时, 该值 不能为 0.

            默认值为  1.

        - `.spec.strategy.rollingupdate.maxSurge`

            可选配置, 用来指定超过期望的 Pod 数量的最大个数. 

            该值可以为一个绝对数值(如 5), 也可以是期望 Pod 数量的百分比(如 10%), 通过计算百分比的绝对值向下取整.

            如果 `.spec.strategy.rollingupdate.maxUnavailable` 为 0 时, 该值 不能为 0.

            默认值为  1.

5. Progress Deadline Seconds
    
    `.spec.progressDeadlineSeconds` 可选配置, 用来指定在系统报告 Deployment failed progressing -- 表现为 resources 的状态中的 `type=Progressing`, `status=False`, `Reason=ProgressDeadlineExceeded` 前可以等待的 Deployment 进行的秒数 .Deployment controllers 会继续重试该 Deployment.

    如果设置该参数, 该值必须**大于** `.spec.minReadySeconds`

6. Min Ready Seconds
    
    `.spec.minReadySeconds` 可选配置, 用来指定没有任何容器 crash 的 Pod 并被认为是可用状态的最小秒数, 默认为 0.

7. Rollback To
    
    `.spec.rollbackTo` 可选配置, 用来配置 Deployment 回退的配置. 设置该参数将触发回退操作, 每次回退完成后, 该值就会被清除.

    `.spec.rollbackTo.revision` 可选配置, 用来指定回退到的 revision, 默认为 0, 即回退到历史中最老的 revision.

8. Revision History Limit
    
    Deployment revision history 存储在他控制的 ReplicaSets 中.

    `.spec.revisionHistoryLimit` 可选配置, 用来指定可以保留的旧的 ReplicaSet 数量.

    该理想值取决于 Deployment 的频率和稳定性. 如果该值没有设置的话, 默认所有旧的 ReplicaSet 都会被保留, 将资源存储在 etcd 中

    每个 Deployment 的该配置都保存在 ReplicaSet 中, 一旦删除旧的 ReplicaSet , 则 Deployment 就再也无法回退到该 revision.

    如果设置为 0 , 则 ReplicaSet 无法回退.

9. Paused
    
    `.spec.paused` 是可选配置, boolean 值. 用来指定暂停和恢复 Deployment. 

    Deployment 被创建之后, 默认是 非 paused.

    Paused 和 没有 Paused 的 Deployment 之间唯一的区别就是, 所有对 Paused Deployment 中的 PodTemplateSpec 的修改都不会触发新的 rollout.

#### Secret
Secret 解决了密码, token, 密钥等敏感数据的配置问题, 而无需把这些敏感数据暴露到镜像或 Pod Spec 中.

Secret 可以以 Volume 或者环境变量的方式使用.

##### 类型
###### 1. Service Account : 
    
用来访问 Kubernetes API, 有 Kubernetes 自动创建, 并且会挂载到 Pod 的 `/run/secrets/kubernetes.io/serviceaccount` 目录中.

    $ kubectl run nginx --image nginx
    $ kubectl get pods
    $ kubectl exec  nginx_POD_ID ls /run/secrets/kubernetes.io/serviceaccount
      ca.crt
      namespace
      token

###### 2. Opaque : 

base64 编码格式的 secrets, 用来存储密码, 密钥等.

**创建**
Opaque 类型是一个 map 类型, 要求 value 是 base64 编码格式.

    $ echo -n 'admin' | base64 
      YWRtaW4=
    $ echo -n "123456" | base64 
      MTIzNDU2

    $ cat secrets.yml
      apiVersion: v1
      kind: Secret
      metadata:
        name: mysecret
      type: Opaque
      data:
        password: MTIzNDU2
        username: YWRtaW4=

    # 创建 secrets
    $ kubectl create -f secrets.yml

如果是从文件创建  secrets, 则可以用更简单的 kubectl 命令:

    # 创建 tls 的 secret
    $ kubectl create secret generic helloworld-tls --from-file=key.pem --from-file=cert.pem

**使用**:

1. 以 Volume 方式: 将 Secret 挂载到 Volume 中.
    
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            name: db
          name: db
        spec:
          volumes:
          - name: secrets
            secret: 
              secretName: mysecret
          container:
          - image: gcr.io/my_project_id/pg:v1
            name: db
            volumeMounts:
            - name: secrets
              mountPath: "/etc/secrets"
              readOnly: true
            ports:
            - name: cp
              containerPort: 5432
              hostPort: 5432

2. 以环境变量方式: 将 secret 导出到环境变量中

        apiVersion: extensions/v1beta1
        kind: Deployment
        metadata:
          name: wordpress-deployment
        spec:
          replicas: 2
          strategy:
            type: RollingUpdate
          template:
            metadata:
              labels:
                app: wordpress
                visualize: "true"
            spec:
              container:
              - name: "wordpress"
                images: "wordpress"
                ports:
                - containerPort: 80
                env: 
                  - name: WORDPRESS_DB_USER
                    valueFrom:
                      secretKeyRef:
                        name: mysecret
                        key: username
                  - name: WORDPRESS_DB_PASSWORD
                    valueFrom:
                      secretKeyRef:
                        name: mysecret
                        key: password

###### 3. kubernetes.io/dockerconfigjson : 
    
用来存储私有 docker Registry 的认证信息.

**创建**

    # 直接用 kubectl 命令来创建用于 docker Registry 认证的 secret
    $ kubectl create secret docker-registrty myregistrykey --docker-server=DOCKER_REGISTRY_SERVER --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL

    # 直接读取 `~/.dockercfg` 内容来创建
    $ kubectl create secret docker-registry myregistrykey --from-file="~/.dockercfg"

**使用**: 在创建 Pod 时, 通过 `imagePullSecrets` 来引用`myregistrykey`

    apiVersion: v1
    kind: Pod
    metadata:
      name: foo
    spec:
      containers:
        - name: foo
          image: janedoe/awesomeapp:v1
      imagePullSecrets:
        - name: myregistrykey

#### StatefulSet
StatefulSet 为了解决**有状态服务**的问题(对应 Deployment 和 ReplicaSets 为无状态服务设计).

##### 1. 应用场景

- 稳定的持久化存储, 
    
    即 Pod 重新调度后还是能访问到相同的持久化数据, 基于 PVC 来实现.
- 稳定的网络标志, 
    
    即 Pod 重新调度后其 PodName 和 HostName 不变, 基于 Headleass Service(没有 Cluster IP 的 Service) 来实现.

- 有序部署, 有序扩展
    
    即 Pod 是有顺序的, 在部署或者扩展的时候要依据定义的顺序依次进行(即 从 0 到 N-1, 在下一个 Pod 运行之前所有之前的 Pod 必须都是 Running 和 Ready 状态), 基于 init container 实现.

- 有序收缩, 有序删除(即 从 N-1 到 0)

StatefulSet 由一下几个部分组成:
1. 用于定义网络标志(DNS domain)的 Headless Service.
2. 用于创建 PersistnetVolumes 的 volumeClaimTemplates
3. 定于具体应用的 StatefulSet

StatefulSet 中每个 Pod 的 DNS 格式为 `statefulSetName-{0..N-1}.serviceName.namespace.svc.cluster.local`, 其中:
- `serviceName` 为 Headless Service的名字
- `0..N-1` 为 Pod 所在的序号, 从 0 开始到 N-1
- `statefulSetName` 为 StatefulSet 的名字
- `namespace` 为服务所在的 namespace, Headless Service 和 StatefulSet 必须在相同的 namespace.
- `.cluster.local` 为 Cluster Domain.

##### 2. 示例
示例1 : nginx 服务
    $ cat web.yml
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      ports:
      - port: 80
        name: web
      clusterIP: None
      selector:
        app: nginx

    ---
    apiVersion: apps/v1beta1
    kind: StatefulSet
    metadata:
      name: web
    spec:
      serviceName: "nginx"
      replicas: 2
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            images: gcr.io/google_containers/nginx-slim:0.8
            ports:
            - containerPort: 80
              name: web
            volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
      volumeClaimTemplates:
      - metadata:
          name: www
          annotations:
            volume.alpha.kubernetes.io/storage-class: anything
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 1Gi

    $ kubectl create -f web.yml

    # 查看创建的 headless service 和 statefulset
    $ kubectl get service nginx
    $ kubectl get statefulset web

    # 根据 volumeClaimTemplates 自动创建 PVC (在 GCE 中会自动创建 kubernetes.io/gce-pd 类型的 volume)
    $ kubectl get pvc

    # 查看创建的  pod, 他们都是有序的.
    $ kubectl get pods -l app=nginx

    # 使用 nslookup 查看 Pod 的 DNS
    $ kubectl run -t --tty --image busybox dns-test --restart=Never --rm /bin/bash

        $ nslookup web-0.nginx
        $ nslookup web-1.nginx

    # 扩容
    $ kubectl scale statefulset web --replicas=5

    # 缩容
    $ kubectl patch statefulset web -p '{"spec": {"replicas": 3}}'

    # 镜像更新(目前不支持直接更新 image, 需要 patch 来间接实现)
    $ kubectl patch statefulset web --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"gcr.io/google_containers/nginx-slim:0.7"}]'

    # 删除 StatefulSet 和 Headless Service
    $ kubectl delete statefulset web
    $ kubectl delete service nginx

    # 删除不在使用的 PVC
    $ kubectl delete pvc www-web-0 www-web-1

示例2 : [zookeeper 服务](https://kubernetes.io/docs/tutorials/stateful-application/zookeeper/)
    
    $ cat zookeeper.yml
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: zk-headless
      labels:
        app: zk-headless
    spec:
      ports:
      - port: 2888
        name: server
      - port: 3888
        name: leader-election
      clusterIP: None
      selector:
        app: zk
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: zk-config
    data:
      ensemble: "zk-0;zk-1;zk-2"
      jvm.heap: "2G"
      tick: "2000"
      init: "10"
      sync: "5"
      client.cnxns: "60"
      snap.retain: "3"
      purge.interval: "1"
    ---
    apiVersion: policy/v1beta1
    kind: PodDisruptionBudget
    metadata:
      name: zk-budget
    spec:
      selector:
        matchLabels:
          app: zk
      minAvailable: 2
    ---
    apiVersion: apps/v1beta1
    kind: StatefulSet
    metadata:
      name: zk
    spec:
      serviceName: zk-headless
      replicas: 3
      template:
        metadata:
          labels:
            app: zk
          annotations:
            pod.alpha.kubernetes.io/initialized: "true"
            scheduler.alpha.kubernetes.io/affinity: >
                {
                  "podAntiAffinity": {
                    "requiredDuringSchedulingRequiredDuringExecution": [{
                      "labelSelector": {
                        "matchExpressions": [{
                          "key": "app",
                          "operator": "In",
                          "values": ["zk-headless"]
                        }]
                      },
                      "topologyKey": "kubernetes.io/hostname"
                    }]
                  }
                }
        spec:
          containers:
          - name: k8szk
            imagePullPolicy: Always
            image: gcr.io/google_samples/k8szk:v1
            resources:
              requests:
                memory: "4Gi"
                cpu: "1"
            ports:
            - containerPort: 2181
              name: client
            - containerPort: 2888
              name: server
            - containerPort: 3888
              name: leader-election
            env:
            - name : ZK_ENSEMBLE
              valueFrom:
                configMapKeyRef:
                  name: zk-config
                  key: ensemble
            - name : ZK_HEAP_SIZE
              valueFrom:
                configMapKeyRef:
                    name: zk-config
                    key: jvm.heap
            - name : ZK_TICK_TIME
              valueFrom:
                configMapKeyRef:
                    name: zk-config
                    key: tick
            - name : ZK_INIT_LIMIT
              valueFrom:
                configMapKeyRef:
                    name: zk-config
                    key: init
            - name : ZK_SYNC_LIMIT
              valueFrom:
                configMapKeyRef:
                    name: zk-config
                    key: tick
            - name : ZK_MAX_CLIENT_CNXNS
              valueFrom:
                configMapKeyRef:
                    name: zk-config
                    key: client.cnxns
            - name: ZK_SNAP_RETAIN_COUNT
              valueFrom:
                configMapKeyRef:
                    name: zk-config
                    key: snap.retain
            - name: ZK_PURGE_INTERVAL
              valueFrom:
                configMapKeyRef:
                    name: zk-config
                    key: purge.interval
            - name: ZK_CLIENT_PORT
              value: "2181"
            - name: ZK_SERVER_PORT
              value: "2888"
            - name: ZK_ELECTION_PORT
              value: "3888"
            command:
            - sh
            - -c
            - zkGenConfig.sh && zkServer.sh start-foreground
            readinessProbe:
              exec:
                command:
                - "zkOk.sh"                
              initialDelaySeconds: 15
              timeoutSeconds: 5
            livenessProbe:
              exec:
                command:
                - "zkOk.sh"
              initialDelaySeconds: 15
              timeoutSeconds: 5
            volumeMounts:
            - name: datadir
              mountPath: /var/lib/zookeeper
          securityContext:
            runAsUser: 1000
            fsGroup: 1000
      volumeClaimTemplates:
      - metadata:
          name: datadir
          annotations:
            volume.alpha.kubernetes.io/storage-class: anything
        spec:
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: 20Gi

    $ kubectl create -f zookeeper.yml

##### 3. 注意事项  
1. 还在beta状态, 需要kubernetes v1.5版本以上才支持
2. 所有Pod的Volume必须使用PersistentVolume或者是管理员事先创建好
3. 为了保证数据安全, 删除StatefulSet时不会删除Volume
4. StatefulSet需要一个Headless Service来定义DNS domain, 需要在StatefulSet之前创建好
5. 目前StatefulSet还没有feature complete, 比如更新操作还需要手动patch

#### DaemonSet
DaemonSet 保证在每个 Node 上都运行一个容器副本, 常用来部署一些集群的日志, 监控, 或者其他系统管理应用. 

##### 使用场景
典型应用包括:

- 日志收集, 如 fluentd, logstash 等.
- 系统监控, 如 Prometheus Node Exporter, collectd, New Relic agent, Ganglia gmond 等. 
- 系统程序, 如 kube-proxy, kube-dns, glusterd, ceph.

##### 示例 : 使用 Fluentd 收集日志
    apiVersion: extensions/v1beta1
    kind: DaemonSet
    metadata:
      name: fluentd
    spec:
      template:
        metadata:
          labels:
            app: logging
            id: fluentd
            name: fluentd
        spec:
          containers:
          - name: fluentd-es
            image: gcr.io/google_containers/fluentd-elasticsearch:1.3
            env:
              - name: FLUENT_ARGS
                value: -qq
            volumeMounts:
              - name: containers
                mountPath: /var/lib/docker/containers
              - name: varlog
                mountPath: /varlog
          volumes:
            - hostPath:
                path: /var/lib/docker/containers
              name: containers
            - hostPath:
                path: /var/log
              name: varlog
##### 指定 Node 节点
DaemonSet 会忽略 Node 的 unschedulable 状态, 有两种方式来指定 Pod 只运行在指定的 Node 节点上:

###### `nodeSelector` : 只调度到匹配指定 label 的 Node上.
    
    # 给 Node 打标签
    $ kubectl label nodes node-01 disktype=ssd

    # 在 daemonset 中指定 nodeSelector 为 disktype=ssd

        spec: 
          nodeSelector:
            disktype: ssd

###### `nodeAffinity` : 功能更丰富的 Node 选择器, 支持集合操作

nodeAffinity 支持两种选择条件:
- `requiredDuringSchedulingIgnoredDuringExecution` : 代表必须满足条件
- `preferredDuringSchedulingIgnoredDuringExecution` : 优选条件.

示例: 调度 Pod 到包含标签`kubernetes.io/e2e-as-name` 并且值为 `e2e-az1` 或 `e2e-az2` 的 Node, 并且优选带有标签 `another-node-label-key=another-node-label-value` 的 Node.

    apiVersion: v1
    kind: Pod
    metadata:
      name: with-node-affinity
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/e2e-az-name
                operator: In
                values:
                - e2e-az1
                - e2e-az2
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: another-node-label-key
                operator: In
                values:
                - another-node-label-value
      containers:
      - name: with-node-affinity
        image: gcr.io/google_containers/pause:2.0

###### `podAffinity` : 调度到满足条件的 Pod 所在的 Node 上.
`podAffinity` 基于 Pod 的标签来选择 Node, 仅调度到满足条件 Pod 所在的 Node 上, 支持 `podAffinity` 和 `podAntiAffinity`.

示例: 
如果一个Node 所在的 Zone 中包含至少一个带有 `security=s1` 标签且运行中的 pod, 那么调度到该 Pod;
不调度到'包含至少一个带有 security=s2 标签且运行中的 Pod' 的 Node 上.

    apiVersion: v1
    kind: Pod
    metadata:
      name: with-pod-affinity
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: security
                operator: In
                values:
                - S1
            topologyKey: failure-domain.beta.kubernetes.io/zone
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: security
                  operator: In
                  values:
                  - S2
              topologyKey: kubernetes.io/hostname
      containers:
      - name: with-pod-affinity
        image: gcr.io/google_containers/pause:2.0

##### 静态 Pod
可以使用静态 Pod 来在每台机器上运行指定的 Pod, 需要 kubelet 在启动的时候指定 manifest 目录:
    
    $ kubelet --pod-manifest-path=/etc/kubernetes/manifests

然后将所需要的 Pod 定义文件放到指定的 manifests 目录中.

**静态 Pod 不能通过 API Service 来删除, 但可以通过删除 manifests 文件来自动删除对应的 Pod**

#### ServiceAccount
ServiceAccount 是为了方便 Pod 里面的进程调用 Kubernetes API 或 其他外部服务而设计的. 它与 UserAccount 不同:
1. User Account 是为人设计的, 而 ServiceAccount 是为 Pod 中的进程调用 Kubernetes API 而设计的(类似于 AWS AMI ROLE 的概念).
2. UsersAccount 的跨 namespace 的, 而 ServiceAccount 则是仅局限于它所在的 namespace.
3. 每个 namespace 都会自动创建一个 default service account .
4. Token controller 检测 service account 的创建, 并为他们创还能 secret.
5. 开始 ServiceAccount Admission Controller 后:
    - 每个 Pod 在创建后都会自动设置 `spec.serviceAccount` 为 default, 除非指定了其他 ServiceAccount.
    - 验证 Pod 引用的 ServiceAccount 已经存在, 否则拒绝创建.
    - 如果 Pod 没有指定 ImagePullSecrets , 则把 ServiceAccount 的 ImagePullSecrets 加到 Pod 中.
    - 每个 container 启动后, 都会挂载 ServiceAccount 的 `token` 和 `ca.crt` 到 `/var/run/secrets/kubernetes.io/serviceaccount/`

            $ kubectl exec nginx-3137573019-md1u2 ls /var/run/secrets/kubernetes.io/serviceaccount/

##### 创建 ServiceAccount
    
    # 创建 ServiceAccount
    $ kubectl create serviceaccount jenkins

    # 查看 serviceAccount 配置信息
    $ kubectl get serviceaccounts jenkins -o yaml

##### 授权
Service Account 为服务提供了一种方便的认证机制, 但它不关心授权的问题. 可以配合 RBAC 来为 Service Account 鉴权:

- 配置 `--authorization-mode=RBAC` 和 `--runtime-config=rbac.authorization.k8s.io/v1alpha1`
- 配置 `--authorization-rbac-super-user=admin`
- 定义 Role, ClusterRole, RoleBinding 或 ClusterRoleBinding 

        # This role allows to read pods in the namespace "default"
        kind: Role
        apiVersion: rbac.authorization.k8s.io/v1alpha1
        metadata:
          namespace: default
          name: pod-reader
        rules:
          - apiGroups: [""] # The API group "" indicates the core API Group.
            resources: ["pods"]
            verbs: ["get", "watch", "list"]
            nonResourceURLs: []

        --- 

        # This role binding allows "default" to read pods in the namespace "default"
        kind: RoleBinding
        apiVersion: rbac.authorization.k8s.io/v1alpha1
        metadata:
          name: read-pods
          namespace: default
        subjects:
          - kind: ServiceAccount # May be "User", "Group" or "ServiceAccount"
            name: default
        roleRef:
          kind: Role
          name: pod-reader
          apiGroup: rbac.authorization.k8s.io

#### ReplicationController和ReplicaSet
ReplicationController (简称 RC) 用来确保容器应用的副本数始终保持在用户定义的副本数, 即如果有容器异常退出, 会自动创建新的 Pod 来替代; 而异常多出来的容器也会自动回收.

ReplicationController 的典型应用场景包括确保健康的 Pod 的数量, 弹性伸缩, 滚动升级以及应用多版本发布跟踪等.

ReplicaSet (简称 RS) : 新版本 k8s 中建议使用 ReplicaSet 来取代 ReplicationController . ReplicaSet 跟 ReplicationController 没有本质的不同, 只是名字不一样, 并且 ReplicaSet 支持集合式的 selector (ReplicationController 仅支持等式).

虽然 ReplicaSet 可以独立使用, 但建议使用 Deployment 来自动管理 ReplicaSet, 这样就无需担心跟其他机制的不兼容问题(如 ReplicaSet 不支持 rolling-update 但 Deployment 支持), 并且还支持版本记录, 回滚, 暂停升级等高级特性.
    
    # Replication Controller 示例
    apiVersion: v1
    kind: ReplicationController
    metadata:
      name: nginx
    spec:
      replicas: 3
      selector:
        app: nginx
      template:
        metadata:
          name: nginx
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx
            ports:
            - containerPort: 80


    # ReplicaSet 示例
    apiVersion: extensions/v1beta1
    kind: ReplicaSet
    metadata:
      name: frontend
      # these labels can be applied automatically
      # from the labels in the pod template if not set
      # labels:
        # app: guestbook
        # tier: frontend
    spec:
      # this replicas value is default
      # modify it according to your case
      replicas: 3
      # selector can be applied automatically
      # from the labels in the pod template if not set,
      # but we are specifying the selector here to
      # demonstrate its usage.
      selector:
        matchLabels:
          tier: frontend
        matchExpressions:
          - {key: tier, operator: In, values: [frontend]}
      template:
        metadata:
          labels:
            app: guestbook
            tier: frontend
        spec:
          containers:
          - name: php-redis
            image: gcr.io/google_samples/gb-frontend:v3
            resources:
              requests:
                cpu: 100m
                memory: 100Mi
            env:
            - name: GET_HOSTS_FROM
              value: dns
              # If your cluster config does not include a dns service, then to
              # instead access environment variables to find service host
              # info, comment out the 'value: dns' line above, and uncomment the
              # line below.
              # value: env
            ports:
            - containerPort: 80        

#### Job
Job 负责批处理短暂的一次性任务(short lived one-off tasks). 它保证批处理任务的一个或多个 Pod 成功结束.

Kubernetes 支持一下集中 Job:
- 非并行 Job : 通常创建一个 Pod 直至其成功结束.
- 固定结束次数的 Job : 设置 `.spec.completions` 创建多个 Pod, 直到 `.spec.completions` 个 Pod 成功结束.
- 带有工作队列的并行 Job : 设置 `.spec.Parallelism` 但不设置 `.spec.completions`, 当所有 Pod 结束并且至少一个成功时, Job 就认为是成功的.

根据 `.spec.completions` 和 `.spec.Parallelism` 的设置, 可以将 Job 划分为以下几种 pattern :

| Job 类型 | 使用示例 | 行为 | completionis | Parallelism | 
| --- | --- | --- | --- | --- |
| 一次性 Job | 数据库迁移 | 创建一个 Pod 直至其成功结束 | 1 | 1 |
| 固定结束次数的 Job | 处理工作队列的 Pod | 依次创建一个 Pod 运行直至 completions 个 成功结束 | 2+ | 1 |
| 固定结束次数的并行 Job | 多个 Pod 同时处理工作队列 | 依次创阿金多个 Pod 运行, 直至 completions 个成功结束 | 2+ | 2+ |
| 并行 Job | 多个 Pod 同时处理工作队列| 创建一个或多个 Pod 直至有一个成功结束 | 1 | 2+ |

##### Job Controller
Job Controller 负责根据 Job Spec 创建 Pod, 并持续监控 Pod 的窗台, 直至其成功结束. 如果失败, 则根据 restartPolicy (只支持 OnFailure , Never, 不支持 Always) 决定是否创建新的 Pod 再次重新任务.

![job arch](http://oluv2yxz6.bkt.clouddn.com/job.png)

##### Job spec
- `spec.template` 格式同 Pod
- `RestartPolicy` 仅支持 `Never` 或 `OnFailure`
- 单个 Pod 时, 默认 Pod 成功运行后 Job 即结束
- `.spec.completions` 表示 Job 结束需要成功运行的 Pod 个数, 默认为 1
- `.spec.parallelism` 标志并行运行的 Pod 的个数, 默认为 1
- `spec.activeDeadlineSeconds` 标志失败 Pod 的重试最大时间, 超过这个时间不会继续重试.

示例:
    
    $ cat job.yaml
        apiVersion: batch/v1
        kind: Job
        metadata:
          name: pi
        spec:
          template:
            metadata:
              name: pi
            spec:
              containers:
              - name: pi
                image: perl
                command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
              restartPolicy: Never

    $ kubectl create -f ./job.yaml

    $ pods=$(kubectl get pods --selector=job-name=pi --output=jsonpath={.items..metadata.name})
    $ kubectl logs $pods

    # 固定次数的 Job
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: busybox
    spec:
      completions: 3
      template:
        metadata:
          name: busybox
        spec:
          containers:
          - name: busybox
            image: busybox
            command: ["echo", "hello"]
          restartPolicy: Never

##### Bare Pods
所谓 Bare Pods 是指直接用 PodSpec 来创建的 Pod (即不在 ReplicaSets 或者 ReplicationController 的管理之下的 Pods). 这些 Pod 在 Node 重启后不会自动重启, 但 Job 则会创建新的 Pod 继续任务. 所以, 推荐使用 Job 来代替 Bare Pods, 即便是应用只需要一个 Pod.

#### CronJob

CronJob 即定时任务, 类似 Linux 系统的 crontab, 在指定的时间周期运行指定的任务. 在 Kubernetes 1.5 , 使用 CronJob 需要开启 `batch/v2alpha1` API, 即 `--runtime-config=batch/v2alpha1`.

##### CronJob Spec
- `.spec.schedule` 指定任务运行周期, 格式同 [Cron](https://en.wikipedia.org/wiki/Cron)
- `.spec.jobTemplate` 执行需要运行的任务, 格式同 Job
- `.spec.startingDeadlineSeconds` 指定任务开始的截止期限.
- `.spec.concurrencyPolicy` 指定任务的并发策略, 支持 `Allow`,`Forbid`,`Replace` 三个选项.

示例:
    $ cat cronjob.yaml

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
                args:
                - /bin/sh
                - -c
                - date; echo Hello from the Kubernetes cluster
              restartPolicy: OnFailure

    $ kubectl create -f cronjob.yaml

    # 使用 'kubectl run' 来创建一个 CronJob
    $ kubectl run hello --schedule="*/1 * * * *" --restrart=OnFailure --image=busybox -- /bin/sh -c "date ; echo Hello from the k8s cluster"

    $ kubectl get cronjob
    $ kubectl get jobs
    $ pods=$(kubectl get pods --selector=job-name=hello-1202039034 --output=jsonpath={.items..metadata.name} -a)
    $ kubectl logs $pods

    # 注意 : 删除 CronJob 的时候, 不会自动删除 job, 这些 job 可以用 'kubectl delete cronjob' 来删除
    $ kubectl delete cronjob hello

#### SecurityContext

Security Context 的目的是限制不可信容器的行为, 保护系统和其他容器不受其影响.

Kubernetes 提供了三种配置 Security Context 的方法:

- `Container-level Security Context` : 仅应用到指定的容器, 并且不会影响 volume.
    
        # 设置容器运行在特权模式
        apiVersion: v1
        kind: Pod
        metadata:
          name: hello-world
        spec:
          containers:
            - name: hello-world-container
              # The container definition
              # ...
              securityContext:
                privileged: true    

- `Pod-level Security Context` : 应用到 Pod 内所有容器以及 Volume, (包括 fsGroup 和 selinuxOptions)
        
        apiVersion: v1
        kind: Pod
        metadata:
          name: hello-world
        spec:
          containers:
          # specification of the pod's containers
          # ...
          securityContext:
            fsGroup: 1234
            supplementalGroups: [5678]
            seLinuxOptions:
              level: "s0:c123,c456"      

- `Pod Security Policies (PSP)` : 应用到集群内部所有 Pod 以及 Volume 
    
    Pod Security Policies (PSP) 是集群级的 Pod 安全策略, 自动为集群内的 Pod 和 Volume 设置 Security Context.

    使用 PSP 需要 API Server 开启 `extensions/v1beta1/podsecuritypolicy` 并且配置 `PodSecurityPolicy admission` 控制器.

支持的控制项

| 控制项 | 说明 | 
| --- | --- |
| privileged | 添加特权容器 |
| defaultAddCapabilities | 可添加到容器的 Capabilities |
| requiredDropCapalibities | 会从容器中删除的 Capabilities |
| volumes | 控制容器可以使用哪些 volume |
| hostNetwork | host 网络 |
| hostPorts | 允许的 host 端口列表 |
| hostPID | 使用 host PID namespace |
| hostIPC | 使用 host IPC namespace |
| seLinux | SELinux Context |
| runAsUser | user ID |
| supplementalGroups | 允许的补充用户组 |
| fsGroup | volume FSGroup |
| readOnlyRootFilesystem | 只读根文件系统 |

示例: 限制容器的 host 端口范围为 8000 - 8080 .

    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: permissive
    spec:
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: RunAsAny
      hostPorts:
      - min: 8000
        max: 8080
      volumes:
      - '*'

#### Resource Quota
Resource Quote (资源配额) 是用来限制用户资源用量的一种机制. 其**工作原理**如下:
1. 资源配额应用在 Namespace 上, 并且每个 Namespace 最多只能有一个 `ResourceQuote` 对象.
2. 开启计算资源配额后, 创建容器时必须配置计算资源请求或限制, 也可以用 LimitRange 设置默认值.
3. 用户超额后禁止创建新的资源.

##### 资源配额开启
1. 在 API Server 启动时配置 `ResourceQuota adminssion control`
2. 在 namespace 中创建 `ResourceQuote` 对象即可.

##### 资源配额的类型与范围
**类型** :

1. 计算资源 : 包括 CPU 和 memory
    
    - CPU : `limits.cpu`, `requests.cpu`
    - memory : `limits.memory`, `requests.memory`

    示例:

        apiVersion: v1
        kind: ResourceQuota
        metadata:
          name: compute-resources
        spec:
          hard:
            pods: "4"
            requests.cpu: "1"
            requests.memory: 1Gi
            limits.cpu: "2"
            limits.memory: 2Gi    

2. 存储资源 : 包括存储资源的总量以及指定 storage classs 的总量.
    
    - `requests.storage`
    - `persistentvolumeclaims`
    - `.storageclass.storage.k8s.io/requests.storage`
    - `.storageclass.storage.k8s.io/persistentvolumeclaims`

3. 对象数 : 即可创建的对象的个数.
    
    - `pods`, `replicationcontrollers`, 'configmaps', 'secrets'
    - `resourcequotes`, `persistentvolumeclaims`
    - `services`, `services.loadbalancers`, 'servuces.nodeports'
    
    示例:

        apiVersion: v1
        kind: ResourceQuota
        metadata:
          name: object-counts
        spec:
          hard:
            configmaps: "10"
            persistentvolumeclaims: "4"
            replicationcontrollers: "20"
            secrets: "10"
            services: "10"
            services.loadbalancers: "2"

**范围** :

| 范围 | 说明 |
| --- | --- |
| Terminating | `podSpec.ActiveDeadlineSeconds >= 0` 的 Pod |
| NotTerminating | `podSpec.ActiveDeadlineSeconds=nil` 的 Pod |
| BestEffort | 所有容器的 `requests` 和 `limits` 都没有设置的 Pod (Best-Effort) |
| NotBestEffort | 与`BestEffort` 相反 |

##### LimitRange
默认情况下, kubernetes 中所有容器都没有 CPU 和内存限制.
LimitRange 用来给 Namespace 增加一个资源限制, 包括最小, 最大 和 默认资源.
    
    $ cat limits.yaml
    apiVersion: v1
    kind: LimitRange
    metadata:
      name: mylimits
    spec:
      limits:
      - max:
          cpu: "2"
          memory: 1Gi
        min:
          cpu: 200m
          memory: 6Mi
        type: Pod
      - default:
          cpu: 300m
          memory: 200Mi
        defaultRequest:
          cpu: 200m
          memory: 100Mi
        max:
          cpu: "2"
          memory: 1Gi
        min:
          cpu: 100m
          memory: 3Mi
        type: Container

    $ kubectl create -f limits.yaml --namespace=limit-example

    $ kubectl describe limits mylimits --namespace=limit-example

#### Horizontal Pod Autoscaling
Horizontal Pod Autoscaling 可以根据 CPU 使用率或应用自定义 metrics 自动扩展 Pod 数量, 支持 `replication controller`, `deployment` 和 `replica set`.

- 控制管理器每隔 30s (可以通过 `--horizontal-pod-autoscaler-sync-period` 修改) 查询 metrics 资源使用情况.
- 支持三种 metrics 类型:
    - 预定义 `metrics` (如 Pod 的 CPU), 以利用率的方式计算
    - 自定义 `Pod metrics` ,以原始值(raw value) 的方式计算
    - 自定义 `object metries` 
- 支持两种 metrics 查询方式: Heapster 和自定义的 REST API
- 支持多 metrics .

示例:

    # 创建pod和service
    $ kubectl run php-apache --image=gcr.io/google_containers/hpa-example --requests=cpu=200m --expose --port=80

    # 创建autoscaler
    $ kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
    $ kubectl get hpa

    # 增加负载
    $ kubectl run -i --tty load-generator --image=busybox /bin/sh
    $ while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done

    # 过一会就可以看到负载升高了
    $ kubectl get hpa

    # autoscaler将这个deployment扩展为7个pod
    $ kubectl get deployment php-apache

    # 删除刚才创建的负载增加pod后会发现负载降低, 并且pod数量也自动降回1个
    $ kubectl get hpa
    $ kubectl get deployment php-apache

##### 自定义 metrics 
可以参考 k8s.io/metics 开发自定义的metrics API server. 

使用方法:

1. 控制管理器开启 `--horizontal-pod-autoscaler-use-rest-clients`
2. 管理控制器的 `--apiserver` 指向 API Server Aggregator
3. 在 API Server Aggregator 中注册自定义的 metrics API

示例:

    apiVersion: autoscaling/v2alpha1
    kind: HorizontalPodAutoscaler
    metadata:
      name: php-apache
      namespace: default
    spec:
      scaleTargetRef:
        apiVersion: apps/v1beta1
        kind: Deployment
        name: php-apache
      minReplicas: 1
      maxReplicas: 10
      metrics:
      - type: Resource
        resource:
          name: cpu
          targetAverageUtilization: 50
      - type: Pods
        pods:
          metricName: packets-per-second
          targetAverageValue: 1k
      - type: Object
        object:
          metricName: requests-per-second
          target:
            apiVersion: extensions/v1beta1
            kind: Ingress
            name: main-route
          targetValue: 10k
    status:
      observedGeneration: 1
      lastScaleTime: <some-time>
      currentReplicas: 1
      desiredReplicas: 1
      currentMetrics:
      - type: Resource
        resource:
          name: cpu
          currentAverageUtilization: 0
          currentAverageValue: 0

#### Network Policy
Network Policy 提供基于策略的网络控制, 用于隔离应用并减少攻击面. 它使用标签选择器模拟传统的分段网络, 并通过策略控制他们之间的流量以及来自外部的流量.

在使用 Network Policy 之前, 需要注意:
1. apiserver 开启 `extensions/v1beta1/networkpolicies`
2. 网络插件需要支持 Network Policy , 如 Calico, Romana, Weave Net 和 trireme 等

##### 策略
1. Namespace 隔离
    
    默认情况下, 所有 Pod 之前是全通的. 每个 Namespace 可以配置独立的网络策略, 来隔离 Pod 之间的流量. 比如隔离 namespace 的所有 Pod 之间的流量(包括从外部到该 namespace 中所有 pod 的流量以及 namespace 内部 Pod 相互之间的流量).

        $ kubectl annotate ns <namespace>

    目前 Network Policy **仅支持 Ingress 流量控制**

2. Pod 隔离
    
    通过使用标签选择器, 包括 `namespaceSelecrtor` 和 `podSelector` 来控制 Pod 之间的流量.

        # 允许 default namespace 中带有 role=frontend 标签的 Pod 访问 default namespace 中带有 role=db 标签的 pod 的 6379 端口.
        # 允许带有 project=myprojects 标签的namespace中所有Pod访问default namespace中带有 role=db 标签Pod的6379端口

        apiVersion: extensions/v1beta1
        kind: NetworkPolicy
        metadata:
          name: test-network-policy
          namespace: default
        spec:
          podSelector:
            matchLabels:
              role: db
          ingress:
          - from:
            - namespaceSelector:
                matchLabels:
                  project: myproject
            - podSelector:
                matchLabels:
                  role: frontend
            ports:
            - protocol: tcp
              port: 6379

##### 示例 : 以 calico 为例看一下 Network Policy 的具体用法
    
    # 配置 kubectl 使用 CNI 网络插件
    $ kubectl --network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin ...

    # 安装 calico 网络插件
    # 注意修改 CIDR, 需要跟 k8s pod-network-cide 一直, 默认为 192.168.0.0/16
    $ kubectl apply -f http://docs.projectcalico.org/v2.1/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

    # 部署 nginx 服务 用于测试, 此时可以通过其他 Pod 访问 nginx 服务.
    $ kubectl run nginx --image=nginx --replicas=2
    $ kubectl expose deployment nginx --port=80

    # 开启 default namespace 的 DefaultDeny Network Policy 后, 其他 POd 包括 namespace 外部, 就不能访问 nginx 服务了
    $ kubectl annotate ns default

    # 创建一个带有 'access=true' 的 Pod访问的 网络策略
    $ cat nginx-policy.yaml
    kind: NetworkPolicy
    apiVersion: extensions/v1beta1
    metadata:
      name: access-nginx
    spec:
      podSelector:
      matchLabels:
          run: nginx
      ingress:
      - from:
        - podSelector:
            matchLabels:
              access: "true"
    $ kubectl create -f nginx-policy.yaml

    # 带有 `access=true` 标签的 Pod 可以访问 nginx 服务
    $ kubectl run busybox --rm -ti --labels="access=true" --image=busybox /bin/sh
        / # wget --spider --timeout=1 nginx

    # 开启 ngixn 服务的外部访问
    $ cat nginx-external-policy.yaml
        apiVersion: extensions/v1beta1
        kind: NetworkPolicy
        metadata:
          name: front-end-access
          namespace: sock-shop
        spec:
          podSelector:
            matchLabels:
              run: nginx
          ingress:
            - ports:
                - protocol: TCP
                  port: 80

    $ kubectl create -f nginx-external-policy.yaml

#### Ingress

通常情况下, service 和 pod 的 IP 仅可在集群内部访问. 集群外部的请求需要通过负载均衡转发到 service 的 Node 上暴露的 NodePort 上, 然后再由 kube-proxy 将其转发给相关的 Pod.

Ingress 为进入进群的情求提供**路由规则**的集合.
    
    internet
        |
   [ Ingress ]
   --|-----|--
   [ Services ]

Ingress 可以给 service 提供集群外部访问的 URL, 负载均衡, SSL 终止, HTTP 路由等. 为了配置这些 Ingress 规则, 集群管理员需要部署一个 **Ingress controller** , 它监听 Ingress 和 service 的变化, 并根据规则配置负载均衡并提供访问入口.

##### 格式
每个 Ingress 都需要配置 `rules`, 目前 Kubernetes 仅支持 http 规则.
    
    # 示例: 将请求 `/testpath` 转发到服务 `test` 的 80 端口

    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: test-ingress
    spec:
      rules:
      - http:
          paths:
          - path: /testpath
            backend:
              serviceName: test
              servicePort: 80

    # 创建
    $ kubectl create test-ingress.yaml

    # 查看详情
    $ kubectl get ing

##### Ingress 类型

1. **单服务 Ingress**
    
    单服务 Ingress 即该 Ingress 仅指定一个没有任何规则的后端服务.

        apiVersion: extensions/v1beta1
        kind: Ingress
        metadata:
          name: test-ingress
        spec:
          backend:
            serviceName: testsvc
            servicePort: 80

    单个服务还可以通过设置 `Service.Type=NodePort` 或 `Service.Type=LoadBalancer` 来对外暴露.

2. **路由到多服务的 Ingress**
    
    路由到多服务的 Ingress 即根据请求路径的不同转发到不同的后端服务上.如 : 

        foo.bar.com --> 178.91.123.143 -->  /foo    s1:80
                                            /bar    s2:80

        apiVersion: extensions/v1beta1
        kind: Ingress
        metadata:
          name: test
        spec:
          rules:
          - host: foo.bar.com
            http:
              paths:
              - path: /foo
                backend:
                  serviceName: s1
                  servicePort: 80
              - path: /bar
                backend:
                  serviceName: s2
                  servicePort: 80

3. **虚拟主机 Ingress**

    虚拟主机 Ingress 即根据名字的不同转发到不同的后端服务上, 而他们共用同一个 IP 地址:

        foo.bar.com --|                 |-> foo.bar.com s1:80
                      | 178.91.123.132  |
        bar.foo.com --|                 |-> bar.foo.com s2:80

    示例: 基于 Host header 路由请求的 Ingress

        apiVersion: extensions/v1beta1
        kind: Ingress
        metadata:
          name: test
        spec:
          rules:
          - host: foo.bar.com
            http:
              paths:
              - backend:
                  serviceName: s1
                  servicePort: 80
          - host: bar.foo.com
            http:
              paths:
              - backend:
                  serviceName: s2
                  servicePort: 80

    没有定义规则的后端服务成为默认后端服务, 可以用来方便的处理 404 页面.

4. **TLS Ingress** 
    
    TLS Ingress 通过 Secret 获取 TLS 私钥和证书(名为 tls.crt 和 tls.key), 来执行 TLS 终止. 如果 Ingress 中的 TLS 配置部分指定了不同的主机, 则他们将根据通过 SNI TLS 扩展指定的主机名(如 Ingress Controller 支持 SNI) 在多个相同的端口上进行复用.

        # 定义一个包含 `tls.crt` 和 `tls.key` 的 secret
        apiVersion: v1
        data:
          tls.crt: base64 encoded cert
          tls.key: base64 encoded key
        kind: Secret
        metadata:
          name: testsecret
          namespace: default
        type: Opaque

        # Ingress 中医用 secret
        apiVersion: extensions/v1beta1
        kind: Ingress
        metadata:
          name: no-rules-map
        spec:
          tls:
            - secretName: testsecret
          backend:
            serviceName: s1
            servicePort: 80        


    **注意** 不同 Ingress Controller 支持的 TLS 功能不尽相同, 可以参阅有关 nginx, GCE 或任何其他 Ingress Controlles 的文档, 以了解 TLS 的支持情况.

##### 更新 Ingress
更新 Ingress 有两种方式:
1. `kubectl edit ing <ing_name>` 在线修改, 保存后即会将其更新到 Kubernetes API Server, 进而触发 Ingress Controller 重新配置负载均衡.

2. `kubectl replace -f new-ingress.yaml` 来更新(替换)


##### Ingress Controller 
[traefik ingress 实践案例](插件扩展)
[kubernetes/ingress 示例](https://github.com/kubernetes/ingress-nginx/tree/master)
[Kubernetes Ingress Controller](https://github.com/kubernetes/ingress/tree/master)
[使用 NGINX 和 NGINX Plus 的 Ingress Controller 进行 Kubernetes 的负载均衡](http://www.cnblogs.com/276815076/p/6407101.html)

#### ThirdPartyResources
ThirdPartyResources 是一种无需改变代码就可以扩展 Kubernetes API 的机制, 可以用来管理自定义对象.

每个 ThirdPartyResources 都包含以下属性:
1. `metadata` 跟 kubernetes metadata 一样.
2. `kind` 自定义的资源类型, 采用 `<kind_name>.<domain>` 的格式.
3. `description` 资源描述
4. `version` 版本列表
5. 其他 : 其他任何自定义的属性.

示例: 创建一个 `/apis/stable.example.com/v1/namespaces/<namespace>/crontabs/..`的 API
    
    $ cat resource.yaml

        apiVersion: extensions/v1beta1
        kind: ThirdPartyResource
        metadata:
          name: cron-tab.stable.example.com
        description: "A specification of a Pod to run on a cron style schedule"
        versions:
        - name: v1

    $ kubectl create -f resource.yaml

    # 创建具体的 CronTab 对象
    $ cat my-cronjob.yaml
        apiVersion: "stable.example.com/v1"
        kind: CronTab
        metadata:
          name: my-new-cron-object
        cronSpec: "* * * * /5"
        image: my-awesome-cron-image

    $ kubectl create -f my-crontab.yaml

    $ kubectl get crontab

##### ThirdPartyResources 与 RBAC

ThirdPartyResources 不是 namespace-scoped 的资源, 在普通用户使用之前需要绑定 ClusterRole 权限.

    $ cat cron-rbac.yaml
        apiVersion: rbac.authorization.k8s.io/v1alpha1
        kind: ClusterRole
        metadata:
          name: cron-cluster-role
        rules:
        - apiGroups:
          - extensions
          resources:
          - thirdpartyresources
          verbs:
          - '*'
        - apiGroups:
          - stable.example.com
          resources:
          - crontabs
          verbs:
          - "*"

    $ kubectl create -f cron-rbac.yaml

    $ kubectl create clusterrolebinding user1 --clusterrole=cron-cluster-role --user=user1 --user=user2 --group=group1

#### ConfigMap
ConfigMap 用于保存配置数据的键值对, 可以用来保存单个属性, 也可以用来保存配置文件. 

ConfigMap 跟 secret 很类似, 但它可以更方便的处理不包含敏感信息的字符串.

##### 创建
可以使用 `kubectl create configmap` 从文件, 目录或者 key-value 字符串等创建 ConfigMap.

1. 从 key-value 字符串创建 ConfigMap
    
        $ kubectl create configmap special-config --from-literal=special.how=very

        $ kubectl get configmap special-config -o go-template='{{.data}}'
          map[special.how:very]

2. 从 环境变量 创建
    
        $ echo -e "a=b\nc=d" | tee config.env

        $ kubectl create configmap special-config --from-env-file=config.env

        $ kubectl get configmap special-config -o go-template='{{.data}}'
          map[a:b c:d]

3. 从 目录创建
    
        $ mkdir config
        $ echo a > config/a
        $ echo b > config/b

        $ kubectl create configmap special-config --from-file=config/

        $ kubectl get configmap special-config -o go-template='{{.data}}'
            map[a:a
             b:b
            ]        

##### 使用
ConfigMap 可以通过多种方式在 Pod 中使用. 但是需要注意: ConfigMap 必须在 Pod 引用之**前**创建; 使用`envFrom` 时, 将会自动忽略无效的键.

1. 设置环境变量   
    
        # 创建 ConfigMap
        $ kubectl create configmap special-config --from-literal=special.how=very --from-literal=special.type=charm

        $ kubectl create configmap env-config --from-literal=log_level=INFO

        # 以环境变量方式引用
            apiVersion: v1
            kind: Pod
            metadata:
              name: test-pod
            spec:
              containers:
                - name: test-container
                  image: gcr.io/google_containers/busybox
                  command: [ "/bin/sh", "-c", "env" ]
                  env:
                    - name: SPECIAL_LEVEL_KEY
                      valueFrom:
                        configMapKeyRef:
                          name: special-config
                          key: special.how
                    - name: SPECIAL_TYPE_KEY
                      valueFrom:
                        configMapKeyRef:
                          name: special-config
                          key: special.type
                  envFrom:
                    - configMapRef:
                        name: env-config
              restartPolicy: Never

        # 当 Pod 运行结束后, 它的输出会包括
            SPECIAL_LEVEL_KEY=very
            SPECIAL_TYPE_KEY=charm
            log_level=INFO

2. 用作命令行参数
    
    将 ConfigMap 用作命令行参数时, 需要先把 ConfigMap 的数据保存在环境变量zhong, 然后通过 `$(VAR_NAME)` 的方式引用环境变量.

        apiVersion: v1
        kind: Pod
        metadata:
          name: dapi-test-pod
        spec:
          containers:
            - name: test-container
              image: gcr.io/google_containers/busybox
              command: [ "/bin/sh", "-c", "echo $(SPECIAL_LEVEL_KEY) $(SPECIAL_TYPE_KEY)" ]
              env:
                - name: SPECIAL_LEVEL_KEY
                  valueFrom:
                    configMapKeyRef:
                      name: special-config
                      key: special.how
                - name: SPECIAL_TYPE_KEY
                  valueFrom:
                    configMapKeyRef:
                      name: special-config
                      key: special.type
          restartPolicy: Never

        # 当 Pod 结束后输出
            very charm

3. 用作 Volume 配置文件
    
    可以直接用 ConfigMap 的数据填充 Volume.

        apiVersion: v1
        kind: Pod
        metadata:
          name: vol-test-pod
        spec:
          containers:
            - name: test-container
              image: gcr.io/google_containers/busybox
              command: [ "/bin/sh", "-c", "cat /etc/config/special.how" ]
              volumeMounts:
              - name: config-volume
                mountPath: /etc/config
          volumes:
            - name: config-volume
              configMap:
                name: special-config
          restartPolicy: Never

        # 当 Pod 结束后输出
            very

        # 可以指定 Volume 路径
            apiVersion: v1
            kind: Pod
            metadata:
              name: dapi-test-pod
            spec:
              containers:
                - name: test-container
                  image: gcr.io/google_containers/busybox
                  command: [ "/bin/sh","-c","cat /etc/config/keys/special.level" ]
                  volumeMounts:
                  - name: config-volume
                    mountPath: /etc/config
              volumes:
                - name: config-volume
                  configMap:
                    name: special-config
                    items:
                    - key: special.level
                      path: /keys
              restartPolicy: Never

#### PodPresset

PodPresset 用来给指定标签的 Pod 注入额外的信息, 如环境变量, 存储卷等. 这样, Pod 模板就不需要为每个 Pod 都显式设置重复的信息.

##### 开启 PodPresset
1. 开启 API `settings.k8s.io/v1alpha1/podpreset`
2. 开启准入控制 `PodPreset`

##### 示例

    # 增加环境变量和存储卷的 PorPreset
        kind: PodPreset
        apiVersion: settings.k8s.io/v1alpha1
        metadata:
          name: allow-database
          namespace: myns
        spec:
          selector:
            matchLabels:
              role: frontend
          env:
            - name: DB_PORT
              value: "6379"
          volumeMounts:
            - mountPath: /cache
              name: cache-volume
          volumes:
            - name: cache-volume
              emptyDir: {}

    # 用户提交 Pod
        apiVersion: v1
        kind: Pod
        metadata:
          name: website
          labels:
            app: website
            role: frontend
        spec:
          containers:
            - name: website
              image: ecorp/website
              ports:
                - containerPort: 80

    # 经过准入控制 `PodPreset` 后, Pod 会自动增加环境变量和存储卷.
        apiVersion: v1
        kind: Pod
        metadata:
          name: website
          labels:
            app: website
            role: frontend
          annotations:
            podpreset.admission.kubernetes.io/allow-database: "resource version"
        spec:
          containers:
            - name: website
              image: ecorp/website
              volumeMounts:
                - mountPath: /cache
                  name: cache-volume
              ports:
                - containerPort: 80
              env:
                - name: DB_PORT
                  value: "6379"
          volumes:
            - name: cache-volume
              emptyDir: {}

##### 示例
    
    # ConfigMap
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: etcd-env-config
        data:
          number_of_members: "1"
          initial_cluster_state: new
          initial_cluster_token: DUMMY_ETCD_INITIAL_CLUSTER_TOKEN
          discovery_token: DUMMY_ETCD_DISCOVERY_TOKEN
          discovery_url: http://etcd_discovery:2379
          etcdctl_peers: http://etcd:2379
          duplicate_key: FROM_CONFIG_MAP
          REPLACE_ME: "a value"

    # PodPreset
        kind: PodPreset
        apiVersion: settings.k8s.io/v1alpha1
        metadata:
          name: allow-database
          namespace: myns
        spec:
          selector:
            matchLabels:
              role: frontend
          env:
            - name: DB_PORT
              value: 6379
            - name: duplicate_key
              value: FROM_ENV
            - name: expansion
              value: $(REPLACE_ME)
          envFrom:
            - configMapRef:
                name: etcd-env-config
          volumeMounts:
            - mountPath: /cache
              name: cache-volume
            - mountPath: /etc/app/config.json
              readOnly: true
              name: secret-volume
          volumes:
            - name: cache-volume
              emptyDir: {}
            - name: secret-volume
              secretName: config-details   

    # 用户提交 Pod
        apiVersion: v1
        kind: Pod
        metadata:
          name: website
          labels:
            app: website
            role: frontend
        spec:
          containers:
            - name: website
              image: ecorp/website
              ports:
                - containerPort: 80

    # 经过准入控制 `PodPreset` 后, Pod 会自动增加 ConfigMap 环境变量
        apiVersion: v1
        kind: Pod
        metadata:
          name: website
          labels:
            app: website
            role: frontend
          annotations:
            podpreset.admission.kubernetes.io/allow-database: "resource version"
        spec:
          containers:
            - name: website
              image: ecorp/website
              volumeMounts:
                - mountPath: /cache
                  name: cache-volume
                - mountPath: /etc/app/config.json
                  readOnly: true
                  name: secret-volume
              ports:
                - containerPort: 80
              env:
                - name: DB_PORT
                  value: "6379"
                - name: duplicate_key
                  value: FROM_ENV
                - name: expansion
                  value: $(REPLACE_ME)
              envFrom:
                - configMapRef:
                  name: etcd-env-config
          volumes:
            - name: cache-volume
              emptyDir: {}
            - name: secret-volume
              secretName: config-details

### 2.3 核心组件
Kubernetes 多组件之间的**通信原理**为:

1. apiserver 负责 etcd 存储的所有操作, 且只有 apiserver 才直接操作 etcd 集群.
2. apiserver 对内(集群中的其他组件)和对外(用户)提供统一的 REST API, 其他组件均通过 apiserver 进行通信.
    - controller manager , scheduler, kube-proxy 和 kubelet 等均通过 apiserver watch API 检测资源变化情况, 并对资源做相应的操作.
    - 所有需要更新资源状态的操作均通过 apiserver 的 REST API 进行.
3. apiserver 也会直接调用 kubectl API (如 logs , exec, attach 等), 默认不校验 kubelet 证书, 但可以通过 `--kubelet-certificate-authority` 开启, (而 GKE 通过 SSH 隧道保护他们之间的通信).

#### etcd 
保存了整个集群的状态；

Etcd 是 CoreOS 基于 Raft 开发的分布式 key-value 存储, 可用于服务发现, 共享配置以及一致性保障(如数据库选主, 分布式锁等).

##### 1. 主要功能
1. 基本 Key-value 存储
2. 监听机制
3. key 的过期及续约机制, 用于监控和服务发现.
4. 原子 CAS 和 CAD , 用于分布式锁和 leader 选举.

##### 2. ETCD 基于 Raft 的一致性
- 选举方法
    
    1. 初始启动时, 节点处于 follower 状态, 并被设定一个 election timeout, 如果在这一时间周期内, 没有收到来自 leader 的 heartbeat , 节点将发起选举 : 将自己切换为 candidate(候选人) 之后, 向集群中其他 follower 节点发送请求, 询问其是否选举自己成为 leader.

    2. 当收到来自集群中过半数节点的接受投票后, 节点即成为 leader, 开始接收保存 client 的数据并向其他的 follower 节点同步日志. 如果没有达成一致, 则 candidate 随机选择一个等待间隔 (150ms ~ 300ms) 再次发起投票, 得到集群中半数以上 follower 接受的 candidate 将成为 leader.

    3. leader 节点依靠定时向 follower 发送 heartbeat 来保持其地位.

    4. 任何时候, 如果其他 follower 在 election timeout 期间都没有收到来自 leader 的 heartbeat, 同样会将自己的状态切换为 candidate 并发起选举. 每成功选举一次, 新 leader 的任期(Term) 都会比之前 leader 的任期大 1.

- 日志复制
    
    当 leader 接受到客户端的日志(事务请求)后, 先把该日志追加到本地 Log 中, 然后通过 heartbeat 把该 Entry 同步给其他 follower;

    follower 接受到日志后记录日志, 然后向 leader 发送 ACK;

    当 leader 收到大多数 (n/2+1) follower 的 ACK 信息后, 将该日志设置为**已提交**, 并追加到本地磁盘中, 通知客户端并在下一个 heartbeat 中 leader 将通知所有的 follower 将该日志存储在自己本地磁盘中.

- 安全性

    安全性是用于保证每个节点都执行相同序列的安全机制, 如当 某个 follower 在当前 leader commit log 时变得不可用了, 稍后, 可能该 follower 又被选举为 leader , 这是新 leader 可能会用新的 log 覆盖先前已 commited  的 log, 这就是导致节点指定不同序列.

    safety 就是用于保证选举出来的 leader 一定包含先前 commited log 的机制.

    1. 选举安全性(Election safety) : 每个任期(Term) 只能选举出一个 leader

    2. Leader 完整性(Leader Completeness) : 指 Leader 日志的完整性, 当 Log 在任期 Term1 被 Commit 后, 那么以后任期 Term2, Term3 ... 等的 Leader 必须包含该 Log;

        Raft 在选举节点就使用 Term 的判断用于保证完整性: 当请求投票的该 Candidate 的 **Term 较大**或 **Term 相同Index 较大**则投票, 否则拒绝该请求.

- 失效处理
    
    1. Leader 失效 : 

        其他没有收到 heartbeat 的节点会发起新的选举, 而当 Leader 恢复后由于步进数小会自动成为 follower, 日志也会被新 leader 的日志覆盖.
    
    2. follower 节点不可用 : 

        follower 节点不可用的情况, 相对容易解决, 因为集群中的日志内容始终是从 leader 节点同步的, 只要这一节点再次加入集群是重新从 leader 节点处复制日志即可.
    
    3. 多个 candidate : 

        冲突后 candidate 将随机选择一个等待时间(150ms ~ 300ms) 再次发起投票, 得到集群中半数以上 follower 接受的 candidate 将成为 leader.

- wal 日志
    
    Etcd 实现 raft 的时候, 充分利用了 go 语言 CSP 并发模型和 chan 的魔法.
    ![wal 数据结构](http://oluv2yxz6.bkt.clouddn.com/wal_data_stru.png)
    wal 日志是二进制的, 接续出来之后是以上数据结构:
    - `type` : 

        只有两种类型:
        1. `0` : 表示 Normal;
        2. `1` : 表示 COnfChange , 即 Etcd 本身的配置变更同步, 如有新节点加入等.

    - `term` : 

        每个 term 代表一个主节点的任期, 每次主节点变更 term 就会变化.
    
    - `index` : 
        
        该序号严格有序递增的, 代表变更序号.

    - `data` : 

        二进制的 data, 将 raft request 对象的 pb 结构整个保存下来.

        etcd 源码下有个 `tools/etcd-dump-log` 可以将 wal 日志 dump 成文本查看, 可以协助分析 raft 协议.

        raft 协议本身不关心应用数据, 即 data 中的部分. 一致性都通过同步 wal 日志来实现, 每个节点将从主节点收到的 data apply 到本地存储, raft 只关心日志的同步状态, 如果本地存储实现的有 bug, 比如没有正确的将 data apply 到本地, 也可能会导致数据不一致.

##### 3. Etcd v2 与 v3
Etcd v2 和 v3 本质上是共享同一套 raft 协议代码的两个独立的应用. 接口不一样, 存储不一样, 数据相互隔离.

1. Etcd v2 存储, watch 以及过期机制
    
    ![etcd v2 存储机制](http://oluv2yxz6.bkt.clouddn.com/etcd_v2_store.png)

    Etcd v2 是个纯内存的实现, 并未实时将数据写入到磁盘, 持久化机制很简单: 就是将 store 整个序列化成 json 写入文件. 数据在内存是一个简单的树结构.

    store 中有一个全局 currentIndex , 每次变更, index 会加 1. 然后每个 event 都会关联到 currentIndex.

    当客户端调用 watch 接口(参数中增加 wait 参数时), 如果请求参数中有 waitIndex, 并且 waitIndex 小于等于 currentIndex , 并且和 watch key 匹配的 event 如果有数据, 则直接返回. 如果没有数据或者请求没有带 waitIndex , 则放入 WatchHub 中, 每个 key 会关联一个 watcher 列表, 当有变更操作时, 变更生成的 event 会放入 EventHistory 表中, 同时通知和该 key 相关的 watcher.

    **注意**
    - EventHistroy 是有长度限制的, 最长1000. 也就是说, 如果你的客户端停了许久, 然后重新watch的时候, 可能和该waitIndex相关的event已经被淘汰了, 这种情况下会丢失变更. 
    
    - 如果通知watch的时候, 出现了阻塞（每个watch的channel有100个缓冲空间）, Etcd 会直接把watcher删除, 也就是会导致wait请求的连接中断, 客户端需要重新连接. 

    - Etcd store的每个node中都保存了过期时间, 通过定时机制进行清理. 

    - 过期时间只能设置到每个key上, 如果多个key要保证生命周期一致则比较困难. 
    
    - watch只能watch某一个key以及其子节点（通过参数 recursive),不能进行多个watch. 

    -   很难通过watch机制来实现完整的数据同步（有丢失变更的风险）, 所以当前的大多数使用方式是通过watch得知变更, 然后通过get重新获取数据, 并不完全依赖于watch的变更event. 

2. Etcd v3 存储, watch 以及过期机制
    
    ![etcd v3 存储机制](http://oluv2yxz6.bkt.clouddn.com/etcd_v3_store.png)

    Etcd v3 将watch和store拆开实现.

    1. Store

        Etcd v3 store 分为两部分 : 
        
        - 内存中的索引 : kvindex, 是基于google开源的一个golang的btree实现的.

        - 后端存储 : 按照它的设计, backend可以对接多种存储, 当前使用的boltdb. boltdb是一个单机的支持事务的kv存储, Etcd 的事务是基于boltdb的事务实现的. Etcd 在boltdb中存储的key是reversion, value是 Etcd 自己的key-value组合, 也就是说 Etcd 会在boltdb中把每个版本都保存下, 从而实现了多版本机制. 


        reversion主要由两部分组成, 
        - main rev, 每次事务进行加一
        - sub rev, 同一个事务中的每次操作加一. 

        如上示例, 第一次操作的main rev是3, 第二次是4. 当然这种机制大家想到的第一个问题就是空间问题, 所以 Etcd 提供了命令和设置选项来控制compact, 同时支持put操作的参数来精确控制某个key的历史版本数. 

        了解了 Etcd 的磁盘存储, 可以看出如果要从boltdb中查询数据, 必须通过 `reversion`, 但客户端都是通过key来查询value, 所以 Etcd 的内存 kvindex 保存的就是key和reversion之前的映射关系, 用来加速查询. 

    2. watch

        Etcd v3 的watch机制支持watch某个固定的key, 也支持watch一个范围（可以用于模拟目录的结构的watch）, 所以 watchGroup 包含两种watcher, 一种是 key watchers, 数据结构是每个key对应一组watcher, 另外一种是 range watchers, 数据结构是一个 IntervalTree , 方便通过区间查找到对应的watcher. 

        同时, 每个 WatchableStore 包含两种 watcherGroup, 一种是synced, 一种是unsynced, 前者表示该group的watcher数据都已经同步完毕, 在等待新的变更, 后者表示该group的watcher数据同步落后于当前最新变更, 还在追赶. 

        当 Etcd 收到客户端的watch请求, 如果请求携带了revision参数, 则比较请求的revision和store当前的revision, 如果大于当前revision, 则放入synced组中, 否则放入unsynced组. 同时 Etcd 会启动一个后台的goroutine持续同步unsynced的watcher, 然后将其迁移到synced组. 也就是这种机制下, Etcd v3 支持从任意版本开始watch, 没有v2的1000条历史event表限制的问题（当然这是指没有compact的情况下）. 

        另外我们前面提到的, Etcd v2在通知客户端时, 如果网络不好或者客户端读取比较慢, 发生了阻塞, 则会直接关闭当前连接, 客户端需要重新发起请求. Etcd v3为了解决这个问题, 专门维护了一个推送时阻塞的watcher队列, 在另外的goroutine里进行重试. 

        Etcd v3 对过期机制也做了改进, 过期时间设置在lease上, 然后key和lease关联. 这样可以实现多个key关联同一个lease id, 方便设置统一的过期时间, 以及实现批量续约.

##### 4. etcd 周边工具
1. Confd : 基于 etcd 的kv 存储, 实现配置变更的机制和工具.
    
    Confd 通过 watch 机制监听 Etcd 的变更, 然后将数据同步到自己的一个本地存储, 用户可以通过配置定义自己关注那些 key 的变更, 同事提供一个配置文件模板.

    Confd 一旦发现数据变更就是用最新数据渲染模板生成配置文件, 如果新旧配置文件有变化, 则进行替换, 同时触发用户提供的 reload 脚本, 让应用程序重新加载配置.

2. Metad
    
    服务注册的实现模式一般分两种:
    1. 调度系统代为注册 : 

        应用程序启动后需要一种机制让应用程序知道"我是谁", 然后发现自己所在的集群以及自己的配置.

    2. 应用程序自己注册;

    Metad 使用 调用系统代为注册的机制. 客户端请求 Metad 的一个固定的 `/self` , 有 Metad 告知应用程序其所属的元信息(通过保存一个 ip 到元信息路径的映射关系实现), 简化了客户端的服务发现和配置变更逻辑.

    Metad 后端支持 Etcd v3 , 提供简单好用的 http rest 接口. 他会把 Etcd 的数据通过 watch 机制同步到本地内存中, 相当于一个 Etcd 代理. 

    也可以吧 Metad 当做 Etcd 代理来使用, 适用于不方便使用 Etcd v3 的 rpc 接口或向降低 Etcd 压力的场景.

#### apiserver 
提供了资源操作的唯一入口, 并提供认证、授权、访问控制、API注册和发现等机制；

##### 功能:
1. 提供集群管理的 REST API 接口, 包括认证授权, 数据校验以及集群状态变更等;
2. 提供其他模块之间的数据交互和通信的枢纽(其他模块通过 API Servier 查询或修改数据, 只有 API Servier 才能直接操作 Etcd)

##### [REST API](https://v1-6.docs.kubernetes.io/docs/reference/) 
kube-apiserver 支持同时提供 https (端口 6443) 和 http (端口 8080) API, 其中 http API 是非安全接口, 不做任何认证授权机制. 两个接口提供的 REST API 格式相同.

实际使用中, 通常使用 `kubectl` 来访问 apiserver, 也可以通过 Kubernetes 各个语言的 client 库来访问 apiserver. 

在使用 kubectl 时, 打开调试日志, 可以看到每个 API 的调用格式:
    
    $ kubectl --v=8 get pods

OpenAPI 和 Swagger 

通过 `/swaggerapi` 可以查看 Swagger API, `/swagger.json` 查看 OpenAPI.
开启 `--enable-swagger-ui=true`后, 还可以通过 `/swagger-ui` 访问 Swagger UI.

##### 访问控制
Kubernetes API 的每个请求都会经过多阶段的访问控制之后, 才会被接受, 这包括认证, 授权以及准入控制等.

1. 认证 

    开启 TLS 时, 所有的请求都需要首先认证. Kubernetes 支持多种认证机制, 并支持同时开启多个认证插件(只要有一个认证通过即可). 如果认证成功, 则用户的 `username` 会传入授权模块做进一步授权认证; 如果认证失败, 返回 HTTP 401.

    Kubernetes 不直接管理用户, 不能创建 `user` 对象, 也不存储 username.

    [kubernetes 认证插件](插件扩展/认证)

2. 授权
    
    认证之后的请求就到了 授权模块. Kubernetes 支持多种授权机制, 并支持同事开启多个授权插件(只要一个验证通过即可). 如果授权成功, 则用户的请求会发送到准入控制模块做进一步请求认证, 授权失败则返回 HTTP 403.

    [kubernetes 授权插件](插件扩展/授权)
    
3. 准入控制(Admission Control)
    
    准入控制用来对请求做进一步的验证或添加默认参数. 

    不同于授权和认证只关心请求的用户和操作, 准入控制还处理请求的内容, 并且仅对创建, 更新, 删除, 链接(如代理)等有效, 对 读 操作无效. 

    准入控制支持同时开启多个插件, 他们依次调用, 只有**全部插件都通过**的请求才可以放过进入系统.

    [kubernetes 准入控制插件](插件扩展/准入控制)

##### 启动 apiserver 示例
    $ kube-apiserver --feature-gates=AllAlpha=true --runtime-config=api/all=true \
        --requestheader-allowed-names=front-proxy-client \
        --client-ca-file=/etc/kubernetes/pki/ca.crt \
        --allow-privileged=true \
        --experimental-bootstrap-token-auth=true \
        --storage-backend=etcd3 \
        --requestheader-username-headers=X-Remote-User \
        --requestheader-extra-headers-prefix=X-Remote-Extra- \
        --service-account-key-file=/etc/kubernetes/pki/sa.pub \
        --tls-cert-file=/etc/kubernetes/pki/apiserver.crt \
        --tls-private-key-file=/etc/kubernetes/pki/apiserver.key \
        --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt \
        --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt \
        --insecure-port=8080 \
        --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds \
        --requestheader-group-headers=X-Remote-Group \
        --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key \
        --secure-port=6443 \
        --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname \
        --service-cluster-ip-range=10.96.0.0/12 \
        --authorization-mode=RBAC \
        --advertise-address=192.168.0.20 --etcd-servers=http://127.0.0.1:2379

##### kube-apiserver 工作原理
![kube-apiserver](http://oluv2yxz6.bkt.clouddn.com/kube-apiserver.png)

#### kube-scheduler
kube-scheduler 负责分配调度 Pod 到集群内的节点上, 它监听 kube-apiserver , 查询还未分配 Node 的 Pod, 然后根据调度策略为这些 Pod 分配节点(更新 Pod 的 `NodeName` 字段).

调度器需要考虑的因素, 影响调度的 因素:
1. 公平调度
2. 资源高效利用
3. QoS
4. affinity 和 anti-affinity
5. 数据本地化(data locality)
6. 内部负载干扰(inter-workload interference)
7. deadlines

##### 指定 Node 节点调度
有三种方式指定 Pod 只运行在指定的 Node 节点上:

1. nodeSelector : 只调度到匹配指定 label 的 Node 上.
    
    1. 给 Node 打标签

            $ kubectl label nodes node-01 disktype=ssd

    2. 在 daemonset 中指定 nodeSelector 为 `disktype=ssd`

            spec:
              nodeSelector:
                disktype: ssd
    
    
2. nodeAffinity : 功能更丰富的 Node 选择器, 如支持集合操作
    
    nodeAffinity 目前支持两种: 
    - `requiredDuringSchedulingIgnoredDuringExecution` : 必须满足条件
    - `preferredDuringSchedulingIgnoredDuringExecution` : 优选条件

    示例: 调度到包含标签 `kubernetes.io/e2e-az-name` 并且值为 `e2e-az1` 或 `e2e-az2` 的 Node上, 并且优选还带有标签 `another-node-label-key=another-node-label-value` 的 Node.

        apiVersion: v1
        kind: Pod
        metadata:
          name: with-node-affinity
        spec:
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: kubernetes.io/e2e-az-name
                    operator: In
                    values:
                    - e2e-az1
                    - e2e-az2
              preferredDuringSchedulingIgnoredDuringExecution:
              - weight: 1
                preference:
                  matchExpressions:
                  - key: another-node-label-key
                    operator: In
                    values:
                    - another-node-label-value
          containers:
          - name: with-node-affinity
            image: gcr.io/google_containers/pause:2.0

3. podAffinity : 调度到满足条件的 Pod 所在的 Node 上.
    
    podAffinity 基于 Pod 的标签来选择 Node, 仅调度到满足条件 Pod 所在的 Node 上. 支持 `podAffinity` 和 `podAntiAffinity`.

    示例: 如果一个“Node所在Zone中包含至少一个带有security=S1标签且运行中的Pod”，那么可以调度到该Node; 不调度到“包含至少一个带有security=S2标签且运行中Pod”的Node上.

        apiVersion: v1
        kind: Pod
        metadata:
          name: with-pod-affinity
        spec:
          affinity:
            podAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchExpressions:
                  - key: security
                    operator: In
                    values:
                    - S1
                topologyKey: failure-domain.beta.kubernetes.io/zone
            podAntiAffinity:
              preferredDuringSchedulingIgnoredDuringExecution:
              - weight: 100
                podAffinityTerm:
                  labelSelector:
                    matchExpressions:
                    - key: security
                      operator: In
                      values:
                      - S2
                  topologyKey: kubernetes.io/hostname
          containers:
          - name: with-pod-affinity
            image: gcr.io/google_containers/pause:2.0

##### Taints 和 tolerations
Taints 和 tolerations 用于保证 Pod 不被调度到不合适的 Node 上, 其中 

- `Taints` 应用于 Node 上.
    类型:
    - `NoSchedule` : 新的 Pod 不调度到该 Node 上, 不影响正在运行的 Pod
    - `PreferNoSchedule` : soft 版的 NoSchedule, 尽量不调度到该 Node 上.
    - `NoExecute` : 新的 Pod 不调度到该 Node , 并删除(evict) 已在运行的 Pod, Pod 可以增加一个时间`tolerationSeconds`.

    当 Pod 的 Tolerations 匹配 Node 的所有 Taints 的时候, 可以调度到该 Node 上;
    当 Pod 是已经运行的时候, 也不会删除(evicted).
    对于 NoExecute, 如果 Pod 增阿基了一个 tolerationSeconds , 则会在该时间之后才删除 Pod.

    示例: 在 Node1 上应用以下一个 taint:

        $ kubectl taint nodes node1 key1=value1:NoSchedule
        $ kubectl taint nodes node1 key2=value2:NoExecute
        $ kubectl taint nodes node1 key2=value2:NoSchedule

- `tolerations` 应用于 Pod 上.

        # 如下 Pod 由于没有 tolerate `key2=value2:NoSchedule` 无法调度到 node1 上
        tolerations: 
        - key: "key1"
          operator: "Equal"
          value: "value1"
          effect: "NoSchedule"
        - key: "key1"
          operator: "Equal"
          value: "value1"
          effect: "NoExecute"

        # 正在运行且带有 `tolerationSeconds` 的 Pod 会在 600s 后被删除
        tolerations: 
        - key: "key1"
          operator: "Equal"
          value: "value1"
          effect: "NoSchedule"
        - key: "key1"
          operator: "Equal"
          value: "value1"
          effect: "NoExecute"
          tolerationSeconds: 600
        - key: "key2"
          operator: "Equal"
          value: "value2"
          effect: "NoSchedule"

`DaemonSet` 创建的 Pod 会自动加上对 `node.alpha.kubernetes.io/unreachable` 和 `node.alpha.kubernetes.io/notReady` 的 `NoExecute` toleration, 以避免被删除.

##### 多调度器
如果默认的调度器不满足要求, 还可以部署自定义的调度器, 并且在整个集群中还可以同时运行多个调度器. 通过 `podSpec.schedulerName` 来选择使用哪一个调度器(默认使用内置调度器).

    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      # 选择使用自定义调度器my-scheduler
      schedulerName: my-scheduler
      containers:
      - name: nginx
        image: nginx:1.10

##### 调度器扩展
kube-scheduler 还支持使用 `--policy-config-file` 指定一个调度策略文件来自定义调度策略.

    {
    "kind" : "Policy",
    "apiVersion" : "v1",
    "predicates" : [
        {"name" : "PodFitsHostPorts"},
        {"name" : "PodFitsResources"},
        {"name" : "NoDiskConflict"},
        {"name" : "MatchNodeSelector"},
        {"name" : "HostName"}
        ],
    "priorities" : [
        {"name" : "LeastRequestedPriority", "weight" : 1},
        {"name" : "BalancedResourceAllocation", "weight" : 1},
        {"name" : "ServiceSpreadingPriority", "weight" : 1},
        {"name" : "EqualPriority", "weight" : 1}
        ],
    "extenders":[
        {
            "urlPrefix": "http://127.0.0.1:12346/scheduler",
            "apiVersion": "v1beta1",
            "filterVerb": "filter",
            "prioritizeVerb": "prioritize",
            "weight": 5,
            "enableHttps": false,
            "nodeCacheCapable": false
        }
        ]
    }        

##### 其他影响调度的因素

1. 如果 Node Condition 处于 MemoryPressure , 则所有 BestEffort 的新 Pod (未指定 resources limits 和 request) 不会调度到该 Node 上.
2. 如果 Node Condition 处于 DiskPressure, 则所有新 Pod 都不会调度到该 Node 上.
3. 为保证Critical Pods 的正常运行, 当他们处于异常状态时, 会自动重新调度.  Critical Pods 是指:

    - annotation 包括 `scheduler.alpha.kubernetes.io/critical-pod=''`
    - tolerations 包括 `[{"key": "CriticalAddoneOnly", "operator": "Exists"}]`

##### 启动 kube-scheduler 示例
    
    $ kube-scheduler --address=127.0.0.1 --leader-elect=true --kubeconfig=/etc/kubernetes/scheduler.conf

##### kube-scheduler 工作原理

    For given pod:

        +---------------------------------------------+
        |               Schedulable nodes:            |
        |                                             |
        | +--------+    +--------+      +--------+    |
        | | node 1 |    | node 2 |      | node 3 |    |
        | +--------+    +--------+      +--------+    |
        |                                             |
        +-------------------+-------------------------+
                            |
                            |
                            v
        +-------------------+-------------------------+

        Pred. filters: node 3 doesn't have enough resource

        +-------------------+-------------------------+
                            |
                            |
                            v
        +-------------------+-------------------------+
        |             remaining nodes:                |
        |   +--------+                 +--------+     |
        |   | node 1 |                 | node 2 |     |
        |   +--------+                 +--------+     |
        |                                             |
        +-------------------+-------------------------+
                            |
                            |
                            v
        +-------------------+-------------------------+

        Priority function:    node 1: p=2
                              node 2: p=5

        +-------------------+-------------------------+
                            |
                            |
                            v
                select max{node priority} = node 2


kube-scheduler 调度分为两个阶段: predicate 和 priority 

1. predicate 过滤不符合条件的节点
    
    predicate 策略:

    - `PodFitsPorts` : 同PodFitsHostPorts
    - `PodFitsHostPorts` : 检查是否有Host Ports冲突
    - `PodFitsResources` : 检查Node的资源是否充足, 包括允许的Pod数量、CPU、内存、GPU个数以及其他的OpaqueIntResources
    - `HostName` : 检查pod.Spec.NodeName是否与候选节点一致
    - `MatchNodeSelector` : 检查候选节点的pod.Spec.NodeSelector是否匹配
    - `NoVolumeZoneConflict` : 检查volume zone是否冲突
    - `MaxEBSVolumeCount` : 检查AWS EBS Volume数量是否过多（默认不超过39）
    - `MaxGCEPDVolumeCount` : 检查GCE PD Volume数量是否过多（默认不超过16）
    - `MaxAzureDiskVolumeCount` : 检查Azure Disk Volume数量是否过多（默认不超过16）
    - `MatchInterPodAffinity` : 检查是否匹配Pod的亲和性要求
    - `NoDiskConflict` : 检查是否存在Volume冲突, 仅限于GCE PD、AWS EBS、Ceph RBD以及ISCSI
    - `GeneralPredicates` : 分为noncriticalPredicates和EssentialPredicates. noncriticalPredicates中包含PodFitsResources, EssentialPredicates中包含PodFitsHost, PodFitsHostPorts和PodSelectorMatches. 
    - `PodToleratesNodeTaints` : 检查Pod是否容忍Node Taints
    - `CheckNodeMemoryPressure` : 检查Pod是否可以调度到MemoryPressure的节点上
    - `CheckNodeDiskPressure` : 检查Pod是否可以调度到DiskPressure的节点上
    - `NoVolumeNodeConflict` : 检查节点是否满足Pod所引用的Volume的条件

2. priority 优先级排序, 选择优先级最高的节点.
    
    priority 策略:

    - `SelectorSpreadPriority` : 优先减少节点上属于同一个Service或Replication Controller的Pod数量
    - `InterPodAffinityPriority` : 优先将Pod调度到相同的拓扑上（如同一个节点、Rack、Zone等）
    - `LeastRequestedPriority` : 优先调度到请求资源少的节点上
    - `BalancedResourceAllocation` : 优先平衡各节点的资源使用
    - `NodePreferAvoidPodsPriority` : alpha.kubernetes.io/preferAvoidPods字段判断,权重为10000, 避免其他优先级策略的影响
    - `NodeAffinityPriority` : 优先调度到匹配NodeAffinity的节点上
    - `TaintTolerationPriority` : 优先调度到匹配TaintToleration的节点上
    - `ServiceSpreadingPriority` : 尽量将同一个service的Pod分布到不同节点上, 已经被SelectorSpreadPriority替代[默认未使用]
    - `EqualPriority` : 将所有节点的优先级设置为1[默认未使用]
    - `ImageLocalityPriority` : 尽量将使用大镜像的容器调度到已经下拉了该镜像的节点上[默认未使用]
    - `MostRequestedPriority` : 尽量调度到已经使用过的Node上, 特别适用于cluster-autoscaler[默认未使用]


#### controller manager 负责维护集群的状态, 比如故障检测、自动扩展、滚动更新等；

Controller Managher 由 `kube-controller-manager` 和 `cloud-controller-manager` 组成, 是 kubernetes 的大脑, 它通过 apiserver 监控整个集群的状态, 并确保集群处于预期的工作状态.

1. `kube-controller-manager` 由一系列控制器组成.
    
    控制器:

    1. 必须启动的控制器

        - EndpointController
        - ReplicationController
        - PodGCController
        - ResourceQuotaController
        - NamespaceController
        - ServiceAccountController
        - GarbageCollectorController
        - DaemonSetController
        - JobController
        - DeploymentController
        - ReplicaSetController
        - HPAController
        - DisruptionController
        - StatefulSetController
        - CronJobController
        - CSRSigningController
        - CSRApprovingController
        - TTLController

    2. 默认启动的可选控制器, 可通过选项设置是否开启

        - TokenController
        - NodeController
        - ServiceController
        - RouteController
        - PVBinderController
        - AttachDetachController
    3. 默认禁止的可选控制器, 可通过选项设置是否开启

        - BootstrapSignerController
        - TokenCleanerController

2. `cloud-controller-manager` 是 Kubernetes 启动 Cloud Provider 的时候才需要, 用来配合云服务提供商的控制, 也包括一系列的控制器.

    控制器:

    - CloudNodeController
    - RouteController
    - ServiceController


##### kube-controller-manager 启动示例

    $ kube-controller-manager --enable-dynamic-provisioning=true \
        --feature-gates=AllAlpha=true \
        --horizontal-pod-autoscaler-sync-period=10s \
        --horizontal-pod-autoscaler-use-rest-clients=true \
        --node-monitor-grace-period=10s \
        --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt \
        --address=127.0.0.1 \
        --leader-elect=true \
        --use-service-account-credentials=true \
        --controllers=*,bootstrapsigner,tokencleaner \
        --kubeconfig=/etc/kubernetes/controller-manager.conf \
        --insecure-experimental-approve-all-kubelet-csrs-for-group=system:bootstrappers \
        --root-ca-file=/etc/kubernetes/pki/ca.crt \
        --service-account-private-key-file=/etc/kubernetes/pki/sa.key \
        --cluster-signing-key-file=/etc/kubernetes/pki/ca.key

1. 如何保证高可用
    
    在启动时设置 `--leader-elect=true` 后, controller manager 会使用多节点选主的方式选择主节点. 只有主节点才会调用 `StartControllers()` 启动所有控制器, 而其他从节点则仅执行选主算法.

    多节点选主的实现方法见`leaderelection.go`, 它实现了两种资源锁(Endpoint 和 ConfigMap, kube-controller-manager 和 cloud-controller-manager 都使用 Endpoint 锁), 通过更新资源的 Annotation (`control-plane.alpha.kubernetes.io/leader`) , 来确认主从关系.

2. 如何保证高性能
    
    从 kubernetes 1.7 开始, 所有需要监控资源变化情况的调用均推荐使用 `Informer`. Informar 提供了基于事件通知的只读缓存机制, 可以注册资源变化的回调函数, 并可以极大减少 API 的调用.


#### kubelet 负责维护容器的生命周期, 同时也负责Volume（CVI）和网络（CNI）的管理；

每个节点上都运行一个 kubelet 服务进程, 默认监听 10250 端口, 接受并执行 master 发来的指令, 管理 Pod 和 Pod 中的容器. 每个 kubelet 进程会在 API Server 上注册节点自身信息, 定期向 master 节点汇报节点的资源使用情况, 并通过 cAdvisor 监控节点和容器的资源.

1. 节点管理
    
    主要是**节点自注册**和**节点状态更新**:

    - kubectl 可以通过设置启动参数 `--register-node` 来确定是否向 API Server 注册自己.
    - 如果 Kubelet 没有选择自注册模式, 则需要用户自己配置 Node 资源信息, 同时需要告知 kubelet 集群上的 API Server 的位置
    - kubelet 在启动时通过 API Server 注册节点信息, 并定时向 API Server 发送节点新消息, API Server 在接收到新消息后, 将信息写入 etcd.
    
2. Pod 管理
    
    - 获取 Pod 清单

        kubelet 以 PodSpec 的方式工作. PodSpec 是描述一个 Pod 的 YAML 或 JSON 对象. kubelet 采用一组通过各种机制提供的 podSpecs (主要通过 apiserver), 并确保这些 podSpecs 中描述的 Pod 正常健康运行.

        向 kubelet 提供节点上需要运行的 Pod 清单的方法:
        
        1. 文件 

            启动参数 `--config` 指定的配置目录下的文件(默认 `/etc/kubernetes/manifests/` ). 该文件默认每 20s 重新检查一次.

        2. HTTP endpoint(URL) 

            启动参数 `--manifest-url` 设置, 默认每 20s 检查一次这个断点.
        
        3. API Server 

            通过 API Server 监听 Etcd 目录, 同步 Pod 清单.
        
        4. HTTP Server 

            kubectl 侦听 HTTP 请求, 并响应简单的 API 以提交新的 Pod 清单.

    - 通过 API Server 获取 Pod 清单及创建 Pod 的过程

        Kubelet 通过 API Server Client (kubelet 启动时创建) 使用 `Watch` 加 `List` 的方式监听 `/registry/nodes/$当前节点名` 和 `/registry/pods` 目录, 将获取的信息同步到本地缓存中.

        Kubelet 监听 etcd , 所有针对 Pod 的操作都将会被 kubelet 监听到. 如果发现新的绑定到本节点的 Pod, 则按照 Pod 清单的要求创建该 Pod.

        如果发现本地的 Pod 被修改, 则 Kubelet 会做出相应的修改.比如 删除某个Pod 中的某个容器时, 则会通过 Docker Client 删除该容器.

        kubelet 读取监听到的信息, 如果是创建和修改 Pod 任务, 则执行如下处理:

        1. 为 该 Pod 创建一个数据目录;
        2. 从 API Server 读取该 Pod 清单;
        3. 为该 Pod 挂载外部卷
        4. 下载 Pod 用到的 Secret;
        5. 检查已经在节点上运行的 Pod, 如果该 Pod 没有容器或 Pause 容器没有启动, 则先停止Pod 里所有容器的进程. 如果在 Pod 中有需要删除的容器, 则删除这些容器.
        6. 用`kubernetes/pause` 镜像为每个 Pod 创建一个容器. Pause 容器用于接管 Pod 所有其他容器的网络. 每创建一个新的 Pod, Kubelet 都会先创建一个 Pause 容器, 然后创建其他的容器.
        7. 为 Pod 中的每个容器做如下处理:

            - 为容器计算一个 hash 值, 然后用容器的名字去 Docker 查询对应容器的 hash 值. 若查找到容器, 且两者 hash 值不同, 则停止 Docker 中容器的进程, 并停止与之关联的 Pause 容器的进程; 若两者相同, 则不作任何处理.
            - 如果容器被终止了, 且容器没有指定 restartPolicy , 则不作任何处理;
            - 调用 Docker Client 下载容器镜像, 调用 Docker Client 运行容器.

    - Static Pod

        所有以非 API Server 方式创建的 Pod 都叫 Static Pod. 

        Kubelet 将 Static Pod 的状态汇报给 API Server, API Server 为该 Static Pod 创建一个 Mirror Pod 和其相匹配. Mirror Pod 的状态将真实反映 Static Pod 的状态. 当 Static Pod 被删除时, 与之相对应的 Mirror Pod 也会被删除.

3. 容器健康检查
    
    Pod 通过两类探针检查容器的健康状态:

    - `LivenessProbe` 用于判断容器是否健康, 告诉 Kubelet 一个容器什么时候处于不健康的状态.

        如果 `LivenessProbe` 探测到容器不健康, 则 Kubelet 将删除该容器, 并根据容器的重启策略做相应的处理.

        如果一个容器不包含`LivenessProbe` 探针, 那么 Kubelet 认为该容器的 LivenessProbe 探针返回的值永远是 `Success`.

        Kubelet 定期调用容器中的 `LivenessProbe` 探针来诊断容器的健康状况. `LivenessProbe` 包含如下三种实现方式:

        1. `ExecAction` : 在容器内部执行一个命令, 如果该命令的退出码状态为 `0` , 则表明容器健康.
        2. `TCPSocketAction` : 通过容器的 IP 地址和端口号执行 TCP 检查, 如果端口能被方位, 则表明容器健康.
        3. `HTTPGetAction` : 通过容器的 IP 地址, 端口号, 及路径调用 HTTP GET 方法, 如果响应的状态码大于等于 200 且小于 400, 则认为容器状态健康.

    - `ReadinessProbe` 用于判断容器是否启动完成且准备接受请求.

        如果 `ReadinessProbe` 探针探测到失败, 则 Pod 的状态将被修改. Endpoint Controller 将从 Service 的 Endpoint 中删除包含该容器所在的 Pod 的 IP 地址的 Endpoint 条目.

4. cAdvisor 资源监控
    
    Kubernetes 集群中, 应用程序的执行情况可以在不同的级别上检测到, 这些级别包括:
    - 容器
    - pod
    - service 
    - 整个集群

    Heapster 项目为 Kubernetes 提供一个基本的监控平台, 他是集群级别的监控是时间数据集成器.

    Heapster 以 Pod 的方式运行在集群中, Heapster 通过kubelet 发现所有运行在集群中的节点, 并查看来自这些节点的资源使用情况. Heapster 通过带着关联标签的 Pod 分组这些信息, 这些数据将被推到一个可配置的后端, 用于存储和可视化展示. 支持的的后端包括 InfluxDB 和 Google Cloud Monitoring.

    cAdvisor 是一个开源的分析容器资源使用率和性能特性的代理工具, 已集成到 Kubernetes 代码中. 

    cAdvisor 自动查找所有在其所在节点上的容器, 自动采集 CPU, 内存 , 文件系统 和 网络使用的统计信息. cAdvisor 通过他所在节点机的 Root 容器, 采集并分析该节点机的全面使用情况.

    cAdvisor 通过其所在节点机的 4194 端口暴露一个简单的 UI.

    
5. 容器运行时(Container Runtime)
    
    容器运行时是 Kubernetes 最重要的组件之一, 负责真正管理镜像和容器的生命周期. Kubelet 通过 **Container Runtime Interface (CRI)** 与容器运行时交互, 以管理镜像和容器.

    - CRI

        Container Runtime Interface (CRI) 是 kubelet 1.5/1.6 中主要负责的一块项目, 他重新定义了 kubelet container runtime API, 将原来完全面向 Pod 级别的 API 拆分成 面向Sandbox 和 Container 的 API, 并分离镜像管理和容器引擎到不同的服务.

        ![kubelet cri](http://oluv2yxz6.bkt.clouddn.com/kube_cri.png)

    - Docker

        Docker runtime 的核心代码在 kubelet 内部, 是最稳定和特定支持最好的 Runtime.

    - Hyper

        Hyper 是一个基于 Hypervisor 的容器运行时, 为 kubernetes 带来了强隔离, 适用于多租户和运行不可信容器的场景.

        Hyper 在 Kubernetes 的集成项目为 [frakti](https://github.com/kubernetes/frakti), 目前已支持 Kubernetes v1.6+
    
    - Rkt

        Rkt 是另一个继承在 kubelet 内部的容器运行时.
    
    - Runc

        1. cri-containerd : 还在开发中,
        2. cri-o : 以支持 Kubernetes v1.6


##### 启动 kubelet 示例

    $ kubelet --kubeconfig=/etc/kubernetes/kubelet.conf \
        --require-kubeconfig=true \
        --pod-manifest-path=/etc/kubernetes/manifests \
        --allow-privileged=true \
        --network-plugin=cni \
        --cni-conf-dir=/etc/cni/net.d \
        --cni-bin-dir=/opt/cni/bin \
        --cluster-dns=10.96.0.10 \
        --cluster-domain=cluster.local \
        --authorization-mode=Webhook \
        --client-ca-file=/etc/kubernetes/pki/ca.crt \
        --feature-gates=AllAlpha=true


##### kubelet 工作原理
![kubelet 内部组件](http://oluv2yxz6.bkt.clouddn.com/kubelet.png)

kubelet 内部组件:
1. kubelet API
    - 认证API : 10250 
    - cAdvisor API : 4194
    - 只读 API : 10255
    - 健康检查 API : 10248

2. syncLoop 
    
    从 API 或者 manifest 目录接受 Pod 更新, 发送到 podWorkers 处理, 大量使用 channel 处理异步请求.

3. 辅助的 manager
    
    如 cAdvisor , PLEG, Volume Manager 等, 处理 syncLoop 以外的其他工作.

4. CRI
    
    容器执行引擎接口, 负责与 container runtime shim 通信.

5. 容器引擎插件
    
    如 dockershim, rkt 等.

6. 网络插件
    
    目前支持 CNI 和 kubenet.

#### kube-proxy 负责为Service提供cluster内部的服务发现和负载均衡；

每台机器上都运行一个 kube-proxy 服务, 他监听 API Server 中的 service 和 endpoint 的变化情况, 并通过 iptables 等来为服务配置负载均衡(仅支持 TCP 和 UDP). 

不支持 HTTP 路由, 并且也没有健康检查机制, 这些可以通过自定义 Ingress Controller 的方法来解决.

![kube-proxy](http://oluv2yxz6.bkt.clouddn.com/kube-proxy.png)

kube-proxy 运行方式 :
1. 直接运行在 物理机上
2. 以 static pod 方式运行
3. 以 daemonset 方式运行

kube-proxy 当前支持一下几种实现:
1. userspace : 在用户空间监听一个端口, 所有服务通过 iptables 转发到这个端口, 然后在其内部负载均衡到实际的 Pod.
    
    效率低, 有明显的 性能瓶颈.

2. iptables : 目前推荐方案, 完全以 iptables 规则的方式来实现 service 负载均衡.
    
    在服务多的时候, 产生太多的 iptables 规则, 大规模下也有性能问题.

3. winuserspace : 同 userspace , 但仅工作在 windows 上.

4. ipvs 方案: 正在讨论中, 尚未实现, 大规模情况下可以大幅提高性能.

启动示例:
    $ kube-proxy --kubeconfig=/var/lib/kube-proxy/kubeconfig.conf

#### kube DNS : 为集群提供命名服务, 作为 addon 的方式部署

![kube-dns](http://oluv2yxz6.bkt.clouddn.com/kube-dns.png)

##### 支持的 DNS 格式:

1. Service
    - `A record` : 生成 `my-svc.my-namespace.svc.cluster.local`.

        解析 IP 分为两种情况:
        1. 普通 Service 解析为 Cluster IP
        2. Headless Service 解析为指定的 Pod IP 列表

    - `SRV record` : 生成  `_my-port-name._my-port-protocol.my-svc.my-namespace.svc.cluster.local`
2. Pod 
    - `A record` : `pod-ip-address.my-namespace.pod.cluster.local`
    - `hostname` 和 `subdomain` : `hostname.custom-subdomain.default.svc.cluster.local`

            apiVersion: v1
            kind: Pod
            metadata:
              name: busybox2
              labels:
                name: busybox
            spec:
              hostname: busybox-2
              subdomain: default-subdomain
              containers:
              - image: busybox
                command:
                  - sleep
                  - "3600"
                name: busybox

##### 组件及启动示例
kube-dns 由三个容器组成:

1. kube-dns : DNS 服务的核心组件, 主要有 KubeDNS 和 SkyDNS 组成.
    
    - KubeDNS 负责监听 Service 和 Endpoint 的变化情况, 并将相关的信息更新到 SkyDNS 中.

    - SkyDNS 负责 DNS 解析, 监听在 10053 端口(TCP/UDP), 同时也监听在 10055 端口提供 metrics.

    - kube-dns 还监听 8081 端口, 以供健康检查使用.

2. dnsmasq-nanny : 负责启动 dnsmasq , 并在配置发生变化是重启 dnsmasq
    
    dnsmasq 的 upstream 为 SkyDNS, 即集群内部的 DNS 解析有 SkyDNS 负责.

3. sidecar : 复则健康检查和提供 DNS metrics (监听 10054 端口)

启动示例:
        
    # kube-dns container
    $ kube-dns --domain=cluster.local. --dns-port=10053 --config-dir=/kube-dns-config --v=2

    # dnsmasq container
    $ dnsmasq-nanny -v=2 -logtostderr -configDir=/etc/k8s/dns/dnsmasq-nanny -restartDnsmasq=true -- -k --cache-size=1000 --log-facility=- --server=127.0.0.1#10053

    # sidecar container
    $ sidecar --v=2 --logtostderr --probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.cluster.local.,5,A --probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.cluster.local.,5,A

#### Federation
在云计算环境中，服务的作用距离范围从近到远一般可以有：同主机（Host，Node）、跨主机同可用区（Available Zone）、跨可用区同地区（Region）、跨地区同服务商（Cloud Service Provider）、跨云平台。

K8s的设计定位是单一集群在同一个地域内，因为同一个地区的网络性能才能满足K8s的调度和计算存储连接要求。而集群联邦（Federation）就是为提供跨Region跨服务商K8s集群服务而设计的。

每个Federation有自己的分布式存储、API Server 和 Controller Manager。用户可以通过Federation的API Server注册该Federation的成员K8s Cluster。

当用户通过Federation的API Server创建、更改API对象时，Federation API Server会在自己所有注册的子K8s Cluster都创建一份对应的API对象。在提供业务请求服务时，K8s Federation会先在自己的各个子Cluster之间做负载均衡，而对于发送到某个具体K8s Cluster的业务请求，会依照这个K8s Cluster独立提供服务时一样的调度模式去做K8s Cluster内部的负载均衡。而Cluster之间的负载均衡是通过域名服务的负载均衡来实现的。

所有的设计都尽量不影响K8s Cluster现有的工作机制，这样对于每个子K8s集群来说，并不需要更外层的有一个K8s Federation，也就是意味着所有现有的K8s代码和机制不需要因为Federation功能有任何变化。

![federation api ](http://oluv2yxz6.bkt.clouddn.com/federation-api-4x.png)

组件:
- `federation-apiserver` : 类似kube-apiserver，但提供的是跨集群的REST API
- `federation-controller-manager` : 类似kube-controller-manager，但提供多集群状态的同步机制
- `kubefed` : Federation管理命令行工具

##### 部署方法
    
    # 下载 kubefed 和 kubectl
    $ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/kubernetes-client-linux-amd64.tar.gz
    $ tar -xzvf kubernetes-client-linux-amd64.tar.gz

    # 初始化主集群
    # 选择一个已部署好的 Kubernetes 集群作为主集群, 作为集群联邦的控制平面, 并配置好本地的 kubeconfig, 然后运行 kubefed inti 来初始化集群
    $ kubefed init fellowship \
        --host-cluster-context=rivendell \   # 部署集群的kubeconfig配置名称
        --dns-provider="google-clouddns" \   # DNS服务提供商，还支持aws-route53或coredns
        --dns-zone-name="example.com." \     # 域名后缀，必须以.结束
        --apiserver-enable-basic-auth=true \ # 开启basic认证
        --apiserver-enable-token-auth=true \ # 开启token认证
        --apiserver-arg-overrides="--anonymous-auth=false,--v=4" # federation API server自定义参数
    $ kubectl config use-context fellowship
    
#### hyperkube

#### kubeadm

#### kubectl

## 参考资料
[kubernetes handbook](https://jimmysong.io/kubernetes-handbook/)