---
title: PyStdLib--logging
date: 2018-03-19 18:35:18
categories:
- Python
tags:
- python 标准库
---
线程安全的日志记录模块.

## 一. 使用示例

    import logging

    logging.basicConfig(filename="app.log",
                        format="%(asctime)s - %(name)s - %(levelname)s -%(module)s:  %(message)s",
                        datefmt="%Y-%m-%d %H:%M:%S %p",
                        level=10)   # level=ERROR, INFO, WARN

    # 记录日志 : 只有【当前写等级】大于【日志等级】时，日志文件才被记录。

    logging.debug("debug")
    logging.info("info")
    logging.warning("warning")
    logging.error("error")
    logging.critical("critical")

    logging.log(LEVEL, msg)
        logging.log(10, 'info')

## 二. 日志等级

    CRITICAL = 50
    FATAL = CRITICAL
    ERROR = 40
    WARNING = 30
    WARN = WARNING
    INFO = 20
    DEBUG = 10
    NOTSET = 0

## 三. 日志格式变量
![日志格式变量](/imgs/python/%E6%97%A5%E5%BF%97%E6%A0%BC%E5%BC%8F%E5%8F%98%E9%87%8F.png)