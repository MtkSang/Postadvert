//
//  UserProfileComponentViewController.m
//  Stroff
//
//  Created by Ray on 10/23/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "UserProfileComponentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
@interface UserProfileComponentViewController ()

@end

@implementation UserProfileComponentViewController

- (id)init
{
    self = [super initWithNibName:@"UserProfileComponentViewController" bundle:nil];
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    if (style == UITableViewStyleGrouped) {
        self = [super initWithNibName:@"UserProfileComponentViewController_Group" bundle:nil];
    }else
        self = [super initWithNibName:@"UserProfileComponentViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [super viewDidLoad];

    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    footerHUD = [[MBProgressHUD alloc]initWithView:footerView];
    
    footerHUD.hasBackground = NO;
    footerHUD.backgroundColor = [UIColor clearColor];
    footerView.backgroundColor = [UIColor clearColor];
    footerHUD.hidden = YES;
    
    activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //[footerView addSubview:activityView];
    activityView.hidden = YES;
    //self.searchDisplayController.searchResultsTableView.tableFooterView = footerView;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self centerActivityView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self centerActivityView];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
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
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.segmentControl.selectedSegmentIndex = previousIndex;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) centerActivityView
{
    CGPoint centerPoint = self.searchDisplayController.searchResultsTableView.center;
    centerPoint.y = footerView.center.y;
    activityView.center = centerPoint;
}

- (void)viewDidUnload {
    [self setTitle:nil];
    [self setSegmentControl:nil];
    [self setSearchBar:nil];
    [self setShortTitle:nil];
    [self setHeaderView:nil];
    [super viewDidUnload];
}
- (IBAction)segmentControl:(id)sender {
    self.shortTitle.text = [self shortTitleString];
}

- (NSString*) shortTitleString
{
    return [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
}
@end
