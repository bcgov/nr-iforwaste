//
//  WastePieceDTO.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-08.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WastePieceDTO : NSObject

@property  NSNumber * buttDeduction;
@property  NSNumber * buttDiameter;
@property  NSNumber * length;
@property  NSNumber * lengthDeduction;
@property  NSNumber * piece;
@property  NSString * pieceNumber;
@property  NSDecimalNumber * pieceVolume;
@property  NSNumber * topDeduction;
@property  NSNumber * topDiameter;
@property  NSNumber * estimatedPercent;
@property  NSDecimalNumber * densityEstimate;
@property  NSDecimalNumber * estimatedVolume;

@property  NSString *borderlineCode;
@property  NSString *buttEndCode;
@property  NSString *commentCode;
@property  NSString *decayTypeCode;
@property  NSString *materialKindCode;
@property  NSString *scaleGradeCode;
@property  NSString *scaleSpeciesCode;
@property  NSString *topEndCode;
@property  NSString *wasteClassCode;

@end
