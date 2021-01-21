//
//  PlotSizeCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WasteStratum;

@interface PlotSizeCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDecimalNumber * plotMultipler;
@property (nonatomic, retain) NSString * plotSizeCode;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *plotSizeCodeStratum;
@end

@interface PlotSizeCode (CoreDataGeneratedAccessors)

- (void)addPlotSizeCodeStratumObject:(WasteStratum *)value;
- (void)removePlotSizeCodeStratumObject:(WasteStratum *)value;
- (void)addPlotSizeCodeStratum:(NSSet *)values;
- (void)removePlotSizeCodeStratum:(NSSet *)values;

@end
