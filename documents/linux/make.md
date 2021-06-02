# Makefile

`make` 是一个根据指定的 Shell 命令进行构建的工具。它的规则很简单，只需规定要构建哪个文件、依赖哪些源文件，当那些文件有变动时，如何重新构建。

## 配置文件
- 默认配置文件为 `Makefile` 或 `makefile`
- 指定其他配置文件: 
    
    ```bash
    $ make -f rules.txt
    $ make --file-rules=rules.txt
    ```

## 配置规则

每条规则就明确两件事:
1. 构建目标的前置条件是什么.
2. 如何构建.

```txt
<target> : <prerequisites> 
[tab]  <commands>
```

### 1. Target: 必选
一个目标（target）就构成一条规则.

Target 通常为:
- 文件名, 指明所要构建的对象. 可以为一个文件名, 也可以是多个文件名, 中间用**空格**分割.
- 操作名, 即 伪目标 (phony target). 如果当前目录中已经存在一个名为 *操作名* 的文件, 则操作不会执行, 因为文件已存在, 无需重新构建.

    ```text
    clean:
        rm *.txt
    ```
    如上配置中, 如果目录中已存在名为 `clean` 的文件, 则操作不会执行, 因为 make 会吧 `clean` 文件当做构建结构, 不再重新构建.

    为了避免以上情况出现, 可以明确声明其为 phony target, 之后, make 就不再检查 `clean` 文件是否存在. 写法如下:

    ```txt
    .PHONY: clean
    clean:
        rm *.txt
    ```

**如果没有指明 `target` 执行 `make` 命令, 则默认执行 Makefile 的第一个目标**

### 2. Prerequisites: 可选

通常为一组使用空格分割的**文件名**, 指定了 `Target` 是否重新构建的判断标准: 只要一个文件不存在 或者有过更新(通过 Prerequisites last-modification 时间戳比 Target 文件新), `Target` 就需要重新构建.

生成多个文件:
```
# source 是一个 phony target.
source: file1 file2 file3
```

### 3. Command: 可选

Command 表示如何更新 Target 文件, 由一行或者多行的 shell 命令组成, 是构建 `Target` 的具体指令, 它的运行结果通常就是生成目标文件.

- 每行命令之前必须有一个 `tab` 键. 如果想使用其他格式, 可以使用内置变量 `.RECIPEPREFIX` 声明.
    ```txt
    # 指定使用大括号(>)替代 tab 键
    .RECIPEPREFIX = >
    all:
    > echo "Hello World!"
    ```

- 每行命令在一个单独的 `shell` 进程中执行, 这些 shell 之间没有继承关系. 解决的办法是将两行命令写在一行里, 中间用*分号(;)* 分割; 或者 在换行符前加*反斜杠(\)* 转义 或者 使用 `.ONESHELL:` 指令.
    ```
    var-lost:
        export foo=bar
        echo "foo=[[$foo]]"     # error

    var-lost-v2:
        export foo=bar; echo "foo=[[$foo]]"     # 将多行写在一行
    
    var-lost-v3:
        export foo=bar; \       # 反斜杠转义
        echo "foo=[[$foo]]"
    
    .ONESHELL:                  # 使用指令
    var-lost-v4:
        export foo=bar;
        echo "foo=[[$foo]]"
    ```

## Makefile 文件语法

- `#` 注释

    ```
    # 这是注释
    result.txt: source.txt
        # 这是注释
        cp source.txt result.txt    # 这是注释
    ```

- 回声(echoing): 通常 make 会打印每条命令, 然后再执行.

    ```
    test:
        # this is a test line
    ```

    输出:
    ```
    $ make test
    # this is a test line
    ```

    关闭回声: 由于在构建过程中, 需要了解当前在执行那条命令, 所以通常只在注释和纯显示的 `echo` 命令前添加 `@`.
    ```txt
    test:
        @#this is a test line
        @ echo "this is a test line"
    ```

- 通配符: 用来执行一组符合条件的文件名. Makefile 的通配符和 Bash 一致.

    通配符主要有:
    - `*` : 
    - `?` : 
    - `...` : 

    示例:
    ```
    clean:
        rm -f *.txt
    ```

- 模式匹配: Make 命令允许对文件名, 进行类似正则运算的匹配, 主要匹配符号为 `%`.

    使用匹配符 `%`, 可以将大量同类型的文件, 只用一条规则就能完成构建.

    ```
    # 假定当前目录下有 f1.c f2.c 两个源文件.
    %.o: %.c

    等同于:
    f1.o: f1.c
    f2.o: f2.c
    ```

- 变量 和 赋值符

    - Makefile 允许使用等号(`=`)自定义变量, 调用时, 变量需要在 `$()` 中.

        ```txt
        txt = Hello World
        test:
            @echo $(txt) > new.txt
        ```

    - 变量的值可能指向另一个变量:
        ```
        v1 = $(v2)
        ```

    - 调用 Shell 变量, 需要在美元符号(`$`)之前, 再加一个美元符号`$`, 例如 `$$HOME`, 因为 Make 命令会对 美元符号(`$`) 转义.

        ```txt
        test:
            @echo $$HOME
        ```

