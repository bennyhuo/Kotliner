---
title: Android Extensions 小坑
category: 编程语言
reward: false
date: 2017-06-19 06:19:57
author: bennyhuo
tags: android
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

用 Kotlin 写 Android 我们都知道也都最先被一个叫做 kotlin-android-extensions 的东西吸引，因为我们再也不用写findViewById 了。

它其实是编译器帮我们生成的扩展，它更像是一个语法糖，又由于有缓存机制，所以性能也不是什么问题。那么它有什么问题呢？

* 你在 App 中引用了一个 Mvp 的源码模块，如果这个模块没有开启 kotlin-android-extensions 插件，那么它当中的 xml 布局文件中的 id 将不会被合成，我们只能通过 findViewById 访问他们；

	```kotlin
	compile project(":mvp")
	```

* 同理，如果你引用了一个第三方 aar 的依赖，里面的 xml 布局文件的 id 就不会被合成，只能 findViewById；

	```kotlin
	compile "xxx.yyy:zzz:1.0"
	```

* 另外，对于 App 中 debug/release 目录下面的 xml 布局文件中的 id，我们同样只能 findViewById。

当然，对于 flavor，kotlin-android-extensions 是做了支持的，所以大家可以放心大胆的去用。

有些朋友可能也遇到过明明 IntelliJ 提示有合成的 View 引用，但编译不通过的情况，这个需要大家理解下它的工作机制。实际上 IntelliJ 的提示只不过是为了用户体验，而真正编译执行的操作是在编译器插件当中合成的，而在早期的 IntelliJ 的插件中，无论你是否真正启用 kotlin-android-extensions 插件，IntelliJ 都会提示你有这样的合成引用，这样就会导致刚才我们说到的问题。


---

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，或者加 QQ 群：162452394 （**必须正确**回答加群暗号哈，防止特务混入）联系我们。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/kotlin_group.jpg)