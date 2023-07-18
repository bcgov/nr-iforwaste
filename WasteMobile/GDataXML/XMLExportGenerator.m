//
//  XMLExportGenerator.m
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-31.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import "XMLExportGenerator.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "WastePiece.h"
#import "GDataXMLNode.h"
#import "XMLMappingDAO.h"
#import "XMLToESFMappingDAO.h"
#import "Timbermark.h"
#import "MaturityCode.h"
#import "AssessmentMethodCode.h"
#import "WasteLevelCode.h"
#import "PlotSizeCode.h"
#import "WasteTypeCode.h"
#import "ScaleGradeCode.h"
#import "ScaleSpeciesCode.h"
#import "TopEndCode.h"
#import "WasteClassCode.h"
#import "ButtEndCode.h"
#import "CommentCode.h"
#import "DecayTypeCode.h"
#import "MaterialKindCode.h"
#import "BorderLineCode.h"
#import "HarvestMethodCode.h"
#import "CheckerStatusCode.h"
#import "SiteCode+CoreDataClass.h"
#import "StratumTypeCode.h"
#import "ShapeCode.h"
#import "MonetaryReductionFactorCode.h"
#import "Constants.h"
#import "ExportUserData+CoreDataClass.h"
#import "ExportUserDataDAO.h"

@implementation XMLExportGenerator


