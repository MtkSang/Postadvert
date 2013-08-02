//
//  ActivityViewController.m
//  Postadvert
//
//  Created by Ray on 8/30/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "ActivityViewController.h"
#import "PostAdvertControllerV2.h"
#import "UIActivityCell.h"
#import "UserPAInfo.h"
#import "Constants.h"
#import "ActivityContent.h"
@interface ActivityViewController ()
- (void) loadCellsInBackground;
- (void) initActivityCell;
- (void) reloadTableView;
- (void) drawACell:(int) index;
- (void) loadCellAtIndex:(NSNumber*)num;
- (void) loadActivity;
- (void) addBottomCells;
@end

@implementation ActivityViewController
@synthesize navigationController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadActivity) name:@"loadActivity" object:nil];
    self.view.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:235.0/255.0 blue:245.0/255.0 alpha:1];
    //setup footview
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44)];
    [footerView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    footerView.autoresizesSubviews = YES;
    self.view.frame =[[UIScreen mainScreen] bounds];
    self.tableView.frame = [[UIScreen mainScreen] bounds];
    [self.tableView setTableFooterView: footerView];
    footerLoading = [[MBProgressHUD alloc]initWithView:self.tableView.tableFooterView];
    footerLoading.hasBackground = NO;
    footerLoading.mode = MBProgressHUDModeIndeterminate;
    footerLoading.autoresizingMask = footerView.autoresizingMask;
    footerLoading.autoresizesSubviews = YES;
    footerView = nil;
    
//    //LOAD DATA
//    if (self.view.superview) {
//        HUD = [[MBProgressHUD alloc]initWithView:self.view.superview];
//        [self.view.superview addSubview:HUD];
//    }else {
//        HUD = [[MBProgressHUD alloc]initWithView:self.view];
//        [self.view addSubview:HUD];
//    }
//    HUD.delegate = self;
//    HUD.userInteractionEnabled = NO;
//    [HUD setLabelText:@"Loading..."];
//    [HUD showWhileExecuting:@selector(loadCellsInBackground) onTarget:self withObject:nil animated:YES];
     NSLog(@"LoadActivity");
    [self loadActivity];
    NSLog(@"UITablePostViewController");

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    //[[NSNotificationCenter defaultCenter]removeObserver:self name:@"loadActivity" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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
}

/*
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
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
    HUD = nil;
}

#pragma mark -
- (void)loadActivity
{
    if (lastUserId == [[UserPAInfo sharedUserPAInfo]registrationID]) {
        return;
    }
    lastUserId = [[UserPAInfo sharedUserPAInfo]registrationID];
    
    //LOAD DATA
    if (listActivityCell && listContent) {
        [listActivityCell removeAllObjects];
        [listContent removeAllObjects];
        [self.tableView reloadData];
    }
    
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
    id data = [[PostadvertControllerV2 sharedPostadvertController] getStatusUpdateWithUserID:[NSString stringWithFormat:@"%ld",lastUserId] limit:@"5" index:@"1" status_id:@"0"];
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
    UIActivityCell *cell;// = [listActivityCell objectAtIndex:index];
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
    NSMutableArray *bottomCells = [[PostadvertControllerV2 sharedPostadvertController] getStatusUpdateWithUserID:[NSString stringWithFormat:@"%ld",lastUserId] limit:@"5" index:@"1" status_id:status_id];
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


#pragma mark Supper method

- (void) refresh
{
    if (!loadingHideView) {
        loadingHideView = [[MBProgressHUD alloc]init];
        loadingHideView.hasBackground = NO;
        loadingHideView.mode = MBProgressHUDModeIndeterminate;
    }
    isLoadData = YES;
    [loadingHideView showWhileExecuting:@selector(addTopCells) onTarget:self withObject:nil animated:NO];
    //[self performSelector:@selector(addTopCells) withObject:nil afterDelay:0.00];
}

@end
