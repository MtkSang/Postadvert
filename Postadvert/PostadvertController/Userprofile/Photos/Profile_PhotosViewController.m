//
//  Profile_PhotosViewController.m
//  Stroff
//
//  Created by Ray on 10/17/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "Profile_PhotosViewController.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
#import "UIImageView+URL.h"
#import "UserPAInfo.h"
#import "Constants.h"
#import "Profile_PhotoListViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface Profile_PhotosViewController ()
@end

@implementation Profile_PhotosViewController
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
    
    self.shortTitle.text = [NSString stringWithFormat:@"%@'s albums", fullName];
    //setting ActivityView
    [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityView setColor:[UIColor grayColor]];
    
    //Set rightbtutton
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhotoAlbum:)];
    self.navigationItem.rightBarButtonItem = barBtnItem;
    //set segmentControl
    [self.segmentControl removeAllSegments];
    [self.segmentControl insertSegmentWithTitle:@"All albums" atIndex:0 animated:NO];
    NSString *tilteS2 = @"";
    if (userID == [[UserPAInfo sharedUserPAInfo]registrationID]) {
        tilteS2 = @"My albums";
    }else
    {
        if (fullName.length<4) {
            tilteS2 = [NSString stringWithFormat:@"%@'s groups", fullName] ;
        }else
            tilteS2 = @"User's Groups";
    }
    [self.segmentControl insertSegmentWithTitle:tilteS2 atIndex:1 animated:NO];
    self.segmentControl.selectedSegmentIndex = 1;
    self.segmentControl.alpha = 0.9;
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
    }
    
    // Configure the cell...
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    NSDictionary *cellData;
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            cellData = [listContent_all objectAtIndex:indexPath.section];
            break;
        case 1:
            cellData = [listContent_my objectAtIndex:indexPath.section];
            break;
        default:
            cellData = [listContent_my objectAtIndex:indexPath.section];
            break;
    }
    
    
    
    NSString *imageURL = [NSData stringDecodeFromBase64String: [cellData objectForKey:@"thumbnail"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[NSData stringDecodeFromBase64String:[cellData objectForKey:@"name"] ], [[cellData objectForKey:@"total_photos"] integerValue]];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSData stringDecodeFromBase64String:[cellData objectForKey:@"created"]];

    return cell;
}

- (float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}
- (float) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
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
    NSDictionary *cellData;
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            cellData = [listContent_all objectAtIndex:indexPath.section];
            break;
        case 1:
            cellData = [listContent_my objectAtIndex:indexPath.section];
            break;
        default:
            cellData = [listContent_my objectAtIndex:indexPath.section];
            break;
    }

    Profile_PhotoListViewController *albumDeatailCtr = [[Profile_PhotoListViewController alloc]init];
    albumDeatailCtr.albumID = [[cellData objectForKey:@"id"] integerValue];
    albumDeatailCtr.photoCount = [[cellData objectForKey:@"total_photos"] integerValue];
    albumDeatailCtr.navigationController = self.navigationController;
    [self.navigationController pushViewController:albumDeatailCtr animated:YES];
}
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
    hud = nil;
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
    id data;

    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            data = [[PostadvertControllerV2 sharedPostadvertController] getAllAlbumsWithUserID:[NSString stringWithFormat:@"%ld", userID] fromID:@"0" limit:@"0"];
            break;
        case 1:
            data = [[PostadvertControllerV2 sharedPostadvertController] getUserAlbumsWithUserID:[NSString stringWithFormat:@"%ld", userID]];
            break;
        default:
            
            break;
    }
    
    if (data) {
        switch (self.segmentControl.selectedSegmentIndex) {
            case 0:
                listContent_all = [NSMutableArray arrayWithArray:data];
                break;
            case 1:
                listContent_my = [NSMutableArray arrayWithArray:data];
                break;
            default:
                listContent_my = [NSMutableArray arrayWithArray:data];
                break;
        }
        
    }
    
    self.tableView.scrollEnabled = YES;
    data = nil;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

- (void) addPhotoAlbum:(id) sender
{
    
}

- (void) segmentControl:(id)sender
{
    self.shortTitle.text = [self shortTitleString];
    [self loadActivity];
}

- (NSString*) shortTitleString
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        return @"All albums";
    }else
    {
        return [NSString stringWithFormat:@"%@'s groups", fullName] ;
    }
}
@end
