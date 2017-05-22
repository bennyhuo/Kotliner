---
title: Kotlin 与 Java 兼容的神坑，Int 说：怪我咯
category: 编程语言
reward: false
date: 2017-05-22 13:40:40
author: bennyhuo
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

Kotlin 是一门完全面向对象的语言，连函数也都是对象，基本类型也是对象，所以类似 Java 那样不伦不类的类型系统，Kotlin 的类型表现起来有着高度的一致性。

这样是好的，不仅 Kotlin 这么做，很多语言都这么做。可是，Kotlin 号称 100% 兼容 Java 啊，谁让你这么号称的，只要出了问题就是 Kotlin 的锅！

话说我们社区的一位“萌新”（大佬，您也真是太萌了）提了个问题，说有这么个 Java 接口：

```java
interface IntMap<V> extends java.util.Map<Integer, V> {
    V get(Integer key);
    V get(int key);
}
```

用 Kotlin 无法实现。

我一开始听说的时候，表示居然有此事！待洒家试了一试之后发现，还真得无法实现！

为啥？因为在 Kotlin 当中没有 int 这个的基本类型，Int 类型在编译时会根据情况自动选择映射于 Java 字节码的 Integer 还是 int，所以我们无需关心也无法决定 Int 最终编译成什么。

于是用 Kotlin 实现这个接口时，上述两个 get 方法签名就变得一致了：

```kotlin
class IntMapImpl: IntMap<String> {
    override fun get(key: Int?): String {
		...
    }

    override fun get(key: Int): String {
		...
    }
}
```

不得不说，这是一个忧伤的故事，这是第一个遇到的让我觉得无解的问题，因为 Kotlin 的编译器就真这么写了，真是无话可说。

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，或者加 QQ 群：162452394 联系我们。

![](/arts/kotlin_group.jpg)