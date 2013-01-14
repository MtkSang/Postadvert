//
//  HDBViewController.m
//  Stroff
//
//  Created by Ray on 1/3/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HDBViewController.h"
#import "UIImage+Resize.h"
#import "Constants.h"
@interface HDBViewController ()
- (NSInteger) getInternalItemIDWithItemName:(NSString*)itemName;
- (IBAction) makeKeyBoardGoAway;
- (void) hideKeyboardWhenSwitchViews;
@end

@implementation HDBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.itemName = @"HDB Search";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initAndLoadDataForView];
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
    self.tableView.separatorColor = [UIColor colorWithRed:79.0/255 green:177.0/255 blue:190.0/255 alpha:1];
    //self.tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DCASeprator.png"]];
    
    //SearchBar
    for(UIView *subView in self.searchBar.subviews) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)subView setKeyboardAppearance: UIKeyboardAppearanceAlert];
                [(UITextField *)subView setReturnKeyType:UIReturnKeyDone];
                [(UITextField *)subView setEnablesReturnKeyAutomatically:NO];
            }
            @catch (NSException *exception) {
                
            }
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboardWhenSwitchViews)
                                                 name:@"sideBarUpdate"
                                               object:nil];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLbTitle:nil];
    [self setTableView:nil];
    [self setCellWithSearchBar:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if ([itemName isEqualToString:@"HDB Search"]) {
        if (currentButton == leftButton) {
            internalID = 1;
        }else
            internalID = 2;
    }
    
    return internalID;
}

- (void) initAndLoadDataForView
{
    internalItemID = [self getInternalItemIDWithItemName:self.itemName];
    NSString *plistPathForStaticDCA = [[NSBundle mainBundle] pathForResource:@"DCA" ofType:@"plist"];
    staticData = [NSDictionary dictionaryWithContentsOfFile:plistPathForStaticDCA];
    staticData = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"HDB Search"]];
    NSDictionary *dict;
    NSUserDefaults *database = [[NSUserDefaults alloc]init];
    
    if ((internalItemID % 2) == 1) {
        dict = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Sale"]];
    }else
        dict = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Rent"]];
    switch (internalItemID) {
        case 1:
            //init
            mainFiles = [dict objectForKey:@"Main Fields"];
            moreOptions = [dict objectForKey:@"More Options"];
            searchBy = [dict objectForKey:@"Sort By"];
            filters = [dict objectForKey:@"Filters"];
            
            //load

            mainFilesValues = [database objectForKey:@"Main Fields Values"];
            if (mainFilesValues == nil || mainFilesValues.count == 0 ) {
                mainFilesValues = [[NSMutableArray alloc]initWithObjects:@"Any Type", @"Any Location", @"Any Price", @"Any Size", @"Any", nil];
            }
            
            break; 
            
        default:
        
            break;
    }
}
- (void) keyboardWillBeShown:(NSNotification*) notification
{
    NSDictionary *info = notification.userInfo;
    CGRect frame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.view convertRect:frame fromView:nil];
    
    CGSize contentSize = self.tableView.contentSize;
    contentSize.height = contentSize.height + frame.size.height;
    
    [self.tableView setContentSize:contentSize];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void) keyboardWillBeHidden:(NSNotification*) notification
{
    NSDictionary *info = notification.userInfo;
    CGRect frame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.view convertRect:frame fromView:nil];
    
    CGSize contentSize = self.tableView.contentSize;
    contentSize.height = contentSize.height - frame.size.height;
    
    [self.tableView setContentSize:contentSize];

}
- (void) hideKeyboardWhenSwitchViews
{
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"sideBarUpdate"];
    if (num.integerValue == 1) {
        [self makeKeyBoardGoAway];
    }
}

