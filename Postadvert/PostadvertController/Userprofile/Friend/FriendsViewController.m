//
//  FriendsViewController.m
//  Postadvert
//
//  Created by Mtk Ray on 7/3/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "FriendsViewController.h"
#import "PostAdvertControllerV2.h"
#import "Constants.h"
#import "CredentialInfo.h"
#import "UserPAInfo.h"
#import "UIImageView+URL.h"
#import "NSData+Base64.h"

@interface NSArray (SSArrayOfArrays)
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation NSArray (SSArrayOfArrays)
- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
}

@end

@interface NSMutableArray (SSArrayOfArrays)
// If idx is beyond the bounds of the reciever, this method automatically extends the reciever to fit with empty subarrays.
- (void)addObject:(id)anObject toSubarrayAtIndex:(NSUInteger)idx;
@end

@implementation NSMutableArray (SSArrayOfArrays)

- (void)addObject:(id)anObject toSubarrayAtIndex:(NSUInteger)idx
{
    while ([self count] <= idx) {
        [self addObject:[NSMutableArray array]];
    }
    NSLog(@"Total %d, newindex %d", [self count], idx);
    
    [[self objectAtIndex:idx] addObject:anObject];
    
}

@end

@interface FriendsViewController ()
- (void) loadlistFriendCellContent;
- (void) plusLastFriends;
@end

@implementation FriendsViewController

