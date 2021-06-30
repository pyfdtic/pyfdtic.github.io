## 系统调用


系统调用是**同步的**.

寄存器, 有名字.

系统调用的调用规约:

浏览内核代码: code.woboq.org

go code --> c code --> kernel

## 常见系统调用


## 观察系统调用

strace --> linux : 依赖 ptrace .
    -f
    -c
dtruss --> mac

## Go 语言中的系统调用

阻塞: sysnb

非阻塞: sys

## 参考
https://shimo.im/docs/T3RgxxJDkcCth99J/