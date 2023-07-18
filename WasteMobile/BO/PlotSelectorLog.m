//
//  PlotSelectorLog.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-03-14.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "PlotSelectorLog.h"
#import "WastePlot.h"
#import "WasteStratum.h"
#import "WasteBlock.h"

@implementation PlotSelectorLog

+(NSString *) getPlotSelectorLog:(WastePlot*)wp actionDec:(NSString*)actionDec{
    /*
     Column description
     
     1.	IPad identifier
     2.	Surveyor
     3.	Reporting Unit
     4. License
     5. CP
     6.	Block
     7.	Stratum (IE. SG2X)
     8.	Plot No.
     9.	Time stamp
     10.	GPS coordinate? - not ready yet
     11.	Random Selection indicator
     12. Predicted Green Volume
     13. Predicted Dry Volume
     14. All prediction attempts
     */
    
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *surveyor = [NSString stringWithString:wp.plotStratum.stratumBlock.surveyorName];
    NSString *ru = [NSString stringWithFormat:@"%@", wp.plotStratum.stratumBlock.reportingUnit];
    NSString *block = [NSString stringWithString:wp.plotStratum.stratumBlock.cutBlockId];
    NSString *license = [NSString stringWithString:wp.plotStratum.stratumBlock.licenceNumber];
    NSString *cp = [NSString stringWithString:wp.plotStratum.stratumBlock.cuttingPermitId];
    NSString *stratum = [NSString stringWithString:wp.plotStratum.stratum];
    NSString *plot_num = [wp.plotNumber stringValue];
    NSString *selected = [wp.isMeasurePlot integerValue] == 1 ? @"YES":@"NO";
    NSString *gv = [NSString stringWithFormat:@"%.2f", [wp.greenVolume floatValue]];
    NSString *dv = [NSString stringWithFormat:@"%.2f", [wp.dryVolume floatValue]];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\";;", uniqueIdentifier, surveyor, ru, license, cp, block, stratum, plot_num, timestamp, @"N/A", selected, gv, dv, actionDec];
}

@end
