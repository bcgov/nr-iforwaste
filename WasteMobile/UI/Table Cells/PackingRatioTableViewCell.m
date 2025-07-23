//
//  PackingRatioTableViewCell.m
//  WasteMobile
//
//  Created by Michael Tennant on 2023-07-25.
//  Copyright © 2023 Salus Systems. All rights reserved.
//

#import "PackingRatioTableViewCell.h"

@implementation PackingRatioTableViewCell
@synthesize deleteButtonPR;

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
