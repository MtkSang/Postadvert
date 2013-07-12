//
//  HDBPostViewController.m
//  Stroff
//
//  Created by Ray on 3/26/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HDBPostViewController.h"
#import "UIImage+Resize.h"
#import "Constants.h"
#import "UIPlaceHolderTextView.h"
#import "OptionTableHDBPostViewController.h"
#import "DCAOptionsViewController.h"
#import "InsertPictureViewController.h"
#import "InsertURLViewController.h"
#import "PostadvertControllerV2.h"
#import "UserPAInfo.h"
#import "HBBResultCellData.h"
#import "NSData+Base64.h"
#import "HDBResultDetailViewController.h"
#import "DCAPickerViewController.h"
#import "SupportFunction.h"
#import "HDBResultDetailViewController.h"
@interface HDBPostViewController ()

@end

@implementation HDBPostViewController

@synthesize overlay;
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
    
    UIImage *image = [UIImage imageNamed:@"titleHDB.png"];
    image = [image resizedImage:self.lbTitle.frame.size interpolationQuality:0];
    [self.lbTitle setBackgroundColor:[UIColor colorWithPatternImage:image]];
    [self.lbTitle setText:@"Post a Classified Ad"];
    
    [self.tableView setTableHeaderView:[self viewForHeader]];
    //TapGesture
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    
    //Load plist
    NSString *plistPathForStaticDCA = [[NSBundle mainBundle] pathForResource:@"DCA" ofType:@"plist"];
    staticData = [NSMutableDictionary dictionaryWithContentsOfFile:plistPathForStaticDCA];
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        staticData = [NSMutableDictionary dictionaryWithDictionary: [staticData objectForKey:@"HDB Search"]];
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        staticData = [NSMutableDictionary dictionaryWithDictionary: [staticData objectForKey:@"Condos Search"]];
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        staticData = [NSMutableDictionary dictionaryWithDictionary: [staticData objectForKey:@"Landed Property Search"]];
    }
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        staticData = [NSMutableDictionary dictionaryWithDictionary: [staticData objectForKey:@"Rooms For Rent Search"]];
    }
    
    
    //
    NSString *plistPathForStaticHDBPost = [[NSBundle mainBundle] pathForResource:@"DCA" ofType:@"plist"];
    NSDictionary *staticData2 = [NSDictionary dictionaryWithContentsOfFile:plistPathForStaticHDBPost];
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        sourceData = [NSMutableDictionary dictionaryWithDictionary: [staticData2 objectForKey:@"HDB Post"]];
        allKeys = [[NSMutableArray alloc]initWithObjects:
                   @"Property Details",
                   @"Address of Property",
                   @"Description of Property",
                   @"Pictures, URLs & Videos",
                   @"Special Features",
                   @"Home Interior", nil];
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        sourceData = [NSMutableDictionary dictionaryWithDictionary: [staticData2 objectForKey:@"Condos Post"]];
        allKeys = [[NSMutableArray alloc]initWithObjects:
                   @"Property Details",
                   @"Address of Property",
                   @"Description of Property",
                   @"Pictures, URLs & Videos",
                   @"Special Features",
                   @"Amenities",
                   @"Interior and Fixtures & Fittings", nil];
    }
    
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        sourceData = [NSMutableDictionary dictionaryWithDictionary: [staticData2 objectForKey:@"Landed Property Post"]];
        allKeys = [[NSMutableArray alloc]initWithObjects:
                   @"Property Details",
                   @"Address of Property",
                   @"Description of Property",
                   @"Pictures, URLs & Videos",
                   @"Special Features",
                   @"Indoor & Outdoors",
                   @"Fixtures & Fittings", nil];
    }

    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        sourceData = [NSMutableDictionary dictionaryWithDictionary: [staticData2 objectForKey:@"Rooms For Rent Post"]];
        allKeys = [[NSMutableArray alloc]initWithObjects:
                   @"Property Details",
                   @"Address of Property",
                   @"Description of Property",
                   @"Pictures, URLs & Videos",
                   @"Special Features",
                   @"Amenities",
                   @"Home Interior",
                   @"Restrictions ( if any )", nil];
    }

    
    
    [self InsertPictureDidDisappear];
    [self InsertURLsDidDisappear];
    [self resetValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLbTitle:nil];
    [self setTableView:nil];
    [self setCellHDBPostSubmit:nil];
    [self setCellHDBPostPreviewAd:nil];
    [self setOverlay:nil];
    [self setTextField:nil];
    [self setInputForm:nil];
    [self setInputTitle:nil];
    [self setInputTextForm:nil];
    [self setBoundForm:nil];
    [self setTitleInputTextForm:nil];
    [self setPhTextView:nil];
    [super viewDidUnload];
}
#pragma mark - textViewDelegate
- (void)textViewDidChange:(UITextView *)textView 
{
    CGSize constraint, size;
    constraint = CGSizeMake(300.f, 160.f);
    size = [textView.text sizeWithFont:textView.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    //self.boundForm.frame = CGRectMake(10, 38, 300, size.height + 10);
}

#pragma mark - subview

-(void) showDialog:(UIView*) view
{
    activeForm = view;
    [overlay addSubview:view];
    
    CGRect rc = [[UIScreen mainScreen] bounds];
    overlay.frame = rc;
    
    rc = view.frame;
	rc.origin = CGPointMake(0.0f, -rc.size.height);
	view.frame = rc;
    
	// Show the overlay
	if (!overlay.superview)
    {
        [self.view addSubview:overlay];
    }
    
    //    UIViewController *modalViewController = [[UIViewController alloc] init];
    //    modalViewController.view = overlay;
    //    [self presentModalViewController:modalViewController animated:YES];
    
	overlay.alpha = 1.0;
	
	// Animate the message view into place
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
	rc.origin = CGPointMake(0.0f, 0.0f);//point; //CGPointMake(0.0f, 10.0f);
	view.frame = rc;
    [UIView commitAnimations];
    
    //    [modalViewController release];
}

-(void) hideDialog:(UIView*) view
{
    CGRect rc = view.frame;
    rc.origin = CGPointMake(0.0f, -rc.size.height);
    
    // Animate the message view away
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
	
	view.frame = rc;
    [UIView commitAnimations];
    
	// Hide the overlay
	[overlay performSelector:@selector(setAlpha:) withObject:nil afterDelay:0.3f];
    [overlay removeFromSuperview];
    [[self modalViewController] dismissModalViewControllerAnimated:NO];
}
#pragma mark TableView HeaderView
- (UIView*) viewForHeader
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, cCellHeight)];
    [headerView setBackgroundColor:[UIColor colorWithRed:90.0/255 green:85.0/255 blue:73.0/255 alpha:1]];
    UILabel *lbDCAType = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, headerView.frame.size.width / 2 + 4, headerView.frame.size.height)];
    [lbDCAType setBackgroundColor:[UIColor clearColor]];
    [lbDCAType setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_TITLE_SIZE]];
    [lbDCAType setMinimumFontSize:FONT_SIZE_SMALL];
    [lbDCAType setTextColor:_tableView.backgroundColor];
    [lbDCAType setTextAlignment:NSTextAlignmentCenter];
    NSString *itemShortName = [self.itemName stringByReplacingOccurrencesOfString:@" Search" withString:@""];
    itemShortName = [NSString stringWithFormat:@" %@", itemShortName];
    [lbDCAType setText:[itemShortName uppercaseString]];
    UILabel *lbDCACountry = [[UILabel alloc]initWithFrame:CGRectMake(headerView.frame.size.width / 2 -4 , 0, headerView.frame.size.width / 2 - 4, headerView.frame.size.height)];
    [lbDCACountry setBackgroundColor:[UIColor clearColor]];
    [lbDCACountry setText:[[UserPAInfo sharedUserPAInfo].userCountryPA capitalizedString]];
    [lbDCACountry setTextAlignment:NSTextAlignmentCenter];
    [lbDCACountry setTextColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
    [lbDCACountry setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_TITLE_SIZE]];
    [lbDCACountry setMinimumFontSize:FONT_SIZE_SMALL];
    [headerView addSubview:lbDCAType];
    [headerView addSubview:lbDCACountry];
    return headerView;
}
#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section >= allKeys.count) {
        return nil;
    }
    return [allKeys objectAtIndex:section];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return allKeys.count + 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section>= allKeys.count) {
        return 2;
    }
    NSArray *array = [sourceData objectForKey:[allKeys objectAtIndex:section] ];
    return array.count;
//    
//    if (section == 0) {
//        return 11;
//    }
//    if (section == 01) {
//        return 2;
//    }
//    if (section == 02) {
//        return 1;
//    }
//    if (section == 03) {
//        return 3;
//    }
//    if (section == 04) {
//        return 4;
//    }
//    if (section == 05) {
//        return 1;
//    }
//    if (section == 06) {
//        return 1;
//    }
//    if (section == 07) {
//        return 1;
//    }
//    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section >= allKeys.count) {
        if (indexPath.row == 0) {
            return self.cellHDBPostPreviewAd;
        }
        if (indexPath.row == 01) {
            return self.cellHDBPostSubmit;
        }
    }
    cell = [[UITableViewCell alloc] init];
    NSString *headerStr = [allKeys objectAtIndex:indexPath.section];
    NSArray *array = [sourceData objectForKey:headerStr];
