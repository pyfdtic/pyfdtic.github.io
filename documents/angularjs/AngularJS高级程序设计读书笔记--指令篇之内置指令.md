---
title: AngularJS高级程序设计读书笔记--指令篇之内置指令
date: 2018-03-16 17:09:08
categories:
- JavaScript
tags:
- angularjs
- 前端框架
---
AngularJS 内置超过 50 个内置指令, 包括 数据绑定,表单验证,模板生成,时间处理 和 HTML 操作.

指令暴露了 AngularJS 的核心功能, 如 事件处理,表单验证,模板等.

## 一. 数据绑定指令
**数据绑定**: 使用模型中的值, 并将其插入到 HTML 文档中.所有的数据绑定指令, 都可以当做一个属性或者类使用.
- 属性 : `<span ng-bind="todos.length"></span>` 属性可能会导致其他开发工具的各种问题, 如某些 JavaScript 库对属性名做了若干假设, 而且某些限制性的版本控制系统不允许 HTML 内容中有非标准的属性.
- 类  : `<span class="ng-bind: todos.length"></span>`

**数据绑定**: AngularJS 的数据绑定是动态的, 当绑定所关联的值在数据模型中发生变化时, HTML 元素也会被随之更新,显示新的值.
- **单向数据绑定** : 从数据模型中获得值并插入到 HTMl 元素中.
- **双向数据绑定** : 从两个方向同时跟踪变化, 允许元素从用户处收集数据已修改程序的状态. 双向数据绑定仅能用于那些允许用户输入数据值的元素上, 既 input,select,textarea 元素

数据绑定的一个很好的特性是, AngularJS 将在需要的时候动态的创建模型属性, 也就说无需费力的定义所有要使用的属性, 就可以和视图关联在一起.

在请求绑定到一个不存在的模型属性时, AngularJS 也**不会报错**, 因为他假定这个属性将会在之后创建.

| 指令 | 用作 | 描述 |
| --- | --- | --- |
| ng-bind | 属性, 类 | 绑定一个 HTML 元素的 innerText 属性 |
| ng-bind-html | 属性, 类 | 使用一个HTML 元素的 innerHTML 属性创建数据绑定, 这是有潜在风险的, 因为这意味着浏览器把内容解析为 HTML, 而不是内容本身. |
| ng-bind-template | 属性, 类 | 与 ng-bind 类似, 但允许在属性值中制定多个模板表达式 |
| ng-model | 属性, 类 | 创建一个双向数据绑定 |
| ng-non-bindable | 属性, 类 | 声明一块不会被执行数据绑定的区域 |


示例代码 : 

    <!DOCTYPE html>
    <html ng-app="exampleApp">
    <head>
        <title>Directives</title>
        <script src="angular.js"></script>
        <link href="bootstrap.css" rel="stylesheet" />
        <link href="bootstrap-theme.css" rel="stylesheet" />
        <script>
            angular.module("exampleApp", [])
                .controller("defaultCtrl", function ($scope) {
                    $scope.todos = [
                        { action: "Get groceries", complete: false },
                        { action: "Call plumber", complete: false },
                        { action: "Buy running shoes", complete: true },
                        { action: "Buy flowers", complete: false },
                        { action: "Call family", complete: false }];
                });
        </script>
    </head>
    <body>
        <div id="todoPanel" class="panel" ng-controller="defaultCtrl">
            <h3 class="panel-header">To Do List</h3>
      
            <div>There are { {todos.length} } items</div>      

            <div>
                There are <span ng-bind="todos.length"></span> items
            </div>

            <div ng-bind-template=
                 "First: { {todos[0].action} }. Second: { {todos[1].action} }">
            </div>

            <div ng-non-bindable>
                AngularJS uses { { and } } characters for templates
            </div>        
        </div>
    </body>
    </html>

### 1. `ng-bind` 与 `{ {} }`内联绑定

    <div>There are { {todos.length} } items</div>      
    ---
    <div>
        There are <span ng-bind="todos.length"></span> items
    </div>        

### 2. `ng-bind-html`

### 3. `ng-bind-template` : 处理多个数据绑定.

    <div ng-bind-template=
         "First: { {todos[0].action} }. Second: { {todos[1].action} }">
    </div>

### 4. `ng-non-bindable` : 阻止 AngularJS 处理内联绑定.

        <div ng-non-bindable>
            AngularJS uses { { and } } characters for templates
        </div>        

### 5. `ng-model`
ng-model 指令对所应用到的元素内容进行设置, 也通过更新数据模型的方式响应用户所做的更改.
**数据模型属性上的变化, 会被传播到所有的相关绑定上, 以保证在整个应用中的数据同步**.在下面的代码中, input 元素属性的修改, 将会影响到 `{ {} }` 内联绑定元素属性的修改.

**原理:** 当 input 元素的内容被修改时, AngularJS 使用标准 JavaScript 事件从 input 元素接受通知, 并且将这一变化通过 $scope 服务进行传播.可以通过浏览器的 开发者工具, 看到 AngularJS 所建立的事件处理器.

    <div class="well">
        <div>The first item is: { {todos[0].action} }</div>
    </div>
    
    <div class="form-group well">
        <label for="firstItem">Set First Item:</label>
        <input name="firstItem" class="form-control" ng-model="todos[0].action" />
    </div>        

## 二. 模板指令
AngularJS 包含了一组可使用模板生成 HTML 元素的指令, 使得使用数据集合进行工作, 以及向响应数据状态的模板中添加基本逻辑变得简单.可以帮助我们不用写任何 JavaScript 代码就可以向视图中添加简单逻辑.

