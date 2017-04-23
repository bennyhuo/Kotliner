---
title: 如何正确终止 forEach
category: 编程语言
reward: false
date: 2017-04-23 23:18:52
author: bennyhuo
tags: [Kotlin, Lambda, Stream Api]
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---
## 问题背景

话说周六下午团建回来，看到群里的小伙伴们在纠结一个问题，如何退出 forEach 循环，或者说有没有终止 forEach 循环的方法，就像 break 那样。我们来看个例子：

```kotlin
val list = listOf(1,3,4,5,6,7,9)
for(e in list){
    if(e > 3) break
    println(e)
}
```

如果 e 大于 3，那么循环终止，这是传统的写法，那么问题来了，我们现在追求更现代化的写法，要把代码改成 forEach 的函数调用，那么我们会怎么写呢？

```kotlin
list.forEach {
    if(it > 3) ???
    println(it)
}
```

就像上面这样吗？感觉应该是这样，不过大于 3 的时候，究竟该怎么办才能退出这个循环呢？

## return 还是 return@forEach ？

作为基本上等价于匿名函数的 Lambda 表达式，我们可能希望它能够提前返回，这样是不是就相当于终止循环了呢？

```kotlin
fun main(args: Array<String>) {
    val list = listOf(1,3,4,5,6,7,9)
    list.forEach {
        if(it > 3) return
        println(it)
    }
}
```

这时候我们毫不犹豫的写下了这样的代码，大于 3 的时候，直接 return，结果呢？运行到 4 的时候，forEach 就真的被终止了，后面也就没有了输出。

嗯，这样是不是就算把问题解决啦？想想也不可能呀，不然我这周的文章岂不是太坑人了？

```kotlin
fun main(args: Array<String>) {
    val list = listOf(1,3,4,5,6,7,9)
    list.forEach {
        if(it > 3) return
        println(it)
    }
    println("Hello")
}
```

当我们把代码改成这样的时候，我们运行时发现只输出 1 3，后面的 Hello 则是无法打印的。原因呢，当然也很简单，在 return 眼里，Lambda 表达式都不算事儿，所以我们在大于 3 时的 return，实际上是返回了 main 函数，于是 list.forEach 这个结构之后的代码就不能被执行了。

好吧，那这里用 return 肯定是有问题的，我们不用它了行了吧。那不用 return 用什么呢？好在 Kotlin 为我们提供了标签式的返回方法，也就是说，如果你想从一个 Lambda 表达式当中显式地返回，那么你只需要写 return@xxx 即可，例如：

```kotlin
fun main(args: Array<String>) {
    val list = listOf(1,3,4,5,6,7,9)
    list.forEach {
        if(it > 3) return@forEach
        println(it)
    }
    println("Hello")
}
```

你也可以给这个 Lambda 表达式起个新标签名称，比如 block：

```kotlin
fun main(args: Array<String>) {
    val list = listOf(1,3,4,5,6,7,9)
    list.forEach block@{
        if(it > 3) return@block
        println(it)
    }
    println("Hello")
}
```

这样，我们的程序运行结果就是：

```
1
3
Hello
```

这一步大家都会想到的，不过这并不是最终的解。

## 调用还是循环？

我来问大家一个问题，前面的 forEach 后面传入的 Lambda 表达式体是循环体吗？

当然不是。那其实就是一个函数体，因此对这个函数体的退出只能退出当前的调用。为了说明这个问题，我们还是需要对原有的例子做下小修改：

```kotlin
fun main(args: Array<String>) {
    val list = listOf(1,3,4,5,6,7,9)
    list.forEach block@{
        println("it=$it")
        if(it > 3) return@block
        println(it)
    }
    println("Hello")
}
```

结果呢？

```kotlin
it=1
1
it=3
3
it=4
it=5
it=6
it=7
it=9
Hello
```

好家伙，尽管我们在大于 3 的时候 return@block，但看上去仍然没有什么软用，显然，后面的循环仍然执行了。

