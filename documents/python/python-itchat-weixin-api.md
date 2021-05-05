---
title: python 微信接口 -- itchat 文档
date: 2018-03-16 17:05:25
categories:
- Python
tags:
- itchat
- 微信
- PyPi
---
# itchat

## 一. 安装
    $ pip install itchat

**特殊的字典使用方式**
通过打印 itchat 的用户以及注册消息的参数, 可以发现这些值都是字典.

但实际上 itchat 精心构造了相应的消息,用户,群聊,公众号等.

其所有的键值都可以通过这一方式访问:
    
    @itchat.msg_register(TEXT)
    def _(msg):
        # equals to print(msg['FromUserName'])
        print(msg.fromUserName)

属性名为键值首字母小写后的内容.

    author = itchat.search_frients(nickName="LittleCoder")[0]
    author.send("greeting ,  LittleCoder!")

## 二. 登录

一般而言, 会在完成消息的注册后登录.

**强调三点**:
- 登录状态缓存, 短时间关闭重连, 关闭程序后一定时间内不需要扫码即可登录. 由于目前微信网页版提供上一次登录的微信号不扫码直接手机确认登录, 所以如果开启登录状态暂存, 将会自动使用这一功能.
- 命令行二维码, 
- 自定义登录内容(如更改提示语, 二维码出现后邮件发送等).

### 1. 短时间关闭程序后重连.
即使程序关闭，一定时间内重新开启也可以不用重新扫码.

**使用 `auto_login` 方法传入值为真的 `hotReload`**.
该方法会生成一个静态文件 `itchat.pkl`, 用于存储登录的状态. 

    import itchat
    from itchat.content import TEXT

    @itchat.msg_register(TEXT)
    def simple_reply(TEXT):
        print(msg.text)

    itchat.auto_login(hotReload=True)
    itchat.run()

通过设置 `statusStorageDir` 可以将静态文件指定为其他的值. 这一内置选项,相当于使用了以下两个函数的这一段程序:

    import itchat
    from itchat.content import TEXT

    if itchat.load_login_status():  # itchat.load_login_status() 用于读取设置
        @itchat.msg_register(TEXT):
        def simple_reply(msg):
            print(msg["Text"])

        itchat.run()
        itchat.dump_login_status()  # itchat.dump_login_status() 用于导出设置

    else:
        itchat.auto_login()
        itchat.dump_login_status()
        print("Config stored, so exit.")

通过设置传入的 `fileDir` 的值, 可以设定导入导出的文件.

### 2. 命令行二维码
通过如下命令在登录的时候, 使用命令行显示 二维码.
    
    itchat.auto_login(enableCmdQR=True)

部分系统可能字符宽度有出入, 可以通过将 enableCmdQR 赋值为特定的倍数进行调整.
    
    # 如部分 Linux 系统, 块字符的宽度为一个字符(正常为两个字符), 故赋值为 2
    itchat.auto_login(enableCmdQR=2)

默认控制台背景颜色为暗色(黑色), 若背景色为浅色, 可将 enableCmdQR 赋值为负值:
    
    itchat.auto_login(enableCmdQR=-1)

### 3. 自定义登录过程
itchat 提供了登录所需的每一步的方法, 登录的过程按殊勋为:
1) 获取二维码 `uuid`, 并返回该 `uuid`

    - 方法名称: `get_QRuuid()`
    - 参数: 无
    - 返回值: 成功返回 uuid, 失败返回 None

2) 获取二维码 : 根据`uuid`获取二维码并打开.

    - 方法名: `get_QR()`
    - 参数: uuid
    - 返回值: True, False

3) 判断是否已登录成功

    - 方法名称: `check_login()`
    - 参数: uuid
    - 返回值: 200 登录成功, 201 以扫描二维码, 408 二维码失效, 0 未获取到信息.

4) 获取初始化数据: 获取微信用户信息以及心跳所需要的数据.

    - 方法名称: `web_init()`
    - 参数: 无
    - 返回值: 存储登录微信用户信息的字典.

