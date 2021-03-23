# 概述

- Core Animation 是一个复合引擎，它能快速的组合屏幕上不同显示的内容，并将其分解成独立图层，存储到 Layer Tree 的体系中。

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gk4u0hnipgj30u80mawha.jpg)

- 每个 `UIView` 都有一个 `CALayer` 的图层属性。

  - Layer 给 View 提供了基础设施，使得绘制内容和呈现动画更容易，更低耗。
  
  - Layer 不参与 View 的事件处理和响应链。

  - View 在系统中的作用就是接收用户点击和呈现内容，而 Layer 就是负责了内容呈现的工作，不参与用户点击事件处理的工作。

- 自定义 `UIView` 的子时类，可以重载以下方法，设置其 `CALayer` 类型。

  ```objective-c
  + (Class)layerClass {
      return [STLayer class];
  }
  ```

  > 充分利用 `CALayer` 及其各种子类，创建基于不同图层的视图是一个简单可复用的方法。

- **为什么 iOS要基于 `UIView` 和 `CALayer` 提供两个平行的层级关系呢？为什么不用一个简单的层级来处理所有事情呢？**

  原因在于职责分离，这样可以避免很多重复代码。在 iOS 和 Mac OS 两个平台下，事件和用户交互存在比较大的差异。比如 Mac OS 的用户交互可以通过鼠标/键盘控制，而 iOS 则通过手势触摸。这就是为何 iOS 开发界面使用 `UIKit` 和 `UIView`，而 Mac OS 开发界面使用 `AppKit` 和 `NSView`。 因为他们之间的用户交互手段不一样，但是它们在功能上是非常类似的，所以都有 Core Animation 框架和 `CALayer`。而 `CALayer` 只处理显示上的需求，不做交互上的需求处理，这样设计就可以减少非常多不必要的代码。

# 内容呈现

- **更新机制**

  - 系统有基本稳定的刷新频率，在 Layer 内容改变的时候，系统会把这个 Layer 标记为**需要绘制**，即被调用 **`setNeedsDisplay`**，也可以主动调用该方法对 Layer 进行标记。
  
  - 每次刷新时，把上次刷新之后被标记的 Layer 一次性全部提交给图形系统，即被调用 **`display`** ，该方法一般无需主动调用，而是交给系统调用，从而获得更好的调用时机；
  
  - 如果真的急需刷新，可以主动调用 **`displayIfNeeded`**，立即对已被标记为需要刷新的 Layer 进行绘制。

- **内容提供**

  - 系统依次检测 `display`、delegate 的 `displayLayer:`、`drawInContext:`、delegate 的`drawLayer:inContext:`，其中任何一个方法实现了，就认为已经为 Layer 提供了内容，进行绘制。

  > `display` 和 `drawInContext:` 可以通过自定义 `CALayer` 子类来实现。
  >
  > delegate 的方法通过代理来实现， layer 的 delegate 默认为其所属的 view。

  - 直接设置寄宿图：

  ```objective-c
  UIImage *image = [UIImage imageNamed:@"1.png"];
  // content属性为id类型，原则上可以赋任何类型的值，但是如果赋值对象不是CGImage类型，视图仍然显示空白
  layer.contents = (__bridge id)image.CGImage;
  ```

- 属性设置

  - `contentsGravity`：设置寄宿图的内容的对齐方式，类似视图的 `cotentMode` 属性。
  
  - `contentsScale`：设置寄宿图的像素尺寸和视图大小的比例，一般设置为 `layer.contentsScale = [[UIScreen mainScreen] scale];`。
  
  - `contentsRect`：显示寄宿图的一个子域，`CGRect` 类型，使用比例单位，即默认为 {0, 0, 1, 1}。
  
  - `contentsCenter`：使用比例单位，`CGRect` 类型，默认为 {0, 0, 1, 1}，表示当图片要对齐时（由 `contentsGravity` 决定，只有 contents 大小和图层大小不一致时，才发挥作用），各个部分时均匀地拉伸。

# 几何位置

