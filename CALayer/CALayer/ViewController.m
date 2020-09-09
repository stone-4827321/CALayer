//
//  ViewController.m
//  CALayer
//
//  Created by stone on 2020/9/2.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "ViewController.h"
#import "STLayer.h"
#import <CoreText/CoreText.h>
#import <AVKit/AVKit.h>

@interface CAScrollLayerView : UIView
@end

@implementation CAScrollLayerView

+ (Class)layerClass {
    return [CAScrollLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame]))
    {
        self.layer.masksToBounds = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint offset = self.bounds.origin;
    offset.x -= [pan translationInView:self].x;
    offset.y -= [pan translationInView:self].y;
    [(CAScrollLayer *)self.layer scrollToPoint:offset];
    [pan setTranslation:CGPointZero inView:self];
}
@end

@interface ViewController () <CALayerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
   // [self testVanishingPoint];
}

#pragma mark - 内容呈现

- (void)testContent {
    STLayer *layer = [STLayer layer];
    layer.frame = CGRectMake(50.0f, 50.0f, 200.0f, 200.0f);
    layer.backgroundColor = [UIColor blueColor].CGColor;
    [self.view.layer addSublayer:layer];
    
//    UIImage *image = [UIImage imageNamed:@"1.jpg"];
//    layer.contents = (__bridge id)image.CGImage;
    
//    layer.delegate = self;
//    [layer setNeedsDisplay];
}

//- (void)displayLayer:(CALayer *)layer {
//    UIImage *image = [UIImage imageNamed:@"2.png"];
//    layer.contents = (__bridge id)image.CGImage;
//}
//
//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
//    // 绘制一个圆
//    CGContextSetLineWidth(ctx, 10.0f);
//    CGContextSetStrokeColorWithColor(ctx, [UIColor yellowColor].CGColor);
//    CGContextStrokeEllipseInRect(ctx, layer.bounds);
//}

#pragma mark - 几何位置

- (void)testFrame {
    // 对照组
    CALayer *l = [CALayer layer];
    l.frame = CGRectMake(50.0f, 50.0f, 200.0f, 200.0f);
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    l.contents = (__bridge id)image.CGImage;
    [self.view.layer addSublayer:l];

    
    STLayer *layer = [STLayer layer];
    layer.frame = CGRectMake(50.0f, 50.0f, 200.0f, 200.0f);
    layer.contents = (__bridge id)image.CGImage;
    [self.view.layer addSublayer:layer];
    
    NSLog(@"%@", NSStringFromCGRect(layer.frame));
    NSLog(@"%@", NSStringFromCGPoint(layer.position));
    
    layer.anchorPoint = CGPointMake(0, 0);
    NSLog(@"%@", NSStringFromCGRect(layer.frame));
    NSLog(@"%@", NSStringFromCGPoint(layer.position));
}

#pragma mark - 视觉效果

// 圆角
- (void)testConrner {
    STLayer *layer = [STLayer layer];
    layer.backgroundColor = [UIColor blueColor].CGColor;
    layer.frame = CGRectMake(50.0f, 50.0f, 200.0f, 200.0f);
    [self.view.layer addSublayer:layer];

    // 使用1.jpg需要设置layer.masksToBounds = YES;
    UIImage *image1 = [UIImage imageNamed:@"1.jpg"];
    layer.contents = (__bridge id)image1.CGImage;
    layer.cornerRadius = 10;
    layer.masksToBounds = YES;
    
    
    STLayer *layer2 = [STLayer layer];
    layer2.backgroundColor = [UIColor blueColor].CGColor;
    layer2.frame = CGRectMake(50.0f, 350.0f, 200.0f, 200.0f);
    [self.view.layer addSublayer:layer2];

    // 使用1.png不需要设置layer.masksToBounds = YES;
    UIImage *image2 = [UIImage imageNamed:@"1.png"];
    layer2.contents = (__bridge id)image2.CGImage;
    layer2.cornerRadius = 10;
}