5) 获取微信通讯录, 获取微信的所有好友信息并更新

    - 方法名称: `get_frients()`
    - 参数: 无
    - 返回值: 存储好友信息的列表

6) 更新微信手机登录状态, 在手机上显示登录状态.

    - 方法名称: `show_mobile_login()`
    - 参数: 无
    - 返回值: 无

7) 循环扫描新信息(开启心跳)

    - 方法名称: `start_receiving()`
    - 参数: 无
    - 返回值: 无

### 4. `auto_login`的实现代码:

    import itchat, time, sys

    def output_info(msg):
        print('[INFO] %s' % msg)

    def open_QR():
        for get_count in range(10):
            output_info("Getting uuid")
            uuit = itchat.get_QRuuid()
            while uuid is None:
                uuitd = itchat.get_QRuuid();
                time.sleep(1)
            output_info("Getting QR code")
            if itchat.get_QR(uuid):
                break
            elif get_coun >= 9:
                output_info("Failed to get QR code, plz restart the program")
                sys.exit()

        output_info("Plz scan the QE Code")
        return uuid

    uuid = open_QR()
    waitForConfirm = False

    while 1:
        status = itchat.check_login(uuid)
        if status == '200':
            break
        elif status = '201':
            if waitForConfirm:
                output_info("Plz press confirm")
                waitForConfirm = True
        elif status == '408':
            output_info("Reloading QR Code")
            uuid = open_QR()
            waitForConfirm = False

    userInfo = itchat.web_init()
    itchat.show_mobile_login()
    itchat.get_friends(True)
    output_info("Login successfully as %s" % userInfo["NickName"])
    itchat.start_receiving()

    # start auto-replying
    @itchat.msg_register
    def simple_reply(msg):
        if msg["Type"] == "Text":
            return "I received: %s" % msg["Content"]

    itchat.run()

### 5. 退出及登录完成后调用的特定方法
登录完成后的方法需要赋值在 `loginCallback` 中
退出后的方法,需要赋值在 `exitCallback` 中.
    
    import itchat, time
    def lc():
        print("Finash Login!")
    def ec():
        print("exit")

    itchat.auto_login(loginCallback=lc, exitCallback=ec)
    time.sleep()
    itchat.logout()

若不设置 `loginCallback` 的值, 将会自动删除二维码图片并清空命令行显示.

### 6. 用户多开
    
    import itchat
    netInstance = itchat.new_instance()
    netInstance.auto_login(hotReload=True, statusStorageDir="newInstance.pkl")

    @newInstance.msg_register(TEXT)
    def reply(msg):
        return msg.text

    netInstance.run()

## 三. 回复
五种回复方法, 建议直接使用 `send` 方法
### 1. `send`
- 方法: `send(msg="Text Message", toUserName=None)`
- 参数: 

    - `msg` : 文本消息内容
    - `@fil@path_to_file` : 发送文件
    - `@img@path_to_img` : 发送图片
    - `@vid@path_to_video` : 发送视频
    - `toUserName` : 发送对象, 如果留空, 将发送给自己.

- 返回值: True, False
- 示例代码:
        
        # coding-utf-8
        import itchat

        itchat.auto_login()
        itchat.send("Hello World!")
        ithcat.send("@fil@%s" % '/tmp/test.text')
        ithcat.send("@img@%s" % '/tmp/test.png')
        ithcat.send("@vid@%s" % '/tmp/test.mkv')

### 2. `send_msg`
- 方法: `send_msg(msg='Text Message', toUserName=None)`
- 参数: 
    - `msg`: 消息内容
    - `toUserName`: 发送对象, 如果留空, 将发送给自己.
- 返回值: True, False
- 示例代码:
        
        import itchat

        itchat.auto_login()
        itchat.send_msg("hello world.")

