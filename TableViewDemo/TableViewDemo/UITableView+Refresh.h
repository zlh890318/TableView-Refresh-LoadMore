//
//  UITableView+Refresh.h
//  Haoshiqi
//
//  Created by 朱李宏 on 15/11/24.
//  Copyright © 2015年 haoshiqi. All rights reserved.
//

#import <UIKit/UIKit.h>

static float const kUITableViewRefreshHeight = 55;
static float const kUITableViewRefreshAddTriggerHeight = 30;

@protocol UITableViewRefresh;

@interface UITableView (Refresh)

/*! 默认TableViewRefreshView */
@property (nonatomic, strong) UIView<UITableViewRefresh> *tableViewRefreshView;
/*! 触发加载更多时调用的方法，里面是有weak self
 */
- (void)addRefreshTriggerBlock:(void(^)(void))block;
- (void)endRefresh;
- (void)trigerRefresh;

@end

@protocol UITableViewRefresh <NSObject>

@required
@property (nonatomic, assign) float refreshProgress;
- (void)trigerRefreshStatus;
- (void)endRefreshStatus;

@end


@interface TableViewRefreshView : UIView <UITableViewRefresh>

@property (nonatomic, assign) float refreshProgress;
- (void)trigerRefreshStatus;
- (void)endRefreshStatus;

@end