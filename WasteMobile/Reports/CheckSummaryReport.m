//
//  CheckSummaryReport.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-08-25.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "CheckSummaryReport.h"
#import "WasteBlock.h"
#import "WasteStratum.h"

#import "WastePlot.h"
#import "WastePiece.h"
#import "BorderlineCode.h"
#import "ScaleSpeciesCode.h"
#import "MaterialKindCode.h"
#import "WasteClassCode.h"
#import "TopEndCode.h"
#import "ButtEndCode.h"
#import "ScaleGradeCode.h"
#import "DecayTypeCode.h"
#import "CommentCode.h"
#import "WasteStratum.h"
#import "CheckerStatusCode.h"
#import "WasteCalculator.h"

@implementation CheckSummaryReport


-(void) generateReportByStratum:(WasteStratum *)wasteStratum
{
}

-(void) generateReportByBlock:(WasteBlock *)wasteBlock
{
  
    [super checkReportFolder];
    NSError *error = nil;

    /*
  
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Testing" attributes:nil];
    NSData *data = [str dataFromRange:(NSRange){0, [str length]} documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} error:&error];

    if(error != nil)
    {
        NSLog(@"Failed to create persistent store. Error %@.", error);
        abort();
    }
    
    [data writeToFile:@"/WasteReports/test_report.rtf" atomically:YES];

   */
    
    // Figure out destination name (in public docs dir)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *zippedName = @"/WasteReports/restingReport.rtf";
    NSString *zippedPath = [documentsDirectory stringByAppendingPathComponent:zippedName];
    
    // Check if file already exists (unless we force the write)
    if ( [[NSFileManager defaultManager] fileExistsAtPath:zippedPath]) {
        NSLog(@"File exists already");
        abort();
    }
    
    
    
    // Export to data buffer
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Testing" attributes:nil];
    NSData *data = [str dataFromRange:(NSRange){0, [str length]} documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} error:&error];

    
    
    
    
    
    if (data == nil) abort();
    
    // Write to disk
    [data writeToFile:zippedPath atomically:YES];
    

}


