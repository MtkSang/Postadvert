//
//  HDBPostViewController.h
//  Stroff
//
//  Created by Ray on 3/26/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIPlaceHolderTextView;
@class OptionTableHDBPostViewController;
@interface HDBPostViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    NSDictionary *sourceData;
    NSMutableArray *allKeys;
    UITapGestureRecognizer *tapGesture;
    UIView *overlay;
    NSIndexPath *currentIndexPath;
    UIView *activeForm;
    OptionTableHDBPostViewController *optionTableViewCtr;
}
@property (weak, nonatomic) IBOutlet UILabel *inputTitle;
- (IBAction)clickedOnInputForm:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *inputForm;
@property (strong, nonatomic) IBOutlet UIView *inputTextForm;
@property (weak, nonatomic) IBOutlet UIView *boundForm;
@property (weak, nonatomic) IBOutlet UILabel *titleInputTextForm;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *phTextView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIView *overlay;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellHDBPostPreviewAd;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellHDBPostSubmit;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
