//
//  UIActivityCell.m
//  Postadvert
//
//  Created by Ray on 8/29/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "UIActivityCell.h"
#import "ActivityContent.h"
#import "Constants.h"
#import "UIImageView+URL.h"
#import <QuartzCore/QuartzCore.h>
#import "NSAttributedString+Attributes.h"
#import "SDWebImageController/SDWebImageRootViewController.h"
#import "LinkPreview.h"
#import "UserPAInfo.h"
#import "CommentsViewController.h"
#import "Profile_CommentViewController.h"
#import "PostadvertControllerV2.h"

@interface UIActivityCell()

- (NSString*) setNameWithAction;
@end

@implementation UIActivityCell

@synthesize created_time;
@synthesize textContent;
@synthesize linkView;
@synthesize thumbnailView;
@synthesize clapComment;
@synthesize imgAvatar;
@synthesize userName;
@synthesize clapBtn;
@synthesize numClap;
@synthesize commentBtn;
@synthesize quickCommentBtn;
@synthesize botView;
@synthesize isLoadContent;
@synthesize isShowFullText;
@synthesize _content;
@synthesize cellHeight;
@synthesize navigationController;
@synthesize isDidDraw;
@synthesize typeOfCurrentView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - congfig cell
- (void) loadNibFile
{
    if (! isDidDraw) {
        imgAvatar  = (UIImageView*)[self viewWithTag:1];
        userName   = (OHAttributedLabel*)[self viewWithTag:2];
        created_time    = (UILabel*)[self viewWithTag:3];
        textContent       = (OHAttributedLabel*)[self viewWithTag:4];
        textContent.linkColor = [UIColor blueColor];
        textContent.underlineLinks = NO;
        textContent.delegate = self;
        textContent.extendBottomToFit = YES;
        linkView   = (LinkPreview*)[self viewWithTag:5];
        thumbnailView = (UIView*)[self viewWithTag:6];
        botView    =[self viewWithTag:7];
        clapComment= [self viewWithTag:8];
        clapBtn    = (UIButton*)[self viewWithTag:9];
        commentBtn = (UIButton*)[self viewWithTag:10];
        numClap    = (UILabel*)[self viewWithTag:11];
        quickCommentBtn = (UIButton*)[self viewWithTag:12];
        isDidDraw = YES;
//        for (UITapGestureRecognizer *tapGesture in self.gestureRecognizers) {
//            if ([tapGesture isKindOfClass:[UITapGestureRecognizer class]]) {
//                [tapGesture addTarget:self action:@selector(commentButtonClicked:)];
//            }
//            
//        }
    }
}

