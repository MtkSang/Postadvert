//
//  PostadvertControllerV2.m
//  Postadvert
//
//  Created by Mtk Ray on 7/11/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "PostadvertControllerV2.h"
#import "Reachability.h"
#import "Constants.h"
#import "SBJson.h"
#import "TouchXML.h"
#import "NSData+Base64.h"
#import "UserPAInfo.h"
#import "KTPhotoView+SDWebImage.h"
//
#import "PostCellContent.h"
#import "ActivityContent.h"
@interface PostadvertControllerV2 ()
-(void) showAlertWithMessage: (NSString*) msg andTitle: (NSString*) title;
@end

@implementation PostadvertControllerV2
@synthesize internetActive = _internetActive;
@synthesize hostActive = _hostActive;

static PostadvertControllerV2* _sharedMySingleton = nil;

+(PostadvertControllerV2*)sharedPostadvertController
{
	@synchronized([PostadvertControllerV2 class])
	{
		if (!_sharedMySingleton)
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wunused-value"
            [[self alloc] init];
            #pragma clang diagnostic pop
		return _sharedMySingleton;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([PostadvertControllerV2 class])
	{
		NSAssert(_sharedMySingleton == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedMySingleton = [super alloc];
		return _sharedMySingleton;
	}
    
	return nil;
}


- (id) init
{
    self = [super init];
    if (self) {
        // check for internet connection
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReachable = [Reachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        
        // check if a pathway to a random host exists
        hostReachable = [Reachability reachabilityWithHostName: @"postadvert.com"];
        [hostReachable startNotifier];
        
        // now patiently wait for the notification
    }
    remainCount = 0;
    return self;
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
        }
    }
    isChecked = YES;
}

- (BOOL)isConnectToWeb
{
    if (isChecked) {
        return self.internetActive;
    }
    else {
        BOOL connected;
        
        NSString *hostGoogle = @"www.google.com";
        SCNetworkReachabilityRef reachabilityGoogle = SCNetworkReachabilityCreateWithName(NULL, [hostGoogle UTF8String]);
        SCNetworkReachabilityFlags flags;
        connected = SCNetworkReachabilityGetFlags(reachabilityGoogle, &flags);
        BOOL isConnected = connected && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);    
        CFRelease(reachabilityGoogle);
        
        if (!isConnected) {
            NSString *hostApple = @"www.apple.com";
            SCNetworkReachabilityRef reachabilityApple = SCNetworkReachabilityCreateWithName(NULL, [hostApple UTF8String]);
            SCNetworkReachabilityFlags appleFlags;
            connected = SCNetworkReachabilityGetFlags(reachabilityApple, &appleFlags);
            isConnected = connected && (appleFlags & kSCNetworkFlagsReachable) && !(appleFlags & kSCNetworkFlagsConnectionRequired);    
            CFRelease(reachabilityApple);
        }
        
        return isConnected;
    }
    return NO;
}