| 指令 | 用作 | 描述 |
| --- | --- | --- |
| ng-cloak | 属性, 类 | 使用一个 css 样式隐藏内联绑定表达式`{ {} }`, 在文档第一个加载时会短暂的可见 |
| ng-include | 元素, 属性, 类 | 向 DOM 中加载,处理和插入一段 HTML |
| ng-repeat | 属性, 类 | 对数组中或对象某个属性中的每一个对象生成一个元素及其内容的若干新拷贝 |
| ng-repeat-start | 属性, 类 | 表示含有多个顶层元素的重复区域的开始部分 |
| ng-repeat-end | 属性, 类 | 表示含有多个顶层元素的重复区域的结束部分 |
| ng-switch | 属性, 类 | 根据数据绑定的值修改 DOM 中的元素. |


### 1 `ng-repeat`

用于为数据集中的各项生成同样的内容.
1. 基础形式
    ng-repeat 指令属性值的基本形式是 <variable> in <srouce> , 其中 source 是被控制器的 $scope 所定义的一个对象或者数组, 在本例中时 todos 数组. 该指令遍历数组中的对象, 创建元素及其内容的一个新实例, 并且处理所包含的模板. 在指令属性值中赋给 <variable> 的名称可用于引用当前数据内容. 

        <div id="todoPanel" class="panel" ng-controller="defaultCtrl">
            <h3 class="panel-header">To Do List</h3>

            <table class="table">
                <thead>
                    <tr>
                        <th>Action</th>
                        <th>Done</th>
                    </tr>
                </thead>
                <tbody>
                    <tr ng-repeat="item in todos">
                        <td>{ {item.action} }</td>
                        <td>{ {item.complete} }</td>
                    </tr>
                </tbody>
            </table>
        </div>

2. ng-repeat 的嵌套使用: 用于遍历对象中的属性.

        <table class="table">
            <thead>
                <tr>
                    <th>Action</th>
                    <th>Done</th>
                </tr>
            </thead>
            <tbody>
                <tr ng-repeat="item in todos">
                    <td ng-repeat="prop in item">{ {prop} }</td>
                </tr>
            </tbody>
        </table>        

    外层 ng-repeat 指令对 todos 数组中的每个对象生成一个 tr 元素, 并且每个对象被赋给变量 item.
    内层 ng-repeat 指令对 item 对象的每个属性生成一个 td 元素, 并将属性值赋给变量 prop. 
    最后 , prob 变量用于一个单项数据绑定, 作为 td 元素的内容.

    该示例与前例相同, 但是却能够自适应的为数据对象中定义的任何新属性生成 td 元素.

3. 使用数据对象的键值工作

        <tbody>
            <tr ng-repeat="item in todos">
                <td ng-repeat="(key, value) in item">
                    { {key} }={ {value} }
                </td>
            </tr>
        </tbody>    

4. 内置变量 : 可用于提供被处理数据的上下文信息.
    内置的 ng-repeat 变量, **索引从 0 开始**
    
    | 变量 | 描述 |
    | --- | --- |
    | $index | 返回当前对象或属性的位置 |
    | $first | 在当前对象为集合中的第一个元素时, 返回 true |
    | $middle | 在当前对象既不是集合的第一个也不是集合的最后一个时, 返回 true |
    | $last | 在当前对象为集合中的最后一个元素时, 返回 true |
    | $even | 对于集合中偶数编号的对象, 返回 true |
    | $odd | 对于集合中奇数编号的对象, 返回 true |

    示例代码:

        <table class="table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Action</th>
                    <th>Done</th>
                </tr>
            </thead>
            <tr ng-repeat="item in todos">
                <td>{ {$index + 1} }</td>
                <td ng-repeat="prop in item">
                    { {prop} }
                </td>
            </tr>
        </table>

        // ng-repeat 与 ng-class 联合使用, 实现条纹效果.       

        <style>
            .odd { background-color: lightcoral}
            .even { background-color: lavenderblush}
        </style>            
        // ...
        <table class="table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Action</th>
                    <th>Done</th>
                </tr>
            </thead>
            <tr ng-repeat="item in todos" ng-class="$odd ? 'odd' : 'even'">
                <td>{ {$index + 1} }</td>
                <td ng-repeat="prop in item">{ {prop} }</td>
            </tr>
        </table>

        // ng-repeat 与 ng-if, ng-class 联合使用

        <style>
            .odd { background-color: lightcoral}
            .even { background-color: lavenderblush}
        </style>            
        // ...
        <table class="table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Action</th>
                    <th>Done</th>
                </tr>
            </thead>
            <tr ng-repeat="item in todos" ng-class="$odd ? 'odd' : 'even'">
                <td>{ {$index + 1} }</td>
                <td>{ {item.action} }</td>
                <td><span ng-if="$first || $last">{ {item.complete} }</span></td> # 在不是 第一个或最后一个元素时, 移除 item.complete .
            </tr>
        </table>
        
        // track must be the last one.
        <div ng-repeat="n in [42, 42, 43, 43] track by $index">
          { {n} }
        </div>    
        ... 
        <div ng-repeat="model in collection | orderBy: 'id' as filtered_result track by model.id">
          { {model.name} }
        </div>
### 2 `ng-repeat-start` 与 `ng-repeat-end` : 对每个数据对象重复生成多个顶层元素.
在需要对每个处理的数据项生成多个表格行时, 最常用到.
ng-repeat-start 指令的配置方法类似于 ng-repeat, 但是将会重复生成所有的顶层元素(及其内容)直到 ng-repeat-end 属性所对应的元素(也包含在内).

    <table class="table">
        <tbody>
            <tr ng-repeat-start="item in todos">
                <td>This is item { {$index} }</td>
            </tr>
            <tr>
                <td>The action is: { {item.action} }</td>
            </tr>
            <tr ng-repeat-end>
                <td>Item { {$index} } is { {$item.complete? '' : "not "} } complete</td>
            </tr>
        </tbody>
    </table>

