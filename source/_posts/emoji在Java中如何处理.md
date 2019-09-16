---
title: emoji在Java中如何处理
date: 2019-08-19 18:32:14
categories: 
	- Java
---

## emoji 字符串在 Java 中被切分？

```java
str="😂😂😂😂";
System.out.println(str.substring(0,str.length()-1));
```

> 😂😂😂?

打印结果里最后一个字符并不是问号，而是乱码。



## 怎么能解决由切分emoji引起的乱码问题？

### String 的 offsetByCodePoints 方法

```java
public int offsetByCodePoints(int index, int codePointOffset) {
    if (index < 0 || index > value.length) {
        throw new IndexOutOfBoundsException();
    }
    return Character.offsetByCodePointsImpl(value, 0, value.length, index, codePointOffset);
}
```

index : 起始位置下标。

codePointOffset : 按照码位的偏移量。

返回值 : 从起始位置偏移 codePointOffset 个码位后的下标。

###  offsetByCodePoints 怎么解决了这个问题？

offsetByCodePoints 方法内部调用了 Character 的静态方法 offsetByCodePointsImpl 。

```java
static int offsetByCodePointsImpl(char[]a, int start, int count,
                                  int index, int codePointOffset) {
    int x = index;
    if (codePointOffset >= 0) {
        int limit = start + count;
        int i;
        for (i = 0; x < limit && i < codePointOffset; i++) {
            if (isHighSurrogate(a[x++]) &&
                    x < limit &&
                    isLowSurrogate(a[x])) {
                x++;
            }
        }
        if (i < codePointOffset) {
            throw new IndexOutOfBoundsException();
        }
    } else {
        int i;
        for (i = codePointOffset; x > start && i < 0; i++) {
            if (isLowSurrogate(a[--x]) &&
                    x > start &&
                    isHighSurrogate(a[x-1])) {
                x--;
            }
        }
        if (i < 0) {
            throw new IndexOutOfBoundsException();
        }
    }
    return x;
}
```

只关注 codePointOffset 大于等于 0 的情况，其他情况同理。

Line 7 : 遍历 codePointOffset 次数，并且 x 作为返回结果必须小于字符数组长度。

Line 8 : isHighSurrogate 函数判断 (当前位置) 的字符是否为高代理单元。

以下是 JDK 源码中对该方法的描述。

> Determines if the given {@code char} value is a Unicode high-surrogate code unit.
>
> 确定给定的{@code char}值是否为Unicode高代理代码单元。
>
> Such values do not represent characters by themselves, but are used in the representation of in the UTF-16 encoding.
>
> 这些值本身不代表字符，而用UTF-16编码来表示。

Line 9 : 限定 x 不能超过 char 数组长度

Line 10 : isLowSurrogate函数判断 (当前位置+1) 的字符是否为低代理单元。

Line 11 : 若判断两个位置的字符都在 Surrogate 范围，x++ 将这两个字符作为一个整体

### 引用自 [gdkkx](https://angovia.me/)的总结

> 我简单解释下，Java 里面的编码都是 UTF-16 去表示unicode 的。但是 unicode 的范围只用 16 bit 是无法表示完全的。
>
> 那超过 16bit 的部分怎么办呢？就用两个char表示就行。
>
> 那我怎么知道这个编码是超过 16bit 的呢？就看 highSurrogate 和 lowSurrogate 是否满足。
>
> highSurrogate 和 lowSurrogate 就是说如果用两个 char 表示一个字符，那么他的高 16 位和低 16 位范围是否正确。

## 怎么判断一个字符串中有多少个字？( emoji 算一个字)

根据 offsetByCodePointsImpl 方法源码修改一下，直接看代码

```java
public static int emojiNum(String str) {
    char[] strChar = str.toCharArray();
    int len = strChar.length, num=0;
    for (int i=0; i<len;) {
        num++;
        if (Character.isHighSurrogate(strChar[i++]) &&
                i<len && Character.isLowSurrogate(strChar[i])) {
            i++;
        }
    }
    return num;
}
```

其他情况也可以根据 offsetByCodePointsImpl 方法修改。例如：怎么判断刚输入的N个字符是否是 emoji ？