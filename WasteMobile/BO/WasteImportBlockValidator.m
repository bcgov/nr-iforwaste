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
#import "Constants.h"
#import "StratumPile+CoreDataClass.h"
#import "WastePile+CoreDataClass.h"
#import "PileShapeCode+CoreDataClass.h"
#import "AggregateCutblock+CoreDataClass.h"
#import "WastePiece.h"
#import "WasteClassCode.h"
#import "MaterialKindCode.h"
#import "BorderlineCode.h"
#import "ScaleGradeCode.h"
#import "ScaleSpeciesCode.h"
#import "CommentCode.h"
#import "DecayTypeCode.h"
#import "WasteTypeCode.h"
#import "ButtEndCode.h"
#import "TopEndCode.h"

@implementation WasteImportBlockValidator

+(NSMutableArray *) compareBlockForImport:(WasteBlock *)wb1 wb2:(WasteBlock *)wb2{

    //reporting unit number, cut block ID, licence number and cutting permit ID should be the same
    NSMutableArray *warning = [[NSMutableArray alloc] init];
    
    //comparing Cut Block Fields
    if(wb1.yearLoggedTo && wb2.yearLoggedTo && [wb1.yearLoggedTo integerValue] != [wb2.yearLoggedTo integerValue]){
        [warning addObject:@"Cut Block Logged To"];
    }
    if(wb1.yearLoggedFrom && wb2.yearLoggedFrom && [wb1.yearLoggedFrom integerValue] != [wb2.yearLoggedFrom integerValue]){
        [warning addObject:@"Cut Block Logged From"];
    }
    if((wb1.loggingCompleteDate == nil && wb2.loggingCompleteDate != nil) || (wb1.loggingCompleteDate != nil && wb2.loggingCompleteDate == nil) || (wb1.loggingCompleteDate != nil && wb2.loggingCompleteDate != nil)){
        if(![wb1.loggingCompleteDate isEqualToDate:wb2.loggingCompleteDate]){
            [warning addObject:@"Cut Block Logging Complete Date"];
        }
    }
    if((wb1.surveyDate == nil && wb2.surveyDate != nil) || (wb1.surveyDate != nil && wb2.surveyDate == nil) || (wb1.surveyDate != nil && wb2.surveyDate != nil)){
        if(![wb1.surveyDate isEqualToDate:wb2.surveyDate]){
            [warning addObject:@"Cut Block Survey Date"];
        }
    }
    if(wb1.netArea && wb2.netArea && [wb1.netArea floatValue] != [wb2.netArea floatValue]){
        [warning addObject:@"Cut Block Net Area"];
    }
    if(wb1.surveyArea && wb2.surveyArea && (isnan([wb1.surveyArea floatValue]) ? 0.0 :[wb1.surveyArea floatValue] != [wb2.surveyArea floatValue])){
        [warning addObject:@"Cut Block Net Area"];
    }
    if((wb1.blockMaturityCode == nil && wb2.blockMaturityCode != nil) || (wb1.blockMaturityCode != nil && wb2.blockMaturityCode == nil) || (wb1.blockMaturityCode != nil && wb2.blockMaturityCode != nil)){
        if([wb1.regionId integerValue] == 1 && [wb2.regionId integerValue]== 1 && ![[wb1.blockMaturityCode.maturityCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[wb2.blockMaturityCode.maturityCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject:@"Cut Block Maturity Code"];
        }
    }
    if((wb1.blockSiteCode == nil && wb2.blockSiteCode != nil) || (wb1.blockSiteCode != nil && wb2.blockSiteCode == nil) || (wb1.blockSiteCode != nil && wb2.blockSiteCode != nil)){
        if([wb1.regionId integerValue] == 2 && [wb2.regionId integerValue]== 2 && ![[wb1.blockSiteCode.siteCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[wb2.blockSiteCode.siteCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject:@"Cut Block Site Code"];
        }
    }
    if((wb1.ratioSamplingEnabled == nil && wb2.ratioSamplingEnabled != nil) || (wb1.ratioSamplingEnabled != nil && wb2.ratioSamplingEnabled == nil) || (wb1.ratioSamplingEnabled != nil && wb2.ratioSamplingEnabled != nil)){
        if([wb1.ratioSamplingEnabled integerValue] != [wb2.ratioSamplingEnabled integerValue]){
            [warning addObject:@"Cut Block Survey Type (SRS vs Ratio Sampling)"];
        }
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
        }/*else{
            [self ValidateTimbermark:stm tm2:tm warning:warning prefix:@"Secondary"];
        }*/
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
    if([tm1.timbermarkBlock.regionId integerValue] == CoastRegion){
        if(tm1.timbermark && tm2.timbermark && ![[tm1.timbermark.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[tm2.timbermark.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject: [NSString stringWithFormat:@"%@ %@", prefix, @"Timber Mark Name"]];
        }
    }else {
    if((tm1.timbermark  == nil && tm2.timbermark != nil) || (tm1.timbermark  != nil && tm2.timbermark == nil) || (tm1.timbermark  != nil && tm2.timbermark != nil)){
        if( ![[tm1.timbermark.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[tm2.timbermark.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject: [NSString stringWithFormat:@"%@ %@", prefix, @"Timber Mark Name"]];
        }
    }
    }
    if((tm1.area  == nil && tm2.area != nil) || (tm1.area  != nil && tm2.area == nil) || (tm1.area  != nil && tm2.area != nil)){
        if([tm1.area floatValue] != [tm2.area floatValue]){
            [warning addObject: [NSString stringWithFormat:@"%@ %@", prefix, @"Timber Mark Area"]];
        }
    }
}

+(void) ValidateStratum:(WasteStratum *)st1 st2:(WasteStratum*)st2 warning:(NSMutableArray*)warning stratum:(NSString *)stratum{
    if((st1.stratumWasteTypeCode  == nil && st2.stratumWasteTypeCode != nil) || (st1.stratumWasteTypeCode  != nil && st2.stratumWasteTypeCode == nil) || (st1.stratumWasteTypeCode  != nil && st2.stratumWasteTypeCode != nil)){
        if(![[st1.stratumWasteTypeCode.wasteTypeCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumWasteTypeCode.wasteTypeCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject:[NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Waste Type Code"]];
        }
    }
    if((st1.stratumHarvestMethodCode  == nil && st2.stratumHarvestMethodCode != nil) || (st1.stratumHarvestMethodCode  != nil && st2.stratumHarvestMethodCode == nil) || (st1.stratumHarvestMethodCode  != nil && st2.stratumHarvestMethodCode != nil)){
        if(![[st1.stratumHarvestMethodCode.harvestMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumHarvestMethodCode.harvestMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Harvest Method Code"]];
        }
    }
    if((st1.stratumAssessmentMethodCode  == nil && st2.stratumAssessmentMethodCode != nil) || (st1.stratumAssessmentMethodCode  != nil && st2.stratumAssessmentMethodCode == nil) || (st1.stratumAssessmentMethodCode  != nil && st2.stratumAssessmentMethodCode != nil)){
        if(![[st1.stratumAssessmentMethodCode.assessmentMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumAssessmentMethodCode.assessmentMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Assessment Method Code"]];
        }
    }
    if((st1.stratumWasteLevelCode  == nil && st2.stratumWasteLevelCode != nil) || (st1.stratumWasteLevelCode  != nil && st2.stratumWasteLevelCode == nil) || (st1.stratumWasteLevelCode  != nil && st2.stratumWasteLevelCode != nil)){
        if(![[st1.stratumWasteLevelCode.wasteLevelCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumWasteLevelCode.wasteLevelCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Waste Level Code"]];
        }
    }
    if((st1.stratumSurveyArea == nil && st2.stratumSurveyArea != nil) || (st1.stratumSurveyArea != nil && st2.stratumSurveyArea == nil) || (st1.stratumSurveyArea != nil && st2.stratumSurveyArea != nil)){
        if([st1.stratumSurveyArea floatValue] != [st2.stratumSurveyArea floatValue]){
            [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Area"]];
        }
    }
    if((st1.measurePlot == nil && st2.measurePlot != nil) || (st1.measurePlot != nil && st2.measurePlot == nil) || (st1.measurePlot != nil && st2.measurePlot != nil)){
        if([st1.measurePlot integerValue] != [st2.measurePlot integerValue]){
            [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Measure Plot"]];
        }
    }
    if((st1.predictionPlot == nil && st2.predictionPlot != nil) || (st1.predictionPlot != nil && st2.predictionPlot == nil) || (st1.predictionPlot != nil && st2.predictionPlot != nil)){
        if([st1.predictionPlot integerValue] != [st2.predictionPlot integerValue]){
            [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", stratum, @"Prediction Plot"]];
        }
    }
    
    for(WastePlot* plot_st1 in st1.stratumPlot){
        for(WastePlot* plot_st2 in st2.stratumPlot){
            if([st1.stratumBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                if([plot_st1.plotNumber integerValue] == [plot_st2.plotNumber integerValue]){
                    //[warning addObject: [NSString stringWithFormat:@"Stratum (%@) has duplicate plot %@", stratum, plot_st1.plotNumber]];
                    //break;
                    BOOL found_match = FALSE;
                    for(WastePiece *wp1 in plot_st1.plotPiece){
                        for(WastePiece *wp2 in plot_st2.plotPiece){
                            if([wp1.pieceNumber isEqualToString:wp2.pieceNumber]){
                                found_match = TRUE;
                                if([st1.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                    if([wp1.pieceBorderlineCode.borderlineCode isEqualToString:wp2.pieceBorderlineCode.borderlineCode] && [wp1.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:wp2.pieceScaleSpeciesCode.scaleSpeciesCode] && [wp1.pieceMaterialKindCode.materialKindCode isEqualToString:wp2.pieceMaterialKindCode.materialKindCode] && [wp1.pieceWasteClassCode.wasteClassCode isEqualToString:wp2.pieceWasteClassCode.wasteClassCode] && [wp1.length intValue] == [wp2.length intValue] && [wp1.topDiameter intValue] == [wp2.topDiameter intValue] && [wp1.pieceTopEndCode.topEndCode isEqualToString:wp2.pieceTopEndCode.topEndCode] && [wp1.buttDiameter intValue] == [wp2.buttDiameter intValue] && [wp1.pieceButtEndCode.buttEndCode isEqualToString:wp2.pieceButtEndCode.buttEndCode] && [wp1.pieceScaleGradeCode.scaleGradeCode isEqualToString:wp2.pieceScaleGradeCode.scaleGradeCode] && [wp1.lengthDeduction intValue] == [wp2.lengthDeduction intValue] && [wp1.topDeduction intValue] == [wp2.topDeduction intValue] && [wp1.buttDeduction intValue] == [wp2.buttDeduction intValue] /*&& [wp1.pieceDecayTypeCode.decayTypeCode isEqualToString:wp2.pieceDecayTypeCode.decayTypeCode] && [wp1.farEnd intValue] == [wp2.farEnd intValue] && [wp1.addLength intValue] == [wp2.addLength intValue] && [wp1.pieceCommentCode.commentCode isEqualToString:wp2.pieceCommentCode.commentCode]*/){
                                        break;
                                    }else{
                                        [warning addObject: [NSString stringWithFormat:@"Stratum (%@), Plot (%@) has duplicate piece %@",stratum, plot_st1.plotNumber, wp1.pieceNumber]];
                                        break;
                                    }
                                }else if([st1.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"S"]){
                                    if([wp1.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:wp2.pieceScaleSpeciesCode.scaleSpeciesCode] && [wp1.pieceMaterialKindCode.materialKindCode isEqualToString:wp2.pieceMaterialKindCode.materialKindCode] && [wp1.pieceWasteClassCode.wasteClassCode isEqualToString:wp2.pieceWasteClassCode.wasteClassCode] && [wp1.length intValue] == [wp2.length intValue] && [wp1.topDiameter intValue] == [wp2.topDiameter intValue] && [wp1.pieceTopEndCode.topEndCode isEqualToString:wp2.pieceTopEndCode.topEndCode] && [wp1.buttDiameter intValue] == [wp2.buttDiameter intValue] && [wp1.pieceButtEndCode.buttEndCode isEqualToString:wp2.pieceButtEndCode.buttEndCode] && [wp1.pieceScaleGradeCode.scaleGradeCode isEqualToString:wp2.pieceScaleGradeCode.scaleGradeCode] && [wp1.lengthDeduction intValue] == [wp2.lengthDeduction intValue] && [wp1.topDeduction intValue] == [wp2.topDeduction intValue] && [wp1.buttDeduction intValue] == [wp2.buttDeduction intValue] /*&& [wp1.pieceDecayTypeCode.decayTypeCode isEqualToString:wp2.pieceDecayTypeCode.decayTypeCode] && [wp1.pieceCommentCode.commentCode isEqualToString:wp2.pieceCommentCode.commentCode]*/){
                                        break;
                                    }else{
                                        [warning addObject: [NSString stringWithFormat:@"Stratum (%@), Plot (%@) has duplicate piece %@", stratum, plot_st1.plotNumber, wp1.pieceNumber]];
                                        break;
                                    }
                                }else if([st1.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"]){
                                    if([wp1.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:wp2.pieceScaleSpeciesCode.scaleSpeciesCode] && [wp1.pieceMaterialKindCode.materialKindCode isEqualToString:wp2.pieceMaterialKindCode.materialKindCode] && [wp1.pieceWasteClassCode.wasteClassCode isEqualToString:wp2.pieceWasteClassCode.wasteClassCode] && [wp1.pieceScaleGradeCode.scaleGradeCode isEqualToString:wp2.pieceScaleGradeCode.scaleGradeCode] && [wp1.estimatedPercent doubleValue] == [wp2.estimatedPercent doubleValue]){
                                        break;
                                    }else{
                                        [warning addObject: [NSString stringWithFormat:@"Stratum (%@), Plot (%@) has duplicate piece %@", stratum, plot_st1.plotNumber, wp1.pieceNumber]];
                                        break;
                                    }
                                }
                            }/*else{
                                [warning addObject: [NSString stringWithFormat:@"Plot (%@) has no piece %@", stratum, wp1.pieceNumber?wp1.pieceNumber:wp2.pieceNumber]];
                                break;
                            }*/
                        }
                        if(!found_match){
                            [warning addObject: [NSString stringWithFormat:@"Plot (%@) has new piece", plot_st1.plotNumber]];
                            break;

                        }
                        found_match = NO;
                    }
                }
            }else{
                BOOL found_match = FALSE;
                if([plot_st1.plotNumber integerValue] == [plot_st2.plotNumber integerValue]){
                    if([plot_st1.aggregateCutblock intValue] == [plot_st2.aggregateCutblock intValue] && [plot_st1.aggregateCuttingPermit intValue] == [plot_st2.aggregateCuttingPermit intValue] && [plot_st1.aggregateLicence intValue] == [plot_st2.aggregateLicence intValue]){
                        for(WastePiece *wp1 in plot_st1.plotPiece){
                            for(WastePiece *wp2 in plot_st2.plotPiece){
                                if([wp1.pieceNumber isEqualToString:wp2.pieceNumber]){
                                    found_match = TRUE;
                                    if([st1.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                        if([wp1.pieceBorderlineCode.borderlineCode isEqualToString:wp2.pieceBorderlineCode.borderlineCode] && [wp1.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:wp2.pieceScaleSpeciesCode.scaleSpeciesCode] && [wp1.pieceMaterialKindCode.materialKindCode isEqualToString:wp2.pieceMaterialKindCode.materialKindCode] && [wp1.pieceWasteClassCode.wasteClassCode isEqualToString:wp2.pieceWasteClassCode.wasteClassCode] && [wp1.length intValue] == [wp2.length intValue] && [wp1.topDiameter intValue] == [wp2.topDiameter intValue] && [wp1.pieceTopEndCode.topEndCode isEqualToString:wp2.pieceTopEndCode.topEndCode] && [wp1.buttDiameter intValue] == [wp2.buttDiameter intValue] && [wp1.pieceButtEndCode.buttEndCode isEqualToString:wp2.pieceButtEndCode.buttEndCode] && [wp1.pieceScaleGradeCode.scaleGradeCode isEqualToString:wp2.pieceScaleGradeCode.scaleGradeCode] && [wp1.lengthDeduction intValue] == [wp2.lengthDeduction intValue] && [wp1.topDeduction intValue] == [wp2.topDeduction intValue] && [wp1.buttDeduction intValue] == [wp2.buttDeduction intValue] /*&& [wp1.pieceDecayTypeCode.decayTypeCode isEqualToString:wp2.pieceDecayTypeCode.decayTypeCode] && [wp1.farEnd intValue] == [wp2.farEnd intValue] && [wp1.addLength intValue] == [wp2.addLength intValue] && [wp1.pieceCommentCode.commentCode isEqualToString:wp2.pieceCommentCode.commentCode]*/){
                                            break;
                                        }else{
                                            [warning addObject: [NSString stringWithFormat:@"Stratum (%@), Plot (%@) has duplicate piece %@",stratum, plot_st1.plotNumber, wp1.pieceNumber]];
                                            break;
                                        }
                                    }else if([st1.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"S"]){
                                        if([wp1.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:wp2.pieceScaleSpeciesCode.scaleSpeciesCode] && [wp1.pieceMaterialKindCode.materialKindCode isEqualToString:wp2.pieceMaterialKindCode.materialKindCode] && [wp1.pieceWasteClassCode.wasteClassCode isEqualToString:wp2.pieceWasteClassCode.wasteClassCode] && [wp1.length intValue] == [wp2.length intValue] && [wp1.topDiameter intValue] == [wp2.topDiameter intValue] && [wp1.pieceTopEndCode.topEndCode isEqualToString:wp2.pieceTopEndCode.topEndCode] && [wp1.buttDiameter intValue] == [wp2.buttDiameter intValue] && [wp1.pieceButtEndCode.buttEndCode isEqualToString:wp2.pieceButtEndCode.buttEndCode] && [wp1.pieceScaleGradeCode.scaleGradeCode isEqualToString:wp2.pieceScaleGradeCode.scaleGradeCode] && [wp1.lengthDeduction intValue] == [wp2.lengthDeduction intValue] && [wp1.topDeduction intValue] == [wp2.topDeduction intValue] && [wp1.buttDeduction intValue] == [wp2.buttDeduction intValue] /*&& [wp1.pieceDecayTypeCode.decayTypeCode isEqualToString:wp2.pieceDecayTypeCode.decayTypeCode] && [wp1.pieceCommentCode.commentCode isEqualToString:wp2.pieceCommentCode.commentCode]*/){
                                            break;
                                        }else{
                                            [warning addObject: [NSString stringWithFormat:@"Stratum (%@), Plot (%@) has duplicate piece %@", stratum, plot_st1.plotNumber, wp1.pieceNumber]];
                                            break;
                                        }
                                    }else if([st1.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"]){
                                        if([wp1.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:wp2.pieceScaleSpeciesCode.scaleSpeciesCode] && [wp1.pieceMaterialKindCode.materialKindCode isEqualToString:wp2.pieceMaterialKindCode.materialKindCode] && [wp1.pieceWasteClassCode.wasteClassCode isEqualToString:wp2.pieceWasteClassCode.wasteClassCode] && [wp1.pieceScaleGradeCode.scaleGradeCode isEqualToString:wp2.pieceScaleGradeCode.scaleGradeCode] && [wp1.estimatedPercent doubleValue] == [wp2.estimatedPercent doubleValue]){
                                            break;
                                        }else{
                                            [warning addObject: [NSString stringWithFormat:@"Stratum (%@), Plot (%@) has duplicate piece %@", stratum, plot_st1.plotNumber, wp1.pieceNumber]];
                                            break;
                                        }
                                    }
                                }/*else{
                                    [warning addObject: [NSString stringWithFormat:@"Plot (%@) has no piece %@", stratum, wp1.pieceNumber?wp1.pieceNumber:wp2.pieceNumber]];
                                    break;
                                }*/
                            }
                            if(!found_match){
                                [warning addObject: [NSString stringWithFormat:@"Plot (%@) has new piece", plot_st1.plotNumber]];
                                break;

                            }
                            found_match = NO;
                        }
                    }else{
                        [warning addObject: [NSString stringWithFormat:@"Cannot have the same plot with different CB, CP, licence #"]];
                        break;
                    }
                }
            }
        }
    }
}

+(NSMutableArray *) compareBlockForImportPileStratum:(WasteBlock *)wb1 wb2:(WasteBlock *)wb2{
    //reporting unit number, cut block ID, licence number and cutting permit ID should be the same
    NSMutableArray *warning = [[NSMutableArray alloc] init];
    
    //comparing Cut Block Fields
    if(wb1.yearLoggedTo && wb2.yearLoggedTo && [wb1.yearLoggedTo integerValue] != [wb2.yearLoggedTo integerValue]){
        [warning addObject:@"Cut Block Logged To"];
    }
    if(wb1.yearLoggedFrom && wb2.yearLoggedFrom && [wb1.yearLoggedFrom integerValue] != [wb2.yearLoggedFrom integerValue]){
        [warning addObject:@"Cut Block Logged From"];
    }
    if((wb1.loggingCompleteDate == nil && wb2.loggingCompleteDate != nil) || (wb1.loggingCompleteDate != nil && wb2.loggingCompleteDate == nil) || (wb1.loggingCompleteDate != nil && wb2.loggingCompleteDate != nil)){
        if(![wb1.loggingCompleteDate isEqualToDate:wb2.loggingCompleteDate]){
            [warning addObject:@"Cut Block Logging Complete Date"];
        }
    }
    if((wb1.surveyDate == nil && wb2.surveyDate != nil) || (wb1.surveyDate != nil && wb2.surveyDate == nil) || (wb1.surveyDate != nil && wb2.surveyDate != nil)){
        if(![wb1.surveyDate isEqualToDate:wb2.surveyDate]){
            [warning addObject:@"Cut Block Survey Date"];
        }
    }
    if(wb1.netArea && wb2.netArea && [wb1.netArea floatValue] != [wb2.netArea floatValue]){
        [warning addObject:@"Cut Block Net Area"];
    }
    if(wb1.surveyArea && wb2.surveyArea && (isnan([wb1.surveyArea floatValue]) ? 0.0 :[wb1.surveyArea floatValue] != [wb2.surveyArea floatValue])){
        [warning addObject:@"Cut Block Net Area"];
    }
    if((wb1.blockMaturityCode == nil && wb2.blockMaturityCode != nil) || (wb1.blockMaturityCode != nil && wb2.blockMaturityCode == nil) || (wb1.blockMaturityCode != nil && wb2.blockMaturityCode != nil)){
        if([wb1.regionId integerValue] == 1 && [wb2.regionId integerValue]== 1 && ![[wb1.blockMaturityCode.maturityCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[wb2.blockMaturityCode.maturityCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject:@"Cut Block Maturity Code"];
        }
    }
    if((wb1.blockSiteCode == nil && wb2.blockSiteCode != nil) || (wb1.blockSiteCode != nil && wb2.blockSiteCode == nil) || (wb1.blockSiteCode != nil && wb2.blockSiteCode != nil)){
        if([wb1.regionId integerValue] == 2 && [wb2.regionId integerValue]== 2 && ![[wb1.blockSiteCode.siteCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[wb2.blockSiteCode.siteCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject:@"Cut Block Site Code"];
        }
    }
    if((wb1.ratioSamplingEnabled == nil && wb2.ratioSamplingEnabled != nil) || (wb1.ratioSamplingEnabled != nil && wb2.ratioSamplingEnabled == nil) || (wb1.ratioSamplingEnabled != nil && wb2.ratioSamplingEnabled != nil)){
        if([wb1.ratioSamplingEnabled integerValue] != [wb2.ratioSamplingEnabled integerValue]){
            [warning addObject:@"Cut Block Survey Type (SRS vs Ratio Sampling)"];
        }
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
        }
    }
    for (WasteStratum *st1 in wb1.blockStratum){
        for (WasteStratum *st2 in wb2.blockStratum){
            if([st1.stratum isEqualToString:st2.stratum]){
                if((st1.stratumWasteTypeCode  == nil && st2.stratumWasteTypeCode != nil) || (st1.stratumWasteTypeCode  != nil && st2.stratumWasteTypeCode == nil) || (st1.stratumWasteTypeCode  != nil && st2.stratumWasteTypeCode != nil)){
                    if(![[st1.stratumWasteTypeCode.wasteTypeCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumWasteTypeCode.wasteTypeCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
                        [warning addObject:[NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Waste Type Code"]];
                    }
                }
                if((st1.stratumHarvestMethodCode  == nil && st2.stratumHarvestMethodCode != nil) || (st1.stratumHarvestMethodCode  != nil && st2.stratumHarvestMethodCode == nil) || (st1.stratumHarvestMethodCode  != nil && st2.stratumHarvestMethodCode != nil)){
                    if(![[st1.stratumHarvestMethodCode.harvestMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumHarvestMethodCode.harvestMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
                        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Harvest Method Code"]];
                    }
                }
                if((st1.stratumAssessmentMethodCode  == nil && st2.stratumAssessmentMethodCode != nil) || (st1.stratumAssessmentMethodCode  != nil && st2.stratumAssessmentMethodCode == nil) || (st1.stratumAssessmentMethodCode  != nil && st2.stratumAssessmentMethodCode != nil)){
                    if(![[st1.stratumAssessmentMethodCode.assessmentMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumAssessmentMethodCode.assessmentMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
                        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Assessment Method Code"]];
                    }
                }
                if((st1.stratumWasteLevelCode  == nil && st2.stratumWasteLevelCode != nil) || (st1.stratumWasteLevelCode  != nil && st2.stratumWasteLevelCode == nil) || (st1.stratumWasteLevelCode  != nil && st2.stratumWasteLevelCode != nil)){
                    if(![[st1.stratumWasteLevelCode.wasteLevelCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumWasteLevelCode.wasteLevelCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
                        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Waste Level Code"]];
                    }
                }
                /*if((st1.stratumSurveyArea == nil && st2.stratumSurveyArea != nil) || (st1.stratumSurveyArea != nil && st2.stratumSurveyArea == nil) || (st1.stratumSurveyArea != nil && st2.stratumSurveyArea != nil)){
                    if([st1.stratumSurveyArea floatValue] != [st2.stratumSurveyArea floatValue]){
                        [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Area"]];
                    }
                }*/
                
                if([wb1.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                    // comparing Stratum
                    if([st2.stratumBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                        NSSet* pile_set = [NSSet setWithSet:st2.strPile.pileData];
                        for(WastePile *swb_pile in pile_set){
                            for(WastePile *pwb_pile in st1.strPile.pileData){
                                if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                     if([pwb_pile.measuredLength doubleValue] != [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] != [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] != [swb_pile.measuredHeight doubleValue] && ![pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode] && [pwb_pile.measuredPileArea doubleValue] != [swb_pile.measuredPileArea doubleValue] && [pwb_pile.measuredPileVolume doubleValue] != [swb_pile.measuredPileVolume doubleValue]){
                                         [warning addObject: [NSString stringWithFormat:@"RU (%@), Stratum (%@), Block (%@), CP (%@), License (%@), Pile Number (%@), the measure dimensions on the incoming file do not match the receiving file.",wb2.reportingUnit, st1.stratum, wb2.blockNumber, wb2.cuttingPermitId, wb2.licenceNumber, swb_pile.pileNumber]];
                                     }
                                    break;
                                }
                            }
                        }
                    }else{
                        if(st2.strPile.stratumPileId == st1.strPile.stratumPileId){
                            NSSet* pile_set = [NSSet setWithSet:st2.strPile.pileData];
                            for(WastePile *swb_pile in pile_set){
                                for(WastePile *pwb_pile in st1.strPile.pileData){
                                    if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                         if([pwb_pile.length doubleValue] != [swb_pile.length doubleValue] && [pwb_pile.width doubleValue] != [swb_pile.width doubleValue] && [pwb_pile.height doubleValue] != [swb_pile.height doubleValue] && [pwb_pile.measuredLength doubleValue] != [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] != [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] != [swb_pile.measuredHeight doubleValue] && ![pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode]){
                                             [warning addObject: [NSString stringWithFormat:@"RU (%@), Stratum (%@), Block (%@), CP (%@), License (%@), Pile Number (%@), the measure dimensions on the incoming file do not match the receiving file.",wb2.reportingUnit, st1.stratum, wb2.blockNumber, wb2.cuttingPermitId, wb2.licenceNumber, swb_pile.pileNumber]];
                                         }
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }else if([wb1.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]){
                    // comparing Stratum
                        for (AggregateCutblock *swb_aggCB in st2.stratumAgg){
                            for(AggregateCutblock *pwb_aggCB in st1.stratumAgg){
                                if(pwb_aggCB.aggregateCuttingPermit == swb_aggCB.aggregateCuttingPermit && pwb_aggCB.aggregateCutblock == swb_aggCB.aggregateCutblock && pwb_aggCB.aggregateLicense == swb_aggCB.aggregateLicense){
                                   if([st2.stratumBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                                        NSSet* pile_set = [NSSet setWithSet:st2.strPile.pileData];
                                        for(WastePile *swb_pile in pile_set){
                                            for(WastePile *pwb_pile in st1.strPile.pileData){
                                                if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                                     if([pwb_pile.measuredLength doubleValue] != [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] != [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] != [swb_pile.measuredHeight doubleValue] && ![pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode] && [pwb_pile.measuredPileArea doubleValue] != [swb_pile.measuredPileArea doubleValue] && [pwb_pile.measuredPileVolume doubleValue] != [swb_pile.measuredPileVolume doubleValue]){
                                                         [warning addObject: [NSString stringWithFormat:@"RU (%@), Stratum (%@), Block (%@), CP (%@), License (%@), Pile Number (%@), the measure dimensions on the incoming file do not match the receiving file.",wb2.reportingUnit, st1.stratum, wb2.blockNumber, wb2.cuttingPermitId, wb2.licenceNumber, swb_pile.pileNumber]];
                                                     }
                                                    break;
                                                }
                                            }
                                        }
                                    }else{
                                       if(swb_aggCB.aggPile.stratumPileId == pwb_aggCB.aggPile.stratumPileId){
                                        NSSet* pile_set = [NSSet setWithSet:swb_aggCB.aggPile.pileData];
                                        for(WastePile *swb_pile in pile_set){
                                            for(WastePile *pwb_pile in pwb_aggCB.aggPile.pileData){
                                                if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                                    if([pwb_pile.length doubleValue] != [swb_pile.length doubleValue] && [pwb_pile.width doubleValue] != [swb_pile.width doubleValue] && [pwb_pile.height doubleValue] != [swb_pile.height doubleValue] && [pwb_pile.measuredLength doubleValue] != [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] != [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] != [swb_pile.measuredHeight doubleValue] && ![pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode]){
                                                        [warning addObject: [NSString stringWithFormat:@"RU (%@), Stratum (%@), Block (%@), CP (%@), License (%@), Pile Number (%@), the measure dimensions on the incoming file do not match the receiving file.",wb2.reportingUnit, st1.stratum, wb2.blockNumber, wb2.cuttingPermitId, wb2.licenceNumber, swb_pile.pileNumber]];
                                                    }
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    break;
                }
            }
        }
    }
    return warning;
}

+(NSMutableArray *) compareBlockForImportStratum:(WasteBlock *)wb1 wb2:(WasteBlock *)wb2{
    //reporting unit number, cut block ID, licence number and cutting permit ID should be the same
    NSMutableArray *warning = [[NSMutableArray alloc] init];
    
    //comparing Cut Block Fields
    if(wb1.yearLoggedTo && wb2.yearLoggedTo && [wb1.yearLoggedTo integerValue] != [wb2.yearLoggedTo integerValue]){
        [warning addObject:@"Cut Block Logged To"];
    }
    if(wb1.yearLoggedFrom && wb2.yearLoggedFrom && [wb1.yearLoggedFrom integerValue] != [wb2.yearLoggedFrom integerValue]){
        [warning addObject:@"Cut Block Logged From"];
    }
    if((wb1.loggingCompleteDate == nil && wb2.loggingCompleteDate != nil) || (wb1.loggingCompleteDate != nil && wb2.loggingCompleteDate == nil) || (wb1.loggingCompleteDate != nil && wb2.loggingCompleteDate != nil)){
        if(![wb1.loggingCompleteDate isEqualToDate:wb2.loggingCompleteDate]){
            [warning addObject:@"Cut Block Logging Complete Date"];
        }
    }
    if((wb1.surveyDate == nil && wb2.surveyDate != nil) || (wb1.surveyDate != nil && wb2.surveyDate == nil) || (wb1.surveyDate != nil && wb2.surveyDate != nil)){
        if(![wb1.surveyDate isEqualToDate:wb2.surveyDate]){
            [warning addObject:@"Cut Block Survey Date"];
        }
    }
    if(wb1.netArea && wb2.netArea && [wb1.netArea floatValue] != [wb2.netArea floatValue]){
        [warning addObject:@"Cut Block Net Area"];
    }
    if(wb1.surveyArea && wb2.surveyArea && (isnan([wb1.surveyArea floatValue]) ? 0.0 :[wb1.surveyArea floatValue] != [wb2.surveyArea floatValue])){
        [warning addObject:@"Cut Block Net Area"];
    }
    if((wb1.blockMaturityCode == nil && wb2.blockMaturityCode != nil) || (wb1.blockMaturityCode != nil && wb2.blockMaturityCode == nil) || (wb1.blockMaturityCode != nil && wb2.blockMaturityCode != nil)){
        if([wb1.regionId integerValue] == 1 && [wb2.regionId integerValue]== 1 && ![[wb1.blockMaturityCode.maturityCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[wb2.blockMaturityCode.maturityCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject:@"Cut Block Maturity Code"];
        }
    }
    if((wb1.blockSiteCode == nil && wb2.blockSiteCode != nil) || (wb1.blockSiteCode != nil && wb2.blockSiteCode == nil) || (wb1.blockSiteCode != nil && wb2.blockSiteCode != nil)){
        if([wb1.regionId integerValue] == 2 && [wb2.regionId integerValue]== 2 && ![[wb1.blockSiteCode.siteCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[wb2.blockSiteCode.siteCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
            [warning addObject:@"Cut Block Site Code"];
        }
    }
    if((wb1.ratioSamplingEnabled == nil && wb2.ratioSamplingEnabled != nil) || (wb1.ratioSamplingEnabled != nil && wb2.ratioSamplingEnabled == nil) || (wb1.ratioSamplingEnabled != nil && wb2.ratioSamplingEnabled != nil)){
        if([wb1.ratioSamplingEnabled integerValue] != [wb2.ratioSamplingEnabled integerValue]){
            [warning addObject:@"Cut Block Survey Type (SRS vs Ratio Sampling)"];
        }
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
        }
    }
    
    for(WasteStratum *st1 in wb1.blockStratum){
        for(WasteStratum *st2 in wb2.blockStratum){
            if([st1.stratum isEqualToString:st2.stratum]){
                if([st1.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue] && [st2.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                    [self ValidateStratum:st1 st2:st2 warning:warning stratum:st1.stratum];
                }else{
                    if((st1.stratumWasteTypeCode  == nil && st2.stratumWasteTypeCode != nil) || (st1.stratumWasteTypeCode  != nil && st2.stratumWasteTypeCode == nil) || (st1.stratumWasteTypeCode  != nil && st2.stratumWasteTypeCode != nil)){
                        if(![[st1.stratumWasteTypeCode.wasteTypeCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumWasteTypeCode.wasteTypeCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
                            [warning addObject:[NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Waste Type Code"]];
                        }
                    }
                    if((st1.stratumHarvestMethodCode  == nil && st2.stratumHarvestMethodCode != nil) || (st1.stratumHarvestMethodCode  != nil && st2.stratumHarvestMethodCode == nil) || (st1.stratumHarvestMethodCode  != nil && st2.stratumHarvestMethodCode != nil)){
                        if(![[st1.stratumHarvestMethodCode.harvestMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumHarvestMethodCode.harvestMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
                            [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Harvest Method Code"]];
                        }
                    }
                    if((st1.stratumAssessmentMethodCode  == nil && st2.stratumAssessmentMethodCode != nil) || (st1.stratumAssessmentMethodCode  != nil && st2.stratumAssessmentMethodCode == nil) || (st1.stratumAssessmentMethodCode  != nil && st2.stratumAssessmentMethodCode != nil)){
                        if(![[st1.stratumAssessmentMethodCode.assessmentMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumAssessmentMethodCode.assessmentMethodCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
                            [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Assessment Method Code"]];
                        }
                    }
                    if((st1.stratumWasteLevelCode  == nil && st2.stratumWasteLevelCode != nil) || (st1.stratumWasteLevelCode  != nil && st2.stratumWasteLevelCode == nil) || (st1.stratumWasteLevelCode  != nil && st2.stratumWasteLevelCode != nil)){
                        if(![[st1.stratumWasteLevelCode.wasteLevelCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[st2.stratumWasteLevelCode.wasteLevelCode.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
                            [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Waste Level Code"]];
                        }
                    }
                    if([st1.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue] && [st2.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue] ){
                        if((st1.stratumSurveyArea == nil && st2.stratumSurveyArea != nil) || (st1.stratumSurveyArea != nil && st2.stratumSurveyArea == nil) || (st1.stratumSurveyArea != nil && st2.stratumSurveyArea != nil)){
                            if([st1.stratumSurveyArea floatValue] != [st2.stratumSurveyArea floatValue]){
                                [warning addObject: [NSString stringWithFormat:@"Stratum (%@) %@", st1.stratum, @"Area"]];
                            }
                        }
                    }
                    
                    if([wb1.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                        // comparing Stratum
                        if([st2.stratumBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                            NSSet* pile_set = [NSSet setWithSet:st2.strPile.pileData];
                            for(WastePile *swb_pile in pile_set){
                                for(WastePile *pwb_pile in st1.strPile.pileData){
                                    if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                         if([pwb_pile.measuredLength doubleValue] != [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] != [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] != [swb_pile.measuredHeight doubleValue] && ![pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode] && [pwb_pile.measuredPileArea doubleValue] != [swb_pile.measuredPileArea doubleValue] && [pwb_pile.measuredPileVolume doubleValue] != [swb_pile.measuredPileVolume doubleValue]){
                                             [warning addObject: [NSString stringWithFormat:@"RU (%@), Stratum (%@), Block (%@), CP (%@), License (%@), Pile Number (%@), the measure dimensions on the incoming file do not match the receiving file.",wb2.reportingUnit, st1.stratum, wb2.blockNumber, wb2.cuttingPermitId, wb2.licenceNumber, swb_pile.pileNumber]];
                                         }
                                        break;
                                    }
                                }
                            }
                        }else{
                            if(st2.strPile.stratumPileId == st1.strPile.stratumPileId){
                                NSSet* pile_set = [NSSet setWithSet:st2.strPile.pileData];
                                for(WastePile *swb_pile in pile_set){
                                    for(WastePile *pwb_pile in st1.strPile.pileData){
                                        if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                             if([pwb_pile.length doubleValue] != [swb_pile.length doubleValue] && [pwb_pile.width doubleValue] != [swb_pile.width doubleValue] && [pwb_pile.height doubleValue] != [swb_pile.height doubleValue] && [pwb_pile.measuredLength doubleValue] != [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] != [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] != [swb_pile.measuredHeight doubleValue] && ![pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode]){
                                                 [warning addObject: [NSString stringWithFormat:@"RU (%@), Stratum (%@), Block (%@), CP (%@), License (%@), Pile Number (%@), the measure dimensions on the incoming file do not match the receiving file.",wb2.reportingUnit, st1.stratum, wb2.blockNumber, wb2.cuttingPermitId, wb2.licenceNumber, swb_pile.pileNumber]];
                                             }
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }else if([wb1.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]){
                        // comparing Stratum
                            for (AggregateCutblock *swb_aggCB in st2.stratumAgg){
                                for(AggregateCutblock *pwb_aggCB in st1.stratumAgg){
                                    if(pwb_aggCB.aggregateCuttingPermit == swb_aggCB.aggregateCuttingPermit && pwb_aggCB.aggregateCutblock == swb_aggCB.aggregateCutblock && pwb_aggCB.aggregateLicense == swb_aggCB.aggregateLicense){
                                       if([st2.stratumBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                                            NSSet* pile_set = [NSSet setWithSet:st2.strPile.pileData];
                                            for(WastePile *swb_pile in pile_set){
                                                for(WastePile *pwb_pile in st1.strPile.pileData){
                                                    if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                                         if([pwb_pile.measuredLength doubleValue] != [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] != [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] != [swb_pile.measuredHeight doubleValue] && ![pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode] && [pwb_pile.measuredPileArea doubleValue] != [swb_pile.measuredPileArea doubleValue] && [pwb_pile.measuredPileVolume doubleValue] != [swb_pile.measuredPileVolume doubleValue]){
                                                             [warning addObject: [NSString stringWithFormat:@"RU (%@), Stratum (%@), Block (%@), CP (%@), License (%@), Pile Number (%@), the measure dimensions on the incoming file do not match the receiving file.",wb2.reportingUnit, st1.stratum, wb2.blockNumber, wb2.cuttingPermitId, wb2.licenceNumber, swb_pile.pileNumber]];
                                                         }
                                                        break;
                                                    }
                                                }
                                            }
                                        }else{
                                           if(swb_aggCB.aggPile.stratumPileId == pwb_aggCB.aggPile.stratumPileId){
                                            NSSet* pile_set = [NSSet setWithSet:swb_aggCB.aggPile.pileData];
                                            for(WastePile *swb_pile in pile_set){
                                                for(WastePile *pwb_pile in pwb_aggCB.aggPile.pileData){
                                                    if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                                        if([pwb_pile.length doubleValue] != [swb_pile.length doubleValue] && [pwb_pile.width doubleValue] != [swb_pile.width doubleValue] && [pwb_pile.height doubleValue] != [swb_pile.height doubleValue] && [pwb_pile.measuredLength doubleValue] != [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] != [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] != [swb_pile.measuredHeight doubleValue] && ![pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode]){
                                                            [warning addObject: [NSString stringWithFormat:@"RU (%@), Stratum (%@), Block (%@), CP (%@), License (%@), Pile Number (%@), the measure dimensions on the incoming file do not match the receiving file.",wb2.reportingUnit, st1.stratum, wb2.blockNumber, wb2.cuttingPermitId, wb2.licenceNumber, swb_pile.pileNumber]];
                                                        }
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    
    return warning;
}

@end