-(void) showAlertWithMessage: (NSString*) msg andTitle: (NSString*) title{
    UIAlertView *baseAlert = [[UIAlertView alloc] initWithTitle: title
                                                        message: msg
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [baseAlert show];
    
}

- (long) registrationLogin:(NSString *)userName :(NSString *)password
{    
    
    if(![self isConnectToWeb]){
        [self showAlertWithMessage:@"This device does not connect to Internet." andTitle:@"Postadvert"];
        return 0;
    }
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:@"login" andParametter:
                     [NSString stringWithFormat:@"<login_name>%@</login_name>"
                                                @"<login_password>%@</login_password>", userName, password]];
    NSDictionary *info;
    NSLog(@"%@",jsonObject);
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Dictionary %@", jsonObject);
        info = [NSDictionary dictionaryWithDictionary: jsonObject];
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])  
    {
        NSLog(@"Array %@", jsonObject);
    }
    long logInId  = 0;
    if ([[info objectForKey:@"result"] boolValue]) {
        NSDictionary *userInfo = [info objectForKey:@"info"];
        logInId = [[userInfo objectForKey:@"id"]integerValue ];
        [UserPAInfo sharedUserPAInfo].registrationID = logInId;
        //for Kelvin
        //[UserPAInfo sharedUserPAInfo].registrationID = 101;
        NSLog(@"registrationID %ld %ld", logInId, [UserPAInfo sharedUserPAInfo].registrationID);
        [UserPAInfo sharedUserPAInfo].email = [userInfo objectForKey:@"email"];
        [UserPAInfo sharedUserPAInfo].fullName = [userInfo objectForKey:@"name"];
        [UserPAInfo sharedUserPAInfo].usernamePU = [userInfo objectForKey:@"username"];
        [UserPAInfo sharedUserPAInfo].passwordPU = password;
        NSString *base64Str = [userInfo objectForKey:@"thumb"];
        NSData *imageData = [NSData dataFromBase64String:base64Str];
        UIImage *image = [UIImage imageWithData:imageData];
        [UserPAInfo sharedUserPAInfo].imgAvatar = image;
        //save user info
        NSUserDefaults *database = [[NSUserDefaults alloc]init];
        [database setValue:[UserPAInfo sharedUserPAInfo].usernamePU forKey:@"userNamePA"];
        [database setValue:[UserPAInfo sharedUserPAInfo].email  forKey:@"email"];
        [database setValue:[UserPAInfo sharedUserPAInfo].passwordPU forKey:@"passwordPA"];
        [database synchronize];
    }
    jsonObject = nil;
    return logInId;
}

