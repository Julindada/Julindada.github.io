---
title: 深入理解CAS
date: 2018-12-20 14:38:44
categories: 
	- Java多线程
---

一、锁机制
---
1. 悲观锁(互斥同步)：假定会发生并发冲突，屏蔽一切可能违反数据完整性的操作。例如：synchronized和ReentrantLock。
2. 乐观锁(非阻塞同步)：假设不会发生并发冲突，只在提交操作时检查是否违反数据完整性。乐观锁需要操作和冲突检测这两个步骤具备原子性，这里就不能再使用互斥同步来保证了，只能靠硬件来完成。硬件支持的原子性操作最典型的是：比较并交换（Compare-and-Swap，CAS）。

二、CAS概念
---
CAS包含了3个操作数——需要读写的内存位置V、进行比较的值A和拟写入的新值B。当且仅当V的值等于A时，CAS才会通过原子方式用新值B来更新V的值。

三、Atomic类实现原理
---
以AtomicInteger的incrementAndGet和compareAndSet方法为例

``` java
public final int incrementAndGet() {//当前值加1,并返回新值
    return unsafe.getAndAddInt(this, valueOffset, 1) + 1;
}

public final int getAndAddInt(Object var1, long var2, int var4) {
    int var5;
    do {
        var5 = this.getIntVolatile(var1, var2);
    } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));
    return var5;
}
```

1. AtomicInteger里面的value被加载在工作内存中，通过getIntVolatile(var1, var2)方法获取value的值。

2. 通过compareAndSwapInt方法，以原子操作修改值。

3. 若不成功则循环获取value值，直到compareAndSwapInt方法修改值成功并返回true。

``` java
public final boolean compareAndSet(int expect, int update) {//如果当前值为expect,则设置为update
    return unsafe.compareAndSwapInt(this, valueOffset, expect, update);
}
```
该函数若更新值失败，则直接返回false。无循环是因为要依赖expect值，更新失败说明不符合expect值，故不做无用功。

四、CAS与synchronized性能比较
---

``` java
public class Main {
    private static volatile int a=0;
    private static AtomicInteger atomicInteger = new AtomicInteger(0);
    private static int m=10000000;//循环次数

    public static void main(String[] args) throws InterruptedException {
        int amount=2;//线程数量
        Thread[] threads=new Thread[amount];
        //Syn
        long start0=System.currentTimeMillis();
        for (int i=0; i<amount; i++){
            threads[i]=new Thread(new MyThread0());
            threads[i].start();
        }
        for (int i=0; i<amount; i++) threads[i].join();
        long end0=System.currentTimeMillis();
        System.out.println("There is " + amount + " threads to run " + m + " , Syn use "+(end0-start0)+ " ms");

        //CAS
        long start1=System.currentTimeMillis();
        for (int i=0; i<amount; i++){
            threads[i]=new Thread(new MyThread1());
            threads[i].start();
        }
        for (int i=0; i<amount; i++) threads[i].join();
        long end1=System.currentTimeMillis();
        System.out.println("There is " + amount + " threads to run " + m + " , CAS use "+(end1-start1)+ " ms");

    }
    static class MyThread0 implements Runnable{
        @Override
        public void run() {
            synchronized(Main.class){
                for (int i=0; i<m; i++)
                    a++;
            }
        }
    }
    static class MyThread1 implements Runnable{
        @Override
        public void run() {
            for (int i=0; i<m; i++)
                atomicInteger.incrementAndGet();
        }
    }
}
```
There is 8 threads to run 1000 , Syn use 8.7 ms

There is 8 threads to run 1000 , CAS use 4.7 ms
***

There is 8 threads to run 10000 , Syn use 14.4 ms

There is 8 threads to run 10000 , CAS use 11.5 ms
***

There is 16 threads to run 10000 , Syn use 26.2 ms

There is 16 threads to run 10000 , CAS use 19.6 ms
***

There is 32 threads to run 10000 , Syn use 25.9 ms

There is 32 threads to run 10000 , CAS use 31.9 ms

以上数据由每10次结果计算一次平均值得出。从测试结果看，在锁竞争不激烈的情况下CAS乐观锁效率更高；锁竞争激烈的情况下synchronized悲观锁效率更高。

原因：锁竞争低的情况下，**synchronized仍进行线程阻塞和唤醒切换以及用户态内核态间切换操作浪费大量CPU资源，而CAS基于硬件实现，且自旋较少，不需要进入内核或切换线程**，效率远高于synchronized。一旦锁竞争激烈，CAS操作会耗费大量CPU资源在自旋，故效率低于synchronized。

五、CAS为什么是原子操作
---

来自[gdkkx](http://angovia.me/)的提示：换一个思路来思考这个问题，如果需要实现一个有原子性的CAS操作，如何实现？

(1) 总线加锁

所谓总线锁就是使用处理器提供的一个 LOCK＃信号，当一个处理器在总线上输出此信号时，其他处理器的请求将被阻塞住, 那么该处理器可以独占使用共享内存。(个人看法：如果使用总线加锁，开销很大，所以，并不是期望的结果)

(2) 缓存锁定

在同一时刻我们只需保证对某个内存地址的操作是原子性，利用缓存一致性机制来保证操作的原子性。

> 具体实现原理参考博客：[聊聊并发（五）——原子操作的实现原理](https://www.infoq.cn/article/atomic-operation)

六、CAS的ABA问题
---
在CAS算法中，如果V的值首先由A变成B，再由B变成A，那么仍然被认为是发生了变化，并需要重新执行算法中的某些步骤。

解决方法：

1. 垃圾回收机制支持
2. 给对象加版本号，使用：AtomicStampedReference(“对象-引用”二元组，通过在引用上加上”版本号”)或者AtomicMarkableReference(“对象-布尔值”二元组，布尔值标记是否为“已删除节点”)

七、总结
---
1. 实践过程中，运行时间并不稳定，所以临界值并不准确。原因：可能是计算机其他进程影响。
2. 代码中循环次数m越高，CAS效率越低。原因：循环次数的增加，间接增加了CAS中锁竞争，而对synchronized影响不大，若将for写在synchronized之外则效率会大大降低。
3. 乐观锁也并非完美的锁机制。没有所有情况都完美的解，只有某些情况下的最优解。

参考资料：
---

- 《实战Java高并发程序设计》 葛一鸣/郭超 著
- Java并发编程实战([Java Concurrency in Practice](https://inbravo.github.io/docs/refer/java-concurrency.pdf))
- [聊聊并发（五）——原子操作的实现原理](https://www.infoq.cn/article/atomic-operation)
