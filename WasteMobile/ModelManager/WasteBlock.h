//
//  WasteBlock.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-04.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MaturityCode, SnowCode, Timbermark, WasteStratum, SiteCode, EFWCoastStat, EFWInteriorStat;

NS_ASSUME_NONNULL_BEGIN

@interface WasteBlock : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "WasteBlock+CoreDataProperties.h"
