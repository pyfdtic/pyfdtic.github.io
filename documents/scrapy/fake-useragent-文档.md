---
title: fake-useragent-文档
date: 2018-03-15 15:38:11
categories:
- Python
tags:
- 爬虫
- UserAgent
- PyPi
---
使用 fake-useragent 为爬虫提供 UserAgent.
<!-- more -->
grabs up to date useragent from [useragentstring.com](http://useragentstring.com)
randomize with real world statistic via w3schools.com
    
    https://fake-useragent.herokuapp.com/browsers/0.1.5

## 1. 安装

    $ pip install fake-useragent

## 2. 使用

    from fake_useragent import UserAgent
    ua = UserAgent()

    ua.random
    # and the best one, random via real world browser usage statistic

    ua.ie
    # Mozilla/5.0 (Windows; U; MSIE 9.0; Windows NT 9.0; en-US);

    ua.msie
    # Mozilla/5.0 (compatible; MSIE 10.0; Macintosh; Intel Mac OS X 10_7_3; Trident/6.0)'
    
    ua['Internet Explorer']
    # Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; GTB7.4; InfoPath.2; SV1; .NET CLR 3.3.69573; WOW64; en-US)
    
    ua.opera
    # Opera/9.80 (X11; Linux i686; U; ru) Presto/2.8.131 Version/11.11
    
    ua.chrome
    # Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.2 (KHTML, like Gecko) Chrome/22.0.1216.0 Safari/537.2'
    
    ua.google
    # Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13
    
    ua['google chrome']
    # Mozilla/5.0 (X11; CrOS i686 2268.111.0) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11
    
    ua.firefox
    # Mozilla/5.0 (Windows NT 6.2; Win64; x64; rv:16.0.1) Gecko/20121011 Firefox/16.0.1
    
    ua.ff
    # Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:15.0) Gecko/20100101 Firefox/15.0.1
    
    ua.safari
    # Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25

    
## 3. update saved database just:

    from fake_useragent import UserAgent
    ua = UserAgent()
    ua.update()

Sometimes, useragentstring.com or w3schools.com changes their html, or down, in such case fake-useragent uses hosted cache server heroku.com fallback . 
If You don't want to use hosted cache server (version 0.1.5 added)

    from fake_useragent import UserAgent
    ua = UserAgent(use_cache_server=False)


## 4. caech Exception
    
    from fake_useragent import FakeUserAgentError

    try:
        ua = UserAgent()
    except FakeUserAgentError:
        pass


## 5. if you use a unknown useragent , it will not raise a error, but return "Your favorite Browser".

    import fake_useragent
    ua = fake_useragent.UserAgent(fallback='Your favorite Browser')
    ua.just_test_agent
    'Your favorite Browser'