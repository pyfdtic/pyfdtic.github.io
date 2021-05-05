---
title: AngularJS高级程序设计读书笔记--过滤器篇
date: 2018-03-16 17:09:08
categories:
- JavaScript
tags:
- angularjs
- 前端框架
---
## 一. 过滤器基础
过滤器用于在视图中格式化展现给用户的数据. 一旦定义过滤器之后, 就可在整个模块中全面应用, 也就意味着可以用来保证跨多个控制器和视图之间的数据展示的一致性.

过滤器将数据在被指令处理并显示到视图中之前进行转换, 而不必修改作用域中原有的数据, 这样能够允许同一份数据在应用中的不同部分以不同的形式得以展现.

过滤器可以执行任意类型的转换, 但是大多数情况下, 用于格式化或者对数据以某种方式排序.

## 二. 内置过滤器
### 1. 过滤单个数据的值
| 名称 | 描述 |
| ---  | ---  | 
| currency | 该过滤器对货币值进行格式化 |
| date | 对日期进行格式化 |
| json | 从 JSON 字符串中生成一个对象 |
| number | 对数字值进行格式化 |
| uppercase/lowercase | 将字符串格式化为全大写或全小写 |

    // currency 
    <td class="text-right">{ {p.price | currency:"£" } }</td>
    <td class="text-right">{ {p.price | currency} }</td>

    // number, number:0 , 0 表示显示的小数位数.
    <td class="text-right">${ {p.price | number:0 } }</td> 

    // date , 格式化日期, 这个日期可以是字符串,JavaScript 日期对象或毫秒数等
     <td>{ {getExpiryDate(p.expiry) | date:"dd MMM yy"} }</td>

    // uppercase/lowercase
    <td>{ {p.name | uppercase } }</td>
    <td>{ {p.category | lowercase } }</td>

**date 过滤器支持的格式化字符串**
![date 过滤器支持的格式化字符串](http://oluv2yxz6.bkt.clouddn.com/date.PNG)
**date 过滤器支持的快捷格式化字符串**
![date 过滤器支持的快捷格式化字符串](http://oluv2yxz6.bkt.clouddn.com/date_2.PNG)

### 2. 过滤数据集合

| 过滤器名称 | 描述 |
| --- | --- |
| limitTo | 限制项目数量, 支持数组对象,也支持字符串 |
| filter | 从数组中华选出一些对象, 选取条件可以为一个表达式,或者一个用于匹配属性的 map 对象 |
| orderBy | 对数组中的对象进行排序 |

    // limitTo , 支持正数和负数
    <tr ng-repeat="p in products | limitTo:limitVal">

    // filter: {FIELD: NAME}, 只显示某个字段的数据. 如果通过一个函数过滤, 那么选出的项目,僵尸那些是的函数执行结果返回 true 的.
    <tr ng-repeat="p in products | filter:{category: 'Fish'}">

    // 函数式筛选
    $scope.selectItems = function (item) {
        return item.category == "Fish" || item.name == "Beer";

    <tr ng-repeat="p in products | filter:selectItems">

    // orderBy: 
    <tr ng-repeat="p in products | orderBy:'price'"> // 根据对象的 price 属性进行排序. 注意引号
    <tr ng-repeat="p in products | orderBy:'price'"> // price 降序

    // 使用排序函数
    $scope.myCustomSorter = function (item) {
        return item.expiry < 5 ? 0 : item.price;
    }  
    <tr ng-repeat="p in products | orderBy:myCustomSorter">

    // 排序数组, 多次排序
    <tr ng-repeat="p in products | orderBy:[myCustomSorter, '-price']">
    
### 3. 链式过滤
使用多个过滤器, 按照顺序对同一数据进行操作.

    <tr ng-repeat="p in products | orderBy:[myCustomSorter, '-price'] | limitTo: 5">

## 三. 自定义过滤器


`Module.filter `方法用于定义过滤器, 其参数是新过滤器的名称以及一个在调用时将会创建过滤器的工厂函数. 过滤器本身就是函数, 接受数据值并进行格式化, 这样就可以显示该值了.


示例 : 用于过滤单个数据值的过滤器

    // labelCase 用于将字符串格式化为 只有首字母大写.
    angular.module("exampleApp")    // 此处用于查找 exampleApp 模块, 在这一段代码被当引用的时候, 应当放在 exampleApp 定义代码的后面.
        .filter("labelCase", function () {
            return function (value, reverse) {      // value 参数是待被过滤的值, 在应用时由 AngularJS 提供; reverse 参数用于允许过滤器用途被颠倒过来.
                if (angular.isString(value)) {
                    var intermediate =  reverse ? value.toUpperCase() : value.toLowerCase();
                    return (reverse ? intermediate[0].toLowerCase() :
                        intermediate[0].toUpperCase()) + intermediate.substr(1);
                } else {
                    return value;
                }
            };
        });

    // 在 HTML 代码中使用
    <td>{ {p.name | labelCase } }</td>    // 此处没有指定第二个参数, 则 AngularJS 会将 null 值传给过滤器的worker 函数的第二个参数.
    <td>{ {p.category | labelCase:true } }</td>    

示例 : 用于过滤数据集合的过滤器
    
    // skip 用于返回数据集合中指定数量的元素.
    angular.module("exampleApp")
        .filter("labelCase", function () {
            return function (value, reverse) {
                if (angular.isString(value)) {
                    var intermediate =  reverse ? value.toUpperCase() : value.toLowerCase();
                    return (reverse ? intermediate[0].toLowerCase() :
                        intermediate[0].toUpperCase()) + intermediate.substr(1);
                } else {
                    return value;
                }
            };
        })
        .filter("skip", function () {
            return function (data, count) {
                if (angular.isArray(data) && angular.isNumber(count)) {     // 边界检查
                    if (count > data.length || count < 1) {     // 边界检查
                        return data;
                    } else {
                        return data.slice(count);
                    }
                } else { 
                    return data;
                }
            }
        });

    // 调用
    <tr ng-repeat="p in products | skip:2 | limitTo: 5">

示例 : 在已有的过滤器上搭建新的过滤器.

    // 将 skip 和 limitTo 的功能合并到单个过滤器中.
    angular.module("exampleApp")
        .filter("labelCase", function () {
            return function (value, reverse) {
                if (angular.isString(value)) {
                    var intermediate =  reverse ? value.toUpperCase() : value.toLowerCase();
                    return (reverse ? intermediate[0].toLowerCase() :
                        intermediate[0].toUpperCase()) + intermediate.substr(1);
                } else {
                    return value;
                }
            };
        })
        .filter("skip", function () {
            return function (data, count) {
                if (angular.isArray(data) && angular.isNumber(count)) {
                    if (count > data.length || count < 1) {
                        return data;
                    } else {
                        return data.slice(count);
                    }
                } else { 
                    return data;
                }
            }
        .filter("take", function ($filter) {    // 声明对 $filter 服务的依赖, 这提供了对模块中所有已定义的过滤器的访问能力. 这些过滤器通过在 worker 函数中通过名称来访问和调用.
            return function (data, skipCount, takeCount) {
                var skippedData = $filter("skip")(data, skipCount);
                return $filter("limitTo")(skippedData, takeCount);
            }
        });

        // html 中调用
        <tr ng-repeat="p in products | take:2:5">   // 多个参数.