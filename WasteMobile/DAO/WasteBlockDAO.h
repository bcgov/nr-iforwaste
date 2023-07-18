//
//  WasteBlockDAO.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-09.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WasteBlock, Timbermark, WasteStratum, WastePlot, WastePiece, EFWCoastStat, EFWInteriorStat;

typedef enum MergeOutcomeCode{
    MergeSuccessful,
    MergeFailDataMismatch,
    MergeFailLoadXML,
    MergeFailCutBlockNotFound
}MergeOutcomeCode;

@interface WasteBlockDAO : NSObject

+(WasteBlock *) getWasteBlockByCutBlockId:(NSString *) cutBlockId reportingUnitId:(NSString *)reportUnitId;
+(WasteBlock *) getWasteBlockByAssessmentAreaId:(NSString *) assessmentAreaId;
+(WasteBlock *) getWasteBlockByRU:(NSString *) ru cutBlockId:(NSString *)cutBlockId license:(NSString*)license cutPermit:(NSString*)cutPermit;
+(WasteBlock *) getWasteBlockByRUButWAID:(NSString *) ru cutBlockId:(NSString *)cutBlockId license:(NSString*)license cutPermit:(NSString*)cutPermit wasteAsseID:(NSString *)wasteAsseID;
+(WasteBlock *) createEmptyCutBlock:(int) regionId ratioSample:(BOOL)ratioSample;
+(Timbermark *) createEmptyTimbermark;
+(WasteStratum *) createEmptyStratum;
+(WastePlot *) createEmptyPlot;
+(WastePiece *) createEmptyPiece;

+(EFWCoastStat *) createEFWCoastStat;
+(EFWInteriorStat *) createEFWInteriorStat;

+(void) deleteCutBlock:(WasteBlock *) targetWasteBlock;
+(void) deleteStratum:(WasteStratum *) targetWasteStratum usingWB:(WasteBlock *) targetWasteBlock;

+(MergeOutcomeCode) mergeWasteBlock:(WasteBlock*)primary_wb WasteBlock:(WasteBlock*)secondary_wb;
+(NSNumber *) GetNextAssessmentAreaId;
+(BOOL) checkDuplicateWasteBlockByRU:(NSString *) ru cutBlockId:(NSString *)cutBlockId license:(NSString*)license cutPermit:(NSString*)cutPermit assessmentAreaId:(NSNumber *)assessmentAreaId;
@end
