//
//  StratumPile+CoreDataProperties.m
//  WasteMobile
//
//  Created by Sweta Kutty on 2020-03-06.
//  Copyright © 2020 Salus Systems. All rights reserved.
//
//

#import "StratumPile+CoreDataProperties.h"

@implementation StratumPile (CoreDataProperties)

+ (NSFetchRequest<StratumPile *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StratumPile"];
}

@dynamic surveyorName;
@dynamic surveyDate;
@dynamic notes;
@dynamic stratumPileId;
@dynamic strPile;
@dynamic pileData;
@dynamic aggPile;
@dynamic pileCoastStat;
@dynamic  pileInteriorStat;

@end
