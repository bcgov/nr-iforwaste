//
//  WasteImportBlockValidator.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-02-08.
//  Copyright © 2017 Salus Systems. All rights reserved.
//
#include <math.h>

#import "WasteImportBlockValidator.h"

#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "Timbermark.h"
#import "AssessmentmethodCode.h"
#import "HarvestMethodCode.h"
#import "PlotSizeCode.h"
#import "StratumTypeCode.h"
#import "WasteLevelCode.h"
#import "WasteTypeCode.h"
#import "MaturityCode.h"
#import "SiteCode+CoreDataClass.h"

@implementation WasteImportBlockValidator

+(NSMutableArray *) compareBlockForImport:(WasteBlock *)wb1 wb2:(WasteBlock *)wb2{

    //reporting unit number, cut block ID, licence number and cutting permit ID should be the same
    NSMutableArray *warning = [[NSMutableArray alloc] init];
    
    //comparing Cut Block Fields
    if(wb1.location && wb2.location && ![wb1.location isEqualToString:wb2.location]){
        [warning addObject:@"Cut Block Location"];
    }
    if(wb1.yearLoggedTo && wb2.yearLoggedTo && [wb1.yearLoggedTo integerValue] != [wb2.yearLoggedTo integerValue]){
        [warning addObject:@"Cut Block Logged To"];
    }
    if(wb1.yearLoggedFrom && wb2.yearLoggedFrom && [wb1.yearLoggedFrom integerValue] != [wb2.yearLoggedFrom integerValue]){
        [warning addObject:@"Cut Block Logged From"];
    }
    if(wb1.loggingCompleteDate && wb2.loggingCompleteDate && ![wb1.loggingCompleteDate isEqualToDate:wb2.loggingCompleteDate]){
        [warning addObject:@"Cut Block Logging Complete Date"];
    }
    if(wb1.surveyDate && wb2.surveyDate && ![wb1.surveyDate isEqualToDate:wb2.surveyDate]){
        [warning addObject:@"Cut Block Survey Date"];
    }
    if(wb1.netArea && wb2.netArea && [wb1.netArea floatValue] != [wb2.netArea floatValue]){
        [warning addObject:@"Cut Block Net Area"];
    }
    if(wb1.npNFArea && wb2.npNFArea && (isnan([wb1.npNFArea floatValue]) ? 0.0 :[wb1.npNFArea floatValue] != [wb2.npNFArea floatValue])){
        [warning addObject:@"Cut Block NP/NF Area"];
    }
    if(wb1.blockMaturityCode && wb2.blockMaturityCode && ![wb1.blockMaturityCode.maturityCode isEqualToString:wb2.blockMaturityCode.maturityCode] ){
        [warning addObject:@"Cut Block Maturity Code"];
    }
    if(wb1.blockSiteCode && wb2.blockSiteCode && ![wb1.blockSiteCode.siteCode isEqualToString:wb2.blockSiteCode.siteCode] ){
        [warning addObject:@"Cut Block Site Code"];
    }
    if(wb1.returnNumber && wb2.returnNumber && [wb1.returnNumber integerValue] != [wb2.returnNumber integerValue]){
        [warning addObject:@"Cut Block Return Number"];
    }
    if(wb1.surveyorLicence && wb2.surveyorLicence && ![wb1.surveyorLicence isEqualToString:wb2.surveyorLicence]){
        [warning addObject:@"Cut Block Surveyor Licence"];
    }
    if(wb1.surveyorName && wb2.surveyorName && ![wb1.surveyorName isEqualToString:wb2.surveyorName]){
        [warning addObject:@"Cut Block Surveyor Name"];
    }
    if(wb1.professional && wb2.professional && ![wb1.professional isEqualToString:wb2.professional]){
        [warning addObject:@"Cut Block Professional"];
    }
    if(wb1.registrationNumber && wb2.registrationNumber && ![wb1.registrationNumber isEqualToString:wb2.registrationNumber]){
        [warning addObject:@"Cut Block Registration Number"];
    }
    if(wb1.position && wb2.position && ![wb1.position isEqualToString:wb2.position]){
        [warning addObject:@"Cut Block Position"];
    }
    if(wb1.ratioSamplingEnabled && wb2.ratioSamplingEnabled && [wb1.ratioSamplingEnabled integerValue] != [wb2.ratioSamplingEnabled integerValue]){
        [warning addObject:@"Cut Block Survey Type (SRS vs Ratio Sampling)"];
    }
    
    //comparing Timber Mark
    Timbermark *ptm = nil;
    Timbermark *stm = nil;
    for (Timbermark *tm in wb1.blockTimbermark ){
        if( [tm.primaryInd integerValue]== 1){
            ptm = tm;
        }else{
            stm = tm;
        }
    }
    for (Timbermark *tm in wb2.blockTimbermark ){
        if( [tm.primaryInd integerValue]== 1){
            [self ValidateTimbermark:ptm tm2:tm warning:warning prefix:@"Primary"];
        }else{
            [self ValidateTimbermark:stm tm2:tm warning:warning prefix:@"Secondary"];
        }
    }
    
    // comparing Stratum
    //BOOL found_matching_st = NO;
    for (WasteStratum *st1 in wb1.blockStratum){
        for (WasteStratum *st2 in wb2.blockStratum){
            NSString *st1_name = st1.stratum;
            NSString *st2_name = st2.stratum;
            if([st1.stratum isEqualToString:st2.stratum]){
                //found_matching_st = YES;
                [self ValidateStratum:st1 st2:st2 warning:warning stratum:st1.stratum];
            }
        }
        //if(!found_matching_st){
        //    [warning addObject:[NSString stringWithFormat:@"Stratum %@ is missing", st1.stratum]];
       // }
        //found_matching_st = NO;
    }

    return warning;
}

