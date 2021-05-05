---
title: AngularJS高级程序设计读书笔记--控制器篇
date: 2018-03-16 17:09:07
categories:
- JavaScript
tags:
- angularjs
- 前端框架
---

控制器通过作用域向视图提供数据和逻辑.

作用域组成了一个能够用于在控制器之间形成通信的体系结构. 

当控制器声明了对 `$scope` 服务的依赖时, 就可以使得控制器通过其对应的作用于向试图提供各种能力. 作用于不仅定义了控制器和视图之间的关系, 而且对许多最重要的 AngularJS 特性提供了运转机制, 如数据绑定.

## 一. 控制器和作用域的基本原理

控制器是一个 AngularJS 程序中最大的构件之一, 它扮演了模型和视图之间的渠道的角色. 大多数 AngularJS 项目拥有多个控制器, 每一个向应用程序的一部分提供所需的数据和逻辑.

控制器就像领域模型与视图之间的纽带, 他给视图提供数据与服务, 并且定义了所需的业务逻辑, 从而将用户行为转换成模型上的变化.

控制器从模型中暴露数据给视图, 以及基于用户与视图的交互使模型产生变化所需的逻辑.

控制器可用于向所支持的视图提供作用域.

示例代码:
```
<!DOCTYPE html>
<html ng-app="exampleApp">
<head>
    <title>Controllers</title>
    <script src="angular.js"></script>
    <link href="bootstrap.css" rel="stylesheet" />
    <link href="bootstrap-theme.css" rel="stylesheet" />
    <script>
        angular.module("exampleApp", []);
    </script>
</head>
<body>
    <div class="well">
        Content will go here.
    </div>
</body>
</html>
```
### 1. 创建控制器
控制器是通过 AngularJS 的 Module 对象所提供的的 controller 方法创建出来的. controller 方法的参数是新建控制器的名字和一个将被用于创建控制器的函数. 这个函数应被理解为构造器, 也可以看作为一个工厂函数.

控制器名称的命名习惯是使用 `Ctrl` 后缀.

工厂函数能够使用以来注入特性来声明对 AngularJS 服务的依赖. 几乎每个控制器都要使用 $scope 服务, 用于系那个视图提供作用域, 定义可被视图使用的数据和逻辑.

严格说来, `$scope` 并不是一个服务, 而是一个叫 `$rootScope` 的服务提供的**对象**. 在实际应用上, `$scope` 与服务极为相像, 所以简单起见, 可以成为一个服务.

区别控制器所支持的视图, 是通过 ng-controller 指令来完成的. 该指令所指定的值,必须与创建的控制器同名. **每一个控制器实例对应一个作用域**.
```
<script>
    angular.module("exampleApp", [])
        .controller("simpleCtrl", function ($scope) {

        });
</script>

// 将控制器应用于视图.
<div class="well" ng-controller="simpleCtrl">
    Content will go here.
</div>
```
控制器名称的命名习惯是使用 `Ctrl` 后缀.

传给 `Module.controller` 函数的参数用于声明控制器的依赖(依赖注入), 即控制器所需的 AngularJS 组件.

示例如下:
```
myApp.controller("dayCtrl", function($scope){...})

$scope : 该服务请求 AngularJS 为控制器提供作用域. 控制器使用 $scope 组件, 这能够允许向视图传递数据. $scope 组件是用于向视图提供数据的, 只有通过 $scope 配置的数据才能用于表达式和数据绑定中.
```
当控制器生命了对 $scope 服务的依赖时, 就可以使得控制器通过其对应的作用域向视图提供各种能力. 作用于不仅定义了控制器和视图之间的关系, 而且对许多重要的 AngularJS 特性提供了运转机制, 如 数据绑定.

有两种方法, 通过控制器使用作用域:
- 定义数据
- 定义行为, 即可以在视图绑定的表达式或指令中调用 JavaScript 函数.

关于作用域最重要的一点是, 修改会传播下去, 自动更新所有相依赖的数据值, 即使是通过行为产生的.

### 2. 依赖注入(DI)
一个 AngularJS 应用程序的一些组件将会依赖于其他的组件. 依赖注入简化了在组件之间处理依赖的过程(解决依赖).
AngularJS 应用程序的一个组件通过在工厂函数的参数上声明依赖, 声明的名称要与所依赖的组件相匹配.

