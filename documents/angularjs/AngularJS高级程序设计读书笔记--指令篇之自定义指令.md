---
title: AngularJS高级程序设计读书笔记--指令篇之自定义指令
date: 2018-03-16 17:09:07
categories:
- JavaScript
tags:
- angularjs
- 前端框架
---
## 一. 自定义指令(15-17 章)

`Module.directive(name, factory)` 

指令是专门用于在应用程序内或程序之间复用的, 应当避免产生硬链接的依赖关系, 包括引用被特定控制器所创建的数据.

### 0. AngularJS 对 属性 名称的解析
- 大写开头的会被当做一个单词.
    
    `listProperty` == `list-property`

- 以 `data-` 为前缀的, AngularJS 会自动移除该前缀.

    `data-list-property` == `list-property` == `listProperty`

### 1. 链接函数: 提供了将指令与 HTML 文档和作用域数据相连接的方法.

当 AngularJS 建立指令的每个实例时, 链接函数便被调用, 并接受三个参数: 指令被应用到的视图的作用域(scope), 指令被应用到的 HTML 元素(element), HTML 元素的属性集合( attrs).

- `scope` : 指令并不声明对 $scope 服务的依赖, 取而代之的是, 传入的是指令被应用到的视图的控制器所创建的作用域, 因为他允许单个指令在一个应用程序中被使用多次, 而每个程序可能是在作用域层次结构上的不同作用域上工作的.

- `attrs` 是一个按照名字索引的属性集合.

- `element` jqLite 是 AngularJS 实现的一个剪裁版本的 jQuery, 他不具有 jQuery 的所有功能, 但拥有足够的与执行相工作的功能. jqLite 的功能通过传递给 链接函数的 element 参数暴露出来. 大多数 jqLite 方法返回的结果是拥有访问 jqLite 各种功能的另一个对象(称为 jqLite 对象), AngularJS 不会暴露浏览器所提供的 DOM API, 在任何时候想对元素进行操作, 都会期望接受一个 jqLite 对象. 如果没有 jqLite 对象, 却需要一个, 可以使用 `angular.element` 方法, 返回一个 jqLite 对象.

```
// javascript
<script>
    var app = angular.module("exampleApp", [])
        .directive('unorderedList', function () {
            return function(scope, element, attrs){
                var data = scope[attrs["unorderedList"]];
                var propertyName = attrs["listProperty"];   // 支持属性

                if (angular.isArray(data)){
                    var listElem = angular.element("<ul>");
                    element.append(listElem);
                    for (var i=0; i < data.length; i++){
                        listElem.append(angular.element("<li>").text(data[i][propertyName]));
                    }
                }
            }
        })
        .controller("defaultCtrl", function ($scope) {
            $scope.products = [
                {name: "Apples", category: "Fruit", price: 1.20, expire: 20},
                {name: "Bananas", category: "Fruit", price: 2.42, expire: 7},
                {name: "Pears", category: "Fruit", price: 2.02, expire: 6},
            ]
        })

</script>

// html
<body ng-app="exampleApp" ng-controller="defaultCtrl">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3>Products</h3>
        </div>
        <div class="panel-body">
            <div unordered-list="products" list-property="name"></div>  // 支持属性
        </div>
    </div>
</body>
```

**计算属性 scope.$eval**: 让作用域将属性值当做一个表达式来进行计算, `scope.$eval` 方法接受 要计算的表示和需要用于计算的任意本地数据.

```
// javascript
<script>
    var app = angular.module("exampleApp", [])
        .directive('unorderedList', function () {
            return function(scope, element, attrs){
                var data = scope[attrs["unorderedList"]];
                var propertyExpression = attrs["listProperty"]

                if (angular.isArray(data)){
                    var listElem = angular.element("<ul>");
                    element.append(listElem);
                    for (var i=0; i < data.length; i++){
                        listElem.append(angular.element("<li>").text(scope.$eval(propertyExpression, data[i])));    // scope.$eval 将属性值当做表达式来计算.
                    }
                }
            }
        })
        .controller("defaultCtrl", function ($scope) {
            $scope.products = [
                {name: "Apples", category: "Fruit", price: 1.20, expire: 20},
                {name: "Bananas", category: "Fruit", price: 2.42, expire: 7},
                {name: "Pears", category: "Fruit", price: 2.02, expire: 6},
            ]
        })

</script>

// html
<body ng-app="exampleApp" ng-controller="defaultCtrl">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3>Products</h3>
        </div>
        <div class="panel-body">
            <div unordered-list="products" list-property="price | currency"></div>  // 添加表达式
        </div>
    </div>
</body>

```

