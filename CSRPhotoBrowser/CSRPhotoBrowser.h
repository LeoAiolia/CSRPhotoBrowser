//
//  CSRPhotoBrowser.h
//  photobrowser
//
//  Created by run on 2018-2-3.
//  Copyright (c) 2018年 run. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSRPhotoBrowser;

@protocol CSRPhotoBrowserDelegate <NSObject>

@required

- (UIImage*)photoBrowser:(CSRPhotoBrowser*)browser
    placeholderImageForIndex:(NSInteger)index;

@optional

- (NSURL*)photoBrowser:(CSRPhotoBrowser*)browser
    highQualityImageURLForIndex:(NSInteger)index;

@end

@interface CSRPhotoBrowser : UIView <UIScrollViewDelegate>

@property(nonatomic, weak) UIView* sourceImagesContainerView;  // 父视图
@property(nonatomic, weak) UIView* origionImageView;  // 原imageView

@property(nonatomic, assign) NSInteger currentImageIndex;
@property(nonatomic, assign) NSInteger imageCount;

@property(nonatomic, weak) id<CSRPhotoBrowserDelegate> delegate;

- (void)show;

@end