- (void) updateCellWithContent:(ActivityContent *)content
{
    if (content != nil) {
        _content = nil;
        _content = content;
    }
    
    cellHeight = 0;
    CGRect cellFrame, videoFrame, frame;
    CGSize constraint;
    CGSize size;
    if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            cellFrame = CGRectMake( 0.0, 0.0, 480, 311);
        }else
        {
            cellFrame = CGRectMake( 0.0, 0.0, 1024, 768);
        }
        
    }else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            cellFrame = CGRectMake(0.0, 0.0, 320, 311);
        }else
        {
            cellFrame = CGRectMake( 0.0, 0.0, 768, 1024);
        }
    }
    float leftMarginContent = CELL_CONTENT_MARGIN_LEFT;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        leftMarginContent = CELL_CONTENT_MARGIN_LEFT + cAvartaContentHeight + CELL_MARGIN_BETWEEN_CONTROLL;
    }
    videoFrame = CGRectMake(leftMarginContent, 0.0, cellFrame.size.width - 20 - leftMarginContent - CELL_CONTENT_MARGIN_RIGHT, cYoutubeHeight + (2 * CELL_MARGIN_BETWEEN_IMAGE));//Include left+right magrin
    //[self loadNibFile];
    if (! isLoadContent) {
        
        //[imgAvatar setImageWithURL:[NSURL URLWithString:content.actor_thumbl] placeholderImage:[UIImage imageNamed:@"user_default_thumb.png"]];
        imgAvatar.image = content.actor_thumbl;
        //userName.text = [self setNameWithAction];
        NSString *user_action = [self setNameWithAction];
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:user_action];
        [attrStr setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        [attrStr setTextColor:[UIColor grayColor]];
        [attrStr setTextAlignment:kCTJustifiedTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];
        [attrStr setTextColor:[UIColor colorWithRed:79.0/255 green:178.0/255 blue:187.0/255 alpha:1] range:[user_action rangeOfString:_content.actor_name]];
        [attrStr setTextBold:YES range:[user_action rangeOfString:_content.actor_name]];
        
        userName.attributedText = attrStr;
        //textContent.text = _content.text;
        created_time.text = content.created_time;

        //avatar
        frame = CGRectMake(CELL_CONTENT_MARGIN_LEFT, CELL_CONTENT_MARGIN_TOP, cAvartaContentHeight, cAvartaContentHeight);
        imgAvatar.frame = frame;
        cellHeight = CELL_CONTENT_MARGIN_TOP + imgAvatar.frame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
        //User name; do not resize now
        constraint = CGSizeMake(cellFrame.size.width - 20 - imgAvatar.frame.size.width - imgAvatar.frame.origin.x - CELL_CONTENT_MARGIN_LEFT - CELL_CONTENT_MARGIN_RIGHT - CELL_MARGIN_BETWEEN_CONTROLL, 20000.0f);
        size = [userName.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        //[userName setTextColor:[UIColor blueColor]];
        
        //Created_time
            
        //Fixsize
        
        textContent.text = [UIActivityCell makeTextStringWithContent:content];
        if (![textContent.text isEqualToString:@""]) {
            [textContent setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
            constraint = CGSizeMake(cellFrame.size.width - 20 - leftMarginContent - CELL_CONTENT_MARGIN_RIGHT, 20000.0f);
            size = [textContent.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            frame = CGRectMake(leftMarginContent, cellHeight, size.width, size.height);
            textContent.frame = frame;
            //Set Link here
            cellHeight += size.height + CELL_MARGIN_BETWEEN_CONTROLL;
            textContent.hidden = NO;
        }else {
            textContent.hidden = YES;
        }
        //Add Image
        if (_content.listImages.count) {
            NSLog(@"Images %@", _content.listImages);
            frame = videoFrame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.height = cImageHeight + 2 * CELL_MARGIN_BETWEEN_IMAGE ;
            //[thumbnailView CreateImagesViewWithFrame:frame];
            //new version here
            imageViewCtr = [[SDWebImageRootViewController alloc] initWithFrame:frame andArray:_content.listImages];
            imageViewCtr.navigationController = navigationController;
            [imageViewCtr LoadThumbnail];
            imageViewCtr.view.frame = frame;
            [thumbnailView addSubview:imageViewCtr.view];
            thumbnailView.backgroundColor = self.backgroundColor;
            frame = videoFrame;
            frame.origin.y = cellHeight;
            thumbnailView.frame = frame;
            cellHeight += cImageHeight + 2 * CELL_MARGIN_BETWEEN_IMAGE + CELL_MARGIN_BETWEEN_CONTROLL;
            thumbnailView.hidden = NO;
        }else {
            [_content.listImages removeAllObjects];
            thumbnailView.hidden = YES;
        }
        //add link here
//        if (_content.linkWebsite) {
//            linkView.autoresizesSubviews = YES;
//            frame = videoFrame;
//            [linkView loadContentWithFrame:frame LinkInfo:_content.linkWebsite Type:linkPreviewTypeWebSite];
//            frame.origin.y = cellHeight;
//            linkView.frame = frame;
//            cellHeight += videoFrame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
//            linkView.hidden = NO;
//        }else {
//            linkView.hidden = YES;
//        }
        //Video
        if (content.video) {
            linkView.autoresizesSubviews = YES;
            frame = videoFrame;
            NSLog(@"%@",[_content.video objectForKey:@"url"]);
            [linkView loadContentWithFrame:frame LinkInfo:_content.video Type:linkPreviewTypeYoutube];
            frame.origin.y = cellHeight;
            linkView.frame = frame;
            cellHeight += videoFrame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
            linkView.hidden = NO;
        }else {
            linkView.hidden = YES;
        }
        
        
        //BotView
        frame = botView.frame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            frame.origin.x = leftMarginContent - CELL_CONTENT_MARGIN_LEFT;
            frame.size.width = frame.size.width - (leftMarginContent - CELL_CONTENT_MARGIN_LEFT);
        }
        frame.origin.y = cellHeight;
        botView.frame = frame;
        //ClapComment
        [clapComment setBackgroundColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0]];
        [clapComment.layer setCornerRadius:4.0];
        //- - > clapbtn
        [clapBtn addTarget:self action:@selector(clapButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //- - > Clap num
        NSLog(@"%@", NSStringFromClass([numClap class]));
        numClap.text = [NSString stringWithFormat:@"%d", _content.totalClap];
        //- - > button comments
        
        [commentBtn setTitle:[NSString stringWithFormat:@"%d comments",_content.totalComment] forState:UIControlStateNormal];
        commentBtn.titleLabel.textColor = [UIColor colorWithRed:79.0/255 green:178.0/255 blue:187.0/255 alpha:1];
        //commentBtn.titleLabel.textColor = [UIColor blueColor];
        
        [commentBtn addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //- - > Quick commentBtn
        [quickCommentBtn addTarget:self action:@selector(plusButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        cellHeight += frame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
        isLoadContent = YES;
    }
    else {
        //avatar
        cellHeight = CELL_CONTENT_MARGIN_TOP + imgAvatar.frame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
        // title
        constraint = CGSizeMake(cellFrame.size.width - 20 - imgAvatar.frame.size.width - imgAvatar.frame.origin.x - CELL_CONTENT_MARGIN_LEFT - CELL_CONTENT_MARGIN_RIGHT - CELL_MARGIN_BETWEEN_CONTROLL, 20000.0f);
        size = [created_time.text sizeWithFont:created_time.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        //created_time.frame = CGRectMake(imgAvatar.frame.origin.x + imgAvatar.frame.size.width + CELL_MARGIN_BETWEEN_CONTROLL, 22, size.width, size.height);
        
        if (![textContent.text isEqualToString:@""]) {

            constraint = CGSizeMake(cellFrame.size.width - 20 - leftMarginContent - CELL_CONTENT_MARGIN_RIGHT, 20000.0f);
            size = [textContent.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            frame = CGRectMake(leftMarginContent, cellHeight, size.width, size.height);
            textContent.frame = frame;
            cellHeight += size.height + CELL_MARGIN_BETWEEN_CONTROLL;
        }
        //Add Image
        if ([_content.app_type isEqualToString:@"photos"] && [_content.commnent_type isEqualToString:@"photos"]) {
            frame = videoFrame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            imageViewCtr.view.frame = frame;
            frame = videoFrame;
            frame.origin.y = cellHeight;
            thumbnailView.frame = frame;
            cellHeight += cImageHeight + 2 * CELL_MARGIN_BETWEEN_IMAGE + CELL_MARGIN_BETWEEN_CONTROLL;
        }
//        //add link here
//        if (_content.listLinks.count) {
//            //[linkView reDrawWithFrame:videoFrame];
//            frame = videoFrame;
//            frame.origin.y = cellHeight;
//            linkView.frame = frame;
//            cellHeight += videoFrame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
//        }
//        
        //Video
        if (_content.video) {
            [linkView reDrawWithFrame:videoFrame];
            frame = videoFrame;
            frame.origin.y = cellHeight;
            linkView.frame = frame;
            
            cellHeight += videoFrame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
        }
        
        //BotView
        frame = botView.frame;
        frame.origin.y = cellHeight;
        botView.frame = frame;
        //ClapComment
        
        //- - > Clap num
        
        //- - > button comments
        
        
        //cellHeight += frame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
    }
    //[self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:YES];
    //[self setNeedsDisplay];
    //[self performSelector:@selector(setNeedsDisplay)];
    //[self setNeedsLayout];
    //[self setNeedsDisplay];
    //Update color
    [self updateColor];
    
}

+ (Float32) getCellHeightWithContent:(ActivityContent*)content
{
    if (!content) {
        return 0.0;
    }
   
    Float32 cellHeight = 0;
    CGRect cellFrame, videoFrame, frame;
    CGSize constraint;
    CGSize size;
    if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            cellFrame = CGRectMake( 0.0, 0.0, 480, 311);
        }else
        {
            cellFrame = CGRectMake( 0.0, 0.0, 1024, 768);
        }
        
    }else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            cellFrame = CGRectMake(0.0, 0.0, 320, 311);
        }else
        {
            cellFrame = CGRectMake( 0.0, 0.0, 768, 1024);
        }
    }
    float leftMarginContent = CELL_CONTENT_MARGIN_LEFT;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        leftMarginContent = CELL_CONTENT_MARGIN_LEFT + cAvartaContentHeight + CELL_MARGIN_BETWEEN_CONTROLL;
    }
    videoFrame = CGRectMake(leftMarginContent, 0.0, cellFrame.size.width - 20 - leftMarginContent - CELL_CONTENT_MARGIN_RIGHT, cYoutubeHeight + (2 * CELL_MARGIN_BETWEEN_IMAGE));//Include left+right magrin
    //avatar
    cellHeight = CELL_CONTENT_MARGIN_TOP + cAvartaContentHeight + CELL_MARGIN_BETWEEN_CONTROLL;
    //User name
    //title
    
    constraint = CGSizeMake(cellFrame.size.width - 20 - cAvartaContentHeight - CELL_CONTENT_MARGIN_LEFT - CELL_CONTENT_MARGIN_LEFT - CELL_CONTENT_MARGIN_RIGHT - CELL_MARGIN_BETWEEN_CONTROLL, 20000.0f);
    size = [content.title sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    //[titlePost setTextColor:[UIColor colorWithRed:105.0/255.0 green:92.0/255.0 blue:75.0/225.0 alpha:1.0]];
    
//    Float32 tempHeight = 22 + size.height;
//    
//    cellHeight = cellHeight > tempHeight ? cellHeight : tempHeight;
    //text
    NSString *str = [UIActivityCell makeTextStringWithContent:content];
    if (![str isEqualToString:@""] ) {
        constraint = CGSizeMake(cellFrame.size.width - 20 - leftMarginContent - CELL_CONTENT_MARGIN_RIGHT, 20000.0f);
        size = [str sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        frame = CGRectMake(leftMarginContent, cellHeight, size.width, size.height);
        cellHeight += size.height + CELL_MARGIN_BETWEEN_CONTROLL;
    }
//    //Add Image
    if (content.listImages.count) {
        cellHeight += cImageHeight + 2 * CELL_MARGIN_BETWEEN_IMAGE + CELL_MARGIN_BETWEEN_CONTROLL;
    }
//    //add link here
//    if (content.listLinks.count) {
//        cellHeight += videoFrame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
//    }
    //Video
    if (content.video) {
        cellHeight += videoFrame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
    }
    
    
    //Bot view
    cellHeight += 38 + CELL_MARGIN_BETWEEN_CONTROLL;//botView.frame.size.height = 38
    
    cellHeight += CELL_MARGIN_BETWEEN_CONTROLL;
    
    return cellHeight;
}

- (void) updateView
{
    cellHeight = 0;
    CGRect cellFrame, videoFrame, frame;
    CGSize constraint;
    CGSize size;
    if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            cellFrame = CGRectMake( 0.0, 0.0, 480, 311);
        }else
        {
            cellFrame = CGRectMake( 0.0, 0.0, 1024, 768);
        }
        
    }else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            cellFrame = CGRectMake(0.0, 0.0, 320, 311);
        }else
        {
            cellFrame = CGRectMake( 0.0, 0.0, 768, 1024);
        }
    }
    float leftMarginContent = CELL_CONTENT_MARGIN_LEFT;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        leftMarginContent = CELL_CONTENT_MARGIN_LEFT + cAvartaContentHeight + CELL_MARGIN_BETWEEN_CONTROLL;
    }
    videoFrame = CGRectMake(leftMarginContent, 0.0, cellFrame.size.width - 20 - leftMarginContent - CELL_CONTENT_MARGIN_RIGHT, cYoutubeHeight + (2 * CELL_MARGIN_BETWEEN_IMAGE));//Include left+right magrin
    //avatar
    
    //Created_time
    cellHeight = CELL_CONTENT_MARGIN_TOP + imgAvatar.frame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
    constraint = CGSizeMake(cellFrame.size.width - 20 - imgAvatar.frame.size.width - imgAvatar.frame.origin.x - CELL_CONTENT_MARGIN_LEFT - CELL_CONTENT_MARGIN_RIGHT - CELL_MARGIN_BETWEEN_CONTROLL, 20000.0f);
    size = [created_time.text sizeWithFont:created_time.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    created_time.frame = CGRectMake(3 + cAvartaContentHeight + CELL_MARGIN_BETWEEN_CONTROLL, 22, size.width, size.height);
    
    //User name; do not resize now
    //text
    if (![textContent.text isEqualToString:@""]) {
        if (self.isShowFullText) {
            textContent.text = [UIActivityCell makeTextStringWithContent:_content];
        }
        constraint = CGSizeMake(cellFrame.size.width - 20 - leftMarginContent - CELL_CONTENT_MARGIN_RIGHT, 20000.0f);
        size = [textContent.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        frame = CGRectMake(leftMarginContent, cellHeight, size.width, size.height);
        textContent.frame = frame;
        cellHeight += size.height + CELL_MARGIN_BETWEEN_CONTROLL;
    }
    //Add Image
    if (_content.listImages.count) {
        frame = thumbnailView.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        imageViewCtr.view.frame = frame;
        frame = videoFrame;
        frame.origin.y = cellHeight;
        thumbnailView.frame = frame;
        cellHeight += cImageHeight + 2 * CELL_MARGIN_BETWEEN_IMAGE + CELL_MARGIN_BETWEEN_CONTROLL;
    }
//    //add link here
//    if (_content.listLinks.count) {
//        //[linkView reDrawWithFrame:videoFrame];
//        frame = videoFrame;
//        frame.origin.y = cellHeight;
//        linkView.frame = frame;
//        cellHeight += videoFrame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
//    }
    //Video
    if (_content.video) {
        [linkView reDrawWithFrame:videoFrame];
        frame = videoFrame;
        frame.origin.y = cellHeight;
        linkView.frame = frame;
        
        cellHeight += videoFrame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
    }
    
    
    //BotView
    frame = botView.frame;
    frame.origin.y = cellHeight;
    botView.frame = frame;
    //ClapComment
    
    //- - > Clap num
    
    //- - > button comments
    
    
    //cellHeight += frame.size.height + CELL_MARGIN_BETWEEN_CONTROLL;
}

- (void) clapButtonClicked:(id) sender
{
    
    
    UIActionSheet *uias = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:_content.isClap ? @"Unclap" : @"Clap", nil];
    
    [uias showInView:self];
    uias = nil;
}

