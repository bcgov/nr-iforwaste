//
//  TextInputTableViewCell.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-05.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "TextInputTableViewCell.h"

@implementation TextInputTableViewCell

@synthesize textField;

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
