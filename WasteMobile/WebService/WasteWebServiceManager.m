//
//  WasteWebServiceManager.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-25.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "WasteWebServiceManager.h"
#import "WasteCalculator.h"

#import "SearchResultDTOAdaptor.h"
#import "WasteBlockDTOAdaptor.h"
#import "TimbermarkDTOAdaptor.h"
#import "WasteStratumDTOAdaptor.h"
#import "WastePlotDTOAdaptor.h"
#import "WastePieceDTOAdaptor.h"

#import "WasteBlockDTO.h"
#import "TimbermarkDTO.h"
#import "WasteStratumDTO.h"
#import "WastePlotDTO.h"
#import "WastePieceDTO.h"

#import "WasteBlock.h"
#import "Timbermark.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "WastePiece.h"
#import "CodeDAO.h"
#import "MaturityCode.h"
#import "SnowCode.h"
#import "PlotSizeCode.h"
#import "WasteTypeCode.h"
#import "AssessmentMethodCode.h"
#import "StratumTypeCode.h"
#import "AssessmentMethodCode.h"
#import "SiteCode+CoreDataClass.h"
#import "Constants.h"

#define SEARCH_WS_SUFFIX @"%@cutBlockByReportingUnit/%@"
#define CUTBLOCK_WS_SUFFIX @"%@cutBlockByCutBlockId/%@"
#define TIMBERMARK_WS_SUFFIX @"%@timberMarksByCutBlockId/%@"
#define STRATUM_WS_SUFFIX @"%@strataByCutBlockId/%@"
#define PLOT_WS_SUFFIX @"%@plotsByStratumId/%@"
#define PIECE_BY_PLOT_WS_SUFFIX @"%@piecesByPlotId/%@"
#define PIECE_BY_STRATUM_WS_SUFFIX @"%@piecesByStratumId/%@"


@implementation WasteWebServiceManager

/*
-(void)searchCutBlock:(NSNumber *)reportingUnitNumber error:(NSError **)error{
    NSString *urlAsString = [NSString stringWithFormat:SEARCH_WSURL_DEV, reportingUnitNumber];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    
        if (error != nil){
            [self.delegate fetchingSearchResultFailed:error];
        }else{
            [self.delegate receivedSearchResultJSON:data];
        }
    }];
}
*/
+ (NSString *) getWSURLBASE{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteWebServiceEndPoint"];
}

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}


-(NSArray *) searchCutBlock:(NSNumber *)reportingUnitNumber{
    

    NSString *urlAsString = [NSString stringWithFormat:SEARCH_WS_SUFFIX, [WasteWebServiceManager getWSURLBASE], reportingUnitNumber];
    NSLog(@"WebService URL: %@", urlAsString);
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
   
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSArray *result = nil;
    
    if (error != nil){
        NSLog(@"Error when call the web service: %@", error);

    }else{

        result = [SearchResultDTOAdaptor searchResultDTOFromJSON:responseData error:&error ];
        if (error != nil){
            NSLog(@"Error when transforming JSON data: %@", error);
        }
    }
    
    return result;

}

