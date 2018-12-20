---
title: 方法区的OOM
date: 2018-12-20 14:44:08
categories: 
	- JVM
---

一、JDK1.6 64bit下方法区的OOM
---
今天跑了一个项目(JDK1.6，Windows 64bit)，然后抛出了这样一个异常

java.lang.OutOfMemoryError: PermGen space

2018-09-19 09:18:23 JRebel: ERROR Failed to transform class xxx/xxx/xxx

我的解决方法：在IDEA中设置Tomcat VM options 增大这两个参数-XX:PermSize -XX:MaxPermSize（-XX:PermSize设置方法区初始值，默认是物理内存的1/64；由XX:MaxPermSize设置最大方法区内存的大小，默认是物理内存的1/4。）


二、JDK1.7前后的方法区
---

PermGen space(Permanent Generation space)翻译为永久代。但个人理解就是JDK1.6以及之前的运行时数据区的‘方法区’。

周志明老师的《深入理解Java虚拟机:JVM高级特性与最佳实践(第2版)》 P56 代码清单2-6如下

``` java
public class RuntimeConstantPoolOOM {
    public static void main(String[] args){
        //使用List保持常量池引用，避免Full GC回收常量池行为
        List<String> list = new ArrayList<String>();
        int i=0;
        while (true){
            list.add(String.valueOf(i++).intern());
        }
    }
}
```
书中所描述的java.lang.OutOfMemoryError: PermGen space是由String造成的。但这只是JDK1.6的情况。如果用JDK1.7以后的版本编译，就会抛出java.lang.OutOfMemoryError: Java heap space。

原因如下（JDK1.7前后方法区中数据的分配）：

1. JDK1.6及之前 ： 方法区中存储类信息、常量池、静态变量、JIT编译后的代码等数据。（周志明老师的《深入理解Java虚拟机》描述的就是这种情况。）

2. JDK1.7 ： SymbolTable(符号引用)移到Native Memory，StringTable(字符串常量池)移到Java Heap，class statics(类的静态变量)移到了Java Heap

3. JDK1.8 ： 移除永久代。取而代之的是元空间(Metaspace)。大多数类的元数据存储在Metaspace中。

三、为什么移除永久代？
---

1. 字符串存在永久代中，容易出现性能问题和内存溢出。
2. 永久代大小不容易确定，PermSize指定太小容易造成永久代OOM
3. 永久代会为GC带来不必要的复杂度，并且回收效率偏低。
4. 其他虚拟机没有永久代的概念。可能会将HotSpot与JRockit合并。

参考资料：
---

- 《深入理解Java虚拟机:JVM高级特性与最佳实践(第2版)》 周志明著
- [知乎问题：方法区的Class信息,又称为永久代,是否属于Java堆？](https://www.zhihu.com/question/49044988/answer/113961406)
- [JVM的Heap Memory和Native Memory](https://blog.csdn.net/u013721793/article/details/51204001)