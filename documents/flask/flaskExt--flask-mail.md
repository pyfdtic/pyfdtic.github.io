---
title: Flask 扩展之--flask-mail
date: 2018-03-19 18:49:26
categories:
- Python
tags:
- Flask
- Flask 扩展
---
Flask-Mail 封装了 python 标准库 smtplib 包, 以便于更好的与 Flask 集成.

## 一. 安装

    $ pip install flask-mail

## 二. 配置 及 初始化

Flask-Mail SMTP 服务器配置列表

| 配置 |     默认值 |    说明 |
| ---  | ----       | ----    |
| MAIL_SERVER | localhost |  电子邮件服务器的主机名或 IP 地址 |
| MAIL_PORT | 25 | 电子邮件服务器的端口 |
| MAIL_USE_TLS | False | 启用传输层安全（Transport Layer Security，TLS）协议 |
| MAIL_USE_SSL | False | 启用安全套接层（Secure Sockets Layer，SSL）协议 |
| MAIL_USERNAME | None | 邮件账户的用户名 |
| MAIL_PASSWORD | None | 邮件账户的密码 |

*配置示例*

    import os
    # ... 
    app.config["MAIL_SERVER"] = 'smtp.googlemail.com'
    app.config["MAIL_PORT"] = 587
    app.config["MAIL_USE_TLS"] = True
    app.config["MAIL_USERNAME"] = os.environ.get("MAIL_USERNAME")
    app.config["MAIL_PASSWORD"] = os.environ.get("MAIL_PASSWORD")

    ------------------------------------------------------------
    定义环境变量 : 
        Linux : 
            $ export MAIL_USERNAME=<MY_USERNAME>
            $ export MAIL_PASSWORD=<MY_PASSWD>

        Windows : 
            $ set MAIL_USERNAME=<MY_USERNAME>
            $ set MAIL_PASSWORD=<MY_PASSWD>

*初始化*

    from flask_mail import Mail
    mail = Mail(app)

## 三. 在程序中集成发送电子邮件功能
*可以使用 jinja2 模板渲染邮件正文*

    from flask_migrate import Migrate, MigrateCommand

    app.config["FLASK_MAIL_SUBJECT_PREFIX"] = '[MyFlask]'   # 邮件中主题前缀.
    app.config["FLASK_MAIL_SENDER"] = 'FLASK Admin <admin@example.com>'  # 发件人地址

    def send_email(to, subject, template, **kwargs):
        """收件人地址, 主题, 邮件末班, 关键字参数列表(模板中定义的模板参数)"""
        msg = Message(app.config["FLASK_MAIL_SUBJECT_PREFIX"] + subject,
                      sender=app.config["FLASK_MAIL_SENDER"],
                      recipients=[to])
        msg.body = render_template(template + '.txt', **kwargs)    # 纯文本正文
        msg.html = render_template(template + '.html', **kwargs)   # 富文本正文
        mail.send(msg)

## 四. 异步发送电子邮件.

    from threading import Thread

    def send_async_email(app, msg):
        with app.app_context():         # 激活程序上下文.
            mail.send(msg)

    def send_email(to, subject, template, **kwargs):
        """收件人地址, 主题, 邮件末班, 关键字参数列表(模板中定义的模板参数)"""
        msg = Message(app.config["FLASK_MAIL_SUBJECT_PREFIX"] + subject,
                      sender=app.config["FLASK_MAIL_SENDER"],
                      recipients=[to])
        msg.body = render_template(template + '.txt', **kwargs)    
        msg.html = render_template(template + '.html', **kwargs)   

        thr = Thread(target=send_async_email, args=[app, msg])
        return thr
    
**当程序要发送大量邮件时, 使用专门发送电子邮件的作业要比给每封邮件都新建一个线程更合适, 如使用 Celery 等任务队列**