// 圆角和阴影
- (void)testShadow {
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    STLayer *layer = [STLayer layer];
    layer.contents = (__bridge id)image.CGImage;
    layer.backgroundColor = [UIColor blueColor].CGColor;
    layer.frame = CGRectMake(50.0f, 50.0f, 200.0f, 200.0f);
    [self.view.layer addSublayer:layer];

    layer.cornerRadius = 10;
    layer.masksToBounds = YES;

    STLayer *layer1 = [STLayer layer];
    layer1.frame = CGRectMake(50.0f, 50.0f, 200.0f, 200.0f);
    layer1.backgroundColor = [UIColor blueColor].CGColor;
    [self.view.layer insertSublayer:layer1 below:layer];

    layer1.cornerRadius = 10;
    layer1.shadowColor = [UIColor redColor].CGColor;
    layer1.shadowOffset = CGSizeMake(0, 10);
    layer1.shadowOpacity = 1;
}

// 蒙板
- (void)testMask {
    //父图层是一个矩形
    STLayer *layer = [STLayer layer];
    layer.frame = CGRectMake(10, 100, 200, 200);
    layer.contents = (__bridge id)[UIImage imageNamed:@"1.png"].CGImage;
    [self.view.layer addSublayer:layer];
    
    //蒙版图层是一张图片
    STLayer *maskLayer = [STLayer layer];
    maskLayer.frame = layer.bounds;
    maskLayer.contents = (__bridge id)[UIImage imageNamed:@"2.png"].CGImage;
    maskLayer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor;

    layer.mask = maskLayer;
}

#pragma mark - 变换

//  仿射变换
- (void)testTransform {
    STLayer *layer = [STLayer layer];
    layer.frame = CGRectMake(100, 20, 100, 100);
    layer.contents = (__bridge id)[UIImage imageNamed:@"1.jpg"].CGImage;
    [self.view.layer addSublayer:layer];
    
    STLayer *layer1 = [STLayer layer];
    layer1.frame = CGRectMake(100, 200, 100, 100);
    layer1.contents = (__bridge id)[UIImage imageNamed:@"1.jpg"].CGImage;
    [self.view.layer addSublayer:layer1];
    
    CGAffineTransform affineTransform = CGAffineTransformMakeRotation(M_PI_4);
    layer1.affineTransform = affineTransform;
    
    STLayer *layer2 = [STLayer layer];
    layer2.frame = CGRectMake(100, 400, 100, 100);
    layer2.contents = (__bridge id)[UIImage imageNamed:@"1.jpg"].CGImage;
    [self.view.layer addSublayer:layer2];
    
    // 在Y轴方向旋转45度
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1.0 / 500.0;
    transform = CATransform3DRotate(transform, M_PI_4, 0, 1, 0);
    layer2.transform = transform;
}

- (void)testsublayerTransform {
    //父图层设置sublayerTransform
    CALayer *superLayer          = self.view.layer;
    CATransform3D perspective    = CATransform3DIdentity;
    perspective.m34              = - 1.0 / 500.0;
    superLayer.sublayerTransform = perspective;

    CALayer *layer1  = [CALayer layer];
    layer1.frame     = CGRectMake(self.view.center.x - 50, self.view.center.y - 50, 100, 100);
    layer1.contents  = (__bridge id)[UIImage imageNamed:@"1.jpg"].CGImage;
    [superLayer addSublayer:layer1];
    layer1.transform = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);

    CALayer *layer2  = [CALayer layer];
    layer2.frame     = CGRectMake(self.view.center.x + 50, self.view.center.y - 50, 100, 100);
    layer2.contents  = (__bridge id)[UIImage imageNamed:@"1.jpg"].CGImage;
    [superLayer addSublayer:layer2];
    layer2.transform = CATransform3DMakeRotation(-M_PI_4, 0, 1, 0);
}

