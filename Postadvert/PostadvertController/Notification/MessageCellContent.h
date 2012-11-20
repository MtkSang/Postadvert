//
//  MessageCellContent.h
//  Postadvert
//
//  Created by Mtk Ray on 6/18/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCellContent : NSObject
@property (nonatomic, strong)   NSString *userPostName;
@property (nonatomic, strong)   UIImage *userAvatar;
@property (nonatomic, strong)   NSString *text;
@property (nonatomic, strong)   NSDate *datePost;
@property (nonatomic, strong)   UIImage *imageAttachment;
//@property (nonatomic, strong)   NSTimer *timePost;

@property (nonatomic)   NSInteger msg_id;
@property (nonatomic)   NSInteger parent_id;
@property (nonatomic)   NSInteger author_id;
@property (nonatomic, strong)   NSString *subject;
@property (nonatomic, strong)   NSMutableArray *partners;
@property (nonatomic, strong)   NSString *created;
@property (nonatomic)   BOOL is_read;
@property (nonatomic, strong)   NSString *messageThumbURL;

- (id)initWithDictionary:(NSDictionary*)dict withOption:(NSInteger)opt;
- (id) initWithDictionary:(NSDictionary *)dict andSuperMessage:(MessageCellContent*)superMessage;
- (void) parseDataWithOption:(NSInteger) opt;
@end
