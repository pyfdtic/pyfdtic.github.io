---
title: PyStdLib--pickle
date: 2018-03-19 18:28:48
categories:
- Python
tags:
- python 标准库
---
## pickle & cPickle

pickle 和 cPickle 除了导入名称不一样之外, 使用方法, 均一样.
pickle 导入   `import pickle`  
cPickle 导入 `import cPickle as pickle`

**cPickle 比 pickle 快很多**

#### pickle.dumps(OBJ) --> 序列化对象  
    
    import cPickle as pickle
    b = {"name":"tom", "age":12,"job":"dev"}
    s=pickle.dumps(b)
    

#### pickle.dump(OBJ,f) --> 序列化对象, 并存储到文件

    import cPickle as pickle
    b = {"name":"tom", "age":12,"job":"dev"}
    with open("a.pkl", 'f') as f:
        s=pickle.dump(b,f)
    
#### pickle.load(f)  --> 从文件加载被序列化的 对象.

    import cPickle as pickle
    with open("a.pkl",'r') as f:
        b = pickle.load(f)
    type(b)