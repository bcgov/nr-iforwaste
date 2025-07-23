//
//  PlotTableViewCell.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-12.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlotTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *isPlotAudited;
@property (weak, nonatomic) IBOutlet UILabel *plotNumber;
@property (weak, nonatomic) IBOutlet UILabel *baseline;
@property (weak, nonatomic) IBOutlet UILabel *strip;
@property (weak, nonatomic) IBOutlet UILabel *measure;
@property (weak, nonatomic) IBOutlet UILabel *shape;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
