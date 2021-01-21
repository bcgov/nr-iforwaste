//
//  AggregatePileTableViewCell.m
//  WasteMobile
//
//  Created by Sweta Kutty on 2020-02-26.
//  Copyright © 2020 Salus Systems. All rights reserved.
//
#import "AggregatePileTableViewCell.h"

@implementation AggregatePileTableViewCell

@synthesize deleteButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
