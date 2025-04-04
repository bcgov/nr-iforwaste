//
//  WasteCalculator.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-15.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WastePiece;
@class WasteBlock;
@class Timbermark;
@class WasteStratum;
@class EFWCoastStat;
@class EFWInteriorStat;

@interface WasteCalculator : NSObject

//shared functions
+(void) calculatePieceStat:(WastePiece *)wastePiece wasteStratum:(WasteStratum *)ws;
+(void) calculateRate:(WasteBlock *) wasteBlock;
+(void) calculateWMRF:(WasteBlock *) wasteBlock updateOriginal:(BOOL) updateOriginal;
+(void) calculatePiecesValue:(WasteBlock *) wasteBlock;
+ (double) getValueFromPieceDictionary:(NSDictionary *)pieceDictionary timbermark:(Timbermark *)tm useOriginalRate:(BOOL) useOrginalRate;
+(void) calculateEFWStat:(WasteBlock *) wasteBlock;

+(void) resetEFWCoastStat:(EFWCoastStat *) stat;
+(void) resetEFWInteriorStat:(EFWInteriorStat *) stat;
+(float)pieceRate:(NSString*)species withGrade:(NSString*)grade withAvoid:(BOOL)avoid forBlock:(WasteBlock*)wasteBlock withTimbermark:(Timbermark*)timbermark;
+(NSString *) convertDecimalNumberToString:(NSDecimalNumber *) decimalNo;
@end
