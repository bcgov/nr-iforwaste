//
//  WastePlot+CoreDataProperties.h
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "WastePlot.h"


NS_ASSUME_NONNULL_BEGIN

@interface WastePlot (CoreDataProperties)

+ (NSFetchRequest<WastePlot *> *)fetchRequest;


@property (nullable, nonatomic, copy) NSString *aggregateLicence;
@property (nullable, nonatomic, copy) NSString *aggregateCutblock;
@property (nullable, nonatomic, copy) NSString *aggregateCuttingPermit;
@property (nullable, nonatomic, copy) NSString *assistant;
@property (nullable, nonatomic, copy) NSString *baseline;
@property (nullable, nonatomic, copy) NSString *certificateNumber;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkAvoidX;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkAvoidY;
@property (nullable, nonatomic, copy) NSDate *checkDate;
@property (nullable, nonatomic, copy) NSNumber *checkerMeasurePercent;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkNetVal;
@property (nullable, nonatomic, copy) NSDecimalNumber *deltaAvoidX;
@property (nullable, nonatomic, copy) NSDecimalNumber *deltaAvoidY;
@property (nullable, nonatomic, copy) NSDecimalNumber *deltaNetVal;
@property (nullable, nonatomic, copy) NSDecimalNumber *dryVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *greenVolume;
@property (nullable, nonatomic, copy) NSNumber *isMeasurePlot;
@property (nullable, nonatomic, copy) NSNumber *isSurvey;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSNumber *plotID;
@property (nullable, nonatomic, copy) NSNumber *plotNumber;
@property (nullable, nonatomic, copy) NSString *returnNumber;
@property (nullable, nonatomic, copy) NSNumber *strip;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyAvoidX;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyAvoidY;
@property (nullable, nonatomic, copy) NSDate *surveyDate;
@property (nullable, nonatomic, copy) NSNumber *surveyedMeasurePercent;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyNetVal;
@property (nullable, nonatomic, copy) NSString *surveyorName;
@property (nullable, nonatomic, copy) NSString *weather;
@property (nullable, nonatomic, copy) NSNumber *plotEstimatedVolume;
@property (nullable, nonatomic, retain) NSSet<WastePiece *> *plotPiece;
@property (nullable, nonatomic, retain) ShapeCode *plotShapeCode;
@property (nullable, nonatomic, retain) PlotSizeCode *plotSizeCode;
@property (nullable, nonatomic, retain) WasteStratum *plotStratum;
@property (nullable, nonatomic, retain) EFWCoastStat *plotCoastStat;
@property (nullable, nonatomic, retain) EFWInteriorStat *plotInteriorStat;
@property (nullable, nonatomic, retain) NSDecimalNumber *sawlogPercent;
@property (nullable, nonatomic, retain) NSDecimalNumber *greenGradePercent;
@property (nullable, nonatomic, retain) NSDecimalNumber *dryGradePercent;

@end

@interface WastePlot (CoreDataGeneratedAccessors)

- (void)addPlotPieceObject:(WastePiece *)value;
- (void)removePlotPieceObject:(WastePiece *)value;
- (void)addPlotPiece:(NSSet<WastePiece *> *)values;
- (void)removePlotPiece:(NSSet<WastePiece *> *)values;

@end

NS_ASSUME_NONNULL_END
