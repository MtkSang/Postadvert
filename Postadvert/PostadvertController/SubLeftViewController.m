//
//  SubLeftViewController.m
//  PostAdvert11
//
//  Created by Ray Mtk on 24/4/12.
//  Copyright (c) 2012 ray@futureworkz.com. All rights reserved.
//

#import "SubLeftViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "DetailViewController.h"
#import "UserPAInfo.h"
#import "SupportFunction.h"
#import "PostadvertControllerV2.h"
#import "HDBSubItemsViewController.h"
@interface SubLeftViewController ()
- (UIGestureRecognizer*) addPanGesture:(id)target;
- (void) handlePanGesture:(UIPanGestureRecognizer*) gesture;
- (void) addTitle;

@end

@implementation SubLeftViewController
@synthesize detailVw;
@synthesize listItems, listImages;
@synthesize listNums;
@synthesize itemName = _itemName;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //view.backgroundColor =[UIColor colorWithRed:79 green:178 blue:187 alpha:1.0];
        listItems = [[NSMutableArray alloc] init];
        listNums = [[NSMutableArray alloc]init];
        listSubMemus = [[NSMutableArray alloc]init];
        self.tableView.backgroundColor = [UIColor colorWithRed:79.0/225.0 green:178.0/255.0 blue:187.0/255.0 alpha:1];
        self.tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"div.png"]];
    }
    return self;
}


- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = NO;
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableScrollTable) name:@"disableScrollTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScrollTable) name:@"enableScrollTable" object:nil];
    
    [self.view addGestureRecognizer:[self addPanGesture:self]];
    
    subItem = [[HDBSubItemsViewController alloc] initWithItems:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (!listNums) {
        listNums = [[NSMutableArray alloc]init];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // e.g. self.myOutlet = nil;
    self.listItems = nil;
    self.listImages = nil;
}
- (void) viewWillAppear:(BOOL)animated
{
    [self addTitle];
    [super viewWillAppear:animated];
    isload = YES;
    if (! listSubMemus.count) {
        listSubMemus = [[NSMutableArray alloc]init];
        for (int i = 0; i < listItems.count; i++) {
            [listSubMemus addObject:[NSNumber numberWithInt:0]];
        }
    }
    [self performSelectorInBackground:@selector(getSubNums) withObject:nil];
    //Set up title
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (lbTitle.superview) {
        [lbTitle removeFromSuperview];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //[self.navigationController.navigationBar setTitleVerticalPositionAdjustment: -10 forBarMetrics:UIBarMetricsDefault];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    //[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return listItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (listSubMemus.count > section) {
        NSNumber *num = [listSubMemus objectAtIndex:section];
        if (num.intValue == 1) {
            return 2;
        }
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listSubMemus.count > indexPath.section) {
        NSNumber *num = [listSubMemus objectAtIndex:indexPath.section];
        if (num.intValue == 1) {
            if (indexPath.row) {
                return [subItem getSizeToFit].height;
            }
        }
    }
    return cCellHeight;
}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.detailTextLabel.frame = CGRectMake(cMaxLeftView - 100, 0.0, 70, cCellHeight);
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma mark . Sub Cell
    if (indexPath.row) {
        static NSString *CellIdentifier1 = @"SubView";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (! cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.selected = NO;
            subItem.view.tag = 1;
            [cell.contentView addSubview:subItem.view];
        }
        UIView *aView = (UIView*)[cell.contentView viewWithTag:1];
        if (aView) {
            aView.hidden = NO;
            CGRect frame = aView.frame;
            frame.origin.y = 0;
            aView.frame = frame;
        }else
        {
            subItem.view.tag = 1;
            [cell.contentView addSubview:subItem.view];
        }
        return cell;
    }
#pragma mark . Normal Cell
    static NSString *CellIdentifier = @"NormalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.backgroundColor = [UIColor clearColor]; 
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        UIImageView *imageBGSelected = [[UIImageView alloc ] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, cCellHeight)] ;
        imageBGSelected.opaque = NO;
        //imageBGSelected.layer.cornerRadius = 10;
        //imageBGSelected.layer.masksToBounds = YES;
        imageBGSelected.image = [UIImage imageNamed:@"titleHDB.png"];
        [cell setSelectedBackgroundView:imageBGSelected];
        imageBGSelected = nil;
        
        UIImageView *imageBG = [[UIImageView alloc ] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, cCellHeight)] ;
        imageBG.tag = 10;
        imageBG.opaque = NO;
        //    imageBG.layer.cornerRadius = 10;
        //    imageBG.layer.masksToBounds = YES;
        imageBG.image = [UIImage imageNamed:@"normal_state.png"];
        [cell setBackgroundView:imageBG];
        imageBG = nil;
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityView.frame = CGRectMake(self.view.frame.size.width - cRemainView - activityView.frame.size.width - 15.0 , (cCellHeight - activityView.frame.size.height) / 2.0, activityView.frame.size.width + 10.0 , activityView.frame.size.height);
        activityView.tag = 2;
        [cell addSubview:activityView];
    }
    
    cell.textLabel.text = [listItems objectAtIndex:indexPath.section];
    cell.imageView.image = [listImages objectAtIndex:indexPath.section];
    UILabel *labelNum = (UILabel*)[cell viewWithTag:1];
    if (labelNum == nil) {
        labelNum = [[UILabel alloc]init];
        [labelNum setTextAlignment:UITextAlignmentCenter];
        [labelNum setBackgroundColor:[UIColor grayColor]];
        [labelNum setTextColor:[UIColor whiteColor]];
        [labelNum setTag:1];
        [cell.contentView addSubview:labelNum];
    }
    if (!isload && listNums.count > indexPath.section) {
        NSInteger value = [(NSNumber*)[listNums objectAtIndex:indexPath.section]intValue ];
        if (value >= 0) {
            labelNum.hidden = NO;
            labelNum.text = [NSString stringWithFormat:@"%d", value];
            UIActivityIndicatorView *activityView = (UIActivityIndicatorView*)[cell viewWithTag:2];
            [activityView stopAnimating ];
        }else {
            labelNum.hidden = YES;
            labelNum.text = @"0";
        }
    }else {
        labelNum.text = @"";
        NSInteger  wallID = 1;
        NSInteger countryID = 190;
        countryID = [SupportFunction GetCountryIdFromConutryName:[UserPAInfo sharedUserPAInfo].userCountryPA];
        wallID = [SupportFunction getWallIdFromCountryID:countryID andItemName:[listItems objectAtIndex:indexPath.section]];
        UIActivityIndicatorView *activityView = (UIActivityIndicatorView*)[cell viewWithTag:2];
        if (wallID > 0) {
            activityView.hidden = NO;
            [activityView startAnimating ];
        }else
            activityView.hidden = YES;
            
        
    }
    [labelNum sizeToFit];
    labelNum.frame = CGRectMake(self.view.frame.size.width - cRemainView - labelNum.frame.size.width - 15.0 , (cCellHeight - labelNum.frame.size.height) / 2.0, labelNum.frame.size.width + 10.0 , labelNum.frame.size.height);
    NSLog(@"SubLeftView  %@", self.view);

    NSLog(@"lable NUM %@", labelNum);
    [cell.contentView bringSubviewToFront:labelNum];

    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([self showAddSubMenuAtIndexPath:indexPath]) {
        [self insertSubMenuAtIndexPath:indexPath];
        return;
    }
    if (tableView.scrollEnabled == NO) {
        return;
    }
     NSDictionary *dict = [NSDictionary dictionaryWithObject:[listItems objectAtIndex:indexPath.section] forKey:@"itemName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showDetailFromSubView" object:nil userInfo:dict];
}
#pragma overwrite supper

