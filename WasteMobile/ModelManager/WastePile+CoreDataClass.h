//
//  WastePile+CoreDataClass.h
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-06.
//  Copyright © 2019 Salus Systems. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PileShapeCode, WasteStratum, StratumPile;

NS_ASSUME_NONNULL_BEGIN

@interface WastePile : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "WastePile+CoreDataProperties.h"
