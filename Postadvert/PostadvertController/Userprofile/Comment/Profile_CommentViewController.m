//
//  Profile_CommentViewController.m
//  Stroff
//
//  Created by Nguyen Ngoc Sang on 11/6/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "Profile_CommentViewController.h"
#import "UIPlaceHolderTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "UserPAInfo.h"
#import "UICommentsCell.h"
#import "CommentsCellContent.h"
#import "UIActivityCell.h"
#import "UIImageView+URL.h"
#import "ActivityContent.h"
#import "MBProgressHUD.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
@interface Profile_CommentViewController ()
- (void) loadCommentsInBackground;
- (void)keyboardWilBeShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;

- (IBAction)commentBtnClicked:(id)sender ;
- (IBAction)clapBtnClicked:(id)sender ;
@end

@implementation Profile_CommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithActivityCell:(UIActivityCell *)cell
{
    //Must call from this contructor
    self = [super init];
    if (self) {
        dataCellFromMain = cell;

        NSArray *nib = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            nib = [[NSBundle mainBundle] loadNibNamed:@"UIActivityCell" owner:self options:nil];
        }
        else{
            nib = [[NSBundle mainBundle] loadNibNamed:@"UIActivityCell" owner:self options:nil];
        }
        actiCell = (UIActivityCell *)[nib objectAtIndex:0];
        [actiCell loadNibFile];
        actiCell.navigationController = self.navigationController;
        [actiCell updateCellWithContent:cell._content];
        [actiCell setSelectionStyle:UITableViewCellEditingStyleNone];
        [actiCell setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//        cell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
//        cell.backgroundView.backgroundColor = [UIColor whiteColor];
        
        
        actiCell.typeOfCurrentView = 1;
        actiCell.commentViewCtr = self;
        actiCell.botView.hidden = YES;
        actiCellSuperView = (UITableView*)cell.superview;
        listComments = [[NSMutableArray alloc]init];
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _textBox.layer.cornerRadius = 5.0;
    _textBox.layer.borderWidth = 0.25;
    _textBox.placeholder = @"Write a comment";
    _btnSend.layer.cornerRadius = 5.0;
    _btnSend.layer.borderWidth = 0.20;
    _btnSend.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    
    //TapGesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_tableView addGestureRecognizer:tap];
    tap = nil;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    //load Data
    if (self.showKeyboard) {
        [self.textBox becomeFirstResponder];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWilBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    MBProgressHUD * actView = [[MBProgressHUD alloc]initWithView:self.scrollView];
    actView.hasBackground = NO;
    [actView setMode:MBProgressHUDModeIndeterminate];
    //actView.center = _tableView.center;
    actView.userInteractionEnabled = NO;
    [self.view addSubview:actView];
    [actView showWhileExecuting:@selector(loadCommentsInBackground) onTarget:self withObject:nil animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated
{
   
    [super viewWillAppear:animated];
    actiCell.typeOfCurrentView = 1;
    actiCell.botView.hidden = YES;
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    
    actiCell.typeOfCurrentView = 0;
    [super viewWillDisappear:animated];
    dataCellFromMain._content = actiCell._content;
    [dataCellFromMain refreshClapCommentsView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    

    //Draw backview
    [actiCellSuperView reloadData];
    actiCell.botView.hidden = NO;
    
    
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBotView:nil];
    [self setBtnSend:nil];
    [self setTextBox:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.01];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    return listComments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 ) {
        return  [UIActivityCell getCellHeightWithContent:actiCell._content] - actiCell.botView.frame.size.height + 3;
    }
    return [CommentsCellContent getCellHeighWithContent:[listComments objectAtIndex:indexPath.row] withWidth:actiCell.frame.size.width - 74];
}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.detailTextLabel.frame = CGRectMake(cMaxLeftView - 100, 0.0, 70, cCellHeight);
//
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [actiCell updateView];
        return actiCell;
    }
    
    if (listComments.count == 0) {
        CGRect frame = tableView.frame;
        frame.size.height += cCellHeight;//make "No data" below Loading
        UILabel *labelCell = [[UILabel alloc]initWithFrame:frame];
        labelCell.text = @"No Data";
        [labelCell setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE * 2.5]];
        [labelCell setTextAlignment:UITextAlignmentCenter];
        labelCell.backgroundColor = [UIColor clearColor];
        labelCell.textColor = [UIColor darkGrayColor];
        labelCell.alpha = 0.6;
        UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:tableView.frame];
        [cell.contentView addSubview:labelCell];
        tableView.scrollEnabled = NO;
        labelCell = nil;
        return  cell;
    }
    static NSString *CellIdentifier = @"UICommentCell";
    
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = nil;
        nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (UITableViewCell *)[nib objectAtIndex:0];

    }
    CommentsCellContent *content = [listComments objectAtIndex:indexPath.row];
    //ImageView
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    [imageView setImageWithURL:[NSURL URLWithString: content.userAvatarURL]];
    //Username
    UILabel *userName = (UILabel*)[cell viewWithTag:2];
    userName.text = content.userPostName;
    //text
    UILabel *text = (UILabel*)[cell viewWithTag:3];
    text.text = content.text;
    [text setNeedsDisplay];
    CGSize constraint = CGSizeMake(actiCell.frame.size.width - 74, 20000.0f);
    CGSize size = [content.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGRect frame = text.frame;
    frame.size = size;
    text.frame = frame;
//    [text setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin ];
    //Create
    UILabel *created = (UILabel*)[cell viewWithTag:4];
    created.text = content.created;
    tableView.scrollEnabled = YES;
    
    cell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
         return CELL_COMMENTS_HEADER_HEIGHT;
//        if (actiCell._content.totalClap) {
//            return CELL_COMMENTS_HEADER_HEIGHT;
//        }
    }
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 10.0;
    }
    return 1.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = nil;
    if (section == 0) {
        return nil;
    }
    if (section == 1) {
        // Create view for header
        
        if (actiCell._content.totalClap >= 0) {
            header = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, CELL_COMMENTS_HEADER_HEIGHT)];
            header.backgroundColor = [UIColor clearColor];
            
            //clap btn
            
            UIButton *clapBtn = [[UIButton alloc]init];
            [clapBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE + 1]];
            if (actiCell._content.isClap) {
                [clapBtn setTitle:@"Unclap  " forState:UIControlStateNormal];
            }else
                [clapBtn setTitle:@" Clap    " forState:UIControlStateNormal];
            [clapBtn setTitleColor:actiCell.commentBtn.titleLabel.textColor forState:UIControlStateNormal];
            [clapBtn sizeToFit];
            clapBtn.layer.cornerRadius = 5.0;
            //clapBtn.layer.borderWidth = 0.20;
            //clapBtn.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
            [clapBtn.layer setMasksToBounds:YES];
            [clapBtn addTarget:self action:@selector(clapBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                              
            float width = self.scrollView.frame.size.width - CELL_CONTENT_MARGIN_RIGHT;
            CGRect frame;
            float y = 7;
            [clapBtn sizeToFit];
            frame = clapBtn.frame;
            frame.origin.x = 15;
            frame.origin.y = y;
            clapBtn.frame =frame;
            [header addSubview:clapBtn];
            if (actiCell._content.totalComment) {
                //Commnets
                UIButton *commentBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.scrollView.frame.size.width - 120, 7, 100, 15)];
                [commentBtn setTitle:[NSString stringWithFormat:@"%d Comments", actiCell._content.totalComment] forState:UIControlStateNormal];
                [commentBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                [commentBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [commentBtn sizeToFit];
                commentBtn.frame = CGRectMake(self.scrollView.frame.size.width - commentBtn.frame.size.width - 20, 7, commentBtn.frame.size.width, commentBtn.frame.size.height);
                //commentBtn.titleLabel.textColor = [UIColor colorWithRed:79.0/255 green:178.0/255 blue:187.0/255 alpha:1];
                commentBtn.titleLabel.textColor = actiCell.commentBtn.titleLabel.textColor;
                [commentBtn setTitleColor:actiCell.commentBtn.titleLabel.textColor forState:UIControlStateNormal];
                [commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [commentBtn sizeToFit];
                width -= commentBtn.frame.size.width;
                frame = commentBtn.frame;
                frame.origin.x = width;
                frame.origin.y = y;
                commentBtn.frame = frame;
                [header addSubview:commentBtn];
                
                width -= 7;
            }
            
            if (actiCell._content.totalClap) {
                // people clap
                UILabel *lbPeopleClap = [[UILabel alloc]init];
                lbPeopleClap.backgroundColor = [UIColor clearColor];
                [lbPeopleClap setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                lbPeopleClap.text =  [NSString stringWithFormat:@"%d", actiCell._content.totalClap];
                lbPeopleClap.textColor = actiCell.commentBtn.titleLabel.textColor;
                [lbPeopleClap sizeToFit];
                width -= lbPeopleClap.frame.size.width;
                frame = lbPeopleClap.frame;
                frame.origin.x = width;
                frame.origin.y = y;
                lbPeopleClap.frame = frame;
                 [header addSubview:lbPeopleClap];
                
                //[_clapIcon sizeToFit];
                //icon clap
                UIImageView *clapIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clap_black_white.png"]];
                clapIcon.frame = CGRectMake( 20.0, 7, 20 , 20);

                width -= (clapIcon.frame.size.width + 3);
                frame =clapIcon.frame;
                frame.origin.x = width;
                frame.origin.y = y;
                clapIcon.frame = frame;
                [header addSubview:clapIcon];
            }
        
        }
        
        
    }
    return header;
}
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        _btnSend.enabled = NO;
        _btnSend.titleLabel.textColor = [UIColor lightGrayColor];
    }else {
        _btnSend.enabled = YES;
        _btnSend.titleLabel.textColor = [UIColor blueColor];
        //        CGSize constraint = CGSizeMake(textView.frame.size.width, 64.0 );
        //        CGSize size = [textView.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        //        if (size.height > 32.0) {
        //            CGRect frame = textView.frame;
        //            frame.size.height = size.height;
        //            frame.origin.y -= (size.height - textView.frame.size.height);
        //            textView.frame = frame;
        //        }
    }
}
#pragma mark - Handle Keyboard

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWilBeShown:(NSNotification*)aNotification
{
    NSLog(@"%f %f %f", _tableView.contentOffset.y, _tableView.frame.size.height, _tableView.contentSize.height);
    float v1 = _tableView.contentOffset.y + _tableView.frame.size.height;
    float v2 = _tableView.contentSize.height - cCellHeight;

    
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.scrollView convertRect:frame fromView:nil];
    CGPoint pt = CGPointZero;
    ((UIScrollView*)self.scrollView).scrollEnabled = YES;
    pt = CGPointMake(0.0, frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.03];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    frame = self.view.frame;
    frame.size.height -= pt.y;
    self.scrollView.frame = frame;
    
    
    [UIView commitAnimations];
    
    @try {
        if ( v1 >=  v2 ) {
            if (listComments.count > 0) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count -1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@ scrollToRowAtIndexPath", [self class]);
    }
    @finally {
        
    }
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.scrollView convertRect:frame fromView:nil];
    CGPoint pt = CGPointZero;
    self.scrollView.scrollEnabled = YES;
    pt = CGPointMake(0.0, frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.03];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    frame = self.view.frame;
    //frame.size.height += pt.y;
    self.scrollView.frame = frame;
    
    
    [UIView commitAnimations];

}

