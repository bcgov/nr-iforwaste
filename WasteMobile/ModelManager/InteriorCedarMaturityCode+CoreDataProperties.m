//
//  InteriorCedarMaturityCode+CoreDataProperties.m
//  iForWaste
//
//  Created by Sweta Kutty on 2019-02-08.
//  Copyright © 2019 Salus Systems. All rights reserved.
//
//

#import "InteriorCedarMaturityCode+CoreDataProperties.h"

@implementation InteriorCedarMaturityCode (CoreDataProperties)

+ (NSFetchRequest<InteriorCedarMaturityCode *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"InteriorCedarMaturityCode"];
}

@dynamic desc;
@dynamic effectiveDate;
@dynamic expiryDate;
@dynamic interiorCedarCode;
@dynamic updateTimestamp;
@dynamic interiorCedarMaturityCodeBlock;

@end