- (void) commentButtonClicked:(id) sender
{
    if (typeOfCurrentView == 1) {
        @try {
            
            [self.commentViewCtr.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.commentViewCtr.tableView numberOfRowsInSection:1] - 1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: Try to scroll to bottom");
        }
        @finally {
            
        }
    }
    else
    {
        NSLog(@"%@", self.superview);
        if (_content.totalComment == 0) {
            //return;
        }
        Profile_CommentViewController *commentViewCtr = [[Profile_CommentViewController alloc]initWithActivityCell:self];
        //[self addCommentsListenner];
        
        [navigationController pushViewController: commentViewCtr animated:YES];
        // = nil;
        commentViewCtr = nil;
    }
    
}

- (void) plusButtonClicked
{
    if (typeOfCurrentView == 1) {
        @try {
            [(UITextView*) self.commentViewCtr.textBox becomeFirstResponder];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    
    }
//    //navigationController.navigationBarHidden =YES;
//    AddCommentViewController *addCommand = [[AddCommentViewController alloc]init];
//    addCommand.content = self.content;
//    [self addCommentsListenner];
//    [navigationController presentModalViewController:addCommand animated:NO];
//    // = nil;
//    addCommand = nil;
}

- (NSString*) setNameWithAction
{
    NSString *_userName = _content.actor_name;
    NSString *actionDescription = @" ";
    //Status update: no need to show
//    if ([_content.app_type isEqualToString:@"profile"] && [_content.commnent_type isEqualToString:@"profile.status"]) {
//        NSString *gender = @"his ";
//        if ([_content.actor_gender isKindOfClass:[NSString class]]) {
//            if ([_content.actor_gender isEqualToString:@"male"]) {
//                gender = @"his ";
//            }
//            if ([_content.actor_gender isEqualToString:@"female"]) {
//                gender = @"her ";
//            }
//        }
//        actionDescription = [NSString stringWithFormat:@" updated %@status", gender];
//    }
    
    return [_userName stringByAppendingString:actionDescription];
}

-(void) updateColor
{
    
    NSURL *url = [[NSURL alloc]initWithString:@"activity:url"];
    NSURL *urlUerProfile = [[NSURL alloc]initWithString:[NSString stringWithFormat: @"localStroff://user__%d", _content.actor_id]];
    if ([_content.activity_type isEqualToString:@"activity"]) {
        if ([_content.app_type isEqualToString:@"profile"] && [_content.commnent_type isEqualToString:@"profile.avatar.upload"]) {
            
            [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
            return;
        }

        //add new status
        if ([_content.app_type isEqualToString:@"profile"] && [_content.commnent_type isEqualToString:@"profile.status"]) {
            //nothing to set color
            return;
        }
        //add friend
        if ([_content.app_type isEqualToString:@"friends"] && [_content.commnent_type isEqualToString:@""]) {
            NSString *actor2_name =@"";
            if (_content.actor_2.count) {
                NSDictionary *actor_2 = [_content.actor_2 objectAtIndex:0];
                actor2_name = [actor_2 objectForKey:@"name"];
            }
            [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
            [textContent addCustomLink:url inRange:[textContent.text rangeOfString:actor2_name]];
        }

        //add photo
        if ([_content.app_type isEqualToString:@"photos"] && [_content.commnent_type isEqualToString:@"photos"]) {
            if ([_content.commentContent isEqualToString:@""]) {
                [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
            }
        }
        
        //add photo into album
        if ([_content.app_type isEqualToString:@"photos"] && [_content.commnent_type isEqualToString:@"photos.album"]) {
            [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
            [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.target_name options:NSBackwardsSearch]];
        }
        // Add Event
        if ([_content.app_type isEqualToString:@"events"] && [_content.commnent_type isEqualToString:@"groups.event"])  {
            [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
            [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.target_name options:NSBackwardsSearch]];
        }
        //Commented on an event
        if ([_content.app_type isEqualToString:@"events.wall"] && [_content.commnent_type isEqualToString:@"events.wall"])  {
            [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
            [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.target_name options: NSBackwardsSearch]];
            return;
        }

        // add video
        if ([_content.app_type isEqualToString:@"videos"] && [_content.commnent_type isEqualToString:@"videos"])  {
            if ([_content.commentContent isEqualToString:@""]) {
                [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
            }
        }
        // comment on a photo
        if ([_content.app_type isEqualToString:@"photos"] && [_content.commnent_type isEqualToString:@"photos.wall.create"])
        {
            [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
            return;
        }

    }
    //Wall
    if ([_content.activity_type isEqualToString:@"wall"]) {
        //comment on status
        if ([_content.commnent_type isEqualToString:@"profile.status"] || YES) {
            if ([_content.target_author_name isKindOfClass:[NSString class]]) {
                if (_content.target_author_name != @"") {
                    if (_content.actor_id == _content.target_author_id) {
                        if ([_content.actor_gender isKindOfClass:[NSString class]]) {
                        }
                        else
                        {
                            [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.target_author_name options:NSBackwardsSearch]];
                        }
                    }
                    else
                        //khac user, kiem tra voi regited user - current user
                        if (_content.target_author_id != [[UserPAInfo sharedUserPAInfo] registrationID]) {
                            [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.target_author_name options:NSBackwardsSearch]];
                        }
                        
                }
            }
            [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
        }
    }

#warning incomplete function
    [textContent addCustomLink:urlUerProfile inRange:[textContent.text rangeOfString:_content.actor_name]];
    [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.target_name options: NSBackwardsSearch]];

}

- (void) insertClap
{
//    insertLike($target_id, $comment_type, $user_id)
    
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    functionName = @"insertLike";
    paraNames = [NSArray arrayWithObjects:@"target_id", @"comment_type", @"user_id",nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", _content.target_id], _content.commnent_type, [NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];

}


+ (NSString*) makeTextStringWithContent:(ActivityContent*)content
{
    NSString *actionStr =@"";
    if ([content.activity_type isEqualToString:@"activity"]) {
        
        //upload new avatar profile.avatar.upload
        if ([content.app_type isEqualToString:@"profile"] && [content.commnent_type isEqualToString:@"profile.avatar.upload"]) {
#warning not complete Mtk
            NSString *gender = @"his ";
            if ([content.actor_gender isKindOfClass:[NSString class]]) {
                
                if ([content.actor_gender isEqualToString:@"male"]) {
                    gender = @"his ";
                }
                if ([content.actor_gender isEqualToString:@"female"]) {
                    gender = @"her ";
                }
            }
            actionStr = [NSString stringWithFormat:@"%@ updated %@ avatar", content.actor_name, gender];
            return actionStr;
        }
        //add new status
        if ([content.app_type isEqualToString:@"profile"] && [content.commnent_type isEqualToString:@"profile.status"]) {
            
            actionStr = [NSString stringWithFormat:@"%@", content.commentContent];
            return actionStr;
        }
        //add friend
        if ([content.app_type isEqualToString:@"friends"] && [content.commnent_type isEqualToString:@""]) {
            NSString *actor2_name =@"";
            if (content.actor_2.count) {
                NSDictionary *actor_2 = [content.actor_2 objectAtIndex:0];
                actor2_name = [actor_2 objectForKey:@"name"];
            }
            actionStr = [NSString stringWithFormat:@"%@ and %@ are now friends", content.actor_name, actor2_name ];
            return actionStr;
        }
        //add photo
        if ([content.app_type isEqualToString:@"photos"] && [content.commnent_type isEqualToString:@"photos"] ) {
            if ([content.commentContent isEqualToString:@""]) {
                actionStr = [NSString stringWithFormat:@"%@ added a new photo", content.actor_name];
            }else
                actionStr = content.commentContent;
            return actionStr;
        }
        
        //add photo into album
        if ([content.app_type isEqualToString:@"photos"] &&  [content.commnent_type isEqualToString:@"photos.album"]) {
            actionStr = [NSString stringWithFormat:@"%@ added a new photo into %@ album", content.actor_name, content.target_name];
            return actionStr;
        }
        
        // Add Event
        if ([content.app_type isEqualToString:@"events"] && [content.commnent_type isEqualToString:@"groups.event"])  {
            if ([content.target_name isKindOfClass:[NSString class]]) {
                if (content.target_name != @"") {
                    
                }else
                    content.target_name = @" ";
            }else
                content.target_name = @" ";
            actionStr = [NSString stringWithFormat:@"%@ added a new event: %@", content.actor_name, content.target_name];
            
            return actionStr;
        }
        //Commented on an event
        if ([content.app_type isEqualToString:@"events.wall"] && [content.commnent_type isEqualToString:@"events.wall"])  {
            if ([content.target_name isKindOfClass:[NSString class]]) {
                if (content.target_name != @"") {
                    
                }else
                    content.target_name = @" ";
            }else
                content.target_name = @" ";
            actionStr = [NSString stringWithFormat:@"%@ commented on %@ event", content.actor_name, content.target_name];
            
            return actionStr;
        }

        // Add Video
        if ([content.app_type isEqualToString:@"videos"] && [content.commnent_type isEqualToString:@"videos"])  {
            if ([content.commentContent isEqualToString:@""]) {
                actionStr = [NSString stringWithFormat:@"%@ added a video", content.actor_name];
            }else
                actionStr = content.commentContent;
            
            return actionStr;
        }
        // comment on a photo
        if ([content.app_type isEqualToString:@"photos"] && [content.commnent_type isEqualToString:@"photos.wall.create"])
        {
            actionStr = [NSString stringWithFormat:@"%@ commented on a photo: %@", content.actor_name, content.commentContent];
        }
    }
    //Wall
    if ([content.activity_type isEqualToString:@"wall"]) {
        //comment on status
        if ([content.commnent_type isEqualToString:@"profile.status"] || YES) {
                NSString *target = @"";
                if ([content.target_author_name isKindOfClass:[NSString class]]) {
                    if (content.target_author_name != @"") {
                        if (content.actor_id == content.target_author_id) {
                            if ([content.actor_gender isKindOfClass:[NSString class]]) {
                                target = [NSString stringWithFormat:@"%@'s", content.target_author_name];
                                if ([content.actor_gender isEqualToString:@"male"]) {
                                    target = @"his ";
                                }
                                if ([content.actor_gender isEqualToString:@"female"]) {
                                    target = @"her ";
                                }
                            }
                            else
                            {
                                target = [NSString stringWithFormat:@"%@'s", content.actor_name];
                            }
                        }
                        else
                            //khac user, kiem tra voi regited user - current user
                            if (content.target_author_id != [[UserPAInfo sharedUserPAInfo] registrationID]) {
                                target = [NSString stringWithFormat:@"%@'s",content.target_author_name];
                            }else
                                target = @"your ";

                            
                    }
                }else
                    target = @"a ";
                actionStr = [NSString stringWithFormat:@"%@ commented on %@ %@: %@" ,content.actor_name, target, content.target_name, content.commentContent];
                return actionStr;
            }
    }
#warning incomplete function
    if ([content.target_name isKindOfClass:[NSString class]]) {
        if (content.target_name != @"") {
            
        }else
            content.target_name = @" ";
    }else
        content.target_name = @" ";
    if ([content.commentContent isEqualToString:@""] || ![content.commentContent isKindOfClass:[NSString class]]) {
        actionStr = [NSString stringWithFormat:@"%@ %@ %@", content.actor_name, content.actionStringFromServer, content.target_name];
    }else
        actionStr = [NSString stringWithFormat:@"%@ %@ %@: %@", content.actor_name, content.actionStringFromServer, content.target_name, content.commentContent];
    
    return actionStr;
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)uias clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // user pressed "Cancel"
    if(buttonIndex == [uias cancelButtonIndex]) return;
    // user pressed "Clap"/"Unclap"
    //Upadte server
    
    //Update local
    _content.isClap = !_content.isClap;
    if (_content.isClap) {
        _content.totalClap += 1;
        [self insertClap];
    }else {
        _content.totalClap -= 1;
    }
    [self refreshClapCommentsView];
    if (typeOfCurrentView == 1) {
        if ([self.superview isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView*) self.superview;
            [tableView reloadData];
        }
    }
}
#pragma mark OHAttributedLabelDelegate

-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    
    [[NSUserDefaults standardUserDefaults] setURL:linkInfo.URL forKey:@"openURL"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openURL" object:nil];
    return NO;
}

#pragma mark - Notification

- (void) refreshClapCommentsView
{
    if (isDidDraw) {
        numClap.text = [NSString stringWithFormat:@"%d", _content.totalClap];
        [commentBtn setTitle:[NSString stringWithFormat:@"%d comments",_content.totalComment] forState:UIControlStateNormal];
    }
    
    
}


@end
