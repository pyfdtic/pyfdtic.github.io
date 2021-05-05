---
title: python-pyecharts-文档笔记
date: 2018-03-16 16:41:56
categories:
- Python
tags:
- pyecharts
- PyPi
- echarts
- JavaScript 图表

---
**pyecharts 项目地址**

[https://github.com/chenjiandongx/pyecharts](https://github.com/chenjiandongx/pyecharts)

**pyecharts 文档地址**

[https://github.com/chenjiandongx/pyecharts/blob/master/document/zh-cn/documentation.md](https://github.com/chenjiandongx/pyecharts/blob/master/document/zh-cn/documentation.md)
[https://github.com/chenjiandongx/pyecharts/blob/master/example.md](https://github.com/chenjiandongx/pyecharts/blob/master/example.md)
[https://github.com/chenjiandongx/pyecharts/blob/master/document/zh-cn/doc_flask.md](https://github.com/chenjiandongx/pyecharts/blob/master/document/zh-cn/doc_flask.md)


## 1. 安装
    
    $ pip install pyecharts


### 1.1 简单使用

降水量与蒸发量柱状图

    attr = ["{} 月".format(i) for i in range(1,13)]
    v1 = [2.0,4.9,7.0,23.2,25.6,76.7,135.6,162.1,32.6,20.0,6.4,3.3]
    v2 = [2.6,5.9,9.0,26.2,28.6,70.7,175.6,182.1,48.6,18.0,6.4,2.3]
    bar = Bar("降水量与蒸发量")
    bar.add('蒸发量' ,attr, v1, mark_line=['average'], mark_point=["max","min"])
    bar.add('降水量' ,attr, v2, mark_line=['average'], mark_point=["max","min"])
    bar.render('./rain.html')

饼图 - 玫瑰图

    from pyecharts import Pie
    attr = ["衬衫", "羊毛衫","雪纺衫", "裤子", "高跟鞋","袜子"]
    v1 = [11,12,13,10,10,10]
    v2 = [19,21,32,20,20,33]

    pie = Pie("饼图-玫瑰图示例", title_pos="center", width=1200)

    pie.add("商品A", attr, v1, center=[25,50], is_random=True, radius=[30,75], rosetype="radius")

    pie.add("商品B", attr,v2, center=[75,50], is_random=True, radius=[30,75], rosetype="area", is_legend_show=False,is_label_show=True)

    pie.render('./rose.html')

图标嵌套与叠加

    from pyecharts import Bar,Line,Overlap
    attr = ['A', "B","C",'D','E','F']
    v1 = [10,20,30,40,50,60]
    v2 = [38,28,58,48,78,68]

    bar = Bar("Line-Bar Example")
    bar.add('bar',attr,v1)

    line =Line()
    line.add('line',attr,v2)

    overlap = Overlap()
    overlap.add(bar)
    overlap.add(line)
    overlap.render('./overlap.html')

## 2. 基本使用
### 2.1 基本套路
基本上所有的图标类型都可使用如下的套路去绘制:

1. chart_name = Type()  : 初始化具体类型图表
2. add()    : 添加数据及配置项
3. render() : 生成 html 文件.

    from pyecharts import Bar

    bar = Bar("My First Bar", "Second Title Here")
    bar.add("服装", ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"], [5, 20, 36, 10, 75, 90])
    bar.show_config()       
    bar.render()            
    bar.render_embed()
    
- Bar.add()             # 主要方法, 用于添加图表的数据和设置各种配置项.
    
    - add() 的数据一般为两个列表(长度一致), 如果数据是字典或者带元组的字典, 可使用 `cast()` 方法转换.
    - cast() : 转换数据序列, 将带字典和元组类型的序列转换为 k_lst, v_lst 两个列表. 如下示例:

        - 元组列表
        `[(A1, B1), (A2, B2), (A3, B3), (A4, B4)]` --> `k_lst[ A[i1, i2...] ], v_lst[ B[i1, i2...] ]`

        - 字典列表
        `[{A1: B1}, {A2: B2}, {A3: B3}, {A4: B4}]` --> `k_lst[ A[i1, i2...] ], v_lst[ B[i1, i2...] ]`

        - 字典
        `{A1: B1, A2: B2, A3: B3, A4: B4}` -- > `k_lst[ A[i1, i2...] ], v_lst[ B[i1, i2...] ]`

- Bar.show_config()     # 打印输出图表的所有配置项
- Bar.render("/path/to/myrender.html")          # 默认在当前目录下, 生成一个 render.html 文件, 支持 path 参数. 文件可用浏览器打开;
- Bar.render_embed()    # 生成 html 内嵌的 script 代码.

### 2.2 图表类初始化接受的参数(所有类型的图表都一样)
- title -> str

    主标题文本，支持 \n 换行，默认为 ""

- subtitle -> str

    副标题文本，支持 \n 换行，默认为 ""

- width -> int

    画布宽度，默认为 800（px）

- height -> int

    画布高度，默认为 400（px）

- title_pos -> str/int

    标题距离左侧距离，默认为'left'，有`'auto', 'left', 'right', 'center'`可选，也可为百分比或整数

- title_top -> str/int

    标题距离顶部距离，默认为'top'，有`'top', 'middle', 'bottom'`可选，也可为百分比或整数

- title_color -> str

    主标题文本颜色，默认为 '#000'

- subtitle_color -> str

    副标题文本颜色，默认为 '#aaa'

- title_text_size -> int

    主标题文本字体大小，默认为 18

- subtitle_text_size -> int

    副标题文本字体大小，默认为 12

- background_color -> str

    画布背景颜色，默认为 '#fff'

- is_grid -> bool

    是否使用 grid 组件，grid 组件用于并行显示图表。
    具体实现参见 用户自定义.



### 2.3 通用配置项(均在 add() 中设置)

#### 2.3.1 xyAxis: 直角坐标系中的 x, y 轴(Line, Bar, Scatter, EffectScatter, Kline)

- is_convert -> bool

    是否交换 x 轴与 y 轴
- is_xaxislabel_align -> bool

    x 轴刻度线和标签是否对齐，默认为 False
- is_yaxislabel_align -> bool

    y 轴刻度线和标签是否对齐，默认为 False
- x_axis -> list

    x 轴数据项
- xaxis_interval -> int

    x 轴刻度标签的显示间隔，在类目轴中有效。默认会采用标签不重叠的策略间隔显示标签。
设置成 0 强制显示所有标签。设置为 1，表示『隔一个标签显示一个标签』，如果值为 2，表示隔两个标签显示一个标签，以此类推
- xaxis_margin -> int

    x 轴刻度标签与轴线之间的距离。默认为 8
- xaxis_name -> str

    x 轴名称
- xaxis_name_size -> int

    x 轴名称体大小，默认为 14
- xaxis_name_gap -> int

    x 轴名称与轴线之间的距离，默认为 25
- xaxis_name_pos -> str

    x 轴名称位置，有'start'，'middle'，'end'可选
- xaxis_min -> int/float

    x 坐标轴刻度最小值，默认为自适应。
- xaxis_max -> int/float

    x 坐标轴刻度最大值，默认为自适应。
- xaxis_type -> str

    x 坐标轴类型
'value'：数值轴，适用于连续数据。
'category'：类目轴，适用于离散的类目数据，为该类型时必须通过 data 设置类目数据。
'time'：时间轴，适用于连续的时序数据，与数值轴相比时间轴带有时间的格式化，在刻度计算上也有所不同，例如会根据跨度的范围来决定使用月，星期，日还是小时范围的刻度。
'log'：对数轴。适用于对数数据。
- xaxis_rotate -> int

    x 轴刻度标签旋转的角度，在类目轴的类目标签显示不下的时候可以通过旋转防止标签之间重叠。默认为 0，即不旋转。旋转的角度从 -90 度到 90 度。
- y_axis -> list

    y 坐标轴数据
- yaxis_interval -> int

    y 轴刻度标签的显示间隔，在类目轴中有效。默认会采用标签不重叠的策略间隔显示标签。
设置成 0 强制显示所有标签。设置为 1，表示『隔一个标签显示一个标签』，如果值为 2，表示隔两个标签显示一个标签，以此类推
- yaxis_margin -> int

    y 轴刻度标签与轴线之间的距离。默认为 8
- yaxis_formatter -> str

    y 轴标签格式器，如 '天'，则 y 轴的标签为数据加'天'(3 天，4 天),默认为 ""
- yaxis_name -> str

    y 轴名称
- yaxis_name_size -> int

    y 轴名称体大小，默认为 14
- yaxis_name_gap -> int

    y 轴名称与轴线之间的距离，默认为 25
- yaxis_name_pos -> str

    y 轴名称位置，有'start', 'middle'，'end'可选
- yaxis_min -> int/float

    y 坐标轴刻度最小值，默认为自适应。
- yaxis_max -> int/float

    y 坐标轴刻度最大值，默认为自适应。
- yaxis_type -> str

    y 坐标轴类型
'value'：数值轴，适用于连续数据。
'category'：类目轴，适用于离散的类目数据，为该类型时必须通过 data 设置类目数据。
'time'：时间轴，适用于连续的时序数据，与数值轴相比时间轴带有时间的格式化，在刻度计算上也有所不同，例如会根据跨度的范围来决定使用月，星期，日还是小时范围的刻度。
'log'：对数轴。适用于对数数据。
- yaxis_rotate -> int

    y 轴刻度标签旋转的角度，在类目轴的类目标签显示不下的时候可以通过旋转防止标签之间重叠。默认为 0，即不旋转。旋转的角度从 -90 度到 90 度。

#### 2.3.2 dataZoom: dataZoome 组件用于区域缩放, 从而能自由关注细节的数据信息, 或者概览数据整体, 或者去除离群点的影响, (Line, Bar, Scatter, EffectScatter, Kline )

- is_datazoom_show -> bool

    是否使用区域缩放组件，默认为 False

- datazoom_type -> str

    区域缩放组件类型，默认为'slider'，有'slider', 'inside'可选

- datazoom_range -> list

    区域缩放的范围，默认为[50, 100]

- datazoom_orient -> str

    datazomm 组件在直角坐标系中的方向，默认为 
    'horizontal'，效果显示在 x 轴。如若设置为 'vertical' 的话效果显示在 y 轴。

#### 2.3.3  legend: 图例组件. 图例组件展现了不同系列的标记(Symbol), 颜色和名字. 可以通过点击图例控制那些系列不显示.
- is_legend_show -> bool

    是否显示顶端图例，默认为 True
- legend_orient -> str

    图例列表的布局朝向，默认为'horizontal'，有'horizontal', 'vertical'可选
- legend_pos -> str

    图例组件离容器左侧的距离，默认为'center'，有'left', 'center', 'right'可选
- legend_top -> str

    图例组件离容器上侧的距离，默认为'top'，有'top', 'center', 'bottom'可选
- legend_selectedmode -> str/bool

    图例选择的模式，控制是否可以通过点击图例改变系列的显示状态。默认为'multiple'，可以设成 'single' 或者 'multiple' 使用单选或者多选模式。也可以设置为 False 关闭显示状态。

#### 2.3.4 label: 图形上的文本标签, 可用于说明图形的一些数据信息, 如值,名称等.

- is_label_show -> bool

    是否正常显示标签，默认不显示。标签即各点的数据项信息

- is_emphasis -> bool

    是否高亮显示标签，默认显示。高亮标签即选中数据时显示的信息项。

- label_pos -> str

    标签的位置，Bar 图默认为'top'。有'top', 'left', 'right', 'bottom', 'inside','outside'可选

- label_text_color -> str

    标签字体颜色，默认为 "#000"

- label_text_size -> int

    标签字体大小，默认为 12

- is_random -> bool

    是否随机排列颜色列表，默认为 False

    is_random 可随机打乱图例颜色列表，算是切换风格

- label_color -> list

    自定义标签颜色。全局颜色列表，所有图表的图例颜色均在这里修改。如 Bar 的柱状颜色，Line 的线条颜色等等。

- formatter -> list

    标签内容格式器，有'series', 'name', 'value', 'percent'可选。如 ["name", "value"]

    - series：图例名称
    - name：数据项名称
    - value：数据项值
    - percent：数据的百分比（主要用于饼图）


#### 2.3.5 lineStyle : 带线图形的线的风格选项, (Line, Polar, Radar, Graph, Parallel)

- line_width -> int

    线的宽度，默认为 1

- line_opacity -> float

    线的透明度，0 为完全透明，1 为完全不透明。默认为 1

- line_curve -> float

    线的弯曲程度，0 为完全不弯曲，1 为最弯曲。默认为 0

- line_type -> str

    线的类型，有'solid', 'dashed', 'dotted'可选。默认为'solid'


#### 2.3.6 grib3D : 3D 笛卡尔坐标系组配置项, 适用于 3D 图形. (Bar3D, Line3D, Scatter3D)
- grid3D_width -> int

    三维笛卡尔坐标系组件在三维场景中的高度。默认为 100

- grid3D_height -> int

    三维笛卡尔坐标系组件在三维场景中的高度。默认为 100

- grid3D_depth -> int

    三维笛卡尔坐标系组件在三维场景中的高度。默认为 100

- is_grid3D_rotate -> bool

    是否开启视角绕物体的自动旋转查看。默认为 False

- grid3D_rotate_speed -> int

    物体自传的速度。单位为角度 / 秒，默认为 10 ，也就是 36 秒转一圈。

- grid3D_rotate_sensitivity -> int

    旋转操作的灵敏度，值越大越灵敏。默认为 1, 设置为 0 后无法旋转。


#### 2.3.7 axis3D : 3D 笛卡尔坐标系 X,Y,Z 轴配置项.
##### 2.3.7.1 X轴
- xaxis3d_name -> str

    x 轴名称，默认为 ""

- xaxis3d_name_size -> int

    x 轴名称体大小，默认为 16

- xaxis3d_name_gap -> int

    x 轴名称与轴线之间的距离，默认为 25

- xaxis3d_min -> int/float

    x 坐标轴刻度最小值，默认为自适应。

- xaxis3d_max -> int/float

    x 坐标轴刻度最大值，默认为自适应。

- xaxis3d_interval -> int

    x 轴刻度标签的显示间隔，在类目轴中有效。默认会采用标签不重叠的策略间隔显示标签。

    - 设置为 0, 强制显示所有标签。
    - 设置为 1，表示『隔一个标签显示一个标签』，
    - 设置为 2，表示隔两个标签显示一个标签，
    - 以此类推

- xaxis3d_margin -> int

    x 轴刻度标签与轴线之间的距离。默认为 8

##### 2.3.7.2 Y轴
- yaxis3d_name -> str

    y 轴名称，默认为 ""

- yaxis3d_name_size -> int

    y 轴名称体大小，默认为 16

- yaxis3d_name_gap -> int

    y 轴名称与轴线之间的距离，默认为 25

- yaxis3d_min -> int/float

    y 坐标轴刻度最小值，默认为自适应。

- yaxis3d_max -> int/float

    y 坐标轴刻度最大值，默认为自适应。

- yaxis3d_interval -> int

    y 轴刻度标签的显示间隔，在类目轴中有效。默认会采用标签不重叠的策略间隔显示标签。

    - 设置为 0, 强制显示所有标签。
    - 设置为 1，表示『隔一个标签显示一个标签』，
    - 设置为 2，表示隔两个标签显示一个标签，
    - 以此类推

- yaxis3d_margin -> int

    y 轴刻度标签与轴线之间的距离。默认为 8

##### 2.3.7.3 Z轴
- zaxis3d_name -> str

    z 轴名称，默认为 ""

- zaxis3d_name_size -> int

    z 轴名称体大小，默认为 16

- zaxis3d_name_gap -> int

    z 轴名称与轴线之间的距离，默认为 25

- zaxis3d_min -> int/float

    z 坐标轴刻度最小值，默认为自适应。

- zaxis3d_max -> int/float

    z 坐标轴刻度最大值，默认为自适应。

- zaxis3d_margin -> int

    z 轴刻度标签与轴线之间的距离。默认为 8


#### 2.3.8 visualMap : 是视觉映射组件, 用于进行 视觉编码, 也就是将数据映射视觉元素(视觉通道)

- is_visualmap -> bool

    是否使用视觉映射组件

- visual_type -> str

    制定组件映射方式，默认为'color‘，即通过颜色来映射数值。有'color', 'size'可选。'szie'通过数值点的大小，也就是图形点的大小来映射数值。

- visual_range -> list

    指定组件的允许的最小值与最大值。默认为 [0, 100]

- visual_text_color -> list

    两端文本颜色。

- visual_range_text -> list

    两端文本。默认为 ['low', 'hight']

- visual_range_color -> list

    过渡颜色。默认为 ['#50a3ba', '#eac763', '#d94e5d']

- visual_range_size -> list

    数值映射的范围，也就是图形点大小的范围。默认为 [20, 50]

- visual_orient -> str

    visualMap 组件条的方向，默认为'vertical'，有'vertical', 'horizontal'可选。

- visual_pos -> str/int

    visualmap 组件条距离左侧的位置，默认为'left'。有'right', 'center', 'right'可选，也可为百分数或整数。

- visual_top -> str/int

    visualmap 组件条距离顶部的位置，默认为'top'。有'top', 'center', 'bottom'可选，也可为百分数或整数。

- is_calculable -> bool

    是否显示拖拽用的手柄（手柄能拖拽调整选中范围）。默认为 True


### 2.2 Python2 的编码问题
    
    #!/usr/bin/python
    #coding=utf-8           # 通知编辑器, 使用 UTF-8 编码,
    from __future__ import unicode_literals     # 告知 python 解释器, 所有字符均是 UTF-8 编码

## 3. Bar (柱状图/条形图)

全局配置项要在最后一个 `add()` 上设置，否侧设置会被冲刷掉。

### 3.1 Bar 数据堆叠

Bar.add(name, x_axis, y_axis, is_stack=False, **kwargs)

- name --> str

    图例名称

- x_axis --> list

    x 坐标轴数据

- y_axis --> list

    y 坐标轴数据

- is_stack --> bool

    数据堆叠, 同个类目轴上系列配置相同的 stack 值可以堆叠放置.

数据堆叠示例
    
    from pyecharts import Bar

    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    v1 = [5, 20, 36, 10, 75, 90]
    v2 = [10, 25, 8, 60, 20, 80]
    bar = Bar("柱状图数据堆叠示例")
    bar.add("商家A", attr, v1, is_stack=True)
    bar.add("商家B", attr, v2, is_stack=True)
    bar.render()

### 3.2 标记线和标记点
可选项:

- mark_point -> list

    标记点，有'min', 'max', 'average'可选

- mark_line -> list

    标记线，有'min', 'max', 'average'可选

- mark_point_symbol -> str

    标记点图形，，默认为'pin'，有'circle', 'rect', 'roundRect', 'triangle', 'diamond', 'pin', 'arrow'可选

- mark_point_symbolsize -> int

    标记点图形大小，默认为 50

- mark_point_textcolor -> str

    标记点字体颜色，默认为'#fff'


代码示例:

    from pyecharts import Bar

    bar = Bar("标记线和标记点示例")
    bar.add("商家A", attr, v1, mark_point=["average"])
    bar.add("商家B", attr, v2, mark_line=["min", "max"])
    bar.render()

### 3.3 X 轴和 Y 轴交换

    bar = Bar("X 轴和Y轴交换")
    bar.add("商家A", attr, v1)
    bar.add("商家B", attr, v2, is_convert=True)
    bar.render("bar_xy_exchange.html")

### 3.4 Bar - datazoom 

**datazoom** 适合所有平面直角坐标系图形，也就是(Line、Bar、Scatter、EffectScatter、Kline)

#### 3.4.1 slide 类型

    import random

    attr = ["{}天".format(i) for i in range(30)]
    v1 = [random.randint(1, 30) for _ in range(30)]
    bar = Bar("Bar - datazoom - slider 示例")
    bar.add("", attr, v1, is_label_show=True, is_datazoom_show=True)
    bar.render()

#### 3.4.2 inside 类型

    attr = ["{}天".format(i) for i in range(30)]
    v1 = [random.randint(1, 30) for _ in range(30)]
    bar = Bar("Bar - datazoom - inside 示例")
    bar.add("", attr, v1, is_datazoom_show=True, datazoom_type='inside', datazoom_range=[10, 25])
    bar.show_config()
    bar.render()

#### 3.4.3 坐标轴标签旋转
当 x 轴或 y 轴由的标签因为过于密集而导致全部显示出来会重叠时, 可采用使 标签旋转的方法.
    
    attr = ["{}天".format(i) for i in range(20)]
    v1 = [random.randint(1, 20) for _ in range(20)]
    bar = Bar("坐标轴标签旋转示例")
    bar.add("", attr, v1, xaxis_interval=0, xaxis_rotate=30, yaxis_rotate=30)
    bar.show_config()
    bar.render()

可通过设置 xaxis_min/xaxis_max/yaxis_min/yaxis_max 来调整 x 轴 和 y 轴上的最大最小值, 针对数值轴有效.

可通过 label_color 设置柱状颜色, 如 ["#eee", "#000"], 所有图标类型的图例颜色都可以通过 label_color 来修改.

## 4. Bar3D (3D 柱状图)

## 5. EffectScatter (带有涟漪特效动画的散点图)
利用动画特效, 可以将某些想要突出的数据进行视觉突出.

EffectScatter.add(name, x_value, y_value, symbol_size=10, **kwargs)

- name --> str : 图例名称
- x_axis --> list : x 坐标轴数据
- y_axis --> list : y 坐标轴数据
- symbol_size --> int : 标记图形大小.

- symbol --> str : 标记图形, 有 "rect", "roundRect", "triangle", "diamond", "pin", "arrow" 可选.
- effect_brushtype --> str : 波纹绘制方式, 有 "stroke", "fill" 可选, 默认为 "stroke"
- effect_scale --> float : 动画中波纹的最大缩放比例, 默认为 2.5
- effect_period --> float : 动画持续时间, 默认为 4s.

普通散点图:

    from pyecharts import EffectScatter

    v1 = [10, 20, 30, 40, 50, 60]
    v2 = [25, 20, 15, 10, 60, 33]
    es = EffectScatter("动态散点图示例")
    es.add("effectScatter", v1, v2)
    es.render()

各种图形散点示例:

    es = EffectScatter("动态散点图各种图形示例")
    es.add("", [10], [10], symbol_size=20, effect_scale=3.5, effect_period=3, symbol="pin")
    es.add("", [20], [20], symbol_size=12, effect_scale=4.5, effect_period=4,symbol="rect")
    es.add("", [30], [30], symbol_size=30, effect_scale=5.5, effect_period=5,symbol="roundRect")
    es.add("", [40], [40], symbol_size=10, effect_scale=6.5, effect_brushtype='fill',symbol="diamond")
    es.add("", [50], [50], symbol_size=16, effect_scale=5.5, effect_period=3,symbol="arrow")
    es.add("", [60], [60], symbol_size=6, effect_scale=2.5, effect_period=3,symbol="triangle")
    es.render()

## 6. Funnel (漏斗图)
Funnel.add(name, attr, value, **kwargs)
- name --> str : 图例名称
- attr --> list : 属性名称
- value --> list : 属性对应的值,

普通示例:

    from pyecharts import Funnel

    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    value = [20, 40, 60, 80, 100, 120]
    funnel = Funnel("漏斗图示例")
    funnel.add("商品", attr, value, is_label_show=True, label_pos="inside", label_text_color="#fff")
    funnel.render()

示例:

    funnel = Funnel("漏斗图示例", width=600, height=400, title_pos='center')
    funnel.add("商品", attr, value, is_label_show=True, label_pos="outside", legend_orient='vertical',
               legend_pos='left')
    funnel.show_config()
    funnel.render()

## 7. Gauge (仪表盘)
Gauge.add(name, attr, value, scale_range=None, angle_range=None, **kwargs)

- name --> str : 图例名称
- attr --> list : 属性名称
- value --> list : 属性对应的值
- scale_range --> list : 仪表盘数据范围, 默认为 [0,100]
- angle_range --> list : 仪表盘角度范围, 默认为 [225, -45]

示例一 :

    from pyecharts import Gauge

    gauge = Gauge("仪表盘示例")
    gauge.add("业务指标", "完成率", 66.66)
    gauge.show_config()
    gauge.render()

示例二 :

    gauge = Gauge("仪表盘示例")
    gauge.add("业务指标", "完成率", 166.66, angle_range=[180, 0], scale_range=[0, 200], is_legend_show=False)
    gauge.show_config()
    gauge.render()

## 8. Geo (地理坐标系)
地理坐标系组件用于地图的绘制, 支持在地理坐标系上绘制散点图, 线集.

Geo.add(name, attr, value, type="scatter", maptype="china", symbol_size=12, border_color="#111", geo_normal_color="#323c48", geo_emphasis_color="#2a333d", **kwargs)
- name --> str : 图例名称
- attr --> list : 属性名称
- value --> list : 属性所对应的值
- type --> str : 图例类型, 有 "scatter", "effectscatter", "heatmap" 可选, 默认为 "scatter"
- maptype --> str : 地图类型, 目前只支持 "china"
- symbol_size --> int : 标记图形大小, 默认12
- border_color --> str : 地图边界颜色, 默认为 "#111"
- geo_normal_color --> str : 正常状态下地图区域的颜色, 默认为 "#323C48"
- geo_emphasis_color --> str : 高亮状态下地图区域的颜色, 默认为 "#2a333d"

### 8.1 scatter
请配合 通用配置项 中的 visualmap 使用.

    from pyecharts import Geo

    data = [
        ("海门", 9),("鄂尔多斯", 12),("招远", 12),("舟山", 12),("齐齐哈尔", 14),("盐城", 15),
        ("赤峰", 16),("青岛", 18),("乳山", 18),("金昌", 19),("泉州", 21),("莱西", 21),
        ("日照", 21),("胶南", 22),("南通", 23),("拉萨", 24),("云浮", 24),("梅州", 25),
        ("文登", 25),("上海", 25),("攀枝花", 25),("威海", 25),("承德", 25),("厦门", 26),
        ("汕尾", 26),("潮州", 26),("丹东", 27),("太仓", 27),("曲靖", 27),("烟台", 28),
        ("福州", 29),("瓦房店", 30),("即墨", 30),("抚顺", 31),("玉溪", 31),("张家口", 31),
        ("阳泉", 31),("莱州", 32),("湖州", 32),("汕头", 32),("昆山", 33),("宁波", 33),
        ("湛江", 33),("揭阳", 34),("荣成", 34),("连云港", 35),("葫芦岛", 35),("常熟", 36),
        ("东莞", 36),("河源", 36),("淮安", 36),("泰州", 36),("南宁", 37),("营口", 37),
        ("惠州", 37),("江阴", 37),("蓬莱", 37),("韶关", 38),("嘉峪关", 38),("广州", 38),
        ("延安", 38),("太原", 39),("清远", 39),("中山", 39),("昆明", 39),("寿光", 40),
        ("盘锦", 40),("长治", 41),("深圳", 41),("珠海", 42),("宿迁", 43),("咸阳", 43),
        ("铜川", 44),("平度", 44),("佛山", 44),("海口", 44),("江门", 45),("章丘", 45),
        ("肇庆", 46),("大连", 47),("临汾", 47),("吴江", 47),("石嘴山", 49),("沈阳", 50),
        ("苏州", 50),("茂名", 50),("嘉兴", 51),("长春", 51),("胶州", 52),("银川", 52),
        ("张家港", 52),("三门峡", 53),("锦州", 54),("南昌", 54),("柳州", 54),("三亚", 54),
        ("自贡", 56),("吉林", 56),("阳江", 57),("泸州", 57),("西宁", 57),("宜宾", 58),
        ("呼和浩特", 58),("成都", 58),("大同", 58),("镇江", 59),("桂林", 59),("张家界", 59),
        ("宜兴", 59),("北海", 60),("西安", 61),("金坛", 62),("东营", 62),("牡丹江", 63),
        ("遵义", 63),("绍兴", 63),("扬州", 64),("常州", 64),("潍坊", 65),("重庆", 66),
        ("台州", 67),("南京", 67),("滨州", 70),("贵阳", 71),("无锡", 71),("本溪", 71),
        ("克拉玛依", 72),("渭南", 72),("马鞍山", 72),("宝鸡", 72),("焦作", 75),("句容", 75),
        ("北京", 79),("徐州", 79),("衡水", 80),("包头", 80),("绵阳", 80),("乌鲁木齐", 84),
        ("枣庄", 84),("杭州", 84),("淄博", 85),("鞍山", 86),("溧阳", 86),("库尔勒", 86),
        ("安阳", 90),("开封", 90),("济南", 92),("德阳", 93),("温州", 95),("九江", 96),
        ("邯郸", 98),("临安", 99),("兰州", 99),("沧州", 100),("临沂", 103),("南充", 104),
        ("天津", 105),("富阳", 106),("泰安", 112),("诸暨", 112),("郑州", 113),("哈尔滨", 114),
        ("聊城", 116),("芜湖", 117),("唐山", 119),("平顶山", 119),("邢台", 119),("德州", 120),
        ("济宁", 120),("荆州", 127),("宜昌", 130),("义乌", 132),("丽水", 133),("洛阳", 134),
        ("秦皇岛", 136),("株洲", 143),("石家庄", 147),("莱芜", 148),("常德", 152),("保定", 153),
        ("湘潭", 154),("金华", 157),("岳阳", 169),("长沙", 175),("衢州", 177),("廊坊", 193),
        ("菏泽", 194),("合肥", 229),("武汉", 273),("大庆", 279)]

    geo = Geo("全国主要城市空气质量", "data from pm2.5", title_color="#fff", title_pos="center",
    width=1200, height=600, background_color='#404a59')
    attr, value = geo.cast(data)
    geo.add("", attr, value, visual_range=[0, 200], visual_text_color="#fff", symbol_size=15, is_visualmap=True)
    geo.show_config()
    geo.render()

### 8.2 effectScatter
    from pyecharts import Geo

    data = [("海门", 9), ("鄂尔多斯", 12), ("招远", 12), ("舟山", 12), ("齐齐哈尔", 14), ("盐城", 15)]
    geo = Geo("全国主要城市空气质量", "data from pm2.5", title_color="#fff", title_pos="center",
              width=1200, height=600, background_color='#404a59')
    attr, value = geo.cast(data)
    geo.add("", attr, value, type="effectScatter", is_random=True, effect_scale=5)
    geo.show_config()
    geo.render()

### 8.3 heatmap

    geo = Geo("全国主要城市空气质量", "data from pm2.5", title_color="#fff", title_pos="center", width=1200, height=600,
              background_color='#404a59')
    attr, value = geo.cast(data)
    geo.add("", attr, value, type="heatmap", is_visualmap=True, visual_range=[0, 300], visual_text_color='#fff')
    geo.show_config()
    geo.render()

## 9. Graph (关系图)

## 10. HeatMap (热力图)

## 11. Kline (K线图)

**红涨蓝跌**

Kline.add(name, x_axis, y_axis, **kwargs)
- name --> str : 图例名称
- x_axis --> list : x 坐标轴数据
- y_axis --> [list] : 包含列表的列表. y 坐标轴数据. 数据中, 每一行是一个 数据项, 每一列属于一个维度. 数据项具体为 [open, close, lowest, highest], 即 [开盘值, 收盘值, 最低值, 最高值].

示例一 : 普通线

    from pyecharts import Kline

    v1 = [[2320.26, 2320.26, 2287.3, 2362.94], [2300, 2291.3, 2288.26, 2308.38],
          [2295.35, 2346.5, 2295.35, 2345.92], [2347.22, 2358.98, 2337.35, 2363.8],
          [2360.75, 2382.48, 2347.89, 2383.76], [2383.43, 2385.42, 2371.23, 2391.82],
          [2377.41, 2419.02, 2369.57, 2421.15], [2425.92, 2428.15, 2417.58, 2440.38],
          [2411, 2433.13, 2403.3, 2437.42], [2432.68, 2334.48, 2427.7, 2441.73],
          [2430.69, 2418.53, 2394.22, 2433.89], [2416.62, 2432.4, 2414.4, 2443.03],
          [2441.91, 2421.56, 2418.43, 2444.8], [2420.26, 2382.91, 2373.53, 2427.07],
          [2383.49, 2397.18, 2370.61, 2397.94], [2378.82, 2325.95, 2309.17, 2378.82],
          [2322.94, 2314.16, 2308.76, 2330.88], [2320.62, 2325.82, 2315.01, 2338.78],
          [2313.74, 2293.34, 2289.89, 2340.71], [2297.77, 2313.22, 2292.03, 2324.63],
          [2322.32, 2365.59, 2308.92, 2366.16], [2364.54, 2359.51, 2330.86, 2369.65],
          [2332.08, 2273.4, 2259.25, 2333.54], [2274.81, 2326.31, 2270.1, 2328.14],
          [2333.61, 2347.18, 2321.6, 2351.44], [2340.44, 2324.29, 2304.27, 2352.02],
          [2326.42, 2318.61, 2314.59, 2333.67], [2314.68, 2310.59, 2296.58, 2320.96],
          [2309.16, 2286.6, 2264.83, 2333.29], [2282.17, 2263.97, 2253.25, 2286.33],
          [2255.77, 2270.28, 2253.31, 2276.22]]
    kline = Kline("K 线图示例")
    kline.add("日K", ["2017/7/{}".format(i + 1) for i in range(31)], v1)
    kline.show_config()
    kline.render()

示例二 : 带 datazoom 的 kline.

    kline = Kline("K 线图示例")
    kline.add("日K", ["2017/7/{}".format(i + 1) for i in range(31)], v1, mark_point=["max"], is_datazoom_show=True)
    kline.show_config()
    kline.render()

示例三 : datazoom 添加到 纵坐标轴上.

    kline = Kline("K 线图示例")
    kline.add("日K", ["2017/7/{}".format(i + 1) for i in range(31)], v1, mark_point=["max"],
              is_datazoom_show=True, datazoom_orient='vertical')
    kline.show_config()
    kline.render()

## 12. Line (折线图/面积图)
折线图是用折现将各个数据点标志连接起来的图表, 用以展现数据的变化趋势.

Line.add(name, x_axis, y_axis, is_symbol_show=True, is_smooth=False, is_stack=False, is_step=False, is_fill=False, **kwargs)

- name --> str : 图例名称
- x_axis --> list : x 坐标轴数据
- y_axis --> list : Y 坐标轴数据
- is_symbol_show --> bool : 是否显示标记图形, 默认为 True
- is_smooth --> bool : 是否显示平滑曲线, 默认为 False
- is_stack --> bool : 数据堆叠, 同个类目轴上系列配置相同的 stack 值可以堆叠放置, 默认为 False.
- is_step --> bool/str : 是否是阶梯线图. 默认为 False. 也支持设置成 "start", "middle", "end" 分别配置在当前点, 当前点与下个点的中间, 下个点的拐弯.
- is_fill --> bool : 是否填充曲线所绘制面积, 默认为 False.

- mark_point --> list : 标记点, 有 min, max, average 可选
- mark_line --> list : 标记线, 有 min, max, average 可选.
- mark_point_symbol --> str : 标记点图形, 默认为 pin, 有 circle, rect, roundRect, triangle, diamond, pin, arrow 可选.
- mark_point_symbolsize --> int : 标记点图形大小, 默认为 50
- mark_point_textcolor --> str : 标记点字体颜色, 默认为 #fff.

- area_color --> str : 填充区域颜色.
- area_opacity --> float : 填充区域透明度


示例一 :

    from pyecharts import Line

    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    v1 = [5, 20, 36, 10, 10, 100]
    v2 = [55, 60, 16, 20, 15, 80]
    line = Line("折线图示例")
    line.add("商家A", attr, v1, mark_point=["average"])
    line.add("商家B", attr, v2, is_smooth=True, mark_line=["max", "average"])
    line.show_config()
    line.render()

示例二 : 标记点 配置示例.

    line = Line("折线图示例")
    line.add("商家A", attr, v1, mark_point=["average", "max", "min"],
             mark_point_symbol='diamond', mark_point_textcolor='#40ff27')
    line.add("商家B", attr, v2, mark_point=["average", "max", "min"],
             mark_point_symbol='arrow', mark_point_symbolsize=40)
    line.show_config()
    line.render()

示例三 : 折线图-数据堆叠示例
    
    line = Line("折线图-数据堆叠示例")
    line.add("商家A", attr, v1, is_stack=True, is_label_show=True)
    line.add("商家B", attr, v2, is_stack=True, is_label_show=True)
    line.show_config()
    line.render()

示例四 : 折线图-阶梯图示例
    
    line = Line("折线图-面积图示例")
    line.add("商家A", attr, v1, is_fill=True, line_opacity=0.2, area_opacity=0.4, symbol=None)
    line.add("商家B", attr, v2, is_fill=True, area_color='#000', area_opacity=0.3, is_smooth=True)
    line.show_config()
    line.render()

示例五 : 折线图-面积图示例
    
    line = Line("折线图-面积图示例")
    line.add("商家A", attr, v1, is_fill=True, line_opacity=0.2, area_opacity=0.4, symbol=None)
    line.add("商家B", attr, v2, is_fill=True, area_color='#000', area_opacity=0.3, is_smooth=True)
    line.show_config()
    line.render()

## 13. Line3D (3D折线图)

## 14. Liquid (水球图)
主要用来突出数据的百分比.

Liquid.add(name, data, shape="circle", liquid_color=None, is_liquid_animation=True,is_liquid_outline_show=True, **kwargs)

- name --> str : 图例名称
- data --> list : 数据项
- shape --> str : 水球外形, 有 circle, rect, roundRect, triangle, diamond, pin, arrow 可选. 默认为 circle.
- liquid_color --> list : 波浪颜色, 默认颜色列表为 ["#294D99", "#156ACF", "#1598ED", "#45BDFF"]
- is_liquid_animation --> bool : 是否显示波浪动画, 默认为 True.
- is_liquid_outline_show --> bool : 是否显示边框, 默认为 True.

示例一 : 有边界, 单波浪

    from pyecharts import Liquid

    liquid = Liquid("水球图示例")
    liquid.add("Liquid", [0.6])
    liquid.show_config()
    liquid.render()

示例二 : 无边界, 多波浪

    from pyecharts import Liquid

    liquid = Liquid("水球图示例")
    liquid.add("Liquid", [0.6, 0.5, 0.4, 0.3], is_liquid_outline_show=False)
    liquid.show_config()
    liquid.render()

## 15. Map (地图)
地图主要用于地理区域数据的可视化.

Map.add(name, attr, value, is_roam=True, maptype="china", **kwargs)

- name --> str : 图例名称
- attr --> list : 属性名称
- value --> list : 属性所对应的值.
- is_roam --> bool/str : 是否开启鼠标缩放和平移漫游, 默认为 True. 如果只开启缩放或者平移, 可以设置成 "scale" 或者 "move", 设置为 True ,表示两个都开启.
- maptype --> str : 地图烈性, 支持 china, world, 安徽、澳门、北京、重庆、福建、福建、甘肃、广东，广西、广州、海南、河北、黑龙江、河南、湖北、湖南、江苏、江西、吉林、辽宁、内蒙古、宁夏、青海、山东、上海、陕西、四川、台湾、天津、香港、新疆、西藏、云南、浙江. 地图提供了(自定义模式)[https://github.com/chenjiandongx/pyecharts/blob/master/document/zh-cn/user-customize-map.md].


示例一 : 全国地图示例

    from pyecharts import Map

    value = [155, 10, 66, 78]
    attr = ["福建", "山东", "北京", "上海"]
    map = Map("全国地图示例", width=1200, height=600)
    map.add("", attr, value, maptype='china')
    map.show_config()
    map.render()

示例二 : Map + VisualMap

    # 中国地图
    from pyecharts import Map
    value = [155, 10, 66, 78, 33, 80, 190, 53, 49.6]
    attr = ["福建", "山东", "北京", "上海", "甘肃", "新疆", "河南", "广西", "西藏"]
    map = Map("Map 结合 VisualMap 示例", width=1200, height=600)
    map.add("", attr, value, maptype='china', is_visualmap=True, visual_text_color='#000')
    map.show_config()
    map.render()

    # 广东地图
    from pyecharts import Map
    value = [20, 190, 253, 77, 65]
    attr = ['汕头市', '汕尾市', '揭阳市', '阳江市', '肇庆市']
    map = Map("广东地图示例", width=1200, height=600)
    map.add("", attr, value, maptype='广东', is_visualmap=True, visual_text_color='#000')
    map.show_config()
    map.render()

示例三 : 世界地图示例
    
    value = [95.1, 23.2, 43.3, 66.4, 88.5]
    attr= ["China", "Canada", "Brazil", "Russia", "United States"]
    map = Map("世界地图示例", width=1200, height=600)
    map.add("", attr, value, maptype="world", is_visualmap=True, visual_text_color='#000')
    map.render()

## 16. Parallel (平行坐标系)

## 17. Pie (饼图-玫瑰图)
饼图用于表现不同类目的数据在总和中的占比. 每个弧度表示数据数量的比例.

Pie.add(name, attr, value, radius=None, center=None, rosetype=None, **kwargs)

- name --> str : 图例名称
- attr --> list : 属性名称
- value --> list : 属性对应的值.
- radius --> list : 饼图的半径, 数组的第一项是内半径, 第二项为 外半径(默认为 [0.75]). 默认设置成百分比, 相对于容器高宽中较小的一项的一半.
- center --> list : 饼图的中心(圆心)坐标, 数组的第一项是横坐标, 第二项是纵坐标, 默认为 [50,50]. 默认设置成百分比, 设置成百分比时第一项是相对于容器宽度, 第二项是相对于容器高度.
- rosetype --> str : 是否展示位 南丁格尔图, 通过半径区分数据大小, 有 "radius" 和 "area" 两种模式. 默认为 "radius".
    - radius : 扇区圆心角展现数据的百分比, 半径展现数据的大小
    - area : 所有扇区圆心角相同, 仅通过半径展现数据大小.


示例一 : 饼图

    from pyecharts import Pie

    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    v1 = [11, 12, 13, 10, 10, 10]
    pie = Pie("饼图示例")
    pie.add("", attr, v1, is_label_show=True)
    pie.show_config()
    pie.render()

示例二 : 饼图-圆环图示例

    from pyecharts import Pie

    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    v1 = [11, 12, 13, 10, 10, 10]
    pie = Pie("饼图-圆环图示例", title_pos='center')
    pie.add("", attr, v1, radius=[40, 75], label_text_color=None, is_label_show=True, legend_orient='vertical', legend_pos='left')
    pie.show_config()
    pie.render()

示例三 : 饼图-玫瑰图示例

    from pyecharts import Pie

    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    v1 = [11, 12, 13, 10, 10, 10]
    v2 = [19, 21, 32, 20, 20, 33]
    pie = Pie("饼图-玫瑰图示例", title_pos='center', width=900)
    pie.add("商品A", attr, v1, center=[25, 50], is_random=True, radius=[30, 75], rosetype='radius')
    pie.add("商品B", attr, v2, center=[75, 50], is_random=True, radius=[30, 75], rosetype='area',
            is_legend_show=False, is_label_show=True)
    pie.show_config() 
    pie.render()

## 18. Polar (极坐标系)
可用以散点图和折线图.

Polar.add(name, data, angle_data=None, radius_data=None, type="line", symbol_siza=4, start_angle=90, rotate_step=0, boundary_gap=True, clockwise=True, **kwargs)

- name --> str : 图例名称
- data --> [list] : 包含列表的列表, 数据项, [极径, 极角, [ 数据值]]
- angle_data --> list : 角度类目数据
- radius_data --> list : 半径类目数据
- type --> str : 图例类型, 有 line, scatter, effectScatter, barAngle, barRadius 可选, 默认为 line.
- symbol_size --> int : 标记图形大小, 默认为 4
- start_angle --> int : 起始刻度的角度, 默认为 90 度, 即圆形的正上方, 0 度为圆心的正右方.
- rotate_step --> int : 刻度标签旋转的角度, 在类目轴的类目标签显示不下的时候,可以通过旋转防止标签之间重叠. 旋转的角度从 -90 度 到 90 度, 默认为 0.
- boundary_gap --> bool : 坐标两边留白策略. 默认为 True, 这是刻度只是作为分割线, 标签和数据点都会在两个刻度之间的带(band) 中间.
- clockwise --> bool : 刻度增长是否按顺时针, 默认为 True
- is_stack --> bool : 数据堆叠, 同个类目轴上系列配置相同的 stack 值可以堆叠放置 .
- axis_range --> list : 坐标轴刻度范围, 默认为 [None, None].
- is_angleaxis_show --> bool : 是否显示极坐标系的角度轴, 默认为 True.
- is_radiusaxis_show --> bool : 是否显示极坐标系的经向轴, 默认为 True.

- is_splitline_show --> bool : 是否显示分割线, 默认为 True
- is_axisline_show --> bool : 是否显示坐标轴线, 默认为 True
- area_opacity --> float : 填充区域透明度
- area_color --> str : 填充区域颜色.

**可配置 lineStyle 参数**

示例一 : 极坐标系 - 散点图示例
    
    # 极坐标系 - 散点
    from pyecharts import Polar
    import random
    data = [(i, random.randint(1, 100)) for i in range(101)]
    polar = Polar("极坐标系-散点图示例")
    polar.add("", data, boundary_gap=False, type='scatter', is_splitline_show=False, area_color=None, is_axisline_show=True)
    polar.show_config()
    polar.render()


    # 极坐标系 - 多重散点
    from pyecharts import Polar
    import random
    data_1 = [(10, random.randint(1, 100)) for i in range(300)]
    data_2 = [(11, random.randint(1, 100)) for i in range(300)]
    polar = Polar("极坐标系-散点图示例", width=1200, height=600)
    polar.add("", data_1, type='scatter')
    polar.add("", data_2, type='scatter')
    polar.show_config()
    polar.render()

    # 极坐标系 - 动态散点图
    from pyecharts import Polar
    import random
    data = [(i, random.randint(1, 100)) for i in range(10)]
    polar = Polar("极坐标系-动态散点图示例", width=1200, height=600)
    polar.add("", data, type='effectScatter', effect_scale=10, effect_period=5)
    polar.show_config()
    polar.render()

示例二 : 极坐标系 - 堆叠柱状图示例 - barRadius

    from pyecharts import Polar

    radius = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    polar = Polar("极坐标系-堆叠柱状图示例", width=1200, height=600)
    polar.add("A", [1, 2, 3, 4, 3, 5, 1], radius_data=radius, type='barRadius', is_stack=True)
    polar.add("B", [2, 4, 6, 1, 2, 3, 1], radius_data=radius, type='barRadius', is_stack=True)
    polar.add("C", [1, 2, 3, 4, 1, 2, 5], radius_data=radius, type='barRadius', is_stack=True)
    polar.show_config()
    polar.render()


示例三 : 极坐标系 - 堆叠柱状图 -- > barAngle

    from pyecharts import Polar
    radius = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    polar = Polar("极坐标系-堆叠柱状图示例", width=1200, height=600)
    polar.add("", [1, 2, 3, 4, 3, 5, 1], radius_data=radius, type='barAngle', is_stack=True)
    polar.add("", [2, 4, 6, 1, 2, 3, 1], radius_data=radius, type='barAngle', is_stack=True)
    polar.add("", [1, 2, 3, 4, 1, 2, 5], radius_data=radius, type='barAngle', is_stack=True)
    polar.show_config()
    polar.render()



## 19. Radar (雷达图)

## 20. Scatter (散点图)

## 21. Scatter3D (3D散点图)

## 22. WordCloud (词云图)
WordCloud.add(name, attr, value, shape="circle", word_gap=20, word_size_range=None, rotate_step=45)

- name --> str : 图例名称
- attr --> list : 属性名称
- value --> list : 属性所对应的值
- shape --> list : 词云图轮廓, 有 cicle, cardioid, diamond, triangle-forward, triangle, pentagon, star 可选. 
- word_gap --> int : 单词间隔, 默认为 20
- word_size_range --> list : 单词字体大小范围, 默认为 [12, 60]
- rotate_step --> int : 旋转单词角度, 默认为 45.

**当且仅当 shape 为默认的'circle'时 rotate_step 参数才生效**

示例一 : 

    from pyecharts import WordCloud
    name = ['Sam S Club', 'Macys', 'Amy Schumer', 'Jurassic World', 'Charter Communications',
            'Chick Fil A', 'Planet Fitness', 'Pitch Perfect', 'Express', 'Home', 'Johnny Depp',
            'Lena Dunham', 'Lewis Hamilton', 'KXAN', 'Mary Ellen Mark', 'Farrah Abraham',
            'Rita Ora', 'Serena Williams', 'NCAA baseball tournament', 'Point Break']
    value = [10000, 6181, 4386, 4055, 2467, 2244, 1898, 1484, 1112, 965, 847, 582, 555,
             550, 462, 366, 360, 282, 273, 265]
    wordcloud = WordCloud(width=1300, height=620)
    wordcloud.add("", name, value, word_size_range=[20, 100])
    wordcloud.show_config()
    wordcloud.render()

示例二 : 
    
    wordcloud = WordCloud(width=1300, height=620)
    wordcloud.add("", name, value, word_size_range=[30, 100], shape='diamond')
    wordcloud.show_config()
    wordcloud.render()


## 23. 用户自定义

### 23.1 Grib : 并行显示多张图
用户可以自定义集合 Line/Bar/Kline/Scatter/EffectScatter/Pie/HeatMap 图表, 将不同类型图表画在多张图上.

**Grid 类的使用**
1. 引入 `Grid` 类, `from pyecharts import Grid`
2. 实例化 `Grid` 类, `grid = Grid()`
3. 使用 `add()` 向 `grid` 中添加图, 至少需要设置 `grid_top`, `grid_bottom`, `grid_left`, `grid_right` 四个参数中的一个. `grid_width` 和 `grid_height` 一般不用设置, 默认即可.
    
    `add()` 参数如下:
    - `grid_width` --> str/int : grid 组件的宽度, 默认自适应
    - `grid_height` --> str/int : grid 组件的高度, 默认自适应
    - `grid_top` --> str/int : grid 组件离容器顶部的距离. 默认为 None, 有 top,center,middle 可选, 也可为 百分数或者整数.
    - `grid_bottom` --> str/int : grid 组件离容器底部的距离. 默认为 None, 有 top,center,middle 可选, 也可为 百分数或者整数.
    - `grid_left` --> str/int : grid 组件离容器左侧的距离. 默认为 None, 有 top,center,middle 可选, 也可为 百分数或者整数.
    - `grid_right` --> str/int : grid 组件离容器右侧的距离. 默认为 None, 有 top,center,middle 可选, 也可为 百分数或者整数.

4. 使用 `render()` 方法渲染成 `.html` 文件.
 
**Grid 类中的其他方法**
`render_embed()` : 在 Flask/Django 中可以使用该方法渲染.
`show_config()` : 打印输出所有配置项.
`chart` : chart 属性返回图形示实例.

示例一 : 上下类型, Bar + Line

    from pyecharts import Bar, Line, Grid
    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    v1 = [5, 20, 36, 10, 75, 90]
    v2 = [10, 25, 8, 60, 20, 80]
    bar = Bar("柱状图示例", height=720)
    bar.add("商家A", attr, v1, is_stack=True)
    bar.add("商家B", attr, v2, is_stack=True)
    
    line = Line("折线图示例", title_top="50%")
    attr = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    line.add("最高气温", attr, [11, 11, 15, 13, 12, 13, 10], mark_point=["max", "min"], mark_line=["average"])
    line.add("最低气温", attr, [1, -2, 2, 5, 3, 2, 0], mark_point=["max", "min"], mark_line=["average"], legend_top="50%")

    grid = Grid()
    grid.add(bar, grid_bottom="60%")
    grid.add(line, grid_top="60%")
    bar.show_config()
    grid.render()

示例二 : 左右类型, Scatter + EffectScatter

    from pyecharts import Scatter, EffectScatter, Grid
    v1 = [5, 20, 36, 10, 75, 90]
    v2 = [10, 25, 8, 60, 20, 80]
    scatter = Scatter(width=1200)
    scatter.add("散点图示例", v1, v2, legend_pos="70%")
    es = EffectScatter()
    es.add("动态散点图示例", [11, 11, 15, 13, 12, 13, 10], [1, -2, 2, 5, 3, 2, 0], effect_scale=6, legend_pos="20%")

    grid = Grid()
    grid.add(scatter, grid_left="60%")
    grid.add(es, grid_right="60%")
    grid.render()

示例三 : 上下左右类型, Bar + Line + Scatter + EffectScatter

    from pyecharts import Bar, Line, Scatter, EffectScatter, Grid  

    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    v1 = [5, 20, 36, 10, 75, 90]
    v2 = [10, 25, 8, 60, 20, 80]
    bar = Bar("柱状图示例", height=720, width=1200, title_pos="65%")
    bar.add("商家A", attr, v1, is_stack=True)
    bar.add("商家B", attr, v2, is_stack=True, legend_pos="80%")
    line = Line("折线图示例")
    attr = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    line.add("最高气温", attr, [11, 11, 15, 13, 12, 13, 10], mark_point=["max", "min"], mark_line=["average"])
    line.add("最低气温", attr, [1, -2, 2, 5, 3, 2, 0], mark_point=["max", "min"],
             mark_line=["average"], legend_pos="20%")
    v1 = [5, 20, 36, 10, 75, 90]
    v2 = [10, 25, 8, 60, 20, 80]
    scatter = Scatter("散点图示例", title_top="50%", title_pos="65%")
    scatter.add("scatter", v1, v2, legend_top="50%", legend_pos="80%")
    es = EffectScatter("动态散点图示例", title_top="50%")
    es.add("es", [11, 11, 15, 13, 12, 13, 10], [1, -2, 2, 5, 3, 2, 0], effect_scale=6,
            legend_top="50%", legend_pos="20%")

    grid = Grid()
    grid.add(bar, grid_bottom="60%", grid_left="60%")
    grid.add(line, grid_bottom="60%", grid_right="60%")
    grid.add(scatter, grid_top="60%", grid_left="60%")
    grid.add(es, grid_top="60%", grid_right="60%")
    grid.render()


### 23.2 Overlap : 结合不同类型图表叠加画在同张图上.
用户可以自定义结合 Line/Bar/Kline, Scatter/EffectScatter 图表, 将不同类型图表画在一张图上, 利用第一个图表为基础, 之后的数据都将画在第一个图表上.

**Overlap 使用方法**
1. 引入 `Overlap` 类, `from pyecharts import Overlap`
2. 实例化 `Overlap` 类, `overlap = Overlap()`
3. 使用 `add()` 向 `overlap` 添加图
4. 使用 `render()` 渲染生成 `.html` 文件

**Overlap 类中的其他方法**
1. `render_embed()` : 在 Flask/Django 中可用该方法渲染.
2. `show_config()` : 打印输出所有配置项
3. `chart` : 返回图形示例.

示例一 : Line + Bar

    from pyecharts import Bar, Line, Overlap
    attr = ['A', 'B', 'C', 'D', 'E', 'F']
    v1 = [10, 20, 30, 40, 50, 60]
    v2 = [38, 28, 58, 48, 78, 68]
    bar = Bar("Line - Bar 示例")
    bar.add("bar", attr, v1)
    line = Line()
    line.add("line", attr, v2)

    overlap = Overlap()
    overlap.add(bar)
    overlap.add(line)
    overlap.render()

示例二 : 

    from pyecharts import Scatter, EffectScatter, Overlap
    v1 = [10, 20, 30, 40, 50, 60]
    v2 = [30, 30, 30, 30, 30, 30]
    v3 = [50, 50, 50, 50, 50, 50]
    v4 = [10, 10, 10, 10, 10, 10]
    es = EffectScatter("Scatter - EffectScatter 示例")
    es.add("es", v1, v2)
    scatter = Scatter()
    scatter.add("scatter", v1, v3)
    es_1 = EffectScatter()
    es_1.add("es_1", v1, v4, symbol='pin', effect_scale=5)

    overlap = Overlap()
    overlap.add(es)
    overlap.add(scatter)
    overlap.add(es_1)
    overlap.render()

示例三 : Kline + Line

    import random
    from pyecharts import Line, Kline, Overlap

    v1 = [[2320.26, 2320.26, 2287.3, 2362.94],
          [2300, 2291.3, 2288.26, 2308.38],
          [2295.35, 2346.5, 2295.35, 2345.92],
          [2347.22, 2358.98, 2337.35, 2363.8],
          [2360.75, 2382.48, 2347.89, 2383.76],
          [2383.43, 2385.42, 2371.23, 2391.82],
          [2377.41, 2419.02, 2369.57, 2421.15],
          [2425.92, 2428.15, 2417.58, 2440.38],
          [2411, 2433.13, 2403.3, 2437.42],
          [2432.68, 2334.48, 2427.7, 2441.73],
          [2430.69, 2418.53, 2394.22, 2433.89],
          [2416.62, 2432.4, 2414.4, 2443.03],
          [2441.91, 2421.56, 2418.43, 2444.8],
          [2420.26, 2382.91, 2373.53, 2427.07],
          [2383.49, 2397.18, 2370.61, 2397.94],
          [2378.82, 2325.95, 2309.17, 2378.82],
          [2322.94, 2314.16, 2308.76, 2330.88],
          [2320.62, 2325.82, 2315.01, 2338.78],
          [2313.74, 2293.34, 2289.89, 2340.71],
          [2297.77, 2313.22, 2292.03, 2324.63],
          [2322.32, 2365.59, 2308.92, 2366.16],
          [2364.54, 2359.51, 2330.86, 2369.65],
          [2332.08, 2273.4, 2259.25, 2333.54],
          [2274.81, 2326.31, 2270.1, 2328.14],
          [2333.61, 2347.18, 2321.6, 2351.44],
          [2340.44, 2324.29, 2304.27, 2352.02],
          [2326.42, 2318.61, 2314.59, 2333.67],
          [2314.68, 2310.59, 2296.58, 2320.96],
          [2309.16, 2286.6, 2264.83, 2333.29],
          [2282.17, 2263.97, 2253.25, 2286.33],
          [2255.77, 2270.28, 2253.31, 2276.22]]
    attr = ["2017/7/{}".format(i + 1) for i in range(31)]
    kline = Kline("Kline - Line 示例")
    kline.add("日K", attr, v1)
    line_1 = Line()
    line_1.add("line-1", attr, [random.randint(2400, 2500) for _ in range(31)])
    line_2 = Line()
    line_2.add("line-2", attr, [random.randint(2400, 2500) for _ in range(31)])

    overlap = Overlap()
    overlap.add(kline)
    overlap.add(line_1)
    overlap.add(line_2)
    overlap.render()

### 23.4 Page : 同一网页按顺序展示多图.

**Page 类的使用**

1. 引入 `Page` 类, `from pyecharts import Page`
2. 实例化 `Page` 类, `page = Page()`
3. 使用 `add()` 向 `page` 实例中添加图片
4. 使用 `render()` 渲染生成 `.html` 文件.

**Page 类中的其他方法**
1. `render_embed()` : 在 Flask/Django 中可以使用该方法渲染
2. `show_config()` : 打印输出所有配置项
3. `chart` : chart 属性返回图形实例.


示例 : 

    #coding=utf-8
    from __future__ import unicode_literals

    from pyecharts import Line, Pie, Kline, Radar
    from pyecharts import Page


    page = Page()

    # line
    attr = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    line = Line("折线图示例")
    line.add("最高气温", attr, [11, 11, 15, 13, 12, 13, 10], mark_point=["max", "min"], mark_line=["average"])
    line.add("最低气温", attr, [1, -2, 2, 5, 3, 2, 0], mark_point=["max", "min"], mark_line=["average"])
    page.add(line)

    # pie
    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    v1 = [11, 12, 13, 10, 10, 10]
    pie = Pie("饼图-圆环图示例", title_pos='center')
    pie.add("", attr, v1, radius=[40, 75], label_text_color=None, is_label_show=True, legend_orient='vertical',
            legend_pos='left')
    page.add(pie)

    # kline
    v1 = [[2320.26, 2320.26, 2287.3, 2362.94],
          [2300, 2291.3, 2288.26, 2308.38],
          [2295.35, 2346.5, 2295.35, 2345.92],
          [2347.22, 2358.98, 2337.35, 2363.8],
          [2360.75, 2382.48, 2347.89, 2383.76],
          [2383.43, 2385.42, 2371.23, 2391.82],
          [2377.41, 2419.02, 2369.57, 2421.15],
          [2425.92, 2428.15, 2417.58, 2440.38],
          [2411, 2433.13, 2403.3, 2437.42],
          [2432.68, 2334.48, 2427.7, 2441.73],
          [2430.69, 2418.53, 2394.22, 2433.89],
          [2416.62, 2432.4, 2414.4, 2443.03],
          [2441.91, 2421.56, 2418.43, 2444.8],
          [2420.26, 2382.91, 2373.53, 2427.07],
          [2383.49, 2397.18, 2370.61, 2397.94],
          [2378.82, 2325.95, 2309.17, 2378.82],
          [2322.94, 2314.16, 2308.76, 2330.88],
          [2320.62, 2325.82, 2315.01, 2338.78],
          [2313.74, 2293.34, 2289.89, 2340.71],
          [2297.77, 2313.22, 2292.03, 2324.63],
          [2322.32, 2365.59, 2308.92, 2366.16],
          [2364.54, 2359.51, 2330.86, 2369.65],
          [2332.08, 2273.4, 2259.25, 2333.54],
          [2274.81, 2326.31, 2270.1, 2328.14],
          [2333.61, 2347.18, 2321.6, 2351.44],
          [2340.44, 2324.29, 2304.27, 2352.02],
          [2326.42, 2318.61, 2314.59, 2333.67],
          [2314.68, 2310.59, 2296.58, 2320.96],
          [2309.16, 2286.6, 2264.83, 2333.29],
          [2282.17, 2263.97, 2253.25, 2286.33],
          [2255.77, 2270.28, 2253.31, 2276.22]]
    kline = Kline("K 线图示例")
    kline.add("日K", ["2017/7/{}".format(i + 1) for i in range(31)], v1)
    page.add(kline)

    # radar
    schema = [("销售", 6500), ("管理", 16000), ("信息技术", 30000), ("客服", 38000), ("研发", 52000), ("市场", 25000)]
    v1 = [[4300, 10000, 28000, 35000, 50000, 19000]]
    v2 = [[5000, 14000, 28000, 31000, 42000, 21000]]
    radar = Radar("雷达图示例")
    radar.config(schema)
    radar.add("预算分配", v1, is_splitline=True, is_axisline_show=True)
    radar.add("实际开销", v2, label_color=["#4e79a7"], is_area_show=False, legend_selectedmode='single')
    page.add(radar)

    page.render()

### 23.5 Timeline : 提供时间线轮播多张图
**Timeline 类的使用**
1. 引入 `TimeLIne` 类, `from pyecharts import Timeline`
2. 实例化 `Timeline` 类, `timeline = Timeline()`
    
    实例化 Timeline 类时接受设置参数.
    - is_auto_play -> bool

        是否自动播放，默认为 Flase

    - is_loop_play -> bool

        是否循环播放，默认为 True

    - is_rewind_play -> bool

        是否方向播放，默认为 Flase

    - is_timeline_show -> bool

        是否显示 timeline 组件。默认为 True，如果设置为false，不会显示，但是功能还存在。

    - timeline_play_interval -> int

        播放的速度（跳动的间隔），单位毫秒（ms）。

    - timeline_symbol -> str

        标记的图形。ECharts 提供的标记类型包括 'circle', 'rect', 'roundRect', 'triangle', 'diamond', 'pin', 'arrow'

    - timeline_symbol_size -> int/list

        标记的图形大小，可以设置成诸如 10 这样单一的数字，也可以用数组分开表示宽和高，例如 [20, 10] 表示标记宽为 20，高为 10。

    - timeline_left -> int/str

        timeline 组件离容器左侧的距离。

        left 的值可以是像 20 这样的具体像素值，可以是像 '20%' 这样相对于容器高宽的百分比，也可以是 'left', 'center', 'right'。如果 left 的值为'left', 'center', 'right'，组件会根据相应的位置自动对齐。

    - timeline_right -> int/str

        timeline 组件离容器右侧的距离。同 left

    - timeline_top -> int/str

        timeline 组件离容器顶侧的距离。同 left

    - timeline_bottom -> int/str

        timeline 组件离容器底侧的距离。同 left


3. 使用 `add()` 向 `timeline` 中添加图. 该方法接受两个参数, 第一个为 **图实例** , 第二个为时间线的**时间点**.
4. 使用 `render() 渲染成 `.html` 文件.

**Timeline 类中的其他**
1. `render_embed()` : 在 Flask/Django 中可以使用该方法渲染
2. `show_config()` : 打印输出所有配置项
3. `chart` : chart 属性返回图形实例.

示例一 : 

    from pyecharts import Bar, Timeline

    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    bar_1 = Bar("2012 年销量", "数据纯属虚构")
    bar_1.add("春季", attr, [randint(10, 100) for _ in range(6)])
    bar_1.add("夏季", attr, [randint(10, 100) for _ in range(6)])
    bar_1.add("秋季", attr, [randint(10, 100) for _ in range(6)])
    bar_1.add("冬季", attr, [randint(10, 100) for _ in range(6)])

    bar_2 = Bar("2013 年销量", "数据纯属虚构")
    bar_2.add("春季", attr, [randint(10, 100) for _ in range(6)])
    bar_2.add("夏季", attr, [randint(10, 100) for _ in range(6)])
    bar_2.add("秋季", attr, [randint(10, 100) for _ in range(6)])
    bar_2.add("冬季", attr, [randint(10, 100) for _ in range(6)])

    bar_3 = Bar("2014 年销量", "数据纯属虚构")
    bar_3.add("春季", attr, [randint(10, 100) for _ in range(6)])
    bar_3.add("夏季", attr, [randint(10, 100) for _ in range(6)])
    bar_3.add("秋季", attr, [randint(10, 100) for _ in range(6)])
    bar_3.add("冬季", attr, [randint(10, 100) for _ in range(6)])

    bar_4 = Bar("2015 年销量", "数据纯属虚构")
    bar_4.add("春季", attr, [randint(10, 100) for _ in range(6)])
    bar_4.add("夏季", attr, [randint(10, 100) for _ in range(6)])
    bar_4.add("秋季", attr, [randint(10, 100) for _ in range(6)])
    bar_4.add("冬季", attr, [randint(10, 100) for _ in range(6)])

    bar_5 = Bar("2016 年销量", "数据纯属虚构")
    bar_5.add("春季", attr, [randint(10, 100) for _ in range(6)])
    bar_5.add("夏季", attr, [randint(10, 100) for _ in range(6)])
    bar_5.add("秋季", attr, [randint(10, 100) for _ in range(6)])
    bar_5.add("冬季", attr, [randint(10, 100) for _ in range(6)], is_legend_show=True)

    timeline = Timeline(is_auto_play=True, timeline_bottom=0)
    timeline.add(bar_1, '2012 年')
    timeline.add(bar_2, '2013 年')
    timeline.add(bar_3, '2014 年')
    timeline.add(bar_4, '2015 年')
    timeline.add(bar_5, '2016 年')
    timeline.render()

示例二 : 

    from pyecharts import Pie, Timeline

    attr = ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
    pie_1 = Pie("2012 年销量比例", "数据纯属虚构")
    pie_1.add("秋季", attr, [randint(10, 100) for _ in range(6)],
              is_label_show=True, radius=[30, 55], rosetype='radius')

    pie_2 = Pie("2013 年销量比例", "数据纯属虚构")
    pie_2.add("秋季", attr, [randint(10, 100) for _ in range(6)],
              is_label_show=True, radius=[30, 55], rosetype='radius')

    pie_3 = Pie("2014 年销量比例", "数据纯属虚构")
    pie_3.add("秋季", attr, [randint(10, 100) for _ in range(6)],
              is_label_show=True, radius=[30, 55], rosetype='radius')

    pie_4 = Pie("2015 年销量比例", "数据纯属虚构")
    pie_4.add("秋季", attr, [randint(10, 100) for _ in range(6)],
              is_label_show=True, radius=[30, 55], rosetype='radius')

    pie_5 = Pie("2016 年销量比例", "数据纯属虚构")
    pie_5.add("秋季", attr, [randint(10, 100) for _ in range(6)],
              is_label_show=True, radius=[30, 55], rosetype='radius')

    timeline = Timeline(is_auto_play=True, timeline_bottom=0)
    timeline.add(pie_1, '2012 年')
    timeline.add(pie_2, '2013 年')
    timeline.add(pie_3, '2014 年')
    timeline.add(pie_4, '2015 年')
    timeline.add(pie_5, '2016 年')
    timeline.show_config()
    timeline.render()


## 24. pyecharts 集成 Flask
核心原理: 使用 render_template 将 Type.render_embed() 返回的 js 代码, 作为参数传入 template 中, template 需要事先加载 所需要的 js 库.

template 代码示例

    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="utf-8">
        <title>ECharts</title>
        <script src="http://oog4yfyu0.bkt.clouddn.com/echarts.min.js"></script>
        <script src="http://oog4yfyu0.bkt.clouddn.com/echarts-gl.js"></script>
        <script type="text/javascript " src="http://echarts.baidu.com/gallery/vendors/echarts/map/js/china.js"></script>
        <script type="text/javascript " src="http://echarts.baidu.com/gallery/vendors/echarts/map/js/world.js"></script>
        <script type="text/javascript " src="http://oog4yfyu0.bkt.clouddn.com/wordcloud.js"></script>
    </head>

    <body>
      {{myechart|safe}}
    </body>

    </html>

flaks 代码示例
    
    from flask import Flask, render_template
    app = Flask(__name__)


    @app.route("/")
    def hello():
        return render_template('pyecharts.html', myechart=scatter3d())


    def scatter3d():
        from pyecharts import Scatter3D

        import random
        data = [[random.randint(0, 100), random.randint(0, 100), random.randint(0, 100)] for _ in range(80)]
        range_color = ['#313695', '#4575b4', '#74add1', '#abd9e9', '#e0f3f8', '#ffffbf',
                       '#fee090', '#fdae61', '#f46d43', '#d73027', '#a50026']
        scatter3D = Scatter3D("3D scattering plot demo", width=1200, height=600)
        scatter3D.add("", data, is_visualmap=True, visual_range_color=range_color)
        return scatter3D.render_embed()