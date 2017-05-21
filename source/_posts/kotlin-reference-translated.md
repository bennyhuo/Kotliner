---
title: Kotlin 官方参考文档翻译完毕
category: 社区动态
reward: false
date: 2017-05-17 11:13:15
author: 灰蓝天际
tags: [Kotlin, 中文, 官网]
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

非常高兴跟大家宣布：Kotlin 官方文档的参考部分已翻译校对完毕、且与官网同步，这也是目前唯一完整且最新的官方参考文档翻译。

打开 [Kotlin 语言中文站](https://www.kotlincn.net/)，点[学习](https://www.kotlincn.net/docs/reference/)即是，或者直接打开这个链接：[https://www.kotlincn.net/docs/reference/](https://www.kotlincn.net/docs/reference/)。为了便于离线阅读，还可以从 GitBook 项目 [gitbook.com/book/hltj/kotlin-reference-chinese](https://www.gitbook.com/book/hltj/kotlin-reference-chinese/details) 下载对应电子书。今后官方文档有更新时，中文站和 GitBook 也会及时同步并更新翻译，关注 Kotlin 语言的同学请保持关注。

## Kotlin 是什么？
Kotlin 中文站首页（[https://www.kotlincn.net/](https://www.kotlincn.net/)）已经用很醒目的字眼回答了这个问题。而我觉得这样介绍会更充分一些：Kotlin 是一门支持多范式、多平台的现代静态编程语言。Kotlin 支持面向对象、泛型与函数式等编程范式，它支持 JVM、Android、JavaScript 目标平台，而[原生（Native）平台的 Kotlin 几天前也发布了 0.2 版本](https://www.kotliner.cn/2017/05/12/Kotlin_Native%20v0.2%20is%20out/)。而且 Kotlin 具有很多现代（也有称下一代的）静态语言特性：如类型推断、多范式支持、可空性表达、扩展函数、模式匹配等。因此上面描述毫不夸张，它是一门非常有潜力的新兴语言。

另外 100% 的 Java 互操作性，，使 Kotlin 能够与既有工具/框架如 Dagger、Spring、Vert.x 等集成，也能让既有的基于 Java 的服务端与 Android 项目逐步迁移到 Kotlin。详情参见[Kotlin 用于服务器端](https://www.kotlincn.net/docs/reference/server-overview.html)与[Kotlin 用于 Android](https://www.kotlincn.net/docs/reference/android-overview.html)。了解更多关于 Kotlin 的内容，请关注 [Kotlin 中文站](https://www.kotlincn.net/)与 [Kotlin 中文博客](https://www.kotliner.cn/)。

## Kotlin 中文站
针对 Kotlin 官方参考文档的翻译有很多支系，而只有 [Kotlin 中文站](https://www.kotlincn.net/) 能够与官网及时同步且最终完成全部参考文档翻译。

这当然离不开创始人[晓_晨DEV](http://tanfujun.com)和我（[灰蓝天际](https://hltj.me/)）以及[所有参与翻译的同学](https://www.kotlincn.net/contribute.html#中文站翻译贡献者)的共同努力。我从 2016 年 2 月开始参与 Kotlin 中文站的翻译，Kotlin 1.0 就是那时正式发布的，时隔一年多又亲历了它 1.1 版的发布，见证它成长的同时，也在不断校对和补充官方参考文档的翻译。而晓\_晨DEV更是在 2015 年就开了 Kotlin 中文站的翻译，并且组织带动社区参与者一起翻译。在 Kotlin 中文站版本库的[贡献者统计图](https://github.com/hltj/kotlin-web-site-cn/graphs/contributors)中可以看到晓\_晨DEV与我分别提交了近 4000 行与近 6000 行的改动，已经同官方文档的撰写者一起排进了前十。

![contributors.png](/assets/2017.05.17/contributors.png)

## 与官方站及时同步
Kotlin 中文站之所以能够与官网内容同步，在于创始人晓\_晨DEV采用了科学的翻译方式，其实也是开源界普遍采用的 fork-修改模式，只是 Kotlin 中文站直接 fork 了官方的英文源站。这样做的显著优势是官方站有任何更新可以及时合并进来。尽管这可能会引入冲突解决的环节，并且合并新的英文原版内容会降低翻译完整度。

2016 年 2 月当我评估各个翻译组潜力的时候，就发现了这个问题，当时虽然 Kotlin 中文站的完成度不是最高的，但是其他的翻译组都不具备与官网及时同步的能力，于是果断加入了 Kotlin 中文站翻译。

## GitBook 避免重复工作
Kotlin 网站最初是基于 Jekyll 的网站，目前是使用 Jinjia2 模版引擎的类 Jekyll 网站，并不能直接拿来制作 GitBook。为了能够方便提供 ePUB 版和 Moby 版电子书，我在 [gitbook.com/book/hltj/kotlin-reference-chinese](https://www.gitbook.com/book/hltj/kotlin-reference-chinese/details) 项目中采用了引入语法，在 GitBook 项目中只维护目录、章节等基本结构，内容都是引用的 Kotlin 中文站版本库的，当然其中用了一些具体的技巧来处理不兼容问题。这样在避免重复工作的同时，也避免出现同步脱节的问题。

## 参与和改进

后续 Koltin 中文站会继续翻译教程部分以及参考部分的更新内容。参与翻译请直接 fork [github.com/hltj/kotlin-web-site-cn](https://github.com/hltj/kotlin-web-site-cn) 并提 Pull Request 过来。

关于网站与 PDF 有任何问题请在[这里](https://github.com/hltj/kotlin-web-site-cn/issues)反馈；
关于 ePUB 与 Mobi 有任何问题请在[这里](https://github.com/hltj/kotlin-reference-chinese/issues)反馈。

## 关于我
多年互联网研发从业者。Kotlin 中文站维护人。欢迎关注
- Github：[https://github.com/hltj](https://github.com/hltj)
- 微博：[灰蓝天际](http://weibo.com/hltj)

  ![](/assets/2017.05.17/weibo_qr.png)    ![](/assets/2017.05.17/wechat_qr.png)
