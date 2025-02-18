//
//  BlockTypeSummaryReport.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-01-18.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "BlockTypeSummaryReport.h"

#import "WasteBlock.h"
#import "WasteStratum.h"
#import "Timbermark.h"
#import "WastePlot.h"
#import "WastePiece.h"
#import "WastePile+CoreDataClass.h"
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
#import "Constants.h"
#import "AssessmentMethodCode.h"
#import "PlotSizeCode.h"

@interface ReportDataRow : NSObject
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSDecimalNumber *value1;
@property (nonatomic, retain) NSDecimalNumber *value2;
@property (nonatomic, retain) NSDecimalNumber *value3;
@property (nonatomic, retain) NSDecimalNumber *value4;
@property (nonatomic, retain) NSDecimalNumber *value5;
@property (nonatomic, retain) NSDecimalNumber *value6;
@property (nonatomic, retain) NSDecimalNumber *value7;
@property (nonatomic, retain) NSDecimalNumber *value8;
@property (nonatomic, retain) NSDecimalNumber *value9;
@property (nonatomic, retain) NSDecimalNumber *value10;
@property (nonatomic, retain) NSDecimalNumber *value11;
@property (nonatomic, retain) NSDecimalNumber *value12;
@property (nonatomic, retain) NSString *speices;
@property (nonatomic, retain) NSString *class;
@property (nonatomic, retain) NSString *kind;

@end

@implementation ReportDataRow
@end

@implementation BlockTypeSummaryReport 

-(void) generateReportByStratum:(WasteStratum *)wasteStratum
{
}