+(void) ValidateTimbermark:(Timbermark *)tm1 tm2:(Timbermark*)tm2 warning:(NSMutableArray*)warning prefix:(NSString*)prefix{
    if(tm1.timbermark && tm2.timbermark && ![tm1.timbermark isEqualToString:tm2.timbermark]){
        [warning addObject: [NSString stringWithFormat:@"%@ %@", prefix, @"Timber Mark Name"]];
    }
    if(tm1.coniferWMRF && tm2.coniferWMRF && [tm1.coniferWMRF floatValue] != [tm2.coniferWMRF floatValue]){
        [warning addObject: [NSString stringWithFormat:@"%@ %@", prefix, @"Timber Mark Rate"]];
    }
    if(tm1.deciduousPrice && tm2.deciduousPrice && [tm1.deciduousPrice floatValue] != [tm2.deciduousPrice floatValue]){
        [warning addObject: [NSString stringWithFormat:@"%@ %@", prefix, @"Timber Mark Rate"]];
    }
    if(tm1.area && tm2.area && [tm1.area floatValue] != [tm2.area floatValue]){
        [warning addObject: [NSString stringWithFormat:@"%@ %@", prefix, @"Timber Mark Area"]];
    }
}

+(void) ValidateStratum:(WasteStratum *)st1 st2:(WasteStratum*)st2 warning:(NSMutableArray*)warning stratum:(NSString *)stratum{
    if(st1.stratumWasteTypeCode && st2.stratumWasteTypeCode && ![st1.stratumWasteTypeCode.wasteTypeCode isEqualToString:st2.stratumWasteTypeCode.wasteTypeCode]){
        [warning addObject:[NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Waste Type Code"]];
    }
    if(st1.stratumHarvestMethodCode && st2.stratumHarvestMethodCode && ![st1.stratumHarvestMethodCode.harvestMethodCode isEqualToString:st2.stratumHarvestMethodCode.harvestMethodCode]){
        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Harvest Method Code"]];
    }
    if(st1.stratumAssessmentMethodCode && st2.stratumAssessmentMethodCode && ![st1.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:st2.stratumAssessmentMethodCode.assessmentMethodCode]){
        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Assessment Method Code"]];
    }
    if(st1.stratumWasteLevelCode && st2.stratumWasteLevelCode && ![st1.stratumWasteLevelCode.wasteLevelCode isEqualToString:st2.stratumWasteLevelCode.wasteLevelCode]){
        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Waste Level Code"]];
    }
    if(st1.stratumArea && st2.stratumArea && [st1.stratumArea floatValue] != [st2.stratumArea floatValue]){
        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Area"]];
    }
    if(st1.measurePlot && st2.measurePlot && [st1.measurePlot integerValue] != [st2.measurePlot integerValue]){
        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Measure Plot"]];
    }
    if(st1.predictionPlot && st2.predictionPlot && [st1.predictionPlot integerValue] != [st2.predictionPlot integerValue]){
        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Prediction Plot"]];
    }

    for(WastePlot* plot_st1 in st1.stratumPlot){
        for(WastePlot* plot_st2 in st2.stratumPlot){
            if([plot_st1.plotNumber integerValue] == [plot_st2.plotNumber integerValue]){
                [warning addObject: [NSString stringWithFormat:@"Stratum (%@) has duplicate plot %@", stratum, plot_st1.plotNumber]];
                break;
            }
        }
    }
}
@end
