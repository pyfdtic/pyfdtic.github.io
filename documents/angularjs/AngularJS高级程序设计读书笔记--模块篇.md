---
title: AngularJS高级程序设计读书笔记--模块篇
date: 2018-03-16 17:09:08
categories:
- JavaScript
tags:
- angularjs
- 前端框架
---
# 一. 模块基础
## 1. 创建模块
```
<!DOCTYPE html>
<html ng-app="exampleApp">
<head>
    <title>Test</title>
    <script type="text/javascript">
        var myApp = angular.module("exampleApp", []);
        myApp.controller('dayCtrl', function ($scope) {
            // controller statements will go here
        });
    </script>
</head>
<body>
    <div class="panel" ng-controller="dayCtrl">
        <!-- HTML code here -->
    </div>
</body>
</html>
```
模块的三种重要角色:

- 将一个 AngularJS 应用程序 与 HTML 文档中的一部分相关联
- 起到通往 AngularJS 框架的关键特性的门户作用.
- 帮助组织一个 AngularJS 应用程序中的代码和组件.

angular.module 方法所接受的**参数**

| 名称     |   描述 |
| ---      | ---    |
| name     |   新模块的名称 |
| requires |   该模块所以来的模块集合 |
| config   |   盖默快的配置, 等效于调用 Module.config 方法. |

angular.module 方法返回一个 Module 对象. 该 Module 对象的**成员方法**如下表:

| 名称                            |   描述 |
| ---                            | ---    |
| animation(name, factory)       |   支持动画特性, 见 第23章   |
| config(callback)               |   注册一个在模块加载时对该模块进行配置的函数,见 9.4.1    |
| constant(key, value)           |   定义一个返回一个常量的服务, 见 9.4.1  |
| controller(name, constructor)  |   创建一个控制器, 见 13 章 |
| directive(name, factory)       |   创建一个指令, 对标准HTML词汇进行扩展, 见 15-17 章 |
| factory(name, provider)        |   创建一个服务, 见 14 章 |
| filter(name, factory)          |   创建一个对显示给用户的数据进行格式化的过滤器.见 14 章 |
| provider(name, type)           |   创建一个服务. |
| name                           |   返回模块名称 |
| run(callback)                  |   注册一个在 Angular 加载完毕后用于对所有模块进行配置的函数. |
| service(name, constructor)     |   创建一个服务 |
| value(name, value)             |   定义一个返回一个常量的服务. |
|**factory, service, provider 的区别** |   见 14,18 章 |

可以按照任何顺序创建组件, AngularJS 将保证在开始调用工厂函数和执行依赖注入之前一切都已正确创建.

## 2. fluent API
Module 对象定义的方法返回的结果仍然是 Module 对象本身. 这是的能够使用 fluent API , 即多个方法调用可以链式调用链接在一起.
如下示例: 

    <script type="text/javascript">
        angular.module('exampleApp', [])
            .controller('dayCtrl', ['$scope', function ($scope) {
                var dayName = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Staturday"]
                $scope.day = dayName[new Date().getDay()];
            }])
            .controller('tomorrowCtrl', ['$scope', function ($scope) {
                var dayName = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Staturday"]
                $scope.day = dayName[(new Date().getDay() + 1) % 7]
            }])
    </script>

    # angular.module 方法得到 Module 对象作为返回结果, 在这个对象上直接调用 controller 方法创建 dayCtrl 控制器. 从 controller 方法得到的结果与调用 angular.module 方法得到的结果是同一个 Module 对象, 所以可以使用它调用 controller 方法来创建 tomorrowCtrl .


## 3. ng-app 与 模块
将 ng-app 指令应用到 HTML 中. ng-app 属性是在 AngularJS 生命周期的 bootstrap 阶段被使用.

## 4. 模块创建/查找陷阱
```
var myApp = angular.module('exampleApp');       # 查找名称为 exampleApp 的模块
var myApp = angular.module('exampleApp', []);   # 创建名称为 exampleApp 的模块
```
# 二. 使用模块组织代码

