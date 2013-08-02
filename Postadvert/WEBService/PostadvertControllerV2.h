//
//  PostadvertControllerV2.h
//  Postadvert
//
//  Created by Mtk Ray on 7/11/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserPAInfo.h"
@class Reachability;
@class PostCellContent;
@class CredentialInfo;
@interface PostadvertControllerV2 : NSObject
{
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL isChecked;
    
}
@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;
@property (nonatomic) int remainCount;
@property (nonatomic) int timeOut_in_minute;
+(PostadvertControllerV2*)sharedPostadvertController;
- (void) checkNetworkStatus:(NSNotification *)notice;
- (BOOL) isConnectToWeb;
-(void) showAlertWithMessage: (NSString*) msg andTitle: (NSString*) title;

+ (PostCellContent*)getaPostCellWithDict:(NSDictionary*)dict;

- (id) jsonObjectFromWebserviceWithFunctionName:(NSString*/*Function name*/)functionName parametterName: (NSArray*/*Parametter array */) paramettersName parametterValue:(NSArray*/*parameters values*/) paramettersValus;
- (id) jsonObjectFromWebserviceWithFunctionName:(NSString*/*Function name*/)functionName parametterName: (NSArray*/*Parametter array */) paramettersName parametterValue:(NSArray*/*parameters values*/) paramettersValus callBackDelegate:(id) delegate;
- (long)registrationCreate:(CredentialInfo *) credential;
- (long)registrationCreateWithFirstName:(NSString*)fristName lastName:(NSString*)lastName userName:(NSString*)userName email:(NSString*)email password:(NSString*) password countryID:(int) countryID_;
//- (void) getFullProfile;
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
//Viodes
-(id) getUserVideosWithUserID:(NSString*)userID;
-(id) getAllVideosWithUserID:(NSString*)userID fromID:(NSString*)video_id limit:(NSString*)limit;
-(id) searchVideosWithUserID:(NSString*)userID searchID:(NSString*)search_id key:(NSString*)key searchType:(NSString*)type video_id:(NSString*)video_id limit:(NSString*)limit;
//Album
-(id) getUserAlbumsWithUserID:(NSString*)userID;
-(id) getAllAlbumsWithUserID:(NSString*)userID fromID:(NSString*)albumID limit:(NSString*)limit;
-(id) getPhotoOfAlbumWithAlbumID:(NSString*)albumID;
//Event
-(id) getAllPastEvents:(NSString*)eventID limit:(NSString*)limit;
-(id) getUserCurrentEvents:(NSString*)user_id limit:(NSString*)limit;
-(id) getAllCurrentEvents:(NSString*)event_id limit:(NSString*)limit;


-(id) getFriendStatusWithUserID:(NSString*)userID andOtherID:(NSString*)otherID;

-(id) getUserGroupsWithUserID:(NSString*)userID;
-(id) getAllGroupsWithUserID:(NSString*)userID fromID:(NSString*)groupID limit:(NSString*)limit;
-(id) searchGroupsWithUserID:(NSString*)userID searchID:(NSString*)search_id key:(NSString*)key searchType:(NSString*)type groupID:(NSString*)groupsID limit:(NSString*)limit;
//getAllAlbums($user_id, $album_id, $limit, $base64_image = false)
@end
