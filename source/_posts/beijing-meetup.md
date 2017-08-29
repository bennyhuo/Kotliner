---
title: 北京 Kotlin 线下活动纪要
category: 社区动态
reward: false
date: 2017-06-12 06:15:18
author: bennyhuo
tags: 社区动态
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

各位大佬好！

6月10日，我们 Kotlin 北京的小伙伴们进行了第一次线下活动，活动非常得欢乐，我们首先介绍了 Kotliner 社区的发展历程，并在冰封等小伙伴们毫不知情的情况下对他们进行了赞（tiao）扬（xi），总之这是一次成功滴活动，完美。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.06.12/yonghegong.jpg)

在活动一开始呢，大家对自己进行了介绍，介绍的过程中我就发现，哇，大家果然大多数都是 Android 开发者，同行居多来来握个爪(* @ο@ *) ～ 大家大多工作多年，有着比较丰富的工作经验，这一次过来也让我们看到其实程序员不是那么无聊的，有两位小伙伴都立刻马上要乐队搞起了，简直不能太有趣~

### 分享一：现代编程语言概述

接着呢，来自在互联网混迹多年的的大哥贾彦伟，他也是 [Kotlin 中文站](https://www.kotlincn.net/)的主要维护者，为我们带来了现代主要的静态编程语言特性以及几门主流语言在这些特性的实现上的对比。

他主要从介绍了类型安全、Lambda、Trait、高阶函数等等几个方面为我们对比了诸如 Scala、Swift、Kotlin 的实现。不得不说，作为一门既要兼容 Java，又要求简洁，还不失优雅的语言，Kotlin 在这些特性的实现上表现得可圈可点。贾哥这分明就是劝人快快入坑嘛，连圈粉都搞得这么优雅，果然是大佬。

贾哥还带着我们做了好几个 Kotlin 的题目，让我们对 Kotlin 的一些进阶特性有了进一步的认识，尤其是那个字符统计的题目，简直要秒杀别人几条街的感觉~

```kotlin
input.groupingBy { it }.eachCount().let(::println)
```

### 分享二：Kotlin 的协程

而后呢，我为大家分享了一下 Kotlin 的协程，就是一次一小时搞懂协程的尝试，在这一个小时当中我们 cover 了什么是协程（额，就是 Coroutine 嘛），协程最基础的例子，协程调度，协程是如何运行以及编译器是如何编译 suspend 函数的等知识点；除此之外，我们也简单地了解了一下 [kotlinx.coroutine](https://github.com/Kotlin/kotlinx.coroutines) 是如何调度协程的，以及 [Anko](https://github.com/Kotlin/anko) 以及 [AsyncAwait](https://github.com/metalabdesign/AsyncAwait) 这两个框架在 Android 上的协程支持。

```kotlin
log("coroutine before")
launch(AsyncContext()) {
    try {
        log("coroutine start")
        val result = longTimeTask(this@HelloWorld::doSthLongTime)
        log("coroutine end $result")
    } catch(e: Exception) {
        e.printStackTrace()
    }
}
log("coroutine after")
```

分享中编写的代码已经提交到 Github：[Kotlin-Coroutine-HelloWorld
](https://github.com/enbandari/Kotlin-Coroutine-HelloWorld/tree/master)

### 合影在这里！

最后大家一起合影，话说这次发文化衫大家也没法直接换嘛，所以下次合影是不是就可以一起文化衫了呢！

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.06.12/beijing-meetup_small.jpg)


---

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，或者加 QQ 群：162452394 （**必须正确**回答加群暗号哈，防止特务混入）联系我们。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/kotlin_group.jpg)