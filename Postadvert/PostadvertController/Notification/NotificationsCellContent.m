//
//  NotificationsCellContent.m
//  Postadvert
//
//  Created by Mtk Ray on 6/26/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "NotificationsCellContent.h"
#import "NSData+Base64.h"

@implementation NotificationsCellContent

- (id) initWithDictionnary:(NSDictionary*)dict
{
    self = [self init];
    @try {
        _notification_ID = [[dict objectForKey:@"id"] integerValue];
        _target_ID = [[dict objectForKey:@"target_id"] integerValue];
        NSDictionary *actor = [dict objectForKey:@"actor"];
        _actor_ID = [[actor objectForKey:@"id"]integerValue];
        _actor_fullName = [actor objectForKey:@"name"];
        _actor_thumb = [actor objectForKey:@"thumb"];
        _action_string = [dict objectForKey:@"action"];;
        _wall_ID = [[dict objectForKey:@"wall_id"]integerValue];
        _wall_name = [dict objectForKey:@"wall_name"];
        _created = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
        _is_read = [[dict objectForKey:@"is_read"] boolValue];
        
        _fullText = [self getFullText];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return self;
}
- (NSString*) getFullText
{
    NSString *str = [NSString stringWithFormat:@"%@%@%@", _actor_fullName, _action_string, _wall_name];
    return str;
}
@end
