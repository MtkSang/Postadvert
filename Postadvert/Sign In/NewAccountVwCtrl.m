//

#import "NewAccountVwCtrl.h"
#import "PostadvertControllerV2.h"
#import "CredentialInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "MyApplication.h"

#import "Constants.h"


@implementation NewAccountVwCtrl

@synthesize listItems;
@synthesize palUpCtrl;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initTableView];
    }
    return self;
}

-(id) initWithPostAdvertController:(PostAdvertController *) postAdvertController
{
    if (self) {
        self.palUpCtrl = postAdvertController;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWilBeShown:)
                                                 name:UITextFieldTextDidBeginEditingNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didParseDatafromServer) name:cRegistrationCreateFunc object:nil];
    
    [self initTableView];
    //tableVw = [[UITableView alloc]init];
    tableVw.scrollEnabled = NO;
    tableVw.separatorColor = [UIColor clearColor];
    tableVw.separatorStyle = UITableViewCellSeparatorStyleNone;
    ((UIScrollView*)self.view).scrollEnabled = NO;
    
}

- (void)viewDidUnload
{
    NSLog(@"NewAccountBaseVwContrl : viewDidUnload");
    [self setBtnCreateAccount:nil];
    [super viewDidUnload];
    self.navigationController.navigationBarHidden = NO;
    [listItems removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return YES;
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
    
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect mainSize = [[UIScreen mainScreen] bounds];
    //mainSize = [self.view convertRect:mainSize fromView:nil];
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.view convertRect:frame fromView:nil];
    [(UIScrollView*)self.view setContentSize:CGSizeMake(frame.size.width, mainSize.size.height)];
    
    CGPoint pt = CGPointZero;
    
    ((UIScrollView*)self.view).scrollEnabled = YES;
    
    switch (activeField.tag) {
        case 1:{
            pt = CGPointMake(0.0, 70.0);
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
            pt = CGPointMake(0.0, 180.0);
        }
            break;

        default:
            NSLog(@"Don't know control.");
            break;
    }
    
    
    [(UIScrollView*)self.view setContentOffset:pt animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView setAnimationDuration:10.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
    //[(UIScrollView*)self.view setContentSize:self.view.frame.size];
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    ((UIScrollView*) self.view).contentInset = contentInsets;
    ((UIScrollView*) self.view).scrollIndicatorInsets = contentInsets;
    [(UIScrollView*)self.view setContentOffset:CGPointZero animated:YES];
    ((UIScrollView*)self.view).scrollEnabled = NO;
    [UIView commitAnimations];
}


///////////////////     Table View
#pragma mark - Table View
// Check if user available
- (void)checkForUserAvailable: (NSString*) userName
{
    if(![[PostadvertControllerV2 sharedPostadvertController] isConnectToWeb]){
        [[PostadvertControllerV2 sharedPostadvertController] showAlertWithMessage:@"This device does not connect to Internet." andTitle:@"PalUp"];
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
    NSLog(@"List: %d %@",listItems.count, listItems);
    return [listItems count] + 1;
} 

// Draw for cell table. Please see more help from Apple
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == listItems.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWithButtonCreate"];
        if(cell == nil)
        {
            //cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)
            //                              reuseIdentifier:newAccStr];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellWithButtonCreate"];
            cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0);
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.btnCreateAccount.center = cell.center;
            [cell addSubview:self.btnCreateAccount];
        }
        return cell;
    }
    
    static NSString *newAccStr = @"NewAccountTblId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:newAccStr];
    if(cell == nil) 
    {         
        //cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)
         //                              reuseIdentifier:newAccStr];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newAccStr];
        cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0);
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        unsigned int section = [indexPath section];
        CGSize s = tableView.frame.size;
        
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 10.0, s.width - 35.0, 23.0)];
        textField.delegate = self;
        [textField addTarget:self action:@selector(didEndOnExitTxt:) 
            forControlEvents:UIControlEventEditingDidEndOnExit];
        textField.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;        
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
                textField.returnKeyType = UIReturnKeyDone;
            }break;
        }
        
        [cell.contentView addSubview:textField];
        
        if (section == 2) {
            UIImageView *imageBG = [[UIImageView alloc ] initWithFrame:CGRectMake(9.0, 0.0, 302.0, 60.0)] ;
            imageBG.opaque = NO;
            //    imageBG.layer.cornerRadius = 10;
            //    imageBG.layer.masksToBounds = YES;
            imageBG.image = [UIImage imageNamed:@"cell_updown_enable.png"];
            [cell setBackgroundView:imageBG];

            imgUsrNmAvalidChk = [[UIImageView alloc ] initWithFrame:CGRectMake(15.0, 43.0, 12.0, 12.0)];
            imgUsrNmAvalidChk.opaque = NO;
            //imgUsrNmAvalidChk.image = [UIImage imageNamed:@"icon_valid_1.png"];
            [cell.contentView addSubview: imgUsrNmAvalidChk];
 
            lblUsrNmAvalidChk = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 43.0, 200.0, 14.0)];
            lblUsrNmAvalidChk.text = @"";
            lblUsrNmAvalidChk.textColor = [UIColor greenColor];
            lblUsrNmAvalidChk.opaque = NO;
            lblUsrNmAvalidChk.backgroundColor = [UIColor clearColor];
            lblUsrNmAvalidChk.font = [UIFont fontWithName:@"Helvetica" size:12.0];
            [cell.contentView addSubview:lblUsrNmAvalidChk];

        } else {
            UIImageView *imageBG = [[UIImageView alloc ] initWithFrame:CGRectMake(9.0, 0.0, 302.0, 55.0)] ;
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
    if ((section == 2) || (section == 3)) {
        return 24.0;
    }
    return 12.0;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view;
    if ((section == 2) || (section == 3)) {
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
        } else {
            lable.text = @"Valid email to confirm";
        }
        
        view = [[UIView alloc] initWithFrame:rcView];
        [view addSubview:lable];
    } else {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        //return nil;
    }

    return view;
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
                                                                    password:[(UITextView*)[self.view viewWithTag:5] text] ];

    //userRegister($fist_name, $last_name, $username, $email, $password)
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
        case 6:{
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

@end
