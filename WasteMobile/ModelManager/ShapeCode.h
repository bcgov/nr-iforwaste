//
//  ShapeCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePlot;

@interface ShapeCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * shapeCode;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *shapeCodePlot;
@end

@interface ShapeCode (CoreDataGeneratedAccessors)

- (void)addShapeCodePlotObject:(WastePlot *)value;
- (void)removeShapeCodePlotObject:(WastePlot *)value;
- (void)addShapeCodePlot:(NSSet *)values;
- (void)removeShapeCodePlot:(NSSet *)values;

@end
