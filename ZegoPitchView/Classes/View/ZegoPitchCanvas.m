//
//  ZegoPitchCanvas.m
//  GoChat
//
//  Created by Vic on 2021/11/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import "ZegoPitchCanvas.h"

@interface ZegoPitchCanvas ()

@property (nonatomic, strong) ZegoPitchViewConfig *config;

@property (nonatomic, copy) NSArray<ZegoPitchModel *> *stdPitchModelsToDraw;
@property (nonatomic, copy) NSArray<ZegoPitchModel *> *hitPitchModelsToDraw;
@property (nonatomic, assign) int pitch; // 10 - 90
@property (nonatomic, assign) NSInteger progress;


@property (nonatomic, assign) CGFloat msWidth;
@property (nonatomic, assign) CGFloat pitchHeight;
@property (nonatomic, assign) CGFloat vlineOffsetX;

@end

@implementation ZegoPitchCanvas

- (void)drawRect:(CGRect)rect {
  
  // 五线谱
  [self drawStaff];
  // 标准音高线
  [self drawStandardPitchModels];
  // 击中音高线
  [self drawHitPitchModels];
  // 竖线
  [self drawVerticalLine];
  // 音调指示器
  [self drawPitchIndicator];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self setupUIProperties];
}

#pragma mark - Public
- (void)setConfig:(ZegoPitchViewConfig *)config {
  _config = config;
  [self setupUIProperties];
}

- (void)drawWithProgress:(NSInteger)progress
          stdPitchModels:(NSArray<ZegoPitchModel *> *)stdPitchModels
          hitPitchModels:(NSArray<ZegoPitchModel *> *)hitPitchModels
                   pitch:(int)pitch {
  self.progress = progress;
  self.stdPitchModelsToDraw = stdPitchModels;
  self.hitPitchModelsToDraw = hitPitchModels;
  self.pitch = pitch;
  
  [self setNeedsDisplay];
}

- (void)clearAll {
  self.stdPitchModelsToDraw = nil;
  self.hitPitchModelsToDraw = nil;
  self.progress = 0;
  
  [self setNeedsDisplay];
}

#pragma mark - Private
- (void)setupUIProperties {
  if (!self.config) {
    return;
  }
  self.backgroundColor = self.config.backgroundColor;

  CGFloat selfHeight = CGRectGetHeight(self.bounds);
  CGFloat selfWidth = CGRectGetWidth(self.bounds);
  
  self.msWidth = selfWidth / (self.config.timeElapsedOnScreen + self.config.timeToPlayOnScreen);
  self.pitchHeight = selfHeight / self.config.pitchNum;
}

- (CGFloat)getPitchRectCenterYWithPitch:(int)pitch {
  CGFloat selfHeight = CGRectGetHeight(self.bounds);
  if (pitch < self.config.minPitch) {
    return selfHeight;
  }
  if (pitch > self.config.maxPitch) {
    return 0;
  }
  if (pitch == self.config.minPitch) {
    pitch += 1;
  }
  return (self.config.maxPitch - pitch) * self.config.pitchNum / (self.config.maxPitch - self.config.minPitch) * self.pitchHeight + self.pitchHeight * 0.5;
}

#pragma mark Drawing

- (void)drawStaff {
  CGFloat selfHeight = CGRectGetHeight(self.bounds);
  CGFloat selfWidth = CGRectGetWidth(self.bounds);
  CGFloat lineWidth = 1;
  
  CGFloat spaceY = (selfHeight - 5) / 4;
  for (int i = 0; i < 5; i++) {
    CGFloat y = i * (spaceY + lineWidth);
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, y, selfWidth, lineWidth)];
    UIColor *lineColor = self.config.staffColor;
    [lineColor setFill];
    [linePath fill];
  }
}

- (void)drawVerticalLine {
  CGFloat selfHeight = CGRectGetHeight(self.bounds);
  CGFloat selfWidth = CGRectGetWidth(self.bounds);
  CGFloat lineWidth = 0.5;
  
  CGFloat vlineOffsetX = selfWidth * self.config.timeElapsedOnScreen / (self.config.timeElapsedOnScreen + self.config.timeToPlayOnScreen);
  self.vlineOffsetX = vlineOffsetX;
  CGRect vlineRect = CGRectMake(vlineOffsetX, 0, lineWidth, selfHeight);
  UIBezierPath *vlinePath = [UIBezierPath bezierPathWithRect:vlineRect];
  UIColor *vlineColor = self.config.verticalLineColor;
  [vlineColor setFill];
  [vlinePath fill];
}

/// 绘制标准音高线
- (void)drawStandardPitchModels {
  [self drawPitchModels:self.stdPitchModelsToDraw fillColor:self.config.standardRectColor validateGap:NO];
}

/// 绘制击中音高线
- (void)drawHitPitchModels {
  [self drawPitchModels:self.hitPitchModelsToDraw fillColor:self.config.hitRectColor validateGap:NO];
}

- (void)drawPitchModels:(NSArray<ZegoPitchModel *> *)pitchModels fillColor:(UIColor *)fillColor validateGap:(BOOL)validate {
  if (!(pitchModels.count > 0)) {
    return;
  }
 
#if RELEASE
  validate = NO;
#endif
  
  CGFloat msWidth = self.msWidth;
  CGFloat pitchHeight = self.pitchHeight;
  
  ZegoPitchModel *prev = nil;
  
  for (ZegoPitchModel *pitchModel in pitchModels) {
    if (prev) {
      if (validate) {
        if (pitchModel.begin_time > prev.begin_time + prev.duration) {
//          NSLog(@"[KTV_DEBUG_PITCH_TEST] prev_end:%ld, cur_begin:%ld", (long)(prev.begin_time + prev.duration), (long)pitchModel.begin_time);
        }
      }
    }
    
    NSInteger beginTime = pitchModel.begin_time;
    NSInteger duration = pitchModel.duration;
    int pitch = pitchModel.value;
    
    CGFloat x = msWidth * (beginTime - (self.progress - self.config.timeElapsedOnScreen));
    CGFloat y = [self getPitchRectCenterYWithPitch:pitch] - self.pitchHeight * 0.5;
    CGFloat w = msWidth * duration;
    CGFloat h = pitchHeight;
    
    if (validate) {
      h /= 2;
    }
    
    CGRect pitchRect = CGRectMake(x, y, w, h);
    
    UIBezierPath *linePath;
    BOOL rounded = YES;

    if (rounded) {
      linePath = [UIBezierPath bezierPathWithRoundedRect:pitchRect cornerRadius:pitchHeight * 0.5];
    }else {
      linePath = [UIBezierPath bezierPathWithRect:pitchRect];
    }
    
//    NSLog(@"[KTV_DEBUG_PITCH_DRAW] self bounds:%@, pitch rect:%@", NSStringFromCGRect(self.bounds), NSStringFromCGRect(pitchRect));
    
    UIColor *lineColor = fillColor;
    [lineColor setFill];
    [linePath fill];
    
    prev = pitchModel;
  }
}

- (void)drawPitchIndicator {
  CGFloat y = [self getPitchRectCenterYWithPitch:self.pitch];
  CGPoint endPoint = CGPointMake(self.vlineOffsetX, y);
  [self.delegate updatePitchIndicatorPositionWithEndPoint:endPoint];
}

@end
