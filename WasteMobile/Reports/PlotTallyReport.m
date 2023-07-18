//
//  PlotTallyReport.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-05.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "PlotTallyReport.h"
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
#import "WasteBlock.h"
#import "WasteStratum.h"

static float originalVolumeValue;
static float checkVolumeValue;

@implementation PlotTallyReport

-(GenerateOutcomeCode) generateReport:(WasteBlock *)wastBlock withPlot:(WastePlot*)wastPlot suffix:(NSString *)subffix replace:(BOOL)replace{
    NSLog(@"Genereate plot tally report");
    
    [super checkReportFolder];
    NSError *error = nil;
    
    // Figure out destination name (in public docs dir)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if( ![subffix isEqualToString:@""]){
        subffix = [NSString stringWithFormat:@"_%@", [subffix stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    }
    
    NSString *zippedName = [NSString stringWithFormat: @"%@_%@_%@_PlotTallyReport%@.rtf",[super getReportFilePrefix:wastBlock], wastPlot.plotStratum.stratum, wastPlot.plotNumber, subffix];
    NSString *zippedPath = [documentsDirectory stringByAppendingPathComponent:zippedName];
    
    
    // Check if file already exists (unless we force the write)
    if ( [[NSFileManager defaultManager] fileExistsAtPath:zippedPath] && !replace) {
        NSLog(@"File exists already");
        return Fail_Filename_Exist;
    }
    
    
    // check if we got WasteBlock && WastePlot
    if(wastBlock==nil || wastPlot==nil){
        return Fail_Unknown;
    }
    
    NSString *tempFilePath =[documentsDirectory stringByAppendingString:@"/ReportTemplate/"];
    
    originalVolumeValue = 0.0;
    checkVolumeValue = 0.0;
    
    // PREPARE TEMPLATES FOR BUILDING THE HTML
    //
    //NSString *path = [[NSBundle mainBundle] pathForResource: @"REPORT" ofType: @"html"];
    NSString *path = [tempFilePath stringByAppendingString:@"REPORT.html"];
    NSError *errorForHTML;
    NSString *tmpPath, *newHTML, *rowHTML, *CSS, *TITLE, *T3_1, *FOOTER, *NOTE = [[NSString alloc] init];
    
    
    // LOAD STYLE TEMPLATE
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"CSS_3" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"CSS_3.html"];
    CSS = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // LOAD TITLE TEMPLATE
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"TITLE" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"TITLE.html"];
    TITLE = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    if([wastBlock.userCreated integerValue] == 1 ){
        TITLE = [NSString stringWithFormat:TITLE, @"Waste Plot Tally Card"];
    }else{
        TITLE = [NSString stringWithFormat:TITLE, @"Waste Audit Plot Tally Card"];
    }
    
    // LOAD ROWS TEMPLATE
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"ROW_3" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"ROW_3.html"];
    rowHTML = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // LOAD NOTE TEMPLATE
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"NOTE" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"NOTE.html"];
    NOTE = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    NOTE = [NSString stringWithFormat:NOTE, [NSString stringWithFormat:@"<p>Plot - %@</p>%@", (wastPlot.notes ? wastPlot.notes : @""), [self createNotesForPiecesIn:wastPlot]]];
    
    // LOAD FOOTER TEMPLATE
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];

    FOOTER = [self getFooter:wastBlock note:NOTE];
    
    
    
    
    // TABLE3_1 CREATION
    //
    
    // put the data into the required format
    NSArray *dataForTable1 = [self CalculateDataTable1:wastBlock withPlot:wastPlot];
    
    // create the rowsHtmlString from the data format
    NSString *rowsHTML = [self createRowsForTable1:dataForTable1 wasteBlock:wastBlock];
    
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"TABLE3_1" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"TABLE3_1.html"];
    T3_1 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    
    // create the table
    // insert all the rows: first row data,..., all the rows html, original volume data, check volume data
    
    /*
    NSLog(@"%@", [wastPlot.plotStratum.stratum substringWithRange:NSMakeRange(0,1)]);
    NSLog(@"%@", [wastPlot.plotStratum.stratum substringWithRange:NSMakeRange(1,2)]);
    NSLog(@"%@", [wastPlot.plotStratum.stratum substringWithRange:NSMakeRange(2,3)]);
    NSLog(@"%@", [wastPlot.plotStratum.stratum substringWithRange:NSMakeRange(3,4)]);
    */
    
    //NSLog(@"%@", wastPlot.plotStratum.stratum);
    
    
    // survey date formatting
    NSDate *surveyDate = wastBlock.surveyDate;
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *surveyDateString = [dateFormat stringFromDate:surveyDate];

    NSString *originalVolume = @"";
    if([wastBlock.userCreated integerValue] == 1 ){
        originalVolume = [NSString stringWithFormat:@"Plot Volume: %.03f", originalVolumeValue];
    }else{
        originalVolume = [NSString stringWithFormat:@"Original Volume: %.03f", originalVolumeValue];
    }
    
    NSString *checkVolume = ([wastBlock.userCreated integerValue] == 1 ? @"": [NSString stringWithFormat:@"Check Volume: %.03f",checkVolumeValue]);
    
    T3_1 = [NSString stringWithFormat:T3_1, wastBlock.licenceNumber, wastBlock.cuttingPermitId, wastBlock.blockNumber, surveyDateString, wastPlot.certificateNumber, wastBlock.returnNumber, (wastPlot.baseline ? wastPlot.baseline : @""), wastPlot.strip, wastPlot.plotNumber, wastPlot.checkerMeasurePercent, [wastPlot.plotStratum.stratum substringWithRange:NSMakeRange(0,1)], [wastPlot.plotStratum.stratum substringWithRange:NSMakeRange(1,1)], [wastPlot.plotStratum.stratum substringWithRange:NSMakeRange(2,1)], [wastPlot.plotStratum.stratum substringWithRange:NSMakeRange(3,1)],[NSString stringWithString:rowsHTML], originalVolume, checkVolume];
    
    // STICH TOGETHER THE FORM FILE: HMTL = CSS + TITLE + T1 + T2 + FOOTER
    //
    NSMutableString* stichingHTML = [[NSMutableString alloc] init];
    [stichingHTML appendString:CSS];
    [stichingHTML appendString:TITLE];
    [stichingHTML appendString:T3_1];
    [stichingHTML appendString:FOOTER];
    
    
    // convert back to normal string from mutable
    newHTML = [NSString stringWithString:stichingHTML];
    
    
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
    
    
    
    
    // Export to data buffer
    UIEdgeInsets margin = {.left = 110, .right = 72, .top = 30, .bottom = 30};
    
    NSData *data = [str dataFromRange:(NSRange){0, [str length]}
                   documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType,
                                        NSPaperSizeDocumentAttribute:[NSValue valueWithCGSize:CGSizeMake(792,612)],
                                        NSPaperMarginDocumentAttribute: [NSValue valueWithUIEdgeInsets:margin],
                                        NSViewModeDocumentAttribute: [NSNumber numberWithInt:0] }
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
    
    NSLog(@"Plot tally report is generated");

    
    return Successful;
}




