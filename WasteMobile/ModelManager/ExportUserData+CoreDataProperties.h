//
//  ExportUserData+CoreDataProperties.h
//  WasteMobile
//
//  Created by Denholm Scrimshaw on 2017-02-27.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "ExportUserData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ExportUserData (CoreDataProperties)

+ (NSFetchRequest<ExportUserData *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *districtCode;
@property (nullable, nonatomic, copy) NSString *clientCode;
@property (nullable, nonatomic, copy) NSString *licenseeContact;
@property (nullable, nonatomic, copy) NSString *telephoneNumber;
@property (nullable, nonatomic, copy) NSString *emailAddress;

@end

NS_ASSUME_NONNULL_END
