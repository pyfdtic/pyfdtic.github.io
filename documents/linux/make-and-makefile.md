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

        四个赋值运算符:
        - `VARIABLE = value` : 在**执行**时扩展, 允许递归扩展.
        - `VARIABLE := value` : 在**定义**时扩展.
        - `VARIABLE ?= value` : 只有在该变量**为空**时才设置值.
        - `VARIABLE += value` : 将值**追加**到变量的尾端.

- 内置变量(Implicit Variables)

    Make 提供一系列内置变量, 参考 [官方手册 Variables Used By Implicit Rules](https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html)

    ```txt
    output:
        $(CC) -o output input.c
    ```

    内置变量清单: 
    - `$(CC)` 指向当前使用的编译器
    - `$(MAKE)` 指向当前使用的 Make 工具
    - `AR` : Archive-maintaining program; default ‘ar’.
    - `AS` : Program for compiling assembly files; default ‘as’.
    - `CXX` : Program for compiling C++ programs; default ‘g++’.
    - `CPP` : Program for running the C preprocessor, with results to standard output; default ‘$(CC) -E’.
    - `FC` : Program for compiling or preprocessing Fortran and Ratfor programs; default ‘f77’.
    - `M2C` : Program to use to compile Modula-2 source code; default ‘m2c’.
    - `PC` : Program for compiling Pascal programs; default ‘pc’.
    - `CO` : Program for extracting a file from RCS; default ‘co’.
    - `GET` : Program for extracting a file from SCCS; default ‘get’.
    - `LEX` : Program to use to turn Lex grammars into source code; default ‘lex’.
    - `YACC` : Program to use to turn Yacc grammars into source code; default ‘yacc’.
    - `LINT` : Program to use to run lint on source code; default ‘lint’.
    - `MAKEINFO` : Program to convert a Texinfo source file into an Info file; default ‘makeinfo’.
    - `TEX` : Program to make TeX DVI files from TeX source; default ‘tex’.
    - `TEXI2DVI` : Program to make TeX DVI files from Texinfo source; default ‘texi2dvi’.
    - `WEAVE` : Program to translate Web into TeX; default ‘weave’.
    - `CWEAVE` : Program to translate C Web into TeX; default ‘cweave’.
    - `TANGLE` : Program to translate Web into Pascal; default ‘tangle’.
    - `CTANGLE` : Program to translate C Web into C; default ‘ctangle’.
    - `RM` : Command to remove a file; default ‘rm -f’.

    Here is a table of variables whose values are additional arguments for the programs above. The default values for all of these is the empty string, unless otherwise noted.

    - `ARFLAGS`: Flags to give the archive-maintaining program; default ‘rv’.
    - `ASFLAGS`: Extra flags to give to the assembler (when explicitly invoked on a ‘.s’ or ‘.S’ file).
    - `CFLAGS`: Extra flags to give to the C compiler.
    - `CXXFLAGS`: Extra flags to give to the C++ compiler.
    - `COFLAGS`: Extra flags to give to the RCS co program.
    - `CPPFLAGS`: Extra flags to give to the C preprocessor and programs that use it (the C and Fortran compilers).
    - `FFLAGS`: Extra flags to give to the Fortran compiler.
    - `GFLAGS`: Extra flags to give to the SCCS get program.
    - `LDFLAGS`: Extra flags to give to compilers when they are supposed to invoke the linker, ‘ld’, such as -L. Libraries (-lfoo) should be added to the LDLIBS variable instead.
    - `LDLIBS` : Library flags or names given to compilers when they are supposed to invoke the linker, ‘ld’. LOADLIBES is a deprecated (but still supported) alternative to LDLIBS. Non-library linker flags, such as -L, should go in the LDFLAGS variable.
    - `LFLAGS`: Extra flags to give to Lex.
    - `YFLAGS`: Extra flags to give to Yacc.
    - `PFLAGS`: Extra flags to give to the Pascal compiler.
    - `RFLAGS`: Extra flags to give to the Fortran compiler for Ratfor programs.
    - `LINTFLAGS`: Extra flags to give to lint.