/* 
   takes the object containing data
   puts the data into the required format (Array)
   * also checks for any data missing and fills it with @""
*/
- (NSArray*) CalculateDataTable1:(WasteBlock *)wastBlock withPlot:(WastePlot*)wastPlot{
    
    
    // just 20, because the first one td0 is alternatively O/C for each of these
    NSString *td1, *td2, *td3, *td4, *td5, *td6, *td7, *td8, *td9, *td10, *td11, *td12, *td13, *td14, *td15, *td16, *td17, *td18, *td19, *td20 = [[NSString alloc] init];
   
    //NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"pieceNumber" ascending:YES];
    
    NSArray *tmpPieces = [wastPlot.plotPiece allObjects];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"sortNumber" ascending:YES];
   
    NSArray *sortedWastePieces = [tmpPieces sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    
    NSArray *row = [[NSArray alloc] init];
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    // for each piece
    // data for the whole row of table cells
    int numberOfRows = 0;
    NSString *previousPiece = @"";
    for (WastePiece *piece in sortedWastePieces)
    {
        // piece shouldn't be nil since NSSet cant have nil as element
        if(piece == nil){
            td1 = @"";
            td2 = @"";
            td3 = @"";
            td4 = @"";
            td5 = @"";
            td6 = @"";
            td7 = @"";
            td8 = @"";
            td9 = @"";
            td10 = @"";
            td11 = @"";
            td12 = @"";
            td13 = @"";
            td14 = @"";
            td15 = @"";
            td16 = @"";
            td17 = @"";
            td18 = @"";
            td19 = @"";
            td20 = @"";
        }
        else{
            td1 = piece.pieceNumber ? piece.pieceNumber : @"";
            td2 = piece.pieceBorderlineCode.borderlineCode ? piece.pieceBorderlineCode.borderlineCode : @"";
            td3 = piece.pieceScaleSpeciesCode.scaleSpeciesCode ? piece.pieceScaleSpeciesCode.scaleSpeciesCode : @"";
            td4 = piece.pieceMaterialKindCode.materialKindCode ? piece.pieceMaterialKindCode.materialKindCode : @"";
            td5 = piece.pieceWasteClassCode.wasteClassCode ? piece.pieceWasteClassCode.wasteClassCode : @"";
            td6 = [piece.length stringValue] ? [piece.length stringValue] : @"";
            td7 = [piece.topDiameter stringValue] ? [piece.topDiameter stringValue] : @"";
            td8 = piece.pieceTopEndCode.topEndCode ? piece.pieceTopEndCode.topEndCode : @"";
            td9 = [piece.buttDiameter stringValue] ? [piece.buttDiameter stringValue] : @"";
            td10 = piece.pieceButtEndCode.buttEndCode ? piece.pieceButtEndCode.buttEndCode : @"";
            
            td11 = piece.pieceScaleGradeCode.scaleGradeCode ? piece.pieceScaleGradeCode.scaleGradeCode : @"";
            td12 = [piece.lengthDeduction stringValue] ? [piece.lengthDeduction stringValue] : @"";
            td13 = [piece.topDeduction stringValue] ? [piece.topDeduction stringValue] : @"";
            td14 = [piece.buttDeduction stringValue] ? [piece.buttDeduction stringValue] : @"";
            td15 = piece.pieceDecayTypeCode.decayTypeCode ? piece.pieceDecayTypeCode.decayTypeCode : @"";
            td16 = [piece.farEnd stringValue] ? [piece.farEnd stringValue] : @"";
            td17 = [piece.addLength stringValue] ? [piece.addLength stringValue] : @"";
            td18 = piece.pieceCommentCode.commentCode ? piece.pieceCommentCode.commentCode : @"";
            td19 = piece.notes ? @"*" : @"";
            td20 = [piece.pieceVolume stringValue];
        }
        
        //NSLog(@"PIECE NUMBER = %@",td1);
        
        
        row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, td7, td8, td9, td10, td11, td12, td13, td14, td15, td16, td17, td18, td19, td20, nil];
        
        
        // allways create 2 rows for the same piece
        // if the piece is change (has a 'c') then replace the previous duplicate with changed one
        if( [self stringHasC:td1] ){
            td1 = [td1 substringToIndex:td1.length-1];
            row = [NSArray arrayWithObjects:td1, td2, td3, td4, td5, td6, td7, td8, td9, td10, td11, td12, td13, td14, td15, td16, td17, td18, td19, td20, nil];
            
            [rows replaceObjectAtIndex:numberOfRows-1 withObject:row]; // BUG index out of range (probably 0-1= -1 and objAtIndex:-1 is wrong
        }
        else{
            [rows addObject:row];
            [rows addObject:row];
            numberOfRows+=2;
        }
        
        
    
        previousPiece = td1;
    }
    
    
    return [NSArray arrayWithArray:rows];
}

