//
//  AggregateCutblock+CoreDataProperties.h
//  WasteMobile
//
//  Created by Sweta Kutty on 2020-03-09.
//  Copyright © 2020 Salus Systems. All rights reserved.
//
//

#import "AggregateCutblock+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AggregateCutblock (CoreDataProperties)

+ (NSFetchRequest<AggregateCutblock *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *aggregateCutblock;
@property (nullable, nonatomic, copy) NSString *aggregateCuttingPermit;
@property (nullable, nonatomic, copy) NSString *aggregateLicense;
@property (nullable, nonatomic, copy) NSString *n1sample;
@property (nullable, nonatomic, copy) NSString *n2sample;
@property (nullable, nonatomic, copy) NSNumber *totalNumPile;
@property (nullable, nonatomic, copy) NSNumber *measureSample;
@property (nullable, nonatomic, copy) NSNumber *aggregateID;
@property (nullable, nonatomic, retain) WasteStratum *stratumAgg;
@property (nullable, nonatomic, retain) StratumPile *aggPile;

@end

NS_ASSUME_NONNULL_END
