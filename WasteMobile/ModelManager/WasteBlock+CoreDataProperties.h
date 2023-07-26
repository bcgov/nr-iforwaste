//
//  WasteBlock+CoreDataProperties.h
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "WasteBlock.h"


NS_ASSUME_NONNULL_BEGIN

@interface WasteBlock (CoreDataProperties)

+ (NSFetchRequest<WasteBlock *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *isAggregate;

@property (nullable, nonatomic, copy) NSNumber *blockID;
@property (nullable, nonatomic, copy) NSString *blockNumber;
@property (nullable, nonatomic, copy) NSString *blockStatus;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkAvoidX;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkAvoidY;
@property (nullable, nonatomic, copy) NSNumber *checkComplete;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkDeciduousRate;
@property (nullable, nonatomic, copy) NSString *checkerName;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkHembalRate;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkNetVal;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkSppJRate;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkXRate;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkYRate;
@property (nullable, nonatomic, copy) NSDecimalNumber *cruiseArea;
@property (nullable, nonatomic, copy) NSString *cutBlockId;
@property (nullable, nonatomic, copy) NSString *cuttingPermitId;
@property (nullable, nonatomic, copy) NSDecimalNumber *deltaAvoidX;
@property (nullable, nonatomic, copy) NSDecimalNumber *deltaAvoidY;
@property (nullable, nonatomic, copy) NSDecimalNumber *deltaNetVal;
@property (nullable, nonatomic, copy) NSDate *entryDate;
@property (nullable, nonatomic, copy) NSString *exempted;
@property (nullable, nonatomic, copy) NSString *licenceNumber;
@property (nullable, nonatomic, copy) NSString *location;
@property (nullable, nonatomic, copy) NSDate *loggingCompleteDate;
@property (nullable, nonatomic, copy) NSDecimalNumber *netArea;
@property (nullable, nonatomic, copy) NSString *notation;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSString *usercode;        
@property (nullable, nonatomic, copy) NSDecimalNumber *npNFArea;
@property (nullable, nonatomic, copy) NSString *position;
@property (nullable, nonatomic, copy) NSString *professional;
@property (nullable, nonatomic, copy) NSNumber *ratioSamplingEnabled;
@property (nullable, nonatomic, copy) NSString *ratioSamplingLog;
@property (nullable, nonatomic, copy) NSNumber *regionId;
@property (nullable, nonatomic, copy) NSString *registrationNumber;
@property (nullable, nonatomic, copy) NSNumber *reportingUnit;
@property (nullable, nonatomic, copy) NSNumber *reportingUnitId;
@property (nullable, nonatomic, copy) NSNumber *returnNumber;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyArea;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyAvoidX;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyAvoidY;
@property (nullable, nonatomic, copy) NSDate *surveyDate;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyDeciduousRate;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyHembalRate;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyNetVal;
@property (nullable, nonatomic, copy) NSString *surveyorLicence;
@property (nullable, nonatomic, copy) NSString *surveyorName;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveySppJRate;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyXRate;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyYRate;
@property (nullable, nonatomic, copy) NSNumber *userCreated;
@property (nullable, nonatomic, copy) NSNumber *wasteAssessmentAreaID;
@property (nullable, nonatomic, copy) NSNumber *yearLoggedFrom;
@property (nullable, nonatomic, copy) NSNumber *yearLoggedTo;
@property (nullable, nonatomic, retain) MaturityCode *blockCheckMaturityCode;
@property (nullable, nonatomic, retain) SiteCode *blockCheckSiteCode;
@property (nullable, nonatomic, retain) MaturityCode *blockMaturityCode;
@property (nullable, nonatomic, retain) SiteCode *blockSiteCode;
@property (nullable, nonatomic, retain) SnowCode *blockSnowCode;
@property (nullable, nonatomic, retain) NSSet<WasteStratum *> *blockStratum;
@property (nullable, nonatomic, retain) NSSet<Timbermark *> *blockTimbermark;
@property (nullable, nonatomic, retain) EFWCoastStat *blockCoastStat;
@property (nullable, nonatomic, retain) EFWInteriorStat *blockInteriorStat;
@property (nullable, nonatomic, retain) InteriorCedarMaturityCode *blockInteriorCedarMaturityCode;

@end

@interface WasteBlock (CoreDataGeneratedAccessors)

- (void)addBlockStratumObject:(WasteStratum *)value;
- (void)removeBlockStratumObject:(WasteStratum *)value;
- (void)addBlockStratum:(NSSet<WasteStratum *> *)values;
- (void)removeBlockStratum:(NSSet<WasteStratum *> *)values;

- (void)addBlockTimbermarkObject:(Timbermark *)value;
- (void)removeBlockTimbermarkObject:(Timbermark *)value;
- (void)addBlockTimbermark:(NSSet<Timbermark *> *)values;
- (void)removeBlockTimbermark:(NSSet<Timbermark *> *)values;

@end

NS_ASSUME_NONNULL_END
