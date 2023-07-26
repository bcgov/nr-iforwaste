//
//  AggregatePlotTableViewCell.h
//  EForWasteBC
//
//  Created by Chris Nesmith on 4/25/19.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AggregatePlotTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *plotNumber;
@property (weak, nonatomic) IBOutlet UILabel *license;
@property (weak, nonatomic) IBOutlet UILabel *blockId;
@property (weak, nonatomic) IBOutlet UILabel *cuttingPermit;
@property (weak, nonatomic) IBOutlet UILabel *baseline;
@property (weak, nonatomic) IBOutlet UILabel *strip;
@property (weak, nonatomic) IBOutlet UILabel *measure;
@property (weak, nonatomic) IBOutlet UILabel *shape;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
