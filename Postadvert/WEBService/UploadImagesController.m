//
//  UploadImagesController.m
//  Stroff
//
//  Created by Ray on 11/29/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "UploadImagesController.h"
#import "Constants.h"
#import "PostadvertControllerV2.h"

@implementation UploadImagesController


- (void) uploadWithPostID:(NSInteger)postID ListImages:(NSArray*)listImage progressBar:(UIProgressView*)progressView andCancelButton:(UIButton*)cancelbtn
{
    self.postID = postID;
    self.listImageNeedToPost = [NSArray arrayWithArray:listImage];
    self.progressBar = progressView;
    self.cancelBtn = cancelbtn;
    
    //uploadPostImage($imageString, $post_id, $folder = '')
    ShowNetworkActivityIndicator();
    [PostadvertControllerV2 sharedPostadvertController].remainCount ++;
    
    NSString *functionName = @"uploadPostImage";
    NSString *parametterString = @"";
    NSString *soapFormat = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                            @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                            @"<soap:Body>"
                            @"<%@ xmlns=\"http://stroff.com/ws/server_side/\">"
                            @"%@"
                            @"</%@>"
                            @"</soap:Body>"
                            @"</soap:Envelope>",functionName, parametterString, functionName];
    
    
    
    
    
    //NSLog(@"The request format is: \n%@",soapFormat);
    
    NSURL *locationOfWebService = [NSURL URLWithString:@"http://stroff.com/ws/server_side/api.php?wsdl"];
    //NSLog(@"web url = %@",locationOfWebService);
    
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc]initWithURL:locationOfWebService];// cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4];
    [theRequest setTimeoutInterval:120];
    NSString *msgLength = [NSString stringWithFormat:@"%d",[soapFormat length]];
    
    
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:@"" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    //the below encoding is used to send data over the net
    [theRequest setHTTPBody:[soapFormat dataUsingEncoding:NSUTF8StringEncoding]];

}

@end