// 灭点
- (void)testVanishingPoint {
    CALayer *layer1  = [CALayer layer];
    layer1.frame     = CGRectMake(self.view.center.x - 50, self.view.center.y - 50, 100, 100);
    layer1.contents  = (__bridge id)[UIImage imageNamed:@"1.jpg"].CGImage;
    [self.view.layer addSublayer:layer1];
    CATransform3D transform1 = CATransform3DIdentity;
    transform1.m34 = - 1.0 / 500.0;
    transform1 = CATransform3DRotate(transform1, M_PI_4, 0, 1, 0);
    transform1 = CATransform3DTranslate(transform1, -100, 0, 0);
    layer1.transform = transform1;
    
    CALayer *layer2  = [CALayer layer];
    layer2.frame     = CGRectMake(self.view.center.x - 50, self.view.center.y - 50, 100, 100);
    layer2.contents  = (__bridge id)[UIImage imageNamed:@"1.jpg"].CGImage;
    [self.view.layer addSublayer:layer2];
    CATransform3D transform2 = CATransform3DIdentity;
    transform2.m34 = - 1.0 / 500.0;
    transform2 = CATransform3DRotate(transform2, -M_PI_4, 0, 1, 0);
    transform2 = CATransform3DTranslate(transform2, 100, 0, 0);
    layer2.transform = transform2;
}

#pragma mark - CAShapeLayer

// 火柴人
- (void)testCAShapeLayer1 {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(175, 100)];
    [path addArcWithCenter:CGPointMake(150, 100) radius:25 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [path moveToPoint:CGPointMake(150, 125)];
    [path addLineToPoint:CGPointMake(150, 175)];
    [path addLineToPoint:CGPointMake(125, 225)];
    [path moveToPoint:CGPointMake(150, 175)];
    [path addLineToPoint:CGPointMake(175, 225)];
    [path moveToPoint:CGPointMake(100, 150)];
    [path addLineToPoint:CGPointMake(200, 150)];

    //create shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 5;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.path = path.CGPath;
    
    
    [self.view.layer addSublayer:shapeLayer];
}

- (void)testCAShapeLayer2 {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(50, 50, 200, 200) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft cornerRadii:CGSizeMake(20, 20)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path          = path.CGPath;
    shapeLayer.strokeColor   = [UIColor redColor].CGColor;
    shapeLayer.fillColor     = [UIColor yellowColor].CGColor;
    shapeLayer.strokeStart   = 0;
    shapeLayer.strokeEnd     = 0.3;
    shapeLayer.lineWidth     = 10;
    
    [self.view.layer addSublayer:shapeLayer];
}

#pragma mark - CATextLayer

- (void)testCATextLayer {
    CATextLayer *textLayer  = [CATextLayer layer];
    textLayer.frame = CGRectMake(100, 100, 100, 100);
    textLayer.alignmentMode = kCAAlignmentJustified;
    // 是否自适应layer的bounds的大小
    textLayer.wrapped = YES;
    // 以Retina方式来渲染，防止画出来的文本模糊
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    UIFont *font = [UIFont systemFontOfSize:30];
    CGFloat fontSize = font.pointSize;
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CTFontRef fontRef = CTFontCreateWithName(fontName, fontSize, NULL);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"hello stone"];
    NSDictionary *attribs = @{(__bridge id)kCTForegroundColorAttributeName : (__bridge id)[UIColor blackColor].CGColor, (__bridge id)kCTFontAttributeName : (__bridge id)fontRef};
    [string setAttributes:attribs range:NSMakeRange(0, 5)];
    
    attribs = @{(__bridge id)kCTForegroundColorAttributeName : (__bridge id)[UIColor redColor].CGColor, (__bridge id)kCTFontAttributeName : (__bridge id)fontRef};
    [string setAttributes:attribs range:NSMakeRange(6, 5)];
    
    CFRelease(fontRef);
    textLayer.string = string;
    [self.view.layer addSublayer:textLayer];
}

#pragma mark - CAScrollLayer

