//
//  QiuShiDetailViewController.m
//  XWQSBK
//
//  Created by renxinwei on 13-5-7.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import "QiuShiDetailViewController.h"
#import "JSONKit.h"
#import "CommentCell.h"
#import "QiuShiImageViewController.h"

@interface QiuShiDetailViewController ()

@end

@implementation QiuShiDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
    
    if (_loadMoreFooterView ==nil) {
        _loadMoreFooterView = [[LoadMoreFooterView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        _loadMoreFooterView.delegate = self;
        _qiushiDetailTableView.tableFooterView = _loadMoreFooterView;
        _qiushiDetailTableView.tableFooterView.hidden = NO;
    }
    
    _currentCommentPage = 1;
    _commentArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self initCommentRequest:_qiushi.qiushiID page:_currentCommentPage];
}

- (void)dealloc
{
    SafeClearRequest(self.commentRequest);
    [_loadMoreFooterView release];
    [_commentArray release];
    [_qiushiDetailTableView release];
    [_backButton release];
    [_shareButton release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setQiushiDetailTableView:nil];
    [self setBackButton:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"rotate");
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITableView datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : [_commentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QiuShiCell" owner:self options:nil] lastObject];
        UIImage *backgroundImage = [UIImage imageNamed:@"block_background.png"];
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 320, 14, 0)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
        [cell setBackgroundView:imageView];
        [imageView release];
        ((QiuShiCell *)cell).delegate = self;
        [((QiuShiCell *)cell) configQiuShiCellWithQiuShi:_qiushi];
    }
    else {
        static NSString *cellIdentifier = @"CommentCellIdentifier";
        cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil] lastObject];
            UIImage *backgroundImage = [UIImage imageNamed:@"block_center_background.png"];
            backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 320, 4, 0)];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
            [cell setBackgroundView:imageView];
            [imageView release];
        }
        [((CommentCell *)cell) configCommentCellWithComment:[_commentArray objectAtIndex:indexPath.row]];
    }

    return cell;
}

#pragma mark - UITableView delegate method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.section == 0) {
        height = [QiuShiCell getCellHeight:_qiushi];
    }
    else {
        NSString *content = ((Comment *)[_commentArray objectAtIndex:indexPath.row]).content;
        height = [CommentCell getCellHeight:content];
    }
    
    return height;
}

#pragma mark - UIScrollView delegate method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_loadMoreFooterView loadMoreScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_loadMoreFooterView loadMoreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - LoadMoreFooterViewDelegate method

- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreFooterView *)view
{
    _moreLoading = YES;
    _currentCommentPage++;
    [self initCommentRequest:_qiushi.qiushiID page:_currentCommentPage];
}

#pragma mark - QiuShiCellDelegate method

- (void)didTapedQiuShiCellImage:(NSString *)midImageURL
{
    QiuShiImageViewController *qiushiImageVC = [[QiuShiImageViewController alloc] initWithNibName:@"QiuShiImageViewController" bundle:nil];
    [qiushiImageVC setQiuShiImageURL:midImageURL];
    qiushiImageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:qiushiImageVC animated:YES completion:nil];
    [qiushiImageVC release];
}

#pragma mark - ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    JSONDecoder *jsonDecoder = [[JSONDecoder alloc] init];
    NSDictionary *dic = [jsonDecoder objectWithData:[request responseData]];
    [jsonDecoder release];
    
    if (_moreLoading) {
        _moreLoading = NO;
        [_loadMoreFooterView loadMoreshScrollViewDataSourceDidFinishedLoading:_qiushiDetailTableView];
    }
    
    NSArray *array = [dic objectForKey:@"items"];
    if (array) {
        for (int i = 0; i < [array count]; i++) {
            NSDictionary *commentDic = [array objectAtIndex:i];
            Comment *comment = [[Comment alloc] initWithDictionary:commentDic];
            [_commentArray addObject:comment];
            [comment release];
        }
    }
    _totalCommentCount = [[dic objectForKey:@"total"] integerValue];
    
    [_qiushiDetailTableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[Dialog Instance] toast:self withMessage:@"评论不行了,顶一个上去啊!"];
}

#pragma mark - ShareOptionViewDelegate methods

- (void)shareOptionView:(ShareOptionView *)shareView didClickButtonAtIndex:(NSInteger)index
{
    [shareView fadeOut];
}

#pragma mark - UIAction methods

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareButtonClicked:(id)sender
{
    ShareOptionView *shareView = [[[ShareOptionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))] autorelease];
    shareView.delegate = self;
    [self.view addSubview:shareView];
    [shareView fadeIn];
}

#pragma mark - Private methods

- (void)initViews
{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background.png"]]];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:_backButton] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:_shareButton] autorelease];
}

- (void)initCommentRequest:(NSString *)qiushiID page:(NSInteger)page
{
    self.commentRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:api_article_comment(qiushiID, 50, page)]];
    self.commentRequest.delegate = self;
    [self.commentRequest startAsynchronous];
}

@end