//
//  Profile_VideoViewController.m
//  Stroff
//
//  Created by Ray on 10/16/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "Profile_VideoViewController.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
#import "UIImageView+URL.h"
#import "UserPAInfo.h"
#import "Constants.h"

@interface Profile_VideoViewController ()
- (void)loadActivity;
@end

@implementation Profile_VideoViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithFullName:(NSString*)name userID:(long) userID_
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        fullName = name;
        userID = userID_;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    listContent_my = [[NSMutableArray alloc]init];
    self.clearsSelectionOnViewWillAppear = NO;
    //headerView
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    view.backgroundColor = [UIColor clearColor];
    
    self.shortTitle.text = [NSString stringWithFormat:@"%@'s videos", fullName];
    //setting ActivityView
    [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    //Set rightbtutton
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    self.navigationItem.rightBarButtonItem = barBtnItem;
    //set segmentControl
    [self.segmentControl removeAllSegments];
    [self.segmentControl insertSegmentWithTitle:@"All Videos" atIndex:0 animated:NO];
    NSString *tilteS2 = @"";
    if (userID == [[UserPAInfo sharedUserPAInfo]registrationID]) {
        tilteS2 = @"My Videos";
    }else
    {
        if (fullName.length<4) {
            tilteS2 = [NSString stringWithFormat:@"%@'s Videos", fullName] ;
        }else
            tilteS2 = @"User's Videos";
    }
    [self.segmentControl insertSegmentWithTitle:tilteS2 atIndex:1 animated:NO];
    [self.segmentControl insertSegmentWithTitle:@"Search" atIndex:2 animated:NO];
    self.segmentControl.selectedSegmentIndex = 1;
    self.segmentControl.alpha = 0.9;
    previousIndex = self.segmentControl.selectedSegmentIndex;
    //Set up Scope Bar itmes
    NSString *optionName1 = @"All Videos";
    NSString *optionName2 = [self.segmentControl titleForSegmentAtIndex:1];
    self.searchBar.showsScopeBar = YES;
    [self.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:optionName1, optionName2, nil]];
    
    [self loadActivity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            return listContent_all.count;
            break;
        case 1:
            return listContent_my.count;
        case 2:
            return filteredListContent.count;
            break;
        default:
            return listContent_my.count;
            break;
    }
    return listContent_my.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Profile_Video_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        UILabel *durationLabel = [[UILabel alloc]init];
        durationLabel.tag = 101;
        [cell.imageView addSubview:durationLabel];
    }
    
    // Configure the cell...
    NSArray *listData;
    NSDictionary *cellData;
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            listData = listContent_all;
            //cellData = [listContent_all objectAtIndex:indexPath.section];
            break;
        case 1:
            listData = listContent_my;
            //cellData = [listContent_my objectAtIndex:indexPath.section];
            break;
        case 2:
            listData = filteredListContent;
            //cellData = [listContent_invition objectAtIndex:indexPath.section];
            break;
        default:
            cellData = [listContent_my objectAtIndex:indexPath.section];
            break;
    }
    if (listData.count <= indexPath.section) {
        listData = nil;
        return cell;
    }
    cellData = [listData objectAtIndex:indexPath.section];
    NSString *imageURL = [NSData stringDecodeFromBase64String: [cellData objectForKey:@"thumbnail"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"video_icon.jpg"]];
    cell.textLabel.text = [NSData stringDecodeFromBase64String: [cellData objectForKey:@"title"] ];
    cell.textLabel.numberOfLines = 2;
    NSString *detail = [NSString stringWithFormat:@"%d views    %@",[[cellData objectForKey:@"hits"]integerValue ], [NSData stringDecodeFromBase64String:[cellData objectForKey:@"created"]]];
    cell.detailTextLabel.text = detail;
    NSString *duration = [NSString stringWithFormat:@" %@ ", [cellData objectForKey:@"duration"]];
    UILabel *durationLabel = (UILabel*)[cell viewWithTag:101];
    durationLabel.text = duration;
    durationLabel.textColor = [UIColor whiteColor];
    durationLabel.backgroundColor = [UIColor darkTextColor];
    durationLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE];
    [durationLabel sizeToFit];
    CGRect frame = durationLabel.frame;
    frame.origin.x = 85 - frame.size.width;
    frame.origin.y = 70 - 20;
    durationLabel.frame = frame;
    listData = nil;
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
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *cellData = [listContent_my objectAtIndex:indexPath.section];
    NSString *urlString = [NSData stringDecodeFromBase64String: [cellData objectForKey:@"video_url"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}
- (float) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
        return view;
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        view.backgroundColor = self.tableView.backgroundColor;
        view.alpha = 0.7;
    }

    return view;
}
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
    hud = nil;
}

