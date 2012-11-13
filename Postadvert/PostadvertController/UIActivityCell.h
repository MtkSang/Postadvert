//
//  UIActivityCell.h
//  Postadvert
//
//  Created by Ray on 8/29/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "OHAttributedLabel.h"
@class ActivityContent;
@class LinkPreview;
@class ThumbnailPostCellView;
@class SDWebImageRootViewController;
@class Profile_CommentViewController;
@interface UIActivityCell : UITableViewCell <UIActionSheetDelegate, OHAttributedLabelDelegate>//< UITextViewDelegate>
{
    ActivityContent *_content;
//    IBOutlet UILabel *created_time;
//    IBOutlet OHAttributedLabel *textContent;
//    IBOutlet UIView *clapComment;
//    IBOutlet LinkPreview *linkView;
//    IBOutlet UIView *thumbnailView;
//    IBOutlet UIImageView *imgAvatar;
//    IBOutlet OHAttributedLabel *userName;
//    IBOutlet UILabel *numClap;
//    IBOutlet UIButton *clapBtn;
//    IBOutlet UIButton *commentBtn;
//    IBOutlet UIButton *quickCommentBtn;
//    IBOutlet UIView *botView;

    //internal var

    SDWebImageRootViewController *imageViewCtr;
    BOOL isDidDraw;
    BOOL isLoadContent;
}
@property (nonatomic, strong) IBOutlet UILabel *created_time;
@property (nonatomic, strong) IBOutlet OHAttributedLabel *textContent;
@property (nonatomic, strong) IBOutlet LinkPreview *linkView;
@property (nonatomic, strong) IBOutlet UIView *thumbnailView;
@property (nonatomic, strong) IBOutlet UIView *clapComment;
@property (nonatomic, strong) IBOutlet UIImageView *imgAvatar;
@property (nonatomic, strong) IBOutlet OHAttributedLabel *userName;
@property (nonatomic, strong) IBOutlet UIButton *clapBtn;
@property (nonatomic, strong) IBOutlet UILabel *numClap;
@property (nonatomic, strong) IBOutlet UIButton *commentBtn;
@property (nonatomic, strong) IBOutlet UIButton *quickCommentBtn;
@property (nonatomic, strong) IBOutlet UIView *botView;
@property (nonatomic) BOOL isLoadContent;
@property (nonatomic) BOOL isShowFullText;
@property (nonatomic)         int typeOfCurrentView;
@property (nonatomic, strong) ActivityContent *_content;
@property (nonatomic) Float32 cellHeight;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic)         BOOL isDidDraw;
@property (nonatomic, weak)   Profile_CommentViewController *commentViewCtr;

- (void) updateCellWithContent:(ActivityContent *)content;
- (void) clapButtonClicked:(id) sender;
- (void) plusButtonClicked;
- (void) commentButtonClick:(id) sender;
- (void) loadNibFile;
- (void) updateView;
- (void) refreshClapCommentsView;
+ (Float32) getCellHeightWithContent:(ActivityContent*)content;
@end

