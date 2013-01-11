//

#import "NewAccountVwCtrl.h"
#import "PostadvertControllerV2.h"
#import "CredentialInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "MyApplication.h"
#import "FlagViewController.h"
#import "LeftViewController.h"

#import "Constants.h"


@implementation NewAccountVwCtrl

@synthesize listItems;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initTableView];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void) initTableView
{
    if (listItems) {
        [listItems removeAllObjects];
        listItems = nil;
    }
    
    //listItems = [[NSMutableArray alloc] initWithObjects:@"First Name", @"Last Name", @"Email address", @"Passwork", "Confirm ", nil];
    listItems = [[NSMutableArray alloc] init];
    [listItems addObject:@"First Name"];
    [listItems addObject:@"Last Name"];
    [listItems addObject:@"Username"];
    [listItems addObject:@"Email Address"];
    [listItems addObject:@"Password"];
    [listItems addObject:@"Confirm Password"];
    [listItems addObject:@"Country of Residence"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG1_revert.png"]];
    //self.view.backgroundColor = [UIColor clearColor];
    // Register Notification event for Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWilBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWilBeShown:)
//                                                 name:UITextFieldTextDidBeginEditingNotification object:nil];
//    //[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didParseDatafromServer) name:cRegistrationCreateFunc object:nil];
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    mainBounds.size.height = mainBounds.size.height + self.topView.frame.size.height;
    [self initTableView];
    tableVw.tableHeaderView = self.topView;
    tableVw.scrollEnabled = NO;
    tableVw.separatorColor = [UIColor clearColor];
    tableVw.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableVw setFrame:mainBounds];
    ((UIScrollView*)self.view).scrollEnabled = YES;
    
}

- (void)viewDidUnload
{
    [self setBtnCreateAccount:nil];
    [self setTopView:nil];
    [super viewDidUnload];
    self.navigationController.navigationBarHidden = NO;
    [listItems removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [(UIScrollView*)self.view setContentSize:tableVw.contentSize];
}

/////////////////////
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}



#pragma mark - Handle Keyboard

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWilBeShown:(NSNotification*)aNotification
{
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
        return;
    }
    
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect mainFrame = [self.view convertRect:mainBounds fromView:nil];
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.view convertRect:frame fromView:nil];
    if (frame.size.height != 0 ) {
        keyboardFrame = frame;
    }
    frame = keyboardFrame;
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height = mainFrame.size.height - keyboardFrame.size.height;
    //self.view.frame = viewFrame;
    CGSize contentSize = tableVw.contentSize;
    [(UIScrollView*)self.view setContentSize:CGSizeMake(keyboardFrame.size.width, contentSize.height + keyboardFrame.size.height)];
    
    CGPoint pt = CGPointZero;
    

    switch (activeField.tag) {
        case 1:{
            pt = CGPointMake(0.0, 52.0);
        } break;
            
        case 2:{
            pt = CGPointMake(0.0, 90.0);
        } break;
            
        case 3:{
            pt = CGPointMake(0.0, 120.0);
        } break;
            
        case 4:{
            pt = CGPointMake(0.0, 150.0);
        } break;
        case 5:{
            pt = CGPointMake(0.0, 180.0);
        }
            break;
        case 6:{
            pt = CGPointMake(0.0, 216.0);
        }
            break;
        case 7:{
            pt = CGPointMake(0.0, 250.0);
        }
            break;

        default:
            NSLog(@"Don't know control.");
            break;
    }
    
    if ([[UIApplication sharedApplication]statusBarOrientation] != UIDeviceOrientationPortrait) {
        pt = (CGPoint) {0, 51 * activeField.tag};
    }
    
    [(UIScrollView*)self.view setScrollEnabled:YES];
    [(UIScrollView*)self.view setContentOffset:pt animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
//    [UIView beginAnimations:nil context:(__bridge void*)tableVw];
//    [UIView setAnimationDuration:0.1];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
    
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect mainFrame = [self.view convertRect:mainBounds fromView:nil];
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height = mainFrame.size.height;
    self.view.frame = viewFrame;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [((UIScrollView*)self.view) setContentSize:tableVw.contentSize];
    ((UIScrollView*)self.view).contentInset = contentInsets;
    ((UIScrollView*)self.view).scrollIndicatorInsets = contentInsets;
    [((UIScrollView*)self.view) setContentOffset:CGPointZero animated:YES];
    
    ((UIScrollView*)self.view).scrollEnabled =YES;
//    [UIView commitAnimations];
}


