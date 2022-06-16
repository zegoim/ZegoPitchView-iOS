//
//  ZegoPitchView.m
//  GoChat
//
//  Created by Vic on 2021/11/24.
//  Copyright © 2021 zego. All rights reserved.
//

#import "ZegoPitchView.h"
#import "ZegoPitchCanvas.h"

@interface ZegoPitchView ()
<
ZegoPitchCanvasProtocol,
CAAnimationDelegate
>

/// UI
@property (nonatomic, strong) ZegoPitchCanvas *canvas;
@property (nonatomic, strong) CAShapeLayer *pitchIndicatorLayer;
@property (nonatomic, assign) CGPoint pitchIndicatorOriginPosition;
@property (nonatomic, strong) NSMutableDictionary *animationLabelMap; //用来将 label 从 superView 移除, 防止 label 生产太快导致移除错误
@property (nonatomic, strong) UIFont *scoreLabelFont;

/// Data
@property (nonatomic, strong) ZegoPitchViewConfig *config;
@property (nonatomic, copy, nullable) NSArray<ZegoPitchModel *> *stdPitchModels;
@property (nonatomic, strong, nullable) NSMutableArray<ZegoPitchModel *> *hitPitchModels;
@property (nonatomic, assign) int curProgress;
@property (nonatomic, assign) int curSingPitch;
@property (nonatomic, assign) BOOL hitInPeriod;

/// Animation
@property (nonatomic, strong) CAAnimation *anim1;
@property (nonatomic, strong) CAAnimation *anim2;
@property (nonatomic, strong) CAAnimation *anim4;
@property (nonatomic, strong) CAAnimation *anim5;
@property (nonatomic, strong) CAKeyframeAnimation *riseAnim;

@end

@implementation ZegoPitchView

#pragma mark - Override
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setup];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self setup];
  }
  return self;
}

- (void)layoutSubviews {
  CGFloat canvasMarginY = 5;
  [self.canvas setFrame:CGRectMake(0,
                                   canvasMarginY,
                                   CGRectGetWidth(self.bounds),
                                   CGRectGetHeight(self.bounds) - 2 * canvasMarginY)];
}


#pragma mark - Public
- (void)setConfig:(ZegoPitchViewConfig *)config {
  if (!config) {
    config = [ZegoPitchViewConfig defaultConfig];
  }
  _config = config;
  [self.canvas setConfig:config];
}

- (void)setStandardPitchModels:(NSArray<ZegoPitchModel *> *)standardPitchModels {
  [self reset];
  self.stdPitchModels = standardPitchModels;
}

- (int)getPitchStartTime {
  if (!(self.stdPitchModels.count > 0)) {
    return 0;
  }
  ZegoPitchModel *firstPitchModel = self.stdPitchModels.firstObject;
  return firstPitchModel.begin_time;
}

- (void)setCurrentSongProgress:(int)progress pitch:(int)pitch {
  self.curProgress = progress;
  int beginTime = [self beginTimeOnViewWithProgress:progress];
  int endTime = [self endTimeOnViewWithProgress:progress];
  
  pitch = [self validatePitch:pitch];
  _curSingPitch = pitch;
  
  /// 找出当前需要绘制的标准音高数据
  NSArray<ZegoPitchModel *> *stdPitchModelsToDraw = [self filterPitchModels:self.stdPitchModels betweenBeginTime:beginTime endTime:endTime];
  
  //如果 pitchVal 为 0~5, 则需要判断更新 hitPitchModels
  [self updateCurrentSingPitchAndHitPitchModelsIfNeededWithProgress:progress pitch:pitch stdPitchModelsOnView:stdPitchModelsToDraw];
  
  /// 找出当前需要绘制的击中音高数据
  NSArray<ZegoPitchModel *> *hitPitchModelsToDraw = [self filterPitchModels:self.hitPitchModels betweenBeginTime:beginTime endTime:progress];
  
  [self.canvas drawWithProgress:progress
                 stdPitchModels:stdPitchModelsToDraw
                 hitPitchModels:hitPitchModelsToDraw
                          pitch:self.curSingPitch];
}

- (void)addScore:(int)score {
  
  // 过滤音高线开始之前的得分
  if ([self isProgressBeforeFirstPitchModel]) {
    return;
  }
  
  UILabel *scoreLabel = [self createAScoreLabel];
  
  scoreLabel.text = [NSString stringWithFormat:@"+%d", score];
  
  [self animateScoreLabel:scoreLabel];
}

