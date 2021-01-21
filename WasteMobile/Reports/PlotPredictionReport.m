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


-(GenerateOutcomeCode) generateReport:(WasteBlock *)wastBlock suffix:(NSString *)suffix replace:(BOOL)replace{
    
    NSLog(@"Genereate plot prediction report (CSV)");
    
    [super checkReportFolder];
    NSError *error = nil;
    
    // check if we got WasteBlock
    if(wastBlock==nil){
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
    
    NSString *zippedName = [NSString stringWithFormat: @"%@PlotPredictionReport%@.csv",[super getReportFilePrefix:wastBlock], suffix];
    NSString *zippedPath = [documentsDirectory stringByAppendingPathComponent:zippedName];
    
    NSLog(@" zippedPath = %@ ", zippedPath ); // test
    
    // Check if file already exists (unless we force the write)
    if ( [[NSFileManager defaultManager] fileExistsAtPath:zippedPath] && !replace) {
        NSLog(@"File exists already");
        return Fail_Filename_Exist;
    }

    
    NSSet *tmpStratums = [wastBlock blockStratum];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
    NSArray *sortedStratums = [tmpStratums sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    //header based on interior and coast region
    NSString* mainbody;
    if([wastBlock.regionId integerValue] == InteriorRegion){
        //initial the body with column header
        mainbody = @"\"IPad identifier\",\"Surveyor\",\"Reporting Unit\",\"License\",\"CP\",\"Block\",\"Stratum\",\"Plot No\",\"Time stamp\",\"GPS coordinate\","
        "\"Random Selection indicator\",\"Predicted Green Volume\",\"Predicted Dry Volume\",\"Attribute Changed\"\n";
    }else if ([wastBlock.regionId integerValue] == CoastRegion){
        //initial the body with column header
        mainbody = @"\"IPad identifier\",\"Surveyor\",\"Reporting Unit\",\"License\",\"CP\",\"Block\",\"Stratum\",\"Plot No\",\"Time stamp\",\"GPS coordinate\","
        "\"Random Selection indicator\",\"Predicted Plot Volume\",\"Attribute Changed\"\n";
    }

    NSArray *roratioSamplingLogItems;
    NSMutableArray *ratioSamplingLogItems = [NSMutableArray new];
    NSString *buildmainbody;
    NSInteger substitutionloopcouter, ratioSamplingLogItemscounter, attemptcount, ratioSamplingLogoffset, numoffieldsinauditlog;
    
    for(WasteStratum* ws in sortedStratums){
        // Pulls header data from Cut Block in preparation for substituting data into audit log (ratioSamplingLog)
        if(![ws.ratioSamplingLog isEqualToString:@""]){
        roratioSamplingLogItems = [ws.ratioSamplingLog componentsSeparatedByString:@";;"];
        attemptcount = roratioSamplingLogItems.count-1;                                                                 // counts number of audit records
        roratioSamplingLogItems = [ws.ratioSamplingLog componentsSeparatedByString:@"\",\""];
        ratioSamplingLogItemscounter = roratioSamplingLogItems.count-1;                                                 // counter number of fields
        numoffieldsinauditlog = ratioSamplingLogItemscounter / attemptcount;
        
        // test for divide by 0 or, total number of fields in ratioSamplingLog not evenly divisible by number of fields in one record
        if ((attemptcount == 0) || (ratioSamplingLogItemscounter % attemptcount != 0)){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Application Error" message:@"PlotPrediction Divide Error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return Fail_Unknown;
        }
        
        ratioSamplingLogItems = [NSMutableArray arrayWithArray:roratioSamplingLogItems];
        // Loop through each record of the auditlog (rationSamplingLog) and substitute surveyorName, Reporting Unit Number, License, Cutting Permit Number and Cut Block fields
        // using cut block header information
        if([wastBlock.regionId integerValue] == InteriorRegion){
            for(substitutionloopcouter=0; substitutionloopcouter <attemptcount; substitutionloopcouter++){
                ratioSamplingLogoffset = substitutionloopcouter*numoffieldsinauditlog;
                [ratioSamplingLogItems removeObjectAtIndex:                                         1+ratioSamplingLogoffset]; // surveyorName
                [ratioSamplingLogItems insertObject:wastBlock.surveyorName atIndex:                 1+ratioSamplingLogoffset];
                [ratioSamplingLogItems removeObjectAtIndex:                                         2+ratioSamplingLogoffset]; // reporting unit number
                [ratioSamplingLogItems insertObject:[wastBlock.reportingUnit stringValue] atIndex:  2+ratioSamplingLogoffset];
                [ratioSamplingLogItems removeObjectAtIndex:                                         3+ratioSamplingLogoffset]; // License
                [ratioSamplingLogItems insertObject:wastBlock.licenceNumber atIndex:                3+ratioSamplingLogoffset];
                [ratioSamplingLogItems removeObjectAtIndex:                                         4+ratioSamplingLogoffset]; // Cutting Permit Number
                [ratioSamplingLogItems insertObject:wastBlock.cuttingPermitId atIndex:              4+ratioSamplingLogoffset];
                [ratioSamplingLogItems removeObjectAtIndex:                                         5+ratioSamplingLogoffset]; // Cut Block
                [ratioSamplingLogItems insertObject:wastBlock.cutBlockId atIndex:                   5+ratioSamplingLogoffset];
            }
        }else if([wastBlock.regionId integerValue] == CoastRegion){
            int counter = 0;
            for(substitutionloopcouter=0; substitutionloopcouter <attemptcount; substitutionloopcouter++){
                ratioSamplingLogoffset = substitutionloopcouter*numoffieldsinauditlog;
                [ratioSamplingLogItems removeObjectAtIndex:                                         1+(ratioSamplingLogoffset-counter)]; // surveyorName
                [ratioSamplingLogItems insertObject:wastBlock.surveyorName atIndex:                 1+(ratioSamplingLogoffset-counter)];
                [ratioSamplingLogItems removeObjectAtIndex:                                         2+(ratioSamplingLogoffset-counter)]; // reporting unit number
                [ratioSamplingLogItems insertObject:[wastBlock.reportingUnit stringValue] atIndex:  2+(ratioSamplingLogoffset-counter)];
                [ratioSamplingLogItems removeObjectAtIndex:                                         3+(ratioSamplingLogoffset-counter)]; // License
                [ratioSamplingLogItems insertObject:wastBlock.licenceNumber atIndex:                3+(ratioSamplingLogoffset-counter)];
                [ratioSamplingLogItems removeObjectAtIndex:                                         4+(ratioSamplingLogoffset-counter)]; // Cutting Permit Number
                [ratioSamplingLogItems insertObject:wastBlock.cuttingPermitId atIndex:              4+(ratioSamplingLogoffset-counter)];
                [ratioSamplingLogItems removeObjectAtIndex:                                         5+(ratioSamplingLogoffset-counter)]; // Cut Block
                [ratioSamplingLogItems insertObject:wastBlock.cutBlockId atIndex:                   5+(ratioSamplingLogoffset-counter)];
                [ratioSamplingLogItems removeObjectAtIndex:                                         12+(ratioSamplingLogoffset-counter)];
                counter = counter+1;
            }
        }
        buildmainbody = [ratioSamplingLogItems componentsJoinedByString:@"\",\""];

        if(buildmainbody && ![buildmainbody isEqualToString:@""]){
            mainbody = [mainbody stringByAppendingString:buildmainbody];
            
        }
        ratioSamplingLogItems = nil;  // deallocates memory
    }
    }
    
        // Pulls header data from Cut Block in preparation for substituting data into audit log (ratioSamplingLog)
        if(![wastBlock.ratioSamplingLog isEqualToString:@""]){
            roratioSamplingLogItems = [wastBlock.ratioSamplingLog componentsSeparatedByString:@";;"];
            attemptcount = roratioSamplingLogItems.count-1;                                                                 // counts number of audit records
            roratioSamplingLogItems = [wastBlock.ratioSamplingLog componentsSeparatedByString:@"\",\""];
            ratioSamplingLogItemscounter = roratioSamplingLogItems.count-1;                                                 // counter number of fields
            numoffieldsinauditlog = ratioSamplingLogItemscounter / attemptcount;
            
            // test for divide by 0 or, total number of fields in ratioSamplingLog not evenly divisible by number of fields in one record
            if ((attemptcount == 0) || (ratioSamplingLogItemscounter % attemptcount != 0)){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Application Error" message:@"PlotPrediction Divide Error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return Fail_Unknown;
            }
            
            ratioSamplingLogItems = [NSMutableArray arrayWithArray:roratioSamplingLogItems];
            // Loop through each record of the auditlog (rationSamplingLog) and substitute surveyorName, Reporting Unit Number, License, Cutting Permit Number and Cut Block fields
            // using cut block header information
            if([wastBlock.regionId integerValue] == InteriorRegion){
                if([wastBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                    for(substitutionloopcouter=0; substitutionloopcouter <attemptcount; substitutionloopcouter++){
                        ratioSamplingLogoffset = substitutionloopcouter*numoffieldsinauditlog;
                        [ratioSamplingLogItems removeObjectAtIndex:                                         1+ratioSamplingLogoffset]; // surveyorName
                        [ratioSamplingLogItems insertObject:wastBlock.surveyorName atIndex:                 1+ratioSamplingLogoffset];
                        [ratioSamplingLogItems removeObjectAtIndex:                                         2+ratioSamplingLogoffset]; // reporting unit number
                        [ratioSamplingLogItems insertObject:[wastBlock.reportingUnit stringValue] atIndex:  2+ratioSamplingLogoffset];
                        [ratioSamplingLogItems removeObjectAtIndex:                                         3+ratioSamplingLogoffset]; // License
                        [ratioSamplingLogItems insertObject:wastBlock.licenceNumber atIndex:                3+ratioSamplingLogoffset];
                        [ratioSamplingLogItems removeObjectAtIndex:                                         4+ratioSamplingLogoffset]; // Cutting Permit Number
                        [ratioSamplingLogItems insertObject:wastBlock.cuttingPermitId atIndex:              4+ratioSamplingLogoffset];
                        [ratioSamplingLogItems removeObjectAtIndex:                                         5+ratioSamplingLogoffset]; // Cut Block
                        [ratioSamplingLogItems insertObject:wastBlock.cutBlockId atIndex:                   5+ratioSamplingLogoffset];
                    }
                }
            }else if([wastBlock.regionId integerValue] == CoastRegion){
                if([wastBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                    int counter = 0;
                    for(substitutionloopcouter=0; substitutionloopcouter <attemptcount; substitutionloopcouter++){
                        ratioSamplingLogoffset = substitutionloopcouter*numoffieldsinauditlog;
                        [ratioSamplingLogItems removeObjectAtIndex:                                         1+(ratioSamplingLogoffset-counter)]; // surveyorName
                        [ratioSamplingLogItems insertObject:wastBlock.surveyorName atIndex:                 1+(ratioSamplingLogoffset-counter)];
                        [ratioSamplingLogItems removeObjectAtIndex:                                         2+(ratioSamplingLogoffset-counter)]; // reporting unit number
                        [ratioSamplingLogItems insertObject:[wastBlock.reportingUnit stringValue] atIndex:  2+(ratioSamplingLogoffset-counter)];
                        [ratioSamplingLogItems removeObjectAtIndex:                                         3+(ratioSamplingLogoffset-counter)]; // License
                        [ratioSamplingLogItems insertObject:wastBlock.licenceNumber atIndex:                3+(ratioSamplingLogoffset-counter)];
                        [ratioSamplingLogItems removeObjectAtIndex:                                         4+(ratioSamplingLogoffset-counter)]; // Cutting Permit Number
                        [ratioSamplingLogItems insertObject:wastBlock.cuttingPermitId atIndex:              4+(ratioSamplingLogoffset-counter)];
                        [ratioSamplingLogItems removeObjectAtIndex:                                         5+(ratioSamplingLogoffset-counter)]; // Cut Block
                        [ratioSamplingLogItems insertObject:wastBlock.cutBlockId atIndex:                   5+(ratioSamplingLogoffset-counter)];
                        [ratioSamplingLogItems removeObjectAtIndex:                                         12+(ratioSamplingLogoffset-counter)];
                        counter = counter+1;
                    }
                }
            }
            buildmainbody = [ratioSamplingLogItems componentsJoinedByString:@"\",\""];
            
            if(buildmainbody && ![buildmainbody isEqualToString:@""]){
                mainbody = [mainbody stringByAppendingString:buildmainbody];
                
            }
            ratioSamplingLogItems = nil;  // deallocates memory
        }
    
    mainbody = [mainbody stringByReplacingOccurrencesOfString:@";;" withString:@"\n"];

    if(error != nil)
    {
        NSLog(@"Failed to create persistent store. Error %@.", error);
        //abort();
        return Fail_Unknown;
    }
    
    // data should not be nil
    if (mainbody == nil) abort();
    
    // Write to disk
    [mainbody writeToFile:zippedPath atomically:YES];
    
    NSLog(@"Plot Prediciton report is generated");
    
    return Successful;
}

@end
