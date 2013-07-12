//
//  HDBItemCollectionViewLayout.h
//  Stroff
//
//  Created by Ray on 7/8/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
UIKIT_EXTERN NSString * const HDBItemCollectionViewLayoutItemTitleKind;
@interface HDBItemCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) CGFloat titleHeight;
@property (nonatomic) CGRect viewInRect;

@end
