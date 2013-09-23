//
//  Q_ACellDetailViewController.m
//  Stroff
//
//  Created by Ray on 9/12/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "Q_ACellDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "Constants.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
#import "UIImageView+URL.h"
#import "CommentsCellContent.h"

@interface Q_ACellDetailViewController ()

@end

@implementation Q_ACellDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithData:(NSDictionary*)data andType:(enum Q_ADetailType)type
{
    self = [super init];
    if (self) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            cellData = [[NSDictionary alloc]initWithDictionary:data];
            typeDetail = type;
        }
        
    }
    return self;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWilBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    //TapGesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_tableView addGestureRecognizer:tap];
    mpLoadData = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:mpLoadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setTableView:nil];
    [self setBtnSend:nil];
    [self setTextBox:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 2;
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    if (section == 0) {
        numberOfRowsInSection = 1;
    }
    if (section == 1 && listAnwser) {
        numberOfRowsInSection = listAnwser.count;
    }
    return numberOfRowsInSection;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Question Cell
    if (indexPath.section == 0) {
        static NSString *CellIdentifierQ_ACell = @"Q_ACellDetail";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierQ_ACell];
        if (cell == nil) {
            NSArray *nib = nil;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                nib = [[NSBundle mainBundle] loadNibNamed:@"Q_ACellList" owner:self options:nil];
            }
            else{
                nib = [[NSBundle mainBundle] loadNibNamed:@"Q_ACellList" owner:self options:nil];
            }
            cell = (UITableViewCell*)[nib objectAtIndex:0];
        }
        @try {
            //Background
            UIView *backgroundView = [cell viewWithTag:100];
            backgroundView.layer.cornerRadius = 5.0f;
            
            //    User
            CredentialInfo *author = [[CredentialInfo alloc]initWithDictionary:[cellData objectForKey:@"author"]];
            UILabel *userName = (UILabel*)[cell viewWithTag:1];
            userName.text = author.usernamePU;
            UIImageView *avatar = (UIImageView*)[cell viewWithTag:2];
            [avatar setImageWithURL:[NSURL URLWithString:author.avatarUrl] placeholderImage:[UIImage imageNamed:@"user_default_thumb.png" ]];
            UILabel *created = (UILabel*)[cell viewWithTag:4];
            created.text =  [NSData stringDecodeFromBase64String: [cellData objectForKey:@"created_on_lapseTime"]];
            
            UILabel *lbQuestion = (UILabel*)[cell viewWithTag:5];
            NSString *question = @"";
            question = [question stringByAppendingString:[NSData stringDecodeFromBase64String: [cellData objectForKey:@"content"]]];
            lbQuestion.text = question;
            
            CGRect frame;
            float y = 20;
            CGSize constraint = CGSizeMake(220, 20000.0f);
            CGSize size = [question sizeWithFont:lbQuestion.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            frame = lbQuestion.frame;
            frame.size = size;
            frame.origin.y = y;
            lbQuestion.frame = frame;
            y += frame.size.height + CELL_CONTENT_MARGIN_TOP;
            UILabel *answerBy_catelogy = (UILabel*)[cell viewWithTag:6];
            NSString *answerBy = [cellData objectForKey:@"created"];
            NSString *replies = [cellData objectForKey:@"total_answer"];
            NSString *cat_name = [NSData stringDecodeFromBase64String:[cellData objectForKey:@"cat_name"]];
            answerBy_catelogy.text = [NSString stringWithFormat:@"Answered by on %@ | %@ Replies \nCategogy: %@", answerBy, replies, cat_name];
            
            size = [answerBy_catelogy.text sizeWithFont:answerBy_catelogy.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            frame = answerBy_catelogy.frame;
            frame.size = size;
            frame.origin.y = y;
            answerBy_catelogy.frame = frame;
            y += frame.size.height + CELL_CONTENT_MARGIN_TOP;
            UILabel *lbAnswer = (UILabel*)[cell viewWithTag:7];
            lbAnswer.hidden = YES;
            //Claps_commnets
            UIView *aView = [cell viewWithTag:8];
            aView.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        @catch (NSException *exception) {
            return cell;
        }
    }
    if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"UICommentCell";
        
        UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = nil;
            nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
            cell = (UITableViewCell *)[nib objectAtIndex:0];
            
        }
        CommentsCellContent *content = [listAnwser objectAtIndex:indexPath.row];
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
        CGSize constraint = CGSizeMake(294 - 74, 20000.0f);
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
    return [[UITableViewCell alloc]init];
}

