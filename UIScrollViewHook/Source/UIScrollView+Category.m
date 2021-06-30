//
//  UIScrollView+Category.m
//  UIScrollViewHook
//
//  Created by 范庆宇 on 2021/6/7.
//

#import "UIScrollView+Category.h"


@implementation UIScrollView (Category)

static const char *p_stopScrollBlock;

static const char *p_scrollDirectionBlock;


- (StopScrollBlock)stopScrollBlock {
    return objc_getAssociatedObject(self, &p_stopScrollBlock);
}
 
- (void)setStopScrollBlock:(StopScrollBlock)stopScrollBlock {
    objc_setAssociatedObject(self, &p_stopScrollBlock, stopScrollBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ScrollDirectionBlock)scrollDirectionBlock {
    return objc_getAssociatedObject(self, &p_scrollDirectionBlock);
}

- (void)setScrollDirectionBlock:(ScrollDirectionBlock)scrollDirectionBlock {
    objc_setAssociatedObject(self, &p_scrollDirectionBlock, scrollDirectionBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}


- (void)custom_scrollToTop {
    [self setContentOffset:CGPointZero];
}

@end
