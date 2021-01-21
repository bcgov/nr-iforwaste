//
//  WasteClassCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;

@interface WasteClassCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSString * wasteClassCode;
@property (nonatomic, retain) NSSet *wasteClassCodePiece;
@end

@interface WasteClassCode (CoreDataGeneratedAccessors)

- (void)addWasteClassCodePieceObject:(WastePiece *)value;
- (void)removeWasteClassCodePieceObject:(WastePiece *)value;
- (void)addWasteClassCodePiece:(NSSet *)values;
- (void)removeWasteClassCodePiece:(NSSet *)values;

@end
