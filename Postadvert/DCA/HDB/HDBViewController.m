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
#import "DCAPickerViewController.h"
#import "TDSemiModal.h"
#import "DCAOptionsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HDBListResultViewController.h"
#import "PostadvertControllerV2.h"
//#import "MyModalViewController.h"
//#import "UIViewController+MyModalView.h"
//#import "MyViewController.h"

//#import "SideBarViewController.h"
@interface HDBViewController ()
- (NSInteger) getInternalItemIDWithItemName:(NSString*)itemName;
- (IBAction) makeKeyBoardGoAway;
- (void) hideKeyboardWhenSwitchViews;
- (IBAction)moreOptionChangeValue:(id)sender;
- (void) reloadInternalID;
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
    [self.lbTitle setText:self.itemName];
    
    //setupTabelHeader
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    headerView.backgroundColor = [UIColor colorWithRed:57.0/255 green:60.0/255.0 blue:38.0/255 alpha:1];
    
    leftButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, 149, 30)];
//    [leftButton setBackgroundImage:[UIImage imageNamed:@"leftPressed.png"]  forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"Sale" forState:UIControlStateNormal];
    rightButton = [[UIButton alloc]initWithFrame:CGRectMake(161, 5, 149, 30)];
//    [rightButton setBackgroundImage:[UIImage imageNamed:@"rightUnPress.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"Rent" forState:UIControlStateNormal];
    currentButton = leftButton;
    [self updateButtonSelected];
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
    //TapGesture
    
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    

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
    @try {
        return;
        switch (internalItemID) {
            case 1:
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                break;
            case 2:
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                break;
            case 101:
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                break;
                
            case 102:
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                break;
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
- (void) updateButtonSelected
{
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
- (void) btnClicked:(id) sender
{
    if (sender == currentButton) {
        return;
    }else
        currentButton = sender;
    [self performSelectorOnMainThread:@selector(updateButtonSelected) withObject:nil waitUntilDone:NO];
    //Update value for sort by

    NSArray *array = [sortByValue componentsSeparatedByString:@" ("];
    NSString *string = [array objectAtIndex:0];
    if ([string isEqualToString:@"Price"]) {
        sortByValue = [sortByValue stringByReplacingOccurrencesOfString:@"Price" withString:@"Monthly Rental"];
    }
    if ([string isEqualToString:@"Monthly Rental"]) {
        sortByValue = [sortByValue stringByReplacingOccurrencesOfString:@"Monthly Rental" withString:@"Price"];
    }
    
    //Save data
    [self initAndLoadDataForView];
    //load data
    [self.tableView reloadData];
}

#pragma implement

- (NSInteger) getInternalItemIDWithItemName:(NSString*)itemName
{
    NSInteger internalID = 0;
    if ([itemName isEqualToString:@"HDB Search"]) {
        if (currentButton == leftButton) {
            if (isMoreOptionOn) {
                internalID = 101;//sale on
            }
            else
                internalID = 1;//sale off
        }else
            if (isMoreOptionOn) {
                internalID = 102;//rent on
            }else
                internalID = 2;//rent off
    }
    
    if ([itemName isEqualToString:@"Condos Search"]) {
        if (currentButton == leftButton) {
            if (isMoreOptionOn) {
                internalID = 103;//sale on
            }
            else
                internalID = 3;//sale off
        }else
            if (isMoreOptionOn) {
                internalID = 104;//rent on
            }else
                internalID = 4;//rent off
    }
    
    if ([itemName isEqualToString:@"Landed Property Search"]) {
        if (currentButton == leftButton) {
            if (isMoreOptionOn) {
                internalID = 105;//sale on
            }
            else
                internalID = 5;//sale off
        }else
            if (isMoreOptionOn) {
                internalID = 106;//rent on
            }else
                internalID = 6;//rent off
    }
    
    return internalID;
}

- (void) initAndLoadDataForView
{
    [self saveCurrentValues];
    internalItemID = [self getInternalItemIDWithItemName:self.itemName];
    NSString *plistPathForStaticDCA = [[NSBundle mainBundle] pathForResource:@"DCA" ofType:@"plist"];
    staticData = [NSDictionary dictionaryWithContentsOfFile:plistPathForStaticDCA];
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        staticData = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"HDB Search"]];
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        staticData = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Condos Search"]];
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        staticData = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Landed Property Search"]];
    }
    NSDictionary *dict;
    //NSUserDefaults *database = [[NSUserDefaults alloc]init];
    
    if ((internalItemID % 2) == 1) {
        dict = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Sale"]];
    }else
        dict = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Rent"]];
    switch (internalItemID % 2) {
        case 1:
            //init
            mainFiles = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"Main Fields"]];
            moreOptions = [dict objectForKey:@"More Options"];
            sortByData = [dict objectForKey:@"Sort By"];
            sortByDataV2 = [dict objectForKey:@"Sort By V2"];
            sortByDataV3 = [dict objectForKey:@"Sort By V3"];
            
            filters = [dict objectForKey:@"Filters"];
            
            //load

            
            //if (mainFilesValues == nil || mainFilesValues.count == 0 ) {
                mainFilesValues = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"DefaultValues"]];
