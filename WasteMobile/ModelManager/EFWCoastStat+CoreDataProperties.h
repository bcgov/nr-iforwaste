//
//  EFWCoastStat+CoreDataProperties.h
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "EFWCoastStat+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EFWCoastStat (CoreDataProperties)

+ (NSFetchRequest<EFWCoastStat *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDecimalNumber *gradeJValue;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeJValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeJVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeJVolumeHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeUHBValue;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeUHBValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeUHBVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeUHBVolumeHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeUValue;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeUValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeUVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeUVolumeHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeXHBValue;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeXHBValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeXHBVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeXHBVolumeHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeYValue;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeYValueHa;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeYVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *gradeYVolumeHa;
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
