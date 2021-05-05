---
title: 使用 markdown 写 PPT
date: 2018-07-20 23:07:35
categories:
- Tools
tags:
- PPT
- markdown
---

Landslide是基于Google的html5slides的一个Slide生成工具，可将markdown、ReST 或者 textile文件转化成HTML5的slide。

Landslide 基于 Python 开发，最大的优点就是简洁，从安装到编写，到生成的 slides 风格都十分简洁。整个过程，用户只需要懂 Markdown 语法就可以.

该转化支持内联模式，即生成一个具有完整功能的HTML文件，将依赖的css等东西放入其中，很容易用来分享。

[项目地址: https://github.com/adamzap/landslide](https://github.com/adamzap/landslide)
[作者写的几个例子: https://github.com/adamzap/landslide/tree/master/examples](https://github.com/adamzap/landslide/tree/master/examples)

## 一. 安装 使用
安装:
```
--- 安装
$ pip install landslide

--- 使用
$ landslide file.md -d name_you_like.html

```

幻灯片播放快捷键:

```
--- PPT 支持的快捷键

h:      展示帮助
← →:    上/下一张幻灯片
t：     显示目录
ESC:    展示PPT总览
n:      显示当前是第几张幻灯片
b:      屏幕全黑
e:      使当前幻灯片最大化
2:      展示 幻灯片 笔记, 指定的 .notes 宏里的内容
3:      展示伪3D效果
c:      取消显示前后幻灯片预览，只显示当前幻灯片
S:      展示每个幻灯片文件的 源地址 链接.
```

高级用法:

```
--- 设置自定义 目的文件
$ landslide slides.md -d /path/to/dest/slide.html

--- 目录
$ landslide slides/

--- 在直接打印结果
$ landslide slides.md -o | tidy

--- 使用其他主题
$ landslide slides.md -t mytheme
$ landslide slides.md -t /path/to/theme/dir

--- copy the whole theme directory to your presentation one by passing the --copy-theme option to the landslide command
$ landslide slides.md -t /path/to/theme/dir --copy-theme

--- 内嵌 Base-64 编码 图片
$ landslide slides.md -i

--- 导出为 pdf
$ landslide slides.md -d presentation.pdf

--- If you intend to publish your HTML presentation online, you'll have to use the --relative option, as well as the --copy-theme one to have all asset links relative to the root of your presentation;
$ landslide slides.md --relative --copy-theme

```

查看帮助
```
--- 帮助
$ landslide --help

    Usage: landslide [options] input.md ...

    Generates an HTML5 or PDF slideshow from Markdown or other formats

    Options:
      --version             show program's version number and exit
      -h, --help            show this help message and exit
      -c, --copy-theme      Copy theme directory into current presentation source
                            directory
      -b, --debug           Will display any exception trace to stdout
      -d FILE, --destination=FILE
                            The path to the to the destination file: .html or .pdf
                            extensions allowed (default: presentation.html)
      -e ENCODING, --encoding=ENCODING
                            The encoding of your files (defaults to utf8)
      -i, --embed           Embed stylesheet and javascript contents,
                            base64-encoded images in presentation to make a
                            standalone document
      -l LINENOS, --linenos=LINENOS
                            How to output linenos in source code. Three options
                            availables: no (no line numbers); inline (inside <pre>
                            tag); table (lines numbers in another cell, copy-paste
                            friendly)
      -o, --direct-output   Prints the generated HTML code to stdout; won't work
                            with PDF export
      -P, --no-presenter-notes
                            Don't include presenter notes in the output
      -q, --quiet           Won't write anything to stdout (silent mode)
      -r, --relative        Make your presentation asset links relative to current
                            pwd; This may be useful if you intend to publish your
                            html presentation online.
      -t THEME, --theme=THEME
                            A theme name, or path to a landlside theme directory
      -v, --verbose         Write informational messages to stdout (enabled by
                            default)
      -x EXTENSIONS, --extensions=EXTENSIONS
                            Comma-separated list of extensions for Markdown
      -w, --watch           Watch source directory for changes and regenerate
                            slides
      -m, --math-output     Enable mathematical output using MathJax

    Note: PDF export requires the `prince` program: http://princexml.com/
```
## 二. 使用配置文件
声明配置文件如下: **必须声明 `[landslide]` 配置项**

```
$ cat config.cfg
  [landslide]
  theme = /path/to/mytheme
  source = myslice_source.md
           a_dir
           another_dir
           now_a_slide.markdown
           another_one.rst
  destination = /path/to/dest/presentation.html
  css =    my_first_stylesheet.css
           my_other_stylesheet.css
  js =     jquery.js
           my_fancy_javascript.js
  relative = True
  linenos = inline

--- 使用配置文件生成 slide
$ landslide config.cfg
```

## 三. Macros
**宏的使用, 必须紧紧跟在标题之后, 否则不生效!!!**

### 1. notes
使用 `.notes:` 关键字在 slide 中声明 注释说明.

```
# My Slide Title
.notes: These are my notes, hidden by default

My visible content goes here.
```

使用数字键 `2` 来打开显示 笔记.

### 2. QR Codes
使用 `.qr` 关键字添加一个 二维码到 slide 中.

```
---
# 关注我们
.qr: 450|https://www.pyfdtic.com

扫一扫, 关注我们!
```

### 3. Presenter Notes
在同一个页面中, 以 h1 标题模式, 声明另一个 `# Presenter Notes`, 可以作为 演讲者笔记 形式出现, 使用快捷键 `p` 显示和隐藏 笔记.

```
---
# 北京
You can also add presenter notes to each slide by following the slide content with a heading entitled "Presenter Notes". Press the 'p' key to open the presenter view.

# Presenter Notes
这才是我要说的, 你知道吗.
```
## 四. markdown 写作提要
- Markdown 源文件, 必须以 `.md/.markdn/.mdwn/.mdown/.markdown`
- `---` : 三个以上的 横线 表示强制分页.
- 每个 slide 页面应该用一个 `#` 来表示 渲染 `h1` 标题
- `open NAME.html` iterm2 会自动用浏览器打开该 html 页面. `open` 命令会使用系统定义的 文件默认打开程序 打开文件.



















