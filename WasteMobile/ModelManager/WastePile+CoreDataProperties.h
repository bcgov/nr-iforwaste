//
//  WastePile+CoreDataProperties.h
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-06.
//  Copyright © 2019 Salus Systems. All rights reserved.
//
//

#import "WastePile+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WastePile (CoreDataProperties)

+ (NSFetchRequest<WastePile *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *pileId;
@property (nullable, nonatomic, copy) NSNumber *pileNumber;
@property (nullable, nonatomic, copy) NSDecimalNumber *length;
@property (nullable, nonatomic, copy) NSDecimalNumber *width;
@property (nullable, nonatomic, copy) NSDecimalNumber *height;
@property (nullable, nonatomic, copy) NSDecimalNumber *pileArea;
@property (nullable, nonatomic, copy) NSDecimalNumber *pileVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredLength;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredWidth;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredHeight;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredPileArea;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredPileVolume;
@property (nullable, nonatomic, copy) NSString *comment;
@property (nullable, nonatomic, copy) NSNumber *isSample;
@property (nullable, nonatomic, retain) PileShapeCode *pilePileShapeCode;
@property (nullable, nonatomic, retain) MeasuredPileShapeCode *pileMeasuredPileShapeCode;
@property (nullable, nonatomic, retain) WasteStratum *pileStratum;
@property (nullable, nonatomic, copy) NSString *surveyorName;
@property (nullable, nonatomic, copy) NSString *assistant;
@property (nullable, nonatomic, copy) NSString *weather;
@property (nullable, nonatomic, copy) NSString *returnNumber;
@property (nullable, nonatomic, copy) NSString *surveyorLicence;
@property (nullable, nonatomic, copy) NSString *licence;
@property (nullable, nonatomic, copy) NSString *cuttingPermit;
@property (nullable, nonatomic, copy) NSString *block;
@property (nullable, nonatomic, copy) NSDate *surveyDate;
@property (nullable, nonatomic, copy) NSString *notes;

//Data change variables
@property (nullable, nonatomic, copy) NSString *dcSurveyorName;
@property (nullable, nonatomic, copy) NSString *dcDesignation;
@property (nullable, nonatomic, copy) NSString *dcLicenseNumber;
@property (nullable, nonatomic, copy) UIImage *dcSignature;
@property (nullable, nonatomic, copy) NSString *dcRationale;

@end

NS_ASSUME_NONNULL_END
