---
title: 'val b = a?: 0，a 是 Double 类型，那 b 是什么类型？'
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


> 前面有朋友看了我的文章之后，表示都不敢用 Kotlin 了。
> 
> 这事儿要辩证的看待，Java 坑那么多，你还不是照样用么？
> 
> 而 Kotlin 本身坑很少，大多数都是为了照顾 Java 而出现的一些有意思的问题，对于这些问题的深挖可以让我们看得更多，想得更深，了解得更多，然则与坑斗，其乐无穷也。
> 

本文基于 Kotlin 1.1.4。

## 1. 数值类型的推导

我们的标题其实已经说得很清楚了，我把完整的代码贴出来：

```kotlin
    var a: Double? = null
    val b = a?: 0
```
问题就是，请问 `b` 的类型。

这个问题看上去似乎并没有什么难度，在 Kotlin 当中，所有数值类型都是 `Number` 的子类，也就是说 `Double` 和 `Int` 都是它的子类，这种情况下， `b` 的类型应该毫无疑问的是 `Number`。

真的是这样吗？

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/15039773971806.jpg)

很遗憾，IntelliJ 告诉我们，`b` 的类型是 `Any`。

>注意，这里是变量 `b` 的类型推导， `b` 指向的内存的类型取决于真实的内存数据。

为什么会这样？难道我发现了一个编译器的 Bug？

## 2.  普通类继承的推导

有了这个发现，我倒要试试看，是不是所有类的推导都会直接推导为 `Any`。

先声明下面的类型：

```kotlin
interface Parent
class ChildA: Parent
class ChildB: Parent
```
看下我们的测试代码：

```kotlin
    var childA: ChildA? = null
    val childOrParent = childA?: ChildB()
```
有了前面的经验，我就有点儿担心 Kotlin 会把 `childOrParent` 这个变量推导成 `Any` 了，不过结果却并不是这样：

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/15039778133742.jpg)

推导的类型是 `Parent`，是合乎情理的。

## 3. 字节码分析

面对这个类型的结果差异，我瞬间想到了看看字节码，

```kotlin
val b = a?: 0
```
对应的字节码：

``` java
    LINENUMBER 8 L2
   L3
    ICONST_0
    INVOKESTATIC java/lang/Integer.valueOf (I)Ljava/lang/Integer;
   L4
    ASTORE 2
```

>注意，此处为了阻止编译器优化字节码，我们需要对变量 `b` 有操作，例如在后面添加 `println(b)`，否则字节码可能与文中有出入

而：

```kotlin
val childOrParent = childA?: childB
```
对应的字节码：

```java
    LINENUMBER 21 L10
   L11
    ALOAD 4
    CHECKCAST java/lang/Comparable
   L12
    ASTORE 5
```
为啥前面就没有 `CHECKCAST` 呢？字节码是生成的结果，不是类型推导的原因，通过这个结果我们只能推测到类型推导的结果在第一个那里就被推导为 `Any` 了。

当然，如果你愿意，你也可以明确指定 `b` 的类型：

```kotlin
    val b: Number = a?: 0
```
这时候字节码也会变成：

```java
    LINENUMBER 8 L2
   L3
    ICONST_0
    INVOKESTATIC java/lang/Integer.valueOf (I)Ljava/lang/Integer;
    CHECKCAST java/lang/Number //注意，这里有强转啦
   L4
    ASTORE 2
```

尽管这样会达到我们的目的，但并不能解释前面我们遇到的问题。

## 4. 几个猜想

最近在看《柔软的宇宙》，科学家们在发现问题的时候总是先来个猜想，然后想办法通过实践来证明。前面被数值的基本类型的映射坑了太多把了，所以我想一定是因为后面的那个 `0` 被识别成了 Java 基本类型的 `int`。

那么我们想办法把这个这个 `0` 变成装箱类型会怎么样呢？

```kotlin
    var a: Double? = null
    val b = a?: "0".toInt()
```