-(GenerateOutcomeCode) generateReport:(WasteBlock *)wastBlock suffix:(NSString *)suffix replace:(BOOL)replace{

    NSLog(@"Genereate check summary report");

    [super checkReportFolder];


    NSError *error = nil;
    
    
    // check if we got WasteBlock
    if(wastBlock==nil){
        NSLog(@"CheckSummaryReport-wasteBlock=nil");
        return Fail_Unknown;
    }
    
    
    // Figure out destination name (in public docs dir)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempFilePath =[documentsDirectory stringByAppendingString:@"/ReportTemplate/"];
    
    if( ![suffix isEqualToString:@""]){
        suffix = [NSString stringWithFormat:@"_%@", [suffix stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    }
    
    NSString *zippedName = [NSString stringWithFormat: @"%@_CheckSummary%@.rtf",[super getReportFilePrefix:wastBlock], suffix];
    NSString *zippedPath = [documentsDirectory stringByAppendingPathComponent:zippedName];
    
    NSLog(@" zippedPath = %@ ", zippedPath ); // test
    
    // Check if file already exists (unless we force the write)
    if ( [[NSFileManager defaultManager] fileExistsAtPath:zippedPath] && !replace) {
        NSLog(@"File exists already");
        return Fail_Filename_Exist;
    }
    
    

    
    
    
    // PREPARE TEMPLATES FOR BUILDING THE HTML
    //
    //NSString *path = [[NSBundle mainBundle] pathForResource: @"REPORT" ofType: @"html"];
    NSString *path = [tempFilePath stringByAppendingString:@"REPORT.html"];
    NSError *errorForHTML;
    NSString *tmpPath, *newHTML, *NOTE, *CSS, *TITLE, *T1, *T2, *T3, *FOOTER = [[NSString alloc] init];

    
    // LOAD STYLE TEMPLATE
    tmpPath = [[NSBundle mainBundle] pathForResource: @"CSS_1" ofType: @"html"];
    CSS = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // LOAD TITLE TEMPLATE
    tmpPath = [[NSBundle mainBundle] pathForResource: @"TITLE" ofType: @"html"];
    TITLE = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    TITLE = [NSString stringWithFormat:TITLE, @"Waste Check Summary Report" ];
    
    // LOAD NOTE TEMPLATE
    
    // Get the note from the stratum
    
    NSSet *tmpStratums = [wastBlock blockStratum];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
    NSArray *sortedStratums = [tmpStratums sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    NSString *straNote = @"";
    for (WasteStratum *st in sortedStratums){
        if(st.notes){
            straNote = [NSString stringWithFormat:@"%@<BR />%@ - %@", straNote, st.stratum, st.notes];
        }
    }
    
    tmpPath = [[NSBundle mainBundle] pathForResource: @"NOTE" ofType: @"html"];
    NOTE = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

    if (!wastBlock.notes){
        NOTE = [NSString stringWithFormat:NOTE, straNote];
    }else{
        NOTE = [NSString stringWithFormat:NOTE, [NSString stringWithFormat:@"Block - %@ <BR /> %@ ", wastBlock.notes, straNote]];
    }
    
    // LOAD FOOTER TEMPLATE
    FOOTER = [self getFooter:wastBlock note:NOTE];

    // SUBTITLE FOR TABLES
    NSString *subtitle = [[NSString alloc] init];
    
    

    
    // TABLE 1 CREATION
    //
    
    // load the rows html
    NSArray *dataForTable1 = [self CalculateDataTable1:wastBlock];
    NSString *rowsHTML = [self createRowsForTable1:dataForTable1];

    // load the HTML template
    subtitle = @"Plot Results Summary";
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"TABLE1_1" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"TABLE1_1.html"];

    T1 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // define the table head
    NSString *th1, *th2, *th3, *th4, *th5, *th6, *th7, *th8, *th9, *th10 = [[NSString alloc] init];
    th1 = @"Plot";
    th2 = @"Stratum";
    th3 = @"Survey</br>Pieces";
    th4 = @"Check</br>Pieces";
    th5 = @"Grade</br>Changes";
    th6 = @"Species</br>Changes";
    th7 = @"Waste</br>Class";
    th8 = @"Length</br>Changes";
    th9 = @"Radii</br>Changes";
    th10 = @"Missed/</br>Extra Pieces";
    
    
    
    // insert the table head and ROWS (convert ROWS to nonmutable first)
    T1 = [NSString stringWithFormat:T1, [[NSString alloc] initWithFormat:@"%@", [wastBlock.reportingUnit stringValue]], wastBlock.blockNumber, subtitle, th1, th2, th3, th4, th5, th6, th7, th8, th9, th10, rowsHTML ];

    
    
    
    
    // TABLE 2 CREATION
    //
    // load the rows html
    NSArray *dataForTable2 = [self CalculateDataTable2:wastBlock];
    rowsHTML = [self createRowsForTable2:dataForTable2];
    
    // load the HTML template
    subtitle = @"Block and Stratum Volume Summary (Weighted)";
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"TABLE1_2" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"TABLE1_2.html"];
    
    T2 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // define the table head
    th1 = @"Stratum";
    th2 = @"Plot";
    th3 = @"Survey</br>Vol.(m3)";
    th4 = @"Check</br>Vol.(m3)";
    th5 = @"Diff(%)";
    th6 = @"Pass / Fail";
    
    // insert the table head and ROWS (convert ROWS to nonmutable first)
    T2 = [NSString stringWithFormat:T2, subtitle, th1, th2, th3, th4, th5, th6, [NSString stringWithString:rowsHTML] ];
    
    
    

    
    
    
    // TABLE 3 CREATION
    //
    
    // load the rows html
    NSArray *dataForTable3 = [self CalculateDataTable3:wastBlock];
    rowsHTML = [self createRowsForTable2:dataForTable3];

    // load the HTML template
    subtitle = @"Block and Stratum Value Summary (Weighted)";
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"TABLE1_3" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"TABLE1_3.html"];
    T3 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // define the table head
    th1 = @"Stratum";
    th2 = @"Plot";
    th3 = @"Survey</br>Val.($)";
    th4 = @"Check</br>Val.($)";
    th5 = @"Diff(%)";
    th6 = @"Pass / Fail";
    
    // insert the table head and ROWS (convert ROWS to nonmutable first)
    T3 = [NSString stringWithFormat:T3, subtitle, th1, th2, th3, th4, th5, th6, [NSString stringWithString:rowsHTML] ];
    
    
    
    
    
    // STICH TOGETHER THE FORM FILE: HMTL = CSS + TITLE + T1 + T2 + T3 + NOTE + FOOTER
    //
    NSMutableString* stichingHTML = [[NSMutableString alloc] init];
    [stichingHTML appendString:CSS];
    [stichingHTML appendString:TITLE];
    [stichingHTML appendString:T1];
    [stichingHTML appendString:T2];
    [stichingHTML appendString:T3];
    [stichingHTML appendString:FOOTER];
    
    
    // convert back to normal string from mutable
    newHTML = [NSString stringWithString:stichingHTML];
    
    
    
    // SAVE HTML FILE - save the NSString that contains the HTML to a file
    [newHTML writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&errorForHTML];
    if(errorForHTML){
        NSLog(@"Error in saving HTML file = ");
    }
    
    
    // Create URL for HTML file in application bundle
    //NSURL *htmlInput = [[NSBundle mainBundle] URLForResource: @"REPORT" withExtension:@"html"];
    NSURL *htmlInput = [[NSURL alloc] initFileURLWithPath:[tempFilePath stringByAppendingString:@"REPORT.html"]];
    
    // Create attributed string from HTML
    NSAttributedString *str = [[NSAttributedString alloc]
                                    initWithFileURL:htmlInput
                                            options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                 documentAttributes:nil
                                              error:nil
                               ];
    
    
    // Export to data buffer, creating a RTF
    NSData *data = [str dataFromRange:(NSRange){0, [str length]}
                   documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType}
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
    [data writeToFile:zippedPath atomically:YES];

    NSLog(@"Check summary report is generated");

    
    return Successful;
}