- (void) refresh
{
    
    isload = YES;
//    NSMutableArray *new_listNums = [[NSMutableArray alloc]init];
//    for (NSString* itemName in listItems) {
//        NSInteger  wallID = 0;
//        NSInteger countryID = 190;
//        countryID = [SupportFunction GetCountryIdFromConutryName:[UserPAInfo sharedUserPAInfo].userCountryPA];
//        wallID = [SupportFunction getWallIdFromCountryID:countryID andItemName:itemName];
//        NSNumber *num = [[PostadvertControllerV2 sharedPostadvertController] getCountPostsWithWallId:[NSString stringWithFormat:@"%d", wallID]];
//        [new_listNums addObject:num];
//    }
//    isload = NO;
//    listNums = new_listNums;
//    [self stopLoading];
//    [self.tableView reloadData];
    isload = YES;
    //[self performSelectorOnMainThread:@selector(getSubNums) withObject:nil waitUntilDone:YES];
    [self performSelectorInBackground:@selector(getSubNums) withObject:nil];
}

#pragma mark - Implement
- (BOOL)showAddSubMenuAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL canAdd = NO;
    if ([self.itemName isEqualToString:@"PROPERTY"]) {
        if ([[listItems objectAtIndex:indexPath.section] rangeOfString:@"HDB"].length) {
            canAdd = YES;
        }
        if ([[listItems objectAtIndex:indexPath.section] rangeOfString:@"Condos"].length) {
            canAdd = YES;
        }
        if ([[listItems objectAtIndex:indexPath.section] rangeOfString:@"Landed Property"].length) {
            canAdd = YES;
        }
        if ([[listItems objectAtIndex:indexPath.section] rangeOfString:@"Rooms For Rent"].length) {
            canAdd = YES;
        }
        if ([[listItems objectAtIndex:indexPath.section] rangeOfString:@"Commercial"].length) {
            canAdd = YES;
        }
    }
    
    return canAdd;
}

- (void)insertSubMenuAtIndexPath:(NSIndexPath*)indexPath
{
    if (listSubMemus.count < indexPath.section + 1) {
        return;
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        //dispatch_async(dispatch_get_main_queue(), ^{
        //});
    }
    NSNumber *num = [listSubMemus objectAtIndex:indexPath.section];
    
    NSArray *indexPaths = [ NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:indexPath.section], nil];
    NSMutableArray *indexPathsNeedToReload = [[NSMutableArray alloc]init];
    [indexPathsNeedToReload addObject:indexPath];
    if (num.intValue == 1) {
//        delete subView
        UIView *aView = [cell.contentView viewWithTag:1];
        if (aView) {
            aView.hidden = YES;
        }
        [listSubMemus replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInt:0]];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }else
    {
        
//        remove current subView
        for (int i = 0; i < listSubMemus.count; i++) {
            NSNumber *currentNum = [listSubMemus objectAtIndex:i];
            if (currentNum.intValue == 1) {
                UIView *aView = [cell.contentView viewWithTag:1];
                if (aView) {
                    aView.hidden = YES;
                }
                [listSubMemus replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
                [indexPathsNeedToReload addObject:[NSIndexPath indexPathForRow:0 inSection:i]];
                [self.tableView deleteRowsAtIndexPaths:[ NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:i], nil] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        [subItem setupForItemName:cell.textLabel.text];
        subItem.view.tag = 1;
//        add row
        [listSubMemus replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInt:1]];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    [self postNotificationReload];
//    [self performSelector:@selector(postNotificationReload) withObject:nil afterDelay:1];
        //[self.tableView reloadData];
//    [self.tableView reloadRowsAtIndexPaths:indexPathsNeedToReload withRowAnimation:UITableViewRowAnimationNone];
}

- (void) getSubNums
{
    isload = YES;
    if ( ! listNums) {
        listNums = [[NSMutableArray alloc]init];
    }
    NSMutableArray *new_listNums = [[NSMutableArray alloc]init];
    for (NSString* itemName in listItems) {
        NSInteger  wallID = 1;
        NSInteger countryID = 190;
        countryID = [SupportFunction GetCountryIdFromConutryName:[UserPAInfo sharedUserPAInfo].userCountryPA];
        wallID = [SupportFunction getWallIdFromCountryID:countryID andItemName:itemName];
        if (wallID < 0) {
            [new_listNums addObject:[NSNumber numberWithInt:-1]];
            continue;
        }
        NSNumber *num = [[PostadvertControllerV2 sharedPostadvertController] getCountPostsWithWallId:[NSString stringWithFormat:@"%d", wallID]];
        [new_listNums addObject:num];
        
    }
    isload = NO;
    if (! listSubMemus.count) {
        listSubMemus = [[NSMutableArray alloc]init];
        for (int i = 0; i < listItems.count; i++) {
            [listSubMemus addObject:[NSNumber numberWithInt:0]];
        }
    }
    listNums = new_listNums;
    [self stopLoading];
    [self.tableView reloadData];
}

- (void) addTitle{
//    lbTitle = nil;
//    CGRect frame = self.navigationController.navigationBar.frame;
//    
//    lbTitle = [[UILabel alloc]initWithFrame:CGRectMake(160, 0.0, frame.size.width, frame.size.height)];
//    [lbTitle setBackgroundColor:[UIColor clearColor]];
//    [lbTitle setTextAlignment:UITextAlignmentCenter];
//    [lbTitle setTextColor:[UIColor whiteColor]];
//    [lbTitle setText:_itemName];
//    //[lbTitle setTextColor:[UIColor redColor]];
//    lbTitle.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    [self.navigationController.navigationBar addSubview:lbTitle];
//    [UIView animateWithDuration:0.35
//                          delay:0.0
//                        options: UIViewAnimationCurveEaseOut
//                     animations:^{
//                         [lbTitle setFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
//                     } 
//                     completion:^(BOOL finished){
//                         NSLog(@"Done!");
//                     }];

    
    //lbTitle = nil;
    self.title = _itemName;

}

- (void)setTitle:(NSString *)title
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] init];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:16.0]; // Set the Title Font Size
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5]; // Set the Title Shadow
        titleView.textColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5]; // Set the Title Color
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void) disableScrollTable{
    self.tableView.scrollEnabled = NO;
}
- (void) enableScrollTable{
    self.tableView.scrollEnabled = YES;
}

