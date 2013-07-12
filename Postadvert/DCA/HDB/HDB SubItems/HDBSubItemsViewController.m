//
//  HDBSubItemsViewController.m
//  Stroff
//
//  Created by Ray on 7/8/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HDBSubItemsViewController.h"
#import "HDBSubItemImageCollectionViewCell.h"
#import "HDBSubItemTitleCollectionReusebleView.h"
#import "HDBItemCollectionViewLayout.h"
#import "Constants.h"
static NSString * const ItemCellIdentifier = @"ItemCell";
static NSString * const ItemTitleIdentifier = @"ItemTitle";
@interface HDBSubItemsViewController ()

@end

@implementation HDBSubItemsViewController


- (id)initWithItems:(NSMutableArray *)items
{
    self = [super initWithNibName:@"HDBSubItemsViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.listItems = [[NSMutableArray alloc]initWithArray:items];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.listItems = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.HDBSubItemFlowLayout.viewInRect = CGRectMake(0, 0, cMaxLeftView, 146);
    [self.collectionView registerClass:[HDBSubItemImageCollectionViewCell class]
            forCellWithReuseIdentifier:ItemCellIdentifier];
    [self.collectionView registerClass:[HDBSubItemTitleCollectionReusebleView class]
            forSupplementaryViewOfKind:HDBItemCollectionViewLayoutItemTitleKind
                   withReuseIdentifier:ItemTitleIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setHDBSubItemFlowLayout:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect frame = self.view.frame;
    frame.size.height = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    self.view.frame = frame;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.listItems.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HDBSubItemImageCollectionViewCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:ItemCellIdentifier forIndexPath:indexPath];
    //NSArray *dataInfo = [self.listItems objectAtIndex:indexPath.section * numCol + indexPath.row];
    itemCell.imageView.image = [UIImage imageNamed: [[_listItems objectAtIndex:indexPath.section] objectAtIndex:0]];
    itemCell.selectedBackgroundView = [[UIView alloc]initWithFrame:itemCell.bounds];
    itemCell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:93.0/255.0 green:175.0/255.0 blue:185.0/255.0 alpha:1.0f];
    return itemCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    HDBSubItemTitleCollectionReusebleView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:ItemTitleIdentifier forIndexPath:indexPath];
    [titleView.titleLabel setText:[[_listItems objectAtIndex:indexPath.section] objectAtIndex:1]];
    return titleView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HDBSubItemTitleCollectionReusebleView *titleView = (HDBSubItemTitleCollectionReusebleView*)[self collectionView:collectionView viewForSupplementaryElementOfKind:ItemTitleIdentifier atIndexPath:indexPath];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:titleView.titleLabel.text forKey:@"itemName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showDetailFromSubView" object:nil userInfo:dict];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
////    cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
//}
//
//- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
////    cell.contentView.backgroundColor = nil;
//}
#pragma mark - implement

- (CGSize)getSizeToFit
{
    return self.collectionView.collectionViewLayout.collectionViewContentSize;
}

- (void) setupForItemName:(NSString*)itemName_
{
    NSRange rang = [itemName_ rangeOfString:@"HDB"];
    if (rang.length) {
        self.listItems = [[NSMutableArray alloc]initWithObjects:
                          [NSArray arrayWithObjects: @"HDB_Search.png", @"HDB Search", nil],
                          [NSArray arrayWithObjects: @"HDB_Q-A.png", @"HDB Q&A", nil], nil];
    }
    rang = [itemName_ rangeOfString:@"Condos"];
    if (rang.length) {
        self.listItems = [[NSMutableArray alloc]initWithObjects:
                          [NSArray arrayWithObjects: @"Condos_Search.png", @"Condos Search", nil],
                          [NSArray arrayWithObjects: @"HDB_Q-A.png", @"Condos Q&A", nil], nil];
    }
    rang = [itemName_ rangeOfString:@"Landed Property"];
    if (rang.length) {
        self.listItems = [[NSMutableArray alloc]initWithObjects:
                          [NSArray arrayWithObjects: @"Landed-Property_Search.png", @"Landed Property Search", nil],
                          [NSArray arrayWithObjects: @"HDB_Q-A.png", @"Landed Property Q&A", nil], nil];
    }
    rang = [itemName_ rangeOfString:@"Rooms For Rent"];
    if (rang.length) {
        self.listItems = [[NSMutableArray alloc]initWithObjects:
                          [NSArray arrayWithObjects: @"Room-For-Rent_Search.png", @"Rooms For Rent Search", nil],
                          [NSArray arrayWithObjects: @"HDB_Q-A.png", @"Rooms For Rent Q&A", nil], nil];
    }

    self.view.hidden = NO;
    [self.collectionView reloadData];
}
@end