-(void) downloadCutBlock:(NSString *)wasteAssessmentAreaId{
    
    //start a new thread to download the cut block data
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSError *error;
        WasteBlock *wb;
        
        @try {
            NSString *wsBase = [WasteWebServiceManager getWSURLBASE];
            
            // call web service for cut block
            NSString *urlAsString = [NSString stringWithFormat:CUTBLOCK_WS_SUFFIX, wsBase, wasteAssessmentAreaId];
            NSLog(@"WebService URL for cut block: %@", urlAsString);
            
            NSURL *url = [[NSURL alloc] initWithString:urlAsString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            NSURLResponse *response;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (error != nil){
                NSLog(@"Error when getting cut block: %@", error);
            }

            NSArray *wbAry =[WasteBlockDTOAdaptor wasteBlockDTOFromJSON:responseData error:&error];
            NSLog(@"block data: %lu", (unsigned long)wbAry.count);
            
            wb = [self createCutBlock:wbAry[0]];
            
            //default the check maturity & site code to the original
            wb.blockCheckMaturityCode = wb.blockMaturityCode;
            wb.blockCheckSiteCode = wb.blockSiteCode;
            
            //set the region - Because the web service is not working yet
            if(wb.blockMaturityCode){
                //assume if maturity code is set, it is coast
                wb.regionId = [[NSNumber alloc] initWithInt:CoastRegion];
            }else{
                //otherise interior
                wb.regionId = [[NSNumber alloc] initWithInt:InteriorRegion];
            }
            

            //call web service for timbermark
            urlAsString = [NSString stringWithFormat:TIMBERMARK_WS_SUFFIX, wsBase, wasteAssessmentAreaId];
            NSLog(@"WebService URL for timbermark: %@", urlAsString);

            url = [[NSURL alloc] initWithString:urlAsString];
            request = [NSMutableURLRequest requestWithURL:url];
            
            responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

            if (error != nil){
                NSLog(@"Error when getting timbermark: %@", error);
            }

            NSArray *tmAry = [TimbermarkDTOAdaptor timbermarkDTOFromJSON:responseData error:&error];
            
            for(TimbermarkDTO *tmDto in tmAry){
                Timbermark *tm = [self createTimbermark:tmDto];
                
                //set the default value for primary timbermark
                //if ([tm.primaryInd intValue] == 1 ){
                    //default to use survey volume
                tm.timbermarkMonetaryReductionFactorCode = (MonetaryReductionFactorCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"monetaryReductionFactorCode" code:@"A"];
                
                //set benchmark based on cut block maturity
                if(wb.blockMaturityCode){
                    if ([wb.blockMaturityCode.maturityCode isEqualToString:@"I"]){
                        //for immature
                        tm.benchmark = [[NSDecimalNumber alloc] initWithFloat:10.0];
                    }else if([wb.blockMaturityCode.maturityCode isEqualToString:@"M"]){
                        // for mature
                        tm.benchmark = [[NSDecimalNumber alloc] initWithFloat:35.0];
                    }
                    tm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:1.0];
                }else if(wb.blockSiteCode){
                    if ([wb.blockSiteCode.siteCode isEqualToString:@"DB"]){
                        // for site code Dry zone
                        tm.benchmark = [[NSDecimalNumber alloc] initWithFloat:4.0];
                    }else if ([wb.blockSiteCode.siteCode isEqualToString:@"TZ"]){
                        // for site code Transition
                        tm.benchmark = [[NSDecimalNumber alloc] initWithFloat:10.0];
                    }else if([wb.blockSiteCode.siteCode isEqualToString:@"WB"]){
                        // for site code wet zone
                        tm.benchmark = [[NSDecimalNumber alloc] initWithFloat:20.0];
                    }
                    tm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:0.5];
                }
            
                if(!tm.benchmark){
                    //default value to...
                    tm.benchmark = [[NSDecimalNumber alloc] initWithFloat:10.0];
                }
                
                //default the master rate to zero
                tm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:0.0];
                
                tm.xPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
                tm.yPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
                tm.hembalPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
                

                //}
                [wb addBlockTimbermarkObject:tm];
            }
            
            
            //call web service for stratum
            urlAsString = [NSString stringWithFormat:STRATUM_WS_SUFFIX, wsBase, wasteAssessmentAreaId];
            NSLog(@"WebService URL for stratum: %@", urlAsString);
            
            url = [[NSURL alloc] initWithString:urlAsString];
            request = [NSMutableURLRequest requestWithURL:url];
            
            responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (error != nil){
                NSLog(@"Error when getting stratum: %@", error);
                        }
            
            NSArray *wsAry = [WasteStratumDTOAdaptor wasteStratumDTOFromJSON:responseData error:&error];
            
            for(WasteStratumDTO *wsDto in wsAry){
                
                //add stratum to cut block
                WasteStratum *ws = [self createStratum:wsDto];
                NSString *assessmentMethodCode = [[NSString alloc] initWithString: ws.stratumAssessmentMethodCode.assessmentMethodCode];
                
                //if stratum is using plot assessment method
                if ([assessmentMethodCode isEqualToString:@"P"]){
                    
                    //call web service for plot
                    urlAsString = [NSString stringWithFormat:PLOT_WS_SUFFIX, wsBase, ws.stratumID];
                    NSLog(@"WebService URL for Plot: %@", urlAsString);
                    
                    url = [[NSURL alloc] initWithString:urlAsString];
                    request = [NSMutableURLRequest requestWithURL:url];
                    
                    responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                    
                    if (error != nil){
                        NSLog(@"Error when getting Plot: %@", error);
                    }
                    
                    NSArray *wplotAry = [WastePlotDTOAdaptor wastePlotDTOFromJSON:responseData error:&error];
                    
                    for(WastePlotDTO *wplotDto in wplotAry){
                        WastePlot *wplot = [self createPlot:wplotDto];
                        
                        urlAsString = [NSString stringWithFormat:PIECE_BY_PLOT_WS_SUFFIX, wsBase, wplot.plotID];
                        NSLog(@"WebService URL for Piece: %@", urlAsString);
                        
                        url = [[NSURL alloc] initWithString:urlAsString];
                        request = [NSMutableURLRequest requestWithURL:url];
                        
                        responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                        
                        if (error != nil){
                            NSLog(@"Error when getting Piece: %@", error);
                            
                        }
                        
                        NSArray *wpieceAry = [WastePieceDTOAdaptor wastePieceDTOFromJSON:responseData error:&error];
                        
                        for(WastePieceDTO *wpieceDto in wpieceAry){
                            WastePiece *wpiece = [self createPiece:wpieceDto];
                            
                            //default to "not check" for status code
                            wpiece.pieceCheckerStatusCode = (CheckerStatusCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"checkerStatusCode" code:@"1"];
                            
                            //default the sort number to piece number X 10
                            wpiece.sortNumber = [NSNumber numberWithInt: [wpiece.pieceNumber intValue] * 10];
                            
                            //calculate the piece volume
                            [WasteCalculator calculatePieceStat:wpiece wasteStratum:ws];
                            
                            //add tje piece to plot
                            [wplot addPlotPieceObject:wpiece];
                        }
                        
                        //add plot to stratum after adding the piece to plot
                        [ws addStratumPlotObject:wplot];
                    }
                }else{
                    //if stratum is not using plot assessment method, create a empty plot to hold the pieces
                    WastePlot *wplot = [self createEmptyPlot];
                    
                    urlAsString = [NSString stringWithFormat:PIECE_BY_STRATUM_WS_SUFFIX, wsBase, ws.stratumID];
                    NSLog(@"WebService URL for Piece: %@", urlAsString);
                    
                    url = [[NSURL alloc] initWithString:urlAsString];
                    request = [NSMutableURLRequest requestWithURL:url];
                    
                    responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                    
                   if (error != nil){
                        NSLog(@"Error when getting Piece: %@", error);
                        
                    }
                    
                    NSArray *wpieceAry = [WastePieceDTOAdaptor wastePieceDTOFromJSON:responseData error:&error];
                    
                    for(WastePieceDTO *wpieceDto in wpieceAry){
                        WastePiece *wpiece = [self createPiece:wpieceDto];
                        
                        //default to "not check" for status code
                        wpiece.pieceCheckerStatusCode = (CheckerStatusCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"checkerStatusCode" code:@"1"];

                        //default the sort number to piece number X 10
                        wpiece.sortNumber = [NSNumber numberWithInt: [wpiece.pieceNumber intValue] * 10];
                        
                        //calculate the piece volume
                        [WasteCalculator calculatePieceStat:wpiece wasteStratum:ws];
                        
                        //add tje piece to plot
                        [wplot addPlotPieceObject:wpiece];
                    }
                    
                    //add plot to stratum after adding the piece to plot
                    [ws addStratumPlotObject:wplot];
                    
                }


                
                
                //add stratum to cut block after adding the plot to stratum
                [wb addBlockStratumObject:ws];

            }
        
            NSManagedObjectContext *context = [self managedObjectContext];
            
          if (error == nil){
                
                [WasteCalculator calculateWMRF:wb  updateOriginal:YES];
                
                [WasteCalculator calculateRate:wb];
                
                [WasteCalculator calculatePiecesValue:wb];

                if([wb.userCreated intValue] ==1){
                    [WasteCalculator calculateEFWStat:wb];
                }
                
                // if no error, save the whole cut block
                [context save:&error];
            }else{
                [context deleteObject:wb];
                
                NSLog(@" Error when saving waste block into Core Data: %@", error);
            }
        }
        @catch (NSException *exception) {
            NSDictionary *errorDictionary = @{ NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"Error exception occurs:%@ - %@", exception.name, exception.reason] };
            
            error =  [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:1 userInfo:errorDictionary];
        }
        @finally {
        }


        
        dispatch_async( dispatch_get_main_queue(), ^{
            //thread has finished so call final method
            
            if (error){
                [self.delegate downloadCutBlockFailed:error];
            }else{
                [self.delegate finishDownloadCutBlock:wb];
            }
        });
    });
}



