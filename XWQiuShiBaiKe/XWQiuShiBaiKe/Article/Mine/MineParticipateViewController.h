//
//  MineParticipateViewController.h
//  XWQiuShiBaiKe
//
//  Created by renxinwei on 13-5-30.
//  Copyright (c) 2013年 renxinwei's iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QiuShiCell.h"

@interface MineParticipateViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, LoadMoreFooterViewDelegate, ASIHTTPRequestDelegate, QiuShiCellDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    LoadMoreFooterView *_loadMoreFooterView;
    RequestType _requestType;
    
    NSMutableArray *_participateArray;
    NSInteger _currentPage;
    BOOL _reloading;
}

@property (nonatomic) BOOL isLoaded;
@property (retain, nonatomic) ASIHTTPRequest *participateRequest;
@property (retain, nonatomic) IBOutlet UITableView *participateTableView;
@property (retain, nonatomic) IBOutlet UIButton *sideButton;

- (IBAction)sideButtonClicked:(id)sender;

@end