## 1. 模块依赖
任何 AngularJS 模块都可以依赖于在其他模块中定义的组件, 在复杂的应用程序中这是一个能够使得组织代码更为容易的特性.

模块的定义可以按照任何顺序定义. AngularJS 会加载定义在程序中的所有模块并解析依赖, 将每个模块中包含的构件进行合并.这个合并使得无缝的使用来来自其他模块的功能成为可能.
```

<script>
    var controllersModule = angular.module("exampleApp.Controllers", [])

    controllersModule.controller("dayCtrl", function ($scope, days) {
        $scope.day = days.today;

    });

    controllersModule.controller("tomorrowCtrl", function ($scope, days) {
        $scope.day = days.tomorrow;
    });


    angular.module("exampleApp.Filters", []).filter("dayName", function () {
        var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday",
                        "Thursday", "Friday", "Saturday"];
        return function (input) {
            return angular.isNumber(input) ? dayNames[input] : input;
        };
    });      
      
    var myApp = angular.module("exampleApp",
        ["exampleApp.Controllers", "exampleApp.Filters",
         "exampleApp.Services", "exampleApp.Directives"]);  // 依赖注入. 

    angular.module("exampleApp.Directives", [])
        .directive("highlight", function ($filter) {

            var dayFilter = $filter("dayName");

            return function (scope, element, attrs) {
                if (dayFilter(scope.day) == attrs["highlight"]) {
                    element.css("color", "red");
                }
            }
        });

     
    var now = new Date();
    myApp.value("nowValue", now);

    angular.module("exampleApp.Services", [])
        .service("days", function (nowValue) {
            this.today = nowValue.getDay();
            this.tomorrow = this.today + 1;
        });

</script>

// 模块的定义可以按照任何顺序定义. AngularJS 会加载定义在程序中的所有模块并解析依赖, 将每个模块中包含的构件进行合并.这个合并使得无缝的使用来来自其他模块的功能成为可能.如 exmapleApp.service 模块中的 days 服务依赖来自于 exampleApp 模块中的 nowValue 值服务, exmapleApp.directives 模块中指令依赖于来自 exampleApp.filter 模块中的过滤器.
```
## 2. Module.controller(name, constructor) 控制器

控制器是模型和视图之间的桥梁.

### 2.1 多个视图
每个控制器可以支持多个视图, 者语序同一份数据以多种不同的形式展现, 或者有效的创建和管理紧密相关的数据.

```
<!DOCTYPE html>
</html>
<html ng-app="exampleAPP">
    <head>
        <title>Hello AngularJS</title>
        <link rel="stylesheet" type="text/css" href="bootstrap.css">
        <link rel="stylesheet" type="text/css" href="bootstrap-theme.css">
        <script src='js/angular.js'></script>
        <script type="text/javascript">
            var myApp = angular.module("exampleAPP", []);
            myApp.controller('dayCtrl', ['$scope', function ($scope) {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                $scope.dat = dayNames[new Date().getDay()];
                $scope.tomorrow = dayNames[(new Date().getDay() + 1) % 7];
                
            }]);
        </script>
    </head>
    <body>
        <div class="panel">
            <div class="page-header">
                <h3> AngularJS App</h3>
                <h4 ng-controller="dayCtrl">Today is {{day || "(unknown)"}} </h4>
                <h4 ng-controller="dayCtrl">Tomorrow is {{tomorrow || "(unknown)"}} </h4>
            </div>
        </div>
    </body>
</html>
```

