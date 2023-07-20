//
//  PlotSampleGenerator.h
//  WasteMobile
//
//  Created by Jack Wong on 2017-03-16.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import <stdlib.h>
#import <Foundation/Foundation.h>

@class WasteStratum;

@interface PlotSampleGenerator : NSObject

+(void)generatePlotSample2:(WasteStratum*) ws;
+(void)TestingRandomess:(int)sampleSize predictionPlot:(int)predictionPlot measurePlot:(int)measurePlot;

@end
