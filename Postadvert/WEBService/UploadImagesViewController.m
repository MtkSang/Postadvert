//
//  UploadImagesViewController.m
//  Stroff
//
//  Created by Ray on 11/29/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "UploadImagesViewController.h"
#import "NSData+Base64.h"
#import "Constants.h"
#import "PostadvertControllerV2.h"
#import "TouchXML.h"
#import "SBJson.h"


@interface UploadImagesViewController ()

@end

@implementation UploadImagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isSuccess = YES;
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - implement

-(void) uploadtoPost:(NSInteger)postID withListImages:(NSArray*)listImages
{
    self.postID = postID;
    self.listImageNeedToPost = [[NSArray alloc]initWithArray:listImages];
    currentIndex = 0;
    isUploading = YES;
    isSuccess = YES;
    self.progressView.progress = 0;
    self.retryBtn.hidden = YES;
    //[self performSelectorInBackground:@selector(uploadImage) withObject:nil];
    [self uploadImage];
    
}

- (void) updateViewWithState
{
    if (isSuccess) {
        isUploading = NO;
        //sleep(1);
        self.view.hidden = YES;
    }else
    {
        isUploading = NO;
        self.view.hidden = YES;
    }
}
-(void) uploadImage
{
    if (currentIndex >= self.listImageNeedToPost.count) {
        isSuccess = YES;
        [_alertView dismissWithClickedButtonIndex:[_alertView cancelButtonIndex] animated:YES];
        [self.cancelBtn setImage:[UIImage imageNamed:@"icon_valid_1.png"] forState:UIControlStateNormal];
        self.cancelBtn.enabled = NO;
        [self.cancelBtn setNeedsDisplay];
        [self performSelector:@selector(updateViewWithState) withObject:nil afterDelay:1];
        return;
    }
    [self.cancelBtn setImage:[UIImage imageNamed:@"error_icon.png"] forState:UIControlStateNormal];
    self.cancelBtn.enabled = YES;
    self.retryBtn.hidden = YES;
    isSuccess = YES;
    isUploading = YES;
    NSString *functionName;
    NSArray *paraNames;
    NSMutableArray *paraValues;
    NSString *parametterString = @"";
    ////uploadPostImage($imageString, $post_id, $folder = '')
    functionName = @"uploadPostImage";
    
    NSData *imageData = [[NSData alloc]initWithContentsOfFile:[self.listImageNeedToPost objectAtIndex:currentIndex]];
    self.imageView.image = [UIImage imageWithData:imageData];
    NSString *encodedImage = [imageData base64EncodedString];
    paraNames = [NSArray arrayWithObjects:@"imageString", @"post_id",nil];
    paraValues = [NSMutableArray arrayWithObjects:encodedImage, [NSString stringWithFormat:@"%d", self.postID],  nil];
    int count = 0;
    for (NSString* ns1 in paraNames) {
        NSString *parametterStr = [NSString stringWithFormat:@"<%@>%@</%@>", ns1, [paraValues objectAtIndex:count], ns1];
        parametterString = [parametterString stringByAppendingString:parametterStr];
        count ++;
    }
    
    //ShowNetworkActivityIndicator();
    //[PostadvertControllerV2 sharedPostadvertController].remainCount ++;
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
    
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc]initWithURL:locationOfWebService];
    NSString *msgLength = [NSString stringWithFormat:@"%d",[soapFormat length]];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue:@"" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[soapFormat dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setTimeoutInterval:10*60];
    
