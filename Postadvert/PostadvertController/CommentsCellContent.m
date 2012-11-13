//
//  CommentsCellContent.m
//  Postadvert
//
//  Created by Mtk Ray on 6/5/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "CommentsCellContent.h"
#import "Constants.h"
@implementation CommentsCellContent
@synthesize  userAvatarURL,userPostName,text, userPostID, commnetID, created;

- (id) init
{
    self = [super init];
    return self;
}


+ (float) getCellHeighWithContent:(CommentsCellContent*)content withWidth:(float) width
{
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [content.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return 65 - 21 + size.height;
}
@end
