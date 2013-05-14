//
//  HBBResultCellData.m
//  Stroff
//
//  Created by Ray on 2/7/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HBBResultCellData.h"

@implementation HBBResultCellData
//condition,
//"ad_owner",
//"size_m",
- (id) init
{
    self = [super init];
    if (self) {
        self.paraNames = [[NSMutableArray alloc]initWithObjects:
                          @"id",
                          @"status",
                          @"block_no",
                          @"street_name",
                          @"property_type",
                          @"description",
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
                          @"psf",
                          @"ad_owner",
                          @"total_comments",
                          @"clap_info",
                          @"total_views",
                          @"other_features",
                          @"fixtures_fittings",
                          @"images",
                          @"videos",
                          @"websites",
                          nil];
        
        self.paraValues = [[NSMutableArray alloc]init];
        self.array_fixtures_fittings = [[NSMutableArray alloc]init];
        self.array_other_features = [[NSMutableArray alloc]init];
        self.images = [[NSMutableArray alloc]init];
    }
    
    return self;
}
- (void) parseFixtures_fittingAndFeatures{
    NSInteger index;
    if (self.paraValues.count != self.paraNames.count) {
        return;
    }
    id objectValue;
    index = [self.paraNames indexOfObject:@"other_features"];
    if (index != NSIntegerMax) {
        objectValue = [self.paraValues objectAtIndex:index];
        if (![objectValue isEqualToString:@""] && [objectValue isKindOfClass:[NSString class]]) {
            objectValue = [objectValue stringByReplacingOccurrencesOfString:@", " withString:@","];
            self.array_other_features = [[NSMutableArray alloc]initWithArray:[objectValue componentsSeparatedByString:@","]];
        }
    }
    
    index = [self.paraNames indexOfObject:@"fixtures_fittings"];
    if (index != NSIntegerMax) {
        objectValue = [self.paraValues objectAtIndex:index];
        if (![objectValue isEqualToString:@""] && [objectValue isKindOfClass:[NSString class]]) {
            objectValue = [objectValue stringByReplacingOccurrencesOfString:@", " withString:@","];
            self.array_fixtures_fittings = [[NSMutableArray alloc]initWithArray:[objectValue componentsSeparatedByString:@","]];
        }
    }
    index = [self.paraNames indexOfObject:@"images"];
    if (index != NSIntegerMax) {
        objectValue = [self.paraValues objectAtIndex:index];
        if ([objectValue isKindOfClass:[NSArray class]]) {
            NSString *imageURL, *imageThumb;
            for (NSDictionary *dict in objectValue) {
                imageThumb = [dict objectForKey:@"thumb"];
                imageURL = [dict objectForKey:@"image_url"];
                if (imageThumb == nil) {
                    imageThumb = @"";
                }
                if (imageURL == nil) {
                    imageURL = @"";
                }
                [self.images addObject:[NSArray arrayWithObjects:imageURL, imageThumb, nil]];
            }
            //self.images = [[NSMutableArray alloc]initWithArray:objectValue];
        }
    }
}
@end
