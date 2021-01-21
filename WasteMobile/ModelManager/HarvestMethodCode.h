//
//  HarvestMethodCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WasteStratum;

@interface HarvestMethodCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * harvestMethodCode;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *harvestMethodCodeStratum;
@end

@interface HarvestMethodCode (CoreDataGeneratedAccessors)

- (void)addHarvestMethodCodeStratumObject:(WasteStratum *)value;
- (void)removeHarvestMethodCodeStratumObject:(WasteStratum *)value;
- (void)addHarvestMethodCodeStratum:(NSSet *)values;
- (void)removeHarvestMethodCodeStratum:(NSSet *)values;

@end