**响应作用域中数据变化的能力**
```
// JavaScript
<script>
    var app = angular.module("exampleApp", [])
        .directive('unorderedList', function () {
            return function(scope, element, attrs){
                var data = scope[attrs["unorderedList"]];
                var propertyExpression = attrs["listProperty"]

                if (angular.isArray(data)){
                    var listElem = angular.element("<ul>");
                    element.append(listElem);
                    for (var i=0; i < data.length; i++){
                        (function(){    // IIFE, 自调用函数, 解决 JavaScript 闭包导致的引用函数外变量问题. 函数所访问的变量是在函数被调用时计算的, 而不是函数定义时.
                            var itemElement = angular.element("<li>")
                            listElem.append(itemElement);

                            var index = i;  // index 不会被 for 循环的下一个迭代更新, 即监听器函数可以从 index 访问到正确的变量.
                            
                            // 监听器函数, 基于作用域中的数据计算出一个值, 该函数在每次作用域发生变化时被调用. 
                            // 如果该函数返回值发生变化, 则 $watch 处理函数就会被调用.
                            var watchFn = function(watchScope){
                                return watchScope.$eval(propertyExpression, data[index]);
                            }
                            // $watch 监视器, 监控作用域变化.
                            scope.$watch(watchFn, function(newValue, oldValue){
                                itemElement.text(newValue);
                            })    
                        }());
                        
                    }
                }
            }
        })
        .controller("defaultCtrl", function ($scope) {
            $scope.products = [
                {name: "Apples", category: "Fruit", price: 1.20, expire: 20},
                {name: "Bananas", category: "Fruit", price: 2.42, expire: 7},
                {name: "Pears", category: "Fruit", price: 2.02, expire: 6},
            ];

            $scope.incrementPrice = function(){
                for (var i=0; i<$scope.products.length; i++){
                    $scope.products[i].price++;
                }
            }
        })

</script>

// html
<body ng-app="exampleApp" ng-controller="defaultCtrl">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3>Products</h3>
        </div>
        <div class="panel-body">
            <!-- 涨价按钮 -->
            <button class="btn btn-primary" ng-click="incrementPrice()">Change Prices</button>
        </div>
        <div class="panel-body">
            <div unordered-list="products" list-property="price | currency"></div>
        </div>
    </div>
</body>
```

### 2. 编译函数: 可以与指令相关联的函数.

### 1. 创建自定义指令的方法
- `Module.directive(name, factory)`
    示例 : 

        <script>
            var myApp = angular.module('exampleApp', [])
            myApp.contorller('dayCtrl', function($scope){
                var dayName = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Staturday"]
                $scope.day = dayName[new Date().getDay()];
            });
            myApp.directive("highlight", function(){
                return function(scope, element, attrs){
                    if (scope.day == attrs["highlight"]{
                        element.css("color", "red")
                    })
                }
            });
        </script>

        <body ng-app='exampleAPP'>
            <h4 ng-controller="dayCtrl" highlight="Monday">
                Today is { {day || "(unknown)"} }
            </h4>
        </body>

        # scope, element, attrs 分别为 : 视图的作用域, 指令所应用到的元素, 该元素的属性.
        # scope 参数用于检查在视图中可用的数据, 该示例中, 该参数能获得 day 属性的值.
        # attrs 参数提供了指令所应用到的元素的属性的完整集合, 包括让指令起作用的那个属性, 即获取 highlight 属性的值.
        # element 是一个 jqLite 对象, 如果 highlight 属性的值与作用于中 day 变量的值相等, 就调用 element 参数来设置 HTML 内容. css 方法可以设置一个 css 属性值. 

### 2. 自定义指令的作用点
- 被当作属性使用
- 当做自定义 HTML 元素使用

## 二. 工厂函数与工人函数
所有的可用于创建 AngularJS 构件的 Module 的方法都可以接受函数作为参数. 这些函数通常被称为 工厂函数, 因为他们负责创建那些将被 AngularJS 用来执行工作的对象.

工厂函数通常会返回一个工人函数, 也就是说将被 AngularJS 用来执行工作的对象也是一个函数.

    myApp.directive("highlight", function(){    // 此处 function 是一个 工厂函数
        return function(scope, element, attrs){     // 工人函数
            if (scope.day == attrs["highlight"]{
                element.css("color", "red")
            })
        }
    });

**不能够依赖于工厂函数或工人函数在某个特定时刻被调用**
当希望注册一个构件时, 调用 Module 的方法;
当建立构件时 AngularJS 将调用工厂函数;
然后当需要使用该构件时就会调用工人函数.
这三个事件并一定会按照顺序立即调用.


## 三. 定义复杂指令