简单总结一下，在 Lambda 表达式中，return 返回的是所在函数，return@xxx 返回的是 xxx 标签对应的代码块。由于 forEach 后面的这个 Lambda 实际上被调用了多次，因此我们没有办法像 for 循环那样直接 break 。

额。。这可如何是好？

## 流式数据处理

实际上我们在 Kotlin 当中用到的 forEach、map、flatMap 等等这样的高阶函数调用，都是流式数据处理的典型例子，我们也看到不甘落后却又跟不上节奏的 Java 在 8.0 推出了 stream Api，其实也无非就是为流式数据处理提供了方便。

采用流式 api 处理数据，我们就不能再像以前那样思考问题啦，以前的思维方式多单薄呀，只要是遍历，那就是 for 循环，只要是条件那就是 if...else，殊不知世界在变，api 也在变，你不跟着变，那你就请便啦。

那么，回到我们最开始的问题，需求其实很明确，遇到某一个大于 3 的数，我们就终止遍历，这样的代码用流式 api 写出来应该是这样的：

```kotlin
val list = listOf(1,3,4,5,6,7,9)
list.takeWhile { it <= 3 }.forEach(::println)
println("Hello")
```

我们首先通过 takeWhile 来筛选出前面连续不大于 3 的元素，也就是说一旦遇到一个大于 3 的元素我们就丢弃从这个开始所有后面的元素；接着，我们把取到的这些不大于 3 的元素通过 forEach 打印出来，这样的话，程序的效果与文章最开头的 for 循环 break 的实现就完全一致了。

```kotlin
val list = listOf(1,3,4,5,6,7,9)
for(e in list){
    if(e > 3) break
    println(e)
}
```

当然，你可能会说如果我想要打印其中的偶数，那我该怎么写呢？这时候我告诉大家，如果你写出了下面这样的代码，那么我只能告诉你，。。额，我刚想说啥来着？？

```kotlin
list.forEach { 
    if(it % 2 == 0){
        println(it)
    }
}
```

上面这样写的代码呢，让我想起了辫帅张勋：张将军，你知不知道，咱大清已经亡了呢？

```kotlin
list.filter { it % 2 == 0 }.forEach(::println)
```

哈哈，如果真的希望使用流式 api，那么上面这样的写法才算是符合风格的写法。当然了，如果你愿意，你还可以定义一个 isEven 的方法，代码写出来就像下面这样：

```kotlin
fun Int.isEven() = this % 2 == 0

fun main(args: Array<String>) {
    val list = listOf(1,3,4,5,6,7,9)
    list.filter(Int::isEven).forEach(::println)
}
```

## 性能

前不久看到有一篇文章对 Java 8 的流式 api 做了评测，说流式 api 的执行效率比传统的 for-loop 差出一倍甚至更多，所以建议大家慎重考虑选择。

其实对于这个东西我认为我们没必要把神经绷这么紧。原因也很简单呀，流式 api 的执行效率从实现上来讲，确实很难达到纯 for-loop 那样的高效，例如我们前面的：

```kotlin
list.filter(Int::isEvent).forEach(::println)
```

在 filter 的时候就调用了一次完整的 for-loop，而后面的 forEach 同样再来一遍，也就是说我们用传统的 for-loop 一遍搞定的事儿，用流式 api 写了两遍，如果条件比较复杂，出现两遍三遍的情况也是比较正常的。

不过这并不能说明流式 api 就一定要慎重使用。流式 api 更适用于数据的流式处理，特别是涉及到较多 UI 交互的场景，这样的业务逻辑用流式 api 表达起来会非常的简洁直观，也易于维护，相应的，这样的场景对于性能的要求并没有到吹毛求疵的地步；而对于性能比较敏感的程序，通常来说也没有很复杂的业务逻辑，流式 api 在这里也难以发挥作用。

另外，仅仅多个几次循环也并不会改变算法本身的运算效率的数量级，所以对于适用于流式 api 的场景，大家还是可以放心去使用的。

--

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，或者加 QQ 群：162452394 联系我们。

![](/arts/kotlin_group.jpg)