///////////////////     Table View
#pragma mark - Table View
// Check if user available
- (void)checkForUserAvailable: (NSString*) userName
{
    if(![[PostadvertControllerV2 sharedPostadvertController] isConnectToWeb]){
        [[PostadvertControllerV2 sharedPostadvertController] showAlertWithMessage:@"This device does not connect to Internet." andTitle:@"Stroff"];
        return;
    }
    
    //checkUsername($username, $from_where = 'app')
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"checkUsername";
    paraNames = [NSArray arrayWithObjects:@"username", @"from_where", nil];
    paraValues = [NSArray arrayWithObjects:userName, @"app", nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    
    NSInteger value = [[data objectForKey:@"error_code"] integerValue];

    if (value < 0) {
        lblUsrNmAvalidChk.text = @"User name is not available";
        lblUsrNmAvalidChk.textColor = [UIColor redColor];
        imgUsrNmAvalidChk.image = [UIImage imageNamed:@"icon_invalid_1.png"];
    } else {
        lblUsrNmAvalidChk.text = @"User name is available";
        lblUsrNmAvalidChk.textColor = [UIColor greenColor];
        imgUsrNmAvalidChk.image = [UIImage imageNamed:@"icon_valid_1.png"];
    }

}

- (void)onEventEditingChanged: (id) sender
{
    UITextField *txtFld = (UITextField*) sender;
    NSLog(@"txtFld.text =%@", txtFld.text);
    if (![txtFld.text isEqualToString:@""]) {
        [NSThread detachNewThreadSelector:@selector(checkForUserAvailable:)
                                 toTarget:self withObject:txtFld.text];
    } else {
        imgUsrNmAvalidChk.image = nil;
        lblUsrNmAvalidChk.text = @"";
    }
}

// return number of row in section. Please see more help from Apple
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}


- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView 
{
    int count = listItems.count + 1;
    return count;
} 

// Draw for cell table. Please see more help from Apple
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize s = tableView.frame.size;
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        tableView.backgroundColor = [UIColor colorWithRed:79/255.0 green:178/255.0 blue:187/255.0 alpha:1];
        tableView.separatorColor = [UIColor colorWithRed:79/255.0 green:178/255.0 blue:187/255.0 alpha:1];
    }
    if (indexPath.section == listItems.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWithButtonCreate"];
        if(cell == nil)
        {
            //cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)
            //                              reuseIdentifier:newAccStr];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellWithButtonCreate"];
            cell.frame = CGRectMake(0.0, 0.0, s.width, 44.0);
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.btnCreateAccount.center = cell.center;
            if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
                cell.contentView.backgroundColor = [UIColor colorWithRed:79/255.0 green:178/255.0 blue:187/255.0 alpha:1];
            }
            [cell addSubview:self.btnCreateAccount];
            
            //setUP for view
            CGRect frameTable = tableView.frame;
            frameTable.size.height = tableView.contentSize.height;
            tableView.frame = frameTable;
            [(UIScrollView*)self.view setContentSize:tableView.contentSize];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        return cell;
    }
    
    if (indexPath.section == 6) {
        static NSString *newAccStrCountry = @"NewAccountCountry";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:newAccStrCountry];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newAccStrCountry];
            cell.tag = 7;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryView.png"] highlightedImage:[UIImage imageNamed:@"accessoryViewSelected.png"]];
            [cell setAccessoryView:imgView];
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, cCellHeight)];
            view.backgroundColor = [UIColor whiteColor];
            cell.backgroundView = view;
            
            UIView *selectedBackgroudView = [[UIView alloc] init];
            selectedBackgroudView.backgroundColor = [UIColor blueColor];
            [cell setSelectedBackgroundView:selectedBackgroudView];
            
            cell.textLabel.backgroundColor = [UIColor whiteColor];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
            cell.textLabel.text = @"Singapore";
            cell.imageView.image = [LeftViewController getFlagWithName:cell.textLabel.text];
        }
        cellCountry = cell;
        return cell;
    }
    
    static NSString *newAccStr = @"NewAccountTblId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:newAccStr];
    if(cell == nil) 
    {         
        //cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)
         //                              reuseIdentifier:newAccStr];
        unsigned int section = [indexPath section];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newAccStr];
        cell.frame = CGRectMake(0.0, 0.0, s.width, 44.0);
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 10.0, s.width - 18, 23.0)];
        textField.delegate = self;
        [textField addTarget:self action:@selector(didEndOnExitTxt:) 
            forControlEvents:UIControlEventEditingDidEndOnExit];
        textField.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        textField.tag = section + 1;
        [textField setPlaceholder:[listItems objectAtIndex:section]];
        
        switch (section) {
            case 0:{
                textField.returnKeyType = UIReturnKeyNext;
            }
                break;
            case 1:{
                textField.returnKeyType = UIReturnKeyNext;
            }
                break;
            case 2:{
                [textField addTarget:self
                              action:@selector(onEventEditingChanged:) 
                    forControlEvents:UIControlEventEditingChanged];

                textField.returnKeyType = UIReturnKeyNext;
            }break;
                
            case 3:{
                textField.keyboardType = UIKeyboardTypeEmailAddress;
                textField.returnKeyType = UIReturnKeyNext;
            }break;
                
            case 4:{
                textField.secureTextEntry = YES;
                textField.returnKeyType = UIReturnKeyNext;
            }break;
                
            case 5:{
                textField.secureTextEntry = YES;
                textField.returnKeyType = UIReturnKeyNext;
            }break;
            case 6:{
                textField.secureTextEntry = YES;
                textField.returnKeyType = UIReturnKeyDone;
            }break;
        }
        
        [cell.contentView addSubview:textField];
        
        if (section == 2) {
            UIImageView *imageBG = [[UIImageView alloc ] initWithFrame:CGRectMake(9.0, 0.0, s.width - 18, 60.0)] ;
            imageBG.opaque = NO;
            //    imageBG.layer.cornerRadius = 10;
            //    imageBG.layer.masksToBounds = YES;
            imageBG.image = [UIImage imageNamed:@"cell_updown_enable.png"];
            [cell setBackgroundView:imageBG];

            imgUsrNmAvalidChk = [[UIImageView alloc ] initWithFrame:CGRectMake(15.0, 40.0, 12.0, 12.0)];
            imgUsrNmAvalidChk.opaque = NO;
            //imgUsrNmAvalidChk.image = [UIImage imageNamed:@"icon_valid_1.png"];
            [cell.contentView addSubview: imgUsrNmAvalidChk];
 
            lblUsrNmAvalidChk = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 40.0, 200.0, 14.0)];
            lblUsrNmAvalidChk.text = @"";
            lblUsrNmAvalidChk.textColor = [UIColor greenColor];
            lblUsrNmAvalidChk.opaque = NO;
            lblUsrNmAvalidChk.backgroundColor = [UIColor clearColor];
            lblUsrNmAvalidChk.font = [UIFont fontWithName:@"Helvetica" size:12.0];
            [cell.contentView addSubview:lblUsrNmAvalidChk];

        } else {
            UIImageView *imageBG = [[UIImageView alloc ] initWithFrame:CGRectMake(9.0, 0.0, s.width - 18, 55.0)] ;
            imageBG.opaque = NO;
            //    imageBG.layer.cornerRadius = 10;
            //    imageBG.layer.masksToBounds = YES;
            imageBG.image = [UIImage imageNamed:@"cell_bg_1.png"];
            [cell setBackgroundView:imageBG];
        }
    }
    
    return cell; 
}

