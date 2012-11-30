//
//  UploadImagesViewController.h
//  Stroff
//
//  Created by Ray on 11/29/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadImagesViewController : UIViewController
<UIAlertViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    UIAlertView *_alertView;
    NSInteger currentIndex;
    BOOL    isUploading;
    NSInteger currentDataLength;
    NSMutableData *reciveData;
    BOOL isSuccess;
}
@property (nonatomic)   NSInteger postID;
@property (nonatomic, strong)     NSArray *listImageNeedToPost;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;

- (IBAction)retryBtnClicked:(id)sender;

- (IBAction)cancelBtnClicked:(id)sender;

-(void) uploadtoPost:(NSInteger)postID withListImages:(NSArray*)listImages;
-(void) uploadImage;

@end
