//
//  MonetaryReductionFactorCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Timbermark;

@interface MonetaryReductionFactorCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * monetaryReductionFactorCode;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *monetaryReductionFactorCodeTimbermark;
@end

@interface MonetaryReductionFactorCode (CoreDataGeneratedAccessors)

- (void)addMonetaryReductionFactorCodeTimbermarkObject:(Timbermark *)value;
- (void)removeMonetaryReductionFactorCodeTimbermarkObject:(Timbermark *)value;
- (void)addMonetaryReductionFactorCodeTimbermark:(NSSet *)values;
- (void)removeMonetaryReductionFactorCodeTimbermark:(NSSet *)values;

@end
