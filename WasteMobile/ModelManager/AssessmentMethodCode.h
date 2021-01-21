//
//  AssessmentMethodCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2015-07-29.
//  Copyright (c) 2015 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WasteStratum;

@interface AssessmentMethodCode : NSManagedObject

@property (nonatomic, retain) NSString * assessmentMethodCode;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *assessmentMethodCodeStratum;
@end

@interface AssessmentMethodCode (CoreDataGeneratedAccessors)

- (void)addAssessmentMethodCodeStratumObject:(WasteStratum *)value;
- (void)removeAssessmentMethodCodeStratumObject:(WasteStratum *)value;
- (void)addAssessmentMethodCodeStratum:(NSSet *)values;
- (void)removeAssessmentMethodCodeStratum:(NSSet *)values;

@end
