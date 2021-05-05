---
title: markdown 语法总结
date: 2018-03-14 17:38:24
categories:
- Tools
tags:
- 博客
- markdown
- 标记语言
---

1. 段落标题

    `在行首插入 1 - 6 个 # ,对应 标题1 - 标题6`

    `## 会在标题下面插入一个横线, 作为分割.`

2. 区块引用
    > 普通区块引用
    > > 嵌套区块引用

3. 列表
    1. 有序列表
        `` 数字 + . ``
    2. 无序列表
        `` * + - , 作用相同, 无差别 ``

4. 代码
    0. 代码块 --> 推荐 `\`\`\``
        使用 三个反引号, 无需制表符, 并且带 行号.
        ```
        ```
        ```
    1.代码块

        `缩进4个空格, 或一个制表符, 代码块会一直持续到没有缩进的哪一行, 或者文件结尾`

    2.小段代码

        `反引号包含小段代码`
5. 分割线

        三个以上的星号`*`,减号`-`, 来建立一个分割线, 行内不能有其他东西, 也可用于强制分页.

6. 链接
    1. 普通链接
        1. 行内式
        
            ``[Name](http://www.baidu.com "Title")``
        2. 引用式
        
            `定义: [id]: http://example.com "Optionnal Title"`
            `引用: [Name][id]`
    2. 图片
        1. 行内式
            
            `![Alt text](/path/to/img.jpg "Optional title")` 
        2. 引用式
        
            `定义: [id]: url/to/image  "Optional title attribute"`
            `引用: ![Alt text][id]`
        3. Markdown 无法指定图片的宽高, 如果需要请使用<img>
    3. 自动链接
    
        `针对URL  : <http://www.baidu.com>`

        `针对邮箱 : <admin@example.com>`
    
    
7. 强调
    1. 斜体
    
        `*WORD*`    
    2. 加粗
     
        `**WORD**`  

8. 转义 : 在一些符号前面加上 反斜杠 来插入特殊符号

9.表格基本

    | 表头 | 表头 | 表头 | 表头 |
    | --   | --- | --- | ---  |
    | 内容  | 内容  | 内容  | 内容  |

表格对齐  

    | :--  | ---> 左对齐  
    | ---: | ---> 右对齐  
    | :---:| ---> 居中对齐

10. 颜色

        `<font color="blue">GREEN</font>`
    <font color="blue">GREEN</font>

11. 删除线
    
    `~~这里是删除内容~~`

    效果 : 

    ~~这里是删除内容~~


12. TodoList
    
    ```
    - [ ] Eat
    - [x] Code
      - [x] HTML
      - [x] CSS
      - [x] JavaScript
    - [ ] Sleep
    ```
    

--------------

区块元素

    段落
        1. 类 Setext 格式 : 底线 形式
            
            最高阶标题 : ==== 
            第二阶标题 : ----

            示例 :
                This is H1
                ==========

                This is H2
                ----------

        2. 类 atx 格式 : # 形式
            在行首插入 1 - 6 个 # , 对应标题1 - 标题6

            示例 : 
                # This is H1
                ## This is H2
                ### This is H3

            ** 可以选择性的 [闭合] 类 atx 样式的标题 : 在行尾加上 # , 而且行尾的 # 数量也无需同开头一样.


    区块引用 Blockquotes

        普通区块引用 : >
            > This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
            > consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
            > Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.        

        嵌套区块引用 : 根据层次加上不同数量的 > 
            > This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
            >> consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
            >> Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.

        引用的区域也可以使用其他的 Markdown 语法 : 包括标题,列表,代码区块等.

    列表
        有序列表 : 数字 + .


        无序列表 : * + - , 作用相同, 无差别.


        ** 层次化表示, 需要缩进.

        ** 转义 : \ 
            如 : 1991\.12\.12

    代码区块
        缩进4个空格 , 或者 1 个制表符.

        代码区块会一直持续到没有缩进的那一行, 或是文件结尾.

        ** 代码区块中, 一般 Markdown 语法不会被转换.

    代码
        小段代码
            `CODE` 
            `` CODE ``

            ** 多个反引号时, 可以在代码中使用 反引号本身.
            ** 代码区段的起始和结束端都可以放入一个空白，起始端后面一个，结束端前面一个，这样你就可以在区段的一开始就插入反引号
            ** 在代码区段内，& 和尖括号都会被自动地转成 HTML 实体，这使得插入 HTML 原始码变得很容易

    分割线 : 
        三个以上的星号,减号,底线来建立一个分割线, 行内不能有其他东西. 型号或减号之间可以插入空格.

        ***
        * * *
        ---
        - - - - - 


    链接
        链接文字 : [文字]

        行内式
            [Name](http://www.baidu.com "Title")

            相对路径
                [logo](/static/logo.jpg "logo")             

        参考式 : 先定义, 后引用

            定义 :    在文档的任意处, 把这个标记的链接内容定义出来：
                [id]: http://example.com "Optionnal Title"

            引用 : 不区分大小写
                [Name][id]

            示例 :
                [foo]: http://example.com/  "Optional Title Here"
                [foo]: http://example.com/  'Optional Title Here'
                [foo]: http://example.com/  (Optional Title Here)
                [id]: <http://example.com/>  "Optional Title Here"

                [link text][a]
                [link text][A]

    强调 : 
        *WORDS*     : <em>
        _WORDS_     : <em>
        **WORD**    : <strong>
        __WORD__    : <strong>

        \*  : 转义
        \_  : 转义


        ** 如果 * 和 _ 两边都有空白的话，它们就只会被当成普通的符号。


    图片
        行内式
            ![Alt text](/path/to/img.jpg)
            ![Alt text](/path/to/img.jpg "Optional title")


        参考式
            ![Alt text][id]
            [id]: url/to/image  "Optional title attribute"

        ** Markdown 无法指定图片的 宽高, 如果需要可以使用 <img> 标签.

    自动链接 : 针对 URL 和 Email 地址
        
        <http://example.com/>

        <address@example.com>

    反斜杠 : 转义
        Markdown 支持一下这些符号前面加上 反斜杠 来帮助插入普通的符号.

        \   反斜线
        `   反引号
        *   星号
        _   底线
        {}  花括号
        []  方括号
        ()  括弧
        #   井字号
        +   加号
        -   减号
        .   英文句点
        !   惊叹号     

    免费编辑器
        Windows 平台
            MarkdownPad
            MarkPad

        Linux 平台
            ReText

        Mac 平台
            Mou

        在线编辑器
            Markable.in
            Dillinger.io

        浏览器插件
            MaDe (Chrome)

        高级应用
            Sublime Text 2 + MarkdownEditing / 教程   