#pragma mark . Property Details
    if ([headerStr isEqualToString:@"Property Details"]) {
        static NSString *CellIdentifier1 = @"CellHBDPostWithOption";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
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
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        
        cell.textLabel.text = textLabel;
        NSString *detailText = [[NSUserDefaults standardUserDefaults] objectForKey:textLabel];
        if (detailText == nil || [detailText isEqualToString:@""] || [detailText isEqualToString:@"0"]) {
            NSArray *defauleValue = [sourceData objectForKey:@"Default Value"];
            detailText = [defauleValue objectAtIndex:indexPath.row];
//            if (indexPath.row == array.count - 1 || indexPath.row < 6) {
//                detailText = @"Select One";
//            }else
//                detailText = @"";
        }
        cell.detailTextLabel.text = detailText;
        [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        //if (indexPath.row == array.count - 1 || indexPath.row < 6) {
            if ([cell.detailTextLabel.text isEqualToString:@"0"] || [cell.detailTextLabel.text isEqualToString:@"Select One"] || [cell.detailTextLabel.text isEqualToString:@""]) {
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
//        }else
//        {
//            
//        }
    }
#pragma mark . Address of Property
    if ([headerStr isEqualToString:@"Address of Property"]) {
        static NSString *CellIdentifier2 = @"CellHBDPostWithOption2";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2];
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
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        cell.textLabel.text = textLabel;
        NSString *detailText = [[NSUserDefaults standardUserDefaults] objectForKey:textLabel];
        if (detailText == nil) {
            detailText = @"";
        }
        cell.detailTextLabel.text = detailText;
        [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        if ([cell.detailTextLabel.text isEqualToString:@"0"] || [cell.detailTextLabel.text isEqualToString:@"Select One"] || [cell.detailTextLabel.text isEqualToString:@""]) {
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
    }
#pragma mark . Description of Property
    if ([headerStr isEqualToString:@"Description of Property"]) {
        static NSString *CellIdentifier3 = @"CellHBDPostWithOption3";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier3];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor blackColor]];
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
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        //cell.textLabel.text = textLabel;
        NSString *detailText = [[NSUserDefaults standardUserDefaults] objectForKey:textLabel];
        if (detailText == nil) {
            detailText = @"";
        }
        cell.textLabel.text = detailText;
        [cell.textLabel setNumberOfLines:15];
        [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        
        if ([cell.textLabel.text isEqualToString:@""]) {
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
        
    }
#pragma mark . Pictures, URLs & Videos
    if ([headerStr isEqualToString:@"Pictures, URLs & Videos"]) {
        static NSString *CellIdentifier2 = @"CellHBDPostWithOption2";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2];
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
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        cell.textLabel.text = textLabel;
        NSString *detailText = [[NSUserDefaults standardUserDefaults] objectForKey:textLabel];
        if (detailText == nil) {
            detailText = @"";
        }
        cell.detailTextLabel.text = detailText;
        [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        if ([cell.detailTextLabel.text isEqualToString:@"0"] || [cell.detailTextLabel.text isEqualToString:@"Select One"] || [cell.detailTextLabel.text isEqualToString:@""]) {
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
        
    }
    
#pragma mark . Special Features
    if ([headerStr isEqualToString:@"Special Features"]) {
        static NSString *CellIdentifier1 = @"CellHBDPostWithOption";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
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
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        cell.textLabel.text = textLabel;
        NSString *detailText = [[NSUserDefaults standardUserDefaults] objectForKey:textLabel];
        if (detailText == nil || [detailText isEqualToString:@""]) {
            if (indexPath.row == array.count - 1) {
                detailText = @"Others Features";
            }else
                detailText = @"Select One";
        }
        cell.detailTextLabel.text = detailText;
        [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        if ([cell.detailTextLabel.text isEqualToString:@"Others Features"] || [cell.detailTextLabel.text isEqualToString:@"Select One"] || [cell.detailTextLabel.text isEqualToString:@""]) {
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
    }
#pragma mark . Home Interior
    if ([headerStr isEqualToString:@"Home Interior"]) {
        static NSString *CellIdentifier6 = @"CellHBDPostWithOption6";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier6];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier6];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setNumberOfLines:2];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];

        }
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        cell.textLabel.text = textLabel;
        NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] objectForKey:headerStr];
        NSRange rang = [fixtures_fittings rangeOfString:cell.textLabel.text];
        if (rang.length) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
#pragma mark . Interior and Fixtures & Fittings
    if ([headerStr isEqualToString:@"Interior and Fixtures & Fittings"]) {
        static NSString *CellIdentifier6 = @"CellHBDPostWithOption6";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier6];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier6];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setNumberOfLines:2];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            
        }
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        cell.textLabel.text = textLabel;
        NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] objectForKey:headerStr];
        NSRange rang = [fixtures_fittings rangeOfString:cell.textLabel.text];
        if (rang.length) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
#pragma mark . Fixtures & Fittings
    if ([headerStr isEqualToString:@"Fixtures & Fittings"]) {
        static NSString *CellIdentifier6 = @"CellHBDPostWithOption6";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier6];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier6];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setNumberOfLines:2];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            
        }
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        cell.textLabel.text = textLabel;
        NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] objectForKey:headerStr];
        NSRange rang = [fixtures_fittings rangeOfString:cell.textLabel.text];
        if (rang.length) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
#pragma mark . Amenities
    if ([headerStr isEqualToString:@"Amenities"]) {
        static NSString *CellIdentifier7 = @"CellHBDPostWithOption7";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier7];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier7];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setNumberOfLines:2];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            
        }
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        cell.textLabel.text = textLabel;
        NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] objectForKey:headerStr];
        NSRange rang = [fixtures_fittings rangeOfString:cell.textLabel.text];
        if (rang.length) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
#pragma mark . Indoor & Outdoors
    if ([headerStr isEqualToString:@"Indoor & Outdoors"]) {
        static NSString *CellIdentifier7 = @"CellHBDPostWithOption7";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier7];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier7];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setNumberOfLines:2];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            
        }
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        cell.textLabel.text = textLabel;
        NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] objectForKey:headerStr];
        NSRange rang = [fixtures_fittings rangeOfString:cell.textLabel.text];
        if (rang.length) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
#pragma mark . Restrictions ( if any )
    if ([headerStr isEqualToString:@"Restrictions ( if any )"]) {
        static NSString *CellIdentifier7 = @"CellHBDPostWithOption7";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier7];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier7];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setNumberOfLines:2];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            
        }
        NSString *textLabel = [array objectAtIndex:indexPath.row];
        if (textLabel == nil) {
            textLabel =@"";
        }
        cell.textLabel.text = textLabel;
        NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] objectForKey:headerStr];
        NSRange rang = [fixtures_fittings rangeOfString:cell.textLabel.text];
        if (rang.length) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    return cell;
}
- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < allKeys.count) {
        NSString *headerStr = [allKeys objectAtIndex:indexPath.section];
        NSRange rang = [headerStr rangeOfString:@"Description"];
        if (rang.length) {
            NSString *text = [[NSUserDefaults standardUserDefaults]objectForKey:headerStr];
            CGSize constraint, size;
            if (text.length) {
                constraint = CGSizeMake(237.f, 300.f);
                size = [text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                if (size.height < cCellHeight) {
                    size.height = cCellHeight;
                }
            }else
                size.height = 2.0 * cCellHeight;
            return size.height + 5;
        }
    }
    return cCellHeight;
}

#pragma mark - Table view delegate
- (void) accessoryClicked:(UITapGestureRecognizer*) tapGesture_
{
    NSIndexPath *indexPath;
    UIView *view = tapGesture_.view;
    UITableViewCell *cell;// = (UITableViewCell*) view.superview;
    while (view) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell*)view;
            break;
        }
        view = view.superview;
    }
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:cell];
    }
    if (!indexPath) {
        return;
    }
    NSString *headerStr = [allKeys objectAtIndex:indexPath.section];
