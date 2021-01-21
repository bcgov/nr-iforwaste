//
//  WastePieceDTOAdaptor.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-08.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "WastePieceDTOAdaptor.h"
#import "WastePieceDTO.h"

@implementation WastePieceDTOAdaptor

+ (NSArray *)wastePieceDTOFromJSON:(NSData *)objectNotation error:(NSError **)error{
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
        
        WastePieceDTO *wpDto = [[WastePieceDTO alloc] init];
        
        if(![[wp valueForKey:@"wastePieceId"] isKindOfClass:[NSNull class]]){
            wpDto.piece = [wp objectForKey:@"wastePieceId"];
        }
        if(![[wp valueForKey:@"wastePieceNumber"] isKindOfClass:[NSNull class]]){
            wpDto.pieceNumber = [(NSNumber *)[wp objectForKey:@"wastePieceNumber"] stringValue];
        }
        if(![[wp valueForKey:@"length"]  isKindOfClass:[NSNull class]]){
            wpDto.length = [wp objectForKey:@"length"];
        }
        if(![[wp valueForKey:@"topDiameter"]  isKindOfClass:[NSNull class]]){
            wpDto.topDiameter = [wp objectForKey:@"topDiameter"];
        }
        if(![[wp valueForKey:@"buttDiameter"]  isKindOfClass:[NSNull class]]){
            wpDto.buttDiameter = [wp objectForKey:@"buttDiameter"];
        }
        if(![[wp valueForKey:@"lengthDeduction"]  isKindOfClass:[NSNull class]]){
            wpDto.lengthDeduction = [wp objectForKey:@"lengthDeduction"];
        }
        if(![[wp valueForKey:@"topDeduction"]  isKindOfClass:[NSNull class]]){
            wpDto.topDeduction = [wp objectForKey:@"topDeduction"];
        }
        if(![[wp valueForKey:@"buttDeduction"]  isKindOfClass:[NSNull class]]){
            wpDto.buttDeduction = [wp objectForKey:@"buttDeduction"];
        }
        if(![[wp valueForKey:@"estimatedVolume"]  isKindOfClass:[NSNull class]]){
            wpDto.estimatedVolume = [wp objectForKey:@"estimatedVolume"];
        }
        if(![[wp valueForKey:@"wasteMaterialKindCode"] isKindOfClass:[NSNull class]]){
            wpDto.materialKindCode = [wp objectForKey:@"wasteMaterialKindCode"];
        }
        if(![[wp valueForKey:@"wasteClassCode"] isKindOfClass:[NSNull class]]){
            wpDto.wasteClassCode = [wp objectForKey:@"wasteClassCode"];
        }
        if(![[wp valueForKey:@"scaleGradeCode"] isKindOfClass:[NSNull class]]){
            wpDto.scaleGradeCode = [wp objectForKey:@"scaleGradeCode"];
        }
        if(![[wp valueForKey:@"scaleSpeciesCode"] isKindOfClass:[NSNull class]]){
            wpDto.scaleSpeciesCode = [wp objectForKey:@"scaleSpeciesCode"];
        }
        if(![[wp valueForKey:@"topEndCode"] isKindOfClass:[NSNull class]]){
            wpDto.topEndCode = [wp objectForKey:@"topEndCode"];
        }
        if(![[wp valueForKey:@"buttEndCode"] isKindOfClass:[NSNull class]]){
            wpDto.buttEndCode = [wp objectForKey:@"buttEndCode"];
        }
        if(![[wp valueForKey:@"wasteBorderlineCode"] isKindOfClass:[NSNull class]]){
            wpDto.borderlineCode = [wp objectForKey:@"wasteBorderlineCode"];
        }
        if(![[wp valueForKey:@"wasteDecayTypeCode"] isKindOfClass:[NSNull class]]){
            wpDto.decayTypeCode = [wp objectForKey:@"wasteDecayTypeCode"];
        }
        if(![[wp valueForKey:@"wasteCommentCode"] isKindOfClass:[NSNull class]]){
            wpDto.commentCode = [wp objectForKey:@"wasteCommentCode"];
        }
        if(![[wp valueForKey:@"estimatedPercent"]  isKindOfClass:[NSNull class]]){
            wpDto.estimatedPercent = [wp objectForKey:@"estimatedPercent"];
        }
        if(![[wp valueForKey:@"densityEstimate"]  isKindOfClass:[NSNull class]]){
            wpDto.densityEstimate = [wp objectForKey:@"densityEstimate"];
        }
        
        [wpAry addObject:wpDto];
    }
    
    NSLog(@"Found %lu piece for a plot", (unsigned long)wpAry.count);
    return wpAry;
}

@end
