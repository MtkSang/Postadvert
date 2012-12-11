//
//  UIAlertCell.h
//  Postadvert
//
//  Created by Mtk Ray on 6/27/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIAlertCellDelegate;

@interface UIAlertCell : UITableViewCell

@property (nonatomic)       NSInteger connection_id;
@property(nonatomic, weak) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UIButton *userName;
@property(nonatomic, weak) IBOutlet UILabel      *mutiFriends;
@property (weak, nonatomic) IBOutlet UILabel     *message;
@property(nonatomic, weak) IBOutlet UIButton     *btnConfirm;
@property(nonatomic, weak) IBOutlet UIButton     *btnNotNow;
- (IBAction)btnUserNameCliked:(id)sender;
@property(nonatomic, weak) IBOutlet id<UIAlertCellDelegate> delegate;
@end

@protocol UIAlertCellDelegate <NSObject>

- (void) didTapOnCustomLink;
- (void) didRespondRequest:(NSDictionary*)dictValue;

@end