// Return heigh of cell
- (CGFloat) tableView : (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    CGFloat h = cCellHeight;
    if ([indexPath section] == 2) {
        h = cCellHeight * 3.0 / 2.0;
    }
    return h;
}

- (float) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ((section == 2) || (section == 3) || (section == 6)) {
        return 24.0;
    }
    return 12.0;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view;
    if ((section == 2) || (section == 3 ) || (section == 6) ) {
        CGRect rcView = CGRectZero;
        rcView.size.height = 24.0;
        rcView.size.width = tableView.frame.size.width;
        
        CGRect rectLabel = CGRectMake(15.0, 2.0, rcView.size.width, rcView.size.height);
        UILabel *lable = [[UILabel alloc] initWithFrame:rectLabel];
        
        lable.textColor = [UIColor whiteColor];
        lable.opaque = NO;
        lable.backgroundColor = [UIColor clearColor];
        lable.font = [UIFont fontWithName:@"Helvetica" size:11.0];
        
        if (section == 2) {
            lable.text = @"Choose a Unique Username";
        }
        if (section == 3) {
            lable.text = @"Valid email to confirm";
        }
        
        if (section == 6) {
            lable.text = @"Country of Residence";
        }
        
        
        view = [[UIView alloc] initWithFrame:rcView];
        [view addSubview:lable];
    } else {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        //return nil;
    }

    if ([[[UIDevice currentDevice]model] isEqualToString:@"iPad"]) {
        view.backgroundColor = [UIColor colorWithRed:79/255.0 green:178/255.0 blue:187/255.0 alpha:1];
    }
    return view;
}

#pragma mark - UITaleViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 7) {
        cellCountry = cell;
        [self showCountryToSelect];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 
- (void) showCountryToSelect
{
    FlagViewController *flagViewCtr = [[FlagViewController alloc] init];
    flagViewCtr.delegate = self;
    [self presentViewController:flagViewCtr animated:YES completion:nil];
}

