# kubernetes awesome tools

个人用过的比较好的工具/项目.

## 集群篇
### 1. [minikube](https://github.com/kubernetes/minikube)

```shell
# docker 模式
$ minikube start --kubernetes-version='v1.18.8' --image-repository="registry.cn-hangzhou.aliyuncs.com/google_containers"

# vm 模式
$ minikube start --kubernetes-version='v1.18.8' --image-repository="registry.cn-hangzhou.aliyuncs.com/google_containers" --vm=true

# 使用 aliyun image repo, 会导致 storage-provider 启动失败, 可通过以下方式解决
$ kubectl patch pod storage-provisioner -p '{"spec":{"containers":[{"name":"storage-provisioner","image":"registry.cn-hangzhou.aliyuncs.com/google_containers/storage-provisioner:v5"}]}}' -n kube-system
```

### 2. [kind]((https://github.com/kubernetes-sigs/kind)): kubernetes in docker
kubernetes in docker

### 3. k3s && k3d
#### 3.1 [k3s]((https://github.com/k3s-io/k3s)) 精简版 kubernetes

#### 3.2 [k3d]((https://github.com/rancher/k3d)) : 多 k3s 集群管理工具

### 4. [Rancher](https://github.com/rancher/rancher)

多集群 kubernetes web 管理工具.

### 5. [kubeadm](https://github.com/kubernetes/kubeadm)

生产部署推荐

## 工具篇
### 1. kubectl plugin
1. 可执行文件, 并且位于 PATH 目录下.
2. 名称为 `kubectl-XXX`
3. [krew](https://github.com/kubernetes-sigs/krew) 工具, 需要翻墙, 慢

### 2. [kubectx & kubens](https://github.com/ahmetb/kubectx)
- `kubectx`: 多集群 kubeconfig 管理/切换
- `kubens`: 多 Namespace 切换

### 3. [k9s](https://github.com/derailed/k9s)
命令行管理 kubernetes 工具

配置示例参考:
```yaml
k9s:
  refreshRate: 5
  maxConnRetry: 5
  enableMouse: false
  headless: true
  logoless: false
  crumbsless: false
  readOnly: false
  noIcons: false
  logger:
    tail: 100
    buffer: 5000
    sinceSeconds: 60
    fullScreenLogs: false
    textWrap: false
    showTime: false
  currentContext: minikube
  currentCluster: minikube
  clusters:
    minikube:
      namespace:
        active: all
        favorites:
        - all
        - default
      view:
        active: pods
      featureGates:
        nodeShell: false
      shellPod:
        image: busybox:1.31
        command: []
        args: []
        namespace: default
        limits:
          cpu: 100m
          memory: 100Mi
      portForwardAddress: localhost
  thresholds:
    cpu:
      critical: 90
      warn: 70
    memory:
      critical: 90
      warn: 70
```

### 4. [kt-connect](https://github.com/alibaba/kt-connect)
通过 VPN/Socket5 本地连接集群调试工具

## 其他开源项目

### 1. [Konveyor](http://www.konveyor.io/)
旨在通过构建工具、识别模式和提供关于如何跨 IT 进行云原生转型的建议，帮助对开放混合云应用程序进行现代化和迁移。

Konveyor 项目的目标是通过 [OperatorHub.io](https://operatorhub.io/) 提供 Konveyor 的交付工具和应用程序，简化使用和生命周期管理。

Konveyor 还支持越来越多的工具，这些工具的设计都是为了加速 Kubernetes 的采用。如
- [Crane](https://github.com/konveyor/mig-operator): 关注于在 Kubernetes 集群之间迁移应用程序。很多时候，开发人员和操作团队希望在 Kubernetes 的旧版本和新版本之间进行迁移，转移一个集群或迁移到不同的底层基础设施。
    许多用户需要一个解决方案来持续迁移 Kubernetes 命名空间中的持久数据和对象。
- [Move2Kube](https://konveyor.io/move2kube/): 将现有工件转换为 Kubernetes 原生概念，提高了组织在 Kubernetes 上运行应用程序的速度和能力。
- [Tackle](https://github.com/konveyor/tackle-application-inventory) : 旨在提供工具来帮助评估和分析应用程序，以便将其重构为容器，并提供一个公共目录。Tackle 背后的团队利用他们使用 [Pathfinder](https://github.com/redhat-cop/pathfinder) 和 [Windup](https://github.com/windup) 等工具的经验来指导他们在应用程序上的工作，将现有的最佳流程和策略引入云原生领域。
- [Pelorus](https://github.com/redhat-cop/pelorus): 支持指标驱动的转型，并度量软件交付性能的关键指标，包括变更的交付时间、部署频率、恢复的平均时间和变更失败率。
- [Forklift](https://github.com/konveyor/forklift-operator): 将虚拟机迁移到 Kubernetes，并提供了将虚拟机迁移到 KubeVirt 的能力，同时最小化停机时间。
- [KubeVirt](https://kubevirt.io/): 允许开发人员和运营团队获得 Kubernetes 编配和周围生态系统的好处，而不需要更改代码或配置。

### 2. [kspan](https://github.com/weaveworks-experiments/kspan)
将 kubenetes evnets 转为 OpenTelemetry Spans, 方便在 Jaeger 中呈现.

### 3. [Dragonfly](https://github.com/dragonflyoss/Dragonfly): p2p 镜像拉取
