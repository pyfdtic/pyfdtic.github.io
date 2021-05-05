---
title: AngularJS高级程序设计读书笔记--jqLite
date: 2018-03-16 17:07:35
categories:
- JavaScript
tags:
- angularjs
- 前端框架
- jqLite
- jQuery
---

jqLite 是 AngularJS 实现的一个剪裁版的 jQuery,  可以与 AngularJS 一起工作创建, 操作, 管理 HTML 元素. jqLite 的每一个方法的实现, 都对应一个 jQuery 的同名方法. [jQuery API](http://jquery.com).

### 1. 对文档对象模型(DOM)导航
AngularJS 用于表示 HTML 元素的对象( jqLite对象 ), 实际上可以表示零个, 一个或多个 HTML 元素. 因此, 有些 jqLite 方法会将 jqLite 对象当做一个集合处理.

| 名称 | 描述 |
| -- | -- |
| children() | 返回一组子元素(直接定义在该元素下的元素), 该方法的 jqLite 实现*不支持* jQuery 所提供的选择器特性. |
| partent() | 返回父元素, 该方法的 jqLite 实现*不支持* jQuery 所提供的选择器特性. |
| next() | 获得下一个兄弟元素, 该方法的 jqLite 实现*不支持* jQuery 所提供的选择器特性. |
| eq(index) | 从一个元素集合中, 返回制定索引下的元素. |
| find(tag) | 按照制定的 tag 名称定位所有的**后代元素**. jQuery 的实现为选择元素提供了额外选项, 但该方法的 jqLite 实现中并不可用. |


```
// JavaScript
<script>
    var app = angular.module("exampleApp", [])
        .directive('demoDirective', function () {
            return function(scope, element, attrs){
                // var items = element.children();     // 查找所有子元素.
                var items = element.find("li");        // 查找所有后代元素. 

                for (var i=0; i<items.length; i++){
                    if (items.eq(i).text() == "Oranges"){
                        items.eq(i).css("font-weight", "bold");
                    }
                }
            }
        })
        .controller("defaultCtrl", function ($scope) {
            // controller code here
        })

</script>

// HTML
<body ng-app="exampleApp" ng-controller="defaultCtrl">
    <h3>Fruit</h3>
    <ol demo-directive>
        <li>Apples</li>
        <ul>
            <li>Bananas</li>
            <li>Cherries</li>
            <li>Oranges</li>
        </ul>
        <li>Oranges</li>
        <li>Pears</li>
    </ol>
</body>

```

### 2. 修改元素
jqLite 提供了修改元素内容和属性的方法.

| 名称 | 描述 |
| -- | -- |
| attr(name), attr(name, value) | 获得 jqLite 对象中的第一个元素的指定**特性**的值, 或者为所有元素设置指定值. |
| css(name), css(name, value) | 获得 jqLite 对象中的第一个元素的指定 **CSS 属性**的值, 或者为所有元素设置指定值. |
| prop(name), prop(name, value) | 获得 jqLite 对象中的第一个元素的指定**属性**的值, 或者为所有元素设置指定值. |
| text(), text(value) | 获得 jqLite 对象中所有元素的文本内容拼接后的结果, 或者设置所有元素的文本内容. |
| val(), val(value) | 获取 jqLite 对象中的第一个元素的 value 特性, 或者设置所有元素的 value 特性. |
| hasClass(name) | 如果 jqLite 对象中有任一对象属于指定的 class 时, 返回 true. |
| addClass(name) | 将 jqLite 对象中的所有元素添加到指定的 class |
| removeClass(name) | 从 jqLite 对象中**移除具有指定 class 的元素**. |
| removeAttr(name) | 从 jqLite 对象的所有元素中, **移除某个特性** |
| toggleClass(name) | 为 jqLite 对象中的所有元素切换指定 class 的所属资格. 那些不在 class 中的元素将被添加到其中, 而那些在 class 中的元素将会从中移除. |

```
var app = angular.module("exampleApp", [])
    .directive('demoDirective', function () {
        return function(scope, element, attrs){
            // var items = element.children();     // 查找所有子元素.
            var items = element.find("li");        // 查找所有后代元素. 
            items.css("color", "red");             // 设置所有元素的 css color 属性.
            for (var i=0; i<items.length; i++){
                if (items.eq(i).text() == "Oranges"){
                    items.eq(i).css("font-weight", "bold");
                } else {
                    items.eq(i).css("font-weight", "normal")
                }
            }
            console.log(items.length)
            console.log(items.css("font-weight"))   // 获取第一个元素的 css font-weight 属性.
        }
    })
```
**特性**与**属性**
prop 方法处理的是被 DOM API HTMLElement 对象所定义的的属性;
attr 方法处理的是被标记语言中的 HTML 元素所定义的特性. 

通常, 特性和属性是一致的, 但并非总是如此, 如 class 特性在 HTMLElement 对象中使用 className 属性表示的.

一般来说, prop 方法会是应该使用的选择, 因为他返回的对象与特性值相比更容易使用. 这些对象都是 [DOM API](https://www.w3.org/TR/html5) 所定义的

### 3. 创建和移除元素

| 名称 | 描述 |
| -- | -- |
| angular.element(html) | 创建一个代表特定 HTML 字符串的元素的 jqLite 对象. |
| after(elements) | 在调用方法的元素后面插入特定内容. |
| append(elements) | 在调用方法的 jqLite 对象的**每一个元素上**, 将特定元素作为**最后一个子元素**插入. |
| clone() | 从方法调用的对象复制元素并作为一个新的 jqLite 对象返回. |
| prepend(elements) | 在调用方的的 jqLite 对象的**每一个元素**上, 将特定元素作为**第一个子元素**插入 |
| remove() | 从 DOM 中删除 jqLite 对象的元素 |
| replaceWith(elements) | 用指定元素替换调用方法的 jqLite 对象的元素 |
| wrap(elements) | 使用特定元素包装 jqLite 对象中的**每个元素**. |

需要注意, jQuery fluent API . 这意味着, 许多这类方法返回的 jqLite 对象中包含了原来在调用方法的 jqLite 对象中就存在的元素, 而不是那些参数中的元素. 如下示例中的 `var listItem = element.append("<ol>");`, append 方法返回的是一个表示操作被执行的元素的 jqLite 对象, 即 div 元素, 而非 ol 元素.

解决这个问题的一个有效方法就是, 使用 `angular.element` 方法来创建 jqLite 对象并在单独的语句中对他们执行各种操作. 

```
<script>
    var app = angular.module("exampleApp", [])
        .directive('demoDirective', function () {
            return function(scope, element, attrs){
                // 错误版本
                // var listItem = element.append("<ol>");   // append 方法返回的是一个表示操作被执行的元素的 jqLite 对象, 即 div 元素, 而非 ol 元素
                // for (var i=0; i<scope.names.length; i++){
                //     listItem.append("<li>").append("<span>").text(scope.names[i]);
                // }

                // 正确版本
                var listItem = angular.element("<ol>");
                element.append(listItem);
                for (var i=0; i<scope.names.length; i++){
                    listItem.append(
                        angular.element("<li>").append(angular.element("<span>").text(scope.names[i]))
                        );
                }
            }
        })
        .controller("defaultCtrl", function ($scope) {
            $scope.names = ["Apples", "Namamas", "Oranges"]
        })

</script>

</head>
<body ng-app="exampleApp" ng-controller="defaultCtrl">
    <h3>Fruit</h3>
    <div demo-directive></div>
</body>
```

### 4. 处理事件

jqLite 支持处理元素所发生的事件, 这些方法与那些内置的**事件指令**, 用来接收和处理事件的方法是同样的方法.

| 名称 | 描述 |
| -- | -- |
| on(events, handler) | 为 jqLite 对象所代表的元素发生事件注册一个处理器. 本方法的 jqLite 实现**不支持** jQuery 提供的选择器或事件数据特性. |
| off(events, handler) | 为 jqLite 对象所代表的元素发生的事件移除一个之前已注册的处理器. 本方法的 jqLite 实现**不支持** jQuery 提供的选择器或事件数据特性. |
| triggerHandler(event) | 对 jqLite 对象所代表的所有元素上注册的指定事件触发所有处理器. |

```
<script>
    var app = angular.module("exampleApp", [])
        .directive('demoDirective', function () {
            return function(scope, element, attrs){
                // 错误版本
                // var listItem = element.append("<ol>");   
                // for (var i=0; i<scope.names.length; i++){
                //     listItem.append("<li>").append("<span>").text(scope.names[i]);
                // }

                // 正确版本
                var listItem = angular.element("<ol>");
                element.append(listItem);
                for (var i=0; i<scope.names.length; i++){
                    listItem.append(
                        angular.element("<li>").append(angular.element("<span>").text(scope.names[i]))
                        );
                };

                var buttons = element.find("button");
                // 注册 click 事件
                buttons.on("click", function(e){
                    element.find("li").toggleClass("bold")  // 切换 bold class 属性.
                })
            }
        })
        .controller("defaultCtrl", function ($scope) {
            $scope.names = ["Apples", "Namamas", "Oranges"]
        })

</script>
</head>
<body ng-app="exampleApp" ng-controller="defaultCtrl">
    <h3>Fruit</h3>
    <div demo-directive>
        <button>Click Me</button>
    </div>

</body>
```

### 5. 其他 jqLite 方法
| 名称 | 描述 |
| -- | -- |
| data(key), data(key, value) | 将任意数据与 jqLite 对象代表的所有元素关联起来, 或者从 jqLite 对象代表的**第一个元素**中获取制定 key 的值. |
| removeData(key) | 从 jqLite 对象代表的元素中移除与指定 key 相关联的数据 |
| html() | 返回 jqLite 对象所代表的第一个元素的内容的 HTML 表达上形式. |
| ready(handler) | 注册一个监听器函数, 该函数将在 DOM 的内容被**完全加载**时调用一次. |


### 6. 从 jqLite 访问 AngularJS 特性
jqLite 还提供了一些方法, 可以提供对 AngularJS 专属的特性的访问.

| 名称 | 描述 |
| -- | -- |
| controller(), controller(name) | 返回与当前元素或其父元素相关联的控制器. 控制器可以与指令交互.|
| injector() | 返回与当前元素相关的注入器. |
| isolatedScope() | 如果当前元素有相关联的独立的作用域, 则返回该作用域. |
| scope() | 返回与当前元素或其父元素相关联的作用域. |
| inheritedData(key) | 该方法与 jQuery 的 data 方法执行同样的功能, 但是会沿着元素层次结构向上查找与制定 key 相匹配的值. |

