//
//  UserProfileViewController.m
//  Postadvert
//
//  Created by Ray on 9/12/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UserPAInfo.h"
#import "CredentialInfo.h"
#import "ActivityContent.h"
#import "UIActivityCell.h"
#import "Constants.h"
#import "PostadvertControllerV2.h"
#import "Profile_VideoViewController.h"
#import "Profile_PhotosViewController.h"
#import "Profile_EventViewController.h"
#import "UIImageView+URL.h"
#import "FriendsViewController.h"
#import "Profile_GroupsViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface UserProfileViewController ()

- (IBAction)btn_scrolling_bar_clicked:(id)sender;
- (IBAction)userPhotos:(id)sender;
- (IBAction)userGroups:(id)sender;
- (IBAction)userEvents:(id)sender;
- (IBAction)friendBtnClicked:(id)sender;
- (IBAction)messageBtnClicked:(id)sender;
//- (void) setFriendBtnTitle;
- (void)updateView;
- (void)updateUserInfo;
@end

@implementation UserProfileViewController

@synthesize headerViewSection = headerViewSection;
@synthesize navigationController;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUserID:(long)userID
{
    self = [super initWithNibName:@"UserProfileViewController" bundle:nil];
    if (self) {
        // Custom initialization
        lastUserId = userID;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerDidRotation) name:@"viewControllerDidRotation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerwillAnimateRotation) name:@"viewControllerwillAnimateRotation" object:nil];
    
    self.clearsSelectionOnViewWillAppear = YES;
    listActivityCell = [[NSMutableArray alloc]init];
    listContent = [[NSMutableArray alloc]init];
    [self initView];
    [self performSelectorInBackground:@selector(updateUserInfo) withObject:nil];
    [self loadActivity];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"viewControllerDidRotation" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"viewControllerwillAnimateRotation" object:nil];
    [self setAddFriendBtn:nil];
    [self setMessageBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
   
    
    
}
- (void) viewControllerwillAnimateRotation
{
    if (popoverController) {
        popoverController.view.hidden = YES;
    }
}

- (void) viewControllerDidRotation
{
    if (popoverController) {
        [self presentPopover];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (listActivityCell.count) {
        return listActivityCell.count;
    }else
        return 1;
    return listActivityCell.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listContent.count == 0) {
        return tableView.frame.size.height;
    }
    
    Float32 height = [UIActivityCell getCellHeightWithContent:[listContent objectAtIndex:indexPath.section]];
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listContent.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:tableView.frame];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.scrollEnabled = NO;
        return  cell;
    }
    UIActivityCell *cell = [listActivityCell objectAtIndex:indexPath.section];
    if ([cell isKindOfClass:[NSNull class]]) {
        [self performSelectorOnMainThread:@selector(loadCellAtIndex:) withObject:[NSNumber numberWithInteger:indexPath.section] waitUntilDone:YES];
        cell = [listActivityCell objectAtIndex:indexPath.section];
    }
    tableView.scrollEnabled = YES;
    [cell updateCellWithContent:[listContent objectAtIndex:indexPath.section]];
    [cell performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
    [listActivityCell replaceObjectAtIndex:indexPath.section withObject:cell];
    return cell;
}/*
  // Override to support conditional editing of the table view.
  - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
  {
  // Return NO if you do not want the specified item to be editable.
  return YES;
  }
  */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActivityCell *cell = (UIActivityCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell commentButtonClicked:nil];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
    hud = nil;
}

#pragma mark Supper method

- (void) refresh
{
    isLoadData = YES;
    //[loadingHideView showWhileExecuting:@selector(loadActivity) onTarget:self withObject:nil animated:NO];
    [self loadActivity];
}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isLoading || isLoadData) {
        return;
    }
    
    [super scrollViewDidScroll:scrollView];
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
#pragma mark -
#pragma customAction
- (IBAction)btnPostClicked:(id)sender {
//    if (popoverController) {
//		[popoverController dismissPopoverAnimated:YES];
//		popoverController = nil;
//        viewUseToGetRectPopover = nil;
//        //[self removeDetailMessageListenner:self];
//	} else {
//        //Add listenner to get data when user choice from Global Message
//        //[self addDetailMessageListenner:self];
//        
//        viewUseToGetRectPopover = (UIView*)sender;
//        UINewStatusViewController *contentViewController = [[UINewStatusViewController alloc] init];
//        contentViewController.delegate = self;
//        //contentViewController.tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:247/255.0 blue:247/255.0 alpha:1];
//		popoverController = [[WEPopoverController alloc] initWithContentViewController:(UIViewController*)contentViewController];
//		
//		if ([popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
//			[popoverController setContainerViewProperties:[self defaultContainerViewProperties]];
//		}
//		
//		popoverController.delegate = self;
//		popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController];
//        [self presentPopover];
//    }
    
    UINewStatusViewController *newContrl = [[UINewStatusViewController alloc]initWithUserInfo:userInfo];
    [self.navigationController presentViewController:newContrl animated:YES completion:nil];
}
- (void) presentPopover
{
    [popoverController presentPopoverFromRect:viewUseToGetRectPopover.frame
                                       inView: self.view
                     permittedArrowDirections:(UIPopoverArrowDirectionUp)
                                     animated:YES];
}

