//
//  PileShapeCode+CoreDataProperties.h
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-06.
//  Copyright © 2019 Salus Systems. All rights reserved.
//
//

#import "PileShapeCode+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PileShapeCode (CoreDataProperties)

+ (NSFetchRequest<PileShapeCode *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *pileShapeCode;
@property (nullable, nonatomic, copy) NSString *desc;
@property (nullable, nonatomic, copy) NSDate *effectiveDate;
@property (nullable, nonatomic, copy) NSDate *expiryDate;
@property (nullable, nonatomic, copy) NSDate *updateTimestamp;
@property (nullable, nonatomic, retain) NSSet<WastePile *> *pileShapeCodePile;

@end

@interface PileShapeCode (CoreDataGeneratedAccessors)

- (void)addPileShapeCodePileObject:(WastePile *)value;
- (void)removePileShapeCodePileObject:(WastePile *)value;
- (void)addPileShapeCodePile:(NSSet<WastePile *> *)values;
- (void)removePileShapeCodePile:(NSSet<WastePile *> *)values;

@end

NS_ASSUME_NONNULL_END