### 3. `send_file`
- 方法: `send_file(fileDir, toUserName=None)`
- 参数: 
    - `fileDir` : 文件路径, 当文件不存在时, 将打印无此文件的提醒.
    - `toUserName` : 发送对象, 如果留空, 将发送给自己.
- 返回值: True, False
- 示例代码:
    
        import itchat

        itchat.auto_login()
        itchat.send_file("/tmp/test.txt")

### 4. `send_img`
- 方法: `send_img(fileDir, toUserName=None)`
- 参数:
    - `fileDir` : 文件路径, 当文件不存在时, 将打印无此文件的提醒.
    - `toUserName` : 发送对象, 如果留空, 将发送给自己.

- 返回值: True, False
- 示例代码:

        import itchat

        itchat.auto_login()
        itchat.send_img("/tmp/test.txt")

### 5. `send_video`
- 方法: `send_video(fileDir, toUserName=None)`
- 参数: 
    - `fileDir` : 文件路径, 当文件不存在时, 将打印无此文件的提醒.
    - `toUserName` : 发送对象, 如果留空, 将发送给自己.
- 返回值: True, False
- 示例代码:

        import itchat

        itchat.auto_login()
        itchat.send_video("/tmp/test.txt")

## 四. 注册消息方法

itchat 将根据接受到的消息类型寻找对应的已注册的方法.

如果一个消息类型没有对应的注册方法, 该消息将会被**舍弃**.

在运行过程中也可以动态注册方法, 注册方式与结果不变.

### 1. 注册方法:
两种方法注册消息.

- 不带具体对象注册, 将注册为普通消息的回复方法.

        import itchat
        from itchat.content import *

        @itchat.msg_register(TEXT)
        def simple_reply(msg):
            return "T reveived: %s" % msg["Text"]

- 带对象参数注册, 对应消息对象将调用该方法.

        import itchat
        from itchat.content import *

        @itchat.msg_register(TEXT, isFriendChat=True, isGroupChat=True,isMpChat=True)
        def text_reply(msg):
            msg.user.send("%s : %s" % (mst.type, msg.text))


### 2. 消息类型
**向注册方法传入的 `msg` 包含微信返回的字典的所有内容**.

itchat 增加 `Text`, `Type`(也就是参数) 键值, 方便操作.

`itcaht.content` 中包含所有的**消息类型参数**, 如下表:

| 参数 | 类型 | Text 键值 |
| ---  | ---  | ---       |
| TEXT    | 文本|   文本内容 |
| MAP     | 地图|   位置文本 |
| CARD    | 名片|   推荐人字典 |
| NOTE    | 通知|   通知文本 |
| SHARING | 分享|   分享名称 |
| PICTURE | 图片/表情 |  下载方法 |
| RECORDING | 语音|     下载方法 |
| ATTACHMENT | 附件|      下载方法 |
| VIDEO  | 小视频|      下载方法 |
| FRIENDS | 好友邀请|    添加好友所需参数 |
| SYSTEM | 系统消息|     更新内容的用户或群聊的`UserName`组成的列表 |

代码示例: 存储接受的文件

    @itchat.msg_register(ATTACHMENT)
    def download_files(msg):
        msg["Text"](msg["FileName"])

**附件的下载与发送**
itchat 的附件下载方法存储在 msg 的 Text 键中.

发送的文件名(图片给出的默认文件名), 都存储在 msg 的 FileName 键中.

下载方法, 接受一个可用的位置参数(包括文件名), 并将文件响应的存储.

    @itchat.msg_register([PICTURE, RECORDING, ATTACHMENT, VIDEO])
    def download_files(msg):
        msg.download(msg.fileName)
        itchat.send('@%s@%s' % ('img' if msg['Type'] == 'Picture' else 'fil', msg["FileName"]), msg["FromUserName"])

        return "%s received" % msg["Type"]
