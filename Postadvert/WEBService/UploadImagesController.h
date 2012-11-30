//
//  UploadImagesController.h
//  Stroff
//
//  Created by Ray on 11/29/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadImagesController : NSObject <NSURLConnectionDownloadDelegate, NSURLConnectionDelegate>
{
    
}
@property (nonatomic)   NSInteger postID;
@property (nonatomic, strong)     NSArray *listImageNeedToPost;
@property (nonatomic, weak)     UIProgressView *progressBar;
@property (nonatomic, weak)     UIButton    *cancelBtn;


//--
- (void) uploadWithRequest:(NSMutableURLRequest*)request ListImages:(NSArray*)listImage progressBar:(UIProgressView*)progressView andCancelButton:(UIButton*)cancelbtn;
@end
