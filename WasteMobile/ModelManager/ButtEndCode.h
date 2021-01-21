//
//  ButtEndCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;

@interface ButtEndCode : NSManagedObject

@property (nonatomic, retain) NSString * buttEndCode;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *buttEndCodePiece;
@end

@interface ButtEndCode (CoreDataGeneratedAccessors)

- (void)addButtEndCodePieceObject:(WastePiece *)value;
- (void)removeButtEndCodePieceObject:(WastePiece *)value;
- (void)addButtEndCodePiece:(NSSet *)values;
- (void)removeButtEndCodePiece:(NSSet *)values;

@end
