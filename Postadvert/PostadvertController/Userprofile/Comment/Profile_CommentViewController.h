//
//  Profile_CommentViewController.h
//  Stroff
//
//  Created by Nguyen Ngoc Sang on 11/6/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIPlaceHolderTextView;
@class UIActivityCell;
@interface Profile_CommentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    NSMutableArray *listComments;
    UIActivityCell *actiCell;
    UIActivityCell *dataCellFromMain;
    UITableView *actiCellSuperView;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *botView;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *textBox;
@property (nonatomic)   BOOL showKeyboard;

- (id)initWithActivityCell:(UIActivityCell*) cell;
- (IBAction)btnSendClicked:(id)sender;

@end