//    NSArray *array = [sourceData objectForKey:headerStr];
    NSRange rang = [headerStr rangeOfString:@"Description"];
    if (rang.length) {
        UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
        if (![cell.textLabel.text isEqualToString:@""] ) {
            if (accessoryView) {
                accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                CGRect frame = accessoryView.frame;
                frame.size = CGSizeMake(30, 30);
                [accessoryView setFrame:frame];
            }
            cell.textLabel.text = @"";
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:headerStr];
            return;
        }else
        {
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
    //
    
    UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
    if (![cell.detailTextLabel.text isEqualToString:@"Others Features"] && ![cell.detailTextLabel.text isEqualToString:@"Select One"] && ![cell.detailTextLabel.text isEqualToString:@""] ) {
        if (accessoryView) {
            accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
            accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
            CGRect frame = accessoryView.frame;
            frame.size = CGSizeMake(30, 30);
            [accessoryView setFrame:frame];
        }
        //Property detail
        rang = [headerStr rangeOfString:@"Details"];
        if (rang.length) {
            NSArray *defauleValue = [sourceData objectForKey:@"Default Value"];
            cell.detailTextLabel.text = [defauleValue objectAtIndex:indexPath.row];
//            if (indexPath.row == array.count - 1 || indexPath.row < 6) {
//                cell.detailTextLabel.text = @"Select One";
//            }else
//                cell.detailTextLabel.text = @"";//Value for Price ,...
            [[NSUserDefaults standardUserDefaults]setValue:cell.detailTextLabel.text forKey:cell.textLabel.text];
        }
        // Address of Property
        rang = [headerStr rangeOfString:@"Address"];
        if (rang.length) {
            cell.detailTextLabel.text = @"";
            [[NSUserDefaults standardUserDefaults]setValue:cell.detailTextLabel.text forKey:cell.textLabel.text];
        }
        
        //Picture, URL
        rang = [headerStr rangeOfString:@"Pictures"];
        if (rang.length) {
            rang = [cell.textLabel.text rangeOfString:@"Images"];
            if (rang.length) {
                if (insertPicCtr) {
                    insertPicCtr.dataSoure = [[NSMutableArray alloc]init];
                }
                cell.detailTextLabel.text = @"";
                [[NSUserDefaults standardUserDefaults]setValue:cell.detailTextLabel.text forKey:cell.textLabel.text];
                [insertPicCtr performSelectorInBackground:@selector(updateView) withObject:nil];
            }
            
            //URL
            rang = [cell.textLabel.text rangeOfString:@"URL"];
            if (rang.length) {
                if (insertURLsCtr) {
                    insertURLsCtr.listURLs = [[NSMutableArray alloc]init];
                }
                cell.detailTextLabel.text = @"";
                [[NSUserDefaults standardUserDefaults]setValue:cell.detailTextLabel.text forKey:cell.textLabel.text];
                [insertURLsCtr.tableView reloadData];
                
            }
            //Video
            rang = [cell.textLabel.text rangeOfString:@"Video"];
            if (rang.length) {
                if (insertVideosCtr) {
                    insertVideosCtr.listURLs = [[NSMutableArray alloc]init];
                }
                cell.detailTextLabel.text = @"";
                [[NSUserDefaults standardUserDefaults]setValue:cell.detailTextLabel.text forKey:cell.textLabel.text];
                [insertVideosCtr.tableView reloadData];
                
            }
        }
        //Special
        rang = [headerStr rangeOfString:@"Special"];
        if (rang.length) {
            if ([cell.textLabel.text isEqualToString:@"Others"]) {
                cell.detailTextLabel.text = @"Others Features";
            }else
            {
                cell.detailTextLabel.text = @"Select One";
            }
            [[NSUserDefaults standardUserDefaults]setValue:cell.detailTextLabel.text forKey:cell.textLabel.text];
        }

    }else
    {
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= allKeys.count) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    currentIndexPath = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *headerStr = [allKeys objectAtIndex:indexPath.section];
    NSArray *array = [sourceData objectForKey:headerStr];
    NSRange rang ;
//    allKeys = [[NSMutableArray alloc]initWithObjects:
//               @"Property Details",
//               @"Address of Property",
//               @"Description of Property",
//               @"Pictures, URLs & Videos",
//               @"Special Features",
//               @"Home Interior", nil];
    //               @"Property Details",
#pragma mark . Property Details
    if ([headerStr isEqualToString:@"Property Details"]) {
        NSRange rang = [cell.textLabel.text rangeOfString:@"Property Status"];
        if (rang.length) {
            NSArray *array = [staticData objectForKey:@"PropertyStatus"];
            NSInteger selectedIndex = -1;
            if (![cell.detailTextLabel.text isEqualToString:@"Select One"]) {
                selectedIndex = [array indexOfObject:cell.detailTextLabel.text];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:array DCAOptionType:DCAOptionPropertyStatus selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        // Ad Owner
        rang = [cell.textLabel.text rangeOfString:@"Ad Owner"];
        if (rang.length) {
            NSArray *array = [staticData objectForKey:@"AdOwner"];
            NSInteger selectedIndex = -1;
            if (![cell.detailTextLabel.text isEqualToString:@"Select One"]) {
                selectedIndex = [array indexOfObject:cell.detailTextLabel.text];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:array DCAOptionType:DCAOptionAdOwner selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        // HDB Estate
        rang = [cell.textLabel.text rangeOfString:@"HDB Estate"];
        if (rang.length) {
            NSArray *HDBEstateData = [staticData objectForKey:@"HDBEstate"];
            NSString *hdbEstateString = cell.detailTextLabel.text;
            NSArray *array = [hdbEstateString componentsSeparatedByString:@", "];
            if ([hdbEstateString isEqualToString:@"Select One"]) {
                array = nil;
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:HDBEstateData DCAOptionType:DCAOptionSHDBEstate selectedValues:array];
            //dcaOptionViewCtr.multiSelect = YES;
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        // District
        rang = [cell.textLabel.text rangeOfString:@"District"];
        if (rang.length) {
            NSArray *hdbTypeData = [staticData objectForKey:@"District"];
            NSInteger selectedIndex = -1;
            NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
            if (![hdbType isEqualToString:@"Any"] && ![hdbType isEqualToString:@"Select One"]) {
                selectedIndex = [hdbTypeData indexOfObject:hdbType];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCAOptionCondosDistrict selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        //HDB Type
        rang = [cell.textLabel.text rangeOfString:@"HDB Type"];
        if (rang.length) {
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
        //Project Name
        rang = [cell.textLabel.text rangeOfString:@"Project Name"];
        if (rang.length) {
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
        //Tenure
        rang = [cell.textLabel.text rangeOfString:@"Tenure"];
        if (rang.length) {
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
        //Bedrooms
        rang = [cell.textLabel.text rangeOfString:@"Bedrooms"];
        if (rang.length) {
            NSArray *hdbTypeData = [staticData objectForKey:@"Bedrooms"];
            NSInteger selectedIndex = -1;
            NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
            if (![hdbType isEqualToString:@"Select One"]) {
                selectedIndex = [hdbTypeData indexOfObject:hdbType];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCAOptionBedrooms selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        //Washrooms
        rang = [cell.textLabel.text rangeOfString:@"Washrooms"];
        if (rang.length) {
            NSArray *hdbTypeData = [staticData objectForKey:@"Washrooms"];
            NSInteger selectedIndex = -1;
            NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
            if (![hdbType isEqualToString:@"Select One"]) {
                selectedIndex = [hdbTypeData indexOfObject:hdbType];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCAOptionWashrooms selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        //Constructed
        rang = [cell.textLabel.text rangeOfString:@"Completion"];
        if (rang.length) {
            NSArray *hdbTypeData = [staticData objectForKey:@"Constructed"];
            NSInteger selectedIndex = -1;
            NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
            if (![hdbType isEqualToString:@"Select One"]) {
                selectedIndex = [hdbTypeData indexOfObject:hdbType];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCaOptionConstructed selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        //TOP
        rang = [cell.textLabel.text rangeOfString:@"TOP"];
        if (rang.length) {
            NSArray *hdbTypeData = [staticData objectForKey:@"Constructed"];
            NSInteger selectedIndex = -1;
            NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
            if (![hdbType isEqualToString:@"Select One"]) {
                selectedIndex = [hdbTypeData indexOfObject:hdbType];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCaOptionConstructed selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        //Property Type
        rang = [cell.textLabel.text rangeOfString:@"Property Type"];
        if (rang.length) {
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
        
        //Room Type
        rang = [cell.textLabel.text rangeOfString:@"Room Type"];
        if (rang.length) {
            NSArray *hdbTypeData = [staticData objectForKey:@"RoomType"];
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

        //Attached Bathroom Type
        rang = [cell.textLabel.text rangeOfString:@"Attached Bathroom"];
        if (rang.length) {
            NSArray *hdbTypeData = [staticData objectForKey:@"AttachedBathroom"];
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

        
        UIDCAPickerControllerSourceType sourceType = pickerTypeUnknow;
        rang = [cell.textLabel.text rangeOfString:@"Size (sq ft)"];
        if (rang.length) {
            sourceType = pickerTypeInputSizeSqft;
        }
        rang = [cell.textLabel.text rangeOfString:@"Size (sqm)"];
        if (rang.length) {
            sourceType = pickerTypeInputSizeSqm;
        }
        rang = [cell.textLabel.text rangeOfString:@"Size (sqm)"];
        if (rang.length) {
            sourceType = pickerTypeInputSizeSqm;
        }
        rang = [cell.textLabel.text rangeOfString:@"Valuation"];
        if (rang.length) {
            sourceType = pickerTypeInputValuationPrice;
        }
        if ([cell.textLabel.text isEqualToString:@"Price (S$)"]) {
            sourceType = pickerTypeInputPrice;
        }
        rang = [cell.textLabel.text rangeOfString:@"Monthly Rental"];
        if (rang.length) {
            sourceType = pickerTypeInputMonthlyRental;
        }
        rang = [cell.textLabel.text rangeOfString:@"Lease Term"];
        if (rang.length) {
            sourceType = pickerTypeInputLeaseTerm;
        }
        picker = [[DCAPickerViewController alloc]initWithDictionary:staticData andSourceType:sourceType andValue:cell.detailTextLabel.text];
        picker.delegate = self;
        //picker.customValue = cell.detailTextLabel.text;
        [self presentSemiModalViewController:picker];
//        }
    }
#pragma mark . Special Features
    if ([headerStr isEqualToString:@"Special Features"]) {
        if ([cell.textLabel.text isEqualToString:@"Unit Level"]) {
            NSArray *hdbTypeData = [staticData objectForKey:@"UnitLevel"];
            NSInteger selectedIndex = -1;
            NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
            if (![hdbType isEqualToString:@"Any"]) {
                selectedIndex = [hdbTypeData indexOfObject:hdbType];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCAOptionUnitLevel selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        if ([cell.textLabel.text isEqualToString:@"Furnishing"]) {
            NSArray *hdbTypeData = [staticData objectForKey:@"Furnishing"];
            NSInteger selectedIndex = -1;
            NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
            if (![hdbType isEqualToString:@"Any"]) {
                selectedIndex = [hdbTypeData indexOfObject:hdbType];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCAOptionFurnishing selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        if ([cell.textLabel.text isEqualToString:@"Condition "]) {
            NSArray *hdbTypeData = [staticData objectForKey:@"Condition"];
            NSInteger selectedIndex = -1;
            NSString *hdbType = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
            if (![hdbType isEqualToString:@"Any"]) {
                selectedIndex = [hdbTypeData indexOfObject:hdbType];
            }
            DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:hdbTypeData DCAOptionType:DCAOptionFurnishing selectedIndex:selectedIndex];
            dcaOptionViewCtr.delegate = self;
            [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
            return;
        }
        if ([cell.textLabel.text isEqualToString:@"Others"]) {
            NSArray *HDBEstateData = [staticData objectForKey:@"OthersFeatures"];
            NSString *hdbEstateString = cell.detailTextLabel.text;
                NSArray *array = [hdbEstateString componentsSeparatedByString:@", "];
                if ([hdbEstateString isEqualToString:@"Any"] || [hdbEstateString isEqualToString:@"Others Features"]) {
                    array = nil;
                }
                DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:HDBEstateData DCAOptionType:DCAOptionOthersFeatures selectedValues:array];
                dcaOptionViewCtr.multiSelect = YES;
                dcaOptionViewCtr.delegate = self;
                [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
                return;
            }

    }
#pragma mark . Address of Property
    //               @"Address of Property",
    if ([headerStr isEqualToString:@"Address of Property"]) {
        [self.phTextView becomeFirstResponder];
        [self.phTextView setText:cell.detailTextLabel.text];
        [self.titleInputTextForm setText:[NSString stringWithFormat:@"%@", [array objectAtIndex:indexPath.row]]];
        [self textViewDidChange:self.phTextView];
        [self showDialog:self.inputTextForm];
    }
#pragma mark . Description of Property
    //               @"Description of Property",
    if ([headerStr isEqualToString:@"Description of Property"]) {
        [self.phTextView becomeFirstResponder];
        [self.phTextView setText:cell.textLabel.text];
        [self.titleInputTextForm setText:[NSString stringWithFormat:@"%@", headerStr]];
        [self textViewDidChange:self.phTextView];
        [self showDialog:self.inputTextForm];
    }
#pragma mark . Pictures, URLs & Videos
    //               @"Pictures, URLs & Videos",
    if ([headerStr isEqualToString:@"Pictures, URLs & Videos"]) {
        rang = [cell.textLabel.text rangeOfString:@"Images"];
        if (rang.length) {
            if (!insertPicCtr) {
                insertPicCtr = [[InsertPictureViewController alloc]init];
                insertPicCtr.keyForTitle = cell.textLabel.text;
                insertPicCtr.delegate = self;
            }
            
            [self.navigationController pushViewController:insertPicCtr animated:YES];
        }
        rang = [cell.textLabel.text rangeOfString:@"URL"];
        if (rang.length) {
            if (!insertURLsCtr) {
                insertURLsCtr = [[InsertURLViewController alloc]init];
                insertURLsCtr.delegate = self;
                insertURLsCtr.keyForTitle = cell.textLabel.text;
            }
            
            [self.navigationController pushViewController:insertURLsCtr animated:YES];
        }
        rang = [cell.textLabel.text rangeOfString:@"Video"];
        if (rang.length) {
            if (!insertVideosCtr) {
                insertVideosCtr = [[InsertURLViewController alloc]init];
                insertVideosCtr.delegate = self;
                insertVideosCtr.keyForTitle = cell.textLabel.text;
            }
            
            [self.navigationController pushViewController:insertVideosCtr animated:YES];
        }

    }
#pragma mark . Home Interior 
    //Home Interior
    if ([headerStr isEqualToString:@"Home Interior"]) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByAppendingFormat:@"%@, ", cell.textLabel.text];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@, ", cell.textLabel.text] withString:@""];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }
    }
#pragma mark . Interior and Fixtures & Fittings
    if ([headerStr isEqualToString:@"Interior and Fixtures & Fittings"]) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByAppendingFormat:@"%@, ", cell.textLabel.text];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@, ", cell.textLabel.text] withString:@""];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }
    }
#pragma mark . Fixtures & Fittings
    if ([headerStr isEqualToString:@"Fixtures & Fittings"]) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByAppendingFormat:@"%@, ", cell.textLabel.text];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@, ", cell.textLabel.text] withString:@""];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }
    }

#pragma mark . Amenities
    if ([headerStr isEqualToString:@"Amenities"]) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByAppendingFormat:@"%@, ", cell.textLabel.text];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@, ", cell.textLabel.text] withString:@""];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }
    }
    
#pragma mark . Indoor & Outdoors
    if ([headerStr isEqualToString:@"Indoor & Outdoors"]) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByAppendingFormat:@"%@, ", cell.textLabel.text];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@, ", cell.textLabel.text] withString:@""];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }
    }
#pragma mark . Restrictions ( if any )
    if ([headerStr isEqualToString:@"Restrictions ( if any )"]) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByAppendingFormat:@"%@, ", cell.textLabel.text];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            NSString *fixtures_fittings = [[NSUserDefaults standardUserDefaults] valueForKey:headerStr];
            fixtures_fittings = [fixtures_fittings stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@, ", cell.textLabel.text] withString:@""];
            [[NSUserDefaults standardUserDefaults] setValue:fixtures_fittings forKey:headerStr];
        }
    }

}
#pragma mark DCAPOptionViewController Delegate
- (void) didSelectRowOfDCAOptionViewController:(DCAOptionsViewController *)dcaViewCtr
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:currentIndexPath];
    NSString *value = @"";
    if (dcaViewCtr.selectedIndex>=0 && dcaViewCtr.selectedIndex < dcaViewCtr.intSource.count) {
        value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
    }
    if (dcaViewCtr.sourceType == DCAOptionOthersFeatures) {
        
        if (dcaViewCtr.selectedValues.count >= 1) {
            value = [dcaViewCtr.selectedValues objectAtIndex:0];
            [dcaViewCtr.selectedValues removeObjectAtIndex:0];
            for (NSString *str in dcaViewCtr.selectedValues) {
                value = [value stringByAppendingFormat:@", %@", str];
            }
        }else
            value = @"Others Features";
    }
    if (dcaViewCtr.sourceType == DCAOptionUnitLevel) {
        value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
    }
    if (dcaViewCtr.sourceType == DCAOptionFurnishing) {
        value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
    }
    //Condition

    //Lease Term
    
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:cell.textLabel.text];
    
    [self propertyStatusChanged];
    
    [dcaViewCtr.navigationController popViewControllerAnimated:YES];
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


#pragma mark implement action

- (IBAction)clickedOnInputForm:(id)sender {
    //[self.textField resignFirstResponder];
    //UITableViewCell *cell = [_tableView cellForRowAtIndexPath:currentIndexPath];
    NSString *headerStr = [allKeys objectAtIndex:currentIndexPath.section];
    NSArray *array = [sourceData objectForKey:headerStr];
    if ([headerStr isEqualToString:@"Property Details"]) {
        if (currentIndexPath.row == array.count - 1 || currentIndexPath.row < 6) {
        }
        else{
            [[NSUserDefaults standardUserDefaults] setValue:self.textField.text forKey:[array objectAtIndex:currentIndexPath.row]];

        }
    }
    //               @"Address of Property",
    if ([headerStr isEqualToString:@"Address of Property"]) {
        [[NSUserDefaults standardUserDefaults] setValue:self.phTextView.text forKey:[array objectAtIndex:currentIndexPath.row]];
    }
    //               @"Description of Property",
    if ([headerStr isEqualToString:@"Description of Property"]) {
        [[NSUserDefaults standardUserDefaults] setValue:self.phTextView.text forKey:[array objectAtIndex:currentIndexPath.row]];
    }
    
    //               @"Pictures, URLs & Videos",
    
    //               @"Special Features",
    
    
    //Home Interior
        
    [self hideDialog:activeForm];
    [_tableView reloadData];
}

- (IBAction)submitAdClicked:(id)sender {
    //id data;
    NSString *functionName;
    NSMutableArray *paraNames;
    NSMutableArray *paraValues;
    NSMutableArray *pararNamesOnView;
    functionName = @"createHDB";
    NSArray *para = [self addValueForArrays];
    paraNames = [para objectAtIndex:0];
    paraValues = [para objectAtIndex:1];
    pararNamesOnView = [para objectAtIndex:2];
    NSString *notPassed = [self checkValue:pararNamesOnView of:paraValues];
    if (![notPassed isEqualToString:@""]) {
        [[PostadvertControllerV2 sharedPostadvertController] showAlertWithMessage:[NSString stringWithFormat:@"You must select: %@", notPassed ] andTitle:@"Submit Ad"];
        return;
    }
    HDBResultDetailViewController *detailViewCtr = [[HDBResultDetailViewController alloc]initBySubmitParaNames:paraNames andParavalues:paraValues withListImages:insertPicCtr.dataSoure];
    detailViewCtr.itemName = self.itemName;
    [self.navigationController pushViewController:detailViewCtr animated:YES];
//    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
//    
//    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data];
//    
//    if (dict.allKeys.count) {
//        
//        HBBResultCellData *cellData = [[HBBResultCellData alloc]init];
//        cellData.hdbID = [[dict objectForKey:@"id"] integerValue];
//        cellData.timeCreated = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
//        //cellData.titleHDB = [dict objectForKey:@"address"];
//        //        NSString *title = [dict objectForKey:@"street_name"];
//        //        cellData.titleHDB = [cellData.titleHDB stringByAppendingString:title];
//        
//        //author
//        NSDictionary *authorDict = [dict objectForKey:@"author"];
//        cellData.userInfo = [[CredentialInfo alloc]init];
//        if ([authorDict isKindOfClass:[NSDictionary class]]) {
//            cellData.userInfo = [[CredentialInfo alloc]initWithDictionary:authorDict];
//        }
//        
//        for (NSString *key in cellData.paraNames) {
//            id object = [dict objectForKey:key];
//            if (object != nil) {
//                [cellData.paraValues addObject: object];
//            }
//            
//        }
//        HDBResultDetailViewController *detailViewCtr = [[HDBResultDetailViewController alloc]initWithHDBID:cellData.hdbID userID:[[UserPAInfo sharedUserPAInfo]registrationID]];
//        //[self.navigationController popViewControllerAnimated:YES];
//        [self.navigationController pushViewController:detailViewCtr animated:YES];
//    }else
//    {
//        
//    }
}

- (IBAction)previewAdClicked:(id)sender {
    HDBResultDetailViewController *hdbResultViewCtr = [[HDBResultDetailViewController alloc] init];
    hdbResultViewCtr.itemName = self.itemName;
    hdbResultViewCtr.viewMode = 0;
    NSArray *source = [NSArray arrayWithArray:[self addValueForArrays]];
    hdbResultViewCtr.sourceForPreviewMode = source;
    hdbResultViewCtr.listImages = insertPicCtr.dataSoure;
    NSString *notPassed = [self checkValue:source[2]of:source[1]];
    if (![notPassed isEqualToString:@""]) {
        [[PostadvertControllerV2 sharedPostadvertController] showAlertWithMessage:[NSString stringWithFormat:@"You must select: %@", notPassed ] andTitle:@"Preview Ad"];
    }else
        [self.navigationController pushViewController:hdbResultViewCtr animated:YES];
}

- (IBAction)btnCancelClicked:(id)sender {
    [self hideDialog:activeForm];
}

#pragma mark - 

- (void) propertyStatusChanged
{
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"Property Status *"];
    //For Sale
    //For Rent
    NSRange rang ;
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray: [sourceData objectForKey:@"Property Details"]];
    NSString *key;
    if ([value isEqualToString:@"For Sale"]) {
        
        for (NSInteger index = 0; index < array.count; index ++) {
            //Monthly Rental (S$)
            key = [array objectAtIndex:index];
            rang = [key rangeOfString:@"Monthly"];
            if (rang.length) {
                [array replaceObjectAtIndex:index withObject:@"Price (S$)"];
            }
            //Lease Term
            rang = [key rangeOfString:@"Lease Term"];
            if (rang.length) {
                [array replaceObjectAtIndex:index withObject:@"Valuation Price (S$)"];
            }
        }
       
    }
    else if ([value isEqualToString:@"For Rent"]) {
        
        for (NSInteger index = 0; index < array.count; index ++) {
            //Price (S$)
            key = [array objectAtIndex:index];
            if ([key isEqualToString:@"Price (S$)"]) {
                [array replaceObjectAtIndex:index withObject:@"Monthly Rental (S$)"];
            }
            //Valuation Price (S$)
            rang = [key rangeOfString:@"Valuation Price (S$)"];
            if (rang.length) {
                [array replaceObjectAtIndex:index withObject:@"Lease Term"];
            }
        }
        
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        if ([value isEqualToString:@"For Sale"]) {
            NSInteger index = [array indexOfObject:@"Tenure *"];
            if (index == NSIntegerMax) {
                [array insertObject:@"Tenure *" atIndex:3];
            }
        
        }else{
            [array removeObject:@"Tenure *"];
        }
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        if ([value isEqualToString:@"For Sale"]) {
            NSInteger index = [array indexOfObject:@"Tenure *"];
            if (index == NSIntegerMax) {
                [array insertObject:@"Tenure *" atIndex:3];
            }
            
        }else{
            [array removeObject:@"Tenure *"];
        }
    }
    [sourceData setObject:array forKey:@"Property Details"];
    
    
}

- (NSArray*) addValueForArrays;
{
    NSMutableArray *paraNames = [[NSMutableArray alloc]init];
    NSMutableArray *paraValues = [[NSMutableArray alloc]init];
    NSMutableArray *paraNamesOnView = [[NSMutableArray alloc]init];
    NSMutableArray *templateArray = [[NSMutableArray alloc]init];

    @try {
        
        NSString *value;
        NSString *key;
        NSUserDefaults *database = [NSUserDefaults standardUserDefaults];
#pragma mark . HDB
        if ([self.itemName isEqualToString:@"HDB Search"]) {
            //    createHDB($property_status, $block, $street_name, $property_type, $hdb_owner, $hdb_estate, $bedrooms, $washrooms, $price, $size, $valuation, $lease_term, $completion, $unit_level, $furnishing, $condition, $description, $other_features, $fixtures_fittings, $picture, $url, $video, $user_id, $limit, $base64_image = false)
            //property_status
            [paraNames addObject:@"property_status"];
            key = @"Property Status *";
            value = [database objectForKey:key];
            if ([value isEqualToString:@"For Sale"]) {
                value = @"s";
            }else
                value = @"r";
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Property Status *"];
            //block
            [paraNames addObject:@"block"];
            key = @"Block No. *";
            value = [database objectForKey:key];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Block No. *"];
            //street_name
            [paraNames addObject:@"street_name"];
            key = @"Street Name *";
            value = [database objectForKey:key];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Street Name *"];
            //property_type
            [paraNames addObject:@"property_type"];
            key = @"HDB Type *";
            value = [database objectForKey:key];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"HDB Type *"];
            //hdb_owner
            [paraNames addObject:@"hdb_owner"];
            value = [database objectForKey:@"Ad Owner *"];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Ad Owner *"];
            //hdb_estate
            [paraNames addObject:@"hdb_estate"];
            [paraValues addObject:[database objectForKey:@"HDB Estate *"]];
            [paraNamesOnView addObject:@"HDB Estate *"];
            //bedrooms
            [paraNames addObject:@"bedrooms"];
            value = [database objectForKey:@"No. of Bedrooms *"];
            value = [NSString stringWithFormat:@"%d", [value integerValue]];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"No. of Bedrooms *"];
            //washrooms
            [paraNames addObject:@"washrooms"];
            value = [database objectForKey:@"No. of Washrooms *"];
            value = [NSString stringWithFormat:@"%d", [value integerValue]];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"No. of Washrooms *"];
            //price
            [paraNames addObject:@"price"];
            value = [paraValues objectAtIndex:0];
            if ([value isEqualToString:@"s"]) {
                [paraValues addObject:[database objectForKey:@"Price (S$)"]];
                [paraNamesOnView addObject:@"Price (S$)"];
            }else
            {
                [paraValues addObject:[database objectForKey:@"Monthly Rental (S$)"]];
                [paraNamesOnView addObject:@"Monthly Rental (S$)"];
            }
            //size
            [paraNames addObject:@"size"];
            [paraValues addObject:[database objectForKey:@"Size (sq ft) *"]];
            [paraNamesOnView addObject:@"Size (sq ft) *"];
            //valuation
            [paraNames addObject:@"valuation"];
            [paraValues addObject:[database objectForKey:@"Valuation Price (S$)"]];
            [paraNamesOnView addObject:@"Valuation Price (S$)"];
            //lease_term
            [paraNames addObject:@"lease_term"];
            value = [database objectForKey:@"Lease Term"];
            templateArray = [NSMutableArray arrayWithArray: [SupportFunction numbersFromFullYearsMonths:value]];
            [paraValues addObject:templateArray[3]];
            [paraNamesOnView addObject:@"Lease Term"];
            //completion
            [paraNames addObject:@"completion"];
            [paraValues addObject:[database objectForKey:@"Building Completion"]];
            [paraNamesOnView addObject:@"Building Completion"];
            //unit_level
            [paraNames addObject:@"unit_level"];
            [paraValues addObject:[database objectForKey:@"Unit Level"]];
            [paraNamesOnView addObject:@"Unit Level"];
            //furnishing
            [paraNames addObject:@"furnishing"];
            [paraValues addObject:[database objectForKey:@"Furnishing"]];
            [paraNamesOnView addObject:@"Furnishing"];
            //condition
            [paraNames addObject:@"condition"];
            [paraValues addObject:[database objectForKey:@"Condition "]];
            [paraNamesOnView addObject:@"Condition "];
            //description
            [paraNames addObject:@"description"];
            value = [database objectForKey:@"Description of Property"];
            
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Description *"];
            //other_features
            [paraNames addObject:@"other_features"];
            [paraValues addObject:[database objectForKey:@"Others"]];
            [paraNamesOnView addObject:@"Others"];
            //fixtures_fittings
            [paraNames addObject:@"fixtures_fittings"];
            value = [database objectForKey:@"Home Interior"];
            if (value == nil) {
                value = @"";
            }
            if ([value rangeOfString:@","].length) {
                value = [value substringToIndex:value.length - 2];
            }
            [paraValues addObject: value];
            [paraNamesOnView addObject:@"Home Interior"];
            //picture
            [paraNames addObject:@"picture"];
            value = @"";
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Upload Images"];
            //url
            [paraNames addObject:@"url"];
            value = @"";
            for (NSString* urlStr in insertURLsCtr.listURLs) {
                value = [value stringByAppendingString:urlStr];
                value = [value stringByAppendingString:@","];
            }
            if (![value isEqualToString:@""]) {
                NSRange rang = [value rangeOfString:@"," options:NSBackwardsSearch];
                value = [value stringByReplacingCharactersInRange:rang withString:@""];
            }
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Insert URLs"];
            //video
            [paraNames addObject:@"video"];
            value = @"";
            for (NSString* urlStr in insertVideosCtr.listURLs) {
                value = [value stringByAppendingString:urlStr];
                value = [value stringByAppendingString:@","];
            }
            if (![value isEqualToString:@""]) {
                NSRange rang = [value rangeOfString:@"," options:NSBackwardsSearch];
                value = [value stringByReplacingCharactersInRange:rang withString:@""];
            }
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Insert Videos"];
            //user_id
            [paraNames addObject:@"user_id"];
            [paraValues addObject:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID]];
            [paraNamesOnView addObject:@""];
            //limit
            [paraNames addObject:@"limit"];
            [paraValues addObject:@"1"];
            [paraNamesOnView addObject:@"1"];
        }
#pragma mark . Condos
        if ([self.itemName isEqualToString:@"Condos Search"]) {
//            property_status
            [paraNames addObject:@"property_status"];
            key = @"Property Status *";
            value = [database objectForKey:key];
            if ([value isEqualToString:@"For Sale"]) {
                value = @"s";
            }else
                value = @"r";
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Property Status *"];
//            address
            [paraNames addObject:@"address"];
            key = @"Address *";
            value = [database objectForKey:key];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Address *"];
//            project_name
            [paraNames addObject:@"project_name"];
            key = @"Project Name *";
            value = [database objectForKey:key];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Project Name *"];
//            ad_owner
            [paraNames addObject:@"ad_owner"];
            value = [database objectForKey:@"Ad Owner *"];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Ad Owner *"];
//            district
            [paraNames addObject:@"district"];
            [paraValues addObject:[database objectForKey:@"District *"]];
            [paraNamesOnView addObject:@"District *"];
//            tenure
            [paraNames addObject:@"tenure"];
            [paraValues addObject:[database objectForKey:@"Tenure *"]];
            key = @"Property Status *";
            value = [database objectForKey:key];
            if ([value isEqualToString:@"For Sale"]) {
                [paraNamesOnView addObject:@"Tenure *"];
            }else
                [paraNamesOnView addObject:@"Tenure"];
//            bedrooms
            [paraNames addObject:@"bedrooms"];
            value = [database objectForKey:@"No. of Bedrooms *"];
            value = [NSString stringWithFormat:@"%d", [value integerValue]];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"No. of Bedrooms *"];

//            washrooms
            [paraNames addObject:@"washrooms"];
            value = [database objectForKey:@"No. of Washrooms *"];
            value = [NSString stringWithFormat:@"%d", [value integerValue]];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"No. of Washrooms *"];
//            price
            [paraNames addObject:@"price"];
            value = [paraValues objectAtIndex:0];
            if ([value isEqualToString:@"s"]) {
                [paraValues addObject:[database objectForKey:@"Price (S$)"]];
                [paraNamesOnView addObject:@"Price (S$)"];
            }else
            {
                [paraValues addObject:[database objectForKey:@"Monthly Rental (S$)"]];
                [paraNamesOnView addObject:@"Monthly Rental (S$)"];
            }
//            size
            [paraNames addObject:@"size"];
            [paraValues addObject:[database objectForKey:@"Size (sq ft) *"]];
            [paraNamesOnView addObject:@"Size (sq ft) *"];
//            valuation
            [paraNames addObject:@"valuation"];
            [paraValues addObject:[database objectForKey:@"Valuation Price (S$)"]];
            [paraNamesOnView addObject:@"Valuation Price (S$)"];
//            lease_term
            [paraNames addObject:@"lease_term"];
            value = [database objectForKey:@"Lease Term"];
            templateArray = [NSMutableArray arrayWithArray: [SupportFunction numbersFromFullYearsMonths:value]];
            [paraValues addObject:templateArray[3]];
            [paraNamesOnView addObject:@"Lease Term"];
//            completion
            [paraNames addObject:@"completion"];
            [paraValues addObject:[database objectForKey:@"TOP"]];
            [paraNamesOnView addObject:@"TOP"];
//            unit_level
            [paraNames addObject:@"unit_level"];
            [paraValues addObject:[database objectForKey:@"Unit Level"]];
            [paraNamesOnView addObject:@"Unit Level"];
//            furnishing
            [paraNames addObject:@"furnishing"];
            [paraValues addObject:[database objectForKey:@"Furnishing"]];
            [paraNamesOnView addObject:@"Furnishing"];
//            condition
            [paraNames addObject:@"condition"];
            [paraValues addObject:[database objectForKey:@"Condition "]];
            [paraNamesOnView addObject:@"Condition "];
//            description
            [paraNames addObject:@"description"];
            value = [database objectForKey:@"Description of Property"];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Description *"];
//            other_features
            [paraNames addObject:@"other_features"];
            [paraValues addObject:[database objectForKey:@"Others"]];
            [paraNamesOnView addObject:@"Others"];
//            fixtures_fittings
            [paraNames addObject:@"fixtures_fittings"];
            value = [database objectForKey:@"Interior and Fixtures & Fittings"];
            if (value == nil) {
                value = @"";
            }
            if ([value rangeOfString:@","].length) {
                value = [value substringToIndex:value.length - 2];
            }
            [paraValues addObject: value];
            [paraNamesOnView addObject:@"Interior and Fixtures & Fittings"];
//            picture
            [paraNames addObject:@"picture"];
            value = @"";
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Upload Images"];
//            url
            [paraNames addObject:@"url"];
            value = @"";
            for (NSString* urlStr in insertURLsCtr.listURLs) {
                value = [value stringByAppendingString:urlStr];
                value = [value stringByAppendingString:@","];
            }
            if (![value isEqualToString:@""]) {
                NSRange rang = [value rangeOfString:@"," options:NSBackwardsSearch];
                value = [value stringByReplacingCharactersInRange:rang withString:@""];
            }
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Insert URLs"];
//            video
            [paraNames addObject:@"video"];
            value = @"";
            for (NSString* urlStr in insertVideosCtr.listURLs) {
                value = [value stringByAppendingString:urlStr];
                value = [value stringByAppendingString:@","];
            }
            if (![value isEqualToString:@""]) {
                NSRange rang = [value rangeOfString:@"," options:NSBackwardsSearch];
                value = [value stringByReplacingCharactersInRange:rang withString:@""];
            }
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Insert Videos"];
//            amenities
            [paraNames addObject:@"amenities"];
            value = [database objectForKey:@"Amenities"];
            if (value == nil) {
                value = @"";
            }
            if ([value rangeOfString:@","].length) {
                value = [value substringToIndex:value.length - 2];
            }
            [paraValues addObject: value];
            [paraNamesOnView addObject:@"Amenities"];
//            user_id
            [paraNames addObject:@"user_id"];
            [paraValues addObject:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID]];
            [paraNamesOnView addObject:@""];
//            limit
            [paraNames addObject:@"limit"];
            [paraValues addObject:@"1"];
            [paraNamesOnView addObject:@"1"];
//            base64_image
        }
#pragma mark . Landed Property
        if ([self.itemName isEqualToString:@"Landed Property Search"]) {
//            property_status,
            [paraNames addObject:@"property_status"];
            key = @"Property Status *";
            value = [database objectForKey:key];
            if ([value isEqualToString:@"For Sale"]) {
                value = @"s";
            }else
                value = @"r";
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Property Status *"];
//            address,
            [paraNames addObject:@"address"];
            key = @"Address *";
            value = [database objectForKey:key];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Address *"];
//            ad_owner,
            [paraNames addObject:@"ad_owner"];
            value = [database objectForKey:@"Ad Owner *"];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Ad Owner *"];
//            district,
            [paraNames addObject:@"district"];
            [paraValues addObject:[database objectForKey:@"District *"]];
            [paraNamesOnView addObject:@"District *"];
//            tenure,
            [paraNames addObject:@"tenure"];
            [paraValues addObject:[database objectForKey:@"Tenure *"]];
            key = @"Property Status *";
            value = [database objectForKey:key];
            if ([value isEqualToString:@"For Sale"]) {
                [paraNamesOnView addObject:@"Tenure *"];
            }else
                [paraNamesOnView addObject:@"Tenure"];
//            bedrooms,
            [paraNames addObject:@"bedrooms"];
            value = [database objectForKey:@"No. of Bedrooms *"];
            value = [NSString stringWithFormat:@"%d", [value integerValue]];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"No. of Bedrooms *"];
//            washrooms,
            [paraNames addObject:@"washrooms"];
            value = [database objectForKey:@"No. of Washrooms *"];
            value = [NSString stringWithFormat:@"%d", [value integerValue]];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"No. of Washrooms *"];
//            price,
            [paraNames addObject:@"price"];
            value = [paraValues objectAtIndex:0];
            if ([value isEqualToString:@"s"]) {
                [paraValues addObject:[database objectForKey:@"Price (S$)"]];
                [paraNamesOnView addObject:@"Price (S$)"];
            }else
            {
                [paraValues addObject:[database objectForKey:@"Monthly Rental (S$)"]];
                [paraNamesOnView addObject:@"Monthly Rental (S$)"];
            }

//            size,
            [paraNames addObject:@"size"];
            [paraValues addObject:[database objectForKey:@"Size (sq ft) *"]];
            [paraNamesOnView addObject:@"Size (sq ft) *"];
//            valuation,
            [paraNames addObject:@"valuation"];
            [paraValues addObject:[database objectForKey:@"Valuation Price (S$)"]];
            [paraNamesOnView addObject:@"Valuation Price (S$)"];
//            lease_term,
            [paraNames addObject:@"lease_term"];
            value = [database objectForKey:@"Lease Term"];
            templateArray = [NSMutableArray arrayWithArray: [SupportFunction numbersFromFullYearsMonths:value]];
            [paraValues addObject:templateArray[3]];
            [paraNamesOnView addObject:@"Lease Term"];
//            completion,
            [paraNames addObject:@"completion"];
            [paraValues addObject:[database objectForKey:@"Building Completion"]];
            [paraNamesOnView addObject:@"Building Completion"];
//            furnishing,
            [paraNames addObject:@"furnishing"];
            [paraValues addObject:[database objectForKey:@"Furnishing"]];
            [paraNamesOnView addObject:@"Furnishing"];
//            condition,
            [paraNames addObject:@"condition"];
            [paraValues addObject:[database objectForKey:@"Condition "]];
            [paraNamesOnView addObject:@"Condition "];
//            indoor_outdoors,
            [paraNames addObject:@"indoor_outdoors"];
            value = [database objectForKey:@"Indoor & Outdoors"];
            if (value == nil) {
                value = @"";
            }
            if ([value rangeOfString:@","].length) {
                value = [value substringToIndex:value.length - 2];
            }
            [paraValues addObject: value];
            [paraNamesOnView addObject:@"Indoor & Outdoors"];
//            description,
            [paraNames addObject:@"description"];
            value = [database objectForKey:@"Description of Property"];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Description *"];
//            fixtures_fittings,
            [paraNames addObject:@"fixtures_fittings"];
            value = [database objectForKey:@"Fixtures & Fittings"];
            if (value == nil) {
                value = @"";
            }
            if ([value rangeOfString:@","].length) {
                value = [value substringToIndex:value.length - 2];
            }
            [paraValues addObject: value];
            [paraNamesOnView addObject:@"Fixtures & Fittings"];
//            special_features,
            [paraNames addObject:@"other_features"];
            [paraValues addObject:[database objectForKey:@"Others"]];
            [paraNamesOnView addObject:@"Others"];
//            picture,
            [paraNames addObject:@"picture"];
            value = @"";
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Upload Images"];
//            url,
            [paraNames addObject:@"url"];
            value = @"";
            for (NSString* urlStr in insertURLsCtr.listURLs) {
                value = [value stringByAppendingString:urlStr];
                value = [value stringByAppendingString:@","];
            }
            if (![value isEqualToString:@""]) {
                NSRange rang = [value rangeOfString:@"," options:NSBackwardsSearch];
                value = [value stringByReplacingCharactersInRange:rang withString:@""];
            }
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Insert URLs"];
//            video,
            [paraNames addObject:@"video"];
            value = @"";
            for (NSString* urlStr in insertVideosCtr.listURLs) {
                value = [value stringByAppendingString:urlStr];
                value = [value stringByAppendingString:@","];
            }
            if (![value isEqualToString:@""]) {
                NSRange rang = [value rangeOfString:@"," options:NSBackwardsSearch];
                value = [value stringByReplacingCharactersInRange:rang withString:@""];
            }
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Insert Videos"];
//            user_id,
            [paraNames addObject:@"user_id"];
            [paraValues addObject:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID]];
            [paraNamesOnView addObject:@""];
//            limit,
            [paraNames addObject:@"limit"];
            [paraValues addObject:@"1"];
            [paraNamesOnView addObject:@"1"];
//            base64_image
        }
#pragma mark . Rooms For Rent
        if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
            
//            address,
            [paraNames addObject:@"address"];
            key = @"Address *";
            value = [database objectForKey:key];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Address *"];
//            property_type,
            [paraNames addObject:@"property_type"];
            key = @"Property Type *";
            value = [database objectForKey:key];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Property Type *"];
//            ad_owner,
            [paraNames addObject:@"ad_owner"];
            value = [database objectForKey:@"Ad Owner *"];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Ad Owner *"];
//            location,
            [paraNames addObject:@"location"];
            [paraValues addObject:[database objectForKey:@"District *"]];
            [paraNamesOnView addObject:@"District *"];
//            lease_term,
            [paraNames addObject:@"lease_term"];
            value = [database objectForKey:@"Lease Term"];
            templateArray = [NSMutableArray arrayWithArray: [SupportFunction numbersFromFullYearsMonths:value]];
            [paraValues addObject:templateArray[3]];
            [paraNamesOnView addObject:@"Lease Term"];
//            room_type,
            [paraNames addObject:@"room_type"];
            [paraValues addObject:[database objectForKey:@"Room Type"]];
            [paraNamesOnView addObject:@"Room Type"];
//            attached_bathroom,
            [paraNames addObject:@"attached_bathroom"];
            value = [database objectForKey:@"Attached Bathroom"];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Attached Bathroom"];
//            price,
            [paraNames addObject:@"price"];
            value = [paraValues objectAtIndex:0];
            [paraValues addObject:[database objectForKey:@"Monthly Rental (S$)"]];
            [paraNamesOnView addObject:@"Monthly Rental (S$)"];
//            size,
            [paraNames addObject:@"size"];
            [paraValues addObject:[database objectForKey:@"Size (sq ft) *"]];
            [paraNamesOnView addObject:@"Size (sq ft) *"];
//            unit_level,
            [paraNames addObject:@"unit_level"];
            [paraValues addObject:[database objectForKey:@"Unit Level"]];
            [paraNamesOnView addObject:@"Unit Level"];
//            furnishing,
            [paraNames addObject:@"furnishing"];
            [paraValues addObject:[database objectForKey:@"Furnishing"]];
            [paraNamesOnView addObject:@"Furnishing"];
//            condition, 
            [paraNames addObject:@"condition"];
            [paraValues addObject:[database objectForKey:@"Condition "]];
            [paraNamesOnView addObject:@"Condition "];

//            description,
            [paraNames addObject:@"description"];
            value = [database objectForKey:@"Description of Property"];
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Description *"];
//            special_features,
            [paraNames addObject:@"special_features"];
            [paraValues addObject:[database objectForKey:@"Others"]];
            [paraNamesOnView addObject:@"Others"];
//            home_interior,
            [paraNames addObject:@"home_interior"];
            value = [database objectForKey:@"Home Interior"];
            if (value == nil) {
                value = @"";
            }
            if ([value rangeOfString:@","].length) {
                value = [value substringToIndex:value.length - 2];
            }
            [paraValues addObject: value];
            [paraNamesOnView addObject:@"Home Interior"];
//            restrictions,
            [paraNames addObject:@"restrictions"];
            value = [database objectForKey:@"Restrictions ( if any )"];
            if (value == nil) {
                value = @"";
            }
            if ([value rangeOfString:@","].length) {
                value = [value substringToIndex:value.length - 2];
            }
            [paraValues addObject: value];
            [paraNamesOnView addObject:@"Restrictions ( if any )"];
//            picture,
            [paraNames addObject:@"picture"];
            value = @"";
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Upload Images"];
//            url,
            [paraNames addObject:@"url"];
            value = @"";
            for (NSString* urlStr in insertURLsCtr.listURLs) {
                value = [value stringByAppendingString:urlStr];
                value = [value stringByAppendingString:@","];
            }
            if (![value isEqualToString:@""]) {
                NSRange rang = [value rangeOfString:@"," options:NSBackwardsSearch];
                value = [value stringByReplacingCharactersInRange:rang withString:@""];
            }
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Insert URLs"];
//            video,
            [paraNames addObject:@"video"];
            value = @"";
            for (NSString* urlStr in insertVideosCtr.listURLs) {
                value = [value stringByAppendingString:urlStr];
                value = [value stringByAppendingString:@","];
            }
            if (![value isEqualToString:@""]) {
                NSRange rang = [value rangeOfString:@"," options:NSBackwardsSearch];
                value = [value stringByReplacingCharactersInRange:rang withString:@""];
            }
            [paraValues addObject:value];
            [paraNamesOnView addObject:@"Insert Videos"];
//            amenities,
            [paraNames addObject:@"amenities"];
            value = [database objectForKey:@"Amenities"];
            if (value == nil) {
                value = @"";
            }
            if ([value rangeOfString:@","].length) {
                value = [value substringToIndex:value.length - 2];
            }
            [paraValues addObject: value];
            [paraNamesOnView addObject:@"Amenities"];
//            user_id,
            [paraNames addObject:@"user_id"];
            [paraValues addObject:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID]];
            [paraNamesOnView addObject:@""];