- `UIView` 有三个比较重要的布局属性：`frame`，`bounds ` 和 `center`，`CALayer` 对应地叫做 `frame`，`bounds` 和 `position`，以及 `anchorPoint`。

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gk4u0tj551j317q0pijuo.jpg)

- `UIView` 的 `frame`，`bounds ` 和 `center` 属性仅仅是存取方法，当操纵 `frame` 时，实际上是在改变位于视图下方 `CALayer` 的 `frame`，不能够独立于图层之外改变视图的 `frame`。

  - 对于视图或者图层来说，`frame` 其实是一个虚拟属性，是根据 `bounds`，`position ` 和 `transform` 计算而来，所以当其中任何一个值发生改变，`frame` 都会变化。相反，改变 `frame` 的值同样会影响到他们当中的值。

  - 当对图层做变换的时候，比如旋转或者缩放，`frame` 实际上代表了覆盖在图层旋转之后的整个轴对齐的矩形区域， `frame` 的宽高可能和 `bounds` 的宽高不再一致了。

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gk4u1328x0j315c0ra45l.jpg)

- `anchorPoint` 称为锚点，使用单位坐标，定义图层变换（旋转，平移和缩放）时的支点，而 `position` 就是 `anchorPoint ` 在superLayer 中的位置——`position` 的位置是根据 `anchorPoint` 来确定的。

  > position 点是相对 suerLayer 的，anchorPoint 点是相对 Layer 的，两者是相对不同的坐标空间的一个重合点。

  - 互不影响原则：单独修改 `position` 与`anchorPoint` 中任何一个属性都不影响另一个属性。因此，修改 `anchorPoint` 时会移动图层——`position` 不受影响，只是 `frame.origin` 做相应的改变。

  ```objective-c
  frame.origin.x = position.x - anchorPoint.x * bounds.size.width；  
  frame.origin.y = position.y - anchorPoint.y * bounds.size.height；  
  ```

  - 如果只想修改 `anchorPoint` 而不改变图层的位置，可以重新设置`frame` 值（会修改 `position` 值）。

  ```objective-c
  CGRect oldFrame = view.frame;
  view.layer.anchorPoint = anchorpoint;
  view.frame = oldFrame;
  ```

- `zPosition` 在Z轴上描述图层位置，最实用的功能就是改变图层的显示顺序，可以使后加入的图层却显示在下面。注意：不会改变事件传递的顺序。

# 视觉效果

- **圆角**：`cornerRadius` 设置的圆角只对背景色和图层边框有用，对 `contents` 属性中的 image 无效。当 `contents` 有内容或者内容背景不是透明的时，单靠 `cornerRadius` 是无法完成圆角效果的，还需要设置 `maskToBounds = YES` 对超过图层边界的内容进行裁剪。 

- **透明度**：`allowsGroupOpacity` （默认）设置为 YES 后，子图层在视觉上的透明度的上限是其父图层的`opacity`。

- **蒙板**：为了让两个图层搭配出一个新的视觉效果，简单理解就是一个遮罩，mask 图层区域外的任何区域不显示。

  ```objective-c
  //原图层是一个矩形
  CALayer *layer = [CALayer layer];
  layer.frame = CGRectMake(10, 100, 200, 200);
  layer.backgroundColor = [UIColor redColor].CGColor;
  [self.view.layer addSublayer:layer];
  
  //蒙版图层是一张图片
  CALayer *maskLayer = [CALayer layer];
  maskLayer.frame = layer.bounds;
  maskLayer.contents = (__bridge id)[UIImage imageNamed:@"head.png"].CGImage;
  
  layer.mask = maskLayer;
  ```

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gk4u1cdb1sj307l069aa3.jpg)