/*
 takes the object containing data
 puts the data into the required format (Array)
 * also checks for any data missing and fills it with @""
 */
- (NSArray*) CalculateDataTable1:(WasteBlock *)wastBlock{

    //NSLog(@"GENERATE TABLE 1");
    

    NSString *td1, *td2, *td3, *td4, *td5, *td6, *td7, *td8, *td9, *td10 = [[NSString alloc] init];
    
    NSArray *row = [[NSArray alloc] init];
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    @try
    {
        NSSet *tmpStratums = [wastBlock blockStratum];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
        NSArray *sortedStratums = [tmpStratums sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        NSSortDescriptor *sortPlots = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES]; // is key ok ? does it actually sort according to it / TEST - @"pieceNumber"
        NSArray *sortedPlots = [[NSArray alloc] init];
        
        
        NSSortDescriptor *sortPieces = [[NSSortDescriptor alloc ] initWithKey:@"pieceNumber" ascending:YES]; // is key ok ? does it actually sort according to it / TEST - @"pieceNumber"
        NSArray *sortedPieces = [[NSArray alloc] init];
        
        
        int sumSurveyPieces = 0;
        int sumCheckPieces = 0;
        int sumGrades = 0;
        int sumSpecies = 0;
        int sumWasteClass = 0;
        int sumLength = 0;
        int sumRadii = 0;
        int sumMissedPiece = 0;
        WastePiece *previousPiece = nil;
        int surveyPieces = 0;
        int checkPieces = 0;
        int grades = 0;
        int species = 0;
        int wasteClass = 0;
        int length = 0;
        int radii = 0;
        int missedPiece = 0;
        
        // we are relying on the fact that stratums,plots,pieces should be initialized upon receiving the wastBlock
        // all numbers are initialized
        // check everything else
        for(WasteStratum *stratum in sortedStratums)
        {
            
            sortedPlots = [stratum.stratumPlot sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPlots]];
            
            //NSLog(@"STRATUM = %@", stratum.stratum);
            
            // TD2
            td2 = stratum.stratum ? stratum.stratum : @"";
         
            for(WastePlot *plot in sortedPlots)
            {
                
                
                sortedPieces = [plot.plotPiece sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPieces]];
                
                
                // TD1
                td1 = plot.plotNumber ? [plot.plotNumber stringValue] : @"";
                //NSLog(@"PLOT = %@", td1);
                
                
                for(WastePiece *piece in sortedPieces) // check every piece in this plot, for which columns can it be counted
                {
                    
                    /*
                    NSLog(@"Piece \n");
                    NSLog(@"pieceNumber = %@", piece.pieceNumber);
                    NSLog(@"pieceID = %@", piece.piece);
                    NSLog(@"piece status = %@", piece.pieceCheckerStatusCode.checkerStatusCode);
                    NSLog(@"piece grade = %@", piece.pieceScaleGradeCode.scaleGradeCode);
                    NSLog(@"piece species = %@", piece.pieceScaleSpeciesCode.scaleSpeciesCode);
                    NSLog(@"piece waste = %@", piece.pieceWasteClassCode.wasteClassCode);
                    NSLog(@"\n");
                    */
                    
                    // TD3 - Survey pieces count = all pieces except those without pieceID
                    if(piece.pieceCheckerStatusCode.checkerStatusCode != nil && ! [self stringHasC: piece.pieceNumber]){
                        surveyPieces++;
                    }
                    
                    
                    // TD4 - Check pieces count // POTENTIAL BUG, comparing strings
                    if( (piece.pieceCheckerStatusCode!=nil && [piece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"1"]) && piece.piece ){
                        // dont count
                    }
                    else{
                        if( ! [self stringHasC: piece.pieceNumber  ] ){ // dont count changed pices, since they got accounted for in the "if" above
                            checkPieces++;
                        }
                    }
                    
                    
                    // if there arent any previousPieces then none are valid for adding
                    if(previousPiece != nil)
                    {
                        // TD5 // POTENTIAL BUG, comparing strings
                        // for the changed pieces - those with (c)
                        if( piece.pieceNumber!=nil && [self stringHasC: piece.pieceNumber] )
                        {
                            
                            
                            if(!piece.pieceScaleGradeCode && !previousPiece.pieceScaleGradeCode){
                                // dont count if both are nil, they havent changed
                            }
                            // counting nil cases too ( if original has code, and changed doesnt, then count it)
                            else if( (!piece.pieceScaleGradeCode && previousPiece.pieceScaleGradeCode) ||  (piece.pieceScaleGradeCode && !previousPiece.pieceScaleGradeCode)  ){
                                grades++;
                            }
                            // for those that have their grade changed
                            else if( ! [piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:previousPiece.pieceScaleGradeCode.scaleGradeCode]){
                                grades++;
                            }
                        }
                    
                        
                        // TD6 // POTENTIAL BUG, comparing strings
                        if( [self stringHasC: piece.pieceNumber] )
                        {
                            
                            
                            
                            if( (!piece.pieceScaleSpeciesCode && !previousPiece.pieceScaleSpeciesCode) ){
                                // dont count if both are nil, they havent changed
                            }
                            // counting nil cases too ( if original has code, and changed doesnt, then count it)
                            else if( (!piece.pieceScaleSpeciesCode && previousPiece.pieceScaleSpeciesCode) ||  (piece.pieceScaleSpeciesCode && !previousPiece.pieceScaleSpeciesCode)  ){
                                species++;
                            }
                            // for those that have their species changed
                            else if( ![piece.pieceScaleSpeciesCode.scaleSpeciesCode isEqualToString:previousPiece.pieceScaleSpeciesCode.scaleSpeciesCode] ){
                                species++;
                            }
                        }
                        
                        
                        // TD7 // POTENTIAL BUG, comparing strings
                        if( [self stringHasC: piece.pieceNumber] )
                        {
                            
                            if( (!piece.pieceWasteClassCode && !previousPiece.pieceWasteClassCode) ){
                                // dont count if both are nil, they havent changed
                            }
                            // counting nil cases too ( if original has code, and changed doesnt, then count it)
                            else if( (!piece.pieceWasteClassCode && previousPiece.pieceWasteClassCode) ||  (piece.pieceWasteClassCode && !previousPiece.pieceWasteClassCode)  ){
                                wasteClass++;
                            }
                            // for those that have their wasteclass changed
                            else if( ! [piece.pieceWasteClassCode.wasteClassCode isEqualToString:previousPiece.pieceWasteClassCode.wasteClassCode] ){
                                wasteClass++;
                            }
                        }
                        
                        // TD8
                        if( [self stringHasC: piece.pieceNumber] )
                        {

                            if( (!previousPiece.length && !piece.length) ){
                                // dont count if both are nil, they havent changed
                            }
                            // for those that have their length changed
                            else if( ! [piece.length isEqualToNumber: previousPiece.length] ){
                                length++;
                            }
                        }
                        
                        // TD9
                        if( [self stringHasC: piece.pieceNumber] )
                        {


                            
                            
                            
                            if( (!previousPiece.topDiameter && !piece.topDiameter) && (!previousPiece.buttDiameter && !piece.buttDiameter) ){
                                // dont count if both are nil, they havent changed
                            }
                            // one of the pieces was initialy nil, and now it has a value
                            else if( ((!previousPiece.topDiameter && piece.topDiameter) || (previousPiece.topDiameter && !piece.topDiameter)) ||
                                    ((!previousPiece.buttDiameter && piece.buttDiameter) || (previousPiece.buttDiameter && !piece.buttDiameter))
                            ){
                                radii++;
                            }
                            // for those that have their diameter value changed
                            // note: isEqualToNumber CANNOT accept nil values, if it does, the behavior is undefined
                            else if( (piece.topDiameter && previousPiece.topDiameter) && ![piece.topDiameter isEqualToNumber: previousPiece.topDiameter] ){
                                radii++;
                            }
                            else if( (piece.buttDiameter && previousPiece.buttDiameter) && ![piece.buttDiameter isEqualToNumber: previousPiece.buttDiameter]  ){
                                radii++;
                            }
                            
                            
                            
                        }
                    }
                    
                    
                    
                    // TD10
                    if(piece.pieceCheckerStatusCode.checkerStatusCode == nil){ // if nil, count him too
                        // POTENTIAL BUG, comparing strings
                        missedPiece++;
                    }
                    
                
                    
                    previousPiece = piece;
                }// end of pieces
                
                previousPiece = nil; // test
                
                td3 = [NSString stringWithFormat:@"%d", surveyPieces];
                td4 = [NSString stringWithFormat:@"%d", checkPieces];
                td5 = [NSString stringWithFormat:@"%d", grades];
                td6 = [NSString stringWithFormat:@"%d", species];
                td7 = [NSString stringWithFormat:@"%d", wasteClass];
                td8 = [NSString stringWithFormat:@"%d", length];
                td9 = [NSString stringWithFormat:@"%d", radii];
                td10 = [NSString stringWithFormat:@"%d", missedPiece];
                row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, td7, td8, td9, td10, nil];
                [rows addObject:row];
                
                // compound values for total calc
                sumSurveyPieces += surveyPieces;
                sumCheckPieces += checkPieces;
                sumGrades += grades;
                sumSpecies += species;
                sumWasteClass += wasteClass;
                sumLength += length;
                sumRadii += radii;
                sumMissedPiece += missedPiece;
                
                // reset counters for the next pieces (next row)
                surveyPieces = 0;
                checkPieces = 0;
                grades = 0;
                species = 0;
                wasteClass = 0;
                length = 0;
                radii = 0;
                missedPiece = 0;
                
            }// end of plots
        }// end for stratum
        
        
        
        // TOTAL ROW
        
        td1 = [NSString stringWithFormat:@"<b>TOTAL</b>"];
        td2 = [NSString stringWithFormat:@""];
        td3 = [NSString stringWithFormat:@"<b>%d</b>", sumSurveyPieces];
        td4 = [NSString stringWithFormat:@"<b>%d</b>", sumCheckPieces];
        td5 = [NSString stringWithFormat:@"<b>%d</b>", sumGrades];
        td6 = [NSString stringWithFormat:@"<b>%d</b>", sumSpecies];
        td7 = [NSString stringWithFormat:@"<b>%d</b>", sumWasteClass];
        td8 = [NSString stringWithFormat:@"<b>%d</b>", sumLength];
        td9 = [NSString stringWithFormat:@"<b>%d</b>", sumRadii];
        td10 = [NSString stringWithFormat:@"<b>%d</b>", sumMissedPiece];
        row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, td7, td8, td9, td10, nil];
        [rows addObject:row];
        
    }// end try
    @catch (NSException *ex) {
        NSLog(@"ERROR caught - in CheckSummaryReport-CalculateDataTable1:");
        NSLog(@"%@",ex);
    }
    
    
    return [NSArray arrayWithArray:rows];
}
- (NSArray*) CalculateDataTable2:(WasteBlock *)wastBlock{
    
    //NSLog(@"CALC DATA TABLE 2");
    
    NSString *td1, *td2, *td3, *td4, *td5, *td6 = [[NSString alloc] init];
    NSArray *row = [[NSArray alloc] init];
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    @try{
        NSSet *tmpStratums = wastBlock.blockStratum;
        NSSortDescriptor *sortStratums = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
        NSArray *sortedStratums = [tmpStratums sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortStratums]];
        
        
        NSSortDescriptor *sortPlots = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES]; // is key ok ? does it actually sort according to it
        NSArray *sortedPlots = [[NSArray alloc] init];
        
        
        NSSortDescriptor *sortPieces = [[NSSortDescriptor alloc ] initWithKey:@"piece" ascending:YES]; // is key ok ? does it actually sort according to it
        NSArray *sortedPieces = [[NSArray alloc] init];
        
        NSString *passFail = @"";
        for(WasteStratum *stratum in sortedStratums)
        {
            sortedPlots = [stratum.stratumPlot sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPlots]];
            
            //NSLog(@"STRATUM = %@", stratum.stratum);
            
            // TD1
            td1 = stratum.stratum ? stratum.stratum : @"";
            for(WastePlot *plot in sortedPlots)
            {
                
                sortedPieces = [plot.plotPiece sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPieces]];
                
                
                //NSLog(@"PLOT NUMBER = %@", [plot.plotNumber stringValue]);
                
                // TD2
                td2 = plot.plotNumber ? [plot.plotNumber stringValue] : @"";

                // calc pass/fail
                passFail = @"P";
                //NSDecimalNumber *absDiff = [self abs:diff];
                NSDecimalNumber *limit = [NSDecimalNumber decimalNumberWithString:@"10"];
                NSComparisonResult result = [plot.deltaAvoidY compare:limit];
                if (result == NSOrderedDescending)
                {
                    //NSLog(@"diff > limit");
                    
                    // FAIL
                    passFail = @"F";
                }
                td5 = [NSString stringWithFormat:@"%.1f%%", [plot.deltaAvoidY floatValue]];
                td6 = [NSString stringWithFormat:@"%@", passFail];
                td3 = [NSString stringWithFormat:@"%.03f", plot.surveyAvoidY.floatValue];
                td4 = [NSString stringWithFormat:@"%.03f", plot.checkAvoidY.floatValue];

                row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, nil];
                [rows addObject:row];
                
                
            }// end of plots

            
            if(stratum.checkAvoidY.floatValue < 0.005){
                td5 = @"";
                td6 = @"";
            }
            else{
                // calc pass/fail
                passFail = @"P";
                NSDecimalNumber *absDiff = [self abs:stratum.deltaAvoidY];
                NSDecimalNumber *limit = [NSDecimalNumber decimalNumberWithString:@"10"];
                NSComparisonResult result = [absDiff compare:limit];
                if (result == NSOrderedDescending)
                {
                    //NSLog(@"diff > limit");
                    
                    // FAIL
                    passFail = @"F";
                }
                
                td5 = [NSString stringWithFormat:@"%.1f%%", stratum.deltaAvoidY.floatValue];
                td6 = [NSString stringWithFormat:@"%@", passFail];
                
            }
            
            
            td2 = @"TOTAL";
            td3 = [NSString stringWithFormat:@"%.03f", stratum.surveyAvoidY.floatValue];
            td4 = [NSString stringWithFormat:@"%.03f", stratum.checkAvoidY.floatValue];
            
            row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, nil];
            
            if( sortedPlots.count != 0 ){
                [rows addObject:row]; // if no plots dont add
            }

        }// end for stratum
        
        
        // TOTAL ROW
        if(wastBlock.deltaAvoidY.floatValue < 0.005){
            td5 = @"";
            td6 = @"";
        }
        else{
           
            
            // calc pass/fail
            passFail = @"P";
            NSDecimalNumber *absDiff = [self abs:wastBlock.deltaAvoidY];
            NSDecimalNumber *limit = [NSDecimalNumber decimalNumberWithString:@"10"];
            NSComparisonResult result = [absDiff compare:limit];
            if (result == NSOrderedDescending)
            {
                passFail = @"F";
            }
            td5 = [NSString stringWithFormat:@"<b>%.1f%%</b>", wastBlock.deltaAvoidY.floatValue];
            td6 = [NSString stringWithFormat:@"<b>%@</b>", passFail];
        }

        
        td1 = [NSString stringWithFormat:@"<b>BLOCK</b>"];
        td2 = [NSString stringWithFormat:@"<b>TOTAL</b>"];
        td3 = [NSString stringWithFormat:@"<b>%.03f</b>", wastBlock.surveyAvoidY.floatValue];
        td4 = [NSString stringWithFormat:@"<b>%.03f</b>", wastBlock.checkAvoidY.floatValue];

        row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, nil];
        [rows addObject:row];
        
        return [NSArray arrayWithArray:rows];
    }
    @catch (NSException *ex) {
        NSLog(@"ERROR caught - in CheckSummaryReport-CalculateDataTable2:");
        NSLog(@"%@",ex);
    }
}
- (NSArray*) CalculateDataTable3:(WasteBlock *)wastBlock{
    /*
    NSLog(@"\n");
    NSLog(@"CALCULATE TABLE 3");
    NSLog(@"\n");
    */
    NSString *td1, *td2, *td3, *td4, *td5, *td6 = [[NSString alloc] init];
    NSArray *row = [[NSArray alloc] init];
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    @try{
        NSSet *tmpStratums = wastBlock.blockStratum;
        NSSortDescriptor *sortStratums = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
        NSArray *sortedStratums = [tmpStratums sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortStratums]];
        
        
        NSSortDescriptor *sortPlots = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES]; // is key ok ? does it actually sort according to it
        NSArray *sortedPlots = [[NSArray alloc] init];
        
        
        NSSortDescriptor *sortPieces = [[NSSortDescriptor alloc ] initWithKey:@"piece" ascending:YES]; // is key ok ? does it actually sort according to it
        NSArray *sortedPieces = [[NSArray alloc] init];
        
        //NSDecimalNumberHandler *behaviorD3 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        
        NSString *passFail = @"";
        for(WasteStratum *stratum in sortedStratums)
        {
            sortedPlots = [stratum.stratumPlot sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPlots]];
            
            //NSLog(@"STRATUM = %@", stratum.stratum);
            
            // TD1
            td1 = stratum.stratum ? stratum.stratum : @"";
            for(WastePlot *plot in sortedPlots)
            {
                
                sortedPieces = [plot.plotPiece sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPieces]];
                
                // TD2
                td2 = plot.plotNumber ? [plot.plotNumber stringValue] : @"";
                
                if(plot.checkAvoidY.floatValue < 0.005){
                    td5 = @"";
                    td6 = @"";
                }else{

                    
                    // calc pass/fail
                    passFail = @"P";
                    NSDecimalNumber *absDiff = [self abs:plot.deltaNetVal];
                    NSDecimalNumber *limit = [NSDecimalNumber decimalNumberWithString:@"10"];
                    NSComparisonResult result = [absDiff compare:limit];
                    if (result == NSOrderedDescending)
                    {
                        //NSLog(@"diff > limit");
                        
                        // FAIL
                        passFail = @"F";
                    }
                    
                    td5 = [NSString stringWithFormat:@"%.1f%%", plot.deltaNetVal.floatValue];
                    td6 = [NSString stringWithFormat:@"%@", passFail];
                    
                }

                
                

                
                
                td3 = [NSString stringWithFormat:@"$%.03f", plot.surveyNetVal.floatValue];
                td4 = [NSString stringWithFormat:@"$%.03f", plot.checkNetVal.floatValue];

                row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, nil];
                [rows addObject:row];
                
            }// end of plots
            
            
            if(stratum.checkAvoidY.floatValue < 0.005){
                td5 = @"";
                td6 = @"";
            }
            else{
                // calc pass/fail
                passFail = @"P";
                NSDecimalNumber *absDiff = [self abs:stratum.deltaNetVal];
                NSDecimalNumber *limit = [NSDecimalNumber decimalNumberWithString:@"10"];
                NSComparisonResult result = [absDiff compare:limit];
                if (result == NSOrderedDescending)
                {
                    //NSLog(@"diff > limit");
                    
                    // FAIL
                    passFail = @"F";
                }
                
                td5 = [NSString stringWithFormat:@"%.1f%%", stratum.deltaNetVal.floatValue];
                td6 = [NSString stringWithFormat:@"%@", passFail];
            
            }
            
            
            td2 = @"TOTAL";
            td3 = [NSString stringWithFormat:@"$%.03f", stratum.surveyNetVal.floatValue];
            td4 = [NSString stringWithFormat:@"$%.03f", stratum.checkNetVal.floatValue];

            row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, nil];
            
            if( sortedPlots.count != 0 ){
                [rows addObject:row]; // if no plots dont add
            }
            
            
            
        }// end for stratum
        
        
        // TOTAL ROW
        
        // calc diff
        
        if(wastBlock.checkAvoidY.floatValue < 0.005){
            td5 = @"";
            td6 = @"";
        }else{

            // calc pass/fail
            passFail = @"P";
            NSDecimalNumber *absDiff = [self abs:wastBlock.deltaNetVal];
            NSDecimalNumber *limit = [NSDecimalNumber decimalNumberWithString:@"10"];
            NSComparisonResult result = [absDiff compare:limit];
            if (result == NSOrderedDescending)
            {
                //NSLog(@"diff > limit");
                
                // FAIL
                passFail = @"F";
            }
            td5 = [NSString stringWithFormat:@"<b>%.1f%%</b>", wastBlock.deltaNetVal.floatValue];
            td6 = [NSString stringWithFormat:@"<b>%@</b>", passFail];
        
        }
        
        
        td1 = [NSString stringWithFormat:@"<b>BLOCK</b>"];
        td2 = [NSString stringWithFormat:@"<b>TOTAL</b>"];
        td3 = [NSString stringWithFormat:@"<b>$%.03f</b>", wastBlock.surveyNetVal.floatValue];
        td4 = [NSString stringWithFormat:@"<b>$%.03f</b>", wastBlock.checkNetVal.floatValue];

        row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, nil];
        [rows addObject:row];
        
        return [NSArray arrayWithArray:rows];
    }
    @catch (NSException *ex) {
        NSLog(@"ERROR caught - in CheckSummaryReport-CalculateDataTable3:");
        NSLog(@"%@",ex);
    }
}

