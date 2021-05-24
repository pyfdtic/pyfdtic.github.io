编译过程:
- 词法分析
- 语法分析
    astexpolorer.net
- 语义分析
- ssa 中间代码生成
    golang.design/gossa
- 机器码生成
    godbolt.org

链接过程:
- aaa

```
go tool compile -S ./hello.go

go tool objdump // 寻找 make 的实现.
```

golang.org/ref/spec 官方推荐使用方式.


make:
- slice
    runtime.makeslice
- map
    runtime.makemap
- channel
    runtime.makechannel


9: runtime 堆
0-8: local 队列

time.Sleep : 内部创建 goroutine
    1.13: 会启动 goroute
    1.14: 不会启动 goroute

编译原理图书推荐: 不推荐龙书.


b
c
si
dissa: 反汇编
x: 检查一段连续内存里面的值.


活文档: 注解

sql 审计:
- vitess
- pingCAP

elasticsql















