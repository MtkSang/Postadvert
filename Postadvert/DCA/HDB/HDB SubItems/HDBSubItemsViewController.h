//
//  HDBSubItemsViewController.h
//  Stroff
//
//  Created by Ray on 7/8/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HDBItemCollectionViewLayout;

@interface HDBSubItemsViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{

}

@property (nonatomic, strong) NSMutableArray *listItems;
@property (nonatomic, strong) NSString *itemName;
@property (weak, nonatomic) IBOutlet HDBItemCollectionViewLayout *HDBSubItemFlowLayout;

- (id)initWithItems:(NSMutableArray *)items;
- (CGSize)getSizeToFit;
- (void) setupForItemName:(NSString*)itemName_;
- (void)setTitle:(NSString *)title;
@end
