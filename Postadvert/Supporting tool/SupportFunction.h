//
//  SupportFunction.h
//  Postadvert
//
//  Created by Mtk Ray on 7/27/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SupportFunction : NSObject


+ (NSInteger) GetCountryIdFromConutryName:(NSString*)countryName;

+ (NSInteger) getWallIdFromCountryID:(NSInteger)countryID andItemName:(NSString*)itemName;

+ (CGSize) sizeForScaleWithMaxWidth:(float) width fromWidth:(float)imageWidth andHeight:(float)imageHeight;

+ (NSString*) getYoutubeIDFromUrl:(NSString*) url;

+ (BOOL) isYoutubeVideoLink:(NSURL*)url;

+ (NSString *) stringFromYears:(NSInteger) years andMonths:(NSInteger)months;
+ (NSString *) stringFromShortYearMonthString:(NSString*) str;
+ (NSArray*) numbersFromFullYearsMonths:(NSString*)fullStr;
@end
