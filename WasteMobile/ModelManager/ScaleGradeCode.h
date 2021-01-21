//
//  ScaleGradeCode.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WastePiece;

@interface ScaleGradeCode : NSManagedObject

@property (nonatomic, retain) NSString * areaType;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * effectiveDate;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * scaleGradeCode;
@property (nonatomic, retain) NSString * surveyType;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSSet *scaleGradeCodePiece;
@end

@interface ScaleGradeCode (CoreDataGeneratedAccessors)

- (void)addScaleGradeCodePieceObject:(WastePiece *)value;
- (void)removeScaleGradeCodePieceObject:(WastePiece *)value;
- (void)addScaleGradeCodePiece:(NSSet *)values;
- (void)removeScaleGradeCodePiece:(NSSet *)values;

@end
