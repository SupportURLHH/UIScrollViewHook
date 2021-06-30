//
//  UIScrollView+Swizzle.m
//  UIScrollViewHook
//
//  Created by 范庆宇 on 2021/6/7.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+Swizzle.h"
#import "UIScrollView+Category.h"
#import <objc/runtime.h>

static void Hook_Method(Class originalClass, SEL originalSel, Class replacedClass, SEL replacedSel, SEL noneSel) {
    // 原实例方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    if (!originalMethod) {
        Method noneMethod = class_getInstanceMethod(replacedClass, noneSel);
        BOOL addNoneMethod = class_addMethod(originalClass,
                                             originalSel, method_getImplementation(noneMethod), method_getTypeEncoding(noneMethod));
        if (addNoneMethod) {
            NSLog(@"******** 没有实现 (%@) 方法，手动添加成功！！",NSStringFromSelector(originalSel));
            
        }
        
    }else {
        // 向实现 delegate 的类中添加新的方法
        // 这里是向 originalClass 的 replaceSel（@selector(p_scrollViewDidEndDecelerating:)） 添加 replaceMethod
        BOOL addMethod = class_addMethod(originalClass, replacedSel, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod));
        if (addMethod) {
            // 添加成功
            NSLog(@"******** 实现了 (%@) 方法并成功 Hook 为 --> (%@)", NSStringFromSelector(originalSel), NSStringFromSelector(replacedSel));
            // 重新拿到添加被添加的 method,这里是关键(注意这里 originalClass, 不 replacedClass), 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
            Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
            // 实现交换
            method_exchangeImplementations(originalMethod, newMethod);
            
        }else{
            // 添加失败，则说明已经 hook 过该类的 delegate 方法，防止多次交换。
            NSLog(@"******** 已替换过，避免多次替换 --> (%@)",NSStringFromClass(originalClass));
            
        }
        
    }

}

Direction previousScrollDirection;
CGFloat previousOffsetY;

@implementation UIScrollView (Swizzle)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([UIScrollView class], @selector(setDelegate:));
        Method replaceMethod = class_getInstanceMethod([UIScrollView class], @selector(hook_setDelegate:));
        method_exchangeImplementations(originalMethod, replaceMethod);
        
    });
    
}

// Private Property
//- (UIPanGestureRecognizer *)fd_fullscreenPopGestureRecognizer
//{
//    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
//
//    if (!panGestureRecognizer) {
//        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
//        panGestureRecognizer.maximumNumberOfTouches = 1;
//
//        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return panGestureRecognizer;
//}


- (void)hook_setDelegate:(id<UIScrollViewDelegate>)delegate {
    
    if ([self isMemberOfClass:[UICollectionView class]] || [self isMemberOfClass:[UITableView class]] || [self isMemberOfClass:[UIScrollView class]]) {
        NSLog(@"是UIScrollView，hook方法");
        
        // Hook scrollViewDidScroll
        Hook_Method([delegate class],
                    @selector(scrollViewDidScroll:),
                    [self class],
                    @selector(p_scrollViewDidScroll:),
                    @selector(add_scrollViewDidScroll:)
                    );
        
        //Hook (scrollViewDidEndDecelerating:) 方法
        Hook_Method([delegate class],
                    @selector(scrollViewDidEndDecelerating:),
                    [self class],
                    @selector(p_scrollViewDidEndDecelerating:),
                    @selector(add_scrollViewDidEndDecelerating:)
                    );
        //Hook (scrollViewDidEndDragging:willDecelerate:) 方法
        Hook_Method([delegate class],
                    @selector(scrollViewDidEndDragging:willDecelerate:),
                    [self class],
                    @selector(p_scrollViewDidEndDragging:willDecelerate:),
                    @selector(add_scrollViewDidEndDragging:willDecelerate:)
                    );
        
    } else {
        NSLog(@"不是UIScrollView，不需要hook方法");
        
    }
    
    [self hook_setDelegate:delegate];
    
}

// 已经实现需要hook的代理方法时，调用此处方法进行替换
#pragma mark - Replace_Method
- (Direction)detectScrollDirection:(CGFloat)currentOffsetY andPreviousOffset:(CGFloat)previousOffsetY {
    if (currentOffsetY > previousOffsetY) {
        return UP;
        
    } else if (currentOffsetY < previousOffsetY) {
        return DOWN;
        
    } else {
        return NONE;
    }
    
}

// 向上滚动，且滚动距离大于已经设置的值，显示回到顶部按钮，其他时间隐藏
- (void)private_scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    Direction currentScrollDirection = [scrollView detectScrollDirection:currentOffsetY andPreviousOffset:previousOffsetY];
    CGFloat topBoundary = -scrollView.contentInset.top;
    CGFloat bottomBoundary = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    BOOL isOverTopBoundary = currentOffsetY <= topBoundary;
    BOOL isOverBottomBoundary = currentOffsetY >= bottomBoundary;
    
    BOOL isBouncing = (isOverTopBoundary && currentScrollDirection != DOWN) || (isOverBottomBoundary && currentScrollDirection != UP);
    
    if (isBouncing) {
        return;
    }
    switch (currentScrollDirection) {
        case 1:{
            if (self.scrollDirectionBlock) {
                self.scrollDirectionBlock(UP,scrollView.contentOffset);
            }
            
        }
            break;
        case 2:{
            if (self.scrollDirectionBlock) {
                self.scrollDirectionBlock(DOWN,scrollView.contentOffset);
            }
        }
            break;
            
        case 0:
            break;
    }
    previousScrollDirection = currentScrollDirection;
    previousOffsetY = currentOffsetY;
    
}

- (void)p_scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
    [self p_scrollViewDidScroll:scrollView];
    [scrollView private_scrollViewDidScroll:scrollView];
    
}

- (void)p_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //    NSLog(@"%s", __func__);
    [self p_scrollViewDidEndDecelerating:scrollView];
    // 停止类型1、停止类型2
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [scrollView stopScroll:scrollView];
    }
    
}

- (void)p_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //    NSLog(@"%s", __func__);
    [self p_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (!decelerate) {
        // 停止类型3
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [scrollView stopScroll:scrollView];
        }
    }
    
}

// 那没有实现需要hook的代理方法时，调用此处方法
#pragma mark - Add_Method

- (void)add_scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
    [scrollView private_scrollViewDidScroll:scrollView];
    
}

- (void)add_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //    NSLog(@"%s", __func__);
    // 停止类型1、停止类型2
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [scrollView stopScroll:scrollView];
    }
    
}

- (void)add_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //    NSLog(@"%s", __func__);
//    [self add_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (!decelerate) {
        // 停止类型3
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [scrollView stopScroll:scrollView];
        }
    }
    
}

#pragma mark - scrollView 滚动停止时触发的方法
- (void)stopScroll:(UIScrollView *)scrollView {
    //    NSLog(@"滚动已停止");
    if (self.stopScrollBlock) {
        self.stopScrollBlock(scrollView);
    }
    
}




@end