- (id) jsonObjectFromWebserviceWithFunctionName:(NSString*/*FUnction name*/)functionName andParametter: (NSString*/*Parametter String */) parametterString
{
    ShowNetworkActivityIndicator();
    remainCount ++;
    NSString *soapFormat = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                            @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                            @"<soap:Body>"
                            @"<%@ xmlns=\"http://stroff.com/ws/server_side/\">"
                            @"%@"
                            @"</%@>"
                            @"</soap:Body>"
                            @"</soap:Envelope>",functionName, parametterString, functionName];
    
    
    
    
    
    NSLog(@"The request format is: \n%@",soapFormat); 
    
    NSURL *locationOfWebService = [NSURL URLWithString:@"http://stroff.com/ws/server_side/api.php?wsdl"];//http://jmobile.futureworkz.com.sg/fwz_service/fwz_server_wsdl.php?wsdl
    
    NSLog(@"web url = %@",locationOfWebService);
    
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc]initWithURL:locationOfWebService];// cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4];
    
    NSString *msgLength = [NSString stringWithFormat:@"%d",[soapFormat length]];
    
    
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:@"" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    //the below encoding is used to send data over the net
    [theRequest setHTTPBody:[soapFormat dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    NSError *error;	
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    NSString *results = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
    NSLog(@"%@",results);
    CXMLDocument *doc = [[CXMLDocument alloc] initWithData:data options:0 error:nil];
    NSLog(@"DATA :%@", doc);
    NSArray *nodes = NULL;
    //  searching for return nodes (return from WS)
    nodes = [doc nodesForXPath:@"//return" error:nil];
    //Get info
    SBJsonParser *jsonParser = [[SBJsonParser alloc]init]; 
    id jsonObject;
    for (CXMLElement *node in nodes) {
        jsonObject = [jsonParser objectWithString:node.stringValue];
    }
    remainCount --;
    if (remainCount< 1) {
        remainCount = 0;
        HideNetworkActivityIndicator();
    }
    
    return jsonObject;
}
- (id) getPostsWithWall:(NSString*) wallId from:(NSString*) start andCount:(NSString*) count WithUserID:(NSString*)userID
{
    if ([userID isEqualToString:@"0"]) {
        userID = [NSString stringWithFormat:@"%ld",[[UserPAInfo sharedUserPAInfo]registrationID]];
    }
    NSString *functionName = @"getPosts";
    NSString *parametterStr = [NSString stringWithFormat:@"<wall_id>%@</wall_id>"
                               @"<start>%@</start>"
                               @"<end>%@</end>"
                               @"<id>%@</id>",wallId, start, count, userID];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    NSMutableArray *listCellContent = [[NSMutableArray alloc] init];
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])  
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
        NSLog(@"Array %@", infoArray);
        for (NSDictionary *dict in infoArray) {
            NSLog(@"One Post: %@", dict);
            PostCellContent *cellContent = [[PostCellContent alloc]init];
            //Author
            NSDictionary *author = [dict objectForKey:@"author"];
            if ([author isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Author %@", author);
                cellContent.userPostName = [author objectForKey:@"name"];
                NSLog(@"Username %@", cellContent.userPostName);
                //User Avatar
                NSString *urlAvatar = [author objectForKey:@"thumb"];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlAvatar]];
                cellContent.userAvatar = [UIImage imageWithData:imageData];
                imageData = nil;

            }else {
                continue;
            }
            //Comments
            
            NSDictionary *comments = [dict objectForKey:@"comments"];
            NSLog(@"comments %@", comments);
            if ([comments isKindOfClass:[NSDictionary class]]) {
                NSArray *commentsList = [comments objectForKey:@"comments_list"];
                cellContent.listComments = [NSMutableArray arrayWithArray:commentsList];
                cellContent.totalComment = [[comments objectForKey:@"total_comments"] integerValue];
            }
            //Like
            NSDictionary *like = [dict objectForKey:@"like"];
            if ([like isKindOfClass:[NSDictionary class]]) {
                cellContent.isClap = [[like objectForKey:@"is_liked"] boolValue];
                NSLog(@"Is Like %d", cellContent.isClap);
                cellContent.totalClap = [[like objectForKey:@"total_likes"] integerValue];
            }
            
            //Post
            NSDictionary *post = [dict objectForKey:@"post"];
            cellContent.ID_Post = [[post objectForKey:@"id"] integerValue];
            cellContent.text = [NSData stringDecodeFromBase64String:[post objectForKey:@"post"]];
            cellContent.titlePost = [post objectForKey:@"title"];
            NSLog(@"Detail a post : %@ Title is:%@", post, cellContent.titlePost);
            //time
            NSString *timePost = [post objectForKey:@"created_on_lapseTime"];
            if ([timePost isKindOfClass:[NSString class]]) {
                cellContent.created_on_lapseTime = [NSData stringDecodeFromBase64String:timePost];
            }else
                cellContent.created_on_lapseTime = @"";
            // - > website
            NSDictionary *website = [dict objectForKey:@"website"];
            if ([website isKindOfClass:[NSDictionary class]]) {
                [cellContent.listLinks addObject:[website objectForKey:@"url"]];
                cellContent.linkWebsite = [NSDictionary dictionaryWithDictionary:website];
                //description
                //title
            }
            
            // - > yotube
            NSDictionary *youtube = [dict objectForKey:@"youtube"];
            if ([youtube isKindOfClass:[NSDictionary class]]) {
                cellContent.linkYoutube = [NSDictionary dictionaryWithDictionary:youtube];
                [cellContent.listVideos addObject:[youtube objectForKey:@"url"]];
            }

            //Image
            NSDictionary *images = [dict objectForKey:@"image"];
            
            NSLog(@"image %@", images);
            NSLog(@"Kind %@", NSStringFromClass([images class]));
            if ([images isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dictImages in images) {
                    [cellContent.listImages addObject:[NSArray arrayWithObjects:[dictImages objectForKey:@"full_image"],[dictImages objectForKey:@"thumb_image"], nil]];
                }
                NSLog(@"List Image %@", cellContent.listImages);
            }
            [listCellContent addObject:cellContent];
        }
    }

    return (id)listCellContent;
}
/*
 
 travelPosts($wall_id,$post_id,$user_id,$type_get,$number)
 4:56 type_get = next hoặc previous nha em
 4:56 number là số record muốn lấy
 */
