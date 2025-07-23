//
//  PlotSelectorLog.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-03-14.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "PlotSelectorLog.h"
#import "WastePlot.h"
#import "WastePile+CoreDataProperties.h"
#import "WasteStratum.h"
#import "WasteBlock.h"
#import "Constants.h"
#import "AssessmentMethodCode.h"

@implementation PlotSelectorLog

+(NSString *) getPileSelectorLog:(WastePile*)wp stratum:(WasteStratum*)ws actionDec:(NSString*)actionDec{
    /*
     Column description
     
     1.    IPad identifier
     2.    Surveyor
     3.    Reporting Unit
     4. License
     5. CP
     6.    Block
     7.    Stratum (IE. SG2X)
     8.    Plot No.
     9.    Time stamp
     10.    GPS coordinate? - not ready yet
     11.    Random Selection indicator
     12. Predicted Green Volume
     13. Predicted Dry Volume
     14. All prediction attempts
     */
        
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *surveyor = wp.surveyorName ? [NSString stringWithString:wp.surveyorName] : @"";
    NSString *ru = ws.stratumBlock.reportingUnit ? [NSString stringWithFormat:@"%@", ws.stratumBlock.reportingUnit] : @"";
    
    NSString *block;
    NSString *licence;
    NSString *cp;
    if ([ws.stratumBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]) {
        block = ws.stratumBlock.cutBlockId ? [NSString stringWithString:ws.stratumBlock.cutBlockId] : @"";
        licence = ws.stratumBlock.licenceNumber ? [NSString stringWithString:ws.stratumBlock.licenceNumber] : @"";
        cp = ws.stratumBlock.cuttingPermitId ? [NSString stringWithString:ws.stratumBlock.cuttingPermitId] : @"";
    } else {
        block = wp.block ? [NSString stringWithString:wp.block] : @"";
        licence = wp.licence ? [NSString stringWithString:wp.licence] : @"";
        cp = wp.cuttingPermit ? [NSString stringWithString:wp.cuttingPermit] : @"";
    }

    NSString *stratum = ws.stratum ? [NSString stringWithString:ws.stratum] : @"";
    NSString *pile_num = wp.pileNumber? wp.pileNumber : @"";
    NSString *selected = [wp.isSample integerValue] == 1 ? @"YES":@"NO";
    NSString *gv = [wp.pileVolume floatValue] ? [NSString stringWithFormat:@"%.2f", [wp.pileVolume floatValue]] : @"";
    NSString *dv = @"";
    NSString *mp = @"100";
    NSString *modifySurveyor = wp.dcSurveyorName ? wp.dcSurveyorName : @"";
    NSString *modifyDesg = wp.dcDesignation? wp.dcDesignation : @"";
    NSString *modifyLicense = wp.dcLicenseNumber ? wp.dcLicenseNumber : @"";
    NSString *modifySignature = @"";
    NSString *modifyRationale = wp.dcRationale ? wp.dcRationale : @"";
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
        
    NSString *plotSelectorLine = @"";

    
    if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]) {
        gv = [NSString stringWithFormat:@"%.2f", [wp.pileVolume doubleValue]];
    }
    plotSelectorLine = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\";;", uniqueIdentifier, surveyor, ru, licence, cp, block, stratum, pile_num, timestamp, @"N/A", selected, gv, dv, mp, actionDec, modifySurveyor, modifyDesg, modifyLicense, modifySignature, modifyRationale];
    NSLog(@"plotSelectorLine");
    NSLog(@"%@", plotSelectorLine);

    return plotSelectorLine;
}

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
    NSString *surveyor = wp.plotStratum.stratumBlock.surveyorName ? [NSString stringWithString:wp.surveyorName] : @"";
    NSString *ru = wp.plotStratum.stratumBlock.reportingUnit ? [NSString stringWithFormat:@"%@", wp.plotStratum.stratumBlock.reportingUnit] : @"";
    NSString *block = @"";
    NSString *license = @"";
    NSString *cp = @"";
    if([wp.plotStratum.stratumBlock.isAggregate intValue] == 1)
    {
        block = wp.aggregateCutblock ? [NSString stringWithString:wp.aggregateCutblock] : @"";
        license = wp.aggregateLicence ? [NSString stringWithString:wp.aggregateLicence] : @"";
        cp = wp.aggregateCuttingPermit ? [NSString stringWithString:wp.aggregateCuttingPermit] : @"";
    }
    else
    {
        block = wp.plotStratum.stratumBlock.cutBlockId ? [NSString stringWithString:wp.plotStratum.stratumBlock.cutBlockId] : @"";
        license = wp.plotStratum.stratumBlock.licenceNumber ? [NSString stringWithString:wp.plotStratum.stratumBlock.licenceNumber] : @"";
        cp = wp.plotStratum.stratumBlock.cuttingPermitId ? [NSString stringWithString:wp.plotStratum.stratumBlock.cuttingPermitId] : @"";
    }
    NSString *stratum = wp.plotStratum.stratum ? [NSString stringWithString:wp.plotStratum.stratum] : @"";
    NSString *plot_num = wp.plotNumber? [wp.plotNumber stringValue] : @"";
    NSString *selected = [wp.isMeasurePlot integerValue] == 1 ? @"YES":@"NO";
    NSString *gv = [wp.greenVolume floatValue] ? [NSString stringWithFormat:@"%.2f", [wp.greenVolume floatValue]] : @"";
    NSString *dv = [wp.dryVolume floatValue] ? [NSString stringWithFormat:@"%.2f", [wp.dryVolume floatValue]] : @"";
    NSString *mp = [wp.surveyedMeasurePercent intValue] ? [NSString stringWithFormat:@"%d", [wp.surveyedMeasurePercent intValue]] : @"";
    NSString *modifySurveyor = wp.dcSurveyorName ? wp.dcSurveyorName : @"";
    NSString *modifyDesg = wp.dcDesignation? wp.dcDesignation : @"";
    NSString *modifyLicense = wp.dcLicenseNumber ? wp.dcLicenseNumber : @"";
    NSString *modifySignature = @"";
    NSString *modifyRationale = wp.dcRationale ? wp.dcRationale : @"";
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *plotSelectorLine = @"";
    

    plotSelectorLine = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\";;", uniqueIdentifier, surveyor, ru, license, cp, block, stratum, plot_num, timestamp, @"N/A", selected, gv, dv, mp, actionDec, modifySurveyor, modifyDesg, modifyLicense, modifySignature, modifyRationale];
    
    return plotSelectorLine;
}

