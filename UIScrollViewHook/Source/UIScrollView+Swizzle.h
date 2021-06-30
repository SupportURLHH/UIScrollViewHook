//
//  UIScrollView+Swizzle.h
//  UIScrollViewHook
//
//  Created by 范庆宇 on 2021/6/7.
//



NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,Direction){
    NONE = 0,
    UP = 1,
    DOWN = 2,
};

@interface UIScrollView (Swizzle)

//public var upThresholdY: CGFloat = 0.0
//public var downThresholdY: CGFloat = 0.0
//private var previousScrollDirection: Direction = .None
//private var previousOffsetY: CGFloat = 0.0
//private var accumulatedY: CGFloat = 0.0



@end

NS_ASSUME_NONNULL_END
