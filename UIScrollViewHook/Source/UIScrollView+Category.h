//
//  UIScrollView+Category.h
//  UIScrollViewHook
//
//  Created by 范庆宇 on 2021/6/7.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "UIScrollView+Swizzle.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^ StopScrollBlock)(UIScrollView *scrollView);

typedef void(^ ScrollDirectionBlock)(Direction direction, CGPoint currentOffSet);

@interface UIScrollView (Category)

@property(nonatomic, copy) StopScrollBlock stopScrollBlock;

@property(nonatomic, copy) ScrollDirectionBlock scrollDirectionBlock;

- (void)custom_scrollToTop;

// 向上滚动，且滚动距离大于已经设置的值，显示回到顶部按钮，其他时间隐藏

@end

NS_ASSUME_NONNULL_END