- (id) getContinuePostsWithWall:(NSString*) wallId PostId:(NSString*)postId WithUserID:(NSString*)userID Type:(NSString*) type andCount:(NSString*) count
{
    if ([userID isEqualToString:@"0"]) {
        userID = [NSString stringWithFormat:@"%ld",[[UserPAInfo sharedUserPAInfo]registrationID]];
    }
    NSString *functionName = @"travelPosts";
    NSString *parametterStr = [NSString stringWithFormat:@"<wall_id>%@</wall_id>"
                               @"<post_id>%@</post_id>"
                               @"<user_id>%@</user_id>"
                               @"<type_get>%@</type_get>"
                               @"<number>%@</number>",wallId, postId, userID, type, count];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    NSMutableArray *listCellContent = [[NSMutableArray alloc] init];
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
        NSLog(@"Array %@", infoArray);
        for (NSDictionary *dict in infoArray) {
            NSLog(@"One Post: %@", dict);
            PostCellContent *cellContent = [[PostCellContent alloc]init];
            //Author
            NSDictionary *author = [dict objectForKey:@"author"];
            if ([author isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Author %@", author);
                cellContent.userPostName = [author objectForKey:@"name"];
                NSLog(@"Username %@", cellContent.userPostName);
                //User Avatar
                NSString *urlAvatar = [author objectForKey:@"thumb"];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlAvatar]];
                cellContent.userAvatar = [UIImage imageWithData:imageData];
                imageData = nil;
                
            }else {
                continue;
            }
            //Like
            NSDictionary *like = [dict objectForKey:@"like"];
            if ([like isKindOfClass:[NSDictionary class]]) {
                cellContent.isClap = [[like objectForKey:@"is_liked"] boolValue];
                NSLog(@"Is Like %d", cellContent.isClap);
                cellContent.totalClap = [[like objectForKey:@"total_likes"] integerValue];
            }
            
            //Post
            NSDictionary *post = [dict objectForKey:@"post"];
             cellContent.ID_Post = [[post objectForKey:@"id"] integerValue];
            cellContent.text = [NSData stringDecodeFromBase64String:[post objectForKey:@"post"]];
            cellContent.titlePost = [post objectForKey:@"title"];
            NSLog(@"Detail a post : %@ Title is:%@", post, cellContent.titlePost);
            //time
            NSString *timePost = [post objectForKey:@"created_on_lapseTime"];
            if ([timePost isKindOfClass:[NSString class]]) {
                cellContent.created_on_lapseTime = [NSData stringDecodeFromBase64String:timePost];
            }else
                cellContent.created_on_lapseTime = @"";
            // - > website
            NSDictionary *website = [dict objectForKey:@"website"];
            if ([website isKindOfClass:[NSDictionary class]]) {
                [cellContent.listLinks addObject:[website objectForKey:@"url"]];
                cellContent.linkWebsite = [NSDictionary dictionaryWithDictionary:website];
                //description
                //title
            }
            
            // - > yotube
            NSDictionary *youtube = [dict objectForKey:@"youtube"];
            if ([youtube isKindOfClass:[NSDictionary class]]) {
                cellContent.linkYoutube = [NSDictionary dictionaryWithDictionary:youtube];
                [cellContent.listVideos addObject:[youtube objectForKey:@"url"]];
            }
            
            //Image
            NSDictionary *images = [dict objectForKey:@"image"];
            
            NSLog(@"image %@", images);
            NSLog(@"Kind %@", NSStringFromClass([images class]));
            if ([images isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dictImages in images) {
                    [cellContent.listImages addObject:[NSArray arrayWithObjects:[dictImages objectForKey:@"full_image"],[dictImages objectForKey:@"thumb_image"], nil]];
                }
                NSLog(@"List Image %@", cellContent.listImages);
            }
            [listCellContent addObject:cellContent];
        }
    }
    
    return (id)listCellContent;
}


