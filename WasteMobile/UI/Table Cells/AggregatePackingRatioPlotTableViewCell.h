//
//  AggregatePackingRatioPlotTableViewCell.h
//  WasteMobile
//
//  Created by Michael Tennant on 2023-07-25.
//  Copyright © 2023 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AggregatePackingRatioPlotTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *plotNumberAPR;
@property (weak, nonatomic) IBOutlet UILabel *licenceAPR;
@property (weak, nonatomic) IBOutlet UILabel *cuttingPermitAPR;
@property (weak, nonatomic) IBOutlet UILabel *blockIdAPR;
@property (weak, nonatomic) IBOutlet UIButton *deleteButtonAPR;

@end
