//
//  ZegoPitchCanvas.h
//  GoChat
//
//  Created by Vic on 2021/11/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoPitchModel.h"
#import "ZegoPitchViewConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZegoPitchCanvasProtocol <NSObject>

- (void)updatePitchIndicatorPositionWithEndPoint:(CGPoint)endPoint;

@end

@interface ZegoPitchCanvas : UIView

@property (nonatomic, weak) id<ZegoPitchCanvasProtocol> delegate;

- (void)setConfig:(ZegoPitchViewConfig *)config;

- (void)drawWithProgress:(int)progress
          stdPitchModels:(NSArray<ZegoPitchModel *> *)stdPitchModels
          hitPitchModels:(NSArray<ZegoPitchModel *> *)hitPitchModels
                   pitch:(int)pitch;

- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
