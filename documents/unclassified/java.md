## java 标准库与第三方库

java.lang : 内部导入, 直接使用, 无需导入.

Doug Lea

slf4j: 日志模式

依赖注入:
    guice
    dagger

ioc: 控制反转模式

junit framework


mvn dependency:tree

菱形依赖: shade 抽取函数, 而非完全拷贝包.

giai :
    - hy 熔断

giai.impl --> 扩展.
    options

一个仓库:
    grpc-regression
    load testing

grpc: 版本 1.0.3

## 修饰符

访问控制修饰符 : Java中，可以使用访问控制符来保护对类、变量、方法和构造方法的访问。Java 支持 4 种不同的访问权限。
- default (即默认，什么也不写）: 在同一包内可见，不使用任何修饰符。使用对象：类、接口、变量、方法。
- private : 在同一类内可见。使用对象：变量、方法。 注意：不能修饰类（外部类）
- public : 对所有类可见。使用对象：类、接口、变量、方法
- protected : 对同一包内的类和所有子类可见。使用对象：变量、方法。 注意：不能修饰类（外部类）。

非访问修饰符: 
- static 修饰符，用来修饰类方法和类变量。
- final 修饰符，用来修饰类、方法和变量，final 修饰的类不能够被继承，修饰的方法不能被继承类重新定义，修饰的变量为常量，是不可修改的。
- abstract 修饰符，用来创建抽象类和抽象方法。
- synchronized 和 volatile 修饰符，主要用于线程的编程。
  - synchronized 关键字声明的方法同一时间只能被一个线程访问。synchronized 修饰符可以应用于四个访问修饰符。
  - volatile 修饰的成员变量在每次被线程访问时，都强制从共享内存中重新读取该成员变量的值。而且，当成员变量发生变化时，会强制线程将变化值回写到共享内存。这样在任何时刻，两个不同的线程总是看到某个成员变量的同一个值。
  - transient 该修饰符包含在定义变量的语句中，用来预处理类和变量的数据类型。序列化的对象包含被 transient 修饰的实例变量时，java 虚拟机(JVM)跳过该特定的变量。

### 访问控制和继承
请注意以下方法继承的规则：
- 父类中声明为 public 的方法在子类中也必须为 public。
- 父类中声明为 protected 的方法在子类中要么声明为 protected，要么声明为 public，不能声明为 private。
- 父类中声明为 private 的方法，不能够被继承。

## 方法

### 方法重载
如果你调用max方法时传递的是int型参数，则 int型参数的max方法就会被调用；

如果传递的是double型参数，则double类型的max方法体会被调用，这叫做**方法重载**；

就是说一个类的两个方法拥有相同的名字，但是有不同的参数列表。

Java编译器根据**方法签名**判断哪个方法应该被调用。

方法重载可以让程序更清晰易读。执行密切相关任务的方法应该使用相同的名字。

重载的方法必须拥有不同的参数列表。你不能仅仅依据修饰符或者返回类型的不同来重载方法。

### 命令行参数

传递命令行参数给`main()`函数实现。

命令行参数是在执行程序时候紧跟在程序名字后面的信息。

```java
public class CommandLine {
   public static void main(String args[]){ 
      for(int i=0; i<args.length; i++){
         System.out.println("args[" + i + "]: " + args[i]);
      }
   }
}
/*
运行: 
$ javac CommandLine.java
$ java CommandLine this is a args
*/

```


### 构造方法
当一个对象被创建时候，构造方法用来初始化该对象。构造方法和它所在类的**名字相同**，但构造方法没有返回值。

通常会使用构造方法给一个类的实例变量赋初值，或者执行其它必要的步骤来创建一个完整的对象。

不管你是否自定义构造方法，所有的类都有构造方法，因为 Java 自动提供了一个**默认构造方法**，默认构造方法的访问修饰符和类的访问修饰符相同(类为 public，构造函数也为 public；类改为 protected，构造函数也改为 protected)。

一旦你定义了自己的构造方法，默认构造方法就会失效。


```java
public class ConsDemo {
  public static void main(String args[]) {
    MyClass t1 = new MyClass( 10 );
    MyClass t2 = new MyClass( 20 );
    System.out.println(t1.x + " " + t2.x);
  }
}

class MyClass {
  int x;

  // 以下是构造函数
  MyClass(int i ) {
    x = i;
  }
}
```

### 可变参数
```java
typeName... parameterName
```
在方法声明中，在指定参数类型后加一个省略号(`...`).

一个方法中只能指定**一个**可变参数，它必须是方法的**最后一个参数**。任何普通的参数必须在它之前声明。

### finalize() 方法
Java 允许定义这样的方法，它在对象被垃圾收集器析构(回收)之**前**调用，这个方法叫做 finalize( )，它用来清除回收对象。

例如，你可以使用 finalize() 来确保一个对象打开的文件被关闭了。

在 finalize() 方法里，你必须指定在对象销毁时候要执行的操作。

finalize() 一般格式是：
```java
protected void finalize()
{
   // 在这里终结代码
}
```
关键字 protected 是一个限定符，它确保 finalize() 方法不会被该类以外的代码调用。

当然，Java 的内存回收可以由 JVM 来自动完成。如果你手动使用，则可以使用上面的方法。


```java
public class FinalizationDemo {
    public static void main(String[] args) {
        Cake c1 = new Cake(1);
        Cake c2 = new Cake(2);
        Cake c3 = new Cake(3);

        c2 = c3 = null;

        System.gc();    // 调用 Java 垃圾收集器.
    }
}

class Cake extends Object {
    private int id;

    public Cake(int id) {
        this.id = id;
        System.out.println("Cake object " + id + "is created");
    }

    protected void finalize() throws java.lang.Throwable {
        super.finalize();
        System.out.println("Cake object " + id + "is disposed");
    }
}
```

## 异常处理

- 检查性异常：最具代表的检查性异常是用户错误或问题引起的异常，这是程序员无法预见的。例如要打开一个不存在文件时，一个异常就发生了，这些异常在编译时不能被简单地忽略。
- 运行时异常： 运行时异常是可能被程序员避免的异常。与检查性异常相反，运行时异常可以在编译时被忽略。
- 错误： 错误不是异常，而是脱离程序员控制的问题。错误在代码中通常被忽略。例如，当栈溢出时，一个错误就发生了，它们在编译也检查不到的。


### throws/throw 关键字

如果一个方法没有捕获到一个检查性异常，那么该方法必须使用 throws 关键字来声明。throws 关键字放在方法签名的尾部。

也可以使用 throw 关键字抛出一个异常，无论它是新实例化的还是刚捕获到的。一个方法可以声明抛出多个异常，多个异常之间用逗号隔开。

```java
import java.io.*;
public class className
{
   public void withdraw(double amount) throws RemoteException,
                              InsufficientFundsException
   {
       // Method implementation
   }
   //Remainder of class definition
}
```

### finally关键字
finally 关键字用来创建在 try 代码块后面执行的代码块。

无论是否发生异常，finally 代码块中的代码总会被执行。

在 finally 代码块中，可以运行清理类型等收尾善后性质的语句。

finally 代码块出现在 catch 代码块最后，语法如下：

```java
try{
  // 程序代码
}catch(异常类型1 异常的变量名1){
  // 程序代码
}catch(异常类型2 异常的变量名2){
  // 程序代码
}finally{
  // 程序代码
}
```

### 声明自定义异常
在 Java 中你可以自定义异常。编写自己的异常类时需要记住下面的几点。
- 所有异常都必须是 Throwable 的子类。
- 如果希望写一个检查性异常类，则需要继承 Exception 类。
- 如果你想写一个运行时异常类，那么需要继承 RuntimeException 类。

可以像下面这样定义自己的异常类：

```java
class MyException extends Exception{
}
```

只继承 `Exception` 类来创建的异常类是检查性异常类。

下面的 `InsufficientFundsException` 类是用户定义的异常类，它继承自 Exception。

一个异常类和其它任何类一样，包含有变量和方法。

## 继承

Java 是单继承, 不支持多继承, 但支持多重继承( B 类继承 A 类，C 类继承 B 类，按照关系就是 B 类是 C 类的父类，A 类是 B 类的父类).


继承的特性
- 子类拥有父类非 private 的属性、方法。
- 子类可以拥有自己的属性和方法，即子类可以对父类进行扩展。
- 子类可以用自己的方式实现父类的方法。
- Java 的继承是单继承，但是可以多重继承，单继承就是一个子类只能继承一个父类，多重继承就是，例如 B 类继承 A 类，C 类继承 B 类，所以按照关系就是 B 类是 C 类的父类，A 类是 B 类的父类，这是 Java 继承区别于 C++ 继承的一个特性。
- 提高了类之间的耦合性（继承的缺点，耦合度高就会造成代码之间的联系越紧密，代码独立性越差）。

继承可以使用 `extends` 和 `implements` 这两个关键字来实现继承，而且所有的类都是继承于 `java.lang.Object`, 当一个类没有继承的两个关键字，则默认继承 object（这个类在 java.lang 包中，所以不需要 import）祖先类。

- `extends`: 在 Java 中，类的继承是单一继承，也就是说，一个子类只能拥有一个父类，所以 extends 只能继承一个类。
    
    ```java
    public class Animal { 
        private String name;   
        private int id; 
        public Animal(String myName, String myid) { 
            //初始化属性值
        } 
        public void eat() {  //吃东西方法的具体实现  } 
        public void sleep() { //睡觉方法的具体实现  } 
    } 
    
    public class Penguin  extends  Animal{ 
    }
    ```

- `implements`: 使用 implements 关键字可以变相的使java具有多继承的特性，使用范围为类继承接口的情况，可以同时继承多个接口(接口跟接口之间采用逗号分隔).

    ```java
    public interface A {
        public void eat();
        public void sleep();
    }
    
    public interface B {
        public void show();
    }
    
    public class C implements A,B {
    }
    ```

- super 与 this 关键字

    - `super` : 我们可以通过super关键字来实现对父类成员的访问，用来引用当前对象的父类。
    - `this` : 指向自己的引用。

    ```java
    class Animal {
        void eat() {
            System.out.println("animal : eat");
        }
    }
    
    class Dog extends Animal {
        void eat() {
            System.out.println("dog : eat");
        }
        void eatTest() {
            this.eat();   // this 调用自己的方法
            super.eat();  // super 调用父类方法
        }
    }
    
    public class Test {
        public static void main(String[] args) {
            Animal a = new Animal();
            a.eat();
            Dog d = new Dog();
            d.eatTest();
        }
    }
    ```



### 方法的重写

- 参数列表与被重写方法的参数列表必须**完全相同**。
- 返回类型与被重写方法的返回类型可以**不相同**，但是必须是父类返回值的派生类（java5 及更早版本返回类型要一样，java7 及更高版本可以不同）。
- 访问权限**不能**比父类中被重写的方法的访问权限更*低*。例如：如果父类的一个方法被声明为 public，那么在子类中重写该方法就不能声明为 protected。
- 父类的成员方法只能被它的子类重写。
- 声明为 `final` 的方法不能被重写。
- 声明为 `static` 的方法不能被重写，但是能够被再次声明。
- 子类和父类在同一个包中，那么子类可以重写父类所有方法，除了声明为 private 和 final 的方法。
- 子类和父类不在同一个包中，那么子类只能够重写父类的声明为 public 和 protected 的非 final 方法。
- 重写的方法能够抛出任何非强制异常，无论被重写的方法是否抛出异常。但是，重写的方法不能抛出新的强制性异常，或者比被重写方法声明的更广泛的强制性异常，反之则可以。
- 构造方法不能被重写。
- 如果不能继承一个类，则不能重写该类的方法。

### 重载

重载(overloading) 是在一个类里面，方法名字相同，而参数不同。返回类型可以相同也可以不同。

每个重载的方法（或者构造函数）都必须有一个独一无二的参数类型列表。

最常用的地方就是构造器的重载。

重载规则:
- 被重载的方法**必须**改变参数列表(参数个数或类型不一样)；
- 被重载的方法**可以**改变返回类型；
- 被重载的方法**可以**改变访问修饰符；
- 被重载的方法**可以**声明新的或更广的检查异常；
- 方法能够在同一个类中或者在一个子类中被重载。
- 无法以返回值类型作为重载函数的区分标准。

重写与重载之间的区别: 方法的重写(Overriding)和重载(Overloading)是java多态性的不同表现，重写是父类与子类之间多态性的一种表现，重载可以理解成多态的具体表现形式。

| 区别点 | 重载方法  |  重写方法 |
| -- | -- | -- |
| 参数列表 |    必须修改  |  一定不能修改 |
| 返回类型 |    可以修改  |  一定不能修改 |
| 异常 |  可以修改  |  可以减少或删除，一定不能抛出新的或者更广的异常 |
| 访问 |  可以修改  |  一定不能做更严格的限制（可以降低限制） |

### 多态

多态是同一个行为具有多个不同表现形式或形态的能力。

多态就是同一个接口，使用不同的实例而执行不同操作.

多态存在的三个必要条件: 
- 继承
- 重写
- 父类引用指向子类对象：`Parent p = new Child();`

多态的实现方式
- 方式一：重写：

    这个内容已经在上一章节详细讲过，就不再阐述，详细可访问：Java 重写(Override)与重载(Overload)。

- 方式二：接口

    1. 生活中的接口最具代表性的就是插座，例如一个三接头的插头都能接在三孔插座中，因为这个是每个国家都有各自规定的接口规则，有可能到国外就不行，那是因为国外自己定义的接口类型。

    2. java中的接口类似于生活中的接口，就是一些方法特征的集合，但没有方法的实现。具体可以看 java接口 这一章节的内容。

- 方式三：抽象类和抽象方法

    抽象类除了不能实例化对象之外，类的其它功能依然存在，成员变量、成员方法和构造方法的访问方式和普通类一样。

    由于抽象类不能实例化对象，所以抽象类必须被继承，才能被使用。也是因为这个原因，通常在设计阶段决定要不要设计抽象类。

    在Java中抽象类表示的是一种继承关系，一个类只能继承一个抽象类，而一个类却可以实现多个接口。

    如果你想设计这样一个类，该类包含一个特别的成员方法，该方法的具体实现由它的子类确定，那么你可以在父类中声明该方法为抽象方法。

    Abstract 关键字同样可以用来声明抽象方法，抽象方法只包含一个方法名，而没有方法体。

    抽象方法没有定义，方法名后面直接跟一个分号，而不是花括号。构造方法，类方法（用 static 修饰的方法）不能声明为抽象方法。

    ```java
    public abstract class Employee
    {
    private String name;
    private String address;
    private int number;
    
    public abstract double computePay();
    
    //其余代码
    }
    ```

    声明**抽象方法**会造成以下两个结果: 
    - 如果一个类包含抽象方法，那么该类必须是抽象类。
    - 任何子类必须重写父类的抽象方法，或者声明自身为抽象类。

## Java 封装

封装可以被认为是一个保护屏障，防止该类的代码和数据被外部类定义的代码随机访问。要访问该类的代码和数据，必须通过严格的接口控制。

封装最主要的功能在于我们能修改自己的实现代码，而不用修改那些调用我们代码的程序片段。

适当的封装可以让程式码更容易理解与维护，也加强了程式码的安全性。

实现 Java 封装的步骤:
- 修改属性的可见性来限制对属性的访问（一般限制为private）
- 对每个值属性提供对外的公共方法访问，也就是创建一对赋取值方法，用于对私有属性的访问.


```java
/* 文件名: EncapTest.java */
public class EncapTest{
 
   private String name;
   private String idNum;
   private int age;
 
   public int getAge(){
      return age;
   }
 
   public String getName(){
      return name;
   }
 
   public String getIdNum(){
      return idNum;
   }
 
   public void setAge( int newAge){
      age = newAge;
   }
 
   public void setName(String newName){
      name = newName;
   }
 
   public void setIdNum( String newId){
      idNum = newId;
   }
}

/* F文件名 : RunEncap.java */
public class RunEncap{
   public static void main(String args[]){
      EncapTest encap = new EncapTest();
      encap.setName("James");
      encap.setAge(20);
      encap.setIdNum("12343ms");
 
      System.out.print("Name : " + encap.getName()+ 
                             " Age : "+ encap.getAge());
    }
}
```

## Java 接口

接口，在JAVA编程语言中是一个**抽象类型**，是**抽象方法**的集合，接口通常以`interface`来声明。一个类通过继承接口的方式，从而来继承接口的抽象方法。

接口并不是类，编写接口的方式和类很相似，但是它们属于不同的概念。类描述对象的属性和方法。接口则包含类要实现的方法。

除非实现接口的类是抽象类，否则该类要定义接口中的所有方法。

接口**无法被实例化**，但是可以被实现。一个实现接口的类，必须实现接口内所描述的所有方法，否则就必须声明为抽象类。另外，在 Java 中，接口类型可用来声明一个变量，他们可以成为一个空指针，或是被绑定在一个以此接口实现的对象。

接口与类的区别：
- 接口不能用于实例化对象。
- 接口没有构造方法。
- 接口中所有的方法必须是抽象方法。
- 接口不能包含成员变量，除了 static 和 final 变量。
- 接口不是被类继承了，而是要被类实现。
- 接口支持多继承。

接口特性
- 接口是**隐式抽象**的，当声明一个接口的时候，不必使用abstract关键字。
- 接口中每一个方法也是**隐式抽象**的,接口中的方法会被隐式的指定为 `public abstract`（只能是 public abstract，其他修饰符都会报错）。
- 接口中可以含有变量，但是接口中的变量会被隐式的指定为 `public static final` 变量（并且只能是 public，用 private 修饰会报编译错误）。
- 接口中的方法是不能在接口中实现的，只能由实现接口的类来实现接口中的方法。

抽象类和接口的区别
- 抽象类中的方法可以有方法体，就是能实现方法的具体功能，但是接口中的方法不行。
- 抽象类中的成员变量可以是各种类型的，而接口中的成员变量只能是 `public static final` 类型的。
- 接口中不能含有静态代码块以及静态方法(用 static 修饰的方法)，而抽象类是可以有静态代码块和静态方法。
- 一个类只能继承一个抽象类，而一个类却可以实现多个接口。

**Tips**:
- JDK 1.8 以后，接口里可以有静态方法和方法体了。
- JDK 1.8 以后，接口允许包含具体实现的方法，该方法称为"默认方法"，默认方法使用 default 关键字修饰。更多内容可参考 Java 8 默认方法。
- JDK 1.9 以后，允许将方法定义为 private，使得某些复用的代码不会把方法暴露出去。更多内容可参考 Java 9 私有接口方法。

### 声明接口
```java
[可见度] interface 接口名称 [extends 其他的接口名] {
        // 声明变量
        // 抽象方法
}

// 实例
interface Animal {
   public void eat();
   public void travel();
}
```

### 接口的实现
当类实现接口的时候，类要实现接口中所有的方法。否则，类必须声明为抽象的类。
类使用implements关键字实现接口。在类声明中，Implements关键字放在class声明后面。

```java
public class MammalInt implements Animal{
 
   public void eat(){
      System.out.println("Mammal eats");
   }
 
   public void travel(){
      System.out.println("Mammal travels");
   } 
 
   public int noOfLegs(){
      return 0;
   }
 
   public static void main(String args[]){
      MammalInt m = new MammalInt();
      m.eat();
      m.travel();
   }
}
```

重写接口中声明的方法时，需要注意以下规则：
- 类在实现接口的方法时，不能抛出强制性异常，只能在接口中，或者继承接口的抽象类中抛出该强制性异常。
- 类在重写方法时要保持一致的方法名，并且应该保持相同或者相兼容的返回值类型。
- 如果实现接口的类是抽象类，那么就没必要实现该接口的方法。

在实现接口的时候，也要注意一些规则：
- 一个类可以同时实现多个接口。
- 一个类只能继承一个类，但是能实现多个接口。
- 一个接口能继承另一个接口，这和类之间的继承比较相似。

### 接口的继承

一个接口能继承另一个接口，和类之间的继承方式比较相似。接口的继承使用`extends`关键字，子接口继承父接口的方法。

```java
// 文件名: Sports.java
public interface Sports
{
   public void setHomeTeam(String name);
   public void setVisitingTeam(String name);
}
 
// 文件名: Football.java
public interface Football extends Sports
{
   public void homeTeamScored(int points);
   public void visitingTeamScored(int points);
   public void endOfQuarter(int quarter);
}
 
// 文件名: Hockey.java
public interface Hockey extends Sports
{
   public void homeGoalScored();
   public void visitingGoalScored();
   public void endOfPeriod(int period);
   public void overtimePeriod(int ot);
}
```

接口允许**多继承**。在接口的多继承中extends关键字只需要使用一次，在其后跟着继承接口。
```java
public interface Hockey extends Sports, Event
```

### 标记接口

最常用的继承接口是*没有包含任何方法的接口*。

**标记接口**是没有任何方法和属性的接口. 它仅仅表明它的类属于一个特定的类型,供其他代码来测试允许做一些事情。

**标记接口**作用：简单形象的说就是给某个对象打个标（盖个戳），使对象拥有某个或某些特权。

```java
package java.util;
public interface EventListener
{}
```

标记接口主要用于以下两种目的 : 
- 建立一个公共的父接口 : 

    正如EventListener接口，这是由几十个其他接口扩展的Java API，你可以使用一个标记接口来建立一组接口的父接口。例如 : 当一个接口继承了EventListener接口，Java虚拟机(JVM)就知道该接口将要被用于一个事件的代理方案。

- 向一个类添加数据类型 : 

    这种情况是标记接口最初的目的，实现标记接口的类不需要定义任何接口方法(因为标记接口根本就没有方法)，但是该类通过多态性变成一个接口类型。

## 枚举

Java 枚举是一个特殊的**类**，一般表示一组常量，比如一年的 4 个季节，一个年的 12 个月份，一个星期的 7 天，方向有东南西北等。

Java 枚举类使用 `enum` 关键字来定义，各个常量使用逗号 `,` 来分割。

每个枚举都是通过 Class 在内部实现的，且所有的枚举值都是 `public static final`的。

```java
enum Color
{
    RED, GREEN, BLUE;
}
 
public class Test
{
    // 执行输出结果
    public static void main(String[] args)
    {
        Color c1 = Color.RED;
        System.out.println(c1);
    }
}

// 在内部类中使用枚举
public class Test
{
    enum Color
    {
        RED, GREEN, BLUE;
    }
 
    // 执行输出结果
    public static void main(String[] args)
    {
        Color c1 = Color.RED;
        System.out.println(c1);
    }
}

// 使用 for 迭代枚举类: Color.values()
enum Color
{
    RED, GREEN, BLUE;
}
public class MyClass {
  public static void main(String[] args) {
    for (Color myVar : Color.values()) {
      System.out.println(myVar);
    }
  }
}
```

### `values()`, `ordinal()` 和 `valueOf()` 方法

`enum` 定义的枚举类默认继承了 `java.lang.Enum` 类，并实现了 `java.lang.Seriablizable` 和 `java.lang.Comparable` 两个接口。

`values()`, `ordinal()` 和 `valueOf()` 方法位于 `java.lang.Enum` 类中: 
- `values()` : 返回枚举类中所有的值。
- `ordinal()` : 方法可以找到每个枚举常量的**索引**，就像数组索引一样。
- `valueOf()` : 方法返回指定字符串值的枚举常量。

```java
enum Color
{
    RED, GREEN, BLUE;
}
 
public class Test
{
    public static void main(String[] args)
    {
        // 调用 values()
        Color[] arr = Color.values();
 
        // 迭代枚举
        for (Color col : arr)
        {
            // 查看索引
            System.out.println(col + " at index " + col.ordinal());
        }
 
        // 使用 valueOf() 返回枚举常量，不存在的会报错 IllegalArgumentException
        System.out.println(Color.valueOf("RED"));   // 返回 READ
        // System.out.println(Color.valueOf("WHITE"));
    }
}
```

### 枚举类成员
枚举跟普通类一样可以用自己的变量、方法和构造函数，构造函数只能使用 private 访问修饰符，所以外部无法调用。

枚举既可以包含具体方法，也可以包含抽象方法。 如果枚举类具有抽象方法，则枚举类的每个实例都必须实现它。

```java
enum Color
{
    RED, GREEN, BLUE;
 
    // 构造函数
    private Color()
    {
        System.out.println("Constructor called for : " + this.toString());
    }
 
    public void colorInfo()
    {
        System.out.println("Universal Color");
    }
}
 
public class Test
{    
    // 输出
    public static void main(String[] args)
    {
        Color c1 = Color.RED;
        System.out.println(c1);
        c1.colorInfo();
    }
}
```

枚举类中的抽象方法:
```java
enum Color{
    RED{
        public String getColor(){   //枚举对象实现抽象方法
            return "红色";
        }
    },
    GREEN{
        public String getColor(){   //枚举对象实现抽象方法
            return "绿色";
        }
    },
    BLUE{
        public String getColor(){   //枚举对象实现抽象方法
            return "蓝色";
        }
    };
    public abstract String getColor();//定义抽象方法
}

public class Test{
    public static void main(String[] args) {
        for (Color c:Color.values()){
            System.out.print(c.getColor() + "、");
        }
    }
}
```


## 包
通常使用小写的字母来命名避免与类、接口名字的冲突。
包声明应该在源文件的第一行，每个源文件只能有一个包声明，这个文件中的每个类型都应用于它。

如果一个源文件中没有使用包声明，那么其中的类，函数，枚举，注释等将被放在一个无名的包（unnamed package）中。

### package

```java
package pkg1[．pkg2[．pkg3…]];
```

package 目录结构 , 类放在包中会有两种主要的结果: 
- 包名成为类名的一部分
- 包名必须与相应的**字节码所在的目录结构**相吻合。

通常，一个公司使用它互联网域名的颠倒形式来作为它的包名.例如：互联网域名是 runoob.com，所有的包名都以 com.runoob 开头。包名中的每一个部分对应一个子目录。

用`-d`选项来编译这个文件，如下：
```bash
$ javac -d . Runoob.java
```

类目录的绝对路径叫做 class path。设置在系统变量 CLASSPATH 中。编译器和 java 虚拟机通过将 package 名字加到 class path 后来构造 .class 文件的路径。

一个 class path 可能会包含好几个路径，多路径应该用分隔符分开。默认情况下，编译器和 JVM 查找当前目录。JAR 文件按包含 Java 平台相关的类，所以他们的目录默认放在了 class path 中。

### import 

类文件中可以包含**任意数量**的 `import` 声明。`import` 声明必须在包声明之**后**，类声明之**前**。

```java
import package1[.package2…].(classname|*);
```



## Java 数据结构

### 枚举 `Enumeration`
枚举（Enumeration）接口虽然它本身不属于数据结构,但它在其他数据结构的范畴里应用很广。 枚举（The Enumeration）接口定义了一种从数据结构中取回连续元素的方式。

- `boolean hasMoreElements()` 测试此枚举是否包含更多的元素。
- `Object nextElement()` 如果此枚举对象至少还有一个可提供的元素，则返回此枚举的下一个元素。

```java
import java.util.Vector;
import java.util.Enumeration;
 
public class EnumerationTester {
   public static void main(String args[]) {
      Enumeration<String> days;
      Vector<String> dayNames = new Vector<String>();
      dayNames.add("Sunday");
      dayNames.add("Monday");
      dayNames.add("Tuesday");
      dayNames.add("Wednesday");
      dayNames.add("Thursday");
      dayNames.add("Friday");
      dayNames.add("Saturday");

      days = dayNames.elements();
      
      while (days.hasMoreElements()){
         System.out.println(days.nextElement()); 
      }
   }
}
```

### 位集合 `BitSet`
位集合类实现了一组可以单独设置和清除的位或标志。

该类在处理一组布尔值的时候非常有用，你只需要给每个值赋值一"位"，然后对位进行适当的设置或清除，就可以对布尔值进行操作了。

BitSet中实现了Cloneable接口中定义的方法.


构造方法:
```java
BitSet()

BitSet(int size)
```

示例:
```java
import java.util.BitSet;
 
public class BitSetDemo {
 
  public static void main(String args[]) {
     BitSet bits1 = new BitSet(16);
     BitSet bits2 = new BitSet(16);
      
     // set some bits
     for(int i=0; i<16; i++) {
        if((i%2) == 0) bits1.set(i);
        if((i%5) != 0) bits2.set(i);
     }
     System.out.println("Initial pattern in bits1: ");
     System.out.println(bits1);
     System.out.println("\nInitial pattern in bits2: ");
     System.out.println(bits2);
 
     // AND bits
     bits2.and(bits1);
     System.out.println("\nbits2 AND bits1: ");
     System.out.println(bits2);
 
     // OR bits
     bits2.or(bits1);
     System.out.println("\nbits2 OR bits1: ");
     System.out.println(bits2);
 
     // XOR bits
     bits2.xor(bits1);
     System.out.println("\nbits2 XOR bits1: ");
     System.out.println(bits2);
  }
}
```

### 向量 `Vector`
向量（Vector）类和传统数组非常相似，但是Vector的大小能根据需要动态的变化。

Vector 是同步访问的。

和数组一样，Vector对象的元素也能通过索引访问。

使用Vector类最主要的好处就是在创建对象的时候不必给对象指定大小，它的大小会根据需要动态的变化。

```java
import java.util.*;

public class VectorDemo {

   public static void main(String args[]) {
      // initial size is 3, increment is 2
      Vector v = new Vector(3, 2);
      System.out.println("Initial size: " + v.size());
      System.out.println("Initial capacity: " +
      v.capacity());
      v.addElement(new Integer(1));
      v.addElement(new Integer(2));
      v.addElement(new Integer(3));
      v.addElement(new Integer(4));
      System.out.println("Capacity after four additions: " +
          v.capacity());

      v.addElement(new Double(5.45));
      System.out.println("Current capacity: " +
      v.capacity());
      v.addElement(new Double(6.08));
      v.addElement(new Integer(7));
      System.out.println("Current capacity: " +
      v.capacity());
      v.addElement(new Float(9.4));
      v.addElement(new Integer(10));
      System.out.println("Current capacity: " +
      v.capacity());
      v.addElement(new Integer(11));
      v.addElement(new Integer(12));
      System.out.println("First element: " +
         (Integer)v.firstElement());
      System.out.println("Last element: " +
         (Integer)v.lastElement());
      if(v.contains(new Integer(3)))
         System.out.println("Vector contains 3.");
      // enumerate the elements in the vector.
      Enumeration vEnum = v.elements();
      System.out.println("\nElements in vector:");
      while(vEnum.hasMoreElements())
         System.out.print(vEnum.nextElement() + " ");
      System.out.println();
   }
}
```

### 栈 `Stack`
栈（Stack）实现了一个后进先出（LIFO）的数据结构。

你可以把栈理解为对象的垂直分布的栈，当你添加一个新元素时，就将新元素放在其他元素的顶部。

当你从栈中取元素的时候，就从栈顶取一个元素。换句话说，最后进栈的元素最先被取出。


栈是Vector的一个子类，它实现了一个标准的后进先出的栈。
堆栈只定义了默认构造函数，用来创建一个空栈。 

构造方法:
```java
Stack()
```

堆栈除了包括由Vector定义的所有方法，也定义了自己的一些方法:
- `boolean empty()` : 测试堆栈是否为空。
- `Object peek()` : 查看堆栈顶部的对象，但不从堆栈中移除它。
- `Object pop()` : 移除堆栈顶部的对象，并作为此函数的值返回该对象。
- `Object push(Object element)` : 把项压入堆栈顶部。
- `int search(Object element)` : 返回对象在堆栈中的位置，以 1 为基数。


```java
import java.util.*;
 
public class StackDemo {
 
    static void showpush(Stack<Integer> st, int a) {
        st.push(new Integer(a));
        System.out.println("push(" + a + ")");
        System.out.println("stack: " + st);
    }
 
    static void showpop(Stack<Integer> st) {
        System.out.print("pop -> ");
        Integer a = (Integer) st.pop();
        System.out.println(a);
        System.out.println("stack: " + st);
    }
 
    public static void main(String args[]) {
        Stack<Integer> st = new Stack<Integer>();
        System.out.println("stack: " + st);
        showpush(st, 42);
        showpush(st, 66);
        showpush(st, 99);
        showpop(st);
        showpop(st);
        showpop(st);
        try {
            showpop(st);
        } catch (EmptyStackException e) {
            System.out.println("empty stack");
        }
    }
}
```


### 字典 `Dictionary`
字典（Dictionary） 类是一个**抽象类**，它定义了键映射到值的数据结构。

当你想要通过特定的键而不是整数索引来访问数据的时候，这时候应该使用Dictionary。

由于Dictionary类是抽象类，所以它只提供了键映射到值的数据结构，而没有提供特定的实现。

给出键和值，你就可以将值存储在Dictionary对象中。一旦该值被存储，就可以通过它的键来获取它。所以和Map一样， Dictionary 也可以作为一个键/值对列表。

- `Enumeration elements()`: 返回此 dictionary 中值的枚举。
- `Object get(Object key)`: 返回此 dictionary 中该键所映射到的值。
- `boolean isEmpty()`: 测试此 dictionary 是否不存在从键到值的映射。
- `Enumeration keys()`: 返回此 dictionary 中的键的枚举。
- `Object put(Object key, Object value)`: 将指定 key 映射到此 dictionary 中指定 value。
- `Object remove(Object key)`: 从此 dictionary 中移除 key （及其相应的 value）。
- `int size()`: 返回此 dictionary 中条目（不同键）的数量。

### 哈希表 `Hashtable`
Hashtable类提供了一种在用户定义键结构的基础上来组织数据的手段。

Hashtable是原始的`java.util`的一部分， 是一个`Dictionary`具体的实现 。

例如，在地址列表的哈希表中，你可以根据邮政编码作为键来存储和排序数据，而不是通过人名。

哈希表键的具体含义完全取决于哈希表的使用情景和它包含的数据。

```java
import java.util.*;

public class HashTableDemo {

   public static void main(String args[]) {
      // Create a hash map
      Hashtable balance = new Hashtable();
      Enumeration names;
      String str;
      double bal;

      balance.put("Zara", new Double(3434.34));
      balance.put("Mahnaz", new Double(123.22));
      balance.put("Ayan", new Double(1378.00));
      balance.put("Daisy", new Double(99.22));
      balance.put("Qadir", new Double(-19.08));

      // Show all balances in hash table.
      names = balance.keys();
      while(names.hasMoreElements()) {
         str = (String) names.nextElement();
         System.out.println(str + ": " +
         balance.get(str));
      }
      System.out.println();
      // Deposit 1,000 into Zara's account
      bal = ((Double)balance.get("Zara")).doubleValue();
      balance.put("Zara", new Double(bal+1000));
      System.out.println("Zara's new balance: " +
      balance.get("Zara"));
   }
}
```

### 属性 `Properties`

Properties 继承于 `Hashtable.Properties` 类表示了一个持久的属性集. 属性列表中每个键及其对应值都是一个字符串。

Properties 类被许多Java类使用。例如，在获取环境变量时它就作为System.getProperties()方法的返回值。

```java
import java.util.*;
 
public class PropDemo {
 
   public static void main(String args[]) {
      Properties capitals = new Properties();
      Set states;
      String str;
      
      capitals.put("Illinois", "Springfield");
      capitals.put("Missouri", "Jefferson City");
      capitals.put("Washington", "Olympia");
      capitals.put("California", "Sacramento");
      capitals.put("Indiana", "Indianapolis");
 
      // Show all states and capitals in hashtable.
      states = capitals.keySet(); // get set-view of keys
      Iterator itr = states.iterator();
      while(itr.hasNext()) {
         str = (String) itr.next();
         System.out.println("The capital of " +
            str + " is " + capitals.getProperty(str) + ".");
      }
      System.out.println();
 
      // look for state not in list -- specify default
      str = capitals.getProperty("Florida", "Not Found");
      System.out.println("The capital of Florida is "
          + str + ".");
   }
}
```


## Java 注解
作用在代码的注解是
- `@Override` - 检查该方法是否是重写方法。如果发现其父类，或者是引用的接口中并没有该方法时，会报编译错误。
- `@Deprecated` - 标记过时方法。如果使用该方法，会报编译警告。
- `@SuppressWarnings` - 指示编译器去忽略注解中声明的警告。

作用在其他注解的注解(或者说 元注解)是:
- `@Retention` - 标识这个注解怎么保存，是只在代码中，还是编入class文件中，或者是在运行时可以通过反射访问。
- `@Documented` - 标记这些注解是否包含在用户文档中。
- `@Target` - 标记这个注解应该是哪种 Java 成员。
- `@Inherited` - 标记这个注解是继承于哪个注解类(默认 注解并没有继承于任何子类)

从 Java 7 开始，额外添加了 3 个注解:
- `@SafeVarargs` - Java 7 开始支持，忽略任何使用参数为泛型变量的方法或构造函数调用产生的警告。
- `@FunctionalInterface` - Java 8 开始支持，标识一个匿名函数或函数式接口。
- `@Repeatable` - Java 8 开始支持，标识某注解可以在同一个声明上使用多次。

### Annotation 组成部分

![java-annotation](imgs/java-annotation.jpg)

1. 1 个 Annotation 和 1 个 RetentionPolicy 关联。
    可以理解为：每1个Annotation对象，都会有唯一的RetentionPolicy属性。

2. 1 个 Annotation 和 1~n 个 ElementType 关联。

    可以理解为：对于每 1 个 Annotation 对象，可以有若干个 ElementType 属性。

3. Annotation 有许多实现类，包括：Deprecated, Documented, Inherited, Override 等等。

    Annotation 的每一个实现类，都 "和 1 个 RetentionPolicy 关联" 并且 " 和 1~n 个 ElementType 关联"。


```java
// Annotation.java
package java.lang.annotation;
public interface Annotation {

    boolean equals(Object obj);

    int hashCode();

    String toString();

    Class<? extends Annotation> annotationType();
}

// ElementType.java
package java.lang.annotation;

public enum ElementType {
    TYPE,               /* 类、接口（包括注释类型）或枚举声明  */

    FIELD,              /* 字段声明（包括枚举常量）  */

    METHOD,             /* 方法声明  */

    PARAMETER,          /* 参数声明  */

    CONSTRUCTOR,        /* 构造方法声明  */

    LOCAL_VARIABLE,     /* 局部变量声明  */

    ANNOTATION_TYPE,    /* 注释类型声明  */

    PACKAGE             /* 包声明  */
}

// RetentionPolicy.java
package java.lang.annotation;
public enum RetentionPolicy {
    SOURCE,            /* Annotation信息仅存在于编译器处理期间，编译器处理完之后就没有该Annotation信息了  */

    CLASS,             /* 编译器将Annotation存储于类对应的.class文件中。默认行为  */

    RUNTIME            /* 编译器将Annotation存储于class文件中，并且可由JVM读入 */
}
```


1. Annotation 就是个接口。

    "每 1 个 Annotation" 都与 "1 个 RetentionPolicy" 关联，并且与 "1～n 个 ElementType" 关联。可以通俗的理解为：每 1 个 Annotation 对象，都会有唯一的 RetentionPolicy 属性；至于 ElementType 属性，则有 1~n 个。

2. ElementType 是 Enum 枚举类型，它用来指定 Annotation 的类型。

    "每 1 个 Annotation" 都与 "1～n 个 ElementType" 关联。当 Annotation 与某个 ElementType 关联时，就意味着：Annotation有了某种用途。例如，若一个 Annotation 对象是 METHOD 类型，则该 Annotation 只能用来修饰方法。

3. RetentionPolicy 是 Enum 枚举类型，它用来指定 Annotation 的策略。通俗点说，就是不同 RetentionPolicy 类型的 Annotation 的作用域不同。

    "每 1 个 Annotation" 都与 "1 个 RetentionPolicy" 关联。
    - a) 若 Annotation 的类型为 SOURCE，则意味着：Annotation 仅存在于编译器处理期间，编译器处理完之后，该 Annotation 就没用了。 例如，" @Override" 标志就是一个 Annotation。当它修饰一个方法的时候，就意味着该方法覆盖父类的方法；并且在编译期间会进行语法检查！编译器处理完后，"@Override" 就没有任何作用了。
    - b) 若 Annotation 的类型为 CLASS，则意味着：编译器将 Annotation 存储于类对应的 .class 文件中，它是 Annotation 的默认行为。
    - c) 若 Annotation 的类型为 RUNTIME，则意味着：编译器将 Annotation 存储于 class 文件中，并且可由JVM读入。



