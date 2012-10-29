//
//  Profile_PhotosViewController.m
//  Stroff
//
//  Created by Ray on 10/17/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "Profile_EventViewController.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
#import "UIImageView+URL.h"
#import "UserPAInfo.h"
#import "Constants.h"
#import "Profile_PhotoListViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface Profile_EventViewController ()

@end

@implementation Profile_EventViewController
@synthesize navigationController;
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
    //self = [super initWithNibName:@"Profile_GroupsViewController" bundle:nil];
    self = [super initWithStyle:UITableViewStylePlain];
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
    searchCount = 0;
    listContent_my = [[NSMutableArray alloc]init];
    listContent_all = [[NSMutableArray alloc]init];
    listContent_invition = [[NSMutableArray alloc]init];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    //Setting supper's items
    [self.segmentControl setSegmentedControlStyle:UISegmentedControlStyleBezeled];
    self.shortTitle.text = [NSString stringWithFormat:@"%@'s groups", fullName];
    previousIndex = self.segmentControl.selectedSegmentIndex;
    if (userID == [[UserPAInfo sharedUserPAInfo]registrationID]) {
        [self.segmentControl setTitle:@"My Groups" forSegmentAtIndex:1];
    }else
    {
        if (fullName.length<4) {
            [self.segmentControl setTitle:[NSString stringWithFormat:@"%@'s groups", fullName] forSegmentAtIndex:1];
        }else
            [self.segmentControl setTitle:@"User's Groups" forSegmentAtIndex:1];
    }
    //Set up Scope Bar itmes
    NSString *optionName1 = @"All Groups";
    NSString *optionName2 = [self.segmentControl titleForSegmentAtIndex:1];
    self.searchBar.showsScopeBar = YES;
    [self.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:optionName1, optionName2, nil]];
    
    //Load data
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
    // Return the number of sections.
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            return listContent_all.count;
            break;
        case 1:
            return listContent_my.count;
        case 2:
            return listContent_invition.count;
        case 3:
            return filteredListContent.count;
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
    static NSString *reuseIdentifier = @"Profile_GroupsViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        //Profile_GroupsViewCell
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        topLevelObjects = nil;
        
    }
    
    // Configure the cell...
    NSDictionary *cellData;
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            cellData = [listContent_all objectAtIndex:indexPath.section];
            break;
        case 1:
            cellData = [listContent_my objectAtIndex:indexPath.section];
            break;
        case 2:
            cellData = [listContent_invition objectAtIndex:indexPath.section];
            break;
        case 3:
            cellData = [filteredListContent objectAtIndex:indexPath.section];
            break;
        default:
            cellData = [listContent_my objectAtIndex:indexPath.section];
            break;
    }
    
    NSString *imageURL = [NSData stringDecodeFromBase64String: [cellData objectForKey:@"thumb"]];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    [imageView setImageWithURL:[NSURL URLWithString:imageURL]placeholderImage:[UIImage imageNamed:@"group_thumb.png"]];
    imageView.frame = CGRectMake(0, 0, 75, 75);
    UILabel *name = (UILabel*)[cell viewWithTag:2];
    name.text = [NSData stringDecodeFromBase64String:[cellData objectForKey:@"name"]];
    //description
    UILabel *description = (UILabel*)[ cell viewWithTag:3];
    description.text = [NSData stringDecodeFromBase64String: [cellData objectForKey:@"description"]];
    
    UILabel *created = (UILabel *)[cell viewWithTag:4];
    created.text = [cellData objectForKey:@"created"];
    
    UIButton *member_count = (UIButton *)[cell viewWithTag:6];
    int num = [[cellData objectForKey:@"member_count"] integerValue];
    if (num>1) {
        [member_count setTitle:[NSString stringWithFormat:@"%d Members", num] forState:UIControlStateNormal ] ;
    }else
        [member_count setTitle:[NSString stringWithFormat:@"%d Member", num] forState:UIControlStateNormal ] ;
    
    UIButton *discuss_count = (UIButton *)[cell viewWithTag:8];
    num = [[cellData objectForKey:@"discuss_count"] integerValue];
    [discuss_count setTitle:[NSString stringWithFormat:@"%d Discussions", num] forState:UIControlStateNormal];
    
    UIButton *wall_count = (UIButton *)[cell viewWithTag:10];
    num = [[cellData objectForKey:@"wall_count"] integerValue];
    [wall_count setTitle:[NSString stringWithFormat:@"%d Wall Posts", num] forState:UIControlStateNormal];
    
    
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
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [self filterContentForSearchText:searchString];
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [filteredListContent removeAllObjects];
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"Serach %@", searchText);
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

#pragma mark

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
            data = [[PostadvertControllerV2 sharedPostadvertController] getAllGroupsWithUserID:[NSString stringWithFormat:@"%ld", userID] fromID:@"0" limit:@"0"];
            break;
        case 1:
            data = [[PostadvertControllerV2 sharedPostadvertController] getUserGroupsWithUserID:[NSString stringWithFormat:@"%ld", userID]];
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
    if (selectedIndex != 3) {
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
        
        [self.searchBar becomeFirstResponder];
        
    }
    switch (selectedIndex) {
        case 0:
            self.shortTitle.text = @"All Groups";
            break;
        case 1:
            self.shortTitle.text = [NSString stringWithFormat:@"%@'s Groups", fullName];
            break;
        case 2:
            self.shortTitle.text = [NSString stringWithFormat:@"%@'s Pending Invitations", fullName];
            break;
        case 3:
            
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
    NSString *key = @"All";
    if (self.searchBar.selectedScopeButtonIndex == 1) {
        key = @"user";
    }
    id data = [[PostadvertControllerV2 sharedPostadvertController]searchGroupsWithUserID:[NSString stringWithFormat:@"%ld", userID] searchID:[NSString stringWithFormat:@"%d", searchCount] key:searchText searchType:key groupID:@"0" limit:@"0"];
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