如果不需要下载到本地, 仅需要读取二进制串进一步处理可以不传入参数, 方法将会返回图片的二进制串.

    @itchat.msg_register([PICTURE, RECORDING, ATTACHMENT, VIDEO])
    def download_files(msg):
        with open(msg.fileName, 'wb') as f:
            f.write(msg.download())


**群消息**增加了三个键值:
- `isAt` : 判断是否 @ 本号
- `ActualNickName` : 实际 NickName
- `Content` : 实际 Content

测试程序:

    import itcaht
    from itchat.content import TEXT

    @itchat.msg_register(TEXT, isGroupChat=True)
    def text_reply(msg):
        print(msg.isAt)
        print(msg.actualNickName)
        print(msg.text)

    itchat.auto_login()
    itchat.run()

### 3. 注册消息的优先级

优先级规则: 
- 后注册消息 > 先注册消息
- 带参数消息 > 不带参数消息

### 4. 动态注册消息
- 将 `itchat.run()` 放入另一线程
        
        import thread
        thread.start_new_thread(itcaht.run(), ())

- 使用 `configured_reply()` 方法处理消息.
        
        while 1:
            itcaht.configured_reply()
            # some other functions
            time.sleep()

**示例**: 

    #coding=utf-8
    import thread

    import itchat
    from itchat.content import *

    replyToGroupChat = True
    functionStatus = False

    def change_function():
        if replyToGroupChat != functionStatus:
            if replyToGroupChat:
                @itchat.msg_register(TEXT, isGroupChat=True)
                def group_text_reply(msg):
                    if u'关闭' in msg["Text"]:
                        replyToGroupChat = False
                        return u"以关闭"
                    elif u"开启" in msg["Text"]:
                        return u"已经在运行"
                    return u'输入"关闭" 或者 "开启" 测试功能'
            else:
                @itcaht.msg_register(TEXT, isGroupCaht=True)
                def group_text_reply(msg):
                    if u"开启" in msg["Text"]:
                        replyToGroupChat = True
                        return u"重新开启成功"

            functionStatus = replyToGroupChat

    thread.start_new_thread(itcaht.run, ())
    while 1:
        change_function()
        time.sleep(1)

    # 各类消息的注册: 通过如下代码, 微信已经可以就日常的各种信息进行获取与回复.

    import  itchat, time
    from itchat.content import *

    @itchat.msg_register([TEXT, MAP, NOTE, SHARING])
    def text_replay(msg):
        msg.user.send('%s %s' % (msg.type, msg.text))

    @itchat.msg_register([PICTURE, RECORDING, ATTACHMENT, VIDEO])
    def download_file(msg):
        msg.download(msg.fileName)
        typeSymbol = {
            PICTURE: 'img',
            VIDEO: 'vid', }.get(msg.type, 'fil')

        return "@%s@%s" % (typeSymbol, msg.fileName)

    @itchat.msg_register(FRIENDS)
    def add_friend(msg):
        msg.user.verify()
        msg.user.send("Nice to meet you!")

    @itchat.msg_register(TEXT, isGroupChat=True)
    def text_replay(msg):
        if msg.isAt:
            msg.user.send(u'@$s\u2005I received: %s' % (msg.actualNickName, msg.text))
    
    itchat.auto_login(True)
    itchat.run(True)    

## 五. 消息内容
### 1. 微信一般消息内容
微信回复的所有消息都遵循这一格式.

    {
        "FromUserName": "",
        "ToUserName": "",
        "Content": "",
        "StatusNotifyUserName": "",
        "ImgWidth": 0,
        "PlayLength": 0,
        "RecommendInfo": {},
        "StatusNotifyCode": 0,
        "NewMsgId": "",
        "Status": 0,
        "VoiceLength": 0,
        "ForwardFlag": 0,
        "AppMsgType": 0,
        "Ticket": "",
        "AppInfo": {},
        "Url": "",
        "ImgStatus": 0,
        "MsgType": 0,
        "ImgHeight": 0,
        "MediaId": "",
        "MsgId": "",
        "FileName": "",
        "HasProductId": 0,
        "FileSize": "",
        "CreateTime": 0,
        "SubMsgType": 0
    }

