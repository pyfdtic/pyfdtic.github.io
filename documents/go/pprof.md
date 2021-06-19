# Go 性能剖析工具 之 PProf

Go语言项目中的性能优化主要有以下几个方面: 
- `CPU profile`: 报告程序的 CPU 使用情况,按照一定频率去采集应用程序在 CPU 和寄存器上面的数据, 可确定应用程序在主动消耗 CPU 周期时花费时间的位置. 
- `Memory Profile(Heap Profile)`: 报告程序的内存使用情况. 在应用程序进行堆分配时记录堆栈跟踪, 用于监视当前和历史内存使用情况, 以及检查内存泄漏. 
- `Block Profiling`: 报告 goroutines 不在运行状态的情况,可以用来分析和查找死锁等性能瓶颈,记录 goroutine 阻塞等待同步(包括定时器通道)的位置. 记录 Goroutine 阻塞等待同步(包括定时器通道)的位置, **默认不开启**, 需要调用 `runtime.SetBlockProfileRate` 进行设置. 
- `Goroutine Profiling`: 报告 goroutines 的使用情况,有哪些 goroutine,它们的调用关系是怎样的. 可以对当前应用程序正在运行的 Goroutine 进行堆栈跟踪和分析. 
- `Mutex Profiling`: 互斥锁分析,报告互斥锁的竞争情况. **默认不开启**, 需要调用 `runtime.SetMutexProfileFraction` 进行设置. 

PProf 是用于可视化和分析性能分析数据的工具,PProf 以 `profile.proto`读取分析样本的集合,并生成报告以可视化并帮助分析数据(支持文本和图形报告). `profile.proto` 是一个 Protobuf v3 的描述文件, 它描述了一组 callstack 和 symbolization 信息,  作用是统计分析的一组采样的调用栈, 是很常见的 stacktrace 配置文件格式. 

采样方式:
- `runtime/pprof`: 采集程序(非 Server)的指定区块的运行数据进行分析. 
- `net/http/pprof`: 基于 HTTP Server 运行, 并且可以采集运行时数据进行分析. 
- `go test`: 通过运行测试用例, 并指定所需标识来进行采集. 

## 使用模式:
### 1. `Report generation`: 报告生成. 



### 2. `Interactive terminal use`: 交互式终端使用. 
通过命令行对堆正在运行的应用程序 pprof 的抓取和分析:

#### 2.1 CPU Profiling
```shell
$ go tool pprof http://localhost:6060/debug/pprof/profile\?seconds\=60

Fetching profile over HTTP from http://localhost:16060/debug/pprof/profile?seconds=60
Saved profile in /Users/mac/pprof/pprof.samples.cpu.001.pb.gz
Type: cpu
Time: Jun 19, 2021 at 4:02pm (CST)
Duration: 1mins, Total samples = 0
No samples were found with the default sample value type.
Try "sample_index" command to analyze different sample values.
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) top10
Showing nodes accounting for 36.23s, 97.26% of 37.25s total
Dropped 80 nodes (cum <= 0.19s)
Showing top 10 nodes out of 34
      flat  flat%   sum%        cum   cum%  Name
    32.63s 87.60% 87.60%     32.70s 87.79%  syscall.syscall
     0.87s  2.34% 89.93%      0.88s  2.36%  runtime.stringtoslicebyte
     0.69s  1.85% 91.79%      0.69s  1.85%  runtime.memmove
     0.52s  1.40% 93.18%      0.52s  1.40%  runtime.nanotime
     ...

```

- `flat`: 函数自身的运行耗时。
- `flat%`: 函数自身在 CPU 运行耗时总比例。
- `sum%`: 函数自身累积使用 CPU 总比例。
- `cum`: 函数自身及其调用函数的运行总耗时。
- `cum%`: 函数自身及其调用函数的运行耗时总比例。
- `Name`: 函数名。

#### 2.2 内存 Profiling
执行 `go tool pprof -TYPE $HOST/debug/pprof/heap` 堆内存进行分析, 其中 `TYPE` 有以下可选项:
- `inuse_space`: 默认, 分析应用程序的常驻内存占用情况。
- `inuse_objects`: 查看每个函数所分别的对象数量
- `alloc_objects`: 分析应用程序的内存临时分配情况。
- `alloc_space`:  查看分配的内存空间大小


```
$ go tool pprof http://localhost:6060/debug/pprof/heap
    Fetching profile over HTTP from http://localhost:6060/debug/pprof/heap
    Saved profile in /Users/eddycjy/pprof/pprof.alloc_objects.alloc_space.inuse_objects.inuse_space.011.pb.gz
    Type: inuse_space
    Entering interactive mode (type "help" for commands, "o" for options)
    (pprof)
```

#### 2.3 Goroutine Profiling

使用 `go tool pprof http://localhost:6060/debug/pprof/goroutine` 可以分析goroutine.

- `traces` 命令，这个命令会打印出对应的所有调用栈，以及指标信息，可以让我们很便捷的查看到整个调用链路有什么，分别在哪里使用了多少个 goroutine，并且能够通过分析查看到谁才是真正的调用方. 在调用栈上来讲，其展示顺序是**自下而上**的.

