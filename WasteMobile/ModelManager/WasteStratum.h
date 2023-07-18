//
//  WasteStratum.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-04.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssessmentMethodCode, HarvestMethodCode, PlotSizeCode, StratumTypeCode, WasteBlock, WasteLevelCode, WastePlot, WasteTypeCode, EFWInteriorStat, EFWCoastStat;

NS_ASSUME_NONNULL_BEGIN

@interface WasteStratum : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "WasteStratum+CoreDataProperties.h"
