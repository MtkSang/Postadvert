//
//  GlobalAlertViewController.m
//  Postadvert
//
//  Created by Mtk Ray on 6/27/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "GlobalAlertViewController.h"
#import "AlertCellContent.h"
#import "UIAlertCell.h"
#import "UserPAInfo.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "PostadvertControllerV2.h"
#import "UIImageView+URL.h"
#import "MBProgressHUD.h"
@interface GlobalAlertViewController ()

@end

@implementation GlobalAlertViewController
@synthesize delegate = _delegate;
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
    self.contentSizeForViewInPopover = CGSizeMake(300, 600);
    [self addPullToRefreshHeader];
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
    [HUD showWhileExecuting:@selector(loadListMessageCellContent) onTarget:self withObject:nil animated:YES];
}

- (void)viewDidUnload
{
    [self setTopView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
     return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Rorote");
}

#pragma mark - implement
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
    [_refreshHeaderView addSubview:_refreshArrow];
    [_refreshHeaderView addSubview:_refreshSpinner];
    [self.tableView addSubview:_refreshHeaderView];
}

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
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(loadListMessageCellContent) withObject:nil afterDelay:2.0];
}


- (void) loadListMessageCellContent
{
    if(listAlertCellContent == nil)
        listAlertCellContent = [[NSMutableArray alloc] init];
    [listAlertCellContent removeAllObjects];
    //getConnections($user_id, $base64_image = false)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"getConnections";
    
    paraNames = [NSArray arrayWithObjects:@"user_id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    [listAlertCellContent removeAllObjects];
    listAlertCellContent = [[NSMutableArray alloc]init];
    [self addListWithData:data];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.0];
    
    [self.tableView reloadData];
}
- (void) addListWithData:(id)data
{
    if ([data isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in data) {
            AlertCellContent *alertContent = [[AlertCellContent alloc] initWithDict:dict];
            [listAlertCellContent addObject:alertContent];
            alertContent = nil;

        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (listAlertCellContent.count == 0) {
        return 1;
    }
    return listAlertCellContent.count;
}

- (UITableViewCell *)tableView:(UITableView *)ctableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listAlertCellContent.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.textLabel.text = @"You have no Alerts.";
        return cell;
    }
    static NSString *CellIdentifier = @"UIAlertCell";
    UIAlertCell *cell = [ctableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UIAlertCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    [cell.imageAvatar setImageWithURL:[NSURL URLWithString:((AlertCellContent*)[listAlertCellContent objectAtIndex:indexPath.row]).connect_from_thumb]];
    [cell.userName setTitle:((AlertCellContent*)[listAlertCellContent objectAtIndex:indexPath.row]).connect_from_name forState:UIControlStateNormal];
    NSInteger num = ((AlertCellContent*)[listAlertCellContent objectAtIndex:indexPath.row]).mutual_friends_count;
    if (num) {
        if (num == 1) {
            cell.mutiFriends.text =@"1 mutual friend";
        } else {
            cell.mutiFriends.text = [NSString stringWithFormat:@"%d mutual friends", num];
        }
    }
    cell.connection_id = ((AlertCellContent*)[listAlertCellContent objectAtIndex:indexPath.row]).connection_id;
    cell.message.text = ((AlertCellContent*)[listAlertCellContent objectAtIndex:indexPath.row]).message;
    cell.btnConfirm.hidden = NO;
    cell.btnNotNow.hidden = NO;
    cell.mutiFriends.hidden = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listAlertCellContent.count == 0) {
        return 44;
    }
    return 72 ;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)ctableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ctableView deselectRowAtIndexPath:indexPath animated:YES];
    //    //Send data to LeftViewCntroller
    AlertCellContent *cellContent = [listAlertCellContent objectAtIndex:indexPath.row];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:cellContent forKey:@"AlertCellContent"];
    if (self.delegate) {
        [self.delegate alertDidSelectedRowWithInfo:dict];
        {
            NSURL *urlUerProfile = [[NSURL alloc]initWithString:[NSString stringWithFormat: @"localStroff://user__%d", cellContent.connect_from_id]];
            [[NSUserDefaults standardUserDefaults] setURL:urlUerProfile forKey:@"openURL"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openURL" object:nil];
        }

    }
}
-( UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]init];
}

- (void) addBottomCells
{
    
    
}

#pragma mark -UIAlertDelegate
- (void) didTapOnCustomLink
{
    if ([self.delegate respondsToSelector:@selector(alertDidSelectedRowWithInfo:)]) {
        [self.delegate alertDidSelectedRowWithInfo:nil];
    }
}

- (void) didRespondRequest:(NSDictionary *)dictValue
{
    NSString *connection_id = [dictValue objectForKey:@"connection_id"];
    NSString *respond_type = [dictValue objectForKey:@"respond_type"];
    
    //friendRequestRespond($connection_id, $respond_type) {
    //respond type = 1 (approve) or -1 (remove)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"friendRequestRespond";
    
    paraNames = [NSArray arrayWithObjects:@"connection_id", @"respond_type", nil];
    paraValues = [NSArray arrayWithObjects:connection_id, respond_type, nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    
    [self loadListMessageCellContent];
}
@end