- 其他：

  - `borderWidth`：边界的宽度。
  
  - `borderColor`：边界的颜色。
  
  - `shadowOpacity`：阴影的透明度，值在 0~1 之间。
  
  - `shadowColor`：阴影的颜色，默认为黑色。
  
  - `shadowOffset`：阴影的方向的距离，`CGSize `类型：宽度控制横向位移，高度控制纵向位移，默认值是{0, -3}。
  
  - `shadowRadius`：阴影的模糊度。
  
  - `shadowPath`：任意阴影形状（实时计算阴影也是非常消耗资源）。
  
  - `maskToBounds`：是否不显示超出该图层边界的内容。
  
  - `minificationFilter`、`magnificationFilter`：图层缩放拉伸时的描绘方式，分别用于缩小和放大

  > 图层的阴影继承自内容的外形，而不是根据边界来确定。为了计算出阴影的形状，Core Animation 会将寄宿图（包括子视图）考虑在内，然后通过这些来完美搭配图层形状从而创建一个阴影。
  >
  > 阴影通常就是在 layer 的边界之外，如果开启了 `masksToBounds` 属性，可能导致阴影不再显示。通常的做法是用两个图层，分别负责裁剪和阴影。

- 图层是双面绘制的，反面是一个镜像图片，这并不是一个很好的特性，会给用户造成困扰，同时也可能造成系统资源的浪费，试想我们不想看到背面，那为什么还要浪费 GPU 绘制它们？

  - `doubleSided` 属性，用来控制图层背面是否绘制，默认为 YES。

# 变换

- **仿射变换**：图层在 2D 平面上进行平移、旋转和缩放。

  - 将图层和一个变换矩阵 **`CGAffineTransform`**（3*3）相乘以得出的结果矩阵来实现变换的。

  ```objective-c
  CGAffineTransformMakeRotation(CGFloat angle) // 旋转
  CGAffineTransformMakeScale(CGFloat sx, CGFloat sy) // 缩放
  CGAffineTransformMakeTranslation(CGFloat tx, CGFloat ty) // 平移
  
  // 混合变换
  CGAffineTransformRotate(CGAffineTransform t, CGFloat angle)
  CGAffineTransformScale(CGAffineTransform t, CGFloat sx, CGFloat sy)
  CGAffineTransformTranslate(CGAffineTransform t, CGFloat tx, CGFloat ty)
  ```

  ```objective-c
  CGAffineTransform affineTransform = CGAffineTransformMakeRotation(M_PI_4);
  // 由affineTransform属性控制
  layer.affineTransform = affineTransform;
  ```

- **3D 变换**：图层在3D空间内进行移动或转动。

  - 将图层和一个变换矩阵 `CATransform3D`（4*4）相乘以得出的结果矩阵来实现变换的。
  
  - 通过调整 `m34` （4*4矩阵中第三列第四行的数）来让图层更加有 3D 的透视效果（两条相等长度的边，远离视角的边看起来更短）。

  ```objective-c
  CATransform3DMakeRotation(CGFloat angle, CGFloat x, CGFloat y, CGFloat z) // 旋转
  CATransform3DMakeScale(CGFloat sx, CGFloat sy, CGFloat sz) // 缩放
  CATransform3DMakeTranslation(Gloat tx, CGFloat ty, CGFloat tz) // 平移
  ```

  ```objective-c
  CATransform3D transform = CATransform3DIdentity;
  transform.m34 = - 1.0 / 500.0;
  transform = CATransform3DRotate(transform, M_PI_4, 0, 1, 0);
  layer.transform = transform;
  ```

- `sublayerTransform` 的变换可以影响到所有的子图层，即可以一次性对包含这些图层的容器做变换，于是所有的子图层都自动继承了这个变换方法。例如，如果有多个视图或者图层，每个都做 3D 变换时，不需要分别设置相同的 m34 值。

  ```objective-c
  CATransform3D perspective = CATransform3DIdentity;
  perspective.m34 = - 1.0 / 500.0;
  superLayer.sublayerTransform = perspective;
  
  // layer1和layer2都会具有透视效果
  [superLayer addSublayer:layer1];
  [superLayer addSublayer:layer2];
  ```

