//
//  CSRPhotoBrowserConfig.h
//  CSRPhotoBrowser
//
//  Created by run on 2018-2-9.
//  Copyright (c) 2018年 LeoAiolia. All rights reserved.
//
#pragma mark - common define -
// 带刘海的手机系列
#define CSR_IPHONE_BANG \
  (CSR_IPHONE_X || CSR_IPHONE_XR || CSR_IPHONE_XS || CSR_IPHONE_XS_MAX)

#define CSR_IPHONEX_TABBAR_ADD_HEIGHT (CSR_IPHONE_BANG ? 34.0 : 0)

#define CSR_STATUSBAR_HEIGHT (CSR_IPHONE_BANG ? 44 : 20)

// 手机设备
#define CSR_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

// 判断iPhoneX
#define CSR_IPHONE_X                                                    \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]         \
       ? CGSizeEqualToSize(CGSizeMake(1125, 2436),                      \
                           [[UIScreen mainScreen] currentMode].size) && \
             CSR_IPHONE                                                 \
       : NO)

// 判断iPHoneXr
#define CSR_IPHONE_XR                                                   \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]         \
       ? CGSizeEqualToSize(CGSizeMake(828, 1792),                       \
                           [[UIScreen mainScreen] currentMode].size) && \
             CSR_IPHONE                                                 \
       : NO)

// 判断iPhoneXs
#define CSR_IPHONE_XS                                                   \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]         \
       ? CGSizeEqualToSize(CGSizeMake(1125, 2436),                      \
                           [[UIScreen mainScreen] currentMode].size) && \
             CSR_IPHONE                                                 \
       : NO)

// 判断iPhoneXs Max
#define CSR_IPHONE_XS_MAX                                               \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]         \
       ? CGSizeEqualToSize(CGSizeMake(1242, 2688),                      \
                           [[UIScreen mainScreen] currentMode].size) && \
             CSR_IPHONE                                                 \
       : NO)

#pragma mark - config -

// 图片保存成功提示文字
#define CSRPhotoBrowserSaveImageSuccessText @"保存成功";

// 图片保存失败提示文字
#define CSRPhotoBrowserSaveImageFailText @"保存失败";

// browser背景颜色
#define CSRPhotoBrowserBackgrounColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]

// browser中图片间的margin
#define CSRPhotoBrowserImageViewMargin 10

// browser中显示图片动画时长
#define CSRPhotoBrowserShowImageAnimationDuration 0.4f

// browser中显示图片动画时长
#define CSRPhotoBrowserHideImageAnimationDuration 0.4f

