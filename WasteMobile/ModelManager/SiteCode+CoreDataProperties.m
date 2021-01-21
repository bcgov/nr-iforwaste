//
//  SiteCode+CoreDataProperties.m
//  WasteMobile
//
//  Created by Jack Wong on 2016-11-04.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import "SiteCode+CoreDataProperties.h"

@implementation SiteCode (CoreDataProperties)

+ (NSFetchRequest<SiteCode *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SiteCode"];
}

@dynamic desc;
@dynamic siteCode;
@dynamic effectiveDate;
@dynamic expiryDate;
@dynamic updateTimestamp;
@dynamic siteCodeBlock;

@end
