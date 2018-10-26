//
//  ViewController.m
//  CSRPhotoBrowser
//
//  Created by run on 2018/10/26.
//  Copyright © 2018 run. All rights reserved.
//

#import "ViewController.h"
#import "CSRPhotoBrowser.h"

@interface ViewController () <CSRPhotoBrowserDelegate>

@property(nonatomic, strong) NSArray* dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _dataArr = @[@"",@"",@"",@""];
  
}

- (void)buttonClick:(id)sender {
  CSRPhotoBrowser* browser = [[CSRPhotoBrowser alloc] init];
  browser.sourceImagesContainerView = self.view;  // 原图的父控件
  browser.origionImageView = sender;
  browser.imageCount = 4;  // 图片总数
  browser.currentImageIndex = 2;
  browser.delegate = self;
  [browser show];
}

// 返回临时占位图片（即原来的小图）
- (UIImage*)photoBrowser:(CSRPhotoBrowser*)browser placeholderImageForIndex:(NSInteger)index {
  /*
  if (!(_friendInfoHeaderModel.pictures.count > index)) {
    return [UIImage imageNamed:@"squareDefaultIcon"];
  }
  ISEditingCoverModel* coverModel = _friendInfoHeaderModel.pictures[index];
  if (coverModel.image) {
    return coverModel.image;
  } else {
    return [UIImage imageNamed:@"squareDefaultIcon"];
  }
  */
  
  return [UIImage imageNamed:@"squareDefaultIcon"];
}

// 返回高质量图片的url
- (NSURL*)photoBrowser:(CSRPhotoBrowser*)browser highQualityImageURLForIndex:(NSInteger)index {
  /*
  if (!(_friendInfoHeaderModel.pictures.count > index)) {
    return [NSURL URLWithString:@""];
  }
  ISEditingCoverModel* coverModel = _friendInfoHeaderModel.pictures[index];
  return coverModel.imageURL;
  */
  return nil;
}

@end