- (void) setLastUserId:(long) userID
{
    lastUserId = userID;
    //Get user info
    [self performSelectorInBackground:@selector(updateUserInfo) withObject:nil];
    
    //get activity
    [self loadActivity];
}
- (void)initView
{
    scrollingBar.contentSize = CGSizeMake(478, scrollingBar.frame.size.height);
    if (lastUserId == [[UserPAInfo sharedUserPAInfo] registrationID]) {
        CGRect frame = headerViewSection.frame;
        frame.size.height = 155 - 30 - 10;
        headerViewSection.frame = frame;
        self.addFriendBtn.hidden = YES;
        self.messageBtn.hidden = YES;
    }
    else
    {
        CGRect frame = headerViewSection.frame;
        self.addFriendBtn.titleLabel.text = @"Add Friend";
        frame.size.height = 155;
        headerViewSection.frame = frame;
        self.addFriendBtn.hidden = NO;
        self.messageBtn.hidden = NO;
    }
}
- (void)updateView
{
    
    //Check User profile OR Friend profile
    CGRect frame = headerViewSection.frame;
    switch (userInfo.friendStatus) {
        case -1:
            frame.size.height = 155 - 30 - 10;
            headerViewSection.frame = frame;
            self.addFriendBtn.hidden = YES;
            self.messageBtn.hidden = YES;
            break;
        case 1:
            // did friend
            [self.addFriendBtn setTitle:@"Friend" forState:UIControlStateNormal];
            frame.size.height = 155;
            headerViewSection.frame = frame;
            self.addFriendBtn.hidden = NO;
            self.messageBtn.hidden = NO;
            break;
        case 2:
            // did friend
            [self.addFriendBtn setTitle:@"Friend Request Sent" forState:UIControlStateNormal];
            frame.size.height = 155;
            headerViewSection.frame = frame;
            self.addFriendBtn.hidden = NO;
            self.messageBtn.hidden = NO;
            break;
        case 3:
            // did friend
            [self.addFriendBtn setTitle:@"Respond to Request" forState:UIControlStateNormal];
            frame.size.height = 155;
            headerViewSection.frame = frame;
            self.addFriendBtn.hidden = NO;
            self.messageBtn.hidden = NO;
            break;
        default:
            // no friend
            [self.addFriendBtn setTitle:@"Add Friend" forState:UIControlStateNormal];
            frame.size.height = 155;
            headerViewSection.frame = frame;
            self.addFriendBtn.hidden = NO;
            self.messageBtn.hidden = NO;
            break;
    }
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44)];
    [footerView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    footerView.autoresizesSubviews = YES;
    [self.tableView setTableFooterView: footerView];
    footerLoading = [[MBProgressHUD alloc]initWithView:self.tableView.tableFooterView];
    footerLoading.hasBackground = NO;
    footerLoading.mode = MBProgressHUDModeIndeterminate;
    footerLoading.autoresizingMask = footerView.autoresizingMask;
    footerLoading.autoresizesSubviews = YES;

}
- (void)updateUserInfo
{
    //-(id) getFriendStatusWithUserID:(NSString*)userID andOtherID:(NSString*)otherID
    [self getUserInfo];
    [userAvatar setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:[UIImage imageNamed:@"user_default_thumb.png"]];
    userFullName.text = [userInfo fullName];
    userName.text = [userInfo usernamePU];
    
    [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
}

- (void)getUserInfo
{
    id data = [[PostadvertControllerV2 sharedPostadvertController] getFriendStatusWithUserID:[NSString stringWithFormat:@"%ld",[[UserPAInfo sharedUserPAInfo] registrationID]] andOtherID:[NSString stringWithFormat:@"%ld", lastUserId]];
    if (data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            userInfo = nil;
            userInfo = [[CredentialInfo alloc]init];
            userInfo.fullName = [data objectForKey:@"name"];
            userInfo.usernamePU = [data objectForKey:@"username"];
            userInfo.friendStatus = [[data objectForKey:@"friend_status"] integerValue];
            userInfo.avatarUrl = [data objectForKey:@"thumb"];
            userInfo.registrationID = [[data objectForKey:@"id"] integerValue];
        }
        
    }
    headerViewSection.hidden = NO;
    headerViewSection.userInteractionEnabled = YES;
}

