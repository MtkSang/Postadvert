//
//  ChatViewController.m
//  Postadvert
//
//  Created by Mtk Ray on 6/20/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "ChatViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIMessageCell.h"
#import "MessageCellContent.h"
#import "UserPAInfo.h"
#import "UIPlaceHolderTextView.h"
#import "Constants.h"
#import "WEPopoverController.h"
#import "TakePhotoViewController.h"
#import "PostadvertControllerV2.h"
#import "UIImageView+URL.h"
@interface ChatViewController ()
- (void) updateLeftBarBtnStateSideBar;
- (void) updateLeftBarBtnStateNormal;
- (void) tapAction;
- (void) updatePostBtnState;
@end

@implementation ChatViewController
@synthesize infoChatting = _infoChatting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithInfo:(MessageCellContent*)info
{
    self = [[ChatViewController alloc]init];
    if (self) {
        self.infoChatting = info;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.message.layer.cornerRadius = 5.0;
    self.message.layer.borderWidth = 0.25;
    self.message.placeholder = @"Write a reply";
    self.btnSend.layer.cornerRadius = 5.0;
    self.btnSend.layer.borderWidth = 0.20;
    self.btnSend.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    //TapGesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_tableView addGestureRecognizer:tap];
    tap = nil;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.userInteractionEnabled = YES;
    [self.view addSubview:hud];
    [hud showWhileExecuting:@selector(loadListMessageCellContent) onTarget:self withObject:nil animated:NO];

}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setBotView:nil];
    [self setBtnPickPicture:nil];
    [self setMessage:nil];
    [self setBtnSend:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWilBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Rotated %@", self);
}
#pragma mark - Table view data source
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    UILabel *lbTitle = [[UILabel alloc]initWithFrame:headerView.frame];
    [lbTitle setText:self.infoChatting.subject];
    [lbTitle setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_TITLE_SIZE]];
    [lbTitle setTextColor:[UIColor colorWithRed:79/255.0 green:177/255.0 blue:190/255.0 alpha:1]];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    lbTitle.backgroundColor = [UIColor clearColor];
    [headerView setAutoresizesSubviews:YES];
    [lbTitle setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight ];
    [headerView addSubview:lbTitle];
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return listMessageCellContent.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    MessageCellContent *cellContent = [listMessageCellContent objectAtIndex:[indexPath row]];
    
    CGSize constraint = CGSizeMake(self.view.frame.size.width - 74, 20000.0f);
    
    CGSize size = [cellContent.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat lableHieght = 21.0;
    
    CGFloat height = 47.0 + MAX(size.height - lableHieght , 0.0);
    
    if (cellContent.imageAttachment) {
        height += 102;// add 2 margin between imge&text
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)ctableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"UIMessageCell";
    // Try to retrieve from the table view a now-unused cell with the given identifier.
    UIMessageCell *cell = [ctableView dequeueReusableCellWithIdentifier:MyIdentifier];
    // If no cell is available, create a new one using the given identifier.
    if (cell == nil) {
        cell = [[UIMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    MessageCellContent *cellCentent;
   cellCentent = ((MessageCellContent*)[listMessageCellContent objectAtIndex:indexPath.row]);    
    if (cellCentent.is_read) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:cellCentent.messageThumbURL] placeholderImage:[UIImage imageNamed:@"read_message.png"]];
        cell.iconSendView.hidden = YES;
        cell.backgroundColor = [UIColor clearColor];
        //cell.message.textColor = [UIColor lightGrayColor];
    }else
    {
        [cell.imageView setImageWithURL:[NSURL URLWithString:cellCentent.messageThumbURL] placeholderImage:[UIImage imageNamed:@"unread_message.png"]];
        if (!cell.iconSendView.image) {
            cell.iconSendView.image = [UIImage imageNamed:@"unread_icon.png"];
        }
        
        cell.iconSendView.hidden = NO;
        //cell.message.textColor = [UIColor darkGrayColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:225/255.0 green:245/255.0 blue:245/255.0 alpha:0.5];
        
    }
    cell.message.text = cellCentent.text;
    CGSize constraint = CGSizeMake(self.view.frame.size.width - 74, 20000.0f);
    
    CGSize size = [cell.message.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGRect frame = cell.message.frame;
    frame.size = size;
    cell.message.frame = frame;

    
    cell.userPostName.text = cellCentent.userPostName;
    cell.postTime.text = cellCentent.created;
    
    cellCentent = nil;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.btnSend.titleLabel.textColor = [UIColor redColor];
    [self updatePostBtnState];
}
#pragma mark - Handle Keyboard

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWilBeShown:(NSNotification*)aNotification
{
    CGPoint pt = CGPointZero;
    
    ((UIScrollView*)self.view).scrollEnabled = YES;
    pt = CGPointMake(0.0, 216);
    
    _tableView.frame = CGRectMake(0.0, 216, self.view.frame.size.width, _tableView.frame.size.height - 216);
    [(UIScrollView*)self.view setContentOffset:pt animated:YES];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listMessageCellContent.count -1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    //    ((UIScrollView*) self.view).contentInset = contentInsets;
    //    ((UIScrollView*) self.view).scrollIndicatorInsets = contentInsets;
    
    [(UIScrollView*)self.view setContentOffset:CGPointZero animated:YES];
    ((UIScrollView*)self.view).scrollEnabled = NO;
    _tableView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, _tableView.frame.size.height + 216);
}

