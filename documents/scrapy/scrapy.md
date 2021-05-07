
## 一. Scrapy 架构组件

| P13 组件 | 描述 | 类型 |
| -- | -- | -- |
| ENGINE | 引擎,  |  |
| SCHEDULER | 调度器,  |  |
| DOWNLOADER | 下载器,  |  |
| SPIDER | 爬虫,  |  |
| MIDDLEWARE | 中间件,  |  |
| ITEM PIPELINE | 数据管道,  |  |

![Scrapy 架构图](imgs/scrapy_architecture_02.png)

框架中的数据流

| P14 对象 | 描述 |
| -- | -- |
| REQUEST | Scrapy 中的 HTTP 请求对象 |
| RESPONSE | Scrapy 中的 HTTP 响应对象 |
| ITEM | 从页面中爬去的一项数据 |

`Request(url[, callback, method='GET', headers, body, cookies, meta, encoding='utf-8', priority=0, dont_filter=False, errback])`

Response 对象
1. `HtmlResponse`
2. `TextResponse`
3. `XmlResponse`

## 二. Spider

`start_urls.parse / start_requests.callback --> REQUEST --> DOWNLOADER --> RESPONSE --> Selector/SelectorList[xpath/css][extract/re/extract_first/re_first]`

## 三. Selector 提取数据

1. 构造 Selector
    ```python
    html = "
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>Title</title>
        </head>
        <body>
            <h1>Hello world!</h1>
            <p>This is a line.</p>
        </body>
        </html>"

    # 使用文本字符串构造
    from scrapy.selector import Selector
    selector = Selector(text=html)

    # 使用 Response 对象构造
    from scrapy.http import HtmlResponse
    response = HtmlResponse(url="http://www.example.com", body=body, encoding='utf-8')
    selector = Selector(response=response)
    ```
2. RESPONSE 内置 selector : 在第一次访问一个 Response 对象的 selector 属性时, Response 对象内部会以自身为参数, 自动创建 Selector 对象, 并将该 Selector 对象缓存, 以便下次使用.
    ```python
    class TextResponse(Response):
        def __init__(self, *args, **kwargs):
            ...
            self._cached_selector = None
            ...

        @property
        def selector(self):
            from scrapy.selector import Selector
            if self._cached_selector is None:
                self._cached_selector = Selector(self)
            return self._cached_selector

        ...

        def xpath(self, query, **kwargs):
            return self.selector.xpath(query, **kwargs)

        def css(self, query):
            return self.selector.css(query)
    ```

3. 选中数据 `XPATH/CSS`

4. 提取数据 `extract()/re()/extract_first()/re_first()`

## 四. Item 封装数据
Scrapy 提供一下两个类, 用户可以使用它们自定义数据类(如书籍信息), 封装爬取到的数据.

- `Item 基类` : 自定义数据类的基类, 支持字典接口(访问 自定义数据类 中的字段与访问字典类似, 支持 get() 方法).
- `Field 类`  : 用来描述自定义数据类包含哪些字段(如name, price 等).

### 1. 自定义数据类, 只需继承 Item, 并创建一系列 Field 对象的类属性即可, 类似于 ORM 创建的 Model.
```python
from scrapy import Item, Field


class BookItem(Item):
    name = Field()
    price = Field()


class ForeignBookItem(BookItem):
    """
    扩展 BookItem 类
    """
    translator = Field()
```

### 2. Field 元数据

```python
class BookItem(Item):
    name = Field(a=123, b=[1,2,3])
    price = Field(a=lambda x: x+2)

# Field 是 Python 字典的子类, 可以通过键获取 Field 对象中的元数据.

b = BookItem(name=100, price=101)
b['name']   # 100
b['price']  # 101
b.fields    # {'name': {'a': 123, 'b': [1, 2, 3]}, 'price': {'a': <function __main__.<lambda>>}}
```
### 代码示例
```
class BookItem(Item):
    ...
    # 当 authors 是一个列表而不是一个字符串时, 串行化为一个字符串.
    authors = Field(serializer=lambda x: "|".join(x))
    ...
```
以上例子中, 元数据键 serializer 时 CSVItemExportr 规定好的, 他会用该键获取元数据, 即一个串行化函数对象, 并使用这个串行化函数将 authors 字符串行化成一个字符串, 具体代码参考 `scrapy/exporters.py` 文件. 

## 五. Item Pipeline 处理数据
在 Scrapy 中, Item Pipeline 是处理数据的组件, 一个 Item Pipeline 就是一个包含特定接口的类, 通常只负责一种功能的数据处理, 在一个项目中可以同时启动多个 Item Pipeline, 他们按指定次序级联起来, 形成一条数据处理流水线.

Item Pipeline 典型应用

- 数据请求
- 验证数据有效性
- 过滤重复数据
- 将数据存入数据库.

### 1. 编写 pipeline
```
class PriceConverterPipeline(object):

    # 英镑兑换人民币汇率
    exchange_rate = 8.5309

    def process_item(self, item, spider):
        # 提取 item 的 price 字段(如 £ 53.74), 去掉 £ 符号, 转换为 float 类型, 乘以汇率
        price = float(item["price"][1:]) * self.exchange_rate

        # 保留两位小数赋值,
        item["price"] = "¥ %.2f" % price

        return item
```
一个 Item Pipeline 不需要继承特定基类, 只需要实现某些特定的方法.

- `process_item(self, item, spider)` : 该方法必须实现.
    该方法用来处理每一项由 Spider 爬取到的数据, 其中 item 为爬取到的一项数据, Spider 为爬取此项数据的 Spider 对象.

    `process_item` 是 Item Pipeline 的核心, process_item 返回的一项数据, 会传递给下一级 Item Pipeline(如果有) 继续处理.

    如果 process_item 在处理某项 item 时抛出 DropItem(scrapy.exceptions.DropItem) 异常, 该项 item 便会被抛弃, 不会传递到下一级 Item Pipeline, 也不会导出到文件. 通常, 在检测到无效数据, 或者希望过滤的数据时, 抛出该异常.

- `open_spider(self, spider)`
    
    Spider 打开时(处理数据前), 回调该方法, 通常该方法用于在 开始处理数据之前完成某些**初始化**的工作, 如连接数据库.

- `close_spider(self, spider)`
    
    Spider 关闭时(处理数据后), 回调该方法, 通常该方法用于在 处理完所有数据之后完成某些**清理**工作, 如关闭数据库链接.

- `from_crawler(cls, crawler)`
    
    创建 Item Pipeline 对象时回调该类方法. 通常, 在该方法中通过 crawler.settings 读取配置, 根据配置创建 Item Pipeline 对象.

    如果一个 Item Pipeline 定义了 from_crawler 方法, Scrapy 就会调用该方法来创建 Item Pipeline 对象. 该方法的两个参数:
    - `cls` : Item Pipeline 类的对象,
    - `crawler` : crawler 是 Scrapy 中的一个核心对象, 可以通过 crawler.settings 属性访问配置文件.


### 2. 启用 Item Pipeline.
```
$ cat settings.py

    ITEM_PIPELINES = {
        'example.pipelines.PriceConverterPipeline': 300,
    }
```
`ITEM_PIPELINES` 是一个字典, 其中每一项 Item Pipeline 类的导入路径, 值是一个 0~1000 的数字, 同时启用多个 Item Pipeline 时, Scrapy 根据这些数值决定各 Item Pipeline 处理数据的先后次序, 数值小的优先级高.