- (IBAction)btn_scrolling_bar_clicked:(id)sender
{
    //Just using for this UI
    UIButton *btn = (UIButton*)sender;
    
    for (UIButton *subBtn in btn.superview.subviews) {
        [subBtn setSelected:NO];
        [subBtn setBackgroundImage:[UIImage imageNamed:@"btnUserProfile_(active)"] forState:UIControlStateSelected];
        [subBtn setBackgroundImage:[UIImage imageNamed:@"btnUserProfile_(inactive)"] forState:UIControlStateNormal];
    }
    [btn setSelected:YES];
    
}

- (IBAction) friendBtnClicked:(id)sender
{
    
}

- (IBAction) messageBtnClicked:(id)sender
{
    
}

- (void)loadActivity
{
    //LOAD DATA
    
    if (self.view.superview) {
        HUD = [[MBProgressHUD alloc]initWithView:self.view.superview];
        [self.view.superview addSubview:HUD];
    }else {
        HUD = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUD];
    }
    HUD.delegate = self;
    HUD.userInteractionEnabled = NO;
    [HUD setLabelText:@"Loading..."];
    [HUD showWhileExecuting:@selector(loadCellsInBackground) onTarget:self withObject:nil animated:YES];
}

- (void) loadCellsInBackground
{
    isLoadData = YES;
    id data = [[PostadvertControllerV2 sharedPostadvertController] getUserStatusUpdateWithUserID:[NSString stringWithFormat:@"%ld",lastUserId] limit:@"5" status_id:@"0"];
    if (data) {
        listContent = data;
        listActivityCell = nil;
    }
    
    [self initActivityCell];
    isLoadData = NO;
    self.tableView.scrollEnabled = YES;
    [self stopLoading];
    data = nil;
}

- (void) initActivityCell
{
    if (!listActivityCell) {
        listActivityCell = [[NSMutableArray alloc]initWithCapacity:listContent.count];
    }
    //static NSString *CellIdentifier = @"UIPostCell_Landscape";
    for (int i=0; i<listContent.count; i++) {
        [listActivityCell insertObject:[NSNull null] atIndex:0 ];
    }
    [self reloadTableView];
    
}

- (void) reloadTableView
{
    for (int i=0; i<=listContent.count; i++) {
        [self drawACell:i];
        
    }
    //[self.tableView endUpdates];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    //[self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void) drawACell:(int) index
{
    if (index >= listContent.count) {
        return;
    }
    UIActivityCell *cell = [listActivityCell objectAtIndex:index];
    if ([cell isKindOfClass:[NSNull class]]) {
        [self performSelectorOnMainThread:@selector(loadCellAtIndex:) withObject:[NSNumber numberWithInteger:index] waitUntilDone:YES];
    }
    cell = nil;
}

- (void) loadCellAtIndex:(NSNumber*)num
{
    NSInteger index = [num integerValue];
    UIActivityCell *cell = [listActivityCell objectAtIndex:index];
    NSArray *nib = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        nib = [[NSBundle mainBundle] loadNibNamed:@"UIActivityCell" owner:self options:nil];
    }
    else{
        nib = [[NSBundle mainBundle] loadNibNamed:@"UIActivityCell" owner:self options:nil];
    }
    cell = (UIActivityCell *)[nib objectAtIndex:0];
    [cell loadNibFile];
    cell.navigationController = self.navigationController;
    [cell updateCellWithContent:[listContent objectAtIndex:index]];
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [listActivityCell replaceObjectAtIndex:index withObject:cell];
    cell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
    cell.backgroundView.backgroundColor = [UIColor whiteColor];
}

- (void) addBottomCells
{
    
    int beforeLoad = listActivityCell.count;
    isLoadData = YES;
    ActivityContent *firstContent = [listContent lastObject];
    NSString *status_id = [NSString stringWithFormat:@"%d", firstContent.status_ID];
    NSMutableArray *bottomCells = [[PostadvertControllerV2 sharedPostadvertController] getUserStatusUpdateWithUserID:[NSString stringWithFormat:@"%ld",lastUserId] limit:@"5" status_id:status_id];
    for (ActivityContent *cellContent in bottomCells) {
        [listContent addObject:cellContent];
        [listActivityCell addObject:[NSNull null]];
    }
    if (listActivityCell.count > beforeLoad) {
        [self reloadTableView];
    }
    
    isLoadData = NO;
    
}

