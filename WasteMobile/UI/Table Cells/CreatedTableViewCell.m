//
//  CreatedTableViewCell.m
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-03.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import "CreatedTableViewCell.h"

@implementation CreatedTableViewCell

@synthesize licenceNoLabel = _licenceNoLabel;
@synthesize cuttingPermitLabel = _cuttingPermitLabel;
@synthesize blockLabel = _blockLabel;
@synthesize timberMarkLabel = _timberMarkLabel;
@synthesize exemptedLabel = _exemptedLabel;
@synthesize netAreaLabel = _netAreaLabel;
@synthesize loadingWheel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
