---
title: AngularJS高级程序设计读书笔记--大纲篇
date: 2018-03-16 17:12:45
categories:
- JavaScript
tags:
- angularjs
- 前端框架
---

学习 AngularJS 的初衷是因为, 去年楼主开始尝试使用 Flask 开发自动化应用, 需要用到大量的表单, Flask-wtf 的功能不能满足要求, 并且不够灵活, 所以在某老猿的建议下开始尝试使用 AngularJS 来写表单. 第一感觉是惊艳, 原来可以这么 easy, 所以想深入的学习一下, 并买了若干本书.

<AngularJS高级程序设计> 是去年买的, 网上的评价一般, 但是楼主觉得讲的比较轻松和易懂, 所以拿来做些笔记和总结. 下面是具体的大纲和链接.

**这几篇文章只做总结和梳理, 方便个人查找.**

## 一. [模块](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%A8%A1%E5%9D%97%E7%AF%87/)

1. 模块基础
2. 使用模块组织代码

## 二. [控制器](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%8E%A7%E5%88%B6%E5%99%A8%E7%AF%87/)
控制器是一个 AngularJS 程序中最大的构件之一, 它扮演了模型和视图之间的渠道的角色. 大多数 AngularJS 项目拥有多个控制器, 每一个向应用程序的一部分提供所需的数据和逻辑.

## 三. 指令

指令是最强大的 AngularJS 特性, 通过他们能扩展并增强 HTML, 从而创建丰富的 Web 应用程序.

AngularJS 通过包含和增强 HTML 来创建 AngularJS 为web应用程序, 讲 HTML 当做构建应用程序特性的基础而不是要解决的问题来处理.

### (一) [内置指令](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%8C%87%E4%BB%A4%E7%AF%87%E4%B9%8B%E5%86%85%E7%BD%AE%E6%8C%87%E4%BB%A4/)

#### 1. 数据绑定指令

| 指令 | 用作 | 描述 |
| --- | --- | --- |
| ng-bind | 属性, 类 | 绑定一个 HTML 元素的 innerText 属性 |
| ng-bind-html | 属性, 类 | 使用一个HTML 元素的 innerHTML 属性创建数据绑定, 这是有潜在风险的, 因为这意味着浏览器把内容解析为 HTML, 而不是内容本身. |
| ng-bind-template | 属性, 类 | 与 ng-bind 类似, 但允许在属性值中制定多个模板表达式 |
| ng-model | 属性, 类 | 创建一个双向数据绑定 |
| ng-non-bindable | 属性, 类 | 声明一块不会被执行数据绑定的区域 |

#### 2. 模板指令

| 指令 | 用作 | 描述 |
| --- | --- | --- |
| ng-cloak | 属性, 类 | 使用一个 css 样式隐藏内联绑定表达式`{ {} }`, 在文档第一个加载时会短暂的可见 |
| ng-include | 元素, 属性, 类 | 向 DOM 中加载,处理和插入一段 HTML |
| ng-repeat | 属性, 类 | 对数组中或对象某个属性中的每一个对象生成一个元素及其内容的若干新拷贝 |
| ng-repeat-start | 属性, 类 | 表示含有多个顶层元素的重复区域的开始部分 |
| ng-repeat-end | 属性, 类 | 表示含有多个顶层元素的重复区域的结束部分 |
| ng-switch | 属性, 类 | 根据数据绑定的值修改 DOM 中的元素. |

#### 3. 元素指令

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

#### 4. 事件处理

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

#### 5. 布尔属性指令, 映射指令

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

#### 6. 表单验证


### (二) [自定义指令](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%8C%87%E4%BB%A4%E7%AF%87%E4%B9%8B%E8%87%AA%E5%AE%9A%E4%B9%89%E6%8C%87%E4%BB%A4/)

## 四. [过滤器](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E8%BF%87%E6%BB%A4%E5%99%A8%E7%AF%87/)
过滤器用于在视图中格式化展现给用户的数据. 一旦定义过滤器之后, 就可在整个模块中全面应用, 也就意味着可以用来保证跨多个控制器和视图之间的数据展示的一致性.

### (一) 过滤器的不同使用方式
### (二) 内置过滤器
### (三) 自定义过滤器

## 五. [服务](https://www.pyfdtic.com/2018/03/16/AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0--%E6%9C%8D%E5%8A%A1%E7%AF%87/)
服务是提供在整个应用程序中所使用的任何功能的单例对象.
**单例** : 只用一个对象实例会被 AngularJS 创建出来, 并被程序需要服务的各个不同部分所共享.
### (一) 内置服务
一些关键方法也被 AngularJS 成为服务. 如 $scope, $http.

### (二) 自定义服务
- Module.service(name, constructor)
- Module.factory(name, provider)
- Module.provider(name, type)
- Module.value(name, value)

## 六. AngularJS 扩展
### (一) [Angular-xeditable](https://vitalets.github.io/angular-xeditable/)
### (二) [angular-flash](https://github.com/sachinchoolur/angular-flash)
### (三) [Angular Advanced Searchbox](http://dnauck.github.io/angular-advanced-searchbox/)
### (四) [AngularUI](https://angular-ui.github.io/)

## 七. 参考链接:
[AngularJS高级程序设计](https://www.amazon.cn/%E5%9B%BE%E4%B9%A6/dp/B013AO48Q4/ref=sr_1_1?ie=UTF8&qid=1491881636&sr=8-1&keywords=AngularJS%E9%AB%98%E7%BA%A7%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1)
[书中源代码](http://oluv2yxz6.bkt.clouddn.com/pro-angularjs-master.zip)