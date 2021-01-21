//
//  MaterialKindCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;

@interface MaterialKindCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * materialKindCode;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *materialKindCodePiece;
@end

@interface MaterialKindCode (CoreDataGeneratedAccessors)

- (void)addMaterialKindCodePieceObject:(WastePiece *)value;
- (void)removeMaterialKindCodePieceObject:(WastePiece *)value;
- (void)addMaterialKindCodePiece:(NSSet *)values;
- (void)removeMaterialKindCodePiece:(NSSet *)values;

@end