### 3 `ng-include` 与 局部视图
1. 基本用法

    ng-include 指令从服务器获取一段 HTML 片段, 编译并处理其中包含的任何指令, 并添加到 DOM 中去. 这些片段被称为**局部视图**. ng-include 允许创建可复用的局部视图.

    当 AngularJS 处理 html 文件时, 当遇到 ng-include 指令, 就会自动发出一个 Ajax 请求获取 src 指定的文件, 处理文档内容并将其添加到文档中. 被 ng-include 指令所加载的文件内容的处理过程就像在原来的地方所定义的一样, 也就是说, 拥有访问数据模型和控制器中定义的行为的能力.

    **ng-include 参数**

    | 名称 | 描述 |
    | --- | --- |
    | src | 指定要加载的内容的 URL, 参数为字符串变量, 用一对引号包含表示. 因为 src 属性是被当做 JavaScript 表达式进行计算的. 另, src 的设置是可以通过计算得到的. | 
    | onload | 指定一个在内容被加载时调用计算的表达式 |
    | autoscroll | 指定在内容被加载时, AngularJS 是否应该滚动到这部分视图所在的区域. | 

    **<ng-include></ng-include> : 必须指定开闭标签.**

    示例代码:

        // 主文件
        <!DOCTYPE html>
        <html ng-app="exampleApp">
        <head>
            <title>Directives</title>
            <script src="angular.js"></script>
            <link href="bootstrap.css" rel="stylesheet" />
            <link href="bootstrap-theme.css" rel="stylesheet" />
            <script>
                angular.module("exampleApp", [])
                    .controller("defaultCtrl", function ($scope) {
                        $scope.todos = [
                            { action: "Get groceries", complete: false },
                            { action: "Call plumber", complete: false },
                            { action: "Buy running shoes", complete: true },
                            { action: "Buy flowers", complete: false },
                            { action: "Call family", complete: false }];
                    });
            </script>
        </head>
        <body>
            <div id="todoPanel" class="panel" ng-controller="defaultCtrl">
                <h3 class="panel-header">To Do List</h3>
                <ng-include src="'table.html'"></ng-include>
            </div>
        </body>
        </html>

        // table.html
        <table class="table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Action</th>
                    <th>Done</th>
                </tr>
            </thead>
            <tr ng-repeat="item in todos" ng-class="$odd ? 'odd' : 'even'">
                <td>{ {$index + 1} }</td>
                <td ng-repeat="prop in item">{ {prop} }</td>
            </tr>
        </table>

2. 动态选择局部视图.

        // list.html
        <ol>
            <li ng-repeat="item in todos">
                { {item.action} }
                <span ng-if="item.complete"> (Done)</span>
            </li>
        </ol>

        // table.html
        <table class="table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Action</th>
                    <th>Done</th>
                </tr>
            </thead>
            <tr ng-repeat="item in todos" ng-class="$odd ? 'odd' : 'even'">
                <td>{ {$index + 1} }</td>
                <td ng-repeat="prop in item">{ {prop} }</td>
            </tr>
        </table>

        // index.html
        <!DOCTYPE html>
        <html ng-app="exampleApp">
        <head>
            <title>Directives</title>
            <script src="angular.js"></script>
            <link href="bootstrap.css" rel="stylesheet" />
            <link href="bootstrap-theme.css" rel="stylesheet" />
            <script>
                angular.module("exampleApp", [])
                    .controller("defaultCtrl", function ($scope) {
                        $scope.todos = [
                            { action: "Get groceries", complete: false },
                            { action: "Call plumber", complete: false },
                            { action: "Buy running shoes", complete: true },
                            { action: "Buy flowers", complete: false },
                            { action: "Call family", complete: false }];

                        $scope.viewFile = function () {
                            return $scope.showList ? "list.html" : "table.html";
                        };
                    });
            </script>
        </head>
        <body>
            <div id="todoPanel" class="panel" ng-controller="defaultCtrl">
                <h3 class="panel-header">To Do List</h3>

                <div class="well">
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" ng-model="showList">
                            Use the list view
                        </label>
                    </div>
                </div>

                <ng-include src="viewFile()"></ng-include>

            </div>
        </body>
        </html>

3. ng-include 用做**属性**

    ng-include 属性可用于任何 HTML 元素, src 参数的值姜葱该属性值中取得.其他的指令配置参数以单独的元素表示, 可以从 onload 的属性中看到. 与 ng-include 用作自定义元素有相同的效果.

        <!DOCTYPE html>
        <html ng-app="exampleApp">
        <head>
            <title>Directives</title>
            <script src="angular.js"></script>
            <link href="bootstrap.css" rel="stylesheet" />
            <link href="bootstrap-theme.css" rel="stylesheet" />
            <script>
                angular.module("exampleApp", [])
                    .controller("defaultCtrl", function ($scope) {
                        $scope.todos = [
                            { action: "Get groceries", complete: false },
                            { action: "Call plumber", complete: false },
                            { action: "Buy running shoes", complete: true },
                            { action: "Buy flowers", complete: false },
                            { action: "Call family", complete: false }];

                        $scope.viewFile = function () {
                            return $scope.showList ? "list.html" : "table.html";
                        };

                        $scope.reportChange = function () {
                            console.log("Displayed content: " + $scope.viewFile());
                        }

                    });
            </script>
        </head>
        <body>
            <div id="todoPanel" class="panel" ng-controller="defaultCtrl">
                <h3 class="panel-header">To Do List</h3>

                <div class="well">
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" ng-model="showList">
                            Use the list view
                        </label>
                    </div>
                </div>

                <div ng-include="viewFile()" onload="reportChange()"></div>
            </div>
        </body>
        </html>


