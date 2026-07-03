//
//  NumberInputTableViewCell.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-05.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "NumberInputTableViewCell.h"

@implementation NumberInputTableViewCell

@synthesize numberField;

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
    // Disable the small popover layout on the numberField asset
       if (@available(iOS 26.0, *)) {
           self.numberField.allowsNumberPadPopover = NO;
       } else {
           // This implicit block automatically handles older iOS versions safely
           // and ignores the new property entirely, preventing runtime crashes!
       }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
