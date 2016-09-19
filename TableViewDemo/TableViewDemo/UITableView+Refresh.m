//
//  UITableView+Refresh.m
//  Haoshiqi
//
//  Created by 朱李宏 on 15/11/24.
//  Copyright © 2015年 haoshiqi. All rights reserved.
//

#import "UITableView+Refresh.h"
#import "NSObject+KVOBlock.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, kUITableViewRefreshStatus) {
    kUITableViewRefreshStatusNormal,
    kUITableViewRefreshStatusTriggering,
    kUITableViewRefreshStatusTriggered,
};
typedef void(^kUITableViewRefreshBlock)(void);

@interface UITableView()

@property (nonatomic, assign) BOOL isTableViewAddTopEdge;
@property (nonatomic, assign) kUITableViewRefreshStatus tableViewRefreshStatus;
@property (nonatomic, strong) kUITableViewRefreshBlock tableViewRefreshBlock;

@end

@implementation UITableView (Refresh)

- (void)addRefreshTriggerBlock:(void(^)(void))block
{
    self.tableViewRefreshBlock = block;
    [self addSubViewWithTableViewRefreshView:self.tableViewRefreshView];
    [self observeKeyPath:@"contentOffset" withBlock:^(__weak UITableView *self, id old, id newVal) {
        [self checkContentOffset:self.contentOffset];
    }];
}

- (void)endRefresh
{
    [self.tableViewRefreshView endRefreshStatus];
    [UIView animateWithDuration:0.2 animations:^{
        [self resetTopEdge];
        self.contentOffset = CGPointMake(0, - self.contentInset.top);
    }completion:^(BOOL finished) {
        self.tableViewRefreshStatus = kUITableViewRefreshStatusNormal;
    }];
}

- (void)trigerRefresh
{
    [self startTriggerRefreshing];
}

#pragma mark Private action

- (void)checkContentOffset:(CGPoint)contentOffset
{
    if (self.tableViewRefreshStatus == kUITableViewRefreshStatusTriggered) {
        return;
    }
    
    float topIndex = - self.contentInset.top - contentOffset.y;
    float progress = topIndex / (kUITableViewRefreshHeight + kUITableViewRefreshAddTriggerHeight);
    self.tableViewRefreshView.refreshProgress = progress;
    
    if (topIndex > kUITableViewRefreshHeight + kUITableViewRefreshAddTriggerHeight && self.dragging) {
        self.tableViewRefreshStatus = kUITableViewRefreshStatusTriggering;
        return;
    }
    if (topIndex > kUITableViewRefreshHeight + 5 && !self.dragging && self.tableViewRefreshStatus == kUITableViewRefreshStatusTriggering) {
        [self startTriggerRefreshing];
        return;
    }
    
    self.tableViewRefreshStatus = kUITableViewRefreshStatusNormal;
}

- (void)startTriggerRefreshing
{
    if (self.tableViewRefreshStatus == kUITableViewRefreshStatusTriggered) {
        return;
    }
    
    [self.tableViewRefreshView trigerRefreshStatus];
    self.tableViewRefreshStatus = kUITableViewRefreshStatusTriggered;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self addTopEdge];
        self.contentOffset = CGPointMake(0, - self.contentInset.top);
    }completion:^(BOOL finished) {
        if (self.tableViewRefreshBlock) {
            self.tableViewRefreshBlock();
        }
    }];
}

- (void)addSubViewWithTableViewRefreshView:(UIView *)refreshView
{
    if (!refreshView.superview) {
        [self addSubview:refreshView];
    }
}

- (void)addTopEdge
{
    UIEdgeInsets contentInset = self.contentInset;
    if (!self.isTableViewAddTopEdge) {
        contentInset.top += kUITableViewRefreshHeight;
        self.isTableViewAddTopEdge = true;
    }
    self.contentInset = contentInset;
}

- (void)resetTopEdge
{
    UIEdgeInsets contentInset = self.contentInset;
    if (self.isTableViewAddTopEdge) {
        contentInset.top -= kUITableViewRefreshHeight;
        self.isTableViewAddTopEdge = false;
    }
    self.contentInset = contentInset;
}

#pragma mark Setter Getter

/*! 顶部刷新 */
- (void)setTableViewRefreshView:(UIView<UITableViewRefresh> *)tableViewRefreshView
{
    if (self.tableViewRefreshView.superview) {
        [self.tableViewRefreshView removeFromSuperview];
        [self addSubViewWithTableViewRefreshView:tableViewRefreshView];
    }
    
    objc_setAssociatedObject(self, &@selector(tableViewRefreshView), tableViewRefreshView, OBJC_ASSOCIATION_RETAIN);
}

- (UIView<UITableViewRefresh> *)tableViewRefreshView
{
    UIView<UITableViewRefresh> *view = objc_getAssociatedObject(self, &@selector(tableViewRefreshView));
    if (!view) {
        view = [[TableViewRefreshView alloc] initWithFrame:CGRectMake(0, - self.contentInset.top - kUITableViewRefreshHeight, CGRectGetWidth(self.bounds), kUITableViewRefreshHeight)];
        view.backgroundColor = [UIColor clearColor];
        
        objc_setAssociatedObject(self, &@selector(tableViewRefreshView), view, OBJC_ASSOCIATION_RETAIN);
    }
    
    return view;
}

