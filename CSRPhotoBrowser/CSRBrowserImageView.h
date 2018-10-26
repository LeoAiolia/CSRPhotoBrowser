//
//  CSRBrowserImageView.h
//  CSRPhotoBrowser
//
//  Created by run on 2018-2-6.
//  Copyright (c) 2018年 LeoAiolia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSRBrowserImageView : UIImageView <UIGestureRecognizerDelegate>

@property(nonatomic, assign) CGFloat progress;
@property(nonatomic, assign, readonly) BOOL isScaled;
@property(nonatomic, assign) BOOL hasLoadedImage;

- (void)eliminateScale;  // 清除缩放

- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)placeholder;

- (void)doubleTapToZommWithScale:(CGFloat)scale;

- (void)clear;

@end
