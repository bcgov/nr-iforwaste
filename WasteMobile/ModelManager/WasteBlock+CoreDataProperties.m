//
//  WasteBlock+CoreDataProperties.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "WasteBlock+CoreDataProperties.h"

@implementation WasteBlock (CoreDataProperties)

+ (NSFetchRequest<WasteBlock *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WasteBlock"];
}

@dynamic blockID;
@dynamic blockNumber;
@dynamic blockStatus;
@dynamic checkAvoidX;
@dynamic checkAvoidY;
@dynamic checkComplete;
@dynamic checkDeciduousRate;
@dynamic checkerName;
@dynamic checkHembalRate;
@dynamic checkNetVal;
@dynamic checkSppJRate;
@dynamic checkXRate;
@dynamic checkYRate;
@dynamic cruiseArea;
@dynamic cutBlockId;
@dynamic cuttingPermitId;
@dynamic deltaAvoidX;
@dynamic deltaAvoidY;
@dynamic deltaNetVal;
@dynamic entryDate;
@dynamic exempted;
@dynamic licenceNumber;
@dynamic location;
@dynamic loggingCompleteDate;
@dynamic netArea;
@dynamic notation;
@dynamic notes;
@dynamic npNFArea;
@dynamic position;
@dynamic professional;
@dynamic ratioSamplingEnabled;
@dynamic ratioSamplingLog;
@dynamic regionId;
@dynamic registrationNumber;
@dynamic reportingUnit;
@dynamic reportingUnitId;
@dynamic returnNumber;
@dynamic surveyArea;
@dynamic surveyAvoidX;
@dynamic surveyAvoidY;
@dynamic surveyDate;
@dynamic surveyDeciduousRate;
@dynamic surveyHembalRate;
@dynamic surveyNetVal;
@dynamic surveyorLicence;
@dynamic surveyorName;
@dynamic surveySppJRate;
@dynamic surveyXRate;
@dynamic surveyYRate;
@dynamic userCreated;
@dynamic wasteAssessmentAreaID;
@dynamic yearLoggedFrom;
@dynamic yearLoggedTo;
@dynamic blockCheckMaturityCode;
@dynamic blockCheckSiteCode;
@dynamic blockMaturityCode;
@dynamic blockSiteCode;
@dynamic blockSnowCode;
@dynamic blockStratum;
@dynamic blockTimbermark;
@dynamic blockCoastStat;
@dynamic blockInteriorStat;

@end
