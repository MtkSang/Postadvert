//
//  HDBViewController.m
//  Stroff
//
//  Created by Ray on 1/3/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HDBViewController.h"
#import "UIImage+Resize.h"
@interface HDBViewController ()
- (NSInteger) getInternalItemIDWithItemName:(NSString*)itemName;
@end

@implementation HDBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //
    UIImage *image = [UIImage imageNamed:@"titleHDB.png"];
    image = [image resizedImage:self.lbTitle.frame.size interpolationQuality:0];
    [self.lbTitle setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    //setupTabelHeader
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    headerView.backgroundColor = [UIColor colorWithRed:57.0/255 green:60.0/255.0 blue:38.0/255 alpha:1];
    
    leftButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, 149, 30)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"leftPressed.png"]  forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"Sale" forState:UIControlStateNormal];
    rightButton = [[UIButton alloc]initWithFrame:CGRectMake(161, 5, 149, 30)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"rightUnPress.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"Rent" forState:UIControlStateNormal];
    currentButton = leftButton;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(20, 5, 280, 30)];
    view.backgroundColor = [UIColor colorWithRed:183.0/255 green:220.0/255 blue:223.0/255 alpha:1];
    [headerView addSubview:view];
    [headerView addSubview:leftButton];
    [headerView addSubview:rightButton];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLbTitle:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma button
- (void) btnClicked:(id) sender
{
    if (sender == currentButton) {
        return;
    }else
        currentButton = sender;
    if (currentButton == leftButton) {
        [leftButton setBackgroundImage:[UIImage imageNamed:@"leftPressed.png"]  forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"rightUnPress.png"] forState:UIControlStateNormal];
    }else
    {
        //rightButton
        [leftButton setBackgroundImage:[UIImage imageNamed:@"leftUnPress.png"]  forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"rightPressed.png"] forState:UIControlStateNormal];
    }
}

#pragma implement

- (NSInteger) getInternalItemIDWithItemName:(NSString*)itemName
{
    NSInteger internalID = 0;
    if ([itemName isEqualToString:@""]) {
        internalID = 1;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
            break;
            
        default:
            return 1;
            break;
    }
    
    return 01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier1 = @"CellStartUpJobsWithOption";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
        }
        
        cell.textLabel.text = @"Option";
        
        cell.detailTextLabel.text = @"Value";
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
    }
    
    if ([indexPath section] == 1) {
        static NSString *CellIdentifier2 = @"CellStartUpJobsWithSearch";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        }
        
        
        return cell;
    }
    return nil;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
