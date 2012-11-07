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
        actiCell = cell;
        actiCell.typeOfCurrentView = 1;
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
    MBProgressHUD * actView = [[MBProgressHUD alloc]initWithView:self.view];
    [actView showWhileExecuting:@selector(loadCommentsInBackground) onTarget:self withObject:nil animated:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBotView:nil];
    [self setBtnSend:nil];
    [self setTextBox:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    
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
        return  actiCell.frame.size.height - 2;
    }
    return [CommentsCellContent getCellHeighWithContent:[listComments objectAtIndex:indexPath.row]];
}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.detailTextLabel.frame = CGRectMake(cMaxLeftView - 100, 0.0, 70, cCellHeight);
//
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
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
        if (actiCell._content.totalClap) {
            return CELL_COMMENTS_HEADER_HEIGHT;
        }
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
        
        if (actiCell._content.totalClap > 0) {
            header = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, CELL_COMMENTS_WIDTH, CELL_COMMENTS_HEADER_HEIGHT)];
            header.backgroundColor = [UIColor clearColor];
            //icon clap
            UIImageView *clapIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clap.png"]];
            clapIcon.frame = CGRectMake( 20.0, 7, 25, 15);
            
            // people clap
            UILabel *lbPeopleClap = [[UILabel alloc]initWithFrame:CGRectMake(clapIcon.frame.origin.x + clapIcon.frame.size.width + CELL_MARGIN_BETWEEN_IMAGE, clapIcon.frame.origin.y, CELL_COMMENTS_WIDTH - (clapIcon.frame.origin.x + clapIcon.frame.size.width + CELL_MARGIN_BETWEEN_IMAGE), clapIcon.frame.size.height )];
            lbPeopleClap.backgroundColor = [UIColor clearColor];
            [lbPeopleClap setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
            
            if (actiCell._content.isClap) {
                // did clap
                switch (actiCell._content.totalClap) {
                    case 1:
                        lbPeopleClap.text = @"You like this";
                        break;
                    case 2:
                        lbPeopleClap.text = @"You and another like this";
                        break;
                    default:
                        lbPeopleClap.text = [NSString stringWithFormat:@"You and %d others like this.", actiCell._content.totalClap - 1];
                        break;
                }
                
            }else {
                switch (actiCell._content.totalClap) {
                    case 1:
                        lbPeopleClap.text = @"A persion likes this";
                        break;
                    default:
                        lbPeopleClap.text = [NSString stringWithFormat:@"%d people like this.", actiCell._content.totalClap];
                        break;
                }
                
            }
            
            [header addSubview:clapIcon];
            [header addSubview:lbPeopleClap];
            clapIcon = nil;
            lbPeopleClap = nil;
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
    CGPoint pt = CGPointZero;
    
    ((UIScrollView*)self.view).scrollEnabled = YES;
    pt = CGPointMake(0.0, 216);
    [(UIScrollView*)self.view setContentOffset:pt animated:YES];
    _tableView.frame = CGRectMake(0.0, 216, self.view.frame.size.width, _tableView.frame.size.height - 216);
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count -1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
- (void) addCell:(CommentsCellContent *) commentContent
{
    if (listComments == nil) {
        listComments = [[NSMutableArray alloc] init ];
    }
    actiCell._content.totalComment += 1;

    [listComments addObject:commentContent];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count - 1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
    
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

- (IBAction)btnSendClicked:(id)sender {
}

- (void) tapAction
{
    [_textBox resignFirstResponder];
}
@end