- 灭点：当在透视角度绘图的时候，远离相机视角的物体将会变小变远，当远离到一个极限距离，它们可能就缩成了一个点，于是所有的物体最后都汇聚消失在同一个点。

  - 当一个图层有多个3D变换的子图层，为了让整个视图绘制的更有3D效果，应该首先把它们都放置于屏幕中央，然后通过平移（使用3D平移，不要用仿射变换）来把它移动到指定位置（而不是直接改变它的position），这样所有的 3D 图层都共享一个灭点。

# 专用图层

- `CALayer` 具有一些非常有用的绘图和动画功能。但 Core Animation 不仅作用于图片和颜色，`CALayer` 拓展了其他一些专用于某种功能的子类，以增强 Core Animation 的绘图能力。

- **`CAShapeLayer `** 是一个通过矢量图形而不是 bitmap 来绘制的图层子类，可以用来绘制所有能够通过 `CGPath` 来表示的形状。

  - 渲染快速。使用了硬件加速，绘制同一图形会比用Core Graphics快很多。
  
  - 高效使用内存。 不需要像普通 `CALayer` 一样创建一个寄宿图形，所以无论有多大，都不会占用太多的内存。
  
  - 不会被图层边界剪裁掉。可以在边界之外绘制，不会像在使用 Core Graphics 的普通 `CALayer` 一样被剪裁掉。
  
  - 不会出现像素化。做3D变换时，不会像一个有寄宿图的普通图层一样变得像素化。

- **`CATextLayer`** 以图层的形式包含了 `UILabel` 几乎所有的绘制特性，并且渲染速度更快。

- **`CAGradientLayer `** 用来生成两种或更多颜色平滑渐变。

  - 可以和 `CAShapeLayer ` 搭配使用，设置 `CAShapeLayer.mask = CAGradientLayer ` 。

- **`CAReplicatorLayer `** 可以高效生成许多相似的图层。它会绘制一个或多个图层的子图层，并在每个复制体上应用不同的变换。

- **`CAScrollLayer`** 提供了和 `UIScrollView` 的基本功能。只不过它是 layer，只负责显示，不响应用户事件，也不提供滚动条。

  - 想要 `CAScrollLayer` 实现滚动的效果，就要给所在的 view 上添加 pan 事件，通过 `scrollToPoint:`方法来实现滚动。

- **`CATransformLayer`** 只能当作容器使用，本身并没有任何独有属性。可以为添加其中的子图层创建真正的3D层次结构。

  - `CATransformLayer` 可以为他的子图层，统一提供景深效果。
  - 下图为分别使用 `CATransformLayer` 和 `CALayer` 做容器时的变换效果。

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gk4u1mc3j0j30780400cm.jpg)

- **`CATiledLayer `** 为载入大图造成的性能问题提供了一个解决方案：将大图分解成小片然后将他们单独按需载入。

  - 通常被添加到 `UIScrollView` 上：`    [scrollView.layer addSublayer:tileLayer];`。

- **`CAEmitterLayer`** 是一个高性能的粒子引擎，被用来创建实时例子动画如：烟雾，火，雨等等这些效果。

  > https://www.jianshu.com/p/d02355dd18d8>

# 动画

- CoreAnimation 就是核心动画，拥有一组非常强大的 API，用来做动画非常简单，但是效果非常绚丽

  - 跨平台的，既可以支持 iOS，也支持 Mac OS；
  
  - 将大部分实际的绘图任务交给了图形硬件来处理，图形硬件会加速图形渲染的速度。
  
  - 执行动画是在后台，不会阻塞主线程；
  
  - 作用在 `CALayer`，不是 `UIView`。

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gk4u20jh52j30ga0b40vq.jpg)

## 隐式动画

- `CALayer` 的部分属性，只要修改其最初设定的值，就会产生动画效果。

  ```objective-c
  // Animatable 表示该属性支持隐式动画
  /* The background color of the layer. Default value is nil. Colors
   * created from tiled patterns are supported. Animatable. */
  
  @property(nullable) CGColorRef backgroundColor;
  ```

