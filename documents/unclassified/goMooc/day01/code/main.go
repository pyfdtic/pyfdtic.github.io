package main
import (
    "fmt"
    "time"
    "runtime"
)

func main() {
    runtime.GOMAXPROCS(1)
    for i:=0; i<10; i++ {
        i := i
        go func() {
            fmt.Println("A: ", i)
        }()
    }

    time.Sleep(time.Hour)
}
