---
title: PyStdLib--optparse
date: 2018-03-15 15:28:55
categories:
- Python
tags:
- python 标准库
---
使用 optparse 解析命令行参数.
<!-- more -->

代码示例: 
    
    import optparse
    
    p = optparse.OptionParser()
    
    p.add_option("-t", action="store_true", dest="tracing")
    
    p.add_option("-o", "--outfile", action="store", type="string", dest="outfile")
    
    p.add_option("-d", "--debuglevel", action="store", type="int", dest="debug")
    
    p.add_option("--speed", action="store", type="choice", dest="speed", choices=["slow", "fast", "ludicrous"])
    
    p.add_option("--coord", action="store", type="int", dest="coord", nargs=2)
    
    p.add_option("--novice", action="store_const", const="novice", dest="mode")
    
    p.add_option("--guru", action="store_const", const="guru", dest="mode")
    
    p.set_defaults(tracing=False,
                   debug=0,
                   speed="fast",
                   coord=(0, 0),
                   mode="novice")
    
    opt, args = p.parse_args()
    
    print "tracing: ", opt.tracing
    print "outfile: ", opt.outfile
    print "debug  : ", opt.debug
    print "speed  : ", opt.speed
    print "coord  : ", opt.coord
    print "mode   : ", opt.mode
    
    print "args   : ", args