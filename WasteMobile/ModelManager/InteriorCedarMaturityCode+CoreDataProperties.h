//
//  InteriorCedarMaturityCode+CoreDataProperties.h
//  iForWaste
//
//  Created by Sweta Kutty on 2019-02-08.
//  Copyright © 2019 Salus Systems. All rights reserved.
//
//

#import "InteriorCedarMaturityCode+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface InteriorCedarMaturityCode (CoreDataProperties)

+ (NSFetchRequest<InteriorCedarMaturityCode *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *desc;
@property (nullable, nonatomic, copy) NSDate *effectiveDate;
@property (nullable, nonatomic, copy) NSDate *expiryDate;
@property (nullable, nonatomic, copy) NSString *interiorCedarCode;
@property (nullable, nonatomic, copy) NSDate *updateTimestamp;
@property (nullable, nonatomic, retain) NSSet<WasteBlock *> *interiorCedarMaturityCodeBlock;

@end

@interface InteriorCedarMaturityCode (CoreDataGeneratedAccessors)

- (void)addInteriorCedarMaturityCodeBlockObject:(WasteBlock *)value;
- (void)removeInteriorCedarMaturityCodeBlockObject:(WasteBlock *)value;
- (void)addInteriorCedarMaturityCodeBlock:(NSSet<WasteBlock *> *)values;
- (void)removeInteriorCedarMaturityCodeBlock:(NSSet<WasteBlock *> *)values;

@end

NS_ASSUME_NONNULL_END
