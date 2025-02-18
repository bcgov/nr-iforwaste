//
//  MeasuredPileShapeCode+CoreDataClass.h
//  WasteMobile
//
//  Created by Michael Tennant on 2023-10-31.
//  Copyright (c) 2023 Salus Systems. All rights reserved.
//

#import "MeasuredPileShapeCode+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MeasuredPileShapeCode (CoreDataProperties)

+ (NSFetchRequest<MeasuredPileShapeCode *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *measuredPileShapeCode;
@property (nullable, nonatomic, copy) NSString *desc;
@property (nullable, nonatomic, copy) NSDate *effectiveDate;
@property (nullable, nonatomic, copy) NSDate *expiryDate;
@property (nullable, nonatomic, copy) NSDate *updateTimestamp;
@property (nullable, nonatomic, retain) NSSet<WastePile *> *measuredPileShapeCodePile;

@end

@interface MeasuredPileShapeCode (CoreDataGeneratedAccessors)

- (void)addMeasuredPileShapeCodePileObject:(WastePile *)value;
- (void)removeMeasuredPileShapeCodePileObject:(WastePile *)value;
- (void)addMeasuredPileShapeCodePile:(NSSet<WastePile *> *)values;
- (void)removeMeasuredPileShapeCodePile:(NSSet<WastePile *> *)values;

@end

NS_ASSUME_NONNULL_END