- 当改变一个属性时，Core Animation 是如何判断动画类型和持续时间的呢？实际上动画执行的时间取决于当前**事务 `CATransaction`** 的设置（事务负责协调多个动画原子更新的显示操作，是动画里面的一个基本单元），动画类型取决于**图层行为**。

  - 动画方式：**事务动画**。

  ```objective-c
  [CATransaction begin];
  // 动画持续时间
  [CATransaction setAnimationDuration:2];
  // 动画时间曲线
  [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
  [CATransaction setCompletionBlock:^{
      // 动画完成后执行
  }];
  // 修改layer的可动画属性
  layer.backgroundColor = [UIColor blueColor].CGColor;
  [CATransaction commit];
  ```

- 如果通过 `UIView`  关联的 `CALayer` 修改属性，是不会有动画效果的。这是因为 `UIView` 关闭掉了隐式动画—— `CALayer` 的 `actionForKey:` 方法返回为 `[NSNull null]`。

  - 按照以下顺序查找：
  
    - 其代理实现了方法 `actionForLayer:forKey:` 并返回一个遵循 `CAAction` 协议的对象，如`CAAnimation` 对象；或返回 nil，进行下一步搜索；或返回 `[NSNull null]`，搜索结束，关闭了隐式动画。
    
    - `actions` 字典属性中对应的 key 是否有值。
    
    - `style` 字典属性中含有一个 actions 对应的字典，该字典中对应的 key 是否有值。
    
    - 调用类方法 `defaultActionForKey:` 方法是否获得值。
    
    - 以上搜索都未找到，则返回一个 `CABasicAnimation` 对象。

  ```objective-c
  - (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    	// 额外增加转场效果
      if ([event isEqualToString:@"backgroundColor"]) {
          CATransition *transition = [CATransition animation];
          transition.type = kCATransitionPush;
          transition.subtype = kCATransitionFromLeft;
          return transition;
      }
      return nil;
  }
  ```

- `CALayer` 内部系统维护着三种 Layer Tree，分别为 **modelLayer**，**presentLayer** 和 **renderLayer**。

  - renderLayer 为系统渲染时内部维护，对于开发者来讲是透明不可见的。
  
  - modelLayer 用户操作和设置属性的图层，保存了图层的基本数据。
  
  - presentLayer 当使用 Core Animation 做动画时，每一帧动的位置都可以从这个图层中读取到。

- 呈现：**当改变一个图层的属性，属性值的确是立刻更新的。如果想要在动画进行过程中实时获取被修改属性当前的值，就需要通过 `presentationLayer` 来访问**。

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gk4u2keamuj313m0i4gq5.jpg)


## 显式动画

- 显式动画能够对一些属性做指定的自定义动画，或者创建非线性动画，比如沿着任意一条曲线移动。

- 显式动画主要使用 **`CAAnimation`** 的子类，不能直接使用，本身实现了 `CAMediaTiming` 协议。

  ```objective-c
  // 动画的速度曲线
  @property(nullable, strong) CAMediaTimingFunction *timingFunction;
  // 代理，实现动画开始和结束时的回调
  @property(nullable, strong) id <CAAnimationDelegate> delegate;
  // 动画完成后是否将图层移除掉，默认为YES
  @property(getter=isRemovedOnCompletion) BOOL removedOnCompletion;
  ```

- **`CAMediaTiming`** 协议，控制动画中和时间相关的属性。`CALayer` 和 `CAAnimation` 都实现了这个协议。

  ```objective-c
  // 动画延迟执行时间，默认为0；如CACurrentMediaTime()+1表示延迟1s
  @property CFTimeInterval beginTime;
  // 动画持续时间，默认为0，实际表示0.25秒
  @property CFTimeInterval duration;
  // 动画执行速度，默认为1，大于1表示快进，小于1表示慢进，负数表示回退；
  // 如果把动画的duration设置为3秒，而speed设置为2，动画将会在1.5秒结束
  @property float speed;
  // 动画进程，默认为0，大于0表示直接跳到某个时间点开始
  @property CFTimeInterval timeOffset;
  // 动画重复执行的次数，默认为0，实际表示1次
  @property float repeatCount;
  // 动画重复执行的时间，默认为0
  @property CFTimeInterval repeatDuration;
  // 动画正常走完以后是否反着从结束值回到起始值，默认为NO
  @property BOOL autoreverses;
  // 动画开始之前和结束之后的状态
  // kCAFillModeRemoved：默认值，动画结束后图层恢复原来的状态
  // kCAFillModeForwards对应toValue：动画结束后，图层保持toValue状态
  // kCAFillModeBackwards对应fromValue：动画开始前，图层一直保持fromValue状态
  // kCAFillModeBoth对应fromValue和toValue：以上两者的结合
  @property(copy) CAMediaTimingFillMode fillMode;
  ```

