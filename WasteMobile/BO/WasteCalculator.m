//
//  WasteCalculator.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-15.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "WasteCalculator.h"
#import "WastePiece.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "Timbermark.h"
#import "MaterialKindCode.h"
#import "WasteClassCode.h"
#import "ScaleSpeciesCode.h"
#import "ScaleGradeCode.h"
#import "CheckerStatusCode.h"
#import "MaturityCode.h"
#import "MonetaryReductionFactorCode.h"
#import "PlotSizeCode.h"
#import "AssessmentMethodCode.h"
#import "SiteCode+CoreDataClass.h"
#import "Constants.h"
#import "WasteBlockDAO.h"
#import "EFWCoastStat+CoreDataClass.h"
#import "EFWInteriorStat+CoreDataClass.h"
#import "WastePile+CoreDataClass.h"

@implementation WasteCalculator

+(void) calculatePieceStat:(WastePiece *)wastePiece wasteStratum:(WasteStratum*)ws{
    int t = [wastePiece.topDiameter intValue];
    int b = [wastePiece.buttDiameter intValue];
    int l = [wastePiece.length intValue];
    
    int td = wastePiece.topDeduction ? [wastePiece.topDeduction intValue] : 0;
    int bd = wastePiece.buttDeduction ? [wastePiece.buttDeduction intValue] : 0;
    int ld = wastePiece.lengthDeduction ? [wastePiece.lengthDeduction intValue] : 0;
    
    
    float k = 0.0001571;
    float pi = 3.141592;
    float volume = 0;
    //NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:4 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    //NSLog(@"assessment method code = %@", wastePiece.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode);
    
    if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] ||
        [ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"S"]){
        if ([wastePiece.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"]){
            volume = ((((((t - td) * (t - td)) * pi) / 10000) + ((((t - td) * (t - td)) * pi) / 10000)) / 2) * (l - ld) / 10;
            //volume =(((t - td) *(t - td)) + ((t - td) * (t - td))) * ((l - ld)/10.0) * k;
        }else{
            volume = ((((((t - td) * (t - td)) * pi) / 10000) + ((((b - bd) * (b - bd)) * pi) / 10000)) / 2) * (l - ld) / 10;
            //volume =(((t - td) *(t - td)) + ((b - bd) * (b - bd))) * ((l - ld)/10.0) * k;
        }
    }else if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"O"]){
        //volume = [wastePiece.estimatedVolume floatValue];
        
    }else if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"]){
        float totalEstimate = 0;

        /*if ([wastePiece.pieceNumber rangeOfString:@"C"].location != NSNotFound){
            totalEstimate = [ws.checkTotalEstimatedVolume floatValue];
        }else{*/
            //totalEstimate = [ws.totalEstimatedVolume floatValue];
            totalEstimate = [wastePiece.piecePlot.plotEstimatedVolume floatValue];
            //we need to calculate the check estimated volume for original waste piece object
            wastePiece.checkPieceVolume =[[[NSDecimalNumber alloc] initWithFloat:([ws.checkTotalEstimatedVolume floatValue] * ([wastePiece.estimatedPercent floatValue] / 100.0))] decimalNumberByRoundingAccordingToBehavior:behavior];
        //}
        volume = totalEstimate * ([wastePiece.estimatedPercent floatValue] / 100.0);

        wastePiece.estimatedVolume = [[[NSDecimalNumber alloc] initWithFloat:volume] decimalNumberByRoundingAccordingToBehavior:behavior];
    }
    
    
    
    wastePiece.pieceVolume = [[NSDecimalNumber alloc] initWithFloat:volume];
    
    
    wastePiece.pieceVolume = [wastePiece.pieceVolume decimalNumberByRoundingAccordingToBehavior:behavior];
    
    //NSLog(@"Calculate piece volume ((%d -%d)^2 + (%d - %d)^2) * ((%d - %d)/10) * %f = %f => round to %@", t, td, b, bd, l,ld, k, volume, wastePiece.pieceVolume);
    
    wastePiece.volOverHa = [[NSDecimalNumber alloc] initWithDouble:([ws.stratumPlotSizeCode.plotMultipler doubleValue] * [wastePiece.pieceVolume doubleValue])];

    wastePiece.volOverHa = [wastePiece.volOverHa decimalNumberByRoundingAccordingToBehavior:behavior];
    
    //NSLog(@"Plot multipler = %@, vol/ha = %@", plotMultipler, wastePiece.volOverHa);
}

+(void) calculateRate:(WasteBlock *) wasteBlock {
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    Timbermark *ptm = nil;
    Timbermark *stm = nil;
    for (Timbermark *tm in [wasteBlock.blockTimbermark allObjects]){
        if ([tm.primaryInd intValue] == 1){
            ptm = tm;
        }else{
            stm = tm;
        }

        //**** Check Rates ****
        //*** populate other rate from the master wmrf ***
        
        // - static rate $1 for deciduous
//        if([wasteBlock.regionId integerValue] == InteriorRegion) {
//            tm.deciduousWMRF = [[[NSDecimalNumber alloc] initWithDouble:[tm.deciduousPrice doubleValue]] decimalNumberByRoundingAccordingToBehavior:behavior];
//        }else if([wasteBlock.regionId integerValue] == CoastRegion){
//            tm.deciduousWMRF = [[[NSDecimalNumber alloc] initWithDouble:[tm.deciduousPrice doubleValue]] decimalNumberByRoundingAccordingToBehavior:behavior];
//        }
        
        tm.deciduousWMRF = [[[NSDecimalNumber alloc] initWithDouble:[tm.deciduousPrice doubleValue]] decimalNumberByRoundingAccordingToBehavior:behavior];
        
        // - hembal rate = master rate * 0.25
        //new change Hembal U = WMRF x Hembal U Stumpage Rate
        tm.hembalWMRF = [[[NSDecimalNumber alloc] initWithDouble: [tm.wmrf doubleValue] * [tm.hembalPrice doubleValue]] decimalNumberByRoundingAccordingToBehavior:behavior];
        
        // - x rate = master rate * 0.25
        //new change X Grade = WMRF x X Grade Stumpage Rate
        tm.xWMRF = [[[NSDecimalNumber alloc] initWithDouble: [tm.wmrf doubleValue] * [tm.xPrice doubleValue]] decimalNumberByRoundingAccordingToBehavior:behavior];
        
        // - y rate is static rate 0.25
        //new change Y Grade = Y Grade Stumpage Rate
        tm.yWMRF = [[NSDecimalNumber alloc] initWithDouble: [tm.yPrice doubleValue]];
        
        // - Other rate is wmrf * conifer
        tm.allSppJWMRF = [[[NSDecimalNumber alloc] initWithDouble: [tm.coniferWMRF doubleValue] * [tm.wmrf doubleValue] ] decimalNumberByRoundingAccordingToBehavior:behavior];

        
        
        //**** Original Rates ****
        if([wasteBlock.regionId integerValue] == InteriorRegion) {
            tm.orgDeciduousWMRF = [[[NSDecimalNumber alloc] initWithDouble: [tm.orgWMRF doubleValue] * [tm.deciduousPrice doubleValue]] decimalNumberByRoundingAccordingToBehavior:behavior];
        }else if([wasteBlock.regionId integerValue] == CoastRegion){
            tm.orgDeciduousWMRF = [[[NSDecimalNumber alloc] initWithDouble: [tm.orgWMRF doubleValue] * [tm.deciduousPrice doubleValue]] decimalNumberByRoundingAccordingToBehavior:behavior];
        }
        
        tm.orgHembalWMRF = [[[NSDecimalNumber alloc] initWithDouble: [tm.orgWMRF doubleValue] * 0.25] decimalNumberByRoundingAccordingToBehavior:behavior];
        
        tm.orgXWMRF = [[[NSDecimalNumber alloc] initWithDouble: [tm.orgWMRF doubleValue] * 0.25] decimalNumberByRoundingAccordingToBehavior:behavior];
        
        tm.orgYWMRF = [[NSDecimalNumber alloc] initWithDouble: 0.25];
        
        tm.orgAllSppJWMRF = [[[NSDecimalNumber alloc] initWithDouble: [tm.coniferWMRF doubleValue] * [tm.orgWMRF doubleValue] ] decimalNumberByRoundingAccordingToBehavior:behavior];
    }
}

+(void) calculateWMRF:(WasteBlock *) wasteBlock updateOriginal:(BOOL) updateOriginal{
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:4 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];

    double blockBenchmark = 0.0;
    double ignoreExtraStratumArea = 0.0;
    
    //NSLog(@"stratum size = %d /",[[wasteBlock.blockStratum allObjects] count] );
    
    for (WasteStratum *ws in [wasteBlock.blockStratum allObjects]){
        
        if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"O"]){
            if([wasteBlock.userCreated intValue] == 1){
                ignoreExtraStratumArea = ignoreExtraStratumArea + [ws.stratumSurveyArea doubleValue];
            }else{
                ignoreExtraStratumArea = ignoreExtraStratumArea + [ws.stratumArea doubleValue];
            }

        }else{

            double stratumBenchmark = 0.0;
            int plot_counter = 0;
            for (WastePlot *wplot in [ws.stratumPlot allObjects]){
                
                if (!wplot.isMeasurePlot || [wplot.isMeasurePlot integerValue] == 1){
                    
                    double plotBenchmark = 0.0;
                    plot_counter = plot_counter + 1;
                    
                    for (WastePiece *wpiece in [wplot.plotPiece allObjects]){
                        
                        //only interested on avoidable pieces
                        BOOL isCheck = NO;
                        
                        if (! wpiece.pieceCheckerStatusCode ){
                            // no status at all - new piece
                            isCheck = YES;
                        //exclude deciduous speices
                        }else if ([wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"1"] || [wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"2"]){
                            // with status Not Check (1), Approve (2), or Edit (4) with "C" in the piece number
                            isCheck = YES;
                            
                        }else if([wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"4"] ){
                            // with edit status
                            if([wpiece.pieceNumber rangeOfString:@"C"].location !=NSNotFound){
                                isCheck = YES;
                            }
                        }
                        
                        if(isCheck){
                            if([wpiece.pieceWasteClassCode.wasteClassCode isEqualToString:@"A"]){
                                
                                
                                //add to benchmark for anything greater than x
                                if(![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Y"] &&
                                   ![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Z"] &&
                                   ![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"4"] &&
                                   ![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"5"] &&
                                   ![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"6"] &&
                                   !(([wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"1"] ||
                                      [wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"2"]) &&
                                        ([wpiece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"AL"] ||
                                         [wpiece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"AR"] ||
                                         [wpiece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"AS"] ||
                                         [wpiece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"BI"] ||
                                         [wpiece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"CO"] ||
                                         [wpiece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"MA"] ||
                                         [wpiece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"WI"])))
                                { //Don't caluculate using Grades Y,Z,4,5,6 or Grades 1 and 2 Deciduous Species
                                    if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                        plotBenchmark = plotBenchmark + ([wpiece.pieceVolume doubleValue]* ([ws.stratumPlotSizeCode.plotMultipler doubleValue]));
                                    }else if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"]){
                                        if ([wpiece.pieceNumber rangeOfString:@"C"].location != NSNotFound ){
                                            //if piece number contain "C", use the piece volume
                                            plotBenchmark = plotBenchmark + ([wpiece.pieceVolume doubleValue]);
                                        }else{
                                            if([wasteBlock.userCreated intValue] == 1){
                                                //for user created block, use piece volume instead of check piece volume
                                                plotBenchmark = plotBenchmark + ([wpiece.pieceVolume doubleValue]);
                                            }else{
                                                //if it is a original piece, use check piece volume for percent estimate stratum
                                                plotBenchmark = plotBenchmark + ([wpiece.checkPieceVolume doubleValue]);
                                            }
                                        }
                                    }else{
                                        // for 100% Scale
                                        plotBenchmark = plotBenchmark + ([wpiece.pieceVolume doubleValue]);
                                    }
                                }
                            }
                        }
                    }
                    //double temp_plot_benchmark = 0.0;
                    if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                        if([wasteBlock.userCreated intValue] == 1){
                            stratumBenchmark = stratumBenchmark + ([wplot.surveyedMeasurePercent intValue] > 0 ? plotBenchmark * (100.0/[wplot.surveyedMeasurePercent integerValue]) : plotBenchmark);
                            //temp_plot_benchmark =([wplot.surveyedMeasurePercent intValue] > 0 ? plotBenchmark * (100.0/[wplot.surveyedMeasurePercent integerValue]) : plotBenchmark);
                        }else{
                            stratumBenchmark = stratumBenchmark + ([wplot.checkerMeasurePercent intValue] > 0 ? plotBenchmark * (100.0/[wplot.checkerMeasurePercent integerValue]) : plotBenchmark);
                            //temp_plot_benchmark =([wplot.checkerMeasurePercent intValue] > 0 ? plotBenchmark * (100.0/[wplot.checkerMeasurePercent integerValue]) : plotBenchmark);
                        }
                    }else{
                        stratumBenchmark = stratumBenchmark + plotBenchmark;
                    }
                    //NSLog(@"stratum %@ plot %d billable volume for WMRF = %f", ws.stratum, [wplot.plotNumber intValue], (temp_plot_benchmark == 0 ? plotBenchmark : temp_plot_benchmark));

                }
            }
            if (stratumBenchmark > 0){
                if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                    //double temp_benchmark = 0.0;
                    if([wasteBlock.userCreated intValue] == 1){
                        blockBenchmark = blockBenchmark + ((stratumBenchmark / (plot_counter * 1.0)) * [ws.stratumSurveyArea doubleValue]);
                        //temp_benchmark =((stratumBenchmark / (plot_counter * 1.0)) * [ws.stratumSurveyArea doubleValue]);
                    }else{
                        blockBenchmark = blockBenchmark + ((stratumBenchmark / (plot_counter * 1.0)) * [ws.stratumArea doubleValue]);
                        //temp_benchmark =((stratumBenchmark / (plot_counter * 1.0)) * [ws.stratumArea doubleValue]);
                    }
                    //NSLog(@"stratum %@ billable volume for WMRF = %f", ws.stratum, temp_benchmark);
                }else{
                    blockBenchmark = blockBenchmark + stratumBenchmark;
                    //NSLog(@"stratum %@ billable volume for WMRF = %f", ws.stratum, stratumBenchmark);
                }
            }
        }
    }
    
    
    for (Timbermark *tm in [wasteBlock.blockTimbermark allObjects]){
        

        if([wasteBlock.userCreated intValue] == 1){
            if (([wasteBlock.surveyArea doubleValue] - ignoreExtraStratumArea) == 0 || blockBenchmark == 0 ){
                tm.avoidable = [[NSDecimalNumber alloc] initWithDouble:0.0];
            }else{
                tm.avoidable = [[[NSDecimalNumber alloc] initWithDouble:(blockBenchmark / ([wasteBlock.surveyArea doubleValue] - ignoreExtraStratumArea))] decimalNumberByRoundingAccordingToBehavior:behavior];
            }
        
            //update the benchmark
           /* if (wasteBlock.blockMaturityCode){
                if ( [wasteBlock.blockMaturityCode.maturityCode isEqualToString:@"I"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"10"];
                }else if ([wasteBlock.blockMaturityCode.maturityCode isEqualToString:@"M"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"35"];
                }
            }else*/ if(wasteBlock.blockSiteCode){
                if ([wasteBlock.blockSiteCode.siteCode isEqualToString:@"DB"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"4"];
                }else if ([wasteBlock.blockSiteCode.siteCode isEqualToString:@"TZ"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"10"];
                }else if ([wasteBlock.blockSiteCode.siteCode isEqualToString:@"WB"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"20"];
                }
            }
        }else{
            if (([wasteBlock.netArea doubleValue] - ignoreExtraStratumArea) == 0 || blockBenchmark == 0 ){
                tm.avoidable = [[NSDecimalNumber alloc] initWithDouble:0.0];
            }else{
                tm.avoidable = [[[NSDecimalNumber alloc] initWithDouble:(blockBenchmark / ([wasteBlock.netArea doubleValue] - ignoreExtraStratumArea))] decimalNumberByRoundingAccordingToBehavior:behavior];
            }
            //update the benchmark
            /*if (wasteBlock.blockCheckMaturityCode){
                if ( [wasteBlock.blockCheckMaturityCode.maturityCode isEqualToString:@"I"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"10"];
                }else if ([wasteBlock.blockCheckMaturityCode.maturityCode isEqualToString:@"M"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"35"];
                }
            }else */if(wasteBlock.blockCheckSiteCode){
                if ([wasteBlock.blockCheckSiteCode.siteCode isEqualToString:@"DB"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"4"];
                }else if ([wasteBlock.blockCheckSiteCode.siteCode isEqualToString:@"TZ"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"10"];
                }else if ([wasteBlock.blockCheckSiteCode.siteCode isEqualToString:@"WB"]){
                    tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"20"];
                }
            }
        }

        //NSLog(@"block average = %f /",[tm.avoidable floatValue]);
        

        
        float benchmark = [tm.benchmark floatValue];
        float wmrf = 0;
        
        if ([tm.timbermarkMonetaryReductionFactorCode.monetaryReductionFactorCode isEqualToString:@"B"]){
            wmrf = 1;
        }else{
            wmrf = ([tm.avoidable floatValue]  - benchmark) / [tm.avoidable floatValue] ;
        }
        
        
        //NSLog(@"WMRF = (block Average %f - benckmark %f) / block average %f = %f", [tm.avoidable floatValue], benchmark, [tm.avoidable floatValue], wmrf);
        if (wmrf < 0){
            wmrf = 0;
        }
        
        tm.wmrf = [[NSDecimalNumber alloc] initWithFloat: wmrf];
        tm.wmrf = [tm.wmrf decimalNumberByRoundingAccordingToBehavior:behavior];
        
        if (updateOriginal || [wasteBlock.userCreated intValue] == 1){
            // if it is user created cut block, copy the value to original every time!
            // copy the value into the original one, it should be call only once when the cut block get downloaded to the ipad for the first time
            tm.orgWMRF = [[NSDecimalNumber alloc] initWithDouble: [tm.wmrf doubleValue]];
        }
    }
    
    
}