### 4 `ng-switch+on`, `ng-switch-when`, `ng-switch-default`
用于在已经存在于文档中的较小代码块之间进行切换.
`ng-switch+on` : 可以被当做**元素**或**属性**使用, on 指定一个表达式, 用于计算并决定那部分内容将被显示出来.
`ng-switch-when` : 只能被当做 **属性** 使用, 表示与所指定的值相关联的一块内容. 当属性值与 ng-switch 中的 on 属性所指定的表达式相匹配时, AngularJS 将会显示出 ng-switch-when 指令所应用到的元素.其他 ng-switch-when 指令代码块里的元素将被移除.
`ng-switch-default` : 只能被当做 **属性** 使用, 用于指定没有任何一个 ng-switch-when 区域匹配到时应当显示的内容.

    <!DOCTYPE html>
    <html ng-app="exampleApp">
    <head>
        <title>Directives</title>
        <script src="angular.js"></script>
        <link href="bootstrap.css" rel="stylesheet" />
        <link href="bootstrap-theme.css" rel="stylesheet" />
        <script>
            angular.module("exampleApp", [])
                .controller("defaultCtrl", function ($scope) {

                    $scope.data = {};
                        
                    $scope.todos = [
                        { action: "Get groceries", complete: false },
                        { action: "Call plumber", complete: false },
                        { action: "Buy running shoes", complete: true },
                        { action: "Buy flowers", complete: false },
                        { action: "Call family", complete: false }];
                });
        </script>
    </head>
    <body>
        <div id="todoPanel" class="panel" ng-controller="defaultCtrl">

            <h3 class="panel-header">To Do List</h3>

            <div class="well">
                <div class="radio" ng-repeat="button in ['None', 'Table', 'List']">
                    <label>
                        <input type="radio" ng-model="data.mode" 
                               value="{ {button} }" ng-checked="$first" />
                        { {button} }
                    </label>
                </div>
            </div>

            <div ng-switch on="data.mode">
                <div ng-switch-when="Table">
                    <table class="table">
                        <thead>
                            <tr><th>#</th><th>Action</th><th>Done</th></tr>
                        </thead>
                        <tr ng-repeat="item in todos" ng-class="$odd ? 'odd' : 'even'">
                            <td>{ {$index + 1} }</td>
                            <td ng-repeat="prop in item">{ {prop} }</td>
                        </tr>
                    </table>
                </div>
                <div ng-switch-when="List">
                    <ol>
                        <li ng-repeat="item in todos">
                            { {item.action} }<span ng-if="item.complete"> (Done)</span>
                        </li>
                    </ol>
                </div>
                <div ng-switch-default>
                    Select another option to display a layout
                </div>
            </div>

        </div>
    </body>
    </html>

### 5 `ng-cloak`
能够在 AngularJS 结束对内容的处理之前先将 `内联元素指令` 隐藏. ng-cloak 指令使用 CSS 对被应用到的元素进行隐藏.

**不建议**对 body 元素使用 ng-cloak 指令, 因为这样当 AngularJS 处理内容时, 用户只能看到一个空白的浏览器窗口. 建议有选择的对部分元素使用该指令, 将其只用到那些具有内联元素表达式的文档部分.

    <div class="well">
        <div class="radio" ng-repeat="button in ['None', 'Table', 'List']">
            <label ng-cloak>
                <input type="radio" ng-model="data.mode" 
                    value="{ {button} }" ng-checked="$first">
                { {button} }
            </label>
        </div>
    </div>

## 三. 元素指令

元素指令, 用于在 DOM 中对元素进行配置和渲染样式的.

| 指令 | 用作 | 描述 |
| --- | --- | --- |
| ng-if | 属性 | 从 DOM 中添加和移除元素 |
| ng-class | 属性, 类 | 为某个元素设置 class 属性 |
| ng-class-even | 属性, 类 | 对 ng-repeat 指令生成的偶数元素设置 class 属性 |
| ng-class-odd | 属性, 类 | 对 ng-repeat 指令生成的奇数元素设置 class 属性 |
| ng-hide | 属性, 类 | 在 DOM 中显示和隐藏元素 |
| ng-show | 属性, 类 | 在 DOM 中显示和隐藏元素 |
| ng-style | 属性, 类 | 设置一个或多个 CSS 属性 |

基础示例代码 :

    <!DOCTYPE html>
    <html ng-app="exampleApp">
    <head>
        <title>Directives</title>
        <script src="angular.js"></script>
        <link href="bootstrap.css" rel="stylesheet" />
        <link href="bootstrap-theme.css" rel="stylesheet" />
        <script>
            angular.module("exampleApp", [])
                .controller("defaultCtrl", function ($scope) {
                    $scope.todos = [
                        { action: "Get groceries", complete: false },
                        { action: "Call plumber", complete: false },
                        { action: "Buy running shoes", complete: true },
                        { action: "Buy flowers", complete: false },
                        { action: "Call family", complete: false }];
                });
        </script>
    </head>
    <body>
        <div id="todoPanel" class="panel" ng-controller="defaultCtrl">
            <h3 class="panel-header">To Do List</h3>

            <table class="table">
                <thead>
                    <tr><th>#</th><th>Action</th><th>Done</th></tr>
                </thead>
                <tr ng-repeat="item in todos">
                    <td>{ {$index + 1} }</td>
                    <td ng-repeat="prop in item">{ {prop} }</td>
                </tr>
            </table>
        </div>
    </body>
    </html>

### 1. ng-hide, ng-show : 隐藏和显示元素

ng-show 和 ng-hide 指令通过添加和移除一个名为 ng-hide(该名称容易与指令名混淆) 的 CSS 类来控制元素的可见性. ng-hide 这个类的 CSS 样式将 display 属性设置为 none, 从而从视图中移除钙元素. 

