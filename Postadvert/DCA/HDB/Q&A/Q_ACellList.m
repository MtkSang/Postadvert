//
//  Q_ACellList.m
//  Stroff
//
//  Created by Ray on 7/16/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "Q_ACellList.h"

@implementation Q_ACellList

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