### 2.2 多个控制器
在多个控制器的场景下, 每个控制器负责程序功能的不同方面,  并且都具有自己的关于整个应用程序的作用域的一部分, 各自属性相互隔离.
```
<!DOCTYPE html>
<html ng-app="exampleAPP">
    <head>
        <title>Hello AngularJS</title>
        <!-- <link rel="stylesheet" type="text/css" href="bootstrap.css">
        <link rel="stylesheet" type="text/css" href="bootstrap-theme.css"> -->
        <script src='js/angular.js'></script>
        <script type="text/javascript">
            var myApp = angular.module("exampleAPP", []);

            myApp.controller('dayCtrl', function ($scope) {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                $scope.day = dayNames[new Date().getDay()];
            });

            myApp.controller('tomorrowCtrl', function ($scope) {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                $scope.day = dayNames[(new Date().getDay() + 1) % 7];
            });
        </script>
    </head>
    <body>
        <div class="panel">
            <div class="page-header">
                <h3> AngularJS App</h3>
                <h4 ng-controller="dayCtrl">Today is {{day || "(unknown)"}} </h4>
                <h4 ng-controller="tomorrowCtrl">Tomorrow is {{day || "(unknown)"}} </h4>
            </div>
        </div>
    </body>
</html>
```
## 3. Module.directive 指令
定义指令可以扩展并增强 HTML, 从而创建丰富的功能和 web 程序.

### 3.1 内置指令

### 3.2 自定义指令.
创建自定义指令, 有多种方法, 如下为一种之示例.
```
<!DOCTYPE html>
<html ng-app="exampleAPP">
    <head>
        <title>Hello AngularJS</title>
        <!-- <link rel="stylesheet" type="text/css" href="bootstrap.css">
        <link rel="stylesheet" type="text/css" href="bootstrap-theme.css"> -->
        <script src='js/angular.js'></script>
        <script type="text/javascript">
            var myApp = angular.module("exampleAPP", []);

            myApp.controller('dayCtrl', function ($scope) {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                $scope.day = dayNames[new Date().getDay()];
            });

            myApp.controller('tomorrowCtrl', function ($scope) {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                $scope.day = dayNames[(new Date().getDay() + 1) % 7];
            });
            myApp.directive('highlight', function () {
                return function (scope, element, attrs){        // scope: 视图的作用域; element: 指令所应用的元素, jsLite 对象; attrs: 该元素的属性集合.
                    if (scope.day == attrs["highlight"]) {
                        element.css("color", "red");
                    }
                }
            });
        </script>
    </head>
    <body>
        <div class="panel">
            <div class="page-header">
                <h3> AngularJS App</h3>
                <h4 ng-controller="dayCtrl" highlight="Sunday">Today is {{day || "(unknown)"}} </h4>
                <h4 ng-controller="tomorrowCtrl">Tomorrow is {{day || "(unknown)"}} </h4>
            </div>
        </div>
    </body>
</html>
```

## 4. Module.filter 过滤器

过滤器用于在视图中格式化展现给用户的数据, 一旦定义过滤器之后, 就可在整个模块中全面应用.

过滤器本身是函数, 就收数据值并进行格式化.

```
<!DOCTYPE html>
<html ng-app="exampleAPP">
    <head>
        <title>Hello AngularJS</title>
        <!-- <link rel="stylesheet" type="text/css" href="bootstrap.css">
        <link rel="stylesheet" type="text/css" href="bootstrap-theme.css"> -->
        <script src='js/angular.js'></script>
        <script type="text/javascript">
            var myApp = angular.module("exampleAPP", []);

            myApp.controller('dayCtrl', function ($scope) {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                $scope.day = dayNames[new Date().getDay()];
            });

            myApp.controller('tomorrowCtrl', function ($scope) {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                $scope.day = dayNames[(new Date().getDay() + 1) % 7];
            });
            myApp.directive('highlight', function ($filter) {   // 将过滤器应用于 自定义指令.
                var dayFilter = $filter("dayName")

                return function (scope, element, attrs){        // scope: 视图的作用域; element: 指令所应用的元素, jsLite 对象; attrs: 该元素的属性集合.
                    if (dayFilter(scope.day) == attrs["highlight"]) {
                        element.css("color", "red");
                    }
                }
            });

            // 定义过滤器 
            myApp.filter("dayName", function() {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                return function(input) {
                    return angular.isNumber(input)? dayNames[input]: input;
                };
            });
        </script>
    </head>
    <body>
        <div class="panel">
            <div class="page-header">
                <h3> AngularJS App</h3>
                <h4 ng-controller="dayCtrl" highlight="Sunday">Today is {{day || "(unknown)"}} </h4>
                <h4 ng-controller="tomorrowCtrl">Tomorrow is {{day || "(unknown)" | dayName}} </h4>
            </div>
        </div>
    </body>
</html>
```