-(WasteBlock *) createCutBlock:(WasteBlockDTO *)wbDto{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WasteBlock *wasteBlock = [NSEntityDescription insertNewObjectForEntityForName:@"WasteBlock" inManagedObjectContext:context];
    
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([wbDto class], &numberOfProperties);
    
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        
        if ([name rangeOfString:@"Code"].location == NSNotFound){
            
            [wasteBlock setValue:[wbDto valueForKey:name] forKey:name];
            
        }else{
            //find the code and map it
            if ( [name isEqualToString:@"maturityCode"]){
                wasteBlock.blockMaturityCode = (MaturityCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"maturityCode" code:[wbDto valueForKey:name]];
            }else if ( [name isEqualToString:@"siteCode"]){
                wasteBlock.blockSiteCode = (SiteCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"siteCode" code:[wbDto valueForKey:name]];
            }else if( [name isEqualToString:@"snowCode"]){
                wasteBlock.blockSnowCode = (SnowCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"snowCode" code:[wbDto valueForKey:name]];
            }
            
        }
        //NSLog(@"Transfer property: %@, value: %@", name, [wbDto valueForKey:name]);
        
    }
    free(propertyArray);
    
    //copy the area to the survey area field
    wasteBlock.surveyArea = [[NSDecimalNumber alloc] initWithDecimal: [wasteBlock.netArea decimalValue]];
    
    //set the entry date
    wasteBlock.entryDate = [NSDate date];
    
    //set user created flag
    [wasteBlock setUserCreated:[NSNumber numberWithBool:NO]];
  
    return wasteBlock;
}

