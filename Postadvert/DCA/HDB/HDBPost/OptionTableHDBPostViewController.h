//
//  OptionTableHDBPostViewController.h
//  Stroff
//
//  Created by Ray on 4/8/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionTableHDBPostViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic)         UITableViewCellAccessoryType cellAccessoryType ;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;

@end