-(void) generateReportByBlock:(WasteBlock *)wasteBlock
{
    
    [super checkReportFolder];
    NSError *error = nil;
    
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
    
    NSLog(@"Genereate block type summary report");
    
    [super checkReportFolder];
    
    
    NSError *error = nil;
    
    
    // check if we got WasteBlock
    if(wastBlock==nil){
        NSLog(@"BlockTypeSummaryReport-wasteBlock=nil");
        return Fail_Unknown;
    }
    
    
    // Figure out destination name (in public docs dir)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempFilePath =[documentsDirectory stringByAppendingString:@"/ReportTemplate/"];
    
    if( ![suffix isEqualToString:@""]){
        suffix = [NSString stringWithFormat:@"_%@", [suffix stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    }
    
    NSString *zippedName = [NSString stringWithFormat: @"%@BlockTypeSummary%@.pdf",[super getReportFilePrefix:wastBlock], suffix];
    NSString *zippedPath = [documentsDirectory stringByAppendingPathComponent:zippedName];
    
    NSLog(@" zippedPath = %@ ", zippedPath ); // test
    
    // Check if file already exists (unless we force the write)
    if ( [[NSFileManager defaultManager] fileExistsAtPath:zippedPath] && !replace) {
        NSLog(@"File exists already");
        return Fail_Filename_Exist;
    }
    
    // PREPARE TEMPLATES FOR BUILDING THE HTML
    //
    NSString *path = [tempFilePath stringByAppendingString:@"REPORT.html"];
    NSError *errorForHTML;
    NSString *tmpPath, *mainTemplate, *table1, *table2, *table3, *row1, *row2, *row3, *headerTable, *body = [[NSString alloc] init];
    NSString *surveyMethod = [[NSString alloc] init];
    NSString *note = [[NSString alloc] init];
    // LOAD TEMPLATE COMPONENTS
    tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSMainTemplate" ofType: @"html"];
    mainTemplate = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

    tmpPath = [[NSBundle mainBundle] pathForResource: @"CSS_1" ofType: @"html"];
    table1 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

    tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSTable1" ofType: @"html"];
    table1 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

    tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSTable2" ofType: @"html"];
    table2 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

    if([wastBlock.regionId intValue]== InteriorRegion){
        tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSTable3" ofType: @"html"];
        table3 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

        tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSRow1" ofType: @"html"];
        row1 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

        tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSRow2" ofType: @"html"];
        row2 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];

        tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSRow3" ofType: @"html"];
        row3 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    } else if ([wastBlock.regionId intValue] == CoastRegion){
        tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSTable4" ofType: @"html"];
        table3 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
        
        tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSRow4" ofType: @"html"];
        row1 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
        
        tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSRow5" ofType: @"html"];
        row2 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
        
        tmpPath = [[NSBundle mainBundle] pathForResource: @"BTSRow6" ofType: @"html"];
        row3 = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    }
    if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [wastBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        surveyMethod = [surveyMethod stringByAppendingString:[NSString stringWithFormat:@"%@",@" Aggregate Ratio Sampling"]];
    }else if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [wastBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        surveyMethod = [surveyMethod stringByAppendingString:[NSString stringWithFormat:@"%@",@" Aggregate SRS Survey"]];
    }else if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [wastBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        surveyMethod = [surveyMethod stringByAppendingString:[NSString stringWithFormat:@"%@",@" Single Block SRS Survey"]];
    }else if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [wastBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        surveyMethod = [surveyMethod stringByAppendingString:[NSString stringWithFormat:@"%@",@" Single Block Ratio Sampling"]];
    }

    // LOAD NOTE TEMPLATE
    
    // Get the note from the stratum
    
    NSSet *tmpStratums = [wastBlock blockStratum];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
    NSArray *sortedStratums = [tmpStratums sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    NSString *dateString = [dateFormat stringFromDate:today];
    //reportDate = [NSString stringWithFormat:FOOTER, NOTE, dateString, wastBlock.checkerName ? wastBlock.checkerName : @"" ];
    
    NSString *reportingUnit = wastBlock.reportingUnit && [wastBlock.reportingUnit intValue] > 0? [wastBlock.reportingUnit stringValue] : @"";
    NSString *ptm = @"";
    for (Timbermark *tm in wastBlock.blockTimbermark.allObjects){
        /*if (tm.primaryInd){
            ptm = tm.timbermark;
        }*/
        ptm = [NSString stringWithFormat:@"%@  %@", ptm, tm.timbermark];
    }
    headerTable = [NSString stringWithFormat:table1, wastBlock.licenceNumber, wastBlock.cuttingPermitId, wastBlock.cutBlockId, ptm, reportingUnit];

    NSMutableArray *str_dataset = [[NSMutableArray alloc] init];
    NSMutableArray *cb_dataset = [[NSMutableArray alloc] init];
    
    ReportDataRow *classTotal = [[ReportDataRow alloc] init];
    ReportDataRow *speciesTotal = [[ReportDataRow alloc] init];
    ReportDataRow *avoidTotal = [[ReportDataRow alloc] init];
    ReportDataRow *unavoidTotal = [[ReportDataRow alloc] init];
    ReportDataRow *grandTotal = [[ReportDataRow alloc] init];

    
    //declare value cells for each row, header cells and table 3 str
    NSString *hc1, *hc2, *hc3, *hc4, *hc5, *hc6 = [[NSString alloc] init];
    NSString *str_table3 =[[NSString alloc] init];

    NSString *table_key = @"";
    BOOL reset_key = NO;

    //initial header cells
    if([wastBlock.regionId intValue]== InteriorRegion){
        hc1 = @"Grd 1";
        hc2 = @"Grd 2";
        hc3 = @"Grd 4";
        hc4 = @"Grd 5";
        hc5 = @"Other";
    }else if([wastBlock.regionId intValue] == CoastRegion ){
        hc1 = @"Grd J";
        hc2 = @"Grd U";
        hc3 = @"Grd W";
        hc4 = @"Grd X";
        hc5 = @"Grd Y";
        hc6 = @"Grd Z";
    }
    
    for( WasteStratum *st in sortedStratums){
        for(WastePlot *pt in st.stratumPlot.allObjects){
            for(WastePiece *pc in pt.plotPiece.allObjects){
                ReportDataRow *p_dr = [self getPieceDataRow:pc wasteBlock:wastBlock wasteStr:st wastePlot:pt];
                //NSLog(@"Stratum:%@ Plot:%@ key:%@ v1:%@ v2:%@ v3:%@ v4:%@ v5:%@", st.stratum, pt.plotNumber, p_dr.key, p_dr.value1, p_dr.value2, p_dr.value3, p_dr.value4, p_dr.value5);
                if([wastBlock.regionId intValue] == InteriorRegion){
                    [self addToDataset:str_dataset datarow:p_dr];
                    [self addToDataset:cb_dataset datarow:p_dr];
                } else if([wastBlock.regionId intValue] == CoastRegion){
                    [self addToCoastDataset:str_dataset datarow:p_dr];
                    [self addToCoastDataset:cb_dataset datarow:p_dr];
                }
            }
        }
        
        if([st.stratumBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue])
        {
              NSSet<ReportDataRow*> *p_drs = [self getPileDataRows:wastBlock wasteStr:st];
              for(ReportDataRow *p_dr in p_drs)
              {
                  if([wastBlock.regionId intValue] == InteriorRegion){
                         [self addToDataset:str_dataset datarow:p_dr];
                         [self addToDataset:cb_dataset datarow:p_dr];
                     } else if([wastBlock.regionId intValue] == CoastRegion){
                         [self addToCoastDataset:str_dataset datarow:p_dr];
                         [self addToCoastDataset:cb_dataset datarow:p_dr];
                     }
              }
              //NSLog(@"Stratum:%@ Plot:%@ key:%@ v1:%@ v2:%@ v3:%@ v4:%@ v5:%@", st.stratum, pt.plotNumber, p_dr.key, p_dr.value1, p_dr.value2, p_dr.value3, p_dr.value4, p_dr.value5);
        }
        else
        {
                NSMutableSet<ReportDataRow*> *p_drs = [self getPileDataRows:wastBlock wasteStr:st];
                  for(ReportDataRow *p_dr in p_drs)
                  {
                      if([wastBlock.regionId intValue] == InteriorRegion){
                             [self addToDataset:str_dataset datarow:p_dr];
                             [self addToDataset:cb_dataset datarow:p_dr];
                         } else if([wastBlock.regionId intValue] == CoastRegion){
                             [self addToCoastDataset:str_dataset datarow:p_dr];
                             [self addToCoastDataset:cb_dataset datarow:p_dr];
                         }
                  }
        }
        
        NSString *str_area = st.stratumSurveyArea && [st.stratumSurveyArea floatValue] > 0.0 ? [[NSString alloc] initWithFormat:@"%.02f", st.stratumSurveyArea.floatValue] : @"";
        NSString *str_header = [NSString stringWithFormat:table2, st.stratum, str_area];
        
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
        NSArray *stored_str_dataset = [[str_dataset copy] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
        
        
        for(ReportDataRow *dr in stored_str_dataset){
            if([wastBlock.regionId intValue] == InteriorRegion){
                [self addTotal:grandTotal data:dr round:YES];
                //NSLog(@"key:%@ v1:%@ v2:%@ v3:%@ v4:%@ v5:%@",  dr.key, dr.value1, dr.value2, dr.value3, dr.value4, dr.value5);
                
                if([dr.key containsString:@"_U_"]){
                    [self addTotal:unavoidTotal data:dr round:YES];
                }else{
                    [self addTotal:avoidTotal data:dr round:YES];
                }
            }else if([wastBlock.regionId integerValue] == CoastRegion){
                [self addCoastTotal:grandTotal data:dr round:YES];
                //NSLog(@"key:%@ v1:%@ v2:%@ v3:%@ v4:%@ v5:%@",  dr.key, dr.value1, dr.value2, dr.value3, dr.value4, dr.value5);
                
                if([dr.key containsString:@"_U_"]){
                    [self addCoastTotal:unavoidTotal data:dr round:YES];
                }else{
                    [self addCoastTotal:avoidTotal data:dr round:YES];
                }
            }
            
            if([table_key isEqualToString:@""]){
                table_key = [dr.key substringToIndex:4];
            }else{
                if(![table_key isEqualToString:[dr.key substringToIndex:4]]){
                    //add class total
                    if([wastBlock.regionId integerValue] == InteriorRegion) {
                        str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Waste Class Total" text2:nil text3:nil datarow:classTotal]];
                        [self clearDatarow:classTotal];
                        reset_key = YES;
                    }else if ([wastBlock.regionId integerValue] == CoastRegion){
                        str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Waste Class Total" text2:nil text3:nil datarow:classTotal]];
                        [self clearCoastDatarow:classTotal];
                        reset_key = YES;
                    }
                }
                if(![[table_key substringToIndex:3] isEqualToString:[dr.key substringToIndex:3]]){
                    //add special class total
                    if([wastBlock.regionId integerValue] == InteriorRegion) {
                        str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Species Class Total" text2:nil text3:nil datarow:speciesTotal]];
                        [self clearDatarow:speciesTotal];
                        reset_key = YES;
                    }else if ([wastBlock.regionId integerValue] == CoastRegion){
                        str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Species Class Total" text2:nil text3:nil datarow:speciesTotal]];
                        [self clearCoastDatarow:speciesTotal];
                        reset_key = YES;
                    }
                }
                if(reset_key){
                    table_key = [dr.key substringToIndex:4];
                    reset_key = NO;
                }
            }
            if([wastBlock.regionId integerValue] == InteriorRegion) {
                str_table3= [str_table3 stringByAppendingString:[self getTextRow:row1 text1:dr.speices text2:dr.class text3:dr.kind datarow:dr]];
                [self addTotal:classTotal data:dr round:YES];
                [self addTotal:speciesTotal data:dr round:YES];
                str_dataset = [[NSMutableArray alloc] init];
            }else if ([wastBlock.regionId integerValue] == CoastRegion){
                str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row1 text1:dr.speices text2:dr.class text3:dr.kind datarow:dr]];
                [self addCoastTotal:classTotal data:dr round:YES];
                [self addCoastTotal:speciesTotal data:dr round:YES];
                str_dataset = [[NSMutableArray alloc] init];
            }
        }
        if([wastBlock.regionId integerValue] == InteriorRegion) {
            str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Waste Class Total" text2:nil text3:nil datarow:classTotal]];
            [self clearDatarow:classTotal];
            str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Species Class Total" text2:nil text3:nil datarow:speciesTotal]];
            [self clearDatarow:speciesTotal];

            //add avoid, unavoid, straum total
            str_table3= [str_table3 stringByAppendingString:[self getTextRow:row3 text1:@"All Species" text2:@"Avoid" text3:nil datarow:avoidTotal]];
            str_table3= [str_table3 stringByAppendingString:[self getTextRow:row3 text1:@"" text2:@"Unavd" text3:nil datarow:unavoidTotal]];
            str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Type Stratum Total" text2:nil text3:nil datarow:grandTotal]];
            [self clearDatarow:avoidTotal];
            [self clearDatarow:unavoidTotal];
            [self clearDatarow:grandTotal];
            table_key = @"";
            
            body = [body stringByAppendingString:[NSString stringWithFormat:@"%@%@", str_header, [NSString stringWithFormat:table3, hc1, hc2, hc3, hc4,hc5, hc1, hc2, hc3, hc4, hc5, str_table3]]];
            str_table3 = @"";
        }else if ([wastBlock.regionId integerValue] == CoastRegion){
            str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Waste Class Total" text2:nil text3:nil datarow:classTotal]];
            [self clearCoastDatarow:classTotal];
            str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Species Class Total" text2:nil text3:nil datarow:speciesTotal]];
            [self clearCoastDatarow:speciesTotal];
            
            //add avoid, unavoid, straum total
            str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row3 text1:@"All Species" text2:@"Avoid" text3:nil datarow:avoidTotal]];
            str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row3 text1:@"" text2:@"Unavd" text3:nil datarow:unavoidTotal]];
            str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Type Stratum Total" text2:nil text3:nil datarow:grandTotal]];
            [self clearCoastDatarow:avoidTotal];
            [self clearCoastDatarow:unavoidTotal];
            [self clearCoastDatarow:grandTotal];
            table_key = @"";
            
            body = [body stringByAppendingString:[NSString stringWithFormat:@"%@%@", str_header, [NSString stringWithFormat:table3, hc1, hc2, hc3, hc4,hc5, hc6, hc1, hc2, hc3, hc4, hc5,hc6, str_table3]]];
            str_table3 = @"";
        }
    }
    
    //add cut block section
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSArray *stored_cb_dataset = [[cb_dataset copy] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
    reset_key = NO;
    if([wastBlock.regionId integerValue] == InteriorRegion) {
        [self clearDatarow:classTotal];
        [self clearDatarow:speciesTotal];
        [self clearDatarow:grandTotal];
        [self clearDatarow:avoidTotal];
        [self clearDatarow:unavoidTotal];
    }else if([wastBlock.regionId integerValue] == CoastRegion){
        [self clearCoastDatarow:classTotal];
        [self clearCoastDatarow:speciesTotal];
        [self clearCoastDatarow:grandTotal];
        [self clearCoastDatarow:avoidTotal];
        [self clearCoastDatarow:unavoidTotal];
    }
    
    for(ReportDataRow *dr in stored_cb_dataset){
        if([wastBlock.regionId integerValue] == InteriorRegion) {
            if(!(isnan([wastBlock.surveyArea doubleValue]))){
            [self recalculateValue:dr area:wastBlock.surveyArea];
            }
            [self addTotal:grandTotal data:dr round:YES];
            if([dr.key containsString:@"_U_"] ){
                [self addTotal:unavoidTotal data:dr round:YES];
            }else{
                [self addTotal:avoidTotal data:dr round:YES];
            }
        }else if([wastBlock.regionId integerValue] == CoastRegion){
            if(!(isnan([wastBlock.surveyArea doubleValue]))){
            [self recalculateCoastValue:dr area:wastBlock.surveyArea];
            }
            [self addCoastTotal:grandTotal data:dr round:YES];
            if([dr.key containsString:@"_U_"] ){
                [self addCoastTotal:unavoidTotal data:dr round:YES];
            }else{
                [self addCoastTotal:avoidTotal data:dr round:YES];
            }
        }
        
        if([table_key isEqualToString:@""]){
            table_key = [dr.key substringToIndex:4];
        }else{
            if(![table_key isEqualToString:[dr.key substringToIndex:4]]){
                //add class total
                if([wastBlock.regionId integerValue] == InteriorRegion) {
                    str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Waste Class Total" text2:nil text3:nil datarow:classTotal]];
                    [self clearDatarow:classTotal];
                    reset_key = YES;
                }else if([wastBlock.regionId integerValue] == CoastRegion){
                    str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Waste Class Total" text2:nil text3:nil datarow:classTotal]];
                    [self clearCoastDatarow:classTotal];
                    reset_key = YES;
                }
            }
            if(![[table_key substringToIndex:3] isEqualToString:[dr.key substringToIndex:3]]){
                //add special class total
                if([wastBlock.regionId integerValue] == InteriorRegion) {
                    str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Species Class Total" text2:nil text3:nil datarow:speciesTotal]];
                    [self clearDatarow:speciesTotal];
                    reset_key = YES;
                }else if([wastBlock.regionId integerValue] == CoastRegion){
                    str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Species Class Total" text2:nil text3:nil datarow:speciesTotal]];
                    [self clearCoastDatarow:speciesTotal];
                    reset_key = YES;
                }
            }
            if(reset_key){
                table_key = [dr.key substringToIndex:4];
                reset_key = NO;
            }
        }
         if([wastBlock.regionId integerValue] == InteriorRegion) {
             str_table3= [str_table3 stringByAppendingString:[self getTextRow:row1 text1:dr.speices text2:dr.class text3:dr.kind datarow:dr]];
             [self addTotal:classTotal data:dr round:YES];
             [self addTotal:speciesTotal data:dr round:YES];
         }else if([wastBlock.regionId integerValue] == CoastRegion){
             str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row1 text1:dr.speices text2:dr.class text3:dr.kind datarow:dr]];
             [self addCoastTotal:classTotal data:dr round:YES];
             [self addCoastTotal:speciesTotal data:dr round:YES];
         }

    }
    if([wastBlock.regionId integerValue] == InteriorRegion) {
        str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Waste Class Total" text2:nil text3:nil datarow:classTotal]];
        str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Species Class Total" text2:nil text3:nil datarow:speciesTotal]];
        [self clearDatarow:classTotal];
        [self clearDatarow:speciesTotal];
        
        //add avoid, unavoid, straum total
         str_table3= [str_table3 stringByAppendingString:[self getTextRow:row3 text1:@"All Species" text2:@"Avoid" text3:nil datarow:avoidTotal]];
         str_table3= [str_table3 stringByAppendingString:[self getTextRow:row3 text1:@"" text2:@"Unavd" text3:nil datarow:unavoidTotal]];
         str_table3= [str_table3 stringByAppendingString:[self getTextRow:row2 text1:@"Block Total" text2:nil text3:nil datarow:grandTotal]];
        
        NSString *cb_area = wastBlock.surveyArea && wastBlock.surveyArea.floatValue > 0 ? [NSString stringWithFormat:@"%0.02f", wastBlock.surveyArea.floatValue] : @"0.00";
        NSString *cb_header = [NSString stringWithFormat:table2, @"All", cb_area];
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@%@", cb_header, [NSString stringWithFormat:table3, hc1, hc2, hc3, hc4,hc5, hc1, hc2, hc3, hc4, hc5, str_table3]]];
    }else if([wastBlock.regionId integerValue] == CoastRegion){
        str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Waste Class Total" text2:nil text3:nil datarow:classTotal]];
        str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Species Class Total" text2:nil text3:nil datarow:speciesTotal]];
        [self clearCoastDatarow:classTotal];
        [self clearCoastDatarow:speciesTotal];
        
        //add avoid, unavoid, straum total
        str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row3 text1:@"All Species" text2:@"Avoid" text3:nil datarow:avoidTotal]];
        str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row3 text1:@"" text2:@"Unavd" text3:nil datarow:unavoidTotal]];
        str_table3= [str_table3 stringByAppendingString:[self getCoastTextRow:row2 text1:@"Block Total" text2:nil text3:nil datarow:grandTotal]];
        
        NSString *cb_area = wastBlock.surveyArea && wastBlock.surveyArea.floatValue > 0 ? [NSString stringWithFormat:@"%0.02f", wastBlock.surveyArea.floatValue] : @"0.00";
        NSString *cb_header = [NSString stringWithFormat:table2, @"All", cb_area];
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@%@", cb_header, [NSString stringWithFormat:table3, hc1, hc2, hc3, hc4,hc5,hc6, hc1, hc2, hc3, hc4, hc5,hc6, str_table3]]];
    }
    if([wastBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        note = [note stringByAppendingString:[NSString stringWithFormat:@"%@",@" Note: If the survey method uses ratio, the displayed values are NOT adjusted by the ratio for the population."]];
    }
    // convert back to normal string from mutable
    mainTemplate = [NSString stringWithFormat:mainTemplate, surveyMethod, headerTable, body, note, dateString, wastBlock.surveyorName];
    
    // SAVE HTML FILE - save the NSString that contains the HTML to a file
    [mainTemplate writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&errorForHTML];
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
   /* NSData *data = [str dataFromRange:(NSRange){0, [str length]}
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
    NSLog(@"Block type summary report is generated");
    
    return Successful;
}

-(ReportDataRow*) getPieceDataRow:(WastePiece *)piece wasteBlock:(WasteBlock *)wasteBlock wasteStr:(WasteStratum*)wasteStr wastePlot:(WastePlot*)wastePlot{
    ReportDataRow *piece_dr = nil;
    if (piece.pieceMaterialKindCode && piece.pieceWasteClassCode && piece.pieceScaleGradeCode && piece.pieceScaleSpeciesCode && piece.pieceVolume){
        
        NSString *key = [NSString stringWithFormat:@"%@_%@_%@", piece.pieceScaleSpeciesCode.scaleSpeciesCode, piece.pieceWasteClassCode.wasteClassCode, piece.pieceMaterialKindCode.materialKindCode];
        
        if([wasteBlock.regionId intValue]== InteriorRegion){
            if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"1"]){
                piece_dr = [self getNewDataRow:key gvalue1:piece.pieceVolume gvalue2:[[NSDecimalNumber alloc] initWithInt:0] gvalue3:[[NSDecimalNumber alloc] initWithInt:0]
                                       gvalue4:[[NSDecimalNumber alloc] initWithInt:0] gvalue5:[[NSDecimalNumber alloc] initWithInt:0] wasteStr:wasteStr wastePlot:wastePlot];
            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"2"]){
                piece_dr = [self getNewDataRow:key gvalue1:[[NSDecimalNumber alloc] initWithInt:0] gvalue2:piece.pieceVolume gvalue3:[[NSDecimalNumber alloc] initWithInt:0]
                                       gvalue4:[[NSDecimalNumber alloc] initWithInt:0] gvalue5:[[NSDecimalNumber alloc] initWithInt:0] wasteStr:wasteStr wastePlot:wastePlot];
            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"4"]){
                piece_dr = [self getNewDataRow:key gvalue1:[[NSDecimalNumber alloc] initWithInt:0] gvalue2:[[NSDecimalNumber alloc] initWithInt:0] gvalue3:piece.pieceVolume
                                       gvalue4:[[NSDecimalNumber alloc] initWithInt:0] gvalue5:[[NSDecimalNumber alloc] initWithInt:0] wasteStr:wasteStr  wastePlot:wastePlot];
            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"5"]){
                piece_dr = [self getNewDataRow:key gvalue1:[[NSDecimalNumber alloc] initWithInt:0] gvalue2:[[NSDecimalNumber alloc] initWithInt:0] gvalue3:[[NSDecimalNumber alloc] initWithInt:0]
                                       gvalue4:piece.pieceVolume gvalue5:[[NSDecimalNumber alloc] initWithInt:0] wasteStr:wasteStr  wastePlot:wastePlot];
            }else {
                piece_dr = [self getNewDataRow:key gvalue1:[[NSDecimalNumber alloc] initWithInt:0] gvalue2:[[NSDecimalNumber alloc] initWithInt:0] gvalue3:[[NSDecimalNumber alloc] initWithInt:0]
                                       gvalue4:[[NSDecimalNumber alloc] initWithInt:0] gvalue5:piece.pieceVolume wasteStr:wasteStr wastePlot:wastePlot];
            }
        }else if([wasteBlock.regionId intValue] == CoastRegion ){
            if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Y"]){
                piece_dr = [self getNewDataCoastRow:key gvalue1:[[NSDecimalNumber alloc] initWithInt:0] gvalue2:[[NSDecimalNumber alloc] initWithInt:0] gvalue3:[[NSDecimalNumber alloc] initWithInt:0]
                                       gvalue4:[[NSDecimalNumber alloc] initWithInt:0] gvalue5:piece.pieceVolume  gvalue6:[[NSDecimalNumber alloc] initWithInt:0] wasteStr:wasteStr wastePlot:wastePlot];
            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"U"]){
                piece_dr = [self getNewDataCoastRow:key gvalue1:[[NSDecimalNumber alloc] initWithInt:0] gvalue2:piece.pieceVolume gvalue3:[[NSDecimalNumber alloc] initWithInt:0]
                                       gvalue4:[[NSDecimalNumber alloc] initWithInt:0] gvalue5:[[NSDecimalNumber alloc] initWithInt:0] gvalue6:[[NSDecimalNumber alloc] initWithInt:0] wasteStr:wasteStr wastePlot:wastePlot];
            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"W"]){
                piece_dr = [self getNewDataCoastRow:key gvalue1:[[NSDecimalNumber alloc] initWithInt:0] gvalue2:[[NSDecimalNumber alloc] initWithInt:0] gvalue3:piece.pieceVolume
                                       gvalue4:[[NSDecimalNumber alloc] initWithInt:0] gvalue5:[[NSDecimalNumber alloc] initWithInt:0] gvalue6:[[NSDecimalNumber alloc] initWithInt:0]wasteStr:wasteStr wastePlot:wastePlot];
            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"X"]){
                piece_dr = [self getNewDataCoastRow:key gvalue1:[[NSDecimalNumber alloc] initWithInt:0] gvalue2:[[NSDecimalNumber alloc] initWithInt:0] gvalue3:[[NSDecimalNumber alloc] initWithInt:0]
                                       gvalue4:piece.pieceVolume gvalue5:[[NSDecimalNumber alloc] initWithInt:0] gvalue6:[[NSDecimalNumber alloc] initWithInt:0] wasteStr:wasteStr wastePlot:wastePlot];
            }else if([piece.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Z"]){
                piece_dr = [self getNewDataCoastRow:key gvalue1:[[NSDecimalNumber alloc] initWithInt:0] gvalue2:[[NSDecimalNumber alloc] initWithInt:0] gvalue3:[[NSDecimalNumber alloc] initWithInt:0]
                                       gvalue4:[[NSDecimalNumber alloc] initWithInt:0] gvalue5:[[NSDecimalNumber alloc] initWithInt:0] gvalue6:piece.pieceVolume wasteStr:wasteStr wastePlot:wastePlot];
            }else {
                piece_dr = [self getNewDataCoastRow:key gvalue1:piece.pieceVolume gvalue2:[[NSDecimalNumber alloc] initWithInt:0] gvalue3:[[NSDecimalNumber alloc] initWithInt:0]
                                       gvalue4:[[NSDecimalNumber alloc] initWithInt:0] gvalue5:[[NSDecimalNumber alloc] initWithInt:0] gvalue6:[[NSDecimalNumber alloc] initWithInt:0] wasteStr:wasteStr wastePlot:wastePlot];
            }
        }
        piece_dr.speices = [[NSString alloc] initWithString:piece.pieceScaleSpeciesCode.scaleSpeciesCode];
        piece_dr.class = [piece.pieceWasteClassCode.wasteClassCode isEqualToString:@"A"] ? @"Avoid" : @"Unavd";
        piece_dr.kind = [[NSString alloc] initWithString:piece.pieceMaterialKindCode.desc];
    }
    return piece_dr;
}

-(NSMutableSet<ReportDataRow*>*) getPileDataRows:(WasteBlock *)wasteBlock wasteStr:(WasteStratum*)wasteStr {
    NSMutableSet<ReportDataRow*> *rowSet = [[NSMutableSet alloc] init];
    NSArray<NSString*> *speciesArray = [NSArray arrayWithObjects:@"AL", @"AR", @"AS", @"BA", @"BI", @"CE", @"CO", @"CY", @"FI", @"HE", @"LA", @"LO", @"MA", @"SP", @"UU", @"WB", @"WH", @"WI", @"YE",  nil];
    
    NSDecimalNumber *summ2estsample = nil;NSDecimalNumber *summ2meassample = nil;NSDecimalNumber *totalestm2 = nil;NSDecimalNumber *totalPredPileVolume = nil;
    NSDecimalNumber *sumPredVol = nil;NSDecimalNumber *sumMeasVolume = nil;NSDecimalNumber *summ2estsamplewoHB = nil;NSDecimalNumber *sumPredVolwoHB = nil;
    NSDecimalNumber *summ2meassamplewoHB = nil;NSDecimalNumber *totalestm2woHB = nil; NSDecimalNumber *totalPredPileVolumewoHB = nil;NSDecimalNumber *sumMeasVolumewoHB = nil;
    NSDecimalNumber *avgAlSpecies = nil;NSDecimalNumber *alSpecies = nil;
    NSDecimalNumber *avgArSpecies = nil;NSDecimalNumber *arSpecies = nil;NSDecimalNumber *avgAsSpecies = nil;NSDecimalNumber *asSpecies = nil;
    NSDecimalNumber *avgBaSpecies = nil;NSDecimalNumber *baSpecies = nil;NSDecimalNumber *avgBiSpecies = nil;NSDecimalNumber *biSpecies = nil;
    NSDecimalNumber *avgCeSpecies = nil;NSDecimalNumber *ceSpecies = nil;NSDecimalNumber *avgCoSpecies = nil;NSDecimalNumber *coSpecies = nil;
    NSDecimalNumber *avgCySpecies = nil;NSDecimalNumber *cySpecies = nil;NSDecimalNumber *avgFiSpecies = nil;NSDecimalNumber *fiSpecies = nil;
    NSDecimalNumber *avgHeSpecies = nil;NSDecimalNumber *heSpecies = nil;NSDecimalNumber *avgLaSpecies = nil;NSDecimalNumber *laSpecies = nil;
    NSDecimalNumber *avgLoSpecies = nil;NSDecimalNumber *loSpecies = nil;NSDecimalNumber *avgMaSpecies = nil;NSDecimalNumber *maSpecies = nil;
    NSDecimalNumber *avgSpSpecies = nil;NSDecimalNumber *spSpecies = nil;NSDecimalNumber *avgUuSpecies = nil;NSDecimalNumber *uuSpecies = nil;
    NSDecimalNumber *avgWbSpecies = nil;NSDecimalNumber *wbSpecies = nil;NSDecimalNumber *avgWhSpecies = nil;NSDecimalNumber *whSpecies = nil;
    NSDecimalNumber *avgWiSpecies = nil;NSDecimalNumber *wiSpecies = nil;NSDecimalNumber *avgYeSpecies = nil;NSDecimalNumber *yeSpecies = nil;
    
    for(WastePile* pile in wasteStr.stratumPile){
        if([pile.isSample intValue] == [[[NSNumber alloc] initWithBool:TRUE]intValue]){
            summ2estsample = [[NSDecimalNumber alloc] initWithDouble:[summ2estsample doubleValue] + [pile.pileArea doubleValue]] ;
            sumPredVol = [[NSDecimalNumber alloc] initWithDouble:[sumPredVol doubleValue] + [pile.pileVolume doubleValue]] ;
//            if(pile.hePercent == 0 || pile.baPercent == 0){
                summ2estsamplewoHB = [[NSDecimalNumber alloc] initWithDouble:[summ2estsamplewoHB doubleValue] + [pile.measuredPileArea doubleValue]];
                sumPredVolwoHB = [[NSDecimalNumber alloc] initWithDouble:[sumPredVolwoHB doubleValue] + [pile.measuredPileVolume doubleValue]];
                summ2meassamplewoHB = [[NSDecimalNumber alloc] initWithDouble:[summ2meassamplewoHB doubleValue] + [pile.measuredPileArea doubleValue]] ;
                totalestm2woHB = [[NSDecimalNumber alloc] initWithDouble:[totalestm2woHB doubleValue] + [pile.pileArea doubleValue]] ;
                totalPredPileVolumewoHB = [[NSDecimalNumber alloc] initWithDouble:[totalPredPileVolumewoHB doubleValue] + [pile.pileVolume doubleValue]] ;
                sumMeasVolumewoHB = [[NSDecimalNumber alloc] initWithDouble:[sumMeasVolumewoHB doubleValue] + [pile.measuredPileVolume doubleValue]] ;
//            }
            //for avg species calculation
//            if(pile.alPercent != 0 ){
//               alSpecies = [[NSDecimalNumber alloc] initWithDouble:[alSpecies doubleValue] + ([pile.alPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.arPercent != 0 ){
//               arSpecies = [[NSDecimalNumber alloc] initWithDouble:[arSpecies doubleValue] + ([pile.arPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.asPercent != 0 ){
//               asSpecies = [[NSDecimalNumber alloc] initWithDouble:[asSpecies doubleValue] + ([pile.asPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.baPercent != 0 ){
//               baSpecies = [[NSDecimalNumber alloc] initWithDouble:[baSpecies doubleValue] + ([pile.baPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.biPercent != 0 ){
//               biSpecies = [[NSDecimalNumber alloc] initWithDouble:[biSpecies doubleValue] + ([pile.biPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.cePercent != 0 ){
//               ceSpecies = [[NSDecimalNumber alloc] initWithDouble:[ceSpecies doubleValue] + ([pile.cePercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.coPercent != 0 ){
//               coSpecies = [[NSDecimalNumber alloc] initWithDouble:[coSpecies doubleValue] + ([pile.coPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.cyPercent != 0 ){
//               cySpecies = [[NSDecimalNumber alloc] initWithDouble:[cySpecies doubleValue] + ([pile.cyPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.fiPercent != 0 ){
//               fiSpecies = [[NSDecimalNumber alloc] initWithDouble:[fiSpecies doubleValue] + ([pile.fiPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.hePercent != 0 ){
//               heSpecies = [[NSDecimalNumber alloc] initWithDouble:[heSpecies doubleValue] + ([pile.hePercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.laPercent != 0 ){
//               laSpecies = [[NSDecimalNumber alloc] initWithDouble:[laSpecies doubleValue] + ([pile.laPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.loPercent != 0 ){
//               loSpecies = [[NSDecimalNumber alloc] initWithDouble:[loSpecies doubleValue] + ([pile.loPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.maPercent != 0 ){
//               maSpecies = [[NSDecimalNumber alloc] initWithDouble:[maSpecies doubleValue] + ([pile.maPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.spPercent != 0 ){
//                spSpecies = [[NSDecimalNumber alloc] initWithDouble:[spSpecies doubleValue] + ([pile.spPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.uuPercent != 0 ){
//               uuSpecies = [[NSDecimalNumber alloc] initWithDouble:[uuSpecies doubleValue] + ([pile.uuPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.wbPercent != 0 ){
//               wbSpecies = [[NSDecimalNumber alloc] initWithDouble:[wbSpecies doubleValue] + ([pile.wbPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.whPercent != 0 ){
//               whSpecies = [[NSDecimalNumber alloc] initWithDouble:[whSpecies doubleValue] + ([pile.whPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.wiPercent != 0 ){
//               wiSpecies = [[NSDecimalNumber alloc] initWithDouble:[wiSpecies doubleValue] + ([pile.wiPercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
//            if(pile.yePercent != 0 ){
//               yeSpecies = [[NSDecimalNumber alloc] initWithDouble:[yeSpecies doubleValue] + ([pile.yePercent doubleValue] * [pile.measuredPileVolume doubleValue])] ;
//            }
        }
        summ2meassample = [[NSDecimalNumber alloc] initWithDouble:[summ2meassample doubleValue] + [pile.measuredPileArea doubleValue]] ;
        totalestm2 = [[NSDecimalNumber alloc] initWithDouble:[totalestm2 doubleValue] + [pile.pileArea doubleValue]] ;
        totalPredPileVolume = [[NSDecimalNumber alloc] initWithDouble:[totalPredPileVolume doubleValue] + [pile.pileVolume doubleValue]] ;
        sumMeasVolume = [[NSDecimalNumber alloc] initWithDouble:[sumMeasVolume doubleValue] + [pile.measuredPileVolume doubleValue]] ;
    }
    
    avgAlSpecies = [[NSDecimalNumber alloc] initWithDouble:[alSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgArSpecies = [[NSDecimalNumber alloc] initWithDouble:[arSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgAsSpecies = [[NSDecimalNumber alloc] initWithDouble:[asSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgBaSpecies = [[NSDecimalNumber alloc] initWithDouble:[baSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgBiSpecies = [[NSDecimalNumber alloc] initWithDouble:[biSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgCeSpecies = [[NSDecimalNumber alloc] initWithDouble:[ceSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgCoSpecies = [[NSDecimalNumber alloc] initWithDouble:[coSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgCySpecies = [[NSDecimalNumber alloc] initWithDouble:[cySpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgFiSpecies = [[NSDecimalNumber alloc] initWithDouble:[fiSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgHeSpecies = [[NSDecimalNumber alloc] initWithDouble:[heSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgLaSpecies = [[NSDecimalNumber alloc] initWithDouble:[laSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgLoSpecies = [[NSDecimalNumber alloc] initWithDouble:[loSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgMaSpecies = [[NSDecimalNumber alloc] initWithDouble:[maSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgSpSpecies = [[NSDecimalNumber alloc] initWithDouble:[spSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgUuSpecies = [[NSDecimalNumber alloc] initWithDouble:[uuSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgWbSpecies = [[NSDecimalNumber alloc] initWithDouble:[wbSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgWhSpecies = [[NSDecimalNumber alloc] initWithDouble:[whSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgWiSpecies = [[NSDecimalNumber alloc] initWithDouble:[wiSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    avgYeSpecies = [[NSDecimalNumber alloc] initWithDouble:[yeSpecies doubleValue] / [sumMeasVolume doubleValue]] ;
    
    NSArray<NSDecimalNumber*> *speciesPercentArray = [NSArray arrayWithObjects:(avgAlSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgAlSpecies),
                                                      (avgArSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgArSpecies),
                                                      (avgAsSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgAsSpecies),
                                                      (avgBaSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgBaSpecies),
                                                      (avgBiSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgBiSpecies),
                                                      (avgCeSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgCeSpecies),
                                                      (avgCoSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgCoSpecies),
                                                      (avgCySpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgCySpecies),
                                                      (avgFiSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgFiSpecies),
                                                      (avgHeSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgHeSpecies),
                                                      (avgLaSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgLaSpecies),
                                                      (avgLoSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgLoSpecies),
                                                      (avgMaSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgMaSpecies),
                                                      (avgSpSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgSpSpecies),
                                                      (avgUuSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgUuSpecies),
                                                      (avgWbSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgWbSpecies),
                                                      (avgWhSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgWhSpecies),
                                                      (avgWiSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgWiSpecies),
                                                      (avgYeSpecies == nil ? [[NSDecimalNumber alloc] initWithInt:0] : avgYeSpecies), nil];
    NSDecimalNumber *ratioSample = [[NSDecimalNumber alloc] initWithDouble:[summ2meassample doubleValue] / [summ2estsample doubleValue]] ;
    NSDecimalNumber *avgPileArea = nil;
    if([wasteBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue])
    {
        avgPileArea = [[NSDecimalNumber alloc] initWithDouble:([ratioSample doubleValue] * [totalestm2 doubleValue])/10000] ;
    }
    else
    {
        avgPileArea = [[NSDecimalNumber alloc] initWithDouble:([totalestm2 doubleValue]/10000)];
    }
    NSDecimalNumber *ratio = [[NSDecimalNumber alloc] initWithDouble:[sumMeasVolume doubleValue] / [sumPredVol doubleValue]] ;
    NSDecimalNumber *totalPileVolume = nil;
    if([wasteBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue])
    {
        totalPileVolume = [[NSDecimalNumber alloc] initWithDouble:[ratio doubleValue] * [totalPredPileVolume doubleValue]] ;
    }
    else
    {
        totalPileVolume = sumMeasVolume;
    }
        
    for(int i = 0; i< speciesArray.count; i++)
    {
        NSString *thisSpecies = speciesArray[i];
        NSDecimalNumber *thisSpeciesPercent = [[NSDecimalNumber alloc] initWithDouble:([speciesPercentArray[i] doubleValue]/100)];
        if(thisSpeciesPercent != nil && ![thisSpeciesPercent isEqualToNumber:[NSNumber numberWithInt:0]])
        {
            if([wasteBlock.regionId intValue]== InteriorRegion)
            {
                if(wasteStr.grade12Percent != nil && ![wasteStr.grade12Percent isEqualToNumber:[NSNumber numberWithInt:0]])
                {
                    ReportDataRow *pile_dr = [[ReportDataRow alloc] init];
                    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", thisSpecies, @"A", @"L"];
                    [pile_dr setKey:key];
                    pile_dr.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    
                    pile_dr.value2 = [[totalPileVolume decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[thisSpeciesPercent decimalValue]]] decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithDouble:([wasteStr.grade12Percent doubleValue]/100)]];
                    pile_dr.value7 = [pile_dr.value2 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
                    
                    pile_dr.speices = thisSpecies;
                    pile_dr.class = @"Avoid";
                    pile_dr.kind = @"X";
                    [rowSet addObject:pile_dr];
                    
                }if(wasteStr.grade4Percent != nil && ![wasteStr.grade4Percent isEqualToNumber:[NSNumber numberWithInt:0]]){
                    ReportDataRow *pile_dr = [[ReportDataRow alloc] init];
                    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", thisSpecies, @"A", @"L"];
                    [pile_dr setKey:key];
                    pile_dr.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    
                    pile_dr.value3 = [[totalPileVolume decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[thisSpeciesPercent decimalValue]]] decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithDouble:([wasteStr.grade4Percent doubleValue]/100)]];
                    pile_dr.value8 = [pile_dr.value3 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
                    
                    pile_dr.speices = thisSpecies;
                    pile_dr.class = @"Avoid";
                    pile_dr.kind = @"X";
                    [rowSet addObject:pile_dr];
                }if(wasteStr.grade5Percent != nil && ![wasteStr.grade5Percent isEqualToNumber:[NSNumber numberWithInt:0]]){
                    ReportDataRow *pile_dr = [[ReportDataRow alloc] init];
                    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", thisSpecies, @"A", @"L"];
                    [pile_dr setKey:key];
                    pile_dr.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    
                    pile_dr.value4 = [[totalPileVolume decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[thisSpeciesPercent decimalValue]]] decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithDouble:([wasteStr.grade5Percent doubleValue]/100)]];
                    pile_dr.value9 = [pile_dr.value9 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
                    
                    pile_dr.speices = thisSpecies;
                    pile_dr.class = @"Avoid";
                    pile_dr.kind = @"X";
                    [rowSet addObject:pile_dr];
                }
            }else if([wasteBlock.regionId intValue] == CoastRegion ){
                if(wasteStr.gradeJPercent != nil && ![wasteStr.gradeJPercent isEqualToNumber:[NSNumber numberWithInt:0]]){
                    ReportDataRow *pile_dr = [[ReportDataRow alloc] init];
                    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", thisSpecies, @"A", @"L"];
                    [pile_dr setKey:key];
                    pile_dr.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    
                    pile_dr.value1 = [[totalPileVolume decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[thisSpeciesPercent decimalValue]]] decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithDouble:([wasteStr.gradeJPercent doubleValue]/100)]];
                    pile_dr.value7 = [pile_dr.value1 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
                    
                    pile_dr.speices = thisSpecies;
                    pile_dr.class = @"Avoid";
                    pile_dr.kind = @"X";
                    [rowSet addObject:pile_dr];
                }if(wasteStr.gradeWPercent != nil && ![wasteStr.gradeWPercent isEqualToNumber:[NSNumber numberWithInt:0]]){
                    ReportDataRow *pile_dr = [[ReportDataRow alloc] init];
                    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", thisSpecies, @"A", @"L"];
                    [pile_dr setKey:key];
                    pile_dr.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    
                    pile_dr.value3 = [[totalPileVolume decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[thisSpeciesPercent decimalValue]]] decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithDouble:([wasteStr.gradeWPercent doubleValue]/100)]];
                    pile_dr.value9 = [pile_dr.value3 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
                    
                    pile_dr.speices = thisSpecies;
                    pile_dr.class = @"Avoid";
                    pile_dr.kind = @"X";
                    [rowSet addObject:pile_dr];
                }if(wasteStr.gradeUPercent != nil && ![wasteStr.gradeUPercent isEqualToNumber:[NSNumber numberWithInt:0]]){
                    ReportDataRow *pile_dr = [[ReportDataRow alloc] init];
                    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", thisSpecies, @"A", @"L"];
                    [pile_dr setKey:key];
                    pile_dr.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    
                    pile_dr.value2 = [[totalPileVolume decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[thisSpeciesPercent decimalValue]]] decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithDouble:([wasteStr.gradeUPercent doubleValue]/100)]];
                    pile_dr.value8 = [pile_dr.value2 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
                    
                    pile_dr.speices = thisSpecies;
                    pile_dr.class = @"Avoid";
                    pile_dr.kind = @"X";
                    [rowSet addObject:pile_dr];
                }if(wasteStr.gradeXPercent != nil && ![wasteStr.gradeXPercent isEqualToNumber:[NSNumber numberWithInt:0]]){
                    ReportDataRow *pile_dr = [[ReportDataRow alloc] init];
                    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", thisSpecies, @"A", @"L"];
                    [pile_dr setKey:key];
                    pile_dr.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    
                    pile_dr.value4 = [[totalPileVolume decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[thisSpeciesPercent decimalValue]]] decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithDouble:([wasteStr.gradeXPercent doubleValue]/100)]];
                    pile_dr.value10 = [pile_dr.value4 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
                    
                    pile_dr.speices = thisSpecies;
                    pile_dr.class = @"Avoid";
                    pile_dr.kind = @"X";
                    [rowSet addObject:pile_dr];
                }if(wasteStr.gradeYPercent != nil && ![wasteStr.gradeYPercent isEqualToNumber:[NSNumber numberWithInt:0]]){
                    ReportDataRow *pile_dr = [[ReportDataRow alloc] init];
                    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", thisSpecies, @"A", @"L"];
                    [pile_dr setKey:key];
                    pile_dr.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    pile_dr.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    
                    pile_dr.value5 = [[totalPileVolume decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[thisSpeciesPercent decimalValue]]] decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithDouble:([wasteStr.gradeYPercent doubleValue]/100)]];
                    pile_dr.value11 = [pile_dr.value5 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
                    
                    pile_dr.speices = thisSpecies;
                    pile_dr.class = @"Avoid";
                    pile_dr.kind = @"X";
                    [rowSet addObject:pile_dr];
                }
            }
        }
    }
    return rowSet;
}
-(ReportDataRow*) getNewDataRow:(NSString *) key gvalue1:(NSDecimalNumber *)gvalue1 gvalue2:(NSDecimalNumber *)gvalue2 gvalue3:(NSDecimalNumber *)gvalue3 gvalue4:(NSDecimalNumber *)gvalue4 gvalue5:(NSDecimalNumber *)gvalue5 wasteStr:(WasteStratum*)wasteStr wastePlot:(WastePlot*)wastePlot{
    ReportDataRow *new_row = [[ReportDataRow alloc] init];
    [new_row setKey:key];
    //NSLog(@"-> key:%@ v1:%@ v2:%@ v3:%@ v4:%@ v5:%@ mp:%@, smp:%@" , key, gvalue1, gvalue2, gvalue3, gvalue4, gvalue5, wasteStr.stratumPlotSizeCode.plotMultipler, wastePlot.surveyedMeasurePercent);
    if((wasteStr.stratumAssessmentMethodCode || [wastePlot.surveyedMeasurePercent doubleValue] == 0)){
        NSDecimalNumberHandler *behaviorND = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:4 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];

        NSDecimalNumber *mp = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", wastePlot.surveyedMeasurePercent]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        
        int plotsize = 0;
        if([wasteStr.stratumBlock.ratioSamplingEnabled intValue] == 1){
            //for ratio sampling block, only count the ones is marked as measure plot.
            for(WastePlot *p in wasteStr.stratumPlot){
                if([p.isMeasurePlot intValue] == 1){
                    plotsize = plotsize + 1;
                }
            }
        }else{
            plotsize = (int) wasteStr.stratumPlot.count ;
        }
        NSDecimalNumber *plot_size = [[NSDecimalNumber alloc] initWithInt:plotsize];
        //NSDecimalNumber *plot_size = [[NSDecimalNumber alloc] initWithInt:[wasteStr.stratumPlot count] > 1 ? [wasteStr.stratumPlot count] : 1];
        if([wasteStr.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
            if([plot_size intValue] == 0 ){
                new_row.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                new_row.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                new_row.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                new_row.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                new_row.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
            }else{
                new_row.value6 = [[[[gvalue1 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value7 = [[[[gvalue2 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value8 = [[[[gvalue3 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value9 = [[[[gvalue4 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value10 = [[[[gvalue5 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
            }
        }else {
            new_row.value6 = [[[gvalue1 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
            new_row.value7 = [[[gvalue2 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
            new_row.value8 = [[[gvalue3 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
            new_row.value9 = [[[gvalue4 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
            new_row.value10 = [[[gvalue5 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];}
    }else{
        new_row.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        new_row.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        new_row.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        new_row.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        new_row.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    }
    
    new_row.value1 = [new_row.value6 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    new_row.value2 = [new_row.value7 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    new_row.value3 = [new_row.value8 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    new_row.value4 = [new_row.value9 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    new_row.value5 = [new_row.value10 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    
    //NSLog(@"<- key:%@ v1:%@ v2:%@ v3:%@ v4:%@ v5:%@", key, new_row.value1, new_row.value2, new_row.value3, new_row.value4, new_row.value5);
    
    return new_row;
}

-(void) addToDataset:(NSMutableArray *)dataset datarow:(ReportDataRow *)datarow{

    BOOL added = NO;
    for (ReportDataRow *dr in dataset){
        //find a matching key
        if( [dr.key isEqualToString:datarow.key]){
            dr.value1 = [dr.value1 decimalNumberByAdding:datarow.value1];
            dr.value2 = [dr.value2 decimalNumberByAdding:datarow.value2];
            dr.value3 = [dr.value3 decimalNumberByAdding:datarow.value3];
            dr.value4 = [dr.value4 decimalNumberByAdding:datarow.value4];
            dr.value5 = [dr.value5 decimalNumberByAdding:datarow.value5];
            dr.value6 = [dr.value6 decimalNumberByAdding:datarow.value6];
            dr.value7 = [dr.value7 decimalNumberByAdding:datarow.value7];
            dr.value8 = [dr.value8 decimalNumberByAdding:datarow.value8];
            dr.value9 = [dr.value9 decimalNumberByAdding:datarow.value9];
            dr.value10 = [dr.value10 decimalNumberByAdding:datarow.value10];

            added= YES;
            break;
        }
    }
    
    if(!added){
        ReportDataRow *newDr = [[ReportDataRow alloc] init];
        newDr.value1 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value1 decimalValue]];
        newDr.value2 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value2 decimalValue]];
        newDr.value3 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value3 decimalValue]];
        newDr.value4 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value4 decimalValue]];
        newDr.value5 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value5 decimalValue]];
        newDr.value6 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value6 decimalValue]];
        newDr.value7 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value7 decimalValue]];
        newDr.value8 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value8 decimalValue]];
        newDr.value9 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value9 decimalValue]];
        newDr.value10 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value10 decimalValue]];
        newDr.key = [NSString stringWithString:datarow.key];
        newDr.class = [NSString stringWithString:datarow.class];
        newDr.speices = [NSString stringWithString:datarow.speices];
        newDr.kind = [NSString stringWithString:datarow.kind];
        [dataset addObject:newDr];
    }
}

-(void) addTotal:(ReportDataRow *)total_datarow data:(ReportDataRow*)data round:(BOOL)round{
    total_datarow.value1 = !total_datarow.value1 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value1 decimalValue]]: [total_datarow.value1 decimalNumberByAdding:data.value1];
    total_datarow.value2 = !total_datarow.value2 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value2 decimalValue]]: [total_datarow.value2 decimalNumberByAdding:data.value2];
    total_datarow.value3 = !total_datarow.value3 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value3 decimalValue]]: [total_datarow.value3 decimalNumberByAdding:data.value3];
    total_datarow.value4 = !total_datarow.value4 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value4 decimalValue]]: [total_datarow.value4 decimalNumberByAdding:data.value4];
    total_datarow.value5 = !total_datarow.value5 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value5 decimalValue]]: [total_datarow.value5 decimalNumberByAdding:data.value5];
    total_datarow.value6 = !total_datarow.value6 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value6 decimalValue]]: [total_datarow.value6 decimalNumberByAdding:data.value6];
    total_datarow.value7 = !total_datarow.value7 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value7 decimalValue]]: [total_datarow.value7 decimalNumberByAdding:data.value7];
    total_datarow.value8 = !total_datarow.value8 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value8 decimalValue]]: [total_datarow.value8 decimalNumberByAdding:data.value8];
    total_datarow.value9 = !total_datarow.value9 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value9 decimalValue]]: [total_datarow.value9 decimalNumberByAdding:data.value9];
    total_datarow.value10 = !total_datarow.value10 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value10 decimalValue]]: [total_datarow.value10 decimalNumberByAdding:data.value10];
    if (round){
        NSDecimalNumberHandler *behaviorND = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        
        total_datarow.value1 = [total_datarow.value1 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value2 = [total_datarow.value2 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value3 = [total_datarow.value3 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value4 = [total_datarow.value4 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value5 = [total_datarow.value5 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value6 = [total_datarow.value6 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value7 = [total_datarow.value7 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value8 = [total_datarow.value8 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value9 = [total_datarow.value9 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value10 = [total_datarow.value10 decimalNumberByRoundingAccordingToBehavior:behaviorND];
    }
}

-(void) addCoastTotal:(ReportDataRow *)total_datarow data:(ReportDataRow*)data round:(BOOL)round{
    total_datarow.value1 = !total_datarow.value1 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value1 decimalValue]]: [total_datarow.value1 decimalNumberByAdding:data.value1];
    total_datarow.value2 = !total_datarow.value2 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value2 decimalValue]]: [total_datarow.value2 decimalNumberByAdding:data.value2];
    total_datarow.value3 = !total_datarow.value3 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value3 decimalValue]]: [total_datarow.value3 decimalNumberByAdding:data.value3];
    total_datarow.value4 = !total_datarow.value4 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value4 decimalValue]]: [total_datarow.value4 decimalNumberByAdding:data.value4];
    total_datarow.value5 = !total_datarow.value5 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value5 decimalValue]]: [total_datarow.value5 decimalNumberByAdding:data.value5];
    total_datarow.value6 = !total_datarow.value6 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value6 decimalValue]]: [total_datarow.value6 decimalNumberByAdding:data.value6];
    total_datarow.value7 = !total_datarow.value7 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value7 decimalValue]]: [total_datarow.value7 decimalNumberByAdding:data.value7];
    total_datarow.value8 = !total_datarow.value8 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value8 decimalValue]]: [total_datarow.value8 decimalNumberByAdding:data.value8];
    total_datarow.value9 = !total_datarow.value9 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value9 decimalValue]]: [total_datarow.value9 decimalNumberByAdding:data.value9];
    total_datarow.value10 = !total_datarow.value10 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value10 decimalValue]]: [total_datarow.value10 decimalNumberByAdding:data.value10];
    total_datarow.value11 = !total_datarow.value11 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value11 decimalValue]]: [total_datarow.value11 decimalNumberByAdding:data.value11];
    total_datarow.value12 = !total_datarow.value12 ? [NSDecimalNumber decimalNumberWithDecimal:[data.value12 decimalValue]]: [total_datarow.value12 decimalNumberByAdding:data.value12];
    if (round){
        NSDecimalNumberHandler *behaviorND = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        
        total_datarow.value1 = [total_datarow.value1 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value2 = [total_datarow.value2 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value3 = [total_datarow.value3 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value4 = [total_datarow.value4 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value5 = [total_datarow.value5 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value6 = [total_datarow.value6 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value7 = [total_datarow.value7 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value8 = [total_datarow.value8 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value9 = [total_datarow.value9 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value10 = [total_datarow.value10 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value11 = [total_datarow.value11 decimalNumberByRoundingAccordingToBehavior:behaviorND];
        total_datarow.value12 = [total_datarow.value12 decimalNumberByRoundingAccordingToBehavior:behaviorND];
    }
}

-(void) clearDatarow:(ReportDataRow*) datarow{
    datarow.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
}

-(void) clearCoastDatarow:(ReportDataRow*) datarow{
    datarow.value1 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value2 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value3 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value4 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value5 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value6 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    datarow.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
}

// recalculte the value 6 to value 10 with new area
-(void) recalculateValue:(ReportDataRow*)datarow area:(NSDecimalNumber*)area{
    datarow.value6 = [datarow.value1 decimalNumberByDividingBy:area];
    datarow.value7 = [datarow.value2 decimalNumberByDividingBy:area];
    datarow.value8 = [datarow.value3 decimalNumberByDividingBy:area];
    datarow.value9 = [datarow.value4 decimalNumberByDividingBy:area];
    datarow.value10 = [datarow.value5 decimalNumberByDividingBy:area];
}

// recalculte the value 6 to value 10 with new area
-(void) recalculateCoastValue:(ReportDataRow*)datarow area:(NSDecimalNumber*)area{
    datarow.value7 = [datarow.value1 decimalNumberByDividingBy:area];
    datarow.value8 = [datarow.value2 decimalNumberByDividingBy:area];
    datarow.value9 = [datarow.value3 decimalNumberByDividingBy:area];
    datarow.value10 = [datarow.value4 decimalNumberByDividingBy:area];
    datarow.value11 = [datarow.value5 decimalNumberByDividingBy:area];
    datarow.value12 = [datarow.value6 decimalNumberByDividingBy:area];
}

-(NSString *)getTextRow:(NSString *)row text1:(NSString*)text1 text2:(NSString *)text2 text3:(NSString*)text3 datarow:(ReportDataRow*)datarow{
    NSString *vc1, *vc2, *vc3, *vc4, *vc5, *vc6, *vc7, *vc8, *vc9, *vc10  = [[NSString alloc] init];

    vc1 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value1.floatValue];
    vc2 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value2.floatValue];
    vc3 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value3.floatValue];
    vc4 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value4.floatValue];
    vc5 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value5.floatValue];
    vc6 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value6.floatValue];
    vc7 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value7.floatValue];
    vc8 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value8.floatValue];
    vc9 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value9.floatValue];
    vc10 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value10.floatValue];

    if (!text3 && text2 && text1){
        return [NSString stringWithFormat:row,text1, text2 ,vc1, vc2, vc3, vc4, vc5, vc6, vc7, vc8, vc9, vc10];
    }else if(!text3 && !text2 && text1 ){
        return [NSString stringWithFormat:row,text1 ,vc1, vc2, vc3, vc4, vc5, vc6, vc7, vc8, vc9, vc10];
    }else{
        return [NSString stringWithFormat:row,text1, text2, text3 ,vc1, vc2, vc3, vc4, vc5, vc6, vc7, vc8, vc9, vc10];
    }
}

-(ReportDataRow*) getNewDataCoastRow:(NSString *) key gvalue1:(NSDecimalNumber *)gvalue1 gvalue2:(NSDecimalNumber *)gvalue2 gvalue3:(NSDecimalNumber *)gvalue3 gvalue4:(NSDecimalNumber *)gvalue4 gvalue5:(NSDecimalNumber *)gvalue5  gvalue6:(NSDecimalNumber *)gvalue6 wasteStr:(WasteStratum*)wasteStr wastePlot:(WastePlot*)wastePlot{
    ReportDataRow *new_row = [[ReportDataRow alloc] init];
    [new_row setKey:key];
    //NSLog(@"-> key:%@ v1:%@ v2:%@ v3:%@ v4:%@ v5:%@ mp:%@, smp:%@" , key, gvalue1, gvalue2, gvalue3, gvalue4, gvalue5, gvalue6, wasteStr.stratumPlotSizeCode.plotMultipler, wastePlot.surveyedMeasurePercent);
    if((wasteStr.stratumAssessmentMethodCode || [wastePlot.surveyedMeasurePercent doubleValue] == 0)){
        NSDecimalNumberHandler *behaviorND = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:4 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        
        NSDecimalNumber *mp = [[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", wastePlot.surveyedMeasurePercent]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        
        int plotsize = 0;
        if([wasteStr.stratumBlock.ratioSamplingEnabled intValue] == 1){
            //for ratio sampling block, only count the ones is marked as measure plot.
            for(WastePlot *p in wasteStr.stratumPlot){
                if([p.isMeasurePlot intValue] == 1){
                    plotsize = plotsize + 1;
                }
            }
        }else{
            plotsize = (int) wasteStr.stratumPlot.count ;
        }
        NSDecimalNumber *plot_size = [[NSDecimalNumber alloc] initWithInt:plotsize];
        if([wasteStr.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
            if([plot_size intValue] == 0 ){
                new_row.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                new_row.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                new_row.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                new_row.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                new_row.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                new_row.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
            }else{
                new_row.value7 = [[[[gvalue1 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value8 = [[[[gvalue2 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value9 = [[[[gvalue3 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value10 = [[[[gvalue4 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value11 = [[[[gvalue5 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value12 = [[[[gvalue6 decimalNumberByMultiplyingBy:wasteStr.stratumPlotSizeCode.plotMultipler] decimalNumberByDividingBy:mp] decimalNumberByDividingBy:plot_size] decimalNumberByRoundingAccordingToBehavior:behaviorND];
            }
        }else {
                new_row.value7 = [[[gvalue1 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value8 = [[[gvalue2 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value9 = [[[gvalue3 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value10 = [[[gvalue4 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value11 = [[[gvalue5 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
                new_row.value12 = [[[gvalue6 decimalNumberByDividingBy:mp] decimalNumberByDividingBy:wasteStr.stratumSurveyArea] decimalNumberByRoundingAccordingToBehavior:behaviorND];
        }
        
    }else{
        new_row.value7 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        new_row.value8 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        new_row.value9 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        new_row.value10 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        new_row.value11 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        new_row.value12 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    }
    
    new_row.value1 = [new_row.value7 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    new_row.value2 = [new_row.value8 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    new_row.value3 = [new_row.value9 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    new_row.value4 = [new_row.value10 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    new_row.value5 = [new_row.value11 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    new_row.value6 = [new_row.value12 decimalNumberByDividingBy:wasteStr.stratumSurveyArea];
    //NSLog(@"<- key:%@ v1:%@ v2:%@ v3:%@ v4:%@ v5:%@ v6:%@", key, new_row.value1, new_row.value2, new_row.value3, new_row.value4, new_row.value5, new_row.value6);
    
    return new_row;
}

-(void) addToCoastDataset:(NSMutableArray *)dataset datarow:(ReportDataRow *)datarow{
    
    BOOL added = NO;
    for (ReportDataRow *dr in dataset){
        //find a matching key
        if( [dr.key isEqualToString:datarow.key]){
            dr.value1 = [dr.value1 decimalNumberByAdding:datarow.value1];
            dr.value2 = [dr.value2 decimalNumberByAdding:datarow.value2];
            dr.value3 = [dr.value3 decimalNumberByAdding:datarow.value3];
            dr.value4 = [dr.value4 decimalNumberByAdding:datarow.value4];
            dr.value5 = [dr.value5 decimalNumberByAdding:datarow.value5];
            dr.value6 = [dr.value6 decimalNumberByAdding:datarow.value6];
            dr.value7 = [dr.value7 decimalNumberByAdding:datarow.value7];
            dr.value8 = [dr.value8 decimalNumberByAdding:datarow.value8];
            dr.value9 = [dr.value9 decimalNumberByAdding:datarow.value9];
            dr.value10 = [dr.value10 decimalNumberByAdding:datarow.value10];
            dr.value11 = [dr.value11 decimalNumberByAdding:datarow.value11];
            dr.value12 = [dr.value12 decimalNumberByAdding:datarow.value12];
            added= YES;
            break;
        }
    }
    
    if(!added){
        ReportDataRow *newDr = [[ReportDataRow alloc] init];
        newDr.value1 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value1 decimalValue]];
        newDr.value2 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value2 decimalValue]];
        newDr.value3 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value3 decimalValue]];
        newDr.value4 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value4 decimalValue]];
        newDr.value5 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value5 decimalValue]];
        newDr.value6 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value6 decimalValue]];
        newDr.value7 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value7 decimalValue]];
        newDr.value8 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value8 decimalValue]];
        newDr.value9 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value9 decimalValue]];
        newDr.value10 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value10 decimalValue]];
        newDr.value11 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value11 decimalValue]];
        newDr.value12 = [NSDecimalNumber decimalNumberWithDecimal:[datarow.value12 decimalValue]];
        newDr.key = [NSString stringWithString:datarow.key];
        newDr.class = [NSString stringWithString:datarow.class];
        newDr.speices = [NSString stringWithString:datarow.speices];
        newDr.kind = [NSString stringWithString:datarow.kind];
        [dataset addObject:newDr];
    }
}
-(NSString *)getCoastTextRow:(NSString *)row text1:(NSString*)text1 text2:(NSString *)text2 text3:(NSString*)text3 datarow:(ReportDataRow*)datarow{
    NSString *vc1, *vc2, *vc3, *vc4, *vc5, *vc6, *vc7, *vc8, *vc9, *vc10, *vc11, *vc12  = [[NSString alloc] init];
    
    vc1 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value1.floatValue];
    vc2 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value2.floatValue];
    vc3 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value3.floatValue];
    vc4 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value4.floatValue];
    vc5 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value5.floatValue];
    vc6 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value6.floatValue];
    vc7 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value7.floatValue];
    vc8 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value8.floatValue];
    vc9 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value9.floatValue];
    vc10 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value10.floatValue];
    vc11 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value11.floatValue];
    vc12 = [[NSString alloc] initWithFormat:@"%.1f", datarow.value12.floatValue];
    
    if (!text3 && text2 && text1){
        return [NSString stringWithFormat:row,text1, text2 ,vc1, vc2, vc3, vc4, vc5, vc6, vc7, vc8, vc9, vc10, vc11, vc12];
    }else if(!text3 && !text2 && text1 ){
        return [NSString stringWithFormat:row,text1 ,vc1, vc2, vc3, vc4, vc5, vc6, vc7, vc8, vc9, vc10, vc11, vc12];
    }else{
        return [NSString stringWithFormat:row,text1, text2, text3 ,vc1, vc2, vc3, vc4, vc5, vc6, vc7, vc8, vc9, vc10, vc11, vc12];
    }
}

@end