-(Timbermark *) createTimbermark:(TimbermarkDTO *)tmDto{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    Timbermark *tm = [NSEntityDescription insertNewObjectForEntityForName:@"Timbermark" inManagedObjectContext:context];
    
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([tmDto class], &numberOfProperties);
    
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        
        [tm setValue:[tmDto valueForKey:name] forKey:name];
          
        //NSLog(@"Transfer property: %@, value: %@", name, [tmDto valueForKey:name]);
    }
    free(propertyArray);
    
    //copy the area to the survey area field
    tm.surveyArea = [[NSDecimalNumber alloc] initWithDecimal: [tm.area decimalValue]];
   
    return tm;
}

-(WasteStratum *) createStratum:(WasteStratumDTO *)wsDto{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WasteStratum *ws = [NSEntityDescription insertNewObjectForEntityForName:@"WasteStratum" inManagedObjectContext:context];
    
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([wsDto class], &numberOfProperties);
    BOOL isStandingTree = NO;
    
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        
        if ([name rangeOfString:@"Code"].location == NSNotFound){
            
            [ws setValue:[wsDto valueForKey:name] forKey:name];
            
        }else{
            //find the code and map it
            if ( [name isEqualToString:@"harvestMethodCode"]){
                ws.stratumHarvestMethodCode = (HarvestMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"harvestMethodCode" code:[wsDto valueForKey:name]];
            }else if( [name isEqualToString:@"plotSizeCode"]){
                if (![wsDto valueForKey:name]){
                    ws.stratumPlotSizeCode = (PlotSizeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"plotSizeCode" code:[wsDto valueForKey:@"assessmentMethodCode"]];
                }else{
                    ws.stratumPlotSizeCode = (PlotSizeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"plotSizeCode" code:[wsDto valueForKey:name]];
                }
            }else if( [name isEqualToString:@"stratumTypeCode"]){
                ws.stratumStratumTypeCode = (StratumTypeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"stratumTypeCode" code:[wsDto valueForKey:name]];
                // for standing tree, default the waste type and harvest method
                if ([[wsDto valueForKey:name] isEqual:@"S"]){
                    isStandingTree = YES;
                }
                    
            }else if( [name isEqualToString:@"wasteLevelCode"]){
                ws.stratumWasteLevelCode = (WasteLevelCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"wasteLevelCode" code:[wsDto valueForKey:name]];
            }else if( [name isEqualToString:@"wasteTypeCode"]){
                ws.stratumWasteTypeCode = (WasteTypeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"wasteTypeCode" code:[wsDto valueForKey:name]];
            }else if( [name isEqualToString:@"assessmentMethodCode"]){
                ws.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:[wsDto valueForKey:name]];
            }
        }
        
        //NSLog(@"Transfer property: %@, value: %@", name, [wsDto valueForKey:name]);
        
    }
    free(propertyArray);
    
    if(isStandingTree){
        ws.stratumWasteTypeCode = (WasteTypeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"WasteTypeCode" code:@"S"];
        ws.stratumHarvestMethodCode = (HarvestMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"HarvestMethodCode" code:@"T"];
    }
    
    //copy the area to the survey area field
    ws.stratumSurveyArea = [[NSDecimalNumber alloc] initWithDecimal: [ws.stratumArea decimalValue]];
    ws.checkTotalEstimatedVolume = [[NSDecimalNumber alloc] initWithDecimal: [ws.totalEstimatedVolume decimalValue]];
    
    [ws setIsSurvey:[NSNumber numberWithBool:YES]];
    
    //update the stratum name for non-tall card plot stratum
    [self updateStratumName:ws];

    return ws;
}