### 2. 消息具体内容
#### 1) 初始化消息

    MsgType: 51
    FromUserName: 自己ID
    ToUserName: 自己ID
    StatusNotifyUserName: 最近联系的联系人ID
    Content:
        <msg>
            <op id='4'>
                <username>
                    # 最近联系的联系人
                    filehelper,xxx@chatroom,wxid_xxx,xxx,...
                </username>
                <unreadchatlist>
                    <chat>
                        <username>
                        # 朋友圈
                            MomentsUnreadMsgStatus
                        </username>
                        <lastreadtime>
                            1454502365
                        </lastreadtime>
                    </chat>
                </unreadchatlist>
                <unreadfunctionlist>
                # 未读的功能账号消息，群发助手，漂流瓶等
                </unreadfunctionlist>
            </op>
        </msg>

#### 2) 文本消息

    MsgType: 1
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    Content: 消息内容

#### 3) 图片消息
itchat 增加了 Text 键, 键值为 下载该图片的方法.

    MsgType: 3
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    MsgId: 用于获取图片
    Content:
        <msg>
            <img length="6503" hdlength="0" />
            <commenturl></commenturl>
        </msg>

#### 4) 小视频消息
itchat 增加了 Text 键, 键值为 下载该视频的方法.

    MsgType: 62
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    MsgId: 用于获取小视频
    Content:
        <msg>
            <img length="6503" hdlength="0" />
            <commenturl></commenturl>
        </msg>

#### 5) 地理位置消息
itchat 增加了 Text 键, 键值为 该地点的文本形式.

    MsgType: 1
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    Content: http://weixin.qq.com/cgi-bin/redirectforward?args=xxx

#### 6) 名片消息
itchat 增加了 Text 键, 键值为 该调用 `add_friend` 需要的属性.

    MsgType: 42
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    Content:
        <?xml version="1.0"?>
        <msg bigheadimgurl="" smallheadimgurl="" username="" nickname=""  shortpy="" alias="" imagestatus="3" scene="17" province="" city="" sign="" sex="1" certflag="0" certinfo="" brandIconUrl="" brandHomeUrl="" brandSubscriptConfigUrl="" brandFlags="0" regionCode="" />

    RecommendInfo:
        {
            "UserName": "xxx", # ID
            "Province": "xxx", 
            "City": "xxx", 
            "Scene": 17, 
            "QQNum": 0, 
            "Content": "", 
            "Alias": "xxx", # 微信号
            "OpCode": 0, 
            "Signature": "", 
            "Ticket": "", 
            "Sex": 0, # 1:男, 2:女
            "NickName": "xxx", # 昵称
            "AttrStatus": 4293221, 
            "VerifyFlag": 0
        }

#### 7) 语音消息
itchat 增加了 Text 键, 键值为 下载该语音文件的方法.

    MsgType: 34
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    MsgId: 用于获取语音
    Content:
        <msg>
            <voicemsg endflag="1" cancelflag="0" forwardflag="0" voiceformat="4" voicelength="1580" length="2026" bufid="216825389722501519" clientmsgid="49efec63a9774a65a932a4e5fcd4e923filehelper174_1454602489" fromusername="" />
        </msg>

#### 8) 动画表情
itchat添加了Text键，键值为下载该图片表情的方法。

