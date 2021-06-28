# 开源项目

## [Konveyor](http://www.konveyor.io/)
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

## [kspan](https://github.com/weaveworks-experiments/kspan)
将 kubenetes evnets 转为 OpenTelemetry Spans, 方便在 Jaeger 中呈现.