```text
(pprof) traces
Type: goroutine
Time: Jun 19, 2021 at 4:42pm (CST)
-----------+-------------------------------------------------------
         1   runtime.gopark
             runtime.netpollblock
             internal/poll.runtime_pollWait
             internal/poll.(*pollDesc).wait
             internal/poll.(*pollDesc).waitRead (inline)
             internal/poll.(*FD).Accept
             net.(*netFD).accept
             net.(*TCPListener).accept
             net.(*TCPListener).Accept
             net/http.(*Server).Serve
             net/http.(*Server).ListenAndServe
             net/http.ListenAndServe (inline)
             main.main
             runtime.main
-----------+-------------------------------------------------------
         1   runtime.gopark
             time.Sleep
             main.main.func1
-----------+-------------------------------------------------------
         1   runtime/pprof.runtime_goroutineProfileWithLabels
             runtime/pprof.writeRuntimeProfile
             runtime/pprof.writeGoroutine
             runtime/pprof.(*Profile).WriteTo
             net/http/pprof.handler.ServeHTTP
             net/http/pprof.Index
             net/http.HandlerFunc.ServeHTTP
             net/http.(*ServeMux).ServeHTTP
             net/http.serverHandler.ServeHTTP
             net/http.(*conn).serve
-----------+-------------------------------------------------------
         1   syscall.syscall
             syscall.read
             syscall.Read (inline)
             internal/poll.(*FD).Read.func1
             internal/poll.ignoringEINTR
             internal/poll.(*FD).Read
             net.(*netFD).Read
             net.(*conn).Read
             net/http.(*connReader).backgroundRead
-----------+-------------------------------------------------------
```

#### 2.4 Mutex Profiling
这些情况会造成阻塞: 调用 `chan`（通道）、调用 `sync.Mutex` （同步锁）、调用 `time.Sleep()` 等等.

```go
func init() {
    // 设置采集频率, 默认关闭，若设置的值小于等于 0 也会认为是关闭。
	runtime.SetMutexProfileFraction(1)
}
```

- `top` 查看互斥量排名
    ```
    $ go tool pprof http://localhost:6061/debug/pprof/mutex
        Fetching profile over HTTP from http://localhost:6061/debug/pprof/mutex
        Saved profile in /Users/eddycjy/pprof/pprof.contentions.delay.010.pb.gz
        Type: delay
        Entering interactive mode (type "help" for commands, "o" for options)
        
        (pprof) top
        Showing nodes accounting for 653.79us, 100% of 653.79us total
            flat  flat%   sum%        cum   cum%
        653.79us   100%   100%   653.79us   100%  sync.(*Mutex).Unlock
                0     0%   100%   653.79us   100%  main.main.func1
    ```

- `list` 查看指定函数的代码情况（包含特定的指标信息，例如：耗时,
    
    ```
    (pprof) list main
    Total: 653.79us
    ROUTINE ======================== main.main.func1 in /eddycjy/main.go
            0   653.79us (flat, cum)   100% of Total
            .          .     40:		go func(i int) {
            .          .     41:			m.Lock()
            .          .     42:			defer m.Unlock()
            .          .     43:
            .          .     44:			datas[i] = struct{}{}
            .   653.79us     45:		}(i)
            .          .     46:	}
            .          .     47:
            .          .     48:	err := http.ListenAndServe(":6061", nil)
            .          .     49:	if err != nil {
            .          .     50:		log.Fatalf("http.ListenAndServe err: %v", err)
    (pprof) 
    ```

#### 2.5 Block Profiling
```go
func init() {
    // 设置采集频率, 默认关闭，若设置的值小于等于 0 也会认为是关闭。
	runtime.SetBlockProfileRate(1)
}
```

- `top`: 查看阻塞排名
- `list`: 查看阻塞详情

### 3. `Web interface`: Web 界面. 
```go
import (
	_ "net/http/pprof"
	// ...
)

func main() {
    // ...
    _ = http.ListenAndServe("0.0.0.0:6060", nil)
}
```
通过浏览器访问`http://127.0.0.1:6060/debug/pprof/` , 在对应的访问路径上新增 `?debug=1`，就可以直接在浏览器访问，否则会直接下载 profile 文件, 访问结果如下:
```text
/debug/pprof/

Types of profiles available:
Count	Profile
3	allocs          # 查看过去所有内存分配的样本，访问路径为 $HOST/debug/pprof/allocs。
0	block           # 查看导致阻塞同步的堆栈跟踪，访问路径为 $HOST/debug/pprof/block。
0	cmdline         # 当前程序的命令行的完整调用路径
8	goroutine       # 查看当前所有运行的 goroutines 堆栈跟踪，访问路径为 $HOST/debug/pprof/goroutine。
3	heap            # 查看活动对象的内存分配情况， 访问路径为 $HOST/debug/pprof/heap。
0	mutex           # 查看导致互斥锁的竞争持有者的堆栈跟踪，访问路径为 $HOST/debug/pprof/mutex。
0	profile         # 默认进行 30s 的 CPU Profiling，得到一个分析用的 profile 文件，访问路径为 $HOST/debug/pprof/profile。
11	threadcreate    # 查看创建新 OS 线程的堆栈跟踪，访问路径为 $HOST/debug/pprof/threadcreate。
0	trace           #  A trace of execution of the current program. You can specify the duration in the seconds GET parameter. After you get the trace file, use the go tool trace command to investigate the trace.
full goroutine stack dump
```
