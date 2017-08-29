---
title: T::class 和 this::class 的区别
category: 编程语言
author: bennyhuo
reward: false
date: 2017-08-19 07:01:03
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

# 0. 引子

前几天推送了一篇文章：[你绝对想不到 Kotlin 泛型给反射留下了怎样的坑！](https://blog.kotliner.cn/2017/08/14/kotlin-class-and-generics/)，受到一位朋友的评论的启发，这篇文章就承接前文，探讨一下 `T::class` 和 `this::class` 区别。

> 感谢这位朋友的支持！

# 1. 类继承的例子

我们先看个例子：

```kotlin
open class Person(val name: String, val age: Int)

class Coder(val language: String, age: Int, name: String): Person(name, age)

inline fun <reified T : Any> T.description()
        = T::class.memberProperties
        .map {
            "${it.name}: ${it.get(this@description)}"
        }
        .joinToString(separator = ";")
```
这实际上就是前面文章的例子，我将 `this::class.memberProperties` 改成了 `T::class.memberProperties`，同时，我为 `Person` 实现了一个子类 `Coder`，它多了一个 `language` 字段，表示它编写代码使用的程序语言。

测试程序如下：

```kotlin
fun main(args: Array<String>) {
    val person = Coder("kotlin", 30, "benny")
    println(person.description())
}
```

这时候输出的结果没有问题：

```
language: kotlin;age: 30;name: benny
```

那么稍微修改一下测试程序：

```kotlin
fun main(args: Array<String>) {
    val person: Person = Coder("java", 30, "benny")
    println(person.description())
}
```
这时候的结果呢？

```
age: 30;name: benny
```
本来这个 `discription` 方法是想要输出对象对应的属性，结果却按照 `Person` 进行了输出。有人可能会说你这不是搞事情吗，明明 `person` 这个变量的类型就是 `Coder`，干嘛非要用 `Person` 类型呢？这问题我想不需要回答吧。

# 2. 泛型参数的例子

其实问题是很清楚的，`this::class` 表示的是对象的类型，而 `T::class` 则取决于 `T` 被如何推断。具体用哪个，取决于你的需求。我们再给大家看个例子：

```kotlin
abstract class A<T>{
    val t: T = ...
}
```
`A` 有个属性是 `T` 类型的，而这个属性呢，需要在内部初始化。我们在定协议时要求类型 `T` 有默认构造方法，以便于我们通过反射实例化它。

我们知道 Kotlin 的泛型也是伪泛型，`T` 在这里不能直接用于获取其具体的类型，如果我们想要初始化 `t`，该怎么做呢？

```kotlin
abstract class A<T>{
    val t: T by lazy{
        (this@A::class
                .supertypes.first() // 类 A 的 KType 
                .arguments.first() // T 的泛型实参
                .type!!.classifier as KClass<*>)
                .primaryConstructor!!.call() as T
    }
}
```
首先我们拿到 `this@A::class`，这实际上并不是 `A::class`，这一点一定要注意，我们这段代码实际上是运行在子类实例化的过程中的，`this` 是一个子类类型的引用，指向子类实例。也正是因为这一点，我们想要获取泛型参数 `T` 的实参，还需要先拿到 super type 也就是 `A` 的 `KType` 实例了。

其次，获取泛型实参，并拿到实参类型的 `KClass` 实例。

最后，调用主构造器构造对象 `T`。

下面看下测试程序：

```kotlin
class B: A<C>() 

class C{
    override fun toString(): String {
        return "C()"
    }
}

fun main(args: Array<String>) {
    val b = B()
    println(b.t)
}
```

结果可想而知了。

```
C()
```

# 3. 衍生话题：编译期类型绑定

我们再回头看下第一个例子，它实际上还涉及到一个编译期类型绑定的问题。我们直接看例子：

```kotlin
open class Employee{
    fun raise(amount: Number){
        println("Got raise: $amount")
    }
}

class Manager: Employee(){
    fun raise(amount: BigDecimal){
        println("Got big raise: $amount")
    }
}

fun main(args: Array<String>) {
    val employee = Employee()
    employee.raise(BigDecimal(31))

    val managerA = Manager()
    managerA.raise(BigDecimal(31000))

    val managerB: Employee = Manager()
    managerB.raise(BigDecimal(31000000))
}
```
我们很容易就能想到结果：

```
Got raise: 31
Got big raise: 31000
Got raise: 31000000
```
这个结果似乎就好像，尽管 `managerB` 是 `Manager` 岗位，享受着经理的待遇，不过他还没有被正式任命，所以在系统中与普通员工是一样一样滴。

相比之下，Groovy 的结果可能会有些不一样：

```groovy
class Employee {
    void raise(Number amount) {
        println("Got raise: $amount")
    }
}

class Manager extends Employee {
    void raise(BigDecimal amount) {
        println("Got big raise: $amount")
    }
}

Employee employee = new Employee()
employee.raise(new BigDecimal(31))

Manager managerA = new Manager()
managerA.raise(new BigDecimal(31000))

Employee managerB = new Manager()
managerB.raise(new BigDecimal(31000000))
```
Groovy 是动态类型的语言，在运行时根据对象的类型确定调用的方法，这一点与 Kotlin 不一样：

```
Got raise: 31
Got big raise: 31000
Got big raise: 31000000
```
这里我还想要告诉大家的是，Java 跟 Kotlin 的结果是一样的。

>注：本例来自 **《Groovy 程序设计》3.6 多方法** 一节的讨论。

# 4. 小结

本文从 `this::class` 和 `T::class` 的异同出发，探讨了 `this::class` 的两种应用场景，并衍生出了编译期绑定的问题，上述讨论的结果也同样适用于 Java 中的 `this.getClass()` 以及 `T.class`。

---

关注公众号 Kotlin ，获取最新的 Kotlin 动态。

![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/Kotlin.jpg)

