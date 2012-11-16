//
//  MessageCellContent.m
//  Postadvert
//
//  Created by Mtk Ray on 6/18/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "MessageCellContent.h"
#import "NSData+Base64.h"
#import "CredentialInfo.h"

@implementation MessageCellContent

@synthesize  userAvatar,userPostName,text, datePost, imageAttachment;


@synthesize msg_id;
@synthesize parent_id;
@synthesize subject;
@synthesize partners;
@synthesize created;
@synthesize is_read;
@synthesize messageThumbURL;
- (id) initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        @try {
            self.msg_id = [[dict objectForKey:@"msg_id"] integerValue];
            self.parent_id = [[dict objectForKey:@"id"] integerValue];
            self.subject = [NSData stringDecodeFromBase64String: [dict objectForKey:@"subject"]];
            self.partners = [[NSMutableArray alloc]init];
            NSArray *listParners = [dict objectForKey:@"partners"];
            for (NSDictionary *dict in listParners) {
                CredentialInfo *aPartner = [[CredentialInfo alloc]init];
                aPartner.registrationID = [[dict objectForKey:@"id"]integerValue];
                aPartner.fullName = [dict objectForKey:@"name"];
                aPartner.avatarUrl = [dict objectForKey:@"thumb"];
                [self.partners addObject:aPartner];
            }
            listParners = nil;
            self.created = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
            self.is_read = [[dict objectForKey:@"is_read"] boolValue];
            self.userPostName = @"";
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
    }
    [self parseDataWithOption:1];
    return self;
}