- (void) addTopCells
{
    int beforeLoad = listActivityCell.count;
    ActivityContent *firstContent = [listContent objectAtIndex:0];
    NSString *status_id = [NSString stringWithFormat:@"%d", firstContent.status_ID];
    //-(id) getStatusUpdateWithUserID:(NSString*)userId limit:(NSString*)limit index:(NSString*)index status_id:(NSString*)status_id
    NSMutableArray *incommingData = [[PostadvertControllerV2 sharedPostadvertController] getStatusUpdateWithUserID:[NSString stringWithFormat:@"%ld",lastUserId] limit:@"5" index:@"0" status_id:status_id];
    while (incommingData.count) {
        ActivityContent *cellContent = [incommingData lastObject];
        [listContent insertObject:cellContent atIndex:0];
        [listActivityCell insertObject:[NSNull null] atIndex:0];
        [incommingData removeLastObject];
    }
    
    if (listActivityCell.count > beforeLoad) {
        [self reloadTableView];
    }
    //[self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.01];
    [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
    //[self stopLoading];
    
    isLoadData = NO;
    
}

- (IBAction)userVideo:(id)sender
{
    Profile_VideoViewController *viewCtr = [[Profile_VideoViewController alloc]initWithFullName:userInfo.fullName userID:userInfo.registrationID];
    [self.navigationController pushViewController:viewCtr animated:YES];
}

- (IBAction)userPhotos:(id)sender
{
    Profile_PhotosViewController *viewCtr = [[Profile_PhotosViewController alloc]initWithFullName:userInfo.fullName userID:userInfo.registrationID];
    viewCtr.navigationController = self.navigationController;
    [self.navigationController pushViewController:viewCtr animated:YES];
}

- (IBAction)userFriends:(id)sender
{
    //FriendsViewController
    FriendsViewController *viewCtr = [[FriendsViewController alloc]initWithUserID:userInfo.registrationID fullName:userInfo.fullName];
    viewCtr.navigationController = self.navigationController;
    [self.navigationController pushViewController:viewCtr animated:YES];
}

- (IBAction)userGroups:(id)sender
{
    //FriendsViewController
    Profile_GroupsViewController *viewCtr = [[Profile_GroupsViewController alloc] initWithFullName:userInfo.fullName userID:userInfo.registrationID ];
    viewCtr.navigationController = self.navigationController;
    [self.navigationController pushViewController:viewCtr animated:YES];
}

- (IBAction)userEvents:(id)sender
{
    //FriendsViewController
    Profile_EventViewController *viewCtr = [[Profile_EventViewController alloc] initWithFullName:userInfo.fullName userID:userInfo.registrationID ];
    viewCtr.navigationController = self.navigationController;
    [self.navigationController pushViewController:viewCtr animated:YES];
}

#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
    popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}
- (WEPopoverContainerViewProperties *)defaultContainerViewProperties {
	WEPopoverContainerViewProperties *ret = [[WEPopoverContainerViewProperties alloc] init];
	
	CGSize imageSize = CGSizeMake(30.0f, 30.0f);
	NSString *bgImageName = @"popoverBgSimple.png";
	CGFloat bgMargin = 6.0;
	CGFloat contentMargin = 4.0;
	
	ret.leftBgMargin = bgMargin;
	ret.rightBgMargin = bgMargin;
	ret.topBgMargin = bgMargin;
	ret.bottomBgMargin = bgMargin;
	ret.leftBgCapSize = imageSize.width/2 ;
	ret.topBgCapSize = imageSize.height/2;
	ret.bgImageName = bgImageName;
	ret.leftContentMargin = contentMargin;
	ret.rightContentMargin = contentMargin;
	ret.topContentMargin = contentMargin;
	ret.bottomContentMargin = contentMargin;
	ret.arrowMargin = 3.0;
	
	ret.upArrowImageName = @"popoverArrowUpSimple.png";
	ret.downArrowImageName = @"popoverArrowDownSimple.png";
	ret.leftArrowImageName = @"popoverArrowLeftSimple.png";
	ret.rightArrowImageName = @"popoverArrowRightSimple.png";
	return ret;
}


- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] init];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = 100;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin;
	props.bottomContentMargin = 100;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;
}

#pragma mark - UINewStatusControllerDelegate

- (void) didChageView
{

    [self performSelectorOnMainThread:@selector(hidePopover) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(showPopover) withObject:nil waitUntilDone:YES];
}

- (void) hidePopover
{
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView beginAnimations:@"popover" context:(__bridge void *)popoverController.view];
    //popoverController.view.frame = CGRectZero;
    [UIView commitAnimations];
}
- (void) showPopover
{
    [UIView setAnimationDuration:2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
    [UIView beginAnimations:@"popover" context: nil];
    popoverController = [[WEPopoverController alloc] initWithContentViewController:popoverController.contentViewController];
    if ([popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
        [popoverController setContainerViewProperties:[self defaultContainerViewProperties]];
    }
    
    popoverController.delegate = self;
    popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController];
    [self presentPopover];
    [UIView commitAnimations];
}
@end



