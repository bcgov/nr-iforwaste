//
//  XMLToESFMappingDAO.m
//  WasteMobile
//
//  Created by Denholm Scrimshaw on 2017-02-20.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "XMLToESFMappingDAO.h"

@implementation XMLToESFMappingDAO {
    
    NSDictionary *xmlMappingDictionary;
    NSMutableArray *wasteAssessmentMappingAry;
    NSMutableArray *wasteStratumMappingAry;
    NSMutableArray *wastePlotMappingAry;
    NSMutableArray *wastePieceMappingAry;
    NSMutableArray *TimberMarkMappingAry;
    NSMutableArray *stratumPileMappingAry;
    NSMutableArray *wastePileMappingAry;
    
}

+ (XMLToESFMappingDAO *) sharedInstance {
    static XMLToESFMappingDAO *singletonXMLtoESFMappingDAO = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        singletonXMLtoESFMappingDAO = [[super alloc] init];
    });
    
    return singletonXMLtoESFMappingDAO;
}

- (id) init {
    self = [super init];
    
    if (self) {
        //Custom initialization
        NSError *error;
        
        [self initCodeTable:&error];
    }
    return self;
}

- (void) initCodeTable: (NSError **) error {
    if (xmlMappingDictionary == nil) {
        
        wasteAssessmentMappingAry   = [[NSMutableArray alloc] init];
        wasteStratumMappingAry      = [[NSMutableArray alloc] init];
        wastePlotMappingAry         = [[NSMutableArray alloc] init];
        wastePieceMappingAry        = [[NSMutableArray alloc] init];
        
        //1. Core Entity Name
        //2. Core Data Field Name
        //3. Core Data Field Data type
        //4. Checked Field Indicator: Y/N
        //5. XML Field Name
        //6. XML Data Type
        //7. XML Format
        //8. XML order - in case we need it
        
        [wasteAssessmentMappingAry addObject:@"WasteBlock:reportingUnit:2:N:reportingUnitID:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:licenceNumber:0:N:licenseNo:string::"];
        [wasteAssessmentMappingAry addObject:@"Timbermark:timbermark:0:N:timberMark:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:cuttingPermitId:0:N:cuttingPermitID:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:cutBlockId:0:N:cutBlockID:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:blockMaturityCode:MaturityCode:N:wasteMaturityTypeCode:string::"];
        [wasteAssessmentMappingAry addObject:@"Conditional:blockConditionCode:ConditionCode:N:wasteConditionTypeCode:string::"];    //Added - Mandatory/valid if annual plan Interior
        [wasteAssessmentMappingAry addObject:@"Conditional:blockSiteCode:SiteCode:N:wasteSiteTypeCode:string::"];                   //Was Y - mand/valid if annual plan Interior
        [wasteAssessmentMappingAry addObject:@"WasteBlock:surveyArea:1:N:wasteNetArea:decimal::"];
        [wasteAssessmentMappingAry addObject:@"Placeholder:harvestStatusCode:4:N:harvestStatusCode:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:yearLoggedFrom:2:N:yearLoggedFrom:string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:yearLoggedTo:2:N:yearLoggedTo:string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:loggingCompleteDate:3:N:primaryLoggingCompleteDate:date::"];
        [wasteAssessmentMappingAry addObject:@"Timbermark:benchmark:2:N:benchmarkVolume:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:surveyorLicence:0:N:wasteSurveyorLicence:string:"];        //License spelt with 'c' - matches spec. though
        [wasteAssessmentMappingAry addObject:@"WasteBlock:returnNumber:2:N:returnNumber:string::"];
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:blockRoadsArea:2:N:wasteRoadsArea:string::"];            //Added, datatype = 2 (Numeric)? Optional
        [wasteAssessmentMappingAry addObject:@"WasteBlock:surveyDate:3:N:surveyDate:date::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:cruiseArea:1:N:cruiseVolume:string::"];
        [wasteAssessmentMappingAry addObject:@"Placeholder:submitToDistrict:4:N:submitToDistrict:string::"];                         //Added, datatype should be boolean, new type
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:submitterRoleTypeCode:0:N:submitterRoleTypeCode:string::"];             //Added - optional, mand if submitToDistrict true
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:surveyorScalerLicenseNumber:0:N:surveyorScalerLicenseNumber:string::"]; //Added - optional, mand if submitterRoleTypeCode
                                                                                                                                    // is not Unlicensed Surveyor
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:personallyCompleted:4:N:personallyCompleted:string::"];                 //Added - optional
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:sponsoredByRpfRft:4:N:sponsoredByRpfRft:string::"];                     //Added - optional
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:wasteDesignationTypeCode:0:N:wasteDesignationTypeCode:string::"];       //Added - optional, mand if spon.byRpfRft true
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:sponsorName:0:N:sponsorName:string::"];                                 //Added - optional, mand if spon.byRpfRft true
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:sponsorLicenseNumber:0:N:sponsorLicenseNumber:string::"];               //Added - optional, mand if spon.byRpfRft true
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:sponsorPhone:0:N:sponsorPhone:string::"];                               //Added - optional, mand if spon.byRpfRft true
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:sponsorFax:0:N:sponsorFax:string::"];                                   //Added - optional, mand if spon.byRpfRft true
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:sponsorEmail:0:N:sponsorEmail:string::"];                               //Added - optional, mand if spon.byRpfRft true
        //[wasteAssessmentMappingAry addObject:@"WasteBlock:statusComment:0:N:statusComment:string::"];                             //Added - optional
        //[wasteAssessmentMappingAry addObject:@"Timbermark:area:1:N:primaryMarkArea:decimal::"];                                   //Removed (missing from spec)
        
        //Stratum
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumStratumTypeCode:0:N:wasteStratumTypeCode:string:"];                   //Added - mandatory
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumWasteTypeCode:WasteTypeCode:N:wasteTypeCode:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumHarvestMethodCode:HarvestMethodCode:N:wasteHarvestMethodCode:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumAssessmentMethodCode:AssessmentMethodCode:N:wasteAssessmentMethodCode:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumPlotSizeCode:PlotSizeCode:N:wastePlotSizeCode:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumWasteLevelCode:WasteLevelCode:N:wasteLevelCode:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumSurveyArea:1:N:stratumArea:decimal:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:totalEstimatedVolume:2:N:totalEstimatedVolume:string:"];
        
        //Plot
        [wastePlotMappingAry addObject:@"WastePlot:plotNumber:2:N:wastePlotNumber:string:"];
        [wastePlotMappingAry addObject:@"WastePlot:baseline:0:N:wasteBaseline:string:"];
        [wastePlotMappingAry addObject:@"WastePlot:strip:2:N:wasteStrip:string:"];
        [wastePlotMappingAry addObject:@"WastePlot:surveyedMeasurePercent:2:N:measureFactor:string:"];
        
        //Piece
        [wastePieceMappingAry addObject:@"WastePiece:pieceScaleSpeciesCode:ScaleSpeciesCode:N:scaleSpeciesCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceMaterialKindCode:MaterialKindCode:N:wasteMaterialKindCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceWasteClassCode:WasteClassCode:N:wasteClassCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceScaleGradeCode:ScaleGradeCode:N:scaleGradeCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:length:2:N:length:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:topDiameter:2:N:topDiameter:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceTopEndCode:TopEndCode:N:topEndCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:buttDiameter:2:N::buttDiameter:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceButtEndCode:ButtEndCode:N:buttEndCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceBorderlineCode:BorderlineCode:N:wasteBorderlineCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:lengthDeduction:2:N:lengthDeduction:decimal:"];
        [wastePieceMappingAry addObject:@"WastePiece:topDeduction:2:N:topDeduction:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:buttDeduction:2:N:buttDeduction:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceDecayTypeCode:DecayTypeCode:N:wasteDecayTypeCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceCommentCode:CommentCode:N:wasteCommentCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:estimatedVolume:1:N:estimatedVolume:decimal:"];
        [wastePieceMappingAry addObject:@"WastePiece:estimatedPercent:1:N:estimatedPercent:decimal:"];
        [wastePieceMappingAry addObject:@"WastePiece:densityEstimate:1:N:estimatedDensity:decimal:"];
        
        stratumPileMappingAry = [[NSMutableArray alloc] init];
        [stratumPileMappingAry addObject:@"StratumPile:stratumPileId:0:Y::string:"];
        [stratumPileMappingAry addObject:@"StratumPile:surveyorName:0:Y::string:"];
        [stratumPileMappingAry addObject:@"StratumPile:notes:0:Y::string:"];
        [stratumPileMappingAry addObject:@"StratumPile:surveyDate:3:Y::string:"];
        
        wastePileMappingAry = [[NSMutableArray alloc] init];
        [wastePileMappingAry addObject:@"WastePile:pileId:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:pileNumber:0:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:length:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:width:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:height:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:pilePileShapeCode:PileShapeCode:Y::"];
        [wastePileMappingAry addObject:@"WastePile:isSample:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:pileArea:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:pileVolume:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:measuredLength:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:measuredWidth:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:measuredHeight:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:measuredPileArea:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:measuredPileVolume:1:Y:::"];
        [wastePileMappingAry addObject:@"WastePile:alPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:arPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:asPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:baPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:biPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:cePercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:coPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:cyPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:fiPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:hePercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:laPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:loPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:maPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:spPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:uuPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:wbPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:whPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:wiPercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:yePercent:2:Y::string:"];
        [wastePileMappingAry addObject:@"WastePile:comment:0:Y::string:"];
    }
}