### 3. 代码示例
#### 3.1 Item Pipeline : 过滤重复数据
```
class DuplicatesPipeline(object):
    def __init__(self):
        self.book_set = set()

    def process_item(self, item, spider):
        name = item["name"]
        if name in self.book_set:
            raise DropItem("Duplicate book found: %s" % item)

        self.book_set.add(name)
        return item
```
#### 3.2 Item Pipeline : 将数据存储 MongoDB
```python
# pipelines.py
class MongoDBPipeline(object):

    @classmethod
    def from_crawler(cls, crawler):
        """
        使用 settings.py 配置文件, 配置 MongoDB 数据库, 而不是硬编码
        如果一个 Item Pipeline 定义了 from_crawler 方法,
        Scrapy 就会调用该方法来创建 Item Pipeline 对象.
        """
        cls.DB_URI = crawler.settings.get("MONGO_DB_URI",
                                            "mongodb://localhost:27017/")

        cls.DB_NAME = crawler.settings.get("MONGO_DB_NBAME", "scrapy_data")

        return cls()

    def open_spider(self, spider):
        """在开始处理数据之前, 链接数据库"""
        self.client = pymongo.MongoClient(self.DB_URI)
        self.db = self.client[self.DB_NAME]

    def close_spider(self, spider):
        """数据处理完成之后, 关闭数据库链接"""
        self.client.close()

    def process_item(self, item, spider):
        """将 item 数据 写入 MongoDB"""
        collection = self.db[spider.name]
        post = dict(item) if isinstance(item, Item) else item
        collection.insert_one(post)

        return item

# settings.py
MONGO_DB_URI = "mongodb://192.168.1.1:27017/"
MONGO_DB_NBAME = "my_scrapy_data"

ITEM_PIPELINES = {
    "toscrapt_book.pipelines.MongoDBPipeline": 403,
}
```
#### 3.3 Item Pipeline : 将数据存储 Mysql
版本一 : 
```
# pipelines.py
class MySQLPipeline(object):
    def open_spider(self, spider):
        db = spider.settings.get("MYSQL_DB_NAME", "scrapy_data")
        host = spider.settings.get("MYSQL_HOST", "locahost")
        port = spider.settings.get("MYSQL_PORT", "3306")
        user = spider.settings.get("MYSQL_USER", "root")
        password = spider.settings.get("MYSQL_PASSWORD", "123456")

        self.db_conn = MySQLdb.connect(host=host, port=port, db=db, user=user, passwd=password, charset="utf-8")
        self.db_cur = self.db_conn.cursor()

    def closer_spider(self, spider):
        self.db_conn.commit()
        self.db_conn.close()

    def procecss_item(self, item, spider):
        self.insert_db(item)

        return item

    def insert_db(self, item):
        values = (
            item["name"],
            item["price"],
            item["rating"],
            item["number"]
        )

        sql = "INSERT INTO books VALUES (%s, %s, %s, %s, )"
        self.db_cur.execute(sql, values)


# settings.py
MYSQL_DB_NAME = "scrapy_data"
MYSQL_HOST = "locahost"
MYSQL_PORT = "3306"
MYSQL_USER = "root"
MYSQL_PASSWORD = "123456"

ITEM_PIPELINES = {
    "toscrapt_book.pipelines.MySQLPipeline": 403,
}
```
版本二: Scrapy 框架本身使用 Twisted 编写, Twisted 是一个事件驱动型的异步网络框架, 鼓励用户编写异步代码, Twisted 中提供了以异步方式多线程访问数据库的模块 `adbapi`, 使用该模块可以显著提高程序访问数据库的效率.
```python
# pipelines.py
from twisted.enterprise import adbapi

class MySQLAsyncPipeline(object):
    def open_spider(self, spider):
        db = spider.settings.get("MYSQL_DB_NAME", "scrapy_data")
        host = spider.settings.get("MYSQL_HOST", "locahost")
        port = spider.settings.get("MYSQL_PORT", "3306")
        user = spider.settings.get("MYSQL_USER", "root")
        password = spider.settings.get("MYSQL_PASSWORD", "123456")

        # adbapi.ConnectionPool 可以创建一个数据库连接池对象, 其中包含多个链接对象, 每个链接对象在单独的线程中工作.
        # adbapi 只提供异步访问数据库的框架, 其内部依然使用 MySQLdb, sqlite3 这样的库访问数据库.
        self.dbpool = adbapi.ConnectionPool("MySQLdb", host=host, database=db,
                                            user=user, password=password, charset="utf-8")

    def close_spider(self, spider):
        self.dbpool.close()

    def process_item(self, item, spider):
        # 以异步方式调用 insert_db 方法, 执行完 insert_db 方法之后, 链接对象自动调用 commit 方法.
        self.dbpool.runInteraction(self.insert_db, item)
        return item

    def insert_db(self, tx, item):
        # tx 是一个 Transaction 对象, 其接口与 Cursor 对象类似, 可以调用 execute 执行 SQL 语句.
        values = (
            item["name"],
            item["price"],
            item["rating"],
            item["number"]
        )

        sql = "INSERT INTO books VALUES (%s, %s, %s, %s, )"
        tx.execute(sql, values)

# settings.py
MYSQL_DB_NAME = "scrapy_data"
MYSQL_HOST = "locahost"
MYSQL_PORT = "3306"
MYSQL_USER = "root"
MYSQL_PASSWORD = "123456"

ITEM_PIPELINES = {
    "toscrapt_book.pipelines.MySQLAsyncPipeline": 403,
}
```
#### 3.4 Item Pipeline : 将数据存储 Redis
```
    # pipelines.py
    import redis
    from scrapy import Item

    class RedisPipeline(object):
        def open_spider(self, spider):
            db_host = spider.settings.get("REDIS_HOST", "localhost")
            db_port = spider.settings.get("REDIS_PORT", "6379")
            db_index = spider.settings.get("REDIS_DB_INDEX", 0)
            
            self.db_conn = redis.StrictRedis(host=db_host, port=db_port, db=db_index)
            self.item_i = 0
        
        def close_spider(self, spider):
            self.db_conn.connection_pool.disconnect()
        
        def process_item(self, item, spider):
            self.insert_db(item)
            
            return item
        
        def insert_db(self, item):
            if isinstance(item, Item):
                item = dict(item)
            
            self.item_i += 1
            self.db_conn.hmset("book:%s" % self.item_i, item)


    # settings.py
    "REDIS_HOST" = "localhost"
    "REDIS_PORT" = 6379
    "REDIS_DB_INDEX" = 0

    ITEM_PIPELINES = {
        "toscrapt_book.pipelines.RedisPipeline": 403,
    }    
```
## 六. LinkExtractor 提取链接

提取页面中的链接, 有两种方法:

- `selector` : 提取少量链接时, 或提取规则比较简单.
- `LinkExtractor` : 专门用于提取链接的类 LinkExtractor.

### 1. 使用示例:
```
    # url from selector
    # next_url = response.css("ul.pager li.next a::attr(href)").extract_first()
    # if next_url:
    #     next_url = response.urljoin(next_url)
    #     yield scrapy.Request(next_url, callback=self.parse)

    # url from LinkeExtractor
    le = LinkExtractor(restrict_css="ul.pager li.next")
    links = le.extract_links(response)      # 返回一个列表, 其中每一个元素都是一个 Link 对象, Link 对象的 url 属性便是链接页面的 绝对 url 地址.

    if links:
        next_url = links[0].url
        yield scrapy.Request(next_url, callback=self.parse)
```
### 2. 链接提取规则:

LinkExtractor 构造器的所有参数都有默认值, 如果构造对象时, 不传递任何参数(使用默认值), 则提取页面中的所有链接.

- `allow` : 接受一个正则表达式或一个正则表达式列表, 提取绝对 url 与 正则表达式匹配的链接, 如果该参数为空(默认), 则提取全部链接.
    ```
    >>> pattern = '/intro/.+\.html$'
    >>> le = LinkExtractor(allow=pattern)
    >>> links = le.extract_links(response)
    ```
- `deny` : 接受一个正则表达式或一个正则表达式列表,  与 allow 相反, 排除绝对 url 与正则表示匹配的链接.
    ```
    >>> pattern = '^http://example.com'
    >>> le = LinkExtractor(deny=pattern)
    >>> links = le.extract_links(response)
    ```
- `allow_domains` : 接受一个域名或一个域名列表, 提取到指定域的链接.
    ```
    >>> domains = ["github.com", "stackoverflow.com"]
    >>> le = LinkExtractor(allow_domains=domains)
    >>> links = le.extract_links(response)
    ```
- `deny_domains` :  接受一个域名或一个域名列表, 与 allow_domains 相反, 排除到指定域的链接.
    ```
    >>> domains = ["github.com", "stackoverflow.com"]
    >>> le = LinkExtractor(deny_domains=domains)
    >>> links = le.extract_links(response)
    ```
- `restrict_xpaths` : 接受一个 Xpath 表达式或一个 Xpath 表达式列表, 提取 XPath 表达式选中区域下的的链接.
    ```
    >>> le = LinkExtractor(restrict_xpaths="//div[@id='top']")
    >>> links = le.extract_links(response)
    ```
- `restrict_css` : 接受一个 CSS 选择器或一个 CSS 选择器列表, 提取 CSS 选择器选中区域下的的链接.
    ```
    >>> le = LinkExtractor(restrict_css="div#bottom")
    >>> links = le.extract_links(response)
    ```
- `tags` : 接受一个标签(字符串)或一个标签列表, 提取指定标签内的链接, 默认为 `["a", "area"]`

- `attrs` : 接受一个属性(字符串)或一个属性列表, 提取指定属性内的链接, 默认为 `["href"]`
    ```
    # <script type="text/javascript" src="/js/app.js" />

    >>> le = LinkExtractor(tags="script", attrs="src")
    >>> links = le.extract_links(response)
    ```
