---
title: django之五--表单
date: 2018-03-16 16:59:19
categories:
- Python
tags:
- web development
- django
---
`HttpRequest`对象 和 `Form`对象

## `HttpRequest` 对象
`HttpRequest`对象包含当前请求URL的一些信息.

| 属性/方法 | 说明 | 举例 |
| --- | --- | --- |
| request.path | 除域名以外的请求路径, 以正斜杠开头. | `/hello/` |
| request.get_host() | 主机名, 域名 | `127.0.0.1:8000` or `www.example.com` |
| request.get_full_path() | 请求路径, 可能包含查询字符串 | `/hello/?print=true` |
| request.is_secure() | 如果通过 HTTPS 访问, 则该方法返回 True, 否则返回 False | `True/False` |
| request.META | 一个 字典, 包含所有本次HTTP请求的Header信息.|"" |
| request.GET | 用户提交信息, 可能来自`<form>`提交,也可能来自URL中的查询字符串. |  |
| request.POST | 用户提交信息, 来自`<form>`标签的提交. |  |

**注意**: 
1. request.META 所包含的Header信息的完整列表取决于用户所发送的 Header 信息和服务端设置的 Header 信息. HTTP Header 信息是由用户的浏览器提交的, 不应该给予信任的额外数据.因为 request.META 是一个普通的字典, 所以当试图访问一个不存在的键时, 会触发一个`KeyError`异常, 应当使用 `try/except`语句或者`dict.get()`方法来处理 request.META 字典.
    
        def ua_dispaly_v1(request):
            try:
                ua = request.META["HTTP_USER_AGENT"]
            except KeyError:
                ua = "unknown"
            return HttpResponse("You browser is %s" % us)

        def ua_dispaly_v1(request):
            ua = request.META.get("HTTP_USER_AGENT", "unknown")
            return HttpResponse("You browser is %s" % us)

2. 类字典对象 : `request.GET` 和 `request.POST`是类字典对象, 即他们的行为像 Python 标准的字典对象, 但在技术底层上, 他们不是标准字典数据. 如 `request.GET` 和 `request.POST` 都有 `get()`,`keys()`,`values()`方法, 可以被迭代等. 同时, `request.GET` 和 `request.POST`也有一些标准字典没有的方法.

## 一个简单的表单处理示例

## 改进表单

## 表单验证

## Contact 表单

## Form 类

## 在视图中使用 Form 对象

## 改变字段显示

## 设置最大长度

## 设置初始值

## 自定义校验规则

## 指定标签

## 定制 Form 设计