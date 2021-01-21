//
//  TopEndCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;

@interface TopEndCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * topEndCode;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *topEndCodePiece;
@end

@interface TopEndCode (CoreDataGeneratedAccessors)

- (void)addTopEndCodePieceObject:(WastePiece *)value;
- (void)removeTopEndCodePieceObject:(WastePiece *)value;
- (void)addTopEndCodePiece:(NSSet *)values;
- (void)removeTopEndCodePiece:(NSSet *)values;

@end
