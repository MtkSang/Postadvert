//
//  HDBResultDetailViewController.m
//  Stroff
//
//  Created by Ray on 3/6/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HDBResultDetailViewController.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
#import "UIImageView+URL.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "CommentsCellContent.h"
#import "UserPAInfo.h"
#import <QuartzCore/QuartzCore.h>
@interface HDBResultDetailViewController ()

@end

@implementation HDBResultDetailViewController

- (id)initWithHDBID:(NSInteger) hdbID_ userID:(NSInteger) userID_
{
    self = [super init];
    if (self) {
        _hdbID = hdbID_;
        _userID = userID_;
    }
    return self;
}



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
    // Do any additional setup after loading the view from its nib.
    _texbox.layer.cornerRadius = 5.0;
    _texbox.layer.borderWidth = 0.25;
    _texbox.placeholder = @"Write a comment";
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
    if (_isModePreviewAd) {
        [_texbox setUserInteractionEnabled:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud showWhileExecuting:@selector(loadDataInBackground) onTarget:self withObject:nil animated:YES];
    if (self.showKeyboard) {
        [self.texbox becomeFirstResponder];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (cellData) {
        return 3;
        // 0-Detail Ad  1-contact Ad Owner  2- comments
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    if (section == 01) {
        return 2;
    }
    if (section == 2) {//comments
        return listComments.count;
    }
    
    return 0;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = nil;
//    if (section == 0) {
//        return nil;
//    }
    if (section == 01) {
        // Create view for header
        NSInteger index = 0;
        NSString *value;
        index = [cellData.paraNames indexOfObject:@"clap_info"];
        NSDictionary *clapInfo = [cellData.paraValues objectAtIndex:index];
        NSInteger totalClap = [[clapInfo objectForKey:@"total_claps"] integerValue];
        BOOL isClap = [[clapInfo objectForKey:@"is_clap"] boolValue];
        
        //Comment
        index = [cellData.paraNames indexOfObject:@"total_comments"];
        value = [cellData.paraValues objectAtIndex:index];
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
                [commentBtn setTitle:[NSString stringWithFormat:@"%d Comments", totalComment] forState:UIControlStateNormal];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        static NSString *CellIdentifier1 = @"HDBResultDetailCell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier1 owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            topLevelObjects = nil;
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            cell.backgroundView = [[UIView alloc] init];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        NSInteger index = 0;
        NSString *value =@"";
        //Property Status
        UILabel *status = (UILabel*)[cell viewWithTag:1];
        if ([_property_status isEqualToString:@"r"]) {
            [status setText:@"For Rent"];
        }else
        {
            [status setText:@"For Sale"];
        }
        //Create
        UILabel *created = (UILabel*)[cell viewWithTag:2];
        index = [cellData.paraNames indexOfObject:@"created"];
        value = [NSData stringDecodeFromBase64String:[cellData.paraValues objectAtIndex:index]];
        [created setText:value];
        //thumb
        UIImageView *imagView = (UIImageView*)[cell viewWithTag:3];
        index = [cellData.paraNames indexOfObject:@"thumb"];
        value = [cellData.paraValues objectAtIndex:index];
        [imagView setImageWithURL:[NSURL URLWithString:value]];
        //Title
        UILabel *titleHDB = (UILabel*) [cell viewWithTag:4];
        index = [cellData.paraNames indexOfObject:@"block_no"];
        value = [cellData.paraValues objectAtIndex:index];
        
        index = [cellData.paraNames indexOfObject:@"street_name"];
        value = [NSString stringWithFormat:@"%@ %@",value, [cellData.paraValues objectAtIndex:index]];
        [titleHDB setText:value];
        //price
        UILabel *price = (UILabel*) [cell viewWithTag:12];
        if ([_property_status isEqualToString:@"s"]) {
            index = [cellData.paraNames indexOfObject:@"price"];
        }else
        {
            index = [cellData.paraNames indexOfObject:@"monthly_rental"];
        }
        
        value = [cellData.paraValues objectAtIndex:index];
        [price setText:[NSString stringWithFormat:@"S$ %@", value]];
        //psf
        index = [cellData.paraNames indexOfObject:@"psf"];
        value = [cellData.paraValues objectAtIndex:index];
        
        [price setText:[NSString stringWithFormat:@"%@ (S$ %@ psf)",price.text, value]];
        
        
        //lease_term_valuation_price (unit_level)
        UILabel *lease_term_valuation_price = (UILabel*) [cell viewWithTag:5];
        if ([_property_status isEqualToString:@"s"]) {
            index = [cellData.paraNames indexOfObject:@"valuation_price"];
            value = [NSString stringWithFormat:@"S$ %@ valn", [cellData.paraValues objectAtIndex:index]];
        }else
        {
            index = [cellData.paraNames indexOfObject:@"lease_term"];
            value = [cellData.paraValues objectAtIndex:index];
        }
        
        //unit_level
        index = [cellData.paraNames indexOfObject:@"unit_level"];
        NSString *unit_level = [cellData.paraValues objectAtIndex:index];
        if (unit_level.length > 0) {
            value = [NSString stringWithFormat:@"%@ ( %@ )", value, unit_level];
        }
        [lease_term_valuation_price setText:value];
        //hdb_estate
        UILabel *hdb_estate = (UILabel*) [cell viewWithTag:6];
        index = [cellData.paraNames indexOfObject:@"hdb_estate"];
        value = [cellData.paraValues objectAtIndex:index];
        
        //furnishing
        index = [cellData.paraNames indexOfObject:@"furnishing"];
        NSString *furnishing = [cellData.paraValues objectAtIndex:index];
        if (! [furnishing isEqualToString:@""] ) {
            value = [value stringByAppendingFormat:@" ( %@ )", furnishing];
        }
        [hdb_estate setText:value];
        //size
        UILabel *size = (UILabel*) [cell viewWithTag:7];
        index = [cellData.paraNames indexOfObject:@"size"];
        value = [cellData.paraValues objectAtIndex:index];
        [size setText:[NSString stringWithFormat:@"%@ sqft",value]];
        float sqft = [value floatValue];
        float sqm = sqft * 0.092903;
        [size setText:[NSString stringWithFormat:@"%@ sqft / %0.02f sqm",value, sqm]];
        //building_completion
        UILabel *building_completion = (UILabel*) [cell viewWithTag:11];
        index = [cellData.paraNames indexOfObject:@"building_completion"];
        value = [cellData.paraValues objectAtIndex:index];
        [building_completion setText:[NSString stringWithFormat:@"%@ Completed", value]];
        //bedrooms
        UILabel *bedrooms = (UILabel*) [cell viewWithTag:8];
        index = [cellData.paraNames indexOfObject:@"bedrooms"];
        value = [cellData.paraValues objectAtIndex:index];
        [bedrooms setText:value];
        //washroom
        UILabel *washroom = (UILabel*) [cell viewWithTag:9];
        index = [cellData.paraNames indexOfObject:@"washroom"];
        value = [cellData.paraValues objectAtIndex:index];
        [washroom setText:value];
        //totalView
        UILabel *total_views = (UILabel*) [cell viewWithTag:13];
        index = [cellData.paraNames indexOfObject:@"total_views"];
        value = [cellData.paraValues objectAtIndex:index];
        [total_views setText:[NSString stringWithFormat:@"Total Views: %@", value]];
        //HDB Type
        UILabel *HDBType = (UILabel*) [cell viewWithTag:14];
        index = [cellData.paraNames indexOfObject:@"property_type"];
        value = [cellData.paraValues objectAtIndex:index];
        [HDBType setText:value];
        return cell;
        
    }
    
    if ((indexPath.section == 1)) {
        if ( ( indexPath.row == 0) ) {
            static NSString *CellIdentifier2 = @"HDBResultDetailCell2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            if (cell == nil) {
                
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier2 owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                topLevelObjects = nil;
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                cell.backgroundView = [[UIView alloc] init];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            NSInteger index;
            NSString *value;
            //avartar
            UIImageView *avatar = (UIImageView*)[cell viewWithTag:3];
            [avatar setImageWithURL:[NSURL URLWithString:cellData.userInfo.avatarUrl]];
            // posted user
            UILabel *user_posted = (UILabel*)[cell viewWithTag:4];
            [user_posted setText:cellData.userInfo.fullName];
            
            
            //ad_owner
            UILabel *ad_owner = (UILabel*)[cell viewWithTag:5];
            index = [cellData.paraNames indexOfObject:@"ad_owner"];
            value = [cellData.paraValues objectAtIndex:index];
            [ad_owner setText:value];
            
            //[self setClapCommentForCell:cell andData:cellData];
            return cell;
        }
        if (indexPath.row == 1) {
            //descritption
            //HDBResultDetailCell3
            static NSString *CellIdentifier3 = @"HDBResultDetailCell3";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier3 owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                topLevelObjects = nil;
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                cell.backgroundView = [[UIView alloc] init];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            NSInteger index;
            NSString *value;
            index = [cellData.paraNames indexOfObject:@"description"];
            value = [cellData.paraValues objectAtIndex:index];
            value = [NSData stringDecodeFromBase64String:value];
            UILabel *description = (UILabel*)[cell viewWithTag:2];
            [description setText:value];
            
            return cell;
        }
        
    }
    if (indexPath.section == 2) {
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
    return nil;
}


#pragma mark - Table view delegate

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 201;
        }
    }
    if (indexPath.section == 01) {
        if (indexPath.row == 0) {
            return 120;
        }
        if (indexPath.row == 1) {//description
            NSInteger index;
            NSString *value;
            index = [cellData.paraNames indexOfObject:@"description"];
            value = [cellData.paraValues objectAtIndex:index];
            value = [NSData stringDecodeFromBase64String:value];
            CGSize constraint = CGSizeMake(320 - 26, 20000.0f);
            CGSize size = [value sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            return size.height + 25;
        }
    }
    //commment size
    return [CommentsCellContent getCellHeighWithContent:[listComments objectAtIndex:indexPath.row] withWidth:294 - 74];
}

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
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count -1 inSection:_tableView.numberOfSections - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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


#pragma mark - background function

- (void) loadDataInBackground
{
    if (_isModePreviewAd) {
        //getHDBDetail($hdb_id, $user_id, $base64_image = false)
        id data;
        NSString *functionName;
        NSArray *paraNames;
        NSArray *paraValues;
        functionName = @"getHDBDetail";
        paraNames = [NSArray arrayWithObjects:@"hdb_id", @"user_id", nil];
        paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", _hdbID], [NSString stringWithFormat:@"%d", _userID], nil];
        data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
        
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data];
        
        if (dict) {
            cellData = [[HBBResultCellData alloc]init];
            cellData.hdbID = [[dict objectForKey:@"id"] integerValue];
            cellData.timeCreated = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
            cellData.titleHDB = [dict objectForKey:@"address"];
            //        NSString *title = [dict objectForKey:@"street_name"];
            //        cellData.titleHDB = [cellData.titleHDB stringByAppendingString:title];
            
            //author
            NSDictionary *authorDict = [dict objectForKey:@"author"];
            cellData.userInfo = [[CredentialInfo alloc]init];
            if ([authorDict isKindOfClass:[NSDictionary class]]) {
                cellData.userInfo = [[CredentialInfo alloc]initWithDictionary:authorDict];
            }
            
            for (NSString *key in cellData.paraNames) {
                id object = [dict objectForKey:key];
                if (object != nil) {
                    [cellData.paraValues addObject: object];
                }
                
            }
            
        }
        [self.tableView reloadData];
        [self performSelectorInBackground:@selector(loadCommentsInBackground) withObject:nil];
    }else
    {
        //getHDBDetail($hdb_id, $user_id, $base64_image = false)
        id data;
        NSString *functionName;
        NSArray *paraNames;
        NSArray *paraValues;
        functionName = @"getHDBDetail";
        paraNames = [NSArray arrayWithObjects:@"hdb_id", @"user_id", nil];
        paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", _hdbID], [NSString stringWithFormat:@"%d", _userID], nil];
        data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
        
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data];
        
        if (dict) {
            cellData = [[HBBResultCellData alloc]init];
            cellData.hdbID = [[dict objectForKey:@"id"] integerValue];
            cellData.timeCreated = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
            //cellData.titleHDB = [dict objectForKey:@"address"];
            //        NSString *title = [dict objectForKey:@"street_name"];
            //        cellData.titleHDB = [cellData.titleHDB stringByAppendingString:title];
            
            //author
            NSDictionary *authorDict = [dict objectForKey:@"author"];
            cellData.userInfo = [[CredentialInfo alloc]init];
            if ([authorDict isKindOfClass:[NSDictionary class]]) {
                cellData.userInfo = [[CredentialInfo alloc]initWithDictionary:authorDict];
            }
            
            for (NSString *key in cellData.paraNames) {
                id object = [dict objectForKey:key];
                if (object != nil) {
                    [cellData.paraValues addObject: object];
                }
                
            }
            
        }
        [self.tableView reloadData];
        [self performSelectorInBackground:@selector(loadCommentsInBackground) withObject:nil];
    }
}