- `process_value` : 接受一个形如 `func(value)` 的回调函数. 如果传递了该参数, LinkExtractor 将调用该回调函数对提取的每一个链接(如 a 的 href) 进行处理, 回调函数正常情况下应该返回一个字符串(处理结果), 想要抛弃所处理的连接时, 返回 None.
    ```
    # <a href="javascript:goToPage('/doc.html'); return false">文档</a>

    >>> import re
    >>> def process(value):
            m = re.search("javascript:goToPage\('(.*?)'", value)
            # 如果匹配, 就提取其中 url 并返回, 不匹配则返回原值.
            if m:
                value = m.group()
            return value

    >>> le = LinkExtractor(process_value=process)
    >>> links = le.extract_links(response)      
    ```

## 七. Exporter 导出数据

在 Scrapy 中, 负责导出数据的组件被称为 Exporter(导出器), Scrapy 内部实现了多个 Exporter , 每个 Exporter 实现一种数据格式的导出. 支持的数据导出格式如下(括号内为对应的  Exporter):

- JSON (JsonItemExporter)
- JSON lines (JsonLinesItemExporter)
- CSV (CsvItemExporter)
- XML (XmlItemExporter)
- Pickle (PickleItemExporter)
- Marshal (MarshalItemExporter)

Scrapy 爬虫会议 `-t` 参数中的数据格式字符串(如 csv, json, xml) 为键, 在配置字典 `FEED_EXPORTERS` 中搜索 Exporter, `FEED_EXPORTERS` 的内容由以下两个字典的内容合并而成:

- 默认配置文件中的 `FEED_EXPORTERS_BASE`, 为 Scrapy 内部支持的导出数据格式, 位于 `scrapy.settings.default_settings`
- 用户配置文件中的 `FEED_EXPORTERS`, 为用户自定义的导出数据格式, 在配置文件 `settings.py` 中.
    ```
    FEED_EXPORTERS = {"excel": "my_propject.my_exporters.ExcelItemExporter"}
    ```

### 1. 导出数据方式:

1. 命令行参数
    ```
    $ scrapy crawl CRAWLER -t FORMAT -o /path/to/save.file 
    $ scrapy crawl books -t csv -o books.data
    $ scrapy crawl books -t xml -o books.data
    $ scrapy crawl books -t json -o books.data

    $ scrapy craw books -o books.csv    # Scrapy 可以通过文件后缀名, 推断出文件格式, 从而省去 -t 参数. 如 `-o books.json`
    ```

    `-o /path/to/file` 支持变量: 如 `scrapy crawl books -o 'export_data/%(name)s/%(time)s.csv'`
    - `%(name)s` : Spider 的名字
    - `%(time)s` : 文件创建时间

2. 通过配置文件指定.
    
    常用选项如下:

    - `FEED_URL` : 导出文件路径
        ```
        FEED_URL = 'export_data/%(name)s/%(csv)s.data'
        ```
    - `FEED_FORMAT` : 导出数据格式
        ```
        FEED_FORMAT = 'csv'
        ```
    - `FEED_EXPORT_ENCODING` : 导出文件编码, 默认 json 使用数字编码, 其他使用 utf-8 编码
        ```
        FEED_EXPORT_ENCODING = "gbk"
        ```
    - `FEED_EXPORT_FIELDS` : 导出数据包含的字段(默认情况下, 导出所有字段), 并指定导出顺序.
        ```
        FEED_EXPORT_FIELDS = ["name", "author", "price"]
        ```
    - `FEED_EXPORTERS` : 用户自定义的 Exporter 字典, 添加新的导出数据格式时使用.
        ```
        FEED_EXPORTERS = {"excel": "my_project.my_exporters.ExcelItemExporter"}
        ```

### 2. 自定义数据导出格式

```python
import six
from scrapy.utils.serialize import ScrapyJSONEncoder
import xlwt

class BaseItemExporter(object):
    def __init__(self, **kwargs):
        self._configure(kwargs)

    def _configure(self, options, dont_fail=False):
        self.encoding = options.pop("encoding", None)
        self.fields_to_export = options.pop("field_to_export", None)
        self.export_empty_fields = options.pop("export_empty_fields", False)

        if not dont_fail and options:
            raise TypeError("Unexpected options: %s" % ','.join(options.keys()))

    def export_item(self, item):
        """
        负责导出爬去到的每一项数据, 参数 item 为一项爬取到的数据, 每个子类必须实现该方法.
        :param item:
        :return:
        """
        raise NotImplementedError

    def serialize_field(self, field, name, value):
        serializer = field.get("serializer", lambda x: x)
        return serializer(value)

    def start_exporting(self):
        """
        在导出开始时被调用, 可在该方法中执行某些初始化操作.
        :return:
        """
        pass

    def finish_exporting(self):
        """
        在导出完成时被调用, 可在该方法中执行某些清理工作.
        :return:
        """
        pass

    def _get_serialized_field(self, item, default_value=None, include_empty=None):
        """
        Return the fields to export as an iterable of tuples (name, serialized_value)
        :param item:
        :param default_value:
        :param include_empty:
        :return:
        """
        if include_empty is None:
            include_empty = self.export_empty_fields

        if self.fields_to_export is None:
            if include_empty and not isinstance(item, dict):
                field_iter = six.iterkeys(item.fields)
            else:
                field_iter = six.iterkeys(item)
        else:
            if include_empty:
                field_iter = self.fields_to_export
            else:
                field_iter = (x for x in self.fields_to_export if x in item)

        for field_name in field_iter:
            if field_name in item:
                field = {} if isinstance(item, dict) else item.fields[field_name]
                value = self.serialize_field(field, field_name, item[field_name])
            else:
                value = default_value

            yield field_name, value

# json
class JsonItemExporter(BaseItemExporter):
    def __init__(self, file, **kwargs):
        self._configure(kwargs, dont_fail=True)
        self.file = file
        kwargs.setdefault("ensure_ascii", not self.encoding)
        self.encoder = ScrapyJSONEncoder(**kwargs)
        self.first_item = True

    def start_exporting(self):
        """
        保证最终导出结果是一个 json 列表.
        :return:
        """
        self.file.write(b"[\n")

    def finish_exporting(self):
        """
        保证最终导出结果是一个 json 列表.
        :return:
        """
        self.file.write(b"\n]")

    def export_item(self, item):
        """
        调用 self.encoder.encode 将每一项数据转换成 json 串.
        :param item:
        :return:
        """
        if self.first_item:
            self.first_item = False
        else:
            self.file.write(b",\n")

        itemdict = dict(self._get_serialized_field(item))
        data = self.encoder.encode(itemdict)
        self.file.write(to_bytes(data, self.encoding))

# 自定义 excel 导出格式.
class ExcelItemExporter(BaseItemExporter):
    def __init__(self, file, **kwargs):
        self._configure(kwargs)
        self.file = file
        self.wbook = xlwt.Workbook()
        self.wsheet = self.wbook.add_sheet("scrapy")
        self.row = 0

    def finish_exporting(self):
        self.wbook.save(self.file)

    def export_item(self, item):
        fields = self._get_serialized_field(item)   # 获取所有字段的迭代器.
        
        for col, v in enumerate(x for _, x in fields):
            self.wsheet.write(self.row, col, v)

        self.row += 1

$ vim settings.py

    # my_exporters.py 与 settings.py 位于同级目录下.
    FEED_EXPORTERS = {"excel": "example.my_exporters.ExcelItemExporter"}
```

## 八. 下载文件(FilesPipeline)和图片(ImagesPipeline)
    
FilesPipeline 和 ImagesPipeline 可以看做两个特殊的下载器, 用户使用时, 只需要铜鼓 item 的一个特殊字段将要下载文件或图片的 URL 传递给他们, 他们会自动将文件或图片下载到本地, 并将下载结果信息存入 item 的另一个特殊字段, 以便用户在导出文件中查阅.

### 1. FilesPipeline 使用方法
    
1. 在 settings.py 中启用 FilesPipeline, 通常将其置于其他 Item Pipelines 之前
    ```
    ITEM_PIPELINES = {"scrapy.pipelines.files.FilesPipeline": 1}
    ```
2. 在 settings.py 中使用 FILES_STORE 指定文件下载目录.
    ```
    FILES_STORE = "/path/to/my/download"
    ```
3. 下载文件
    
    在 Spider 解析一个包含文件下载链接的也面试, 将所有需要下载文件的 url 地址收集到一个列表, 赋给 item 的 `file_urls` 字段(`item["file_urls"]`). FilesPipeline 在处理每一项 item 时, 会读取 `item['file_urls']`, 对其中每一个 url 进行下载.
    ```python
    class DownloadBookSpider(scrapy.Spider):
        ...
        def parse(response):
            item = {}
            item["file_urls"] = []

            for url in response.xpath("//a/@href").extract():
                download_url = response.urljoin(url)
                item["file_urls"].append(download_url)

            yield item
    ```
    当 FilesPipeline 下载完 `item["file_urls"]` 中的所有文件后, 会将各文件的下载结果信息收集到另一个列表, 赋给 `item["files"]` 字段, 下载信息结果包含以下内容:

    - `Path` : 文件下载到本地的路径, 相对于 FILES_STORE 的相对路径.
    - `Checksum` : 文件的校验和
    - `url` : 文件的 url 地址.