/*! 当前加载状态 */
- (void)setTableViewRefreshStatus:(kUITableViewRefreshStatus)tableViewRefreshStatus
{
    objc_setAssociatedObject(self, &@selector(tableViewRefreshStatus), @(tableViewRefreshStatus), OBJC_ASSOCIATION_RETAIN);
}

- (kUITableViewRefreshStatus)tableViewRefreshStatus
{
    return [objc_getAssociatedObject(self, &@selector(tableViewRefreshStatus)) integerValue];
}

/*! 是否添加了顶部edge */
- (void)setIsTableViewAddTopEdge:(BOOL)isTableViewAddTopEdge
{
    objc_setAssociatedObject(self, &@selector(isTableViewAddTopEdge), @(isTableViewAddTopEdge), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isTableViewAddTopEdge
{
    return [objc_getAssociatedObject(self, &@selector(isTableViewAddTopEdge)) boolValue];
}

/*! 触发事件的block */
- (void)setTableViewRefreshBlock:(kUITableViewRefreshBlock)tableViewRefreshBlock
{
    objc_setAssociatedObject(self, &@selector(tableViewRefreshBlock), tableViewRefreshBlock, OBJC_ASSOCIATION_RETAIN);
}

- (kUITableViewRefreshBlock)tableViewRefreshBlock
{
    return objc_getAssociatedObject(self, &@selector(tableViewRefreshBlock));
}

@end


#pragma mark TableViewRefreshView

static int const kTableViewRefreshViewNumber = 12;

@interface TableViewRefreshView()

@property (nonatomic, strong) NSArray *lineLayers;

@end

@implementation TableViewRefreshView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    [self.lineLayers enumerateObjectsUsingBlock:^(CALayer *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    for (int i = 0; i < kTableViewRefreshViewNumber * self.refreshProgress; i ++) {
        [self.layer addSublayer:self.lineLayers[i]];
    }
}

- (CALayer *)lineAtOrigin:(CGPoint)origin
                    angle:(CGFloat)angle
                 inRadius:(CGFloat)inRadius
                outRadius:(CGFloat)outRadius
                    color:(UIColor *)color
{
    CGPoint startPoint = CGPointMake(origin.x + inRadius * cos(angle), origin.y + inRadius * sin(angle));
    CGPoint endPoint = CGPointMake(origin.x + outRadius * cos(angle), origin.y + outRadius * sin(angle));
    
    CGMutablePathRef shapePath = CGPathCreateMutable();
    CGPathMoveToPoint(shapePath, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(shapePath, NULL, endPoint.x, endPoint.y);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setStrokeColor: color.CGColor];
    [shapeLayer setPath:shapePath];
    CGPathRelease(shapePath);
    shapeLayer.lineWidth = 2;
    shapeLayer.lineCap = @"round";
    
    return shapeLayer;
}

- (void)addAnimation
{
    CFTimeInterval duration = 1.2;
    CFTimeInterval beginTime = CACurrentMediaTime();
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // Animation
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.keyTimes = @[@(0), @(0.5), @(1)];
    animation.timingFunctions = @[timingFunction, timingFunction];
    animation.values = @[@(1), @(0.2), @(0)];
    animation.duration = duration;
    animation.repeatCount = HUGE;
    [self.lineLayers enumerateObjectsUsingBlock:^(CALayer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        animation.removedOnCompletion = false;
        animation.beginTime = beginTime + duration / kTableViewRefreshViewNumber * idx;
        obj.opacity = 1 - idx / 3.0;
        [obj addAnimation:animation forKey:@"animation"];
    }];
}

- (NSArray *)lineLayers
{
    if (!_lineLayers) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:kTableViewRefreshViewNumber];
        CGFloat outRadius = 12;
        CGFloat inRadius = outRadius * 0.5;
        CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        for (int i = 0; i < kTableViewRefreshViewNumber; i ++) {
            CALayer *line = [self lineAtOrigin:center
                                         angle:(M_PI_2 / 3 * i - M_PI_2)
                                      inRadius:inRadius
                                     outRadius:outRadius
                                         color:[UIColor darkGrayColor]];
            [array addObject:line];
        }

        _lineLayers = array;
    }
    
    return _lineLayers;
}

- (void)setRefreshProgress:(float)refreshProgress
{
    float begainProgress = 0.4;
    refreshProgress = (refreshProgress - begainProgress) / (1 - begainProgress);
    _refreshProgress = MAX(0, MIN(1, refreshProgress));
    
    [self setNeedsDisplay];
}

- (void)trigerRefreshStatus
{
    self.refreshProgress = 1.0;
    [self addAnimation];
}

- (void)endRefreshStatus
{
    self.refreshProgress = 0;
    [self.lineLayers enumerateObjectsUsingBlock:^(CALayer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.opacity = 1.0;
        [obj removeAllAnimations];
    }];
}

@end