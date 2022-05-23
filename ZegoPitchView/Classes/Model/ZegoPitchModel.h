//
//  ZegoSongPitch.h
//  GoChat
//
//  Created by Vic on 2021/11/24.
//  Copyright © 2021 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoPitchModel : NSObject

/// 音高线开始时间
@property (nonatomic, assign) int begin_time;

/// 音高线持续时间
@property (nonatomic, assign) int duration;

/// 音高值
@property (nonatomic, assign) int value;


+ (instancetype _Nullable)pitchModelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
