//
//  HBBResultCellData.m
//  Stroff
//
//  Created by Ray on 2/7/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HBBResultCellData.h"

@implementation HBBResultCellData

- (id) init
{
    self = [super init];
    if (self) {
        self.paraNames = [[NSMutableArray alloc]initWithObjects:@"id",
                          @"status",
                          @"block_no",
                          @"street_name",
                          @"property_type",
                          @"unit_level",
                          @"hdb_estate",
                          @"size",
                          @"bedrooms",
                          @"washroom",
                          @"furnishing",
                          @"building_completion",
                          @"created",
                          @"price",
                          @"valuation_price",
                          @"monthly_rental",
                          @"lease_term",
                          @"thumb",
                          nil];
                          
        self.paraValues = [[NSMutableArray alloc]init];
    }
    
    return self;
}

@end
