---
title: 一个 Boolean 的有趣的扩展
category: 编程语言
reward: false
date: 2017-06-19 06:19:23
author: bennyhuo
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

我定义了一个叫做 isEnabled 的变量：

```kotlin
 var isEnabled: Boolean = ... 
```

后面要用它的时候通常来说我会直接写出这个变量名，然后想到还得写个 if ... else，就像这样：

```kotlin
 if(isEnabled) ... else ... 
```

当然 IntelliJ 也为我们提供了后缀表达式快速输入 if 语句：

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.06.19/booleanext.gif)

当我想要做一个判断的时候，我首先想到的是这个变量 isEnabled，于是通常我会很快的把它给打出来，接着我想着如果它为 true，那么如何如何，这时候还需要把光标移到最开始，写下 if，尽管我们刚说 IntelliJ 提供了后缀表达式来简化这个输入过程，但还是不能改变这个反人类的输入本质啊。

我想要的就是一个数据处理流，每一次函数调用都是一次数据的变换，if 的出现破坏了流的结构。

相比之下我更喜欢下面的写法：

```kotlin
 isEnabled.yes { 
 	... 
 }.otherwise { 
 	... 
 } 
```

如果你还是看不出来 if 到底有什么“罪过”，那我们再来看一个场景：

```kotlin
 args 
     .map(String::toInt) 
     .filter{    it % 2 == 0		} 
     .count().equals(5) 
 ... 
```

例子是我瞎写的，不用在意它的含义。假设我们通过一系列的函数调用得到了一个 Boolean 值，并且需要根据它的值来做出一些操作，那么我们是不是应该在外面套一层 if else 语句呢？

```kotlin
 if(args 
 	.map(String::toInt) 
 	.filter{    it % 2 == 0		} 
 	.count() == 5 
 ){ 
     println("输入参数中偶数的个数为5") 
 } else { 
     println("输入参数中偶数的个人不为5") 
 } 
```

而我们通过扩展完全可以实现下面的写法：

```kotlin
 args 
     .map(String::toInt) 
     .filter{    it % 2 == 0		} 
     .count().equals(5) 
     .yes { 
         println("输入参数中偶数的个数为5") 
     }.otherwise { 
         println("输入参数中偶数的个人不为5") 
     } 
```

如果分支语句中还有返回值，我们也可以接着向下执行（当然，对于有返回值的分支语句，我们要求分支完备，也就是必须有 otherwise 调用）：

```kotlin
 args.map(String::toInt).filter{ 
         it % 2 == 0 
     }.count().equals(5).yes { 
         "666" 
     }.otherwise { 
         "23333" 
     }.let(::println) 
```

另外，我们可以稍稍做下修改，让语法变得更简单（并且不易懂= =？）：

```kotlin
 isEnabled { 
     "666" 
 } otherwise { 
     "2333" 
 } 
```

不过这样写有个弊端，就是在前面的 Boolean 值是个表达式的时候，需要加括号， otherwise 调用之后如果还有后续操作，那么也会产生歧义。当然这一步其实不是很必须了，做到前面的步骤已经足够。

下面我们来看下扩展的源码：

```kotlin
 sealed class BooleanExt<out T> constructor(val boolean: Boolean) 
 　 
 object Otherwise : BooleanExt<Nothing>(true) 
 class WithData<out T>(val data: T): BooleanExt<T>(false) 
 　 
 inline fun <T> Boolean.yes(block: () -> T): BooleanExt<T> = when { 
     this -> { 
         WithData(block()) 
     } 
     else -> Otherwise 
 } 
 　 
 inline fun <T> Boolean.no(block: () -> T) = when { 
     this -> Otherwise 
     else -> { 
         WithData(block()) 
     } 
 } 
 　 
 inline infix fun <T> BooleanExt<T>.otherwise(block: () -> T): T { 
     return when (this) { 
         is Otherwise -> block() 
         is WithData<T> -> this.data 
         else ->{ 
             throw IllegalAccessException() 
         } 
     } 
 } 
 　 
 inline operator fun <T> Boolean.invoke(block: () -> T) = yes(block) 
```

---

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，或者加 QQ 群：162452394 （**必须正确**回答加群暗号哈，防止特务混入）联系我们。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/kotlin_group.jpg)