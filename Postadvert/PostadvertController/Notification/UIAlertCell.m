//
//  UIAlertCell.m
//  Postadvert
//
//  Created by Mtk Ray on 6/27/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "UIAlertCell.h"

@interface  UIAlertCell ()
- (IBAction)btnConfirmClicked:(id)sender;
- (IBAction)btnNotNowClicked:(id)sender;
@end

@implementation UIAlertCell
@synthesize imageAvatar, userName, mutiFriends, btnNotNow, btnConfirm;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UIAlertCell" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    self = [topLevelObjects objectAtIndex:0];
    topLevelObjects = nil;
    if (!self) {
        // Initialization code
        self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - ACTION

-(IBAction)btnNotNowClicked:(id)sender
{
    self.message.text = @"Friend request hidden";
    if ([self.delegate respondsToSelector:@selector(didRespondRequest:)]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.connection_id], @"connection_id", @"-1" , @"respond_type", nil];
        [self.delegate performSelector:@selector(didRespondRequest:) withObject:dict];
    }
}
-(IBAction)btnConfirmClicked:(id)sender
{
    self.btnConfirm.hidden = YES;
    self.btnNotNow.hidden = YES;
    self.mutiFriends.hidden = YES;
    self.message.text = @"You are friends now.";
    //friendRequestRespond($connection_id, $respond_type) {
    //respond type = 1 (approve) or -1 (remove)
    //respond_type
    if ([self.delegate respondsToSelector:@selector(didRespondRequest:)]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.connection_id], @"connection_id", @"1" , @"respond_type", nil];
        [self.delegate performSelector:@selector(didRespondRequest:) withObject:dict];
    }
}
- (IBAction)btnUserNameCliked:(id)sender {
    
    if ([self.delegate performSelector:@selector(didTapOnCustomLink)]) {
        [self.delegate didTapOnCustomLink];
    }
}
@end
