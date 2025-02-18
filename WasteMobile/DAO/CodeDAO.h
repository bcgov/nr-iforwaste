//
//  CodeDAO.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-17.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BorderlineCode;
@class ButtEndCode;
@class CommentCode;
@class DecayTypeCode;
@class ScaleSpeciesCode;
@class ScaleGradeCode;
@class TopEndCode;
@class CheckerStatusCode;
@class WasteClassCode;
@class MaterialKindCode;
@class WasteLevelCode;
@class ShapeCode;
@class StratumTypeCode;
@class HarvestMethodCode;
@class PlotSizeCode;
@class ConditionCode;
@class DesignationTypeCode;
@class SnowCode;
@class MaturityCode;
@class MaterialKindCode;
@class ReasonCode;
@class RoleTypeCode;
@class PileShapeCode;
@class MeasuredPileShapeCode;

@interface CodeDAO : NSObject {
    //@private NSManagedObjectContext *context;
}

+ (CodeDAO *)sharedInstance;

-(void)initCodeTable:(NSError **)error;
-(void)refreshCodeTable;

-(NSArray *) getBorderLineCodeList;
-(NSArray *) getButtEndCodeList;
-(NSArray *) getCommentCodeList;
-(NSArray *) getDecayTypeCodeList;
-(NSArray *) getScaleSpeciesCodeList;
-(NSArray *) getSnowCodeList;
-(NSArray *) getSurveyReasonCodeList;
-(NSArray *) getPlotSizeCodeList;
-(NSArray *) getShapeCodeList;
-(NSArray *) getStratumTypeCodeList;
-(NSArray *) getHarvestMethodCodeList;
-(NSArray *) getWasteLevelCodeList;
-(NSArray *) getWasteTypeCodeList;
-(NSArray *) getMaturityCodeList;
-(NSArray *) getMonetaryReductionFactorCodeList;
-(NSArray *) getMaterialKindCodeList;
-(NSArray *) getWasteClassCodeList;
-(NSArray *) getTopEndCodeList;
-(NSArray *) getScaleGradeCodeList:(int)regionId;
-(NSArray *) getAssessmentMethodCodeList;
-(NSArray *) getSiteCodeList;
-(NSArray *) getInteriorCedarMaturityList;
-(NSArray *) getPileShapeCodeList;
-(NSArray *) getMeasuredPileShapeCodeList;

-(NSManagedObject *) getCodeByNameCode:(NSString *)codeName code:(NSString *)code;

/*
-(BorderlineCode *) getBorderLineCode:(NSString *)code;
-(ButtEndCode *) getButtEndCode:(NSString *)code;
-(CommentCode *) getCommentCode:(NSString *)code;
-(DecayTypeCode *) getDecayTypeCode:(NSString *)code;
*/
@end