## 5. 服务
服务是提供在整个应用程序中所用的任何功能的额单例对象. 单例, 即只有一个对象实例被 AngularJS 创建出来, 并被程序需要服务的各种不同部分所共享.

Module 对象所定义的方法, 有三种不同的方式来创建服务: service, factory, provide. 这三者时紧密相关的.

### 5.0 内置服务
AngularJS 提供一些以 `$` 开头的内置服务特性.

- `$scope` 该服务请求 AngularJS 为控制器提供作用域. 在创建控制器时制定给参数的 $scope 组件是用于向视图提供数据的, 只有通过 $scope 配置的数据才能用于表达式和数据绑定. 严格说来, `$scope` 并不是一个服务, 而是一个叫 `$rootScope` 的服务提供的**对象**. 在实际应用上, `$scope` 与服务极为相像, 所以简单起见, 可以成为一个服务.
- `$filter` 该服务可以访问所有已定义的过滤器, 包括自定义的过滤器. `$filter("myFilter")`
- `$http` 

### 5.1 Module.value
`Module.value` 用于创建返回固定值和对象的服务.

```
<!DOCTYPE html>
<html ng-app="exampleAPP">
    <head>
        <title>Hello AngularJS</title>
        <!-- <link rel="stylesheet" type="text/css" href="bootstrap.css">
        <link rel="stylesheet" type="text/css" href="bootstrap-theme.css"> -->
        <script src='js/angular.js'></script>
        <script type="text/javascript">
            var myApp = angular.module("exampleAPP", []);

            myApp.controller('dayCtrl', function ($scope, days) {
                $scope.day = days.today;
            });

            myApp.controller('tomorrowCtrl', function ($scope, days) {
                $scope.day = days.tomorrow;
            });

            myApp.directive('highlight', function ($filter) {
                var dayFilter = $filter("dayName");
                return function (scope, element, attrs){        // scope: 视图的作用域; element: 指令所应用的元素, jsLite 对象; attrs: 该元素的属性集合.
                    if (dayFilter(scope.day) == attrs["highlight"]) {
                        element.css("color", "red");
                    }
                }
            });

            myApp.filter("dayName", function() {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                return function(input) {
                    return angular.isNumber(input)? dayNames[input]: input;
                };
            });

            // Module.value
            var now = new Date();
            myApp.value("nowValue", now)

            myApp.service("days", function(nowValue){
                this.today = nowValue.getDay();
                this.tomorrow = this.today + 1;
            });
        </script>
    </head>
    <body>
        <div class="panel">
            <div class="page-header">
                <h3> AngularJS App</h3>
                <h4 ng-controller="dayCtrl" highlight="Sunday">Today is {{day | dayName}} </h4>
                <h4 ng-controller="tomorrowCtrl">Tomorrow is {{day | dayName}} </h4>
            </div>
        </div>
    </body>
</html>
```


### 5.2 Module.constant
`Module.constant` 与 `Module.value` 类似, 但是创建的服务能够作为 config 方法所声明的依赖使用( value 不可以).

```
myApp.constant("startTime", new Date().toLocaleTimeString());
```