依赖注入改变了函数参数的用途. 没有依赖注入, 参数会被用于接受调用者想要传入的任何对象, 但是又累依赖注入后, 函数使用参数来提出需求, 告诉 AngularJS 他需要什么样的构件.

**AngularJS 中参数的顺序总是与声明依赖的顺序相匹配.**

## 二. 组织控制器

### 1 单块控制器

简单, 无需担心各个作用域之间的通信问题, 而且行为将可以被整个 HTML 所用. 当使用一个单块控制器时, 实际上会对整个应用程序创建一个单独的视图.

```
<script>
    angular.module("exampleApp", [])
        .controller("simpleCtrl", function ($scope) {

            $scope.addresses = {};

            $scope.setAddress = function (type, zip) {
                console.log("Type: " + type + " " + zip);
                $scope.addresses[type] = zip;
            }

            $scope.copyAddress = function () {
                $scope.shippingZip = $scope.billingZip;
            }
        });
</script>

// ...
<div class="well">
    <h4>Billing Zip Code</h4>
    <div class="form-group">
        <input class="form-control" ng-model="billingZip">
    </div>
    <button class="btn btn-primary" ng-click="setAddress('billingZip', billingZip)">
        Save Billing
    </button>
</div>

<div class="well">
    <h4>Shipping Zip Code</h4>
    <div class="form-group">
        <input class="form-control" ng-model="shippingZip">
    </div>
    <button class="btn btn-primary" ng-click="copyAddress()">
        Use Billing
    </button>
    <button class="btn btn-primary" 
            ng-click="setAddress('shippingZip', shippingZip)">
        Save Shipping
    </button>
</div>  
```
### 2 复用控制器
![创建一个控制器的多个实例](http://oluv2yxz6.bkt.clouddn.com/%E5%A4%8D%E7%94%A8%E6%8E%A7%E5%88%B6%E5%99%A8.PNG "创建一个控制器的多个实例")

在同一个应用程序中创建多个视图,并复用同一个控制器. AngularJS 将会调用每个应用到控制器的工厂函数, 结果是每个控制器实例将会拥有自己的作用域.

这种方法能够简化控制器, 因为所需管理的只是在单块控制器下需要处理的数据值的一个子集. 这样能够工作的原因是, MVC 模式下能够分离职能, 意味着不同的视图能够以不同的方式对同一份数据和功能进行展示.

每个控制器向其作用域提供的数据和行为都是与另外一个控制**相互独立**的.
```
<script>
    angular.module("exampleApp", [])
        .controller("simpleCtrl", function ($scope) {

            $scope.setAddress = function (type, zip) {
                console.log("Type: " + type + " " + zip);
            }

            $scope.copyAddress = function () {
                $scope.shippingZip = $scope.billingZip;
            }
        });
</script>
// ... 
<div class="well" ng-controller="simpleCtrl">
    <h4>Billing Zip Code</h4>
    <div class="form-group">
        <input class="form-control" ng-model="zip">
    </div>
    <button class="btn btn-primary" ng-click="setAddress('billingZip', zip)">
        Save Billing
    </button>
</div>
<div class="well" ng-controller="simpleCtrl">
    <h4>Shipping Zip Code</h4>
    <div class="form-group">
        <input class="form-control" ng-model="zip">
    </div>
    <button class="btn btn-primary" ng-click="copyAddress()">
        Use Billing
    </button>
    <button class="btn btn-primary" ng-click="setAddress('shippingZip', zip)">
        Save Shipping
    </button>
</div>
```

#### 2.1 作用域之间的通信

![在使用多个控制器时的作用域的层级结构](http://oluv2yxz6.bkt.clouddn.com/%E4%BD%BF%E7%94%A8%E5%A4%9A%E4%B8%AA%E6%8E%A7%E5%88%B6%E5%99%A8%E6%97%B6%E7%9A%84%E4%BD%9C%E7%94%A8%E5%9F%9F%E7%BB%93%E6%9E%84.PNG "在使用多个控制器时的作用域的层级结构")

作用域实际上是以层级结构的形式组织起来的, 顶层是 **根作用域(root scope)**, 每个控制器都会被赋予一个新的作用域, 该作用域是根作用域的一个子作用域. 根作用域提供了在各种作用域之间发送事件的方法, 者意味着允许在各种控制器之间进行通信.

根作用域可以作为一个服务被使用, 所以在控制器中使用 $rootScope(AngularJS的内建服务) 名称声明了对他的依赖. 

所有作用域, 包括 $rootScope 服务, 定义了若干可**用于发送和接受事件的方法**:

| 方法 | 描述 |
| --- | --- |
| `$broadcase(name,args)` | 向当前作用域下的**所有子作用域**发送一个事件. 参数是事件名称, 以及一个用于向事件提供额外数据的对象. |
| `$emit(name, args)` | 向当前作用域的**父作用域**发送一个事件, 直至**根作用域** |
| `$on(name, handler)` | 注册一个事件处理函数, 该函数在特定的事件被当前作用域收到时会被调用. | 

$broadcase 和 $emit 事件都是具有**方向性**的, 他们沿着作用域的层级结构向上发送事件直至根作用域或者向下发送直至每一个子作用域.

```
<script>
    angular.module("exampleApp", [])
        .controller("simpleCtrl", function ($scope, $rootScope) {

            // $scope.$on 用来对 zipCodeUpdated 事件创建一个处理函数.
            // 这个事件处理函数接受一个 Event 对象以及一个参数对象, 
            // 本例中, 对该参数对象定义了 type 和 zipCode 属性, 然后使用它们在本地作用域上定义一个属性.

            $scope.$on("zipCodeUpdated", function (event, args) {
                $scope[args.type] = args.zipCode;
            }); 

            // 通过 $rootScope 对象上调用 $broadcast 方法实现同步, 
            // 传入一个拥有 type 和 zipCode 属性的对象, 这个对象正是事件处理函数所期望得到的.

            $scope.setAddress = function (type, zip) {
                $rootScope.$broadcast("zipCodeUpdated", {
                    type: type, zipCode: zip 
                });
                console.log("Type: " + type + " " + zip);
            }

            $scope.copyAddress = function () {
                $scope.zip = $scope.billingZip;
            };
        });
</script>
```
#### 2.2 使用服务调节作用域事件
AngularJS 中的习惯时使用**服务**来调解作用域之间的通信. 即 使用`Module.service`方法创建一个服务对象, 该服务可被控制器用来发送和接受事件, 而无需直接与作用域中的事件方法产生交互. 这种方法, 可以减少代码的重复.
```
<script>
    angular.module("exampleApp", [])
        // 声明对 $rootScope 服务的依赖
        .service("ZipCodes", function($rootScope) {
            return {
                setZipCode: function(type, zip) {
                    this[type] = zip;
                    $rootScope.$broadcast("zipCodeUpdated", {
                        type: type, zipCode: zip 
                    });
                }
            }
        })
        // 声明对 ZipCodes 的依赖.
        .controller("simpleCtrl", function ($scope, ZipCodes) {

            $scope.$on("zipCodeUpdated", function (event, args) {
                $scope[args.type] = args.zipCode;
            });

            $scope.setAddress = function (type, zip) {
                ZipCodes.setZipCode(type, zip);
                console.log("Type: " + type + " " + zip);
            }

            $scope.copyAddress = function () {
                $scope.zip = $scope.billingZip;
            }
        });
</script>
```

### 3 控制器继承
ng-controller 指令可被内嵌在 HTML 元素上, 产生一种被称为控制器继承的效果, 这是一种目的在于减少代码重复的特性, 可以在一个父控制器中定义公用功能, 并在一个或多个子控制器中使用.

![在使用子控制器时的作用域层次结构](http://oluv2yxz6.bkt.clouddn.com/%E4%BD%BF%E7%94%A8%E8%87%AA%E6%8E%A7%E5%88%B6%E5%99%A8%E6%97%B6%E7%9A%84%E4%BD%9C%E7%94%A8%E5%9F%9F%E5%B1%82%E6%AC%A1%E7%BB%93%E6%9E%84.PNG "在使用子控制器时的作用域层次结构")

```    
// js 代码
var app = angular.module("exampleApp", []);

app.controller("topLevelCtrl", function ($scope) {

    $scope.dataValue = "Hello, Adam";

    $scope.reverseText = function () {
        $scope.dataValue = $scope.dataValue.split("").reverse().join("");
    }

    $scope.changeCase = function () {
        var result = [];
        angular.forEach($scope.dataValue.split(""), function (char, index) {
            result.push(index % 2 == 1
                ? char.toString().toUpperCase() : char.toString().toLowerCase());
        });
        $scope.dataValue = result.join("");
    };
});

app.controller("firstChildCtrl", function ($scope) {

    $scope.changeCase = function () {
       $scope.dataValue = $scope.dataValue.toUpperCase();
    };
});

app.controller("secondChildCtrl", function ($scope) {

    $scope.changeCase = function () {
       $scope.dataValue = $scope.dataValue.toLowerCase();
    };

    $scope.shiftFour = function () {
        var result = [];
        angular.forEach($scope.dataValue.split(""), function (char, index) {
            result.push(index < 4 ? char.toUpperCase() : char);
        });
        $scope.dataValue = result.join("");
    }
});

// HTML 代码
<body ng-controller="topLevelCtrl">

    <div class="well">
        <h4>Top Level Controller</h4>
        <div class="input-group">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button" 
                        ng-click="reverseText()">Reverse</button>
                <button class="btn btn-default" type="button"
                        ng-click="changeCase()">Case</button>
            </span>
            <input class="form-control" ng-model="dataValue">
        </div>
    </div>

    <div class="well" ng-controller="firstChildCtrl">
        <h4>First Child Controller</h4>
        <div class="input-group">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button"
                        ng-click="reverseText()">Reverse</button>
                <button class="btn btn-default" type="button"
                        ng-click="changeCase()">Case</button>
            </span>
            <input class="form-control" ng-model="dataValue">
        </div>
    </div>    

    <div class="well" ng-controller="secondChildCtrl">
        <h4>Second Child Controller</h4>
        <div class="input-group">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button"
                        ng-click="reverseText()">Reverse</button>
                <button class="btn btn-default" type="button"
                        ng-click="changeCase()">Case</button>
                <button class="btn btn-default" type="button"
                        ng-click="shiftFour()">Shift</button>
            </span>
            <input class="form-control" ng-model="dataValue">
        </div>
    </div>    
</body>
// 该例子中, 首次交互为修改 Reverse 按钮时, 所有的 input 框中的内容都将改变; 
// 首次交互修改 第二或第三个 input 框中的内容时, 再次点击 Reverse , 则除了被修改的, 所有的都改变. 
```

当通过 `ng-controller` 指令将控制器嵌入另一个控制器中时, **子控制器的作用域便继承了父控制器作用域中的数据和行为**, 这种嵌套可以为**任意层次**. 每个控制器都用自己独有的作用域, 但是子控制器的作用域包含了其父作用域的数据值和行为.
- 当单击 Reverse 按钮时, 所有的输入框都会改变, 因为 Reverse 调用的 reverseText 行为在顶层控制器中被定义. 子控制器继承了数据值和行为.
- 子控制器可以在继承父控制器的基础上, 实现自定义的功能, 扩展被继承的数据和行为.
- 子控制器能够覆盖他们的父控制器中的数据和行为, 即数据值和行为能够被同名的局部数据和行为所覆盖. 当查找行为时, AngularJS 会从该指令所应用到的控制器作用域上开始查找, 如果该行为存在, 则执行. 如果不存在, AngularJS 会向作用域的上层继续查找, 直到具有指定名称的行为被找到. 可以利用这一特性在大多数时候使用父控制器提供的功能, 而只改写需要自定义的部分.


**AngularJS 对作用域上的数据值的继承的处理方式以及如何受ng-model指令影响**

可以使用下面的示例代码与上面的代码做比较.
```
// js 代码
var app = angular.module("exampleApp", []);

app.controller("topLevelCtrl", function ($scope) {

    $scope.data = {
        dataValue: "Hello, Adam"
    };

    $scope.reverseText = function () {
        $scope.data.dataValue = $scope.data.dataValue.split("").reverse().join("");
    };

    $scope.changeCase = function () {
        var result = [];
        angular.forEach($scope.data.dataValue.split(""), function (char, index) {
            result.push(index % 2 == 1 ? char.toString().toUpperCase() : char.toString().toLowerCase());
        });
        $scope.data.dataValue = result.join("");
    };
});

app.controller("firstChildCtrl", function ($scope) {

    $scope.changeCase = function () {
       $scope.data.dataValue = $scope.data.dataValue.toUpperCase();
    };
});

app.controller("secondChildCtrl", function ($scope) {

    $scope.changeCase = function () {
       $scope.data.dataValue = $scope.data.dataValue.toLowerCase();
    };

    $scope.shiftFour = function () {
        var result = [];
        angular.forEach($scope.data.dataValue.split(""), function (char, index) {
            result.push(index < 4 ? char.toUpperCase() : char);
        });
        $scope.data.dataValue = result.join("");
    };
});

// html 代码
<body ng-controller="topLevelCtrl">

    <div class="well">
        <h4>Top Level Controller</h4>
        <div class="input-group">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button" 
                        ng-click="reverseText()">Reverse</button>
                <button class="btn btn-default" type="button"
                        ng-click="changeCase()">Case</button>
            </span>
            <input class="form-control" ng-model="data.dataValue">
        </div>
    </div>

    <div class="well" ng-controller="firstChildCtrl">
        <h4>First Child Controller</h4>
        <div class="input-group">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button"
                        ng-click="reverseText()">Reverse</button>
                <button class="btn btn-default" type="button"
                        ng-click="changeCase()">Case</button>
            </span>
            <input class="form-control" ng-model="data.dataValue">
        </div>
    </div>    

    <div class="well" ng-controller="secondChildCtrl">
        <h4>Second Child Controller</h4>
        <div class="input-group">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button"
                        ng-click="reverseText()">Reverse</button>
                <button class="btn btn-default" type="button"
                        ng-click="changeCase()">Case</button>
                <button class="btn btn-default" type="button"
                        ng-click="shiftFour()">Shift</button>
            </span>
            <input class="form-control" ng-model="data.dataValue">
        </div>
    </div>    
</body>

// 所有的按钮都可以影响所有的输入框元素, 而且编辑输入元素的内容也不会影响后续的变化.
```
**原理:** 

- 当读取一个直接在作用域上定义的属性的值时, AngularJS 会检查在这个控制器的作用域上是否有一个局部属性, 如果没有, 就会沿着作用域层次结构向上查找是否有一个被继承的属性. 然而, 当使用 ng-model 指令来修改这一属性时, AngularJS 会检查当前作用域是否有这样一个名称的属性, 如果没有, 则假定该属性为隐式属性, 结果便是覆盖了该属性的值.
- 然而, 如果在作用域上定义一个对象然后在对象上定义数据属性, 则不会发生覆盖的行为.  这是因为 JavaScript 对继承的实现是基于**原型继承**, 这意味着, 使用 ng-model 指令时,将会创建局部变量, 并使用一个对象作为中介. 这个将确保 ng-model 会对在父作用域上定义的数据值进行更新.

总结: 如果你想数据值在开始的时候是共享的, 但在修改时会被复制一份, 就直接在作用域上定义数据属性; 如果想确保始终只有一份数据值, 就通过一个对象来定义数据属性.

### 4. 多控制器
![当独立使用控制器时的作用域层次结构](http://oluv2yxz6.bkt.clouddn.com/%E5%BD%93%E7%8B%AC%E7%AB%8B%E4%BD%BF%E7%94%A8%E6%8E%A7%E5%88%B6%E5%99%A8%E6%97%B6%E7%9A%84%E4%BD%9C%E7%94%A8%E5%9F%9F%E5%B1%82%E6%AC%A1%E7%BB%93%E6%9E%84.PNG "当独立使用控制器时的作用域层次结构")
```
// js
<script>
    var app = angular.module("exampleApp", []);

    app.controller("firstController", function ($scope) {

        $scope.dataValue = "Hello, Adam";

        $scope.reverseText = function () {
            $scope.dataValue = $scope.dataValue.split("").reverse().join("");
        }
    });

    app.controller("secondController", function ($scope) {

        $scope.dataValue = "Hello, Jacqui";

        $scope.changeCase = function () {
            $scope.dataValue = $scope.dataValue.toUpperCase();
        };
    });
</script>

// html
<body>
    <div class="well" ng-controller="firstController">
        <h4>First Controller</h4>
        <div class="input-group">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button" 
                        ng-click="reverseText()">Reverse</button>
            </span>
            <input class="form-control" ng-model="dataValue">
        </div>
    </div>

    <div class="well" ng-controller="secondController">
        <h4>Second Controller</h4>
        <div class="input-group">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button"
                        ng-click="changeCase()">
                    Case
                </button>
            </span>
            <input class="form-control" ng-model="dataValue">
        </div>
    </div>    
</body>    
```
### 5. 使无作用域的控制器
如果应用程序无需使用继承,以及控制器间通信, 可以使用无作用域的控制器. 这些控制器可以在根本不需要使用作用域的情况下向视图提供数据和行为. 取而代之的是一个提供给视图的代表控制器的特殊变量.即 通过 JavaScript 的关键字 `this` 定义了自己的数据值和行为.
```
// js 代码
<script>
    var app = angular.module("exampleApp", [])
        .controller("simpleCtrl", function () {
            this.dataValue = "Hello, Adam";

            this.reverseText = function () {
                this.dataValue = this.dataValue.split("").reverse().join("");
            }
        });
</script>

// html 代码
<body>
    <div class="well" ng-controller="simpleCtrl as ctrl">
        <h4>Top Level Controller</h4>
        <div class="input-group">
            <span class="input-group-btn">
                <button class="btn btn-default" type="button"
                        ng-click="ctrl.reverseText()">Reverse</button>
            </span>
            <input class="form-control" ng-model="ctrl.dataValue">
        </div>
    </div>
</body>
```
**要点总结**
- 使用 JavaScript 的关键字 `this`
- ng-controller 指令的表达式格式有所不同 : `<要应用的控制器> as <变量名>`
- 在使用中使用 `变量名` 访问数据和行为.

## 三. 显式更新作用域
主要用于与其他的 JavaScript 框架集成. 下表中的方法允许注册响应作用域上变化的处理函数, 以及从 AngularJS 代码之外向作用域内注入变化.

| 方法 | 描述 |
| --- | --- | 
| `$apply(expression)` | 向作用域应用变化. 也可以向 $apply 方法传递函数, 在创建自定义指令时尤为有用, 允许在响应用户交互时, 使用指令所管理的元素自定义对作用域的更新方法. $apply 提供了对内集成的手段, 在其他框架中发生的变化, 可以引起 AngularJS 中的相应的变化.|
| `$watch(expression, handler)` | 注册一个处理函数, 当 **expression 表达式所引用的值**变化时, 该函数会被通知到. $watch 提供了对外集成的手段, 作用域上的某个变化可以出发调用另一个框架中的相应变化. |
| `$watchCollection(object, handler)` | 注册一个处理函数, 当**指定的 object 对象的任意属性**变化时, 该函数会被通知到 |

```
// js 代码
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/themes/sunny/jquery-ui.min.css">
<script>
    $(document).ready(function () {
        $('#jqui button').button().click(function (e) {
            // $apply 提供了对内集成的手段, 在其他框架中发生的变化, 可以引起 AngularJS 中的相应的变化.
            // angular.element 是一个 jQuery 的轻量级实现, 传递所关系元素的 id 属性值给该方法, 就能到到一个定义了 scope 方法的对象, 并返回所需的作用域.
            // scope 只是 jqLite 的特性之一, 还有其他方法.
            angular.element(angularRegion).scope().$apply('handleClick()');
        });
    });

    var app = angular.module("exampleApp", [])
        .controller("simpleCtrl", function ($scope) {

            $scope.buttonEnabled = true;
            $scope.clickCounter = 0;

            $scope.handleClick = function () {
                $scope.clickCounter++;
            }
            
            // $watch 提供了对外集成的手段, 作用域上的某个变化可以出发调用另一个框架中的相应变化.
            $scope.$watch('buttonEnabled', function (newValue) {
                $('#jqui button').button({
                    disabled: !newValue
                });
            });
        });
</script>

// html 代码
<body>
    <div id="angularRegion" class="well" ng-controller="simpleCtrl">            
        <h4>AngularJS</h4>
        <div class="checkbox">
            <label>
                <input type="checkbox" ng-model="buttonEnabled"> Enable Button
            </label>
        </div>
        Click counter: { {clickCounter} }
    </div>
    <div id="jqui" class="well">
        <h4>jQuery UI</h4>
        <button>Click Me!</button>
    </div>
</body>
```