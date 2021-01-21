//
//  TimbermarkTableViewCell.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-09.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimbermarkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timbermark;
@property (weak, nonatomic) IBOutlet UILabel *area;
@property (weak, nonatomic) IBOutlet UILabel *primary;
@property (weak, nonatomic) IBOutlet UILabel *reductionFactor;
@property (weak, nonatomic) IBOutlet UILabel *aValue;
@property (weak, nonatomic) IBOutlet UILabel *bValue;
@property (weak, nonatomic) IBOutlet UILabel *wmrf;

@end