//                mainFilesValues = [database objectForKey:@"Main Fields Values"];
//                mainFilesValues = [[NSMutableArray alloc]initWithObjects:@"Any", @"Any", @"Any", @"Any", @"Any",@"Any", @"Any", @"Any", @"Any", @"Any", @"Select One",@"Select One", @"Any", @"Any", @"Any", nil];
                sortByValue = @"Any";
            //}
            
            break; 
        case 0:
            //init
            mainFiles = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"Main Fields"]];
            moreOptions = [dict objectForKey:@"More Options"];
            sortByData = [dict objectForKey:@"Sort By"];
            sortByDataV2 = [dict objectForKey:@"Sort By V2"];
            sortByDataV3 = [dict objectForKey:@"Sort By V3"];
            filters = [dict objectForKey:@"Filters"];
            
            //load
            
            
            //if (mainFilesValues == nil || mainFilesValues.count == 0 ) {
                mainFilesValues = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"DefaultValues"]];
//                mainFilesValues = [database objectForKey:@"Main Fields Values"];
//                mainFilesValues = [[NSMutableArray alloc]initWithObjects:@"Any", @"Any", @"Any", @"Any", @"Any",@"Any", @"Any", @"Any", @"Any", @"Any", @"Select One",@"Select One", @"Any", @"Any", @"Any", nil];
                sortByValue = @"Any";
            //}

        default:
        
            break;
    }
    //
    if (! sortByValue && sortByValue.length) {
        sortByValue =@"Any";
    }
    if (isMoreOptionOn) {
        [mainFiles addObjectsFromArray:moreOptions];
    }
    [self loadValues];
}

- (void) resetBtnClicked:(id) sender
{
    internalItemID = [self getInternalItemIDWithItemName:self.itemName];
    NSString *plistPathForStaticDCA = [[NSBundle mainBundle] pathForResource:@"DCA" ofType:@"plist"];
    staticData = [NSDictionary dictionaryWithContentsOfFile:plistPathForStaticDCA];
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        staticData = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"HDB Search"]];
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        staticData = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Condos Search"]];
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        staticData = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Landed Property Search"]];
    }
    NSDictionary *dict;
    if ((internalItemID % 2) == 1) {
        dict = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Sale"]];
    }else
        dict = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Rent"]];
    switch (internalItemID % 2) {
        case 1:
            //init
            mainFiles = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"Main Fields"]];
            moreOptions = [dict objectForKey:@"More Options"];
            sortByData = [dict objectForKey:@"Sort By"];
            sortByDataV2 = [dict objectForKey:@"Sort By V2"];
            sortByDataV3 = [dict objectForKey:@"Sort By V3"];
            filters = [dict objectForKey:@"Filters"];
            
            //load
                mainFilesValues = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"DefaultValues"]];
                sortByValue = @"Any";
            
            break;
        case 0:
            //init
            mainFiles = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"Main Fields"]];
            moreOptions = [dict objectForKey:@"More Options"];
            sortByData = [dict objectForKey:@"Sort By"];
            sortByDataV2 = [dict objectForKey:@"Sort By V2"];
            sortByDataV3 = [dict objectForKey:@"Sort By V3"];
            filters = [dict objectForKey:@"Filters"];
            
            //load
                mainFilesValues = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"DefaultValues"]];
                sortByValue = @"Any";
        default:
            
            break;
    }
    //
    if (! sortByValue && sortByValue.length) {
        sortByValue =@"Any";
    }
    if (isMoreOptionOn) {
        [mainFiles addObjectsFromArray:moreOptions];
    }
//    else
//    {
//        //reset more option
//        NSUserDefaults *database = [NSUserDefaults standardUserDefaults];
//        NSUInteger index = mainFiles.count;
//        NSString *key = @"";
//        id value =@"";
//        while (index < mainFiles.count + moreOptions.count) {
//            key = [moreOptions objectAtIndex:index - mainFiles.count];
//            value = [mainFilesValues objectAtIndex:index];
//            [database setValue:value forKey:key];
//            index ++;
//        }
//    }
    [self saveCurrentValues];
    
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.03];
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

- (IBAction)moreOptionChangeValue:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *switchBtn = (UISwitch*)sender;
        isMoreOptionOn = [switchBtn isOn];
        [self initAndLoadDataForView];
        //[self reloadInternalID];
        [self.tableView reloadData];
    }
}
- (void) reloadInternalID
{
    internalItemID = [self getInternalItemIDWithItemName:self.itemName];
}