使用一个返回链接函数的工厂函数来创建自定义指令, 是最简单的一种办法, 这也意味着许多可由**指令自定义选项**使用的是默认值, 要自定义这些选项, 工厂函数必须返回一个定义对象, 这是一个 javascritp 对象, 可用下表中的一些或全部属性.

| 名称 | 描述 |
| -- | -- |
| compile | 指定一个**编译函数** |
| controller | 为指令创建一个**控制器函数** |
| link | 指定一个**链接函数** |
| replace | 指定模板内容是否替换指令所应用到的元素. |
| require | 声明对某个控制器的依赖. |
| restrict | 指定指令如何被使用 |
| scope | 为指令创建一个新的作用域或者一个隔离的作用域. |
| template | 指定一个将被插入到 HTML 文档的模板 |
| templateUrl | 指定一个将被插入到 HTML 文档的外部模板 |
| transclude | 指定指令是否被用于包含任意内容 |

当只返回一个链接函数时, 所创建的指令只能被当做一个**属性**来使用.

编译函数与连接函数: 严格来说, 应当使用由 compile 定义属性指令的编译函数, 只用来修改 DOM; 并且只使用连接函数来执行比如创建监听器和设置事件处理器等任务. 编译/连接分离有助于改善特别复杂或者处理大量数据的指令的性能.

### 1. restrict : 指定指令如何被使用

| 字母 | 描述 |
| -- | -- |
| E | 允许指令被用作一个**元素** |
| A | 允许指令被用作一个**属性** |
| C | 允许指令被用作一个**类**|
| M | 允许指令被用作一个**注释** |

在实际使用中, restrict 定义属性最常见值是 A,E 或者 AE, 但是也可以四个一起使用, 如 EACM. 即, 只要有可能就应该将指令当做元素或属性来使用, 应为这种方式更容易让人看懂指令应用到何处.

```
<script>
    angular.module("exampleApp", [])
        .directive("unorderedList", function () {
            return {
                link: function (scope, element, attrs) {
                    var data = scope[attrs["unorderedList"] || attrs["listSource"]];
                    var propertyExpression = attrs["listProperty"] || "price | currency";
                    if (angular.isArray(data)) {
                        var listElem = angular.element("<ul>");
                        if (element[0].nodeName == "#comment") {
                            element.parent().append(listElem);
                        } else {
                            element.append(listElem);
                        }
                        for (var i = 0; i < data.length; i++) {
                            var itemElement = angular.element("<li>")
                                .text(scope.$eval(propertyExpression, data[i]));
                            listElem.append(itemElement);
                        }
                    }
                },
                restrict: "EACM"
            }

        }).controller("defaultCtrl", function ($scope) {
            $scope.products = [
                { name: "Apples", category: "Fruit", price: 1.20, expiry: 10 },
                { name: "Bananas", category: "Fruit", price: 2.42, expiry: 7 },
                { name: "Pears", category: "Fruit", price: 2.02, expiry: 6 }
            ];
        })
</script>
```

#### 1.1 将指令当做一个元素来使用
AngularJS 的习惯是将那些通过定义属性 template 和 templateUrl 管理模板的指令当做元素来使用.

将指令当做一个 unordered-list 元素来使用, 并在元素上使用属性对其进行配置.

```
<div class="panel-body">
    <unordered-list list-source="products" list-property="price | currency" />
</div>

// 需要对指令的链接函数做一个修改.
var data = scope[attrs["unorderedList"] || attrs["listSource"]];
```
#### 1.2 将指令当做一个属性来使用

```
<div class="panel-body">
    <div unordered-list="products" list-property="price | currency"></div>        
</div>
```
#### 1.3 将指令当做一个类的属性值来使用 
```
<div class="panel-body">
    <div class="unordered-list: products" list-property="price | currency"></div>
</div>
```
#### 1.4 将指令当做一个注释来使用
容易使得其他开发者不容易看懂代码, 还可能引起某些构建工具的问题(因为有些工具为了缩减文件体积而去除注释). 

注释必须以单词 `directive` 开始, 跟随一个冒号, 指令名以及可选的配置参数.

```
<div class="panel-body">
    <!-- directive: unordered-list products  -->
</div>


// 需要修改链接函数的操作方式已支持注释方式.
if (element[0].nodeName == "#comment") {
    element.parent().append(listElem);
} else {
    element.append(listElem);
}

```

### 2. template, templateUrl: 指定指令模板



#### 2.1 使用函数作为末班

#### 2.2 使用外部模板

#### 2.3 使用函数选择一个外部模板

#### 2.4 替换元素

### 3. scope: 管理指令作用域.



















