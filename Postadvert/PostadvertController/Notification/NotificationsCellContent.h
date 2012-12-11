//
//  NotificationsCellContent.h
//  Postadvert
//
//  Created by Mtk Ray on 6/26/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationsCellContent : NSObject

@property (nonatomic)           NSInteger notification_ID;
@property (nonatomic)           NSInteger target_ID;
@property (nonatomic)           NSInteger actor_ID;
@property (nonatomic , strong)  NSString *actor_fullName;
@property (nonatomic, strong)   NSString *actor_thumb;
@property (nonatomic, strong)   NSString *action_string;
@property (nonatomic)           NSInteger wall_ID;
@property (nonatomic, strong)   NSString *wall_name;
@property (nonatomic, strong)   NSString *created;
@property (nonatomic)           BOOL     is_read;

@property (nonatomic, strong)   NSString *fullText;
- (NSString*) getFullText;
- (id) initWithDictionnary:(NSDictionary*)dict;
@end