- (void) saveCurrentValues
{
    //save
    if (mainFilesValues && mainFilesValues.count) {
        NSUserDefaults *database = [NSUserDefaults standardUserDefaults];
        NSUInteger index = 0;
        NSString *key = @"";
        id value =@"";
        while (index < mainFiles.count) {
            key = [mainFiles objectAtIndex:index];
            value = [mainFilesValues objectAtIndex:index];
            [database setValue:value forKey:key];
            index ++;
        }
    }
    
    if (!isMoreOptionOn && (mainFilesValues.count > mainFiles.count))
    {
        //reset more option
        NSUserDefaults *database = [NSUserDefaults standardUserDefaults];
        NSUInteger index = mainFiles.count;
        NSString *key = @"";
        id value = @"";
        while (index < mainFiles.count + moreOptions.count) {
            key = [moreOptions objectAtIndex:index - mainFiles.count];
            value = [mainFilesValues objectAtIndex:index];
            [database setValue:value forKey:key];
            index ++;
        }
    }
    // Sort by
    if ([sortByValue isEqualToString:@"Any"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"Any" forKey:@"Sort By V3"];
    }else
    {
        NSInteger index = [sortByData indexOfObject:sortByValue];
        if (index == NSIntegerMax) {
            index = 0;
        }
        NSString *value = [sortByDataV3 objectAtIndex:index];
        [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"Sort By V3"];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:sortByValue forKey:@"Sort By"];
    
    
}
- (void) loadValues
{
    while (mainFilesValues.count < mainFiles.count) {
        [mainFilesValues addObject:@""];
    }
    if (mainFilesValues && mainFilesValues.count) {
        NSUserDefaults *database = [NSUserDefaults standardUserDefaults];
        NSUInteger index = 0;
        NSString *key = @"";
        id value =@"";
        while (index < mainFiles.count) {
            key = [mainFiles objectAtIndex:index];
            value = [database valueForKey:key];
            if (value) {
                [mainFilesValues replaceObjectAtIndex:index withObject:value];
            }else
            {
                NSDictionary *dict;
                if ((internalItemID % 2) == 1) {
                    dict = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Sale"]];
                }else
                    dict = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"Rent"]];
                NSArray *defaultValues = [dict objectForKey:@"DefaultValues"];
                [mainFilesValues replaceObjectAtIndex:index withObject:[defaultValues objectAtIndex:index]];
            }
            index ++;
        }
    }
}
- (NSInteger) getIndexForSortBy
{
    NSInteger index = 0;
    NSArray *array = [sortByValue componentsSeparatedByString:@" "];
    NSString *fristValue = [array objectAtIndex:0];
    if ([fristValue isEqualToString:@"Date"]) {
        
    }
    return index;
}

- (IBAction)searchBtnClicked:(id)sender
{
    HDBListResultViewController *resultVctr = [[HDBListResultViewController alloc]init];
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"start"];
    if (currentButton == leftButton) {
        [[NSUserDefaults standardUserDefaults] setValue:@"s" forKey:@"property_status"];
    }else
        [[NSUserDefaults standardUserDefaults] setValue:@"r" forKey:@"property_status"];
    [self saveCurrentValues];
    [[NSUserDefaults standardUserDefaults] setValue:@"up" forKey:@"scroll"];
    resultVctr.itemName = self.itemName;
    [self.navigationController pushViewController:resultVctr animated:YES];
    
    UIButton *btn = (UIButton*) sender;
    if ( [btn.titleLabel.text isEqualToString:@"Search"]) {
        
    }
}