#pragma mark - implement
- (void) addCell:(CommentsCellContent *) commentContent
{
    //insertStatusComment($user_id, $target_id, $content, $comment_type, $limit, $base64_image = false)
    
    
    if (listComments == nil) {
        listComments = [[NSMutableArray alloc] init ];
    }
    actiCell._content.totalComment += 1;
    [actiCell refreshClapCommentsView];
    [listComments addObject:commentContent];
    [_tableView reloadData];
    @try {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count - 1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void) loadCommentsInBackground
{
    //getStatusComments($status_id, $comment_type, $limit, $comment_id, $base64_image = false)
    
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    // actID
    functionName = @"getStatusComments";
    paraNames = [NSArray arrayWithObjects:@"status_id", @"comment_type", @"limit", @"comment_id",nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", actiCell._content.target_id], actiCell._content.commnent_type, @"0", @"0", nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    if (listComments == nil) {
        listComments = [[NSMutableArray alloc] init ];
    }
    for (NSDictionary *dict in data) {
        CommentsCellContent *content = [[CommentsCellContent alloc]init];
        content.commnetID = [[dict objectForKey:@"id"] integerValue];
        content.userAvatarURL = [NSData stringDecodeFromBase64String: [dict objectForKey:@"actor_thumb"]];
        content.userPostName = [dict objectForKey:@"actor_name"];
        content.text = [NSData stringDecodeFromBase64String:[dict objectForKey:@"content"]];
        content.created = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
        content.userPostID = [[dict objectForKey:@"actor_id"] integerValue];
        [listComments addObject:content];
    }
    //[_tableView reloadData];
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

- (IBAction)btnSendClicked:(id)sender {
    CommentsCellContent *newComments = [[CommentsCellContent alloc]init];
    
    newComments.userPostName = [UserPAInfo sharedUserPAInfo].usernamePU;
    newComments.userAvatarURL = [UserPAInfo sharedUserPAInfo].avatarUrl;
    newComments.text = _textBox.text;
    newComments.created = @"Just now";
    newComments.userPostID = [UserPAInfo sharedUserPAInfo].registrationID;
    [self addCell:newComments];
    newComments = nil;
    
    [self performSelector:@selector(sendCommentWithText:) withObject:_textBox.text];
    [_textBox resignFirstResponder];
    _textBox.text = @"";
}

- (void)sendCommentWithText:(NSString*)str
{
    //    insertPostComment($user_id, $post_id, $content)
    //insertStatusComment($user_id, $target_id, $content, $comment_type, $limit, $base64_image = false)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    functionName = @"insertStatusComment";
    paraNames = [NSArray arrayWithObjects:@"user_id", @"target_id", @"content", @"comment_type", @"limit", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%@", dataCellFromMain._content.activity_ID], str, dataCellFromMain._content.commnent_type, @"1", nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];
    
    
}

- (void) clap_UnClapPost:(id)sender
{
    [actiCell insertClap];
    UIButton *btn = (UIButton*)sender;
    btn.userInteractionEnabled = YES;
    [_tableView reloadData];
}

- (IBAction)clapBtnClicked:(id)sender {
    UIButton *btn = (UIButton*)sender;
    btn.userInteractionEnabled = NO;
    [self performSelectorInBackground:@selector(clap_UnClapPost:) withObject:sender];
    
    //Update local
    
}

- (IBAction)commentBtnClicked:(id)sender {
    @try {
        if (listComments.count) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count - 1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: Try to scroll to bottom");
    }
    @finally {
        
    }

}

- (void) tapAction
{
    [_textBox resignFirstResponder];
}
@end