结果，`b` 仍然是 `Any`。换句话说，`b` 的类型推导实际上与 Java 的基本类型没有任何关系。

难道只是 `Number` 的问题？ 这时候我突然想到前面刚刚被坑过的 `AtomicInteger`，试了一下：

```kotlin
    var a: Double? = null
    val b = a?: AtomicInteger(0)
```
结果再一次打脸，这次 `b` 的类型居然就是 `Number` 了。

想来想去，这可能就是 Kotlin 编译器在求两个类型的公共父类的时候有些奇怪的东西我没有 GET 到，那这个奇怪的东西究竟是什么呢？

## 5. Google 不到的东西，只有源码会告诉我

吃螃蟹，就得做好为别人栽树的思想准备。像 Kotlin 这样的新语言，很多时候 Google 也不会告诉我们答案，这也是很多人望而生却的原因。

为了搞清楚编译器是怎么做的，我们需要把 [Kotlin](https://github.com/JetBrains/kotlin) 的源码拖下来，编译运行，打断点调试，找到一个叫做 `TypeBoundsImpl` 的类，这个类实际上就是负责计算公共父类的，有兴趣的朋友也可以自行研读一下它的 `computeValues` 方法，我们在这里只简单介绍一下公共父类的计算方法：

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/15040135903171.jpg)

`Int` 和 `Double` 除了有个公共父类 `Number` 之外，还都实现了 `Comparable` 接口，所以在计算公共父类的时候，先把他们都罗列出来，然后最终变成了求 `Number` 和 `Comparable` 的公共父类，那么自然就是 `Any` 了。

而我们再来看看另外的情形：

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/15040139035564.jpg)

`AtomicInteger` 和 `Double` 只有一个公共父类 `Number`，不像前面还有个公共父接口 `Comparable`，这样问题就简单了，直接把 `b` 的类型推导成 `Number` 而不是 `Any`。

那么对于我们自定义的那一组例子，结果也类似：

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/15040140676853.jpg)

不过我们稍加修改，结果就又是一番情景了：

```kotlin
interface Parent
class ChildA: Parent, Serializable
class ChildB: Parent, Serializable
```

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/15040141583459.jpg)

这下你能想明白是为啥了吧？

同样的，在 YouTrack 上面还有这样的一个 Issue，[Common super type for different enum items is Any instead of common declared super type](https://youtrack.jetbrains.com/issue/KT-4687#tab=Comments)，原因也是类似的。

## 6. 再问个为什么

这里有人肯定还是觉得奇怪，因为 `Int` 和 `Double` 的父类和接口都一样呀，为啥推导的结果不是 `Number` 呢？

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/15040148638022.jpg)

显然这里 Kotlin 的开发者也是很纠结的，既然可以推导成 `Number`，那么推导成 `Comparable` 可以不可以呢？换句话说，对于两个类型有两个以上没有继承关系的公共父类（接口）的情形，推导的结果会有歧义，可能也是为了消除这种歧义，Kotlin 编译器采用了一种比较稳妥的方式来处理，不偏袒任何一方，直接将推导的结果定为 `Any` 也是合情合理的。

这时候如果你明确知道自己想要什么，例如前面的例子，我们想要 `b` 的类型是 `Number` 而不是 `Comparable` ，那么只需要显式的为 `b` 声明类型就可以了。

## 7. 看看其他语言怎么做

对于类似的情形，C# 直接报错：

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/15040503926970.jpg)

即便 `C` 和 `D` 有公共父类， C# 仍然需要你明确他们的类型，大家可以参考 StackOverflow 上面的讨论：
[No implicit conversion when using conditional operator](https://stackoverflow.com/questions/6137974/no-implicit-conversion-when-using-conditional-operator)

当然，如果能像 Scala 那样推导，也是不错滴：

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/assets/15040506938974.jpg)

但不是所有的类都有 Scala 的交集类型（intersection type ）。

---

欢迎关注微信公众号 Kotlin

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/Kotlin.jpg)

