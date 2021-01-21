//
//  TimbermarkTableViewCell.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-09.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "TimbermarkTableViewCell.h"

@implementation TimbermarkTableViewCell

@synthesize timbermark, area, primary, reductionFactor, aValue, bValue, wmrf;

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