#pragma mark - Table view delegate

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float heightForRow = 0;
    if (typeDetail == Q_ADetailTypeViewDetail) {
        if (indexPath.section == 0) {
            if (![cellData isKindOfClass:[NSDictionary class]]) {
                return 0;
            }
            float y = 20.0f;
            NSString *question = @"";
            question = [question stringByAppendingString:[NSData stringDecodeFromBase64String: [cellData objectForKey:@"content"]]];
            
            CGSize constraint = CGSizeMake(220, 20000.0f);
            CGSize size = [question sizeWithFont:[UIFont fontWithName:FONT_NAME size:10.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            y += size.height + CELL_CONTENT_MARGIN_TOP;
            
            NSString *answerBy = [cellData objectForKey:@"created"];
            NSString *replies = [cellData objectForKey:@"total_answer"];
            NSString *cat_name = [NSData stringDecodeFromBase64String:[cellData objectForKey:@"cat_name"]];
            NSString *text = [NSString stringWithFormat:@"Answered by on %@ | %@ Replies \nCategogy: %@", answerBy, replies, cat_name];
            
            size = [text sizeWithFont:[UIFont fontWithName:FONT_NAME size:10.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            y += size.height + CELL_CONTENT_MARGIN_TOP;

            if (y < 80) {
                y =80;
            }
            heightForRow = y;
        }else
        {
            heightForRow = [CommentsCellContent getCellHeighWithContent:[listAnwser objectAtIndex:indexPath.row] withWidth:294 - 74];

        }
    }
    
    return heightForRow;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = nil;
    if (section == 01) {
        // Create view for header
        NSString *value;
        NSDictionary *clapInfo = [cellData objectForKey:@"clap_info"];
        NSInteger totalClap = [[clapInfo objectForKey:@"total_claps"] integerValue];
        BOOL isClap = [[clapInfo objectForKey:@"is_clap"] boolValue];
        
        //Comment
        value = [cellData objectForKey:@"total_answer"];
        NSInteger totalComment = [value integerValue];
        if (totalClap >= 0) {
            header = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, CELL_COMMENTS_HEADER_HEIGHT)];
            header.backgroundColor = [UIColor clearColor];
            
            //clap btn
            
            UIButton *clapBtn = [[UIButton alloc]init];
            [clapBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE ]];
            if (isClap) {
                [clapBtn setTitle:@"Unclap  " forState:UIControlStateNormal];
            }else
                [clapBtn setTitle:@" Clap    " forState:UIControlStateNormal];
            [clapBtn sizeToFit];
            clapBtn.titleLabel.textColor = [UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1];
            //clapBtn.layer.cornerRadius = 5.0;
            //clapBtn.layer.borderWidth = 0.20;
            //clapBtn.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
            //[clapBtn.layer setMasksToBounds:YES];
            [clapBtn addTarget:self action:@selector(clapBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            float width = self.view.frame.size.width - CELL_CONTENT_MARGIN_RIGHT - 22;
            CGRect frame;
            float y = 7;
            [clapBtn sizeToFit];
            frame = clapBtn.frame;
            frame.origin.x = 15;
            frame.origin.y = y;
            clapBtn.frame =frame;
            [header addSubview:clapBtn];
            if (totalComment) {
                //Commnets
                UIButton *commentBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 120, 7, 100, 15)];
                [commentBtn setTitle:[NSString stringWithFormat:@"%d answers", totalComment] forState:UIControlStateNormal];
                [commentBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                [commentBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [commentBtn sizeToFit];
                commentBtn.frame = CGRectMake(self.view.frame.size.width - commentBtn.frame.size.width - 20, 7, commentBtn.frame.size.width, commentBtn.frame.size.height);
                commentBtn.titleLabel.textColor = [UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1];
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
            
            if (totalClap) {
                // people clap
                UILabel *lbPeopleClap = [[UILabel alloc]init];
                lbPeopleClap.backgroundColor = [UIColor clearColor];
                [lbPeopleClap setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                lbPeopleClap.text =  [NSString stringWithFormat:@"%d",totalClap];
                [lbPeopleClap setTextColor:[UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat heightForHeaderInSection = 1;
    if (section == 1) {
        heightForHeaderInSection = CELL_COMMENTS_HEADER_HEIGHT;
    }
    return heightForHeaderInSection;
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
            if (listAnwser.count > 0) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listAnwser.count -1 inSection:_tableView.numberOfSections - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    //    CGPoint pt = CGPointZero;
    self.scrollView.scrollEnabled = YES;
    //    pt = CGPointMake(0.0, frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.03];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    frame = self.view.frame;
    //frame.size.height += pt.y;
    self.scrollView.frame = frame;
    
    
    [UIView commitAnimations];
    
}
- (void) tapAction
{
    [_textBox resignFirstResponder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([text isEqualToString:@""]) {
        _btnSend.enabled = NO;
        _btnSend.titleLabel.textColor = [UIColor lightGrayColor];
    }else {
        _btnSend.enabled = YES;
        _btnSend.titleLabel.textColor = [UIColor blueColor];
    }
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
    
//    [self performSelector:@selector(sendCommentWithText:) withObject:_textBox.text];
    [_textBox resignFirstResponder];
    _textBox.text = @"";
}
- (void) addCell:(CommentsCellContent *) commentContent
{
    //insertStatusComment($user_id, $target_id, $content, $comment_type, $limit, $base64_image = false)
    
    
    if (listAnwser == nil) {
        listAnwser = [[NSMutableArray alloc] init ];
    }

    [listAnwser addObject:commentContent];
    ////Comment
    
    [_tableView reloadData];
    @try {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listAnwser.count - 1 inSection:_tableView.numberOfSections -1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (IBAction)commentBtnClicked:(id)sender {
    @try {
        if (listAnwser.count) {
            NSInteger section = self.tableView.numberOfSections;
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listAnwser.count - 1 inSection:section - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
//        [self performSelectorInBackground:@selector(loadCommentsInBackground) withObject:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: Try to scroll to bottom");
    }
    @finally {
        
    }
    
}

@end
