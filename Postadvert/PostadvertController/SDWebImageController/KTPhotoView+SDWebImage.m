//
//  KTPhotoView+SDWebImage.m
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTPhotoView+SDWebImage.h"
#import "SDWebImageManager.h"

@implementation KTPhotoView (SDWebImage)

- (void)setImageWithURL:(NSURL *)url {
   [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
   SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [activityView_ setHidden:NO];
    [activityView_ startAnimating];
   // Remove in progress downloader from queue
   [manager cancelForDelegate:self];
   
   UIImage *cachedImage = nil;
   if (url) {
     cachedImage = [manager imageWithURL:url];
   }
   
   if (cachedImage) {
       [activityView_ stopAnimating];
      [self setImage:cachedImage];
   }
   else {
      if (placeholder) {
         [self setImage:placeholder];
      }
      
      if (url) {
        [manager downloadWithURL:url delegate:self];
      }
   }
}
- (void)setImageWithURL:(NSURL *)url placeholderURL:(NSURL *)placeholderURL placeholderImage:(UIImage *)placeholderImage {
    
    //[self setImageWithURL:url placeholderImage:placeholderImage];
    //return;
    [activityView_ setHidden:NO];
    [activityView_ startAnimating];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    UIImage *cachedImage = nil;
    if (url) {
        cachedImage = [manager imageWithURL:url];
    }
    
    if (cachedImage) {
        [activityView_ stopAnimating];
        [self setImage:cachedImage];
    }
    else {
        
        if (placeholderURL) {
            //Load Thumbnail
            cachedImage = [manager imageWithURL:placeholderURL];
            if (cachedImage) {
                [self setImage:cachedImage];
            }else
                if (placeholderImage) {
                    //Set temp-image while load URL-Image
                    [self setImage:placeholderImage];
                }
        }
        //Download Image
        if (url) {
            [manager downloadWithURL:url delegate:self];
        }
    }
}


- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
   [activityView_ stopAnimating];
   [self setImage:image];
}


@end