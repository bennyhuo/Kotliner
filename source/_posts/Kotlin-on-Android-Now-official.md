---
title: Google 力挺 Kotlin，这是怎么回事！
category: 官方动态
reward: false
date: 2017-05-18 07:38:18
author:
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

> 困死梦中惊坐起，Google 力挺 Kotlin ！

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.18/android_kotlin.png)

话说洒家梦中化身鲁肃，正准备跟孔明去草船借箭呢，突然好友微信发来则消息：Google 将 Kotlin 列为 Android 官方开发语言，据称 IO 大会上提到这一点的时候，下面的掌声如雷鸣般不绝于耳~

艾玛，这掌声，台上讲话的确定不是毛爷爷？

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.18/maoyeye.jpg)

话说听到这一消息之后，群里的小伙伴们都炸了，嗯？这么多夜猫子！

好啦，不说别的，就说说这一消息能给我们带来什么影响呢？

## 不敢用 Kotlin？

要知道，在 Google 大大在背后撑腰之前，我们在 Android 当中写 Kotlin 都算是野路子，没有人认可这事儿的，出了问题也还要自己负责，代码移交的时候也会带来一堆麻烦（毕竟大家大多数人不愿意学这个东西啊）。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.18/bengkui.jpg)

现在好了，你就可以理直气壮的说，哇塞，Kotlin 是官方语言了，这么好的东西你们都不用，都不愿意去用，你们迟早要被遗忘在历史的车轮印里面的那个小缝缝里面！

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.18/confirm.jpg)

## 想用 Lambda？

要说 Kotlin 最早用在写 Android 上，让人感觉最爽的就是可以任性的使用 **Lambda**，当然这在 Java 8 中也得到了支持（虽然还是支持得很诡异），于是 Google 就差人去折腾个 Jack&Jill，折腾了两年，有一天有个人一进门就冲着 J&J 的开发者们喊了一句 "Hi, Jack!"，于是这个项目就 Deprecated 了。嗯，Android 开发者们想用 Lambda 指望 Google 看来是要等到猴年马月了，而且按照之前的尿性，估计也得等到某个 api 版本才会支持，这就尴尬了。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.18/jacknjill.jpg)

谁能拯救你？当然是 Kotlin 啊！函数是头等公民的 Kotlin，支持函数式编程都毫无压力，Lambda 的体验更是不在话下，哎呀，不说了，我要去写 Kotlin 了~

## 想用 Coroutine？

最近在封装 Camera api。用过的小伙伴肯定都知道，Camera 有两套 api，老 api 基本是是同步调用的接口，只有拍照、对角这两个有回调；新 api 呢，所有的指令都类似于 http 请求一样异步发出去，回调呢，运行在我们发请求时传入的一个 Handler 所在的线程上，这样看来，回调恶魔的大戏就要上演了。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.18/callback_evil.jpg)

遇到这样的 api，我也很绝望啊。。

开发当中类似回调套回调的写法不在少数，我们该如何写出一段看上去是同步执行的代码，实际上却自己处理了异步请求呢？当然是 Coroutine 啊。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.18/coroutine.jpg)

开发过 Unity 的朋友肯定会想到这个，去年有个同事去搞了一段时间游戏，对 Coroutine 的用法大为赞赏，它的主要优点有哪些呢？

* 代码看上去直观，易懂
* 异常处理简单（一个 try ... catch 就解决问题）
* 资源消耗少（比起你动不动就搞十个八个线程池来说，Coroutine 简直太经济啦）

好，最关键的是什么呢？这在 Kotlin 1.1 当中，Coroutine 已经非常完善了，尽管还被标记为 Experimental，但 Kotlin 1.2 的时候目测也不会有大改动，想想以后的 Android 代码还会有这样的东西，真的感觉世界都很美好呢！

哎呀，咋又说这么多，我要去写 Kotlin 了！

## WTFUtils

每次都要提这个东西。你的代码里面一定一堆堆的 StringUtils/ImageUtils/BitmapUtils/LogUtils 这样的东西吧！

更搞笑的是，每个人都有自己的 LogUtils，当然也不排除有些人用的是 LogUtil，结果呢，我在 as 当中 double-shift 输入 LogUti 之后出来一堆，天呐，你们让我选哪一个啊。。

曾经有一次组里面的 iOS 大哥做分享，叫“手把手教 Android 开发写 iOS”，里面特别提到了动态修改方法的特性，以及扩展方法的特性，艾玛，看得我眼馋的不要不要的，想着哪天我也可以给 String 加个什么 util 方法的，该多好。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.18/xiangjingjing.jpg)

后来遇到了 Kotlin，Android 的小伙伴们，来吧，删掉你的 XXUtils 或者 XXUtil 吧，让那些不堪回首的往事都随风而去吧。

## 空指针异常？

听说你用 Java 写的 Android 代码经常出空指针异常啊？是不是辛辛苦苦大半月，一跑就挂千百遍？千百遍，还每次都是那个空指针，急得你直把眼泪掉，哎，这TM是什么破逻辑，模板代码数不尽，查着查着就懵逼。

Kotlin，安全类型来帮你，从此不怕空指针。

。。。

好人就做到这里，剩下的你们自己关注公众号 Kotlin 翻看以前的文章自己体会 ~

**哈哈，我去写 Kotlin 了，别拦着我。**

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.18/byebye.jpeg)

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，或者加 QQ 群：162452394 联系我们。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/kotlin_group.jpg)