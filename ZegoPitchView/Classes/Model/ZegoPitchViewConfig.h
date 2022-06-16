//
//  ZegoPitchViewConfig.h
//  GoChat
//
//  Created by Vic on 2021/11/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoPitchViewConfig : NSObject

/**
 * 音高等级数
 * 默认配置 20
 * 不建议修改
 */
@property (nonatomic, assign) int pitchNum;

/**
 * 最大音高值
 * 默认配置 90
 * 不建议修改
 */
@property (nonatomic, assign) int maxPitch;

/**
 * 最小音高值
 * 默认配置 10
 * 不建议修改
 */
@property (nonatomic, assign) int minPitch;

/**
 * 控件开始至竖线这一段表示的时间, 单位 ms
 * 默认配置 1175
 * 不建议修改
 */
@property (nonatomic, assign) int timeElapsedOnScreen;

/**
 * 竖线至控件末尾这一段表示的时间, 单位 ms
 * 默认配置 2750
 * 不建议修改
 */
@property (nonatomic, assign) int timeToPlayOnScreen;

/**
 * 调用 [ZegoPitchView setCurrentSongProgress: pitch:] 方法的大致时间间隔, 单位 ms
 */
@property (nonatomic, assign) CGFloat estimatedCallInterval;

#pragma mark - Colors

/**
 * 背景颜色
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 * 五线谱横线颜色
 */
@property (nonatomic, strong) UIColor *staffColor;

/**
 * 竖线颜色
 */
@property (nonatomic, strong) UIColor *verticalLineColor;

/**
 * 标准音调颜色
 */
@property (nonatomic, strong) UIColor *standardRectColor;

/**
 * 击中音调颜色
 */
@property (nonatomic, strong) UIColor *hitRectColor;

/**
 * 音调指示器颜色
 */
@property (nonatomic, strong) UIColor *pitchIndicatorColor;

/**
 * 分数文本颜色
 */
@property (nonatomic, strong) UIColor *scoreTextColor;

/**
 * 默认配置
 */
+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
