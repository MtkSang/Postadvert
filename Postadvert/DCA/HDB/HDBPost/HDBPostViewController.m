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
    NSDictionary *staticData = [NSDictionary dictionaryWithContentsOfFile:plistPathForStaticHDBPost];
    sourceData = [NSDictionary dictionaryWithDictionary: [staticData objectForKey:@"HDB Post"]];
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
        if (indexPath.row == array.count - 1 || indexPath.row < 6) {
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
        }else
        {
            
        }
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
        
    }
    //Description of Property
    if ([headerStr isEqualToString:@"Description of Property"]) {
        static NSString *CellIdentifier3 = @"CellHBDPostWithOption3";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier3];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
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
        [cell.textLabel setNumberOfLines:2];
        [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        
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
        if (indexPath.row == array.count - 1) {
            if ([cell.detailTextLabel.text isEqualToString:@"Others Features"] || [cell.detailTextLabel.text isEqualToString:@"Select One"]) {
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
        }else
        {
            
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

#pragma mark - Table view delegate
- (void) accessoryClicked:(UITapGestureRecognizer*) tapGesture_
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
            optionTableViewCtr = [[OptionTableHDBPostViewController alloc] init];
            optionTableViewCtr.dataSource = [NSArray arrayWithArray: array];
            optionTableViewCtr.headerTitle = [array objectAtIndex:indexPath.row];
            [self showDialog:optionTableViewCtr.view];
        }
        else{
            currentIndexPath = indexPath;
            [self.textField setKeyboardType:UIKeyboardTypeDecimalPad];
            [self.textField setReturnKeyType:UIReturnKeyDone];
            [self.textField becomeFirstResponder];
            [self.textField setText:cell.detailTextLabel.text];
            [self.inputTitle setText:[NSString stringWithFormat:@"Enter value for %@", cell.textLabel.text]];
            [self showDialog:self.inputForm];
        }
    }
    //               @"Address of Property",
    if ([headerStr isEqualToString:@"Address of Property"]) {
        currentIndexPath = indexPath;
        [self.phTextView becomeFirstResponder];
        [self.phTextView setText:cell.detailTextLabel.text];
        [self.titleInputTextForm setText:[NSString stringWithFormat:@"%@", [array objectAtIndex:indexPath.row]]];
        [self textViewDidChange:self.phTextView];
        [self showDialog:self.inputTextForm];
    }
    //               @"Description of Property",
    if ([headerStr isEqualToString:@"Description of Property"]) {
        currentIndexPath = indexPath;
        [self.phTextView becomeFirstResponder];
        [self.phTextView setText:cell.textLabel.text];
        [self.titleInputTextForm setText:[NSString stringWithFormat:@"%@", headerStr]];
        [self textViewDidChange:self.phTextView];
        [self showDialog:self.inputTextForm];
    }
    
    //               @"Pictures, URLs & Videos",
    
    //               @"Special Features",

    
    //Home Interior
    if ([headerStr isEqualToString:@"Home Interior"]) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
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
