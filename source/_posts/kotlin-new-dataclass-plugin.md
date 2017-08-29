---
title: 用 Json 直接生成 Kotlin data class，你要不要试试
category: 社区动态
author: bennyhuo
reward: false
date: 2017-07-02 22:00:34
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.07.02/json4kotlin.jpg)

话说呀，前一阵子慕课网的视频群里面的小伙伴们纷纷表示，Kotlin 没有可以 Json 直接生成数据类的工具，很蓝瘦呀！用 Kotlin 就享受不到 Java 中类似 [GsonFormat](https://github.com/zzz40500/GsonFormat) 这样的插件的支持了，忧伤- -、

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.05.22/nothappy.jpg)

后来作为 Kotlin 国内踩坑先锋队队员，我表示抽空去研究下这个插件，然后如法炮制一个 Kotlin 版本的，于是经过几天对 IntelliJ 插件开发的复习和 GsonFormat 逻辑的理解，搞出了一个叫做 [NewDataClassAction](https://github.com/enbandari/NewDataClassAction) 的插件，其中的逻辑与前者基本一致，不同之处在于交互方式稍微有些变化，相比之下更加简单快捷了。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.07.02/dataclass.gif)

我们可以通过一段 Json 文字来直接创建一个 Kotlin 的 data class，这样省去了手动编辑的烦恼，提升效率就是这么简单。

我们的插件用到了一个文件模板，这个大家在设置里面也是可以看到的：

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/2017.07.02/filetemplate.jpeg)

当然，这个插件才刚刚开始开发，功能相对基础和简单，后续我也将考虑完成以下两个方向的功能：

1. 支持主流的 Json 框架的注解生成，例如 Gson 等；
2. 支持出 Json 以外的其他数据类型，例如 xml 等；

如果大家有好的想法和意见，欢迎直接提 issue，GitHub 见：https://github.com/enbandari/NewDataClassAction



---

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，或者加 QQ 群：162452394 （**必须正确**回答加群暗号哈，防止特务混入）联系我们。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/kotlin_group.jpg)