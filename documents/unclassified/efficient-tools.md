# 提升工作效率的技巧汇总

## 如何内容输出到 Linux/Mac 剪切板
- Mac : `pbcopy` & `pbpaste`
    ```shell
    // 将输出复制至剪贴板
    $ echo "hello mac" | pbcopy

    // 将文件中的内容全部复制至剪贴板
    $ pbcopy < remade.md

    // 将剪切板中的内容粘贴至文件
    $ pbpaste > remade.md
    ```

- Linux: `xclip` & `xsel`

    Linux 用户需要先安装 xclip，它建立了终端和剪切板之间的通道。

    ```shell
    // 查看剪切板中的内容
    $ xclip -o
    $ xclip -selection c -o

    // 将输出复制至剪贴板
    $ echo "hello xclip" | xclip-selection c

    // 将文件中的内容全部复制至剪贴板
    $ xclip -selection c remade.md

    // 将剪切板中的内容粘贴至文件
    $ xclip -selection c -o > remade.md

    ```

    直接使用xsel命令：
    ```shell
    // 将输出复制至剪贴板
    $ echo "hello linux" | xsel

    // 将文件中的内容全部复制至剪贴板
    $ xsel < remade.md
    ```

    **xsel、xclip 命令是在 X 环境下使用的，所以远程连接服务器时使用会报异常**

- Windows

    ```shell
    // 将输出复制至剪贴板
    $ echo "hello windows" | clip

    // 将文件中的内容全部复制至剪贴板
    $ clip < remade.txt
    ```

## Chrome 插件
- `OneTeb`: chrome tab 合并到一个页面, 节省内存, 支持 html 导入导出
- `XPath helper`: 在 web 页面使用 XPath 选择元素
- `广告终结者`: 拦截广告
- `Smart TOC`: 自动生成网格的 TOC
- `FE Helper`: JSON自动格式化、手动格式化，支持排序、解码、下载等功能.
- `Octotree`: github 右侧树状代码浏览器
- `超级简单的自动刷新`: 网页自动刷新
- `身份验证器`: 两步验证.
- `有道词典Chrome划词插件`: 

## Mac 技巧
- `open`: 命令行, 使用系统默认应用打开文件或链接.

## VS Code
### 插件
- `Markdown All in One`: 写 Markdown 文档, 包含大纲等功能.
- `Marp for VS Code`: 使用 Markdown 写 PPT
- `vscode-pdf`: 支持只读形式打开 PDF 文档.

## 工具软件
- `docsify`: Makrdown 文档渲染工具.