由于版权问题，部分微信商店提供的表情是无法下载的，注意。


    MsgType: 47
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    Content:
        <msg>
            <emoji fromusername = "" tousername = "" type="2" idbuffer="media:0_0" md5="e68363487d8f0519c4e1047de403b2e7" len = "86235" productid="com.tencent.xin.emoticon.bilibili" androidmd5="e68363487d8f0519c4e1047de403b2e7" androidlen="86235" s60v3md5 = "e68363487d8f0519c4e1047de403b2e7" s60v3len="86235" s60v5md5 = "e68363487d8f0519c4e1047de403b2e7" s60v5len="86235" cdnurl = "http://emoji.qpic.cn/wx_emoji/eFygWtxcoMF8M0oCCsksMA0gplXAFQNpiaqsmOicbXl1OC4Tyx18SGsQ/" designerid = "" thumburl = "http://mmbiz.qpic.cn/mmemoticon/dx4Y70y9XctRJf6tKsy7FwWosxd4DAtItSfhKS0Czr56A70p8U5O8g/0" encrypturl = "http://emoji.qpic.cn/wx_emoji/UyYVK8GMlq5VnJ56a4GkKHAiaC266Y0me0KtW6JN2FAZcXiaFKccRevA/" aeskey= "a911cc2ec96ddb781b5ca85d24143642" ></emoji> 
            <gameext type="0" content="0" ></gameext>
        </msg>

#### 9) 普通链接或应用分享消息

    MsgType: 49
    AppMsgType: 5
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    Url: 链接地址
    FileName: 链接标题
    Content:
        <msg>
            <appmsg appid=""  sdkver="0">
                <title></title>
                <des></des>
                <type>5</type>
                <content></content>
                <url></url>
                <thumburl></thumburl>
                ...
            </appmsg>
            <appinfo>
                <version></version>
                <appname></appname>
            </appinfo>
        </msg>

#### 10) 音乐链接消息

    MsgType: 49
    AppMsgType: 3
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    Url: 链接地址
    FileName: 音乐名

    AppInfo: # 分享链接的应用
        {
            Type: 0, 
            AppID: wx485a97c844086dc9
        }

    Content:
        <msg>
            <appmsg appid="wx485a97c844086dc9"  sdkver="0">
                <title></title>
                <des></des>
                <action></action>
                <type>3</type>
                <showtype>0</showtype>
                <mediatagname></mediatagname>
                <messageext></messageext>
                <messageaction></messageaction>
                <content></content>
                <contentattr>0</contentattr>
                <url></url>
                <lowurl></lowurl>
                <dataurl>
                    http://ws.stream.qqmusic.qq.com/C100003i9hMt1bgui0.m4a?vkey=6867EF99F3684&amp;guid=ffffffffc104ea2964a111cf3ff3edaf&amp;fromtag=46
                </dataurl>
                <lowdataurl>
                    http://ws.stream.qqmusic.qq.com/C100003i9hMt1bgui0.m4a?vkey=6867EF99F3684&amp;guid=ffffffffc104ea2964a111cf3ff3edaf&amp;fromtag=46
                </lowdataurl>
                <appattach>
                    <totallen>0</totallen>
                    <attachid></attachid>
                    <emoticonmd5></emoticonmd5>
                    <fileext></fileext>
                </appattach>
                <extinfo></extinfo>
                <sourceusername></sourceusername>
                <sourcedisplayname></sourcedisplayname>
                <commenturl></commenturl>
                <thumburl>
                    http://imgcache.qq.com/music/photo/album/63/180_albumpic_143163_0.jpg
                </thumburl>
                <md5></md5>
            </appmsg>
            <fromusername></fromusername>
            <scene>0</scene>
            <appinfo>
                <version>29</version>
                <appname>摇一摇搜歌</appname>
            </appinfo>
            <commenturl></commenturl>
        </msg>

#### 11) 群消息
itchat 增加了三个群聊相关的键值:
- `isAt` : 判断是否 @ 本号
- `ActualNickName` : 实际 NickName
- `Content` : 实际 Content

        MsgType: 1
        FromUserName: @@xxx
        ToUserName: @xxx
        Content:
            @xxx:<br/>xxx

#### 12) 红包消息

    MsgType: 49
    AppMsgType: 2001
    FromUserName: 发送方ID
    ToUserName: 接收方ID
    Content: 未知

