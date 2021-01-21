//
//  WastePiece.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-04.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BorderlineCode, ButtEndCode, CheckerStatusCode, CommentCode, DecayTypeCode, MaterialKindCode, ScaleGradeCode, ScaleSpeciesCode, TopEndCode, WasteClassCode, WastePlot;

NS_ASSUME_NONNULL_BEGIN

@interface WastePiece : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "WastePiece+CoreDataProperties.h"
