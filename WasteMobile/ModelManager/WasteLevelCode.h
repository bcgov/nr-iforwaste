//
//  WasteLevelCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WasteStratum;

@interface WasteLevelCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSString * wasteLevelCode;
@property (nonatomic, retain) NSSet *wasteLevelCodeStratum;
@end

@interface WasteLevelCode (CoreDataGeneratedAccessors)

- (void)addWasteLevelCodeStratumObject:(WasteStratum *)value;
- (void)removeWasteLevelCodeStratumObject:(WasteStratum *)value;
- (void)addWasteLevelCodeStratum:(NSSet *)values;
- (void)removeWasteLevelCodeStratum:(NSSet *)values;

@end
