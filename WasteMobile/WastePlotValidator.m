//
//  WastePlotValidator.m
//  WasteMobile
//
//  Created by Jack Wong on 2015-05-24.
//  Copyright (c) 2015 Salus Systems. All rights reserved.
//

#import "WastePlotValidator.h"
#import "WastePiece.h"
#import "WasteClassCode.h"
#import "MaterialKindCode.h"
#import "BorderlineCode.h"
#import "ScaleGradeCode.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "WasteBlock.h"
#import "AssessmentMethodCode.h"
#import "StratumTypeCode.h"
#import "MaturityCode.h"
#import "CommentCode.h"
#import "DecayTypeCode.h"
#import "WasteTypeCode.h"
#import "PlotSizeCode.h"
#import "ButtEndCode.h"
#import "TopEndCode.h"
#import "CheckerStatusCode.h"
#import "Constants.h"

@implementation WastePlotValidator

-(NSString *) validatePlot:(WastePlot *) wastePlot showDetail:(BOOL) showDetail{
    
    NSArray *wastePieces = [wastePlot.plotPiece allObjects];
    
    NSString *errorMessage = @"";
    NSString *shortErrorMessage = @"";
    NSString *shortErrorMessageHeader = [NSString stringWithFormat:@"Stratum %@ - Plot %@,", wastePlot.plotStratum.stratum, wastePlot.plotNumber ];
    
    for (WastePiece *wp in wastePieces){
        //NSLog(@"piece number %@, piece ID %@", wp.pieceNumber, [wp.piece stringValue]);
        
        //only for piece is nil, meaning new piece or edie piece
        if ([wp.piece intValue] == 0){
            
            NSString *pieceErrorMessage = @"";
            //Check required field
            NSString *required = @"";
            // species, kind, class and grade are required for all stratum assessment method
            if (wp.pieceMaterialKindCode == nil || wp.pieceScaleGradeCode == nil || wp.pieceScaleSpeciesCode == nil || wp.pieceWasteClassCode == nil ){
                required = [required stringByAppendingString:wp.pieceMaterialKindCode ? @"" : @"Kind Code, "];
                required = [required stringByAppendingString:wp.pieceScaleGradeCode ? @"" : @"Grade Code, "];
                required = [required stringByAppendingString:wp.pieceScaleSpeciesCode ? @"" : @"Species Code, "];
                required = [required stringByAppendingString:wp.pieceWasteClassCode ? @"" : @"Class Code, "];
            }
            if ((wp.pieceBorderlineCode == nil && [wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]) ){
                required = [required stringByAppendingString:@"Borderline Code, "];
            }
            if (([wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] || [wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"S"])
                      && (wp.pieceTopEndCode == nil || [wp.pieceTopEndCode.desc isEqualToString:@"None"] || [wp.topDiameter intValue] == 0 || [wp.length intValue] == 0 ||
                          (![wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"] && ([wp.buttDiameter intValue] == 0 || wp.pieceButtEndCode == nil || [wp.pieceButtEndCode.desc isEqualToString:@"None"])))){
                
                          required = [required stringByAppendingString:!wp.pieceTopEndCode || [wp.pieceTopEndCode.desc isEqualToString:@"None"]? @"Top End Code, " : @""];
                          required = [required stringByAppendingString:!wp.topDiameter || [wp.topDiameter intValue] ==0 ? @"Top, " : @""];
                          required = [required stringByAppendingString:!wp.length || [wp.length intValue] == 0 ? @"Length, " : @""];
                          required = [required stringByAppendingString:!wp.buttDiameter || [wp.buttDiameter intValue] == 0? @"Butt, " : @""];
                          required = [required stringByAppendingString:!wp.pieceButtEndCode || [wp.pieceButtEndCode.desc isEqualToString:@"None"] ? @"Butt End Code, " : @""];
            }
            
            if(![required isEqualToString:@""]){
                pieceErrorMessage = [pieceErrorMessage stringByAppendingString:[NSString stringWithFormat:@"%@ missing.\n", [required substringToIndex:[required length] - 2]]];
            }
            
            if (([wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] || [wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"S"])){
                //check for waste class U
                if ([wp.pieceWasteClassCode.wasteClassCode isEqualToString:@"U"] && (wp.pieceCommentCode == nil || [wp.pieceCommentCode.commentCode isEqualToString:@" "])){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Comment is required for Waste Class 'U'.\n"];
                }

                //check against minimum radius
                
                if([wastePlot.plotStratum.stratumBlock.regionId intValue] == CoastRegion){
                    
                    int minR = 0;
                    if([wastePlot.plotStratum.stratumBlock.userCreated intValue] == 1){
                        //eforwaste
                        if ([wastePlot.plotStratum.stratumBlock.blockMaturityCode.maturityCode isEqualToString:@"I"]){
                            minR = 5;
                        }else if([wastePlot.plotStratum.stratumBlock.blockMaturityCode.maturityCode isEqualToString:@"M"]){
                            minR = 8;
                        }
                    }else{
                        //iforwaste
                        if ([wastePlot.plotStratum.stratumBlock.blockCheckMaturityCode.maturityCode isEqualToString:@"I"]){
                            minR = 5;
                        }else if([wastePlot.plotStratum.stratumBlock.blockCheckMaturityCode.maturityCode isEqualToString:@"M"]){
                            minR = 8;
                        }
                    }
                    // top < minimum radius
                    if ([wp.topDiameter intValue] < minR ){
                        pieceErrorMessage = [pieceErrorMessage stringByAppendingString:[NSString stringWithFormat:@" Top cannot be less than %dr.\n", minR]];
                    }
                    
                    
                }else if([wastePlot.plotStratum.stratumBlock.regionId intValue]== InteriorRegion){

                    
                    /* pending for future development
                    int minR = 0;
                    
                    if ([wastePlot.plotStratum.stratumBlock.blockCheckMaturityCode.maturityCode isEqualToString:@"I"]){
                        minR = 5;
                    }else if([wastePlot.plotStratum.stratumBlock.blockCheckMaturityCode.maturityCode isEqualToString:@"M"]){
                        minR = 8;
                    }
                    // top < minimum radius
                    if ([wp.topDiameter intValue] < minR ){
                        pieceErrorMessage = [pieceErrorMessage stringByAppendingString:[NSString stringWithFormat:@" Top cannot be less than %d.\n", minR]];
                    }
                     */
                    if ([wp.topDiameter intValue] < 5 ){
                        pieceErrorMessage = [pieceErrorMessage stringByAppendingString:[NSString stringWithFormat:@" Top cannot be less than 5r.\n"]];
                    }
                }
                

                if( [wp.length intValue] <= [wp.lengthDeduction intValue]){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Deduction length >= to Piece length.\n"];
                }
                
                if( [wp.topDiameter intValue] <= [wp.topDeduction intValue]){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Top deduction >= Top dimension.\n"];
                }
                
                if((![wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"]) && [wp.buttDiameter intValue] <= [wp.buttDeduction intValue]){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Butt deduction >= Butt dimension.\n"];
                }
                
                if( ((wp.lengthDeduction && [wp.lengthDeduction intValue] > 0) || (wp.topDeduction && [wp.topDeduction intValue] > 0)|| (wp.buttDeduction && [wp.buttDeduction intValue] > 0))
                     && (!wp.pieceDecayTypeCode || [wp.pieceDecayTypeCode.decayTypeCode isEqualToString:@" "])){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Missing decay type.\n"];
                }

                if( !((wp.lengthDeduction && [wp.lengthDeduction intValue] > 0) || (wp.topDeduction && [wp.topDeduction intValue] > 0)|| (wp.buttDeduction && [wp.buttDeduction intValue] > 0))
                   && (wp.pieceDecayTypeCode && ![wp.pieceDecayTypeCode.decayTypeCode isEqualToString:@" "])){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Missing deduction information.\n"];
                }
                
                if(([wp.buttDiameter intValue] > 0 || (wp.pieceButtEndCode && ![wp.pieceButtEndCode.buttEndCode isEqualToString:@" "])) && [wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"]){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" If Kind=S (Stump) then butt fields should not be entered.\n"];
                }
                
                if(([wastePlot.plotStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"L"] || [wastePlot.plotStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"W"] || [wastePlot.plotStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"T"])
                   && (!wp.pieceButtEndCode)){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Waste class L, W, T missing butt end code."];
                }
                
                if([wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"W"] && [wp.pieceButtEndCode.buttEndCode isEqualToString:@"B"]){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Kind W, butt Code Broken not allowed."];
                }
                
                if(wp.topDeduction && [wp.topDeduction integerValue] > 0 && wp.buttDeduction && [wp.buttDeduction intValue] > 0 && wp.lengthDeduction && [wp.lengthDeduction intValue] > 0){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" more than 2 deductions.\n"];
                }
                
                if([wp.pieceVolume doubleValue] <= 0){
                    pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Net volume <= 0.\n"];
                }
                
                if((wp.topDeduction && [wp.topDeduction integerValue] > 0 )|| (wp.buttDeduction && [wp.buttDeduction intValue] > 0) ||(wp.lengthDeduction && [wp.lengthDeduction intValue] > 0)){
                    NSDecimalNumber *grossVol = [self getGrossVolume:wp];
                    NSDecimalNumber *sound = nil;
                    if( [grossVol doubleValue] > 0){
                        sound = [[wp.pieceVolume decimalNumberByDividingBy:grossVol] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
                    }else{
                        sound = [NSDecimalNumber decimalNumberWithString:@"0"];
                    }
                    if([wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"W"] && [sound floatValue] < 50.0f){
                        pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Kind 'W' < 50% sound.\n"];
                    }
                    if(wp.pieceMaterialKindCode && ([wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"L"] || [wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"T"]) && wp.pieceScaleGradeCode.scaleGradeCode && ([wp.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"1"] || [wp.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"2"]) && [sound doubleValue] < 50.0f ){
                        pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Log Grade 1,2 < 50% sound.\n"];
                    }
                }
            }
            
            //check for "If 'Material Kind' = 'L', Length must be greater than or equal to 3.0 m (30 dm) unless Borderline = 'B'"
            if ([wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] &&
                ![wp.pieceBorderlineCode.borderlineCode isEqualToString:@"B"] && [wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"L"] && [wp.length intValue] < 30){
                pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Kind 'L', length must be >= 30.\n"];
            }
            
            if ([wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] && [wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"W"] && [wp.length intValue] >= 30){
                pieceErrorMessage = [pieceErrorMessage stringByAppendingString:@" Kind 'W', length cannot be >= 30.\n"];
            }
            

            
            // ERROR
            if (![pieceErrorMessage isEqualToString:@""]){
                //[errorMessageAry addObject:[NSString stringWithFormat:@"Piece %@: %@\n", wp.pieceNumber ,errorMessage]];
                errorMessage = [errorMessage stringByAppendingString:[NSString stringWithFormat:@"Error - Piece %@: %@\n", wp.pieceNumber ,pieceErrorMessage]];
                shortErrorMessage = [shortErrorMessage stringByAppendingFormat:@"%@ Piece %@\n",shortErrorMessageHeader, wp.pieceNumber];
            }
            

            
            NSString *pieceWarning = @"";
            
            if (([wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] || [wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"S"])){
                
                //NSDecimalNumber *estLength = [wastePlot.plotStratum.stratumPlotSizeCode.plotMultipler decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithFloat:M_PI]];
                //NSLog(@"plotMultipler = %@" , wastePlot.plotStratum.stratumPlotSizeCode.plotMultipler);
                double estLength =sqrt((10000.0f/[wastePlot.plotStratum.stratumPlotSizeCode.plotMultipler doubleValue])/M_PI) * 2;
                double length_int = (double)(estLength*10);
                if(![wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"S"] && [wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"L"] && [wp.length doubleValue] > length_int){
                    pieceWarning = [pieceWarning stringByAppendingString:[NSString stringWithFormat:@" Length should not exceed plot dia. %0.2fm.\n", length_int/10.0]];
                }
                
                //DEV: we may need to address a case that top and butt are the same with a long piece
                if( ![wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"]){
                    if( [wp.topDiameter intValue] > [wp.buttDiameter intValue]){
                        pieceWarning = [pieceWarning stringByAppendingString:@" Top or Butt out of range.\n"];
                    }else{
                        if([wp.length floatValue] >= 10.0 && labs([wp.buttDiameter integerValue] - [wp.topDiameter integerValue]) >= 4){
                            if( labs([wp.topDiameter integerValue] - [wp.buttDiameter integerValue]) > ([wp.length floatValue]/10 * 1.25)){
                                pieceWarning = [pieceWarning stringByAppendingString:@" Top or Butt out of range.\n"];
                            }
                        }
                    }
                }
                if((wp.topDeduction && [wp.topDeduction integerValue] > 0 )|| (wp.buttDeduction && [wp.buttDeduction intValue] > 0) ||(wp.lengthDeduction && [wp.lengthDeduction intValue] > 0)){
                    NSDecimalNumber *grossVol = [self getGrossVolume:wp];
                    NSDecimalNumber *sound = nil;
                    if( [grossVol doubleValue] > 0){
                        sound = [[wp.pieceVolume decimalNumberByDividingBy:grossVol] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
                    }else{
                        sound = [NSDecimalNumber decimalNumberWithString:@"0"];
                    }
                    if(([wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"L"] || [wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"T"]) && [sound doubleValue] < 33.0f){
                        pieceWarning = [pieceWarning stringByAppendingString:@" Kind 'L','T' less than 33% sound.\n"];
                    }
                }
             
                //check for "If 'Material Kind' = 'S' grade cannot be 'Y'"
                //for Coast
                if ([wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"] && [wp.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Y"]){
                    pieceWarning = [pieceWarning stringByAppendingString:@" Kind 'S', Grade should not be 'Y'.\n"];
                }
                //for Interior
                if ([wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"] && [wp.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"4"]){
                    pieceWarning = [pieceWarning stringByAppendingString:@" Kind 'S', Grade should not be '4'.\n"];
                }

                if ([wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"B"]){
                    pieceWarning = [pieceWarning stringByAppendingString:@" Kind B-Breakage, Should be W-Bucking Waste?\n"];
                }
            }
            
            if (![pieceWarning isEqualToString:@""]){
                //[errorMessageAry addObject:[NSString stringWithFormat:@"Piece %@: %@\n", wp.pieceNumber ,errorMessage]];
                errorMessage = [errorMessage stringByAppendingString:[NSString stringWithFormat:@"Warning - Piece %@: %@\n", wp.pieceNumber ,pieceWarning]];
            }
            
            
        }
        
    }
    
    // Additional Error check
    if(!wastePlot.surveyorName || [wastePlot.surveyorName isEqualToString:@""]){
        errorMessage = [errorMessage stringByAppendingString:@"Error - Surveyor name missing."];
        shortErrorMessage = [shortErrorMessage stringByAppendingFormat:@"%@ Surveyor namen is missing.\n",shortErrorMessageHeader];
    }
    
    if(showDetail){
        return errorMessage;
    }else{
        return shortErrorMessage;
    }
}

-(NSString *) validateBlock:(WasteBlock *) wasteBlock{
    NSString * errorMessage = @"";

    for (WasteStratum *ws in [wasteBlock.blockStratum allObjects]){
        for (WastePlot *wp in [ws.stratumPlot allObjects]){
    
            errorMessage =[NSString stringWithFormat:@"%@%@", errorMessage, [self validatePlot:wp showDetail:NO]];
            if([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"] && [wasteBlock.userCreated intValue] == 1){
                errorMessage =[NSString stringWithFormat:@"%@%@", errorMessage, [self validateTotalPercent:wp]];
            }
        }
        if([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"] && [wasteBlock.userCreated intValue] == 1){
            errorMessage = [NSString stringWithFormat:@"%@%@", errorMessage, [self validateTotalVolume:ws]];
        }
    }
    
    return errorMessage;
}

// this validation only focus on the completeness of the cut block
-(NSString *) validateBlockForPlotPrediction:(WasteBlock *) wasteBlock{
    BOOL contain_at_least_one_piece = NO;
    NSString *error = @"";
    
    if(!wasteBlock){
        return @"Waste Block is invalid.";
    }

    if(wasteBlock.blockStratum && [wasteBlock.blockStratum count] > 0 ){
        for(WasteStratum* ws in wasteBlock.blockStratum){
            if(ws.stratumPlot && [ws.stratumPlot count] > 0){
                for(WastePlot* wp in ws.stratumPlot){
                    if( wp.plotPiece && [wp.plotPiece count]> 0){
                        contain_at_least_one_piece = YES;
                    }else{
                        if(!wp.isMeasurePlot || (wp.isMeasurePlot && [wp.isMeasurePlot integerValue] == 1)){
                            error = [error stringByAppendingString:[NSString stringWithFormat:@"Stratum %@ Plot %@ has no pieces\n", ws.stratum, wp.plotNumber]];
                        }
                    }
                }
            }else{
                error = [error stringByAppendingString:[NSString stringWithFormat:@"Stratum %@ has no pieces\n", ws.stratum]];
            }
        }
    }
    
    if(! contain_at_least_one_piece && [error isEqualToString:@""]){
        error = [error stringByAppendingString:[NSString stringWithFormat:@"Cut block has no pieces\n"]];
    }

    return error;
}

- (NSString*) validateTotalPercent:(WastePlot*)wastePlot{
    double percent = 0.0;
    for(WastePiece *wp in [wastePlot.plotPiece allObjects]){
        if(([wp.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"4"] && [wp.pieceNumber rangeOfString:@"C"].location != NSNotFound)||
           [wp.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"1"] ||
           [wp.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"2"] || wp.pieceCheckerStatusCode == nil){
            
            percent= percent + [wp.estimatedPercent doubleValue];
        }
    }
    if (percent != 100.0){
        return [NSString stringWithFormat:@"Stratum %@ -Total Estimate Percentage is not 100%%.", wastePlot.plotStratum.stratum];
    }else{
        return @"";
    }
}

- (NSString*) validateTotalVolume:(WasteStratum*)wasteStratum{
    if ([wasteStratum.totalEstimatedVolume floatValue] == 0.0){
        return [NSString stringWithFormat:@"Stratum %@ -Total Estimate Volume is 0.", wasteStratum.stratum];
    }else{
        return @"";
    }
}

-(NSDecimalNumber*)getGrossVolume:(WastePiece*)wp{
    NSLog(@"length = %f , butt = %f, top = %f", [wp.length floatValue], [wp.buttDiameter floatValue], [wp.topDiameter floatValue]);
    double gv = [wp.length doubleValue] * (([wp.buttDiameter doubleValue] * [wp.buttDiameter doubleValue]) + ([wp.topDiameter doubleValue] * [wp.topDiameter doubleValue]));
    gv = (gv * 0.0001571f)/10.0;
    return [[NSDecimalNumber alloc] initWithDouble:gv];
}

@end
