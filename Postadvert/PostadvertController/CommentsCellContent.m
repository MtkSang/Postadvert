//
//  CommentsCellContent.m
//  Postadvert
//
//  Created by Mtk Ray on 6/5/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "CommentsCellContent.h"

@implementation CommentsCellContent
@synthesize  userAvatarURL,userPostName,text, userPostID, commnetID, created;

- (id) init
{
    self = [super init];
    return self;
}


+ (float) getCellHeighWithContent:(CommentsCellContent*)content
{
    return 70;
}
@end