#### 示例代码
```python
# items.py
import scrapy

class MatplotlibFileItem(scrapy.Item):
    file_urls = scrapy.Field()
    files = scrapy.Field()  

# spiders/matplotlib.py
import scrapy
from scrapy.linkextractors import LinkExtractor

from ..items import MatplotlibFileItem


class MatplotlibSpider(scrapy.Spider):
    name = 'matplotlib'
    allowed_domains = ['matplotlib.org']
    start_urls = ['https://matplotlib.org/examples/index.html']

    def parse(self, response):
        # 爬取所有 二级 页面地址
        le = LinkExtractor(restrict_css="div.toctree-wrapper.compound", deny="/index.html$")
        links = le.extract_links(response)
        for link in links:
            yield scrapy.Request(link.url, callback=self.parse_page)

    def parse_page(self, response):
        href = response.css("a.reference.external::attr(href)").extract_first()
        url = response.urljoin(href)

        example = MatplotlibFileItem()
        example["file_urls"] = [url]

        yield example

# pipelines.py : 重写 FilesPipeline 的 file_path 代码, 以自定义保存路径.
from scrapy.pipelines.files import FilesPipeline
from urlparse import urlparse
from os.path import basename, dirname, join

class MyFilesPipeline(FilesPipeline):

    def file_path(self, request, response=None, info=None):
        path = urlparse(request.url).path
        return join(basename(dirname(path)), basename(path))

# settings.py
ITEM_PIPELINES = {

    # "scrapy.pipelines.files.FilesPipeline": 1,
    'matplotlib_file.pipelines.MyFilesPipeline': 1,
}

FILES_STORE = "example_src"         # 文件下载路径

# 运行:
$ scrapy crawl matplotlib -o examp.json
```
### 2. ImagesPipeline
图片本身也是文件, ImagesPipeline 是 FilesPipeline 的子类, 使用上和 FilesPipeline 大同小异, 只是在所使用的 item 字段和配置选项上略有差别.

| Desc | FilesPipeline | ImagesPipeline |
| -- | -- | -- |
| 导入路径 | `scrapy.pipelines.files.FilesPipeline` | `scrapy.pipelines.images.ImagesPipeline` |
| Item 字段 | `file_urls`, `files` | `image_urls`, `images` |
| 下载目录 | `FILES_STORE` | `IMAGES_STORE` |

#### 2.1 生成缩略图
在 `settings.py` 中设置 `IMAGES_THUMBS`, 他是一个字典, 每一项的值是缩略图的尺寸.
```  
IMAGES_THUMBS = {
    "small": (50, 50),
    "big": (270, 270)
}
```
开启该功能后, 下载一张图片时, 会在本地出现 3 张图片, 其存储路径如下:
```
[IMAGES_STORE]/full/name.jpg
[IMAGES_STORE]/thumbs/small/name.jpg
[IMAGES_STORE]/thumbs/big/name.jpg
```
#### 2.2 过滤尺寸过小的图片

在 `settings.py` 中设置 `IMAGES_MIN_WIDTH` 和 `IMAGES_MIN_HEIGHT`
```
IMAGES_MIN_WIDTH = 110
IMAGES_MIN_HEIGHT = 110
```
##### 示例代码
```python
# settings.py
ITEM_PIPELINES = {
    "scrapy.pipelines.images.ImagesPipeline": 1,
    # 'so_img.pipelines.SoImgPipeline': 300,
}
IMAGES_STORE = 'download_images'

# spider
import json
import scrapy

class ImagesSpider(scrapy.Spider):
    IMG_TYPE = "wallpaper"
    IMG_START = 0
    BASE_URL = "http://image.so.com/zj?ch=%s&sn=%s&listtype=new&temp=1"

    name = 'wallpaper'
    # allowed_domains = ['image.so.com']
    start_urls = [BASE_URL % (IMG_TYPE, IMG_START)]

    MAX_DOWNLOAD_NUM = 100
    start_index = 0

    def parse(self, response):
        infos = json.loads(response.body.decode("utf-8"))
        yield {"image_urls": [info["qhimg_url"] for info in infos["list"]]}

        # 如果 count 字段大于 0, 并且下载数量不足 MAX_DOWNLOAD_NUM, 继续获取下一页信息.

        self.start_index += infos["count"]
        if infos["count"] > 0 and self.start_index < self.MAX_DOWNLOAD_NUM:
            yield scrapy.Request(self.BASE_URL % (self.IMG_TYPE, self.start_index))

# 爬取图片
$ scrapy crawl wallpaper
```
## 九. 模拟登陆
Scrapy 提供一个 `FormRequest 类(Request 的子类)`, 专门用于构造含有表单数据的请求, FormRequest 的构造器方法有一个 formdata 参数, 接受字典形式的表单数据.

1. 直接构造 FormRequest 
    ```shell
    $ scrapy shell http://example.webscraping.com/places/default/user/login

    >>> sel = response.xpath('//div[@style]/input')
    >>> sel
        [<Selector xpath='//div[@style]/input' data=u'<input name="_next" type="hidden" value='>,
            <Selector xpath='//div[@style]/input' data=u'<input name="_formkey" type="hidden" val'>,
            <Selector xpath='//div[@style]/input' data=u'<input name="_formname" type="hidden" va'>]
    >>> fd = dict(zip(sel.xpath('./@name').extract(), sel.xpath('./@value').extract()))
    >>> fd
        {u'_formkey': u'9c751a58-3dc2-489f-bf7b-93c31fa00c7f',
            u'_formname': u'login',
            u'_next': u'/places/default/index'}
    >>> fd['email'] = "liushuo@webscraping.com"
    >>> fd['password'] = "12345678"
    >>> fd
        {u'_formkey': u'9c751a58-3dc2-489f-bf7b-93c31fa00c7f',
            u'_formname': u'login',
            u'_next': u'/places/default/index',
            'email': 'liushuo@webscraping.com',
            'password': '12345678'}
    >>> from scrapy.http import FormRequest
    >>> request = FormRequest("http://example.webscraping.com/places/default/user/login", formdata=fd)

    >>> fetch(request)
    >>> response.url
        'http://example.webscraping.com/places/default/index'
    >>> "Welcome" in response.text
        True
    ```

2. 调用 FormRequest 的 from_response 方法

    调用时, 只需传入一个 Response 对象作为第一个参数, 该方法会解析 Response 对象所包含的页面中的 <form> 元素, 帮助用户创建 FormRequest 对象, 并将隐藏 <input> 中的信息自动填入表单数据.
    ```shell
    $ scrapy shell http://example.webscraping.com/places/default/user/login

    >>> fd = {"email": "liushuo@webscraping.com", "password": "12345678"}
    >>> from scrapy.http import FormRequest
    >>> req = FormRequest.from_response(response, fd)
    >>> fetch(req)

    >>> response.url
        'http://example.webscraping.com/places/default/index'
    ```

### 1. 实现登录 Spider
```python
class LoginSpider(scrapy.Spider):
    name = "login"
    allowed_domains = ["example.webscraping.com"]
    start_urls = ["http://example.webscraping.com/places/default/user/profile"]

    login_url = "http://example.webscraping.com/places/default/user/login"

    def parse(self, response):
        keys = response.css("table label::text").re("(.+):")
        values = response.css("table td.w2p_fw::text").extract()

        yield dict(zip(keys, values))

    def start_requests(self):
        yield scrapy.Request(self.login_url, callback=self.login)

    def login(self, response):
        fd = {"email": "liushuo@webscraping.com", "password": "12345678"}
        yield scrapy.http.FormRequest.from_response(response, formdata=fd, callback=self.parse_login)

    def parse_login(self, response):
        # 如果 if 判断成功, 调用基类的 start_request() 方法, 继续爬取 start_urls 中的页面.
        if "Welcome" in response.text:
            yield from super().start_requests()     # Python 3 语法
```

