//
//  AggregateCutblock+CoreDataProperties.m
//  WasteMobile
//
//  Created by Sweta Kutty on 2020-03-09.
//  Copyright © 2020 Salus Systems. All rights reserved.
//
//

#import "AggregateCutblock+CoreDataProperties.h"

@implementation AggregateCutblock (CoreDataProperties)

+ (NSFetchRequest<AggregateCutblock *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AggregateCutblock"];
}

@dynamic aggregateCutblock;
@dynamic aggregateCuttingPermit;
@dynamic aggregateLicense;
@dynamic totalNumPile;
@dynamic measureSample;
@dynamic aggregateID;
@dynamic stratumAgg;
@dynamic aggPile;
@dynamic n1sample;
@dynamic n2sample;

@end
