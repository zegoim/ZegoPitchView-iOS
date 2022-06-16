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

/**
 * 音高线开始时间
 */
@property (nonatomic, assign) int begin_time;

/**
 * 音高线持续时间
 */
@property (nonatomic, assign) int duration;

/**
 * 音高值
 */
@property (nonatomic, assign) int value;

/**
 * 将音高线原始数据转为控件数据模型.
 * 歌曲资源类型为高潮片段请使用这个方法，其他歌曲类型请使用 +[ZegoPitchModel analyzePitchData:] 方法.
 *
 * @param json 从 ZegoExpressSDK 的 -[ZegoCopyrightedMusic getStandardPitch: callback:] 方法回调中获取的音高线原始数据.
 * @param beginTime 需要截断音高线数据的开始时间. 例: 对于高潮片段资源来说为 segBegin + preludeDuration.
 * @param endTime 需要截断音高线数据的结束时间. 例: 对于高潮片段资源来说是 segEnd.
 * @param krcFormatOffset 歌词数据 Model 中的 krcFormatOffset
 *
 * @return 音高线数据模型数组, 可通过 -[ZegoPitchView setStandardPitchModels:] 设置音高线 UI 控件的标准音高线.
 */
+ (NSArray<ZegoPitchModel *> *)analyzePitchData:(id)json
                                      beginTime:(NSInteger)beginTime
                                        endTime:(NSInteger)endTime
                                krcFormatOffset:(NSInteger)krcFormatOffset;

/**
 * 将音高线原始数据转为控件数据模型.
 * 歌曲资源类型为非高潮片段的请使用这个方法，歌曲为高潮片段类型请使用 +[ZegoPitchModel analyzePitchData: krcFormatOffset:] 方法.
 *
 * @param json 从 ZegoExpressSDK 的 -[ZegoCopyrightedMusic getStandardPitch: callback:] 方法回调中获取的音高线原始数据.
 *
 * @return 音高线数据模型数组, 可通过 -[ZegoPitchView setStandardPitchModels:] 设置音高线 UI 控件的标准音高线.
 */
+ (NSArray<ZegoPitchModel *> *)analyzePitchData:(id)json;

@end

NS_ASSUME_NONNULL_END
