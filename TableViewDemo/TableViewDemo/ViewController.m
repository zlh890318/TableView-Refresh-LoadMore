//
//  ViewController.m
//  TableViewDemo
//
//  Created by Andy on 16/9/18.
//  Copyright © 2016年 TableViewDemo. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+Refresh.h"
#import "UITableView+LoadMore.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray<NSString *> *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.datas = [NSMutableArray new];
    for (NSInteger i = 0; i < 10; i ++) {
        [self.datas addObject:[NSString stringWithFormat:@"Cell Row:%zd", i]];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addRefreshTriggerBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            [self.tableView endRefresh];
            [self.tableView layoutIfNeeded];
            self.datas = [NSMutableArray new];
            for (NSInteger i = 0; i < 10; i ++) {
                [self.datas addObject:[NSString stringWithFormat:@"Cell Row:%zd", i]];
            }
            [self.tableView reloadData];
        });
    }];
    [self.tableView addLoadingMoreTriggerBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            for (NSInteger i = 0; i < 10; i ++) {
                [self.datas addObject:[NSString stringWithFormat:@"Cell Row:%zd", self.datas.count]];
            }
            [self.tableView endLoadMore];
            [self.tableView reloadData];
        });
    }];
    self.tableView.isMore = true;
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    tableViewCell.textLabel.text = self.datas[indexPath.row];
    
    return tableViewCell;
}

@end
