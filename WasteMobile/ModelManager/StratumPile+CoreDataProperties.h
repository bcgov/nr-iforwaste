//
//  StratumPile+CoreDataProperties.h
//  WasteMobile
//
//  Created by Sweta Kutty on 2020-03-06.
//  Copyright © 2020 Salus Systems. All rights reserved.
//
//

#import "StratumPile+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface StratumPile (CoreDataProperties)

+ (NSFetchRequest<StratumPile *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *surveyorName;
@property (nullable, nonatomic, copy) NSDate *surveyDate;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSString *stratumPileId;
@property (nullable, nonatomic, retain) WasteStratum *strPile;
@property (nullable, nonatomic, retain) NSSet<WastePile *> *pileData;
@property (nullable, nonatomic, retain) AggregateCutblock *aggPile;
@property (nullable, nonatomic, retain) EFWCoastStat *pileCoastStat;
@property (nullable, nonatomic, retain) EFWInteriorStat *pileInteriorStat;

@end

@interface StratumPile (CoreDataGeneratedAccessors)

- (void)addPileDataObject:(WastePile *)value;
- (void)removePileDataObject:(WastePile *)value;
- (void)addPileData:(NSSet<WastePile *> *)values;
- (void)removePileData:(NSSet<WastePile *> *)values;

@end

NS_ASSUME_NONNULL_END