-(ExportOutcomeCode) generateCutBlockXMLExport:(WasteBlock*) wasteBlock replace:(BOOL)replace type:(ExportTypeCode)type{
    
    NSLog(@"Generate XML Export file");
    
    //[super checkReportFolder];
    //NSError *error = nil;
    
    // Figure out destination name (in public docs dir)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *exportFileName = @"";
    NSString *extension = @"";
    NSString *baseFileName = @"";
    
    switch(type) {
        case IFW:
            baseFileName = @"/RU%@_Block%@_Export%@";
            extension = @".ifw";
            break;
        case XML:
            baseFileName = @"/%@-%@%@";
            extension = @".xml";
            break;
        case EFW:
            baseFileName = @"/RU%@_Block%@_Export%@";
            extension = @".efw";
            break;
        default:
            baseFileName = @"/RU%@_Block%@_Export%@";
            extension = @".xml";
            break;
    }

    exportFileName = [exportFileName stringByAppendingFormat:baseFileName, wasteBlock.reportingUnit, wasteBlock.blockNumber, extension];

    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:exportFileName];

    NSLog(@"XML Export file path %@", filePath);

    
    // Check if file already exists (unless we force the write)
    if ( [[NSFileManager defaultManager] fileExistsAtPath:filePath] && !replace) {
        NSLog(@"File exists already");
        return ExportFailFilenameExist;
    }
    
    // Check if we got WasteBlock && WastePlot
    if(wasteBlock==nil){
        return ExportFailUnknown;
    }
    
    // Declare XML structure elements
    GDataXMLElement *sElement;      //ESF submission
    GDataXMLElement *smElement;     //submissionMetadata
    GDataXMLElement *scElement;     //submissionContent
    GDataXMLElement *wsubElement;   //WasteSubmission
    GDataXMLElement *smpElement;    //submissionMetadataProperty
    GDataXMLElement *smpdElement;   //SubmissionMetadata
    GDataXMLElement *siElement;     //submissionItem
    GDataXMLElement *waElement;     //WasteAssessmentArea
    
    //Set DAO mapping and root element based on output file type
    id mappingDAO;
    if (type == XML) {
        mappingDAO = [XMLToESFMappingDAO sharedInstance];
        ExportUserData *submissionUserData = [ExportUserDataDAO getExportUserData];
        
        //Add submission element
        sElement = [GDataXMLNode elementWithName:@"esf:ESFSubmission"];
        [sElement addNamespace:[GDataXMLNode namespaceWithName:@"esf" stringValue:@"http://www.for.gov.bc.ca/schema/esf"]];
        [sElement addNamespace:[GDataXMLNode namespaceWithName:@"xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
        [sElement addNamespace:[GDataXMLNode namespaceWithName:@"waste" stringValue:@"http://www.for.gov.bc.ca/schema/waste"]];
        [sElement addAttribute:[GDataXMLNode attributeWithName:@"xsi:schemaLocation" stringValue:@"http://www.for.gov.bc.ca/schema/esf "
                                "http://www.for.gov.bc.ca/schema/esf/1/xsd/MOF/esf-submission.xsd "
                                "http://www.for.gov.bc.ca/schema/waste "
                                "http://www.for.gov.bc.ca/schema/waste/5/xsd/MOF/mof-waste.xsd"]];
        //Submission metadata
        smElement = [GDataXMLNode elementWithName:@"esf:submissionMetadata"];
        [smElement addChild: [GDataXMLNode elementWithName:@"esf:emailAddress" stringValue:submissionUserData.emailAddress]];
        [smElement addChild: [GDataXMLNode elementWithName:@"esf:telephoneNumber" stringValue:submissionUserData.telephoneNumber]];
        [sElement addChild: smElement];
        
        //Submission Content
        scElement = [GDataXMLNode elementWithName:@"esf:submissionContent"];
        wsubElement = [GDataXMLNode elementWithName:@"waste:WasteSubmission"];
        [wsubElement addNamespace:[GDataXMLNode namespaceWithName:@"" stringValue:@"http://www.for.gov.bc.ca/schema/waste"]];
        [wsubElement addNamespace:[GDataXMLNode namespaceWithName:@"mof" stringValue:@"http://www.for.gov.bc.ca/schema/base"]];
        [wsubElement addNamespace:[GDataXMLNode namespaceWithName:@"xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
        [wsubElement addAttribute:[GDataXMLNode attributeWithName:@"xsi:schemaLocation" stringValue:@"http://www.for.gov.bc.ca/schema/waste "
                                   "http://www.for.gov.bc.ca/schema/waste/5/xsd/MOF/mof-waste.xsd"]];
        //Submission Metadata
        smpElement = [GDataXMLNode elementWithName:@"submissionMetadataProperty"];
        smpdElement = [GDataXMLNode elementWithName:@"SubmissionMetadata"];
        [smpdElement addChild: [GDataXMLNode elementWithName:@"districtCode"        stringValue:submissionUserData.districtCode]];
        [smpdElement addChild: [GDataXMLNode elementWithName:@"clientCode"          stringValue:submissionUserData.clientCode]];
        [smpdElement addChild: [GDataXMLNode elementWithName:@"clientLocationCode"  stringValue:@"00"]];
        [smpdElement addChild: [GDataXMLNode elementWithName:@"licenseeContact"     stringValue:submissionUserData.licenseeContact]];
        [smpdElement addChild: [GDataXMLNode elementWithName:@"telephoneNumber"     stringValue:submissionUserData.telephoneNumber]];
        [smpdElement addChild: [GDataXMLNode elementWithName:@"emailAddress"        stringValue:submissionUserData.emailAddress]];
        [smpElement addChild: smpdElement];
        
        
        //Add submission metadata to wastesubmission
        [wsubElement addChild: smpElement];
        
        //Build waste assessment
        siElement = [GDataXMLNode elementWithName:@"submissionItem"];
        waElement = [GDataXMLNode elementWithName:@"WasteAssessmentArea"];

    } else {
        mappingDAO = [XMLMappingDAO sharedInstance];
        
        waElement = [GDataXMLNode elementWithName:@"WasteAssessmentArea"];
        
        // set up xml schema information
        [waElement addNamespace:[GDataXMLNode namespaceWithName:@"xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
        [waElement addNamespace:[GDataXMLNode namespaceWithName:@"xsd" stringValue:@"http://www.w3.org/2001/XMLSchema"]];
        [waElement addNamespace:[GDataXMLNode namespaceWithName:@"" stringValue:@"http://www.for.gov.bc.ca/schema/waste"]];
    }
    
    //Find timber mark(s)
    Timbermark *ptm = nil;
    Timbermark *stm = nil;
    for (Timbermark *tm in [wasteBlock.blockTimbermark allObjects]){
        if ([tm.primaryInd intValue] == 1 ){
            ptm = tm;
        }else{
            stm = tm;
        }
    }
    
    //Construct data elements
    for (NSString *ele in [mappingDAO getWasteAssessmentTypeMapping]) {
        NSArray *strAry = [ele componentsSeparatedByString:@":"];
        
        NSString *entityFieldName = strAry[1];
        NSObject *valueObj = nil;
        NSString *valueStr = @"";
        
        if ( [strAry[0] isEqualToString:@"Timbermark"]){
            if(ptm && [ptm valueForKey:entityFieldName]){
                valueObj = [ptm valueForKey:entityFieldName];
            }
            
        }else if([strAry[0] isEqualToString:@"WasteBlock"]){
            valueObj = [wasteBlock valueForKey:entityFieldName];
            
        } else if (type == XML) {
            
            //Workaround for conditional objects
            if ([entityFieldName isEqualToString:@"submitToDistrict"]) {

                valueObj = @"false";
                
            } else if([entityFieldName isEqualToString:@"harvestStatusCode"]){
                // default harvest status code to complete
                valueObj = @"COM";
                
            }else if ([wasteBlock.regionId intValue] == InteriorRegion) {
                
                if ([entityFieldName isEqualToString:@"blockConditionCode"]) {
                    valueObj = @"N";
                    
                } else if ([entityFieldName isEqualToString:@"blockSiteCode"]) {
                    valueObj = [wasteBlock valueForKey:entityFieldName];
                    
                } else {
                    // If not interior, 'submitToDistrict' or member of Timbermark/Wasteblock objects, exclude blockCondition/Site code from XML
                    continue;
                }
            }
        }

        valueStr = [self getObjectValue:valueObj];
        
        if([entityFieldName isEqualToString:@"blockMaturityCode"]){
            if( [valueStr isEqualToString:@"I"]){
                valueStr = @"IMM";
            }else if ([valueStr isEqualToString:@"M"]){
                valueStr= @"MAT";
            }
        }
        
        if(![valueStr isEqualToString:@""] || ([entityFieldName isEqualToString:@"cuttingPermitId"] && [valueStr isEqualToString:@""])){
            GDataXMLElement * subEle = [GDataXMLNode elementWithName: ([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4]) stringValue:valueStr];
            if(subEle){
                [waElement addChild:subEle];
            }
        }
    }

    if( [wasteBlock.blockStratum count] > 0){
        [self addStratumFrom:wasteBlock.blockStratum toElement:&waElement withMapping:mappingDAO forType:type];
        
        //add Timbermark
        if([wasteBlock.blockTimbermark count] >0 ){
            [self addTimbermarkFrom:wasteBlock.blockTimbermark toElement:&waElement withMapping:mappingDAO forType:type];
        }
    }
    
    //Add children to XML root
    GDataXMLDocument *xmlDoc;
    
    if (type == XML) {
        [siElement      addChild:waElement];
        [wsubElement    addChild:siElement];
        [scElement      addChild:wsubElement];
        [sElement       addChild:scElement];
        
        xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:sElement];
        
    } else {
        xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:waElement];
        
    }
    
    NSData *xmlData = xmlDoc.XMLData;

    if(type == EFW){
        // encode it with base64
        xmlData = [xmlData base64EncodedDataWithOptions:0];
    }
    
    [xmlData writeToFile:filePath atomically:YES];

    return ExportSuccessful;
}

- (void) addStratumFrom:(NSSet<WasteStratum *> *) blockStratum toElement:(GDataXMLElement **) waElement withMapping:(id) mappingDAO forType:(ExportTypeCode) type {
    
    for(WasteStratum *ws in blockStratum){
        GDataXMLElement *wsElement = [GDataXMLNode elementWithName:@"WasteStratum"];
        BOOL estimatingVolume = NO;
        BOOL isOcular = NO;
        BOOL isScale = NO;
        BOOL assessingWithACCorDIS = NO;
        
        for(NSString * ele in [mappingDAO getWasteStratumMapping]){
            
            NSArray *strAry = [ele componentsSeparatedByString:@":"];
            NSString *entityFieldName = strAry[1];
            NSString *valueStr = @"";
            NSObject *valueObj = nil;
            
            valueObj = [ws valueForKey:entityFieldName];
            
            if (valueObj){
                valueStr = [self getObjectValue:valueObj];
                
                if (type == XML) {
                    if([entityFieldName isEqualToString:@"stratumStratumTypeCode"]){
                        if([valueStr isEqualToString:@"A"]){
                            valueStr = @"ACC";
                            assessingWithACCorDIS = YES;
                        }else if([valueStr isEqualToString:@"D"]){
                            valueStr = @"DIS";
                            assessingWithACCorDIS = YES;
                        }else if([valueStr isEqualToString:@"S"]){
                            valueStr = @"STR";
                        }else{
                            valueStr = @"";
                        }
                    }else if ([entityFieldName isEqualToString:@"stratumAssessmentMethodCode"]  ){
                        //Skip estimated volume if assessing with method code P (not E, S or O)
                        if([valueStr isEqualToString:@"E"]){
                            estimatingVolume = YES;
                        }else if([valueStr isEqualToString:@"O"]){
                            isOcular = YES;
                        }else if([valueStr isEqualToString:@"S"]){
                            isScale = YES;
                        }
                        
                    } else if ([entityFieldName isEqualToString:@"totalEstimatedVolume"] && !estimatingVolume) {
                        continue;
                        
                    }else if ((isOcular || isScale || estimatingVolume) && [entityFieldName isEqualToString:@"stratumPlotSizeCode"] ){
                        continue;
                    }
                    
                    if (!assessingWithACCorDIS) {
                        //Skip wasteTypeCode, harvestMethodCode, plotSizeCode, and wasteLevelCode if assessmentMethodCode is not P
                        if ([entityFieldName isEqualToString:@"stratumPlotSizeCode"] || [entityFieldName isEqualToString:@"stratumWasteLevelCode"] || [entityFieldName isEqualToString:@"stratumHarvestMethodCode"] || [entityFieldName isEqualToString:@"stratumWasteTypeCode"]) {
                            continue;
                        }
                    }
                }
                
                //Add element
                GDataXMLElement * subEle = [GDataXMLNode elementWithName: ([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4]) stringValue:valueStr];
                if(subEle){
                    [wsElement addChild:subEle];
                }
            }
        }
        
        // add Plot
        if(isScale || isOcular || estimatingVolume) {
            WastePlot* firstPlot =[ws.stratumPlot allObjects][0];
            if( [firstPlot.plotPiece count] >0 ){
                [self addPiecesFrom:firstPlot toElement:&wsElement withMapping:mappingDAO];
            }
        }else{
           if( [ws.stratumPlot count] > 0){
               [self addPlotFrom:ws.stratumPlot toElement:&wsElement withMapping:mappingDAO forType:type];
            }
        }
        [*waElement addChild:wsElement];
        
    }
}

- (void) addTimbermarkFrom:(NSSet<Timbermark *> *) blockTimbermark toElement:(GDataXMLElement **) waElement withMapping:(id) mappingDAO forType:(ExportTypeCode) type {
    
    for(Timbermark *tm in blockTimbermark){
        GDataXMLElement *tmElement = [GDataXMLNode elementWithName:@"TimberMark"];
        if (type != XML && [mappingDAO getTimberMarkMapping] != nil) {
            [self addChildrenTo:&tmElement usingChildren:[mappingDAO getTimberMarkMapping] andEntity:tm];
            [*waElement addChild:tmElement];
        }
        
    }
}

- (void) addPlotFrom:(NSSet<WastePlot *> *) stratumPlot toElement:(GDataXMLElement **)wsElement withMapping:(id) mappingDAO forType:(ExportTypeCode) type{
    
    for(WastePlot *wplot in stratumPlot){
        
        // ignore plot with measure plot "NO" but only for XML, EFW and XML will call this function
        if(type == EFW || !wplot.isMeasurePlot || [wplot.isMeasurePlot intValue] == 1){
            
            GDataXMLElement *wplotElement = [GDataXMLNode elementWithName:@"WastePlot"];
            [self addChildrenTo:&wplotElement usingChildren:[mappingDAO getWastePlotMapping] andEntity: wplot];
            
            //Add pieces
            if( [wplot.plotPiece count] >0 ){
                [self addPiecesFrom:wplot toElement:&wplotElement withMapping:mappingDAO];
            }
            [*wsElement addChild:wplotElement];
        }
    }
}

- (void) addPiecesFrom:(WastePlot *) wplot toElement:(GDataXMLElement **)wplotElement withMapping:(id) mappingDAO {
    
    // store the piece first
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"sortNumber" ascending:YES];
    NSArray* stored_piece = [wplot.plotPiece sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    for (WastePiece *wp in stored_piece){
        
        GDataXMLElement *wpieceElement = [GDataXMLNode elementWithName:@"WastePiece"];
        [self addChildrenTo:&wpieceElement usingChildren:[mappingDAO getWastePieceMapping:wplot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode] andEntity: wp];

        [*wplotElement addChild:wpieceElement];
    }
}

- (void) addChildrenTo:(GDataXMLElement **) parent usingChildren:(NSArray *) items andEntity:(id) blockEntity {
    
    for(NSString * ele in items){
        
        NSArray *strAry = [ele componentsSeparatedByString:@":"];
        NSString *entityFieldName = strAry[1];
        NSString *valueStr = @"";
        NSObject *valueObj =[blockEntity valueForKey:entityFieldName];
        
        if(valueObj){
            valueStr = [self getObjectValue:valueObj];
            if( ![valueStr isEqualToString:@""]){
                GDataXMLElement * subEle = [GDataXMLNode elementWithName: ([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4]) stringValue:valueStr];
                if(subEle){
                    [*parent addChild:subEle];
                }
            }
        }
    }
}

- (NSString *) getObjectValue:(NSObject *)valueObj {
    NSString *valueStr = @"";
    if(valueObj){
        if([valueObj isKindOfClass:[NSDecimalNumber class]]){
            if(!isnan([(NSDecimalNumber *)valueObj doubleValue])){
                valueStr = [(NSDecimalNumber *)valueObj stringValue];
            }
        }else if([valueObj isKindOfClass:[NSNumber class]]){
            if(!isnan([(NSNumber *) valueObj doubleValue])){
                valueStr = [(NSNumber *) valueObj stringValue];
            }
        }else if([valueObj isKindOfClass:[NSString class]]){
            valueStr = (NSString *)valueObj;
        }else if([valueObj isKindOfClass:[NSDate class]]){
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            valueStr = [dateFormat stringFromDate:(NSDate *) valueObj];
        }else if([valueObj isKindOfClass:[SiteCode class]]){
            valueStr = [(SiteCode *) valueObj siteCode] ;
        }else if([valueObj isKindOfClass:[MaturityCode class]]){
            valueStr = [(MaturityCode *) valueObj maturityCode] ;
        }else if([valueObj isKindOfClass:[AssessmentMethodCode class]]){
            valueStr = [(AssessmentMethodCode *) valueObj assessmentMethodCode];
        }else if([valueObj isKindOfClass:[PlotSizeCode class]]){
            valueStr = [(PlotSizeCode *) valueObj plotSizeCode];
        }else if([valueObj isKindOfClass:[HarvestMethodCode class]]){
            valueStr = [(HarvestMethodCode *) valueObj harvestMethodCode];
        }else if([valueObj isKindOfClass:[WasteLevelCode class]]){
            valueStr = [(WasteLevelCode *) valueObj wasteLevelCode];
        }else if([valueObj isKindOfClass:[WasteTypeCode class]]){
            valueStr = [(WasteTypeCode *) valueObj wasteTypeCode];
        }else if([valueObj isKindOfClass:[ButtEndCode class]]){
            valueStr = [(ButtEndCode *) valueObj buttEndCode];
        }else if([valueObj isKindOfClass:[TopEndCode class]]){
            valueStr = [(TopEndCode *) valueObj topEndCode];
        }else if([valueObj isKindOfClass:[WasteClassCode class]]){
            valueStr = [(WasteClassCode *) valueObj wasteClassCode];
        }else if([valueObj isKindOfClass:[BorderlineCode class]]){
            valueStr = [(BorderlineCode *) valueObj borderlineCode];
        }else if([valueObj isKindOfClass:[CommentCode class]]){
            valueStr = [(CommentCode *) valueObj commentCode];
        }else if([valueObj isKindOfClass:[DecayTypeCode class]]){
            valueStr = [(DecayTypeCode *) valueObj decayTypeCode];
        }else if([valueObj isKindOfClass:[MaterialKindCode class]]){
            valueStr = [(MaterialKindCode *) valueObj materialKindCode];
        }else if([valueObj isKindOfClass:[ScaleGradeCode class]]){
            valueStr = [(ScaleGradeCode *) valueObj scaleGradeCode];
        }else if([valueObj isKindOfClass:[ScaleSpeciesCode class]]){
            valueStr = [(ScaleSpeciesCode *) valueObj scaleSpeciesCode];
        }else if([valueObj isKindOfClass:[CheckerStatusCode class]]){
            valueStr = [(CheckerStatusCode *) valueObj checkerStatusCode];
        }else if([valueObj isKindOfClass:[StratumTypeCode class]]){
            valueStr = [(StratumTypeCode *) valueObj stratumTypeCode];
        }else if([valueObj isKindOfClass:[ShapeCode class]]){
            valueStr = [(ShapeCode *) valueObj shapeCode];
        }else if([valueObj isKindOfClass:[MonetaryReductionFactorCode class]]) {
            valueStr = [(MonetaryReductionFactorCode *) valueObj monetaryReductionFactorCode];
        }
    }
    return [valueStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
@end
