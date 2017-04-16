---
title: Kotlin Native 详细体验，你想要的都在这儿
category: 编程语言
reward: true
date: 2017-04-15 11:13:15
author: bennyhuo
tags: [Kotlin, Native]
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

>本文来自：www.kotliner.cn

**内容提要：本文通过 gradle 以及 makefile 两种方式对 Kotlin Native 项目进行构建，提供了详细的从 C 源码编译、到 Kotlin Native 项目的编译及运行的方法，以及该过程中遇到的问题和解决方案，涉及两处对编译器的修改也已经提交 pr。**

最近因为 [www.kotliner.cn](http://www.kotliner.cn/)上线的原因，一直没顾上对 Kotlin Native 进行体验，现在 Kotlin Native 预览版发布一周了，我来给大家较为详细地介绍一下它的一些相关内容。

## 1、Kotlin Native 是什么

Kotlin Native 不是 Jni 的概念，它不仅仅是要与底层代码比如 C、C++ 交互，而且还要绕过 Jvm 直接编译成机器码供系统运行。也就是说，Kotlin 准备丢掉 Java 这根拐杖了！

其实我第一次看到 Native 这个名字的时候很自然的想到了 Jni，Kotlin 跑在 Jvm 上面，使用 Jni 与底层代码交互是一件再正常不过的事情了，至于搞这么大动静么，不过等我进行了一番了解之后才发现，Kotlin 项目组的野心真是不小，Java 诞生这么多年了，也没有做过编译成除 Java 虚拟机字节码以外的字节码的事情，Kotlin 才出来多久啊，果然具有革命性。

所以以后有人再问你，什么是 Kotlin，你要回答，Kotlin 是一门很牛逼的静态语言（而不是之前经常说的 Kotlin 是一门运行在 Jvm、Android、FE 上的静态语言了），反正你能想到的，Kotlin 项目组都想干。。

## 2、如何编写 Kotlin Native 程序

现在 Kotlin Native 刚刚处在技术预览阶段，离商用目测还需要至少一年的时间（小小地激动一下，2018年会不会发布正式版呢），性能优化、标准库、反射等等功能现在尚处于早期的状态，所以大家也没必要强求。下面我给大家介绍下怎么编译出一个 HelloWorld 工程。

### 2.1 准备编译器

编译器目前有 Mac、Linux 两个版本，可以编出运行在 树莓派、iOS 以及 OS X 和 Linux 系统上的程序（Windows 真可怜。。），下面的演示运行在 Mac OS X 10.11.6 上，与 Linux 的小伙伴可能稍微一些差异。

编译器官方有现成可用的版本，下载地址如下：

* [Mac / iOS](http://download.jetbrains.com/kotlin/native/kotlin-native-macos-0.1.tar.gz)
* [Linux / 树莓派](http://download.jetbrains.com/kotlin/native/kotlin-native-linux-0.1.tar.gz)

不过呢，也建议小伙伴们直接 clone 编译器源码编译，没有复杂的编译步骤，两行命令即可搞定编译。

[Github: Kotlin Native](https://github.com/JetBrains/kotlin-native)

代码拖下来之后，保证网络畅通，运行：

``` bash
$ ./gradlew dependencies:update
```
这一步是下载依赖，官方源码使用了 gradle-wrapper，所以如果你本地没有 gradle 3.1 的话也会自动去下载。这一步就是下载下载下载，所以一定要注意，出错的话基本上就是网络问题。运行完成之后，你就会在 dist/dependencies 目录下面看到下载的各种依赖了。

![](/assets/2017.04.15/deps.png)

接着就可以编译了：

``` bash
./gradlew dist
```

编译时间不长，如果出现错误，可以 clean 多试几次。。编译完之后我们就可以得到编译器一份啦。

![](/assets/2017.04.15/compiler.png)

### 2.2 Gradle 版 HelloWorld

下面我们先在 IntelliJ 中创建一个普通的 Gradle 工程，创建好之后，修改 build.gradle 文件，改成下面这样：

``` groovy
buildscript {
    repositories {
        mavenCentral()
        maven {
            url  "https://dl.bintray.com/jetbrains/kotlin-native-dependencies"
        }
    }

    dependencies {
        classpath "org.jetbrains.kotlin:kotlin-native-gradle-plugin:0.1"
    }
}

apply plugin: 'konan'

konanInterop {
    kotliner {
        defFile 'kotliner.def' // interop 的配置文件
        includeDirs "src/c" // C 头文件目录，可以传入多个
        //pkg "cn.kotliner.native" // C 头文件编译后映射为 Kotlin 的包名，这个有问题，后面我们再说
    }
}

konanArtifacts {
    Kotliner {
        inputFiles fileTree("src/kotlin") //kotlin 代码配置，项目入口 main 需要定义在这里
        useInterop 'kotliner' //使用前面的 interop 配置
        nativeLibrary file('src/c/cn_kotliner.bc') //自己编译的 llvm 字节格式的依赖
        target 'macbook' // 编译的目标平台
    }
}
```

我们可以看到，konan 就是用来编译 Kotlin 为 native 代码的插件，konanArtifacts 配置我们的项目，konanInterop 主要用来配置 Kotlin 调用 C 的接口。有关插件的配置，可以参考官方文档：[GRADLE_PLUGIN](https://github.com/JetBrains/kotlin-native/blob/master/GRADLE_PLUGIN.md)。

配置好之后，我们还要创建一个 gradle.properties 文件，加入下面的配置：

```
# 配置编译器 home，要配置为 bin 目录的 parent
# 例如：konan.home=<你的 kotlin-native 源码路径>/kotlin-native/dist
konan.home=<你的编译器路径>
```
当然，这个配置可以不加，那样的话，你编译的时候会首先下载一个编译器放到你本地。

接着我们创建一个 kotliner.def 文件，用来配置 c 源码到 kotlin 的映射关系：

**kotliner.def**

```
headers=cn_kotliner.h
```

下面准备我们的源码，在工程目录下面创建 src 目录，在 src/c 目录下面创建下面的文件：

**src/c/cn_kotliner.h**

```c
#ifndef CN_KOTLINER_H
#define CN_KOTLINER_H

void printHello();

int factorial(int n);

#endif //CN_KOTLINER_H
```

**src/c/cn_kotliner.c**

```c
#include "cn_kotliner.h"
#include <stdio.h>

void printHello(){
    printf("[C]HelloWorld\n");
}

int factorial(int n){
    printf("[C]calc factorial: %d\n", n);
    if(n == 0) return 1;
    return n * factorial(n - 1);
}
```

我们定义了两个函数，一个用来打印 “HelloWorld”，一个用来计算阶乘。

接着在 src/c 目录下面，用命令行编译：

``` bash
clang -std=c99 -c cn_kotliner.c -o cn_kotliner.bc -emit-llvm
```

>如果提示找不到 clang 命令，可以去编译器的 dependencies 目录中找。

截止到现在，我们已经编译好 C 源码了。接着我们创建 kotlin 源码：

**src/kotlin/main.kt**

``` kotlin
import kotliner.*

fun main(args: Array<String>) {
    printHello()
    (1..5).map(::factorial).forEach(::println)
}
```

好了，这时候我们可以运行 gradle 的 build 任务了：

```
12:47:29: Executing external task 'build'...
:downloadKonanCompiler
:genKotlinerInteropStubs UP-TO-DATE
:compileKotlinerInteropStubs
JetFile: kotliner.kt
JetFile: kotliner.kt
:compileKonanKotliner
JetFile: main.kt
src/kotlin/main.kt:4:11: warning: inliner failed to obtain inline function declaration
src/kotlin/main.kt:4:28: warning: inliner failed to obtain inline function declaration
:build

BUILD SUCCESSFUL

Total time: 34.743 secs
12:48:04: External task execution finished 'build'.
```

编译完成之后，在 build/konan/Kotliner/bin 目录中会生成一个 kexe 文件，命令行运行它：

``` bash
$ ./Kotliner.kexe
[C]HelloWorld
[C]calc factorial: 1
[C]calc factorial: 0
[C]calc factorial: 2
[C]calc factorial: 1
[C]calc factorial: 0
[C]calc factorial: 3
[C]calc factorial: 2
[C]calc factorial: 1
[C]calc factorial: 0
[C]calc factorial: 4
[C]calc factorial: 3
[C]calc factorial: 2
[C]calc factorial: 1
[C]calc factorial: 0
[C]calc factorial: 5
[C]calc factorial: 4
[C]calc factorial: 3
[C]calc factorial: 2
[C]calc factorial: 1
[C]calc factorial: 0
1
2
6
24
120
```

好，我们的程序已经运行起来了，我们看到了 C 当中的 HelloWorld 输出以及阶乘求解的过程，大功告成。

当然，你还可以编写更多好玩的代码，编译的结果就是 Kotlin 再也不需要 Jvm 了，你说激动不激动？

### 2.3 命令行版 HelloWorld

除了 gradle 构建外，我们也可以直接使用命令行编译 Kotlin Native，具体步骤也比较类似，首先准备好源码，跟 2.2 中一致。

接着编写 Makefile 或者 build.sh，官方采用了 shell 脚本的方式来构建，那么我下面给出类似的 Makefile：

```makefile
build : src/kotlin/main.kt kotliner.kt.bc
	konanc src/kotlin/main.kt -library build/kotliner/kotliner.kt.bc -nativelibrary build/kotliner/cn_kotliner.bc -o build/kotliner/kotliner.kexe

kotliner.kt.bc : kotliner.bc kotliner.def
	cinterop -def ./kotliner.def -o build/kotliner/kotliner.kt.bc

kotliner.bc : src/c/cn_kotliner.c src/c/cn_kotliner.h
	mkdir -p build/kotliner
	clang -std=c99  -c src/c/cn_kotliner.c -o build/kotliner/cn_kotliner.bc -emit-llvm

clean:
	  rm -rf build/kotliner

```

这样只需要在命令行执行先把编译器 <konan.home>/bin 加入 path，之后执行 make，编译完成之后就可以在 build/kotliner/ 下面找到 kotliner.kexe 了。

## 3. 几个重要的坑

### 3.1 Gradle 插件指定包名的问题

gradle konan 插件配置中， 有一行可以配置 C 代码映射到 Kotlin 的包名：

```groovy
konanInterop {
    kotliner {
        ...
        pkg "cn.kotliner.native" // 生成的 C 代码标识符中含有 “.” 倒是无法编译
    }
}
```
如果这样配置，那么生成的 cstubs.c 文件就会出现下面的情形：

``` c
#include <stdint.h>
#include <cn_kotliner.h>

int32_t kni_cn.kotliner.native_factorial (int32_t n) {
    return (int32_t) (factorial((int)n));
}
```
`kni_cn.kotliner.native_factorial` 显然这不是一个合法的 C 标识符。因此目前这个地方还是有问题的。

这个问题我已经提了 issue，参见：[interop with package name failed](https://github.com/JetBrains/kotlin-native/issues/490)

解决方案也比较简单，我发现这段儿 C 代码生成的时候，编译器企图对包名中的特殊字符进行替换，只不过替换的是 "/" 而不是 "."：

**org/jetbrains/kotlin/native/interop/gen/jvm/StubGenerator.kt**

```kotlin
     private val FunctionDecl.cStubName: String
          get() {
              require(platform == KotlinPlatform.NATIVE)
 -            return "kni_" + pkgName.replace('/', '_') + '_' + this.name
 +            return "kni_" + pkgName.replace('.', '_') + '_' + this.name
          }
```

### 3.2 Kotlin 的 main 函数不能有包名

细心的读者应该会发现，我们前面写的 main 函数所在文件是没有 package 的，如果你给这个文件制定一个 package，那么编译器就无法找到入口函数，进而导致编译链接错误。

```
Undefined symbols for architecture x86_64:
  "_kfun:main(kotlin.Array<kotlin.String>)", referenced from:
      _Konan_start in combined8326574232997306104.o
ld: symbol(s) not found for architecture x86_64
exception: java.lang.IllegalStateException: The /Users/benny/Github/kotlin-native/dist/dependencies/target-sysroot-1-darwin-macos/usr/bin/ld command returned non-zero exit code: 1.
	at org.jetbrains.kotlin.backend.konan.LinkStage.runTool(LinkStage.kt:285)
	at org.jetbrains.kotlin.backend.konan.LinkStage.link(LinkStage.kt:261)
```

### 3.3 def 文件的路径

如果你使用前面的 makefile 进行编译，cinterop 调用时传入的 def 文件的路径一定不能写成下面这样

```bash
cinterop -def kotliner.def -o build/kotliner/kotliner.kt.bc
```

kotliner.def 必须使用 ./kotliner.def 的形式，否则编译器在编译时出遇到类似下面的问题：

```
<konan.home>/dependencies/clang-llvm-3.9.0-darwin-macos/bin/clang -Isrc/c -isystem <konan.home>/dependencies/clang-llvm-3.9.0-darwin-macos/lib/clang/3.9.0/include -B<konan.home>/dependencies/target-sysroot-1-darwin-macos/usr/bin --sysroot=<konan.home>/dependencies/target-sysroot-1-darwin-macos -mmacosx-version-min=10.11 -emit-llvm -c build/kotliner/kotliner.kt.bc-build/natives/cstubs.c -o build/kotliner/kotliner.kt.bc-build/natives/cstubs.bc
clang-3.9: error: no such file or directory: 'build/kotliner/kotliner.kt.bc-build/natives/cstubs.c'
clang-3.9: error: no input files
Exception in thread "main" java.lang.Error: Process finished with non-zero exit code: 1
        at org.jetbrains.kotlin.native.interop.gen.jvm.MainKt.runExpectingSuccess(main.kt:112)
        at org.jetbrains.kotlin.native.interop.gen.jvm.MainKt.runCmd(main.kt:158)
        at org.jetbrains.kotlin.native.interop.gen.jvm.MainKt.processLib(main.kt:396)
        at org.jetbrains.kotlin.native.interop.gen.jvm.MainKt.main(main.kt:43)
```

>以上用 < konan.home > 替换了编译的路径。

这个问题是因为 cinterop 最终会调用 clang 去编译一个动态生成的 c 文件，而调用时传入的 workdir 是 def 文件的父目录，如果我们传入 def 文件时写了形如 “-def kotliner.def” 这样的参数，那么得到的父目录就是 null 了，于是就出现了各种找不到文件的情况。

当然我们可以对编译器源码稍作修改就可以解决这个问题：

**Interop/StubGenerator/src/main/kotlin/org/jetbrains/kotlin/native/interop/gen/jvm/main.kt**

```kotlin
 357 -    val workDir = defFile?.parentFile ?: File(System.getProperty("java.io.tmpdir"))
     +    val workDir = defFile?.absoluteFile?.parentFile ?: File(System.getProperty("java.io.tmpdir"))
```

这个问题我也在 github 提了 pr，大家可以参考：[Wrong workdir when use relative def file path like "-def interop.def"](https://github.com/JetBrains/kotlin-native/pull/492)。

## 4、展望

嗯，这题目看上去真有点儿让我想起毕业论文来呢。不过这个展望比起论文的展望要踏实得多。

### 4.1 IntelliJ 支持

通过前面两节对 Kotlin Native 项目的构建和运行，我们发现 Kotlin 官方对于开发体验非常关注，尽管目前 IntelliJ 对此的支持还基本为零，不过 gradle 插件的支持已经非常令人满意了。相信随着 Kotlin Native 项目的迭代，IntelliJ 对其的支持也会趋于完善，彼时我们开发 Kotlin Native 的程序简直会 high 到飞起。

当然，我们也看到前面的构建过程中，对于 c 源码的构建支持几乎为零，我们仍然需要手动对 c 文件进行编译，不过这个并不复杂，所以极有可能出现的情形是 JetBrains 专门为 Kotlin 搞一个 IntelliJ 的版本（哇塞），整合 CLion 以及现有 Kotlin Native 的功能，一键编译 c 以及 Kotlin Native 源码也未可知呀。

### 4.2 支持更多平台

Kotlin Native 技术预览版还不支持 windows，这可苦了没有 Unix-like 机器的小伙伴们（嗯，虚拟机可以拯救你们），不过这只是暂时的，前期也没必要在很多平台上投入精力，一旦 Kotlin Native 在 Unix-like 机器上火起来，届时 windows 版的动力岂不是更大么，哈哈。

比起对 windows 版的支持，我觉得对 Android 的支持才是杀手级的。毕竟现在写桌面程序的人要少一些了，而 windows 程序也大多用微软全家桶，所以赶紧支持 Android 吧，哈哈哈。

### 4.3 再见，Jni 

从学知道 Jni 的一开始，就尝试着写过几个小程序，结果毋庸置疑，除了蛋疼就是蛋疼，IDE 支持也困难得不要不要的。后来开始写 Android，也基本上对 Jni 是敬而远之。

说起来我们公司项目有大量的 openGL 代码用 C/C++ 编写，在 windows 和 Mac 上有相应的移植版本，开发完成后再打包移植到 Android 以及 iOS 上。当然，我并不在这些项目组，我只是觉得搞这些开发的同事特别是负责移植到 Android 的同事的实在太优秀了，像我这种 JB 脑残粉，离了 IDE 智能提示的话，一行代码都写不下去。。。

Kotlin 的出现很有希望终结 Jni 的痛苦现状，Kotlin Native 也将为我们这些 Jvmer 打开一扇窗户，让我们几乎零成本进入底层代码的编写。

那个什么，以后别说自己是 Jvmer 了，说自己是 Kotliner 吧，也欢迎大家经常光顾 www.kotliner.cn。

### 4.4 大一统

如果我想写个牛逼一点儿的程序，我会选择 Java，原因是我对它最熟；

如果我想写一个工具脚本，我会选择 python，尽管 python 有时候还真是挺坑的，不过用着还算不错；

如果我想写个网站，我会选择 php，因为。。开发方便，资料也多。。。

嗯，自打一开始学编程，我就发现这坑可踩大发了。尽管用 C 可以写出 php 能写出的任何程序，Java 也一样，不过每一门语言终究因其自身的特点而擅长于不同的使用场景。

前不久跟一个资深开发聊天，他问我 Kotlin 能做什么，我说能做这个，能做那个，结果他听了之后来了一句：Kotlin 能写的 Java 都能写是呗？没错，他说得是对的，只是这能和能做好之间可就差了十万八千里了。

请问，如果你想要写一个小工具，你用 Java 写的话，是不是工程还没有配好，别人用 python 就已经调试完了？如果你用 C++ 写 web 应用，是不是工程还没配好，别人用 php 已经开始跟客户端联调了？这么说也许夸张了一些，但不得不承认的是，每一门语言都有其擅长的场景，“xxx能干的yyy也能干” 这样的句式简直让人有种 “你行你上啊” 来批驳的冲动。

那么 Kotlin 的出现究竟能给我们带来什么呢？试想一下，写小工具，我们可以用 kts（Kotlin Script）；所有 Java 擅长的 Kotlin 都擅长，而且写起来还比 Java 简洁不少；你甚至可以用 Kotlin 来开发前端程序来替代 JavaScript，尽管这个目前看来还没有很多人用到。而现在呢，我们还可以把 Kotlin 直接编译成 C 一样的机器码来运行，这样一来，Kotlin 将来还可以直接应用于嵌入式等对性能要求比较高的场景，这可真是上的了云端，下的了桌面，写的了网页，嵌的了冰箱啊。

一句话，Kotlin 从 Jvm 起家，现正在向着各种应用场景用功，各个场景的表现也不错，俨然成为一门擅长多个领域的语言了。

当然，程序员们也是萝卜青菜各有所爱，真正实现大一统显然也不太现实，但我们至少拥有了这样的途径和机会是不是？

-----------------

如果你有兴趣加入我们，请直接关注公众号 Kotlin ，或者加 QQ 群：162452394 联系我们。

![](/arts/e_group.png)