**注意** ng-show 和 ng-hide 指令仍会将所操作的元素保存在 DOM 内, 仅仅只是对用户隐藏. 对浏览器来说他并没有隐藏, 仍然在哪里, 因此类似这种根据位置进行选择的 CSS 选择器讲会把隐藏元素也计算在内. 例如在下面对 item.complete 进行渲染时, (Incomplete) 拥有加粗效果, 而 (Done) 则没有.

    <style>
        td > *:first-child {font-weight: bold}
    </style>
    // ... 
    <body>
        <div id="todoPanel" class="panel" ng-controller="defaultCtrl">
            <h3 class="panel-header">To Do List</h3>

            <div class="checkbox well">
                <label>
                    <input type="checkbox" ng-model="todos[2].complete" />
                    Item 3 is complete
                </label>
            </div>

            <table class="table">
                <thead>
                    <tr><th>#</th><th>Action</th><th>Done</th></tr>
                </thead>
                <tr ng-repeat="item in todos">
                    <td>{ {$index + 1} }</td>
                    <td>{ {item.action} }</td>
                    <td>
                        <span ng-hide="item.complete">(Incomplete)</span>
                        <span ng-show="item.complete">(Done)</span>
                    </td>
                </tr>
            </table>
        </div>
    </body>

### 2. ng-if

    <td>
        <span ng-if="!item.complete">(Incomplete)</span>
        <span ng-if="item.complete">(Done)</span>
    </td>

**不能在同一个元素上, 同时使用 ng-repeat 和 ng-if 指令.**

### 3. ng-class, ng-class-odd, ng-class-even

用于将元素添加到类中或者设置单个 CSS 属性的指令.
ng-class 可以管理一个元素的 class 属性.

    <tr ng-repeat="item in todos" ng-class="settings.Rows"> ... </tr>

ng-class-odd 和 ng-class-even 配置 ng-repeat 使用, 用于 **仅对** 奇数或偶数行的元素应用 CSS 类.

    <tr ng-repeat="item in todos" ng-class-even="settings.Rows"
            ng-class-odd="settings.Columns">

### 4. ng-style

用于将元素添加到类中或者设置单个 CSS 属性的指令.
使用 ng-style 直接设置 CSS 属性, 而不是通过一个 CSS 类.

    <td ng-style="{'background-color': settings.Columns}">
        { {item.complete} }
    </td>

## 四. 事件处理
事件处理指令可以直接用于直接计算一个表达式, 或者调用控制器中的一个行为.

| 指令 | 用作 | 描述 |
| --- | --- | --- |
| ng-blur | 属性,类 | 为 blur 事件制定自定义行为, 在元素失去焦点时被触发 |
| ng-change | 属性,类 | 为 change 事件制定自定义行为, 在表单元素的内容状态发生变化时被触发(例如复选框被选中,输入框元素中的文本被修改等) |
| ng-click | 属性,类 | 为 click 事件指定自定义行为, 在用户点击鼠标/光标时被触发 |
| ng-copy, ng-cut, ng-paste | 属性,类 | 为 copy,cut,paste 事件指定自定义行为 |
| ng-dbclick | 属性,类 | 为 dbclick 事件指定自定义行为, 在用户双击鼠标/光标时被触发 |
| ng-focus | 属性,类 | 为 focus 事件指定自定义行为, 在元素获得焦点时被触发 |
| ng-keydown, ng-keypress, ng-keyup | 属性,类 | 为 keydown,keypress,keyup 事件指定自定义行为, 在用户按下,释放某个键时被触发 |
| ng-mousedown, ng-mouseenter,ng-mouseleave, ng-mousemove,ng-mouseover,ng-mouseup | 属性,类 | 为 6个标准鼠标事件事件指定自定义行为, 在用户使用鼠标/光标与元素发生交互时被触发 |
| ng-submit |  属性,类 | 为 submit 事件指定自定义行为, 在表单被提交时被触发 |

    $scope.handleEvent = function (e) {
        console.log("Event type: " + e.type);
        $scope.data.columnColor = e.type == "mouseover" ? "Green" : "Blue";
    }
    // ... 
    <table class="table">
        <thead>
            <tr><th>#</th><th>Action</th><th>Done</th></tr>
        </thead>
        <tr ng-repeat="item in todos" ng-class="data.rowColor"
            ng-mouseenter="handleEvent($event)"
            ng-mouseleave="handleEvent($event)">
            <td>{ {$index + 1} }</td>
            <td>{ {item.action} }</td>
            <td ng-class="data.columnColor">{ {item.complete} }</td>
        </tr>
    </table>

## 五. 布尔属性指令

映射指令, 用于在 AngularJS 所依赖的数据绑定的方式和那些被称为布尔属性的 HTML 特性之间进行映射.

| 指令 | 用作 | 描述 |
| --- | --- | --- |
| ng-checked | 属性 | 管理 checked 属性(在 input 元素上使用) |
| ng-disabled | 属性 | 管理 disabled 属性(在 input 和 button 上使用) |
| ng-open | 属性 | 管理 open 属性 (在 details 元素上使用) |
| ng-readonly | 属性 | 管理 readonly 属性(在 input 元素上使用) |
| ng-selected | 属性 | 管理 select 属性(在 option 元素上使用) |
| ng-href | 属性 | 在 a 元素上设置 href 属性 |
| ng-src | 属性 | 在 img 元素上设置 src 属性 |
| ng-srcset | 属性 | 在 img 元素上设置 srcset 属性. srcset 属性时扩展到 html5 的起草标准之一, 允许为显示不同的大小和像素密度而指定多张图片 |

    <script>
        angular.module("exampleApp", [])
            .controller("defaultCtrl", function ($scope) {
                $scope.dataValue = false;
            });
    </script>

    // ... 
    <div class="checkbox well">
        <label>
            <input type="checkbox" ng-model="dataValue">
            Set the Data Value
        </label>
    </div>
    
    <button class="btn btn-success" ng-disabled="dataValue">My Button</button>