-(WastePlot *) createPlot:(WastePlotDTO *) wplotDto{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePlot *wplot = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
    
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([wplotDto class], &numberOfProperties);
    
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        
        [wplot setValue:[wplotDto valueForKey:name] forKey:name];
        
        //NSLog(@"Transfer property: %@, value: %@", name, [wplotDto valueForKey:name]);
    }
    free(propertyArray);
    wplot.checkerMeasurePercent = [[NSNumber alloc] initWithInteger:[wplot.surveyedMeasurePercent integerValue]];
    [wplot setIsSurvey:[NSNumber numberWithBool:YES]];

    return wplot;
}

-(WastePiece *) createPiece:(WastePieceDTO *) wpieceDto{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePiece *wpiece = [NSEntityDescription insertNewObjectForEntityForName:@"WastePiece" inManagedObjectContext:context];
    
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([wpieceDto class], &numberOfProperties);
    
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        
        if ([name rangeOfString:@"Code"].location == NSNotFound){
            
            [wpiece setValue:[wpieceDto valueForKey:name] forKey:name];
            //NSLog(@"Transfer not code property: %@, DTO value: %@, waste piece value:%@", name, [wpieceDto valueForKey:name], [wpiece valueForKey:name]);
            
        }else{
            
            //find the code and map it
            if ( [name isEqualToString:@"borderlineCode"]){
                wpiece.pieceBorderlineCode = (BorderlineCode *)[[CodeDAO sharedInstance] getCodeByNameCode:name code:[wpieceDto valueForKey:name]];
            }else if( [name isEqualToString:@"buttEndCode"]){
                wpiece.pieceButtEndCode = (ButtEndCode *)[[CodeDAO sharedInstance] getCodeByNameCode:name code:[wpieceDto valueForKey:name]];
            }else if( [name isEqualToString:@"commentCode"]){
                wpiece.pieceCommentCode = (CommentCode *)[[CodeDAO sharedInstance] getCodeByNameCode:name code:[wpieceDto valueForKey:name]];
            }else if( [name isEqualToString:@"decayTypeCode"]){
                wpiece.pieceDecayTypeCode = (DecayTypeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:name code:[wpieceDto valueForKey:name]];
            }else if( [name isEqualToString:@"materialKindCode"]){
                wpiece.pieceMaterialKindCode = (MaterialKindCode *)[[CodeDAO sharedInstance] getCodeByNameCode:name code:[wpieceDto valueForKey:name]];
            }else if( [name isEqualToString:@"scaleGradeCode"]){
                wpiece.pieceScaleGradeCode = (ScaleGradeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:name code:[wpieceDto valueForKey:name]];
            }else if( [name isEqualToString:@"scaleSpeciesCode"]){
                wpiece.pieceScaleSpeciesCode = (ScaleSpeciesCode *)[[CodeDAO sharedInstance] getCodeByNameCode:name code:[wpieceDto valueForKey:name]];
            }else if( [name isEqualToString:@"topEndCode"]){
                wpiece.pieceTopEndCode = (TopEndCode *)[[CodeDAO sharedInstance] getCodeByNameCode:name code:[wpieceDto valueForKey:name]];
            }else if( [name isEqualToString:@"wasteClassCode"]){
                wpiece.pieceWasteClassCode = (WasteClassCode *)[[CodeDAO sharedInstance] getCodeByNameCode:name code:[wpieceDto valueForKey:name]];
            }
        }
        
        //NSLog(@"Transfer property: %@, value: %@", name, [wpieceDto valueForKey:name]);
        
    }
    free(propertyArray);
    [wpiece setIsSurvey:[NSNumber numberWithBool:YES]];

    return wpiece;
}

