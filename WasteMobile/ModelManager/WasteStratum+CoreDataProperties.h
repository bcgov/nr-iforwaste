//
//  WasteStratum+CoreDataProperties.h
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "WasteStratum.h"


NS_ASSUME_NONNULL_BEGIN

@interface WasteStratum (CoreDataProperties)

+ (NSFetchRequest<WasteStratum *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDecimalNumber *checkAvoidX;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkAvoidY;
@property (nullable, nonatomic, copy) NSDecimalNumber *checkNetVal;
@property (nullable, nonatomic, copy) NSNumber *checkTotalEstimatedVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *deltaAvoidX;
@property (nullable, nonatomic, copy) NSDecimalNumber *deltaAvoidY;
@property (nullable, nonatomic, copy) NSDecimalNumber *deltaNetVal;
@property (nullable, nonatomic, copy) NSNumber *isSurvey;
@property (nullable, nonatomic, copy) NSNumber *measurePlot;
@property (nullable, nonatomic, copy) NSString *n1sample;
@property (nullable, nonatomic, copy) NSString *n2sample;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSNumber *orgMeasurePlot;
@property (nullable, nonatomic, copy) NSNumber *orgPredictionPlot;
@property (nullable, nonatomic, copy) NSNumber *predictionPlot;
@property (nullable, nonatomic, copy) NSString *ratioSamplingLog;
@property (nullable, nonatomic, copy) NSString *stratum;
@property (nullable, nonatomic, copy) NSDecimalNumber *stratumArea;
@property (nullable, nonatomic, copy) NSNumber *stratumID;
@property (nullable, nonatomic, copy) NSDecimalNumber *stratumSurveyArea;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyAvoidX;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyAvoidY;
@property (nullable, nonatomic, copy) NSDecimalNumber *surveyNetVal;
@property (nullable, nonatomic, copy) NSNumber *totalEstimatedVolume;
@property (nullable, nonatomic, retain) AssessmentMethodCode *stratumAssessmentMethodCode;
@property (nullable, nonatomic, retain) WasteBlock *stratumBlock;
@property (nullable, nonatomic, retain) HarvestMethodCode *stratumHarvestMethodCode;
@property (nullable, nonatomic, retain) NSSet<WastePlot *> *stratumPlot;
@property (nullable, nonatomic, retain) PlotSizeCode *stratumPlotSizeCode;
@property (nullable, nonatomic, retain) StratumTypeCode *stratumStratumTypeCode;
@property (nullable, nonatomic, retain) WasteLevelCode *stratumWasteLevelCode;
@property (nullable, nonatomic, retain) WasteTypeCode *stratumWasteTypeCode;
@property (nullable, nonatomic, retain) EFWCoastStat *stratumCoastStat;
@property (nullable, nonatomic, retain) EFWInteriorStat *stratumInteriorStat;

@end

@interface WasteStratum (CoreDataGeneratedAccessors)

- (void)addStratumPlotObject:(WastePlot *)value;
- (void)removeStratumPlotObject:(WastePlot *)value;
- (void)addStratumPlot:(NSSet<WastePlot *> *)values;
- (void)removeStratumPlot:(NSSet<WastePlot *> *)values;

@end

NS_ASSUME_NONNULL_END