## 六 表单验证

### 1 数据绑定
#### 1.1 `ng-model` 双向数据绑定

双向数据绑定与表单元素有内在的关联性, 因为通过他可以接受用户输入数据并更新模型.

    <table class="table">
        <thead>
            <tr><th>#</th><th>Action</th><th>Done</th></tr>
        </thead>
        <tr ng-repeat="item in todos">
            <td>{ {$index + 1} }</td>
            <td>{ {item.action} }</td>
            <td>
                <input type="checkbox" ng-model="item.complete"
            </td>
        </tr>
    </table>
#### 1.2. 隐式的创建模型属性

使用表单元素收集用户输入数据, 以便在数据模型中创建一个新的对象或属性.

    <div class="well">
        <div class="form-group row">
            <label for="actionText">Action:</label>
            <input id="actionText" class="form-control"
                    ng-model="newTodo.action">
        </div>
        <div class="form-group row">
            <label for="actionLocation">Location:</label>
            <select id="actionLocation" class="form-control"
                    ng-model="newTodo.location">
                <option>Home</option>
                <option>Office</option>
                <option>Mall</option>
            </select>
        </div>
        <button class="btn btn-primary btn-block"
                ng-click="addNewItem(newTodo)">
            Add
        </button>
    </div>

    # 当网页被首次加载时, newTodo 对象及其 action 和 location 属性并不存在. 在 input 元素或者 select 元素改变时, AngularJS 将会自动创建出 newTodo 对象, 并根据用户正在使用的是哪个元素, 赋值给该对象的 action 或 location 属性.

隐式创建和对象非常灵活, 但有时可能对象尚未创建. AngularJS 访问尚未创建的对象, 会报错, 因此检查所创建的数据模型对象尤其重要.**angular.isDefined(obj[.attr])**可以检查定义的属性或对象是否生成.

    $scope.addNewItem = function (newItem) {
        if (angular.isDefined(newItem) && angular.isDefined(newItem.action)
                && angular.isDefined(newItem.location)) {

            $scope.todos.push({
                action: newItem.action + " (" + newItem.location + ")",
                complete: false
            });
        }
    };

### 2 校验表单
#### 2.1 增加表单元素
AngularJS 对表单校验的支持主要是基于对标准 HTML 元素进行替换的.

    <form name="myForm" novalidate ng-submit="addUser(newUser)">

- `name="myForm"`属性
    替换表单元素的指令, 将会定义一些有用的变量, 用于表示表单数据的有效性, 并且通过 name 属性的值, 来访问这些变量值.

- `novalidate`属性
    用于禁用浏览器支持的校验功能, 并启用 AngularJS 校验功能. novalidate 属性定义于 HTML5 规范之中, 用于告诉浏览器不要自己校验表单, 从而允许 AngularJS 不受干扰的工作.

- `ng-submit="FUNC(param)"`指令
    ng-submit 指令为表单提交事件指定了一个自定义的响应行为, 将在用户提交表单时触发.

#### 2.2 使用校验属性

将标准 HTML 校验属性应用到 input 元素上.

    <label>Name:</label>
    <input name="userName" type="text" class="form-control"
                required ng-model="newUser.name">

    <label>Email:</label>
    <input name="userEmail" type="email" class="form-control"
            required ng-model="newUser.email">

- name 属性
    正如 form 元素那样, 为各个想要验证的元素添加 name 属性是非常重要的, 这样就可以访问到 AngularJS 所提供的各种特殊变量.

- type 属性
    type 属性指定了 input 元素接收的数据类型. HTML5 为 input 元素定义了 type 属性值的一个新集合, 以及可以被 AngularJS 所校验的值.

    **input 元素的 type 属性**

    | 属性值 | 描述 |
    | --- | --- |   
    | checkbox | 创建一个复选框 |
    | email | 创建一个接受邮件地址作为输入值的文本输入框 |
    | number  | 创建一个接受数值类型为值得文本输入框 |
    | radio  | 创建一个单选框 |
    | text  | 创建一个接受任何值的标准文本输入框 |
    | url  | 创建一个接受 URL 作为值得输入框 |
    | 注意 | 邮件地址和 URL 的校验式校验**格式**, 而不是检查地址或 URL 是否存在或被使用. |

- 混合使用 html 标准属性和 AngularJS 指令, 实现进一步约束.
    - required : 指定用户必须为待校验的表单提供一个输入值.

#### 2.3 监控表单的有效性

AngularJS 中用来替换标准表单元素的指令, 定义了一些特殊变量, 可以用来检查表单中各个元素或者整个表单的有效性状态. 这些变量可以联合使用, 以向用户展示校验错误的反馈信息.

**表单指令所定义的校验变量**

| 变量 | 描述 |
| --- | --- |
| $pristine | 如果用户没有与元素/表单产生交互, 返回 true |
| $dirty | 如果用户与元素/表单产生过交互, 返回 true |
| $valid | 当元素/表单内容的校验结果为有效时, 返回 true |
| $invalid | 当元素/表单内容的校验结果为无效时, 返回 true |
| $error | 提供校验错误的详细信息. |

示例代码:
    
    <button type="submit" class="btn btn-primary btn-block"
            ng-disabled="myForm.$invalid">
        OK
    </button>
    // 当表单校验结果为 false 时, 表单提交按钮禁用.


### 3 表单校验反馈

AngularJS 为报告实时校验信息, 提供两种机制:
- CSS 类
- 变量 

#### 3.1 使用 **CSS** 提供校验反馈

AngularJS 通过在一个类的集合中增加或者移除被校验的元素, 来报告有效性检查结果, 这一机制可以与 CSS 联合使用, 通过改变元素样式来为用户提供反馈信息.

**AngularJS 校验中使用到的 CSS 类**