### 函数式接口

JDK 1.8 之前已有的函数式接口:
- `java.lang.Runnable`
- `java.util.concurrent.Callable`
- `java.security.PrivilegedAction`
- `java.util.Comparator`
- `java.io.FileFilter`
- `java.nio.file.PathMatcher`
- `java.lang.reflect.InvocationHandler`
- `java.beans.PropertyChangeListener`
- `java.awt.event.ActionListener`
- `javax.swing.event.ChangeListener`
- `java.util.function`: JDK 1.8 新增
    - `BiConsumer<T,U>` : 代表了一个接受两个输入参数的操作，并且不返回任何结果
    - `BiFunction<T,U,R>` : 代表了一个接受两个输入参数的方法，并且返回一个结果
    - `BinaryOperator<T>` : 代表了一个作用于于两个同类型操作符的操作，并且返回了操作符同类型的结果
    - `BiPredicate<T,U>` : 代表了一个两个参数的boolean值方法
    - `BooleanSupplier` : 代表了boolean值结果的提供方
    - `Consumer<T>` : 代表了接受一个输入参数并且无返回的操作
    - `DoubleBinaryOperator` : 代表了作用于两个double值操作符的操作，并且返回了一个double值的结果。
    - `DoubleConsumer` : 代表一个接受double值参数的操作，并且不返回结果。
    - `DoubleFunction<R>` : 代表接受一个double值参数的方法，并且返回结果
    - `DoublePredicate` : 代表一个拥有double值参数的boolean值方法
    - `DoubleSupplier` : 代表一个double值结构的提供方
    - `DoubleToIntFunction` : 接受一个double类型输入，返回一个int类型结果。
    - `DoubleToLongFunction` : 接受一个double类型输入，返回一个long类型结果
    - `DoubleUnaryOperator` : 接受一个参数同为类型double,返回值类型也为double 。
    - `Function<T,R>` : 接受一个输入参数，返回一个结果。
    - `IntBinaryOperator` : 接受两个参数同为类型int,返回值类型也为int 。
    - `IntConsumer` : 接受一个int类型的输入参数，无返回值 。
    - `IntFunction<R>` : 接受一个int类型输入参数，返回一个结果 。
    - `IntPredicate` : ：接受一个int输入参数，返回一个布尔值的结果。
    - `IntSupplier` : 无参数，返回一个int类型结果。
    - `IntToDoubleFunction` : 接受一个int类型输入，返回一个double类型结果 。
    - `IntToLongFunction` : 接受一个int类型输入，返回一个long类型结果。
    - `IntUnaryOperator` : 接受一个参数同为类型int,返回值类型也为int 。
    - `LongBinaryOperator` : 接受两个参数同为类型long,返回值类型也为long。
    - `LongConsumer` : 接受一个long类型的输入参数，无返回值。
    - `LongFunction<R>` : 接受一个long类型输入参数，返回一个结果。
    - `LongPredicate` : R接受一个long输入参数，返回一个布尔值类型结果。
    - `LongSupplier` : 无参数，返回一个结果long类型的值。
    - `LongToDoubleFunction` : 接受一个long类型输入，返回一个double类型结果。
    - `LongToIntFunction` : 接受一个long类型输入，返回一个int类型结果。
    - `LongUnaryOperator` : 接受一个参数同为类型long,返回值类型也为long。
    - `ObjDoubleConsumer<T>` : 接受一个object类型和一个double类型的输入参数，无返回值。
    - `ObjIntConsumer<T>` : 接受一个object类型和一个int类型的输入参数，无返回值。
    - `ObjLongConsumer<T>` : 接受一个object类型和一个long类型的输入参数，无返回值。
    - `Predicate<T>` : 接受一个输入参数，返回一个布尔值结果。
    - `Supplier<T>` : 无参数，返回一个结果。
    - `ToDoubleBiFunction<T,U>` : 接受两个输入参数，返回一个double类型结果
    - `ToDoubleFunction<T>` : 接受一个输入参数，返回一个double类型结果
    - `ToIntBiFunction<T,U>` : 接受两个输入参数，返回一个int类型结果。
    - `ToIntFunction<T>` : 接受一个输入参数，返回一个int类型结果。
    - `ToLongBiFunction<T,U>` : 接受两个输入参数，返回一个long类型结果。
    - `ToLongFunction<T>` : 接受一个输入参数，返回一个long类型结果。
    - `UnaryOperator<T>` : 接受一个参数为类型T,返回值类型也为T。

