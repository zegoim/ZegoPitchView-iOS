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
@property (nonatomic, assign) NSInteger begin_time;

/**
 * 音高线持续时间
 */
@property (nonatomic, assign) NSInteger duration;

/**
 * 音高值
 */
@property (nonatomic, assign) int value;

/**
 * 将音高线原始数据转为控件数据模型.
 * 歌曲资源类型为非高潮片段的请使用这个方法，歌曲为高潮片段类型请使用 +[ZegoPitchModel analyzeAccompanimentClipPitchData: segmentBegin: segmentEnd: preludeDuration: krcFormatOffset:] 方法.
 *
 * @param json 从 ZegoExpressSDK 的 -[ZegoCopyrightedMusic getStandardPitch: callback:] 方法回调中获取的音高线原始数据.
 *
 * @return 音高线数据模型数组, 可通过 -[ZegoPitchView setStandardPitchModels:] 设置音高线 UI 控件的标准音高线.
 */
+ (NSArray<ZegoPitchModel *> *)analyzePitchData:(id)json;

/**
 * 将音高线原始数据转为控件数据模型.
 * 根据 beginTime 和 endTime 对音高线进行截断
 *
 * @param json 从 ZegoExpressSDK 的 -[ZegoCopyrightedMusic getStandardPitch: callback:] 方法回调中获取的音高线原始数据.
 * @param beginTime 需要截断音高线数据的开始时间.
 * @param endTime 需要截断音高线数据的结束时间.
 *
 * @return 音高线数据模型数组, 可通过 -[ZegoPitchView setStandardPitchModels:] 设置音高线 UI 控件的标准音高线.
 */
+ (NSArray<ZegoPitchModel *> *)analyzePitchData:(id)json
                                      beginTime:(NSInteger)beginTime
                                        endTime:(NSInteger)endTime;

/**
 * 将高潮片段资源对应的音高线原始数据转为控件数据模型.
 *
 * @param json 从 ZegoExpressSDK 的 -[ZegoCopyrightedMusic getStandardPitch: callback:] 方法回调中获取的音高线原始数据.
 * @param segmentBegin 高潮片段开始时间（该字段在请求高潮片段资源时返回）
 * @param segmentEnd 高潮片段结束时间（该字段在请求高潮片段资源时返回）
 * @param preludeDuration 高潮片段前奏时间（该字段在请求高潮片段资源时返回）
 * @param krcFormatOffset krc歌词对歌曲的偏移量（该字段在 krc 歌词模型数据中获取）
 */
+ (NSArray<ZegoPitchModel *> *)analyzeAccompanimentClipPitchData:(id)json
                                                    segmentBegin:(NSInteger)segmentBegin
                                                      segmentEnd:(NSInteger)segmentEnd
                                                 preludeDuration:(NSInteger)preludeDuration
                                                 krcFormatOffset:(NSInteger)krcFormatOffset;

@end

NS_ASSUME_NONNULL_END