- (void)testCAScrollLayer {
    CAScrollLayerView *view = [[CAScrollLayerView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    imageView.image         = [UIImage imageNamed:@"1.jpg"];
    [view addSubview:imageView];
    [self.view addSubview:view];
}

#pragma mark - CAGradientLayer

- (void)testCAGradientLayer1 {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(50, 50, 200, 200);
    gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor,
                             (__bridge id)[UIColor blueColor].CGColor,
                             (__bridge id)[UIColor greenColor].CGColor];
    gradientLayer.locations = @[@0.0, @0.25, @0.5];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    
    [self.view.layer addSublayer:gradientLayer];
}

- (void)testCAGradientLayer2 {
    // 圆形
    UIBezierPath *bezierP    = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(10, 10, 200, 200)];
    CAShapeLayer* shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path          = bezierP.CGPath;
    shapeLayer.lineWidth     = 10;
    shapeLayer.fillColor     = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor   = [UIColor blueColor].CGColor;
    shapeLayer.strokeStart   = 0;
    shapeLayer.strokeEnd     = 1;
    // 颜色渐变
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.bounds = CGRectMake(0, 0, 220, 220);
    gradientLayer.position = self.view.center;
    NSMutableArray *colorArray = [NSMutableArray new];
    for (NSInteger hue = 0; hue <= 360; hue += 5) {
        UIColor *color = [UIColor colorWithHue:1.0*hue/360.0
                                    saturation:1.0
                                    brightness:1.0
                                         alpha:1.0];
        [colorArray addObject:(id)color.CGColor];
    }
    gradientLayer.colors = colorArray;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    // 设置模板
    gradientLayer.mask = shapeLayer;
    [self.view.layer addSublayer:gradientLayer];
}

#pragma mark - CAReplicatorLayer

// 倒影
- (void)testCAReplicatorLayer1 {
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(100, 100, 200, 200);
    [self.view.layer addSublayer:replicatorLayer];
    
    // 复制后的个数
    replicatorLayer.instanceCount = 2;
    //transform变化
    CATransform3D transform = CATransform3DIdentity;
    // 下移
    transform = CATransform3DTranslate(transform, 0, 200, 0);
    // y坐标取相反数，实现上下倒立
    transform = CATransform3DScale(transform, 1, -1, 0);
    replicatorLayer.instanceTransform = transform;
    
    // 颜色变化
    replicatorLayer.instanceBlueOffset = -0.1;
    replicatorLayer.instanceGreenOffset = -0.1;
    
    //复制的子图层
    CALayer *layer = [CALayer layer];
    layer.frame    = CGRectMake(0, 0, 200, 200);
    layer.contents = (__bridge id)[UIImage imageNamed:@"2.png"].CGImage;
    [replicatorLayer addSublayer:layer];
}

// 跳跃的爱心
- (void)testCAReplicatorLayer2 {
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.instanceCount = 40;
    replicatorLayer.instanceDelay = 0.2;
    [self.view.layer addSublayer:replicatorLayer];
    // 子图层
    CALayer *layer        = [CALayer layer];
    layer.frame           = CGRectMake(200, 200, 10, 10);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [replicatorLayer addSublayer:layer];
    // love路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(200, 200)];
    [path addQuadCurveToPoint:CGPointMake(200, 400) controlPoint:CGPointMake(200 + 200, 20)];
    [path addQuadCurveToPoint:CGPointMake(200, 200) controlPoint:CGPointMake(200 - 200, 20)];
    [path closePath];
    // 动作效果
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path                 = path.CGPath;
    animation.duration             = 8;
    animation.repeatCount          = MAXFLOAT;
    [layer addAnimation:animation forKey:@"animation"];
}

#pragma mark - CATransformLayer

