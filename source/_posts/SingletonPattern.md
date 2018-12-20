---
title: SingletonPattern
date: 2018-12-20 14:21:16
categories: 
	- Java多线程
---


双重检查锁（DCL，即 double-checked locking）
---

``` java
public class Singleton {
    private volatile static Singleton singleton;
    private Singleton (){}
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
}
```
双重检查锁写法中volatile的作用是什么？
---
**禁止指令重排序。**(JDK1.5之前volatile不能保证完全禁止指令重排)


为什么volatile禁止指令重排序的作用是有必要的？
---
（1）singleton = new Singleton()并不是一个原子操作，这条语句会被分为三个步骤

1分配内存空间。

2初始化对象。

3将内存空间的地址赋值给对应的引用。

指令重排序可能导致3在2之前（3不可能在1之前，至于为什么，请思考）。**当cpu执行完3，却未执行完2,恰好有另一个线程执行到第一个非空判断，此时singleton不为null，这时singleton指向的对象未被正确发布。**

在未被正确发布的对象中存在的问题：
singleton指向的是一个失效值。（对象只有在构造函数返回后才处于可预知的，真正稳定的状态）

（2） **synchronized保证了变量的可见性**（除此之外，synchronized还有同步功能、保证了同步块内每条语句之间的有序性）。 synchronized代码块中对于共享变量的读取需要从主内存中重新获取，在进入synchronized代码块时并不会保证之前的写操作写入到主内存中，只保证在退出代码块时能将工作内存的数据写入到主内存中。

如果不使用volatile，使用其他方法可不可以？为什么？
---
（1）**静态初始化一个对象引用**

单例模式的静态内部类写法

（2）**volatile修饰对象的引用或者使用AtomicReferance**

AtomicReferance保证实例化对象操作的原子性

（3）**final修饰对象的引用**

final定义引用时需要初始化。类似于急加载模式，但没必要加final修饰

（4）**将对象引用保存到一个由锁保护的域中**

线程安全库中容器类。或者类库中的其他数据传递机制（例如Future和Exchanger）

（5）**个人认为在第一个if语句执行体和return之间执行任意一个singleton的非静态成员方法**

在执行singleton的非静态成员方法之后，singleton指向的一定是一个完全初始化的对象实例，保证了return返回的一定是一个完全初始化的对象实例

参考资料：
---
- Java并发编程实战([Java Concurrency in Practice](https://inbravo.github.io/docs/refer/java-concurrency.pdf)) 3.5安全发布（可精读，最好看英文版）
- [Java 并发基础之内存模型](https://javadoop.com/post/java-memory-model)（一个高质量的博客，推荐阅读）
