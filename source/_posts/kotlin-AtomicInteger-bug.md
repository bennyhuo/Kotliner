---
title: 诡异了，AtomicInteger 在 Kotlin 里面居然是 Abstract 的？
category: 编程语言
author: bennyhuo
reward: false
date: 2017-08-26 08:03:43
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

### 1. 人生自古哪儿没坑

作为一个用了两年 Kotlin 的人，最近越来越控制不住自己，于是乎各种 Java 代码都开始变成 Kt，于是，也就发现了更多好玩的东东~
 
话说呀，有个叫做 Retrofit 的框架，它呢有个叫 CallAdapter 的东西，其中有个 RxJava 版本的实现，让某一个类继承 AtomicInteger 来存储一个线程安全的状态值，如果大家有兴趣的话，可以去看下这个类：[CallArbiter.java](https://github.com/square/retrofit/blob/master/retrofit-adapters/rxjava/src/main/java/retrofit2/adapter/rxjava/CallArbiter.java)

而我呢，最近在闲暇时间仿照 Retrofit 写了一个叫做 RetroApollo 的项目，这个项目主要是对 [Apollo-Android](https://github.com/apollographql/apollo-android) 这个项目做了封装，让我们更方便的访问 GraphQL Api，这其中呢，就涉及到对 RxJava 的支持了。

我当时就想，我也搞一个 `CallArbiter` 吧，只不过我是用 Kotlin 写的，显然根据以往的经验，Kotlin 根本就不会是什么问题好嘛，结果刚开个头就傻眼了：

```kotlin
class CallArbiter: AtomicInteger{ //错误！你有三个方法需要实现！
    constructor(initialValue: Int) : super(initialValue)
    constructor() : super()
}
```

就这么一段代码，打死我都想不到居然会报错，报错理由也挺逗：

> Error:(8, 1) Kotlin: Class 'CallArbiter' must be declared abstract or implement abstract base class member public abstract fun toByte(): Byte defined in java.util.concurrent.atomic.AtomicInteger

这哪儿跟哪儿呢你说，`AtomicInteger` 人家本身就是一个具体的类啊，哪儿来的没实现的方法呢？这错误报的虽然是说没有实现 `toByte` 方法，可仔细观察一下就会发现，没实现的方法居然还有 `toShort` 和 `toChar`。。

### 2. 此坑真是久长时啊

我以为这是在逗我玩呢，毕竟看了下 `AtomicInteger` 和它的父类 `Number`，找了半天也没有找到所谓的 `toByte` 方法啊。

不过这方法名咋看着这么眼熟呢，好像 Kotlin 里面所有的数都有这个方法吧，追查了一下 Kotlin 源码，居然发现 Kotlin 自己有个叫 `Number` 的抽象类！

```kotlin
public abstract class Number {
    public abstract fun toDouble(): Double
    public abstract fun toFloat(): Float
    public abstract fun toLong(): Long
    public abstract fun toInt(): Int
    public abstract fun toChar(): Char
    public abstract fun toShort(): Short
    public abstract fun toByte(): Byte
}
```

所以会不会哪些所谓的没有实现的抽象方法都是来自这个 `Number` 的？

这还用猜？必然是啊，不过这事儿也有点儿奇怪了，毕竟 `AtomicInteger` 继承的可是 `java.lang.Number`，Kotlin 和 Java 中的这两个 `Number` 之间有什么关系么？

### 3. 解密时刻

我之前很早的时候就写过一篇文章 [为什么不直接使用 Array 而是 IntArray ？](https://blog.kotliner.cn/2017/01/09/why-not-Array-but-IntArray/) 提到了 Kotlin 类型到 Java 类型的映射问题，这里我们其实也是遇到了相同的问题。

`kotlin.Number` 编译后映射成了 `java.lang.Number`，也就是说，`AtomicInteger` 在 Kotlin 当中被认为是 `kotlin.Number` 的子类，而巧了，`toByte` 这样的方法在 `AtomicInteger` 和 `java.lang.Number` 当中都没有具体实现，这就导致了前面的情况发生。

不过这里还是有问题的，Java 中的 `Number` 有类似 `doubleValue` 这样的方法，Kotlin 当中的 `toDouble` 与之有何关系？

我们定义这么一个类继承自 Kotlin 的 `Number`：

```kotlin
class MyNumber: Number(){ 
    override fun toByte(): Byte { ... }
    override fun toChar(): Char { ... }
    override fun toDouble(): Double { ... }
    override fun toFloat(): Float { ... }
    override fun toInt(): Int { ... }
    override fun toLong(): Long { ... }
    override fun toShort(): Short { ... }
}
```

编译之后看看字节码就会发现，编译器自动为我们合成了 Java 中 `Number` 对应的方法，例如 `doubleValue`：

```java
  // access flags 0x51
  public final bridge doubleValue()D
   L0
    LINENUMBER 19 L0
    ALOAD 0
    INVOKEVIRTUAL test/TestNumber.toDouble ()D
    DRETURN
    MAXSTACK = 2
    MAXLOCALS = 1
```

而这个 `doubleValue` 正是转而去调用了 `toDouble` 这个方法！

好，那么前面一直出问题的 `toByte` 呢？也是一样，生成了一个叫做 `byteValue` 的方法，然后去调用了 `toByte`。

等等！！这里有问题！人家 Java 中 `Number` 的 `byteValue` 方法是有实现的！你这样不是把人家原来的实现给搞没了么。。

**java.lang.Number**

```java
public byte byteValue() {
    return (byte)intValue();
}
```

嗯啊，是没了。。。除了这个之外，还有一个 `shortValue`，这二位都在 Java 中默认调用了 `intValue`，在 Kotlin 当中则被要求单独实现（`toByte`/`toShort`），于是乎我们想要继承 `AtomicInteger` 就得实现这两个方法。

至于 `toChar`，这个在 Java 的 `Number` 版本中没有对应的 `charValue`，所以我们也得自己实现咯。

### 4. 小结

经过上面的讨论，我们知道了 Kotlin 和 Java 之间存在各式各样的类型和方法的映射，为了兼容 Java 而又保持自己独特的风格，Kotlin 显然不得不这样做，相比其他语言，它也是做得比较不错的。

而对于我们遇到的问题，从逻辑上讲，`AtomicInteger` 这个类不应该是 `open` 的，我们继承它和把它作为一个组件进行组合实际上是没有区别的，对于组合就可以解决的问题，就不应该使用继承。换句话说，文章开头的代码正确的写法应该是：

```kotlin
class CallArbiter<T>{

    val atomicState = AtomicInteger(STATE_WAITING)
    ...   
}
```



---

关注公众号 Kotlin ，获取最新的 Kotlin 动态。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/Kotlin.jpg)