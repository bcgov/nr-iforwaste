//
//  ReportGenerator.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-05.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "ReportGenerator.h"
#import "WasteBlock.h"
#import "WastePlot.h"

@implementation ReportGenerator

-(void) checkReportFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Get documents folder
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/WasteReports"];
    
    NSError *error = nil;

     /*
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    if(error != nil)
    {
        NSLog(@"Failed to create persistent store. Error %@.", error);
        abort();
    }
    */
    
     NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *reportTempPath = [documentsDirectory stringByAppendingPathComponent:@"/ReportTemplate"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:reportTempPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:reportTempPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    if(error != nil)
    {
        NSLog(@"Failed to create report template folder. Error %@.", error);
        abort();
    }

    //copy the report template files to under app folder
    //otherwise app can't open the template file
 
    NSMutableArray *fileStrAry =[[NSMutableArray alloc] init];
    
    [fileStrAry addObject:@"ROW1_1"];
    [fileStrAry addObject:@"ROW1_2"];
    [fileStrAry addObject:@"ROW_2"];
    [fileStrAry addObject:@"ROW_3"];
    [fileStrAry addObject:@"TABLE1_1"];
    [fileStrAry addObject:@"TABLE1_2"];
    [fileStrAry addObject:@"TABLE1_3"];
    [fileStrAry addObject:@"TABLE2_1"];
    [fileStrAry addObject:@"TABLE2_2"];
    [fileStrAry addObject:@"TABLE3_1"];
    [fileStrAry addObject:@"CSS_1"];
    [fileStrAry addObject:@"CSS_2"];
    [fileStrAry addObject:@"CSS_3"];
    [fileStrAry addObject:@"TD_2"];
    [fileStrAry addObject:@"NOTE"];
    [fileStrAry addObject:@"FOOTER"];
    [fileStrAry addObject:@"TITLE"];
    [fileStrAry addObject:@"REPORT"];
    [fileStrAry addObject:@"BTSMainTemplate"];
    [fileStrAry addObject:@"BTSTable1"];
    [fileStrAry addObject:@"BTSTable2"];
    [fileStrAry addObject:@"BTSTable3"];
    [fileStrAry addObject:@"BTSRow1"];
    [fileStrAry addObject:@"BTSRow2"];
    [fileStrAry addObject:@"BTSRow3"];
    
    
    for (NSString *fileStr in fileStrAry){
        
        NSString *reportTempFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/ReportTemplate/%@.html", fileStr]];
        
        if ([fileManager fileExistsAtPath:reportTempFilePath] == NO) {
            NSString *resourcePath = [[NSBundle mainBundle] pathForResource:fileStr ofType:@"html"];
            [fileManager copyItemAtPath:resourcePath toPath:reportTempFilePath error:&error];
        }
    }
    

    if(error != nil)
    {
        NSLog(@"Failed to create persistent store. Error %@.", error);
        abort();
    }
}

-(GenerateOutcomeCode) generateReport:(WasteBlock *)wasteBlock withPlot:(WastePlot*)wastPlot suffix:(NSString *)subffix replace:(BOOL)replace{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}



-(GenerateOutcomeCode) generateReport:(WasteBlock *)wasteBlock suffix:(NSString *)subffix replace:(BOOL)replace{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


-(GenerateOutcomeCode) generateReport:(WasteBlock *)wasteBlock withTimbermark:(Timbermark*)timbermark suffix:(NSString *)subffix replace:(BOOL)replace{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}



-(NSString *) getReportFilePrefix:(WasteBlock *)wasteBlock{
    NSString *reportPrefix = @"";
    reportPrefix = [reportPrefix stringByAppendingFormat:@"/RU%@_Block%@_", wasteBlock.reportingUnit, wasteBlock.blockNumber];

    return reportPrefix;
}

-(NSString *) getFooter:(WasteBlock*)wasteBlock note:(NSString*)note{
    NSString *FOOTER;
    NSString *tmpPath;
    NSError *errorForHTML;
    
    tmpPath = [[NSBundle mainBundle] pathForResource: @"FOOTER" ofType: @"html"];
    FOOTER = [NSString stringWithContentsOfFile: tmpPath encoding:NSUTF8StringEncoding error: &errorForHTML];
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    NSString *dateString = [dateFormat stringFromDate:today];
    
    if([wasteBlock.userCreated integerValue] == 0){
        FOOTER = [NSString stringWithFormat:FOOTER, note, @"Audit", dateString, @"Auditor", (wasteBlock.checkerName ? wasteBlock.checkerName : @"") ];
    }else{
        FOOTER = [NSString stringWithFormat:FOOTER, note, @"Survey", dateString, @"Surveyor", (wasteBlock.surveyorName ? wasteBlock.surveyorName : @"") ];
    }
    
    return FOOTER;
}

@end
