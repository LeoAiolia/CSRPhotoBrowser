//
//  CSRPhotoBrowser.m
//  photobrowser
//
//  Created by run on 2018-2-3.
//  Copyright (c) 2018年 run. All rights reserved.
//

#import "CSRPhotoBrowser.h"
#import "CSRBrowserImageView.h"
#import "CSRPhotoBrowserConfig.h"
#import "ISActionSheet.h"

@implementation CSRPhotoBrowser {
  UIScrollView* _scrollView;
  BOOL _hasShowedFistView;
  UILabel* _indexLabel;
  //    UIButton *_saveButton;
  UIActivityIndicatorView* _indicatorView;
  BOOL _willDisappear;
  NSInteger _origionIndex;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = CSRPhotoBrowserBackgrounColor;
    _origionIndex = 0;
  }
  return self;
}

- (void)setCurrentImageIndex:(NSInteger)currentImageIndex {
  _currentImageIndex = currentImageIndex;
  _origionIndex = currentImageIndex;
}

- (void)didMoveToSuperview {
  [self setupScrollView];

  [self setupToolbars];
}

- (void)dealloc {
  [[UIApplication sharedApplication].keyWindow removeObserver:self
                                                   forKeyPath:@"frame"];
}

- (void)setupToolbars {
  // 1. 序标
  UILabel* indexLabel = [[UILabel alloc] init];
  indexLabel.bounds = CGRectMake(0, 0, 80, 30);
  indexLabel.textAlignment = NSTextAlignmentCenter;
  indexLabel.textColor = [UIColor whiteColor];
  indexLabel.font = [UIFont boldSystemFontOfSize:20];

  indexLabel.layer.cornerRadius = indexLabel.bounds.size.height * 0.5;
  indexLabel.clipsToBounds = YES;
  if (self.imageCount > 1) {
    indexLabel.backgroundColor =
        [[UIColor blackColor] colorWithAlphaComponent:0.5];
    indexLabel.text =
        [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
  }
  _indexLabel = indexLabel;
  [self addSubview:indexLabel];

  // 2.保存按钮
  //    UIButton *saveButton = [[UIButton alloc] init];
  //    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
  //    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  //    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
  //    saveButton.layer.cornerRadius = 5;
  //    saveButton.clipsToBounds = YES;
  //    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
  //    _saveButton = saveButton;
  //    [self addSubview:saveButton];
}

- (void)saveImage {
  int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
  UIImageView* currentImageView = _scrollView.subviews[index];

  UIImageWriteToSavedPhotosAlbum(
      currentImageView.image, self,
      @selector(image:didFinishSavingWithError:contextInfo:), NULL);

  UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] init];
  indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  indicator.center = self.center;
  _indicatorView = indicator;
  [[UIApplication sharedApplication].keyWindow addSubview:indicator];
  [indicator startAnimating];
}