| 变量 | 描述 |
| ---  | ---  | 
| ng-pristine | 用户未曾交互过的元素, 被添加到这个类 |
| ng-dirty | 用户曾经交互过的元素, 被添加到这个类 |
| ng-valid | 校验结果为 **有效** 的元素在这个类中 |
| ng-invalid | 校验结果为 **无效** 的元素在这个类中 |

① **基本 CSS 校验信息**

在每次用户交互之后, AngularJS 会从这些类中添加或移除正在被校验的元素, 也就是说可以使用这些类来向用户提供按键和单击的及时反馈, 无论是这个表单还是单个元素.

    <style>
        form .ng-invalid.ng-dirty { background-color: lightpink; }
        form .ng-valid.ng-dirty { background-color: lightgreen; }
        span.summary.ng-invalid { color: red; font-weight: bold; }
        span.summary.ng-valid { color: green; }
    </style>
    // ... 
    <div class="well">
        Message: { {message} }
        <div>
            Valid: 
            <span class="summary" 
                    ng-class="myForm.$valid ? 'ng-valid' : 'ng-invalid'">
                { {myForm.$valid} }
            </span>
        </div>

在 HTML 页面中, 
- 在发生交互之前, 所有元素都是 ng-pristine 类的成员.
- 内容有效的元素时 ng-valid 类的成员
- 内容无效的是 ng-invalid 类的成员,
- 在 CSS 选这起中将 ng-valid , ng-invalid, ng-dirty 联合使用时, 意味着直到用户开始与元素进行交互时, 才提供关于元素有效性的实时反馈.

② **扩展的校验信息**

上面的表中的列出的类给出了一个校验元素的整体提示信息, 但是 AngularJS 也会将元素添加到类中, 已给出关于应用到该元素的每一个校验约束的具体信息. 所使用的名字是基于相应的元素的.

    <style>
        form .ng-invalid-required.ng-dirty { background-color: lightpink; }
        form .ng-invalid-email.ng-dirty { background-color: lightgoldenrodyellow; }
        // 这里将两个检验约束应用到一个 input 元素上, 使用 required 属性要求必须输入一个值, 并且将 type 属性设置为 email 要求改属性必须为邮箱地址格式. AngularJS 遵守 required 属性的限制, 将把该元素添加到 ng-valid-required 和 ng-invalid-required 类中, 并准守格式限制使用 ng-valid-email 和 ng-invalid-email 类.

        form .ng-valid.ng-dirty { background-color: lightgreen; }
        span.summary.ng-invalid {color: red; font-weight: bold; }
        span.summary.ng-valid { color: green }
    </style>

使用这些类是必须小心, 因为对于一个元素来说,有可能对于一个约束是有效的, 但对于另一个却不是. 如 对于 type 属性为 email 的元素来说, 在输入为空时是有效的, 也就是说, 该元素此时即在 ng-valid-email 类中, 也在 ng-invalid-required 类中. 这是 HTML 规范的产物, 所以进行完整的测试时必要的.

#### 3.2 使用**特殊变量**提供校验反馈

- `ng-disable `

        <button type="submit" class="btn btn-primary btn-block" ng-disabled="myForm.$invalid">OK</button>

- `ng-show` 

        <div class="error" ng-show="myForm.userEmail.$invalid && myForm.userEmail.$dirty">                        
            <span ng-show="myForm.userEmail.$error.email">
                Please enter a valid email address
            </span>
            <span ng-show="myForm.userEmail.$error.required">
                Please enter a value
            </span>
        </div>

### 4 使用表单指令属性
AngularJS 通过使用指令提供了一些自由的表单特性, 能够用于替换标准表单元素, 如 input,form,select . 这些指令都支持一些可选的属性, 可以用于将表单元素更紧密的集成到 AngularJS 风格的应用开发中去.


#### 4.1 **input** 元素

| 名称 | 描述 |
| ---  | --- |
| ng-model | 用于指定双向绑定的模型 |
| ng-change | 用于指定一个表达式, 该表达式在元素内容被改变时被计算求值 |
| ng-minlength | 设置一个合法元素的最小字符数 |
| ng-maxlength | 设置一个合法元素的最大字符数 |
| ng-pattern | 设置一个正则表达式, 合法的元素内容必须匹配该这则表达式 |
| ng-required | 通过数据绑定设置 required 属性 |

    ***注意**: 
    - 上表中的属性,仅在 input 元素**没有**使用 type 属性或者 type 属性为 text, url, email, 和 number 时适用.
    - 当 type 属性值为 email, url, member 时, AngularJS 将会自动设置 ng-pattern 属性为相应的正则表达式, 并检查格式是否匹配. 对于这些类型的 input 元素不应再设置 ng-pattern 属性.

        <script>
            angular.module("exampleApp", [])
                .controller("defaultCtrl", function ($scope) {
                    $scope.requireValue = true;
                    $scope.matchPattern = new RegExp("^[a-z]");
                });
        </script>

        // ...
        
        <div id="todoPanel" class="panel" ng-controller="defaultCtrl">
            <form name="myForm" novalidate>
                <div class="well">
                    <div class="form-group">
                        <label>Text:</label>
                        <input name="sample" class="form-control" ng-model="inputValue"
                                ng-required="requireValue" ng-minlength="3" 
                                ng-maxlength="10" ng-pattern="matchPattern">
                    </div>
                </div>

                <div class="well">
                    <p>Required Error: { {myForm.sample.$error.required} }</p>
                    <p>Min Length Error: { {myForm.sample.$error.minlength} }</p>
                    <p>Max Length Error: { {myForm.sample.$error.maxlength} }</p>
                    <p>Pattern Error: { {myForm.sample.$error.pattern} }</p>
                    <p>Element Valid: { {myForm.sample.$valid} }</p>
                </div>
            </form>
        </div>

