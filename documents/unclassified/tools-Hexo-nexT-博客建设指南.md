---
title: Hexo+nexT 博客建设指南
date: 2018-03-14 17:38:24
categories:
- Tools
tags:
- Hexo
- nexT
- 博客
- markdown
---
# Hexo 搭建 Github 博客
## 开始使用
### 安装 git
    
    $ yum install git -y

### 安装 NodeJS
```Bash    
    $ git clone https://github.com/creationix/nvm.git
    $ source nvm/nvm.sh

    $ nvm install stable

    # nvm 使用国内源
    $ alias cnpm="npm --registry=https://registry.npm.taobao.org \
        --cache=$HOME/.npm/.cache/cnpm \
        --disturl=https://npm.taobao.org/dist \
        --userconfig=$HOME/.cnpmrc"

    # 或者:
    $ npm install -g cnpm --registry=https://registry.npm.taobao.org
```
### 设置 Github
#### 注册 github
#### 创建 github page

创建仓库, 仓库的名字要和你的账号对应, 格式为: `USERNAME.github.io`

### 安装 hexo-cli
```Bash
    $ chmod 755 /root && mkdir -m 755 -p /root/.npm/_logs
    $ npm install -g hexo-cli
    $ chmod 700 /root
    
    $ npm install -g hexo-cli
```
### 建站

#### 安装配置
```Python
    $ hexo init <floder>
    $ cd <floder>
    $ npm install

        文件件目录结构
        .
        ├── _config.yml     # 网站的配置信息, 可以在此配置大部分参数
        ├── package.json    # 应用程序的信息. EJS, Stylus 和 Markdown renderer 已默认安装，您可以自由移除。
        ├── scaffolds       # 模板文件夹, 当新建文章时, Hexo 会根据 scaffold 来建立文件. 
        |                   # Hexo 的模板是指在新建的 markdown 文件中默认填充的内容, 每次新建一篇文章时都会包含这个修改.
        ├── source          # 存放用户资源. 除 _posts 文件夹外, 开头命名为 _ 的文件/文件夹和隐藏的文件都会被忽略. 
        |   |               # Markdown 和 HTML 文件会被解析并放到 public 文件夹, 而其他文件会被拷贝过去.
        |   ├── _drafts
        |   └── _posts
        └── themes          # 主题文件夹, Hexo 会根据主题来生成静态内容.

    # 安装 next theme, 可选.
    $ mkdir themes/next
    $ curl -s https://api.github.com/repos/iissnan/hexo-theme-next/releases/latest | grep tarball_url | cut -d '"' -f 4 | wget -i - -O- | tar -zx -C themes/next --strip-components=1

    # 修改默认 主题设置, 可选
    $ vim _config.yml
        theme: next

    # 安装 hexo server
    $ npm install hexo-server --save

    # 启动 hexo server
    $ hexo server --ip=0.0.0.0
```
#### 写文章与提交部署

安装 hexo-deployer-git 部署方式

    $ npm install hexo-deployer-git --save
    
    # 配置部署方式
    $ vim _config.yml

        deploy:
          type: git
          repo: https://github.com/pyfdtic/pyfdtic.github.io.git
          branch: master


写文章

    # hexo new "TITLE"
    $ vim source/_posts/TITLE.md

        ---
        title: first post
        date: 2018-03-14 17:08:36
        categories:
        - test
        tags:
        - tag-a
        - tag-b
        - tag-c
        ---

        # content

写摘要:
    
    ---
    这里是摘要
    <!-- more -->
    这是正文   

生成静态文件并部署

    $ hexo g -d

密钥认证提交

    $ vim _config.yml 
        其中 repo 配置为 ssh 协议地址

        # 语言配置
        language: zh-Hans

    $ 在 github 上配置 ssh 密钥.

#### 配置主题

