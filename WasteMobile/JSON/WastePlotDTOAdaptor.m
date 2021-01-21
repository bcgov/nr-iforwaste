//
//  WastePlotDTOAdaptor.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-08.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "WastePlotDTOAdaptor.h"
#import "WastePlotDTO.h"

@implementation WastePlotDTOAdaptor

+ (NSArray *)wastePlotDTOFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *wpAry = [[NSMutableArray alloc] init];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd-yyyy"];
  
   
    for (NSDictionary *wp in parsedObject) {
        
        WastePlotDTO *wpDto = [[WastePlotDTO alloc] init];
        
        if(![[wp objectForKey:@"wastePlotId"] isKindOfClass:[NSNull class]]){
            wpDto.plotID = [wp objectForKey:@"wastePlotId"];
        }
        if(![[wp objectForKey:@"wasteBaseline"] isKindOfClass:[NSNull class]] ){
            wpDto.baseline = [wp objectForKey:@"wasteBaseline"];
        }
        if(![[wp objectForKey:@"wastePlotNumber"] isKindOfClass:[NSNull class]]){
            wpDto.plotNumber = [wp objectForKey:@"wastePlotNumber"];
        }
        if(![[wp objectForKey:@"wasteStrip"] isKindOfClass:[NSNull class]]){
            wpDto.strip = [wp objectForKey:@"wasteStrip"];
        }
        if(![[wp objectForKey:@"measureFactor"] isKindOfClass:[NSNull class]]){
            wpDto.surveyedMeasurePercent = [wp objectForKey:@"measureFactor"];
        }
  
        [wpAry addObject:wpDto];
    }
    
    NSLog(@"Found %lu plot for stratum", (unsigned long)wpAry.count);
    return wpAry;
}

@end
