//
//  KTThumbView+SDWebImage.h
//  Sample
//
//  Created by Henrik Nyh on 3/18/10.
//

#import "KTThumbView.h"
#import "SDWebImageManagerDelegate.h"

@interface  KTThumbView (SDWebImage) <SDWebImageManagerDelegate>

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)setImageWithFullImageURL:(NSURL *)fullURL_ thumbURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end