/*
    creates the HTML string out of tableData
*/
- (NSString*) createRowsForTable1:(NSArray*)data wasteBlock:(WasteBlock*)wb{
    
    BOOL coloring = NO;
    NSError *errorForHTML;
    NSString *tmpPath, *rowHTML = [[NSString alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempFilePath =[documentsDirectory stringByAppendingString:@"/ReportTemplate/"];
    
    //tmpPath = [[NSBundle mainBundle] pathForResource: @"ROW_3" ofType: @"html"];
    tmpPath = [tempFilePath stringByAppendingString:@"ROW_3.html"];
    
    rowHTML = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    
    // LOAD DATA INTO ROWS FOR TABLE 3
    //
    NSMutableString* ROWS = [[NSMutableString alloc] init];
    NSString* ROW = [[NSString alloc] init];
    NSString *td1, *td2, *td3, *td4, *td5, *td6, *td7, *td8, *td9, *td10, *td11, *td12, *td13, *td14, *td15, *td16, *td17, *td18, *td19, *td20, *td21 = [[NSString alloc] init];
    
    
    // data is an Array containing Arrays[td1,td2,...]
    for(int rowID=0; rowID<[data count]; rowID++)
    {
        if([wb.userCreated integerValue] == 1 && rowID % 2){
            continue ;
        }
        
        NSString *cellColoring = coloring ? @"coloredRow" : @"blankRow";
        if([wb.userCreated integerValue] == 1){
            td1 = @"O";
        }else{
            td1 = coloring ? @"C" : @"O";
        }
        td2 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:0];
        td3 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:1];
        td4 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:2];
        td5 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:3];
        td6 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:4];
        td7 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:5];
        td8 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:6];
        td9 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:7];
        td10 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:8];
        
        td11 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:9];
        td12 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:10];
        td13 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:11];
        td14 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:12];
        td15 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:13];
        td16 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:14];
        td17 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:15];
        td18 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:16];
        td19 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:17];
        td20 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:18];
        td21 = [((NSArray*)[data objectAtIndex:rowID]) objectAtIndex:19];
        
        
        if([td1 isEqualToString:@"C"]){
            checkVolumeValue += [td21 floatValue];
        }
        else{
            originalVolumeValue += [td21 floatValue];
        }
        
        
        // actual HTML row with inserted values
        ROW = [NSString stringWithFormat:rowHTML, cellColoring, td1, td2, td3, td4, td5, td6, td7, td8, td9, td10, td11, td12, td13, td14, td15, td16, td17, td18, td19, td20, td21];
        
        // all the rows with values put together
        [ROWS appendString:ROW];
        
        coloring = !coloring;
    }
    
    
    
    
    return ROWS;
}

