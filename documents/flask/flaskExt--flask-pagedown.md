---
title: Flask 扩展之--flask-pagedown
date: 2018-03-19 18:49:27
categories:
- Python
tags:
- Flask
- Flask 扩展
---
支持 Markdown 语法, 并添加 富文本文章的预览功能.

使用到的包列表:
- PageDown : 使用 JavaScript 实现的客户端 Markdown 到 HTML 的转换程序.
- Flask-PageDown : 为 Flask 包装的 PageDown, 把 PageDown 集成到 Flask-WTF 表单中.
- Markdown : 使用 Python 实现的服务端 Markdown 到 HTML 的转换程序.
- Bleanch : 使用 Python 实现的 HTML 清理器.

# 一. 安装 : 
    
    $ pip install flask-pagedown markdown bleach

# 二. 初始化 Flask-PageDown : 
与在 Flask 中初始化其他扩展一样.

    from flask_pagedown import PageDown
    # ...
    pagedown = PageDown()
    # ...
    def create_app(config_name):
        # ...
        pagedown.init_app(app)
        # ...

# 三. 使用(渲染) Flask-PageDown : 
Flask-PageDown 扩展定义了一个 PageDownField 类, 该类与 WTForms 的 TextAreaField 接口一致.

    from flask_pagedown.fields import PageDownField

    class PostForm(Form):
        body = PageDownField("Post:", validators=[required()])
        submit = SubmitField("Submit")

# 四. Markdown 预览 : 
Markdown 预览使用 PageDown 库生成, 因此需要在 Jinja 模板中修改. Flask-PageDown 简化了这一过程, 提供了一个红模板, 从 CDN 中加载所需文件.
    
    {% block scripts %}
    {{ super() }}
    {{ pagedown.include_pagedown() }}
    {% endblock %}

# 五. 在服务器上处理富文本

出于安全考虑, 表单在提交后, POST 请求只会发送纯 Markdown 文本给服务端, 页面中显示的 HTML 预览会被丢掉. 被提交的 POST 数据, 在服务端使用 Markdown 将其转换为 HTML, 得到HTML 之后, 在使用 Bleach 进行清理, 确保其中只包含几个允许使用的 HTML 标签.

转换步骤 : 
1. markdown() 函数将 Markdown 文本转换成 HTML;
2. clean() 函数将 HTML 与允许使用的 HTML 标签列表对比, 清除所有不在白名单中的标签.
3. linkify() , 由 Bleach 提供, 把纯文本的 URL 转换成适当的 <a> 链接. 因为 Markdown 规范没有为自动生成 链接 提供官方支持, PageDown 以扩展的方式实现了该功能.

示例代码 : 
    
    from markdown import markdown
    import bleach

    class Post(db.Model):
        # ...
        body = db.Colume(db.Text)
        body_html = db.Column(db.Text)
        # ...

        @staticmethod
        def on_changed_method(target, value, oldvalue, initiator):
            allowed_tags = ["a", "abbr", "acronym", "b", "blockquote", "code", "em",
                            "i", "li", "ol", "pre", "strong", "ul", "h1", "h2","h3","h4","p"]
            target.body_html = bleach.linkify(bleach.clean(markdown(value, output_format="html"), tags=allowed_tags, strip=True))

    db.event.listen(Post.body, "set", Post.on_changeed_body) 
    # on_changed_body 函数注册在 body 字段上, 是 SQLIAlchemy "set" 事件的监听程序, 这意味着只要这个类实例的 body 字段设了新值, 函数就会自动被调用. on_changed_body 函数把 body 字段中的文本渲染成 HTML 格式, 结果保存在 body_html 中, 自动高效的完成 Markdown 文本到 HTML 的转换.