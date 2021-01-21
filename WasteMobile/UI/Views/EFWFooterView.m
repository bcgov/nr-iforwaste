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
#import "StratumPile+CoreDataClass.h"

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

-(void) setPileViewValue:(StratumPile *) sp{
    if(sp.pileCoastStat){
        [self setCoastViewValue:sp.pileCoastStat];
    }else if(sp.pileInteriorStat){
        [self setInteriorViewValue:sp.pileInteriorStat];
    }
    self.column1TitleLabel.text = @"Value ($/ha)";
    self.column2TitleLabel.text = @"Value ($)";
    self.column3TitleLabel.text = @"Volume (m\u00B3/ha)";
    self.column4TitleLabel.text = @"Volume (m\u00B3)";
}

-(void) setCoastViewValue:(EFWCoastStat*)stat{
    self.row1TitleLabel.text = @"Grade J & BTR";
    self.row2TitleLabel.text = @"HB Grade U";
    self.row3CTitleLabel.text = @"Other Species Grade U";
    self.row3TitleLabel.text = @"Grade X";
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
    
    self.row3CValLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeUValue floatValue]];
    self.row3CValPerHaLabel.text = [NSString stringWithFormat:@"$%.02f", [stat.gradeUValueHa floatValue]];
    self.row3CVolLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeUVolume floatValue]];
    self.row3CVolPerHaLabel.text = [NSString stringWithFormat:@"%.02f", [stat.gradeUVolumeHa floatValue]];

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
    [self.row3CTitleLabel setHidden:YES];
    self.row3TitleLabel.text = @"Grade 4";
    //change the position of row 3
    CGRect rect = self.row3TitleLabel.frame;
    rect.origin.y = self.row2TitleLabel.frame.origin.y + 31;
    self.row3TitleLabel.frame = rect;
    self.row4TitleLabel.text = @"Grade 5";
    //change the position of row 4
    CGRect rect1 = self.row4TitleLabel.frame;
    rect1.origin.y = self.row3TitleLabel.frame.origin.y + 31;
    self.row4TitleLabel.frame = rect1;
    self.row4TitleLabel.textColor = [UIColor orangeColor];
    self.totalBillTitleLabel.text = @"Total Billable";
    //change the position of row total bill
    CGRect rect2 = self.totalBillTitleLabel.frame;
    rect2.origin.y = self.row4TitleLabel.frame.origin.y + 31;
    self.totalBillTitleLabel.frame = rect2;
    self.totalContTitleLabel.text = @"Total Cut Control";
    //change the position of row total cut control
    CGRect rect3 = self.totalContTitleLabel.frame;
    rect3.origin.y = self.totalBillTitleLabel.frame.origin.y + 31;
    self.totalContTitleLabel.frame = rect3;
    
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
    
    [self.row3CValLabel setHidden:YES];
    [self.row3CValPerHaLabel setHidden:YES];
    [self.row3CVolLabel setHidden:YES];
    [self.row3CVolPerHaLabel setHidden:YES];
    
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
    
    //change the position of rows 3, row 4, row total billable and row total cut control as row 3C is hidden for interior
    CGRect row3ValPos = self.row3ValLabel.frame;
    row3ValPos.origin.y = self.row2ValLabel.frame.origin.y + 31;
    self.row3ValLabel.frame = row3ValPos;
    CGRect row3ValHaPos = self.row3ValPerHaLabel.frame;
    row3ValHaPos.origin.y = self.row2ValPerHaLabel.frame.origin.y + 31;
    self.row3ValPerHaLabel.frame = row3ValHaPos;
    CGRect row3VolPos = self.row3VolLabel.frame;
    row3VolPos.origin.y = self.row2VolLabel.frame.origin.y + 31;
    self.row3VolLabel.frame = row3VolPos;
    CGRect row3VolHaPos = self.row3VolPerHaLabel.frame;
    row3VolHaPos.origin.y = self.row2VolPerHaLabel.frame.origin.y + 31;
    self.row3VolPerHaLabel.frame = row3VolHaPos;
    
    CGRect row4ValPos = self.row4ValLabel.frame;
    row4ValPos.origin.y = self.row3ValLabel.frame.origin.y + 31;
    self.row4ValLabel.frame = row4ValPos;
    CGRect row4ValHaPos = self.row4ValPerHaLabel.frame;
    row4ValHaPos.origin.y = self.row3ValPerHaLabel.frame.origin.y + 31;
    self.row4ValPerHaLabel.frame = row4ValHaPos;
    CGRect row4VolPos = self.row4VolLabel.frame;
    row4VolPos.origin.y = self.row3VolLabel.frame.origin.y + 31;
    self.row4VolLabel.frame = row4VolPos;
    CGRect row4VolHaPos = self.row4VolPerHaLabel.frame;
    row4VolHaPos.origin.y = self.row3VolPerHaLabel.frame.origin.y + 31;
    self.row4VolPerHaLabel.frame = row4VolHaPos;
    
    CGRect rowBillValPos = self.totalBillValLabel.frame;
    rowBillValPos.origin.y = self.row4ValLabel.frame.origin.y + 31;
    self.totalBillValLabel.frame = rowBillValPos;
    CGRect rowBillValHaPos = self.totalBillValPerHaLabel.frame;
    rowBillValHaPos.origin.y = self.row4ValPerHaLabel.frame.origin.y + 31;
    self.totalBillValPerHaLabel.frame = rowBillValHaPos;
    CGRect rowBillVolPos = self.totalBillVolLabel.frame;
    rowBillVolPos.origin.y = self.row4VolLabel.frame.origin.y + 31;
    self.totalBillVolLabel.frame = rowBillVolPos;
    CGRect rowBillVolHaPos = self.totalBillVolPerHaLabel.frame;
    rowBillVolHaPos.origin.y = self.row4VolPerHaLabel.frame.origin.y + 31;
    self.totalBillVolPerHaLabel.frame = rowBillVolHaPos;
    
    CGRect rowContValPos = self.totalContValLabel.frame;
    rowContValPos.origin.y = self.totalBillValLabel.frame.origin.y + 31;
    self.totalContValLabel.frame = rowContValPos;
    CGRect rowContValHaPos = self.totalContValPerHaLabel.frame;
    rowContValHaPos.origin.y = self.totalBillValPerHaLabel.frame.origin.y + 31;
    self.totalContValPerHaLabel.frame = rowContValHaPos;
    CGRect rowContVolPos = self.totalContVolLabel.frame;
    rowContVolPos.origin.y = self.totalBillVolLabel.frame.origin.y + 31;
    self.totalContVolLabel.frame = rowContVolPos;
    CGRect rowContVolHaPos = self.totalContVolPerHaLabel.frame;
    rowContVolHaPos.origin.y = self.totalBillVolPerHaLabel.frame.origin.y + 31;
    self.totalContVolPerHaLabel.frame = rowContVolHaPos;
}

@end
