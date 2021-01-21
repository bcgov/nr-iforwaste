//
//  EFWInteriorStat+CoreDataProperties.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-06-28.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "EFWInteriorStat+CoreDataProperties.h"

@implementation EFWInteriorStat (CoreDataProperties)

+ (NSFetchRequest<EFWInteriorStat *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"EFWInteriorStat"];
}

@dynamic grade124Value;
@dynamic grade124ValueHa;
@dynamic grade124Volume;
@dynamic grade124VolumeHa;
@dynamic grade12Value;
@dynamic grade12ValueHa;
@dynamic grade12Volume;
@dynamic grade12VolumeHa;
@dynamic grade4Value;
@dynamic grade4ValueHa;
@dynamic grade4Volume;
@dynamic grade4VolumeHa;
@dynamic grade5Value;
@dynamic grade5ValueHa;
@dynamic grade5Volume;
@dynamic grade5VolumeHa;
@dynamic totalBillValue;
@dynamic totalBillValueHa;
@dynamic totalBillVolume;
@dynamic totalBillVolumeHa;
@dynamic totalControlValue;
@dynamic totalControlValueHa;
@dynamic totalControlVolume;
@dynamic totalControlVolumeHa;

@end