- 自动变量(Automatic Variables)

    自动变量示例:
    ```txt
    # 上面代码将 src 目录下的 txt 文件，拷贝到 `dest` 目录下。首先判断 `dest` 目录是否存在，如果不存在就新建，然后，`$<` 指代前置文件(`src/%.txt`), `$@` 指代目标文件(`dest/%.txt`) .

    dest/%.txt: src/%.txt
        @[ -d dest ] || mkdir dest
        cp $< $@
    ```

    Make 命令还提供一些自动变量, 他们的值与当前规则有关. 参考: [自动变量手册 Automatic Variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)

    - `$@`: 指代当前目标，就是 Make 命令当前构建的那个**目标**。
        
        比如，`make foo`的 `$@` 就指代`foo`。

        ```txt
        a.txt b.txt: 
            touch $@
        ```
        等同于下面的写法。

        ```txt
        a.txt:
            touch a.txt
        b.txt:
            touch b.txt
        ```

    - `$(@D)` 和 `$(@F)`: `$(@D)` 和 `$(@F)` 分别指向 `$@` 的*目录名*和*文件名*。
        
        比如，`$@`是 `src/input.c`，那么`$(@D)` 的值为 `src` ，`$(@F)` 的值为 `input.c`。

    - `$<`: 指代*第一个前置条件*。
        
        比如，规则为 `t: p1 p2`，那么`$<` 就指代`p1`。
        ```txt
        a.txt: b.txt c.txt
            cp $< $@ 
        ```
        等同于下面的写法。
        ```txt
        a.txt: b.txt c.txt
            cp b.txt a.txt 
        ```

    - `$(<D)` 和 `$(<F)`: `$(<D)` 和 `$(<F)` 分别指向 `$<` 的*目录名*和*文件名*。
    - `$?`: 指代比*目标更新*的**所有前置条件**，之间以空格分隔。
        
        比如，规则为 `t: p1 p2`，其中 `p2` 的时间戳比 `t` 新，`$?`就指代`p2`。

    - `$^`: 指代**所有前置条件**，之间以空格分隔。
        
        比如，规则为 `t: p1 p2`，那么 `$^` 就指代 `p1 p2` 。

    - `$*`: 指代匹配符 `%` 匹配的部分.
        
        比如`%` 匹配 `f1.txt` 中的`f1` ，`$*` 就表示 `f1`。

- 判断和循环: Makefile 使用 **Bash 语法**完成判断和循环.

    ```txt
    # 判断当前编译器是否是 gcc, 然后指定不同的库文件.
    ifeq ($(CC),gcc)
    libs=$(libs_for_gcc)
    else
    libs=$(normal_libs)
    endif
    ```
    示例:
    ```txt
    LIST = one two three
    all:
        for i in $(LIST); do \
            echo $$i; \
        done
    
    # 等同于
    all: 
        for i in one two three; do\
            echo $i; \
        done
    
    # 运行结果:
    #   one
    #   two
    #   three
    ```

- 函数: Makefile 支持使用函数.
    
    Makefile 函数格式如下:
    ```txt
    $(function arguments)
    # 或者
    ${function arguments}
    ```

    Makefile 提供的常用内置函数. 参考: [内置函数手册 Functions for Transforming Text](http://www.gnu.org/software/make/manual/html_node/Functions.html)

    - shell 函数: 执行 shell 命令
    
        ```txt
        srcfiles := $(shell echo src/{00..99}.txt)
        ```

    - wildcard 函数: 用来在 Makefile 中，替换 Bash 的通配符。

        ```txt
        srcfiles := $(wildcard src/*.txt)
        ```

    - subst 函数: 用来文本替换。

        subst 格式如下:
        ```txt
        $(subst from,to,text)
        ```
        
        下面的例子将字符串"feet on the street"替换成"fEEt on the strEEt"。
        ```txt
        $(subst ee,EE,feet on the street)
        ```
        下面是一个稍微复杂的例子。
        ```txt
        comma:= ,
        empty:=
        space:= $(empty) $(empty)   # space变量用两个空变量作为标识符，当中是一个空格
        foo:= a b c
        bar:= $(subst $(space),$(comma),$(foo))
        # bar is now `a,b,c'.
        ```

    - patsubst函数: 用于模式匹配的替换。

        `patsubst` 格式如下
        ```txt
        $(patsubst pattern,replacement,text)
        ```

        下面的例子将文件名`x.c.c bar.c`，替换成`x.c.o bar.o`。
        ```txt
        $(patsubst %.c,%.o,x.c.c bar.c)
        ```
        
    - 替换后缀名

        替换后缀名函数的写法是, 它实际上`patsubst`函数的一种简写形式。
        ```txt
        变量名 + 冒号 + 后缀名替换规则
        ```

        如下代码的意思是，将变量`OUTPUT`中的后缀名 `.js` 全部替换成 `.min.js` 。    
        ```txt
        min: $(OUTPUT:.js=.min.js)
        ```
    