- (void) loadCommentsInBackground
{
    //getHDBComments($hdb_id, $limit = 0, $comment_id = 0, $base64_image = false, $function = 'apps')
    
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    // actID
    functionName = @"getHDBComments";
    paraNames = [NSArray arrayWithObjects:@"hdb_id", @"limit", @"comment_id", @"base64_image", @"function", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", self.hdbID], @"0", @"0", @"0", @"app", nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    listComments = [[NSMutableArray alloc] init ];
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


#pragma mark -
- (void) addCell:(CommentsCellContent *) commentContent
{
    //insertStatusComment($user_id, $target_id, $content, $comment_type, $limit, $base64_image = false)
    
    
    if (listComments == nil) {
        listComments = [[NSMutableArray alloc] init ];
    }
//    actiCell._content.totalComment += 1;
//    [actiCell refreshClapCommentsView];
    [listComments addObject:commentContent];
    ////Comment
    NSInteger index = [cellData.paraNames indexOfObject:@"total_comments"];
    NSString *value = [NSString stringWithFormat:@"%d", listComments.count];
    [cellData.paraValues replaceObjectAtIndex:index withObject:value];
    
    [_tableView reloadData];
    @try {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count - 1 inSection:_tableView.numberOfSections -1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (IBAction)commentBtnClicked:(id)sender {
    if (_isModePreviewAd) {
        return;
    }
    @try {
        if (listComments.count) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count - 1 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        [self performSelectorInBackground:@selector(loadCommentsInBackground) withObject:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: Try to scroll to bottom");
    }
    @finally {
        
    }
    
}

- (void)sendCommentWithText:(NSString*)str
{
    //  insertHDBComment($user_id, $hdb_id, $content, $limit, $base64_image = false)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    functionName = @"insertHDBComment";
    paraNames = [NSArray arrayWithObjects:@"user_id", @"hdb_id", @"content", @"limit", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%d", self.hdbID], str, @"1", nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];
    @try {
        BOOL error_code = [[data objectForKey:@"error_code"] boolValue];
        if (!error_code) {
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        
    }
    
   
}

- (void) tapAction
{
    [_texbox resignFirstResponder];
}

- (void) insertClap
{
    // hdbClap($user_id, $hdb_id)
    
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    functionName = @"hdbClap";
    paraNames = [NSArray arrayWithObjects:@"user_id", @"hdb_id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%d", self.hdbID], nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];
    
    @try {
        NSInteger isClap = [[data objectForKey:@"clap"] integerValue];
        NSInteger totalClap = [[data objectForKey:@"total_clap"] integerValue];
        //Update clap
        
        NSInteger index = [cellData.paraNames indexOfObject:@"clap_info"];
        NSDictionary *clapInfo = [cellData.paraValues objectAtIndex:index];
        [clapInfo setValue:[NSString stringWithFormat:@"%d", totalClap] forKey:@"total_claps"];
        [clapInfo setValue:[NSString stringWithFormat:@"%d", isClap] forKey:@"is_clap"];
        [cellData.paraValues replaceObjectAtIndex:index withObject:clapInfo];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    [self.tableView reloadData];
    
}

- (void) clap_UnClapPost:(id)sender
{
    [self insertClap];
    UIButton *btn = (UIButton*)sender;
    btn.userInteractionEnabled = YES;
    [_tableView reloadData];
}

- (IBAction)clapBtnClicked:(id)sender {
    if (_isModePreviewAd) {
        return;
    }
    UIButton *btn = (UIButton*)sender;
    btn.userInteractionEnabled = NO;
    [self performSelectorInBackground:@selector(clap_UnClapPost:) withObject:sender];
    
    //Update local
    
}

- (IBAction)btnSendClicked:(id)sender {
    CommentsCellContent *newComments = [[CommentsCellContent alloc]init];
    
    newComments.userPostName = [UserPAInfo sharedUserPAInfo].usernamePU;
    newComments.userAvatarURL = [UserPAInfo sharedUserPAInfo].avatarUrl;
    newComments.text = _texbox.text;
    newComments.created = @"Just now";
    newComments.userPostID = [UserPAInfo sharedUserPAInfo].registrationID;
    [self addCell:newComments];
    newComments = nil;
    
    [self performSelector:@selector(sendCommentWithText:) withObject:_texbox.text];
    [_texbox resignFirstResponder];
    _texbox.text = @"";
    
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBtnSend:nil];
    [self setTexbox:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
