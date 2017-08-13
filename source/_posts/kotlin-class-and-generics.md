---
title: 你绝对想不到 Kotlin 泛型给反射留下了怎样的坑！
category: 编程语言
author: bennyhuo
reward: false
date: 2017-08-14 08:21:41
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

前面我们已经发过一篇介绍 [Kotlin 泛型](https://blog.kotliner.cn/2017/06/26/kotlin-generics/)的文章了，相比大家对于泛型已经有了较为深刻的理解。这块儿内容的重点和难点是对于型变的理解，而我们今天就要给大家展示一段有坑的代码。本文需要你对泛型和反射有相对深入的了解，反正。。阅读过程中有任何不适，本人概不负责。。：）逃

## 1. 有坑自远方来。。

话说呀，我们有一个很简单的需求，就是为很多个类添加一个 `description` 方法，这个方法的返回值就是这个类的属性名以及值，例如下面这个类：

```kotlin
class Person(val name: String, val age: Int)
```

它的 `description` 方法的返回值应该是这样：

```
age: 30;name: Benny
```

这个东西很通用，于是我们决定用扩展方法加反射的方式来输出，于是：


```kotlin
inline fun <reified T : Any> T.description()
        = this::class.memberProperties
        .map {
            "${it.name}: ${it.get(this@description)}"
        }
        .joinToString(separator = ";")
```

看上去很美是吧，不过呢，这段代码是编译不过的！为什么？`it.get(this@description)` 这一句看上去很合理，`it` 是一个属性的反射引用，通过 `get` 传入调用者 `this` 来获取当前属性的值，很正常嘛，我们在 Java 中都是这么干的呀。然而，并没有什么用，这里就是报错。

## 2. 坑亦有理

那我们就来分析下吧，报错的原因也很简单，编译器说 `this@description` 的类型是 `Person`，而 `it.get` 需要的参数类型是 `out Person`，什么鬼，这里居然还有协变的事儿？？

本着息事宁人的态度，类型不匹配我强转下不就得啦:

```kotlin
it.get(this@description as out Person) // 错误的！！
```

可问题是你老人家仔细瞅瞅，协变类型强转的事儿，真是没听说过..

这就有意思了，我明明用的是 `Person` 的实例，怎么后面的属性的泛型参数是 `out Person`？我们看下下面的属性的反射引用类型的定义（也就是 `it` 的类型）：

```kotlin
public interface KProperty1<T, out R> : KProperty<R>, (T) -> R { 

	public fun get(receiver: T): R
	
	...
}
```
`T` 的类型从哪儿来的呢？当然是从获取反射引用的 `KClass` 对象来的，也就是 `this::class` 这个对象了，这个对象难道不应该是 `KClass<Person>` 吗？No，是 `KClass<out Person>`！看上去有点儿不可思议，不过仔细想想，这样是否有道理呢？

```kotlin
val person: Any = Person("Benny", 30)
```

对于这样的情况，`person::class` 如果返回的是 `KClass<Any>`，那么在后续的反射访问属性的操作中，我们将什么都得不到，毕竟 `Any` 什么属性都没有。可这不对呀，`person::class` 不应该拿到的是对象真实的类型吗？没错，为了照顾到这一点，又不让类型系统出错， Kotlin 选择将  `person::class` 的类型置为 `KClass<out Any>` 来解决问题。

其实 Java 也有类似的操作，请看文章：[Java中getClass方法的返回值类型](https://zhuanlan.zhihu.com/p/27012082?utm_source=qq&utm_medium=social)

`person::class` 相当于 Java 的 `person.getClass()`，尽管这个方法的签名是这样的：

```java
public final Class<?> getClass()
```
但这个返回值实际上是协变的：

```java
Class<? extends String> c = "".getClass();
```

不过 Java 毕竟与 Kotlin 不一样，它的反射传参要求非常简单，没有严格的类型限制，只要是 `Object` 就照单全收：

**Method.java**

```java
public Object get(Object obj) 
```

总结下，Java 和 Kotlin 对于 `person.getClass()` （Java 当中）或者 `person::class`（Kotlin 当中）的处理方式是一致的，返回值都是协变的，但对于反射来说，Java 对参数类型要求几乎没有，而 Kotlin 则非常严格，这样会导致的问题就是 Kotlin 的反射使用起来有些难受。

对于这一点，官方论坛中也有人提出了类似的质疑：[Kotlin and Reflection](https://discuss.kotlinlang.org/t/kotlin-and-reflection/1576)，说 Kotlin 怎么能酱紫搞呢，这么完美的代码居然给我报了个协变的错误，真是不可思议！

>Error:(18, 16) Kotlin: Out-projected type 'KMutableProperty1' prohibits the use of 'public abstract fun set(receiver: T, value: R): Unit defined in kotlin.reflect.KMutableProperty1'

反射嘛，本来就是黑科技，类型整那么复杂真的有必要吗？

## 3. 遇坑填坑

有坑不填，不是好码农啊。

前面抛出这么个大坑，说实在的，不给出解决方案我都不好意思写这篇文章。


### 3.1 类型强转方案

谁说类型强转不行了？谁说的？？既然 `get` 不好使，我们给他来个类似 Java 反射的版本，我们对参数类型不做任何限制：

```kotlin
fun <T, R> KProperty1<T, R>.getUnsafed(receiver: Any): R {
    return get(receiver as T)
}
```

那么我们的 `T.description` 扩展就可以稍作修改啦：

```kotlin
inline fun <reified T : Any> T.description()
        = this::class.memberProperties
        .map {
            "${it.name}: ${it.getUnsafed(this@description)}" //注意这里的修改
        }
        .joinToString(separator = ";")

```

没毛病。

### 3.2 Java 反射方案

Kotlin 反射不能用？不用还不行了么，打不起还躲不起吗，什么世道。。

```kotlin
inline fun <reified T : Any> T.description()
        = this.javaClass.declaredFields
        .map {
        	//注意我们访问的 Kotlin 属性对于 Java 来说是 private 的，getter 是 public 的
            it.isAccessible = true
            "${it.name}: ${it.get(this@description)}"
        }
        .joinToString(separator = ";")
```

### 3.3 我和我的小伙伴们都惊呆了的方案

这。。什么鬼。。

不知道大家怎么看这件事儿，kotlin 对象获取 `KClass` 实例的方法其实不止 `person::class` 这样一种，还有一种叫做：`this.javaClass.kotlin` ，这货的类型是 `KClass<Person>`，没有 out，repeat，没有 out ！

所以我们的代码还可以改成这样：

```kotlin
inline fun <reified T : Any> T.description()
        = this.javaClass.kotlin.memberProperties
        .map {
            "${it.name}: ${it.get(this@description)}"
        }
        .joinToString(separator = ";")
```

哇靠，Kotlin 官方的开发者，你们太不厚道了。。

我当时就惊呆了，还以为这两种获取 `KClass` 的方式有什么重大差别呢，结果跟了下源码，是的，`this::class` 这种写法在调试的时候也是可以强制跳入调用栈的（反编译看字节码也可以），二位居然都是调用了下面的方法来获取 `KClass` 实例的：

```java
public class Reflection {

    public static KClass getOrCreateKotlinClass(Class javaClass) {
        return factory.getOrCreateKotlinClass(javaClass);
    }

	...
}
```

嗯，人家哥们直接用了 Java 的 raw 类型，在 Kotlin 调用处做了一次类型强转，一个强转成了 `KClass<out Person>`，一个强转成了 `KClass<Person>` 。。。

我就问一句，你们这么搞，良心不痛吗？

## 4. 小结

这篇文章讲述了一个因 Kotlin 泛型类型严格导致某些情况下反射代码编译不通过的故事。这个故事呢，你说 Kotlin 事儿多也行，说它严谨也行，反正，解决方案咱都有，大不了，大不了我去天桥上贴膜。。什么破代码，不写了！

---

关注公众号 Kotlin ，获取最新的 Kotlin 动态。

![](/arts/Kotlin.jpg)