-(WastePlot *) createEmptyPlot{
    NSManagedObjectContext *context = [self managedObjectContext];

    WastePlot *wp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
    wp.assistant = @"";
    wp.baseline = @"";
    wp.certificateNumber = @"";
    wp.checkDate = [NSDate date];
    wp.checkerMeasurePercent = [[NSNumber alloc] initWithInteger:100];
    wp.notes = @"";
    wp.plotID = @0;
    wp.plotNumber = [[NSNumber alloc] initWithLong: 1];
    wp.returnNumber = @"";
    wp.strip = @0;
    wp.surveyDate = [NSDate date];
    wp.surveyedMeasurePercent = [[NSNumber alloc] initWithInteger:100];
    wp.surveyorName = @"";
    wp.weather = @"";
    wp.plotPiece = nil;
    wp.plotShapeCode = nil;
    wp.plotSizeCode = nil;
    wp.plotStratum = nil;
    
    [wp setIsSurvey:[NSNumber numberWithBool:YES]];
    
    return wp;
}

- (void) updateStratumName:(WasteStratum *)ws{
    
    NSMutableString *stratumName = [[NSMutableString alloc] initWithString:ws.stratum];
    
    if ( ws.stratumStratumTypeCode && [ws.stratumStratumTypeCode.stratumTypeCode isEqualToString:@"S"]){
        
        [stratumName replaceCharactersInRange:NSMakeRange(0, 3) withString:@"STR"];
        [stratumName replaceCharactersInRange:NSMakeRange(3, 1) withString:ws.stratumAssessmentMethodCode.assessmentMethodCode ];
        
    }else{
        
        // replace 1st number of title
        //tmp = [ [self codeFromText:self.wasteType.text] isEqualToString:@""] ? @"_" : [self codeFromText:self.wasteType.text];
        //[last4numbers replaceCharactersInRange:NSMakeRange(0, 1) withString:tmp];
        
        // replace 2nd number of title
        //tmp = [ [self codeFromText:self.harvestMethod.text] isEqualToString:@""] ? @"_" : [self codeFromText:self.harvestMethod.text];
        //[last4numbers replaceCharactersInRange:NSMakeRange(1, 1) withString:tmp];
        
        // replace 3rd number of title
        NSString *testVariable = ws.stratumAssessmentMethodCode.assessmentMethodCode;
        if (![ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] ){
            [stratumName replaceCharactersInRange:NSMakeRange(2, 1) withString:ws.stratumAssessmentMethodCode.assessmentMethodCode ];
        }
        
        // replace 4th number of title
        //tmp = [ [self codeFromText:self.wasteLevel.text] isEqualToString:@""] ? @"_" : [self codeFromText:self.wasteLevel.text];
        //[last4numbers replaceCharactersInRange:NSMakeRange(3, 1) withString:tmp ];
        
    }
    ws.stratum = [NSString stringWithString:stratumName];
                  
}

@end