- (void)image:(UIImage*)image
    didFinishSavingWithError:(NSError*)error
                 contextInfo:(void*)contextInfo;
{
  [_indicatorView removeFromSuperview];

  UILabel* label = [[UILabel alloc] init];
  label.textColor = [UIColor whiteColor];
  label.backgroundColor =
      [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
  label.layer.cornerRadius = 5;
  label.clipsToBounds = YES;
  label.bounds = CGRectMake(0, 0, 150, 30);
  label.center = self.center;
  label.textAlignment = NSTextAlignmentCenter;
  label.font = [UIFont boldSystemFontOfSize:17];
  [[UIApplication sharedApplication].keyWindow addSubview:label];
  [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
  if (error) {
    label.text = CSRPhotoBrowserSaveImageFailText;
  } else {
    label.text = CSRPhotoBrowserSaveImageSuccessText;
  }
  [label performSelector:@selector(removeFromSuperview)
              withObject:nil
              afterDelay:1.0];
}

- (void)setupScrollView {
  _scrollView = [[UIScrollView alloc] init];
  _scrollView.delegate = self;
  _scrollView.showsHorizontalScrollIndicator = NO;
  _scrollView.showsVerticalScrollIndicator = NO;
  _scrollView.pagingEnabled = YES;
  [self addSubview:_scrollView];

  for (int i = 0; i < self.imageCount; i++) {
    CSRBrowserImageView* imageView = [[CSRBrowserImageView alloc] init];
    imageView.tag = i;

    // 单击图片
    UITapGestureRecognizer* singleTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(photoClick:)];

    // 双击放大图片
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(imageViewDoubleTaped:)];
    doubleTap.numberOfTapsRequired = 2;

    [singleTap requireGestureRecognizerToFail:doubleTap];

    [imageView addGestureRecognizer:singleTap];
    [imageView addGestureRecognizer:doubleTap];

    UILongPressGestureRecognizer* longPress =
        [[UILongPressGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(showSaveImageActionSheet:)];
    longPress.minimumPressDuration = 0.65;
    longPress.cancelsTouchesInView = NO;
    [imageView addGestureRecognizer:longPress];

    [_scrollView addSubview:imageView];
  }

  [self setupImageOfImageViewForIndex:self.currentImageIndex];
}

- (void)showSaveImageActionSheet:(UILongPressGestureRecognizer*)press {
  if (press.state == UIGestureRecognizerStateBegan) {
    // 展示保存图片的弹框
    NSArray* dataArr = @[ @"保存到相册" ];
    ISActionSheet* action = [ISActionSheet
        actionSheetWithStyle:ISActionSheetStyleWeChat
                       title:nil
                  optionsArr:dataArr
                 cancelTitle:@"取消"
               selectedBlock:^(NSInteger row, NSString* _Nonnull title) {
                 [self saveImage];
               }
                 cancelBlock:^{
                 }];
    [action showInView:self];
  }
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index {
  CSRBrowserImageView* imageView = _scrollView.subviews[index];
  _currentImageIndex = index;
  if (imageView.hasLoadedImage) return;
  if ([self highQualityImageURLForIndex:index]) {
    [imageView setImageWithURL:[self highQualityImageURLForIndex:index]
              placeholderImage:[self placeholderImageForIndex:index]];
  } else {
    imageView.image = [self placeholderImageForIndex:index];
  }
  imageView.hasLoadedImage = YES;
}

- (void)photoClick:(UITapGestureRecognizer*)recognizer {
  _scrollView.hidden = YES;
  _willDisappear = YES;

  CSRBrowserImageView* currentImageView = (CSRBrowserImageView*)recognizer.view;
  NSInteger currentIndex = currentImageView.tag;

  if (currentIndex != _origionIndex) {
    [UIView animateWithDuration:CSRPhotoBrowserHideImageAnimationDuration
        animations:^{
          self.alpha = 0.1;
          self->_indexLabel.alpha = 0.1;
        }
        completion:^(BOOL finished) {
          [self removeFromSuperview];
        }];
    return;
  }

  UIView* sourceView = self.origionImageView;

  CGRect targetTemp =
      [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];

  UIImageView* tempView = [[UIImageView alloc] init];
  tempView.contentMode = sourceView.contentMode;
  tempView.clipsToBounds = YES;
  tempView.image = currentImageView.image;
  CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) *
              currentImageView.image.size.height;

  if (!currentImageView.image) {  // 防止 因imageview的image加载失败 导致 崩溃
    h = self.bounds.size.height;
  }

  tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
  tempView.center = self.center;

  [self addSubview:tempView];

  //    _saveButton.hidden = YES;

  [UIView animateWithDuration:CSRPhotoBrowserHideImageAnimationDuration
      animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
        self->_indexLabel.alpha = 0.1;
      }
      completion:^(BOOL finished) {
        [self removeFromSuperview];
      }];
}