### 5.3 Module.service
```
<!DOCTYPE html>
<html ng-app="exampleAPP">
    <head>
        <title>Hello AngularJS</title>
        <!-- <link rel="stylesheet" type="text/css" href="bootstrap.css">
        <link rel="stylesheet" type="text/css" href="bootstrap-theme.css"> -->
        <script src='js/angular.js'></script>
        <script type="text/javascript">
            var myApp = angular.module("exampleAPP", []);

            myApp.controller('dayCtrl', function ($scope, days) {
                $scope.day = days.today;
            });

            myApp.controller('tomorrowCtrl', function ($scope, days) {
                $scope.day = days.tomorrow;
            });

            myApp.directive('highlight', function ($filter) {
                var dayFilter = $filter("dayName");
                return function (scope, element, attrs){        // scope: 视图的作用域; element: 指令所应用的元素, jsLite 对象; attrs: 该元素的属性集合.
                    if (dayFilter(scope.day) == attrs["highlight"]) {
                        element.css("color", "red");
                    }
                }
            });

            myApp.filter("dayName", function() {
                var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                return function(input) {
                    return angular.isNumber(input)? dayNames[input]: input;
                };
            });
            myApp.service("days", function(){
                this.today = new Date().getDay();
                this.tomorrow = this.today + 1;
            });
        </script>
    </head>
    <body>
        <div class="panel">
            <div class="page-header">
                <h3> AngularJS App</h3>
                <h4 ng-controller="dayCtrl" highlight="Sunday">Today is {{day | dayName}} </h4>
                <h4 ng-controller="tomorrowCtrl">Tomorrow is {{day | dayName}} </h4>
            </div>
        </div>
    </body>
</html>
```
### 5.4 Module.factory
### 5.5 Module.provider

## 6. Module.config
传给 config 方法的函数在**当前模块**被加载**后**调用;

config 方法接受一个函数, 该函数在调用方法的模块被加载后调用. config 方法通常通过注入来自其他服务的值(如连接的详细信息或用户凭证)的方式用于配置模块.

示例, 见*Module.run*的示例.


## 7. Module.run    

传给 `run` 方法的函数在**所有模块**被加载**后**调用

run 方法接受的函数只会在所有模块加载完成后以及解析完他们的依赖后才会被调用.
```
<script>

    var myApp = angular.module("exampleApp",
        ["exampleApp.Controllers", "exampleApp.Filters",
            "exampleApp.Services", "exampleApp.Directives"]);

    // constant 方法与 value 方法类似, 但是创建的能够作为 config 方法所声明的依赖使用 (value 服务做不到).
    myApp.constant("startTime", new Date().toLocaleTimeString());

    myApp.config(function (startTime) {
        console.log("Main module config: " + startTime);
    });
    myApp.run(function (startTime) {
        console.log("Main module run: " + startTime);
    });

    angular.module("exampleApp.Directives", [])
        .directive("highlight", function ($filter) {

            var dayFilter = $filter("dayName");

            return function (scope, element, attrs) {
                if (dayFilter(scope.day) == attrs["highlight"]) {
                    element.css("color", "red");
                }
            }
        });
         
    var now = new Date();
    myApp.value("nowValue", now);

    angular.module("exampleApp.Services", [])
        .service("days", function (nowValue) {
            this.today = nowValue.getDay();
            this.tomorrow = this.today + 1;
        })
        .config(function() {
            console.log("Services module config: (no time)");
        })
        .run(function (startTime) {
            console.log("Services module run: " + startTime);
        });

</script>

// 输出
Services module config: (no time)
Main moule config: 16:57:28
Services module run: 16:57:28
Main module run: 16:57:28
```

## 8. 内置函数
- `angular.isArray`
- `angular.isDate`
- `angular.isNumber`
- `angular.isString`
- `angular.isElement`
- `angular.isFunction`
- `angular.isObject`
- `angular.isDefined`
- `angular.isUndefined`

- `angular.bind`
- `angular.bootstrap`
- `angular.copy`
- `angular.element`
- `angular.equals`
- `angular.errorHandlingConfig`
- `angular.extend`
- `angular.forEach`
- `angular.fromJson`
- `angular.toJson`
- `angular.identity`
- `angular.injector`
- `angular.merge`
- `angular.module`
- `angular.noop`
- `angular.reloadWithDebugInfo`

- `angular.lowercase`
- `angular.uppercase`