- (NSString*) createNotesForPiecesIn:(WastePlot*)thePlot{
    
    NSMutableString* NOTES = [[NSMutableString alloc] init];
    NSSortDescriptor *sortPieces = [[NSSortDescriptor alloc ] initWithKey:@"pieceNumber" ascending:YES]; // is key ok ? does it actually sort according to it
    NSArray *sortedPieces = [thePlot.plotPiece sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPieces]];
    
    for(WastePiece *piece in sortedPieces)
    {
        
        NSString *noteNumber = [self stringHasC:piece.pieceNumber] ? [piece.pieceNumber substringToIndex:piece.pieceNumber.length-1] : piece.pieceNumber;
        
        if(piece.notes != nil){
            if(![piece.notes isEqualToString:@""]){
                NSString *htmlNote = [[NSString alloc] initWithFormat:@"<p>Piece #%@. %@</p>",noteNumber, piece.notes];
                [NOTES appendString:htmlNote];
            }
        }
        
        //NSLog(@"<p>%@. %@</p>",piece.pieceNumber, piece.notes);
    }
    
    
    
    
    return  [NSString stringWithString:NOTES];
}


// HELPER
- (BOOL)stringHasC:(NSString*)theString{
    
    NSString *uppedString = [theString uppercaseString];
    
    BOOL hasC = !([uppedString rangeOfString:@"C"].location == NSNotFound);
    
    //NSLog(@"string = %@", uppedString);
    //NSLog(@"hasC = %@",  hasC ? @"YES" : @"NO");
    
    return hasC;
}


@end
