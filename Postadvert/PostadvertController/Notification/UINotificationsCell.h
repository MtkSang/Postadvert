//
//  UINotificationsCell.h
//  Stroff
//
//  Created by Ray on 12/6/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
@class NotificationsCellContent;
@protocol UINotificationsCellDelegate;

@interface UINotificationsCell : UITableViewCell <OHAttributedLabelDelegate>

@property (nonatomic, strong) NotificationsCellContent *content;
@property (weak, nonatomic) IBOutlet UIImageView *userAvartar;
@property (weak, nonatomic) IBOutlet OHAttributedLabel *text;
@property (weak, nonatomic) IBOutlet UILabel *created;
@property (weak, nonatomic) IBOutlet UIImageView *actionIcon;
@property (weak, nonatomic) IBOutlet id<UINotificationsCellDelegate> delegate;

- (id) initWithNib;
-(void) setContent:(NotificationsCellContent*)content;
-(void) updateValueForControl;
@end

@protocol UINotificationsCellDelegate <NSObject>

- (void) didTapOnCustomLink;

@end