- (IBAction) makeKeyBoardGoAway
{
    [self.searchBar resignFirstResponder];
}
#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return @"Sort";
    }
    if (section == 3) {
        return @"Filters";
    }
    if (section == 4) {
        return @"Keywords";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return mainFiles.count;
            break;
        case 3:
            return filters.count;
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
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryView.png"] highlightedImage:[UIImage imageNamed:@"accessoryViewSelected.png"]];
            [cell setAccessoryView:imgView];
        }
        
        cell.textLabel.text = [mainFiles objectAtIndex:indexPath.row];
        
        
        cell.detailTextLabel.text = [mainFilesValues objectAtIndex:indexPath.row];
        [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        
        
        return cell;
    }
    
    if ([indexPath section] == 1) {
        static NSString *CellIdentifier2 = @"CellStartUpJobsWithMoreOption";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];

            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            UISwitch *switchBtn = [[UISwitch alloc]init];
            [switchBtn sizeToFit];
            CGRect frame = cell.frame;
            CGRect framebtn = switchBtn.frame;
            framebtn.origin.x = frame.size.width - framebtn.size.width - 20;
            framebtn.origin.y = (cCellHeight - framebtn.size.height) / 2;
            switchBtn.frame = framebtn;
            [switchBtn setOnTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPressed.png"] ]];
            [cell addSubview:switchBtn];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.textLabel.text = @"More Options";
        }
        
        
        return cell;
    }
    if (indexPath.section == 2) {
        static NSString *CellIdentifier3 = @"CellStartUpJobsWithSort";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier3];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryView.png"] highlightedImage:[UIImage imageNamed:@"accessoryViewSelected.png"]];
            [cell setAccessoryView:imgView];

            cell.textLabel.text = @"Sort by";
            cell.detailTextLabel.text = @"Any";
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        }
        
        
        return cell;
    }
    if (indexPath.section == 3) {
        static NSString *CellIdentifier4 = @"CellStartUpJobsWithFilters";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier4];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        
        cell.textLabel.text = [filters objectAtIndex:indexPath.row];        
        
        return cell;
    }
    if (indexPath.section == 4) {
//        static NSString *CellIdentifier5 = @"CellStartUpJobsWithSearchBar";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier5];
//            [cell setBackgroundColor:[UIColor clearColor]];
//            UITextField *searchView = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, cCellHeight)];
//            searchView.backgroundColor = [UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1];
//            [searchView setPlaceholder:@"Search"];
//            cell.backgroundView = [[UIView alloc]init];
//            [cell addSubview:searchView];
//        }
        [self.CellWithSearchBar setBackgroundView:[[UIView alloc] init]];
        return self.CellWithSearchBar;
    }
    
    if (indexPath.section == 5 || indexPath.section == 6) {
        static NSString *CellIdentifier6 = @"CellStartUpJobsWithButton";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier6];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier6];
            UIView *backgroundView = [[UIView alloc]init];
            //[backgroundView setBackgroundColor:[UIColor colorWithRed:90.0/255 green:80.0/255 blue:65.5/255 alpha:1]];
            [cell setBackgroundView:backgroundView];
            
            UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 300, cCellHeight)];
            searchBtn.tag = 1;
            [searchBtn setBackgroundImage:[UIImage imageNamed:@"btnHDBUnormal.png"] forState:UIControlStateNormal];
            [cell addSubview:searchBtn];
        }
        if (indexPath.section == 5) {
            UIButton *searchBtn = (UIButton*)[cell viewWithTag:1];
            [searchBtn setTitle:@"Search" forState:UIControlStateNormal];
        }
        if (indexPath.section == 6) {
            UIButton *searchBtn = (UIButton*)[cell viewWithTag:1];
            [searchBtn setTitle:@"Save & Search" forState:UIControlStateNormal];
        }
        
        return cell;
    }
    
    if (indexPath.section == 7) {
        static NSString *CellIdentifier7 = @"CellStartUpJobsWithButton";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier7];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier7];
            UIView *backgroundView = [[UIView alloc]init];
            //[backgroundView setBackgroundColor:[UIColor colorWithRed:43.0/255 green:145.0/255 blue:158.0/255 alpha:1]];
            [cell setBackgroundView:backgroundView];
            
            UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 300, cCellHeight)];
            searchBtn.tag = 1;
            [searchBtn setBackgroundImage:[UIImage imageNamed:@"btnResetHDBnormal.png"] forState:UIControlStateNormal];
            [searchBtn setTitle:@"Reset" forState:UIControlStateNormal];
            [cell addSubview:searchBtn];
        }
        
        return cell;
    }
    return nil;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cCellHeight;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