- (void) parseDataWithOption:(NSInteger) opt
{
    //parse for quickly preview
    if (opt == 1) {
        //self.userPostName
        for (CredentialInfo* apartner in self.partners) {
            self.userPostName = [self.userPostName stringByAppendingFormat:@"%@, ", apartner.fullName];
        }
        @try {
            self.userPostName = [self.userPostName substringToIndex:self.userPostName.length - 2];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
        //text
        self.text = self.subject;
        //thumURL
        self.messageThumbURL = [(CredentialInfo*)[self.partners lastObject] avatarUrl];
    }
}


@end

//
//[msg_id] => 111//cai nay anh tra len lai cho em luc goi ham nay
//            [id] => 22//day la parent_id, luc goi ham getConversation a dua len cho e
//            [subject] => UkU6aGo=
//            [partners] => Array//danh sach nhung nguoi co trong tn
//                (
//                                     [0] => stdClass Object
//                                         (
//                                                                      [id] => 95
//                                                                      [name] => david nguyen
//                                                                      [thumb] => http://stroff.com/images/avatar/thumb_2092c3d688417681157a4ef0.jpg
//                                                                  )
//
//                                 )
//
//            [created] => MyBkYXlzIGFnbw==
//            [is_read] => 0


/*

 NSString *dateString = @"01-02-2010";
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 // this is imporant - we set our input date format to match our input string
 // if format doesn't match you'll get nil from your string, so be careful
 [dateFormatter setDateFormat:@"dd-MM-yyyy"];
 NSDate *dateFromString = [[NSDate alloc] init];
 // voila!
 dateFromString = [dateFormatter dateFromString:dateString];
 [dateFormatter release];
 NSDate convert to NSString:
 
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 [dateFormatter setDateFormat:@"dd-MM-yyyy"];
 NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
 NSLog(@"%@", strDate);
 [dateFormatter release];
 
 
 ///////
 
 NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
 [dateFormat setDateFormat:@"yyyy-MM-dd"];
 
 NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
 [timeFormat setDateFormat:@"HH:mm:ss"];
 
 NSDate *now = [[NSDate alloc] init];
 
 NSString *theDate = [dateFormat stringFromDate:now];
 NSString *theTime = [timeFormat stringFromDate:now];
 
 NSLog(@"\n"
 "theDate: |%@| \n"
 "theTime: |%@| \n"
 , theDate, theTime);
 
 [dateFormat release];
 [timeFormat release];
 [now release];
 
 //////
 
 
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 [dateFormatter setDateFormat:@"EEEE"];
 NSString *dayName = [dateFormatter stringFromDate:yourDate];
 [dateFormatter release];
 
 ////////
*/


/*

 
 I had this problem a while back, and I created the following methods to make everything easier.
 
 Definitions
 
 #define DATE_TYPE_hhmmss [NSArray arrayWithObjects:@"h", @"m", @"s", nil]
 #define DATE_TYPE_MMDDYYYY [NSArray arrayWithObjects:@"M", @"D", @"Y", nil]
 #define DATE_TYPE_MMDDYYYYhhmmss [NSArray arrayWithObjects:@"M", @"D", @"Y", @"h", @"m", @"s", nil]
 #define DATE_TYPE_MMDDYYYYWWhhmmss [NSArray arrayWithObjects:@"M", @"D", @"Y", @"W", @"h", @"m", @"s", nil]
 #define DATE_TYPE_MMDDYYYYhhmmssWW [NSArray arrayWithObjects:@"M", @"D", @"Y", @"h", @"m", @"s", @"W", nil]
 #define DATE_TYPE_YYYYMMDD [NSArray arrayWithObjects:@"Y", @"M", @"D", nil]
 #define DATE_TYPE_YYYYMMDDhhmmss [NSArray arrayWithObjects:@"Y", @"M", @"D", @"h", @"m", @"s", nil]
 #define DATE_TYPE_YYYYMMDDWWhhmmss [NSArray arrayWithObjects:@"Y", @"M", @"D", @"W", @"h", @"m", @"s", nil]
 #define DATE_TYPE_YYYYMMDDhhmmssWW [NSArray arrayWithObjects:@"Y", @"M", @"D", @"h", @"m", @"s", @"W", nil]
 #define DATE_TYPE_FRIENDLY [NSArray arrayWithObjects:@"xx", nil]
 Date Methods
 
 Create Date From Values
 
 -(NSDate *) getDateWithMonth:(int)month day:(int)day year:(int)year {
 NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
 NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
 NSDateComponents * dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
 
 [dateFormatter setDateFormat:@"MM"];
 [dateComponents setMonth:month];
 [dateFormatter setDateFormat:@"DD"];
 [dateComponents setDay:day];
 [dateFormatter setDateFormat:@"YYYY"];
 [dateComponents setYear:year];
 
 NSDate * result = [calendar dateFromComponents:dateComponents];
 
 return result;
 }
 
 -(NSDate *) getDateWithMonth:(int)month day:(int)day year:(int)year hour:(int)hour minute:(int)minute {
 NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
 NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
 NSDateComponents * dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
 
 [dateFormatter setDateFormat:@"MM"];
 [dateComponents setMonth:month];
 [dateFormatter setDateFormat:@"DD"];
 [dateComponents setDay:day];
 [dateFormatter setDateFormat:@"YYYY"];
 [dateComponents setYear:year];
 [dateFormatter setDateFormat:@"HH"];
 [dateComponents setHour:hour];
 [dateFormatter setDateFormat:@"MM"];
 [dateComponents setMinute:minute];
 
 NSDate * result = [calendar dateFromComponents:dateComponents];
 
 return result;
 }
 
 -(NSDate *) getDateWithMonth:(int)month day:(int)day year:(int)year hour:(int)hour minute:(int)minute second:(int)second {
 NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
 NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
 NSDateComponents * dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
 
 [dateFormatter setDateFormat:@"MM"];
 [dateComponents setMonth:month];
 [dateFormatter setDateFormat:@"DD"];
 [dateComponents setDay:day];
 [dateFormatter setDateFormat:@"YYYY"];
 [dateComponents setYear:year];
 [dateFormatter setDateFormat:@"HH"];
 [dateComponents setHour:hour];
 [dateFormatter setDateFormat:@"MM"];
 [dateComponents setMinute:minute];
 [dateFormatter setDateFormat:@"SS"];
 [dateComponents setSecond:second];
 
 NSDate * result = [calendar dateFromComponents:dateComponents];
 
 return result;
 }
 Get String From Date
 
 -(NSString *) getStringFromDate:(NSDate *)date dateType:(NSArray *)dateType {
 NSString * result = @"";
 
 NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
 NSString * format = @"";
 
 NSDateComponents * dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit) fromDate:date];
 
 NSInteger year = [dateComponents year];
 NSInteger month = [dateComponents month];
 NSInteger day = [dateComponents day];
 NSInteger weekday = [dateComponents weekday];
 NSInteger hour = [dateComponents hour];
 NSInteger minute = [dateComponents minute];
 NSInteger second = [dateComponents second];
 
 if (dateType != nil) {
 for (int x = 0; x < [dateType count]; x++) {
 if (x == ([dateType count]-1)) {
 if ([[dateType objectAtIndex:x] isEqualToString:@"Y"]) {
 format = [format stringByAppendingFormat:@"%d", year];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"M"]) {
 format = [format stringByAppendingFormat:@"%d", month];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"D"]) {
 format = [format stringByAppendingFormat:@"%d", day];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"W"]) {
 format = [format stringByAppendingFormat:@"%d", weekday];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"h"]) {
 format = [format stringByAppendingFormat:@"%d", hour];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"m"]) {
 format = [format stringByAppendingFormat:@"%d", minute];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"s"]) {
 format = [format stringByAppendingFormat:@"%d", second];
 }
 } else {
 if ([[dateType objectAtIndex:x] isEqualToString:@"Y"]) {
 format = [format stringByAppendingFormat:@"%d|", year];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"M"]) {
 format = [format stringByAppendingFormat:@"%d|", month];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"D"]) {
 format = [format stringByAppendingFormat:@"%d|", day];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"W"]) {
 format = [format stringByAppendingFormat:@"%d|", weekday];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"h"]) {
 format = [format stringByAppendingFormat:@"%d|", hour];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"m"]) {
 format = [format stringByAppendingFormat:@"%d|", minute];
 } else if ([[dateType objectAtIndex:x] isEqualToString:@"s"]) {
 format = [format stringByAppendingFormat:@"%d|", second];
 }
 }
 
 if ([[dateType objectAtIndex:x] isEqualToString:@"xx"]) {
 format = [NSString stringWithFormat:@"Year: %d, Month: %d, Day: %d, Weekday: %d, Hour: %d, Minute: %d, Second: %d", year, month, day, weekday, hour, minute, second];
 }
 }
 } else {
 format = [format stringByAppendingFormat:@"%d|", year];
 format = [format stringByAppendingFormat:@"%d|", month];
 format = [format stringByAppendingFormat:@"%d|", day];
 format = [format stringByAppendingFormat:@"%d|", weekday];
 format = [format stringByAppendingFormat:@"%d|", hour];
 format = [format stringByAppendingFormat:@"%d|", minute];
 format = [format stringByAppendingFormat:@"%d|", second];
 
 format = [NSString stringWithFormat:@"%d|%d|%d|%d|%d|%d|%d", year, month, day, weekday, hour, minute, second];
 }
 
 result = format;
 
 return result;
 }
 Example
 
 NSDate * date = [self getDateWithMonth:12 day:24 year:1994];
 NSString * dateInString = [self getStringFromDate:date dateType:DATE_TYPE_MMDDYYYY];
 
 int month = [[[dateInString componentsSeparatedByString:@"|"] objectAtIndex:0] intValue];
 int day = [[[dateInString componentsSeparatedByString:@"|"] objectAtIndex:1] intValue];
 int year = [[[dateInString componentsSeparatedByString:@"|"] objectAtIndex:2] intValue];
 
 NSLog(@"String of Date: \"%@\"", dateInString);
 NSLog(@"Month: %d", month);
 NSLog(@"Day: %d", day);
 NSLog(@"Year: %d", year);
 The method [self getDateWithMonth:12 day:24 year:1994] returns an NSDate object which is usually hard to read, so you can use [self getStringFromDate:date dateType:DATE_TYPE_MMDDYYYY] to get a string of an NSDate object.
 
 Use the definitions (macros) to specify the format of the date you would like to get in the string.
 
 For example: DATE_TYPE_hhmmss would return the Hour|Minute|Second, DATE_TYPE_MMDDYYYY would return the Month|Day|Year, DATE_TYPE_MMDDYYYYhhmmss would return the Month|Day|Year|Hour|Minute|Second, DATE_TYPE_MMDDYYYYWWhhmmss would return the Month|Day|Year|Weekday (#)|Hour|Minute|Second
 
 and so on...
 
 Console Log
 
 2012-04-29 13:42:15.791 Atomic Class[1373:f803] String of Date: "12|24|1994"
 2012-04-29 13:42:15.793 Atomic Class[1373:f803] Month: 12
 2012-04-29 13:42:15.794 Atomic Class[1373:f803] Day: 24
 2012-04-29 13:42:15.794 Atomic Class[1373:f803] Year: 1994
*/