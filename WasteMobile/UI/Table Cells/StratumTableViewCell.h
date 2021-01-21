//
//  StratumTableViewCell.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-12.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StratumTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *stratumType;
@property (weak, nonatomic) IBOutlet UILabel *harvestMethod;
@property (weak, nonatomic) IBOutlet UILabel *plotSize;
@property (weak, nonatomic) IBOutlet UILabel *wasteLevel;
@property (weak, nonatomic) IBOutlet UILabel *wasteType;
@property (weak, nonatomic) IBOutlet UILabel *area;

@property (weak, nonatomic) IBOutlet UILabel *stratum;
@property (weak, nonatomic) IBOutlet UILabel *stratumID;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
