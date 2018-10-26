//
//  CSRBrowserImageView.m
//  CSRPhotoBrowser
//
//  Created by run on 2018-2-6.
//  Copyright (c) 2018年 LeoAiolia. All rights reserved.
//

#import "CSRBrowserImageView.h"
#import "CSRPhotoBrowserConfig.h"
#import "UIImageView+WebCache.h"

@implementation CSRBrowserImageView {
  BOOL _didCheckSize;
  UIScrollView* _scroll;
  UIImageView* _scrollImageView;
  UIScrollView* _zoomingScroolView;
  UIImageView* _zoomingImageView;
  CGFloat _totalScale;
  UIActivityIndicatorView* _indicator;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.userInteractionEnabled = YES;
    self.contentMode = UIViewContentModeScaleAspectFit;
    _totalScale = 1.0;

    // 捏合手势缩放图片
    UIPinchGestureRecognizer* pinch =
        [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(zoomImage:)];
    pinch.delegate = self;
    [self addGestureRecognizer:pinch];
  }
  return self;
}

- (BOOL)isScaled {
  return 1.0 != _totalScale;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGSize imageSize = self.image.size;

  if (self.bounds.size.width * (imageSize.height / imageSize.width) >
      self.bounds.size.height) {
    if (!_scroll) {
      UIScrollView* scroll = [[UIScrollView alloc] init];
      scroll.backgroundColor = [UIColor whiteColor];
      UIImageView* imageView = [[UIImageView alloc] init];
      imageView.image = self.image;
      _scrollImageView = imageView;
      [scroll addSubview:imageView];
      scroll.backgroundColor = CSRPhotoBrowserBackgrounColor;
      _scroll = scroll;
      [self addSubview:scroll];
    }
    _scroll.frame = self.bounds;

    CGFloat imageViewH =
        self.bounds.size.width * (imageSize.height / imageSize.width);

    _scrollImageView.bounds =
        CGRectMake(0, 0, _scroll.frame.size.width, imageViewH);
    _scrollImageView.center =
        CGPointMake(_scroll.frame.size.width * 0.5,
                    _scrollImageView.frame.size.height * 0.5);
    _scroll.contentSize = CGSizeMake(0, _scrollImageView.bounds.size.height);

  } else {
    if (_scroll)
      [_scroll removeFromSuperview];  // 防止旋转时适配的scrollView的影响
  }

  if (_indicator.superview) {
    _indicator.center = self.center;
  }
}

- (void)setProgress:(CGFloat)progress {
  _progress = progress;
  //    _waitingView.progress = progress;
}

- (void)setImageWithURL:(NSURL*)url placeholderImage:(UIImage*)placeholder {
  if (_indicator == nil) {
    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.activityIndicatorViewStyle =
        UIActivityIndicatorViewStyleWhiteLarge;
    _indicator.center = self.center;
  }
  [self addSubview:_indicator];
  [_indicator startAnimating];

  __weak CSRBrowserImageView* wSelf = self;
  [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
    wSelf.progress = (CGFloat)receivedSize / expectedSize;
  } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    [self->_indicator removeFromSuperview];
    if (error) {
      self->_scrollImageView.image = [UIImage imageNamed:@"squareDefaultIcon"];
    } else {
      self->_scrollImageView.image = image;
    }
    [self->_scrollImageView setNeedsDisplay];
  }];
}

- (void)zoomImage:(UIPinchGestureRecognizer*)recognizer {
  [self prepareForImageViewScaling];
  CGFloat scale = recognizer.scale;
  CGFloat temp = _totalScale + (scale - 1);
  [self setTotalScale:temp];
  recognizer.scale = 1.0;
}

- (void)setTotalScale:(CGFloat)totalScale {
  if ((_totalScale < 0.5 && totalScale < _totalScale) ||
      (_totalScale > 2.0 && totalScale > _totalScale))
    return;  // 最大缩放 2倍,最小0.5倍

  [self zoomWithScale:totalScale];
}

- (void)zoomWithScale:(CGFloat)scale {
  _totalScale = scale;

  _zoomingImageView.transform = CGAffineTransformMakeScale(scale, scale);

  if (scale > 1) {
    CGFloat contentW = _zoomingImageView.frame.size.width;
    CGFloat contentH =
        MAX(_zoomingImageView.frame.size.height, self.frame.size.height);

    _zoomingImageView.center = CGPointMake(contentW * 0.5, contentH * 0.5);
    _zoomingScroolView.contentSize = CGSizeMake(contentW, contentH);

    CGPoint offset = _zoomingScroolView.contentOffset;
    offset.x = (contentW - _zoomingScroolView.frame.size.width) * 0.5;
    _zoomingScroolView.contentOffset = offset;

  } else {
    _zoomingScroolView.contentSize = _zoomingScroolView.frame.size;
    _zoomingScroolView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _zoomingImageView.center = _zoomingScroolView.center;
  }
}

- (void)doubleTapToZommWithScale:(CGFloat)scale {
  [self prepareForImageViewScaling];
  [UIView animateWithDuration:0.5
      animations:^{
        [self zoomWithScale:scale];
      }
      completion:^(BOOL finished) {
        if (scale == 1) {
          [self clear];
        }
      }];
}

- (void)prepareForImageViewScaling {
  if (!_zoomingScroolView) {
    _zoomingScroolView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _zoomingScroolView.backgroundColor = CSRPhotoBrowserBackgrounColor;
    _zoomingScroolView.contentSize = self.bounds.size;
    UIImageView* zoomingImageView =
        [[UIImageView alloc] initWithImage:self.image];
    CGSize imageSize = zoomingImageView.image.size;
    CGFloat imageViewH = self.bounds.size.height;
    if (imageSize.width > 0) {
      imageViewH =
          self.bounds.size.width * (imageSize.height / imageSize.width);
    }
    zoomingImageView.bounds =
        CGRectMake(0, 0, self.bounds.size.width, imageViewH);
    zoomingImageView.center = _zoomingScroolView.center;
    zoomingImageView.contentMode = UIViewContentModeScaleAspectFit;
    _zoomingImageView = zoomingImageView;
    [_zoomingScroolView addSubview:zoomingImageView];
    [self addSubview:_zoomingScroolView];
  }
}

- (void)scaleImage:(CGFloat)scale {
  [self prepareForImageViewScaling];
  [self setTotalScale:scale];
}

// 清除缩放
- (void)eliminateScale {
  [self clear];
  _totalScale = 1.0;
}

- (void)clear {
  [_zoomingScroolView removeFromSuperview];
  _zoomingScroolView = nil;
  _zoomingImageView = nil;
}

@end
