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
    self = [super initWithNibName:@"Profile_PhotosViewController" bundle:nil];
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
    listContent = [[NSMutableArray alloc]init];
    [self loadActivity];
    self.clearsSelectionOnViewWillAppear = NO;
    //headerView
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    view.backgroundColor = [UIColor clearColor];
    headerTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.textColor = [UIColor darkGrayColor];
    headerTitle.textAlignment = UITextAlignmentCenter;
    [headerTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    headerTitle.text = [NSString stringWithFormat:@"%@'s albums", fullName];
    [view addSubview:headerTitle];
    self.tableView.tableHeaderView = view;
    //view = nil;
    
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
    return listContent.count;
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
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    NSDictionary *cellData = [listContent objectAtIndex:indexPath.section];
    NSString *imageURL = [NSData stringDecodeFromBase64String: [cellData objectForKey:@"thumbnail"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[cellData objectForKey:@"name"], [[cellData objectForKey:@"total_photos"] integerValue]];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSData stringDecodeFromBase64String:[cellData objectForKey:@"created"]];
    
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
    NSDictionary *cellData = [listContent objectAtIndex:indexPath.section];
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
    id data = [[PostadvertControllerV2 sharedPostadvertController] getUserAlbumsWithUserID:[NSString stringWithFormat:@"%ld", userID]];
    if (data) {
        listContent = data;
    }
    
    self.tableView.scrollEnabled = YES;
    data = nil;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}
@end
