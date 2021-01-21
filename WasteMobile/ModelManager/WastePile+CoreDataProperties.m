//
//  WastePile+CoreDataProperties.m
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-06.
//  Copyright © 2019 Salus Systems. All rights reserved.
//
//

#import "WastePile+CoreDataProperties.h"

@implementation WastePile (CoreDataProperties)

+ (NSFetchRequest<WastePile *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"WastePile"];
}

@dynamic pileId;
@dynamic pileNumber;
@dynamic length;
@dynamic width;
@dynamic height;
@dynamic pileArea;
@dynamic pileVolume;
@dynamic measuredLength;
@dynamic measuredWidth;
@dynamic measuredHeight;
@dynamic measuredPileArea;
@dynamic measuredPileVolume;
@dynamic cePercent;
@dynamic hePercent;
@dynamic spPercent;
@dynamic baPercent;
@dynamic coPercent;
@dynamic loPercent;
@dynamic biPercent;
@dynamic alPercent;
@dynamic arPercent;
@dynamic asPercent;
@dynamic cyPercent;
@dynamic fiPercent;
@dynamic laPercent;
@dynamic maPercent;
@dynamic otPercent;
@dynamic wbPercent;
@dynamic whPercent;
@dynamic wiPercent;
@dynamic uuPercent;
@dynamic yePercent;
@dynamic comment;
@dynamic isSample;
@dynamic pilePileShapeCode;
@dynamic pileStratum;
@dynamic pileData;

@end