Demo:
```java
import java.util.Arrays;
import java.util.List;
import java.util.function.Predicate;
 
public class Java8Tester {
   public static void main(String args[]){
      List<Integer> list = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9);
        
      // Predicate<Integer> predicate = n -> true
      // n 是一个参数传递到 Predicate 接口的 test 方法
      // n 如果存在则 test 方法返回 true
        
      System.out.println("输出所有数据:");
        
      // 传递参数 n
      eval(list, n->true);
        
      // Predicate<Integer> predicate1 = n -> n%2 == 0
      // n 是一个参数传递到 Predicate 接口的 test 方法
      // 如果 n%2 为 0 test 方法返回 true
        
      System.out.println("输出所有偶数:");
      eval(list, n-> n%2 == 0 );
        
      // Predicate<Integer> predicate2 = n -> n > 3
      // n 是一个参数传递到 Predicate 接口的 test 方法
      // 如果 n 大于 3 test 方法返回 true
        
      System.out.println("输出大于 3 的所有数字:");
      eval(list, n-> n > 3 );
   }
    
   public static void eval(List<Integer> list, Predicate<Integer> predicate) {
      for(Integer n: list) {
        
         if(predicate.test(n)) {
            System.out.println(n + " ");
         }
      }
   }
}
```

## QA
1. 包的路径关系: 包与路径对应? 包与子包?

    ```java
    package com.leyantech.utility.args.apt;
    package com.leyantech.utility.args;
    ```








