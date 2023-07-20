//
//  WasteBlockDTO.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-07.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WasteBlockDTO : NSObject

@property NSString *blockNumber;
@property NSString *blockStatus;
@property NSDecimalNumber *cruiseArea;
@property NSString *cutBlockId;
@property NSString *cuttingPermitId;
@property NSString *exempted;
@property NSString *licenceNumber;
@property NSString *location;
@property NSDate *loggingCompleteDate;
@property NSDecimalNumber *netArea;
@property NSDecimalNumber *npNFArea;
@property NSNumber *reportingUnit;
@property NSNumber *reportingUnitId;
@property NSNumber *returnNumber;
@property NSDate *surveyDate;
@property NSString *surveyorLicence;
@property NSNumber *yearLoggedFrom;
@property NSNumber *yearLoggedTo;

@property NSString *maturityCode;
@property NSString *siteCode;
@property NSString *snowCode;

@property NSNumber *wasteAssessmentAreaID;

@end
