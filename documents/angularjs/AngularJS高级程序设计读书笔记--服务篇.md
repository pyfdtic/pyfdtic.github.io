---
title: AngularJS高级程序设计读书笔记--服务篇
date: 2018-03-16 17:07:35
categories:
- JavaScript
tags:
- angularjs
- 前端框架
---
服务是提供在整个应用程序中所使用的任何功能的单例对象.
**单例 :** 只用一个对象实例会被 AngularJS 创建出来, 并被程序需要服务的各个不同部分所共享.

## 一. 内置服务
一些关键方法也被 AngularJS 成为服务. 如 $scope, $http.

## 二. 自定义服务
### 1. Module.service(name, constructor)

service 方法由两个参数: 服务名和调用后用来创建服务对象的工厂函数. 当 AngularJS 调用工厂函数时, 会分配一个可通过 this 关键字访问的新对象, 我们就可以使用这个对象来定义 today 和 tomorrow 属性.

示例代码: 
```
<!DOCTYPE html>
<html ng-app="exampleApp">
<head>
    <title>AngularJS Demo</title>
    <link href="bootstrap.css" rel="stylesheet" />
    <link href="bootstrap-theme.css" rel="stylesheet" />
    <script src="angular.js"></script>
    <script>

        var myApp = angular.module("exampleApp", []);

        myApp.controller("dayCtrl", function ($scope, days) {   // 依赖注入服务
            $scope.day = days.today;
        });

        myApp.controller("tomorrowCtrl", function ($scope, days) {  // 依赖注入服务
            $scope.day = days.tomorrow;
        });

        myApp.directive("highlight", function ($filter) {

            var dayFilter = $filter("dayName");
            
            return function (scope, element, attrs) {
                if (dayFilter(scope.day) == attrs["highlight"]) {
                    element.css("color", "red");
                } 
            }
        });
         
        myApp.filter("dayName", function () {
            var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday",
                            "Thursday", "Friday", "Saturday"];
            return function (input) {
                return angular.isNumber(input) ? dayNames[input] : input;
            };
        });

        myApp.service("days", function () {     // 创建服务
            this.today = new Date().getDay();
            this.tomorrow = (this.today + 1)%7;
        });

    </script>
</head>
<body> 
    <div class="panel">
        <div class="page-header">
            <h3>AngularJS App</h3>
        </div>
        <h4 ng-controller="dayCtrl" highlight="Monday">
            Today is { {day || "(unknown)" | dayName} }
        </h4>
        <h4 ng-controller="tomorrowCtrl">
            Tomorrow is { {day || "(unknown)" | dayName} }
        </h4>
    </div>
</body>
</html>
```
### 2. Module.factory(name, provider)

### 3. Module.provider(name, type)

### 4. Module.value(name, value)
用于创建返回固定值和对象的服务, 这意味着可以为任何值或对象使用依赖注入, 而不仅仅是 module 方法创建的那些对象.

示例代码:
```
<script>
    var myAPP = angular.module("exampleApp", [])
    var now = new Date();   // 将 Date() 对象赋给自定义的 now 变量
    myApp.value("nowValue", now)    // 创建一个值服务

    myApp.service("days", function(nowValue){   // 定义对 nowValue 服务的依赖.
        this.today = nowValue.getDay();
        this.tomorrow = this.today + 1;
    });
</script>
```