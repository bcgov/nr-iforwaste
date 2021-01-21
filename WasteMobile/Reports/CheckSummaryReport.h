//
//  CheckSummaryReport.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-08-25.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ReportGenerator.h"

@class WasteStratum;
@class WasteBlock;

@interface CheckSummaryReport : ReportGenerator

-(void) generateReportByStratum:(WasteStratum *)wasteStratum;
-(void) generateReportByBlock:(WasteBlock *)wasteBlock;



@end