- (void)animateScoreLabel:(UILabel *)label {
  //相对当前三角形的位置
  CGPoint triangleOrigin = self.pitchIndicatorOriginPosition;
  CGFloat x = triangleOrigin.x;
  CGFloat y = MIN(triangleOrigin.y, CGRectGetHeight(self.bounds) - 20);
  
  CGSize labelSize = [self calculateSizeForScoreLabel:label];
  CGRect labelRect = CGRectMake(x, y, labelSize.width, labelSize.height);
  label.frame = labelRect;
  
  CAAnimation *anim = [self groupedAnimationMoveOnAxisYFrom:y to:10];
  [label.layer addAnimation:anim forKey:nil];
  
  self.animationLabelMap[anim] = label;
}

- (void)reset {
  self.stdPitchModels = nil;
  self.hitPitchModels = nil;
  self.curProgress = 0;
  self.hitInPeriod = NO;
  
  [self.canvas clearAll];
}

#pragma mark - Delegate
- (void)updatePitchIndicatorPositionWithEndPoint:(CGPoint)endPoint {
  CGFloat originY = CGRectGetMaxY(self.canvas.frame);
  CGFloat translatedY = endPoint.y + CGRectGetMinY(self.canvas.frame);
  CGPoint translatedEndPoint = CGPointMake(endPoint.x, translatedY);
  
  CGFloat w = 5;
  CGFloat h = 7;
  if (!_pitchIndicatorLayer) {
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *triPath = [UIBezierPath bezierPath];
    
    CGPoint point1 = translatedEndPoint;
    CGPoint point2 = CGPointMake(translatedEndPoint.x - w, translatedEndPoint.y - h * 0.5);
    CGPoint point3 = CGPointMake(translatedEndPoint.x - w, translatedEndPoint.y + h * 0.5);

    [triPath moveToPoint:point1];
    [triPath addLineToPoint:point2];
    [triPath addLineToPoint:point3];
    [triPath closePath];
    
    layer.fillColor = self.config.pitchIndicatorColor.CGColor;
    layer.path = triPath.CGPath;
    [self.layer addSublayer:layer];

    _pitchIndicatorLayer = layer;
  }
  else {
    [CATransaction begin];
    [CATransaction setDisableActions:self.hitInPeriod];
//    [CATransaction setAnimationDuration:1];

    CGFloat ty = translatedY - originY;
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, ty);
    self.pitchIndicatorLayer.affineTransform = translation;

    [CATransaction commit];
  }
  
  //记录当前三角形原点位置
//  self.pitchIndicatorOriginPosition = CGPointMake(translatedEndPoint.x - w, translatedY - h * 0.5);
  self.pitchIndicatorOriginPosition = endPoint;
}

#pragma mark -
#pragma mark - Private

/// 初始化
- (void)setup {
  _hitPitchModels = [NSMutableArray array];
  _canvas = [[ZegoPitchCanvas alloc] init];
  _canvas.delegate = self;
  [self addSubview:_canvas];
  
  _animationLabelMap = [NSMutableDictionary dictionary];
}

/// 验证 pitch 值, 若不合法则修改
- (int)validatePitch:(int)pitch {
  if (pitch < 0) {
    pitch = 0;
  }
  else if (pitch > 5 && pitch < self.config.minPitch) {
    pitch = self.config.minPitch;
  }
  else if (pitch > self.config.maxPitch) {
    pitch = self.config.maxPitch;
  }
  return pitch;
}

/// 找到当前 view 需要显示的音调数据
- (NSArray<ZegoPitchModel *> *)filterPitchModels:(NSArray<ZegoPitchModel *> *)pitchModels
                                betweenBeginTime:(int)beginTime
                                         endTime:(int)endTime {
  if (!(pitchModels.count > 0)) {
    return nil;
  }
  if (beginTime >= endTime) {
    return nil;
  }
  NSMutableArray *ret = [NSMutableArray array];
  for (ZegoPitchModel *model in pitchModels) {
    int begin = model.begin_time;
    int end = begin + model.duration;
    if (begin >= endTime) {
      continue;
    }
    if (end <= beginTime) {
      continue;
    }
    [ret addObject:model];
  }
  return ret.copy;
}

- (int)getOffsetScaleWithPitch:(int)pitch {
  int offsetScale = -1;
  switch (pitch) {

    case 1:
      offsetScale = -2;
      break;
      
    case 2:
      offsetScale = 0;
      break;
      
    case 3:
      offsetScale = 0;
      break;
      
    case 4:
      offsetScale = 0;
      break;
      
    case 5:
      offsetScale = 2;
      break;
      
    case 0:
    default:
      break;
  }
  return offsetScale;
}