+(NSString *) convertDecimalNumberToString:(NSDecimalNumber *) decimalNo {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    [formatter setMinimumIntegerDigits:1];
    return [formatter stringFromNumber:decimalNo];
}

+(void) calculatePiecesValue:(WasteBlock *) wasteBlock{

    NSDecimalNumberHandler *behaviorD2 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumberHandler *behaviorD4 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:4 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumberHandler *behaviorND = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:1 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    NSMutableDictionary *blockSurveyPieceSpeciesGradeVolume = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *blockCheckPieceSpeciesGradeVolume = [[NSMutableDictionary alloc] init];

    double blockCheckBillTotalVol = 0.0;
    double blockCheckCutControlTotalVol = 0.0;
    
    double blockSurveyBillTotalVol = 0.0;
    double blockSurveyCutControlTotalVol = 0.0;
    
    double blockBenchmark = 0.0;
    
    double blockCheckTotalValue = 0.0;
    double blockSurveyTotalValue = 0.0;
    
    int blockCheckCounter = 0;
    int blockSurveyCounter = 0;
   
    
    for (WasteStratum *ws in [wasteBlock.blockStratum allObjects]){
        NSLog(@" stratum  = %@, assessment method code = %@", ws.stratum, ws.stratumAssessmentMethodCode.assessmentMethodCode);
        
        if (![ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"O"]){
        
            double stratumCheckBillTotalVol = 0.0;
            double stratumCheckCutControlTotalVol = 0.0;
            
            double stratumSurveyBillTotalVol = 0.0;
            double stratumSurveyCutControlTotalVol = 0.0;
            
            double stratumBenchmark = 0.0;

            int stratumCheckCounter = 0;
            int stratumSurveyCounter = 0;
            
            NSMutableDictionary *stratumSurveyPieceSpeciesGradeVolume = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *stratumCheckPieceSpeciesGradeVolume = [[NSMutableDictionary alloc] init];
            
            //to store the total value of all plot within a stratum
            double stratumSurveyTotalValue = 0.0;
            double stratumCheckTotalValue = 0.0;
            
            for (WastePlot *wplot in [ws.stratumPlot allObjects]){
                //if it is ratio stratum plot, it has to be marked as measure plot
                double plotCheckBillTotalVol = 0.0;
                double plotCheckCutControlTotalVol = 0.0;
                double plotSurveyBillTotalVol = 0.0;
                double plotSurveyCutControlTotalVol = 0.0;
                double plotBenchmark = 0.0;

                int plotCheckBillCounter = 0;
                int plotSurveyBillCounter = 0;
                int plotCheckCutControlCounter = 0;
                int plotSurveyCutControlCounter = 0;
                
               if (!wplot.isMeasurePlot || [wplot.isMeasurePlot integerValue] == 1) {
                    NSMutableDictionary *plotSurveyPieceSpeciesGradeVolume = [[NSMutableDictionary alloc] init];
                    NSMutableDictionary *plotCheckPieceSpeciesGradeVolume = [[NSMutableDictionary alloc] init];
                   
                    for (WastePiece *wpiece in [wplot.plotPiece allObjects]) {
                        
                        //only interested on avoidable pieces
                        BOOL isSurvey = NO;
                        BOOL isCheck = NO;
                        if (![wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"1"] &&
                            wpiece.pieceNumber && wpiece.pieceScaleGradeCode && wpiece.pieceScaleSpeciesCode){
                            
                            NSString *key = [NSString stringWithFormat:@"%@_%@_%@",wpiece.pieceNumber, wpiece.pieceScaleGradeCode.scaleGradeCode, wpiece.pieceScaleSpeciesCode.scaleSpeciesCode];

                            if (!wpiece.pieceCheckerStatusCode ){
                                // no status at all - new piece
                                isCheck = YES;
                                if ([wasteBlock.userCreated intValue] == 1){
                                    isSurvey = YES;
                                }
                            } else {
                                // with status: Not Check (1), Approve (2), No Tally(3) or Edit (4)
                                if ([wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"2"]) {
                                    isCheck = YES;
                                    isSurvey = YES;
                                } else if([wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"3"]) {
                                    isSurvey = YES;
                                } else if([wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"4"]) {
                                    if([wpiece.pieceNumber rangeOfString:@"C"].location !=NSNotFound){
                                        isCheck = YES;
                                    }else{
                                        isSurvey = YES;
                                    }
                                }
                            }
                            
                            //---Volume & Value Summary Calculation:Original---
                            if (isSurvey) {
                                //add the volume to the cut-control pot
                                if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]) {
                                    plotSurveyCutControlTotalVol = plotSurveyCutControlTotalVol + ([wpiece.pieceVolume doubleValue] * ([ws.stratumPlotSizeCode.plotMultipler doubleValue]));
                                } else {
                                    plotSurveyCutControlTotalVol = plotSurveyCutControlTotalVol + [wpiece.pieceVolume doubleValue];
                                }
                                
                                plotSurveyCutControlCounter = plotSurveyCutControlCounter + 1;
                                
                                if ([wpiece.pieceWasteClassCode.wasteClassCode isEqualToString:@"A"]) {
                                    // add the volume to the billable
                                    if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]) {
                                        plotSurveyBillTotalVol = plotSurveyBillTotalVol + ([wpiece.pieceVolume doubleValue] * ([ws.stratumPlotSizeCode.plotMultipler doubleValue]));
                                    } else {
                                        plotSurveyBillTotalVol = plotSurveyBillTotalVol + [wpiece.pieceVolume doubleValue];
                                    }

                                    plotSurveyBillCounter = plotSurveyBillCounter + 1;
                                    
                                    // the mutable array is used to get the total value at the end
                                    if ([plotSurveyPieceSpeciesGradeVolume objectForKey:key]) {
                                        
                                        NSDecimalNumber *newDN =[[plotSurveyPieceSpeciesGradeVolume objectForKey:key] decimalNumberByAdding:wpiece.pieceVolume];
                                        
                                        [plotSurveyPieceSpeciesGradeVolume removeObjectForKey:key];
                                        [plotSurveyPieceSpeciesGradeVolume setObject:newDN forKey:key];
                                    } else {
                                        // for new key
                                        [plotSurveyPieceSpeciesGradeVolume setObject:[[NSDecimalNumber alloc] initWithDouble:[wpiece.pieceVolume doubleValue]] forKey:key];
                                    }
                                }
                            }// End of if:isSurvey

                            //---Volume & Value Summary Calculation:Check---
                            if (isCheck) {
                                // For Cut Control Volume
                                if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]) {
                                    plotCheckCutControlTotalVol = plotCheckCutControlTotalVol + ([wpiece.pieceVolume doubleValue] * ([ws.stratumPlotSizeCode.plotMultipler doubleValue]));
                                } else if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"]) {
                                    if ([wpiece.pieceNumber rangeOfString:@"C"].location !=NSNotFound) {
                                        plotCheckCutControlTotalVol = plotCheckCutControlTotalVol + ([wpiece.pieceVolume doubleValue]);
                                    } else {
                                        plotCheckCutControlTotalVol = plotCheckCutControlTotalVol + ([wpiece.checkPieceVolume doubleValue]);
                                    }
                                } else {
                                    plotCheckCutControlTotalVol = plotCheckCutControlTotalVol + ([wpiece.pieceVolume doubleValue] );
                                }
                                
                                plotCheckCutControlCounter = plotCheckCutControlCounter + 1;

                                // For Billable Volume
                                if ([wpiece.pieceWasteClassCode.wasteClassCode isEqualToString:@"A"]) {
                                    if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]) {
                                        plotCheckBillTotalVol = plotCheckBillTotalVol + ([wpiece.pieceVolume doubleValue]* ([ws.stratumPlotSizeCode.plotMultipler doubleValue]));
                                    } else if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"]) {
                                        if ([wpiece.pieceNumber rangeOfString:@"C"].location !=NSNotFound) {
                                            plotCheckBillTotalVol = plotCheckBillTotalVol + ([wpiece.pieceVolume doubleValue]);
                                        } else {
                                            plotCheckBillTotalVol = plotCheckBillTotalVol + ([wpiece.checkPieceVolume doubleValue]);
                                        }
                                    } else {
                                        plotCheckBillTotalVol = plotCheckBillTotalVol + ([wpiece.pieceVolume doubleValue]);
                                    }
                                    
                                    plotCheckBillCounter = plotCheckBillCounter + 1;
                                    
                                    //add to benchmark
                                    if (![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"W"] && ![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Y"] && ![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"4"] && ![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"5"] && ![wpiece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"6"]) {
                                        plotBenchmark = plotBenchmark + ([wpiece.pieceVolume doubleValue]* ([ws.stratumPlotSizeCode.plotMultipler doubleValue]));
                                    }

                                    if ([plotCheckPieceSpeciesGradeVolume objectForKey:key]) {
                                        NSDecimalNumber *newDN = nil;

                                        if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"] && [wpiece.pieceNumber rangeOfString:@"C"].location == NSNotFound) {
                                            newDN =[[plotCheckPieceSpeciesGradeVolume objectForKey:key] decimalNumberByAdding:wpiece.checkPieceVolume];
                                        } else {
                                            newDN =[[plotCheckPieceSpeciesGradeVolume objectForKey:key] decimalNumberByAdding:wpiece.pieceVolume];
                                        }
                                        
                                        [plotCheckPieceSpeciesGradeVolume removeObjectForKey:key];
                                        [plotCheckPieceSpeciesGradeVolume setObject:newDN forKey:key];
                                    } else {
                                        // for new key
                                        if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"] && [wpiece.pieceNumber rangeOfString:@"C"].location == NSNotFound) {
                                            [plotCheckPieceSpeciesGradeVolume setObject:[[NSDecimalNumber alloc] initWithDouble:[wpiece.checkPieceVolume doubleValue]] forKey:key];
                                        } else {
                                            [plotCheckPieceSpeciesGradeVolume setObject:[[NSDecimalNumber alloc] initWithDouble:[wpiece.pieceVolume doubleValue]] forKey:key];
                                        }
                                    }
                                }
                            }//End of if:isCheck
                        }
                    } //End of for loop:WastePiece
                    
                    // store the plot average volume here
                    //plotCheckBillTotalVol = [[[[NSDecimalNumber alloc] initWithFloat:plotCheckBillTotalVol ] decimalNumberByRoundingAccordingToBehavior:behaviorD4] de];
                    plotSurveyCutControlTotalVol = [[[[NSDecimalNumber alloc] initWithDouble:plotSurveyCutControlTotalVol ] decimalNumberByRoundingAccordingToBehavior:behaviorD4] doubleValue];
                    
                    wplot.checkAvoidY = [[[NSDecimalNumber alloc] initWithDouble:([wplot.checkerMeasurePercent integerValue]> 0 ? plotCheckBillTotalVol * (100.0/[wplot.checkerMeasurePercent integerValue]) : plotCheckBillTotalVol)] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                    wplot.checkAvoidX = [[[NSDecimalNumber alloc] initWithDouble:([wplot.checkerMeasurePercent integerValue]> 0 ? plotCheckCutControlTotalVol * (100.0/[wplot.checkerMeasurePercent integerValue]) :plotCheckCutControlTotalVol)] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                    
                    wplot.surveyAvoidY = [[[NSDecimalNumber alloc] initWithDouble:([wplot.surveyedMeasurePercent integerValue]> 0 ? plotSurveyBillTotalVol *(100.0/[wplot.surveyedMeasurePercent integerValue]) : plotSurveyBillTotalVol) ] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                    wplot.surveyAvoidX = [[[NSDecimalNumber alloc] initWithDouble:([wplot.surveyedMeasurePercent integerValue]> 0 ? plotSurveyCutControlTotalVol * (100.0/[wplot.surveyedMeasurePercent integerValue]) : plotSurveyCutControlTotalVol)] decimalNumberByRoundingAccordingToBehavior:behaviorD4];

                    wplot.deltaAvoidX = [[NSDecimalNumber alloc] initWithDouble:([wplot.checkAvoidX doubleValue] > 0.0 ? fabs((([wplot.checkAvoidX doubleValue] - [wplot.surveyAvoidX doubleValue])/ [wplot.checkAvoidX doubleValue]) * 100.0) : 0.0)];
                    wplot.deltaAvoidX = [wplot.deltaAvoidX decimalNumberByRoundingAccordingToBehavior:behaviorND];

                    wplot.deltaAvoidY = [[NSDecimalNumber alloc] initWithDouble:([wplot.checkAvoidY doubleValue] > 0.0 ? fabs((([wplot.checkAvoidY doubleValue] - [wplot.surveyAvoidY doubleValue])/ [wplot.checkAvoidY doubleValue]) * 100.0) : 0.0)];
                    wplot.deltaAvoidY = [wplot.deltaAvoidY decimalNumberByRoundingAccordingToBehavior:behaviorND];

                    
                    //now calculate the value by timbermark. This should support multiple Timbermark later
                    double plotSurveyTotalValue = 0.0;
                    double plotCheckTotalValue = 0.0;
                    
                    //for total value at plot level, only use primary TM
                    for(Timbermark *tm in [wasteBlock.blockTimbermark allObjects]){
                        if ([tm.primaryInd integerValue] == 1){
                            //Note: Logic updated based on IFORWASTE-137
                            if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                //---For standard stratum---
            
                               // plotSurveyTotalValue = ([self getValueFromPieceDictionary:plotSurveyPieceSpeciesGradeVolume timbermark:tm useOriginalRate:YES] * [ws.stratumPlotSizeCode.plotMultipler doubleValue]) * ([wplot.surveyedMeasurePercent integerValue] > 0 ? (100.0/[wplot.surveyedMeasurePercent integerValue]) : 1.0);
                                
                                //plotCheckTotalValue = ([self  getValueFromPieceDictionary:plotCheckPieceSpeciesGradeVolume timbermark:tm useOriginalRate:NO] * [ws.stratumPlotSizeCode.plotMultipler doubleValue]) * ([wplot.checkerMeasurePercent integerValue] > 0 ? (100.0/[wplot.checkerMeasurePercent integerValue]) : 1.0);
                                
                                plotSurveyTotalValue = [self getValueFromPieceDictionary:plotSurveyPieceSpeciesGradeVolume timbermark:tm useOriginalRate:NO];
                                
                                plotCheckTotalValue = [self  getValueFromPieceDictionary:plotCheckPieceSpeciesGradeVolume timbermark:tm useOriginalRate:NO];
                               
                            }else{
                                //---For Percent, Ocular, 100% Scale Stratum---
                                
                                //plotSurveyTotalValue = [self getValueFromPieceDictionary:plotSurveyPieceSpeciesGradeVolume timbermark:tm useOriginalRate:YES] * ([wplot.surveyedMeasurePercent integerValue] > 0 ? (100.0/[wplot.surveyedMeasurePercent integerValue]) : 1.0);
                                //plotCheckTotalValue = [self  getValueFromPieceDictionary:plotCheckPieceSpeciesGradeVolume timbermark:tm useOriginalRate:NO] * ([wplot.checkerMeasurePercent integerValue] > 0 ? (100.0/[wplot.checkerMeasurePercent integerValue]) : 1.0);
                                
                                double survaryTotalValue = [self getValueFromPieceDictionary:plotSurveyPieceSpeciesGradeVolume timbermark:tm useOriginalRate:YES];
                                double surveyArea = [[self convertDecimalNumberToString:ws.stratumSurveyArea] doubleValue];
                                plotSurveyTotalValue = survaryTotalValue / surveyArea;
                                
                                double checkTotalValue = [self getValueFromPieceDictionary:plotCheckPieceSpeciesGradeVolume timbermark:tm useOriginalRate:NO];
                                double checkArea = [[self convertDecimalNumberToString:ws.stratumArea] doubleValue];
                                plotCheckTotalValue = checkTotalValue / checkArea;
                            }
                        }
                    }
                    
                    // volume summary in plot IFOR-204
                    wplot.checkNetVal = [[[NSDecimalNumber alloc] initWithDouble:plotCheckTotalValue] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
                    
                    wplot.surveyNetVal = [[[NSDecimalNumber alloc] initWithDouble:plotSurveyTotalValue] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
                    
                    stratumCheckTotalValue = stratumCheckTotalValue + [wplot.checkNetVal doubleValue];
                    stratumSurveyTotalValue =  stratumSurveyTotalValue + [wplot.surveyNetVal doubleValue];
                    
                    wplot.deltaNetVal = [[NSDecimalNumber alloc] initWithDouble:([wplot.checkNetVal doubleValue] > 0.0 ? fabs((([wplot.surveyNetVal doubleValue] - [wplot.checkNetVal doubleValue])/ [wplot.checkNetVal doubleValue]) * 100.0 ): 0.0)];
                    wplot.deltaNetVal = [wplot.deltaNetVal decimalNumberByRoundingAccordingToBehavior:behaviorND];
                    
                    
                    //store the piece species grade volume array in stratum and block level for calculating the total value
                    for(NSString *key in [plotCheckPieceSpeciesGradeVolume allKeys]){
                        if ([stratumCheckPieceSpeciesGradeVolume objectForKey:key]){
                            
                            NSDecimalNumber *newDN =[[stratumCheckPieceSpeciesGradeVolume objectForKey:key] decimalNumberByAdding:[plotCheckPieceSpeciesGradeVolume objectForKey:key]];
                            
                            [stratumCheckPieceSpeciesGradeVolume removeObjectForKey:key];
                            [stratumCheckPieceSpeciesGradeVolume setObject:newDN forKey:key];
                        }else{
                            // for new key
                            [stratumCheckPieceSpeciesGradeVolume setObject:[[NSDecimalNumber alloc] initWithDouble:[[plotCheckPieceSpeciesGradeVolume objectForKey:key] doubleValue]] forKey:key];
                        }

                        if ([blockCheckPieceSpeciesGradeVolume objectForKey:key]){
                            
                            NSDecimalNumber *newDN =[[blockCheckPieceSpeciesGradeVolume objectForKey:key] decimalNumberByAdding:[plotCheckPieceSpeciesGradeVolume objectForKey:key]];
                            
                            [blockCheckPieceSpeciesGradeVolume removeObjectForKey:key];
                            [blockCheckPieceSpeciesGradeVolume setObject:newDN forKey:key];
                        }else{
                            // for new key
                            [blockCheckPieceSpeciesGradeVolume setObject:[[NSDecimalNumber alloc] initWithDouble:[[plotCheckPieceSpeciesGradeVolume objectForKey:key] doubleValue]] forKey:key];
                        }
                    }
                    
                    for(NSString *key in [plotSurveyPieceSpeciesGradeVolume allKeys]){
                        if ([stratumSurveyPieceSpeciesGradeVolume objectForKey:key]){
                            
                            NSDecimalNumber *newDN =[[stratumSurveyPieceSpeciesGradeVolume objectForKey:key] decimalNumberByAdding:[plotSurveyPieceSpeciesGradeVolume objectForKey:key]];
                            
                            [stratumSurveyPieceSpeciesGradeVolume removeObjectForKey:key];
                            [stratumSurveyPieceSpeciesGradeVolume setObject:newDN forKey:key];
                        }else{
                            // for new key
                            [stratumSurveyPieceSpeciesGradeVolume setObject:[[NSDecimalNumber alloc] initWithDouble:[[plotSurveyPieceSpeciesGradeVolume objectForKey:key] doubleValue]] forKey:key];
                        }

                        if ([blockSurveyPieceSpeciesGradeVolume objectForKey:key]){
                            
                            NSDecimalNumber *newDN =[[blockSurveyPieceSpeciesGradeVolume objectForKey:key] decimalNumberByAdding:[plotSurveyPieceSpeciesGradeVolume objectForKey:key]];
                            
                            [blockSurveyPieceSpeciesGradeVolume removeObjectForKey:key];
                            [blockSurveyPieceSpeciesGradeVolume setObject:newDN forKey:key];
                        }else{
                            // for new key
                            [blockSurveyPieceSpeciesGradeVolume setObject:[[NSDecimalNumber alloc] initWithDouble:[[plotSurveyPieceSpeciesGradeVolume objectForKey:key] doubleValue]] forKey:key];
                        }
                    }
                    
                    //add to the stratum stats
                    if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                        stratumCheckBillTotalVol = stratumCheckBillTotalVol + [wplot.checkAvoidY doubleValue];
                        stratumCheckCutControlTotalVol = stratumCheckCutControlTotalVol + [wplot.checkAvoidX doubleValue];
                    }else{
                        stratumCheckBillTotalVol = stratumCheckBillTotalVol + (ws.stratumArea == 0 || [wplot.checkAvoidY doubleValue] == 0.0 ? 0.0 : ([wplot.checkAvoidY doubleValue]/[ws.stratumArea doubleValue]));
                        stratumCheckCutControlTotalVol = stratumCheckCutControlTotalVol + (ws.stratumArea == 0 || [wplot.checkAvoidX doubleValue] == 0.0 ? 0.0 : ([wplot.checkAvoidX doubleValue]/[ws.stratumArea doubleValue]));
                    }

                    stratumCheckCounter = stratumCheckCounter + 1;
                    
                    //benchmark
                    stratumBenchmark = stratumBenchmark + (wplot.checkerMeasurePercent > 0 ? plotBenchmark * (100.0/[wplot.checkerMeasurePercent integerValue]) : plotBenchmark);
                    
                    //don't count the new plot into the survey counters
                    if(wplot.plotID){
                        if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                            stratumSurveyBillTotalVol = stratumSurveyBillTotalVol + [wplot.surveyAvoidY doubleValue];
                            stratumSurveyCutControlTotalVol = stratumSurveyCutControlTotalVol + [wplot.surveyAvoidX doubleValue];
                        }else{
                            stratumSurveyBillTotalVol = stratumSurveyBillTotalVol + ( ws.stratumSurveyArea == 0 || [wplot.surveyAvoidY doubleValue] == 0.0 ? 0.0 :([wplot.surveyAvoidY doubleValue]/[ws.stratumSurveyArea doubleValue]));
                            stratumSurveyCutControlTotalVol = stratumSurveyCutControlTotalVol + (ws.stratumSurveyArea == 0 || [wplot.surveyAvoidX doubleValue] == 0.0 ? 0.0 :([wplot.surveyAvoidX doubleValue]/[ws.stratumSurveyArea doubleValue]));
                        }

                        stratumSurveyCounter = stratumSurveyCounter + 1;
                    }
                }
                
            }
        
                
            ws.checkAvoidY = [[[NSDecimalNumber alloc] initWithDouble:(stratumCheckCounter > 0 ? stratumCheckBillTotalVol / stratumCheckCounter : 0.0)] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
            ws.checkAvoidX = [[[NSDecimalNumber alloc] initWithDouble:(stratumCheckCounter > 0 ? stratumCheckCutControlTotalVol / stratumCheckCounter : 0.0)] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
            
            ws.surveyAvoidY = [[[NSDecimalNumber alloc] initWithDouble:(stratumSurveyCounter > 0 ? stratumSurveyBillTotalVol / stratumSurveyCounter : 0.0)] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
            ws.surveyAvoidX = [[[NSDecimalNumber alloc] initWithDouble:(stratumSurveyCounter > 0 ? stratumSurveyCutControlTotalVol / stratumSurveyCounter : 0.0)] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
            
            ws.deltaAvoidX = [[NSDecimalNumber alloc] initWithDouble:([ws.checkAvoidX doubleValue] > 0.0 ? fabsf((([ws.checkAvoidX floatValue] - [ws.surveyAvoidX floatValue])/ [ws.checkAvoidX floatValue]) * 100): 0.0)];
            ws.deltaAvoidX = [ws.deltaAvoidX decimalNumberByRoundingAccordingToBehavior:behaviorND];
            ws.deltaAvoidY = [[NSDecimalNumber alloc] initWithDouble:([ws.checkAvoidY doubleValue] > 0.0 ? fabsf((([ws.checkAvoidY floatValue] - [ws.surveyAvoidY floatValue])/ [ws.checkAvoidY floatValue]) * 100): 0.0)];
            ws.deltaAvoidY = [ws.deltaAvoidY decimalNumberByRoundingAccordingToBehavior:behaviorND];


            //calculate the total value with timebermarks
            //*** calculate the total value again with the pieces data to avoid the rounding problem
            
            //at the strutam level, the total value will be the average of the total value of the plots within the stratum
            //DEV: because of the rounding issue: 0.1 + 0.1 + 0.1 = 0.2999999 etc
            // use NSDecimalNumber to do the division

            //---Value calculation within startum---
            NSDecimalNumber *valueDN =[[[NSDecimalNumber alloc] initWithDouble:(stratumCheckTotalValue)] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
            if ( stratumCheckCounter != 0){
                valueDN = [valueDN decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithDouble:stratumCheckCounter]];
            }
            if (![ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] && [ws.stratumArea floatValue] != 0.0){
                valueDN = [valueDN decimalNumberByDividingBy:ws.stratumArea];
            }
            ws.checkNetVal = [valueDN decimalNumberByRoundingAccordingToBehavior:behaviorD2];

            valueDN =[[[NSDecimalNumber alloc] initWithDouble:(stratumSurveyTotalValue)] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
           // NSLog(@"stratumSurveyCounter: %d", stratumSurveyCounter);
            if (stratumSurveyCounter != 0 && valueDN != 0){
                valueDN = [valueDN decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithDouble:stratumSurveyCounter]];
            }
            if (![ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] && [ws.stratumSurveyArea floatValue] != 0.0){
                valueDN = [valueDN decimalNumberByDividingBy:ws.stratumSurveyArea];
            }
            ws.surveyNetVal = [valueDN decimalNumberByRoundingAccordingToBehavior:behaviorD2];
           // NSLog(@"Stratum Value: %@", ws.surveyNetVal);
        
            ws.deltaNetVal = [[NSDecimalNumber alloc] initWithDouble:([ws.checkNetVal doubleValue] > 0.0 ? fabs((([ws.checkNetVal doubleValue] - [ws.surveyNetVal doubleValue])/ [ws.checkNetVal doubleValue]) * 100.0 ): 0.0)];
            ws.deltaNetVal = [ws.deltaNetVal decimalNumberByRoundingAccordingToBehavior:behaviorND];
            
            //add to the block stats
            //if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                blockCheckBillTotalVol = blockCheckBillTotalVol + ([ws.checkAvoidY doubleValue] * [ws.stratumArea doubleValue]);
                blockCheckCutControlTotalVol = blockCheckCutControlTotalVol + ([ws.checkAvoidX doubleValue] * [ws.stratumArea doubleValue]);
            //}else{
            //    blockCheckBillTotalVol = blockCheckBillTotalVol + ([ws.checkAvoidY doubleValue] * [ws.stratumArea doubleValue]);
             //   blockCheckCutControlTotalVol = blockCheckCutControlTotalVol + ([ws.checkAvoidX doubleValue] * [ws.stratumArea doubleValue]);
            //}
        
            blockCheckCounter = blockCheckCounter + 1;
            
            //benchmark
            blockBenchmark = blockBenchmark + (stratumBenchmark * [ws.stratumArea doubleValue]);

            valueDN = [[[NSDecimalNumber alloc] initWithDouble:([ws.checkNetVal doubleValue] * [ws.stratumArea doubleValue])] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
            //NSLog(@"add to Block original value :%0.2f", [valueDN floatValue]);
            blockCheckTotalValue = blockCheckTotalValue + [valueDN doubleValue];
            
            if(ws.stratumID > 0){
                //if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                    blockSurveyBillTotalVol = blockSurveyBillTotalVol + ([ws.surveyAvoidY doubleValue] * [ws.stratumSurveyArea doubleValue]);
                    blockSurveyCutControlTotalVol = blockSurveyCutControlTotalVol + ([ws.surveyAvoidX doubleValue] * [ws.stratumSurveyArea doubleValue]);
                //}else{
                //    blockSurveyBillTotalVol = blockSurveyBillTotalVol + ([ws.surveyAvoidY doubleValue]);
                //    blockSurveyCutControlTotalVol = blockSurveyCutControlTotalVol + ([ws.surveyAvoidX doubleValue]);
                //}

                
                blockSurveyCounter = blockSurveyCounter + 1;

                valueDN = [[[NSDecimalNumber alloc] initWithDouble:([ws.surveyNetVal doubleValue] * [ws.stratumSurveyArea doubleValue])]decimalNumberByRoundingAccordingToBehavior:behaviorD2];
                //NSLog(@"add to Block check value :%0.2f", [valueDN floatValue]);
                blockSurveyTotalValue = blockSurveyTotalValue + [valueDN doubleValue];

            }
        
            //DEBUG OUTPUT
            //NSLog(@" block bill volume = %0.4f", ([ws.surveyAvoidY doubleValue] * [ws.stratumSurveyArea doubleValue]));
            //NSLog(@" block cut control volume = %0.4f", ([ws.surveyAvoidX doubleValue] * [ws.stratumSurveyArea doubleValue]));
            //}
        }

    }//End of for:WasteStratum
    
    //DEBUG OUTPUT
    //NSLog(@" block check bill volume = %0.4f", blockCheckBillTotalVol);
    //NSLog(@" block cut control volume = %0.4f", blockCheckCutControlTotalVol);

    
    // formula: sum( stratum check total volume x stratum check area) / block check area
    // * assume the stratum check area added up to block check area
    wasteBlock.checkAvoidY = [[[NSDecimalNumber alloc] initWithDouble:(blockCheckBillTotalVol / [wasteBlock.netArea doubleValue] )] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
    wasteBlock.checkAvoidX = [[[NSDecimalNumber alloc] initWithDouble:(blockCheckCutControlTotalVol / [wasteBlock.netArea doubleValue] )] decimalNumberByRoundingAccordingToBehavior:behaviorD4];

    // formula: sum( stratum survey total volume x stratum survey area) / block survey area
    // * assume the stratum survey area added up to block survey area
    wasteBlock.surveyAvoidY = [[[NSDecimalNumber alloc] initWithDouble:(blockSurveyBillTotalVol / [wasteBlock.surveyArea doubleValue])] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
    wasteBlock.surveyAvoidX = [[[NSDecimalNumber alloc] initWithDouble:(blockSurveyCutControlTotalVol/ [wasteBlock.surveyArea doubleValue])] decimalNumberByRoundingAccordingToBehavior:behaviorD4];


    wasteBlock.deltaAvoidX = [[NSDecimalNumber alloc] initWithDouble:([wasteBlock.checkAvoidX doubleValue] > 0.0 ? fabsf((([wasteBlock.checkAvoidX floatValue] - [wasteBlock.surveyAvoidX floatValue])/ [wasteBlock.checkAvoidX floatValue]) * 100): 0.0)];
    wasteBlock.deltaAvoidX = [wasteBlock.deltaAvoidX decimalNumberByRoundingAccordingToBehavior:behaviorND];
    wasteBlock.deltaAvoidY = [[NSDecimalNumber alloc] initWithDouble:([wasteBlock.checkAvoidY doubleValue] > 0.0 ? fabsf((([wasteBlock.checkAvoidY floatValue] - [wasteBlock.surveyAvoidY floatValue])/ [wasteBlock.checkAvoidY floatValue]) * 100): 0.0)];
    wasteBlock.deltaAvoidY = [wasteBlock.deltaAvoidY decimalNumberByRoundingAccordingToBehavior:behaviorND];

    //again, calculate the total value with timebermarks
    
    /* 
    //DEV: 2015 04 21 - don't care about the mulit-timbermark calculation.
    float blockSurveyTotalValue = 0.0;
    float blockCheckTotalValue = 0.0;
    float timbermarkTotalArea = 0.0;
    
    for(Timbermark *tm in [wasteBlock.blockTimbermark allObjects]){
        
        blockSurveyTotalValue = blockSurveyTotalValue + ([self getValueFromPieceDictionary:blockSurveyPieceSpeciesGradeVolume timbermark:tm] * [tm.area doubleValue]);
        blockCheckTotalValue = blockCheckTotalValue + ([self  getValueFromPieceDictionary:blockCheckPieceSpeciesGradeVolume timbermark:tm] * [tm.area doubleValue]);
        timbermarkTotalArea = timbermarkTotalArea + [tm.area floatValue];
    }
    
    wasteBlock.checkNetVal = [[[NSDecimalNumber alloc] initWithDouble:(blockCheckTotalValue / timbermarkTotalArea)]  decimalNumberByRoundingAccordingToBehavior:behaviorD2];
    wasteBlock.surveyNetVal = [[[NSDecimalNumber alloc] initWithDouble:(blockSurveyTotalValue / timbermarkTotalArea)] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
    
    wasteBlock.deltaNetVal = [[NSDecimalNumber alloc] initWithDouble:([wasteBlock.checkNetVal doubleValue] > 0.0 ? fabsf((([wasteBlock.checkNetVal doubleValue] - [wasteBlock.surveyNetVal doubleValue])/ [wasteBlock.checkNetVal doubleValue]) * 100.0 ): 0.0)];
    wasteBlock.deltaNetVal = [wasteBlock.deltaNetVal decimalNumberByRoundingAccordingToBehavior:behaviorND];
    */
    
    //DEV: 2015 04 21 - formula for total value = SUM( stratum area X stratum total value)

    wasteBlock.checkNetVal = [[[NSDecimalNumber alloc] initWithDouble:blockCheckTotalValue ]  decimalNumberByRoundingAccordingToBehavior:behaviorD2];
    wasteBlock.surveyNetVal = [[[NSDecimalNumber alloc] initWithDouble:blockSurveyTotalValue ] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
    //NSLog(@"SURVEYNetVAl: %@", wasteBlock.surveyNetVal);
    
    wasteBlock.deltaNetVal = [[NSDecimalNumber alloc] initWithDouble:([wasteBlock.checkNetVal doubleValue] > 0.0 ? fabs((([wasteBlock.checkNetVal doubleValue] - [wasteBlock.surveyNetVal doubleValue])/ [wasteBlock.checkNetVal doubleValue]) * 100.0 ): 0.0)];
    wasteBlock.deltaNetVal = [wasteBlock.deltaNetVal decimalNumberByRoundingAccordingToBehavior:behaviorND];
    
    
    
    //benchmark - store it back into timber mark
    
    //for (Timbermark *tm in [wasteBlock.blockTimbermark allObjects]){
        //NSLog(@"block average = sum of volume %f / block area %d = %f",sumStratumVolume,[wasteBlock.netArea intValue], blockAverage);
    //    tm.avoidable = [[[NSDecimalNumber alloc] initWithDouble:(blockBenchmark / [wasteBlock.netArea doubleValue])] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
    //}

    
}

+ (double) getValueFromPieceDictionary:(NSDictionary *)pieceDictionary timbermark:(Timbermark *)tm useOriginalRate:(BOOL) useOrginalRate {
    double total = 0;

     NSDecimalNumberHandler *behaviorD2 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];

    for(NSString *key in [pieceDictionary allKeys]){
        //key is the combination of: PieceNo_Grade_Spieces
        NSLog(@"At key: %@", key);
        NSDecimalNumber *rate = nil;
        
        //NSLog(@"key:%@ , volume:%.2f", key, [[pieceDictionary objectForKey:key] doubleValue]);

        if (useOrginalRate){
            
            if([tm.timbermarkBlock.regionId integerValue] == InteriorRegion && [self isDeciduousSpecies:key]){
                rate = tm.orgDeciduousWMRF;

            }else if ([key rangeOfString:@"W_"].location != NSNotFound){
                rate = tm.orgDeciduousWMRF ;
                
            }else if ([key rangeOfString:@"X_"].location != NSNotFound){
                rate = tm.orgXWMRF ;
                
            }else if ([key rangeOfString:@"Y_"].location != NSNotFound || [key rangeOfString:@"_4_"].location != NSNotFound || [key rangeOfString:@"_5_"].location != NSNotFound ){
                rate =tm.orgYWMRF ;
                
            }else if ([key rangeOfString:@"U_HE"].location != NSNotFound || [key rangeOfString:@"U_BA"].location != NSNotFound){
                rate =tm.orgHembalWMRF ;

            }else if ([key rangeOfString:@"_6_"].location != NSNotFound){
                rate = [NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:0] decimalValue]];
            
            }else{
                rate =tm.orgAllSppJWMRF ;
            }
        }else{
            
            if([tm.timbermarkBlock.regionId integerValue] == InteriorRegion && [self isDeciduousSpecies:key]){
                rate = tm.deciduousPrice;
                
            }else if ([key rangeOfString:@"W_"].location != NSNotFound){
                rate = tm.deciduousPrice ;
                
            }else if ([key rangeOfString:@"X_"].location != NSNotFound){
                rate = tm.xPrice ;
                
            }else if ([key rangeOfString:@"Y_"].location != NSNotFound || [key rangeOfString:@"_4_"].location != NSNotFound || [key rangeOfString:@"_5_"].location != NSNotFound ){
                rate =tm.yPrice ;
                
            }else if ([key rangeOfString:@"U_HE"].location != NSNotFound || [key rangeOfString:@"U_BA"].location != NSNotFound || [key rangeOfString:@"U_LA"].location != NSNotFound){
                rate = tm.hembalPrice ;
                
            }else if ([key rangeOfString:@"_6_"].location != NSNotFound || [key rangeOfString:@"Z_"].location != NSNotFound){
                rate = [NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:0] decimalValue]];

            }else if ([key rangeOfString:@"U_"].location != NSNotFound || [key rangeOfString:@"J_"].location != NSNotFound){
                rate =tm.coniferPrice ;
                
            }
            else{
                rate =tm.allSppJWMRF ;
            }
        }
        
       
        //NSLog(@"total:%.2f", [[[[NSDecimalNumber alloc] initWithDouble:[[pieceDictionary objectForKey:key] doubleValue]] decimalNumberByMultiplyingBy:rate] doubleValue]);
        if( isnan([rate floatValue])) rate = [[NSDecimalNumber alloc] initWithInt:0];
        
        NSLog(@"rate:%.2f",  [rate doubleValue]);

        total  = total + [[[[[NSDecimalNumber alloc] initWithDouble:[[pieceDictionary objectForKey:key] doubleValue]] decimalNumberByMultiplyingBy:rate] decimalNumberByRoundingAccordingToBehavior:behaviorD2] doubleValue];
        
        NSLog(@"total:%.2f",  total );
    }
    return total;
}