#pragma mark - implement
- (void) updatePostBtnState
{
    //Update icon btn TakePhoto
    
    if (imageAttachment) {
        [self.btnPickPicture setImage:imageAttachment forState:UIControlStateNormal];
    }else {
        [self.btnPickPicture setImage:[UIImage imageNamed:@"take-photo.png"] forState:UIControlStateNormal];
    }
    
    BOOL canEnable = NO;
    if (imageAttachment) {
        canEnable = YES;
    }
    NSString *text = [self.message.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([self.message.text isEqualToString:@""] || [text isEqualToString:@""]) {
        //canEnable = NO;
    }else {
        canEnable = YES;
    }
    text = nil;

    //Update post btn
    if (canEnable) {
        self.btnSend.enabled = YES;
        self.btnSend.titleLabel.textColor = [UIColor blueColor];
    }else {
        self.btnSend.titleLabel.textColor = [UIColor lightGrayColor];
        self.btnSend.enabled = NO;
    }
}

- (void) addCell:(MessageCellContent *) newCell
{
    if (listMessageCellContent == nil) {
        listMessageCellContent = [[NSMutableArray alloc] init ];
    }
    [listMessageCellContent addObject:newCell];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listMessageCellContent.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void) updateLeftBarBtnStateNormal
{
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
}

- (void) updateLeftBarBtnStateSideBar
{
    UIButton *abutton = [[UIButton alloc]initWithFrame:CGRectMake(5.0, 0.0, 30, 30)];
    [abutton setImage:[UIImage imageNamed:@"list_btn.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:abutton];
    leftBarItem.width = 30;
    self.navigationItem.leftBarButtonItem = leftBarItem;
    abutton = nil;
    //leftBarBtnItem = nil;
}

- (void) tapAction
{
    NSLog(@"Tap");
    [self.message resignFirstResponder];
}

- (IBAction) buttonSendClicked:(id)sender
{
    //sendReplyMessage($user_id, $msg_parent, $content, $limit)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"sendReplyMessage";
    paraNames = [NSArray arrayWithObjects:@"user_id", @"msg_parent", @"content", @"limit", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%d",self.infoChatting.parent_id],self.message.text, @"5", nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    
    MessageCellContent *newComments = [[MessageCellContent alloc]init];
    newComments.text = self.message.text;
    newComments.userAvatar = [UserPAInfo sharedUserPAInfo].imgAvatar;
    newComments.userPostName = [UserPAInfo sharedUserPAInfo].usernamePU;
    newComments.datePost = [NSDate date]; 
    newComments.imageAttachment = imageAttachment;
    newComments.is_read = 1;
    newComments.messageThumbURL = [UserPAInfo sharedUserPAInfo].avatarUrl;
    newComments.created = @"Just now";
    [self addCell:newComments];
    newComments = nil;
    [self.message resignFirstResponder];
    self.message.text = @"";
    imageAttachment = nil;
    [self updatePostBtnState];
}

- (void) loadListMessageCellContent
{
    if(listMessageCellContent == nil)
        listMessageCellContent = [[NSMutableArray alloc] init];
    [listMessageCellContent removeAllObjects];
    //getConversation($user_id, $parent_id, $msg_id, $limit, $base64_image = false)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"getConversation";
    paraNames = [NSArray arrayWithObjects:@"user_id", @"parent_id", @"msg_id", @"limit", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%d",self.infoChatting.parent_id],@"0", @"0", nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    
    for (NSDictionary *dict  in data) {
        MessageCellContent *message = [[MessageCellContent alloc]initWithDictionary:dict andSuperMessage:self.infoChatting];
        [listMessageCellContent addObject:message];
    }
    
    
    [_tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{ //cancel
	
	[picker dismissModalViewControllerAnimated:YES];
	
}

-(IBAction)onTakePhoto:(id)sender{
    if (popoverController) {
		[popoverController dismissPopoverAnimated:YES];
		popoverController = nil;
	} else {
        [self.message resignFirstResponder];
        TakePhotoViewController *contentViewController = [[TakePhotoViewController alloc] init];
		CGRect rect = CGRectMake(0.0 , 400,((UIView*)sender).frame.size.width + 6, 70);
		//self.navigationController.navigationBarHidden = YES;
        contentViewController.navigationController = self.navigationController;
        if (imageAttachment) {
            [contentViewController performSelectorOnMainThread:@selector(setImageForView:) withObject :imageAttachment waitUntilDone:NO];
            contentViewController.showPicker = NO;
            //contentViewController.imageView =[[UIImageView alloc]initWithImage:imageAttachment];
        }
        
        contentViewController.delegate = self;
        contentViewController.contentSizeForViewInPopover = CGSizeMake(280, 300);
		popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
		
		if ([popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
			[popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
		}
		
		popoverController.delegate = self;
		popoverController.passthroughViews = [NSArray arrayWithObject:sender];
		
		[popoverController presentPopoverFromRect:rect  
												inView:self.navigationController.view 
							  permittedArrowDirections:(UIPopoverArrowDirectionLeft)
											  animated:YES];
    }
}

#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
    popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
    WEPopoverContainerViewProperties *ret = [[WEPopoverContainerViewProperties alloc] init];
	
	CGSize imageSize = CGSizeMake(30.0f, 30.0f);
	NSString *bgImageName = @"popoverBgSimple.png";
	CGFloat bgMargin = 6.0;
	CGFloat contentMargin = 4.0;
	
	ret.leftBgMargin = bgMargin;
	ret.rightBgMargin = bgMargin;
	ret.topBgMargin = bgMargin;
	ret.bottomBgMargin = bgMargin;
	ret.leftBgCapSize = imageSize.width/2;
	ret.topBgCapSize = imageSize.height/2;
	ret.bgImageName = bgImageName;
	ret.leftContentMargin = contentMargin;
	ret.rightContentMargin = contentMargin;
	ret.topContentMargin = contentMargin;
	ret.bottomContentMargin = contentMargin;
	ret.arrowMargin = 1.0;
	
	ret.upArrowImageName = @"popoverArrowUpSimple.png";
	ret.downArrowImageName = @"popoverArrowDownSimple.png";
	ret.leftArrowImageName = @"popoverArrowLeftSimple.png";
	ret.rightArrowImageName = @"popoverArrowRightSimple.png";
	return ret;	
}

#pragma mark - TakePhotoDelegate
- (void) didTakePicture:(UIImage *)picture
{
    if (popoverController) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
    }
    imageAttachment = nil;
    imageAttachment = picture;
    picture = nil;
    [self updatePostBtnState];
}
- (void) didCancelPicture
{
    if (popoverController) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
    }
    [self updatePostBtnState];
}
- (void)didReMovePicture
{
    if (popoverController) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
    }
    imageAttachment = nil;
    [self updatePostBtnState];
}
@end
