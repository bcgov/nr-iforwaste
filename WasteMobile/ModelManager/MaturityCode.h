//
//  MaturityCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WasteBlock;

@interface MaturityCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * maturityCode;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *maturityCodeBlock;
@end

@interface MaturityCode (CoreDataGeneratedAccessors)

- (void)addMaturityCodeBlockObject:(WasteBlock *)value;
- (void)removeMaturityCodeBlockObject:(WasteBlock *)value;
- (void)addMaturityCodeBlock:(NSSet *)values;
- (void)removeMaturityCodeBlock:(NSSet *)values;

@end
