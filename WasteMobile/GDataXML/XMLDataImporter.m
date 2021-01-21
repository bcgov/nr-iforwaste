//
//  XMLDataImporter.m
//  WasteMobile
//
//  Created by Jack Wong on 2016-11-02.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import "XMLDataImporter.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "WastePiece.h"
#import "GDataXMLNode.h"
#import "XMLMappingDAO.h"
#import "WasteBlockDAO.h"
#import "CodeDAO.h"
#import "WasteCalculator.h"
#import "Timbermark.h"
#import "StratumPile+CoreDataClass.h"
#import "WastePile+CoreDataClass.h"
#import "AggregateCutblock+CoreDataClass.h"

@implementation XMLDataImporter

/*
 main entities in xml 
 <WasteAssessmentArea>
     <WasteStratum>
        <WastePlot>
            <WastePiece/>
            ...
        </WastePlot>
        ...
     </WasteStratum>
        ...
     <TimberMark></TimberMark>
 </WasteAssessmentArea>
 */

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

-(ImportOutcomeCode) ImportDataByFileName:(NSString *)fileName wasteBlock:(WasteBlock **)wb ignoreExisting:(BOOL)igExist{
    return [self ParseData:fileName data:nil wasteBlock:wb ignoreExisting:igExist];
}

-(ImportOutcomeCode) ImportDataByURL:(NSURL*)url wasteBlock:(WasteBlock **)wb ignoreExisting:(BOOL)igExist{
    return [self ParseData:[url path] data:[NSData dataWithContentsOfURL:url]  wasteBlock:wb ignoreExisting:igExist];
}

