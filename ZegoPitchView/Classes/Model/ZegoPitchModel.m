//
//  ZegoSongPitch.m
//  GoChat
//
//  Created by Vic on 2021/11/24.
//  Copyright © 2021 zego. All rights reserved.
//

#import "ZegoPitchModel.h"

@implementation ZegoPitchModel

+ (instancetype)pitchModelWithDict:(NSDictionary *)dict {
  if (!dict || !dict.count) {
    return nil;
  }
  ZegoPitchModel *pitch = [[ZegoPitchModel alloc] init];
  pitch.begin_time = [dict[@"begin_time"] intValue];
  pitch.duration = [dict[@"duration"] intValue];
  pitch.value = [dict[@"value"] intValue];
  return pitch;
}

@end
