//
//  CommentsViewController.h
//  Postadvert
//
//  Created by Mtk Ray on 6/5/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIPostCell;
@class UIPlaceHolderTextView;
@class PostCellContent;
@interface CommentsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    NSMutableArray *listComments;
    UIPostCell *actiCell;
    UIPostCell *dataCellFromMain;
    UITableView *actiCellSuperView;
    NSInteger postID;
    PostCellContent *cellContent;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *botView;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *textBox;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic)   BOOL    showKeyboard;

- (id)initWithPostCell:(UIPostCell *)cell;
- (id)initWithPostID:(NSInteger)_postID;
- (IBAction)btnSendClicked:(id)sender;
- (void) clap_UnClapPost:(id)sender;

@end
