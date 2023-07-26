//
//  AggregatePlotTableViewCell.m
//  EForWasteBC
//
//  Created by Chris Nesmith on 4/25/19.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "AggregatePlotTableViewCell.h"

@implementation AggregatePlotTableViewCell
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