//            limit,
            [paraNames addObject:@"limit"];
            [paraValues addObject:@"1"];
            [paraNamesOnView addObject:@"1"];

        }


    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    for (int i = 0; i < paraValues.count; i++) {
        NSString *value = [paraValues objectAtIndex:i];
        if ([value isEqualToString:@"Select One"] || [value isEqualToString:@"Others Features"]) {
            value = @"";
            [paraValues replaceObjectAtIndex:i withObject:@""];
        }
    }
    return [NSArray arrayWithObjects:paraNames, paraValues, paraNamesOnView, nil];
}

- (NSString*) checkValue:(NSMutableArray*)paraNames of:(NSMutableArray*)paraValues
{
    NSString *notPassed =@"";
    NSInteger index;
    NSRange rang;
    NSString *value;
    for (NSString *key in paraNames) {
        rang = [key rangeOfString:@"*"];
        index = [paraNames indexOfObject:key];
        if (index != NSIntegerMax) {
            value = [paraValues objectAtIndex:index];
        }
        if ([value isEqualToString:@"Select One"] || [value isEqualToString:@"Others Features"]) {
            value = @"";
            [paraValues replaceObjectAtIndex:index withObject:@""];
        }
        if (rang.length) {
            if ([value isEqualToString:@""] ) {
                value = [key stringByReplacingOccurrencesOfString:@"*" withString:@""];
                value = [NSString stringWithFormat:@"\n%@", value];
                notPassed = [NSString stringWithFormat:@" %@ %@", notPassed, value];
            }
        }
    }
    return notPassed;
}
- (void) resetValue
{
    //return;
    NSUserDefaults *database = [NSUserDefaults standardUserDefaults];
    //property_status
    [database setValue:@"Select One" forKey:@"Property Status *"];
    //block
    [database setValue:@"" forKey:@"Block No. *"];
    //street_name
    [database setValue:@"" forKey:@"Street Name *"];
    //property_type
    [database setValue:@"Select One" forKey:@"HDB Type *"];
    //hdb_owner
    [database setValue:@"Select One" forKey:@"Ad Owner *"];
    //hdb_estate
    [database setValue:@"Select One" forKey:@"HDB Estate *"];
    //bedrooms
    [database setValue:@"Select One" forKey:@"No. of Bedrooms *"];
    //washrooms
    [database setValue:@"Select One" forKey:@"No. of Washrooms *"];
    //price
    [database setValue:@"" forKey:@"Price (S$)"];
    //size
    [database setValue:@"" forKey:@"Size (sq ft) *"];
    //valuation
    [database setValue:@"" forKey:@"Valuation Price (S$)"];
    //lease_term
    [database setValue:@"" forKey:@"Lease Term"];
    //completion
    [database setValue:@"" forKey:@"Building Completion"];
    //unit_level
    [database setValue:@"Select One" forKey:@"Unit Level"];
    //furnishing
    [database setValue:@"Select One" forKey:@"Furnishing"];
    //condition
    [database setValue:@"Select One" forKey:@"Condition "];
    //description
    [database setValue:@"" forKey:@"Description of Property"];
    //other_features
    [database setValue:@"" forKey:@"Others"];
    //fixtures_fittings
    [database setValue:@"" forKey:@"Home Interior"];
    //picture
    [database setValue:@"" forKey:@"Upload Images"];
    
    NSArray *propertyDetails = [sourceData objectForKey:@"Property Details"];
    NSArray *defaultValue = [sourceData objectForKey:@"Default Value"];
    for (int i = 0 ; i < propertyDetails.count; i++) {
        NSString *key = [propertyDetails objectAtIndex:i];
        NSString *value = [defaultValue objectAtIndex:i];
        [database setValue:value forKey:key];
    }
    
    if (insertPicCtr) {
        [insertPicCtr.dataSoure removeAllObjects];
        [insertPicCtr updateView];
    }
    //url
    [database setValue:@"" forKey:@"Insert URLs"];
    if (insertURLsCtr) {
        [insertURLsCtr.listURLs removeAllObjects];
    }
    //video
    [database setValue:@"" forKey:@"Insert Videos"];
    if (insertVideosCtr) {
        [insertVideosCtr.listURLs removeAllObjects];
    }
    //user_id
    
    //limit

    //Size (sqm) *
    [database setValue:@"" forKey:@"Size (sqm) *"];
    [database setValue:@"" forKey:@"Monthly Rental (S$)"];
    [database setValue:@"" forKey:@"Lease Term"];
    [database setValue:@"" forKey:@"fixtures_fittings"];
    [database setValue:@"" forKey:@"other_features"];
    
    //
    [database setValue:@"" forKey:@"Address *"];
#pragma mark . Condos
    [database setValue:@"Select One" forKey:@"Project Name *"];
    [database setValue:@"Select One" forKey:@"District *"];
    [database setValue:@"Select One" forKey:@"Tenure *"];
    [database setValue:@"Select One" forKey:@"TOP"];
    [database setValue:@"" forKey:@"Amenities"];
    [database setValue:@"" forKey:@"Interior and Fixtures & Fittings"];
#pragma mark . Landed Property
    [database setValue:@"" forKey:@"Indoor & Outdoors"];
    [database setValue:@"" forKey:@"Fixtures & Fittings"];
#pragma mark . Rooms For Rent
    [database setValue:@"" forKey:@"Restrictions ( if any )"];
    
}
#pragma mark DCAPickerViewControllerDelegate

