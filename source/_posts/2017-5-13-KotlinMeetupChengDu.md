---
layout: post
title: 成都 Kotlin 线下聚会报告及科技汇总
category: 线下活动
tags: 线下活动
author: 千里冰封
reward: false
date: 2017-05-15 12:13:15
source_url: http://ice1000.org/2017/05/13/KotlinMeetupChengDu
keywords: Life,ice1000,Kotlin
description: kotlin event ChengDu
---

上星期我组织了成都的一次主题为 Kotlin 的线下聚会（也可以说是沙龙），来的人不到十个，却代表了三代人啊。

## 为何线下聚会

不知道

## 活动内容

早上 9:30 \~ 10:00 基本把成员接到。

上午大概的内容：

0. *千里冰封*聊 Kotlin DSL 的原理
0. _CharlieJiang_ 聊 Kotlin JNI 调用
0. _CharlieJiang_ 介绍项目 [Laplacian](https://github.com/cqjjjzr/Laplacian) ， JVM 音乐播放器内核
0. *清水河学渣*介绍 Kotlin Web 开发
0. *清水河学渣*介绍自己写的 IntelliJ 高亮插件 [MultiHighlight](https://github.com/huoguangjin/MultiHighlight)
0. 大家一起讨论 Kotlin 的花样玩法。

然后午饭就在旁边一破地方吃的，*优格*还说他来过这地方（汗），吃到一半，*迎风尿，腿不抖*被公司召唤而去。
`members.size.dec()`。

下午，*优格*拿出了他的**任天堂 switch**，然后一发而不可收拾。。

+ *清水河学渣*暴露身份，实际上是**清水河学神**。
+ 有个挤牛奶的游戏，玩起来动作很像撸管
+ 最年轻的*查理江*同学全程打守望先锋
+ 大家都笑得像个孩子

这次聚会我反正学到了新东西，很开心。希望别人也如此。

这里总结一下我觉得值得一提的聚会中聊到的科技。这两天我又有新发现，下次活动说。

## 黑科技汇总

### 假构造方法模拟 Factory

（by 清水河学渣）

+ 重载 `companion object` 的操作符模仿构造方法，还能做到完全模拟 Factory ：

```kotlin
/**
 * 直线，使用解析式表示
 * ax + by + c = 0
 */
class Line(val a: Int, val b: Int, val c: Int) {
//  constructor(point1: Pair<Int, Int>, point2: Pair<Int, Int>) : this()
// 上面这样写，通过两点计算 a b c 表达式会很复杂，可读性并不好（虽然我不觉得）
// 但是你必须在第一时间调用 primary constructor ，在此之前不能进行
// 任何变量声明或者流程控制
// 怎么办呢
  companion object Factory {
    // 于是可以通过这个解决
    // 这个求 a b c 的写法其实并不优雅，只是为了展示例子
    // 这个方法调用起来和构造方法语法完全相同
    // 但是这样写，可以在调用构造方法之前进行一些流程控制或者变量声明
    operator fun invoke(one: Pair<Int, Int>, two: Pair<Int, Int>): Line {
      val a = two.second - one.second
      val b = one.first - two.first
      val c = two.first * one.second - one.first * two.second
      return Line(a, b, c)
    }
  }
}

fun main(args: Array<String>) {
  val a = Line(1, 1, 1) // 调用构造方法
  val b = Line(Pair(1, 2), Pair(3, 4)) // 调用操作符重载
}
```

### 非常规函数的 JNI 声明

（by CharlieJiang）

+ 非常规函数的 JNI 声明，以及通过注解确保编译器不改名

比如 getter setter 以及改名的函数。

```kotlin
class A {
  var a: Int
    external get
    external set

  @JvmName("myNameIsVan")
  external fun myNameIsVan()
}
```

### JvmMultifileClass

（by 千里冰封）

+ 将多个文件的内容编译到同一个类里面

文件 1：

```kotlin
// file 1.kt
@file:JvmName("Fuck")
@file:JvmMultifileClass

val shit = "fuck"
val fuck = "shit"
```

文件 2：

```kotlin
// file 2.kt
@file:JvmName("Fuck")
@file:JvmMultifileClass

fun GameObject.destroy() {
  isAlive = true
}
```

编译之后只会生成一个类 'Fuck.class' ，里面有 `shit fuck destroy` 三个成员。

### 模拟 Null safety

（by 千里冰封）

+ 代数数据类型模拟 Null safety

这是个函数式编程的概念，这里用了 when+is 模拟模式匹配。

这个我在讲的时候代码写错了，后来我想到了原因，是因为没加泛型的协变。

关于我当时举的例子（用 ADT 处理除法的除数为 0 的情况），正确的代码是这样的：

```kotlin
sealed class Option<out T>()
class Some<out T>(val obj: T) : Option<T>()
object None : Option<Nothing>()

fun div(a: Int, b: Int) : Option<Int> =
  if (b == 0) None else Some(a / b)
```

调用：

```kotlin
fun main(args: Array<String>) {
  val io = Scanner(System.`in`)
  val res = div(io.nextInt(), io.nextInt())
  println(when (res) {
    is Some -> println("result: ${res.obj}") // smart cast
    is None -> println("nothing here")
  })
}
```

我觉得还行。

## 三代人

两个 00 后，两个 80 后，三个 90 后，我感觉没有任何代沟，最后一起嗨起来。

也许这就是单纯吧.jpg

## 集体照

随便 po 两张上来：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/14/1.jpg)

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/14/2.jpg)

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/14/3.jpg)



-----------------

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，并且加 QQ 群：162452394 联系我们。

![](/arts/kotlin_group.jpg)