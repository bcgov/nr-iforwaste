//
//  WasteTypeCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WasteStratum;

@interface WasteTypeCode : NSManagedObject

@property (nonatomic, retain) NSString * wasteTypeCode;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *wasteTypeCodeStratum;
@end

@interface WasteTypeCode (CoreDataGeneratedAccessors)

- (void)addWasteTypeCodeStratumObject:(WasteStratum *)value;
- (void)removeWasteTypeCodeStratumObject:(WasteStratum *)value;
- (void)addWasteTypeCodeStratum:(NSSet *)values;
- (void)removeWasteTypeCodeStratum:(NSSet *)values;

@end
