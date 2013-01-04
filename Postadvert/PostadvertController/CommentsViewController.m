//
//  CommentsViewController.m
//  Postadvert
//
//  Created by Mtk Ray on 6/5/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "CommentsViewController.h"
#import "PostCellContent.h"
#import "UIPlaceHolderTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "UserPAInfo.h"
#import "UICommentsCell.h"
#import "CommentsCellContent.h"
#import "UIPostCell.h"
#import "UIImageView+URL.h"
#import "ActivityContent.h"
#import "MBProgressHUD.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"

@interface CommentsViewController ()
- (void) loadCommentsInBackground;
- (void)keyboardWilBeShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
- (void)sendCommentWithText:(NSString*)str;
- (IBAction)commentBtnClicked:(id)sender ;
- (IBAction)clapBtnClicked:(id)sender ;
- (void) loadPostInBackground:(NSNumber*)num;
@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithPostID:(NSInteger)_postID
{
    self = [super init];
    if (self) {
        postID = _postID;
        NSNumber *num = [NSNumber numberWithInteger:postID];
        listComments = [[NSMutableArray alloc]init];
        [self performSelectorInBackground:@selector(loadPostInBackground:) withObject:num];
    }

    return self;
}

- (id)initWithPostCell:(UIPostCell *)cell
{
    //Must call from this contructor
    self = [super init];
    if (self) {
        dataCellFromMain = cell;
        NSArray *nib = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            nib = [[NSBundle mainBundle] loadNibNamed:@"UIPostCell_Landscape" owner:self options:nil];
        }
        else{
            nib = [[NSBundle mainBundle] loadNibNamed:@"UIPostCell_IPad" owner:self options:nil];
        }
        actiCell = (UIPostCell *)[nib objectAtIndex:0];
        [actiCell loadNibFile];
        actiCell.navigationController = cell.navigationController;
        [actiCell updateCellWithContent:cell.content andOption:1];
        [actiCell setSelectionStyle:UITableViewCellEditingStyleNone];
        [actiCell setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//        actiCell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
//        actiCell.backgroundView.backgroundColor = [UIColor whiteColor];
        
        actiCell.botView.hidden = YES;
        actiCellSuperView = (UITableView*)cell.superview;
        listComments = [[NSMutableArray alloc]init];
        cellContent = actiCell.content;
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _textBox.layer.cornerRadius = 5.0;
    _textBox.layer.borderWidth = 0.25;
    _textBox.placeholder = @"Write a text";
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
    [actView showWhileExecuting:@selector(loadCommentsInBackground) onTarget:self withObject:nil animated:NO];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    actiCell.botView.hidden = YES;
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    dataCellFromMain.content = actiCell.content;
    [dataCellFromMain refreshClapCommentsView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    //Draw backview
    //[dataCellFromMain updateCellWithContent:actiCell.content andOption:0];
    [actiCellSuperView reloadData];
    actiCell.botView.hidden = NO;
    
    
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBotView:nil];
    [self setBtnSend:nil];
    [self setTextBox:nil];
    [self setScrollView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        if (actiCell == nil && cellContent == nil) {
            return 40;
        }
        if (actiCell == nil && cellContent != nil) {
            return  [UIPostCell getCellHeightWithContent:cellContent andOption:1] - 26 + 3;;
        }
        return  [UIPostCell getCellHeightWithContent:actiCell.content andOption:1] - actiCell.botView.frame.size.height + 3;
    }
    return [CommentsCellContent getCellHeighWithContent:[listComments objectAtIndex:indexPath.row] withWidth:self.view.frame.size.width - 74];
}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.detailTextLabel.frame = CGRectMake(cMaxLeftView - 100, 0.0, 70, cCellHeight);
//
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (actiCell == nil) {     
            if (cellContent == nil) {
                UITableViewCell *cell = [[UITableViewCell alloc]init];
                UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
                [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                [cell addSubview:activityView];
                activityView.hidden = NO;
                [activityView startAnimating];
                return cell;

            }else
            {
                NSArray *nib = nil;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                    nib = [[NSBundle mainBundle] loadNibNamed:@"UIPostCell_Landscape" owner:self options:nil];
                }
                else{
                    nib = [[NSBundle mainBundle] loadNibNamed:@"UIPostCell_IPad" owner:self options:nil];
                }
                actiCell = (UIPostCell *)[nib objectAtIndex:0];
                [actiCell loadNibFile];
                actiCell.navigationController = self.navigationController;
                [actiCell updateCellWithContent:cellContent andOption:1];
                [actiCell setSelectionStyle:UITableViewCellEditingStyleNone];
                [actiCell setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
                //        actiCell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
                //        actiCell.backgroundView.backgroundColor = [UIColor whiteColor];
                
                actiCell.botView.hidden = YES;
                return actiCell;
            }
        }
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
        
        if (cellContent.totalClap >= 0) {
            header = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, CELL_COMMENTS_HEADER_HEIGHT)];
            header.backgroundColor = [UIColor clearColor];
            UIColor *controllColor = dataCellFromMain.numComment.textColor;
            if (dataCellFromMain == nil) {
                controllColor = [UIColor colorWithRed:50.0/255.0 green:79.0/255.0 blue:133.0/255.0 alpha:1];
            }
            //clap btn
            
            UIButton *clapBtn = [[UIButton alloc]init];
            [clapBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
            if (cellContent.isClap) {
                [clapBtn setTitle:@"Unclap  " forState:UIControlStateNormal];
            }else
                [clapBtn setTitle:@" Clap    " forState:UIControlStateNormal];

            [clapBtn setTitleColor:controllColor forState:UIControlStateNormal];
            [clapBtn sizeToFit];
            clapBtn.layer.cornerRadius = 5.0;
            //clapBtn.layer.borderWidth = 0.20;
            //clapBtn.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
            [clapBtn.layer setMasksToBounds:YES];
            [clapBtn addTarget:self action:@selector(clapBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            float width = actiCell.contentView.frame.size.width - CELL_CONTENT_MARGIN_RIGHT;
            CGRect frame;
            float y = 7;
            [clapBtn sizeToFit];
            frame = clapBtn.frame;
            frame.origin.x = 15;
            frame.origin.y = y;
            clapBtn.frame =frame;
            [header addSubview:clapBtn];
            if (cellContent.totalComment) {
                //Commnets
                UIButton *commentBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.scrollView.frame.size.width - 120, 7, 100, 15)];
                [commentBtn setTitle:[NSString stringWithFormat:@"%d Comments", cellContent.totalComment] forState:UIControlStateNormal];
                [commentBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                [commentBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [commentBtn sizeToFit];
                commentBtn.frame = CGRectMake(self.scrollView.frame.size.width - commentBtn.frame.size.width - 20, 7, commentBtn.frame.size.width, commentBtn.frame.size.height);
                //commentBtn.titleLabel.textColor = [UIColor colorWithRed:79.0/255 green:178.0/255 blue:187.0/255 alpha:1];
                commentBtn.titleLabel.textColor = controllColor;
                [commentBtn setTitleColor:controllColor forState:UIControlStateNormal];
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
            
            if (cellContent.totalClap) {
                // people clap
                UILabel *lbPeopleClap = [[UILabel alloc]init];
                lbPeopleClap.backgroundColor = [UIColor clearColor];
                [lbPeopleClap setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                lbPeopleClap.text =  [NSString stringWithFormat:@"%d", cellContent.totalClap];
                lbPeopleClap.textColor = controllColor;
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
    if (listComments == nil) {
        listComments = [[NSMutableArray alloc] init ];
    }
    cellContent.totalComment += 1;
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
- (void) loadPostInBackground:(NSNumber*)num
{
    
    //getPostDetail($user_id, $post_id, $base64_image = false)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    functionName = @"getPostDetail";
    paraNames = [NSArray arrayWithObjects:@"user_id", @"post_id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%d", num.integerValue], nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
     cellContent = [PostadvertControllerV2 getaPostCellWithDict:data];
    
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

- (void) loadCommentsInBackground
{
    //getStatusComments($status_id, $comment_type, $limit, $comment_id, $base64_image = false)
    
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    // actID
    
    //getPostComments($post_id, $limit, $comment_id, $base64_image = false)
    functionName = @"getPostComments";
    paraNames = [NSArray arrayWithObjects:@"post_id", @"limit", @"comment_id",nil];
    NSInteger posid = 0;
    if (actiCell == nil) {
        posid = postID;
    }else
        posid = actiCell.content.ID_Post;
    if (posid == 0) {
        return;
    }
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", posid], @"0", @"0", nil];
    
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
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:1];
    
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

- (void) clap_UnClapPost:(id)sender
{
    [actiCell clap_UnClapPost];
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
- (void)sendCommentWithText:(NSString*)str
{
//    insertPostComment($user_id, $post_id, $content)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    functionName = @"insertPostComment";
    paraNames = [NSArray arrayWithObjects:@"user_id", @"post_id", @"content",nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%d", actiCell.content.ID_Post], str, nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];
    
}
@end
