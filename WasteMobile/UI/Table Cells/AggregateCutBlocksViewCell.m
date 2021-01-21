//
//  AggregateCutBlocksViewCell.m
//  EForWasteBC
//
//  Created by Chris Nesmith on 3/11/19.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "AggregateCutBlocksViewCell.h"

@implementation AggregateCutBlocksViewCell

@synthesize cutBlockNo = _cutBlockNo;
@synthesize cutBlockId = _cutBlockId;
@synthesize cutBlockArea = cutBlockArea;
@synthesize cutBlockLicense = _cutBlockLicense;
@synthesize cutBlockPredPlot = _cutBlockPredPlot;
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
