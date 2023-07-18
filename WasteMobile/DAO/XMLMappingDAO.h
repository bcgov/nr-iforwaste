//
//  XMLMappingDAO.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-26.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MappingDataType{
    DTString = 0,
    DTDecimalNumber = 1,
    DTNumber = 2,
    DTDate = 3
}MappingDataType;

@interface XMLMappingDAO : NSObject

+(XMLMappingDAO *) sharedInstance;

-(void)initCodeTable:(NSError **)error;

-(NSArray *) getWasteAssessmentTypeMapping;
-(NSArray *) getWasteStratumMapping;
-(NSArray *) getWastePlotMapping;
-(NSArray *) getWastePieceMapping:(NSString*) assessmnetMethodCode;
-(NSArray *) getTimberMarkMapping;

@end
