//
//  ZegoPitchViewConfig.m
//  GoChat
//
//  Created by Vic on 2021/11/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import "ZegoPitchViewConfig.h"

@implementation ZegoPitchViewConfig

+ (instancetype)defaultConfig {
  ZegoPitchViewConfig *config = [[ZegoPitchViewConfig alloc] init];
  
  config.pitchNum = 20;
  config.maxPitch = 90;
  config.minPitch = 10;
  config.timeElapsedOnScreen = 1175;
  config.timeToPlayOnScreen = 2750;
  config.estimatedCallInterval = 60;
  
  config.backgroundColor = [UIColor colorWithRed:7/255.0 green:1/255.0 blue:18/255.0 alpha:0.14];
  config.staffColor = [UIColor colorWithWhite:1 alpha:0.2];
  config.verticalLineColor = [UIColor colorWithRed:168/255.0 green:123/255.0 blue:241/255.0 alpha:1];
  config.standardRectColor = [UIColor colorWithRed:93/255.0 green:59/255.0 blue:148/255.0 alpha:1];
  config.hitRectColor = [UIColor colorWithRed:255/255.0 green:53/255.0 blue:113/255.0 alpha:1];
  config.pitchIndicatorColor = UIColor.whiteColor;
  config.scoreTextColor = UIColor.whiteColor;
  
  return config;
}

@end
