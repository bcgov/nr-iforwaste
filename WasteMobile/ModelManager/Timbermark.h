//
//  Timbermark.h
//  WasteMobile
//
//  Created by Jack Wong on 2015-04-21.
//  Copyright (c) 2015 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MonetaryReductionFactorCode, WasteBlock;

@interface Timbermark : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * allSppJWMRF;
@property (nonatomic, retain) NSDecimalNumber * area;
@property (nonatomic, retain) NSDecimalNumber * avoidable;
@property (nonatomic, retain) NSDecimalNumber * benchmark;
@property (nonatomic, retain) NSDecimalNumber * coniferPrice;
@property (nonatomic, retain) NSDecimalNumber * coniferWMRF;
@property (nonatomic, retain) NSDecimalNumber * deciduousPrice;
@property (nonatomic, retain) NSDecimalNumber * deciduousWMRF;
@property (nonatomic, retain) NSDecimalNumber * hembalPrice;
@property (nonatomic, retain) NSDecimalNumber * hembalWMRF;
@property (nonatomic, retain) NSNumber * primaryInd;
@property (nonatomic, retain) NSDecimalNumber * surveyArea;
@property (nonatomic, retain) NSString * timbermark;
@property (nonatomic, retain) NSDecimalNumber * wmrf;
@property (nonatomic, retain) NSDecimalNumber * xPrice;
@property (nonatomic, retain) NSDecimalNumber * xWMRF;
@property (nonatomic, retain) NSDecimalNumber * yPrice;
@property (nonatomic, retain) NSDecimalNumber * yWMRF;
@property (nonatomic, retain) NSDecimalNumber * orgXWMRF;
@property (nonatomic, retain) NSDecimalNumber * orgYWMRF;
@property (nonatomic, retain) NSDecimalNumber * orgAllSppJWMRF;
@property (nonatomic, retain) NSDecimalNumber * orgDeciduousWMRF;
@property (nonatomic, retain) NSDecimalNumber * orgHembalWMRF;
@property (nonatomic, retain) NSDecimalNumber * orgWMRF;
@property (nonatomic, retain) WasteBlock *timbermarkBlock;
@property (nonatomic, retain) MonetaryReductionFactorCode *timbermarkMonetaryReductionFactorCode;

@end