- 显式动画一般步骤：

  - 创建 `CAAnimation` 的子类对象；
  
  - 设置动画的相关属性； 
  
  - 给 `CALayer` 添加动画 `addAnimation:forKey:` 。

### 基础动画

  - **`CABasicAnimation`** 基础动画，通过设置初始状态、结束状态或插值状态进行动画。

    ```objective-c
    // 创建CABasicAnimation对象
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    // 设置初始值
    animation.fromValue = (id)[UIColor redColor].CGColor;
    // 设置结束值
    animation.toValue = (id)[UIColor blueColor].CGColor;
    // 设置时间
    animation.duration = 2.0;
    
    //以下两个保证动画结束后停留在结束值
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    [layer addAnimation:animation forKey:@"animation"];
    ```

- **为什么动画结束后返回原状态**？给图层添加动画时，真正移动并不是图层本身，而是 presentLayer。动画开始时 presentLayer 开始移动，modelLayer 隐藏。动画结束时，presentLayer 从屏幕上移除，modelLayer 显示。在整个动画开始及结束之后，modelLayer 根本就没发生过改变。

   - 另外一种禁止返回原状态的方式是实现 `CAAnimationDelegate` 协议，在动画结束回调函数中设置图层属性为新值，但需要设置禁止触发隐式动画，否则会出现两次动画。

   ```objective-c
   - (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
       [CATransaction begin];
       [CATransaction setDisableActions:YES];
       layer.backgroundColor = (__bridge CGColorRef)((CABasicAnimation *)anim).toValue;
       [CATransaction commit];
   }
   ```

- `animation.removedOnCompletion = NO` 会导致内存泄漏，必须在必要时显式地移除动画。

   ```objective-c
   [layer removeAnimationForKey:@"animation"];
   ```

- **`CASpringAnimation`** 弹簧动画：`CABasicAnimation` 的子类，可实现弹簧效果的动画，iOS9 后新增。

  ```objective-c
  CASpringAnimation *animation = [CASpringAnimation animationWithKeyPath:@"position.y"];
  // 质量，质量越大，弹簧拉伸和压缩的幅度就越大
  animation.mass = 10;
  // 刚度系数，刚度系数越大，形变产生的力就越大，运动越快
  animation.stiffness = 5000;
  // 阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快
  animation.damping = 100.0;
  // 初始速率，速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
  animation.initialVelocity = 5.f;
  
  // 结算时间，根据动画参数估算弹簧开始运动到停止的时间，动画设置的时间最好根据此时间来设置
  animation.duration = animation.settlingDuration;
      
  animation.toValue = @(400);
  animation.fillMode = kCAFillModeForwards;
  animation.removedOnCompletion = NO;
  ```

### 关键帧动画

- **`CAKeyframeAnimation`** 关键帧动画，通过设置不同的值来进行关键帧的属性和时间控制。

  ```objective-c
  // 创建CABasicAnimation对象
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  // 设置关键帧
  NSValue *key1 = [NSValue valueWithCGPoint:CGPointMake(150, 150)];
  NSValue *key2 = [NSValue valueWithCGPoint:CGPointMake(200, 20)];
  NSValue *key3 = [NSValue valueWithCGPoint:CGPointMake(200, 200)];
  NSValue *key4 = [NSValue valueWithCGPoint:CGPointMake(45, 200)];
  animation.values = @[key1, key2, key3, key4];
  // 设置各个帧的运行时间
  animation.keyTimes = @[@0.1, @0.2, @0.3, @0.4];
  // 设置时间
  animation.duration = 10.0f;
  
  [layer addAnimation:animation forKey:@"animation"];
  ```

