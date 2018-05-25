/*
  一、ios类别（分类Category）：
     1、可以给原类增加方法，可以通过runtime给原类增加成员变量和属性【objc_getAssociatedObject / objc_setAssociatedObject来访问和生成关联对象】
     2、主要用在给NSString、NSSArray、NSDictionary等增加新处理方法 或者针对其他类增加方法，把相关的方法分组到多个单独的文件中
        这里有一个约定俗成的规定，类别文件命名时，是原类名+扩展标识名：
        //  NSString+ex.h
        @interface NSString(ex)
            // 扩展的类回别方法
        @end
 
        //  NSString+ex.m
        @implementation NSString(ex)
            // 方法的实现
        @end
 
 二、ios扩展（extension）
     1、是一种特殊的类别
     2、语法格式
        @interface 主类类名（）
        @end
        扩展通常定义在主类.m文件中，扩展中声明的方法直接在主类.m文件中实现
     3、可以增加方法和属性、成员变量，增加的方法与原类一样时会覆盖原类
 
 ps：当增加的方法有与原类同名时，将覆盖原类的方法实现且类别和扩展都无法继续使用原类的实现，即无法调用[super xxx]；只有继承才行
 */

#import "ViewController.h"
#import "Student.h"

//下面这个就是一个扩展
@interface ViewController () {
    Student *_student;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _student = [[Student alloc] init];
    _student.name = @"oldName_hu";
    
    
    // 1.给student对象的添加观察者，观察其stuName属性
    [_student addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    // 此时，stuName发生了变化
    _student.name = @"newName_wang";
    

    
}

/*
    KVO的实现原理：【观察者模式】
 
    当类A的对象第一次被观察的时候，系统会在运行期动态创建类A的派生类。我们称为B。
    在派生类B中重写类A的setter方法，B类在被重写的setter方法中实现通知机制。【即属性值发生改变时都会触发该属性的setter方法，于是重写它，并通知添加的观察者】
    类B重写会 class方法，将自己伪装成类A。类B还会重写dealloc方法释放资源。
    系统将所有指向类A对象的isa指针指向类B的对象。

    PS：要想KVO生效，必须直接或间接的通过setter方法访问属性（KVC的setValue就是间接方式）。直接访问成员变量KVO是不生效的
        KVO 行为是同步的，并且发生与所观察的值发生变化的同样的线程上。没有队列或者 Run-loop 的处理,同步阻塞后续的观察者
   参考：https://www.objccn.io/issue-7-3/
        https://www.jianshu.com/p/66bda10168f1
 
 KVC: 提供了一种新的访问对象属性和成员变量的方法，私有属性也能修改
 KVO和KVC都是基于isa-swing技术，也即基于runtime
 */


// stuName发生变化后，观察者（self）立马得到通知。
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    // 最好判断目标对象object和属性路径keyPath
    if(object == _student && [keyPath isEqualToString:@"name"]) {
        NSLog(@"----old:%@----new:%@",change[@"old"],change[@"new"]);
        
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        
    }
    
}

- (void)dealloc {
    // 移除观察者
    [_student removeObserver:self forKeyPath:@"name"];
    
}


@end
