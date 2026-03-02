//
//  WastePile+CoreDataProperties.m
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-06.
//  Copyright © 2019 Salus Systems. All rights reserved.
//
//

#import "WastePile+CoreDataProperties.h"

@implementation WastePile (CoreDataProperties)

+ (NSFetchRequest<WastePile *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"WastePile"];
}

@dynamic pileId;
@dynamic pileNumber;
@dynamic surveyorName;
@dynamic assistant;
@dynamic block;
@dynamic licence;
@dynamic surveyorLicence;
@dynamic surveyDate;
@dynamic cuttingPermit;
@dynamic returnNumber;
@dynamic notes;
@dynamic weather;
@dynamic length;
@dynamic width;
@dynamic height;
@dynamic pileArea;
@dynamic pileVolume;
@dynamic measuredLength;
@dynamic measuredWidth;
@dynamic measuredHeight;
@dynamic measuredPileArea;
@dynamic measuredPileVolume;

@dynamic comment;
@dynamic isSample;
@dynamic pilePileShapeCode;
@dynamic pileMeasuredPileShapeCode;
@dynamic pileStratum;

//Data change variables
@dynamic dcSurveyorName;
@dynamic dcDesignation;
@dynamic dcLicenseNumber;
@dynamic dcSignature;
@dynamic dcRationale;
//fields added for IFW-145 and IFW-146
@dynamic checkDate;
@dynamic pileCheckerStatusCode;
@dynamic isChanged;
@dynamic checkmLength;
@dynamic checkmWidth;
@dynamic checkmHeight;
@dynamic checkmPileArea;
@dynamic checkmPileVolume;
@dynamic pilecheckmPileShapecode;
@dynamic pileCheckPileShapeCode;
@end