#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
        [self.searchDisplayController.searchResultsTableView setContentOffset:CGPointZero];
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
        [self.searchDisplayController.searchResultsTableView setContentOffset:CGPointZero];
    [filteredListContent removeAllObjects];
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    return YES;
}

#pragma mark -
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
        [self.searchDisplayController.searchResultsTableView setContentOffset:CGPointZero];
    [self filterContentForSearchText:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchDisplayController.searchResultsTableView setContentOffset:CGPointZero];
}

#pragma mark

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.searchBar.hidden = YES;
    self.shortTitle.hidden = NO;
    self.segmentControl.hidden = NO;
    self.tableView.tableHeaderView = self.headerView;
    self.segmentControl.selectedSegmentIndex =  previousIndex;
    
}

- (void)loadActivity
{
    
    //LOAD DATA
    MBProgressHUD *HUD;
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
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadCellsInBackground) object:nil];
    id data = nil;
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            data = [[PostadvertControllerV2 sharedPostadvertController] getAllVideosWithUserID:[NSString stringWithFormat:@"%ld", userID] fromID:@"0" limit:@"0"];
            break;
        case 1:
            data = [[PostadvertControllerV2 sharedPostadvertController] getUserVideosWithUserID:[NSString stringWithFormat:@"%ld", userID]];
            break;
        default:
            
            break;
    }
    if (data) {
        switch (self.segmentControl.selectedSegmentIndex) {
            case 0:
                listContent_all = data;
                break;
            case 1:
                listContent_my = data;
                break;
            default:
                listContent_my = data;
                break;
        }
        
    }
    
    self.tableView.scrollEnabled = YES;
    data = nil;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

