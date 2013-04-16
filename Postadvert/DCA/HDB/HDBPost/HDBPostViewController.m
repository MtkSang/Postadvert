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

@interface HDBPostViewController ()

@end

@implementation HDBPostViewController

@synthesize overlay;
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
    //Load plist
    NSString *plistPathForStaticDCA = [[NSBundle mainBundle] pathForResource:@"DCA" ofType:@"plist"];
    staticData = [NSDictionary dictionaryWithContentsOfFile:plistPathForStaticDCA];
    staticData = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"HDB Search"]];
    
    
    UIImage *image = [UIImage imageNamed:@"titleHDB.png"];
    image = [image resizedImage:self.lbTitle.frame.size interpolationQuality:0];
    [self.lbTitle setBackgroundColor:[UIColor colorWithPatternImage:image]];
    [self.lbTitle setText:@"Post a Classified Ad"];
    //TapGesture
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    
    //
    NSString *plistPathForStaticHDBPost = [[NSBundle mainBundle] pathForResource:@"DCA" ofType:@"plist"];
    NSDictionary *staticData2 = [NSDictionary dictionaryWithContentsOfFile:plistPathForStaticHDBPost];
    sourceData = [NSDictionary dictionaryWithDictionary: [staticData2 objectForKey:@"HDB Post"]];
    allKeys = [[NSMutableArray alloc]initWithObjects:
               @"Property Details",
               @"Address of Property",
               @"Description of Property",
               @"Pictures, URLs & Videos",
               @"Special Features",
               @"Home Interior", nil];
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
    self.boundForm.frame = CGRectMake(10, 38, 300, size.height + 10);
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
	rc.origin = CGPointMake(0.0f, 90.0f);//point; //CGPointMake(0.0f, 10.0f);
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
    return sourceData.count + 1;
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
    //Property Details
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
        if (detailText == nil || [detailText isEqualToString:@""]) {
            if (indexPath.row == array.count - 1 || indexPath.row < 6) {
                detailText = @"Select One";
            }else
                detailText = @"";
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
    //Address of Property
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
    //Description of Property
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
    //Pictures, URLs & Videos
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
    //Special Features
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
    //Home Interior
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
        NSString *detailText = [[NSUserDefaults standardUserDefaults] objectForKey:textLabel];
        if (detailText == nil || [detailText isEqualToString:@""]) {
            detailText = @"No";
        }
        if ([detailText isEqualToString:@"No"]) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
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
    UITableViewCell *cell = (UITableViewCell*) view.superview;
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:cell];
    }
    NSString *headerStr = [allKeys objectAtIndex:indexPath.section];
    NSArray *array = [sourceData objectForKey:headerStr];
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
            if (indexPath.row == array.count - 1 || indexPath.row < 6) {
                cell.detailTextLabel.text = @"Select One";
            }else
                cell.detailTextLabel.text = @"";//Value for Price ,...
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
            cell.detailTextLabel.text = @"";
            [[NSUserDefaults standardUserDefaults]setValue:cell.detailTextLabel.text forKey:cell.textLabel.text];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    currentIndexPath = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *headerStr = [allKeys objectAtIndex:indexPath.section];
    NSArray *array = [sourceData objectForKey:headerStr];
//    allKeys = [[NSMutableArray alloc]initWithObjects:
//               @"Property Details",
//               @"Address of Property",
//               @"Description of Property",
//               @"Pictures, URLs & Videos",
//               @"Special Features",
//               @"Home Interior", nil];
    //               @"Property Details",
    if ([headerStr isEqualToString:@"Property Details"]) {
        if (indexPath.row == array.count - 1 || indexPath.row < 6) {
//            optionTableViewCtr = [[OptionTableHDBPostViewController alloc] init];
//            optionTableViewCtr.dataSource = [NSArray arrayWithArray: array];
//            optionTableViewCtr.headerTitle = [array objectAtIndex:indexPath.row];
//            [self showDialog:optionTableViewCtr.view];
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
        }
        else{
            [self.textField setKeyboardType:UIKeyboardTypeDecimalPad];
            [self.textField setReturnKeyType:UIReturnKeyDone];
            [self.textField becomeFirstResponder];
            [self.textField setText:cell.detailTextLabel.text];
            [self.inputTitle setText:[NSString stringWithFormat:@"Enter value for %@", cell.textLabel.text]];
            [self showDialog:self.inputForm];
        }
    }
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
    
    //               @"Address of Property",
    if ([headerStr isEqualToString:@"Address of Property"]) {
        [self.phTextView becomeFirstResponder];
        [self.phTextView setText:cell.detailTextLabel.text];
        [self.titleInputTextForm setText:[NSString stringWithFormat:@"%@", [array objectAtIndex:indexPath.row]]];
        [self textViewDidChange:self.phTextView];
        [self showDialog:self.inputTextForm];
    }
    //               @"Description of Property",
    if ([headerStr isEqualToString:@"Description of Property"]) {
        [self.phTextView becomeFirstResponder];
        [self.phTextView setText:cell.textLabel.text];
        [self.titleInputTextForm setText:[NSString stringWithFormat:@"%@", headerStr]];
        [self textViewDidChange:self.phTextView];
        [self showDialog:self.inputTextForm];
    }
    
    //               @"Pictures, URLs & Videos",
    if ([headerStr isEqualToString:@"Pictures, URLs & Videos"]) {
        InsertPictureViewController *insertPicCtr = [[InsertPictureViewController alloc]init];
        [self.navigationController pushViewController:insertPicCtr animated:YES];
    }
    //               @"Special Features",

    
    //Home Interior
    if ([headerStr isEqualToString:@"Home Interior"]) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
}
#pragma mark DCAPOptionViewController Delegate
- (void) didSelectRowOfDCAOptionViewController:(DCAOptionsViewController *)dcaViewCtr
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:currentIndexPath];
    NSString *value = @"";
    value = [dcaViewCtr.intSource objectAtIndex:dcaViewCtr.selectedIndex];
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
@end
