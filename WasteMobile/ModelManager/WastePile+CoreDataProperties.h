//
//  WastePile+CoreDataProperties.h
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-06.
//  Copyright © 2019 Salus Systems. All rights reserved.
//
//

#import "WastePile+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WastePile (CoreDataProperties)

+ (NSFetchRequest<WastePile *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *pileId;
@property (nullable, nonatomic, copy) NSString *pileNumber;
@property (nullable, nonatomic, copy) NSDecimalNumber *length;
@property (nullable, nonatomic, copy) NSDecimalNumber *width;
@property (nullable, nonatomic, copy) NSDecimalNumber *height;
@property (nullable, nonatomic, copy) NSDecimalNumber *pileArea;
@property (nullable, nonatomic, copy) NSDecimalNumber *pileVolume;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredLength;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredWidth;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredHeight;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredPileArea;
@property (nullable, nonatomic, copy) NSDecimalNumber *measuredPileVolume;
@property (nullable, nonatomic, copy) NSNumber *cePercent;
@property (nullable, nonatomic, copy) NSNumber *hePercent;
@property (nullable, nonatomic, copy) NSNumber *spPercent;
@property (nullable, nonatomic, copy) NSNumber *baPercent;
@property (nullable, nonatomic, copy) NSNumber *coPercent;
@property (nullable, nonatomic, copy) NSNumber *loPercent;
@property (nullable, nonatomic, copy) NSNumber *biPercent;
@property (nullable, nonatomic, copy) NSNumber *alPercent;
@property (nullable, nonatomic, copy) NSNumber *arPercent;
@property (nullable, nonatomic, copy) NSNumber *asPercent;
@property (nullable, nonatomic, copy) NSNumber *yePercent;
@property (nullable, nonatomic, copy) NSNumber *cyPercent;
@property (nullable, nonatomic, copy) NSNumber *fiPercent;
@property (nullable, nonatomic, copy) NSNumber *laPercent;
@property (nullable, nonatomic, copy) NSNumber *maPercent;
@property (nullable, nonatomic, copy) NSNumber *otPercent;
@property (nullable, nonatomic, copy) NSNumber *wbPercent;
@property (nullable, nonatomic, copy) NSNumber *whPercent;
@property (nullable, nonatomic, copy) NSNumber *wiPercent;
@property (nullable, nonatomic, copy) NSNumber *uuPercent;
@property (nullable, nonatomic, copy) NSString *comment;
@property (nullable, nonatomic, copy) NSNumber *isSample;
@property (nullable, nonatomic, retain) PileShapeCode *pilePileShapeCode;
@property (nullable, nonatomic, retain) WasteStratum *pileStratum;
@property (nullable, nonatomic, retain) StratumPile *pileData;

@end

NS_ASSUME_NONNULL_END