-(id) getCountPostsWithWallId:(NSString*) wallId
{
    NSString *functionName = @"countPosts";
    NSString *parametterStr = [NSString stringWithFormat:@"<wall_id>%@</wall_id>",wallId];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    NSNumber *num = [NSNumber numberWithInt:0];
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])  
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
        NSLog(@"Array %@", infoArray);
        if (infoArray.count) {
            id value = [infoArray objectAtIndex:0];
            num = [NSNumber numberWithInteger:[value integerValue]];
        }
    }
    return num;
    
}

-(NSInteger) countFriendOfUser:(NSString*)userID
{
    if ([userID isEqualToString:@"0"]) {
        userID = [NSString stringWithFormat:@"%ld",[[UserPAInfo sharedUserPAInfo]registrationID]];
    }
    NSString *functionName = @"countFriends";
    NSString *parametterStr = [NSString stringWithFormat:@"<user_id>%@</user_id>",userID];

    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];

    NSDictionary *infoDict;
    NSArray *infoArray;
    NSNumber *num = [NSNumber numberWithInteger:0];
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
        NSLog(@"Array %@", infoArray);
        if (infoArray.count) {
            id value = [infoArray objectAtIndex:0];
            num = [NSNumber numberWithInteger:[value integerValue]];
        }
    }
    return num.integerValue;
}
//getUserFriends($user_id, $row_id, $limit, $base64_image = false)
-(id) getUserFriendsWithID:(NSString*)userID row:(NSString*)row_id count:(NSString*)limit
{
    if ([userID isEqualToString:@"0"]) {
        userID = [NSString stringWithFormat:@"%ld",[[UserPAInfo sharedUserPAInfo]registrationID]];
    }
    NSString *functionName = @"getUserFriends";
    NSString *parametterStr = [NSString stringWithFormat:@"<user_id>%@</user_id>"
                               @"<row_id>%@</row_id>"
                               @"<limit>%@</limit>",userID, row_id, limit];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
        NSLog(@"Array %@", infoArray);
    }
    
    return infoArray;
}
-(id) getFriendsOfUserID:(NSString*)userID from:(NSString*)start count:(NSString*)count
{
    if ([userID isEqualToString:@"0"]) {
        userID = [NSString stringWithFormat:@"%ld",[[UserPAInfo sharedUserPAInfo]registrationID]];
    }
    NSString *functionName = @"getFriends";
    NSString *parametterStr = [NSString stringWithFormat:@"<user_id>%@</user_id>"
                               @"<start>%@</start>"
                               @"<end>%@</end>",userID, start, count];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
        NSLog(@"Array %@", infoArray);
    }
    
    return infoArray;
}
//getStatusUpdate($user_id, $limit, $index, $status_id)
-(id) getStatusUpdateWithUserID:(NSString*)userId limit:(NSString*)limit index:(NSString*)index status_id:(NSString*)status_id
{
    if (! userId.integerValue) {
        userId = [NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID];
    }
    
    NSString *functionName = @"getStatusUpdate";
    NSString *parametterStr = [NSString stringWithFormat:
                               @"<user_id>%@</user_id>"
                               @"<limit>%@</limit>"
                               @"<index>%@</index>"
                               @"<status_id>%@</status_id>",userId, limit, index,status_id];
    //Have been changed roa_id - > total
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    NSMutableArray *listContent = [[NSMutableArray alloc]init];
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
        NSLog(@"Array %@", infoArray);
        for (NSDictionary *dict in infoArray) {
            NSLog(@"dict %@", dict);
            ActivityContent *content = [[ActivityContent alloc]init];
            content.activity_type = [dict objectForKey:@"act_type"];
            content.activity_ID = [dict objectForKey:@"act_id"];
            content.actor_id = [[dict objectForKey:@"actor_id"] integerValue];
            content.actor_name = [dict objectForKey:@"actor_name"];
            content.actor_gender = [dict objectForKey:@"actor_gender"];
            NSString *base64Str = [dict objectForKey:@"actor_thumb"];
            NSData *imageData = [NSData dataFromBase64String:base64Str];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image == nil) {
                image = [UIImage imageNamed:@"user_default_thumb.png"];
            }
            content.actor_thumbl = image;
            if ([[dict objectForKey:@"actor_2"] isKindOfClass:[NSArray class]]) {
                content.actor_2 = [dict objectForKey:@"actor_2"];
            }
            content.app_type = [dict objectForKey:@"app"];
            content.cid = [[dict objectForKey: @"cid"] integerValue];
            content.commnent_type = [dict objectForKey:@"comment_type"];
            content.commentContent = [NSData stringDecodeFromBase64String: [dict objectForKey:@"content"]];
            content.actionStringFromServer = [NSData stringDecodeFromBase64String:[dict objectForKey:@"action"]];
            content.created_time = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
            content.status_ID = [[dict objectForKey:@"id"] integerValue];
            content.like_id = [[dict objectForKey:@"like_id"] integerValue];
            //Like info
            NSDictionary *likeInfo = [dict objectForKey:@"like_info"];
            content.isClap = [[likeInfo objectForKey:@"like_status"] boolValue];
            content.totalClap = [[likeInfo objectForKey:@"like_total"] integerValue];
            
            content.like_type = [dict objectForKey:@"like_type"];
            //target
            if ([[dict objectForKey:@"target_id"] isKindOfClass:[NSNull class]]) {
                content.target_id = 0;
            }else
                content.target_id = [[dict objectForKey:@"target_id"] integerValue];
            content.target_name = [NSData stringDecodeFromBase64String:[dict objectForKey:@"target_name"]];
            if (![[dict objectForKey:@"target_author_id"] isKindOfClass:[NSNull class]]) {
                content.target_author_id = [[dict objectForKey:@"target_author_id"] integerValue] ;
            }else
                content.target_author_id = 0 ;
            
            content.target_author_name = [dict objectForKey:@"target_author_name"];
            
            content.title =  [NSData stringDecodeFromBase64String:[dict objectForKey:@"action"]];
            //photo_info
            NSDictionary *photo_info = [dict objectForKey:@"photo_info"];
            content.photo_info_id = [[photo_info objectForKey:@"id"] integerValue];
//            content.photo_info_image = [NSData stringDecodeFromBase64String:[photo_info objectForKey:@"image"]];
//            content.photo_info_thumb = [NSData stringDecodeFromBase64String:[photo_info objectForKey:@"photo_thumb_url"]];
            content.listImages = [[NSMutableArray alloc]init];
            NSString *fullImage = [NSData stringDecodeFromBase64String:[photo_info objectForKey:@"image"] ];
            NSString *thumbnail = [NSData stringDecodeFromBase64String:[photo_info objectForKey:@"photo_thumb_url"]];
            if (fullImage.length || thumbnail.length) {
                [content.listImages addObject:[NSArray arrayWithObjects:fullImage, thumbnail, nil]];
            }
            //video_info
            content.video = [dict objectForKey:@"video_info"];
            if ([content.video isKindOfClass:[NSDictionary class]]) {
//                content.video = [[NSMutableDictionary alloc]init];
//                [content.video setValue:[NSData stringDecodeFromBase64String: [video objectForKey:@"description"]  ]forKey:@"description"];
//                [content.video setValue:[NSData stringDecodeFromBase64String: [video objectForKey:@"thumb"]  ]forKey:@"thumb"];
//                [content.video setValue:[NSData stringDecodeFromBase64String: [video objectForKey:@"title"]  ]forKey:@"title"];
//                [content.video setValue:[NSData stringDecodeFromBase64String: [video objectForKey:@"url"]  ]forKey:@"url"];
//                [content.video setValue:[video objectForKey:@"id"] forKey:@"id"];
            }else
                content.video = nil;
            //content.video = nil;
            //total comments
            content.totalComment = [[dict objectForKey:@"total_comments"] integerValue];
            
            [listContent addObject:content];
        }
    }
    return listContent;
    
}
//getUserStatusUpdate($user_id, $limit, $status_id)