### 2. 识别验证码
1. OCR 识别: `tesseract-ocr`
    
    pytesseract 可以识别的验证码比较简单, 对于某些复杂的验证码, pytesseract 识别率很低, 或无法识别.

    基本安装与使用
    ```shell
    # 安装
    $ yum install tesseract -y
    $ pip install pillow
    $ pip install pytesseract

    # 使用
    >>> from PIL import Image
    >>> import pytesseract
    >>> img = Image.open("code.png")
    >>> img = img.convert("L")          # 为提高图像识别率, 把图片转换成黑白图.
    >>> pytesseract.image_to_string(img)
    ```
    代码示例:
    ```python
    import json
    from PIL import Image
    from io import BytesIO
    import pytesseract

    class CaptchaLoginSpider(scrapy.Spider):
        name = "login_captcha"
        start_urls = ["http://xxx.com"]

        login_url = "http://xxx.com/login"
        user = "tom@example.com"
        password = "123456"

        def parse(self, response):
            pass

        def start_requests(self):
            yield scrapy.Request(self.login_url, callback=self.login, dont_filter=True)

        def login(self, response):
            """
            该方法即是登录页面的解析方法, 又是下载验证码图片的响应处理函数.
            :param response:
            :return:
            """

            # 如果 response.meta["login_response"] 存在, 当前 response 为验证码图片的响应,
            # 否则, 当前 response 为登录页面的响应.

            login_response = response.meta.get("login_response")

            if not login_response:
                # 此时 response 为 登录页面的响应, 从中提取验证码图片的 url, 下载验证码图片
                captchaUrl = response.css("label.field.prepend-icon img::attr(src)").extract_first()
                captchaUrl = response.urljoin(captchaUrl)

                yield scrapy.Request(captchaUrl, callback=self.login, meta={"login_response": response}, dont_filter=True)

            else:
                # 此时, response 为验证码图片的响应, response.body 为图片二进制数据,
                # login_response 为登录页面的响应, 用其构造表单请求并发送.
                formdata = {
                    "email": self.user,
                    "password": self.password,
                    "code": self.get_captcha_by_ocr(response.body)
                }

                yield scrapy.http.FormRequest.from_response(login_response,
                                                            callback=self.parse_login,
                                                            formdata=formdata,
                                                            dont_click=True)

        def parse_login(self, response):
            info = json.loads(response.text)

            if info["error"] == "0":
                scrapy.log.logger.info("登录成功!")
                return super().start_requests()
            scrapy.log.logger.info("登录失败!")
            return self.start_requests()

        def get_captha_by_ocr(self, data):
            img = Image.open(BytesIO(data))
            img = img.convert("L")
            captcha = pytesseract.image_to_string(img)
            img.close()
            
            return captcha
    ```
2. 网络平台识别
    
    阿里云市场提供很多验证码识别平台, 他们提供了 HTTP 服务接口, 用户通过 HTTP 请求将验证码图片发送给平台, 平台识别后将结果通过 HTTP 响应返回.

3. 人工识别
    
    在 Scrapy 下载完验证码图片后, 调用 Image.show 方法将图片显示出来, 然后调用 Python 内置的 Input 函数, 等待用户肉眼识别后输入识别结果.
    ```python
    def get_captha_by_user(self, data):
        img = Image.open(BytesIO(data))
        img.show()
        captha = input("请输入验证码: ")
        img.close()
        return captha
    ```
### 3. Cookie 登录 && CookiesMiddleware
在使用浏览器登录网站后, 包含用户身份信息的 Cookie 会被浏览器保存到本地, 如果 Scrapy 爬虫能直接使用浏览器的 Cookie 发送 HTTP 请求, 就可以绕过提交表单登录的步骤.

#### 3.1 browsercookie
第三方 Python 库 `browsercookie` 便可以获取 Chrome 和 Firefox 浏览器中的 Cookie.
```shell
$ pip install browsercookie

>>> import browsercookie
>>> chrome_cookiejar = browsercookie.chrome()
>>> firefox_cookiejar = browsercookie.firefox()

>>> type(chrome_cookiejar)
    http.cookiejar.CookieJar

>>> for cookie in chrome_cookiejar:     # 对 http.cookiejar.CookieJar 对象进行迭代, 可以访问其中的每个 Cookie 对象.
        print cookie
```
#### 3.2 CookiesMiddleware
```python
import six
import logging
from collections import defaultdict

from scrapy.exceptions import NotConfigured
from scrapy.http import Response
from scrapy.http.cookies import CookieJar
from scrapy.utils.python import to_native_str

logger = logging.getLogger(__name__)

class CookieMiddleware(object):
    """
    This middleware enables working with sites that need cookies.
    """

    def __init__(self, debug=False):
        """
        jars 中的每一项值, 都是一个 scrapy.http.cookies.CookisJar 对象,
        CookieMiddleware 可以让 Scrapy 爬虫同时使用多个不同的 CookieJar, 即多个不同的账号.
        Request(url, meta={"cookiejar": "account_1"}}

        :param debug:
        """
        self.jars = defaultdict(CookieJar)
        self.debug = debug

    @classmethod
    def from_crawler(cls, crawler):
        """
        从配置文件读取 COOKIES_ENABLED, 决定是否启用该中间件.
        :param crawler:
        :return:
        """
        if not crawler.settings.getbool("COOKIES_ENABLED"):
            raise NotConfigured
        return cls(crawler.settings.getbool("COOKIES_DEBUG"))

    def process_request(self, request, spider):
        """
        处理每一个待发送到额 Request 对象, 尝试从 request.meta["cookiejar"] 获取用户指定使用的 Cookiejar,
        如果用户未指定, 就是用默认的 CookieJar(self.jars[None]).

        调用 self._get_request_cookies 方法获取发送请求 request 应携带的 Cookie 信息, 填写到 HTTP 请求头.

        :param request:
        :param spider:
        :return:
        """
        if request.meta.get("dont_merge_cookies", False):
            request

        cookiejarkey = request.meta.get("cookiejar")
        jar = self.jar[cookiejarkey]
        cookies = self._get_request_cookies(jar, request)
        for cookie in cookies:
            jar.set_cookie_if_ok(cookie, request)

        # set Cookie header
        request.headers.pop("Cookie", None)
        jar.add_cookie_header(request)
        self._debug_cookie(request, spider)

    def process_response(self, request, response, spider):
        """
        处理每一个 response 对象, 依然通过 request.meta["cookiejar"] 获取用户指定使用的 cookiejar,
        调用 extract_cookies 方法将 HTTP 响应头部中的 Cookie 信息保存到 CookieJar 对象中.
        
        :param request:
        :param response:
        :param spider:
        :return:
        """
        if request.meta.get("dont_merge_cookies", False):
            return response

        # extract cookies from Set-Cookie and drop invalid/expired cookies.
        cookiejarkey = request.meta.get("cookiejar")
        jar = self.jars[cookiejarkey]
        jar.extract_cookies(response, request)
        self._debug_set_cookie(response, request)

        return response

    def _debug_cookie(self, request, spider):
        if self.debug:
            cl = [to_native_str(c, errors="replace") for c in request.headers.getlist("Cookie")]

            if cl:
                cookies = "\n".join("Cookie: {}\n".format(c) for c in cl)
                msg = "Sending cookies to:{}\n".format(request, cookies)
                logger.debug(msg, extra={"spider": spider})

    def _debug_set_cookie(self, response, spider):
        if self.debug:
            cl = [to_native_str(c, errors="replace") for c in response.headers.getlist("Set-Cookie")]

            if cl:
                cookies = "\n".join("Set-Cookie: {}\n".format(c) for c in cl)
                msg = "Received cookies from:{}\n".format(response, cookies)
                logger.debug(msg, extra={"spider": spider})

    def _format_cookie(self, cookie):
        # build cookie string
        cookie_str = "%s=%s" % (cookie["name"], cookie["value"])

        if cookie.get("path", None):
            cookie_str += ";Path=%s" % cookie["path"]

        if cookie.get("domain", None):
            cookie_str += ";Domain=%s" % cookie["domain"]

        return cookie_str

    def _get_request_cookies(self, jar, request):
        if isinstance(request.cookies, dict):
            cookie_list = [{"name": k, "value": v} for k, v in six.iteritems(request.cookies)]
        else:
            cookie_list = request.cookies

        cookies = [self._format_cookie(x) for x in cookie_list]

        headers = {"Set-Cookie": cookies}
        response = Response(request.url, headers=headers)

        return jar.make_cookies(response, request)
```
#### 3.3 实现 BrowserCookieMiddleware

