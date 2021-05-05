---
title: AWS-S3
date: 2018-03-15 17:22:31
categories:
- AWS
tags:
- S3
---
AWS 的数据存储服务
<!-- more -->
# S3

使用 S3 创建公司内部的文件服务器, 保存员工私人/共享文件, 并以类似 Dropbox 的方式双向同步.

### S3 介绍

S3 是 AWS 最早发布的诸多服务之一, 用作**可信**存储.  

    可信 : 在指定年度内, 为对象提供 99.999999999% 的持久性和 高达 99.99% 的可用性.

S3 提供如下特性 :

- 跨区域复制 :   
    只需要简单的配置，存储于S3中的数据会自动复制到选定的不同区域中。当你的数据对象的收集分散在不同的区域，而处理集中在某些区域时非常有用。

- 事件通知 :   
    当数据对象上传到 Amazon S3 中或从中删除的时候会发送事件通知。事件通知可使用 SQS 或 SNS 进行传送，也可以直接发送到 AWS Lambda 进行处理。

- 版本控制 :   
    数据对象可以启用版本控制，这样你就可以很方便地进行回滚。对于应用开发者来说，这是个特别有用的特性。
- 加密  
    S3的访问本身是支持 SSL（HTTPS）的，保证传输的安全，对于数据本身，你可以通过Server side encryption（AES256）来加密存储在S3的数据。

- 访问管理  
    通过 IAM/VPC 可以控制S3的访问粒度，你甚至可以控制一个bucket（S3对数据的管理单元，一个bucket类似于一组数据的根目录）里面的每个folder，甚至每个文件的访问权限。

- 可编程  
    可以使用 AWS SDK 进行客户端或者服务端的开发。

- 成本监控和控制  
    S3 有几项管理和控制成本的功能，包括管理成本分配的添加存储桶标签和接收账单警报的 Amazon Cloud Watch 集成。

- 灵活的存储选项  
    - S3 Standard，
    - Standard–Infrequent Access 选项可用于非频繁访问数据，存储的价格大概是 Standard 的 2/5。
    - Glacier : 用于存储冷数据（如N年前的Log），价格在 Standard 的 1/4，缺点是需要几个小时来恢复数据。

### S3 操作方式

##### console

##### AWS CLI
创建 bucket

    aws s3api create-bucket --bucket <name>

删除 bucket

    aws s3api delete-bucket --bucket <name>

像使用一般文件系统一样操作 S3
    
    aws s3 ls
    aws s3 cp
    aws s3 rm

本地文件 与 S3 上文件同步 :

    aws s3 sync ./local_dir s3://my_bucket/my_dir

##### AWS SDK
使用的一般流程 :

    ① 创建 AWS Connection (需要 access key)
    ② 使用 connection 创建 S3 对象
    ③ 使用 S3 API 进行各种操作.
 
### 使用 S3 的典型场景
##### 存储用户上传的文件, 如照片,视频等静态内容
##### 单做一个 k-v 存储, 承担简单的数据库服务功能
##### 数据备份
##### 静态网站的托管 : 可以对一个 bucket 使能 Web Hosting.


[参考](http://www.infoq.com/cn/articles/aws-s3-dive-in)