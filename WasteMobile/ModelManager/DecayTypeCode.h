//
//  DecayTypeCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;

@interface DecayTypeCode : NSManagedObject

@property (nonatomic, retain) NSString * decayTypeCode;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *decayTypeCodePiece;
@end

@interface DecayTypeCode (CoreDataGeneratedAccessors)

- (void)addDecayTypeCodePieceObject:(WastePiece *)value;
- (void)removeDecayTypeCodePieceObject:(WastePiece *)value;
- (void)addDecayTypeCodePiece:(NSSet *)values;
- (void)removeDecayTypeCodePiece:(NSSet *)values;

@end
