//
//  CredentialInfo.m
//  PalUp
//
//  Created by Elisoft on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CredentialInfo.h"
#import "Constants.h"


@implementation CredentialInfo

@synthesize friendCount;
@synthesize friendStatus;
@synthesize userStatus;
@synthesize registrationID; 
@synthesize avatarUrl;
@synthesize imgAvatar;
@synthesize fullName; 
@synthesize email; 
@synthesize phone; 
@synthesize zipcode; 
@synthesize location;
@synthesize gender; 
@synthesize birthday;
@synthesize timeZone; 
@synthesize usernamePU;
@synthesize passwordPU;
@synthesize usernameFB;
@synthesize passwordFB;
@synthesize usernameET;
@synthesize passwordET;
@synthesize build;
@synthesize firstName;
@synthesize interest;
@synthesize registrationStatusTypeID;
@synthesize relationshipTypeID, statusMessage;
@synthesize statusText, relationshipText;
@synthesize drinking, smoking, education;
@synthesize drinkingTypeID, smokingTypeID, educationTypeID;
@synthesize interestTypeID;
@synthesize book, music;
@synthesize appearance, appearanceTypeID;
@synthesize childrenTypeID, children;
@synthesize movies, moviesTypeIDs, musicTypeIDs;
@synthesize userCountryPA, userCountryID;


-(id) init
{
    if (self) {
        usernamePU = nil;
        passwordPU = nil;
        registrationID = 0; 
        fullName = nil; 
        email = nil;
        phone = nil; 
        zipcode = nil; 
        gender = nil;
        timeZone = nil; 
        location = nil;
        userCountryPA = @"Singapore";
    }
    
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
//    [id] => 341
//                        [name] => Ikeuchi Aya
//                        [username] => Titanic
//                        [email] => vick457@yahoo.com
//                        [registerDate] => 2012-11-23 06:52:35
//                        [lastvisitDate] => 2013-02-25 01:33:25
//                        [thumb] => http://stroff.com/images/avatar/thumb_c615f93e05bac7c47e0a4ba2.png
//                        [status] =>
//                        [status_access] => 0
//                        [view] => 25
//                        [posted_on] => 0000-00-00 00:00:00
//                        [friends] => 72
//                        [date_of_birth] =>
    @try {
        self.registrationID = [[dict objectForKey:@"id"] integerValue];
        self.usernamePU = [dict objectForKey:@"username"];
        self.fullName = [dict objectForKey:@"name"];
        self.email = [dict objectForKey:@"email"];
        self.avatarUrl = [dict objectForKey:@"thumb"];
        self.friendCount = [[dict objectForKey:@"friends"] integerValue];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
        return self;
}

-(id) initWithEmail:(NSString*) emailAddr password:(NSString*) pwd
{
    if (self) {
        passwordPU = pwd;
        registrationID = 0; 
        fullName = @""; 
        email = emailAddr;
        phone = @""; 
        zipcode = @""; 
        gender = @"";
        timeZone = @""; 
        location = @"";
    }

    return self;
}
-(id) initWithFirstName:(NSString*)first_Name lastname:(NSString*)lastName email:(NSString*) emailAddr userName:(NSString*)usrName password:(NSString*) pwd countryID:(int) countryID
{
    if (self) {
        self.firstName = first_Name;
        self.lastName = lastName;
        self.userCountryID = countryID;
    }
    return [self initWithEmail:emailAddr userName:usrName password:pwd];
}

-(id) initWithEmail:(NSString*) emailAddr userName:(NSString*)usrName password:(NSString*) pwd
{
    if (self) {
        usernamePU = usrName;
    }
    
    return [self initWithEmail:emailAddr password:pwd];
}


- (long) getRegistrationId
{
    return registrationID;
}

- (NSString*) getUserNamePU
{
    return usernamePU;
}

- (NSString*) getPwdNamePU
{
    return passwordPU;
}


- (int)getAge /*:(NSDate *)dateOfBirth*/
{
    int r = -1;
    if (birthday) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
        NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:birthday];
        
        if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
            (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
            r = [dateComponentsNow year] - [dateComponentsBirth year] - 1;
        } else {
            r = [dateComponentsNow year] - [dateComponentsBirth year];
        }
    }

    return r;
}

@end