#### 13) 系统消息

    MsgType: 10000
    FromUserName: 发送方ID
    ToUserName: 自己ID
    Content:
        "你已添加了 xxx ，现在可以开始聊天了。"
        "如果陌生人主动添加你为朋友，请谨慎核实对方身份。"
        "收到红包，请在手机上查看"


## 六. 账号类型

itchat 为三种账号都提供了 整体获取方法与搜索方法.

**群聊**多出了获取用户列表方法以及创建群聊,增加/删除用户的方法.

### 1. 好友
- `get_friends` : 返回完整的好友列表
    
    - 每个好友为一个字典, 其中第一项为本人的账号信息;
    - 传入 update=True, 将更新好友列表并返回, `get_friends(update=True)`.

- `search_friends` : 好友搜索,  有**四种**搜索方式
    
    - 仅获取自己的用户信息

            # 获取自己的用户信息，返回自己的属性字典
            itchat.search_friends()

    - 获取特定 `UserName` 的用户信息

            # 获取特定UserName的用户信息
            itchat.search_friends(userName='@abcdefg1234567')

    - 获取备注,微信号, 昵称中的任何一项等于`name`键值的用户. (可以与下一项配置使用.)

            # 获取任何一项等于name键值的用户
            itchat.search_friends(name='littlecodersh')
        
    - 获取备注,微信号, 昵称分别等于相应键值的用户. (可以与上一项配置使用.)

            # 获取分别对应相应键值的用户
            itchat.search_friends(wechatAccount='littlecodersh')
            # 三、四项功能可以一同使用
            itchat.search_friends(name='LittleCoder机器人', wechatAccount='littlecodersh')

- `update_friend` : 好友更新

    - 特定用户: 传入用户`UserName`, 返回指定用户的最新信息.
    - 用户列表: 传入 `UserName` 组成的列表, 返回用户最新信息组成的列表.

    `memberList = itchat.update_friend('@abcdefg1234567')`


### 2. 公众号
- `get_mps` : 将返回完整的工作号列表.

    - 每个公众号为一个字典,
    - 传入 `update=True` 将更新公众号列表, 并返回.

- `search_mps` : 有两种搜索方法:
    
    - 获取特定`UserName`的公众号

            # 获取特定UserName的公众号，返回值为一个字典
            itchat.search_mps(userName='@abcdefg1234567')

    - 获取名字中还有特定字符的公众号.

            # 获取名字中含有特定字符的公众号，返回值为一个字典的列表
            itchat.search_mps(name='LittleCoder')

    - 当两项都是勇士, 将仅返回特定`UserName`的公众号.

### 3. 群聊

- `get_chatrooms` : 返回完整的群聊列表.

- `search_chatrooms` : 群聊搜索.

- `update_chatroom` : 获取群聊用户列表或更新该群聊.

    群聊在首次获取中不会获取群聊的用户列表, 所以需要调用该命令才能获取群聊成员.

    - 传入群聊的 `UserName` , 返回特定群聊的详细信息.
    - 传入`UserName`组成的列表, 返回指定用户的最新信息组成的列表.

    `memberList = itchat.update_chatroom('@@abcdefg1234567', detailedMember=True)`

- 创建群聊,增加/删除群聊用户:
    
    - 由于之前通过群聊检测是否被好友拉黑的程序, 目前这三个方法都被严格限制了使用频率.
    - 删除群聊需要本账号为管理员, 否则无效.
    - 将用户加入群聊有`直接加入`与`发送邀请`, 通过 `useInvitation` 设置.
    - 超过 40 人的群聊无法使用直接加入的加入方式.

            memberList = itchat.get_frients()[1:]
            # 创建群聊, topic 键值为群聊名称.
            chatroomUserName = itchat.create_chatroom(memberList, "test chatroom")
            # 删除群聊内的用户
            itchat.delete_member_from_chatroom(chatroomUserName, memberList[0])
            # 增加用户进入群聊.
            itchat.add_member_into_chatroom(chatroomUserName, memberList[0], useInvitation=False)

