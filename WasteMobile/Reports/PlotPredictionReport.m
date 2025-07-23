//
//  PlotPredictionReport.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-03-17.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import "PlotPredictionReport.h"

#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "Constants.h"

@implementation PlotPredictionReport
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


-(GenerateOutcomeCode) generateReport:(WasteBlock *)wasteBlock suffix:(NSString *)suffix replace:(BOOL)replace{
    
    
    [super checkReportFolder];
    NSError *error = nil;
    
    // check if we got WasteBlock
    if(wasteBlock==nil){
        NSLog(@"PlotPredictionReport-wasteBlock=nil");
        return Fail_Unknown;
    }
    
    // Figure out destination name (in public docs dir)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempFilePath =[documentsDirectory stringByAppendingString:@"/ReportTemplate/"];

    if( ![suffix isEqualToString:@""]){
        suffix = [NSString stringWithFormat:@"_%@", [suffix stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    }
    
    NSString *zippedName = [NSString stringWithFormat: @"%@PlotPredictionReport%@.csv",[super getReportFilePrefix:wasteBlock], suffix];
    NSString *zippedPath = [documentsDirectory stringByAppendingPathComponent:zippedName];
    
    NSLog(@" zippedPath = %@ ", zippedPath ); // test
    
    // Check if file already exists (unless we force the write)
    if ( [[NSFileManager defaultManager] fileExistsAtPath:zippedPath] && !replace) {
        NSLog(@"File exists already");
        return Fail_Filename_Exist;
    }

    
    NSSet *tmpStratums = [wasteBlock blockStratum];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
    NSArray *sortedStratums = [tmpStratums sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    //header based on interior and coast region
    NSString* mainBody;
    //initial the body with column header
    mainBody = @"\"IPad identifier\",\"Surveyor\",\"Reporting Unit\",\"License\",\"CP\",\"Block\",\"Stratum\",\"Plot No\",\"Time stamp\",\"GPS coordinate\","
        "\"Random Selection indicator\",\"Predicted Volume\",\"Measure %\",\"Plot Data Tracker\",\"Signing Professional\",\"Designation\",\"License No.\",\"Signature\",\"Rationale\"\n";


    NSArray *roRatioSamplingLogEntries;
    NSArray *roRatioSamplingLogItems;
    NSMutableArray *ratioSamplingLogItems = [NSMutableArray new];
    NSString *buildMainBody;
    NSInteger substitutionLoopCounter, ratioSamplingLogItemsCounter, attemptCount, ratioSamplingLogOffset, numOfFieldsInAuditLog;
    
    BOOL *hasData = FALSE;
    // Pulls header data from Cut Block in preparation for substituting data into audit log (ratioSamplingLog)
    if(![wasteBlock.ratioSamplingLog isEqualToString:@""]){
        // logic to convert old coast ratiosamplinglogs
//        NSString *testLog = @"\"40851923-E9C1-49D8-9BE1-F563C660ED26\",\"\",\"3\",\"3\",\"3\",\"3\",\"PBRX\",\"1\",\"2023-09-13 11:31:06\",\"N/A\",\"YES\",\"7.07\",\"\",\"New Plot Added\";;\"40851923-E9C1-49D8-9BE1-F563C660ED26\",\"\",\"3\",\"3\",\"3\",\"3\",\"PBRX\",\"2\",\"2023-09-13 11:31:26\",\"N/A\",\"YES\",\"21.21\",\"\",\"New Plot Added\";;";
//        NSLog(@"%@", testLog);
        
//        if([wasteBlock.regionId integerValue] == CoastRegion){
            NSArray *components = [wasteBlock.ratioSamplingLog componentsSeparatedByString:@";;"];
//            NSArray *components = [testLog componentsSeparatedByString:@";;"];
            NSMutableArray *outputComponents = [NSMutableArray array];
            NSInteger i = 1;
            for (NSString *component in components) {
                NSArray *subComponents = [component componentsSeparatedByString:@",\""];
                if ([subComponents count] == 0 || [subComponents count] == 1) {
                    continue;
                }
                NSMutableArray *newSubComponents = [subComponents mutableCopy];
                
                // fix certain test files
                if (newSubComponents.count == 20) {
                    BOOL lastSixEmpty = YES;
                    for (NSInteger j = 14; j < 20; j++) {
                        NSString *value = newSubComponents[j];
                        if (![value isEqualToString:@"\""]) {
                            lastSixEmpty = NO;
                            break;
                        }
                    }
                    if (lastSixEmpty) {
                        NSRange rangeToRemove = NSMakeRange(14, 6);
                        [newSubComponents removeObjectsInRange:rangeToRemove];
                    }
                }
                
                // old file logs didn't have measure percent values, add an empty string at the appropriate index
                if (newSubComponents.count == 14) {
                    [newSubComponents insertObject:@"\"" atIndex:12];
                }
                
                if (newSubComponents.count < 20) {
                    // Add extra empty fields to make it 20 elements
                    while (newSubComponents.count < 20) {
                        if (newSubComponents.count < 19) {
                            [newSubComponents addObject:@"\""];
                        } else {
                            [newSubComponents addObject:@""];
                        }
                    }
                    
                    NSString *newComponent = [newSubComponents componentsJoinedByString:@",\""];
                    NSString *outputComponent;
                    if (i < components.count-1) {
                        outputComponent = [NSString stringWithFormat:@"%@\"", newComponent];
                    } else {
                        outputComponent = [NSString stringWithFormat:@"%@\";;", newComponent];
                    }
                    
                    [outputComponents addObject:outputComponent];
                    i++;
                } else {
                    NSString *outputComponent = [newSubComponents componentsJoinedByString:@",\""];
                    [outputComponents addObject:outputComponent];
                    i++;
                }
            }
            NSString *outputString = [outputComponents componentsJoinedByString:@";;"];
            outputString = [outputString stringByAppendingString:@";;"];
            if (outputString.length >= 4 && [outputString hasSuffix:@";;;;"]) {
                outputString = [outputString substringToIndex:outputString.length - 2];
            }
            NSLog(@"Updating Coast block sampling log");
            wasteBlock.ratioSamplingLog = outputString;
//        }
        
        // continue with report generation
        roRatioSamplingLogItems  = [wasteBlock.ratioSamplingLog componentsSeparatedByString:@";;"];
        NSMutableArray *roRatioSamplingLogEntries = [roRatioSamplingLogItems mutableCopy];
        attemptCount = roRatioSamplingLogItems.count-1;                                                                 // counts number of audit records
        roRatioSamplingLogItems = [wasteBlock.ratioSamplingLog componentsSeparatedByString:@"\",\""];
        ratioSamplingLogItemsCounter = roRatioSamplingLogItems.count-1;                                                 // counter number of fields
        numOfFieldsInAuditLog = ratioSamplingLogItemsCounter / attemptCount;
        
        // test for divide by 0 or, total number of fields in ratioSamplingLog not evenly divisible by number of fields in one record
        if ((attemptCount == 0) || (ratioSamplingLogItemsCounter % attemptCount != 0)){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Application Error" message:@"PlotPrediction Divide Error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return Fail_Unknown;
        }
        
        ratioSamplingLogItems = [NSMutableArray arrayWithArray:roRatioSamplingLogItems];
        // Loop through each record of the auditlog (rationSamplingLog) and substitute surveyorName, Reporting Unit Number, License, Cutting Permit Number and Cut Block fields
        // using cut block header information
        ratioSamplingLogOffset = 0;
        
        
        
        if([wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
            NSLog(@"Non-Aggregate!");
            for(substitutionLoopCounter=0; substitutionLoopCounter <attemptCount; substitutionLoopCounter++){
                [ratioSamplingLogItems removeObjectAtIndex:                                         2+ratioSamplingLogOffset]; // reporting unit number
                [ratioSamplingLogItems insertObject:[wasteBlock.reportingUnit stringValue] atIndex:  2+ratioSamplingLogOffset];
                [ratioSamplingLogItems removeObjectAtIndex:                                         12+ratioSamplingLogOffset]; // Predicted Dry Volume
            
                NSArray *currentItem = [[roRatioSamplingLogEntries objectAtIndex:substitutionLoopCounter] componentsSeparatedByString:@"\",\""];
                if([[[roRatioSamplingLogEntries objectAtIndex:substitutionLoopCounter] componentsSeparatedByString:@"\",\""] count] == 14)//Pre-1.4.3 report
                {
                    [ratioSamplingLogItems insertObject:@"" atIndex:                   13+ratioSamplingLogOffset];
                    ratioSamplingLogOffset += [[[roRatioSamplingLogEntries objectAtIndex:substitutionLoopCounter] componentsSeparatedByString:@"\",\""] count];
                }
                else
                {
                    ratioSamplingLogOffset += [[[roRatioSamplingLogEntries objectAtIndex:substitutionLoopCounter] componentsSeparatedByString:@"\",\""] count] - 2;
                }
            }
        }
        else
        {
            NSLog(@"Aggregate!");
            for(substitutionLoopCounter=0; substitutionLoopCounter <attemptCount; substitutionLoopCounter++){
                [ratioSamplingLogItems removeObjectAtIndex:                                         12+ratioSamplingLogOffset]; // Dry Volume

                NSArray *currentItem = [[roRatioSamplingLogEntries objectAtIndex:substitutionLoopCounter] componentsSeparatedByString:@"\",\""];

                if([[[roRatioSamplingLogEntries objectAtIndex:substitutionLoopCounter] componentsSeparatedByString:@"\",\""] count] == 14)//Pre-1.4.3 report
                {
                    [ratioSamplingLogItems insertObject:@"" atIndex:                   13+ratioSamplingLogOffset];
                    ratioSamplingLogOffset += [[[roRatioSamplingLogEntries objectAtIndex:substitutionLoopCounter] componentsSeparatedByString:@"\",\""] count];
                }
                else
                {
                    ratioSamplingLogOffset += [[[roRatioSamplingLogEntries objectAtIndex:substitutionLoopCounter] componentsSeparatedByString:@"\",\""] count] - 2;
                }
            }
        }

        buildMainBody = [ratioSamplingLogItems componentsJoinedByString:@"\",\""];
        
        if(buildMainBody && ![buildMainBody isEqualToString:@""]){
            mainBody = [mainBody stringByAppendingString:buildMainBody];
            
        }
        
        //initial the body with column header
        mainBody = [mainBody stringByAppendingString:@"\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\","
                "\"\",\"\",\"\",\"* measurement data deleted\",\"\",\"\",\"\",\"\",\"\"\n"];

        ratioSamplingLogItems = nil;  // deallocates memory
    }
    
    mainBody = [mainBody stringByReplacingOccurrencesOfString:@";;" withString:@"\n"];
    
    if(error != nil)
    {
        NSLog(@"Failed to create persistent store. Error %@.", error);
        return Fail_Unknown;
    }
    
    // data should not be nil
    if (mainBody == nil) abort();
    
    // Write to disk
    [mainBody writeToFile:zippedPath atomically:YES];
    
    NSLog(@"Plot Prediciton report is generated");
    
    return Successful;
}

@end
