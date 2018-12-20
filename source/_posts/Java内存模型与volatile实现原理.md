---
title: Java内存模型与volatile实现原理
date: 2018-12-20 14:25:50
categories: 
	- Java多线程
---

一、Java内存模型
---
（1）高速缓存的引入解决了CPU与内存的速度差异矛盾，但引入了一个新的问题：缓存一致性（Cache Coherence）。为了解决一致性问题，需要各个处理器访问缓存时都遵循一些协议。

Java内存模型可以理解为在特定操作协议下，对特定的内存或高速缓存进行读写访问的过程抽象。Java内存模型屏蔽了各种硬件和操作系统的内存访问差异，是Java跨平台特性的基础。Java内存模型中主内存与硬件主内存类比，工作内存可以类比为CUP高速缓存。

（2）内存间交互操作（原子性，不可再分。除64位的double和long的load、store、read、write分为两次32位原子操作）

lock(锁):对一个变量lock，会清空工作内存中此变量的值

unlock(释放锁):unlock之前，必须先把变量同步回主存

read(读):从主存读取变量，之后必定是load操作

load(加载):工作内存接受读取变量，之前必定是read操作

use(使用):将变量传递给执行引擎，当JVM遇到一个需要使用变量值的字节码指令时执行该操作

assign(赋值):从执行引擎接收的值，赋给工作内存变量，当JVM遇到一个需要改变值的字节码指令时执行该操作

store(存储):从工作内存发起回写，之后必定是write操作

write(写):主内存接受回写，之前必定是store

（3）Happens-Before原则

1. 程序次序规则
2. 管程锁定规则
3. volatile变量规则
4. 线程启动规则
5. 线程终止规则
6. 线程中断规则
7. 对象终结规则
8. 传递性

二、volatile实现原理
---
volatile的特性包括：内存可见性和禁止指令重排序。

通过DCL代码理解volatile原理

``` java
public static Singleton getSingleton() {
        if (singleton == null) {
            synchronized (Singleton.class) {
                if (singleton == null) {
                    singleton = new Singleton();
                }
            }
        }
        return singleton;
}
```
singleton = new Singleton()的class字节码指令：


利用hsdis和JITWatch查看分析HotSpot JIT compiler生成的汇编代码：
![](/images/ClassBytecode.png)

**使用volatile修饰**
![](/images/assembly_1.png)

**不使用volatile修饰**
![](/images/assembly_2.png)

使用volatile比不使用多了一行lock addl $0x0,(%rsp)。lock前缀相当与一个内存屏障，有三个功能：

1. 重排序时不能把后面的指令重排序到内存屏障之前
2. 使本CPU的Cache立即写入主存
3. store和write操作（即写入主存的操作）会使别的CPU的该变量所在的缓存行失效（可能会引起伪共享问题）

参考资料：
---
- 《深入理解Java虚拟机:JVM高级特性与最佳实践(第2版)》 周志明 著