- (IBAction)segmentControl:(id)sender
{
    UISegmentedControl *segmentCtr = (UISegmentedControl*)sender;
    NSInteger selectedIndex = segmentCtr.selectedSegmentIndex;
    if (selectedIndex != 2) {
        previousIndex = selectedIndex;
        self.searchBar.hidden = YES;
        self.shortTitle.hidden = NO;
        self.segmentControl.hidden = NO;
        [self loadActivity];
    }else
    {
        
        self.searchBar.hidden = NO;
        self.shortTitle.hidden = YES;
        self.segmentControl.hidden = YES;
        if (previousIndex == 1 ) {
            self.searchBar.selectedScopeButtonIndex = 1;
        }else
            self.searchBar.selectedScopeButtonIndex = 0;
        self.tableView.tableHeaderView = self.searchBar;
        [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        if (!activityView.superview) {
            
            self.searchDisplayController.searchResultsTableView.tableHeaderView = activityView;
        }
        //self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
        [self.searchBar becomeFirstResponder];
        
    }
    switch (selectedIndex) {
        case 0:
            self.shortTitle.text = @"All Videos";
            break;
        case 1:
            self.shortTitle.text = [NSString stringWithFormat:@"%@'s Videos", fullName];
            break;
        default:
            
            break;
    }
}
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{

    if ([searchText isEqualToString:@""]) {
        return;
    }
    [self.searchDisplayController.searchResultsTableView setContentOffset:CGPointZero];
    activityView.hidden =NO;
    [activityView startAnimating ];
    //filteredListContent = nil;
    if (filteredListContent == nil) {
        filteredListContent = [[NSMutableArray alloc] init];
    }
    NSArray *tempData = [NSArray arrayWithArray:filteredListContent];
    [filteredListContent removeAllObjects]; // First clear the filtered array.
    NSInteger scopeIndex = self.searchBar.selectedScopeButtonIndex;
    NSMutableArray *templateData = [[NSMutableArray alloc]init];
    if (scopeIndex == 0) {
        templateData = [[NSMutableArray alloc]initWithArray:listContent_all];
    }
    if (scopeIndex == 1) {
        templateData = [[NSMutableArray alloc]initWithArray:listContent_my];
    }
    //[self sumSource:tempData toDestination:templateData];
    for (NSDictionary *obj in tempData) {
        if (![self isDict:obj inArray:templateData]) {
            [templateData addObject:obj];
        }
    }
	for (int i = 0; i< templateData.count; i++)
	{
        NSDictionary *content = [templateData objectAtIndex:i];
        NSString *groupName = [NSData stringDecodeFromBase64String: [content objectForKey:@"name"]];
        if([groupName rangeOfString:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound)
        {
            [filteredListContent addObject:content];
        }
	}
    
    [templateData removeAllObjects];
    templateData = nil;
    //[NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(getSearchDataFromWebService:) object:nil];
    if (searchThread) {
        if ([searchThread isExecuting]) {
            NSLog(@"Cancel old_thread %d", searchCount);
            [searchThread cancel];
        }
        if (searchThread.isFinished) {
            NSLog(@"Thread finished");
        }else
            while (!searchThread.isCancelled) {
                NSLog(@"waiting for old_thread");
            }
    }
    
    searchCount ++;
    searchThread = [[NSThread alloc]initWithTarget:self selector:@selector(getSearchDataFromWebService:) object:searchText];
    [searchThread start];
    NSLog(@"Start new_thread %d", searchCount);
    //[self performSelectorInBackground:@selector(getSearchDataFromWebService:) withObject:searchText];
    //[NSThread detachNewThreadSelector:@selector(getSearchDataFromWebService:) toTarget:self withObject:searchText];
}

- (void) getSearchDataFromWebService:(NSString*)searchText
{
    //searchVideos($user_id, $search_id, $key, $type, $video_id, $limit)
    NSString *key = @"All";
    if (self.searchBar.selectedScopeButtonIndex == 1) {
        key = @"user";
    }
    id data = [[PostadvertControllerV2 sharedPostadvertController]searchVideosWithUserID:[NSString stringWithFormat:@"%ld", userID] searchID:[NSString stringWithFormat:@"%d", searchCount] key:searchText searchType:key video_id:@"0" limit:@"0"];
    if (data) {
        
        NSDictionary *returnSearchID = [data objectAtIndex:0];
        NSInteger returnSearchCount = [[returnSearchID objectForKey:@"search_id"]integerValue];
        NSLog(@"Recive new_thread %d", returnSearchCount);
        if (searchCount == returnSearchCount) {
            activityView.hidden =YES;
            [activityView stopAnimating ];
            //[data removeObjectAtIndex:0];
            filteredListContent =  [NSMutableArray arrayWithArray:data];
            [filteredListContent removeObjectAtIndex:0];
            CGRect frame = self.searchDisplayController.searchResultsTableView.tableHeaderView.frame;
            [self.searchDisplayController.searchResultsTableView setContentOffset:CGPointMake(0, frame.size.height)];
            [self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        
        
    }
}

- (BOOL) isDict:(NSDictionary*)sourceDict inArray:(NSArray*) array
{
    BOOL result = NO;
    NSInteger sourceID =[[sourceDict objectForKey:@"id"] integerValue];
    NSInteger desID = -1;
    for (NSDictionary *dict in array) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            desID = [[dict objectForKey:@"id"] integerValue];
            if (desID == sourceID) {
                return YES;
            }
        }
    }
    
    return result;
}

- (void) sumSource:(NSArray*)array toDestination:(NSMutableArray*)des
{
    if (![des isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    
    for (NSDictionary *obj in array) {
        if (![self isDict:obj inArray:des]) {
            [des addObject:obj];
        }
    }
}

@end
