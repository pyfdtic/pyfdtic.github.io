
---
title: 自动化测试 Splinter
date: 2018-03-15 15:39:53
categories:
- Python
tags:
- 自动化测试
- Splinter
- PyPi
---
使用 Splinter 做自动化测试.
<!-- more -->
[Splinter Doc](http://splinter.readthedocs.io/en/latest/#get-in-touch-and-contribute)

Splinter是一个使用Python开发的开源Web应用测试工具，它可以帮你实现自动浏览站点和与其进行交互。

Splinter 是一个基于 Selenium, PhantomJS, zope.testbrowser 等已存在浏览器的抽象层度较高的自动化测试工具.

## 1. 特点
1. API 简单
2. 多浏览器支持, 支持的 浏览器列表如下:

    chrome webdriver, 
    firefox webdriver, 
    phantomjs webdriver, 
    zopetestbrowser, 
    remote webdriver

3. 支持 CSS 选择器和 Xpath 选择器
4. 支持 iframe 和 alert
5. 支持执行 JavaScript
6. 支持 ajax 调用和 async JavaScript

## 2. 入门
### 2.1 安装
1. 安装 python

    支持 Python 2.7+ 版本

2. 安装 splinter
    ```
        $ pip install splinter
    ```
3. 安装浏览器驱动:
    
    以 chrome 为例:
    ```
        https://chromedriver.storage.googleapis.com/index.html?path=2.35/
    ```

### 2.2 示例:
```
    from splinter import Browser

    # 初始化 browser
    browser = Browser()

    # 打开首页
    browser.visit('http://google.com')

    browser.fill('q', 'splinter - python acceptance testing for web applications')
    browser.find_by_name('btnG').click()

    if browser.is_text_present('splinter.readthedocs.io'):
        print "Yes, the official website was found!"
    else:
        print "No, it wasn't found... We need to improve our SEO techniques"

    browser.quit()
```
Browser 对象支持 上下文管理:
```    
    with Browser() as browser:
        # code here
```
## 3. 基础浏览器行为和交互

### 3.1 网页对象
1. Browser 对象初始化
    ```
        browser = Browser('chrome')
        browser = Browser('firefox')
        browser = Browser('zope.testbrowser')

        browser = Browser(driver_name="chrome", 
                executable_path="/path/to/chrome", 
                user_agent="Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)", 
                incognito=True)
    ```
2. 浏览网页

    ```
        browser.visit('http://cobrateam.info')
        browser.visit('http://username:password@cobrateam.info/protected')    # basic HTTP 认证
    ```
3. 重载网页

    ```    
        browser.reload()
    ```
4. You can back and forward on your browsing history using `back` and `forward` methods:

    ```
        browser.visit('http://cobrateam.info')
        browser.visit('https://splinter.readthedocs.io')
        browser.back()
        browser.forward()
    ```
5. 获取当前网页的相关内容

    ```    
        browser.title   # 网页标题
        browser.html    # 网页的 html 代码
        browser.url     # 网页的 url
    ```
6. 管理多个窗口, 使用 `windows` 对象, 例如弹出窗口.
    ```
        browser.windows              # all open windows
        browser.windows[0]           # the first window
        browser.windows[window_name] # the window_name window
        browser.windows.current      # the current window
        browser.windows.current = browser.windows[3]  # set current window to window 3

        window = browser.windows[0]
        window.is_current            # boolean - whether window is current active window
        window.is_current = True     # set this window to be current window
        window.next                  # the next window
        window.prev                  # the previous window
        window.close()               # close this window
        window.close_others()        # close all windows except this one
    ```
### 3.2 查找网页元素

1. 网页元素获取
    
    splinter 支持 6 种元素查找方式, 每种方式均返回列表作为查找结果.

    支持 `first`, `last` 快捷方式, 查找第一个和最后一个元素.

    因为每个页面中, id 的值一般是不重复的, 因此 `find_by_id` 总是返回**只有一个元素的列表**.
    ```
        browser.find_by_css('h1')
        browser.find_by_xpath('//h1')
        browser.find_by_tag('h1')
        browser.find_by_name('name')
        browser.find_by_text('Hello World!')
        browser.find_by_id('firstheader')
        browser.find_by_value('query')

        browser.find_by_xpath('//h1').first
        browser.find_by_name('name').last
        browser.find_by_tag('h1')[1]
    ```
    获取元素的值
    ```
        browser.find_by_css('h1').first.value
    ```

2. 查找 URL 
    
    返回**列表**作为结果.
    ```
        links_found = browser.find_link_by_text('Link for Example.com')
        links_found = browser.find_link_by_partial_text('for Example')
        links_found = browser.find_link_by_href('http://example.com')
        links_found = browser.find_link_by_partial_href('example')
    ```
    Clicking links : These methods return the first element always.
    ```
        # 绝对 url
        browser.click_link_by_href('http://www.the_site.com/my_link')

        # 相对 url
        browser.click_link_by_partial_href('my_link')

        browser.click_link_by_text('my link')
        browser.click_link_by_partial_text('part of link text')

        browser.click_link_by_id('link_id')
    ```
3. 链式查找
    
    Finding method are chainable, so you can find the descendants of a previously found element.
    ```
        divs = browser.find_by_tag("div")
        within_elements = divs.first.find_by_name("name")
    ```
4. `ElementDoesNotExist` 异常
    
    If an element is not found, the `find_*` methods return an empty list. 

    But if you try to access an element in this list, the method will raise the `splinter.exceptions.ElementDoesNotExist` exception.


5. Clicking buttons
    
    You can click in buttons. Splinter follows any redirects, and submits forms associated with buttons.
    ```
        browser.find_by_name('send').first.click()

        browser.find_link_by_text('my link').first.click()
    ```
6. 表单
    
    ``` 
        browser.fill('query', 'my name')
        browser.attach_file('file', '/path/to/file/somefile.jpg')
        browser.choose('some-radio', 'radio-value')
        browser.check('some-check')
        browser.uncheck('some-check')
        browser.select('uf', 'rj')
    ```
    To trigger JavaScript events, like KeyDown or KeyUp, you can use the `type` method.
    ```
        browser.type("type", "typing text")
    ```
    If you pass the argument `slowly=True` to the `type` method you can interact with the page on every key pressed. Useful for test field's autocompletion (The browser will wait until next iteration to type the subsequent key).
    ```
        for key in browser.type("type", "typing slowly", slowly=True):
            pass
    ```
    You can also use `type` and `fill` methods in an element.
    ```
        browser.find_by_name("name").type("Steve Jobs", slowly=True)
        browser.find_by_css(".city").fill("San Francisco")
    ```
7. 判断元素是否可见.
   
    ```    
        # 返回布尔值
        browser.find_by_css('h1').first.visible
    ```
8. 判断元素是否有 `className`
    
    ```    
        # 返回布尔值
        browser.find_by_css('.content').first.has_class('content')
    ```
9. Interacting with elements through a ElementList object
    
    You can invoke any `Element` method on `ElementList` and it will be proxied to the **first** element of the list. So the two lines below are quivalent.
    ```
        assert browser.find_by_css('a.banner').first.visible
        assert browser.find_by_css('a.banner').visible
    ```
### 3.3 鼠标
**大多数鼠标事件目前只支持 Chrome 和 Firefox 27.0.1**

支持 mouse_over, mouse_out,单击, 双击, 右击鼠标.

1. `mouse_over` : puts the mouse above the element.
    
    ```
        browser.find_by_tag('h1').mouse_over()
    ```
2. `mouns_out` : puts the mouse out of the element.
    
    ```    
        browser.find_by_tag('h1').mouse_out()
    ```
3. `click` : 单击
    
    ```    
        browser.find_by_tag('h1').click()
    ```
4. `double_click` : 双击
    
    ```    
        browser.find_by_tag('h1').double_click()
    ```
5. `right_click` : 右击
    
    ```
        browser.find_by_tag('h1').right_click()
    ```
6. `drag_and_drop` : You can drag an element and drop it to another element.
    
    The example below drags the `<h1> ... </h1>` element and drop it to a container element (identified by a CSS class).
    
    ```
        draggable = browser.find_by_tag('h1')
        target = browser.find_by_css('.container')
        draggable.drag_and_drop(target)
    ```
### 3.4 Ajax & Async JavaScript

When working with Ajax and Asynchronous JavaScript, it's common to have elements which are not present in the HTML code(they are created with JavaScript, dynamically). In this case, you can use the methods `is_element_present` and `is_text_present` to check the existence of an element or text -- Splinter will load the HTML and JavaScript in the browser and the check will be performed *before* processing JavaScript.

There is also the optional argument `wait_time` (given in seconds), it's a timeout: if the verification method gets `True` it will return the result (even if the `wait_time` is not over); if it doesn't get `True`, the method will wait until the `wait_time` is over (sp it'll return the result).
```    
    # 检查文本是否 存在
    browser = Browser()
    browser.visit('https://splinter.readthedocs.io/')
    browser.is_text_present('splinter') # True
    browser.is_text_present('splinter', wait_time=10) # True, using wait_time
    browser.is_text_present('text not present') # False

    # 检查文本是否 不存在
    browser.is_text_not_present('text not present') # True
    browser.is_text_not_present('text not present', wait_time=10) # True, using wait_time
    browser.is_text_not_present('splinter') # False
```
**元素(element)存在性检查**, 返回*布尔值*.
```    
    # 检查元素是否 存在
    browser.is_element_present_by_css('h1')
    browser.is_element_present_by_xpath('//h1')
    browser.is_element_present_by_tag('h1')
    browser.is_element_present_by_name('name')
    browser.is_element_present_by_text('Hello World!')
    browser.is_element_present_by_id('firstheader')
    browser.is_element_present_by_value('query')
    browser.is_element_present_by_value('query', wait_time=10) # using wait_time

    # 检查元素是否 不存在
    browser.is_element_not_present_by_css('h6')
    browser.is_element_not_present_by_xpath('//h6')
    browser.is_element_not_present_by_tag('h6')
    browser.is_element_not_present_by_name('unexisting-name')
    browser.is_element_not_present_by_text('Not here :(')
    browser.is_element_not_present_by_id('unexisting-header')
    browser.is_element_not_present_by_id('unexisting-header', wait_time=10) # using wait_time
```
### 3.5 cookie 管理
It is possible to manipulate cookies using the `cookies` attribute from a `Browser` instance. The `cookies` attribute is a instance of a `CookieManager` class that manipulates cookies, like adding and deleting them.

1. 添加 cookies
    
    ```
        browser.cookies.add({"key": "value"})
    ```
2. 检索 cookies
    
    ```
        browser.cookies.all()
    ```   
3. 删除 cookies
    
    删除 **单个 cookies**
    ```
        browser.cookies.delete("key1")      # 删除 单个 cookies
        browser.cookies.delete("key1", "key2")  # 删除 两个 cookies
    ```
    删除 **所有 cookies**
    ```
        browser.cookies.delete()
    ```
## 4. JavaScript 支持

You can easily execute JavaScript in drivers which support it.
```
    browser.execute_script("$('body').empty()")
```
You can return the result of the script.
``` 
    browser.evaluate_script("4+4") == 8
```
## 5. 其他
### 5.1 HTTP 响应码处理及异常处理

**`status_code` and this HTTP exception handling is available only for selenium webdriver**
```
    browser.visit("http://www.baidu.com")
    browser.status_code.is_success()    # True
    browser.status_code == 200      # True
    browser.status_code.code        # 200
```

当网页返回失败时, 触发 `HttpResponseError` 错误.
```
    try:
        browser.visit('http://cobrateam.info/i-want-cookies')
    except HttpResponseError, e:
        print "Oops, I failed with the status code %s and reason %s" % (e.status_code, e.reason)
```
### 5.2 iframers

You can use the `get_iframe` method and the `with` statement to interact with iframe.
    
You can pass the iframe's name, id, or index to `get_iframe`.
```
    with browser.get_iframe('iframemodal') as iframe:
        iframe.do_stuff()
```
### 5.3 alert and prompts
**Only webdrivers (Firefox and Chrome) has support for alerts and prompts**

You can deal with alerts and prompts using the `get_alert` method.
```  
    alert = browser.get_alert()
    alert.text
    alert.accept()
    alert.dismiss()
```
In case of prompts, you can answer it using the `fill_with` method.
```
    prompts = browser.get_alert()
    prompts.text
    prompts.fill_with("text")
    prompts.accept()
    prompts.dismiss()
```
You can use the `with` statement to interacte with both alerts and prompts too.
```
    with browser.get_alert() as alert:
        alert.do_stuff()
```

**IMPORTANT** : if there's not any prompt or alert, `get_alert` will return `None`. Remember to always use at least one of the alert/prompt ending methods(accept/dismiss). Otherwise your browser instance will be frozen until you accept or dismiss the alert/prompt correctly.

## 6. Drivers
### 6.1 Chrome
1. 安装
    ```
        # 依赖 Selenium 
        $ pip install selenium

        # 需要安装 chrome 浏览器
    ```
2. 使用
    
    - headless option for Chrome
        
        ```
            browser = Browser("chrome", headless=True)
        ```
    - incognito option: 隐身模式
        
        ```
            browser = Browser("chrome", incognito=True)            
        ```
    - emulation option: 仿真模式
        
        ```
            from selenium import webdriver
            from splinter import Browser

            mobile_enulation = {"driverName": "Google Nexus 5"}
            chrome_options = webdriver.ChromeOptions()
            chrome_options.add_experimental_option("mobileEmulation", mobile_enulation)
            browser = Browser("chrome", options=chrome_options)
        ```
    - screenshot:

        Take a screenshot of the current page and saves it locally.
        ```
            screenshot(name=None, suffix='.png')
        ```