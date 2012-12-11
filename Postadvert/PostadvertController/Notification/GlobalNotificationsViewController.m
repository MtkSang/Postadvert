//
//  GlobalNotificationsViewController.m
//  Postadvert
//
//  Created by Mtk Ray on 6/26/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "GlobalNotificationsViewController.h"
#import "NotificationsCellContent.h"
#import "UINotificationsCell.h"
#import "UserPAInfo.h"
#import "Constants.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
@interface GlobalNotificationsViewController ()
- (void) loadListNotificationsContent;
@end

@implementation GlobalNotificationsViewController
@synthesize delegate = _delegate;
@synthesize topView = _topView;
@synthesize tableView = _tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setupStrings];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addPullToRefreshHeader];
    self.contentSizeForViewInPopover = CGSizeMake(300, 600);
    
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44)];
    [footerView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    footerView.autoresizesSubviews = YES;
    [self.tableView setTableFooterView: footerView];
    //self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    //self.tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    footerLoading = [[MBProgressHUD alloc]initWithView:self.tableView.tableFooterView];
    footerLoading.hasBackground = NO;
    footerLoading.mode = MBProgressHUDModeIndeterminate;
    footerLoading.autoresizingMask = footerView.autoresizingMask;
    footerLoading.autoresizesSubviews = YES;
    footerView = nil;
    //Activity
    HUD = [[MBProgressHUD alloc]initWithView:self.tableView];
    [self.tableView addSubview:HUD];
    [HUD showWhileExecuting:@selector(loadListNotificationsContent) onTarget:self withObject:nil animated:YES];
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupStrings{
    _textPull = @"Pull down to refresh...";
    _textRelease = @"Release to refresh...";
    _textLoading = @"Loading...";
}
- (void)addPullToRefreshHeader {
    _refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, self.view.frame.size.width, REFRESH_HEADER_HEIGHT)];
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    //[refreshHeaderView setAutoresizesSubviews:YES];
    //[refreshHeaderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    _refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 50, REFRESH_HEADER_HEIGHT)];
    _refreshLabel.backgroundColor = [UIColor clearColor];
    _refreshLabel.font = [UIFont boldSystemFontOfSize:14.0];
    //refreshLabel.textAlignment = UITextAlignmentCenter;
    _refreshLabel.textColor = [UIColor grayColor];
    [_refreshLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    _refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mui-ten.png"]];
    _refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                     (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                     27, 44);
    
    _refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    _refreshSpinner.hidesWhenStopped = YES;
    
    [_refreshHeaderView addSubview:_refreshLabel];
    //[refreshHeaderView addSubview:lastUpdatedLabel];
    [_refreshHeaderView addSubview:_refreshArrow];
    [_refreshHeaderView addSubview:_refreshSpinner];
    [self.tableView addSubview:_refreshHeaderView];
}
#pragma scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            _refreshLabel.text = self.textRelease;
            [_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            _refreshLabel.text = self.textPull;
            [_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
    
    if (isLoading || isLoadData) {
        return;
    }
    
	if (([scrollView contentOffset].y + scrollView.frame.size.height) + self.tableView.tableFooterView.frame.size.height >= [scrollView contentSize].height - cCellHeight - 100) {
        NSLog(@"scrolled to bottom");
        if (! isLoadData) {
            if (! footerLoading.superview) {
                [self.tableView.tableFooterView addSubview:footerLoading];
            }
            [footerLoading showWhileExecuting:@selector(addBottomCells) onTarget:self withObject:nil animated:YES];
        }
        return;
	}
	if ([scrollView contentOffset].y == scrollView.frame.origin.y) {
        NSLog(@"scrolled to top ");
        
	}
    

    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    _refreshLabel.text = self.textLoading;
    _refreshLabel.frame = CGRectMake(50, 0, self.view.frame.size.width - 50, REFRESH_HEADER_HEIGHT);
    _refreshArrow.hidden = YES;
    [_refreshSpinner startAnimating];
    [UIView commitAnimations];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.tableView.contentInset = UIEdgeInsetsZero;
    UIEdgeInsets tableContentInset = self.tableView.contentInset;
    tableContentInset.top = 0.0;
    self.tableView.contentInset = tableContentInset;
    [_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    _refreshLabel.text = self.textPull;
    _refreshArrow.hidden = NO;
    [_refreshSpinner stopAnimating];
}

- (void)refresh {
    [self performSelector:@selector(loadListNotificationsContent) withObject:nil afterDelay:0];
}

- (void) addBottomCells
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (listNotificationsCellContent.count == 0) {
        return 1;
    }
    return listNotificationsCellContent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listNotificationsCellContent.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.textLabel.text = @"You have no Notifications.";
        return cell;
    }
    static NSString *CellIdentifier = @"UINotificationsCell";
    UINotificationsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UINotificationsCell alloc]initWithNib];
    }
    [cell setContent:[listNotificationsCellContent objectAtIndex:indexPath.row]];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 56 ;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)ctableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ctableView deselectRowAtIndexPath:indexPath animated:YES];
    //    //Send data to DetailViewCntroller
    NotificationsCellContent *cellContent = (NotificationsCellContent*)[listNotificationsCellContent objectAtIndex:indexPath.row];
    NSNumber *num = [NSNumber numberWithInteger:cellContent.target_ID ];
    NSDictionary *dict = [NSDictionary dictionaryWithObject: num forKey:@"NotificationsCellContent"];
    if (self.delegate) {
        [self.delegate didSelectedRowWithInfo:dict];
    }
}
-( UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]init];
}
#pragma mark - UINotificationDelegate

- (void) didTapOnCustomLink{
    if ([self.delegate respondsToSelector:@selector(didSelectedRowWithInfo:)]) {
        [self.delegate didSelectedRowWithInfo:nil];
    }
}
#pragma mark -implement

- (void) loadListNotificationsContent
{
    //getNotifications($user_id, $limit, $notify_id, $base64_image = false)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"getNotifications";
    
    paraNames = [NSArray arrayWithObjects:@"user_id", @"limit", @"notify_id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], @"20", @"0", nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    
    if(listNotificationsCellContent == nil)
        listNotificationsCellContent = [[NSMutableArray alloc] init];
    [listNotificationsCellContent removeAllObjects];
    
    [self addListContentWithData:data andOption:0];
    
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.0];
    
    [self.tableView reloadData];
}

- (void) addListContentWithData:(id)data andOption:(NSInteger) opt
{
    if (data == nil) {
        return;
    }
    if ([data isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in data) {
            NotificationsCellContent *notifi = [[NotificationsCellContent alloc]initWithDictionnary:dict];
            if (opt == 0) {
                //init
                [listNotificationsCellContent addObject:notifi];
            }
            
            if (opt == 1) {
                //scroll down
            }
            
            if (opt == -1) {
                //scroll up
            }
        }
    }
}

@end