-(void) didPickerCloseWithControll:(DCAPickerViewController *)ctr
{
    NSUserDefaults *database = [NSUserDefaults standardUserDefaults];
    //Size (sq ft) *
    if (ctr.sourceType == pickerTypeInputSizeSqft) {
        NSString *value = [ctr.customValue stringByReplacingOccurrencesOfString:@"," withString:@""];
        float sqftValue = [value floatValue];
        float sqmValue = sqftValue * 0.092903;
        
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2]; 
        
        NSString *sqftStr = [formatter stringFromNumber:[NSNumber numberWithFloat:sqftValue]];
        NSString *sqmStr = [formatter stringFromNumber:[NSNumber numberWithFloat:sqmValue]];
        [database setValue:sqftStr forKey:@"Size (sq ft) *"];
        [database setValue:sqmStr forKey:@"Size (sqm) *"];
    }
    //Size (sqm) *
    if (ctr.sourceType == pickerTypeInputSizeSqm) {
        NSString *value = [ctr.customValue stringByReplacingOccurrencesOfString:@"," withString:@""];
        float sqmValue = [value floatValue];
        float sqftValue = sqmValue * 10.7639;
        
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        
        NSString *sqftStr = [formatter stringFromNumber:[NSNumber numberWithFloat:sqftValue]];
        NSString *sqmStr = [formatter stringFromNumber:[NSNumber numberWithFloat:sqmValue]];
        [database setValue:sqftStr forKey:@"Size (sq ft) *"];
        [database setValue:sqmStr forKey:@"Size (sqm) *"];
    }
    // Price
    if (ctr.sourceType == pickerTypeInputPrice) {
        NSString *value = [ctr.customValue stringByReplacingOccurrencesOfString:@"," withString:@""];
        float price = [value floatValue];
        
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        
        NSString *priceStr = [formatter stringFromNumber:[NSNumber numberWithFloat:price]];
        [database setValue:priceStr forKey:@"Price (S$)"];
    }
    // ValuationPrice
    if (ctr.sourceType == pickerTypeInputValuationPrice) {
        NSString *value = [ctr.customValue stringByReplacingOccurrencesOfString:@"," withString:@""];
        float price = [value floatValue];
        
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        
        NSString *priceStr = [formatter stringFromNumber:[NSNumber numberWithFloat:price]];
        [database setValue:priceStr forKey:@"Valuation Price (S$)"];
    }
    // Monthly Rental
    if (ctr.sourceType == pickerTypeInputMonthlyRental) {
        NSString *value = [ctr.customValue stringByReplacingOccurrencesOfString:@"," withString:@""];
        float price = [value floatValue];
        
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        
        NSString *priceStr = [formatter stringFromNumber:[NSNumber numberWithFloat:price]];
        [database setValue:priceStr forKey:@"Monthly Rental (S$)"];
    }
    // Lease Term
    if (ctr.sourceType == pickerTypeInputLeaseTerm) {
        [database setValue:picker.customValue forKey:@"Lease Term"];
    }
    
    [self dismissSemiModalViewController:ctr];
    [self.tableView reloadData];
}

