//
//  WasteStratum+CoreDataProperties.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "WasteStratum+CoreDataProperties.h"

@implementation WasteStratum (CoreDataProperties)

+ (NSFetchRequest<WasteStratum *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WasteStratum"];
}

@dynamic checkAvoidX;
@dynamic checkAvoidY;
@dynamic checkNetVal;
@dynamic checkTotalEstimatedVolume;
@dynamic deltaAvoidX;
@dynamic deltaAvoidY;
@dynamic deltaNetVal;
@dynamic isSurvey;
@dynamic measurePlot;
@dynamic n1sample;
@dynamic n2sample;
@dynamic notes;
@dynamic orgMeasurePlot;
@dynamic orgPredictionPlot;
@dynamic predictionPlot;
@dynamic ratioSamplingLog;
@dynamic stratum;
@dynamic stratumArea;
@dynamic stratumID;
@dynamic stratumSurveyArea;
@dynamic surveyAvoidX;
@dynamic surveyAvoidY;
@dynamic surveyNetVal;
@dynamic totalEstimatedVolume;
@dynamic stratumAssessmentMethodCode;
@dynamic stratumBlock;
@dynamic stratumHarvestMethodCode;
@dynamic stratumPlot;
@dynamic stratumPlotSizeCode;
@dynamic stratumStratumTypeCode;
@dynamic stratumWasteLevelCode;
@dynamic stratumWasteTypeCode;
@dynamic stratumCoastStat;
@dynamic stratumInteriorStat;
@dynamic isPileStratum;
@dynamic stratumAgg;
@dynamic grade12Percent;
@dynamic grade4Percent;
@dynamic grade5Percent;
@dynamic gradeJPercent;
@dynamic gradeUPercent;
@dynamic gradeYPercent;
@dynamic gradeXPercent;
@dynamic gradeWPercent;
@dynamic measureSample;
@dynamic totalNumPile;
@dynamic strPile;

@end
