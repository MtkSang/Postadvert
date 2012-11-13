//
//  CommentsCellContent.h
//  Postadvert
//
//  Created by Mtk Ray on 6/5/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentsCellContent : NSObject
@property (nonatomic, strong)   NSString *userPostName;
@property (nonatomic, strong)   NSString *userAvatarURL;
@property (nonatomic, strong)   NSString *text;
@property (nonatomic, strong)   NSString *created;
@property (nonatomic)           long      userPostID;
@property (nonatomic)           long      commnetID;
+ (float) getCellHeighWithContent:(CommentsCellContent*)content withWidth:(float) width;
@end
