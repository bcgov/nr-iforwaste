//
//  ReportGenerator.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-05.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WasteBlock;
@class WastePlot;
@class Timbermark;

typedef enum GenerateOutcomeCode{
    Successful,
    Fail_Filename_Exist,
    Fail_Unknown
}GenerateOutcomeCode;

typedef enum ReportTypeCode{
    CheckSummaryReportType = 1,
    FS702ReportType = 2,
    PlotTallyReportType = 3
}ReportTypeCode;

@interface ReportGenerator : NSObject


-(void)checkReportFolder;

-(GenerateOutcomeCode) generateReport:(WasteBlock *)wasteBlock withPlot:(WastePlot*)wastePlot suffix:(NSString *)subffix replace:(BOOL)replace;

-(GenerateOutcomeCode) generateReport:(WasteBlock *)wasteBlock suffix:(NSString *)subffix replace:(BOOL)replace;

-(GenerateOutcomeCode) generateReport:(WasteBlock *)wasteBlock withTimbermark:(Timbermark*)timbermark suffix:(NSString *)subffix replace:(BOOL)replace;

-(NSString *) getReportFilePrefix:(WasteBlock *)wasteBlock;

-(NSString *) getFooter:(WasteBlock *)wasteBlock note:(NSString*)note;

@end