#### 4.2 **checkbox** 元素
当 type 属性为 checkbox 时, 可用于 input 元素的额外属性.

| 名称 | 描述 |
| ---  | ---  |
| ng-model | 指定双向绑定的模型 |
| ng-chenge | 用于指定一个表达式, 该表达式在元素内容被改变时被计算求值 |
| ng-true-value | 指定当元素被勾选中时所绑定的表达式的值 |
| ng-false-value | 指定当元素被取消勾选中时所绑定的表达式的值 |

    <form name="myForm" novalidate>
        <div class="well">
            <div class="checkbox">
                <label>
                    <input name="sample" type="checkbox" ng-model="inputValue"
                            ng-true-value="Hurrah!" ng-false-value="Boo!">
                    This is a checkbox
                </label>
            </div>
        </div>
        <div class="well">
            <p>Model Value: { {inputValue} }</p>
        </div>
    </form>
    // 此示例中, inputValue 的值等于 ng-true-value 或 ng-false-value 的值.

`ng-true-value` 和 `ng-false-value` 属性的值将被用于设置所绑定的表达式的值, 但是只在当复选框的勾选状态被改变时生效, 也就是模型属性(如果被印式定义过的话)不会被自动创建, 直到有用户与元素的交互产生时才会被创建 (即使设置了 ng-checked 也是如此).

#### 4.3 **textare** 元素

| 名称 | 描述 |
| ---  | --- |
| ng-model | 用于指定双向绑定的模型 |
| ng-change | 用于指定一个表达式, 该表达式在元素内容被改变时被计算求值 |
| ng-minlength | 设置一个合法元素的最小字符数 |
| ng-maxlength | 设置一个合法元素的最大字符数 |
| ng-pattern | 设置一个正则表达式, 合法的元素内容必须匹配该这则表达式 |
| ng-required | 通过数据绑定设置 required 属性 |

    <script>
        angular.module("exampleApp", [])
            .controller("defaultCtrl", function ($scope) {
                $scope.requireValue = true;
                $scope.matchPattern = new RegExp("^[a-z]");
            });
    </script>

    // ...
    
    <div id="todoPanel" class="panel" ng-controller="defaultCtrl">
        <form name="myForm" novalidate>
            <div class="well">
                <div class="form-group">
                    <label>Text:</label>
                    <textarea name="sample" cols="40" rows="3" ng-model="inputValue"
                    ng-required="requireValue" 
                    ng-minlength="3" 
                    ng-maxlength="10" 
                    ng-pattern="matchPattern"></textarea>
                </div>
            </div>

            <div class="well">
                <p>Required Error: { {myForm.sample.$error.required} }</p>
                <p>Min Length Error: { {myForm.sample.$error.minlength} }</p>
                <p>Max Length Error: { {myForm.sample.$error.maxlength} }</p>
                <p>Pattern Error: { {myForm.sample.$error.pattern} }</p>
                <p>Element Valid: { {myForm.sample.$valid} }</p>
            </div>
        </form>
    </div>

#### 4.4 **select** 元素        

AngularJS 用于 select 元素的指令包括: 
- 与 input 元素类似的 `ng-required` 属性
- 可用于从数组和对象中生成 option 元素的 `ng-options` 属性.

        <script type="text/javascript">
            angular.module("exampleApp", [])
                .controller('defaultCtrl', function ($scope) {
                    $scope.todos = [
                        {id: 100, action: "Get groceries", complete: false},
                        {id: 200, action: "Call plumber", complete: false},
                        {id: 300, action: "Buy running shoes", complete: true},
                        {id: 400, action: "Do somethins", complete: false},
                    ]
                });
        </script>

        // ... 
        <form name="myForm" novalidate>
            <div class="well">
                <div class="form-group">
                    <label>Select a Action:</label>
                    <select ng-model="selectValue" 
                    ng-options="item.action for item in todos">
                        
                    </select>
                </div>
            </div>
            <div class="well">
                <p>Selected : { { selectValue || "None"} }</p>
            </div>
        </form>

**ng-options**的表现形式

- 基本形式

    格式 : `<标签> for <项目> in <数组>`
    ng-model 的值为一个**对象**.

        <select ng-model="selectValue" 
        ng-options="item.action for item in todos">            
        </select>
- 改变第一个选项元素

    ng-model 的值为一个**对象**.

    当 AngularJS 在 ng-model 属性所指向的变量值为 undefined 时会生成这样的元素. 可以添加一个空值的 option 元素来代替默认的 option 元素.

        <select ng-model="selectValue" ng-options="item.action for item in todos">
            <option value="">(pick one)</option>
        </select>
        // 当前情况下, 当用户选定选项时 ng-model 的值会被更新为 集合中的一个 对象 .

    当没有指定第一项时, 第一项的结果为 `<option value="?" selected="selected"></option>`

- 改变选项值
    表达式 : `<所选属性> as <标签> for <变量> in <数组>`

        <select ng-model="selectValue" 
        ng-options="item.action as item.id for item in todos">
            <option value="">(pick one)</option>
        </select>    

- 选项组元素
    ng-options 属性可以用来按照某个属性值将各个选项进行分组, 为每个选项值生成一组 optgroup 元素.

        <script type="text/javascript">
            angular.module("exampleApp", [])
                .controller('defaultCtrl', function ($scope) {
                    $scope.todos = [
                        {id: 100, action: "Get groceries", complete: false, place: "Store"},
                        {id: 200, action: "Call plumber", complete: false, place: "Home"},
                        {id: 300, action: "Buy running shoes", complete: true, place: "Store"},
                        {id: 400, action: "Do somethins", complete: false, place: "Home"},
                    ]
                });
        </script>

        // ... 
        <select ng-model="selectValue" 
        ng-options="item.action as item.id group by item.place for item in todos">
            <option value="">(pick one)</option>
        </select>