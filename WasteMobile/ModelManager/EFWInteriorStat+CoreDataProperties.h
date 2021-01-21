//
//  EFWInteriorStat+CoreDataProperties.h
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "EFWInteriorStat+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EFWInteriorStat (CoreDataProperties)

+ (NSFetchRequest<EFWInteriorStat *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDecimalNumber *grade124Value;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade124ValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade124Volume;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade124VolumeHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade12Value;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade12ValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade12Volume;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade12VolumeHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade4Value;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade4ValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade4Volume;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade4VolumeHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade5Value;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade5ValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade5Volume;
@property (nullable, nonatomic, copy) NSDecimalNumber *grade5VolumeHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *totalBillValue;
@property (nullable, nonatomic, copy) NSDecimalNumber *totalBillValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *totalBillVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *totalBillVolumeHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *totalControlValue;
@property (nullable, nonatomic, copy) NSDecimalNumber *totalControlValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *totalControlVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *totalControlVolumeHa;

@end

NS_ASSUME_NONNULL_END
