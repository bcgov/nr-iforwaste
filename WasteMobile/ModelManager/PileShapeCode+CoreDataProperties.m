//
//  PileShapeCode+CoreDataProperties.m
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-06.
//  Copyright © 2019 Salus Systems. All rights reserved.
//
//

#import "PileShapeCode+CoreDataProperties.h"

@implementation PileShapeCode (CoreDataProperties)

+ (NSFetchRequest<PileShapeCode *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"PileShapeCode"];
}

@dynamic pileShapeCode;
@dynamic desc;
@dynamic effectiveDate;
@dynamic expiryDate;
@dynamic updateTimestamp;
@dynamic pileShapeCodePile;

@end
