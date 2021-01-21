//
//  ExportUserData+CoreDataProperties.m
//  WasteMobile
//
//  Created by Denholm Scrimshaw on 2017-02-27.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "ExportUserData+CoreDataProperties.h"

@implementation ExportUserData (CoreDataProperties)

+ (NSFetchRequest<ExportUserData *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ExportUserData"];
}

@dynamic districtCode;
@dynamic clientCode;
@dynamic licenseeContact;
@dynamic telephoneNumber;
@dynamic emailAddress;

@end
