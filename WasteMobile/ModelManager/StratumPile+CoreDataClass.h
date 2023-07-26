//
//  StratumPile+CoreDataClass.h
//  WasteMobile
//
//  Created by Sweta Kutty on 2020-03-06.
//  Copyright © 2020 Salus Systems. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePile, WasteStratum, AggregateCutblock, EFWInteriorStat, EFWCoastStat;

NS_ASSUME_NONNULL_BEGIN

@interface StratumPile : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "StratumPile+CoreDataProperties.h"
