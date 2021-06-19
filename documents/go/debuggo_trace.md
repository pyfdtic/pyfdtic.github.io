# Go 性能剖析工具 之 trace

```
$ go tool trace trace.out
```

- `View trace`: 查看跟踪
- `Goroutine analysis`: Goroutine 分析
- `Network blocking profile`: 网络阻塞概况
- `Synchronization blocking profile`: 同步阻塞概况
- `Syscall blocking profile`: 系统调用阻塞概况
- `Scheduler latency profile`: 调度延迟概况
- `User defined tasks`: 用户自定义任务
- `User defined regions`: 用户自定义区域
- `Minimum mutator utilization`: 最低 Mutator 利用率

## Demo

```go
import (
	"os"
	"runtime/trace"
)

func main() {
	trace.Start(os.Stderr)
	defer trace.Stop()

	ch := make(chan string)
	go func() {
		ch <- "Go Go Go"
	}()

	<-ch
}
```

```shell
# 生成跟踪文件
$ go run main.go 2> main.trace

# 启动可视化
$ go tool trace main.trace
```