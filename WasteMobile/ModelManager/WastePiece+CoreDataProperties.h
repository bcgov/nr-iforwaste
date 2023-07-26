//
//  WastePiece+CoreDataProperties.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-04.
//  Copyright © 2016 Salus Systems. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WastePiece.h"

NS_ASSUME_NONNULL_BEGIN

@interface WastePiece (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *addLength;
@property (nullable, nonatomic, retain) NSNumber *buttDeduction;
@property (nullable, nonatomic, retain) NSNumber *buttDiameter;
@property (nullable, nonatomic, retain) NSDecimalNumber *checkAvoidX;
@property (nullable, nonatomic, retain) NSDecimalNumber *checkAvoidY;
@property (nullable, nonatomic, retain) NSDecimalNumber *checkNetVal;
@property (nullable, nonatomic, retain) NSDecimalNumber *checkPieceVolume;
@property (nullable, nonatomic, retain) NSDecimalNumber *deltaAvoidX;
@property (nullable, nonatomic, retain) NSDecimalNumber *deltaAvoidY;
@property (nullable, nonatomic, retain) NSDecimalNumber *deltaNetVal;
@property (nullable, nonatomic, retain) NSDecimalNumber *densityEstimate;
@property (nullable, nonatomic, retain) NSDecimalNumber *estimatedPercent;
@property (nullable, nonatomic, retain) NSDecimalNumber *estimatedVolume;
@property (nullable, nonatomic, retain) NSNumber *farEnd;
@property (nullable, nonatomic, retain) NSNumber *length;
@property (nullable, nonatomic, retain) NSNumber *lengthDeduction;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSString *usercode;  
@property (nullable, nonatomic, retain) NSNumber *piece;
@property (nullable, nonatomic, retain) NSString *pieceNumber;
@property (nullable, nonatomic, retain) NSDecimalNumber *pieceValue;
@property (nullable, nonatomic, retain) NSDecimalNumber *pieceVolume;
@property (nullable, nonatomic, retain) NSNumber *sortNumber;
@property (nullable, nonatomic, retain) NSDecimalNumber *surveyAvoidX;
@property (nullable, nonatomic, retain) NSDecimalNumber *surveyAvoidY;
@property (nullable, nonatomic, retain) NSDecimalNumber *surveyNetVal;
@property (nullable, nonatomic, retain) NSNumber *topDeduction;
@property (nullable, nonatomic, retain) NSNumber *topDiameter;
@property (nullable, nonatomic, retain) NSDecimalNumber *volOverHa;
@property (nullable, nonatomic, retain) NSNumber *isSurvey;
@property (nullable, nonatomic, retain) BorderlineCode *pieceBorderlineCode;
@property (nullable, nonatomic, retain) ButtEndCode *pieceButtEndCode;
@property (nullable, nonatomic, retain) CheckerStatusCode *pieceCheckerStatusCode;
@property (nullable, nonatomic, retain) CommentCode *pieceCommentCode;
@property (nullable, nonatomic, retain) DecayTypeCode *pieceDecayTypeCode;
@property (nullable, nonatomic, retain) MaterialKindCode *pieceMaterialKindCode;
@property (nullable, nonatomic, retain) WastePlot *piecePlot;
@property (nullable, nonatomic, retain) ScaleGradeCode *pieceScaleGradeCode;
@property (nullable, nonatomic, retain) ScaleSpeciesCode *pieceScaleSpeciesCode;
@property (nullable, nonatomic, retain) TopEndCode *pieceTopEndCode;
@property (nullable, nonatomic, retain) WasteClassCode *pieceWasteClassCode;

@end

NS_ASSUME_NONNULL_END
