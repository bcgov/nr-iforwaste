//
//  XMLToESFMappingDAO.h
//  WasteMobile
//
//  Created by Denholm Scrimshaw on 2017-02-20.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLToESFMappingDAO : NSObject

+(XMLToESFMappingDAO *) sharedInstance;

- (void) initCodeTable: (NSError **) error;

- (NSArray *) getWasteAssessmentTypeMapping;
- (NSArray *) getWasteStratumMapping;
- (NSArray *) getWastePlotMapping;
-(NSArray *) getWastePieceMapping:(NSString*) assessmnetMethodCode;
- (NSArray *) getTimberMarkMapping;
-(NSArray *) getStratumPileMapping;
-(NSArray *) getWastePileMapping;

@end
