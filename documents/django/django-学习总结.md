---
title: Django 学习总结
date: 2018-03-14 23:32:35
categories:
- Python
tags:
- web development
- django
- PyPi
top: 2
---
## [The Django Book 2.0](http://djangobook.py3k.cn/2.0/)
- 官网: [http://djangobook.com/the-django-book/](http://djangobook.com/the-django-book/)
- 中文: [http://djangobook.py3k.cn/2.0/](http://djangobook.py3k.cn/2.0/)
- 英文: [http://djangobook-cn.readthedocs.io/en/latest/](http://djangobook-cn.readthedocs.io/en/latest/)

## [django 之零 入门篇](http://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E9%9B%B6--%E5%85%A5%E9%97%A8%E7%AF%87/)
1. 安装 django
2. 开始一个项目
3. urls
4. 命令汇总

## [django 之一 视图篇](http://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E4%B8%80--%E8%A7%86%E5%9B%BE%E7%AF%87/)
1. Django 请求处理流程
2. 视图函数
3. 配置视图函数: URLconf
3.1 URLpattern 语法:
3.2 URLpattern 支持的正则表达式
3.3 URL 配置和松耦合
4. 动态 URL

## [django 之二 模板使用篇](http://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E4%BA%8C--%E6%A8%A1%E6%9D%BF%E7%AF%87/)
1. 概述
2. 变量
3. 复杂数据类型
3.1 列表索引
3.2 字典
3.3 属性
3.4 方法
3.5 深层嵌套
3.6 `context` 对象
4. 标签
4.1 `if/else`
4.2 `for` 循环
4.3 `ifequal/ifnotequal`
5. 注释
5.1 单行注释
5.2 多行注释
6. 过滤器
7. 模板加载与模板目录: `{ % include % }`
8. 模板继承 : `{ % extends % }`

## [django 之三 模板原理扩展篇](http://www.pyfdtic.com/2018/03/16/django-%E6%A8%A1%E6%9D%BF%E5%8E%9F%E7%90%86%E5%8F%8A%E6%89%A9%E5%B1%95/)
1. RequestContext 和 Context 处理器
1.1 Context
1.2 RequestContext
2. 模板加载器
2.1 加载模板相关变量
2.2 默认加载模板方法
2.3 其他模板加载器
3. 扩展模板系统
3.1 创建模板库(Django 能够导入的基本结构)
3.1.1 决定模板库应该放在哪个 Django 应用下.
3.1.2 在适当的 Django 应用包里创建一个 templatetags 目录.
3.1.3 在 templatetags 中创建两个空文件:
3.1.4 自定义模板过滤器
3.1.5 自定义模板标签
3.1.5.1 编写编译函数
3.1.5.2 编写模板节点
3.1.5.3 注册标签
3.1.5.4 在上下文中设置变量
3.1.5.5 标签对 : 分析直至另一个模板标签
3.1.5.6 简单标签的快捷方式: django.template.Library.simple_tag()
3.1.5.7 包含标签: 通过渲染其他模板显示数据.
4. 编写自定义模板加载器

## [django 之四 模型篇](http://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E4%B8%89--%E6%A8%A1%E5%9E%8B%E7%AF%87/)
1. MTV
2. 数据库配置
3. django models & app :
4. 模型安装与基本使用
4.1. 在 Django 项目中激活这些模型: 将 books app 添加到配置文件的已安装应用列表中即可.
4.2. 验证模型的有效性
4.3. 生成数据库
4.4. 基本数据访问
5. 外键与多对多关系
5.1 外键
5.1.1 从多的一端查询一, 返回相关的数据模型对象.
5.1.2 从一的一端查询多, 需要使用 QuerySet 对象
5.2 多对多关系
6. 更改数据库模式( Database Schema)
6.1. 添加字段
6.2. 删除字段
6.3. 删除多对多关联字段
6.4. 删除模型
7. Managers : 模型对象的行级别功能
7.1 增加额外的 Manager 方法
7.2 修改初始 Manager QuerySet
8. 模型方法: 模型对象的行级别功能
9. 执行原始 SQL 查询

## [django 之五 管理工具 Admin](http://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E5%9B%9B--Admin%E7%AE%A1%E7%90%86%E5%B7%A5%E5%85%B7/)
1. 概述
1.1 简介
1.2 Admin 工作原理
2. `django.contrib`
3. 使用 Admin
3.1 基本使用
3.1.1 激活
3.1.2 将 Model 添加到 Admin 管理中
3.2 字段选项
3.2.1 `blank=True` : 字段可选
3.2.2 `blank=True`,`null=True` : 日期型和数字型字段可选
3.2.3 `verbose_name=NAME` : 自定义字段标签
4. 自定义 ModelAdmin 类
4.1 自定义列表 : `list_display`,`search_fields`
4.2 字段过滤器
4.3 日期过滤器: `date_hierarchy`
4.4 排序: `ordering`
4.5 自定义编辑表单
4.5.1 自定义字段顺序: `field`
4.5.2 多选框: `filter_horizontal`,`filter_vertical` --> 用于多对多字段
4.5.3 文本框: `raw_id_fields` --> ForeignKey
5. 用户, 用户组, 权限

## [django 之六 表单篇](http://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E4%BA%94--%E8%A1%A8%E5%8D%95/)
进行中 ... ... 

## [django 之七 部署篇](http://www.pyfdtic.com/2018/03/16/django%E4%B9%8B%E5%85%AD--%E9%83%A8%E7%BD%B2%E7%AF%87/)
进行中 ... ...