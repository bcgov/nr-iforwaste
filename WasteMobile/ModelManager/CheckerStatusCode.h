//
//  CheckerStatusCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;
@class WastePile;

@interface CheckerStatusCode : NSManagedObject

@property (nonatomic, retain) NSString * checkerStatusCode;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *checkerStatusCodePiece;
@property (nonatomic, retain) NSSet *checkerStatusCodePile;
@end

@interface CheckerStatusCode (CoreDataGeneratedAccessors)

- (void)addCheckerStatusCodePieceObject:(WastePiece *)value;
- (void)removeCheckerStatusCodePieceObject:(WastePiece *)value;
- (void)addCheckerStatusCodePiece:(NSSet *)values;
- (void)removeCheckerStatusCodePiece:(NSSet *)values;

- (void)addCheckerStatusCodePileObject:(WastePile *)value;
- (void)removeCheckerStatusCodePileObject:(WastePile *)value;
- (void)addCheckerStatusCodePile:(NSSet *)values;
- (void)removeCheckerStatusCodePile:(NSSet *)values;
@end
