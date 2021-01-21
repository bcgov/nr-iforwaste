//
//  TimbermarkDTOAdaptor.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-08.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "TimbermarkDTOAdaptor.h"
#import "TimbermarkDTO.h"

@implementation TimbermarkDTOAdaptor

+ (NSArray *)timbermarkDTOFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *tmAry = [[NSMutableArray alloc] init];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd-yyyy"];
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    
    for (NSDictionary *tm in parsedObject) {
        
        TimbermarkDTO *tmDto = [[TimbermarkDTO alloc] init];
        if([tm valueForKey:@"area"] != [NSNull null]){
            tmDto.area = [NSDecimalNumber decimalNumberWithString:[tm valueForKey:@"area"]];
        }
        if([tm valueForKey:@"timberMark"] != [NSNull null]){
            tmDto.timbermark = [tm valueForKey:@"timberMark"];
        }
        if( [tm valueForKey:@"primaryInd"] != [NSNull null]) {
            tmDto.primaryInd = [nf numberFromString:[tm valueForKey:@"primaryInd"]];
        }
  
        
        [tmAry addObject:tmDto];
    }
    
    NSLog(@"Found %lu timber for the cut block", (unsigned long)tmAry.count);

    return tmAry;
}

@end
