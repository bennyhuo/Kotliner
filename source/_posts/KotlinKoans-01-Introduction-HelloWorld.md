---
title: "解毒 Kotlin Koans: 01 Introduction/HelloWorld"
category: 编程语言
author: bennyhuo
reward: false
date: 2017-07-23 15:25:08
tags: "Kotlin Koans"
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

### 0. 引子

Kotlin 火了吗？也许吧。反正以前不知道它的，现在陆陆续续知道了；以前不敢用它的，现在也开始慢慢接受了；以前就热衷于它的，比如我这样的（说着摸了摸自己的脸，嗯，够大 T T）

![](/assets/2017.07.23/biglian.jpg)

还是一如既往的想着怎么让大家都用起来。

其实，5·18 的 Google IO 大会，只是给了大家一次发现 Kotlin 的机会；而到 Kotlin 的普及，需要一个过程，需要一个大家都接受它，喜欢它，恨它，又难以放弃它的这么个过程。

既然这样，我决定带着大家把 Kotlin Koans 过一遍，希望能带给大家一些更全局的视角。

### 1. 什么是 Kotlin Koans

Koan，我们先来搞清楚这个词，这个词是佛教用语，英文解释如下：

> a paradoxical anecdote or riddle, used in Zen Buddhism to demonstrate the inadequacy of logical reasoning and to provoke enlightenment.

好家伙，俨然一副只可意会不可言传的感觉。我曾经用过一个叫做 Rosetta Stone 的软件学外语，这个软件讲究的就是沉浸式的学习，给你一种让你学习母语那样的氛围让你学习。其实这里也比较类似，Kotlin Koans 就是一个沉浸式学习 Kotlin 的平台，它不见得会告诉你很细节的语法，但会让你自己身临其境地接触和理解它。[Kotlin 中文官网](https://kotlincn.net) 把它翻译成 Kotlin 心印，非常传神。

>如果去查词典，你还会查到 Koan 这个词实际上来自 “公案” 这两个字，但也许因为历史的原因，读音取的是日语读音：こあん；而禅（Zen）在英文中也直接采用了日语读音：ぜん。关于这个，我不想说太多，就是想简单提一下阿拉伯数字名字的来历。

### 2. 如果使用 Kotlin Koans

Kotlin Koans 有两种办法可以使用到，一种直接在 http://try.kotl.in 上面在线使用，另一种则是通过在 IntelliJ 上安装 **Edu Kotlin** 这个插件来在本地使用。

我比较推荐本地使用的方式。所以读到这里请大家毫不犹豫的去安装插件，安装完成之后就可以直接创建 Kotlin Koans 的工程啦。

![](/assets/2017.07.23/install-edu-kotlin.png)

### 3. 千里之行，始于 Hello World

Hello World 的题目是啥呢？给函数返回一个字符串叫做 "OK"，这个题目怎么不按套路出牌呢？难道不应该返回 HelloWorld 吗？！好吧，答案就是这么简单。

```kotlin
fun start(): String = "OK"
```

写完了别忘了点右面的按钮 check 一下，这样就显示你通过了这一关。

![](/assets/2017.07.23/check-solution.png)

### 4. 从来没有什么简单的 Hello World

这题一点儿都不按套路出牌，难道不应该是 `println("HelloWorld")` 吗？老师都是这么教的啊。

这题涉及到了函数的定义，你认识了关键字 `fun`，还看到了函数的表达式形式，仔细想想，Java 风格的函数写法是不是下面这样：

```kotlin
fun start(): String{
    return "OK"
}
```

还有，既然是表达式形式，我们还可以利用 Kotlin 的自动推导，去掉返回值的类型，显然 "OK" 这个字符串足以说明它的类型就是 String 了。

```kotlin
fun start() = "OK"
```

*前面给出的这两个版本也是正确答案。*

总结一下，这道题目涉及到了函数的定义和字符串的知识，稍不留神就也可以涉及下类型推导的知识。


### 5. 本期问题

那么，下面我们要做点儿有意思的事儿了。大家想想 Kotlin Koans 是怎么检查答案的？调用 `start()` 检查返回值是不是 `OK`，对吧？那么是不是说，这题目还有别的解法？

答案呢，我这里有几个，下期揭晓啦！另外也请大家踊跃给出自己的答案吧！


---

关注公众号 Kotlin ，获取最新的 Kotlin 动态。

![](/arts/Kotlin.jpg)