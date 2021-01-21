//
//  ScaleSpeciesCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;

@interface ScaleSpeciesCode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * scaleSpeciesCode;
@property (nonatomic, retain) NSString * surveyType;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *scaleSpeciesCodePiece;
@end

@interface ScaleSpeciesCode (CoreDataGeneratedAccessors)

- (void)addScaleSpeciesCodePieceObject:(WastePiece *)value;
- (void)removeScaleSpeciesCodePieceObject:(WastePiece *)value;
- (void)addScaleSpeciesCodePiece:(NSSet *)values;
- (void)removeScaleSpeciesCodePiece:(NSSet *)values;

@end
