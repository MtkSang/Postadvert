//
//  AlertCellContent.m
//  Postadvert
//
//  Created by Mtk Ray on 6/27/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "AlertCellContent.h"
#import "NSData+Base64.h"
@implementation AlertCellContent

- (id) initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        if (dict) {
            @try {
                self.connect_from_id = [[dict objectForKey:@"connect_from_id"] integerValue];
                self.connect_from_name = [dict objectForKey:@"connect_from_name"];
                self.connect_from_thumb = [NSData stringDecodeFromBase64String: [dict objectForKey:@"connect_from_thumb"]];
                self.connection_id = [[dict objectForKey:@"connection_id"] integerValue];
                self.created = [dict objectForKey:@"created"];
                self.message = [dict objectForKey:@"message"];
                self.mutual_friends_count = [[dict objectForKey:@"mutual_friends_count"] integerValue];
            }
            @catch (NSException *exception) {
            }
            @finally {
                return self;
            }
        }else
            return self;
    }
}
@end
