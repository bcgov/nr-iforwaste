//
//  EFWFooterView.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-27.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "EFWFooterView.h"
#import "EFWCoastStat+CoreDataClass.h"
#import "EFWInteriorStat+CoreDataClass.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"

@implementation EFWFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setBlockViewValue:(WasteBlock *) wb{
    if(wb.blockCoastStat){
        [self setCoastViewValue:wb.blockCoastStat];
    }else if(wb.blockInteriorStat){
        [self setInteriorViewValue:wb.blockInteriorStat];
    }
}

-(void) setStratumViewValue:(WasteStratum *) ws{
    if(ws.stratumCoastStat){
        [self setCoastViewValue:ws.stratumCoastStat];
    }else if(ws.stratumInteriorStat){
        [self setInteriorViewValue:ws.stratumInteriorStat];
    }
    
}

-(void) setPlotViewValue:(WastePlot *) wp{
    if(wp.plotCoastStat){
        [self setCoastViewValue:wp.plotCoastStat];
    }else if(wp.plotInteriorStat){
        [self setInteriorViewValue:wp.plotInteriorStat];
    }
    self.column1TitleLabel.text = @"Value ($/ha)";
    self.column2TitleLabel.text = @"Value ($)";
    self.column3TitleLabel.text = @"Volume (m\u00B3/ha)";
    self.column4TitleLabel.text = @"Volume (m\u00B3)";
    
}

-(void) setCoastViewValue:(EFWCoastStat*)stat{
    self.row1TitleLabel.text = @"Grade J & BTR";
    self.row2TitleLabel.text = @"HB U";
    self.row3TitleLabel.text = @"HB X";
    self.row4TitleLabel.text = @"Grade Y";
    self.totalBillTitleLabel.text = @"Total Billable";
    self.totalContTitleLabel.text = @"Total Cut Control";
    
    
    
    self.row1ValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeJValue floatValue]];
    self.row1ValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeJValueHa floatValue]];
    self.row1VolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeJVolume floatValue]];
    self.row1VolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeJVolumeHa floatValue]];

    self.row2ValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeUHBValue floatValue]];
    self.row2ValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeUHBValueHa floatValue]];
    self.row2VolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeUHBVolume floatValue]];
    self.row2VolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeUHBVolumeHa floatValue]];

    self.row3ValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeXHBValue floatValue]];
    self.row3ValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeXHBValueHa floatValue]];
    self.row3VolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeXHBVolume floatValue]];
    self.row3VolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeXHBVolumeHa floatValue]];

    self.row4ValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeYValue floatValue]];
    self.row4ValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeYValueHa floatValue]];
    self.row4VolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeYVolume floatValue]];
    self.row4VolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeYVolumeHa floatValue]];

    self.totalBillValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.totalBillValue floatValue]];
    self.totalBillValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.totalBillValueHa floatValue]];
    self.totalBillVolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.totalBillVolume floatValue]];
    self.totalBillVolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.totalBillVolumeHa floatValue]];

    self.totalContValLabel.text = @"N/A";
    self.totalContValPerHaLabel.text = @"N/A";
    self.totalContVolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.totalControlVolume floatValue]];
    self.totalContVolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.totalControlVolumeHa floatValue]];
}

-(void) setInteriorViewValue:(EFWInteriorStat*)stat{
    self.row1TitleLabel.text = @"Grade 1,2,4";
    self.row1TitleLabel.textColor = [UIColor colorWithRed:0.07 green:0.57 blue:0.28 alpha:1.0];
    self.row2TitleLabel.text = @"Grade 1,2";
    self.row3TitleLabel.text = @"Grade 4";
    self.row4TitleLabel.text = @"Grade 5";
    self.row4TitleLabel.textColor = [UIColor orangeColor];
    self.totalBillTitleLabel.text = @"Total Billable";
    self.totalContTitleLabel.text = @"Total Cut Control";
    
    self.row1ValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.grade124Value floatValue]];
    self.row1ValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.grade124ValueHa floatValue]];
    self.row1VolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.grade124Volume floatValue]];
    self.row1VolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.grade124VolumeHa floatValue]];

    self.row1ValLabel.textColor = [UIColor colorWithRed:0.07 green:0.57 blue:0.28 alpha:1.0];
    self.row1ValPerHaLabel.textColor = [UIColor colorWithRed:0.07 green:0.57 blue:0.28 alpha:1.0];
    self.row1VolLabel.textColor = [UIColor colorWithRed:0.07 green:0.57 blue:0.28 alpha:1.0];
    self.row1VolPerHaLabel.textColor = [UIColor colorWithRed:0.07 green:0.57 blue:0.28 alpha:1.0];

    self.row2ValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.grade12Value floatValue]];
    self.row2ValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.grade12ValueHa floatValue]];
    self.row2VolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.grade12Volume floatValue]];
    self.row2VolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.grade12VolumeHa floatValue]];
    
    self.row3ValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.grade4Value floatValue]];
    self.row3ValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.grade4ValueHa floatValue]];
    self.row3VolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.grade4Volume floatValue]];
    self.row3VolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.grade4VolumeHa floatValue]];
    
    self.row4ValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.grade5Value floatValue]];
    self.row4ValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.grade5ValueHa floatValue]];
    self.row4VolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.grade5Volume floatValue]];
    self.row4VolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.grade5VolumeHa floatValue]];

    self.row4ValLabel.textColor = [UIColor orangeColor];
    self.row4ValPerHaLabel.textColor = [UIColor orangeColor];
    self.row4VolLabel.textColor = [UIColor orangeColor];
    self.row4VolPerHaLabel.textColor = [UIColor orangeColor];

    self.totalBillValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.totalBillValue floatValue]];
    self.totalBillValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.totalBillValueHa floatValue]];
    self.totalBillVolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.totalBillVolume floatValue]];
    self.totalBillVolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.totalBillVolumeHa floatValue]];
    
    self.totalContValLabel.text = @"N/A";
    self.totalContValPerHaLabel.text = @"N/A";
    self.totalContVolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.totalControlVolume floatValue]];
    self.totalContVolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.totalControlVolumeHa floatValue]];
}

@end
