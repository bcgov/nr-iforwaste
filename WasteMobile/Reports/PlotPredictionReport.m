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
    
    //initial the body with column header
    NSString* mainbody = @"\"IPad identifier\",\"Surveyor\",\"Reporting Unit\",\"License\",\"CP\",\"Block\",\"Stratum\",\"Plot No\",\"Time stamp\",\"GPS coordinate\","
        "\"Random Selection indicator\",\"Predicted Green Volume\",\"Predicted Dry Volume\",\"All prediction attempts\"\n";
    
    for(WasteStratum* ws in sortedStratums){
        if(ws.ratioSamplingLog && ![ws.ratioSamplingLog isEqualToString:@""]){
            mainbody = [mainbody stringByAppendingString:ws.ratioSamplingLog];
        }
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
