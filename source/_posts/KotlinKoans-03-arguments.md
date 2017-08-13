---
title: "解毒 Kotlin Koans: 03 函数参数、重载"
category: 编程语言
author: bennyhuo
reward: false
date: 2017-08-06 21:13:35
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

### 0. 上期回顾

上期我们留下了两个问题，下面给出答案：

1. 请大家阅读 [Kotlin 泛型](https://blog.kotliner.cn/2017/06/26/kotlin-generics/)，并且给出第 3 节中提到的 `BaseView` 和 `BasePresenter` 的 Kotlin 的正确写法。
	
	```kotlin
	interface IMvpView<out Presenter : IPresenter<IMvpView<Presenter>>> : ILifecycle {
	    val presenter: Presenter
	}
	
	interface IPresenter<out View : IMvpView<IPresenter<View>>> : ILifecycle {
	    var view: @UnsafeVariance View
	}
	```
	首先请大家关注泛型参数的协变，思考下为什么这么写，另外需要说明的是，VP 的绑定关系是可以通过运行时反射获取泛型参数来实现的，也就是说，View 实例化的时候同时实例化 Presenter，并初始化 Presenter 的 `view` 这个字段，所以需要外部可以修改这个属性，但可写的要求与协变冲突，所以需要加上 `@UnsafeVariance` 来跳过编译器的检查。

2. 请大家为 `String` 添加扩展方法， 实现 "abc" - "bc" -> "a"
	
	这个比较简单，我们只需要为 `String` 添加一个扩展方法 `minus` 即可，而恰好这个 `minus` 又是一个运算符，所以也可以用 `-` 来代替啦：
	
	```kotlin
	operator fun String.minus(right: String): String{
	    return replace(right, "")
	}
	```

### 1. 本期题目

老规矩，我们看看今天涉及的 Kotlin Koans 的题目是什么：

* Named arguments
* Default arguments

非常棒，这两个题目我都不喜欢。本期结束啦，大家洗洗睡吧，谢谢。。。

哦，不，不能这样，据说最近各方大佬们都已经开始不怎么关注 Kotlin 了，原因嘛，估计也是工（wu）作（li）太（ke）忙（tu）吧，所以我要挺住。。。

![](/assets/2017.08.06/tingzhu.jpg)

这两个东西一个叫具名参数，一个叫默认参数，默认参数很好理解，如果你不选套餐，那么我们就给你一个默认的汉堡薯条加可乐的意思；具名参数呢，就是传参的时候你可以明确告诉函数你传入的某一个参数是给谁的：皑？小明！那本书是韩梅梅给李雷的，你不要乱动！

![](/assets/2017.08.06/lilei&hanmeimei.jpg)

其实对具名参数的支持可以让默认参数的技能范围增强，而不是缩在参数列表最后的一个或者几个参数范围之内；具名参数还有的好处自然就是可读性强，大老远就能看见那是李雷而不是韩梅梅。

#### 1.1 具名参数

下面请听第一题：具名参数的题目，说啊，有贼样一个序列

```kotlin
val list = arrayOf("a", "b", "c")
```

现在我们要让他们拼出 "[a, b, c]" 酱婶儿的一个结果，怎么办呢？

```kotlin
fun joinOptions(options: Collection<String>)
    = options.joinToString(", ", "[", "]")
```

毫不犹豫的写完了，答案也通过了，可问题是跟具名参数有几毛钱关系呢？五毛？显然这里具名参数不是必须的，尽管写上之后会让代码看上去更清晰。

```kotlin
fun joinOptions(options: Collection<String>)
    = options.joinToString(separator = ", ", prefix = "[", postfix = "]")
```

#### 1.2 默认参数

具名参数除了提升代码可读性之外，还可以为默认参数打辅助。我们再来看看默认参数的题目：

参照下面的 Java 代码：

```java
public String foo(String name, int number, boolean toUpperCase) {
	return (toUpperCase ? name.toUpperCase() : name) + number;
}
public String foo(String name, int number) {
	return foo(name, number, false);
}
public String foo(String name, boolean toUpperCase) {
	return foo(name, 42, toUpperCase);
}
public String foo(String name) {
	return foo(name, 42);
}
```

改写下面的 Kotlin 的版本：

```kotlin
fun foo(name: String, number: Int, toUpperCase: Boolean) =
        (if (toUpperCase) name.toUpperCase() else name) + number
```

最直接的办法就是依葫芦画瓢，照着 Java 代码重载几个 `foo` 完事儿，如果真这么干了的话，也是可以通过的：

```kotlin
fun foo(name: String, number: Int, toUpperCase: Boolean): String {
    return (if (toUpperCase) name.toUpperCase() else name) + number
}

fun foo(name: String, number: Int): String {
    return foo(name, number, false)
}

fun foo(name: String, toUpperCase: Boolean): String {
    return foo(name, 42, toUpperCase)
}

fun foo(name: String): String {
    return foo(name, 42)
}
```

不过，请记住，这是道默认参数的题目，所以答案自然应该是：

```kotlin
fun foo(name: String, number: Int = 42, toUpperCase: Boolean = false) =
        (if (toUpperCase) name.toUpperCase() else name) + number
```

默认参数的版本显然要简单的多，在 Kotlin 当中，这个默认参数的版本用起来与 Java 中的函数重载相比，简直有过之而无不及。

### 2. 具名参数与默认参数的关系

下面来讲讲这两者中间的“基情”。

现在，我想要调用 `foo` 这个函数，`number` 默认 `42`，而 `toUpperCase` 这个参数需要传入 `true`，咋办？

```kotlin
foo("benny", true) // 错误！！
```

这样可以吗？当然不可以！你怎么能够跳过中间的 `number` 直接传参数给后面的参数呢？你知不知道这样编译器会无法忍受你的任性！

如果没有具名参数的支持，这也许就是一个悲伤的故事，当然，那是如果嘛。

```kotlin
foo("benny", toUpperCase = true) //正确！
```

### 3. 默认参数与函数（方法）重载的关系

从题目来看，我们是用默认参数替代了 Java 当中的方法重载的实现。所以这二者一定有关系，什么关系？

我们先来看看什么样的方法应该拿去重载，举一个例子：

**List.java**

```java
E remove(int index);
boolean remove(Object o);
```

方法名相同，参数列表不同，是重载没错。这二者从功能上也类似，一个是移除 List 中第 index 个元素，另一个则是移除 List 中指定的元素 o，都是移除。不过，非常遗憾，这是一个非常失败的重载，不信你看：

```java
List<Integer> ints = new ArrayList<>();
ints.add(5);
ints.add(1);
ints.add(3);
...

ints.remove(5);
ints.remove(0);
```

你知道这是在移除元素 5 呢还是在移除第 5 个元素呢？不知道，编译器当然有自己的套路，这种情况下，两个方法只有一个会生效，除非用反射去调用，不然的话永远调用不到另一个。

![](/assets/2017.08.06/liulei.jpg)

所以这个重载从效用上来说是失败的，这也正印证了其设计的失败：能够重载的方法不应该只是有逻辑关系。

那能重载的方法应该有什么关系？能够转换为默认参数的写法。

仔细想想，一个类有多个构造方法重载，正确的写法是怎样的？

**RelativeLayout.java**

```java
public RelativeLayout(Context context) {
    this(context, null);
}

public RelativeLayout(Context context, AttributeSet attrs) {
    this(context, attrs, 0);
}

public RelativeLayout(Context context, AttributeSet attrs, int defStyleAttr) {
    this(context, attrs, defStyleAttr, 0);
}

public RelativeLayout(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
    super(context, attrs, defStyleAttr, defStyleRes);
    ...
}
```

这段代码如果用 Kotlin 实现是不是可以写成默认参数的写法？

```kotlin
class RelativeLayout(context: Context,
	attrs: AttributeSet? = null, 
	defStyleAttr: Int = 0, 
	defStyleRes: Int = 0)
	:ViewGroup(context, attrs, defStyleAttr, defStyleRes){
    ...
}
```

### 4. Java 视角看 Kotlin 的默认参数

Java 中是没有默认参数的，那么在 Java 中要怎样调用 Kotlin 中使用了默认参数定义的函数或者方法呢？

通过字节码，我们其实可以看到 `foo` 这个方法编译完了之后除了本体之外会合成一个方法区构造默认参数：

```java
public static String foo$default(String var0, int var1, boolean var2, 
	int var3, Object var4) {
  if((var3 & 2) != 0) {
     var1 = 42;
  }

  if((var3 & 4) != 0) {
     var2 = false;
  }

  return foo(var0, var1, var2);
}
```

前三个参数就是 `foo` 本体需要的参数，默认参数通过 `var3` 的值来控制，最后一个参数看上去没什么用。例如：

```kotlin
foo("a")
```

编译后的效果就是这样：

```java
foo$default("a", 0, false, 6, (Object)null)
```

那么回到我们的问题，我在 Java 中要怎么享受 Kotlin 默认参数带来的便利呢？

```kotlin
@JvmOverloads 
fun foo(name: String, number: Int = 42, toUpperCase: Boolean = false) =
        (if (toUpperCase) name.toUpperCase() else name) + number
```

使用 `@JvmOverloads` 编译之后，会多生成两个方法，反编译成 Java 之后就是下面这样：

```java
public static final String foo(@NotNull String name, int number) {
  return foo$default(name, number, false, 4, (Object)null);
}

public static final String foo(@NotNull String name) {
  return foo$default(name, 0, false, 6, (Object)null);
}
```

这样我们在 Java 中也能愉快的和 Kotlin 默认参数玩耍了~

### 5. @JvmOverloads 的局限

`@JvmOverloads` 并不是对所有默认参数的情形都适用的，例如前面的 `foo`，对于 `number` 适用默认值，只传入 `toUpperCase` 和 `name` 的情形，Kotlin 可以用具名参数做到，Java 中就没有办法享受到了。

看下面的例子：

```kotlin
@JvmOverloads
fun bar(a: Int = 0, b: String = "", c: Boolean = false){
	...
}
```

生成的重载有多少个版本呢？

```java
public static final void bar(int a, @NotNull String b) {...}

public static final void bar(int a) {...}

public static final void bar() {...}
```
只有三个版本，很容易发现，对于 Kotlin 中需要具名参数才可以完成的调用情形，Java 中就没有对应的重载版本了。

### 6. 父类多个构造器的继承问题

继承一个 Java 类，这个类的各个构造器不可用默认参数来代替（不然我们就用 `@JvmOverloads` 好了），例如继承 `ArrayList`，它的构造器有以下几个版本：

```java
public ArrayList()
public ArrayList(Collection<? extends E> c) 
public ArrayList(int initialCapacity) 
```
这几个版本没的构造器没办法用默认参数的形式合并，我们在 Kotlin 当中继承他时，主构造器只能调用一个父构造器：
	
```kotlin
class MyArrayList<T>(): ArrayList<T>(){
	...
} 
```
	
那么问题来了，我如果想在 Kotlin 当中写出下面的代码：
	
```kotlin
val myIntList = MyArrayList<Int>(alistOfInt)
val myStringList = MyArrayList<String>(5) 
```
	
以此来构造两个 `MyArrayList`，怎么做到？

Kotlin 类如果有主构造器，那么其他构造器必须调用主构造器，但如果没有主构造器，就不需要这么费事儿了。所以我们继承的时候完全可以这么写：

```kotlin
class MyArrayList<T>: ArrayList<T>{
    constructor(): super()
    constructor(initialCapacity: Int) : super(initialCapacity)
    constructor(c: MutableCollection<out T>?) : super(c)
}
```

### 7. 本期问题

又到了本期的问题时间，结合本文对默认参数和方法重载的讨论，以及前面给出的 `RelativeLayout` 的例子，思考下面问题：

在有主构造器的前提下，Kotlin 为什么要求一个类的所有构造器都最终要调用自己的主构造器，显然这样做也会导致只有主构造器才可以调用父构造器？

补充说明：在早期的版本当中，Kotlin 是不允许没有主构造器的，尽管不添加主构造器的写法现在也是允许的，但这种做法显然也是不被推荐的。

![](/assets/2017.08.06/xiaohuangren.jpg)

---

关注公众号 Kotlin ，获取最新的 Kotlin 动态。

![](/arts/Kotlin.jpg)