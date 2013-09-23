//
//  Q_ACellDetailViewController.h
//  Stroff
//
//  Created by Ray on 9/12/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
enum Q_ADetailType
{
    Q_ADetailTypePostNewQuestion = 0,
    Q_ADetailTypeViewDetail = 1
};
@class MBProgressHUD;

@interface Q_ACellDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>
{
    MBProgressHUD *mpLoadData;
    enum Q_ADetailType typeDetail;
    NSMutableArray *listAnwser;
    NSDictionary *cellData;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *textBox;

- (id) initWithData:(NSDictionary*)data andType:(enum Q_ADetailType)type;

- (IBAction)btnSendClicked:(id)sender;
@end
