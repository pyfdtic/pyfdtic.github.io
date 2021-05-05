---
title: Sublime-Text-使用总结
date: 2018-03-14 23:09:52
categories:
- Tools
tags:
- sublime
---
## 初始化配置

### 设置 Linux 换行符

    Perference->Setting-*. 设置对象是 default_line_ending, 这个参数有三 个可用选项：
    - system : system是根据当前系统情况设置, 
    - windows : windows使用的CRLF, 
    - unix : unix使用的是 LF
        
### 设置 tab 为 4 个空格.

    Preference -> Settings-User

    // The number of spaces a tab is considered equal to  
    "tab_size": 4,  
    // Set to true to insert spaces when tab is pressed  
    "translate_tabs_to_spaces": true, 

### 自动保存
     
    Preference -> Settings-User

    "save_on_focus_lost": true

### 手动安装插件

## 插件
    
    Preference -> Browse Package
    
    把下载的插件解压到打开的文件夹中, 解压后即可.

    去除解压后文件夹中的 `-` 等字符, 重启 sublime 即可.

### install package controll

    SUBLIME TEXT 3

        import urllib.request,os,hashlib; h = 'df21e130d211cfc94d9b0905775a7c0f' + '1e3d39e33b79698005270310898eea76'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)      

    SUBLIME TEXT 2

        import urllib2,os,hashlib; h = 'df21e130d211cfc94d9b0905775a7c0f' + '1e3d39e33b79698005270310898eea76'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); os.makedirs( ipp ) if not os.path.exists(ipp) else None; urllib2.install_opener( urllib2.build_opener( urllib2.ProxyHandler()) ); by = urllib2.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); open( os.path.join( ipp, pf), 'wb' ).write(by) if dh == h else None; print('Error validating download (got %s instead of %s), please try manual install' % (dh, h) if dh != h else 'Please restart Sublime Text to finish installation')

### 大块方框, 

    Sublime > Preferences > Package Settings > Anaconda > Settings User

    {"anaconda_linting": false}

### 中文输入法光标跟随

    Packages Control -> install -> IMESupport

### 常用插件

`SublimeLinter` : 用于高亮提示用户编写的代码中存在的不规范和错误的写法, 支持 JavaScript、CSS、HTML、Java、PHP、Python、Ruby 等十多种开发语言. 

`SideBarEnhancements` : SideBarEnhancements是一款很实用的右键菜单增强插件；在安装该插件前, 在Sublime Text左侧FOLDERS栏中点击右键, 只有寥寥几个简单的功能

`Javascript-API-Completions` : 支持Javascript、JQuery、Twitter Bootstrap框架、HTML5标签属性提示的插件, 是少数支持sublime text 3的后缀提示的插件, HTML5标签提示sublime text3自带, 不过JQuery提示还是很有用处的, 也可设置要提示的语言. 

`Git` : 

`Glue` : 会在界面下方显示一个小窗口, 你可以在那里写Shell脚本. 这样一来, 你的编辑器就不仅仅局限于使用Git了

`GitGutter & Modifi`c : 这些插件可以高亮相对于上次提交有所变动的行, 换句话说是实时的diff工具
    GitGutter : 这是一个小巧有用的插件, 它会告诉你自上次git commit以来已经改变的行. 一个指示器显示在行号的旁边. 

`PlainTasks` : 杰出的待办事项表！所有的任务都保持在文件中, 所以可以很方便的把任务和项目绑定在一起. 可以创建项目, 贴标签, 设置日期. 有竞争力的用户界面和快捷键. 

`Lua` : 

`Python` : 

`AllAutocomplete` : 搜索全部打开的标签页

`Emmet` : HTML 快速补全

`markdown` : 

`anaconda` : Python IDE

    anaconda 不能与 jedi 同时存在, 会出现 左括号无法写入的情况.

`GBK support` : 支持 GBK 编码

`SublimeTmpl` : 支持文件模板, [git 地址](https://github.com/kairyou/SublimeTmpl).
    
        默认模板支持及快捷键
            ctrl+alt+h html
            ctrl+alt+j javascript
            ctrl+alt+c css
            ctrl+alt+p php
            ctrl+alt+r ruby
            ctrl+alt+shift+p python

        添加自定义模板文件及快捷键 : 参考 https://segmentfault.com/a/1190000008674119

            1. 新建并编辑自定义模板文件 Packages\User\SublimeTmpl\templates\hexomd.tmpl
            
                ---
                title: ${saved_filename}
                date: ${date}
                categories:
                tags:
                ---
                摘要
                <!-- more -->
                正文

            2. sublime 模板文件定义 : Commands-User

                [
                    {
                        "caption": "Tmpl: Create Hexo Markdown", 
                        "command": "sublime_tmpl",
                        "args": {"type": "hexomd"}
                    }
                ]

            3. 快捷键定义 : KeyBing-User

                [
                    {
                        "keys": ["ctrl+alt+m"], "command": "sublime_tmpl",
                        "args": {"type": "hexomd"}, "context": [{"key": "sublime_tmpl.hexomd"}]
                    }
                ]

            4. 用户设置定义 : Settings-User

                {
                    # 支持 ${saved_filename} 变量
                    "enable_file_variables_on_save": true,
                }

### 设置快捷键. 在SublimeText里, 打开Preferences -> Key Bindings - User, 我设置的快捷键：

    [
        { "keys": ["ctrl+f9"], "command": "build" },
        { "keys": ["f10"], "command": "build", "args": {"variant": "Run"} },
        { "keys": ["ctrl+shift+x"], "command": "toggle_comment", "args": { "block": true } },
    ]       