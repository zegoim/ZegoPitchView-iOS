//
//  ZegoPitchView.h
//  GoChat
//
//  Created by Vic on 2021/11/24.
//  Copyright © 2021 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoPitchModel.h"
#import "ZegoPitchViewConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 打分控件 view
 */
@interface ZegoPitchView : UIView

/**
 * 打分控件基本设置
 * @param config 如果传入为 nil, 则会使用 defaultConfig
 */
- (void)setConfig:(ZegoPitchViewConfig *)config;

/**
 * 设置打分控件的标准音高线模型数组, 默认不过滤
 * @param standardPitchModels 标准音高线模型数组
 */
- (void)setStandardPitchModels:(NSArray<ZegoPitchModel *> * _Nullable)standardPitchModels;

/**
 * 获取标准音高线的开始时间
 * 例: 在有音高线之前, 不需要显示音高线的得分情况
 * @return 音高线开始对应歌曲进度
 */
- (int)getPitchStartTime;

/**
 * 设置当前歌曲播放进度及音高值, 控件会在这个方法中更新标准音高线及击中音高线的绘制
 * @param progress 歌曲播放进度
 * @param pitch 音高值
 */
- (void)setCurrentSongProgress:(int)progress pitch:(int)pitch;

/**
 * 设置唱歌分数并展示, 推荐在每句歌词唱完之后调用
 * @param score 唱歌分数
 */
- (void)addScore:(int)score;

/**
 * 重置打分控件内部状态
 * 一般在一首歌曲结束后, 下一首歌曲开始前调用
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