#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (isMoreOptionOn) {
        if (section == 2) {
            return @"Sort";
        }
        if (section == 3) {
            return @"Filters";
        }
        if (section == 4) {
            return @"Keywords";
        }
    }else
    {
        
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isMoreOptionOn) {
        return 8;
    }
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isMoreOptionOn) {
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
    }else
    {
        switch (section) {
            case 0:
                return mainFiles.count;
                break;
            default:
                return 1;
                break;
        }
    }
    
    
    return 01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma mark . item = 1, 3, 5
    if (internalItemID == 1 || internalItemID == 3 || internalItemID == 5) {// SALE off
        if (indexPath.section == 0) {
            static NSString *CellIdentifier1 = @"CellStartUpJobsWithOption";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
                [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
                [cell.textLabel setTextColor:[UIColor whiteColor]];
                [cell.detailTextLabel setTextColor:[UIColor blackColor]];
                [cell.detailTextLabel setNumberOfLines:2];
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryView.png"] highlightedImage:[UIImage imageNamed:@"accessoryViewSelected.png"]];
                imgView.tag = indexPath.row;
                imgView.userInteractionEnabled = YES;
                UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
                gesture.numberOfTapsRequired = 1;
                [imgView addGestureRecognizer:gesture];
                [cell bringSubviewToFront:imgView];
                [cell setAccessoryView:imgView];
            }
            
            cell.textLabel.text = [mainFiles objectAtIndex:indexPath.row];            
            cell.detailTextLabel.text = [mainFilesValues objectAtIndex:indexPath.row];
            [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
            if ([cell.detailTextLabel.text isEqualToString:@"Any"] || [cell.detailTextLabel.text isEqualToString:@"Select One"]) {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                }
                //cell.detailTextLabel.text = @"Any";
            }
            else
            {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"eraseIcon.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"eraseIcon.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                    [cell bringSubviewToFront:accessoryView];
                }
            }

            
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
                [switchBtn addTarget:self action:@selector(moreOptionChangeValue:) forControlEvents:UIControlEventValueChanged];
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
//        if (indexPath.section == 2) {
//            //        static NSString *CellIdentifier5 = @"CellStartUpJobsWithSearchBar";
//            //        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5];
//            //        if (cell == nil) {
//            //            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier5];
//            //            [cell setBackgroundColor:[UIColor clearColor]];
//            //            UITextField *searchView = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, cCellHeight)];
//            //            searchView.backgroundColor = [UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1];
//            //            [searchView setPlaceholder:@"Search"];
//            //            cell.backgroundView = [[UIView alloc]init];
//            //            [cell addSubview:searchView];
//            //        }
//            [self.CellWithSearchBar setBackgroundView:[[UIView alloc] init]];
//            return self.CellWithSearchBar;
//        }
        
        if (indexPath.section == 2 || indexPath.section == 3) {
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
            UIButton *searchBtn = (UIButton*)[cell viewWithTag:1];
            if (indexPath.section == 2) {
                [searchBtn setTitle:@"Search" forState:UIControlStateNormal];
            }
            if (indexPath.section == 3) {
                
                [searchBtn setTitle:@"Save & Search" forState:UIControlStateNormal];
            }
            [searchBtn addTarget:self action:@selector(searchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        
        if (indexPath.section == 4) {
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
                
                [searchBtn addTarget:self action:@selector(resetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:searchBtn];
            }
            UIButton *searchBtn = (UIButton*) [cell viewWithTag:1];
            [searchBtn setTitle:@"Reset" forState:UIControlStateNormal];
            return cell;
        }
    }
//////////////////////////////////////////////////////////////////
#pragma mark . item = 2, 4, 6
    if (internalItemID == 2 || internalItemID == 4 || internalItemID == 6) {// RENT off
        if (indexPath.section == 0) {
            static NSString *CellIdentifier1 = @"CellStartUpJobsWithOption";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
                [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
                [cell.textLabel setTextColor:[UIColor whiteColor]];
                [cell.detailTextLabel setTextColor:[UIColor blackColor]];
                [cell.detailTextLabel setNumberOfLines:2];
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryView.png"] highlightedImage:[UIImage imageNamed:@"accessoryViewSelected.png"]];
                imgView.tag = indexPath.row;
                imgView.userInteractionEnabled = YES;
                UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
                gesture.numberOfTapsRequired = 1;
                [imgView addGestureRecognizer:gesture];
                [cell bringSubviewToFront:imgView];
                [cell setAccessoryView:imgView];
            }
            
            cell.textLabel.text = [mainFiles objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [mainFilesValues objectAtIndex:indexPath.row];
            [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
            if ([cell.detailTextLabel.text isEqualToString:@"Any"] || [cell.detailTextLabel.text isEqualToString:@"Select One"]) {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                }
                //cell.detailTextLabel.text = @"Any";
            }
            else
            {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"eraseIcon.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"eraseIcon.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                    [cell bringSubviewToFront:accessoryView];
                }
            }
            
            
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
                [switchBtn addTarget:self action:@selector(moreOptionChangeValue:) forControlEvents:UIControlEventValueChanged];
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
//        if (indexPath.section == 2) {
//            //        static NSString *CellIdentifier5 = @"CellStartUpJobsWithSearchBar";
//            //        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5];
//            //        if (cell == nil) {
//            //            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier5];
//            //            [cell setBackgroundColor:[UIColor clearColor]];
//            //            UITextField *searchView = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, cCellHeight)];
//            //            searchView.backgroundColor = [UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1];
//            //            [searchView setPlaceholder:@"Search"];
//            //            cell.backgroundView = [[UIView alloc]init];
//            //            [cell addSubview:searchView];
//            //        }
//            [self.CellWithSearchBar setBackgroundView:[[UIView alloc] init]];
//            return self.CellWithSearchBar;
//        }
        
        if (indexPath.section == 2 || indexPath.section == 3) {
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
            if (indexPath.section == 2) {
                UIButton *searchBtn = (UIButton*)[cell viewWithTag:1];
                [searchBtn setTitle:@"Search" forState:UIControlStateNormal];
            }
            if (indexPath.section == 3) {
                UIButton *searchBtn = (UIButton*)[cell viewWithTag:1];
                [searchBtn setTitle:@"Save & Search" forState:UIControlStateNormal];
            }
            
            return cell;
        }
        
        if (indexPath.section == 4) {
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
                [searchBtn addTarget:self action:@selector(resetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:searchBtn];
            }
            UIButton *searchBtn = (UIButton*)[cell viewWithTag:1];
            [searchBtn setTitle:@"Reset" forState:UIControlStateNormal];
            return cell;
        }
    }
    
//  //////////////////////////////////////////////////////
#pragma mark . item = 101, 103, 105
    if (internalItemID == 101 || internalItemID == 103 || internalItemID == 105) { //Sale on
        if (indexPath.section == 0) {
            static NSString *CellIdentifier1 = @"CellStartUpJobsWithOption";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
                [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
                [cell.textLabel setTextColor:[UIColor whiteColor]];
                [cell.detailTextLabel setTextColor:[UIColor blackColor]];
                [cell.detailTextLabel setNumberOfLines:2];
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryView.png"] highlightedImage:[UIImage imageNamed:@"accessoryViewSelected.png"]];
                imgView.tag = 1;
                imgView.userInteractionEnabled = YES;
                UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
                gesture.numberOfTapsRequired = 1;
                [imgView addGestureRecognizer:gesture];
                [cell bringSubviewToFront:imgView];
                [cell setAccessoryView:imgView];
            }
            
            cell.textLabel.text = [mainFiles objectAtIndex:indexPath.row];
            
            
            cell.detailTextLabel.text = [mainFilesValues objectAtIndex:indexPath.row];
            [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
            if ([cell.detailTextLabel.text isEqualToString:@"Any"] || [cell.detailTextLabel.text isEqualToString:@"Select One"]) {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                }
            }
            else
            {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"eraseIcon.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"eraseIcon.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                    [cell bringSubviewToFront:accessoryView];
                }
            }
            
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
                [switchBtn addTarget:self action:@selector(moreOptionChangeValue:) forControlEvents:UIControlEventValueChanged];
                [switchBtn sizeToFit];
                [switchBtn setOn:YES animated:YES];
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
                imgView.tag = 1;
                imgView.userInteractionEnabled = YES;
                UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
                gesture.numberOfTapsRequired = 1;
                [imgView addGestureRecognizer:gesture];
                [cell setAccessoryView:imgView];
                
                cell.textLabel.text = @"Sort by";
                [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            }
            if (![sortByValue isEqualToString:@"Any"] ) {
                NSInteger index = 0;
                index = [sortByData indexOfObject:sortByValue];
                cell.detailTextLabel.text = [sortByDataV2 objectAtIndex:index];
                // add delete icon here
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"eraseIcon.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"eraseIcon.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                }
            }else
            {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                }
                cell.detailTextLabel.text = @"Any";
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
                //[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
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
    }
    
    //  //////////////////////////////////////////////////////
#pragma mark . item = 102, 104, 106
    if (internalItemID == 102 || internalItemID == 104 || internalItemID == 106) { //Rent on
        if (indexPath.section == 0) {
            static NSString *CellIdentifier1 = @"CellStartUpJobsWithOption";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
                [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
                [cell.textLabel setTextColor:[UIColor whiteColor]];
                [cell.detailTextLabel setTextColor:[UIColor blackColor]];
                [cell.detailTextLabel setNumberOfLines:2];
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryView.png"] highlightedImage:[UIImage imageNamed:@"accessoryViewSelected.png"]];
                imgView.tag = 1;
                imgView.userInteractionEnabled = YES;
                UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
                gesture.numberOfTapsRequired = 1;
                [imgView addGestureRecognizer:gesture];
                [cell bringSubviewToFront:imgView];
                [cell setAccessoryView:imgView];
            }
            
            cell.textLabel.text = [mainFiles objectAtIndex:indexPath.row];
            
            
            cell.detailTextLabel.text = [mainFilesValues objectAtIndex:indexPath.row];
            [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
            if ([cell.detailTextLabel.text isEqualToString:@"Any"] || [cell.detailTextLabel.text isEqualToString:@"Select One"]) {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                }
            }
            else
            {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"eraseIcon.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"eraseIcon.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                    [cell bringSubviewToFront:accessoryView];
                }
            }
            
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
                [switchBtn addTarget:self action:@selector(moreOptionChangeValue:) forControlEvents:UIControlEventValueChanged];
                [switchBtn sizeToFit];
                [switchBtn setOn:YES animated:YES];
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
                imgView.tag = 1;
                imgView.userInteractionEnabled = YES;
                UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
                gesture.numberOfTapsRequired = 1;
                [imgView addGestureRecognizer:gesture];
                [cell setAccessoryView:imgView];
                
                cell.textLabel.text = @"Sort by";
                [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            }
            if (![sortByValue isEqualToString:@"Any"] ) {
                NSInteger index = 0;
                index = [sortByData indexOfObject:sortByValue];
                cell.detailTextLabel.text = [sortByDataV2 objectAtIndex:index];
                // add delete icon here
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"eraseIcon.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"eraseIcon.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                }
            }else
            {
                UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                    [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                }
                cell.detailTextLabel.text = @"Any";
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
                //[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
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
            UIButton *searchBtn = (UIButton*)[cell viewWithTag:1];
            [searchBtn setTitle:@"Reset" forState:UIControlStateNormal];
            return cell;
        }
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
- (void) accessoryClicked:(UITapGestureRecognizer*) tapGesture_
{
    NSIndexPath *indexPath;
    UIView *view = tapGesture_.view;
    UITableViewCell *cell = (UITableViewCell*) view.superview;
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:cell];
    }
    
    if (indexPath.section == 0 && (indexPath.row < mainFiles.count)) {
        UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
        if (![cell.detailTextLabel.text isEqualToString:@"Any"] ) {
            if (accessoryView) {
                accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                CGRect frame = accessoryView.frame;
                frame.size = CGSizeMake(30, 30);
                [accessoryView setFrame:frame];
            }
            cell.detailTextLabel.text = @"Any";
            [mainFilesValues replaceObjectAtIndex:indexPath.row withObject:@"Any"];
            if ([cell.textLabel.text isEqualToString:@"Furnishing"] || [cell.textLabel.text isEqualToString:@"Condition"]) {
                cell.detailTextLabel.text = @"Select One";
                [mainFilesValues replaceObjectAtIndex:indexPath.row withObject:@"Select One"];
            }
            
        }else
        {
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
    ////////
    if (internalItemID == 101 || internalItemID == 102) {
        if (indexPath.section == 2) {
            UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
            if (![sortByValue isEqualToString:@"Any"] ) {
                if (accessoryView) {
                    accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                    accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                    CGRect frame = accessoryView.frame;
                    frame.size = CGSizeMake(30, 30);
                    [accessoryView setFrame:frame];
                }
                cell.detailTextLabel.text = @"Any";
                sortByValue = @"Any";
            }else
            {
                [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            }
            return;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self makeKeyBoardGoAway];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
#pragma mark - HDB Search
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // HDB Type
    if ([cell.textLabel.text isEqualToString:@"HDB Type"]) {
        NSArray *hdbTypeData = [staticData objectForKey:@"PropertyType"];
        NSInteger selectedIndex = -1;
        NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
        if (![hdbType isEqualToString:@"Any"]) {
            selectedIndex = [hdbTypeData indexOfObject:hdbType];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCAOptionsPropertyType selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
    
    //HDB Estate
    if ([cell.textLabel.text isEqualToString:@"HDB Estate"]) {
        NSArray *HDBEstateData = [staticData objectForKey:@"HDBEstate"];
        NSString *hdbEstateString = [mainFilesValues objectAtIndex:1];
        NSArray *array = [hdbEstateString componentsSeparatedByString:@", "];
        if ([hdbEstateString isEqualToString:@"Any"]) {
            array = nil;
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:HDBEstateData DCAOptionType:DCAOptionSHDBEstate selectedValues:array];
        dcaOptionViewCtr.multiSelect = YES;
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
    
    // Sort by
    if ([cell.textLabel.text isEqualToString:@"Sort by"]) {
        NSInteger selectedIndex = -1;
        if (![sortByValue isEqualToString:@"Any"]) {
            selectedIndex = [sortByData indexOfObject:sortByValue];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:sortByData DCAOptionType:DCAOptionsSortBy selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
    }
    //Filters
    if ([[self tableView:tableView titleForHeaderInSection:indexPath.section] isEqualToString:@"Filters"]) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    //if (internalItemID == 1 || internalItemID == 101) {
    if (indexPath.section == 0) {
        if ([cell.textLabel.text isEqualToString:@"Price"] || [cell.textLabel.text isEqualToString:@"Monthly Rental"] || [cell.textLabel.text isEqualToString:@"Size"] || [cell.textLabel.text isEqualToString:@"Bedrooms"] || [cell.textLabel.text isEqualToString:@"Val'n Price"] || [cell.textLabel.text isEqualToString:@"Washrooms"] || [cell.textLabel.text isEqualToString:@"Constructed"] || [cell.textLabel.text isEqualToString:@"PSF"] || [cell.textLabel.text isEqualToString:@"Lease Term"]) {
            NSString *value = [mainFilesValues objectAtIndex:indexPath.row];
            value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            NSArray *array = [value componentsSeparatedByString:@" to "];
            NSInteger start = 0;
            NSInteger end = 0;
            UIDCAPickerControllerSourceType sourceType = pickerTypeUnknow;
           
            NSArray *listValues;
            //Price
            if ([cell.textLabel.text isEqualToString:@"Price"]) {
               listValues = [staticData objectForKey:@"Price"];
                sourceType = pickerTypePrice;
            }
            //Monthly Rental
            if ([cell.textLabel.text isEqualToString:@"Monthly Rental"]) {
                listValues = [staticData objectForKey:@"Price"];
                sourceType = pickerTypePrice;
            }
            //Size
            if ([cell.textLabel.text isEqualToString:@"Size"]) {
                listValues = [staticData objectForKey:@"Size"];
                sourceType = pickerTypeSize;
            }
            //Bedrooms
            if ([cell.textLabel.text isEqualToString:@"Bedrooms"]) {
                listValues = [staticData objectForKey:@"Bedrooms"];
                sourceType = pickerTypeBedrooms;
            }
            // Val'n Price
            if ([cell.textLabel.text isEqualToString:@"Val'n Price"]) {
                listValues = [staticData objectForKey:@"Price"];
                sourceType = pickerTypeValnSize;
            }
            //Washrooms
            if ([cell.textLabel.text isEqualToString:@"Washrooms"]) {
                listValues = [staticData objectForKey:@"Washrooms"];
                sourceType = pickerTypeWashrooms;
            }
            //Constructed
            if ([cell.textLabel.text isEqualToString:@"Constructed"]) {
                listValues = [staticData objectForKey:@"Constructed"];
                sourceType = pickerTypeConstructed;
            }
            //PSF
            if ([cell.textLabel.text isEqualToString:@"PSF"]) {
                listValues = [staticData objectForKey:@"PSF"];
                sourceType = pickerTypePSF;
            }
            //Lease Term
            if ([cell.textLabel.text isEqualToString:@"Lease Term"]) {
                listValues = [staticData objectForKey:@"LeaseTerm"];
                sourceType = pickerTypeLeaseTerm;
            }
            if (array.count == 1) {
                array = [value componentsSeparatedByString:@" and "];
                if (array.count == 1) {
                    if ([[array objectAtIndex:0] isEqual:@"Any"]) {
                        start = -1;
                        end = -1;
                    }
                    else
                    {
                        end = [listValues indexOfObject:[array objectAtIndex:0] ];
                        start = end;
                    }
                    
                }
                
            }
            if (array.count >=2) {
                start = [listValues indexOfObject:[array objectAtIndex:0] ];
                end = [listValues indexOfObject:[array objectAtIndex:1]];
                if ([[array objectAtIndex:1] isEqual:@"above"]) {
                    end = -1;
                }
                if ([[array objectAtIndex:1] isEqual:@"below"]) {
                    end = start;
                    start = -1;
                }
            }
            
            picker = [[DCAPickerViewController alloc]initWithArray: listValues andSourceType:sourceType startIndex:start endIndex:end];
            picker.delegate = self;
            [self presentSemiModalViewController:picker];
            return;
        }
    }
    //}
    
    
    //Add Owner
    if ([cell.textLabel.text isEqualToString:@"Ad Owner"]) {
        NSArray *array = [staticData objectForKey:@"AdOwner"];
        NSInteger selectedIndex = -1;
        if (![cell.detailTextLabel.text isEqualToString:@"Any"]) {
            selectedIndex = [array indexOfObject:cell.detailTextLabel.text];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:array DCAOptionType:DCAOptionAdOwner selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
    //Add Owner
    if ([cell.textLabel.text isEqualToString:@"Unit Level"]) {
        NSArray *array = [staticData objectForKey:@"UnitLevel"];
        NSInteger selectedIndex = -1;
        if (![cell.detailTextLabel.text isEqualToString:@"Any"]) {
            selectedIndex = [array indexOfObject:cell.detailTextLabel.text];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:array DCAOptionType:DCAOptionUnitLevel selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
    
    //Furnishing
    if ([cell.textLabel.text isEqualToString:@"Furnishing"]) {
        NSArray *array = [staticData objectForKey:@"Furnishing"];
        NSInteger selectedIndex = -1;
        if (![cell.detailTextLabel.text isEqualToString:@"Any"] && ![cell.detailTextLabel.text isEqualToString:@"Select One"]) {
            selectedIndex = [array indexOfObject:cell.detailTextLabel.text];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:array DCAOptionType:DCAOptionFurnishing selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
    
    //Furnishing
    if ([cell.textLabel.text isEqualToString:@"Condition"]) {
        NSArray *array = [staticData objectForKey:@"Condition"];
        NSInteger selectedIndex = -1;
        if (![cell.detailTextLabel.text isEqualToString:@"Any"] && ![cell.detailTextLabel.text isEqualToString:@"Select One"]) {
            selectedIndex = [array indexOfObject:cell.detailTextLabel.text];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:array DCAOptionType:DCAOptionCondition selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
    
#pragma mark - Condos Search
//    // Project Name
    if ([cell.textLabel.text isEqualToString:@"Project Name"]) {
        NSArray *hdbTypeData = [staticData objectForKey:@"Project Name"];
        NSInteger selectedIndex = -1;
        NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
        if (![hdbType isEqualToString:@"Any"]) {
            selectedIndex = [hdbTypeData indexOfObject:hdbType];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCAOptionCondosProjectName selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }

    if ([cell.textLabel.text isEqualToString:@"Reset"]) {
        [self resetBtnClicked:nil];
    }
    //    // District
    if ([cell.textLabel.text isEqualToString:@"District"]) {
        NSArray *HDBEstateData = [staticData objectForKey:@"District"];
        NSString *hdbEstateString = [mainFilesValues objectAtIndex:1];
        NSArray *array = [hdbEstateString componentsSeparatedByString:@", "];
        if ([hdbEstateString isEqualToString:@"Any"]) {
            array = nil;
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:HDBEstateData DCAOptionType:DCAOptionCondosDistrict selectedValues:array];
        dcaOptionViewCtr.multiSelect = YES;
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
//    //Tenure
    if ([cell.textLabel.text isEqualToString:@"Tenure"]) {
        NSArray *hdbTypeData = [staticData objectForKey:@"Tenure"];
        NSInteger selectedIndex = -1;
        NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
        if (![hdbType isEqualToString:@"Any"]) {
            selectedIndex = [hdbTypeData indexOfObject:hdbType];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCAOptionCondosTenure selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
    if ([cell.textLabel.text isEqualToString:@"Reset"]) {
        [self resetBtnClicked:nil];
    }

}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [[NSUserDefaults standardUserDefaults] setValue:searchText forKey:@"keyWorlds"];
}
#pragma mark -
#pragma mark DCAPickerViewController Delegate

- (void) didPickerCloseWithControll:(DCAPickerViewController *)ctr
{
    if (ctr.sourceType == pickerTypePrice || ctr.sourceType == pickerTypeBedrooms || ctr.sourceType == pickerTypeSize || ctr.sourceType == pickerTypeValnSize || ctr.sourceType == pickerTypeWashrooms || ctr.sourceType == pickerTypeConstructed || ctr.sourceType == pickerTypePSF || ctr.sourceType == pickerTypeLeaseTerm) {
        NSString *vl1, *vl2, *value;
        if (ctr.strartIndex == 0) {
            if (ctr.endIndex == ctr.intSource.count) {
                value = @"Any";
            }else
            {
                vl2 = [ctr.intSource objectAtIndex:ctr.endIndex];
                if (ctr.sourceType == pickerTypeSize || ctr.sourceType == pickerTypeValnSize) {
                    value = [vl2 stringByAppendingString:@"\nand below"];
                }else
                    value = [vl2 stringByAppendingString:@" and below"];
            }
        }
        if (ctr.strartIndex !=0) {
            vl1 = [ctr.intSource objectAtIndex:ctr.strartIndex - 1];
            if (ctr.endIndex == ctr.intSource.count) {
                if (ctr.sourceType == pickerTypeSize || ctr.sourceType == pickerTypeValnSize || ctr.sourceType == pickerTypeBedrooms || ctr.sourceType == pickerTypeWashrooms) {
                    value = [vl1 stringByAppendingString:@"\nand above"];
                }else
                    value = [vl1 stringByAppendingString:@" and above"];
            }else
            {
                vl2 = [ctr.intSource objectAtIndex:ctr.endIndex];
                if (ctr.sourceType == pickerTypeSize || ctr.sourceType == pickerTypeValnSize || ctr.sourceType == pickerTypeBedrooms || ctr.sourceType == pickerTypeWashrooms) {
                    value = [NSString stringWithFormat:@"%@\nto %@", vl1, vl2];
                }else
                    value = [NSString stringWithFormat:@"%@ to %@", vl1, vl2];
                
            }
        }
        if (ctr.strartIndex == ctr.endIndex + 1) {
            value = [ctr.intSource objectAtIndex:ctr.endIndex];
        }
        NSUInteger index = 0;
        switch (ctr.sourceType) {
            case pickerTypePrice:
                index = [mainFiles indexOfObject:@"Price"];
                if (index == NSNotFound) {
                    index = [mainFiles indexOfObject:@"Monthly Rental"];
                }
                break;
            case pickerTypeSize:
                index = [mainFiles indexOfObject:@"Size"];
                break;
            case pickerTypeBedrooms:
                index = [mainFiles indexOfObject:@"Bedrooms"];
                break;
            case pickerTypeValnSize:
                index = [mainFiles indexOfObject:@"Val'n Price"];
                break;
            case pickerTypeWashrooms:
                index = [mainFiles indexOfObject:@"Washrooms"];
                break;
            case pickerTypeConstructed:
                index = [mainFiles indexOfObject:@"Constructed"];
                break;
            case pickerTypePSF:
                index = [mainFiles indexOfObject:@"PSF"];
                break;
            case pickerTypeLeaseTerm:
                index = [mainFiles indexOfObject:@"Lease Term"];
            default:
                break;
        }
        
        [mainFilesValues replaceObjectAtIndex:index withObject:value];
        [self dismissSemiModalViewController:ctr];
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark DCAPOptionViewController Delegate
- (void) didSelectRowOfDCAOptionViewController:(DCAOptionsViewController *)dcaViewCtr
{
    if (dcaViewCtr.sourceType == DCAOptionsSortBy) {
        sortByValue = [sortByData objectAtIndex:dcaViewCtr.selectedIndex];
    }
    if (dcaViewCtr.sourceType == DCAOptionsPropertyType) {
        NSString *value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
        [mainFilesValues replaceObjectAtIndex:0 withObject:value];
    }
    if (dcaViewCtr.sourceType == DCAOptionSHDBEstate) {
        NSString *value = @"";
        if (dcaViewCtr.selectedValues.count >= 1) {
            value = [dcaViewCtr.selectedValues objectAtIndex:0];
            [dcaViewCtr.selectedValues removeObjectAtIndex:0];
            for (NSString *str in dcaViewCtr.selectedValues) {
                value = [value stringByAppendingFormat:@", %@", str];
            }
        }else
            value = @"Any";
        
        [mainFilesValues replaceObjectAtIndex:1 withObject:value];
    }
    
    if (dcaViewCtr.sourceType == DCAOptionAdOwner) {
        NSString *value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
        NSUInteger index = [mainFiles indexOfObject:@"Ad Owner"];
        if (index != NSNotFound) {
            [mainFilesValues replaceObjectAtIndex:index withObject:value];
        }
    }
    if (dcaViewCtr.sourceType == DCAOptionUnitLevel) {
        NSString *value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
        NSUInteger index = [mainFiles indexOfObject:@"Unit Level"];
        if (index != NSNotFound) {
            [mainFilesValues replaceObjectAtIndex:index withObject:value];
        }
    }
    if (dcaViewCtr.sourceType == DCAOptionFurnishing) {
        NSString *value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
        NSUInteger index = [mainFiles indexOfObject:@"Furnishing"];
        if (index != NSNotFound) {
            [mainFilesValues replaceObjectAtIndex:index withObject:value];
        }
    }
    //Condition
    if (dcaViewCtr.sourceType == DCAOptionCondition) {
        NSString *value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
        NSUInteger index = [mainFiles indexOfObject:@"Condition"];
        if (index != NSNotFound) {
            [mainFilesValues replaceObjectAtIndex:index withObject:value];
        }
    }
    //Lease Term
    if (dcaViewCtr.sourceType == DCAOptionLeaseTerm) {
        NSString *value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
        NSUInteger index = [mainFiles indexOfObject:@"Lease Term"];
        if (index != NSNotFound) {
            [mainFilesValues replaceObjectAtIndex:index withObject:value];
        }
    }
#pragma mark - Condos
    //Project Name
    if (dcaViewCtr.sourceType == DCAOptionCondosProjectName) {
        NSString *value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
        NSUInteger index = [mainFiles indexOfObject:@"Project Name"];
        if (index != NSNotFound) {
            [mainFilesValues replaceObjectAtIndex:index withObject:value];
        }
    }
    //District
    if (dcaViewCtr.sourceType == DCAOptionCondosDistrict) {
        NSString *value = @"";
        if (dcaViewCtr.selectedValues.count >= 1) {
            value = [dcaViewCtr.selectedValues objectAtIndex:0];
            [dcaViewCtr.selectedValues removeObjectAtIndex:0];
            for (NSString *str in dcaViewCtr.selectedValues) {
                value = [value stringByAppendingFormat:@", %@", str];
            }
        }else
            value = @"Any";
        NSUInteger index = [mainFiles indexOfObject:@"District"];
        if (index != NSNotFound) {
            [mainFilesValues replaceObjectAtIndex:index withObject:value];
        }
    }
    //Tenure
    if (dcaViewCtr.sourceType == DCAOptionCondosTenure) {
        NSString *value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
        NSUInteger index = [mainFiles indexOfObject:@"Tenure"];
        if (index != NSNotFound) {
            [mainFilesValues replaceObjectAtIndex:index withObject:value];
        }
    }

    [dcaViewCtr.navigationController popViewControllerAnimated:YES];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
@end