- 还可以通过属性 `path` 可以设置一个 `CGPathRef` 路径，让图层跟着路径移动，只对 `anchorPoint` 和 `position` 属性生效。

### 组动画

- **`CAAnimationGroup`** 组动画，使得多个动画并发执行。

  ```objective-c
  // 创建CAAnimationGroup对象
  CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
  // 动画组合，rotation和rotation都是CAAnimation动画
  group.animations = @[rotation, position];
  ```

### 转场动画

- **`CATransition`** 转场动画，用于做过渡动画或者转场动画，能够为层提供移出屏幕和移入屏幕的动画效果。

  ```objective-c
  CATransition *transition = [CATransition animation];
  // 设置动画类型
  transition.type = kCATransitionMoveIn;
  // 设置动画方向
  transition.subtype = kCATransitionFromLeft;
  transition.duration = 2.0f;
  // 可以控制动画只执行中间部分
  //transition.startProgress = 0.1;
  //transition.endProgress = 0.9;
  [self.layer addAnimation:transition forKey:@"transitionAnimation"];
      
  // 修改属性
  self.layer.backgroundColor = [UIColor blueColor].CGColor;
  ```

# 渲染

- 视图的渲染流程：CPU 把内容放到缓存里，GPU 从缓存里读取数据然后渲染到屏幕上。

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkuq5x9olxj30uc0dyabb.jpg)

  - CPU 计算需要显示的内容，然后通过数据总线传给 GPU；
  
  - GPU 拿到数据之后开始渲染数据并保存在帧缓存区中；
  
  - 随后视频控制器会按照  VSync 信号逐行读取帧缓冲区的数据，经过数模转换传递给显示器显示。

- 视图的渲染流程（详细）：

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkuq6mdl70j30zm0dijrg.jpg)

  - Handle Events：Core Animation 在 RunLoop 中注册了一个Observer，监听 BeforeWaiting（即将休眠） 和 Exit（退出） 事件。当一个触发事件到来时，RunLoop 被唤醒并执行相关代码。在代码中可能涉及到视图的更新，当代码执行完毕后，RunLoop 变为即将休眠或退出状态，则触发 Core Animation 的渲染流程。

  - Commit Transaction：整个步骤在 CPU 中进行
  
    - Layout：构建和布局视图；
    
    - Display：绘制视图，并不是真正的显示，正常情况下只会得到图元信息。但是如果重写了 `drawRect:` 或 `drawLayer:inContext:` 方法，则调用 Core Graphics 绘制方法得到位图信息，并暂存到系统额外申请的一块内存中。
    
    - Prepare：主要是图片的解码和转换（除了用 `imageNamed`：方法从 bundle 加载的 image 会立刻解压之外，其他的比如直接从硬盘读入，或者从网络上下载的 image 不会立刻解压，只有在真正要渲染的时候才会解压）。
    
    - Commit：图层打包并发送到 Render Server。

  - Render Server：分为 Metal 和 Core Graphics 两种处理方式，并最终得到位图信息，存储到 GPU 的帧缓存器（ Frame Buffer）。

    - 执行 Metal 将图元信息转换为位图信息：
    
      - Geometry 几何处理阶段：处理图元；
      
      - Rasterization 光栅化阶段：图元转换为像素；
      
      - Pixel 像素处理阶段：像素转换为位图。
      
    - 获取 Core Graphics 绘制得到的位图信息。

  - Graphics Hardware：视频控制器（Video Controller）会读取帧缓冲器中的信息，经过数模转换传递给显示器（Monitor），进行显示。


  >  iOS 设备的屏幕刷新频率是 60HZ。如果上面的这些步骤在一个刷新周期之内无法做完（1/60s），就会造成掉帧。

