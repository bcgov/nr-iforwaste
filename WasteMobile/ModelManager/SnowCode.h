//
//  SnowCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WasteBlock;

@interface SnowCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * snowCode;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *snowCodeBlock;
@end

@interface SnowCode (CoreDataGeneratedAccessors)

- (void)addSnowCodeBlockObject:(WasteBlock *)value;
- (void)removeSnowCodeBlockObject:(WasteBlock *)value;
- (void)addSnowCodeBlock:(NSSet *)values;
- (void)removeSnowCodeBlock:(NSSet *)values;

@end
