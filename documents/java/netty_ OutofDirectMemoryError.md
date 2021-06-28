# netty OutofDirectMemoryError

java 容器报错:

```java
2021-06-17 11:02:11,540 [grpc-default-worker-ELG-4-11] [sid:] 
    WARN  io.netty.channel.AbstractChannelHandlerContext [/] - An exception 'io.netty.util.internal.OutOfDirectMemoryError: failed to allocate 16777216 byte(s) of direct memory (used: 520093983, max: 536870912)' 
    [enable DEBUG level for full stacktrace] was thrown by a user handler's exceptionCaught() method while handling the following exception:
    io.netty.util.internal.OutOfDirectMemoryError: failed to allocate 16777216 byte(s) of direct memory (used: 520093983, max: 536870912)
    #011at io.netty.util.internal.PlatformDependent.incrementMemoryCounter(PlatformDependent.java:624)
    #011at io.netty.util.internal.PlatformDependent.allocateDirectNoCleaner(PlatformDependent.java:578)
    #011at io.netty.buffer.PoolArena$DirectArena.allocateDirect(PoolArena.java:709)
    #011at io.netty.buffer.PoolArena$DirectArena.newChunk(PoolArena.java:698)
    #011at io.netty.buffer.PoolArena.allocateNormal(PoolArena.java:237)
    #011at io.netty.buffer.PoolArena.allocate(PoolArena.java:213)
    #011at io.netty.buffer.PoolArena.allocate(PoolArena.java:141)
    #011at io.netty.buffer.PooledByteBufAllocator.newDirectBuffer(PooledByteBufAllocator.java:262)
    #011at io.netty.buffer.AbstractByteBufAllocator.directBuffer(AbstractByteBufAllocator.java:179)
    #011at io.netty.buffer.AbstractByteBufAllocator.directBuffer(AbstractByteBufAllocator.java:170)
    #011at io.netty.buffer.AbstractByteBufAllocator.ioBuffer(AbstractByteBufAllocator.java:131)
    #011at io.netty.channel.DefaultMaxMessagesRecvByteBufAllocator$MaxMessageHandle.allocate(DefaultMaxMessagesRecvByteBufAllocator.java:73)
    #011at io.netty.channel.nio.AbstractNioByteChannel$NioByteUnsafe.read(AbstractNioByteChannel.java:117)
    #011at io.netty.channel.nio.NioEventLoop.processSelectedKey(NioEventLoop.java:651)
    #011at io.netty.channel.nio.NioEventLoop.processSelectedKeysOptimized(NioEventLoop.java:574)
    #011at io.netty.channel.nio.NioEventLoop.processSelectedKeys(NioEventLoop.java:488)
    #011at io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:450)
    #011at io.netty.util.concurrent.SingleThreadEventExecutor$5.run(SingleThreadEventExecutor.java:873)
    #011at io.netty.util.concurrent.DefaultThreadFactory$DefaultRunnableDecorator.run(DefaultThreadFactory.java:144)
    #011at java.lang.Thread.run(Thread.java:745)
```

报错代码位置位于 `io/netty/netty-common/4.1.6.Final/netty-common-4.1.6.Final-sources.jar!/io/netty/util/internal/PlatformDependent.java`:

```java
private static void incrementMemoryCounter(int capacity) {
    if (DIRECT_MEMORY_COUNTER != null) {
        for (;;) {
            long usedMemory = DIRECT_MEMORY_COUNTER.get();
            long newUsedMemory = usedMemory + capacity;
            if (newUsedMemory > DIRECT_MEMORY_LIMIT) {
                throw new OutOfDirectMemoryError("failed to allocate " + capacity
                        + " byte(s) of direct memory (used: " + usedMemory + ", max: " + DIRECT_MEMORY_LIMIT + ')');
            }
        }
    }
}
```

`DIRECT_MEMORY_LIMIT` 默认读取 `io.netty.maxDirectMemory` 默认为 -1.
```java
// Here is how the system property is used:
//
// * <  0  - Don't use cleaner, and inherit max direct memory from java. In this case the
//           "practical max direct memory" would be 2 * max memory as defined by the JDK.
// * == 0  - Use cleaner, Netty will not enforce max memory, and instead will defer to JDK.
// * >  0  - Don't use cleaner. This will limit Netty's total direct memory
//           (note: that JDK's direct memory limit is independent of this).
long maxDirectMemory = SystemPropertyUtil.getLong("io.netty.maxDirectMemory", -1);

if (maxDirectMemory == 0 || !hasUnsafe() || !PlatformDependent0.hasDirectBufferNoCleanerConstructor()) {
    USE_DIRECT_BUFFER_NO_CLEANER = false;
    DIRECT_MEMORY_COUNTER = null;
} else {
    USE_DIRECT_BUFFER_NO_CLEANER = true;
    if (maxDirectMemory < 0) {
        maxDirectMemory = maxDirectMemory0();
        if (maxDirectMemory <= 0) {
            DIRECT_MEMORY_COUNTER = null;
        } else {
            DIRECT_MEMORY_COUNTER = new AtomicLong();
        }
    } else {
        DIRECT_MEMORY_COUNTER = new AtomicLong();
    }
}
DIRECT_MEMORY_LIMIT = maxDirectMemory;
```

我们没有设置 `io.netty.maxDirectMemory`, 此时, `DIRECT_MEMORY_LIMIT` 使用 jvm 的 max direct memory 值 512M , 与报错信息 `direct memory (used: 520093983, max: 536870912)`相符, 启动命令:
```
java -XX:MaxDirectMemorySize=512m ...
```

test netty leak
```
-Dio.netty.leakDetection.level=ADVANCED  # 10% 采样
-Dio.netty.leakDetection.level=PARANOID  # 全部采样.
```
