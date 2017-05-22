---
layout: post
title: Kotlin 一个很厉害的 DSL 写法
category: Kotlin
tags: Kotlin
keywords: Kotlin
date: 2017-05-15 12:15:15
description: Kotlin DSL which su go i de su ne!
author: 千里冰封
reward: false
source_url: http://ice1000.org/2017/05/11/KotlinDSL2/
---

好久没写博客了，今天发几个最近在各个地方看到的一些碉堡了的 Kotlin DSL。本文先介绍一种 DSL 写法，再推荐几个 DSL 项目。

## 超厉害的 DSL

之前在 [KotlinTest](https://github.com/kotlintest/kotlintest) 上看到一个很牛逼的写法（我把 README 里的实例改了下）：

```kotlin
class StringSpecExample : StringSpec() {
  init {

    "should add" {
       forAll(table(
           headers("a", "b", "result"),
           row(1, 2, 3),
           row(1, 1, 2)
         )) { a, b, result ->
         a + b shouldBe result
       }
    }
  }
}
```

这其中涉及了好几个 DSL 要素。我一一列举：

### 字符串后面跟一个代码块

这个东西的原理你只要看了源码就知道了，很简单，但是你不看就是想不到（这也是我厨 Kotlin 的原因之一，它很简单，
但是可以玩出很多花样来）。

```kotlin
inline operator fun String.invoke(block: () -> Unit) {
}
```

就这样你可以利用这个 extension 写出字符串后面跟一个代码块的 DSL 。
此处使用的语言特性有：

0. extension （万 DSL 基于 extension）
0. 操作符重载
0. 最后一个参数是 Lambda ，不需要写调用的括号

明白了吧。

#### 使用

举个例子，把他作为一个 URL 的 utility ：

```kotlin
inline operator fun String.invoke(block: (URL) -> Unit) {
  block(URL(this))
}

"ice1000.org" { url ->
  File("download.html").run {
    if (!exists()) createNewFile()
    writeText(url.readText())
  }
}
```

### 表格字面量

就是形如

```kotlin
val a = listOf(
   listOf(-1, 0, 1),
       listOf(0, 1),
          listOf(1),
          listOf(1, 2),
          listOf(1, 2, 3),
          listOf(1, 2, 3, 4)
)
```

这样的东西（上面的代码纯粹搞起耍，请不要在意）。

这个就更简单了我觉得你们应该都知道：

```kotlin
fun <T> listOf(vararg vars: T) = LinkedList(vars.size).apply { addAll(*vars) }
```

无非就是变长参数。

## 形如 `"(+ 1 1)" shouldBe 2` 的测试

这个也很简单，我在小标题里写的就是我在 [lice](https://github.com/lice-lang/lice) 里使用的测试。

首先，假定我们有以下测试：

```kotlin
fun test() {
  assertEquals("ass we can", trie["key"])
}
```

我们希望写成：

```kotlin
fun test() {
  trie["key"] shouldBe "ass we can"
}
```

很简单，可以有：

```kotlin
infix inline fun <T> T?.shouldBe(expected: T?) = assertEquals(expected, this)
```

就是一个中缀表达式而已。这有什么难的？

#### 一些特定情况

我给我的 lice 写的测试中直接把运行字符串的那一步给包含进去了：

```kotlin
infix inline fun Sting.shouldBe(expected: T?) = assertEquals(expected, Lice.run(this))
```

看到没有，运行 lice 代码就是这么简单，还能返回最后一个表达式的值 （喂

## 注意事项

任何长得类似这样的 DSL 都有一个缺点，就是缩进膨胀（字面意思）。 Scala 为了解决这个问题，
推荐用户使用 `Tab size 2` 的缩进（喂。 于是我也建议读者使用 2 空格缩进。

## 几个厉害的 DSL 项目

根据推荐程度排序：

### Anko

[传送门](https://github.com/Kotlin/anko)，不说了，最强的 Kotlin DSL 框架，想必大家早已有所耳闻：

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
  super.onCreate(savedInstanceState)
  verticalLayout {
      padding = dip(30)
      editText {
        hint = "Name"
        textSize = 24f
      }
      editText {
        hint = "Password"
        textSize = 24f
      }
      button("Login") {
        textSize = 26f
      }
  }
}
```

厉害吧。这个框架是用于 Android 的，用于描述 UI 。有一点要说一下，现在的预览插件挂了。

弹窗：

```kotlin
alert("Hi, I'm Roy", "Have you tried turning it off and on again?") {
    yesButton { toast("Oh…") }
    noButton {}
}.show()
```

还有一些非 UI 的吊炸天的代码块，比如异步：

```kotlin
doAsync {
    // Long background task
    uiThread {
        result.text = "Done"
    }
}
```

### 两个基于 Swing 的 DSL

#### Gensokyo

[传送门](https://github.com/cqjjjzr/Gensokyo)，一个刚出来的项目，它长这样：

```kotlin
fun main(args: Array<String>) {
  systemLookAndFeel()
  frame (title = "Test", show = true) {
      size(500, 500)
      exitOnClose
    
      menuBar {
        subMenu("File") {
          item("Open") {
              listenAction {
                println("BOOM!"
              }
          }
          separator
          subMenu("Recent") {
              item("nanimo arimasen") {
                listenAction {
                  println("SHIT!")
                }
              }
          }
          separator
          item("Exit") {
              listenAction {
                println("NOPE! SHIT!")
                exitProcess(0)
              }
          }
        }
      }
    
      gridLayout {
        row {
          button("Hello!") {
              listenAction {
                println("click!")
                hide
              }
          }
          // gap
        }
        row {
          button("Another Hello!") {
              listenAction {
                println("another click!")
                hide
              }
          }
          // gap
        }
        row {
          container {
              gridLayout {
                row {
                  button("Oh Boy♂Next♂Door!") {
                      listenAction{
                        println("Ahh fuck you")
                        hide
                      }
                  }
                  button("change the boss of the gym!") {
                      listenActionWithEvent { source, _, _, _ ->
                        println("Ahh FA♂Q $source")
                        hide
                        this@frame.hide
                      }
                  }
                }
              }
          }
        }
      }
    }
}
```

Swing 其实没那么垃圾，只要配上 DSL ，啥 GUI 代码都变得好看了。

#### FriceEngine DSL

这是我之前弄的那个游戏引擎的 DSL 系统，[传送门](https://github.com/icela/FriceEngine-DSL)，它长这样：

```kotlin
fun main(args: Array<String>) {
  game {
    bounds(500, 500, 800, 750)
    showFPS = false

    whenExit {
      closeWindow()
    }

    whenUpdate {
      if (800.elapsed()) {
        rectangle {
          x = elapsed / 10.0
          y = elapsed / 10.0
          color = PINK
        }
      }
    }

    every(1000) {
      oval {
        x = elapsed / 10.0
        y = elapsed / 10.0
        color = ORANGE
      }
      log("1 second has past.")
    }

    rectangle {
      name("rectangle")
      x = 100.0
      y = 100.0
      width = 100.0
    }
    oval {
      x = 0.0
      y = 85.0
      accelerate {
        x = 10.0
      }
      whenColliding("rectangle") {
        stop()
        x -= 5
        accelerate {
          x = -2.0
          y = 10.0
        }
      }
    }
    image {
      file("C:/frice.png")
      x = 200.0
      y = 300.0
      velocity {
        x = -5.5
      }
    }
  }
}
```

我自己觉得做的还不错。我还为它搞了个中文版，比较粗鄙，用于讽刺中文编程，请前往同项目的 README 查看。

### 官方教程里的 HTML DSL

[传送门](https://github.com/Kotlin/kotlinx.html)，它长这样：

```kotlin
window.setInterval({
  val myDiv = document.create.div("panel") {
      p { 
        +"Here is "
        a("http://kotlinlang.org") { +"official Kotlin site" } 
      }
  }
  document.getElementById("container")?.let {
    it.appendChild(myDiv)
    it.append { div { +"added it" } }
  }
}, 1000L)
```

这代码也是我从 README 里面改过的，原文太瘦了，我改的胖一点。

官方给的例子，非常给力（当时也是看这个的源码搞懂了 anko 的原理）。

### JavaFX DSL

[传送门](https://github.com/edvin/tornadofx)，它长这样：

```kotlin
class MyView : View() {
  private val persons = FXCollections.observableArrayList(
        Person(1, "Samantha Stuart", LocalDate.of(1981, 12, 4)),
        Person(2, "Tom Marks", LocalDate.of(2001, 1, 23)),
        Person(3, "Stuart Gills", LocalDate.of(1989, 5, 23)),
        Person(3, "Nicole Williams", LocalDate.of(1998, 8, 11))
  )
  override val root = tableview(persons) {
      column("ID", Person::id)
      column("Name", Person::name)
      column("Birthday", Person::birthday)
      column("Age", Person::age)
      columnResizePolicy = SmartResize.POLICY
  }
}
```

我个人觉得很不错了已经。

嘛。祝大家玩 Kotlin 开心。


-----------------

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，并且加 QQ 群：162452394 联系我们。

![](/arts/kotlin_group.jpg)