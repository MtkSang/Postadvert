//
//  TestWebService.m
//  SupplyChainAsia
//
//  Created by Ray on 11/15/12.
//  Copyright (c) 2012 TuanPH. All rights reserved.
//

#import "TestWebService.h"

@implementation TestWebService


-(void) testFunction
{
    NSMutableURLRequest  *theRequest =
    [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:@"http://api.supplychainasia.org/users/authenticate.json?key=90bf4f08f12279ed4ebf6a7b5893ac3eda06c554"]
                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                         timeoutInterval:10.0];
    
    [theRequest setHTTPMethod:@"POST"];
    
    // NSLog(@"username=%@&password=%@",username.text, password.text);
    [theRequest setHTTPBody:[ [NSString stringWithFormat:@"username=%@&password=%@",@"fanhaijun", @"123123"]  dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    
    if (theConnection) {
        
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        
        receivedData = [NSMutableData data] ;
        
    } else {
        
        // Inform the user that the connection failed.
        
        UIAlertView *connectFailMessage = [[UIAlertView alloc] initWithTitle:@"Error " message:@"Connection to Server Failed."  delegate: self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [connectFailMessage show];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    // receivedData is declared as a method instance elsewhere
    
    //[connection release];
    //[receivedData release];
    //[indicator stopAnimating];
    // inform the user
    UIAlertView *didFailWithErrorMessage = [[UIAlertView alloc] initWithTitle: @"Error " message: @"Connection to Server Failed."  delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [didFailWithErrorMessage show];
    //  [didFailWithErrorMessage release];
    
    //inform the user
    // NSLog(@"Connection failed! Error - %@ %@",
    //[error localizedDescription],
    //[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    
    NSString *dataString = [[NSString alloc] initWithData: receivedData  encoding:NSStringEncodingConversionAllowLossy];
    
    NSLog(@"%@",dataString);
    
    
}


@end
