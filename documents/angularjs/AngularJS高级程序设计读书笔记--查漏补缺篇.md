---
title: AngularJS高级程序设计读书笔记--查漏补缺篇
date: 2018-04-12 16:12:33
categories:
- JavaScript
tags:
- angularjs
- 前端框架
---

## 一. AngularJS $http 服务实现跨域请求

AngularJS 实现跨域的方式类似于 Ajax, 使用 CORS 机制.

AngularJS XMLHttpRequest `$http` 用于读取远程服务器的数据. 用法如下:

```JavaScript
$http.post(url, data, [config]).success(function(){...});
$http.get(url, [config]).success(function(){...});
```

### 1. `$http.jsonp` 实现跨域

- 指定 callback 和 回调函数名, 函数名为 JSON_CALLBACK 时, 会调用 success 回调函数, JSON_CALLBACK 必须**全为大写**, 
- 指定其他回调函数, 但必须是定义在 windows 下的全局函数. url 中必须加 callback.

### 2. `$http.get` 实现跨域

- 在服务端设置允许在其他域名下访问:
        
    ```JavaScript
    response.setHeader("Access-Controll-Allow-Origin", "*")     // 允许所有域名访问
    response.setHeader("Access-Control-Allow-Origin", "http://www.123.com")     // 允许 www.123.com 访问
    ```

- AngularJS 端使用 `$http.get()`

### 3. `$http.post` 实现跨域

- 在服务端设置允许在其他域名下访问, 及响应类型, 响应头设置
    
    ```JavaScript
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Origin", "POST");
    response.setHeader("Access-Control-Allow-Origin", "x-requested-with, content-type");
    ```
- AngularJS 端调用 `$http.post()`, 同时设置头信息.

    ```JavaScript
    $http.post("http://localhost/ajax/getAllRes.pt", {languateColume: "name_eu"}, {"Content-Type": "application/x-www-form-urlencoded"}).success(function(data){
        $scope.industries = data;
    });
    ```

**参考文档**
- [AngularJS 实现跨域请求](https://blog.csdn.net/ligang2585116/article/details/44781227)

## 二. 配置 Basic 认证

[angular-base64](https://github.com/ninjatronic/angular-base64)

```
angular
    .module('myApp', ['base64'])
    .config(function($httpProvider, $base64) {
        var auth = $base64.encode("foo:bar");
        $httpProvider.defaults.headers.common['Authorization'] = 'Basic ' + auth;
    })
```