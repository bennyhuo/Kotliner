---
title: Kotlin 中文社区论坛
category: 社区动态
author: chpengzh
reward: false
date: 2017-07-10 15:08:30
tags:
keywords:
description:
reward_title:
reward_wechat:
reward_alipay:
source_url:
---

自从 `Kotlin` 被 google 选中为 Android 官方编程语言之一，业内的关注度就一直在上升。

本着创建社区、回馈社区这一理想，这里向大家隆重介绍我们的中文论坛 [kotliner.cn](https://kotliner.cn)

中文论坛旨在提供问答版和精品专题。

你可以在这里提问，发表最新的Kotlin学习见解，也可以订阅最新最好的Kotlin学习专题资料。

中文论坛服务 **使用 Kotlin 编写构建**，并托管在 [Github](https://github.com/Kotlin-lang-CN/Kotlin-CN)，前端使用了时下最火的框架 [Vue.js](https://cn.vuejs.org/)

## 1. 从Android开发到Kotlin中文论坛

笔者曾有过半年多使用 Kotlin 开发 Android 经验。起初接触到 Kotlin 时，这门语言并没有出 release 版本，但它仍然牢牢地抓住了我的眼球。

Kotlin 为我们带来了太多优秀的高级语法: 更优雅的函数编程，更精简的函数拓展，更好用的泛型，短小精悍的数据类等等。因其相对Android开发时使用的`java6`语法的种种优良特性，被业内称之为“`Java6`废土上的一线希望”。

相信不少使用Kotlin的同学都一定知道知乎上这个有名的问题:

[【Kotlin 作为 Android 开发语言相比传统 Java 有什么优势？】](https://www.zhihu.com/question/37288009)

其中不乏优秀的回答，在这里笔者就不再赘述了。

而创建Kotlin中文论坛的初衷， 在于知乎上一个几乎同样的问题:

[【Kotlin作为服务器端开发语言与Java相比会如何?】](https://www.zhihu.com/question/57141334)

当人们将眼光从单纯的Android业务开发中解放出来，去探讨一个语言的定位的时候，才是真正去思考这门语言定位的时候。

> `Kotlin`作为服务端开发是**可行的**。
> 
> 相较于java，它提供了更多的一些高级语法特性(非空检测，智能类型判断等)，在对语言**充分掌握**的情况下**一定能降低开发成本和错误率**。

在笔者看来，新事物出现是必然的、客观的规则， 一方面有些人会顾虑新事物所造成的革新会颠覆自己过去的认知，一方面会有些人大胆的去接受这些新事物并一探究竟。于是我决定就用这门语言去做一个论坛(使用的基本都是传统`javaEE`库)， 用最简单的最原始的方式来证明这个语言是完备的。并不脱离于现有的`java`体系， 而是更好的依附在其之上.

为此，笔者愿和群里大佬一同亲自去实践一波，去编写一个`kotlin in product`的论坛。一方面，我们能为新兴的中国 `Kotlin` 社区贡献一片创作的热土。另一方面，我们也想借此表达`Kotlin`这门语言的优势不仅仅在于`Android`开发，整个互联网产业之下都是其用武之地。

[Kotlin China](https://kotliner.cn) 使用了分布式微服务架构来实现模块解耦。对其结构感兴趣的同学的可以参看[【Kotlin CN 服务端结构简述】](https://kotliner.cn/post/6284216879862673408)，本文解释了一些简单的概念，以及该项目服务所用到的框架模型。

## 2. Kotlin为我们带来了什么

相信感受过Kotlin的同学都应该深有感触，Kotlin为我们带来了太多高级语言特性。以至于允许你在繁杂的 Android 业务开发中，即使不依赖第三方库也能写更优雅的代码。而这时传统`java`开发中很难想象到的场景

> 比如在Android开发中使用Kotlin异步发送HTTP请求

```kotlin
Req.get<ExactlySearchRoomInfo>(API.ROOM, "/rooms/$keyword"
).send(param = {
    it["longitude"] = location.longitude
    it["latitude"] = location.latitude
}, success = { _, resp ->
    starter.next(listOf(RoomInfoWrapper(resp)))
}, fail = { _, _ -> 
    starter.next(emptyList()) 
})
```

> 使用Kotlin代理实现的属性绑定

```kotlin
class UserNameTitleLayout : RelativeLayout {

    val mUserTag: ImageView by bind(R.id.image_tag, comment = "用户标签")
    val mUserNick: TextView by bind(R.id.user_page_nick, comment = "用户昵称")
    val mAge: TextView by bind(R.id.age_text, comment = "用户年龄")
    val mLocationIcon: View by bind(R.id.user_page_location_icon, comment = "定位标记")
    
    //...
}
```

> 直接使用`SQL`语句替代复杂的ORM框架进行开发

```kotlin
"""
--查询私聊消息--
SELECT m.*, a.*
FROM message as m
LEFT JOIN im_user as a
ON a.uid=m.target
WHERE m._owner=?
AND m.group_id=0
AND m.status<>${IMMsg.Status.DELETE}
AND m.target=?
""".queryList(db, { cursor ->
    IMMsg().apply {
        this.status = cursor int "status"
        this.seqNum = cursor str "seqnum"
        this.target = IMUserInfo().apply {
            this.uid = cursor long "uid"
            this.nick = cursor str "nick"
            this.logoURL = cursor str "logo_url"
            this.sex = cursor int "sex"
            this.birthday = cursor str "birthday"
        }
        this.type = cursor int "type"
        this.content = cursor str "content"
        this.date = cursor long "date"
        this.fromChannel = cursor int "from_channel"
        this.tips = cursor str "tips"
    }
}, /*_owner*/owner, /*target*/id)
```

以上只是举出了几个简单的例子，并没有完全枚举这门语言的特性，仅供抛砖引玉。

有人说 Kotlin 是为 Android 而生的一门语言，这并不正确。它提供了大量优秀的语法特性，这些特性即使在服务端平台开发中，也能彰显其价值。

> 比如我们常用的mybatis，可以彻底告别肮脏的xml解析语法了

``` java
interface ProfileMapper {

   @Select("""
   SELECT * FROM profile
   WHERE uid = #{uid}
   LIMIT 1
   """)
   fun getById(uid: Long): Profile?
}
```

> 又比如我们可以用简单易读的lambda函数，来使用数据库事务

```kotlin
//注册事务
Mysql.write {
  var user = UserInfoDao.getByName(it, req.username)
  if (user != null) abort(Err.USER_NAME_EXISTS)

  user = UserInfoDao.getByEmail(it, req.email)
  if (user != null) abort(Err.USER_EMAIL_EXISTS)

  AccountDao.saveOrUpdate(it, account)
  UserInfoDao.saveOrUpdate(it, userInfo)
  //绑定github账号
  if (req.githubUser.id != 0L) {
      req.githubUser.uid = account.id
      GitHubUserInfoDao.saveOrUpdate(it, req.githubUser)
  }
}
```

当然这些都是从语法层面上来描述它所带来的新事物，能让它作为服务端开发的最主要的原因，还是在它和`java`语言几乎绝对的兼容性。

开发过程中有时甚至完全意识不到这是一门新语言，更多的会去想这是一套更强大的java语法糖套件，并很容易使用上瘾。

## 3. 关于我们和Kotlin China社区

我们是来自全国各地的 Kotlin 爱好者

我们乐于帮助每一个希望了解和学习 Kotlin 的小伙伴，也欢迎所有的 Kotlin 爱好者加入我们一起讨论 Kotlin 的话题，一起翻译官方的文档，一起分享自己的开发经历。

社区论坛: [https://kotliner.cn](https://kotliner.cn)

社区博客: [https://www.kotliner.cn](https://www.kotliner.cn)

中文站: [https://www.kotlincn.net](https://www.kotlincn.net)