/*
 creates the HTML string out of tableData
 */
- (NSString*) createRowsForTable1:(NSArray*)data{
    
    NSError *errorForHTML;
    NSString *tmpPath, *rowHTML = [[NSString alloc] init];
    
    tmpPath = [[NSBundle mainBundle] pathForResource: @"ROW1_1" ofType: @"html"];
    rowHTML = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    NSMutableString* ROWS = [[NSMutableString alloc] init];
    NSString* ROW = [[NSString alloc] init];
    NSString *td1, *td2, *td3, *td4, *td5, *td6, *td7, *td8, *td9, *td10 = [[NSString alloc] init];
    for (int rowID=0; rowID<[data count]; rowID++)
    {
        
        td1 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:0];
        td2 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:1];
        td3 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:2];
        td4 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:3];
        td5 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:4];
        td6 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:5];
        td7 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:6];
        td8 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:7];
        td9 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:8];
        td10 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:9];
        
        // actual HTML row with inserted values
        ROW = [NSString stringWithFormat:rowHTML, td1, td2, td3, td4, td5, td6, td7, td8, td9, td10];
        
        // all the rows with values put together
        [ROWS appendString:ROW];
    }
    
    return ROWS;
    
}

- (NSString*) createRowsForTable2:(NSArray*)data{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempFilePath =[documentsDirectory stringByAppendingString:@"/ReportTemplate/"];
    NSError *errorForHTML;
    NSString *tmpPath, *rowHTML = [[NSString alloc] init];
    
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"ROW1_2" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"ROW1_2.html"];
    rowHTML = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    NSMutableString* ROWS = [[NSMutableString alloc] init];
    NSString* ROW = [[NSString alloc] init];
    NSString *td1, *td2, *td3, *td4, *td5, *td6 = [[NSString alloc] init];
    for (int rowID=0; rowID<[data count]; rowID++)
    {
        
        td1 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:0];
        td2 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:1];
        td3 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:2];
        td4 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:3];
        td5 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:4];
        td6 = [(NSArray*)[data objectAtIndex:rowID] objectAtIndex:5];
        
        // actual HTML row with inserted values
        ROW = [NSString stringWithFormat:rowHTML, td1, td2, td3, td4, td5, td6];
        
        // all the rows with values put together
        [ROWS appendString:ROW];
    }
    
    return ROWS;
    
}




// HELPER
- (NSDecimalNumber *)abs:(NSDecimalNumber *)num {
    if ([num compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        // Number is negative. Multiply by -1
        NSDecimalNumber * negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1
                                                                          exponent:0
                                                                        isNegative:YES];
        return [num decimalNumberByMultiplyingBy:negativeOne];
    } else {
        return num;
    }
}
- (BOOL)stringHasC:(NSString*)theString{
    
    NSString *uppedString = [theString uppercaseString];
    
    BOOL hasC = !([uppedString rangeOfString:@"C"].location == NSNotFound);
    
    //NSLog(@"string = %@", uppedString);
    //NSLog(@"hasC = %@",  hasC ? @"YES" : @"NO");
    
    return hasC;
}


@end

