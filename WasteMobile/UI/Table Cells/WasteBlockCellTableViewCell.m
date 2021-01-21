//
//  WasteBlockCellTableViewCell.m
//  WasteMobile
//
//  Created by Salus
//

#import "WasteBlockCellTableViewCell.h"

@implementation WasteBlockCellTableViewCell

@synthesize licenceNoLabel = _licenceNoLabel;
@synthesize cuttingPermitLabel = _cuttingPermitLabel;
@synthesize blockLabel = _blockLabel;
@synthesize timberMarkLabel = _timberMarkLabel;
@synthesize exemptedLabel = _exemptedLabel;
@synthesize netAreaLabel = _netAreaLabel;
@synthesize blockStatusLabel = _blockStatusLabel;
@synthesize loadingWheel;

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
