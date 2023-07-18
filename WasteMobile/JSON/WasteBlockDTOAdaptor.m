//
//  WasteBlockDTOAdaptor.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-07.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "WasteBlockDTOAdaptor.h"
#import "WasteBlockDTO.h"

@implementation WasteBlockDTOAdaptor

+ (NSArray *)wasteBlockDTOFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *wbAry = [[NSMutableArray alloc] init];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM-dd-yyyy"];

    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    
    for (NSDictionary *wb in parsedObject) {
        
        WasteBlockDTO *wbDto = [[WasteBlockDTO alloc] init];
        if([wb valueForKey:@"cutBlockID"] != [NSNull null]){
            wbDto.cutBlockId = [wb valueForKey:@"cutBlockID"];
        }
        if([wb valueForKey:@"blockNumber"] != [NSNull null]){
            wbDto.blockNumber = [wb valueForKey:@"blockNumber"];
        }
        if( [wb valueForKey:@"blockStatus"] != [NSNull null]) {
            wbDto.blockStatus = [wb valueForKey:@"blockStatus"];
        }
        if ([wb valueForKey:@"cruiseArea"] != [NSNull null]){
            wbDto.cruiseArea = [NSDecimalNumber decimalNumberWithString:[wb valueForKey:@"cruiseArea"]];
        }
        if([wb valueForKey:@"cuttingPermitID"] != [NSNull null]){
            wbDto.cuttingPermitId = [wb valueForKey:@"cuttingPermitID"];
        }
        if([wb valueForKey:@"exempted"] != [NSNull null]){
            wbDto.exempted = [wb valueForKey:@"exempted"];
        }
        if([wb valueForKey:@"licenceNumber"] != [NSNull null]){
            wbDto.licenceNumber = [wb valueForKey:@"licenceNumber"];
        }
        if([wb valueForKey:@"location"] != [NSNull null]){
            wbDto.location = [wb valueForKey:@"location"];
        }
        if([wb valueForKey:@"logginCompleteDate"] != [NSNull null]){
            wbDto.loggingCompleteDate = [[NSDate alloc] init];
            wbDto.loggingCompleteDate = [df dateFromString:[wb valueForKey:@"logginCompleteDate"]];
        }
        if([wb valueForKey:@"netArea"] != [NSNull null]){
            wbDto.netArea = [NSDecimalNumber decimalNumberWithString:[wb valueForKey:@"netArea"]];
        }
        if([wb valueForKey:@"npNFArea"] != [NSNull null]){
            wbDto.npNFArea = [NSDecimalNumber decimalNumberWithString:[wb valueForKey:@"npNFArea"]];
        }
        if([wb valueForKey:@"reportingUnit"] != [NSNull null]){
            wbDto.reportingUnit = [nf numberFromString:[wb valueForKey:@"reportingUnit"]];
        }
        if([wb valueForKey:@"reportingUnitID"] != [NSNull null]){
            wbDto.reportingUnitId = [nf numberFromString:[wb valueForKey:@"reportingUnitID"]];
        }
        if([wb valueForKey:@"returnNumber"] != [NSNull null]){
            wbDto.returnNumber = [nf numberFromString:[wb valueForKey:@"returnNumber"]];
        }
        if([wb valueForKey:@"surveyDate"] != [NSNull null]){
            wbDto.surveyDate = [[NSDate alloc] init];
            wbDto.surveyDate = [df dateFromString:[wb valueForKey:@"surveyDate"]];
        }
        if([wb valueForKey:@"surveyorLicence"] != [NSNull null]){
            wbDto.surveyorLicence = [wb valueForKey:@"surveyorLicence"];
        }
        if([wb valueForKey:@"yearLoggedFrom"] != [NSNull null]){
            wbDto.yearLoggedFrom = [nf numberFromString:[wb valueForKey:@"yearLoggedFrom"]];
        }
        if([wb valueForKey:@"yearLoggedTo"] != [NSNull null]){
            wbDto.yearLoggedTo = [nf numberFromString:[wb valueForKey:@"yearLoggedTo"]];
        }
        if([wb valueForKey:@"wasteAssessmentAreaID"] != [NSNull null]){
            wbDto.wasteAssessmentAreaID = [nf numberFromString:[wb valueForKey:@"wasteAssessmentAreaID"]];
        }

        //code in NSString
        //** check site code, if site code exist, assign it to maturity code
        if([wb valueForKey:@"maturityCode"] != [NSNull null]){
            wbDto.maturityCode = [wb valueForKey:@"maturityCode"];
        }
        if([wb valueForKey:@"siteCode"] != [NSNull null]){
            wbDto.siteCode = [wb valueForKey:@"siteCode"];
        }
        if([wb valueForKey:@"snowCode"] != [NSNull null]){
            wbDto.snowCode = [wb valueForKey:@"snowCode"];
        }
        
        [wbAry addObject:wbDto];
    }
    
    NSLog(@"Found %lu cut block for the reporting unit number", (unsigned long)wbAry.count);
    return wbAry;
}

@end
