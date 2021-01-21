//
//  StratumTableViewCell.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-12.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "StratumTableViewCell.h"

@implementation StratumTableViewCell

@synthesize wasteLevel = _wasteLevel;
@synthesize wasteType = _wasteType;
@synthesize area = _area;
@synthesize harvestMethod = _harvestMethod;
@synthesize stratumType = _stratumType;
@synthesize plotSize = _plotSize;

@synthesize stratum = _stratum;
@synthesize stratumID = _stratumID;
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
