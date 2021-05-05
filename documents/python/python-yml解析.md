---
title: python yaml 解析
date: 2018-03-16 16:30:48
categories:
- Python
tags:
- yaml
- PyPi
---
0. 依赖

        $ pip install pyyaml

        示例文件 :
        
        $ cat test.yaml

        host:
            ip00:
                192.168.1.1
            ip01:
                one: 192.168.1.2
                two: 192.168.1.254
        soft:
            apache: 2.2
            mysql: 5.2
            php:   5.3    

1. 解析

        > import yaml
        > s = yaml.load(file("test.yaml"))
        > print s   # s 为字典
            {'host': {'ip00': '192.168.1.1',
              'ip01': {'one': '192.168.1.2', 'two': '192.168.1.254'}},
             'soft': {'apache': 2.2, 'mysql': 5.2, 'php': 5.3}}    

2. 写入

        > file='kkk.yaml'
        > data={'host': {'ip01': {'two': '192.168.1.254', 'one': '192.168.1.2'}, 'ip00': '192.168.1.1'}, 'soft': {'apache': 2.2, 'php': 5.3, 'mysql': 5.2}}

        > f=open(file,'w')
        > yaml.dump(data,f)
        > f.close()    


## yaml 语法
### 1) 基本规则
① 基本语法规则
    - 大小写敏感,
    - 使用缩进表示层级关系
    - 缩进时, 不允许用 Tab 键, 只允许使用空格.
    - 缩进的空格数目不重要, 只要相同层级的元素左侧对齐即可.

② 支持的数据结构
    - 对象 : 键值对的集合, 又称为字典/映射/哈希
    - 数组 : 一组按次序排序的值, 又称为序列/列表
    - 纯量 : 单个的, 不可再分的值.

③ 注释 : `#`

### 2) 对象 : 一组键值对, 使用冒号结构表示

    animal: pets

    hash: {name: Steve, foo: bar}   # 将所有键值对写成一个行内对象.

### 3) 数组 : 一组横线开头的行, 

    - cat
    - dog
    - goldfish

数据结构的子成员是一个数组, 则可以在该项下面缩进一个空格.

    - 
     - cat
     - dog
     - goldfish

数组使用行内表示法 :

    animal: [cat, dog]

### 4) 复合结构 : 对象 + 数组

    languages: 
        - ruby
        - perl
        - python
    websites: 
        YAML: yaml.org
        Ruby: ruby-lang.org
        Python: python.org
        Perl: use.perl.org


### 5) 纯量 : 最基本的, 不可再分的值.
字符串 : 

① 默认不使用引号表示

② 字符串中包含空格,或者特殊字符, 需要放在引号之中.

    str: '内容： 字符串'

③ 单引号和双引号都可以使用, 双引号不会对特殊字符串转义.

    s1: '内容\n字符串'
    s2: "内容\n字符串"

④ 单引号之中如果还有单引号, 必须连续使用两个单引号转义.

    str: 'labor''s day' 

⑤ 多行字符串, 从第二行开始, 必须有一个单空格缩进, 换行符会被转换为空格.

    | : 保留换行符
    > : 折叠换行
    + : 保留文字块默认的换行,
    - : 删除字符串末尾的换行.

    this: |
      Foo
      Bar
    that: >
      Foo
      Bar  

    转换后 : { this: 'Foo\nBar\n', that: 'Foo Bar\n' }

    s1: |
      Foo

    s2: |+
      Foo


    s3: |-
      Foo

    转换后 : { s1: 'Foo\n', s2: 'Foo\n\n\n', s3: 'Foo' }

⑥ 字符串中插入 HTML 标记.

    message: |

      <p style="color: red">
        段落
      </p>
          
布尔值 : `true, false`

    isBoy: true

整数 : 以 **字面量** 形式表示 

    number: 12

浮点数 : 以 **字面量** 形式表示
    number: 12.345

Null : `~`

    parent: ~

时间 : ISO8601 格式

    iso8601: 2001-12-14t21:59:43.10-05:00 

日期 : 复合 iso8601 格式的年、月、日表示。

    date: 1976-07-31

强制类型转换 : !!TYPE VAR, 使用两个感叹号，强制转换数据类型。

    e: !!str 123
    f: !!str true


### 7) 引用 : 
`&`  : 锚点, 用来建立锚点,
`*`  : 别名, 用来引用锚点
`<<` : 合并到当前数据

示例 :

    defaults: &defaults
      adapter:  postgres
      host:     localhost

    development:
      database: myapp_development
      <<: *defaults

    test:
      database: myapp_test
      <<: *defaults

等同于如下代码 : 

    defaults:
      adapter:  postgres
      host:     localhost

    development:
      database: myapp_development
      adapter:  postgres
      host:     localhost

    test:
      database: myapp_test
      adapter:  postgres
      host:     localhost  

示例 : 

    - &showell Steve 
    - Clark 
    - Brian 
    - Oren 
    - *showell 

转换后为 :

    [ 'Steve', 'Clark', 'Brian', 'Oren', 'Steve' ]