利用 browsercookie 对 CookieMiddleware 进行改良.
```python
import browsercookie
from scrapy.downloadermiddlewares.cookies import CookiesMiddleware

class BrowserCookiesMiddleware(CookiesMiddleware):
    def __init__(self, debug=False):
        super().__init__(debug)
        self.load_browser_cookies()

    def load_browser_cookies(self):
        # for chrome
        jar = self.jars["chrome"]
        chrome_cookies = browsercookie.chrome()
        for cookie in chrome_cookies:
            jar.set_cookie(cookie)

        # for firefox
        jar = self.jars["firefox"]
        firefox_cookies = browsercookie.firefox()
        for cookie in firefox_cookies:
            jar.set_cookie(cookie)
```
使用示例:
```shell
# settings.py
USER_AGENT = "Mozilla/5.0 (X11; CrOS i686 3912.101.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36"
DOWNLAODER_MIDDLEWARES = {
    "scrapy.downloademiddleware.cookies.CookiesMiddleware": None,
    "browser_cookie.middlewares.BrowserCookiesMiddleware": 701
}

$ scrapy shell
>>> from scrapy import Request
>>> url = "https://www.zhihu.com/settings/profile"
>>> fetch(Request(url, meta={"cookiejar": 'chrome'}))
>>> view(response)
```

## 十. 爬取动态页面: Splash 渲染引擎