- (void)testCATransformLayer {
    //子图层1
    CALayer *layer1        = [CALayer layer];
    layer1.frame           = CGRectMake(0, 0, 100, 100);
    layer1.backgroundColor = [UIColor redColor].CGColor;
    layer1.transform       = CATransform3DMakeTranslation(0, 0, -50);
    //子图层2
    CALayer *layer2        = [CALayer layer];
    layer2.frame           = CGRectMake(0, 0, 100, 100);
    layer2.backgroundColor = [UIColor blueColor].CGColor;
    layer2.transform       = CATransform3DMakeTranslation(0, 0, -100);
    //layer1和layer2在x轴y轴坐标一样，但z轴坐标不一样。
    
    // 创建容器，分别是CATransformLayer类型和CALayer类型
    CATransformLayer *transformLayer = [CATransformLayer layer];
    //CALayer *transformLayer = [CALayer layer];
    transformLayer.frame = CGRectMake(100, 100, 100, 100);
    [transformLayer addSublayer:layer1];
    [transformLayer addSublayer:layer2];
    [self.view.layer addSublayer:transformLayer];
    
    CATransform3D transform  = CATransform3DIdentity;
    transform.m34            = 1.0 / -500;
    // 绕y轴旋转45度
    transform                = CATransform3DRotate(transform, M_PI_4, 0, 1, 0);
    transformLayer.transform = transform;
}

#pragma mark - CATiledLayer

- (void)testCATiledLayer {
    CATiledLayer *tileLayer = [CATiledLayer layer];
    tileLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) * 2, CGRectGetHeight(self.view.frame) * 2);
    tileLayer.tileSize = self.view.frame.size;
    tileLayer.delegate = self;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.contentSize = tileLayer.frame.size;
    [scrollView.layer addSublayer:tileLayer];

    [tileLayer setNeedsDisplay];
}

//- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)ctx {
//    // 根据ctx获取信息，判断当前的绘制的块内容
//    CGRect bounds = CGContextGetClipBoundingBox(ctx);
//
//    CGFloat x = bounds.origin.x;
//    CGFloat y = bounds.origin.y;
//    CGFloat width = CGRectGetWidth(self.view.bounds);
//    CGFloat height = CGRectGetHeight(self.view.bounds);
//    NSString *imageName;
//    if ((x == 0 && y == 0) || (x == width && y == height)) {
//        imageName = @"1.png";
//    }
//    else {
//        imageName = @"2.png";
//    }
//    UIImage *tileImage = [UIImage imageNamed:imageName];
//
//    UIGraphicsPushContext(ctx);
//    [tileImage drawInRect:bounds];
//    UIGraphicsPopContext();
//}

#pragma mark - CAEmitterLayer

- (void)testCAEmitterLayer {
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.frame           = self.view.bounds;
    emitterLayer.masksToBounds   = YES;
    emitterLayer.emitterPosition = CGPointMake(self.view.bounds.size.width / 2.f, - 20);
    emitterLayer.emitterShape    = kCAEmitterLayerLine;
    emitterLayer.emitterMode     = kCAEmitterLayerSurface;
    emitterLayer.emitterSize     = self.view.bounds.size;
    
    CAEmitterCell *rainflake = [CAEmitterCell  emitterCell];
    rainflake.birthRate      = 5.f;
    rainflake.speed          = 10.f;
    rainflake.velocity       = 10.f;
    rainflake.velocityRange  = 10.f;
    rainflake.yAcceleration  = 1000.f;
    rainflake.contents       = (__bridge id)([UIImage imageNamed:@"1.png"].CGImage);
    rainflake.color          = [UIColor whiteColor].CGColor;
    rainflake.lifetime       = 160.f;
    rainflake.scale          = 0.2f;
    rainflake.scaleRange     = 0.f;
    emitterLayer.emitterCells = @[rainflake];
    
    [self.view.layer addSublayer:emitterLayer];
}


#pragma mark - AVPlayerLayer

- (void)testAVPlayerLayer {
    NSURL *URL       = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp4"];
    AVPlayer *player = [AVPlayer playerWithURL:URL];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame          = CGRectMake(50, 100, 300, 300);
    playerLayer.videoGravity   = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
    
    // 进行各种处理
    CATransform3D transform   = CATransform3DIdentity;
    transform.m34             = -1.0 / 500.0;
    transform                 = CATransform3DRotate(transform, M_PI_4, 1, 1, 0);
    playerLayer.transform     = transform;
    playerLayer.masksToBounds = YES;
    playerLayer.cornerRadius  = 20.0;
    playerLayer.borderColor   = [UIColor redColor].CGColor;
    playerLayer.borderWidth   = 5.0;
    [player play];
}


@end
