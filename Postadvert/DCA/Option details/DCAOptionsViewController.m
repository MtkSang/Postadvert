//
//  DCAOptionsViewController.m
//  Stroff
//
//  Created by Ray on 1/24/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "DCAOptionsViewController.h"
#import "Constants.h"

@interface DCAOptionsViewController ()

@end

@implementation DCAOptionsViewController

- (id) initWithArray:(NSArray*)array DCAOptionType:(DCAOptionSourceType) sourceType_ selectedValues:(NSArray*) selectedValues_
{
    self = [super init];
    if (self) {
        _intSource = [NSArray arrayWithArray:array];
        _sourceType = sourceType_;
        _selectedIndex = -1;
        if ([selectedValues_ isKindOfClass:[NSArray class]]) {
            _selectedValues = [[NSMutableArray alloc] initWithArray:selectedValues_];
        }else
            _selectedValues = [[NSMutableArray alloc]init];
        
    }
    return self;
}
- (id) initWithArray:(NSArray*)array DCAOptionType:(DCAOptionSourceType) sourceType_ selectedIndex:(NSInteger) selectedIndex
{
    self = [super init];
    if (self) {
        _intSource = [NSArray arrayWithArray:array];
        _sourceType = sourceType_;
        _selectedIndex = selectedIndex;
    }
    return self;
}

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
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorColor = [UIColor colorWithRed:79.0/255 green:177.0/255 blue:190.0/255 alpha:1];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.multiSelect) {
        rightNavBtn = self.navigationItem.rightBarButtonItem;
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnClicked:)];
        self.navigationItem.rightBarButtonItem = doneBtn;
    }
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClicked:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    self.navigationItem.rightBarButtonItem = rightNavBtn;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

-(IBAction)doneBtnClicked:(id)sender
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didSelectRowOfDCAOptionViewController:)]) {
            [self.delegate didSelectRowOfDCAOptionViewController:self];
        }
    }
}

- (IBAction)cancelBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (_sourceType) {
        case DCAOptionsSortBy:
            return @"Sort By";
            break;
        case DCAOptionsPropertyType:
            return @"HDB Type";
            break;
        case DCAOptionSHDBEstate:
            return @"HDB Estate";
            break;
        case DCAOptionAdOwner:
            return @"Ad Owner";
            break;
        case DCAOptionUnitLevel:
            return @"Unit Level";
            break;
        case DCAOptionFurnishing:
            return @"Furnishing";
            break;
        case DCAOptionCondition:
            return @"Condition";
            break;
        case DCAOptionOthersFeatures:
            return @"Others Features";
        case DCAOptionCondosProjectName:
            return @"Project Name";
        case DCAOptionCondosDistrict:
            return @"District";
        case DCAOptionCondosTenure:
            return @"Tenure";
        case DCAOptionRoomsRoomType:
            return @"Room Type";
        case DCAOptionRoomsAttachedBathroom:
            return @"Attached Bathroom";
        case DCAOptionQAAskQn:
            return @"Category";
        default:
            return @"";
            break;
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _intSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
    }
    
    [cell.textLabel setText:[_intSource objectAtIndex:indexPath.row]];
    
    if (_multiSelect) {
        int index = [_selectedValues indexOfObject:cell.textLabel.text];
        if (index == NSNotFound) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else
    {
        if (indexPath.row == _selectedIndex) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
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
    _selectedIndex = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self performSelector:@selector(selectRowAtIndexPath:) withObject:indexPath afterDelay:0];
    [self performSelectorOnMainThread:@selector(selectRowAtIndexPath:) withObject:indexPath waitUntilDone:YES];
    //[self.tableView  reloadData];
    if (self.multiSelect) {
        
    }else
    {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didSelectRowOfDCAOptionViewController:)]) {
                [self.delegate didSelectRowOfDCAOptionViewController:self];
            }
        }
    }
}

- (void) selectRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (_multiSelect) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [_selectedValues removeObject:cell.textLabel.text];
        }
        else
        {
            [_selectedValues addObject:cell.textLabel.text];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    else
        _selectedValues = [[NSMutableArray alloc]initWithObjects:cell.textLabel.text, nil];
    
    [self.tableView  reloadData];
    sleep(0.15f);
}

@end
