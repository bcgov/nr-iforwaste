//
//  FS702Report.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-05.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "FS702Report.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "WastePiece.h"
#import "ButtEndCode.h"
#import "ScaleSpeciesCode.h"
#import "ScaleGradeCode.h"
#import "WasteClassCode.h"
#import "CheckerStatusCode.h"
#import "Timbermark.h"
#import "PlotSizeCode.h"
#import "Constants.h"
#import "AssessmentMethodCode.h"
#import "StratumPile+CoreDataClass.h"
#import "WastePile+CoreDataClass.h"

@implementation FS702Report

-(GenerateOutcomeCode) generateReport:(WasteBlock *)wastBlock withTimbermark:(Timbermark*)timbermark suffix:(NSString *)suffix replace:(BOOL)replace{
    
    NSLog(@"Genereate FS 702 report");

    [super checkReportFolder];
    NSError *error = nil;
    
    // Figure out destination name (in public docs dir)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if( ![suffix isEqualToString:@""]){
        suffix = [NSString stringWithFormat:@"_%@", [suffix stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    }
    NSMutableString *tm_name = [timbermark.timbermark mutableCopy];
    NSString *zippedName = [NSString stringWithFormat: @"%@_%@_FS702%@.pdf", [super getReportFilePrefix:wastBlock],
                            [tm_name stringByReplacingOccurrencesOfString:@"/" withString:@"-" ], suffix];
    NSString *zippedPath = [documentsDirectory stringByAppendingPathComponent:zippedName];
    
    
    // Check if file already exists (unless we force the write)
    if ( [[NSFileManager defaultManager] fileExistsAtPath:zippedPath] && !replace) {
        NSLog(@"File exists already");
        return Fail_Filename_Exist;
    }

    // check if we got WasteBlock && WastePlot
    if(wastBlock==nil){
        return Fail_Unknown;
    }
    
  
    NSString *tempFilePath =[documentsDirectory stringByAppendingString:@"/ReportTemplate/"];
    
    // PREPARE TEMPLATES FOR BUILDING THE HTML
    //
    //NSString *path = [[NSBundle mainBundle] pathForResource: @"REPORT" ofType: @"html"];
    NSString *path = [tempFilePath stringByAppendingString:@"REPORT.html"];

    NSError *errorForHTML;
    NSString *tmpPath, *newHTML, *rowHTML, *CSS, *TITLE, *T1, *T2, *FOOTER, *NOTE = [[NSString alloc] init];
    
    
    // LOAD STYLE TEMPLATE
    tmpPath = [[NSBundle mainBundle] pathForResource: @"CSS_2" ofType: @"html"];
    //tmpPath = [tempFilePath stringByAppendingString:@"CSS_2.html"];
    CSS = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // LOAD TITLE TEMPLATE
    tmpPath = [[NSBundle mainBundle] pathForResource: @"TITLE" ofType: @"html"];
    //tmpPath = [tempFilePath stringByAppendingString:@"TITLE.html"];
    TITLE = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    NSString *tt = [NSString stringWithFormat:@"%@ %@", ([wastBlock.regionId integerValue] == InteriorRegion ? @"Interior":@"Coast"), @"Block Billing and Volume summary (FS702) - "];
    if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [wastBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        tt = [tt stringByAppendingString:[NSString stringWithFormat:@"%@",@" Aggregate Ratio Sampling"]];
    }else if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [wastBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        tt = [tt stringByAppendingString:[NSString stringWithFormat:@"%@",@" Aggregate SRS Survey"]];
    }else if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [wastBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        tt = [tt stringByAppendingString:[NSString stringWithFormat:@"%@",@" Single Block SRS Survey"]];
    }else if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [wastBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        tt = [tt stringByAppendingString:[NSString stringWithFormat:@"%@",@" Single Block Ratio Sampling"]];
    }
    TITLE = [NSString stringWithFormat:TITLE, tt];
    
    
    // LOAD ROWS TEMPLATE
    tmpPath = [[NSBundle mainBundle] pathForResource: @"ROW_2" ofType: @"html"];
    //tmpPath = [tempFilePath stringByAppendingString:@"ROW_2.html"];
    rowHTML = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // LOAD FOOTER TEMPLATE
    FOOTER = [self getFooter:wastBlock note:NOTE];

    // Get the note from the stratum
    NSSet *tmpStratums = [wastBlock blockStratum];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
    NSArray *sortedStratums = [tmpStratums sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    NSString *straNote = @"";
    for (WasteStratum *st in sortedStratums){
        if (st.notes){
            straNote = [NSString stringWithFormat:@"%@<BR />%@ - %@", straNote, st.stratum, st.notes];
        }
    }
    
    // LOAD NOTE TEMPLATE
    tmpPath = [[NSBundle mainBundle] pathForResource: @"NOTE" ofType: @"html"];
    NOTE = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

    if (!wastBlock.notes){
        NOTE = [NSString stringWithFormat:NOTE, straNote];
    }else{
        NOTE = [NSString stringWithFormat:NOTE, [NSString stringWithFormat:@"Block - %@ <BR /> %@ ", wastBlock.notes, straNote]];
    }
    
    
    // calculate the data
    NSArray *rawdata = [self CalculateDataTable1:wastBlock withTimbermark:timbermark];
    
    
    // TABLE2_1 CREATION
    //
    // load the rows html
    NSArray *dataForTable1 = [rawdata objectAtIndex:0];
    NSString *rowsHTML = [self createRowsForTable1:dataForTable1];
    
    
    tmpPath = [[NSBundle mainBundle] pathForResource: @"TABLE2_1" ofType: @"html"];
    //tmpPath = [tempFilePath stringByAppendingString:@"TABLE2_1.html"];

    T1 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    //NSLog(@"%@", rowsHTML);
    
    // insert the table HEAD and ROWS (convert ROWS to nonmutable first)
    // TO-DO: when generated the report doesnt have ROWS
    NSString *timberMark = @"";
    for (Timbermark *tm in wastBlock.blockTimbermark){
        timberMark = [NSString stringWithFormat:@"%@ %@", timberMark, tm.timbermark];
    }
    
    
    T1 = [NSString stringWithFormat:T1, wastBlock.licenceNumber, wastBlock.cuttingPermitId, wastBlock.blockNumber, timberMark, timbermark.wmrf, [NSString stringWithString:rowsHTML] ];
    
    //NSLog(@"%@",T1);
    
    
    
    // TABLE2_2 CREATION
    //
    
    // load the rows html
    NSArray *dataForTable2 = [rawdata objectAtIndex:1];
    
    NSArray *totalColumn = [self createCalculateTotalColumn:dataForTable1 wasteBlock:wastBlock];
    
    NSArray *COLUMNS = [self createColumnsForTable2:dataForTable2 withTotalColumn:totalColumn wasteBlock:wastBlock];
    
    tmpPath = [[NSBundle mainBundle] pathForResource: @"TABLE2_2" ofType: @"html"];
    //tmpPath = [tempFilePath stringByAppendingString:@"TABLE2_2.html"];

    T2 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

    // insert the table columns into ROWS
    NSString *r1 = [COLUMNS objectAtIndex:0];
    
    NSString *customSubTotal = @"";
    NSString *gradeZSubTotal = @"";
    NSString *notes = @"";
    //NSString *grade6SubTotal = @"";
    //hard code the sub-total section for coast and interior
    if([wastBlock.regionId integerValue] == CoastRegion){
    
        customSubTotal = [NSString stringWithFormat:@"<tr class=""boldRows""> <td class=""leftAlignment""><b>Total HemBal Avoid</b></td>%@</tr>",  [COLUMNS objectAtIndex:1]];
        customSubTotal = [customSubTotal stringByAppendingString:[NSString stringWithFormat:@"<tr class=""boldRows""> <td class=""leftAlignment""><b>Total All Species Avoid</b></td>%@</tr>",  [COLUMNS objectAtIndex:2]]];
        customSubTotal = [customSubTotal stringByAppendingString:[NSString stringWithFormat:@"<tr class=""boldRows""> <td class=""leftAlignment""><b>Total All Species Avoid</b></td>%@</tr>",  [COLUMNS objectAtIndex:3]]];

    }else if( [wastBlock.regionId integerValue] == InteriorRegion){
        
        customSubTotal = [NSString stringWithFormat:@"<tr class=""boldRows""> <td class=""leftAlignment""><b>Total Avoid</b></td>%@</tr>",  [COLUMNS objectAtIndex:1]];
        customSubTotal = [customSubTotal stringByAppendingString:[NSString stringWithFormat:@"<tr class=""boldRows""> <td class=""leftAlignment""><b>Total Avoid</b></td>%@</tr>",  [COLUMNS objectAtIndex:2]]];
        customSubTotal = [customSubTotal stringByAppendingString:[NSString stringWithFormat:@"<tr class=""boldRows""> <td class=""leftAlignment""><b>Total Avoid</b></td>%@</tr>",  [COLUMNS objectAtIndex:3]]];
        customSubTotal = [customSubTotal stringByAppendingString:[NSString stringWithFormat:@"<tr class=""boldRows""> <td class=""leftAlignment""><b>Total Avoid</b></td>%@</tr>",  [COLUMNS objectAtIndex:4]]];
    }

    NSString *r7 = [COLUMNS objectAtIndex:(COLUMNS.count - 3)];
    NSString *r6 = [COLUMNS objectAtIndex:(COLUMNS.count - 4)];
    
    gradeZSubTotal = [gradeZSubTotal stringByAppendingString:[NSString stringWithFormat:@"<tr class=""boldRows""> <td class=""leftAlignment""><b>Z-Grade</b></td>%@</tr>",  [COLUMNS objectAtIndex:(COLUMNS.count - 2)]]];
    //below code as part of fix EFORWASTE-85
    if( [wastBlock.regionId integerValue] == InteriorRegion){
        gradeZSubTotal = [gradeZSubTotal stringByAppendingString:[NSString stringWithFormat:@"<tr class=""boldRows""> <td class=""leftAlignment""><b>Grade-6</b></td>%@</tr>",  [COLUMNS objectAtIndex:(COLUMNS.count - 1)]]];
    }
    
    if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        notes = [notes stringByAppendingString:[NSString stringWithFormat:@"%@",@" Note: If the survey method uses ratio, the displayed values are NOT adjusted by the ratio for the population."]];
    }
    T2 = [NSString stringWithFormat:T2, r1, customSubTotal, r6, r7,gradeZSubTotal, notes];
    
    
    // STICH TOGETHER THE FORM FILE: HMTL = CSS + TITLE + T1 + T2 + FOOTER
    //
    NSMutableString* stichingHTML = [[NSMutableString alloc] init];
    [stichingHTML appendString:CSS];
    [stichingHTML appendString:TITLE];
    [stichingHTML appendString:T1];
    [stichingHTML appendString:T2];
    [stichingHTML appendString:NOTE];
    [stichingHTML appendString:FOOTER];
    
    
    // convert back to normal string from mutable
    newHTML = [NSString stringWithString:stichingHTML];
    
    
    // build the path where you're going to save the HTML
    //NSString *filename = [path stringByAppendingPathComponent:@"ContentPlaceholder.html"]; // changepath to local
    
    
    // SAVE HTML FILE - save the NSString that contains the HTML to a file
    [newHTML writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&errorForHTML];
    if(errorForHTML){
        NSLog(@"Error in saving HTML file = %@", errorForHTML);
    }
    
    // Create URL from HTML file in application bundle
    //NSURL *htmlInput = [[NSBundle mainBundle] URLForResource: @"REPORT" withExtension:@"html"];
    NSURL *htmlInput = [[NSURL alloc] initFileURLWithPath:[tempFilePath stringByAppendingString:@"REPORT.html"]];
    
    
    // Create attributed string from HTML
    NSAttributedString *str = [[NSAttributedString alloc]
                               initWithFileURL:htmlInput
                               options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                               documentAttributes:nil error:nil];
    
    
    
    
    
    //
    // END OF TEST
    //
        
    // ORIGINAL
    
    // NSAttributedString *str = [[NSAttributedString alloc] initWithString:content attributes:nil];
    /*UIEdgeInsets margin = {.left = 40, .right = 40, .top = 20, .bottom = 20};

    
    // Export to data buffer
    NSData *data = [str dataFromRange:(NSRange){0, [str length]}
                   documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType,
                                        NSPaperMarginDocumentAttribute: [NSValue valueWithUIEdgeInsets:margin]}
                                error:&error
                    ];
    
    if(error != nil)
    {
        NSLog(@"Failed to create persistent store. Error %@.", error);
        //abort();
        return Fail_Unknown;
    }
    
    // data should not be nil
    if (data == nil) abort();
    
    // Write to disk
    [data writeToFile:zippedPath atomically:YES];*/
    
    //Saving as PDF file
    CGRect pageFrame = {{0.0 , 0.0 } , {612.0 , 792.0}};
    
    UIPrintPageRenderer *printPageRenderer = [[UIPrintPageRenderer alloc] init];
    [printPageRenderer setValue:[NSValue valueWithCGRect:pageFrame] forKey:@"paperRect"];
    [printPageRenderer setValue:[NSValue valueWithCGRect:pageFrame] forKey:@"printableRect"];
    
    NSString *strHtml = [NSString stringWithContentsOfURL:htmlInput encoding:NSUTF8StringEncoding error:nil];
    UIPrintFormatter *printFormatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:strHtml];
    
    [printPageRenderer addPrintFormatter:printFormatter startingAtPageAtIndex:0];
    
    NSLog(@"numberOfPages :%ld", (long)printPageRenderer.numberOfPages);
    NSMutableData *pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for(int i=0; i< printPageRenderer.numberOfPages; i++){
        UIGraphicsBeginPDFPage();
        [printPageRenderer drawPageAtIndex:(i) inRect:bounds];
    }
    UIGraphicsEndPDFContext();
    
    [pdfData writeToFile:zippedPath atomically:YES];
    NSLog(@"%@", zippedPath);
    NSLog(@"FS 702 report is genereated");
    
    return Successful;
}

