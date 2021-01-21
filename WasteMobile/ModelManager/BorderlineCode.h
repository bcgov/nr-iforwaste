//
//  BorderlineCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;

@interface BorderlineCode : NSManagedObject

@property (nonatomic, retain) NSString * borderlineCode;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *borderlineCodePiece;
@end

@interface BorderlineCode (CoreDataGeneratedAccessors)

- (void)addBorderlineCodePieceObject:(WastePiece *)value;
- (void)removeBorderlineCodePieceObject:(WastePiece *)value;
- (void)addBorderlineCodePiece:(NSSet *)values;
- (void)removeBorderlineCodePiece:(NSSet *)values;

@end
