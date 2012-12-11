//
//  UINotificationsCell.m
//  Stroff
//
//  Created by Ray on 12/6/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "UINotificationsCell.h"
#import "NotificationsCellContent.h"
#import "UIImageView+URL.h"
@implementation UINotificationsCell

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id) initWithNib
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UINotificationsCell" owner:self options:nil];
    self = [topLevelObjects objectAtIndex:0];
    topLevelObjects = nil;
    if (self) {
        // Initialization code
        _userAvartar = (UIImageView*)[self viewWithTag:1];
        _text = (OHAttributedLabel*)[self viewWithTag:2];
        _created = (UILabel*)[self viewWithTag:3];
        _actionIcon = (UIImageView*)[self viewWithTag:4];
        _text.underlineLinks = NO;
        _text.linkColor = [UIColor blueColor];
        _text.delegate = self;
    }

    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setContent:(NotificationsCellContent*)content
{
    _content = content;
    [self updateValueForControl];
    [self setLinkForText];
}

-(void) updateValueForControl
{
    if (_content == nil) {
        return;
    }

    _text.text = _content.fullText;
    _created.text = _content.created;
    [_userAvartar setImageWithURL:[NSURL URLWithString:_content.actor_thumb]];
    if (_content.is_read) {
        self.contentView.backgroundColor = [UIColor clearColor];
    }else
        self.contentView.backgroundColor = [UIColor colorWithRed:225/255.0 green:245/255.0 blue:245/255.0 alpha:0.5];
    NSRange range = [_content.action_string rangeOfString:@"clapped"];
    if (range.length) {
        _actionIcon.image = [UIImage imageNamed:@"clap_icon.png"];
    }else
        _actionIcon.image = [UIImage imageNamed:@"comment_notification_icon.png"];
}

-(void) setLinkForText
{
    NSString *str = [_content.wall_name stringByReplacingOccurrencesOfString:@" " withString:@"=="];
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"localStroff://wall__%d__%@",_content.wall_ID, str]];
    NSURL *urlUerProfile = [[NSURL alloc]initWithString:[NSString stringWithFormat: @"localStroff://user__%d", self.content.actor_ID]];
    
    NSRange rang = [_content.fullText rangeOfString:_content.wall_name options:NSBackwardsSearch];
    [_text addCustomLink:url inRange:rang];
    [_text addCustomLink:urlUerProfile inRange:[_text.text rangeOfString:_content.actor_fullName]];
    
}

#pragma mark OHAttributedLabelDelegate

-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didTapOnCustomLink)] ) {
            [self.delegate didTapOnCustomLink];
        }
    }
    [[NSUserDefaults standardUserDefaults] setURL:linkInfo.URL forKey:@"openURL"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openURL" object:nil];
    return NO;
}

@end
