//
//  WastePlot+CoreDataProperties.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "WastePlot+CoreDataProperties.h"

@implementation WastePlot (CoreDataProperties)

+ (NSFetchRequest<WastePlot *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WastePlot"];
}

@dynamic aggregateLicence;
@dynamic aggregateCutblock;
@dynamic aggregateCuttingPermit;
@dynamic assistant;
@dynamic baseline;
@dynamic certificateNumber;
@dynamic checkAvoidX;
@dynamic checkAvoidY;
@dynamic checkDate;
@dynamic checkerMeasurePercent;
@dynamic checkNetVal;
@dynamic deltaAvoidX;
@dynamic deltaAvoidY;
@dynamic deltaNetVal;
@dynamic dryVolume;
@dynamic greenVolume;
@dynamic isMeasurePlot;
@dynamic isSurvey;
@dynamic notes;
@dynamic plotID;
@dynamic plotNumber;
@dynamic returnNumber;
@dynamic strip;
@dynamic surveyAvoidX;
@dynamic surveyAvoidY;
@dynamic surveyDate;
@dynamic surveyedMeasurePercent;
@dynamic surveyNetVal;
@dynamic surveyorName;
@dynamic weather;
@dynamic plotPiece;
@dynamic plotShapeCode;
@dynamic plotSizeCode;
@dynamic plotStratum;
@dynamic plotCoastStat;
@dynamic plotInteriorStat;
@dynamic sawlogPercent;
@dynamic greenGradePercent;
@dynamic dryGradePercent;
@dynamic plotEstimatedVolume;

@end
