//
//  SearchResultDTOAdaptor.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "SearchResultDTOAdaptor.h"
#import "SearchResultDTO.h"

@implementation SearchResultDTOAdaptor

+ (NSArray *)searchResultDTOFromJSON:(NSData *)objectNotation error:(NSError **)error{
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *searchResultAry = [[NSMutableArray alloc] init];
    
  //  NSArray *results = [parsedObject valueForKey:@"results"];
  //  NSLog(@"Count %d", results.count);
    
    for (NSDictionary *searchResult in parsedObject) {
        
        SearchResultDTO *searchResultDto = [[SearchResultDTO alloc] init];
        
        searchResultDto.reportingUnit = [searchResult valueForKey:@"reportingUnitNo"] != [NSNull null] ? [searchResult valueForKey:@"reportingUnitNo"] : @"";
        searchResultDto.licenceNumber = [searchResult valueForKey:@"licenceNo"] != [NSNull null] ? [searchResult valueForKey:@"licenceNo"] : @"";
        searchResultDto.cuttingPermitId = [searchResult valueForKey:@"cuttingPermitID"] != [NSNull null] ? [searchResult valueForKey:@"cuttingPermitID"] : @"";
        searchResultDto.blockNumber = [searchResult valueForKey:@"cutBlockId"] != [NSNull null] ? [searchResult valueForKey:@"cutBlockId"] : @"";
        searchResultDto.timbermark = [searchResult valueForKey:@"timberMarks"] != [NSNull null] ? [searchResult valueForKey:@"timberMarks"] : @"";
        searchResultDto.exempted = [searchResult valueForKey:@"exempted"] != [NSNull null] ? [searchResult valueForKey:@"exempted"] : @"";
        searchResultDto.netArea = [searchResult valueForKey:@"netArea"] != [NSNull null] ?  [searchResult valueForKey:@"netArea"] : @"";
        searchResultDto.blockStatus = [searchResult valueForKey:@"blockStatus"] != [NSNull null] ? [searchResult valueForKey:@"blockStatus"] : @"";
        searchResultDto.blockID = [searchResult valueForKey:@"cutBlockId"] != [NSNull null] ? [searchResult valueForKey:@"cutBlockId"] : @"";
        searchResultDto.wasteAssessmentAreaID = [searchResult valueForKey:@"wasteAssessmentAreaID"] != [NSNull null] ? [searchResult valueForKey:@"wasteAssessmentAreaID"] : @"";
        
        [searchResultAry addObject:searchResultDto];
    }
    NSLog(@"Found %lu cut block for the reporting unit number", (unsigned long)searchResultAry.count);
    return searchResultAry;
}

@end