-(id) getUserStatusUpdateWithUserID:(NSString*)userId limit:(NSString*)limit status_id:(NSString*)status_id
{
    if (! userId.integerValue) {
        userId = [NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID];
    }
    
    NSString *functionName = @"getUserStatusUpdate";
    NSString *parametterStr = [NSString stringWithFormat:
                               @"<user_id>%@</user_id>"
                               @"<limit>%@</limit>"
                               @"<status_id>%@</status_id>",userId, limit, status_id];
    //Have been changed roa_id - > total
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    NSMutableArray *listContent = [[NSMutableArray alloc]init];
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
        NSLog(@"Array %@", infoArray);
        for (NSDictionary *dict in infoArray) {
            NSLog(@"dict %@", dict);
            ActivityContent *content = [[ActivityContent alloc]init];
            content.activity_type = [dict objectForKey:@"act_type"];
            content.activity_ID = [dict objectForKey:@"act_id"];
            content.actor_id = [[dict objectForKey:@"actor_id"] integerValue];
            content.actor_name = [dict objectForKey:@"actor_name"];
            content.actor_gender = [dict objectForKey:@"actor_gender"];
            NSString *base64Str = [dict objectForKey:@"actor_thumb"];
            NSData *imageData = [NSData dataFromBase64String:base64Str];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image == nil) {
                image = [UIImage imageNamed:@"user_default_thumb.png"];
            }
            content.actor_thumbl = image;
            if ([[dict objectForKey:@"actor_2"] isKindOfClass:[NSArray class]]) {
                content.actor_2 = [dict objectForKey:@"actor_2"];
            }
            content.app_type = [dict objectForKey:@"app"];
            content.cid = [[dict objectForKey: @"cid"] integerValue];
            content.commnent_type = [dict objectForKey:@"comment_type"];
            content.commentContent = [NSData stringDecodeFromBase64String: [dict objectForKey:@"content"]];
            content.actionStringFromServer = [NSData stringDecodeFromBase64String:[dict objectForKey:@"action"]];
            content.created_time = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
            content.status_ID = [[dict objectForKey:@"id"] integerValue];
            content.like_id = [[dict objectForKey:@"like_id"] integerValue];
            //Like info
            NSDictionary *likeInfo = [dict objectForKey:@"like_info"];
            content.isClap = [[likeInfo objectForKey:@"like_status"] boolValue];
            content.totalClap = [[likeInfo objectForKey:@"like_total"] integerValue];
            
            content.like_type = [dict objectForKey:@"like_type"];
            //target
            if ([[dict objectForKey:@"target_id"] isKindOfClass:[NSNull class]]) {
                content.target_id = 0;
            }else
                content.target_id = [[dict objectForKey:@"target_id"] integerValue];
            content.target_name = [NSData stringDecodeFromBase64String:[dict objectForKey:@"target_name"]];
            if (![[dict objectForKey:@"target_author_id"] isKindOfClass:[NSNull class]]) {
                content.target_author_id = [[dict objectForKey:@"target_author_id"] integerValue] ;
            }else
                content.target_author_id = 0 ;
            
            content.target_author_name = [dict objectForKey:@"target_author_name"];
            
            content.title =  [NSData stringDecodeFromBase64String:[dict objectForKey:@"action"]];
            //photo_info
            NSDictionary *photo_info = [dict objectForKey:@"photo_info"];
            content.photo_info_id = [[photo_info objectForKey:@"id"] integerValue];
            //            content.photo_info_image = [NSData stringDecodeFromBase64String:[photo_info objectForKey:@"image"]];
            //            content.photo_info_thumb = [NSData stringDecodeFromBase64String:[photo_info objectForKey:@"photo_thumb_url"]];
            content.listImages = [[NSMutableArray alloc]init];
            NSString *fullImage = [NSData stringDecodeFromBase64String:[photo_info objectForKey:@"image"] ];
            NSString *thumbnail = [NSData stringDecodeFromBase64String:[photo_info objectForKey:@"photo_thumb_url"]];
            if (fullImage.length || thumbnail.length) {
                [content.listImages addObject:[NSArray arrayWithObjects:fullImage, thumbnail, nil]];
            }
            //video_info
            content.video = [dict objectForKey:@"video_info"];
            if ([content.video isKindOfClass:[NSDictionary class]]) {
                //                content.video = [[NSMutableDictionary alloc]init];
                //                [content.video setValue:[NSData stringDecodeFromBase64String: [video objectForKey:@"description"]  ]forKey:@"description"];
                //                [content.video setValue:[NSData stringDecodeFromBase64String: [video objectForKey:@"thumb"]  ]forKey:@"thumb"];
                //                [content.video setValue:[NSData stringDecodeFromBase64String: [video objectForKey:@"title"]  ]forKey:@"title"];
                //                [content.video setValue:[NSData stringDecodeFromBase64String: [video objectForKey:@"url"]  ]forKey:@"url"];
                //                [content.video setValue:[video objectForKey:@"id"] forKey:@"id"];
            }else
                content.video = nil;
            //content.video = nil;
            //total comments
            content.totalComment = [[dict objectForKey:@"total_comments"] integerValue];
            
            [listContent addObject:content];
        }
    }
    return listContent;
    
}