[Splash](http://splash.readthedocs.io/en/stable/) 是 Scrapy 官方推荐的 javascript 渲染引擎, 他是用 Webkit 开发的轻量级无界面浏览器, 提供基于 http 接口的 javascript 渲染服务, 支持如下功能:

- 为用户返回经过渲染的 HTML 页面或页面截图
- 并发渲染多个页面
- 关闭图片加载, 加速渲染
- 在页面中执行用户自定义的 javascript 代码.
- 指定用户自定义的渲染脚本(lua), 功能类似于 PhantomJS.

### 1. 安装
```shell
# 安装 docker
$ yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine -y

$ yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
$ yum install -y yum-utils device-mapper-persistent-data lvm2
$ yum install docker-ce
$ systemctl start docker

# 获取镜像
$ docker pull scrapinghub/splash

# 运行 splash 服务
$ docker run -p 8051:8051 -p 8050:8050 scrapinghub/splash
```
### 2. render.html : 提供 javascript 渲染服务

| 服务端点 | render.html |
| -- | -- |
| 请求地址 | http://localhost:8051/render.html |
| 请求方式 | GET/POST |
| 返回类型 | html | 

参数列表:

| 参数 | 是否必选 | 类型 | 描述 |
| -- | -- | -- | -- |
| url | 必选 | string | 需要渲染的页面 url |
| timeout | 可选 | float | 渲染页面超时时间 |
| proxy | 可选 | string | 代理服务器地址 |
| wait | 可选 | float | 等待页面渲染的时间 |
| images | 可选 | integer | 是否下载图片, 默认为 1 |
| js_source | 可选 | string | 用自定义的 javascript 代码, 在页面渲染前执行 |

示例: 使用 request 库调用 render.html 渲染页面.    
```shell
    >>> import requests
    >>> from scrapy.selector import  Selector
    >>> splash_url = "http://localhost:8050/render.html"
    >>> args = {"url": "http://quotes.toscrape.com/js", "timeout":5,"image":0}
    >>> response = requests.get(splash_url, params=args)
    >>> sel = Selector(response)
    >>> sel.css("div.quote span.text::text").extract()
```
### 3. execute : 指定用户自定义的 lua 脚本, 利用该断点可在页面中执行 javascript 代码.
在爬去某些页面时, 希望在页面中执行一些用户自定义的 javascript 代码, 例如, 用 javascript 模拟点击页面中的按钮, 或调用页面中的 javascript 函数与服务器交互, 利用 Splash 的 execute 端点可以实现这样的功能.

| 服务端点 | execute |
| -- | -- |
| 请求地址 | http://localhost:8051/execute |
| 请求方式 | POST |
| 返回类型 | 自定义 |

参数 :

| 参数 | 是否必选 | 类型 | 描述 |
| -- | -- | -- | -- |
| lua_source | 必选 | string | 用户自定义的 Lua 脚本 |
| timeout | 可选 | float | 渲染页面超时时间 |
| proxy | 可选 | string | 代理服务器地址 |

可以将  execute 端点的服务看做一个可用 lua 语言编程的浏览器, 功能类似于 PhantomJS. 使用时需传递一个用户自定义的 Lua 脚本给 Spalsh, 该 Lua 脚本中包含用户想要模拟的浏览器行为. 如

- 打开某 url 地址的页面
- 等待页面加载完成
- 执行 javascript 代码
- 获取 HTTP 响应头部
- 获取 Cookie

用户定义的 lua 脚本必须包含一个 `main` 函数作为程序入口, main 函数被调用时传入一个 splash 对象(lua中的对象), 用户可以调用该对象上的方法操作 Splash. main 函数的返回值可以使 字符串, 也可以是 lua 中的表(类似 python 字典), 表会被编码成 json 串.

`Splash` 对象常用属性和方法

- `splash.args`属性
    
    用户传入参数的表, 通过该属性可以访问用户传入的参数, 如 `splash.args.url`

- `splash.js_enabled`
    
    用于开启/禁止 javascript 渲染, 默认为 True

- `splash.images_enabled`
    
    用于开启/禁止 图片加载, 默认为 True

- `splash:go()`
    
    `splash:go(url, baseurl=nil, headers=nil, http_method="GET", body=nil, formdata=nil)` 类似于在浏览器中打开某 url 地址的页面, 页面所需资源会被加载, 并进行 javascript 渲染, 可以通过参数指定 HTTP 请求头部, 请求方法, 表单数据等.
    
- `splash:wait()`
    
    `splash:wait(time, cancel_on_redirect=false, cancel_on_error=true)` 等待页面渲染, time 参数为等待的秒数.

- `splash:evaljs()`
    
    `splash:evaljs(snippet)` 在当前页面下, 执行一段 javascript 代码, 并返回**最后一句表达式的值**.

- `splash:runjs()`
    
    `splash:runjs(snippet)` 在当前页面下, 执行一段 javascript 代码, 与 evaljs 相比, 该函数只执行代码, **不返回值**.

- `splash:url()`
    
    获取当前页面的 url

- `splash:html()`
        
    获取当前页面的 html 文本.

- `splash:get_cookits()`
    
    获取全部 cookie 信息.

示例代码: requests 库调用 execute 端点服务
```shell
>>> import json
>>> lua_script = """
    ...: function main(splash)
    ...:     splash:go('http://example.com')
    ...:     splash:wait(0.5)
    ...:     local title = splash:evaljs("document.title")
    ...:     return {title=title}
    ...: end """
>>> splash_url = "http://localhost:8050/execute"
>>> headers = {"content-type": "application/json"}
>>> data = json.dumps({"lua_source": lua_script})
>>> response = requests.post(splash_url, headers=headers, data=data)

>>> response.content
>>> '{"title": "Example Domain"}'

>>> response.json()
>>> {u'title': u'Example Domain'}
```
### 4. scrapy-splash 
1. 安装
    ```
    $ pip install scrapy-splash
    ```
2. 配置
    ```shell
    $ cat settings.py
        # Splash 服务器地址
        SPLASH_URL = "http://localhost:8050"

        # 开启 Splash 的两个下载中间件并调整 HttpCompressionMiddleware 的次序
        DOWNLOADER_MIDDLEWARES = {
            "scrapy_splash.SplashCookiesMiddleware": 723,
            "scrapy_splash.SplashMiddleware": 725,
            "scrapy.downloadermiddlewares.httpcompression.HttpCompressionMiddleware": 810,
        }

        # 设置去重过滤器
        DUPEFILTER_CLASS = "scrapy_splash.SplashAwareDupeFilter"

        # 用来支持 cache_args (可选)
        SPIDER_MIDDLEWARES = {
            "scrapy_splash.SplashDeduplicateArgsMiddleware": 100,
        }
    ```

3. 使用 

    Scrapy_splash 调用 Splash 服务非常简单. scrapy_Splash 中定义了一个 `SplashRequest` 类, 用户只需使用 `scrapy_splash.SplashRequest` (替代 scrapy.Request) 提交请求即可.

    `SplashRequest` 构造器方法参数
    - `url` : 待爬去页面的 url
    - `headers` : 请求 headers, 同 scrapy.Request.
    - `cookies` : 请求 cookie, 同 scrapy.Request.
    - `args` : 传递给 Splash 的参数(除 url), 如 wait, timeout, images, js_source 等
    - `cache_args` : 如果 args 中的某些参数每次调用都重复传递, 并且数据量巨大, 此时可以把该参数名填入 cache_args 列表中, 让 Splash 服务器缓存该参数. 如 `SplashRequest(url, args={"js_source": js, "wait": 0.5}, cache_args=["js_source"])`
    - `endpoint` : Splash 服务端点, 默认为 `render.html`, 即 javascript 渲染服务. 该参数可以设置为 `render.json`, `render.har`, `render.png`, `render.jpeg`, `execute` 等. 详细参考文档.
    - `splash_url` : Splash 服务器地址, 默认为 None, 即使用配置文件中的 `SPLASH_URL` 地址.

### 5. 代码示例

1. quote 名人名言爬取
    ```python
    import scrapy
    from scrapy_splash import SplashRequest


    class QuotesSpider(scrapy.Spider):
        name = 'quotes'
        allowed_domains = ['quotes.toscrape.com']
        start_urls = ['http://quotes.toscrape.com/js']
        
        splash_base_args = {"images": 0, "timeout": 3}
        
        def start_requests(self):
            for url in self.start_urls:
                yield SplashRequest(url, args=self.splash_base_args)

        def parse(self, response):
            for sel in response.css("div.quote"):
                quote = sel.css("span.text::text").extract_first()
                author = sel.css("small.author::text").extract_first()
                yield {"quote": quote, "author": author}
            
            href = response.css("li.next > a::attr(href)").extract_first()
            if href:
                url = response.urljoin(href)
                yield SplashRequest(url, args=self.splash_base_args)
    ```
2. jd 图书 爬取
    ```python
    import scrapy
    from scrapy import Request
    from scrapy_splash import SplashRequest

    lua_script = """
    function main(splash)
        splash:go(splash.args.url)
        splash:wait(2)
        splash:runjs("document.getElementsByClassName('page')[0].scrollIntoView(true)")
        splash:wait(2)
        return splash:html()
    end
    """

    class JdBookSpider(scrapy.Spider):
        name = 'jd_book'
        allowed_domains = ['search.jd.com']
        
        base_url = "https://search.jd.com/Search?keyword=python&enc=utf-8&book=y&wq=python"
        
        def start_requests(self):
            # 请求第一个页面, 无需渲染 js
            yield Request(self.base_url, callback=self.parse_url, dont_filter=True)

        def parse_url(self, response):
            # 获取商品总数, 计算出总页数.
            total = int(response.css("span#J_resCount::text").re_first("(\d+)\D?"))
            pageNum = total // 60 + (1 if total % 60 else 0)

            # 构造每一页的 url, 向 Splash 端点发送请求
            for i in xrange(pageNum):
                url = "%s&page=%s" % (self.base_url, 2*i + 1)
                headers = {"refer": self.base_url}
                yield SplashRequest(url, endpoint="execute", headers=headers,
                                    args={"lua_source": lua_script}, cache_args=["lua_source"])

        def parse(self, response):
            # 获取单个页面中每本书的名字和价格
            for sel in response.css("ul.gl-warp.clearfix > li.gl-item"):
                yield {
                    "name": sel.css("div.p-name").xpath("string(.//em)").extract_first(),
                    "price": sel.css("div.p-price i::text").extract_first()
                }

    $ vim settings.py

        USER_AGENT = u'Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36'
    ```
## 十一. HTTP 代理

Scrapy 内部提供了一个下载中间件`HttpProxyMiddleware`, 专门用于给 Scrapy 设置代理, 他默认是启动的, 他会在系统环境变量中搜索当前系统代理(名称格式为**xxx_proxy**的环境变量), 作为 Scrapy 爬虫使用的带来.
```shell
$ export http_proxy="http://192.168.1.1:8000"
$ export https_proxy="http://192.168.1.1:8001"

# 包含用户名和密码
$ export https_proxy="http://username:password@192.168.1.1:8001"

$ curl http(s)://httpbin.org/ip     # 返回一个包含请求源 ip 地址信息的额 json 字符串.
```
Scrapy 中为一个请求设置代理的本质就是将代理服务器的 url 填写到 `request.meta["proxy"]`.
```shell
class HttpProxyMiddleware(object):
    ...
    def _set_proxy(self, request, scheme):
        creds, proxy = self.proxies[scheme]
        request.meta["proxy"] = proxy
        if creds:
            # 如果需要认证, 传递包含用户账号和密码的身份验证信息
            request.headers["Proxy-Authorization"] = b"Basic" + creds 

# 手动实现
$ scrapy shell

>>> from scrapy import Request
>>> import base64

>>> req = Request("http://httpbin.org/ip", meta={"proxy": "http://192.168.1.1:8000"})
>>> user = "tom"
>>> password = "tom123"
>>> user_passwd = ("%s:%s" % (user, password)).encode("utf8")
>>> req.headers["Proxy-Authorization"] = b"Basic" + base64.b64encode(user_passwd)
>>> fetch(req)
```
### 1. 抓取免费代理: 
代理网站:

- `http://proxy-list.org`
- `https://free-proxy-list.net`
- `http://www.xicidaili.com`
- `http://www.proxy360.cn`
- `http://www.kuaidaili.com`

获取西祠代理代码
```python
# settings.py
USER_AGENT = "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN) AppleWebKit/523.15 (KHTML, like Gecko, Safari/419.3) Arora/0.3 (Change: 287 c9dfb30)"

# spider.py
import json

import scrapy
from scrapy import Request


class XiciSpider(scrapy.Spider):
    name = 'xici'
    allowed_domains = ['www.xicidaili.com']
    # start_urls = ['http://www.xicidaili.com/nn/']
    base_url = "http://www.xicidaili.com/nn/%s"
    check_url = "%s://httpbin.org/ip"

    def start_requests(self):
        for i in xrange(1, 5):
            yield Request(self.base_url % i)

    def parse(self, response):
        for sel in response.xpath("//table[@id='ip_list']/tr[position()>1]"):
            ip = sel.css('td:nth-child(2)::text').extract_first()
            port = sel.css('td:nth-child(3)::text').extract_first()
            scheme = sel.css('td:nth-child(6)::text').extract_first().lower()

            url = self.check_url % scheme
            proxy = "%s://%s:%s" % (scheme, ip, port)

            meta = {
                "proxy": proxy,
                "dont_retry": True,
                "download_timeout": 10,

                "_proxy_scheme": scheme,
                "_proxy_ip": ip
            }

            yield Request(url, callback=self.check_available, meta=meta, dont_filter=True)

    def check_available(self, response):
        proxy_ip = response.meta["_proxy_ip"]

        if proxy_ip == json.loads(response.text)["origin"]:
            yield {
                "proxy_scheme": response.meta["_proxy_scheme"],
                "proxy": response.meta["proxy"]
            }

```
### 2. 基于 HttpProxyMiddleware 实现随机代理
```python
# middlewares.py
class RandomHttpProxyMiddleware(HttpProxyMiddleware):
    def __init__(self, auth_encoding="latin-1", proxy_list_file=None):
        if not proxy_list_file:
            raise NotConfigured

        self.auth_encoding = auth_encoding

        # 用两个列表维护 HTTP 和 HTTPS 代理, {"http": [...], "https": [...]}
        self.proxies = defaultdict(list)

        with open(proxy_list_file) as f:
            proxy_list = json.load(f)
            for proxy in proxy_list:
                scheme = proxy["proxy_scheme"]
                url = proxy["proxy"]
                self.proxies[scheme].append(self._get_proxy(url, scheme))

    @classmethod
    def from_crawler(cls, crawler):
        auth_encoding = crawler.settings.get("HTTPPROXY_AUTH_ENCODING", "latin-1")
        proxy_list_file = crawler.settings.get("HTTPPROXY_PROXY_LIST_FILE")

        return cls(auth_encoding, proxy_list_file)

    def _set_proxy(self, request, scheme):
        creds, proxy = random.choice(self.proxies[scheme])
        request.meta["proxy"] = proxy
        if creds:
            request.headers["Proxy-Authorization"] = b"Basic" + creds

# spider.py : 测试随机 proxy 是否 work
import json
import scrapy
from scrapy import Request

class TestRandomProxySpider(scrapy.Spider):
    name = "random_proxy"

    def start_requests(self):
        for _ in range(100):
            yield Request("http://httpbin.org/ip", dont_filter=True)
            yield Request("https://httpbin.org/ip", dont_filter=True)

    def parse(self, response):
        print json.loads(response.text)

# settings.py
DOWNLOADER_MIDDLEWARES = {
    'proxy_example.middlewares.RandomHttpProxyMiddleware': 543,
}
HTTPPROXY_PROXY_LIST_FILE = "proxy.json"
```
### 3. 实战: 豆瓣电影
```python
# Spider.py
import json
import re

import scrapy
from scrapy import Request


class DmovieSpider(scrapy.Spider):

    BASE_URL = "https://movie.douban.com/j/search_subjects?type=movie&tag=%s&sort=recommend&page_limit=%s&page_start=%s"

    MOVIE_TAG = "豆瓣高分"
    PAGE_LIMIT = 20
    page_start = 0

    name = 'dmovie'
    allowed_domains = ['movie.douban.com']
    start_urls = [BASE_URL % (MOVIE_TAG, PAGE_LIMIT, page_start)]

    def parse(self, response):
        infos = json.loads(response.body.decode("utf-8"))

        for movie_info in infos["subjects"]:
            movie_item = {}

            movie_item["片名"] = movie_info["title"]
            movie_item["评分"] = movie_info["rate"]

            yield Request(movie_info["url"], callback=self.parse_movie, meta={"_movie_item": movie_item})

        if len(infos["subjects"]) == self.PAGE_LIMIT:
            self.page_start += self.PAGE_LIMIT
            url = self.BASE_URL % (self.MOVIE_TAG, self.PAGE_LIMIT, self.page_start)
            yield Request(url)

    def parse_movie(self, response):
        movie_item = response.meta["_movie_item"]
        info = response.css("div.subject div#info").xpath("string(.)").extract_first()

        fields = [s.strip().replace(":", "") for s in response.css("div#info span.pl::text").extract()]
        values = [re.sub("\s+", "", s.strip()) for s in re.split('\s*(?:%s):\s*' % "|".join(fields), info)][1:]

        movie_item.update(dict(zip(fields, values)))

        yield movie_item

# settings.py
DOWNLOADER_MIDDLEWARES = {
    'douban_movie.middlewares.RandomHttpProxyMiddleware': 543,
}

HTTPPROXY_PROXY_LIST_FILE = "proxy.json"
USER_AGENT = "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN) AppleWebKit/523.15 (KHTML, like Gecko, Safari/419.3) Arora/0.3 (Change: 287 c9dfb30)"

DOWNLOAD_DELAY = 2
ROBOTSTXT_OBEY = False

# middleware.py
class RandomHttpProxyMiddleware(HttpProxyMiddleware):
    def __init__(self, auth_encoding="latin-1", proxy_list_file=None):
        if not proxy_list_file:
            raise NotConfigured

        self.auth_encoding = auth_encoding

        # 用两个列表维护 HTTP 和 HTTPS 代理, {"http": [...], "https": [...]}
        self.proxies = defaultdict(list)

        with open(proxy_list_file) as f:
            proxy_list = json.load(f)
            for proxy in proxy_list:
                scheme = proxy["proxy_scheme"]
                url = proxy["proxy"]
                self.proxies[scheme].append(self._get_proxy(url, scheme))

    @classmethod
    def from_crawler(cls, crawler):
        auth_encoding = crawler.settings.get("HTTPPROXY_AUTH_ENCODING", "latin-1")
        proxy_list_file = crawler.settings.get("HTTPPROXY_PROXY_LIST_FILE")

        return cls(auth_encoding, proxy_list_file)

    def _set_proxy(self, request, scheme):
        creds, proxy = random.choice(self.proxies[scheme])
        request.meta["proxy"] = proxy
        if creds:
            request.headers["Proxy-Authorization"] = b"Basic" + creds

# proxy.json
[
{"proxy_scheme": "http", "proxy": "http://111.155.116.237:8123"},
{"proxy_scheme": "https", "proxy": "https://222.188.190.99:6666"},
{"proxy_scheme": "https", "proxy": "https://60.23.36.250:80"},
{"proxy_scheme": "https", "proxy": "https://120.79.216.57:6666"},
{"proxy_scheme": "https", "proxy": "https://120.92.88.202:10000"},
{"proxy_scheme": "https", "proxy": "https://120.79.151.197:6666"},
{"proxy_scheme": "http", "proxy": "http://118.114.77.47:8080"},
{"proxy_scheme": "http", "proxy": "http://112.74.62.69:8081"},
{"proxy_scheme": "https", "proxy": "https://218.93.166.4:6666"},
{"proxy_scheme": "http", "proxy": "http://58.216.202.149:8118"},
{"proxy_scheme": "http", "proxy": "http://14.118.253.233:6666"}
]
```
## 十二. scrapy-redis 分布式爬虫

Scrapy-redis 利用 Redis 数据库重新实现了 Scrapy 中的某些组件. 

- 基于 Redis 的请求队列(优先队列, FIFO, LIFO)
- 基于 Redis 的请求去重过滤器(过滤掉重复的请求)
- 基于以上两个组件的调度器

Scrapy-redis 为多个爬虫分配爬取任务的方式是: 让所有爬虫共享一个存在于 Redis 数据库中的请求队列(替代各爬虫独立的请求队列), 每个爬虫从请求队列中获取请求, 下载并解析出新请求再添加到 请求队列中, 因此, 每个爬虫即是下载任务的生产者, 又是消费者.

1. 搭建分布式环境
    ```shell
    # 在所有机器上安装包
    $ pip install scrapy
    $ pip install scrapy-redis

    # 启动redis server, 确保分布式环境中每台机器均可访问 redis-server
    $ redis-cli -h REDIS_SERVER ping
    ```
2. 配置项目

    ```python
    # settings.py
    ## 指定爬虫使用的 redis 数据库
    REDIS_URL = "redis://192.168.1.10:6379"

    ## 使用 scrapy-redis 的调度器替代 scrapy 原版调度器
    SCHEDULER = "scrapy_redis.scheduler.Scheduler"

    ## 使用 scrapy-redis 的 RFPDupeFilter 作为去重过滤器
    DUPEFILTER_CLASS = "scrapy_redis.dupefilter.RFPDupeFilter"

    ## 启动 scrapy_redis 的 RedisPipeline 将爬取到的数据汇总到 数据库.
    ITEM_PIPELINES = {
        "scrapy_redis.pipelines.RedisPipeline": 300,
    }

    ## 爬虫停止后, 保留/清理 redis 中的请求队列及去重即可. True: 保留, False: 清理(默认).
    SCHEDULER_PERSIST = True
    ```

    Scrapy-redis 提供了一个新的 Spider 基类 `RedisSpider`, RedisSpider 重写了 `start_requests` 方法, 他重试从  redis 数据库的某个特定列表中获取起始爬取点, 并构造 Request 对象(dont_filter=False), 该列表的键可通过配置文件设置(`REDIS_START_URLS_KEY`), 默认为 `<spider_name>:start_urls`. 

    在分布式爬取时, 用户运行所有爬虫后, 需要手动使用 Redis 命令向该列表添加起始爬取点, 从而避免重复.
    ```python
    # spider.py

    from scrapy_redis.spiders import RedisSpider

    class BooksSpider(RedisSpider):     # 爬虫 继承  RedisSpider 类
        pass

        # 注释 start_urls
        # start_urls = ["http://book.toscrape.com"]


    # 命令行 写入队列开始值.
    $ redis-cli -h 192.168.1.10
    > lpush books:start_urls "http://books.toscrape.com/"
    ```
## 十三. 奇技淫巧
### 1. scrapy 项目的一般步骤
    
1. 创建 项目
    ```
    $ scrapy startproject PROJECT_NAME
    ```
2. 创建 spider
    ```
    $ cd PROJECT_NAME
    $ scrapy genspider SPIDER_NAME DOMAIN
    ```
3. 封装 Item 类

4. 完成 Spider 类

5. 配置 settings.py
    ```
    ## 指定输出序列
    FEED_EXPORT_FIELDS = []
    ## 绕过 roobot.txt
    
    ## USER_AGENT 配置
    ```
6. 编写 Pipeline, 实现 item 字段转换 : settings.py
    ```
    ITEM_PIPELINES = {
        PIPELINE_NAME: rate,
    }
    ```

7. 运行 crawl
    ```
    $ scrapy list    
    $ scrapy crawl MySpider
    ```
### 2. User-Agent

1. [使用 fake-useragent ](documents/scrapy/fake-useragent)
    
    [GitHub - hellysmile/fake-useragent: up to date simple useragent faker with real world database](https://github.com/hellysmile/fake-useragent)

        $ pip install fake-useragent

2. 各大搜索引擎的 UA

    可以伪装成各大搜索引擎网站的UA， 比如 [Google UA](https://support.google.com/webmasters/answer/1061943?hl=zh-Hans)  

    添加`referfer`字段为 搜索引擎网站 也是有用的，因为网站是希望被索引的，所以会放宽搜索引擎的爬取策略。

3. [useragentstring.com](http://useragentstring.com)

### 3. 代理

网上的开源代理:
```
https://github.com/xiaosimao/IP_POOL
```
代理网站:
```
http://www.kuaidaili.com/free/
http://www.66ip.cn/
http://www.goubanjia.com/free/gngn/index.shtml
http://www.xicidaili.com/

data5u
proxydb
```
测试网站:
```
https://httpbin.org/get
```


## 十四. 参考链接
1. [精通 Scrapy 网络爬虫](https://www.amazon.cn/dp/B076F6W84Q/ref=sr_1_1?ie=UTF8&qid=1520433164&sr=8-1&keywords=scrapy)
2. [Scrapy 文档](https://doc.scrapy.org/en/latest/)