-(ImportOutcomeCode) ParseData:(NSString *) fileName data:(NSData *)data wasteBlock:(WasteBlock **)wb ignoreExisting:(BOOL)igExist{
 
    NSData *xmlData = nil;
    if(data){
        xmlData = data;
    }else{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@""];
        NSString *filePath =[NSString stringWithFormat:@"%@/%@", dataPath, fileName];

        xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    }
    
    if([[[fileName pathExtension] lowercaseString] isEqualToString:@"efw"]){
        //decode the data
        xmlData = [[NSData alloc] initWithBase64EncodedString: [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] options:0];
    }
    
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    //NSString *testing = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    if(error){
        NSLog(@"Error when loading xml data to GDataXMLDocument : %@", error);
    }

    NSArray *userCreated = [doc.rootElement elementsForName:@"userCreated"];
    if ([userCreated count] > 0 && [[userCreated[0] stringValue] isEqualToString:@"1"] ) {
        //for new block, check if the cut block already exist in iPad by checking RU, Cut Block, Licence, cutting permit
        NSArray *cbId = [doc.rootElement elementsForName:@"cutBlockID"];
        NSArray *ruId = [doc.rootElement elementsForName:@"reportingUnit"];
        NSArray *license = [doc.rootElement elementsForName:@"licenseNo"];
        NSArray *cpId = [doc.rootElement elementsForName:@"cuttingPermitID"];
        NSArray *regionId = [doc.rootElement elementsForName:@"regionId"];
        NSString *cbId_str = [cbId count] > 0 ? [cbId[0] stringValue] : @"";
        NSString *ruId_str = [ruId count] > 0 ? [ruId[0] stringValue ]: @"";
        NSString *license_str = [license count] > 0 ? [license[0] stringValue]: @"";
        NSString *cpId_str = [cpId count] > 0 ? [cpId[0] stringValue ]: @"";

        if (!igExist){
            WasteBlock *found = [WasteBlockDAO getWasteBlockByRU:ruId_str cutBlockId:cbId_str license:license_str cutPermit:cpId_str ];
            if( found){
                if([[found regionId] intValue] != [[(GDataXMLElement *)[regionId objectAtIndex:0] stringValue] intValue]){
                    return ImportFailRegionIDExist;
                }else{
                    return ImportFailCutBlockExist;
                }
            }
        }
        
    }else{
        //for downloaded block, check if the cut block already exist in iPad by checking wasteAssessmentAreaID
        NSArray *wsaId = [doc.rootElement elementsForName:@"wasteAssessmentAreaID"];
        if([wsaId count] > 0 ){
            if( [WasteBlockDAO getWasteBlockByAssessmentAreaId:[wsaId[0] stringValue] ]){
                return ImportFailCutBlockExist;
            }
        }
    }
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    //assume only have one waste block data per file
    //get the region ID first
    NSArray *regionId = [doc.rootElement elementsForName:@"regionId"];
    NSArray *isAggregate = [doc.rootElement elementsForName:@"isAggregate"];

    *wb = [WasteBlockDAO createEmptyCutBlock:[[(GDataXMLElement *)[regionId objectAtIndex:0] stringValue] intValue] ratioSample:NO isAggregate:[[(GDataXMLElement *)[isAggregate objectAtIndex:0] stringValue] intValue]];
    
    Timbermark *ptm = [WasteBlockDAO createEmptyTimbermark];
    
    NSManagedObject *targetObj = nil;
    
    for( NSString *ele in [[XMLMappingDAO sharedInstance] getWasteAssessmentTypeMapping]){
        // for each mapping record, find the element and value in xml file
        NSArray *strAry = [ele componentsSeparatedByString:@":"];
        
        NSArray *att = [doc.rootElement elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];
        if([att count] > 0 ){
            NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
            
            if([strAry[0] isEqualToString:@"Timbermark"]){
                targetObj = (NSManagedObject *) ptm;
            }else if([strAry[0] isEqualToString:@"WasteBlock"]){
                targetObj = (NSManagedObject *) *wb;
            }
            if([strAry[1] isEqualToString:@"blockMaturityCode"]){
                if([attStrValue isEqualToString:@"IMM"]){
                    attStrValue = @"I";
                }else if([attStrValue isEqualToString:@"MAT"]){
                    attStrValue = @"M";
                }
            }
            [self fillManagedObject:(NSManagedObject *)targetObj valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
        }else{
            //some field need to set to nil
            if([strAry[2] isEqualToString:@"2"]){
                [(NSManagedObject *)*wb setValue:nil forKey:strAry[1]];
            }
        }
    }
    
    NSArray *stratums = [doc.rootElement elementsForName:@"WasteStratum"];
    if (stratums.count > 0){
        for(GDataXMLElement *stra in stratums){
            
            WasteStratum *ws = [WasteBlockDAO createEmptyStratum];
            
            for( NSString *ele in [[XMLMappingDAO sharedInstance] getWasteStratumMapping]){
                // for each mapping record, find the element and value in xml file
                NSArray *strAry = [ele componentsSeparatedByString:@":"];
                
                NSArray *att = [stra elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];
                if([att count] > 0 ){
                    NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
                    
                    [self fillManagedObject:(NSManagedObject *)ws valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
                }else{
                    //some field need to set to nil
                    if([strAry[2] isEqualToString:@"2"]){
                        [(NSManagedObject *)ws setValue:nil forKey:strAry[1]];
                    }
                }
            }
            
            //get plot
            NSArray *plots = [stra elementsForName:@"WastePlot"];
            for(GDataXMLElement *plot in plots){
                WastePlot *wp =[WasteBlockDAO createEmptyPlot];
                
                for( NSString *ele in [[XMLMappingDAO sharedInstance] getWastePlotMapping]){
                    // for each mapping record, find the element and value in xml file
                    NSArray *strAry = [ele componentsSeparatedByString:@":"];
                    NSArray *att = [plot elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];

                    if([att count] > 0 ){
                        NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
                        
                        [self fillManagedObject:(NSManagedObject *)wp valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
                    }else{
                        //some field need to set to nil
                        if([strAry[2] isEqualToString:@"2"]){
                            [(NSManagedObject *)wp setValue:nil forKey:strAry[1]];
                        }
                    }
                }
                
                //get pieces
                NSArray *pieces = [plot elementsForName:@"WastePiece"];
                for(GDataXMLElement *piece in pieces){
                    WastePiece *wpi =[WasteBlockDAO createEmptyPiece];
                    
                    for( NSString *ele in [[XMLMappingDAO sharedInstance] getWastePieceMapping:nil]){
                        // for each mapping record, find the element and value in xml file
                        NSArray *strAry = [ele componentsSeparatedByString:@":"];
                        
                        NSArray *att = [piece elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];
                        if([att count] > 0 ){
                            NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
                            
                            [self fillManagedObject:(NSManagedObject *)wpi valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
                        }else{
                            //some field need to set to nil
                            if([strAry[2] isEqualToString:@"2"]){
                                [(NSManagedObject *)wpi setValue:nil forKey:strAry[1]];
                            }
                        }
                    }
                    [wp addPlotPieceObject:wpi];
                }
                //TODO: remove after
                //wp.isMeasurePlot = nil;
                [ws addStratumPlotObject:wp];
            }
            //get pile
            if([[(GDataXMLElement *)[isAggregate objectAtIndex:0] stringValue] intValue] == [[NSNumber numberWithBool:FALSE] intValue] ){
                NSArray *stratumPile = [stra elementsForName:@"StratumPile"];
                for(GDataXMLElement *strPile in stratumPile){
                    StratumPile *sp =[WasteBlockDAO createEmptyStratumPile];
                    
                    for( NSString *ele in [[XMLMappingDAO sharedInstance] getStratumPileMapping]){
                        // for each mapping record, find the element and value in xml file
                        NSArray *strAry = [ele componentsSeparatedByString:@":"];
                        NSArray *att = [strPile elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];

                        if([att count] > 0 ){
                            NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
                            
                            [self fillManagedObject:(NSManagedObject *)sp valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
                        }else{
                            //some field need to set to nil
                            if([strAry[2] isEqualToString:@"2"]){
                                [(NSManagedObject *)sp setValue:nil forKey:strAry[1]];
                            }
                        }
                    }
                    
                    //get pile
                    NSArray *piles = [strPile elementsForName:@"WastePile"];
                    for(GDataXMLElement *pile in piles){
                        WastePile *wpi =[WasteBlockDAO createEmptyWastePile];
                        
                        for( NSString *ele in [[XMLMappingDAO sharedInstance] getWastePileMapping]){
                            // for each mapping record, find the element and value in xml file
                            NSArray *strAry = [ele componentsSeparatedByString:@":"];
                            
                            NSArray *att = [pile elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];
                            if([att count] > 0 ){
                                NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
                                
                                [self fillManagedObject:(NSManagedObject *)wpi valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
                            }else{
                                //some field need to set to nil
                                if([strAry[2] isEqualToString:@"2"]){
                                    [(NSManagedObject *)wpi setValue:nil forKey:strAry[1]];
                                }
                            }
                        }
                        [sp addPileDataObject:wpi];
                    }
                    [ws setStrPile:sp];
                }
            }else if([[(GDataXMLElement *)[isAggregate objectAtIndex:0] stringValue] intValue] == [[NSNumber numberWithBool:TRUE] intValue] ){
                NSArray *aggregateCutblock = [stra elementsForName:@"AggregateCutblock"];
                for(GDataXMLElement *aggCB in aggregateCutblock){
                    AggregateCutblock *aggcb =[WasteBlockDAO createEmptyAggregateCutblock];
                    
                    for( NSString *ele in [[XMLMappingDAO sharedInstance] getAggregateCutblockMapping]){
                        // for each mapping record, find the element and value in xml file
                        NSArray *strAry = [ele componentsSeparatedByString:@":"];
                        NSArray *att = [aggCB elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];

                        if([att count] > 0 ){
                            NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
                            
                            [self fillManagedObject:(NSManagedObject *)aggcb valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
                        }else{
                            //some field need to set to nil
                            if([strAry[2] isEqualToString:@"2"]){
                                [(NSManagedObject *)aggcb setValue:nil forKey:strAry[1]];
                            }
                        }
                    }
                
                    NSArray *stratumPile = [aggCB elementsForName:@"StratumPile"];
                    for(GDataXMLElement *strPile in stratumPile){
                        StratumPile *sp =[WasteBlockDAO createEmptyStratumPile];
                        
                        for( NSString *ele in [[XMLMappingDAO sharedInstance] getStratumPileMapping]){
                            // for each mapping record, find the element and value in xml file
                            NSArray *strAry = [ele componentsSeparatedByString:@":"];
                            NSArray *att = [strPile elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];

                            if([att count] > 0 ){
                                NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
                                
                                [self fillManagedObject:(NSManagedObject *)sp valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
                            }else{
                                //some field need to set to nil
                                if([strAry[2] isEqualToString:@"2"]){
                                    [(NSManagedObject *)sp setValue:nil forKey:strAry[1]];
                                }
                            }
                        }
                        
                        //get pile
                        NSArray *piles = [strPile elementsForName:@"WastePile"];
                        for(GDataXMLElement *pile in piles){
                            WastePile *wpi =[WasteBlockDAO createEmptyWastePile];
                            
                            for( NSString *ele in [[XMLMappingDAO sharedInstance] getWastePileMapping]){
                                // for each mapping record, find the element and value in xml file
                                NSArray *strAry = [ele componentsSeparatedByString:@":"];
                                
                                NSArray *att = [pile elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];
                                if([att count] > 0 ){
                                    NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
                                    
                                    [self fillManagedObject:(NSManagedObject *)wpi valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
                                }else{
                                    //some field need to set to nil
                                    if([strAry[2] isEqualToString:@"2"]){
                                        [(NSManagedObject *)wpi setValue:nil forKey:strAry[1]];
                                    }
                                }
                            }
                            [sp addPileDataObject:wpi];
                        }
                        [aggcb setAggPile:sp];
                    }
                    [ws addStratumAggObject:aggcb];
                }
            }
            ///////////////////////////////
            [*wb addBlockStratumObject:ws];
        }
    }
    
    NSArray *tms = [doc.rootElement elementsForName:@"TimberMark"];
    for(GDataXMLElement *tm_ele in tms){
        Timbermark *tm =[WasteBlockDAO createEmptyTimbermark];
        
        for( NSString *ele in [[XMLMappingDAO sharedInstance] getTimberMarkMapping]){
            // for each mapping record, find the element and value in xml file
            NSArray *strAry = [ele componentsSeparatedByString:@":"];
            
            NSArray *att = [tm_ele elementsForName:([strAry[4] isEqualToString:@""] ? strAry[1] :strAry[4])];
            if([att count] > 0 ){
                NSString *attStrValue = [(GDataXMLElement *)att[0] stringValue];
                
                [self fillManagedObject:(NSManagedObject *)tm valueString:attStrValue dataTypeString:strAry[2] fieldName:strAry[1]];
            }
        }
        [*wb addBlockTimbermarkObject:tm];
    }
    
    if([(*wb).userCreated intValue] == 1){
        //for new cut block, override the assessment area id in case duplicate in current ipad
        (*wb).wasteAssessmentAreaID = [WasteBlockDAO GetNextAssessmentAreaId];
    }


    //for testing - append text to the cut block name for testing
    //wb.wasteAssessmentAreaID = [[NSNumber alloc] initWithInt:[wb.wasteAssessmentAreaID  intValue] + 1 ];
    //wb.cutBlockId = [NSString stringWithFormat:@"%@-%@", wb.cutBlockId, @"E" ];
    //wb.blockNumber = [NSString stringWithFormat:@"%@-%@", wb.blockNumber, @"E" ];
    
    //do the calculation
    [WasteCalculator calculateWMRF:*wb  updateOriginal:[(*wb).userCreated intValue] == 1];
    [WasteCalculator calculateRate:*wb];
    [WasteCalculator calculatePiecesValue:*wb];
    if([(*wb).userCreated intValue] ==1){
        [WasteCalculator calculateEFWStat:*wb];
    }
    
    // save the whole cut block
    NSManagedObjectContext *context = [self managedObjectContext];
    [context save:&error];
    
    if( error != nil){
        NSLog(@" Error when saving waste block into Core Data: %@", error);
        return ImportFailOnSaveWastBlock;
    }
    
    //for testing, compare the imported object with the original object
    //[self compare:wb otherWasteBlock:[WasteBlockDAO getWasteBlockByAssessmentAreaId:[NSString stringWithFormat:@"%d", [wb.wasteAssessmentAreaID intValue] - 1]]];
    
    return ImportSuccessful;
    //}
    //return nil;
}

-(void) fillManagedObject:(NSManagedObject *) mobj valueString:(NSString *)valueString dataTypeString:(NSString *)dataTypeString fieldName:(NSString *)fieldName{

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    if([dataTypeString rangeOfString:@"Code"].location == NSNotFound){
        switch ([dataTypeString intValue]){
            case DTString:
                [mobj setValue:[[valueString stringByReplacingOccurrencesOfString:@"\n" withString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:fieldName];
                break;
            case DTDecimalNumber:
                [mobj setValue:[[NSDecimalNumber alloc] initWithString:valueString] forKey:fieldName];
                break;
            case DTNumber:
                [mobj setValue:[[NSNumber alloc] initWithInt:[valueString intValue]] forKey:fieldName];
                break;
            case DTDate:
                [mobj setValue:[df dateFromString:valueString] forKey:fieldName];
                break;
        }
    }else{
        //for code
        [mobj setValue:[[CodeDAO sharedInstance] getCodeByNameCode:dataTypeString code:valueString] forKey:fieldName];
    }
}

//test the object field by field
-(BOOL)compare:(WasteBlock *) new_wb otherWasteBlock:(WasteBlock *) org_wb
{
    BOOL result = NO;
    
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([new_wb class], &numberOfProperties);
    
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];

        if ([name rangeOfString:@"Stratum"].location == NSNotFound && [name rangeOfString:@"Timber"].location == NSNotFound){
            if(![[new_wb valueForKey:name] isEqual:[org_wb valueForKey:name]]){
                //NSLog(@"Block Field : %@ not match", name);
                NSLog(@"Block Field : %@ not match - Org: %@ vs Imp: %@", name, [org_wb valueForKey:name], [new_wb valueForKey:name]);
            }else{
                //NSLog(@"Field : %@ matches", name);
                //NSLog(@"Field : %@ matches - Org: %@ vs Imp: %@", name, [org_wb valueForKey:name], [new_wb valueForKey:name]);
            }
        }
        
        //NSLog(@"Transfer property: %@, value: %@", name, [wbDto valueForKey:name]);
        
    }
    
    //compare stratums
    for(WasteStratum *org_ws in [org_wb.blockStratum allObjects]){
        BOOL ws_found = NO;
        for(WasteStratum *new_ws in [new_wb.blockStratum allObjects]){
            if([[org_ws.stratumID stringValue] isEqualToString:[new_ws.stratumID stringValue]]){
                ws_found = YES;

                numberOfProperties = 0;
                propertyArray = class_copyPropertyList([new_ws class], &numberOfProperties);
                
                for (NSUInteger i = 0; i < numberOfProperties; i++)
                {
                    objc_property_t property = propertyArray[i];
                    NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
                    if ([name rangeOfString:@"Plot"].location == NSNotFound && [name rangeOfString:@"stratumBlock"].location == NSNotFound){
                        if(![[new_ws valueForKey:name] isEqual:[org_ws valueForKey:name]]){
                            //NSLog(@"Stratum Field : %@ not match", name);
                            NSLog(@"Stratum Field : %@ not match - Org: %@ vs Imp: %@", name, [org_ws valueForKey:name], [new_ws valueForKey:name]);
                        }else{
                            //NSLog(@"Stratum Field : %@ matches", name);
                            //NSLog(@"Field : %@ matches - Org: %@ vs Imp: %@", name, [org_ws valueForKey:name], [new_ws valueForKey:name]);
                        }
                    }
                }
                
                //compare plots
                for(WastePlot *org_plot in [org_ws.stratumPlot allObjects]){
                    BOOL wplot_found = NO;
                    for(WastePlot *new_plot in [new_ws.stratumPlot allObjects]) {
                        if([[org_plot.plotNumber stringValue] isEqualToString:[new_plot.plotNumber stringValue]]){
                            wplot_found = YES;
                            
                            numberOfProperties = 0;
                            propertyArray = class_copyPropertyList([new_plot class], &numberOfProperties);
                            
                            for (NSUInteger i = 0; i < numberOfProperties; i++)
                            {
                                objc_property_t property = propertyArray[i];
                                NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
                                if ([name rangeOfString:@"Piece"].location == NSNotFound && [name rangeOfString:@"plotStratum"].location == NSNotFound){
                                    if(![[new_plot valueForKey:name] isEqual:[org_plot valueForKey:name]]){
                                        //NSLog(@"Plot Field : %@ not match", name);
                                        NSLog(@"Plot Field : %@ not match - Org: %@ vs Imp: %@", name, [org_plot valueForKey:name], [new_plot valueForKey:name]);
                                    }else{
                                        //NSLog(@"Plot Field : %@ matches", name);
                                        //NSLog(@"Field : %@ matches - Org: %@ vs Imp: %@", name, [org_plot valueForKey:name], [new_plot valueForKey:name]);
                                    }
                                }
                            }
                            
                            //compare pieces
                            for(WastePiece *org_piece in [org_plot.plotPiece allObjects]){
                                BOOL wpiece_found = NO;
                                for(WastePiece *new_piece in [new_plot.plotPiece allObjects]) {
                                    if([org_piece.pieceNumber isEqualToString:new_piece.pieceNumber]){
                                        wpiece_found = YES;
                                        
                                        numberOfProperties = 0;
                                        propertyArray = class_copyPropertyList([new_piece class], &numberOfProperties);
                                        
                                        for (NSUInteger i = 0; i < numberOfProperties; i++)
                                        {
                                            objc_property_t property = propertyArray[i];
                                            NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
                                            if ([name rangeOfString:@"piecePlot"].location == NSNotFound){
                                                if(![[new_piece valueForKey:name] isEqual:[org_piece valueForKey:name]]){
                                                    //NSLog(@"Piece Field : %@ not match", name);
                                                    NSLog(@"Piece Field : %@ not match - Org: %@ vs Imp: %@", name, [org_piece valueForKey:name], [new_piece valueForKey:name]);
                                                }else{
                                                    //NSLog(@"Piece Field : %@ matches", name);
                                                    //NSLog(@"Field : %@ matches - Org: %@ vs Imp: %@", name, [org_piece valueForKey:name], [new_piece valueForKey:name]);
                                                }
                                            }
                                        }
                                    }
                                }
                                if(! wpiece_found){
                                    NSLog(@" Org plot Not found : stratum-plot number-piece number=%@-%@-%@", [org_ws.stratumID stringValue], [org_plot.plotNumber stringValue], org_piece.pieceNumber);
                                }
                            }
                        }
                    }
                    if(! wplot_found){
                        NSLog(@" Org plot Not found : stratum-plot number=%@-%@ ", [org_ws.stratumID stringValue], [org_plot.plotNumber stringValue]);
                    }
                }
            }
        }
        if(! ws_found){
            NSLog(@" Org Stratum Not found : ID=%@ ", [org_ws.stratumID stringValue]);
        }
    }
    
    for(Timbermark *org_tm in [org_wb.blockTimbermark allObjects]){
        BOOL tm_found = NO;
        for(Timbermark *new_tm in [new_wb.blockTimbermark allObjects]) {
            if([org_tm.timbermark isEqualToString:new_tm.timbermark]){
                tm_found = YES;
                
                numberOfProperties = 0;
                propertyArray = class_copyPropertyList([new_tm class], &numberOfProperties);
                
                for (NSUInteger i = 0; i < numberOfProperties; i++)
                {
                    objc_property_t property = propertyArray[i];
                    NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
                    if ([name rangeOfString:@"Block"].location == NSNotFound){
                        if(![[new_tm valueForKey:name] isEqual:[org_tm valueForKey:name]]){
                            //NSLog(@"Piece Field : %@ not match", name);
                            NSLog(@"Timbermark Field : %@ not match - Org: %@ vs Imp: %@", name, [org_tm valueForKey:name], [new_tm valueForKey:name]);
                        }else{
                            //NSLog(@"Piece Field : %@ matches", name);
                            //NSLog(@"Field : %@ matches - Org: %@ vs Imp: %@", name, [org_piece valueForKey:name], [new_piece valueForKey:name]);
                        }
                    }
                }
            }
        }
        if(! tm_found){
            NSLog(@" Org Timbermark Not found : %@", org_tm.timbermark);
        }
    }

    return result;
}
@end
