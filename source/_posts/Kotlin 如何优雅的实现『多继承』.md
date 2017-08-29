
---
title: Kotlin 如何优雅的实现『多继承』
date: 2016-12-26 09:49:45
author: bennyhuo
tags: [接口代理, 多继承]
keywords:
categories: 编程语言
---
Hi，Kotliners，尽管视频完结了，不过每周一我还是会给大家推送一些 Kotlin 的有意思的话题，如果大家对视频有兴趣，直接点击阅读原文就可以找到~

[Kotlin 从入门到『放弃』视频教程](https://github.com/enbandari/Kotlin-Tutorials)

--

这一期给大家讲一个有意思的东西。我们都知道 Java 当年高调的调戏 C++ 的时候，除了最爱说的内存自动回收之外，还有一个著名的单继承，任何 Java 类都是 Object 的子类，任何 Java 类有且只有一个父类，不过，它们可以有多个接口，就像这样：

```java
public class Java extends Language implements JVMRunnable{
	...
}

public class Kotlin extends Language implements JVMRunnable, FERunnable{
	...
}

```

这样用起来真的比 C++ 要简单得多，不过有时候也会有些麻烦：Java 和 Kotlin 都可以运行在 JVM 上面，我们用一个接口 JVMRunnable 来标识它们的这一身份；现在我们假设这二者对于 JVMRunnable 接口的实现都是一样的，所以我们将会在 Java 和 Kotlin 当中写下两段重复的代码：

```java
public class Java extends Language implements JVMRunnable{
	public void runOnJVM(){
		...
	}
}

public class Kotlin extends Language implements JVMRunnable, FERunnable{
	public void runOnJVM(){
		...
	}
	public void runOnFE(){
		...
	}
}
```

重复代码使我们最不愿意看到的，所以我们决定创建一个 JVMLanguage 作为 Java 和 Kotlin 的父类，它提供默认的 runOnJVM 的实现。看上去挺不错。

```java
public abstract class JVMLanguage{
	public void runOnJVM(){
		...
	}
}

public class Java extends JVMLanguage{

}

public class Kotlin extends JVMLanguage implements FERunnable{
	public void runOnFE(){
		...
	}
}
```

当然，我们还知道 Kotlin 可以编译成 Js 运行，那我们硬生生的把 Kotlin 称作 JVMLanguage 就有些牵强了，而刚刚我们觉得很完美的写法呢，其实是不合适的。

简单的说，继承和实现接口的区别就是：继承描述的是这个类『是什么』的问题，而实现的接口则描述的是这个类『能做什么』的问题。

Kotlin 与 Java 在能够运行在 JVM 这个问题上是一致的，可 Java 却不能像 Kotlin 那样去运行在前端，Kotlin 和 Java 运行在 JVM 上这个点只能算作一种能力，而不能对其本质定性。

于是我们在 Java 8 当中看到了接口默认实现的 Feature，于是我们的代码可以改改了：

```java
public interface JVMRunnable{
	default void runOnJVM(){
		...
	}
}

public class Java extends Language implements JVMRunnable{

}

public class Kotlin extends Language implements JVMRunnable, FERunnable{
	public void runOnFE(){
		...
	}
}
```

这样很好，不过，由于接口无法保存状态，runOnJVM 这个方法的接口级默认实现仍然非常受限制。

那么 Kotlin 给我们带来什么呢？大家请看下面的代码：

```kotlin
abstract class Language

interface JVMRunnable{
    fun runOnJVM()
}

class DefaultJVMRunnable : JVMRunnable {
    override fun runOnJVM() {
        println("running on JVM!")
    }
}

class Java(jvmRunnable: JVMRunnable) : Language(), JVMRunnable by jvmRunnable
class Kotlin(jvmRunnable: JVMRunnable) : Language(), JVMRunnable by jvmRunnable, FERunnable{
	fun runOnFE(){
		...
	}
}
```
通过接口代理的方式，我们把 JVMRunnable 的具体实现代理给了 jvmRunnable 这个实例，这个实例当然是可以保存状态的，它一方面可以很好地解决我们前面提到的接口默认实现的问题，另一方面也能在提供能力的同时不影响原有类的『本质』。


![](http://kotlinblog-1251218094.costj.myqcloud.com/80f29e08-11ff-4c47-a6d1-6c4a4ae08ae8/arts/kotlin%E6%89%AB%E7%A0%81%E5%85%B3%E6%B3%A8.png)