// Used when deleting stratums
+(NSString *) getPlotSelectorLog:(WasteStratum*)ws actionDec:(NSString*)actionDec{
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *surveyor = ws.stratumBlock.surveyorName ? [NSString stringWithString:ws.stratumBlock.surveyorName] : @"";
    NSString *ru = ws.stratumBlock.reportingUnit ? [NSString stringWithFormat:@"%@", ws.stratumBlock.reportingUnit] : @"";
    NSString *block = @"";
    NSString *license = @"";
    NSString *cp = @"";
    NSString *stratum = ws.stratum ? [NSString stringWithString:ws.stratum] : @"";
    NSString *plot_num = @"";
    NSString *selected = @"";
    NSString *gv =  @"";
    NSString *dv = @"";
    NSString *mp = @"";
    NSString *modifySurveyor = ws.dcSurveyorName != nil ? ws.dcSurveyorName : @"";
    NSString *modifyDesg = ws.dcDesignation != nil ? ws.dcDesignation : @"";
    NSString *modifyLicense = ws.dcLicenseNumber != nil ? ws.dcLicenseNumber : @"";
    NSString *modifySignature = @"";
    NSString *modifyRationale = ws.dcRationale != nil ? ws.dcRationale : @"";
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *plotSelectorLine = @"";
    
    plotSelectorLine = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\";;", uniqueIdentifier, surveyor, ru, license, cp, block, stratum, plot_num, timestamp, @"N/A", selected, gv, dv, mp, actionDec, modifySurveyor, modifyDesg, modifyLicense, modifySignature, modifyRationale];

    return plotSelectorLine;
}
@end