// for interior block only, check if the species is deciduous or not
+(BOOL) isDeciduousSpecies:(NSString*)key{
    BOOL result = NO;
    
    //TODO = refine the deciduous species list
    if ([key rangeOfString:@"_AS_"].location != NSNotFound || [key rangeOfString:@"_BI_"].location != NSNotFound ||
            [key rangeOfString:@"_CO_"].location != NSNotFound || [key rangeOfString:@"_AL_"].location != NSNotFound ||
            [key rangeOfString:@"_MA_"].location != NSNotFound){
        result = YES;
    }
    return result;
}


+(void) calculateEFWStat:(WasteBlock *) wasteBlock{
    @try{
        // do something that might throw an exception

    Timbermark* timbermark = nil;
    for(Timbermark *tm in wasteBlock.blockTimbermark){
        if([tm.primaryInd intValue] == 1){
            timbermark = tm;
        }
   }
    NSDecimalNumberHandler *behaviorD2 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumberHandler *behaviorD4 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:4 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    if([wasteBlock.regionId intValue] == InteriorRegion){
        if(!wasteBlock.blockInteriorStat){
            wasteBlock.blockInteriorStat = [WasteBlockDAO createEFWInteriorStat];
        }else{
            [self resetEFWInteriorStat:wasteBlock.blockInteriorStat];
        }
        int stratum_counter = 0;
        for( WasteStratum* ws in wasteBlock.blockStratum){
            
            if(!ws.stratumInteriorStat){
                ws.stratumInteriorStat = [WasteBlockDAO createEFWInteriorStat];
            }else{
                [self resetEFWInteriorStat:ws.stratumInteriorStat];
            }
            
            // skip calculations if packing ratio stratum
            if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"] || [ws.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]) {
                NSLog(@"assessment code R!!");
                continue;
            }

            int plot_counter = 0;
            for(WastePlot* wp in ws.stratumPlot){
                if(!wp.plotInteriorStat){
                    wp.plotInteriorStat = [WasteBlockDAO createEFWInteriorStat];
                }else{
                    [self resetEFWInteriorStat:wp.plotInteriorStat];
                }
                if (!wp.isMeasurePlot || [wp.isMeasurePlot integerValue] == 1){
                
                    plot_counter = plot_counter + 1;
                    for(WastePiece* piece in wp.plotPiece){
                        // && ![piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"6"] this line  below was added as part of EFORWASTE-86 so that grade 6 is not calculated in total cut cntrl and total billable
                        if(![piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Z"] && ![piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"6"] ){
                            //Calculate the piece value and the piece volume in per ha
                            NSDecimalNumber *pieceRateDN = [[[NSDecimalNumber alloc] initWithDouble:[self pieceRate:piece.pieceScaleSpeciesCode.scaleSpeciesCode withGrade:piece.pieceScaleGradeCode.scaleGradeCode
                                                                                                          withAvoid:[piece.pieceWasteClassCode.wasteClassCode isEqualToString:@"A"] forBlock:wasteBlock withTimbermark:timbermark]] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                            
                            NSDecimalNumber *piecePriceDN =[[[NSDecimalNumber alloc] initWithDouble:[pieceRateDN doubleValue] * [piece.pieceVolume doubleValue]] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
                            NSDecimalNumber *valueDN = [[[NSDecimalNumber alloc] initWithDouble:[piecePriceDN doubleValue] * (100.0/[wp.surveyedMeasurePercent integerValue])] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
                            NSDecimalNumber *valueHaDN = nil;
                            NSDecimalNumber *pieceVolumeDN = [[[NSDecimalNumber alloc] initWithDouble:[piece.pieceVolume doubleValue] * (100.0/[wp.surveyedMeasurePercent integerValue])] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                            NSDecimalNumber *pieceVolumeHaDN = nil;
                            
                            if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                pieceVolumeHaDN = [[[NSDecimalNumber alloc] initWithDouble:[piece.pieceVolume doubleValue] * (100.0/[wp.surveyedMeasurePercent integerValue]) * [ws.stratumPlotSizeCode.plotMultipler doubleValue]]decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                                valueHaDN = [[[NSDecimalNumber alloc] initWithDouble:[piecePriceDN doubleValue] * (100.0/[wp.surveyedMeasurePercent integerValue]) * [ws.stratumPlotSizeCode.plotMultipler doubleValue]] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
                            }else{
                                pieceVolumeHaDN = [ws.stratumSurveyArea doubleValue] == 0 ? [[NSDecimalNumber alloc] initWithInt:0] : [pieceVolumeDN decimalNumberByDividingBy:ws.stratumSurveyArea];
                                valueHaDN = [ws.stratumSurveyArea doubleValue] == 0 ? [[NSDecimalNumber alloc] initWithInt:0] : [valueDN decimalNumberByDividingBy:ws.stratumSurveyArea];
                                
                            }
                        
                            //Add the value and the volume back to stat placeholders
                            if([piece.pieceWasteClassCode.wasteClassCode isEqualToString:@"A"]){
                                if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"5"] ){
                                    wp.plotInteriorStat.grade5ValueHa = [wp.plotInteriorStat.grade5ValueHa decimalNumberByAdding:valueHaDN];
                                    wp.plotInteriorStat.grade5Value = [wp.plotInteriorStat.grade5Value decimalNumberByAdding:valueDN];
                                    wp.plotInteriorStat.grade5VolumeHa = [wp.plotInteriorStat.grade5VolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                    wp.plotInteriorStat.grade5Volume = [wp.plotInteriorStat.grade5Volume decimalNumberByAdding:pieceVolumeDN];
                                }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"1"]||[piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"2"]){
                                    wp.plotInteriorStat.grade12ValueHa = [wp.plotInteriorStat.grade12ValueHa decimalNumberByAdding:valueHaDN];
                                    wp.plotInteriorStat.grade12Value = [wp.plotInteriorStat.grade12Value decimalNumberByAdding:valueDN];
                                    wp.plotInteriorStat.grade12VolumeHa = [wp.plotInteriorStat.grade12VolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                    wp.plotInteriorStat.grade12Volume = [wp.plotInteriorStat.grade12Volume decimalNumberByAdding:pieceVolumeDN];
                                }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"4"]){
                                    wp.plotInteriorStat.grade4ValueHa = [wp.plotInteriorStat.grade4ValueHa decimalNumberByAdding:valueHaDN];
                                    wp.plotInteriorStat.grade4Value = [wp.plotInteriorStat.grade4Value decimalNumberByAdding:valueDN];
                                    wp.plotInteriorStat.grade4VolumeHa = [wp.plotInteriorStat.grade4VolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                    wp.plotInteriorStat.grade4Volume = [wp.plotInteriorStat.grade4Volume decimalNumberByAdding:pieceVolumeDN];
                                }
                                if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"1"] || [piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"2"] || [piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"4"]){
                                    wp.plotInteriorStat.grade124ValueHa = [wp.plotInteriorStat.grade124ValueHa decimalNumberByAdding:valueHaDN];
                                    wp.plotInteriorStat.grade124Value = [wp.plotInteriorStat.grade124Value decimalNumberByAdding:valueDN];
                                    wp.plotInteriorStat.grade124VolumeHa = [wp.plotInteriorStat.grade124VolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                    wp.plotInteriorStat.grade124Volume = [wp.plotInteriorStat.grade124Volume decimalNumberByAdding:pieceVolumeDN];
                                }
                                
                                wp.plotInteriorStat.totalBillValueHa =[wp.plotInteriorStat.totalBillValueHa decimalNumberByAdding:valueHaDN];
                                wp.plotInteriorStat.totalBillValue =[wp.plotInteriorStat.totalBillValue decimalNumberByAdding:valueDN];
                                wp.plotInteriorStat.totalBillVolumeHa =[wp.plotInteriorStat.totalBillVolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                wp.plotInteriorStat.totalBillVolume = [wp.plotInteriorStat.totalBillVolume decimalNumberByAdding:pieceVolumeDN];
                            }
                        wp.plotInteriorStat.totalControlVolumeHa =[wp.plotInteriorStat.totalControlVolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                        wp.plotInteriorStat.totalControlVolume =[wp.plotInteriorStat.totalControlVolume decimalNumberByAdding:pieceVolumeDN];
                        }
                    }
                    //Add the values to the stratum level
                    ws.stratumInteriorStat.grade124ValueHa = [ws.stratumInteriorStat.grade124ValueHa decimalNumberByAdding:wp.plotInteriorStat.grade124ValueHa] ;
                    ws.stratumInteriorStat.grade124VolumeHa = [ws.stratumInteriorStat.grade124VolumeHa decimalNumberByAdding:wp.plotInteriorStat.grade124VolumeHa];
                    ws.stratumInteriorStat.grade5ValueHa = [ws.stratumInteriorStat.grade5ValueHa decimalNumberByAdding:wp.plotInteriorStat.grade5ValueHa];
                    ws.stratumInteriorStat.grade5VolumeHa = [ws.stratumInteriorStat.grade5VolumeHa decimalNumberByAdding:wp.plotInteriorStat.grade5VolumeHa];
                    ws.stratumInteriorStat.grade12ValueHa = [ws.stratumInteriorStat.grade12ValueHa decimalNumberByAdding:wp.plotInteriorStat.grade12ValueHa];
                    ws.stratumInteriorStat.grade12VolumeHa = [ws.stratumInteriorStat.grade12VolumeHa decimalNumberByAdding:wp.plotInteriorStat.grade12VolumeHa];
                    ws.stratumInteriorStat.grade4ValueHa = [ws.stratumInteriorStat.grade4ValueHa decimalNumberByAdding:wp.plotInteriorStat.grade4ValueHa];
                    ws.stratumInteriorStat.grade4VolumeHa = [ws.stratumInteriorStat.grade4VolumeHa decimalNumberByAdding:wp.plotInteriorStat.grade4VolumeHa];
                    ws.stratumInteriorStat.totalBillValueHa = [ws.stratumInteriorStat.totalBillValueHa decimalNumberByAdding:wp.plotInteriorStat.totalBillValueHa];
                    ws.stratumInteriorStat.totalBillVolumeHa = [ws.stratumInteriorStat.totalBillVolumeHa decimalNumberByAdding:wp.plotInteriorStat.totalBillVolumeHa];
                    ws.stratumInteriorStat.totalControlVolumeHa = [ws.stratumInteriorStat.totalControlVolumeHa decimalNumberByAdding:wp.plotInteriorStat.totalControlVolumeHa];
                }
            }
            
            if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] ){
                if(plot_counter > 1){
                    // Get the average of plots for stratum
                    ws.stratumInteriorStat.grade124ValueHa = [ws.stratumInteriorStat.grade124ValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                    ws.stratumInteriorStat.grade124VolumeHa = [ws.stratumInteriorStat.grade124VolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                    ws.stratumInteriorStat.grade5ValueHa = [ws.stratumInteriorStat.grade5ValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                    ws.stratumInteriorStat.grade5VolumeHa = [ws.stratumInteriorStat.grade5VolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                    ws.stratumInteriorStat.grade12ValueHa = [ws.stratumInteriorStat.grade12ValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                    ws.stratumInteriorStat.grade12VolumeHa = [ws.stratumInteriorStat.grade12VolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                    ws.stratumInteriorStat.grade4ValueHa = [ws.stratumInteriorStat.grade4ValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                    ws.stratumInteriorStat.grade4VolumeHa = [ws.stratumInteriorStat.grade4VolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                    ws.stratumInteriorStat.totalBillValueHa = [ws.stratumInteriorStat.totalBillValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                    ws.stratumInteriorStat.totalBillVolumeHa = [ws.stratumInteriorStat.totalBillVolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                    ws.stratumInteriorStat.totalControlVolumeHa = [ws.stratumInteriorStat.totalControlVolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                }
            }
            if([ws.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                if ([ws.stratumSurveyArea doubleValue] > 0 ){
                    ws.stratumInteriorStat.grade124Value = [ws.stratumInteriorStat.grade124ValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                    ws.stratumInteriorStat.grade124Volume = [ws.stratumInteriorStat.grade124VolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                    ws.stratumInteriorStat.grade5Value = [ws.stratumInteriorStat.grade5ValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                    ws.stratumInteriorStat.grade5Volume= [ws.stratumInteriorStat.grade5VolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                    ws.stratumInteriorStat.grade12Value = [ws.stratumInteriorStat.grade12ValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                    ws.stratumInteriorStat.grade12Volume = [ws.stratumInteriorStat.grade12VolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                    ws.stratumInteriorStat.grade4Value = [ws.stratumInteriorStat.grade4ValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                    ws.stratumInteriorStat.grade4Volume = [ws.stratumInteriorStat.grade4VolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                    ws.stratumInteriorStat.totalBillValue = [ws.stratumInteriorStat.totalBillValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                    ws.stratumInteriorStat.totalBillVolume = [ws.stratumInteriorStat.totalBillVolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                    ws.stratumInteriorStat.totalControlVolume = [ws.stratumInteriorStat.totalControlVolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                }
            }
            
            
            //NSLog(@"stratum %@ grade124 vol/ha %f", ws.stratum, [wasteBlock.blockInteriorStat.grade124VolumeHa doubleValue]);
            //NSLog(@"stratum %@ grade4 vol/ha %f", ws.stratum, [wasteBlock.blockInteriorStat.grade4VolumeHa doubleValue]);
            //NSLog(@"stratum %@ grade5 vol/ha %f", ws.stratum, [wasteBlock.blockInteriorStat.grade5VolumeHa doubleValue]);
            //NSLog(@"stratum %@ grade12 vol/ha %f", ws.stratum, [wasteBlock.blockInteriorStat.grade12VolumeHa doubleValue]);
            //NSLog(@"stratum %@ billable vol/ha %f", ws.stratum, [wasteBlock.blockInteriorStat.totalBillVolumeHa doubleValue]);
            //NSLog(@"stratum %@ cut control vol/ha %f", ws.stratum, [ws.stratumInteriorStat.totalControlVolumeHa doubleValue]);
            
            
            //Add the values to the block level
            wasteBlock.blockInteriorStat.grade124ValueHa = [wasteBlock.blockInteriorStat.grade124ValueHa decimalNumberByAdding:ws.stratumInteriorStat.grade124ValueHa];
            wasteBlock.blockInteriorStat.grade124VolumeHa = [wasteBlock.blockInteriorStat.grade124VolumeHa decimalNumberByAdding:ws.stratumInteriorStat.grade124VolumeHa];
            wasteBlock.blockInteriorStat.grade5ValueHa = [wasteBlock.blockInteriorStat.grade5ValueHa decimalNumberByAdding:ws.stratumInteriorStat.grade5ValueHa];
            wasteBlock.blockInteriorStat.grade5VolumeHa= [wasteBlock.blockInteriorStat.grade5VolumeHa decimalNumberByAdding:ws.stratumInteriorStat.grade5VolumeHa];
            wasteBlock.blockInteriorStat.grade12ValueHa = [wasteBlock.blockInteriorStat.grade12ValueHa decimalNumberByAdding:ws.stratumInteriorStat.grade12ValueHa];
            wasteBlock.blockInteriorStat.grade12VolumeHa = [wasteBlock.blockInteriorStat.grade12VolumeHa decimalNumberByAdding:ws.stratumInteriorStat.grade12VolumeHa];
            wasteBlock.blockInteriorStat.grade4ValueHa = [wasteBlock.blockInteriorStat.grade4ValueHa decimalNumberByAdding:ws.stratumInteriorStat.grade4ValueHa];
            wasteBlock.blockInteriorStat.grade4VolumeHa = [wasteBlock.blockInteriorStat.grade4VolumeHa decimalNumberByAdding:ws.stratumInteriorStat.grade4VolumeHa];
            wasteBlock.blockInteriorStat.totalBillValueHa = [wasteBlock.blockInteriorStat.totalBillValueHa decimalNumberByAdding:ws.stratumInteriorStat.totalBillValueHa];
            wasteBlock.blockInteriorStat.totalBillVolumeHa = [wasteBlock.blockInteriorStat.totalBillVolumeHa decimalNumberByAdding:ws.stratumInteriorStat.totalBillVolumeHa];
            wasteBlock.blockInteriorStat.totalControlValueHa = [wasteBlock.blockInteriorStat.totalControlValueHa decimalNumberByAdding:ws.stratumInteriorStat.totalControlValueHa];
            wasteBlock.blockInteriorStat.totalControlVolumeHa = [wasteBlock.blockInteriorStat.totalControlVolumeHa decimalNumberByAdding:ws.stratumInteriorStat.totalControlVolumeHa];
            
            wasteBlock.blockInteriorStat.grade124Value = [wasteBlock.blockInteriorStat.grade124Value decimalNumberByAdding:ws.stratumInteriorStat.grade124Value ];
            wasteBlock.blockInteriorStat.grade124Volume = [wasteBlock.blockInteriorStat.grade124Volume decimalNumberByAdding:ws.stratumInteriorStat.grade124Volume];
            wasteBlock.blockInteriorStat.grade5Value = [wasteBlock.blockInteriorStat.grade5Value decimalNumberByAdding:ws.stratumInteriorStat.grade5Value ];
            wasteBlock.blockInteriorStat.grade5Volume= [wasteBlock.blockInteriorStat.grade5Volume decimalNumberByAdding:ws.stratumInteriorStat.grade5Volume ];
            wasteBlock.blockInteriorStat.grade12Value = [wasteBlock.blockInteriorStat.grade12Value decimalNumberByAdding:ws.stratumInteriorStat.grade12Value ];
            wasteBlock.blockInteriorStat.grade12Volume = [wasteBlock.blockInteriorStat.grade12Volume decimalNumberByAdding:ws.stratumInteriorStat.grade12Volume ];
            wasteBlock.blockInteriorStat.grade4Value = [wasteBlock.blockInteriorStat.grade4Value decimalNumberByAdding:ws.stratumInteriorStat.grade4Value ];
            wasteBlock.blockInteriorStat.grade4Volume = [wasteBlock.blockInteriorStat.grade4Volume decimalNumberByAdding:ws.stratumInteriorStat.grade4Volume ];
            wasteBlock.blockInteriorStat.totalBillValue = [wasteBlock.blockInteriorStat.totalBillValue decimalNumberByAdding:ws.stratumInteriorStat.totalBillValue ];
            wasteBlock.blockInteriorStat.totalBillVolume = [wasteBlock.blockInteriorStat.totalBillVolume decimalNumberByAdding:ws.stratumInteriorStat.totalBillVolume ];
            wasteBlock.blockInteriorStat.totalControlValue = [wasteBlock.blockInteriorStat.totalControlValue decimalNumberByAdding:ws.stratumInteriorStat.totalControlValue ];
            wasteBlock.blockInteriorStat.totalControlVolume = [wasteBlock.blockInteriorStat.totalControlVolume decimalNumberByAdding:ws.stratumInteriorStat.totalControlVolume ];
            
            if([ws.stratumInteriorStat.totalControlVolumeHa doubleValue] > 0 ){
                stratum_counter = stratum_counter + 1;
            }
        }
        
        if (stratum_counter > 1){
            //NSDecimalNumber *swCounterDN = [[NSDecimalNumber alloc] initWithInt:stratum_counter];

            wasteBlock.blockInteriorStat.grade12VolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.grade12Volume decimalNumberByDividingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.grade4VolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.grade4Volume decimalNumberByDividingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.grade124VolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.grade124Volume decimalNumberByDividingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.grade5VolumeHa= [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.grade5Volume decimalNumberByDividingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.totalBillVolumeHa =  [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.totalBillVolume decimalNumberByDividingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.totalControlVolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.totalControlVolume decimalNumberByDividingBy:wasteBlock.surveyArea withBehavior:behaviorD4];

            
            wasteBlock.blockInteriorStat.grade124ValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.grade124ValueHa decimalNumberByDividingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.grade12ValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.grade12ValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.grade5ValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.grade5ValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.grade4ValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.grade4ValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.totalBillValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.totalBillValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.totalControlValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockInteriorStat.totalControlValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
            /*

            wasteBlock.blockInteriorStat.grade124VolumeHa = [wasteBlock.blockInteriorStat.grade124VolumeHa decimalNumberByDividingBy:swCounterDN withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.grade12VolumeHa = [wasteBlock.blockInteriorStat.grade12VolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.grade5VolumeHa= [wasteBlock.blockInteriorStat.grade5VolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.grade4VolumeHa = [wasteBlock.blockInteriorStat.grade4VolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.totalBillVolumeHa = [wasteBlock.blockInteriorStat.totalBillVolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];
            wasteBlock.blockInteriorStat.totalControlVolumeHa = [wasteBlock.blockInteriorStat.totalControlVolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];

            
            wasteBlock.blockInteriorStat.grade124Value = [wasteBlock.blockInteriorStat.grade124ValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.grade5Value = [wasteBlock.blockInteriorStat.grade5ValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.grade12Value = [wasteBlock.blockInteriorStat.grade12ValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.grade4Value = [wasteBlock.blockInteriorStat.grade4ValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.totalBillValue = [wasteBlock.blockInteriorStat.totalBillValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
            wasteBlock.blockInteriorStat.totalControlValue = [wasteBlock.blockInteriorStat.totalControlValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
            */
        }


            }else if([wasteBlock.regionId intValue] == CoastRegion){
            
            if(!wasteBlock.blockCoastStat){
                wasteBlock.blockCoastStat = [WasteBlockDAO createEFWCoastStat ];
            }else{
                [self resetEFWCoastStat :wasteBlock.blockCoastStat];
            }
            int stratum_counter = 0;
                for( WasteStratum* ws in wasteBlock.blockStratum){
                    if(!ws.stratumCoastStat){
                        ws.stratumCoastStat = [WasteBlockDAO createEFWCoastStat];
                    }else{
                        [self resetEFWCoastStat:ws.stratumCoastStat];
                    }
                    // skip calculations if packing ratio stratum
                    if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"] || [ws.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]) {
                        [self resetEFWCoastStat:ws.stratumCoastStat];
                    } else {

                        int plot_counter = 0;
                        for(WastePlot* wp in ws.stratumPlot){
                            if(!wp.plotCoastStat){
                                wp.plotCoastStat = [WasteBlockDAO createEFWCoastStat];
                            }else{
                                [self resetEFWCoastStat:wp.plotCoastStat];
                            }
                            if (!wp.isMeasurePlot || [wp.isMeasurePlot integerValue] == 1){
                                
                                plot_counter = plot_counter + 1;
                                for(WastePiece* piece in wp.plotPiece){
                                    if(![piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Z"]){
                                        //Calculate the piece value and the piece volume in per ha
                                        NSDecimalNumber *pieceRateDN = [[[NSDecimalNumber alloc] initWithDouble:[self pieceRate:piece.pieceScaleSpeciesCode.scaleSpeciesCode withGrade:piece.pieceScaleGradeCode.scaleGradeCode
                                                                                                                      withAvoid:[piece.pieceWasteClassCode.wasteClassCode isEqualToString:@"A"] forBlock:wasteBlock withTimbermark:timbermark]] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                                        NSDecimalNumber *piecePriceDN =[[[NSDecimalNumber alloc] initWithDouble:[pieceRateDN doubleValue] * [piece.pieceVolume doubleValue]] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                                        NSDecimalNumber *valueDN = [[[NSDecimalNumber alloc] initWithDouble:[piecePriceDN doubleValue] * (100.0/[wp.surveyedMeasurePercent integerValue])] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
                                        NSDecimalNumber *valueHaDN = nil;
                                        NSDecimalNumber *pieceVolumeDN = [[[NSDecimalNumber alloc] initWithDouble:[piece.pieceVolume doubleValue] * (100.0/[wp.surveyedMeasurePercent integerValue])] decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                                        NSDecimalNumber *pieceVolumeHaDN = nil;
                                        
                                        if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                            pieceVolumeHaDN = [[[NSDecimalNumber alloc] initWithDouble:[piece.pieceVolume doubleValue] * (100.0/[wp.surveyedMeasurePercent integerValue]) * [ws.stratumPlotSizeCode.plotMultipler doubleValue]]decimalNumberByRoundingAccordingToBehavior:behaviorD4];
                                            valueHaDN = [[[NSDecimalNumber alloc] initWithDouble:[piecePriceDN doubleValue] * (100.0/[wp.surveyedMeasurePercent integerValue]) * [ws.stratumPlotSizeCode.plotMultipler doubleValue]] decimalNumberByRoundingAccordingToBehavior:behaviorD2];
                                        }else{
                                            pieceVolumeHaDN = [ws.stratumSurveyArea doubleValue] == 0 ? [[NSDecimalNumber alloc] initWithInt:0] : [pieceVolumeDN decimalNumberByDividingBy:ws.stratumSurveyArea];
                                            valueHaDN = [ws.stratumSurveyArea doubleValue] == 0 ? [[NSDecimalNumber alloc] initWithInt:0] : [valueDN decimalNumberByDividingBy:ws.stratumSurveyArea];
                                        }
                                        
                                        //Add the value and the volume back to stat placeholders
                                        if([piece.pieceWasteClassCode.wasteClassCode isEqualToString:@"A"]){
                                            if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Y"] ){
                                                wp.plotCoastStat.gradeYValueHa = [wp.plotCoastStat.gradeYValueHa decimalNumberByAdding:valueHaDN];
                                                wp.plotCoastStat.gradeYValue = [wp.plotCoastStat.gradeYValue decimalNumberByAdding:valueDN];
                                                wp.plotCoastStat.gradeYVolumeHa = [wp.plotCoastStat.gradeYVolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                                wp.plotCoastStat.gradeYVolume = [wp.plotCoastStat.gradeYVolume decimalNumberByAdding:pieceVolumeDN];
                                            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"U"] && ([piece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"HE"]||[piece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"BA"]) ){
                                                wp.plotCoastStat.gradeUHBValueHa = [wp.plotCoastStat.gradeUHBValueHa decimalNumberByAdding:valueHaDN];
                                                wp.plotCoastStat.gradeUHBValue = [wp.plotCoastStat.gradeUHBValue decimalNumberByAdding:valueDN];
                                                wp.plotCoastStat.gradeUHBVolumeHa = [wp.plotCoastStat.gradeUHBVolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                                wp.plotCoastStat.gradeUHBVolume = [wp.plotCoastStat.gradeUHBVolume decimalNumberByAdding:pieceVolumeDN];
                                            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"U"] && (!([piece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"HE"]||[piece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"BA"])) ){
                                                wp.plotCoastStat.gradeUValueHa = [wp.plotCoastStat.gradeUValueHa decimalNumberByAdding:valueHaDN];
                                                wp.plotCoastStat.gradeUValue = [wp.plotCoastStat.gradeUValue decimalNumberByAdding:valueDN];
                                                wp.plotCoastStat.gradeUVolumeHa = [wp.plotCoastStat.gradeUVolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                                wp.plotCoastStat.gradeUVolume = [wp.plotCoastStat.gradeUVolume decimalNumberByAdding:pieceVolumeDN];
                                            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"X"]){
                                                wp.plotCoastStat.gradeXHBValueHa = [wp.plotCoastStat.gradeXHBValueHa decimalNumberByAdding:valueHaDN];
                                                wp.plotCoastStat.gradeXHBValue = [wp.plotCoastStat.gradeXHBValue decimalNumberByAdding:valueDN];
                                                wp.plotCoastStat.gradeXHBVolumeHa = [wp.plotCoastStat.gradeXHBVolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                                wp.plotCoastStat.gradeXHBVolume = [wp.plotCoastStat.gradeXHBVolume decimalNumberByAdding:pieceVolumeDN ];
                                            }else if(![piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"W"] && ![piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"X"] ){
                                                wp.plotCoastStat.gradeJValueHa = [wp.plotCoastStat.gradeJValueHa decimalNumberByAdding:valueHaDN];
                                                wp.plotCoastStat.gradeJValue = [wp.plotCoastStat.gradeJValue decimalNumberByAdding:valueDN];
                                                wp.plotCoastStat.gradeJVolumeHa = [wp.plotCoastStat.gradeJVolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                                wp.plotCoastStat.gradeJVolume = [wp.plotCoastStat.gradeJVolume decimalNumberByAdding:pieceVolumeDN];
                                            }
                                            if(![piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Y"] ){
                                                wp.plotCoastStat.totalBillValue =[wp.plotCoastStat.totalBillValue decimalNumberByAdding:valueDN];
                                                wp.plotCoastStat.totalBillValueHa =[wp.plotCoastStat.totalBillValueHa decimalNumberByAdding:valueHaDN];
                                                wp.plotCoastStat.totalBillVolumeHa =[wp.plotCoastStat.totalBillVolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                                wp.plotCoastStat.totalBillVolume =[wp.plotCoastStat.totalBillVolume decimalNumberByAdding:pieceVolumeDN];
                                            }
                                        }
                                        wp.plotCoastStat.totalControlVolumeHa =[wp.plotCoastStat.totalControlVolumeHa decimalNumberByAdding:pieceVolumeHaDN];
                                        wp.plotCoastStat.totalControlVolume =[wp.plotCoastStat.totalControlVolume decimalNumberByAdding:pieceVolumeDN];
                                    }
                                }
                                //Add the values to the stratum level
                                ws.stratumCoastStat.gradeJValueHa = [ws.stratumCoastStat.gradeJValueHa decimalNumberByAdding:wp.plotCoastStat.gradeJValueHa] ;
                                ws.stratumCoastStat.gradeJVolumeHa = [ws.stratumCoastStat.gradeJVolumeHa decimalNumberByAdding:wp.plotCoastStat.gradeJVolumeHa];
                                ws.stratumCoastStat.gradeYValueHa = [ws.stratumCoastStat.gradeYValueHa decimalNumberByAdding:wp.plotCoastStat.gradeYValueHa];
                                ws.stratumCoastStat.gradeYVolumeHa = [ws.stratumCoastStat.gradeYVolumeHa decimalNumberByAdding:wp.plotCoastStat.gradeYVolumeHa];
                                ws.stratumCoastStat.gradeUHBValueHa = [ws.stratumCoastStat.gradeUHBValueHa decimalNumberByAdding:wp.plotCoastStat.gradeUHBValueHa];
                                ws.stratumCoastStat.gradeUHBVolumeHa = [ws.stratumCoastStat.gradeUHBVolumeHa decimalNumberByAdding:wp.plotCoastStat.gradeUHBVolumeHa];
                                ws.stratumCoastStat.gradeUValueHa = [ws.stratumCoastStat.gradeUValueHa decimalNumberByAdding:wp.plotCoastStat.gradeUValueHa];
                                ws.stratumCoastStat.gradeUVolumeHa = [ws.stratumCoastStat.gradeUVolumeHa decimalNumberByAdding:wp.plotCoastStat.gradeUVolumeHa];
                                ws.stratumCoastStat.gradeXHBValueHa = [ws.stratumCoastStat.gradeXHBValueHa decimalNumberByAdding:wp.plotCoastStat.gradeXHBValueHa];
                                ws.stratumCoastStat.gradeXHBVolumeHa = [ws.stratumCoastStat.gradeXHBVolumeHa decimalNumberByAdding:wp.plotCoastStat.gradeXHBVolumeHa];
                                ws.stratumCoastStat.totalBillValueHa = [ws.stratumCoastStat.totalBillValueHa decimalNumberByAdding:wp.plotCoastStat.totalBillValueHa];
                                ws.stratumCoastStat.totalBillVolumeHa = [ws.stratumCoastStat.totalBillVolumeHa decimalNumberByAdding:wp.plotCoastStat.totalBillVolumeHa];
                                ws.stratumCoastStat.totalControlVolumeHa = [ws.stratumCoastStat.totalControlVolumeHa decimalNumberByAdding:wp.plotCoastStat.totalControlVolumeHa];
                            }
                        }
                        
                        if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] ){
                            if(plot_counter > 1){
                                // Get the average of plots for stratum
                                ws.stratumCoastStat.gradeJValueHa = [ws.stratumCoastStat.gradeJValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeJVolumeHa = [ws.stratumCoastStat.gradeJVolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                                ws.stratumCoastStat.gradeYValueHa = [ws.stratumCoastStat.gradeYValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeYVolumeHa = [ws.stratumCoastStat.gradeYVolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                                ws.stratumCoastStat.gradeUHBValueHa = [ws.stratumCoastStat.gradeUHBValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeUHBVolumeHa = [ws.stratumCoastStat.gradeUHBVolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                                ws.stratumCoastStat.gradeUValueHa = [ws.stratumCoastStat.gradeUValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeUVolumeHa = [ws.stratumCoastStat.gradeUVolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                                ws.stratumCoastStat.gradeXHBValueHa = [ws.stratumCoastStat.gradeXHBValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeXHBVolumeHa = [ws.stratumCoastStat.gradeXHBVolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                                ws.stratumCoastStat.totalBillValueHa = [ws.stratumCoastStat.totalBillValueHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD2];
                                ws.stratumCoastStat.totalBillVolumeHa = [ws.stratumCoastStat.totalBillVolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                                ws.stratumCoastStat.totalControlVolumeHa = [ws.stratumCoastStat.totalControlVolumeHa decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:plot_counter ] withBehavior:behaviorD4];
                            }
                        }
                        if([ws.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                            if ([ws.stratumSurveyArea doubleValue] > 0 ){
                                ws.stratumCoastStat.gradeJValue = [ws.stratumCoastStat.gradeJValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeJVolume = [ws.stratumCoastStat.gradeJVolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                                ws.stratumCoastStat.gradeYValue = [ws.stratumCoastStat.gradeYValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeYVolume= [ws.stratumCoastStat.gradeYVolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                                ws.stratumCoastStat.gradeUHBValue = [ws.stratumCoastStat.gradeUHBValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeUHBVolume = [ws.stratumCoastStat.gradeUHBVolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                                ws.stratumCoastStat.gradeUValue = [ws.stratumCoastStat.gradeUValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeUVolume = [ws.stratumCoastStat.gradeUVolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                                ws.stratumCoastStat.gradeXHBValue = [ws.stratumCoastStat.gradeXHBValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                                ws.stratumCoastStat.gradeXHBVolume = [ws.stratumCoastStat.gradeXHBVolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                                ws.stratumCoastStat.totalBillValue = [ws.stratumCoastStat.totalBillValueHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD2];
                                ws.stratumCoastStat.totalBillVolume = [ws.stratumCoastStat.totalBillVolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                                ws.stratumCoastStat.totalControlVolume = [ws.stratumCoastStat.totalControlVolumeHa decimalNumberByMultiplyingBy:ws.stratumSurveyArea withBehavior:behaviorD4];
                            }
                        }
                        
                        //Add the values to the block level
                        wasteBlock.blockCoastStat.gradeJValueHa = [wasteBlock.blockCoastStat.gradeJValueHa decimalNumberByAdding:ws.stratumCoastStat.gradeJValueHa];
                        wasteBlock.blockCoastStat.gradeJVolumeHa = [wasteBlock.blockCoastStat.gradeJVolumeHa decimalNumberByAdding:ws.stratumCoastStat.gradeJVolumeHa];
                        wasteBlock.blockCoastStat.gradeYValueHa = [wasteBlock.blockCoastStat.gradeYValueHa decimalNumberByAdding:ws.stratumCoastStat.gradeYValueHa];
                        wasteBlock.blockCoastStat.gradeYVolumeHa= [wasteBlock.blockCoastStat.gradeYVolumeHa decimalNumberByAdding:ws.stratumCoastStat.gradeYVolumeHa];
                        wasteBlock.blockCoastStat.gradeUHBValueHa = [wasteBlock.blockCoastStat.gradeUHBValueHa decimalNumberByAdding:ws.stratumCoastStat.gradeUHBValueHa];
                        wasteBlock.blockCoastStat.gradeUHBVolumeHa = [wasteBlock.blockCoastStat.gradeUHBVolumeHa decimalNumberByAdding:ws.stratumCoastStat.gradeUHBVolumeHa];
                        wasteBlock.blockCoastStat.gradeUValueHa = [wasteBlock.blockCoastStat.gradeUValueHa decimalNumberByAdding:ws.stratumCoastStat.gradeUValueHa];
                        wasteBlock.blockCoastStat.gradeUVolumeHa = [wasteBlock.blockCoastStat.gradeUVolumeHa decimalNumberByAdding:ws.stratumCoastStat.gradeUVolumeHa];
                        wasteBlock.blockCoastStat.gradeXHBValueHa = [wasteBlock.blockCoastStat.gradeXHBValueHa decimalNumberByAdding:ws.stratumCoastStat.gradeXHBValueHa];
                        wasteBlock.blockCoastStat.gradeXHBVolumeHa = [wasteBlock.blockCoastStat.gradeXHBVolumeHa decimalNumberByAdding:ws.stratumCoastStat.gradeXHBVolumeHa];
                        wasteBlock.blockCoastStat.totalBillValueHa = [wasteBlock.blockCoastStat.totalBillValueHa decimalNumberByAdding:ws.stratumCoastStat.totalBillValueHa];
                        wasteBlock.blockCoastStat.totalBillVolumeHa = [wasteBlock.blockCoastStat.totalBillVolumeHa decimalNumberByAdding:ws.stratumCoastStat.totalBillVolumeHa];
                        wasteBlock.blockCoastStat.totalControlValueHa = [wasteBlock.blockCoastStat.totalControlValueHa decimalNumberByAdding:ws.stratumCoastStat.totalControlValueHa];
                        wasteBlock.blockCoastStat.totalControlVolumeHa = [wasteBlock.blockCoastStat.totalControlVolumeHa decimalNumberByAdding:ws.stratumCoastStat.totalControlVolumeHa];
                        
                        wasteBlock.blockCoastStat.gradeJValue = [wasteBlock.blockCoastStat.gradeJValue decimalNumberByAdding:ws.stratumCoastStat.gradeJValue ];
                        wasteBlock.blockCoastStat.gradeJVolume = [wasteBlock.blockCoastStat.gradeJVolume decimalNumberByAdding:ws.stratumCoastStat.gradeJVolume];
                        wasteBlock.blockCoastStat.gradeYValue = [wasteBlock.blockCoastStat.gradeYValue decimalNumberByAdding:ws.stratumCoastStat.gradeYValue ];
                        wasteBlock.blockCoastStat.gradeYVolume= [wasteBlock.blockCoastStat.gradeYVolume decimalNumberByAdding:ws.stratumCoastStat.gradeYVolume ];
                        wasteBlock.blockCoastStat.gradeUHBValue = [wasteBlock.blockCoastStat.gradeUHBValue decimalNumberByAdding:ws.stratumCoastStat.gradeUHBValue ];
                        wasteBlock.blockCoastStat.gradeUHBVolume = [wasteBlock.blockCoastStat.gradeUHBVolume decimalNumberByAdding:ws.stratumCoastStat.gradeUHBVolume ];
                        wasteBlock.blockCoastStat.gradeUValue = [wasteBlock.blockCoastStat.gradeUValue decimalNumberByAdding:ws.stratumCoastStat.gradeUValue ];
                        wasteBlock.blockCoastStat.gradeUVolume = [wasteBlock.blockCoastStat.gradeUVolume decimalNumberByAdding:ws.stratumCoastStat.gradeUVolume ];
                        wasteBlock.blockCoastStat.gradeXHBValue = [wasteBlock.blockCoastStat.gradeXHBValue decimalNumberByAdding:ws.stratumCoastStat.gradeXHBValue ];
                        wasteBlock.blockCoastStat.gradeXHBVolume = [wasteBlock.blockCoastStat.gradeXHBVolume decimalNumberByAdding:ws.stratumCoastStat.gradeXHBVolume ];
                        wasteBlock.blockCoastStat.totalBillValue = [wasteBlock.blockCoastStat.totalBillValue decimalNumberByAdding:ws.stratumCoastStat.totalBillValue ];
                        wasteBlock.blockCoastStat.totalBillVolume = [wasteBlock.blockCoastStat.totalBillVolume decimalNumberByAdding:ws.stratumCoastStat.totalBillVolume ];
                        wasteBlock.blockCoastStat.totalControlValue = [wasteBlock.blockCoastStat.totalControlValue decimalNumberByAdding:ws.stratumCoastStat.totalControlValue ];
                        wasteBlock.blockCoastStat.totalControlVolume = [wasteBlock.blockCoastStat.totalControlVolume decimalNumberByAdding:ws.stratumCoastStat.totalControlVolume ];
                        
                        if([ws.stratumCoastStat.totalControlVolumeHa doubleValue] > 0 ){
                            stratum_counter = stratum_counter + 1;
                        }
                    }
                }
            
            if (stratum_counter > 1){
                //NSDecimalNumber *swCounterDN = [[NSDecimalNumber alloc] initWithInt:stratum_counter];

                wasteBlock.blockCoastStat.gradeJValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockCoastStat.gradeJValueHa decimalNumberByDividingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeUHBValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] :[wasteBlock.blockCoastStat.gradeUHBValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeUValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] :[wasteBlock.blockCoastStat.gradeUValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeYValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] :[wasteBlock.blockCoastStat.gradeYValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeXHBValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] :[wasteBlock.blockCoastStat.gradeXHBValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.totalBillValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] :[wasteBlock.blockCoastStat.totalBillValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.totalControlValueHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] :[wasteBlock.blockCoastStat.totalControlValueHa decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD2];
                
                wasteBlock.blockCoastStat.gradeJVolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockCoastStat.gradeJVolume decimalNumberByDividingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeUHBVolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockCoastStat.gradeUHBVolume decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeUVolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockCoastStat.gradeUVolume decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeYVolumeHa= [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockCoastStat.gradeYVolume decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeXHBVolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockCoastStat.gradeXHBVolume decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.totalBillVolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockCoastStat.totalBillVolume decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.totalControlVolumeHa = [wasteBlock.surveyArea floatValue] == 0 ?
                [[NSDecimalNumber alloc] initWithInt:0] : [wasteBlock.blockCoastStat.totalControlVolume decimalNumberByDividingBy:wasteBlock.surveyArea  withBehavior:behaviorD4];
    /*
                wasteBlock.blockCoastStat.gradeJValueHa = [wasteBlock.blockCoastStat.gradeJValueHa decimalNumberByDividingBy:swCounterDN withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeUHBValueHa = [wasteBlock.blockCoastStat.gradeUHBValueHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeYValueHa = [wasteBlock.blockCoastStat.gradeYValueHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeXHBValueHa = [wasteBlock.blockCoastStat.gradeXHBValueHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.totalBillValueHa = [wasteBlock.blockCoastStat.totalBillValueHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.totalControlValueHa = [wasteBlock.blockCoastStat.totalControlValueHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD2];
                
                wasteBlock.blockCoastStat.gradeJVolumeHa = [wasteBlock.blockCoastStat.gradeJVolumeHa decimalNumberByDividingBy:swCounterDN withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeUHBVolumeHa = [wasteBlock.blockCoastStat.gradeUHBVolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeYVolumeHa= [wasteBlock.blockCoastStat.gradeYVolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeXHBVolumeHa = [wasteBlock.blockCoastStat.gradeXHBVolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.totalBillVolumeHa = [wasteBlock.blockCoastStat.totalBillVolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.totalControlVolumeHa = [wasteBlock.blockCoastStat.totalControlVolumeHa decimalNumberByDividingBy:swCounterDN  withBehavior:behaviorD4];
      */
                /*
                wasteBlock.blockCoastStat.gradeUHBVolume = [wasteBlock.blockCoastStat.gradeUHBVolumeHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeXHBVolume = [wasteBlock.blockCoastStat.gradeXHBVolumeHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeJVolume = [wasteBlock.blockCoastStat.gradeJVolumeHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.gradeYVolume= [wasteBlock.blockCoastStat.gradeYVolumeHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.totalBillVolume = [wasteBlock.blockCoastStat.totalBillVolumeHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
                wasteBlock.blockCoastStat.totalControlVolume = [wasteBlock.blockCoastStat.totalControlVolumeHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD4];
                
                wasteBlock.blockCoastStat.gradeJValue = [wasteBlock.blockCoastStat.gradeJValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeYValue = [wasteBlock.blockCoastStat.gradeYValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeUHBValue = [wasteBlock.blockCoastStat.gradeUHBValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.gradeXHBValue = [wasteBlock.blockCoastStat.gradeXHBValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.totalBillValue = [wasteBlock.blockCoastStat.totalBillValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
                wasteBlock.blockCoastStat.totalControlValue = [wasteBlock.blockCoastStat.totalControlValueHa decimalNumberByMultiplyingBy:wasteBlock.surveyArea withBehavior:behaviorD2];
                 */
            }
         }
    }

    @catch (NSException *exception) {
        // deal with the exception
        NSLog(@"Exception caught in calcuateEFWStat funciton.");
    }
    @finally {
        // optional block of clean-up code
        // executed whether or not an exception occurred
    }
}

+(void) resetEFWCoastStat:(EFWCoastStat *) stat{
    stat.gradeJVolume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeJValue= [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeJValueHa= [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeJVolume= [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeJVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeYValue = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeYValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeYVolume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeYVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeUHBValue = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeUHBValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeUHBVolume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeUHBVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeUValue = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeUValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeUVolume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeUVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeXHBValue = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeXHBValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeXHBVolume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.gradeXHBVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    
    stat.totalBillValue = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalBillValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalBillVolume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalBillVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalControlValue = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalControlValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalControlVolume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalControlVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];

}

+(void) resetEFWInteriorStat:(EFWInteriorStat *) stat{
    stat.grade4Value = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade4Volume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade4ValueHa= [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade4VolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade124Value = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade124ValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade124Volume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade124VolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade12Value = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade12ValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade12Volume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade12VolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade5Value = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade5ValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade5Volume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.grade5VolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    
    stat.totalBillValue = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalBillValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalBillVolume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalBillVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalControlValue = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalControlValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalControlVolume = [[NSDecimalNumber alloc] initWithInt:0];
    stat.totalControlVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
}

+(float)pieceRate:(NSString*)species withGrade:(NSString*)grade withAvoid:(BOOL)avoid forBlock:(WasteBlock*)wasteBlock withTimbermark:(Timbermark*)timbermark{
    
 
     //NSLog(@"PIECE");
     //NSLog(@"\n species = %@ \n grade = %@", species, grade);
     //NSLog(@"TIMBERMARK \n");
     //NSLog(@"\nH/B U = %@ \n Decidous = %@ All_X = %@ \n All_Y = %@ All Spp J+ = %@", primaryTimbermark.hembalWMRF, primaryTimbermark.deciduousWMRF, primaryTimbermark.xWMRF,primaryTimbermark.yWMRF, primaryTimbermark.allSppJWMRF );
 
    if (!avoid){
        return 0.0;
    }else{
        
        if(!timbermark){
            //NSLog(@"Missing primary timbermark");
            return 0.0;
        }
        
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        
        
        if(( [species isEqualToString:@"HE"] && [grade isEqualToString:@"U"] ) ||
           ([species isEqualToString:@"BA"] && [grade isEqualToString:@"U"])){
            return [timbermark.hembalWMRF floatValue];
        }
            else if( [grade isEqualToString:@"W"] ||
                    (![grade isEqualToString:@"4"] && ![grade isEqualToString:@"5"] && [wasteBlock.regionId integerValue] == InteriorRegion && ([species isEqualToString:@"AS"]||
                                                                                                                                                [species isEqualToString:@"BI"]||
                                                                                                                                                [species isEqualToString:@"CO"]||
                                                                                                                                                [species isEqualToString:@"AL"]||
                                                                                                                                                [species isEqualToString:@"MA"]||
                                                                                                                                                [species isEqualToString:@"OT"]||
                                                                                                                                                [species isEqualToString:@"AR"]||
                                                                                                                                                [species isEqualToString:@"WI"])) ){
                return [timbermark.deciduousWMRF floatValue];
        }
        else if( [grade isEqualToString:@"X"] ){
            return [timbermark.xWMRF floatValue];
        }
        else if( [grade isEqualToString:@"Y"] || [grade isEqualToString:@"4"] || [grade isEqualToString:@"5"]){
            return [timbermark.yWMRF floatValue];
        }
        else if( [grade isEqualToString:@"6"] ){
            return 0.0;
        }
        else{
            return [timbermark.allSppJWMRF floatValue];
        }
    }
}


@end
