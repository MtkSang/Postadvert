//
//  HBBResultCellData.h
//  Stroff
//
//  Created by Ray on 2/7/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CredentialInfo.h"
@interface HBBResultCellData : NSObject

@property (nonatomic, strong) NSString *timeCreated;
@property (nonatomic, strong) NSString *titleHDB;
@property (nonatomic )        NSInteger numOfBedRooms;
@property (nonatomic)         NSInteger hdbID;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) CredentialInfo *userInfo;
@property (nonatomic, strong) NSMutableArray *paraNames;
@property (nonatomic, strong) NSMutableArray *paraValues;
@property (nonatomic, strong) NSMutableArray *array_fixtures_fittings;
@property (nonatomic, strong) NSMutableArray *array_other_features;
@property (nonatomic, strong) NSMutableArray *array_amenities;
@property (nonatomic, strong) NSMutableArray *arry_restrictions;

- (id) initWithItemName:(NSString*)itemName;
- (void) parseFixtures_fittingAndFeatures;

@end
