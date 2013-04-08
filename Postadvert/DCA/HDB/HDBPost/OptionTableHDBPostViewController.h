//
//  OptionTableHDBPostViewController.h
//  Stroff
//
//  Created by Ray on 4/8/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionTableHDBPostViewController : UITableViewController

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic)         UITableViewCellAccessoryType cellAccessoryType ;

@end
