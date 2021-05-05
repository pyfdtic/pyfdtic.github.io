---
title: AWS-IAM权限控制
date: 2018-03-15 17:20:02
categories:
- AWS
tags:
- IAM
---
AWS 的认证与权限管理服务
<!-- more -->

# IAM 与 权限访问控制机制

IAM , Identity and Access Management

### 基本概念

###### ARN, Amazon Resource Name : 
在 AWS 里, 创建的任何资源都有其全局唯一的 ARN, 是访问控制可以到达的最小粒度.

###### users, 用户

###### groups, 组
    将用户添加到一个群组中, 可以自动获得这个群组的所有权限.

###### roles, 角色
没有任何访问凭证(密码或密钥), 他一般被赋予某个资源(包括用户), 那时起临时具有某些权限.

角色的密钥是动态创建的, 更新和失效都无需特别处理.


###### permissions, 权限, 

    权限可以赋给 用户,组, roles,
    
    权限通过 policy document 描述, 

### policy, 是描述权限的一段 JSON 文本. 示例如下

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "*",
          "Resource": "*"
        }
      ]
    }   

用户或者群组只有添加了相关的 policy才会有响应的权限.

policy 是 IAM 的核心内容. 是 JSON 格式来描述, 主要包含 Statement, 也就是 policy 拥有的权限的陈诉. 一言以蔽之: *谁*在什么*条件*下能对哪些*资源*的哪些*操作*进行*处理*。

policy 的 PARCE 原则 : 

- Principal : 谁  -- 单独创建的 policy 是不需要指明 Principal 的, 当该 policy 被赋给用户,组或者 roles 时, principal 自动创建. 
- Action : 那些操作
- Resource : 那些资源
- Condition : 什么条件
- Effect : 如何处理 (Allow/Deny)

示例  

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:Get*",
            "s3:List*"
          ],
          "Resource": "*"
        }
      ]
    }
    
    在这个policy里，Principal和Condition都没有出现。如果对资源的访问没有任何附加条件，是不需要Condition的；而这条policy的使用者是用户相关的principal（users, groups, roles），当其被添加到某个用户身上时，自然获得了principal的属性，所以这里不必指明，也不能指明。


Resource policy，它们不能单独创建，只能依附在某个资源之上（所以也叫inline policy），这时候，需要指明Principal。 示例如下 : 

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::corp-fs-web-bucket/*"
            }
        ]
    }

    当我希望对一个S3 bucket使能Web hosting时，这个bucket里面的对象自然是要允许外界访问的，所以需要如下的inline policy：

Condition 示例

    "Condition": {
        "IPAddress": {"aws:SourceIP": ["10.0.0.0/8", "4.4.4.4/32"]},
        "StringEquals": {"ec2:ResourceTag/department": "dev"}
    }

    "Condition": {
        "StringLike": {
            "s3:prefix": [
                "tyrchen/*"
            ]
        }
    }   

    ** 在一条Condition下并列的若干个条件间是and的关系，这里IPAddress和StringEquals这两个条件必须同时成立；
    ** 在某个条件内部则是or的关系，这里10.0.0.0/8和4.4.4.4/32任意一个源IP都可以访问。


Policy 执行规则 :

- 默认情况下，一切资源的一切行为的访问都是Deny
- 如果在policy里显式Deny，则最终的结果是Deny
- 否则，如果在policy里是Allow，则最终结果是Allow
- 否则，最终结果是Deny

![IAM Policy Enforcement](/imgs/aws/iam/iam_policy_enforcement.jpg)