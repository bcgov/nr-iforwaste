//
//  EFWFooterView.h
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-27.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WasteBlock, WasteStratum, WastePlot;


@interface EFWFooterView : UIView

@property (weak, nonatomic) IBOutlet UILabel *row1TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *row1ValPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *row1ValLabel;
@property (weak, nonatomic) IBOutlet UILabel *row1VolPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *row1VolLabel;

@property (weak, nonatomic) IBOutlet UILabel *row2TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *row2ValPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *row2ValLabel;
@property (weak, nonatomic) IBOutlet UILabel *row2VolPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *row2VolLabel;

@property (weak, nonatomic) IBOutlet UILabel *row3TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *row3ValPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *row3ValLabel;
@property (weak, nonatomic) IBOutlet UILabel *row3VolPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *row3VolLabel;

@property (weak, nonatomic) IBOutlet UILabel *row4TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *row4ValPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *row4ValLabel;
@property (weak, nonatomic) IBOutlet UILabel *row4VolPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *row4VolLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalBillTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalBillValPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalBillValLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalBillVolPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalBillVolLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalContTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalContValPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalContValLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalContVolPerHaLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalContVolLabel;

@property (weak, nonatomic) IBOutlet UILabel *column1TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *column2TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *column3TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *column4TitleLabel;

-(void) setBlockViewValue:(WasteBlock *) wb;
-(void) setStratumViewValue:(WasteStratum *) wb;
-(void) setPlotViewValue:(WastePlot *) wb;

@end