### 4. Uins : 通过Uin唯一的确定好友与群聊。

Uin 是微信中用于标识用户的方式, 每一个用户/群聊都有唯一且不同的 Uin.
通过 Uin, 即使退出了重新登录, 也可以轻松的确认正在对话的是上一次登录的哪一个用户.

Uin 与其他值不同, 微信后台做了一些限制, 必须通过特殊的操作才能获取. 首次点开登录用的手机端的某个好友或者群聊, itchat 就能获取到该好友或者群聊 Uin. 如果想要通过程序获取, 可以用程序将某个好友或者群聊置顶(取消置顶).

**示例程序**:

    import re, sys, json
    import itchat
    from itchat.content import *

    itcaht.auto_login()

    @itchat.msg_register(SYSTEM)
    def get_uin(msg):
        if msg["SystemInfo"] != 'unis':
            return
        ins = itchat.instanceList[0]
        fullContact = ins.memberList + ins.chatroomList + ins.mpList
        print("** Uin updated **")
        for username in msg["Text"]:
            member = itchat.utils.search_dict_list(fullContact, 'UserName', username)
            print(("%s: %s" % (member.get("NickName", ''), member["Uin"])).encode(sys.stdin.encoding, 'replace'))

    itchat.run(True)

每当 Uin 更新了, 就会打印相应的更新情况. 同样, 吐过希望获取 Uin 更新的情况, 也统过获取`SYSTEM`类型的消息实现.

## 七. Q & A
### 1. 中文文件名文件上传

    Q: 为什么中文的文件没有办法上传？

    A: 这是由于requests的编码问题导致的。若需要支持中文文件传输，将fields.py(py3版本见这里)文件放入requests包的packages/urllib3下即可

### 2. 命令行显示二维码

    Q: 为什么我在设定了itchat.auto_login()的enableCmdQR为True后还是没有办法在命令行显示二维码？

    A: 这是由于没有安装可选的包pillow，可以使用右边的命令安装：pip install pillow

### 3. 如何通过itchat实现控制器

    Q: 如何通过这个包将自己的微信号变为控制器？

    A: 有两种方式：发送、接受自己UserName的消息；发送接收文件传输助手（filehelper）的消息

## 八. itchat 方法汇总:

    itchat.add_friend                  
    itchat.new_instance                
    itchat.add_member_into_chatroom    
    itchat.originInstance              
    itchat.auto_login                  
    itchat.returnvalues                
    itchat.check_login                 
    itchat.run                         
    itchat.components                  
    itchat.search_chatrooms            
    itchat.config                      
    itchat.search_friends              
    itchat.configured_reply            
    itchat.search_mps                  
    itchat.content                     
    itchat.send                        
    itchat.core                        
    itchat.send_file                   
    itchat.Core                        
    itchat.send_image                  
    itchat.create_chatroom             
    itchat.send_msg                    
    itchat.delete_member_from_chatroom 
    itchat.send_raw_msg                
    itchat.dump_login_status           
    itchat.send_video                  
    itchat.get_chatrooms               
    itchat.set_alias                   
    itchat.get_contact                 
    itchat.set_chatroom_name           
    itchat.get_friends                 
    itchat.set_logging                 
    itchat.get_head_img                
    itchat.set_pinned                  
    itchat.get_mps                     
    itchat.show_mobile_login           
    itchat.get_msg                     
    itchat.start_receiving             
    itchat.get_QR                      
    itchat.storage                     
    itchat.get_QRuuid                  
    itchat.update_chatroom             
    itchat.instanceList                
    itchat.update_friend               
    itchat.load_login_status           
    itchat.upload_file                 
    itchat.log                         
    itchat.utils                       
    itchat.login                       
    itchat.VERSION                     
    itchat.logout                      
    itchat.web_init                    
    itchat.msg_register

## 九. Github
[itchat](https://github.com/littlecodersh/ItChat/)