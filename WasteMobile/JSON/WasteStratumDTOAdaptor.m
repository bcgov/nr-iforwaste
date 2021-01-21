//
//  WasteStratumDTOAdaptor.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-08.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "WasteStratumDTOAdaptor.h"
#import "WasteStratumDTO.h"

@implementation WasteStratumDTOAdaptor

+ (NSArray *)wasteStratumDTOFromJSON:(NSData *)objectNotation error:(NSError **)error{
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *wsAry = [[NSMutableArray alloc] init];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd-yyyy"];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    
    for (NSDictionary *ws in parsedObject) {
        
        WasteStratumDTO *wsDto = [[WasteStratumDTO alloc] init];
        if([ws valueForKey:@"stratum"] != [NSNull null]){
            wsDto.stratum = [ws valueForKey:@"stratum"];
        }
        if([ws valueForKey:@"stratumArea"] != [NSNull null]){
            wsDto.stratumArea = [NSDecimalNumber decimalNumberWithString:[ws valueForKey:@"stratumArea"]];
        }
        if( [ws valueForKey:@"stratumID"] != [NSNull null]) {
            wsDto.stratumID = [nf numberFromString:[ws valueForKey:@"stratumID"]];
        }
        if ([ws valueForKey:@"totalEstimatedVolume"] != [NSNull null]){
            wsDto.totalEstimatedVolume = [nf numberFromString:[ws valueForKey:@"totalEstimatedVolume"]];
        }
        
        //code in NSString
        if([ws valueForKey:@"harvestMethodCode"] != [NSNull null]){
            wsDto.harvestMethodCode = [ws valueForKey:@"harvestMethodCode"];
        }
        if([ws valueForKey:@"plotSizeCode"] != [NSNull null]){
            wsDto.plotSizeCode = [ws valueForKey:@"plotSizeCode"];
        }
        if([ws valueForKey:@"stratumTypeCode"] != [NSNull null]){
            wsDto.stratumTypeCode = [ws valueForKey:@"stratumTypeCode"];
        }
        if([ws valueForKey:@"wasteLevelCode"] != [NSNull null]){
            wsDto.wasteLevelCode = [ws valueForKey:@"wasteLevelCode"];
        }
        if([ws valueForKey:@"wasteTypeCode"] != [NSNull null]){
            wsDto.wasteTypeCode = [ws valueForKey:@"wasteTypeCode"];
        }
        if([ws valueForKey:@"wasteTypeCode"] != [NSNull null]){
            wsDto.wasteTypeCode = [ws valueForKey:@"wasteTypeCode"];
        }
        if([ws valueForKey:@"assessmentMethodCode"] != [NSNull null]){
            wsDto.assessmentMethodCode = [ws valueForKey:@"assessmentMethodCode"];
        }
        
        
        [wsAry addObject:wsDto];
    }
    
    NSLog(@"Found %lu stratum for cut block", (unsigned long)wsAry.count);
    
    return wsAry;
}
@end
