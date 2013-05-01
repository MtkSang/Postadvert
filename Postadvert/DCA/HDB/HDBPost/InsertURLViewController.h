//
//  InsertURLViewController.h
//  Stroff
//
//  Created by Ray on 4/18/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIPlaceHolderTextView;
@interface InsertURLViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIWebViewDelegate>
{
    id delegate;
    NSMutableArray *_listCell;
}
@property (strong, nonatomic) NSString *keyForTitle;
@property (nonatomic, strong) IBOutlet id delegate;
@property (nonatomic, strong) NSMutableArray *listURLs;
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *phTextbox;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)btnSendClicked:(id)sender;
@end

@interface NSObject (InsertURLViewControllerDelegate)

- (void) InsertURLsDidDisappear;

@end