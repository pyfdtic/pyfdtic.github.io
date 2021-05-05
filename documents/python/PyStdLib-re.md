---
title: PyStdLib--re
date: 2018-03-19 18:28:48
categories:
- Python
tags:
- python 标准库
---
## re 正则表达式
#### 语法
    import re
    m = re.search('[0-9]','abc4def67')  # 匹配字符及匹配范围
    print m.group(0)    # 返回匹配结果

#### re.search()
    m = re.search(pattern, string, re.IGNORECASE)  # 搜索整个字符串，直到发现符合的子字符串。不区分大小写.

#### re.match()
    m = re.match(pattern, string)   # 从头开始检查字符串是否符合正则表达式。必须从字符串的第一个字符开始就相符。

    s = re.match("0ab",'0abasdasda')      # 有匹配
    s = re.match("[0-9]ab",'0abasdasda')  # 有匹配
    s = re.match("ab",'0abasdasda')       # 没有匹配
#### re.sub()
    str = re.sub(pattern, replacement, string) # 在string中利用正则变换pattern进行搜索，对于搜索到的字符串，用另一字符串replacement替换。返回替换后的字符串
#### re.findall() 
    re.findall()  # 根据正则表达式搜索字符串，将所有符合的子字符串放在一给表(list)中返回
    
    s = '0a1b2c3d4e5f6'
    l=re.findall('[0-9]',s)
    print l
    

#### re.split()
    re.split()    # 根据正则表达式分割字符串， 将分割后的所有子字符串放在一个表(list)中返回
    
    s = '0a1b2c3d4e5f6'
    l = re.split('[0-9]',s)  # 返回列表,去除数字之后的.
    print l
    
#### re.compile()  编译后的正则, 更快
    import re
    regexes = [re.compile(p, re.IGNORECASE) for p in ["this", "that"]]
    text = 'Does this text match the pattern?'
    for regex in regexes:
        print regex.pattern         # this \n that
        if regex.search(text):
            print "OK"              # OK
            print regex.search(text).group()  # this
        else:
            print "Problem"