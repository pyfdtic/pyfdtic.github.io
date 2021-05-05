---
title: Flask 扩展之--flask-moment
date: 2018-03-19 18:49:26
categories:
- Python
tags:
- Flask
- Flask 扩展
---
## 一. 安装

    $ pip install flask-moment

## 二. 初始化 
    
    from flask_moment import Moment

    moment = Moment(app)

## 三. 解决依赖

### moment.js
示例代码 : 在基模板的 scripts 块中引入该库.

    {% block scripts %}
    {{ super() }}
    {{ moment.include_moment() }}
    {% endblock %}


### jquery.js
Flask-Moment依赖于 jquery.js, 需在文档中导入这个 js 库.

## 四. 在模板中使用 Flask-Moment

示例代码 : 
    
    # 从视图函数中, 向模板传入时间变量.

    from datetime import datetime

    @app.route('/')
    def index():
        return render_template("index.html", current_time=datetime.utctime())

    # 在模板中渲染

        <p>The local date and time is {{ moment(current_time).format('LLL') }}.</p> 
        <p>That was {{ moment(current_time).from Now(refresh=True) }}</p>

## 五. 其他方法 :
[文档: http://momentjs.com/docs/#/displaying ](http://momentjs.com/docs/#/displaying)
### format()
根据客户端电脑中的时区和区域设置渲染日期和时间。参数决定了渲染的方式，'L' 到 'LLLL' 分别对应不同的复杂度。format() 函数还可接受自定义的格式说明符。

### formNow()
渲染相对时间戳.

### calendar()
### valueOf()
### unix()