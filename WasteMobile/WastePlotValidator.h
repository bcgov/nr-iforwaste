//
//  WastePlotValidator.h
//  WasteMobile
//
//  Created by Jack Wong on 2015-05-24.
//  Copyright (c) 2015 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WastePlot;
@class WasteBlock;
@class WasteStratum;

@interface WastePlotValidator : NSObject

-(NSString *) validatePlot:(WastePlot *) wastePlot showDetail:(BOOL) showDetail;

-(NSString *) validateBlock:(WasteBlock *) wasteBlock checkPlot:(BOOL) checkPlot;

-(NSString *) validateBlockForPlotPrediction:(WasteBlock *) wasteBlock;

-(NSString *) validateStratum:(WasteStratum *) wasteStratum;

-(NSString *) validatePile:(NSArray *)wastePile wasteBlock:(WasteBlock *) wasteBlock wasteStratum:(WasteStratum *)wasteStratum;
-(NSString *) validPile:(WasteBlock *) wasteBlock;
-(NSString *) validatemultipleStratum:(NSString *)wastestr wastestratum:(NSSet *)wasteStratum;

@end
