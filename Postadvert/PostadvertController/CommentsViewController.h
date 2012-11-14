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

@interface CommentsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    NSMutableArray *listComments;
    UIPostCell *actiCell;
    UIPostCell *dataCellFromMain;
    UITableView *actiCellSuperView;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *botView;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *textBox;

- (id)initWithPostCell:(UIPostCell *)cell;
- (IBAction)btnSendClicked:(id)sender;

@end