/// 更新当前音调, 若击中则更新击中音调数据
- (void)updateCurrentSingPitchAndHitPitchModelsIfNeededWithProgress:(int)progress
                                                              pitch:(int)pitch
                                               stdPitchModelsOnView:(NSArray<ZegoPitchModel *> *)stdPitchModelsOnView {
  if (pitch < 0 || pitch > 5) {
    return;
  }
  
  BOOL hit = NO;
  for (ZegoPitchModel *stdPitch in stdPitchModelsOnView) {
    //找到对应的标准音高线
    BOOL contain = !((progress > (stdPitch.begin_time + stdPitch.duration + 60)) || progress < stdPitch.begin_time);
    if (contain) {
      // 判断是否击中标准音高
      int offsetScale = [self getOffsetScaleWithPitch:pitch];
      
      if ([self test_hitAll]) {
        offsetScale = 0;
      }
      
      if (offsetScale == -1) {
        //无声
        self.curSingPitch = 0;
      }
      else if (offsetScale == 0) {
        //击中
        hit = YES;
        self.curSingPitch = stdPitch.value;
        [self updateHitPitchModelsAtProgress:progress pitch:self.curSingPitch matchedStdPitchModel:stdPitch];
        NSLog(@"[KTV_DEBUG_PITCH]progress:%d, real pitch:%d hit count:%lu", progress, self.curSingPitch, (unsigned long)self.hitPitchModels.count);
      }
      else {
        // 偏大或者偏小的情况
        CGFloat curPitch = stdPitch.value + 4 * offsetScale;
        if (curPitch > self.config.maxPitch) {
//          curPitch = self.config.maxPitch;
        }
        else if (curPitch < self.config.minPitch) {
          curPitch = 0;
        }
        self.curSingPitch = curPitch;
      }
      continue;
    }
  }
  self.hitInPeriod = hit;
}

/// 更新击中块数组
- (void)updateHitPitchModelsAtProgress:(int)progress pitch:(int)pitch matchedStdPitchModel:(ZegoPitchModel *)stdPitchModel {
  
  [self removeObsoleteHitPitchModelsAtProgress:progress];
  
  int stdBegin = stdPitchModel.begin_time;
  int stdDuration = stdPitchModel.duration;
  int stdEnd = stdBegin + stdDuration;
  
  int postTolerance = 100;
  
  // 只需要考察最后一个元素
  ZegoPitchModel *prev = self.hitPitchModels.lastObject;
  if (!prev
      || prev.value != pitch
      || prev.begin_time + prev.duration + self.config.estimatedCallInterval < progress
      ) {
    
    if (stdEnd - progress < postTolerance) {
      // 如果 model 的起始位置距离 std 结束距离过近, 则不新建, 否则长度过短, UI 效果不佳
      return;
    }
    
    ZegoPitchModel *model = [[ZegoPitchModel alloc] init];
    model.begin_time = MAX(progress - self.config.estimatedCallInterval, stdBegin);
    
    int endTime = MIN(stdEnd, progress);
    
    model.duration = endTime - model.begin_time;
    model.value = pitch;
    [self.hitPitchModels addObject:model];
    return;
  }
  
  int endTime = MIN(stdEnd, progress);
  prev.duration = endTime - prev.begin_time;
}

/// 删除不再需要绘制的
- (void)removeObsoleteHitPitchModelsAtProgress:(int)progress {
  __block NSUInteger lengthToRemove = 0;
  [self.hitPitchModels enumerateObjectsUsingBlock:^(ZegoPitchModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
  }];
  [self.hitPitchModels enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ZegoPitchModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (obj.begin_time + obj.duration < [self beginTimeOnViewWithProgress:progress]) {
      lengthToRemove = idx + 1;
      *stop = YES;
    }
  }];
  NSRange rangeToRemove = NSMakeRange(0, lengthToRemove);
  [self.hitPitchModels removeObjectsInRange:rangeToRemove];
}

- (int)beginTimeOnViewWithProgress:(int)progress {
  return (progress - self.config.timeElapsedOnScreen);
}

- (int)endTimeOnViewWithProgress:(int)progress {
  return (progress + self.config.timeToPlayOnScreen);
}

- (NSMutableArray<ZegoPitchModel *> *)hitPitchModels {
  if (!_hitPitchModels) {
    _hitPitchModels = [NSMutableArray array];
  }
  return _hitPitchModels;
}

#pragma mark - Score Label
- (UILabel *)createAScoreLabel {
  UILabel *scoreLabel = [[UILabel alloc] init];
  scoreLabel.textColor = self.config.scoreTextColor;
  scoreLabel.font = self.scoreLabelFont;
  scoreLabel.alpha = 0;
  [self addSubview:scoreLabel];
  
  return scoreLabel;
}

