---
title: "解毒 Kotlin Koans: 02 震惊！你的 Java 代码居然被转换成了这样..."
category: 编程语言
author: bennyhuo
reward: false
date: 2017-07-30 17:59:06
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

### 0. 上期回顾

传送门：[解毒 Kotlin Koans: 01 Introduction/HelloWorld](https://blog.kotliner.cn/2017/07/23/KotlinKoans-01-Introduction-HelloWorld/)

上回书我们说道，一个简单的 HelloWorld 背后也可以隐藏着众多不可告人的秘密。那么这些秘密究竟是什么呢？

那就是，只要我们写的代码可以支持下面的代码运行，并返回 "OK"，那么这事儿就成啦：

```kotlin
start()
```

既然这样，我们除了可以有上一回提到的两种普通解法之外，还应该有以下几种高端解法：

1. 默认参数法：

	```kotlin
	fun start(str: String = "OK") = str
	```

2. Lambda 表达式/匿名函数法
	
	```kotlin
	val start = { "OK" }
	```


3. 运算符重载法

	```kotlin
	object start{
        operator fun invoke() = "OK"
	}
	```

你还想到什么有趣的解法了么？

### 1. 转换 Java 为 Kotlin

大家学习 Kotlin，一定知道有个神奇叫做 "Convert Java File to Kotlin File"，不仅如此，如果你复制一段 Java 代码到 Kotlin 文件中，这段代码也会自动转换成 Kotlin 代码。

有很多时候如果你不知道某种东西怎么用 Kotlin 表达，怎么办呢？你总不能说：小二，给洒家来一本牛津大辞典吧？还好有 J2K 转换工具，这些问题有时候只要你会 Java，你就可以丧心病狂的转换出 Kotlin 代码。

我们今天按照 Kotlin Koan 给出的顺序，要解毒的就是下面这道题：

* 把下面这段 Java 代码转换为 Kotlin 代码：

	```java
	public class JavaCode {
	    public String toJSON(Collection<Integer> collection) {
	        StringBuilder sb = new StringBuilder();
	        sb.append("[");
	        Iterator<Integer> iterator = collection.iterator();
	        while (iterator.hasNext()) {
	            Integer element = iterator.next();
	            sb.append(element);
	            if (iterator.hasNext()) {
	                sb.append(", ");
	            }
	        }
	        sb.append("]");
	        return sb.toString();
	    }
	}
	```

嗯，老夫想了想，这有何难，复制粘贴谁不会，真是的。

![](/assets/2017.07.30/convert-code.gif)

从此以后，我就成了 Kotlin 大神，反正只要用工具把 Java 代码转一下就好啦，还学什么学 >.<!

### 2. 什么玩意，空指针啊

后来我就经常需要将原来用 Java 编写的 Activity 转换为 Kotlin 版本的，例如：

```java
public class TestActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ...       
    }
}
```

老板说了，从今天起，谁写 Java 就是跟他作对（请允许我 YY 一下 - -、），于是没有办法，我就得把它转成 Kotlin：

```kotlin
class TestActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle) {
        super.onCreate(savedInstanceState)
		...
    }
}
```

转的挺快啊，我还没反应过来，就转完了！不过这代码你要是敢运行一遍，Crash 就敢恶心你一遍。`savedInstanceState `  这个参数可能为 null，显然类型定为 `Bundle` 有些不合适。

对于平台类型（Platform Type），很多时候转换工具是无从得知它是否可能为空的，毕竟 Java 没有对此作出过任何承诺。

怎么办？Kotlin 提供了一对注解来标注 Java 类型是否可空：`@Nullable` 和 `@NotNull`，Android Support Annotations 这个包也提供了一对：`@Nullable` 和 `@NonNull`，我们用这些注解标注一下 Java 类型，那么再做转换，工具就会根据你做的标注来转换代码。

```java
@Override
protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    ...
}
```

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
	...
}
```

一句话，**用转换工具的时候一定要注意平台类型！**

### 3. Raw 类型惨叫一声...

尽管我们知道这转换工具没办法有效识别平台类型的问题，不过，对于下面的情况，它支持起来可能就更有些尴尬了：

```java
public class BaseView <T extends BasePresenter>{
    T presenter;
}

...

public class BasePresenter<T extends BaseView> {
    T view;
}
```

下面是转换后的结果：

```kotlin
class BaseView<T : BasePresenter<*>> {
   var presenter: T? = null
}

class BasePresenter<T : BaseView<*>> {
   var view: T? = null
}
```

看上去也没啥问题啊，为啥 IDE 就报错呢？因为我们要求 `BaseView` 当中的 `T` 类型是 `BasePresenter` 的子类，不过我们对这里的 `BasePresenter` 有个小小的要求，那就是它的泛型参数得是 `BaseView` 的子类而不是 `*`。对于 `BasePresenter` 也是一样的。

那么 Java 中为什么没有这样的问题呢？因为 Java 中有 Raw 类型，你可以不传任何泛型参数给 `BaseView` 就像我们在声明 `BasePresenter` 的时候那样。

显然，对于 Raw 类型的转换，转换工具会用 `*` 来代替，但这样的代码有时候可以，有时候却是行不通的。

**小心 Raw 类型！**

传送门：[Kotlin 泛型](https://blog.kotliner.cn/2017/06/26/kotlin-generics/)

### 4. Kotlin 风格的代码

吐槽转换工具就好比我们吐槽谷歌翻译一样：有时候不对，就像我们在 2、3 两节举的例子一样，

![](/assets/2017.07.30/lookingforah.png)

有时候呢，虽然不算错，但也实在是别扭...

![](/assets/2017.07.30/pullthecalf.png)

比如我们今天提到的 Koans 的这道题目，代码转换的结果虽然是对的，但这代码直接暴露了你不会 Kotlin 的事实。会写 Kotlin 的人家都这么写：

```kotlin
fun toJSON(collection: Collection<Int>): String = collection.joinToString(separator = ", ", prefix = "[", postfix = "]")
```

不就是拼接字符串么，还用得着亲自动手？祭出 `joinToString` 神器，可以解决你日常 80% 的拼接需求了。

可是 `Collection` 怎么会有这么个方法，在 Java 里面没见过呀！于是你不相信这眼前的一切，点进去看了一下源码，就发现了扩展方法这样的大杀器，从此你的 Kotlin 装备增加了 100 点物理伤害，以及 40% 的攻速。

```kotlin
public fun <T> Iterable<T>.joinToString(...): String {
    return joinTo(...).toString()
}
```

掌握扩展方法不需要太多的前置条件，只要你有过迫切的想法想给 `Date` 添加一个 `format` 的方法的冲动，那么你就能理解这个特性是用来做什么的。

```kotlin
fun Date.format(pattern: String): String {
    return SimpleDateFormat(pattern).format(this)
}

...

Date().format("yyyy-MM-dd HH:mm:ss")
```

### 5. 本期问题

1. 请大家阅读 [Kotlin 泛型](https://blog.kotliner.cn/2017/06/26/kotlin-generics/)，并且给出第 3 节中提到的 `BaseView` 和 `BasePresenter` 的 Kotlin 的正确写法。
2. 请大家为 `String` 添加扩展方法， 实现 "abc" - "bc" -> "a"
 
那么我们下周再见咯~

---

关注 Kotlin，就像关注每天吃啥一样~

![](/arts/Kotlin.jpg)