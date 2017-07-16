---
title: 用 Map 为你的属性做代理
category: 编程语言
author: bennyhuo
reward: false
date: 2017-07-16 21:07:48
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

>微信公众号 Kotlin 是去年 10 月底开的，到现在，每周最少一篇文章的节奏，把我能想到的的一些关于 Kotlin 的好玩的东西都记录下来告诉大家，结果，我发现一个严重的问题：题目越来越难找了。所以如果大家有好的题目或者想了解的方向、知识点之类的，可以通过公众号直接发给我，只要是历史文章里没有涉及的，我尽量在后面形成文字推送给大家~

### 1. 引子

话说，Kotlin 里面有两个语法用到了 `by` 这个关键字，一个是接口代理，一个是属性代理（不知道这俩东西是神马的，去 [https://kotlincn.net](https://kotlincn.net) 查官方文档）。你应该知道属性代理其实本质上就是用一个对象接管属性的 get/set 操作，这个东西可以用来实现一些 Observable 相关的操作，也可以用来封装简化一些复杂的读写操作，总之是一款非常好用却有点儿容易让人懵逼的特性。

下面我们看个例子：

```kotlin
inline fun <reified R, T> R.pref(default: T) = Preference(AppContext, default, R::class.jvmName)

object Settings {
    var lastPage by pref(0)
}
```

前面的这段小代码其实是基于 `Preference` 这个类（完整代码见后面的附录）做出的扩展，它能实现什么效果呢？`lastPage` 尽管看上去就是一个很普通的属性，不过如果我们对它进行写操作，那么值会被直接存入 `SharedPreference` 当中，读操作也会从 `SharedPreference` 当中读取。

不瞒各位说，Preference 这个类的源码来自于《Kotlin for Android Developers》这本书，我在初学 Kotlin 的时候一下子就被这个特性惊艳到了，有这样好用的扩展，请问你还有什么理由用 `sp.edit().putXXX().commit()` 呢？最要命的是，官方提供的 `SharedPreference` 的 api 在使用过程中，不仅难用，而且还经常因为丢掉 commit 而导致错误。

通过这个例子我们可以看出，属性代理这一特性很牛逼，不会的抓紧时间学，会的抓紧时间学着用，用了的抓紧时间出来吹牛逼啊！

### 2. 属性背后的 Map

如果大家用过 Python，大家就会知道，Python 类有个叫做 `__dict__` 的东西（好吧，我实在不知道该怎么称呼它），它以 key-value 的形式存储了一个 Python 对象当中的可写属性，key 就是这个属性的名字，value 就是这个属性的值。

这么看来，我们在访问一个类的属性的时候，实际上就是那属性名去从一个类似 `Map` 的数据结构中获取相应的值而已。不管各个语言在语法层面做了怎样的封装和简化，背后的实现机制大概也就是如此了。其实有时候如果能够用一个 `Map` 来 backup 一个类的属性，那会意见非常酷的事情，下面我们就给大家看一个例子。

在访问 GitHub 的 list 请求时，分页问题是一个不得不考虑的问题。GitHub 的 RESTful  Api 是如何做分页的呢？通过 Response 的 Header 中设置 link 来告诉客户端分页的情况，例如：

```
Link: <https://api.github.com/resource?page=2>; rel="next",
      <https://api.github.com/resource?page=5>; rel="last"
```

这表明当前页是第一页，下一页的地址和最后一页的地址都告诉我们了，后面可以按需请求。

关于 Link 的值，rel 的值有 next/last/first/prev 四种可能，如果我们写个类来解析这段文字，大概会写出下面的代码：

```kotlin
data class GitHubPaging(var first: String = "", 
		var last: String = "", 
		var next: String = "",
		var prev: String = "")
```

解析的时候怎么解析呢？

```kotlin
//假设 rels 就是解析 link 之后得到的数组
val paging = GitHubPaging()
rels.map{
	when(it.rel){
		"first" -> paging.first = it.url
		"last" -> paging.last = it.url
		"prev" -> paging.prev = it.url	
		"next" -> paging.next = it.url
	}
}
```

这里面有几个问题：

1. 如果 rel 的值有更多，那么我们的 when 表达式就要进一步变长了
2. GitHubPaging 这个类中的成员实际上都应该是不可变的，但由于我们在初始化过程中需要依次为其赋值，如果用 val 修饰其成员，那么我们只能在解析的时候先有中间变量暂存诸如 first/last 这样的值然后再实例化 GitHubPaging，就像这样：

	```kotlin
	data class GitHubPaging(val first: String, 
		val last: String, 
		val next: String,
		val prev: String)
	
	var first: String = ""
	var last: String = "" 
	var next: String = ""
	var prev: String = ""
	rels.map{
		when(it.rel){
			"first" -> first = it.url
			"last" -> last = it.url
			"prev" -> prev = it.url	
			"next" -> next = it.url
		}
	}
	
	val paging = GitHubPaging(first, last, next, prev)
	```


实际上如果我们用 Map 代理 GitHubPaging 这个类的属性，那么问题就要简单多了：

```kotlin
class GitHubPaging(link: String){
    companion object {
        const val URL_PATTERN = """(https?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]"""
    }

    val relMap = HashMap<String, String?>()

    val first by relMap
    val last by relMap
    val next by relMap
    val prev by relMap
    
    init{
        Regex("""<($URL_PATTERN)>; rel="(\w+)"""").findAll(link).asIterable().map {
            matchResult ->
            relMap[matchResult.groupValues[3]] = matchResult.groupValues[1]
        }
    }
}
```

我们用 `relMap` 来代理这几个属性，在初始化 `GitHubPaging` 的时候对 link 进行解析，那么问题就简单了，对于所有的 rel 的值，最终都会被存入 `relMap`，而我们在访问`GitHubPaging` 的属性的时候，其实是从 `relMap` 中取值，解析过程就这么愉快的结束了。

如果 rel 哪天又要增加或者修改，我们只需要在 `GitHubPaging` 中增加或修改相应的属性即可，解析的代码根本不需要改。而如果你想做一个更加通用的代码，还可以为 `GitHubPaging` 实现一个 `get` 运算符，获取相应的 url 就如同从 `Map` 中获取值那样简单：

```kotlin
class GitHubPaging(...){
	...
	operator fun get(key: String): String?{
	    return relMap[key]
	}
}

val paging = ...
val firstUrl = paging.first
val nextUrl = paging["next"]
```

### 3. Map 缘何可代理属性？

`Map` 可以代理属性，这个问题其实并不难想到答案。

一个对象想要能够代理属性，只需要根据被代理的属性的读写能力实现 `setValue/getValue` （如果是只读变量那么实现 `getValue` 即可），这样看来，`Map` 应该也是有这样的方法的。

`MutableMap` 自然是可以代理可读写的属性的，下面的扩展方法印证了这一点：

```kotlin
public inline operator fun <V> MutableMap<in String, in V>.getValue(thisRef: Any?, property: KProperty<*>): V
        = @Suppress("UNCHECKED_CAST") (getOrImplicitDefault(property.name) as V)

public inline operator fun <V> MutableMap<in String, in V>.setValue(thisRef: Any?, property: KProperty<*>, value: V) {
    this.put(property.name, value)
}
```

而非 `MutableMap` 呢，因为是不可修改的 `Map`（注意这一点，Kotlin 的 `Map` 尽管在 Jvm 上编译成了 `java.util.Map`，但在语言层面却没有修改的方法），所以只能代理只读变量了：

```kotlin
public inline operator fun <V, V1: V> Map<in String, @Exact V>.getValue(thisRef: Any?, property: KProperty<*>): V1
        = @Suppress("UNCHECKED_CAST") (getOrImplicitDefault(property.name) as V1)
```

你以为就简单贴一下源码就完事儿了？当然不，仔细看看 `MutableMap` 和 `Map` 的 `getValue` 有什么不同？

我在前面有篇讲泛型的文章：[Kotlin 泛型（修订版）](http://www.kotliner.cn/2017/06/26/kotlin-generics/) 提到过可变集合与不可变集合的型变，前者是不变的，而后者是协变的，所以 `Map` 的 `getValue` 版本的返回值可以是 `V` 的子类，而 `MutableMap` 的版本则不可以。

### 4. Map 中没有这个属性对应的 Key？

这种情况是会发生的。仔细看下我们在前面给出的 `GitHubPaging` 的例子，其中的任何一个属性在从 `relMap` 中取值时，都将会面临找不到值的情形。

有细心的朋友可能会看出来，我们定义 `relMap` 时，value 的类型为 `String?`，也就是说找不到的时候返回 `null` 不就可以了嘛。但事实呢？当然要问问 `getValue` 里面的那个函数咯：

```kotlin
internal fun <K, V> Map<K, V>.getOrImplicitDefault(key: K): V {
    if (this is MapWithDefault)
        return this.getOrImplicitDefault(key)

    return getOrElseNullable(key, { throw NoSuchElementException("Key $key is missing in the map.") })
}
```

这段代码很明显地告诉我们，如果没有这个 key，对不起，异常走你。不过，有一种情况例外，那就是，如果你的 `Map` 类型为 `MapWithDefault` —— 顾名思义，就是有默认值的 `Map`。

那么我们的 `Map` 会有默认值吗？如果你觉得有，那么我就像知道你哪儿来的自信保证`HashMap` 有默认值呢？

`HashMap` 确实没有默认值，那我定义一个 `MapWithDefault` 总可以了吧？

结果。。结果。。。。

```kotlin
private interface MapWithDefault<K, out V>: Map<K, V> {
	...
}
```

居然是 private！是不是想打人？打人也没用，异常走你~

其实这事儿也不难，我们顺藤摸瓜很容易就发现这么个函数：

```kotlin
public fun <K, V> MutableMap<K, V>.withDefault(defaultValue: (key: K) -> V): MutableMap<K, V> =
        when (this) {
            is MutableMapWithDefault -> this.map.withDefault(defaultValue)
            else -> MutableMapWithDefaultImpl(this, defaultValue)
        }
```

只需要在我们自己的 `HashMap` 后面加一句，就可以把它变成 `MapWithDefault`，哦也！

```kotlin
class GitHubPaging{
	val relMap = HashMap<String, String?>().withDefault { null }
	...    
}
```

这回如果找不到 key，那么就返回 null，妥妥的了。

### 附录

```kotlin
class Preference<T>(val context: Context, val name: String, val default: T, val prefName: String = "default") : ReadWriteProperty<Any?, T> {

    constructor(context: Context, default: T, prefName: String = "default"): this(context, "", default, prefName)

    val prefs by lazy { context.getSharedPreferences(prefName, Context.MODE_PRIVATE) }

    override fun getValue(thisRef: Any?, property: KProperty<*>): T {
        return findPreference(findProperName(property), default)
    }

    override fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        putPreference(findProperName(property), value)
    }

    private fun findProperName(property: KProperty<*>) = if(name.isEmpty()) property.name else name

    private fun <U> findPreference(name: String, default: U): U = with(prefs) {
        val res: Any = when (default) {
            is Long -> getLong(name, default)
            is String -> getString(name, default)
            is Int -> getInt(name, default)
            is Boolean -> getBoolean(name, default)
            is Float -> getFloat(name, default)
            else -> throw IllegalArgumentException("Unsupported type")
        }

        res as U
    }

    private fun <U> putPreference(name: String, value: U) = with(prefs.edit()) {
        when (value) {
            is Long -> putLong(name, value)
            is String -> putString(name, value)
            is Int -> putInt(name, value)
            is Boolean -> putBoolean(name, value)
            is Float -> putFloat(name, value)
            else -> throw IllegalArgumentException("Unsupported type")
        }.apply()
    }
}
```


---

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，或者加 QQ 群：162452394 联系我们。

![](/arts/kotlin_group.jpg)