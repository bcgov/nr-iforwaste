//
//  MeasuredPileShapeCode+CoreDataProperties.m
//  WasteMobile
//
//  Created by Michael Tennant on 2023-10-31.
//  Copyright (c) 2023 Salus Systems. All rights reserved.
//
//

#import "MeasuredPileShapeCode+CoreDataProperties.h"

@implementation MeasuredPileShapeCode (CoreDataProperties)

+ (NSFetchRequest<MeasuredPileShapeCode *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"MeasuredPileShapeCode"];
}

@dynamic measuredPileShapeCode;
@dynamic desc;
@dynamic effectiveDate;
@dynamic expiryDate;
@dynamic updateTimestamp;
@dynamic measuredPileShapeCodePile;

@end
