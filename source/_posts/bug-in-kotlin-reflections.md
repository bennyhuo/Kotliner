---
title: 'Kotlin 反射有个坑你们知道么！'
category: 编程语言
author: bennyhuo
reward: false
date: 2017-08-30 08:03:43
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

话说有那么一天，想写个什么框架秀一秀 Kotlin 的反射，这个框架呢，需要获取一个类型的某一个方法，然后调用之。

为了简化问题的叙述，下面我们直接以获取 String 的方法为例，写下了下面的代码（兴高采烈地）：

```kotlin
    String::class.memberFunctions
            .first{ it.name == "toInt" && it.parameters.first().type.jvmErasure == Int::class}
            .call("7f12abcd", 16).let(::println)
```
这是要干什么呢？想调用下面的方法把这个字符串转成 `Int`：

```kotlin
public inline fun String.toInt(radix: Int): Int = java.lang.Integer.parseInt(this, checkRadix(radix))
```

相当于下面的调用：

```kotlin
    "7f12abcd".toInt(16).let(::println)
```

然而，不幸的是，这段代码运行时异常：

```
Exception in thread "main" kotlin.reflect.jvm.internal.KotlinReflectionInternalError: 

Reflection on built-in Kotlin types is not yet fully supported. 

No metadata found for public open val length: 
kotlin.Int defined in kotlin.String[DeserializedPropertyDescriptor@1018bde2]
```

好，非常棒。看上去不是我代码的问题，因为错误信息说：Kotlin 反射对于内置类型还没有完全支持！！

什么鬼！还能不能愉快的玩耍了？引入一个 2.5M 大的反射包已经够够的了（要知道我们腾讯地图的矢量 SDK 也才 1M 多一点儿），结果还不能玩耍了？？

随便 Google 了一下，果然我不是一个人在坑里呆着： [Support reflective access to built-in classes and members](https://youtrack.jetbrains.com/issue/KT-13077)

好吧，我们看看报错的究竟是什么鬼

![](/assets/15048617397170.jpg)

报错的位置是 `String` 的一个叫 `length` 的属性，好的，我们在 `String.kt` 文件当中呢，只能看到下面的代码：

```kotlin
public class String : Comparable<String>, CharSequence {
    ...
    public override val length: Int
    ...
}
```

这个类居然没有实现？`String` 也不是抽象类啊，为啥 `length` 后面啥也没写呢？

大家不要惊慌，这个东西只是一个壳罢了。Kotlin 的编译器会把 `String::length` 这个属性映射成 Java 当中的 `String.length()` 这个方法，换句话说，它根本不需要实现，而更像是障眼法。

也正是因为这个，Kotlin 的 `String::length` 实际上对于 Jvm 来说是根本不存在的东西，也就谈不上 Jvm signature 了，于是乎前面的那个反射代码就报了错。

由于目前的 Kotlin 版本（1.1.4-2）的反射库貌似也没有怎么做优化，所以不论你是获取方法，还是获取属性，亦或是获取扩展属性和方法，Kotlin 都首先会计算出这个类所有的成员然后再来筛选，我们随便找两个例子大家一看便明白了：

```kotlin
val KClass<*>.memberFunctions: Collection<KFunction<*>>
    get() = (this as KClassImpl).data().allNonStaticMembers.filter { it.isNotExtension && it is KFunction<*> } as Collection<KFunction<*>>

val KClass<*>.memberExtensionFunctions: Collection<KFunction<*>>
    get() = (this as KClassImpl).data().allNonStaticMembers.filter { it.isExtension && it is KFunction<*> } as Collection<KFunction<*>>
```
这样的话导致的问题就是，只要这个类当中存在向 Java 类或者方法映射的问题，那么它的反射就基本上用不了。换句话说，不只是 `String`，还有 `Map` 之类的，甚至 `Enum` 都会存在这样的问题。

> 考虑到 `Number` 极其子类也都存在类型映射的情况，这里特别说明一下，以上问题在 `Number` 家族中并不存在，看来支持其他类型也就是时间问题啦。

哇靠，遇到这样的问题该怎么办呢？

很简单，遇到这样的映射问题，通常说明这个东西就是 Java 本身的东西，用 Java 反射就好啦！

不得不说， Kotlin 的坑，基本上都是为了兼容 Java 导致的，比如前面几篇文章提到的类型映射的问题，数据类的问题，相信在 Kotlin 后面的版本，这些问题都将不是问题~~

