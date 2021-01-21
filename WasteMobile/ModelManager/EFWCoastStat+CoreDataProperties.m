//
//  EFWCoastStat+CoreDataProperties.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "EFWCoastStat+CoreDataProperties.h"

@implementation EFWCoastStat (CoreDataProperties)

+ (NSFetchRequest<EFWCoastStat *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"EFWCoastStat"];
}

@dynamic gradeJValue;
@dynamic gradeJValueHa;
@dynamic gradeJVolume;
@dynamic gradeJVolumeHa;
@dynamic gradeUHBValue;
@dynamic gradeUHBValueHa;
@dynamic gradeUHBVolume;
@dynamic gradeUHBVolumeHa;
@dynamic gradeUValue;
@dynamic gradeUValueHa;
@dynamic gradeUVolume;
@dynamic gradeUVolumeHa;
@dynamic gradeXHBValue;
@dynamic gradeXHBValueHa;
@dynamic gradeXHBVolume;
@dynamic gradeXHBVolumeHa;
@dynamic gradeYValue;
@dynamic gradeYValueHa;
@dynamic gradeYVolume;
@dynamic gradeYVolumeHa;
@dynamic totalBillValue;
@dynamic totalBillValueHa;
@dynamic totalBillVolume;
@dynamic totalBillVolumeHa;
@dynamic totalControlValue;
@dynamic totalControlValueHa;
@dynamic totalControlVolume;
@dynamic totalControlVolumeHa;

@end
