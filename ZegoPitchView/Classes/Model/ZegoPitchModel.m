//
//  ZegoSongPitch.m
//  GoChat
//
//  Created by Vic on 2021/11/24.
//  Copyright © 2021 zego. All rights reserved.
//

#import "ZegoPitchModel.h"

@implementation ZegoPitchModel

+ (NSArray<ZegoPitchModel *> *)analyzePitchData:(id)json {
  return [self analyzePitchData:json beginTime:0 endTime:NSIntegerMax krcFormatOffset:0];
}

+ (NSArray<ZegoPitchModel *> *)analyzePitchData:(id)json beginTime:(NSInteger)beginTime endTime:(NSInteger)endTime krcFormatOffset:(NSInteger)krcFormatOffset {
  if (!json) {
    return nil;
  }
  NSDictionary *rsp = [self dictionaryWithJSON:json];
  NSDictionary *dataDict = rsp[@"data"];
  NSArray *pitchModels = nil;
  
  if (dataDict) {
    NSDictionary *pitchArray = dataDict[@"pitch"];
    if (pitchArray) {
      NSMutableArray *mArr = [NSMutableArray array];
      for (NSDictionary *dict in pitchArray) {
        ZegoPitchModel *model = [self pitchModelWithDict:dict];
        model.begin_time += (int)krcFormatOffset;
        
        if (model.begin_time > endTime) {
          continue;
        }
        if (model.begin_time + model.duration < beginTime) {
          continue;
        }
        
        [mArr addObject:model];
      }
      if (mArr.count > 0) {
        //检查头尾元素, 去掉超出范围部分
        [self trimModelInPlace:mArr.firstObject fromBeginTime:(int)beginTime toEndTime:(int)endTime];
        [self trimModelInPlace:mArr.lastObject fromBeginTime:(int)beginTime toEndTime:(int)endTime];
      }
      
      pitchModels = mArr.copy;
    }
  }
  return pitchModels;
}

+ (void)trimModelInPlace:(ZegoPitchModel *)model fromBeginTime:(int)beginTime toEndTime:(int)endTime {
  if (!model) {
    return;
  }
  if (model.begin_time < beginTime) {
    model.duration -= (beginTime - model.begin_time);
    model.begin_time = beginTime;
  }
  if (model.begin_time + model.duration > endTime) {
    model.duration = endTime - model.begin_time;
  }
}


+ (NSArray<ZegoPitchModel *> *)analyzePitchData:(id)json krcFormatOffset:(NSInteger)krcFormatOffset {
  if (!json) {
    return nil;
  }
  NSDictionary *rsp = [self dictionaryWithJSON:json];
  NSDictionary *dataDict = rsp[@"data"];
  NSArray *pitchModels = nil;
  
  if (dataDict) {
    NSDictionary *pitchArray = dataDict[@"pitch"];
    if (pitchArray) {
      NSMutableArray *mArr = [NSMutableArray array];
      for (NSDictionary *dict in pitchArray) {
        ZegoPitchModel *model = [self pitchModelWithDict:dict];
        model.begin_time += (int)krcFormatOffset;
        [mArr addObject:model];
      }
      pitchModels = mArr.copy;
    }
  }
  return pitchModels;
}

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

+ (NSDictionary *)dictionaryWithJSON:(id)json {
  if (!json || json == (id)kCFNull) return nil;
  NSDictionary *dic = nil;
  NSData *jsonData = nil;
  if ([json isKindOfClass:[NSDictionary class]]) {
    dic = json;
  } else if ([json isKindOfClass:[NSString class]]) {
    jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
  } else if ([json isKindOfClass:[NSData class]]) {
    jsonData = json;
  }
  if (jsonData) {
    dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
  }
  return dic;
}

@end
