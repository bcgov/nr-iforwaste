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

+(NSString *) getPlotSelectorLog:(WastePlot*)wp stratum:(WasteStratum*)ws actionDec:(NSString*)actionDec{
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
    NSString *surveyor = wp.plotStratum.stratumBlock.surveyorName ? [NSString stringWithString:wp.plotStratum.stratumBlock.surveyorName] : @"";
    NSString *ru = wp.plotStratum.stratumBlock.reportingUnit ? [NSString stringWithFormat:@"%@", wp.plotStratum.stratumBlock.reportingUnit] : @"";
    NSString *block = wp.plotStratum.stratumBlock.cutBlockId ? [NSString stringWithString:wp.plotStratum.stratumBlock.cutBlockId] : @"";
    NSString *license = wp.plotStratum.stratumBlock.licenceNumber ? [NSString stringWithString:wp.plotStratum.stratumBlock.licenceNumber] : @"";
    NSString *cp = wp.plotStratum.stratumBlock.cuttingPermitId ? [NSString stringWithString:wp.plotStratum.stratumBlock.cuttingPermitId] : @"";
    NSString *stratum = wp.plotStratum.stratum ? [NSString stringWithString:wp.plotStratum.stratum] : @"";
    NSString *plot_num = wp.plotNumber? [wp.plotNumber stringValue] : @"";
    NSString *selected = [wp.isMeasurePlot integerValue] == 1 ? @"YES":@"NO";
    NSString *gv = [wp.greenVolume floatValue] ? [NSString stringWithFormat:@"%.2f", [wp.greenVolume floatValue]] : @"";
    NSString *dv = [wp.dryVolume floatValue] ? [NSString stringWithFormat:@"%.2f", [wp.dryVolume floatValue]] : @"";
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\";;", uniqueIdentifier, surveyor, ru, license, cp, block, stratum, plot_num, timestamp, @"N/A", selected, gv, dv, actionDec];
}

+(NSString *) getPlotSelectorLog:(WasteStratum*)ws actionDec:(NSString*)actionDec{
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *surveyor = ws.stratumBlock.surveyorName ? [NSString stringWithString:ws.stratumBlock.surveyorName] : @"";
    NSString *ru = ws.stratumBlock.reportingUnit ? [NSString stringWithFormat:@"%@", ws.stratumBlock.reportingUnit] : @"";
    NSString *block = ws.stratumBlock.cutBlockId ? [NSString stringWithString:ws.stratumBlock.cutBlockId] : @"";
    NSString *license = ws.stratumBlock.licenceNumber ? [NSString stringWithString:ws.stratumBlock.licenceNumber] : @"";
    NSString *cp = ws.stratumBlock.cuttingPermitId ? [NSString stringWithString:ws.stratumBlock.cuttingPermitId] : @"";
    NSString *stratum = ws.stratum ? [NSString stringWithString:ws.stratum] : @"";
    NSString *plot_num = @"";
    NSString *selected = @"";
    NSString *gv =  @"";
    NSString *dv = @"";
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\";;", uniqueIdentifier, surveyor, ru, license, cp, block, stratum, plot_num, timestamp, @"N/A", selected, gv, dv, actionDec];

}

+(NSString *) getPlotSelectorLog2:(AggregateCutblock*)aggCB stratum:(WasteStratum*)ws actionDec:(NSString*)actionDec{

    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *surveyor = ws.stratumBlock.surveyorName ? [NSString stringWithString:ws.stratumBlock.surveyorName] : @"";
    NSString *ru = ws.stratumBlock.reportingUnit ? [NSString stringWithFormat:@"%@", ws.stratumBlock.reportingUnit] : @"";
    NSString *block = aggCB.aggregateCutblock ? [NSString stringWithString:aggCB.aggregateCutblock] : @"";
    NSString *license = aggCB.aggregateLicense ? [NSString stringWithString:aggCB.aggregateLicense] : @"";
    NSString *cp = aggCB.aggregateCuttingPermit ? [NSString stringWithString:aggCB.aggregateCuttingPermit] : @"";
    NSString *stratum = ws.stratum ? [NSString stringWithString:ws.stratum] : @"";
    NSString *plot_num = @"";
    NSString *selected = @"";
    NSString *gv =  @"";
    NSString *dv = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\";;", uniqueIdentifier, surveyor, ru, license, cp, block, stratum, plot_num, timestamp, @"N/A", selected, gv, dv, actionDec];
}
@end