//@synthesize tableView;
//@synthesize listMessageCellContent = _listMessageCellContent;
//@synthesize filteredListContent =filteredListContent;
@synthesize navigationController = _navigationController;
@synthesize activityView = _activityView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUserID:(long) userID_ fullName:(NSString*)fullname
{
    self = [super initWithNibName:@"FriendsViewController" bundle:nil];
    if (self) {
        userID = userID_;
        
        userFullName = fullname;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%@: %@", NSStringFromClass([self class]), self.view);
    //[self performSelectorInBackground:@selector(getTotalFriends) withObject:nil];
    [self.activityView startAnimating];
    [self performSelectorInBackground:@selector(loadlistFriendCellContent) withObject:nil];
    self.tableView.tableFooterView = [[UIView alloc]init];
    if ([[UserPAInfo sharedUserPAInfo]registrationID] == userID || userID == 0) {
        [self.searchDisplayController.searchBar setPlaceholder:@"Search My friends"];
    }else
        [self.searchDisplayController.searchBar setPlaceholder:[NSString stringWithFormat:@"Search %@'s friends", userFullName]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.activityView.center = self.view.center;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, 44) animated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - tableViewDataSource
-(NSInteger)tableView:(UITableView *)ctableView numberOfRowsInSection:(NSInteger)section
{
    if (ctableView == self.searchDisplayController.searchResultsTableView)
    {
        return [filteredListContent count];
    }
    else
    {
         return [[sectionedListContent objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)ctableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Profile_FriendCell";        
    // Try to retrieve from the table view a now-unused cell with the given identifier.
    UITableViewCell *cell = [ctableView dequeueReusableCellWithIdentifier:reuseIdentifier];        
    // If no cell is available, create a new one using the given identifier.
    if (cell == nil) {
        //Profile_EventCel
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        topLevelObjects = nil;
    }
    CredentialInfo *cellCentent = nil;
    if (ctableView == self.searchDisplayController.searchResultsTableView)
	{
        cellCentent = ((CredentialInfo*)[filteredListContent objectAtIndex:indexPath.row]);
    }
	else
	{
        cellCentent = ((CredentialInfo*)[sectionedListContent objectAtIndexPath:indexPath]);
    }
    UIImageView *imgView = (UIImageView*)[cell viewWithTag:1];
    [imgView setImageWithURL:[NSURL URLWithString: cellCentent.avatarUrl] placeholderImage:[UIImage imageNamed:@"user_default_thumb.png"]];
    imgView.frame = CGRectMake(1, 1, 64, 64);
    UILabel *name = (UILabel*)[cell viewWithTag:2];
    name.text = cellCentent.fullName;
    
    UILabel *status =(UILabel*) [cell viewWithTag:3];
    status.text = cellCentent.userStatus;
    
    UIButton *totalFriend = (UIButton*)[cell viewWithTag:5];
    if (cellCentent.friendCount>1) {
        [totalFriend setTitle:[NSString stringWithFormat:@"%d friends", cellCentent.friendCount] forState:UIControlStateNormal];
    }else
        [totalFriend setTitle:[NSString stringWithFormat:@"%d friend", cellCentent.friendCount] forState:UIControlStateNormal];

    [totalFriend addTarget:self action:@selector(viewFriends:) forControlEvents:UIControlEventTouchUpInside];
    ctableView.scrollEnabled = YES;
    cell.contentView.tag = cellCentent.registrationID;
    return cell;   
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 47;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)ctableView
{
    if (ctableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
    }
	else
	{
        return [sectionedListContent count];
    }
}


- (NSString *)tableView:(UITableView *)ctableView titleForHeaderInSection:(NSInteger)section
{
	if (ctableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[sectionedListContent objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)ctableView
{
    if (ctableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

- (NSInteger)tableView:(UITableView *)ctableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (ctableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (title == UITableViewIndexSearch) {
            [ctableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        } else {
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
        }
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}
#pragma mark - tableViewDelegate
- (void)tableView:(UITableView *)ctableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CredentialInfo *cellCentent = nil;
    if (ctableView == self.searchDisplayController.searchResultsTableView)
	{
        cellCentent = ((CredentialInfo*)[filteredListContent objectAtIndex:indexPath.row]);
    }
	else
	{
        cellCentent = ((CredentialInfo*)[sectionedListContent objectAtIndexPath:indexPath]);
    }

    NSDictionary *dict = [NSDictionary dictionaryWithObject:cellCentent forKey:@"FriendCellContent"];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"DetailMessageListenner" object:nil userInfo:dict];
    if (self.delegate) {
        [self.delegate friendsViewControllerDidSelectedRowWithInfo:dict];
    }else
    {
        NSURL *urlUerProfile = [[NSURL alloc]initWithString:[NSString stringWithFormat: @"localStroff://user__%ld", cellCentent.registrationID]];
        [[NSUserDefaults standardUserDefaults] setURL:urlUerProfile forKey:@"openURL"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openURL" object:nil];
    }
    [ctableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //No sort this time
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    return YES;
}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (([scrollView contentOffset].y + scrollView.frame.size.height) + self.tableView.tableFooterView.frame.size.height >= [scrollView contentSize].height * 4.0 / 5.0) {
        NSLog(@"scrolled to bottom");
        if (! isLoadData) {
            
        }
        return;
	}
	if ([scrollView contentOffset].y == scrollView.frame.origin.y) {
        NSLog(@"scrolled to top ");
        
	}
    
    
}

#pragma mark - implement
- (IBAction)viewFriends:(id)sender
{
    UIButton *friendBtn = (UIButton*)sender;
    UIView *superView = friendBtn.superview;
    NSLog(@"%@", superView);
    long idNeedToShow = friendBtn.superview.tag;
    NSString *fullName = @"";
    BOOL findOut = NO;
    for (NSArray *info in sectionedListContent) {
        for (CredentialInfo *user in info) {
            if (idNeedToShow == user.registrationID) {
                fullName = user.fullName;
                findOut = YES;
                break;
            }
            
        }
        if (findOut) {
            break;
        }
    }
    if (idNeedToShow > 0) {
        FriendsViewController *newViewCtr = [[FriendsViewController alloc]initWithUserID:idNeedToShow fullName:fullName];
        newViewCtr.navigationController = self.navigationController;
        [self.navigationController pushViewController:newViewCtr animated:YES];
    }
}

- (void) loadlistFriendCellContent
{
    isLoadData = YES;
    if(listFriendCellContent == nil)
        listFriendCellContent = [[NSMutableArray alloc] init];
    [listFriendCellContent removeAllObjects];
    if(sectionedListContent == nil)
        sectionedListContent = [[NSMutableArray alloc] init];
    [sectionedListContent removeAllObjects];
    NSInteger count = 20;
    count = 20 < totalFriends ? 20 : totalFriends;
    if (!count) {
        count = 1;
    }
    NSMutableArray *friends = [self getFriendsFrom:0 count:0];
    for (CredentialInfo *friend in friends) {
        [listFriendCellContent addObject:friend];
    }
    currentIndex_friend = listFriendCellContent.count;
    friends = nil;
    //
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    for (CredentialInfo *_id in listFriendCellContent) {
        NSInteger section = [collation sectionForObject:_id collationStringSelector:@selector(fullName)];
        [sectionedListContent addObject:_id toSubarrayAtIndex:section];
    }
    
    NSInteger section = 0;
    for (section = 0; section < [sectionedListContent count]; section++) {
        NSArray *sortedSubarray = [collation sortedArrayFromArray:[sectionedListContent objectAtIndex:section]
                                          collationStringSelector:@selector(fullName)];
        [sectionedListContent replaceObjectAtIndex:section withObject:sortedSubarray];
    }
    //
    [self.tableView reloadData];
    if (sectionedListContent.count) {
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}

- (NSInteger)getTotalFriends{
        totalFriends = [[PostadvertControllerV2 sharedPostadvertController]countFriendOfUser:[NSString stringWithFormat:@"%ld", userID]];
    return totalFriends;
}

-(id)getFriendsFrom:(NSInteger)rowID count:(NSInteger)count
{
    NSMutableArray *friends =  [[PostadvertControllerV2 sharedPostadvertController]getUserFriendsWithID:[NSString stringWithFormat:@"%ld", userID] row:[NSString stringWithFormat:@"%d",rowID] count:[NSString stringWithFormat:@"%d",count]];
    
    NSMutableArray *listFriends = [[NSMutableArray alloc]initWithCapacity:friends.count];
    for (NSDictionary *dict in friends) {
        NSLog(@"Friends %@", dict);
        CredentialInfo *friendInfo = [[CredentialInfo alloc]init];
        friendInfo.email = [dict objectForKey:@"email"];
        friendInfo.fullName = [dict objectForKey:@"name"];
        friendInfo.usernamePU = [dict objectForKey:@"username"];
        friendInfo.avatarUrl = [NSData stringDecodeFromBase64String:[dict objectForKey:@"thumb"]];
        friendInfo.registrationID = [[dict objectForKey:@"user_id"] integerValue];
        friendInfo.friendCount = [[dict objectForKey:@"friend_count"] integerValue];
        friendInfo.userStatus = [NSData stringDecodeFromBase64String: [dict objectForKey:@"status"]];
        [listFriends addObject:friendInfo];
    }
    return listFriends;
}

- (void) plusLastFriends
{
    if (currentIndex_friend >= totalFriends) {
        return;
    }
    if (isLoadData) {
        return;
    }
    isLoadData = YES;
    if(listFriendCellContent == nil)
        listFriendCellContent = [[NSMutableArray alloc] init];
    if(sectionedListContent == nil)
        sectionedListContent = [[NSMutableArray alloc] init];
    NSInteger count = totalFriends - currentIndex_friend;
    count = MIN(20, count);
    if (count < 0) {
        count = 0;
    }
    NSMutableArray *friends = [self getFriendsFrom:currentIndex_friend count:count];
    for (CredentialInfo *friend in friends) {
        [listFriendCellContent addObject:friend];
    }
    currentIndex_friend = listFriendCellContent.count;
    friends = nil;
    //
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    for (CredentialInfo *_id in listFriendCellContent) {
        NSInteger section = [collation sectionForObject:_id collationStringSelector:@selector(fullName)];
        [sectionedListContent addObject:_id toSubarrayAtIndex:section];
    }
    
    NSInteger section = 0;
    for (section = 0; section < [sectionedListContent count]; section++) {
        NSArray *sortedSubarray = [collation sortedArrayFromArray:[sectionedListContent objectAtIndex:section]
                                          collationStringSelector:@selector(fullName)];
        [sectionedListContent replaceObjectAtIndex:section withObject:sortedSubarray];
    }
    //
    [self.tableView reloadData];
    if (sectionedListContent.count) {
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{
    if (filteredListContent == nil) {
        filteredListContent = [[NSMutableArray alloc] init];
    }
	[filteredListContent removeAllObjects]; // First clear the filtered array.
	for (int i = 0; i< listFriendCellContent.count; i++)
	{
        CredentialInfo *content = [listFriendCellContent objectAtIndex:i];
        
        if([content.fullName rangeOfString:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound)
        {
            [filteredListContent addObject:content];
        }
		
	}
}
@end
