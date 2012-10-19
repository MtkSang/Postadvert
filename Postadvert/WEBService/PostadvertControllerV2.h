//
//  PostadvertControllerV2.h
//  Postadvert
//
//  Created by Mtk Ray on 7/11/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Reachability;
@interface PostadvertControllerV2 : NSObject
{
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL isChecked;
    int remainCount;
    
}
@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;
+(PostadvertControllerV2*)sharedPostadvertController;
- (void) checkNetworkStatus:(NSNotification *)notice;
- (BOOL) isConnectToWeb;
- (long) registrationLogin:(NSString *)userName :(NSString *)password;
-(void) testFunction;
- (id) getPostsWithWall:(NSString*) wallId from:(NSString*) start andCount:(NSString*) count WithUserID:(NSString*)userID;
-(id) getCountPostsWithWallId:(NSString*) wallId;
-(id) getUserFriendsWithID:(NSString*)userID row:(NSString*)row_id count:(NSString*)limit;
-(id) getFriendsOfUserID:(NSString*)userID from:(NSString*)start count:(NSString*)count;
-(NSInteger) countFriendOfUser:(NSString*)userID;
- (id) getContinuePostsWithWall:(NSString*) wallId PostId:(NSString*)postId WithUserID:(NSString*)userID Type:(NSString*) type andCount:(NSString*) count;
-(id) getStatusUpdateWithUserID:(NSString*)userId limit:(NSString*)limit index:(NSString*)index status_id:(NSString*)status_id;
-(id) getUserStatusUpdateWithUserID:(NSString*)userId limit:(NSString*)limit status_id:(NSString*)status_id; // using for profile
-(id) getUserVideosWithUserID:(NSString*)userID;
-(id) getUserAlbumsWithUserID:(NSString*)userID;
-(id) getPhotoOfAlbumWithAlbumID:(NSString*)albumID;
-(id) getFriendStatusWithUserID:(NSString*)userID andOtherID:(NSString*)otherID;
@end