//    NSURLResponse *response;
//    NSError *error;
//    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
//    //NSString *results = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",error);
//    CXMLDocument *doc = [[CXMLDocument alloc] initWithData:data options:0 error:nil];
//    NSArray *nodes = NULL;
//    //  searching for return nodes (return from WS)
//    nodes = [doc nodesForXPath:@"//return" error:nil];
//    //Get info
//    SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
//    id jsonObject;
//    for (CXMLElement *node in nodes) {
//        jsonObject = [jsonParser objectWithString:node.stringValue];
//    }
//    NSDictionary *infoDict;
//    NSArray *infoArray;
//    if ([jsonObject isKindOfClass:[NSDictionary class]])
//    {
//        infoDict = [NSDictionary dictionaryWithDictionary: jsonObject];
//        NSData *imageData = [NSData dataFromBase64String:[infoDict objectForKey:@"image"]];
//        UIImage *image = [UIImage imageWithData:imageData];
//        dispatch_async(dispatch_get_main_queue(), ^{
//        
//        self.imageView.image = image;
//
//        });
//        
//    }
//    else if ([jsonObject isKindOfClass:[NSArray class]])
//    {
//        infoArray = [NSArray arrayWithArray:jsonObject];
//         NSDictionary *dict = [infoArray objectAtIndex:0];
//        UIImage *image = [UIImage imageWithData:[dict objectForKey:@"image"]];
//        self.imageView.image = image;
//    }
//    
   
    
    
    
    myConnection = [[NSURLConnection alloc]initWithRequest:theRequest delegate:self startImmediately:YES];
    if (myConnection) {
        NSLog(@"Connection OK");
        reciveData = [[NSMutableData alloc]init];
    }
    else {
        NSLog(@"No Connection established");
    }
    
    
}

- (void) cancelPost
{
    //deleteEasyPost($post_id)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    functionName = @"deleteEasyPost";
    paraNames = [NSArray arrayWithObjects:@"post_id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", self.postID], nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];
    @try {
        NSInteger errorCode = [[data objectForKey:@"error_code"] integerValue];
        if (errorCode == 0) {
            //has a error
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Cancel Upload" message:@"Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
    @catch (NSException *exception) {
    }
    
}

- (IBAction)retryBtnClicked:(id)sender {
    [self uploadImage];
}

- (IBAction)cancelBtnClicked:(id)sender {
    _alertView = [[UIAlertView alloc]initWithTitle:@"Cancel Upload" message:@"Are you sure you want to cancel your upload?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [_alertView show];
}

#pragma mark -AlertDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"Cancel a post");
        [myConnection cancel];
        [self performSelectorInBackground:@selector(cancelPost) withObject:nil];
        
        [self updateViewWithState];
    }
}

#pragma mark NSURLConnectionDelegate Protocol
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    isUploading = NO;
    //Update error icon
    [self.cancelBtn setImage:[UIImage imageNamed:@"fail_icon.png"] forState:UIControlStateNormal];
    self.retryBtn.hidden = NO;
    isSuccess = NO;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    currentIndex ++;
    [self uploadImage];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [reciveData appendData:data];
}

#pragma mark NSURLConnectionDownloadDelegate

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    float percentage = (float)currentIndex / (self.listImageNeedToPost.count * 1.0f);
    float increasePercent = (((float)totalBytesWritten / (1.0f * expectedTotalBytes))) / (1.0f * self.listImageNeedToPost.count);
    
    percentage += increasePercent;
    [self.progressView setProgress:percentage ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:percentage animated:YES];
        [self.progressView setNeedsDisplay];
    });
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    currentIndex ++;
    CXMLDocument *doc = [[CXMLDocument alloc] initWithData:reciveData options:0 error:nil];
    NSLog(@"%@", doc);
    
    doc = [[CXMLDocument alloc] initWithData:[NSData dataWithContentsOfURL:destinationURL] options:0 error:nil];
    NSLog(@"%@", doc);
    reciveData = [[NSMutableData alloc]init];
    [self uploadImage];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@", response);
    [reciveData setLength:0];
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    float percentage = (float)currentIndex / (self.listImageNeedToPost.count * 1.0f);
    float increasePercent = (((float)totalBytesWritten / (1.0f * totalBytesExpectedToWrite))) / (1.0f * self.listImageNeedToPost.count);
    
    percentage += increasePercent;
    [self.progressView setProgress:percentage ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:percentage animated:YES];
        [self.progressView setNeedsDisplay];
    });
    
}


@end
