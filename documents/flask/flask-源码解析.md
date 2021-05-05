---
title: flask 源码学习
date: 2018-05-15 15:38:11
categories:
- Python
tags:
- flask
- 源码
- web
---
/Users/bob/Library/Caches/PyCharm2018.1/python_stubs/960092896/itertools.py
/Users/bob/Documents/virtualEnv/flaskSrcPy3/lib/python3.7/site-packages/werkzeug/debug/__init__.py

/Users/bob/Documents/virtualEnv/flaskSrcPy3/lib/python3.7/site-packages/werkzeug/local.py


```
# app.py
full_dispatch_request --> dispatch_request --> full_dispatch_request --> wsgi_app --> __call__

request --> full_dispatch_request --> dispatch_request --> 


run_wsgi, serving.py:270
handle_one_request, serving.py:328
handle, server.py:426
handle, serving.py:293
__init__, socketserver.py:717
finish_request, socketserver.py:357
process_request_thread, socketserver.py:647
run, threading.py:865
_bootstrap_inner, threading.py:917
_bootstrap, threading.py:885


full_dispatch_request, app.py:1810
wsgi_app, app.py:2289
__call__, app.py:2306
debug_application, __init__.py:288
execute, serving.py:260
run_wsgi, serving.py:270
handle_one_request, serving.py:328
handle, server.py:426
handle, serving.py:293
__init__, socketserver.py:717
finish_request, socketserver.py:357
process_request_thread, socketserver.py:647
run, threading.py:865
_bootstrap_inner, threading.py:917
_bootstrap, threading.py:885

dispatch_request, app.py:1796
full_dispatch_request, app.py:1810
wsgi_app, app.py:2289
__call__, app.py:2306
debug_application, __init__.py:288
execute, serving.py:260
run_wsgi, serving.py:270
handle_one_request, serving.py:328
handle, server.py:426
handle, serving.py:293
__init__, socketserver.py:717
finish_request, socketserver.py:357
process_request_thread, socketserver.py:647
run, threading.py:865
_bootstrap_inner, threading.py:917
_bootstrap, threading.py:885


hello_world, hello.py:5
dispatch_request, app.py:1796
full_dispatch_request, app.py:1810
wsgi_app, app.py:2289
__call__, app.py:2306
debug_application, __init__.py:288
execute, serving.py:260
run_wsgi, serving.py:270
handle_one_request, serving.py:328
handle, server.py:426
handle, serving.py:293
__init__, socketserver.py:717
finish_request, socketserver.py:357
process_request_thread, socketserver.py:647
run, threading.py:865
_bootstrap_inner, threading.py:917
_bootstrap, threading.py:885

full_dispatch_request, app.py:1813
wsgi_app, app.py:2289
__call__, app.py:2306
debug_application, __init__.py:288
execute, serving.py:260
run_wsgi, serving.py:270
handle_one_request, serving.py:328
handle, server.py:426
handle, serving.py:293
__init__, socketserver.py:717
finish_request, socketserver.py:357
process_request_thread, socketserver.py:647
run, threading.py:865
_bootstrap_inner, threading.py:917
_bootstrap, threading.py:885



```