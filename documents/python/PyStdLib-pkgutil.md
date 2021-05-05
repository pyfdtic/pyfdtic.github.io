---
title: PyStdLib--pkgutil
date: 2018-03-19 18:31:56
categories:
- Python
tags:
- python 标准库
---
## pkgutil
```
# __init__.py 

__path__ = pkgutil.extend_path(__path__, __name__)

for importer, modname, ispkg in pkgutil.walk_packages(path=__path__, prefix=__name__ + '.'):
    __import__(modname)
```