#pragma mark InsertPictureDelegate

- (void) InsertPictureDidDisappear
{
    NSInteger count = 0;
    NSString *keyForTitle = @"Upload Images";
    if (insertPicCtr) {
        count = insertPicCtr.dataSoure.count;
        keyForTitle = insertPicCtr.keyForTitle;
    }
    if (count) {
        if (count == 1) {
            [[NSUserDefaults standardUserDefaults] setValue:@"Selected a photo" forKey:keyForTitle];
        }else
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"Selected %d photos", count] forKey:keyForTitle];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:keyForTitle];
    }
    [_tableView reloadData];
}
#pragma mark InsertURLsDidDisappear

- (void) InsertURLsDidDisappear
{
    NSInteger count = 0;
    NSString *keyForTitle = @"Insert URLs";
    if (insertURLsCtr) {
        count = insertURLsCtr.listURLs.count;
        keyForTitle = insertURLsCtr.keyForTitle;
    }
    if (count) {
        if (count == 1) {
            [[NSUserDefaults standardUserDefaults] setValue:@"Added an URL" forKey:keyForTitle];
        }else
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"Added %d URLs", count] forKey:keyForTitle];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:keyForTitle];
    }
    count = 0;
    keyForTitle = @"Insert Videos";
    if (insertVideosCtr) {
        count = insertVideosCtr.listURLs.count;
        keyForTitle = insertVideosCtr.keyForTitle;
    }
    if (count) {
        if (count == 1) {
            [[NSUserDefaults standardUserDefaults] setValue:@"Added an Video" forKey:keyForTitle];
        }else
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"Added %d Videos", count] forKey:keyForTitle];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:keyForTitle];
    }

    [_tableView reloadData];
}

@end
