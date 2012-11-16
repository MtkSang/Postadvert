//
//  TestWebService.h
//  SupplyChainAsia
//
//  Created by Ray on 11/15/12.
//  Copyright (c) 2012 TuanPH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestWebService : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate>
{
    NSMutableData *receivedData;
}
-(void) testFunction;
@end
