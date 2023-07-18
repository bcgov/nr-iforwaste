//
//  XMLMappingDAO.m
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-26.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import "XMLMappingDAO.h"

@implementation XMLMappingDAO {
    
    NSDictionary *xmlMappingDictionary;
    NSMutableArray *wasteAssessmentMappingAry;
    NSMutableArray *wasteStratumMappingAry;
    NSMutableArray *wastePlotMappingAry;
    NSMutableArray *wastePieceMappingAry;
    NSMutableArray *TimberMarkMappingAry;
}

+(XMLMappingDAO *)sharedInstance{
    static XMLMappingDAO *singletonXMLMappingDAO = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        singletonXMLMappingDAO = [[super alloc] init];
    });
    
    return singletonXMLMappingDAO;
}

-(id)init {
    self = [super init];
    
    if(self){
        //custom initialization
        NSError *error;
        
        [self initCodeTable:&error];
    }
    return self;
}


-(void) initCodeTable:(NSError **)error{
    if (xmlMappingDictionary == nil){
        wasteAssessmentMappingAry = [[NSMutableArray alloc] init];
        
        //1. Core Entity Name
        //2. Core Data Field Name
        //3. Core Data Field Data type
        //4. Checked Field Indicator: Y/N
        //5. XML Field Name
        //6. XML Data Type
        //7. XML Format
        //8. XML order - in case we need it
        
        [wasteAssessmentMappingAry addObject:@"Timbermark:benchmark:1:N:benchmarkVolume:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:cruiseArea:1:N:cruiseVolume:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:cutBlockId:0:N:cutBlockID:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:cuttingPermitId:0:N:cuttingPermitID:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:licenceNumber:0:N:licenseNo:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:loggingCompleteDate:3:N:primaryLoggingCompleteDate:date::"];
        [wasteAssessmentMappingAry addObject:@"Timbermark:area:1:N:primaryMarkArea:decimal::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:reportingUnitId:2:N:reportingUnitID:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:returnNumber:2:N:returnNumber:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:surveyDate:3:N:surveyDate:date::"];
        [wasteAssessmentMappingAry addObject:@"Timbermark:timbermark:0:N:timberMark:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:blockMaturityCode:MaturityCode:N:WasteMaturityTypeCode:string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:surveyArea:1:N:wasteNetArea:decimal::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:surveyorLicence:0:N:wasteSurveyorLicence:string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:yearLoggedFrom:2:N:yearLoggedFrom:string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:yearLoggedTo:2:N:yearLoggedTo:string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:blockSiteCode:SiteCode:Y:wasteSiteTypeCode:string:"];

        //extra fields for check values
        [wasteAssessmentMappingAry addObject:@"WasteBlock:wasteAssessmentAreaID:2:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:exempted:0:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:notes:0:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:checkerName:0:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:surveyorName:0:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:position:0:Y::string::"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:professional:0:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:registrationNumber:0:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:regionId:2:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:userCreated:2:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:ratioSamplingEnabled:2:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:blockNumber:0:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:blockStatus:0:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:netArea:1:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:reportingUnit:2:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:location:0:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:blockCheckSiteCode:SiteCode:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:blockCheckMaturityCode:MaturityCode:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:entryDate:3:Y::string:"];
        [wasteAssessmentMappingAry addObject:@"WasteBlock:npNFArea:1:Y::sting:"];
        
        
        wasteStratumMappingAry = [[NSMutableArray alloc] init];
        //xml fields
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumArea:1:N:stratumArea:decimal:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:totalEstimatedVolume:2:N:totalEstimatedVolume:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumAssessmentMethodCode:AssessmentMethodCode:N:wasteAssessmentMethodCode:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumHarvestMethodCode:HarvestMethodCode:N:wasteHarvestMethodCode:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumWasteLevelCode:WasteLevelCode:N:wasteLevelCode:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumPlotSizeCode:PlotSizeCode:N:wastePlotSizeCode:string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumWasteTypeCode:WasteTypeCode:N:wasteTypeCode:string:"];
        
        //extra check fields
        [wasteStratumMappingAry addObject:@"WasteStratum:isSurvey:2:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:notes:0:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:checkTotalEstimatedVolume:2:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumID:2:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumStratumTypeCode:StratumTypeCode:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratumSurveyArea:1:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:checkTotalEstimatedVolume:2:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:stratum:0:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:predictionPlot:2:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:orgPredictionPlot:2:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:measurePlot:2:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:orgMeasurePlot:2:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:n1sample:0:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:n2sample:0:Y::string:"];
        [wasteStratumMappingAry addObject:@"WasteStratum:ratioSamplingLog:0:Y::string:"];
        

        wastePlotMappingAry = [[NSMutableArray alloc] init];
        //xml fields
        [wastePlotMappingAry addObject:@"WastePlot:surveyedMeasurePercent:2:N:measureFactor:string:"];
        [wastePlotMappingAry addObject:@"WastePlot:baseline:0:N:wasteBaseline:string:"];
        [wastePlotMappingAry addObject:@"WastePlot:plotNumber:2:N:wastePlotNumber:string:"];
        [wastePlotMappingAry addObject:@"WastePlot:strip:2:N:wasteStrip:string:"];
        //extra check fields
        [wastePlotMappingAry addObject:@"WastePlot:checkerMeasurePercent:2:Y:plotMultipler:decimal:"];
        [wastePlotMappingAry addObject:@"WastePlot:plotID:2:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:returnNumber:0:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:assistant:0:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:certificateNumber:0:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:notes:0:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:surveyDate:3:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:surveyNetVal:1:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:surveyorName:0:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:weather:0:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:plotShapeCode:ShapeCode:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:plotSizeCode:PlotSizeCode:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:isSurvey:2:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:greenVolume:1:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:dryVolume:1:Y::string:"];
        [wastePlotMappingAry addObject:@"WastePlot:isMeasurePlot:2:Y::string:"];

        
        wastePieceMappingAry = [[NSMutableArray alloc] init];
        //xml fiels
        [wastePieceMappingAry addObject:@"WastePiece:buttDeduction:2:N:buttDeduction:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:buttDiameter:2:N::buttDiameter:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceButtEndCode:ButtEndCode:N:buttEndCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:densityEstimate:1:N:estimatedDensity:decimal:"];
        [wastePieceMappingAry addObject:@"WastePiece:estimatedPercent:1:N:estimatedPercent:decimal:"];
        [wastePieceMappingAry addObject:@"WastePiece:estimatedVolume:1:N:estimatedVolume:decimal:"];
        [wastePieceMappingAry addObject:@"WastePiece:length:2:N:length:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:lengthDeduction:2:N:lengthDeduction:decimal:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceScaleGradeCode:ScaleGradeCode:N:scaleGradeCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceScaleSpeciesCode:ScaleSpeciesCode:N:scaleSpeciesCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:topDeduction:2:N:topDeduction:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:topDiameter:2:N:topDiameter:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceTopEndCode:TopEndCode:N:topEndCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceBorderlineCode:BorderlineCode:N:wasteBorderlineCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceWasteClassCode:WasteClassCode:N:wasteClassCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceCommentCode:CommentCode:N:wasteCommentCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceDecayTypeCode:DecayTypeCode:N:wasteDecayTypeCode:string:"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceMaterialKindCode:MaterialKindCode:N:wasteMaterialKindCode:string:"];

        //extra check fields
        [wastePieceMappingAry addObject:@"WastePiece:pieceNumber:0:Y::"];
        [wastePieceMappingAry addObject:@"WastePiece:checkPieceVolume:1:Y::"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceVolume:1:Y::"];
        [wastePieceMappingAry addObject:@"WastePiece:pieceCheckerStatusCode:CheckerStatusCode:Y::"];
        [wastePieceMappingAry addObject:@"WastePiece:volOverHa:1:Y::"];
        [wastePieceMappingAry addObject:@"WastePiece:isSurvey:2:Y::"];
        [wastePieceMappingAry addObject:@"WastePiece:sortNumber:2:Y::"];
        [wastePieceMappingAry addObject:@"WastePiece:piece:2:Y::"];
        [wastePieceMappingAry addObject:@"WastePiece:notes:0:Y::"];

        //Extra entity

        //Timber Mark
        TimberMarkMappingAry = [[NSMutableArray alloc] init];
        [TimberMarkMappingAry addObject:@"Timebermark:primaryInd:2:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:allSppJWMRF:1:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:orgAllSppJWMRF:1:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:area:1:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:timbermark:0:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:surveyArea:1:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:timbermarkMonetaryReductionFactorCode:MonetaryReductionFactorCode:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:orgWMRF:1:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:coniferWMRF:1:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:xPrice:1:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:yPrice:1:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:hembalPrice:1:Y::"];
        [TimberMarkMappingAry addObject:@"Timebermark:deciduousPrice:1:Y::"];
        
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
    return [wastePieceMappingAry copy];
}
-(NSArray *) getTimberMarkMapping{
    return [TimberMarkMappingAry copy];
}

@end