-(IBAction) touchBackBtn: (id) sender
{
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void) hidePopUpDialog:(UIView*) view
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
	[self.view performSelector:@selector(setAlpha:) withObject:nil afterDelay:0.3f];
    [[self modalViewController] dismissModalViewControllerAnimated:NO];
    //[view removeFromSuperview];
}


-(IBAction) touchCreateAccountBtn: (id) sender
{

    CredentialInfo *credential1 = [ [CredentialInfo alloc] initWithFirstName:[(UITextView*)[self.view viewWithTag:1] text]
                                                                    lastname:[(UITextView*)[self.view viewWithTag:2] text]
                                                                       email:[(UITextView*)[self.view viewWithTag:4] text]
                                                                    userName:[(UITextView*)[self.view viewWithTag:3] text]
                                                                    password:[(UITextView*)[self.view viewWithTag:5] text]
                                                                    countryID:countryID];

    //userRegister($fist_name, $last_name, $username, $email, $password)
    //userRegister($fist_name, $last_name, $username, $email, $password, $country)
    long logInID = [[PostadvertControllerV2 sharedPostadvertController] registrationCreate:credential1];
    if (logInID) {
        NSUserDefaults* dababase = [NSUserDefaults standardUserDefaults];
        long temp = [dababase integerForKey:@"UserID"];
        if(!temp){
            [dababase setInteger:logInID forKey:@"UserID"];
            [dababase setObject:credential1.usernamePU forKey:@"userNamePA"];
            [dababase setObject:credential1.email forKey:@"email"];
            [dababase setObject:credential1.passwordPU forKey:@"passwordPA"];
            [dababase synchronize];
        }
        //[[PostadvertControllerV2 sharedPostadvertController] getFullProfile];
        UIAlertView *baseAlert = [[UIAlertView alloc]
                                  initWithTitle: @"Successful!"
                                  message: @"Your account has been created.\nPlease check your email and active your account."
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"OK", nil];
        [baseAlert show];
        
        NSLog(@"Log in ID = %ld", logInID);
    } else {
        UIAlertView *baseAlert = [[UIAlertView alloc]
                                  initWithTitle: @"Alert!"
                                  message: @"Failed to create account. Please try again."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil];
        [baseAlert show];
    }

}

-(IBAction) didEndOnExitTxt: (id) sender
{
    //[sender resignFirstResponder];
    switch ([(UITextField*)sender tag]) {
        case 1:{
            [(UITextView*)[self.view viewWithTag:2] becomeFirstResponder];
        } break;

        case 2:{
            [(UITextView*)[self.view viewWithTag:3] becomeFirstResponder];
        } break;

        case 3:{
            [(UITextView*)[self.view viewWithTag:4] becomeFirstResponder];
        } break;

        case 4:{
            [(UITextView*)[self.view viewWithTag:5] becomeFirstResponder];
        }
            break;
        case 5:{
            [(UITextView*)[self.view viewWithTag:6] becomeFirstResponder];
        }
            break;
        case 6:{
            [activeField resignFirstResponder];
            [(UITextView*)[self.view viewWithTag:7] becomeFirstResponder];
            [self showCountryToSelect];
            //[(UITextView*)[self.view viewWithTag:7] becomeFirstResponder];
            //[self touchCreateAccountBtn:( (UIButton*)[self.view viewWithTag:98] )];
            //[(UITextView*)[self.view viewWithTag:98] becomeFirstResponder];
            //[self touchCreateAccountBtn:nil];
        } break;
            
        case 7:{
            //[self touchCreateAccountBtn:nil];
        } break;
            
        case 98:{
            //[self touchCreateAccountBtn:( (UIButton*)[self.view viewWithTag:6] )];
            [self touchCreateAccountBtn:nil];
        } break;
            
        case 99:{
            [activeField resignFirstResponder];
        }
            break;
        default:
            NSLog(@"Don't kown control.");
            break;
    }
    [self keyboardWilBeShown:nil];
}

#pragma mark - AlertView Delegate
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) {

    }else
    {
        [(MyApplication*)[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"www.google.com"] forceOpenInSafari:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - FlagViewControllerDelegate

- (void) didSelectCountryWithCpuntryID:(NSInteger)countryID_ countryName:(NSString *)countryName
{
    cellCountry.textLabel.text = countryName;
    cellCountry.imageView.image = [LeftViewController getFlagWithName:countryName];
    countryID = countryID_;
    [(UIScrollView*)self.view setContentSize:tableVw.contentSize];
    CGRect farme = tableVw.frame;
    [(UIScrollView*)self.view scrollRectToVisible:farme animated:YES];
    [(UIScrollView*)self.view setContentSize:tableVw.contentSize];
}

@end