- (void)imageViewDoubleTaped:(UITapGestureRecognizer*)recognizer {
  CSRBrowserImageView* imageView = (CSRBrowserImageView*)recognizer.view;
  CGFloat scale;
  if (imageView.isScaled) {
    scale = 1.0;
  } else {
    scale = 2.0;
  }

  CSRBrowserImageView* view = (CSRBrowserImageView*)recognizer.view;

  [view doubleTapToZommWithScale:scale];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect rect = self.bounds;
  rect.size.width += CSRPhotoBrowserImageViewMargin * 2;

  _scrollView.bounds = rect;
  _scrollView.center = self.center;

  CGFloat y = 0;
  CGFloat w = _scrollView.frame.size.width - CSRPhotoBrowserImageViewMargin * 2;
  CGFloat h = _scrollView.frame.size.height;

  [_scrollView.subviews
      enumerateObjectsUsingBlock:^(CSRBrowserImageView* obj, NSUInteger idx,
                                   BOOL* stop) {
        CGFloat x = CSRPhotoBrowserImageViewMargin +
                    idx * (CSRPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
      }];

  _scrollView.contentSize =
      CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
  _scrollView.contentOffset =
      CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);

  if (!_hasShowedFistView) {
    [self showFirstImage];
  }

  _indexLabel.center =
      CGPointMake(self.bounds.size.width * 0.5, 15 + CSR_STATUSBAR_HEIGHT);
  //    _saveButton.frame = CGRectMake(30, self.bounds.size.height - 70, 50, 25);
}

- (void)show {
  UIWindow* window = [UIApplication sharedApplication].keyWindow;
  self.frame = window.bounds;
  [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
  [window addSubview:self];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(UIView*)object
                        change:(NSDictionary*)change
                       context:(void*)context {
  if ([keyPath isEqualToString:@"frame"]) {
    self.frame = object.bounds;
    CSRBrowserImageView* currentImageView =
        _scrollView.subviews[_currentImageIndex];
    if ([currentImageView isKindOfClass:[CSRBrowserImageView class]]) {
      [currentImageView clear];
    }
  }
}

- (void)showFirstImage {
  UIView* sourceView = self.origionImageView;

  CGRect rect =
      [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];

  UIImageView* tempView = [[UIImageView alloc] init];
  tempView.image = [self placeholderImageForIndex:self.currentImageIndex];

  [self addSubview:tempView];

  CGRect targetTemp = [_scrollView.subviews[self.currentImageIndex] bounds];

  tempView.frame = rect;
  tempView.contentMode =
      [_scrollView.subviews[self.currentImageIndex] contentMode];
  _scrollView.hidden = YES;

  [UIView animateWithDuration:CSRPhotoBrowserShowImageAnimationDuration
      animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
      }
      completion:^(BOOL finished) {
        self->_hasShowedFistView = YES;
        [tempView removeFromSuperview];
        self->_scrollView.hidden = NO;
      }];
}

- (UIImage*)placeholderImageForIndex:(NSInteger)index {
  if ([self.delegate respondsToSelector:@selector
                     (photoBrowser:placeholderImageForIndex:)]) {
    return [self.delegate photoBrowser:self placeholderImageForIndex:index];
  }
  return nil;
}

- (NSURL*)highQualityImageURLForIndex:(NSInteger)index {
  if ([self.delegate respondsToSelector:@selector
                     (photoBrowser:highQualityImageURLForIndex:)]) {
    return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
  }
  return nil;
}

#pragma mark - scrollview代理方法

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  int index =
      (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) /
      _scrollView.bounds.size.width;

  // 有过缩放的图片在拖动一定距离后清除缩放
  CGFloat margin = 150;
  CGFloat x = scrollView.contentOffset.x;
  if ((x - index * self.bounds.size.width) > margin ||
      (x - index * self.bounds.size.width) < -margin) {
    CSRBrowserImageView* imageView = _scrollView.subviews[index];
    if (imageView.isScaled) {
      [UIView animateWithDuration:0.5
          animations:^{
            imageView.transform = CGAffineTransformIdentity;
          }
          completion:^(BOOL finished) {
            [imageView eliminateScale];
          }];
    }
  }

  if (!_willDisappear) {
    _indexLabel.text =
        [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
  }
  [self setupImageOfImageViewForIndex:index];
}

@end