- (UIPanGestureRecognizer*) addPanGesture:(id) target
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]init];
    panGesture.delegate = self;
    [panGesture addTarget:target action:@selector(handlePanGesture:)];
    return panGesture;
}

- (void) handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (![gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            previousPoint = [gesture translationInView:gesture.view.superview];
            //[lastTimes insertObject:[NSNumber numberWithDouble:[gesture timestamp]] atIndex:0];
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSNumber *num = [NSNumber numberWithFloat:[gesture translationInView:gesture.view.superview].x - previousPoint.x];
            previousPoint = [gesture translationInView:gesture.view.superview];
            [[NSUserDefaults standardUserDefaults] setObject:num forKey:@"PointX"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"navMove" object:nil];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint velocity = [gesture velocityInView:self.view];
            CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
            
            NSLog(@" X:%f, Y%f, magnitue:%f", velocity.x, velocity.y, magnitude);
            if (magnitude > cMinSpeedPermit) {
                NSInteger direction = [(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"PointX"] integerValue];
                direction = direction > 0 ? 1 : 0;
                NSNumber *num = [NSNumber numberWithInteger:direction];
                NSDictionary *dict = [NSDictionary dictionaryWithObject:num forKey:@"setSideBarForState"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setSideBarForState" object:nil userInfo:dict];
                num = nil;
                dict = nil;
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"navEndMove" object:nil];
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - GestureRecognizer Delegate
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIView *view = [gestureRecognizer view];
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:[view superview]];
        // Check for horizontal gesture
        if (fabsf(translation.x) > fabsf(translation.y))
        {
            return YES;
        }
        return NO;
    }
    return NO;
}

- (CGSize) viewContentSize
{
    CGSize size = CGSizeZero;
    size.width = self.view.frame.size.width;
    float h = self.listItems.count * cCellHeight;
    for (int i =0; i < listSubMemus.count; i++) {
        NSNumber *num = [listSubMemus objectAtIndex:i];
        if (num.intValue == 1) {
            h += [subItem getSizeToFit].height;
        }
    }
    size.height = h;
    return size;
}
- (void) postNotificationReload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationForReloadLeftView" object:nil];
}
@end