## 离屏渲染

- **离屏渲染的定义**

  - Render Server 处理过程中，至少需要一块与屏幕像素数据量一样大的帧缓存器，作为像素数据存储区域，也是 GPU 存储渲染结果的地方。
  
  - 在某些情况下，无法把渲染结果直接写入帧缓存器，而是先暂存在另外的内存区域，之后再写入帧缓存器，那么这个过程被称之为离屏渲染。

  > 在 `UIView` 中实现了 `drawRect:` 方法后，位图信息不是直接绘制到由 GPU 掌管的帧缓存器，只能暂时先放在另一块内存之中，也可以属于“离屏渲染”。

- **离屏渲染的坏处**

  - 需要额外创建一个新的缓冲区。
  
  - 多次切换上下文环境（代价巨大）：先是从当前屏幕（On-Screen）切换到离屏（Off-Screen）；等到离屏渲染结束以后，将离屏缓冲区的渲染结果显示到屏幕上又需要将上下文环境从离屏切换到当前屏幕。

- **离屏渲染的产生**

  - Render Server 对图层的叠加绘制遵循**画家算法**：先绘制场景中的离观察者较远的物体，再绘制较近的物体，依次输入相应的位图信息到帧缓存器，当位图信息被取出并显示完成后则被丢弃。

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gk4u326klaj30oj076t8y.jpg)

  - 作为“画家”的GPU虽然可以一层一层往画布上进行输出，但是无法在某一层渲染完成之后，再回过头来擦除或改变其中的某个部分——因为在这一层之前的若干层 Layer 像素数据，已经在渲染中被永久覆盖了。这就意味着，对于每一层 Layer，要么能找到一种通过单次遍历就能完成渲染的算法，要么就不得不另开一块内存，借助这个临时中转区域来完成一些更复杂的、多次的修改/剪裁操作。

  - 另一方面，出于效率目的，可以将内容提前渲染保存在离屏缓冲区中，达到复用的目的。如开启光栅化。

- 图层的以下属性将会触发屏幕外绘制：

  - **圆角+裁剪**：一旦为 contents 设置了内容 ，无论是直接设置图片、通过内容提供其他方法绘制内容、添加有图像信息的子视图等，再加上圆角 + 裁剪，就会触发离屏渲染。

    但 iOS 9 之后做了优化， contents 设置了内容 + 圆角 + 裁剪并不会触发离屏渲染。但如果加上了背景色、边框或其他有图像内容的图层，还是会产生离屏渲染

    ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkvdv2ihquj30b408hmxr.jpg)

  ```objective-c
  CALayer *layer = [CALayer layer];
  layer.frame = CGRectMake(100, 100, 100, 100);
        
  // 1 contents 设置内容
  layer.contents = (__bridge id)[UIImage imageNamed:@"1.jpg"].CGImage;
  // 2 背景色
  layer.backgroundColor = [UIColor redColor].CGColor;
  // 3 边框
  layer.borderWidth = 2.0;
    
  // 圆角
  layer.cornerRadius = 50;
  // 裁剪
  layer.masksToBounds = YES;
        
  [self.view.layer addSublayer:layer];
   
  // 1+2或1+3会触发离屏渲染
  ```

  - **阴影**：阴影显示在所有图层内容的下方，需要最先被渲染但又无法在图层内容绘制之前得知具体的阴影形状。只能另外申请一块内存，把 Layer 内容都先画好，再根据渲染结果的形状，添加阴影到帧缓存器中，最后再把 Layer 内容画上去。如果能够预先知道（通过 `shadowPath` 属性）阴影的形状，就可以先被独立地渲染出来，不需要依赖图层内容，也就不再需要离屏渲染了。
  
  - 组透明度：alpha 并不是分别应用在每一层之上，而是只有到整个 Layer 树画完之后，再统一加上alpha，最后和底下其他 Layer 的像素进行组合。
  
  - 蒙板：mask 是应用在 Layer 和其所有子 Layer 的组合之上的。