-(id) getUserAlbumsWithUserID:(NSString*)userID
{
    if ([userID isEqualToString:@"0"]) {
        userID = [NSString stringWithFormat:@"%ld", [[UserPAInfo sharedUserPAInfo] registrationID]];
    }
    
    NSString *functionName = @"getUserAlbums";
    NSString *parametterStr = [NSString stringWithFormat:@"<user_id>%@</user_id>",userID];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
    }
    return infoArray;
}
//getPhotoAlbum
-(id) getPhotoOfAlbumWithAlbumID:(NSString*)albumID
{

    NSString *functionName = @"getPhotoAlbum";
    NSString *parametterStr = [NSString stringWithFormat:@"<user_id>%@</user_id>",albumID];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
    }
    return infoArray;
}

-(id) getUserVideosWithUserID:(NSString*)userID
{
    if ([userID isEqualToString:@"0"]) {
        userID = [NSString stringWithFormat:@"%ld", [[UserPAInfo sharedUserPAInfo] registrationID]];
    }
    
    NSString *functionName = @"getUserVideos";
    NSString *parametterStr = [NSString stringWithFormat:@"<user_id>%@</user_id>",userID];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
    }
    return infoArray;
}
//getFriendStatus($my_id, $other_user_id, $base64_image = false)
-(id) getFriendStatusWithUserID:(NSString*)userID andOtherID:(NSString*)otherID
{
    if ([userID isEqualToString:@"0"]) {
        userID = [NSString stringWithFormat:@"%ld", [[UserPAInfo sharedUserPAInfo] registrationID]];
    }
    
    NSString *functionName = @"getFriendStatus";
    NSString *parametterStr = [NSString stringWithFormat:@"<my_id>%@</my_id><other_user_id>%@</other_user_id>",userID, otherID];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        return infoDict;
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
    }
    return infoArray;
}

-(void) testFunction
{
    return;
    //getStatusUpdate($user_id, $start, $limit, $index)
    
    NSString *functionName = @"getPhotoAlbum";
    NSString *parametterStr = [NSString stringWithFormat:@"<user_id>%@</user_id>",@"13"];
    
    id jsonObject = [self jsonObjectFromWebserviceWithFunctionName:functionName andParametter:parametterStr];
    
    NSDictionary *infoDict;
    NSArray *infoArray;
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
        NSLog(@"Dictionary %@", infoDict);
        
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        infoArray = [NSArray arrayWithArray:jsonObject];
        for (NSDictionary *dict in infoArray) {
            NSLog(@"dict %@", dict);
        }
    }
}




@end