/*
 takes the object containing data
 puts the data into the required format (Array)
 * also checks for any data missing and fills it with @""
 */
- (NSArray*) CalculateDataTable1:(WasteBlock *)wastBlock withTimbermark:(Timbermark*)timbermark{
    NSDecimalNumberHandler *behaviorD2 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];

    //wplot.checkNetVal = [[[NSDecimalNumber alloc] initWithDouble:plotCheckTotalValue] decimalNumberByRoundingAccordingToBehavior:behaviorD2];

    //NSLog(@"FS720 - TABLE 1");
    
    NSString *td1, *td3, *td4, *td5, *td6, *td7, *td8, *td9 = [[NSString alloc] init];
    //removed *td2, no longer needed
    
    NSArray *row = [[NSArray alloc] init];
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *combinationsOfPieces = [[NSMutableDictionary alloc] init];
    
    NSSet *stratums = [wastBlock blockStratum];
    NSSet *pieces = [[NSSet alloc] init];
    NSSet *plots = [[NSSet alloc] init];
    NSSet *piles = [[NSSet alloc] init];
    
    NSString *uniqueID = @"";
    NSArray *pieceData = [[NSArray alloc] init];
    
    
    for(WasteStratum *stratum in stratums)
    {
        //NSLog(@"\n");
        //NSLog(@" STRATUM = %@", stratum.stratum);
        
        plots = stratum.stratumPlot;
        for(WastePlot *plot in plots)
        {
           // NSLog(@"\n");
           // NSLog(@" PLOT NUMBER = %@", plot.plotNumber);
            
            pieces = plot.plotPiece;
            for(WastePiece *piece in pieces)
            {
                
                // the same rules apply to this piece like for the checkVolume
                if( ![piece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"3"]){
                    
                    if( [piece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"4"] && ! [self stringHasC:[piece.piece stringValue]]){
                        // dont add
                    }
                    else
                    {
                        
                        // AVOID_SPECIES_GRADE
                        uniqueID = [NSString stringWithFormat:@"%@_%@_%@", piece.pieceScaleSpeciesCode.scaleSpeciesCode, piece.pieceScaleGradeCode.scaleGradeCode, piece.pieceWasteClassCode.wasteClassCode];
                        
                        //
                        // NO SUCH UNIQUE_ID, ADD NEW KEY AND COUNT
                        //
                        if([combinationsOfPieces objectForKey:uniqueID]==nil)
                        {
                            
                            float pieceRate = [self pieceRate:piece.pieceScaleSpeciesCode.scaleSpeciesCode withGrade:piece.pieceScaleGradeCode.scaleGradeCode
                                                    withAvoid:[piece.pieceWasteClassCode.wasteClassCode isEqualToString:@"A"] forBlock:wastBlock withTimbermark:timbermark];
                            //app crashes when pieceRate is NAN. Inorder to avoid that the below code.
                            pieceRate = isnan(pieceRate) ? 0.0 : pieceRate;
                            //float volHa = [[piece.pieceVolume decimalNumberByDividingBy:wastBlock.netArea] floatValue];
                            //volume = plot multipler x piece volume x (100/ check measure percent) / number of plot
                            double pieceVolume = 0.0;
                            if([wastBlock.userCreated integerValue] == 1){
                                if ([stratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                    
                                    int plotsize = 0;
                                    if([stratum.stratumBlock.ratioSamplingEnabled intValue] == 1){
                                        //for ratio sampling block, only count the ones is marked as measure plot.
                                        for(WastePlot *p in stratum.stratumPlot){
                                            if([p.isMeasurePlot intValue] == 1){
                                                plotsize = plotsize + 1;
                                            }
                                        }
                                    }else{
                                        plotsize = (int) stratum.stratumPlot.count ;
                                    }
                                    
                                    pieceVolume = [stratum.stratumPlotSizeCode.plotMultipler doubleValue] * [piece.pieceVolume doubleValue] * (100.0/[plot.surveyedMeasurePercent integerValue]) * ([stratum.stratumSurveyArea doubleValue]/ plotsize);
                                }else{
                                    pieceVolume = [piece.pieceVolume doubleValue] * (100.0/[plot.surveyedMeasurePercent integerValue]);
                                }
                            }else{
                                if ([stratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                    pieceVolume = [stratum.stratumPlotSizeCode.plotMultipler doubleValue] * [piece.pieceVolume doubleValue] * (100.0/[plot.checkerMeasurePercent integerValue]) * ([stratum.stratumArea doubleValue]/ stratum.stratumPlot.count);
                                }else{
                                    pieceVolume = [piece.pieceVolume doubleValue] * (100.0/[plot.checkerMeasurePercent integerValue]) ;
                                }
                            }
                            NSLog(@"PM=%.2f, PV= %.2f SP=%.2lu, psmp=%ld, ssa=%.2f",
                                  [stratum.stratumPlotSizeCode.plotMultipler floatValue], pieceVolume,
                                  stratum.stratumPlot.count, [plot.surveyedMeasurePercent integerValue], [stratum.stratumSurveyArea doubleValue]);
                            if ( [piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"U"] && [piece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:@"CY"] ) {
                                NSLog(@"piece volumne = %f", pieceVolume);
                            }
                            
                            // count, pieceVolume, vol/ha, rate, total, nil
                            pieceData = [[NSArray alloc] initWithObjects:
                                         @"1",                                                                      // count
                                         [[NSString alloc] initWithFormat:@"%.02f",[[[[NSDecimalNumber alloc] initWithDouble:pieceVolume] decimalNumberByRoundingAccordingToBehavior:behaviorD2] floatValue]],                    // pieceVolume
                                         [[NSString alloc] initWithFormat:@"%.003f", [piece.volOverHa floatValue]],                                  // vol/ha is calculated at the end
                                         [[NSString alloc] initWithFormat:@"%.02f",pieceRate],                      // rate
                                         @"0",                                                                      // total is calculated at the end
                                         nil];
                            
                            [combinationsOfPieces setValue:pieceData forKey:uniqueID];  // BUG???? - should set a new key with value (i dont want to replace it)
                            
                            
                            /*
                            NSLog(@"UNIQUE PIECE \n"); NSLog(@"piece rate = %0.2f", pieceRate);
                            NSLog(@"\t pieceNumber = %@", piece.pieceNumber);
                            NSLog(@"\t pieceID = %@", piece.piece);
                            NSLog(@"\t piece status = %@", piece.pieceCheckerStatusCode.checkerStatusCode);
                            NSLog(@"\t piece species = %@", piece.pieceScaleSpeciesCode.scaleSpeciesCode);
                            NSLog(@"\t piece grade = %@", piece.pieceScaleGradeCode.scaleGradeCode);
                            NSLog(@"\t piece waste = %@", piece.pieceWasteClassCode.wasteClassCode);
                            NSLog(@"UNIQUE PIECE END \n");
                            */
                            //NSLog(@"piece volumne = %f for key %@, m = %f, cnt = %d, area = %f", [piece.pieceVolume doubleValue], uniqueID, [stratum.stratumPlotSizeCode.plotMultipler doubleValue], stratum.stratumPlot.count, [stratum.stratumArea doubleValue]);
                        }
                        //
                        // WE DO HAVE A COMBINATION LIKE THIS, INCREMENT DATA IN DICT
                        //
                        else
                        {
                            // get the current accumulated data for the ID
                            NSArray *tmpDictDataForID = [combinationsOfPieces valueForKey:uniqueID];
                            
                            // update the accumulated data values
                            NSInteger count = [[tmpDictDataForID objectAtIndex:0] integerValue] + 1; // number of pieces
                            double pieceVolume = 0.0;
                            
                            if([wastBlock.userCreated integerValue] == 1){
                                if ([stratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                    int plotsize = 0;
                                    if([stratum.stratumBlock.ratioSamplingEnabled intValue] == 1){
                                        //for ratio sampling block, only count the ones is marked as measure plot.
                                        for(WastePlot *p in stratum.stratumPlot){
                                            if([p.isMeasurePlot intValue] == 1){
                                                plotsize = plotsize + 1;
                                            }
                                        }
                                    }else{
                                        plotsize = (int) stratum.stratumPlot.count ;
                                    }
                                    
                                    pieceVolume = [stratum.stratumPlotSizeCode.plotMultipler doubleValue] * [piece.pieceVolume doubleValue] * (100.0/[plot.surveyedMeasurePercent integerValue]) * ([stratum.stratumSurveyArea doubleValue]/plotsize);
                                }else{
                                    pieceVolume = [piece.pieceVolume doubleValue] ;
                                }
                            }else{
                                if ([stratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
                                    pieceVolume = [stratum.stratumPlotSizeCode.plotMultipler doubleValue] * [piece.pieceVolume doubleValue] * (100.0/[plot.checkerMeasurePercent integerValue]) * ([stratum.stratumArea doubleValue] / stratum.stratumPlot.count);
                                }else{
                                    pieceVolume = [piece.pieceVolume doubleValue] ;
                                }
                            }
                            
                            double newpieceVolume = [[tmpDictDataForID objectAtIndex:1] doubleValue] + [[[[NSDecimalNumber alloc] initWithDouble:pieceVolume] decimalNumberByRoundingAccordingToBehavior:behaviorD2] doubleValue];
                            
                            float volHa = [[tmpDictDataForID objectAtIndex:2] floatValue] + [piece.volOverHa floatValue];
                            
                            float rate = [[tmpDictDataForID objectAtIndex:3] floatValue]; // piece rate is the same for all such pieces and set on their first encounter
                            float total = 0.0; // calculated at the end
                            

                            
                            
                            // update the original accumulated data with new values
                            pieceData = [[NSArray alloc] initWithObjects:
                                         [[NSString alloc] initWithFormat:@"%ld",(long)count],
                                         [[NSString alloc] initWithFormat:@"%.02f", newpieceVolume],
                                         [[NSString alloc] initWithFormat:@"%.003f", volHa] ,
                                         [[NSString alloc] initWithFormat:@"%.02f",rate],
                                         [[NSString alloc] initWithFormat:@"%.02f", total],
                                         nil];
                            [combinationsOfPieces setObject:pieceData forKey:uniqueID];
                            
                            
                            
                            // output the piece that is accumulated
                            /*
                            NSLog(@"------------------------------------------------");
                            NSLog(@"PIECE \n"); NSLog(@"piece rate = %f", rate);
                            NSLog(@"\t pieceNumber = %@", piece.pieceNumber);
                            NSLog(@"\t pieceID = %@", piece.piece);
                            NSLog(@"\t piece status = %@", piece.pieceCheckerStatusCode.checkerStatusCode);
                            NSLog(@"\t\t  piece species = %@", piece.pieceScaleSpeciesCode.scaleSpeciesCode);
                            NSLog(@"\t\t  piece grade = %@", piece.pieceScaleGradeCode.scaleGradeCode);
                            NSLog(@"\t\t  piece waste = %@", piece.pieceWasteClassCode.wasteClassCode);
                            NSLog(@"------------------------------------------------");
                            NSLog(@"\t accumulated count = %ld", (long)count);
                            NSLog(@"\t accumulated pieceVolume = %f", pieceVolume);
                            NSLog(@"\t accumulated volHa = %f", volHa);
                            NSLog(@"\t accumulated rate = %f", rate);
                            NSLog(@"\t accumulated total = %f", total);
                            NSLog(@"------------------------------------------------");
                            */
                        }
                    }
                }// if piece is appropriate
            }// for pieces
        }//for stratums
        StratumPile* sp = stratum.strPile;
          piles = sp.pileData;
          NSString* avoid = @"A";
          for(WastePile* pile in piles)
          {
              NSMutableArray *speciesArray = [[NSMutableArray alloc] init];
              NSMutableArray *speciesPercentArray  = [[NSMutableArray alloc] init];
              if(pile.alPercent != 0 ){
                  [speciesArray addObject: @"AL"];
                  [speciesPercentArray addObject: pile.alPercent];
              }
                if(pile.arPercent != 0 ){
                   [speciesArray addObject: @"AR"];
                   [speciesPercentArray addObject: pile.arPercent];
                }
                if(pile.asPercent != 0 ){
                   [speciesArray addObject: @"AS"];
                   [speciesPercentArray addObject: pile.asPercent];
                }
                if(pile.baPercent != 0 ){
                   [speciesArray addObject: @"BA"];
                   [speciesPercentArray addObject: pile.baPercent];
                }
                if(pile.biPercent != 0 ){
                   [speciesArray addObject: @"BI"];
                   [speciesPercentArray addObject: pile.biPercent];
                }
                if(pile.cePercent != 0 ){
                   [speciesArray addObject: @"CE"];
                   [speciesPercentArray addObject: pile.cePercent];
                }
                if(pile.coPercent != 0 ){
                   [speciesArray addObject: @"CO"];
                     [speciesPercentArray addObject: pile.coPercent];
                }
                if(pile.cyPercent != 0 ){
                   [speciesArray addObject: @"CY"];
                     [speciesPercentArray addObject: pile.cyPercent];
                }
                if(pile.fiPercent != 0 ){
                   [speciesArray addObject: @"FI"];
                     [speciesPercentArray addObject: pile.fiPercent];
                }
                if(pile.hePercent != 0 ){
                   [speciesArray addObject: @"HE"];
                     [speciesPercentArray addObject: pile.hePercent];
                }
                if(pile.laPercent != 0 ){
                   [speciesArray addObject: @"LA"];
                     [speciesPercentArray addObject: pile.laPercent];
                }
                if(pile.loPercent != 0 ){
                   [speciesArray addObject: @"LO"];
                     [speciesPercentArray addObject: pile.loPercent];
                }
                if(pile.maPercent != 0 ){
                   [speciesArray addObject: @"MA"];
                     [speciesPercentArray addObject: pile.maPercent];
                }
                if(pile.spPercent != 0 ){
                    [speciesArray addObject: @"SP"];
                      [speciesPercentArray addObject: pile.spPercent];
                }
                if(pile.uuPercent != 0 ){
                   [speciesArray addObject: @"UU"];
                     [speciesPercentArray addObject: pile.uuPercent];
                }
                if(pile.wbPercent != 0 ){
                   [speciesArray addObject: @"WB"];
                     [speciesPercentArray addObject: pile.wbPercent];
                }
                if(pile.whPercent != 0 ){
                   [speciesArray addObject: @"WH"];
                     [speciesPercentArray addObject: pile.whPercent];
                }
                if(pile.wiPercent != 0 ){
                   [speciesArray addObject: @"WI"];
                     [speciesPercentArray addObject: pile.wiPercent];
                }
                if(pile.yePercent != 0 ){
                   [speciesArray addObject: @"YE"];
                     [speciesPercentArray addObject: pile.yePercent];
                }
              
              NSMutableArray *gradeArray = [[NSMutableArray alloc] init];
              NSMutableArray *gradePercentArray = [[NSMutableArray alloc] init];
              
              if(stratum.grade12Percent != 0 ){
                  [gradeArray addObject: @"2"];
                    [gradePercentArray addObject: stratum.grade12Percent];
              }
              if(stratum.grade4Percent != 0 ){
                  [gradeArray addObject: @"4"];
                    [gradePercentArray addObject: stratum.grade4Percent];
              }
              if(stratum.grade5Percent != 0 ){
                  [gradeArray addObject: @"5"];
                    [gradePercentArray addObject: stratum.grade5Percent];
              }
              if(stratum.gradeJPercent != 0 ){
                  [gradeArray addObject: @"J"];
                    [gradePercentArray addObject: stratum.gradeJPercent];
              }
              if(stratum.gradeYPercent != 0 ){
                  [gradeArray addObject: @"Y"];
                    [gradePercentArray addObject: stratum.gradeYPercent];
              }
              if(stratum.gradeXPercent != 0 ){
                  [gradeArray addObject: @"X"];
                    [gradePercentArray addObject: stratum.gradeXPercent];
              }
              if(stratum.gradeWPercent != 0 ){
                  [gradeArray addObject: @"W"];
                    [gradePercentArray addObject: stratum.gradeWPercent];
              }
              if(stratum.gradeUPercent != 0 ){
                  [gradeArray addObject: @"U"];
                    [gradePercentArray addObject: stratum.gradeUPercent];
              }
              
              int i;
              int j;
              int speciesCount = [speciesArray count];
              int gradeCount = [gradeArray count];
              
              for(i = 0; i < speciesCount; i++)
              {
                  for(j = 0; j < gradeCount; j++)
                  {
                      NSString* species = [speciesArray objectAtIndex:i];
                      NSString* grade = [gradeArray objectAtIndex:j];
                      NSDecimalNumber* speciesPercent = [speciesPercentArray objectAtIndex:i];
                      NSDecimalNumber* gradePercent = [gradePercentArray objectAtIndex:j];
                      
                        uniqueID = [NSString stringWithFormat:@"%@_%@_%@", species, grade, avoid];
                        NSArray *tmpDictDataForID = [combinationsOfPieces valueForKey:uniqueID];
                          
                        NSInteger count = [[tmpDictDataForID objectAtIndex:0] integerValue];

                        NSDecimalNumber *prGrade = [[NSDecimalNumber alloc] initWithDouble:([pile.measuredPileVolume doubleValue] * [gradePercent doubleValue])/100];
                            
                        NSDecimalNumber *volGrade = [[NSDecimalNumber alloc] initWithDouble: ([prGrade doubleValue] * [speciesPercent doubleValue])/100];
                            
                        float pieceRate = [self pieceRate:species withGrade:grade
                        withAvoid:[avoid isEqualToString:@"A"] forBlock:wastBlock withTimbermark:timbermark];
                        
                        double newVolume = [[tmpDictDataForID objectAtIndex:1] doubleValue] + [volGrade doubleValue];
                          
                        float volHa = [[tmpDictDataForID objectAtIndex:2] floatValue] + [[prGrade decimalNumberByDividingBy:pile.measuredPileArea] floatValue];
                        
                        float total = 0.0; // calculated at the end
                        
                        pieceData = [[NSArray alloc] initWithObjects:
                                           [[NSString alloc] initWithFormat:@"%ld",(long)count],
                                           [[NSString alloc] initWithFormat:@"%.02f", newVolume],
                                           [[NSString alloc] initWithFormat:@"%.003f", volHa] ,
                                           [[NSString alloc] initWithFormat:@"%.02f",pieceRate],
                                           [[NSString alloc] initWithFormat:@"%.02f", total], //total calulated at end
                                           nil];
                        [combinationsOfPieces setObject:pieceData forKey:uniqueID];
                  }
              }
          }//end of pile for loop
    }
    
    // for the 2nd table  // BUG?? - is it initialized with elements 0 ?
    NSMutableArray *cutCtrl = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    NSMutableArray *avoidable = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];

    //Coast sub total
    NSMutableArray *totalHem = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    NSMutableArray *totalSpeciesX = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    NSMutableArray *totalSpeciesY = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];

    //Interior sub total
    NSMutableArray *totalGrade1 = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    NSMutableArray *totalGrade2 = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    NSMutableArray *totalGrade4 = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    NSMutableArray *totalGrade5 = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    
    NSMutableArray *totalAvoidable = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    NSMutableArray *totalUnAvoidable = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    NSMutableArray *gradeZ = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    //below code is done as part of fix EFORWASTE-85
    NSMutableArray *grade6 = [[NSMutableArray alloc]initWithObjects:@"0",@"0",@"0",nil];
    
    //testing
    double tt1 = (0.1 / 0.5);
    NSLog(@"tt1=%0.003f", tt1);
    NSDecimalNumber *tt2 = [[NSDecimalNumber decimalNumberWithString:@"0.1"] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"0.5"]];
    NSLog(@"tt2=%0.003f", [tt2 doubleValue]);
 
    
    // get the keys out
    NSArray *keys = [combinationsOfPieces allKeys];
    
    // sort the keys
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    // reverse the order, Avoid=Y first
    //NSArray *sortedKeysReverse = [[sortedKeys reverseObjectEnumerator] allObjects];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    float updated1 = 0;
    float updated2 = 0;
    float updated3 = 0;
    // get the actual data in sorted keys order
    for(NSString *key in sortedKeys){
        
        NSArray *columnSortValues = [key componentsSeparatedByString:@"_"]; // AVOID_SPECIES_GRADE
        NSArray *dataForKey = [combinationsOfPieces objectForKey:key];      // [TOTALCOUNT, TOTALPIECEVOLUME, TOTALVOLHA, TOTALRATE, TOTAL, nil]
        
        
        
        td1 = [columnSortValues objectAtIndex:0];   // SPECIES
        //td2 = @"";                                  // PRODUCT
        td3 = [columnSortValues objectAtIndex:1];   // GRADE
        
        
        NSString *newDesignation = [[columnSortValues objectAtIndex:2] isEqualToString:@"A"] ? @"Y" : @"N";
        td4 = newDesignation;   // AVOID
        
        td5 = [dataForKey objectAtIndex:0];         // PIECES
        td6 = [dataForKey objectAtIndex:1];         // VOLUME
        
        
        NSNumber *vol = [f numberFromString:td6];
        NSNumber *blockArea = [wastBlock.userCreated integerValue] == 1 ? wastBlock.surveyArea : wastBlock.netArea;
        float volHa = [vol floatValue] / [blockArea floatValue];
        td7 = [[NSString alloc] initWithFormat:@"%0.003f", volHa];          // VOL/HA
        
        td8 = [dataForKey objectAtIndex:3];         // RATE
        
        
        
        //NSLog(@"species = %@, grade = %@, pieces = %@, volume = %@ , vol/ha = %@, rate = %@, total = %0.02f", td1, td3, td5, td6, td7, td8, [td6 floatValue] * [td8 floatValue]);

        
        NSDecimalNumber *rate = [[NSDecimalNumber alloc] initWithString:td8];
        NSDecimalNumber *volume = [[NSDecimalNumber alloc] initWithString:td6];
        float totalCalc = [[[rate decimalNumberByMultiplyingBy:volume] decimalNumberByRoundingAccordingToBehavior:behaviorD2] floatValue];
        //NSLog(@"rate = %@, volume = %@, total = %f", rate, volume, totalCalc);
       
        td9 = [[NSString alloc] initWithFormat:@"%0.02f", totalCalc];         // TOTAL calculation, because at this point RATE and VOL/HA are no longer changing
        
        //removed td2, column no longer needed
        row = [NSArray arrayWithObjects:td1, td3, td4, td5, td6, td7, td8, td9, nil];
        [rows addObject:row];
        
        
        // CREATE LAST ROWS - TO-DO
        //
        
        // total cut control
        if(![td3 isEqualToString:@"Z"] && ![td3 isEqualToString:@"6"]){
            updated1 = [[cutCtrl objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[cutCtrl objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[cutCtrl objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [cutCtrl replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [cutCtrl replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [cutCtrl replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
        // avoidable billable
        if( [td4 isEqualToString:@"Y"] ){
            updated1 = [[avoidable objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[avoidable objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[avoidable objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [avoidable replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [avoidable replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [avoidable replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
        
        // total hem
        if( ([td1 isEqualToString:@"HE"] || [td1 isEqualToString:@"BA"]) && [td3 isEqualToString:@"U"] && [td4 isEqualToString:@"Y"] ){
            updated1 = [[totalHem objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[totalHem objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[totalHem objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [totalHem replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [totalHem replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [totalHem replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
        // total all species X grade avoidable
        if( [td3 isEqualToString:@"X"] && [td4 isEqualToString:@"Y"] ){
            updated1 = [[totalSpeciesX objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[totalSpeciesX objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[totalSpeciesX objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [totalSpeciesX replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [totalSpeciesX replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [totalSpeciesX replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
        // total all species Y grade avoidable
        if( [td3 isEqualToString:@"Y"] && [td4 isEqualToString:@"Y"] ){
            updated1 = [[totalSpeciesY objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[totalSpeciesY objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[totalSpeciesY objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [totalSpeciesY replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [totalSpeciesY replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [totalSpeciesY replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }

        // total all species, grade 1, avoidable
        if( [td3 isEqualToString:@"1"] && [td4 isEqualToString:@"Y"] ){
            updated1 = [[totalGrade1 objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[totalGrade1 objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[totalGrade1 objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [totalGrade1 replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [totalGrade1 replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [totalGrade1 replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
        // total all species, grade 2, avoidable
        if( [td3 isEqualToString:@"2"] && [td4 isEqualToString:@"Y"] ){
            updated1 = [[totalGrade2 objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[totalGrade2 objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[totalGrade2 objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [totalGrade2 replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [totalGrade2 replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [totalGrade2 replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
        // total all species, grade 4, avoidable
        if( [td3 isEqualToString:@"4"] && [td4 isEqualToString:@"Y"] ){
            updated1 = [[totalGrade4 objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[totalGrade4 objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[totalGrade4 objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [totalGrade4 replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [totalGrade4 replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [totalGrade4 replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }

        // total all species, grade 5, avoidable
        if( [td3 isEqualToString:@"5"] && [td4 isEqualToString:@"Y"] ){
            updated1 = [[totalGrade5 objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[totalGrade5 objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[totalGrade5 objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [totalGrade5 replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [totalGrade5 replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [totalGrade5 replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
        // total avoidable
        //code below as part of the fix EFORWASTE-85
        if( [td4 isEqualToString:@"Y"] && ![td3 isEqualToString:@"Z"] && ![td3 isEqualToString:@"6"] ){
            updated1 = [[totalAvoidable objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[totalAvoidable objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[totalAvoidable objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [totalAvoidable replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [totalAvoidable replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [totalAvoidable replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
        // total unavoidable
        // code below as part of the fix EFORWASTE-85
        if( [td4 isEqualToString:@"N"] && ![td3 isEqualToString:@"Z"] && ![td3 isEqualToString:@"6"]){
            updated1 = [[totalUnAvoidable objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[totalUnAvoidable objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[totalUnAvoidable objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [totalUnAvoidable replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [totalUnAvoidable replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [totalUnAvoidable replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
        // grade Z removed from 'All' category and new line entry below 'total unavoidable' titled 'Z-Grade'
        if( [td3 isEqualToString:@"Z"]){
            updated1 = [[gradeZ objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[gradeZ objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[gradeZ objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [gradeZ replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [gradeZ replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [gradeZ replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        
        }
        // below code is done as part of fix for EFORWASTE-85
        if([td3 isEqualToString:@"6"]){
            updated1 = [[grade6 objectAtIndex:0] floatValue] + [td5 floatValue];
            updated2 = [[grade6 objectAtIndex:1] floatValue] + [td6 floatValue];
            updated3 = [[grade6 objectAtIndex:2] floatValue] + [td7 floatValue];
            
            [grade6 replaceObjectAtIndex:0 withObject:[[NSString alloc] initWithFormat:@"%.f",updated1]];
            [grade6 replaceObjectAtIndex:1 withObject:[[NSString alloc] initWithFormat:@"%.02f",updated2]];
            [grade6 replaceObjectAtIndex:2 withObject:[[NSString alloc] initWithFormat:@"%.003f",updated3]];
        }
        
    }
    
    
    
    NSArray *table2 = nil;
    
    if ([wastBlock.regionId integerValue] == CoastRegion){
        
        table2 = [[NSArray alloc] initWithObjects:
                  [NSArray arrayWithArray:cutCtrl],
                  [NSArray arrayWithArray:totalHem],
                  [NSArray arrayWithArray:totalSpeciesX],
                  [NSArray arrayWithArray:totalSpeciesY],
                  [NSArray arrayWithArray:totalAvoidable],
                  [NSArray arrayWithArray:totalUnAvoidable],
                  [NSArray arrayWithArray:gradeZ],
                  nil];
    }else if([wastBlock.regionId integerValue] == InteriorRegion){
        
        table2 = [[NSArray alloc] initWithObjects:
                  [NSArray arrayWithArray:cutCtrl],
                  [NSArray arrayWithArray:totalGrade1],
                  [NSArray arrayWithArray:totalGrade2],
                  [NSArray arrayWithArray:totalGrade4],
                  [NSArray arrayWithArray:totalGrade5],
                  [NSArray arrayWithArray:totalAvoidable],
                  [NSArray arrayWithArray:totalUnAvoidable],
                  [NSArray arrayWithArray:gradeZ],
                  [NSArray arrayWithArray:grade6],//code as part of the fix EFORWASTE-85
                  nil];
    }
    
    
    NSArray *bothTables = [[NSArray alloc] initWithObjects:[NSArray arrayWithArray:rows], table2, nil];
    
    
    return bothTables;
}
- (NSDictionary*) CalculateDataTable2:(WasteBlock *)wastBlock{
    
    /*
     // Do we allways know that we will get a wastBlock
     if(!wastBlock){
     NSLog(@"Error in CalculateData - wastBlock=nil");
     return nil;
     }
     */
        
    // TEMPORARY WHILE LOGIC NOT IMPLEMENTED - REMOVE WHEN DONE
    //
    // rows
    NSArray *keys = [NSArray arrayWithObjects:@"row1", @"row2", @"row3", @"row4", @"row5", @"row6", @"row7", nil];
    
    // table data
    NSArray *r = [NSArray arrayWithObjects:@"td1", @"td2", @"td3", @"td4", @"td5",@"td6", @"td7", nil];
    
    // values
    NSArray *objects = [NSArray arrayWithObjects:r, r, r, r, r, r, r, nil];  // ! has to be as many as rows
    
    NSDictionary *dataT2 = [NSDictionary dictionaryWithObjects:objects
                                                       forKeys:keys];
    for (id key in dataT2) {
        NSLog(@"ROW: %@, DATA: %@", key, [dataT2 objectForKey:key]);
    }
    //
    // END OF TEMPORARY
    
    
    
    return dataT2;
    
    
}

/*
 creates the HTML string out of tableData
 */
- (NSString*) createRowsForTable1:(NSArray*)data{
    
    NSError *errorForHTML;
    NSString *tmpPath, *rowHTML = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempFilePath =[documentsDirectory stringByAppendingString:@"/ReportTemplate/"];
    
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"ROW_2" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"ROW_2.html"];
    
    rowHTML = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    //for some reason the file isn't refreshing
    rowHTML = @"<tr><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td class=\"rightAlignment\">%@</td><td class=\"rightAlignment\">%@</td><td class=\"rightAlignment\">%@</td><td class=\"rightAlignment\">%@</td></tr>";
    
    // LOAD DATA INTO ROWS FOR TABLE 1
    //
    NSMutableString* ROWS = [[NSMutableString alloc] init];
    NSString* ROW = [[NSString alloc] init];
    NSString *td1, *td3, *td4, *td5, *td6, *td7, *td8, *td9 = [[NSString alloc] init];
    //removed *td2 as column was not needed
    for (int rowID=0; rowID<[data count]; rowID++)
    {
        // if key instanceof nsstring
        // do stuff
        // else
        // nslog(error in reading keys)
        
        td1 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:0];
        //td2 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:1];
        td3 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:1];
        td4 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:2];
        td5 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:3];
        td6 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:4];
        td7 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:5];
        td8 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:6];
        td9 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:7];
        
        
        
        
        // actual HTML row with inserted values
        ROW = [NSString stringWithFormat:rowHTML, td1, td3, td4, td5, td6, td7, td8, td9];
        
        // all the rows with values put together
        [ROWS appendString:ROW];
    }
    
    return ROWS;
    
}
- (NSArray*) createColumnsForTable2:(NSArray*)data withTotalColumn:(NSArray*)totalColumn wasteBlock:(WasteBlock*)wasteBlock{ // data = [ [td5, td6, td7], [td5, td6, td7], ... ]  // for each row
    
    NSError *errorForHTML;
    NSString *tmpPath, *colHTML = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempFilePath =[documentsDirectory stringByAppendingString:@"/ReportTemplate/"];
    
    // LOAD COLUMN TEMPLATE (tabledata - td)
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"TD_2" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"TD_2.html"];
    colHTML = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // LOAD DATA INTO COLUMNS FOR TABLE 2_2
    //
    NSMutableArray *COLUMNS = [[NSMutableArray alloc] init];
    NSString *COLUMN = [[NSString alloc] init];
    NSString *td1, *td2, *td3, *td4, *td5, *td6, *td7 = [[NSString alloc] init];
    for (int rowID=0; rowID<[data count]; rowID++)
    {
        // if key instanceof nsstring
        // do stuff
        // else
        // nslog(error in reading keys)

        //reset the td7 str
        td7 = @"";
        
        if( [wasteBlock.regionId integerValue] == CoastRegion){
            switch (rowID) {
                case 0:
                    td1 = @"";
                    td7 = @"N/A";
                    break;
                case 1:
                    td1 = @"U";
                    break;
                case 2:
                    td1 = @"X";
                    break;
                case 3:
                    td1 = @"Y";
                    break;
                case 4:
                    td1 = @"All";
                    break;
                case 5:
                    td1 = @"All";
                    td7 = @"N/A";
                    break;
                case 6:
                    td1 = @"Z";
                    td7 = @"N/A";
                    break;
                default:
                    break;
            }
            
        }else if([wasteBlock.regionId integerValue] == InteriorRegion){
            switch (rowID) {
                case 0:
                    td1 = @"";
                    td7 = @"N/A";
                    break;
                case 1:
                    td1 = @"1";
                    break;
                case 2:
                    td1 = @"2";
                    break;
                case 3:
                    td1 = @"4";
                    break;
                case 4:
                    td1 = @"5";
                    break;
                case 5:
                    td1 = @"All";
                    break;
                case 6:
                    td1 = @"All";
                    td7 = @"N/A";
                    break;
                case 7:
                    td1 = @"Z";
                    td7 = @"N/A";
                    break;
                    //case 8 as part of fix EFORWASTE-85
                case 8:
                    td1 = @"6";
                    td7 = @"N/A";
                    break;
                default:
                    break;
            }
            
        }
        
        td2 = @"";
        
        td3 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:0];
        td4 = [[NSString alloc] initWithFormat:@"%.02f", [[(NSArray*)[data objectAtIndex:rowID] objectAtIndex:1] floatValue]];
        td5 = [[NSString alloc] initWithFormat:@"%.02f",[[(NSArray*)[data objectAtIndex:rowID] objectAtIndex:2] floatValue]];
        
        td6 = @"";

        if ([td7 isEqualToString:@""]){
            td7 = [[NSString alloc] initWithFormat:@"$%.02f", [[totalColumn objectAtIndex:rowID] floatValue]];
        }
        
        // actual HTML row with inserted values
        COLUMN = [NSString stringWithFormat:colHTML, td1, td2, td3, td4, td5, td6, td7];

        // all the rows with values put together
        [COLUMNS addObject:COLUMN]; // add to array of columns
    }
    
    
    return COLUMNS;
    
}


// HELP
- (BOOL)stringHasC:(NSString*)theString{
    
    NSString *uppedString = [theString uppercaseString];
    
    BOOL hasC = !([uppedString rangeOfString:@"C"].location == NSNotFound);
    
    //NSLog(@"string = %@", uppedString);
    //NSLog(@"hasC = %@",  hasC ? @"YES" : @"NO");
    
    return hasC;
}

- (float)pieceRate:(NSString*)species withGrade:(NSString*)grade withAvoid:(BOOL)avoid forBlock:(WasteBlock*)wasteBlock withTimbermark:(Timbermark*)timbermark{

    if (!avoid){
        return 0.0;
    }else{
        
       if(!timbermark){
            NSLog(@"Missing primary timbermark");
            return 0.0;
        }
        
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        
        
        if(( [species isEqualToString:@"HE"] && [grade isEqualToString:@"U"] ) ||
           ([species isEqualToString:@"BA"] && [grade isEqualToString:@"U"])){
            return [timbermark.hembalWMRF floatValue];
        }
        else if( [grade isEqualToString:@"6"] ){
            return 0.0;
        }
        else if( [grade isEqualToString:@"Z"] ){
            return 0.0;
        }
        else if( [grade isEqualToString:@"W"] ||
                (![grade isEqualToString:@"4"] && ![grade isEqualToString:@"5"] && [wasteBlock.regionId integerValue] == InteriorRegion && ([species isEqualToString:@"AS"]||
                                                                                                                                            [species isEqualToString:@"BI"]||
                                                                                                                                            [species isEqualToString:@"CO"]||
                                                                                                                                            [species isEqualToString:@"AL"]||
                                                                                                                                            [species isEqualToString:@"MA"]||
                                                                                                                                            [species isEqualToString:@"OT"]||
                                                                                                                                            [species isEqualToString:@"AR"]||
                                                                                                                                            [species isEqualToString:@"WI"])) ){
            return [timbermark.deciduousWMRF floatValue];
        }
        else if( [grade isEqualToString:@"X"] ){
            return [timbermark.xWMRF floatValue];
        }
        else if( [grade isEqualToString:@"Y"] || [grade isEqualToString:@"4"] || [grade isEqualToString:@"5"]){
            return [timbermark.yWMRF floatValue];
        }
        else{
            return [timbermark.allSppJWMRF floatValue];
        }
    }
}

- (float) currentPieceTotalFrom:(float)pieceVolume andRate:(float)pieceRate{
    return (pieceVolume * pieceRate);
}

- (NSArray*) createCalculateTotalColumn:(NSArray*) data wasteBlock:(WasteBlock*)wasteBlock{
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    //added totalGrade6 variable as part of fix EFORWASTE-85
    double totalCC = 0.0, totalAvoid = 0.0, totalHeBaU = 0.0, totalX = 0.0, totalY = 0.0, totalG1 = 0.0, totalG2 = 0.0, totalG4 = 0.0, totalG5 = 0.0,totalUnvoid = 0.0, totalGradeZ = 0.0, totalGrade6 = 0.0;
    NSString *td1, *td3, *td4, *td5, *td6, *td7, *td8, *td9 = [[NSString alloc] init];
    
    for (int rowID=0; rowID<[data count]; rowID++)
    {
        td1 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:0];   // SPECIES
        //td2 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:1];   // PRODUCT
        td3 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:1];   // GRADE
        
        td4 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:2];   // AVOID
        td5 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:3];   // PIECES
        td6 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:4];   // VOLUME
        
        td7 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:5];   // VOL/HA
        td8 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:6];   // RATE
        td9 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:7];   // TOTAL
        
    
        // total cut control
        if(![td3 isEqualToString:@"Z"] && ![td3 isEqualToString:@"6"]){
            totalCC += [[f numberFromString:td9] floatValue];
        }
        //line below was added as part of fix EFORWASTE-85
        if( [td4 isEqualToString:@"Y"] && ![td3 isEqualToString:@"Z"] && ![td3 isEqualToString:@"6"]){
            // avoidable billable
            totalAvoid += [[f numberFromString:td9] floatValue];
        }else{
            // total unavoidable
            totalUnvoid += [[f numberFromString:td9] floatValue];
        }
        
        // total hem
        if( ([td1 isEqualToString:@"HE"] || [td1 isEqualToString:@"BA"]) && [td3 isEqualToString:@"U"] && [td4 isEqualToString:@"Y"] ){
            totalHeBaU += [[f numberFromString:td9] floatValue];
            NSLog(@"total hembai = %0.2f", totalHeBaU);
        }
        
        // total all species
        if( [td3 isEqualToString:@"X"] ){
            totalX += [[f numberFromString:td9] floatValue];
        }
        
        // total all species
        if( [td3 isEqualToString:@"Y"] ){
            totalY += [[f numberFromString:td9] floatValue];
        }
        
        // total all species
        if( [td3 isEqualToString:@"1"] ){
            totalG1 += [[f numberFromString:td9] floatValue];
        }

        // total all species
        if( [td3 isEqualToString:@"2"] ){
            totalG2 += [[f numberFromString:td9] floatValue];
        }

        // total all species
        if( [td3 isEqualToString:@"4"] ){
            totalG4 += [[f numberFromString:td9] floatValue];
        }

        // total all species
        if( [td3 isEqualToString:@"5"] ){
            totalG5 += [[f numberFromString:td9] floatValue];
        }
        
        //total for grade Z
        if([td3 isEqualToString:@"Z"]) {
            totalGradeZ +=[[f numberFromString:td9] floatValue];
        }
        //below code is part of fix EFORWASTE-85
        //total for grade 6
        if([td3 isEqualToString:@"6"]) {
            totalGrade6 +=[[f numberFromString:td9] floatValue];
        }
    }
    
    
    if([wasteBlock.regionId integerValue] == CoastRegion){
        
        return [[NSArray alloc] initWithObjects:
                [NSNumber numberWithDouble:totalCC],
                [NSNumber numberWithDouble:totalHeBaU],
                [NSNumber numberWithDouble:totalX],
                [NSNumber numberWithDouble:totalY],
                [NSNumber numberWithDouble:totalAvoid],
                [NSNumber numberWithDouble:totalUnvoid],
                [NSNumber numberWithDouble:totalGradeZ],
                nil];
    }else if([wasteBlock.regionId integerValue] == InteriorRegion){
        
        return [[NSArray alloc] initWithObjects:
                [NSNumber numberWithDouble:totalCC],
                [NSNumber numberWithDouble:totalG1],
                [NSNumber numberWithDouble:totalG2],
                [NSNumber numberWithDouble:totalG4],
                [NSNumber numberWithDouble:totalG5],
                [NSNumber numberWithDouble:totalAvoid],
                [NSNumber numberWithDouble:totalUnvoid],
                [NSNumber numberWithDouble:totalGradeZ],
                [NSNumber numberWithDouble:totalGrade6], //code is part of fix EFORWASTE-85
                nil];
    }
    
    return nil;

}

- (NSString*) createNotesForStratumsIn:(WasteBlock*)theBlock{
    
    NSMutableString* NOTES = [[NSMutableString alloc] init];
    NSSortDescriptor *sortStratums = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
    NSArray *sortedStratums = [theBlock.blockStratum sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortStratums]];
    
    for(WasteStratum *stratum in sortedStratums)
    {
        
        if(stratum.notes != nil)
        {
            if(![stratum.notes isEqualToString:@""]){
                NSString *htmlNote = [[NSString alloc] initWithFormat:@"<p>%@. %@</p>",stratum.stratum, stratum.notes];
                [NOTES appendString:htmlNote];
            }
        }
        
       // NSLog(@"<p>%@. %@</p>",stratum.stratum, stratum.notes);
    }
    
    
    
    
    return  [NSString stringWithString:NOTES];
}



@end