-(NSArray *) getWasteAssessmentTypeMapping{
    return [wasteAssessmentMappingAry copy];
}
-(NSArray *) getWasteStratumMapping{
    return [wasteStratumMappingAry copy];
}
-(NSArray *) getWastePlotMapping{
    return [wastePlotMappingAry copy];
}
-(NSArray *) getWastePieceMapping:(NSString*) assessmnetMethodCode{
    NSMutableArray* pieceMapping = [[NSMutableArray alloc] init];

    for(NSString* element in wastePieceMappingAry){
        
        if([assessmnetMethodCode isEqualToString:@"E"] || [assessmnetMethodCode isEqualToString:@"O"]){
            if([element rangeOfString:@"length"].location != NSNotFound || [element rangeOfString:@"topDiameter"].location != NSNotFound || [element rangeOfString:@"pieceTopEndCode"].location != NSNotFound ||
               [element rangeOfString:@"buttDiameter"].location != NSNotFound || [element rangeOfString:@"lengthDeduction"].location != NSNotFound || [element rangeOfString:@"topDeduction"].location != NSNotFound ||
               [element rangeOfString:@"buttDeduction"].location != NSNotFound || [element rangeOfString:@"pieceButtEndCode"].location != NSNotFound){
                continue;
            }
        }
        if([assessmnetMethodCode isEqualToString:@"O"]){
            if([element rangeOfString:@"estimatedPercent"].location != NSNotFound ){
                continue;
            }
        }else if([assessmnetMethodCode isEqualToString:@"E"]){
            if([element rangeOfString:@"estimatedVolume"].location != NSNotFound || [element rangeOfString:@"estimatedDensity"].location != NSNotFound){
                continue;
            }
        }else{
            if([element rangeOfString:@"estimatedVolume"].location != NSNotFound ||[element rangeOfString:@"estimatedPercent"].location != NSNotFound || [element rangeOfString:@"estimatedDensity"].location != NSNotFound){
                continue;
            }
        }
        
        [pieceMapping addObject:[NSString stringWithString:element]];
    }
    
    return [pieceMapping copy];
}
-(NSArray *) getTimberMarkMapping{
    return [TimberMarkMappingAry copy];
}
-(NSArray *) getStratumPileMapping{
    return [stratumPileMappingAry copy];
}
-(NSArray *) getWastePileMapping{
    return [wastePileMappingAry copy];
}

@end
