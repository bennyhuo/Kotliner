
---
title: Kotlin Native：本周又搞了个大事情
date: 2017-04-10 09:49:45
author: bennyhuo
tags: Native
keywords:
categories: 官方动态

# 是否开启打赏, 开启填true,不开启填false
reward_title:
# 开启打赏务必填写以下二选一,否则打赏图片是我的:)
reward_wechat:
reward_alipay:
# 转载的文章需要注明来源
source_url:
---


话说。。有一天在地铁上正站得我风生水起（这玩意儿也能风生水起？）的时候，小伙伴突然往群里面丢了一个链接，然后群里就炸了：[Kotlin/Native Tech Preview: Kotlin without a VM](https://blog.jetbrains.com/kotlin/2017/04/kotlinnative-tech-preview-kotlin-without-a-vm/)，Kotlin Native 在年初的时候就逐渐引起大家的注意，Kotlin 的扛把子 Andrey 哥也一再表示“用不了多久咱们就能过上好日子啦”，当然我估摸着 2017 年的大事情会不少，这不来得还挺快。

话说这 Kotlin Native 呢，还处于预览阶段，官方一再强调“我还是个宝宝，你们可不要乱来哦”：

> No performance optimization has been done yet, so benchmarking Kotlin/Native makes no sense at this point.

这个嘛，请官方放心，我们不会轻易放过你的！

于是群里小伙伴们开始下载 Native 的源码 [Github: Kotlin-native](https://github.com/JetBrains/kotlin-native) 开始编译，并运行其中的 sample，整个过程其乐融融，有 Mac 和 Linux 的小伙伴表示毫无压力，而只有 windows 的哥们表示“我的树莓派不在家里啊”。额，看到没，用 windows 做开发是没有钱途滴！这事儿突然让我想起来前几天编译 Android Sdk 源码，编译 mac 版在 Mac 上面编即可，而想编译 windows 的 sdk，你就得在 Linux 上面先编译完 Linux 版 sdk，然后再用 Linux 版来个移魂大法换成 windows 版，额，我就改了几句 aapt 的代码，mac 版立等可取，windows 版编了好几天啊哭。。

接着说 Kotlin Native，当小伙伴们看到 Kn 编译之后生成了这样的 stubs，瞬间表示 Jni 有救啦！

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.4.10/native.png)

一个注解就能连接上 C 代码，是不是很让人期待！

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.4.10/show.jpg)

想来也真是给力，上周刚刚推送的文章对 Kotlin Native 做了狠狠的期待，这周就出这样的大新闻，不得不说，2017 年 Kotlin 很让人期待呀，如果你还在犹豫到底要不要学，啥也别说了先加 QQ 群吧：

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/e_group.png)

