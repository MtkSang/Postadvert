//
//  ActivityContent.h
//  Postadvert
//
//  Created by Ray on 8/29/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityContent : NSObject

@property(nonatomic)                NSInteger status_ID;
@property(nonatomic, strong)        NSString *actor_gender;
@property(nonatomic)                NSInteger actor_id;
@property(nonatomic, strong)        NSString *actor_name;
@property(nonatomic, strong)        UIImage *actor_thumbl;
@property(nonatomic, strong)        NSArray *actor_2;
@property(nonatomic, strong)        NSString *app_type;
@property(nonatomic, strong)        NSString *commnent_type;
@property(nonatomic)                NSInteger cid;
@property(nonatomic, strong)        NSString *created_time;
@property(nonatomic)                NSInteger like_id;
@property(nonatomic)                BOOL        isClap;
@property(nonatomic)                NSInteger totalClap;
@property(nonatomic)                NSInteger totalComment;
@property(nonatomic, strong)        NSString *like_type;
@property(nonatomic)                NSInteger target_id;
@property(nonatomic, strong)        NSString *target_name;
@property(nonatomic, strong)        NSString *title;
@property(nonatomic, strong)        NSString *album_url;
@property(nonatomic)                NSInteger photo_info_id;
//@property(nonatomic, strong)        NSString *photo_info_image;//URL
//@property(nonatomic, strong)        NSString *photo_info_thumb;//Image via base64
@property(nonatomic, strong)        NSMutableArray *listImages;
@property(nonatomic, strong)        NSString *commentContent;
@property(nonatomic, strong)        NSString *actionStringFromServer;
@property(nonatomic, strong)        NSDictionary *video;
@property(nonatomic, strong)        NSString *activity_type;
@property(nonatomic, strong)        NSString *activity_ID;
@property(nonatomic)                NSInteger target_author_id;
@property(nonatomic, strong)        NSString *target_author_name;

@end