[文档](https://github.com/iissnan/hexo-theme-next/wiki/%E5%88%9B%E5%BB%BA-%22%E5%85%B3%E4%BA%8E%E6%88%91%22-%E9%A1%B5%E9%9D%A2)

    $ vim themes/next/_config.yml
        # 主页预览显示
        auto_excerpt:
          enable: true
          length: 250

        # 选择不同的主体
        #scheme: Muse
        scheme: Mist

        # 主页设置
        menu:
          home: / || home
          about: /about/ || user
          tags: /tags/ || tags
          categories: /categories/ || th
          archives: /archives/ || archive

`tags/categories` 页面
    
    # tags
    $ hexo new page "tags"
    $ vim source/tags/index.md
        ---
        title: Tags
        date: 2018-03-14 18:09:40
        type: "tags"
        comments: false
        ---

    $ vim themes/next/_config.yml
        menu:
          # ...
          tags: /tags/ || tags
          # ...

    # categories
    $ hexo new page "categories"
    $ vim source/categories/index.md
        ---
        title: Tags
        date: 2018-03-14 18:09:40
        type: "categories"
        comments: false
        ---

    $ vim themes/next/_config.yml
        menu:
          # ...
          categories: /categories/ || th
          # ...

`about`页面

    $ hexo new page "about"

文章置顶 + 置顶标签
    
    # 安装所需包
    $ npm uninstall hexo-generator-index
    $ npm install hexo-generator-index-pin-top -g

    # 编辑文章元信息, 添加 top 信息. 
    ## top 后面可以跟 true, 也可以跟数字, 数字越大, 越靠前.
    ---
    title: hexo+GitHub博客搭建实战
    date: 2017-09-08 12:00:25
    categories: 博客搭建系列
    top: 1
    ---

    # 设置置顶标志
    $ vim themes/next/layout/_macro/post.swig   在 <div class="post-meta"> 后插入如下代码:

          {% if post.top %}
            <font color=7D26CD>[置顶]</font>
            <span class="post-meta-divider">|</span>
          {% endif %}


谷歌/百度统计

    $ vim _config.yml

        google_analytics: UA-[numbers]
        baidu_analytics: your-analytics-id

站内搜索: 
    
    $ npm install hexo-generator-searchdb --save

    $ vim _config.yml

        search:
          path: search.xml
          field: post
          format: html
          limit: 10000

    $ vim themes/next/_config.yml

        local_search:
          enable: true
          # if auto, trigger search by changing input
          # if manual, trigger search by pressing enter key or search button
          trigger: auto
          # show top n results per article, show all results by setting to -1
          top_n_per_article: -1

站点地图:
    
    $ npm install hexo-generator-sitemap

    $ vim themes/next/_config.yml
        menu:
          # ...
          sitemap: /sitemap.xml || sitemap

    $ 在 google Search console 提交 siteamp 地图.


配置资源文件夹
    
    $ mkdir source/images
    
    # 在文章中引用

        ![](/images/image.jpg)


#### 主题配置参考

**站点配置**

    # =============================================================================
    # NexT Theme configuration
    # =============================================================================

    avatar: https://avatars1.githubusercontent.com/u/32269?v=3&s=460

    # Duoshuo
    duoshuo_shortname: notes-iissnan

    # Disqus
    disqus_shortname: 


    # Social links
    social:
      GitHub: https://github.com/iissnan
      Twitter: https://twitter.com/iissnan
      Weibo: http://weibo.com/iissnan
      DouBan: http://douban.com/people/iissnan
      ZhiHu: http://www.zhihu.com/people/iissnan


    # Creative Commons 4.0 International License.
    # http://creativecommons.org/
    # Available: by | by-nc | by-nc-nd | by-nc-sa | by-nd | by-sa | zero
    creative_commons: by-nc-sa

    # Google Webmaster tools verification setting
    # See: https://www.google.com/webmasters/
    google_site_verification: VvyjvVXcJQa0QklHipu6pwm2PJGnnchIqX7s5JbbT_0


    # Google Analytics
    # Google分析ID
    google_analytics:


    # 百度分析ID
    baidu_analytics: 50c15455e37f70aea674ff4a663eef27

    # Specify the date when the site was setup
    since: 2011

    # =============================================================================
    # End NexT Theme configuration
    # =============================================================================

**主题配置文件**
```
    menu:
      home: /
      categories: /categories
      archives: /archives
      tags: /tags
      #about: /about

    # Place your favicon.ico to /source directory.
    favicon: /favicon.ico

    # Set default keywords (Use a comma to separate)
    keywords: "Hexo,next"

    # Set rss to false to disable feed link.
    # Leave rss as empty to use site's feed link.
    # Set rss to specific value if you have burned your feed already.
    rss:

    # Icon fonts
    # Place your font into next/source/fonts, specify directory-name and font-name here
    # Avialable: default | linecons | fifty-shades | feather
    #icon_font: default
    #icon_font: fifty-shades
    #icon_font: feather
    icon_font: linecons

    # Code Highlight theme
    # Available value: normal | night | night eighties | night blue | night bright
    # https://github.com/chriskempson/tomorrow-theme
    highlight_theme: normal


    # MathJax Support
    mathjax:


    # Schemes
    scheme: Mist


    # Automatically scroll page to section which is under <!-- more --> mark.
    scroll_to_more: true



    # Automatically add list number to toc.
    toc_list_number: true


    ## DO NOT EDIT THE FOLLOWING SETTINGS
    ## UNLESS YOU KNOW WHAT YOU ARE DOING

    # Use velocity to animate everything.
    use_motion: true

    # Fancybox
    fancybox: true

    # Static files
    vendors: vendors
    css: css
    images: images

    # Theme version
    version: 0.4.2
```

代码折叠
```
https://xiaotiandi.github.io/publicBlog/2018-09-19-1985df3b.html 
https://blog.rmiao.top/hexo-fold-block/
https://jerryhanjj.github.io/2018/04/05/Hexo%E5%8D%9A%E5%AE%A2%E6%90%AD%E5%BB%BA%E5%8F%8A%E4%BC%98%E5%8C%96%EF%BC%88%E4%BA%8C%EF%BC%89%EF%BC%9A%E6%B7%BB%E5%8A%A0%E4%BB%A3%E7%A0%81%E6%8A%98%E5%8F%A0%E5%8A%9F%E8%83%BD/

```

#### 删除文章
    
    $ hexo clean
    $ hexo g -d

### 配置 `_config.yml`

### godaddy 域名解析至 github.io

假设域名为 example.com, 希望将 www.example.com 解析到 exampl.github.io
    
1. 在 exampl.github.io 的 git 仓库中添加 `CNAME` 文件, 内容为 `www.example.com`, 并将 `CNAME` 文件放到 source 目录下, 可以防止每次 hexo deploy CNAME 文件被覆盖掉.

2. 在 godaddy 购买域名

3. 管理域名 DNS 解析, 添加两条记录, 其中 192.30.252.154 是 github.io 的ip 地址.
    
        CNAME   www     example.github.io   
        A       @       192.30.252.154

    添加完成之后, 等待域名生效.


#### 网站

| 参数 | 描述 |
| --- | --- |
| title | 网站标题 |
| subtitle | 网站副标题 |
| description | 网站描述, 网站 SEO |
| author | 作者. 显示文章的作者 |
| language | 网站使用的语言|
| timezone | 网站时区. Hexo 默认使用浏览器时区 |

#### 网址

| 参数 | 描述 | 默认值 |
| --- | --- | --- |
| url | 网址 | - |
| root | 网站根目录 | - |
| permalink | 文章的永久链接 | `:year/:mouth/:day/:title` |
| permalink_defaults | 永久链接中各部分的默认值 | |

网站存放在子目录, 如果网站存放在子目录中, 如 `http://yoursite.com/blog` , 则需要把 `url` 设为 'http://yoursite.com/blog', 并把 `root` 设为 `/blog/`;

#### 目录
| 参数 | 描述 | 默认值 |
| --- | --- | --- |
| source_dir | 资源文件夹, 用于存放内容 | source |
| public_dir | 公共文件夹, 用于存放生成的站点文件 | public |
| tag_dir | 标签文件夹 | tags |
| archive_dir | 归档文件夹 | archives |
| category_dir | 分类文件夹 | categories |
| code_dir | include code 文件夹 | downloads/code |
| i18n_dir | 国际化(i18n)文件夹 | `:lang` |
| skip_render | 跳过指定文件的渲染, 可使用 glob 表达式来匹配路径 | | 

如果刚接触 hexo , 则没必要设置以上各值.

#### 文章

|参数 |  描述 | 默认值 |
| --- | --- | --- |
|new_post_name |  新文章的文件名称  |  `:title.md` |
|default_layout | 预设布局   | post |
|auto_spacing |    在中文和英文之间加入空格 | false |
|titlecase |   把标题转换为 title case |  false |
|external_link |   在新标签中打开链接  | true |
|filename_case |   把文件名称转换为 (1) 小写或 (2) 大写 | 0 |
|render_drafts |   显示草稿   | false |
|post_asset_folder |   启动 Asset 文件夹  | false |
|relative_link |   把链接改为与根目录的相对位址 | false |
|future |  显示未来的文章 | true |
|highlight |   代码块的设置 |  |

默认情况下，Hexo生成的超链接都是**绝对地址**. 建议使用绝对地址.

#### 分类 & 标签

| 参数 | 描述 | 默认值 | 
| --- | --- | --- |
| default_category | 默认分类 | `uncategorized` |
| category_map | 分类别名 | |
| tag_map | 标签别名 | |

#### 日期/时间格式
Hexo 使用 Moment.js 来解析和显示时间.

| 参数 | 描述 | 默认值 |
| --- | --- | --- |
| date_format | 日期格式 | `YYYY-MM-DD` |
| time_format | 时间格式 | `H:mm:ss` |

#### 分页
| 参数 | 描述 | 默认值 |
| --- | --- | --- |
| per_page | 每页显示的文章数量(0= 关闭分页功能) | 10 |
| pagination_dir | 分页目录 | page |

#### 扩展
| 参数 | 描述 | 默认值 |
| --- | --- | --- |
| theme | 当前主题名称, 值为 false 时禁用主题 | |
| deploy | 部署部分的设置 | |

### 指令
$ hexo SUB_CMD PARAM

    init [floder] : 新建一个网站. floder 为空时, 为当前文件夹.

    new [layout] <title> : 新建一篇文章, 如果没有设置`layout`的话, 默认使用 `_config.yml` 中的 `default_layout` 参数代替. 
                           如果标签包含空格, 请使用引号.

    generate : 生成静态文件. 可以简写为 "hexo g"
        --d, --deploy : 文件生成后, 立即部署网站
        -w, --watch : 监视文件变动.

    publish [layout] <filename> : 发表草稿

    server : 启动服务器, 默认为 "http://localhost:4000/"

        -p, --port : 指定端口
        -s, --static : 只使用静态文件,
        -l, --log : 启动日志记录, 使用覆盖记录格式.

    deploy : 部署网站. 可以简写为 "hexo d"
        -g, --generate : 部署之前预先生成静态文件.

    render <file1> [file2] ... : 渲染文件.
        -o, --output : 设置输出路径.

    migrate <type> : 从其他博客系统迁移.

    clean : 清除缓存文件(db.json) 和 已生成的静态文件(public). 
            在某些情况下(尤其是更换主题后), 如果发现对网站的更改无论如何不生效, 可能需要运行该命令.

    list <type> : 列出网站资料

    version : 显示 hexo 版本

    --safe : 在安全模式下运行, 不会载入插件和脚本. 当安装新插件遇到问题时, 可以尝试以安全模式重新执行.
    --debug : 在终端中显示调试信息, 并记录到 debug.log.
    --silent : 隐藏终端信息 
    --config custom.yml : 自定义配置文件路径, 执行后将不再使用 _config.yml 
    --draft : 显示 source/_drafts 文件夹中的草稿万丈.
    --cwd /path/to/cwd : 自定义当前工作目录.


## 基本操作
## 写作
### 新建文章

新建一篇文章:
    
    $ hexo new [layout] <title>

可以在 `layout` 中指定文章的布局(layout), 默认为 `post`, 可以通过修改 `_config.yml` 中的 `default_layout` 参数来指定默认布局.

### 文章布局

Hexo 有三种默认布局: `post`, `page`, `draft`. 他们分别对应不同的路径, 用户自定义的其他布局和`post`相同, 都将存储在`source/_posts` 文件夹.

| 布局 | 路径 |
| --- | --- |
| post | source/_posts |
| page | source |
| draft | source/_drafts |

**如果你不希望你的文章被处理, 可以将 Front-Matter 中的 layout: 设置为 false**

#### 草稿
草稿(draft) 默认不会显示在页面中, 可以在执行时加上 `--draft` 参数, 或是把 `render_drafts` 参数设置为 `true` 来**预览草稿**.

`draft` 为草稿布局, 保存与 `source/_drafts` 目录, 可以通过 `publish` 命令将草稿移动到`source/_posts` 文件夹, `publish` 与 `new` 使用方式十分类似.
    
    $ hexo publish [layout] <title>

### 文件名称
Hexo 默认以标题作为文件名称, 可以编辑 `new_post_name` 参数来改变默认的文件名称.如 `:year-:month-:day-:title.md`.

| 变量 | 描述 |
| --- | --- |
| `:title` | 标题(小写, **空格将被替换为短杠**) |
| `:year`  | 建立年份, 如 `2016` |
| `:mouth` | 建立月份, 前导有零, 如 `04` |
| `:i_mouth` | 建立月份, 前导无零, 如 `4` |
| `:day` | 建立的日期, 前导有零, 如 `07` |
| `:i_day` | 建立的日期, 前导无零, 如 `7` |

### 模板(scaffold)

#### 使用方法

在新建文章时, Hexo 会根据 `scaffolds` 文件夹内向对应的文件来建立新文件. 如:
    
    # hexo 在 scaffolds 文件夹中寻找 photo.md , 
    # 并根据其内容建立文章.
    $ hexo new photo "My Gallery"

#### 模板中的可用变量
| 变量 | 描述 | 
| --- | --- |
| `layout` | 布局 |
| `title` | 标题 |
| `date` | 文件建立日期 |

## Front-matter

### 使用格式及预定义参数
Front-matter 是文件最上方以 `---` 分割的区域, 用于指定个别文件的变量. 
    
    title: Hello World
    date: 2013/7/12 20:46:25
    ---

预定义参数列表如下:

| 参数 | 描述 | 默认值 |
| --- | --- | --- |
| `layout` | 布局 | |
| `title` | 标题 | | 
| `date` | 建立日期 | 文件建立日期 | 
| `updated` | 更新日期 | 文件跟新日期 |
| `comments` | 开启文章评论功能 | `true` |
| `tags` | 标签(不适用于分页) | |
| `categories` | 分类(不适用于分页) | |
| `permalink` | 覆盖文章网址 |

### 分类和标签
**只有文章支持分类和标签**, 可以在 `Front-matter` 中设置.
- 分类: 分类有顺序性和层次性, 如 `Foo,Bar` 不等于 `Bar, Foo`
- 标签: 标签没有顺序和层次

示例:
    
    categories:
    - Diary
    tags:
    - PS3
    - Games

WordPress 支持对一篇文章设置多个分类, 而且这些分类可以是同级的, 也可以是父子分类. 但 Hexo **不支持**指定多个同级分类. 如下的分类, `Life` 将成为 `Diary` 的子分类.
    
    categories
    - Diary
    - Life

### JSON Front-matter
可以使用 JSON 来编写 Front-matter, 只需将 `---` 替换为 `;;;` 即可:
    
    "title": "Hello World"
    "date": "2013/7/12 20:46:25"
    ;;;

## 标签插件(Tag Plugins)
标签插件和 Front-matter 中的标签不同, **标签插件是用于在文章中快速插入特定内容的插件**

### 引用块
在文章中插入引言, 可包含作者, 来源 和 标题.

**格式**

    {% blockquote [author[, source]] [link] [source_link_title] %}
    CONTENT
    {% endblockquote %}

**示例**
    
    # 引用网络上的文章
    {% blockquote Seth Godin http://sethgodin.typepad.com/seths_blog/2009/07/welcome-to-island-marketing.html Welcome to Island Marketing %}
    Every interaction is both precious and an opportunity to delight.
    {% endblockquote %}

    # 引用书上的句子
    {% blockquote David Levithan, Wide Awake %}
    Do not just seek happiness for yourself. Seek happiness for all. Through kindness. Through mercy.
    {% endblockquote %}    

### 代码块
在文章中插入代码.

**格式**
    
    {% codeblock [title] [lang:language] [url] [link text] %}
    CODE_SNIPPET
    {% endcodeblock %}

**示例**
    
    # 附加说明和网址
    {% codeblock _.compact http://underscorejs.org/#compact Underscore.js %}
    _.compact([0, 1, false, 2, '', 3]);
    => [1, 2, 3]
    {% endcodeblock %}

    # 指定语言
    {% codeblock lang:objc %}
    [rectangle setX: 10 y: 10 width: 20 height: 20];
    {% endcodeblock %}


### 反引号代码块
使用三个反引号类包裹的代码块:
    
    ``` [language] [title] [url] [link text] code snippet ```
    
### Pull Quote

    {% pullquote [class] %}
    content
    {% endpullquote %}

### jsFiddle

    {% jsfiddle shorttag [tabs] [skin] [width] [height] %}

### Gist
    
    {% gist gist_id [filename] %}

### 3iframe
    
    {% iframe url [width] [height] %}


### Image

    {% img [class names] /path/to/image [width] [height] [title text [alt text]] %}

### Link
在文章中插入链接, 并自动给外部链接添加 `target="_blank"`

    {% link text url [external] [title] %}

### Include Code
插入`source`文件夹内的代码文件.
    
    {% include_code [title] [lang:language] path/to/file %}

### Youtube
插入 Youtube 视频.
    
    {% youtube video_id %}

### Vimeo
插入 vimeo 视频
    
    {% vimeo video_id %}

### 引用文章
引用其他文章的链接.

    {% post_path slug %}
    {% post_link slug [title] %}

### 引用资源
引用文章的资源

    {% asset_path slug %}
    {% asset_img slug [title] %}
    {% asset_link slug [title] %}


### Raw
如果希望在文章中插入 Swig 标签, 可以尝试使用 Raw 标签, 以免发生解析异常.

    {% raw %}
    content
    {% endraw %}

## 资源文件夹
资源`Asset`代表 `source` 文件夹中除了文章以外的所有文件, 如图片,CSS,JS文件等.

如在 `source/images` 文件夹中的图片, 可以使用类似于`![](/images/NAME.jpg)` 方法访问他们.

### 文章资源文件夹
更加组织化的管理资源, 可以通过修改 `config.yml` 文件中的 `post_asset_folder` 选项设为 `true` 来打开.
    
    post_asset_folder: true

打开**资源文件管理功能**之后, Hexo 将会在每一次通过 `hexo new [layout] <title>` 命令创建新文章时自动创建一个文件夹. 这个资源文件夹间会有与这个 markdown 文件一样的名字. 将所有与该文章有关的资源放在这个关联文件夹中之后, 可以通过相对路径来引用这些资源, 这样就得到了一个更简单而且方便的得多的工作流.

### 相对路径引用的标签插件
通过常规的 markdown 语法和相对路径来引用图片和其他资源可能会导致他们在存档页和主页上显示不正常. 可以使用如下方式引用资源, 解决这个问题:

    {% asset_path slug %}
    {% asset_img slug [title] %}
    {% asset_link slug [title] %}

如, 当打开文章资源文件夹功能后, 资源文件夹中有一个 `example.jpg` 图片, 正确的引用该图片的方式是使用如下的标签插件, 而不是 markdown, 该图片将会同时出现在文章和主页及归档页中:
    
    {% asset_img example.jpg This is an example image %}

## 数据文件
有时, 可能需要在主题中使用某些资料, 而这些资料并不在文章内, 并且是需要重复使用的, 那么可以使用 **Hexo 3.0** 新增的 **数据文件**功能, 此功能会载入 `source/_data` 内的 YAML 或 JSON 文件, 以方便在网站中复用这些文件.
    
    # source/_date/menu.yml
    Home: /
    Gallery: /gallery/
    Archives: /archives/

    # 在模板中引用这些资料:
    <% for (var link in site.data.menu) { %>
        <a href="<%= site.data.menu[link] %>"> <%= link %> </a>
    <% } %>

    # 渲染结果
    <a href="/"> Home </a>
    <a href="/gallery/"> Gallery </a>
    <a href="/archives"> Archives </a>

## 服务器
### hexo-server
**Hexo 3.0** 把服务器独立成了个别模块, 必须先安装 `hexo-server` 才能使用.
    
    # 安装
    $ npm install hexo-server --save

    # 启动服务器, 默认 http://localhost:4000
    $ hexo server [-p PORT] [-i IP_ADDRESS] [-s]
        -s : 静态模式, 服务器只处理 public 文件夹内的文件, 而不会处理文件变动, 在执行时, 应该先自行执行 hexo generate, 常用于生产环境.

        -i IP_ADDRESS : 指定IP地址, 默认为 0.0.0.0 .
        -p PORT : 指定监听端口.

### Pow
Pow 是 Mac 系统上的零配置 Rack 服务器, 他也可以作为一个简单易用的静态文件服务器来使用.
    
    # 安装
    $ curl get.pow.cx | sh

    # 设置: 在 ~/.pow 文件夹建立链接(symlink)
    $ cd ~/.pow
    $ ln -s /path/to/myapp 

    # 网站将在 http://myapp.dev 下运行, 网址根据链接名称而定.

## 生成器
### 生成文件:
    
    $ hexo generate [--watch] 
        --watch : 监视文件变动并立即重新生成静态文件. 在生成时对比文件的 SHA1 , 只有变动的文件才会写入.

### 完成后部署
如下两个命令功能相同, **让 Hexo 在生成完毕后自动部署网站**.
    
    $ hexo generate --deploy
    $ hexo g -d     # 上述命令的简写

    $ hexo deploy --generate
    $ hexo d -g     # 上述命令的简写

## [部署](https://hexo.io/zh-cn/docs/deployment.html)
**部署步骤**
    
    $ vim _config.yml
    deploy:
        type: git

    $ hexo deploy

### git 部署
    
    # 安装 hexo-deployer-git
    $ npm install hexo-deployer-git --save

    # 修改 _config.yml
    deploy:
        type: git
        repo: <REPOSITORY URL>
        branch: <GIT BRANCH>
        message: <自定义提交信息>  # 默认为 Site updated: {{ now('YYYY-MM-DD HH:mm:ss') }}

    # 部署
    $ hexo deploy

### Heroku 部署
    
    # 安装 hexo-deployer-heroku
    $ npm install hexo-deployer-heroku --save

    # 修改 _config.yml
    deploy:
        type: heroku
        repo: <REPOSITORY URL>
        message: <自定义提交信息>  # 默认为 Site updated: {{ now('YYYY-MM-DD HH:mm:ss') }}

    # 部署
    $ hexo deploy



## 自定义
### 永久链接(Permalink)
https://hexo.io/zh-cn/docs/permalinks.html
### 主题

#### 修改主题
- 在 `themes` 文件夹内, 创建一个任意名称的文件夹, 
- 修改 `_config.yml` 内的 `theme` 设定, 即可切换主体题

#### 主题目录结构
    .
    ├── _config.yml
    ├── languages
    ├── layout
    ├── scripts
    └── source

##### `_config.yml`
主体的配置文件, 修改时会自动更新, 无需重启服务器.

##### languages
语言文件夹, 参见[国际化](i18n)

##### layout
布局文件夹, 用于存放主题的模板文件, 决定网站内容的呈现方式. 

Hexo 内建 *Swig* 模板引擎, 可以另外安装插件来获得 EJS, Haml, Jade 支持, Hexo 根据模板文件的扩展名来决定所使用的模板引擎.

##### scripts
脚本文件夹, 在启动时, Hexo 会自定载入此文件夹内的 JavaScript 文件.

##### source

资源文件夹, 除了模板以外的 Asset, 如 CSS , JavaScript 文件等, 都应该放在这个文件夹中. 文件或文件夹前缀为 `_ (下划线)` 或 隐藏的文件会被忽略.

如果文件可以被渲染的话, 会经过解析然后存储到 `public` 文件夹, 否则会直接拷贝到 `public` 文件夹.

### 模板
https://hexo.io/zh-cn/docs/templates.html

### 变量
https://hexo.io/zh-cn/docs/variables.html

### 辅助函数
https://hexo.io/zh-cn/docs/helpers.html#toc

### 国际化(i18n)
https://hexo.io/zh-cn/docs/internationalization.html

### 插件
https://hexo.io/zh-cn/docs/plugins.html




# nexT

http://theme-next.iissnan.com/getting-started.html#third-party-services

## 参考文档
[hexo-theme-next](https://github.com/iissnan/hexo-theme-next)
[hexo-wiki](https://github.com/iissnan/hexo-theme-next/wiki)

[hexo 文档 - 中文](https://hexo.io/zh-cn/docs/)
[hexo 文档 - 英文](https://hexo.io/docs/)
[nexT 主题配置文档](http://theme-next.iissnan.com/getting-started.html)











