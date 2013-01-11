//
//  FlagViewController.h
//  PostAdvert11
//
//  Created by Ray Mtk on 25/4/12.
//  Copyright (c) 2012 ray@futureworkz.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlagViewControllerDelegate; 

@interface FlagViewController : UITableViewController
{
    NSMutableArray * listFlags;
    UITableViewCell *currentSeleted;
}

@property (nonatomic, weak) id <FlagViewControllerDelegate> delegate;
@end


@protocol FlagViewControllerDelegate <NSObject>

-(void) didSelectCountryWithCpuntryID:(NSInteger) countryID countryName: (NSString*) countryName;

@end
