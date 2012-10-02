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

@interface UIActivityCell()

- (void) refreshClapCommentsView;
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
        created_time    = (OHAttributedLabel*)[self viewWithTag:3];
        textContent       = (OHAttributedLabel*)[self viewWithTag:4];
        textContent.linkColor = [UIColor blueColor];
        textContent.underlineLinks = NO;
        //textContent.delegate = self;
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
        if ([_content.app_type isEqualToString:@"photos"] && ([_content.commnent_type isEqualToString:@"photos"] || [_content.commnent_type isEqualToString:@"photos.album"])) {
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
        
        [commentBtn addTarget:self action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
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
        created_time.frame = CGRectMake(imgAvatar.frame.origin.x + imgAvatar.frame.size.width + CELL_MARGIN_BETWEEN_CONTROLL, 22, size.width, size.height);
        //[titlePost setTextColor:[UIColor colorWithRed:105.0/255.0 green:92.0/255.0 blue:75.0/225.0 alpha:1.0]];
        
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
    created_time.frame = CGRectMake(imgAvatar.frame.origin.x + imgAvatar.frame.size.width + CELL_MARGIN_BETWEEN_CONTROLL, 22, size.width, size.height);
    //[titlePost setTextColor:[UIColor colorWithRed:105.0/255.0 green:92.0/255.0 blue:75.0/225.0 alpha:1.0]];
    
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

- (void) commentButtonClick:(id) sender
{
//    if (_content.listComments.count == 0) {
//        return;
//    }
//    [self addCommentsListenner];
//    CommentsViewController *commentViewCtr = [[CommentsViewController alloc]init];
//    commentViewCtr.content = _content;
//    //[self addCommentsListenner];
//    [navigationController pushViewController: commentViewCtr animated:YES];
//    // = nil;
//    commentViewCtr = nil;
}

- (void) plusButtonClicked
{
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
    //add new status
    NSURL *url = [[NSURL alloc]initWithString:@"activity:url"];
    if ([_content.app_type isEqualToString:@"profile"] && [_content.commnent_type isEqualToString:@"profile.status"]) {
        //nothing to set color
        return;
    }
    //add photo
    if ([_content.app_type isEqualToString:@"photos"] && [_content.commnent_type isEqualToString:@"photos"]) {
        [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.actor_name]];
    }
    
    //add photo into album
    if ([_content.app_type isEqualToString:@"photos"] && [_content.commnent_type isEqualToString:@"photos.album"]) {
        [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.actor_name]];
        [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.target_name options:NSBackwardsSearch]];
    }
    // Add Event
    if ([_content.app_type isEqualToString:@"events"] && [_content.commnent_type isEqualToString:@"groups.event"])  {
        [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.actor_name]];
        [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.target_name options:NSBackwardsSearch]];
    }
    
    if ([_content.app_type isEqualToString:@"videos"] && [_content.commnent_type isEqualToString:@"videos"])  {
        if ([_content.commentContent isEqualToString:@""]) {
            [textContent addCustomLink:url inRange:[textContent.text rangeOfString:_content.actor_name]];
        }
    }

}



+ (NSString*) makeTextStringWithContent:(ActivityContent*)content
{
    NSString *actionStr =@"";
    //add new status
    if ([content.app_type isEqualToString:@"profile"] && [content.commnent_type isEqualToString:@"profile.status"]) {
        
        actionStr = [NSString stringWithFormat:@"%@", content.commentContent];
        return actionStr;
    }
    //add photo
    if ([content.app_type isEqualToString:@"photos"] && [content.commnent_type isEqualToString:@"photos"] ) {
        actionStr = [NSString stringWithFormat:@"%@ add new photo", content.actor_name];
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
    // Add Video
    if ([content.app_type isEqualToString:@"videos"] && [content.commnent_type isEqualToString:@"videos"])  {
        if ([content.commentContent isEqualToString:@""]) {
            actionStr = [NSString stringWithFormat:@"%@ added a video", content.actor_name];
        }else
            actionStr = content.commentContent;
        
        return actionStr;
    }

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
    }else {
        _content.totalClap -= 1;
    }
    [self refreshClapCommentsView];
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