- (CGSize)calculateSizeForScoreLabel:(UILabel *)label {
  CGRect labelRect = [label.text boundingRectWithSize:CGSizeMake(100, 100) options:0 attributes:@{
    NSFontAttributeName: self.scoreLabelFont,
  } context:nil];
  
  CGFloat labelW = ceil(labelRect.size.width);
  CGFloat labelH = ceil(labelRect.size.height);
  
  return CGSizeMake(labelW, labelH);
}

- (BOOL)isProgressBeforeFirstPitchModel {
  int beginTime = [self getPitchStartTime];
  return self.curProgress < beginTime;
}

- (UIFont *)scoreLabelFont {
  if (!_scoreLabelFont) {
    _scoreLabelFont = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
  }
  return _scoreLabelFont;
}

#pragma mark - Animation
- (CAAnimationGroup *)groupedAnimationMoveOnAxisYFrom:(CGFloat)fromY to:(CGFloat)toY {
  
  CGFloat d1 = 0.2;
  CGFloat d2 = 0.4;
  CGFloat d3 = 0.4;
  CGFloat d4 = 0.01;
  CGFloat d5 = 0.3;
  
  CGFloat dTotal = d1 + d2 + d3 + d4 + d5;
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.delegate = self;
  
  CAAnimation *anim1 = self.anim1;
  CAAnimation *anim2 = self.anim2;
  CAAnimation *anim3 = [self riseAnimationFromY:fromY toY:toY duration:0.4];
  CAAnimation *anim4 = self.anim4;
  CAAnimation *anim5 = self.anim5;
  
  group.animations = @[anim1, anim2, anim3, anim4, anim5];
  group.duration = dTotal;
  anim1.beginTime = 0;
  anim2.beginTime = anim1.duration;
  anim3.beginTime = anim2.beginTime + anim2.duration;
  anim4.beginTime = anim3.beginTime + anim3.duration;
  anim5.beginTime = anim4.beginTime + anim4.duration;
  group.repeatCount = 1;
  
  return group;
}

- (CAKeyframeAnimation *)appearAnimationWithDuration:(CFTimeInterval)duration {
  CAMediaTimingFunction *func = [CAMediaTimingFunction functionWithControlPoints:0.25 :0.1 :0.25 :1];
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
  
  animation.values = @[@0, @1];
  animation.duration = duration;
  animation.timingFunction = func;
  animation.fillMode = kCAFillModeForwards;
  return animation;
}

- (CABasicAnimation *)stayAnimationWithOpacity:(CGFloat)opacity duration:(CFTimeInterval)duration {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  animation.fromValue = @(opacity);
  animation.toValue = @(opacity);
  animation.duration = duration;
  return animation;
}

- (CAKeyframeAnimation *)riseAnimationFromY:(CGFloat)from toY:(CGFloat)to duration:(CGFloat)duration {
  
  if (!_riseAnim) {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    CAMediaTimingFunction *function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.timingFunction = function;
    animation.fillMode = kCAFillModeForwards;
    _riseAnim = animation;
  }
  
  _riseAnim.values = @[@(from), @(to)];
  _riseAnim.duration = duration;
  
  return _riseAnim;
}

- (CAKeyframeAnimation *)disappearAnimationWithDuration:(CFTimeInterval)duration {
  CAMediaTimingFunction *func = [CAMediaTimingFunction functionWithControlPoints:0.25 :0.1 :0.25 :1];
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
  
  animation.values = @[@1, @0];
  animation.duration = duration;
  animation.timingFunction = func;
  return animation;
}

#pragma mark Animation lazy creation
- (CAAnimation *)anim1 {
  if (!_anim1) {
    _anim1 = [self appearAnimationWithDuration:0.2];
  }
  return _anim1;
}

- (CAAnimation *)anim2 {
  if (!_anim2) {
    _anim2 = [self stayAnimationWithOpacity:1 duration:0.4];
  }
  return _anim2;
}

- (CAAnimation *)anim4 {
  if (!_anim4) {
    _anim4 = [self stayAnimationWithOpacity:1 duration:0.01];
  }
  return _anim4;
}

- (CAAnimation *)anim5 {
  if (!_anim5) {
    _anim5 = [self disappearAnimationWithDuration:0.3];
  }
  return _anim5;
}

#pragma mark - Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finish {
  if (finish) {
    UILabel *label = self.animationLabelMap[anim];
    [label removeFromSuperview];
  }
}

#pragma mark -
#pragma mark - Test
- (BOOL)test_hitAll {
  return NO;
}

@end
