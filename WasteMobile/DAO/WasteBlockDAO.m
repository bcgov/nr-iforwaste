	//
//  WasteBlockDAO.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-09.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "WasteBlockDAO.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "WastePiece.h"
#import "Timbermark.h"
#import "EFWCoastStat+CoreDataClass.h"
#import "EFWInteriorStat+CoreDataClass.h"
#import "Constants.h"
#import "PlotSampleGenerator.h"
#import "PlotSelectorLog.h"
#import "WastePile+CoreDataClass.h"
#import "PileShapeCode+CoreDataClass.h"

@implementation WasteBlockDAO


+(NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

+(WasteBlock *) getWasteBlockByCutBlockId:(NSString *) cutBlockId reportingUnitId:(NSString *)reportUnitId{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    [context save:&error];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    // EFW-558 fix
    [request setPredicate:nil];
    NSArray *result = [context executeFetchRequest:request error:&error];

    
    WasteBlock *wb = nil;
    int inputReportingUnit = [reportUnitId intValue];

    // Iterate over the existing waste blocks, comparing them to the input values
    for (WasteBlock *wasteBlock in result) {
        // Convert nil values found from the request to empty strings
        NSString *existingCutBlockId = wasteBlock.cutBlockId ?: @"";
        int existingReportingUnit = [wasteBlock.reportingUnit intValue];

        // If a match is found, return it
        if (existingReportingUnit == inputReportingUnit &&
            [existingCutBlockId isEqualToString:cutBlockId]) {
            
            wb = wasteBlock;
            break;
        }
    }
    
    return wb;
}

+(WasteBlock *) getWasteBlockByAssessmentAreaId:(NSString *) assessmentAreaId{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    [context save:&error];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @" wasteAssessmentAreaID = %@ ", assessmentAreaId];
    
    [request setPredicate:predicate];
    
    // NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result.count > 0) {
        return result[0];
    }else{
        return nil;
    }
}

+(WasteBlock *) getWasteBlockByRU:(NSString *) ru cutBlockId:(NSString *)cutBlockId license:(NSString*)license cutPermit:(NSString*)cutPermit{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock" inManagedObjectContext:context];
    
    [request setEntity:entity];
    [request setPredicate:nil];
    
    // If a user uploads a file, stays on the page, and uploads the same file,
    // issues will arise if string values in the file were nil. This is because
    // they are converted to empty strings after leaving the file upload page
    
    // Get all the uploaded WasteBlocks
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    WasteBlock *wb = nil;
    int inputReportingUnit = [ru intValue];

    // Iterate over the existing waste blocks, comparing them to the input values
    for (WasteBlock *wasteBlock in result) {
        // Convert nil values found from the request to empty strings
        NSString *existingCutBlockId = wasteBlock.cutBlockId ?: @"";
        NSString *existingCuttingPermitId = wasteBlock.cuttingPermitId ?: @"";
        NSString *existingLicenceNumber = wasteBlock.licenceNumber ?: @"";
        int existingReportingUnit = [wasteBlock.reportingUnit intValue];

        // If a match is found, return it
        if (existingReportingUnit == inputReportingUnit &&
            [existingCutBlockId isEqualToString:cutBlockId] &&
            [existingCuttingPermitId isEqualToString:cutPermit] &&
            [existingLicenceNumber isEqualToString:license]) {
            
            wb = wasteBlock;
            break;
        }
    }
    
    return wb;
}
+(WasteBlock *) getWasteBlockByRUCheckDuplicate:(NSString *) ru cutBlockId:(NSString *)cutBlockId license:(NSString*)license cutPermit:(NSString*)cutPermit{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    // EFW-558 fix
    [request setPredicate:nil];
    NSArray *result = [context executeFetchRequest:request error:&error];

    
    WasteBlock *wb = nil;
    int inputReportingUnit = [ru intValue];

    // Iterate over the existing waste blocks, comparing them to the input values
    for (WasteBlock *wasteBlock in result) {
        // Convert nil values found from the request to empty strings
        NSString *existingCutBlockId = wasteBlock.cutBlockId ?: @"";
        NSString *existingCuttingPermitId = wasteBlock.cuttingPermitId ?: @"";
        NSString *existingLicenceNumber = wasteBlock.licenceNumber ?: @"";
        int existingReportingUnit = [wasteBlock.reportingUnit intValue];

        // If a match is found, return it
        if (existingReportingUnit == inputReportingUnit &&
            [existingCutBlockId isEqualToString:cutBlockId] &&
            [existingCuttingPermitId isEqualToString:cutPermit] &&
            [existingLicenceNumber isEqualToString:license]) {
            
            wb = wasteBlock;
            break;
        }
    }
    
    return wb;
}

+(WasteBlock *) getWasteBlockByRUButWAID:(NSString *) ru cutBlockId:(NSString *)cutBlockId license:(NSString*)license cutPermit:(NSString*)cutPermit wasteAsseID:(NSString *)wasteAsseID{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    ru = [ru stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cutBlockId = cutBlockId ? [cutBlockId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    license = license ? [license stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    cutPermit = cutPermit ? [cutPermit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    
    // EFW-558 fix
    [request setPredicate:nil];
    NSArray *result = [context executeFetchRequest:request error:&error];

    
    WasteBlock *wb = nil;
    int inputReportingUnit = [ru intValue];

    // Iterate over the existing waste blocks, comparing them to the input values
    for (WasteBlock *wasteBlock in result) {
        // Convert nil values found from the request to empty strings
        NSString *existingCutBlockId = wasteBlock.cutBlockId ?: @"";
        NSString *existingCuttingPermitId = wasteBlock.cuttingPermitId ?: @"";
        NSString *existingLicenceNumber = wasteBlock.licenceNumber ?: @"";
        int existingReportingUnit = [wasteBlock.reportingUnit intValue];

        // If a match is found, return it
        if (existingReportingUnit == inputReportingUnit &&
            [existingCutBlockId isEqualToString:cutBlockId] &&
            [existingCuttingPermitId isEqualToString:cutPermit] &&
            [existingLicenceNumber isEqualToString:license]) {
            
            wb = wasteBlock;
            break;
        }
    }
    
    return wb;
}

+(WasteBlock *) createEmptyCutBlock:(int) regionId ratioSample:(BOOL)ratioSample isAggregate:(BOOL)isAggregate{
    
    NSManagedObjectContext *context = [self managedObjectContext];

    // create a new waste cut block
    WasteBlock *wasteBlock = [NSEntityDescription insertNewObjectForEntityForName:@"WasteBlock" inManagedObjectContext:context];
    
    // get the max waste block id in core data
    wasteBlock.wasteAssessmentAreaID = [self GetNextAssessmentAreaId];

    wasteBlock.versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    //set the entry date
    wasteBlock.entryDate = [NSDate date];
    wasteBlock.regionId = [[NSNumber alloc] initWithInt:regionId];
    wasteBlock.ratioSamplingEnabled = [NSNumber numberWithBool:ratioSample];
    if([wasteBlock.regionId integerValue] == CoastRegion){
        wasteBlock.blockCoastStat = [self createEFWCoastStat];
    }else if([wasteBlock.regionId integerValue] == InteriorRegion){
        wasteBlock.blockInteriorStat = [self createEFWInteriorStat];
    }
    wasteBlock.isAggregate = [NSNumber numberWithBool:isAggregate];
    if([wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:YES] intValue]){
        wasteBlock.ratioSamplingLog = @"";
    }
    [wasteBlock setUserCreated:[NSNumber numberWithBool:YES]];
    
    return wasteBlock;
}

+(Timbermark *) createEmptyTimbermark{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    Timbermark *tm = [NSEntityDescription insertNewObjectForEntityForName:@"Timbermark" inManagedObjectContext:context];
    
    return tm;
}

+(WasteStratum *) createEmptyStratum{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WasteStratum *wasteStratum = [NSEntityDescription insertNewObjectForEntityForName:@"WasteStratum" inManagedObjectContext:context];

    return wasteStratum;
}

+(WastePlot *) createEmptyPlot{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePlot *wastePlot = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
    
    return wastePlot;
}

+(WastePiece *) createEmptyPiece{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePiece *wastePiece = [NSEntityDescription insertNewObjectForEntityForName:@"WastePiece" inManagedObjectContext:context];
    
    return wastePiece;
}

+(StratumPile *) createEmptyStratumPile{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    StratumPile *stratumPile = [NSEntityDescription insertNewObjectForEntityForName:@"StratumPile" inManagedObjectContext:context];
    
    return stratumPile;
}

+(WastePile *) createEmptyWastePile{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePile *wastePile = [NSEntityDescription insertNewObjectForEntityForName:@"WastePile" inManagedObjectContext:context];
    
    return wastePile;
}

+(EFWCoastStat *) createEFWCoastStat{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    EFWCoastStat *cs = [NSEntityDescription insertNewObjectForEntityForName:@"EFWCoastStat" inManagedObjectContext:context];
    
    cs.gradeJValue= [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeJValueHa= [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeJVolume= [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeJVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeYValue = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeYValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeYVolume = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeYVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeUHBValue = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeUHBValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeUHBVolume = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeUHBVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeUValue = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeUValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeUVolume = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeUVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeXHBValue = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeXHBValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeXHBVolume = [[NSDecimalNumber alloc] initWithInt:0];
    cs.gradeXHBVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
   
    cs.totalBillValue = [[NSDecimalNumber alloc] initWithInt:0];
    cs.totalBillValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.totalBillVolume = [[NSDecimalNumber alloc] initWithInt:0];
    cs.totalBillVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.totalControlValue = [[NSDecimalNumber alloc] initWithInt:0];
    cs.totalControlValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    cs.totalControlVolume = [[NSDecimalNumber alloc] initWithInt:0];
    cs.totalControlVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];

    return cs;
}

+(EFWInteriorStat *) createEFWInteriorStat{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    EFWInteriorStat *its = [NSEntityDescription insertNewObjectForEntityForName:@"EFWInteriorStat" inManagedObjectContext:context];

    its.grade4Value = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade4Volume = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade4ValueHa= [[NSDecimalNumber alloc] initWithInt:0];
    its.grade4VolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade124Value = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade124ValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade124Volume = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade124VolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade12Value = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade12ValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade12Volume = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade12VolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade5Value = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade5ValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade5Volume = [[NSDecimalNumber alloc] initWithInt:0];
    its.grade5VolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    
    its.totalBillValue = [[NSDecimalNumber alloc] initWithInt:0];
    its.totalBillValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    its.totalBillVolume = [[NSDecimalNumber alloc] initWithInt:0];
    its.totalBillVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];
    its.totalControlValue = [[NSDecimalNumber alloc] initWithInt:0];
    its.totalControlValueHa = [[NSDecimalNumber alloc] initWithInt:0];
    its.totalControlVolume = [[NSDecimalNumber alloc] initWithInt:0];
    its.totalControlVolumeHa = [[NSDecimalNumber alloc] initWithInt:0];

    return its;
}

// Delete cut block and its internal components (stratum, plot etc.)
+(void) deleteCutBlock:(WasteBlock *) targetWasteBlock {
    
    NSManagedObjectContext *context = [self managedObjectContext];

    for(WasteStratum *wst in targetWasteBlock.blockStratum) {
        [self deleteStratum:wst usingWB:targetWasteBlock];
    }
        
    [context deleteObject:targetWasteBlock];
   
    NSError *error;
    [context save:&error];
    
    if (error) {
        NSLog(@"Error when saving deletion of cut block: %@", error);
    }
}

// Delete stratum and its internal components (plot, plot piece etc.)
+(void) deleteStratum:(WasteStratum *) targetWasteStratum usingWB:(WasteBlock *) targetWasteBlock {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    BOOL hasRatioLogMsg = false;
    // Step 1 - Remove the piece and plot object
    NSMutableSet *tempPlot = [NSMutableSet setWithSet:targetWasteStratum.stratumPlot];
    if([targetWasteStratum.stratumBlock.ratioSamplingEnabled integerValue]== 1){
          if(targetWasteBlock.ratioSamplingLog != nil){
              if(targetWasteStratum.stratumPlot.count > 0)
              {
                  targetWasteBlock.ratioSamplingLog = [targetWasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:targetWasteStratum actionDec:@"Delete Stratum*"]];
                  hasRatioLogMsg = true;
              }
          }
    }
    for (WastePlot *wpl in targetWasteStratum.stratumPlot) {
          // Remove each plot piece - cast to superclass NSManagedObject so it can be removed
      for(NSManagedObject *wpi in wpl.plotPiece){
           [context deleteObject:wpi];
       }
       [tempPlot removeObject:wpl];
       [context deleteObject:wpl];
    }
    targetWasteStratum.stratumPlot = tempPlot;
    
    NSMutableSet *temppile = [NSMutableSet setWithSet:targetWasteStratum.stratumPile];
    
    if([targetWasteStratum.stratumBlock.ratioSamplingEnabled integerValue]== 1){
          if(targetWasteBlock.ratioSamplingLog != nil){
              if(targetWasteStratum.stratumPile.count > 0)
              {
                  targetWasteBlock.ratioSamplingLog = [targetWasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:targetWasteStratum actionDec:@"Delete Stratum*"]];
                  hasRatioLogMsg = true;
              }
          }
    }
    if ([targetWasteStratum.isPileStratum intValue] == 1) {
        for (WastePile *wp in targetWasteStratum.stratumPile) {
            [temppile removeObject:wp];
            [context deleteObject:wp];
        }
        targetWasteStratum.stratumPile = temppile;
    }
    
    //if no message yet it was an empty stratum, no asterisk in msgLog
    if(!hasRatioLogMsg && [targetWasteStratum.stratumBlock.ratioSamplingEnabled integerValue]== 1)
    {
        targetWasteBlock.ratioSamplingLog = [targetWasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:targetWasteStratum actionDec:@"Delete Stratum"]];
    }
    
    // Step 2 - Remove stratum
    NSMutableSet *tempStratum = [NSMutableSet setWithSet:targetWasteBlock.blockStratum];
    [tempStratum removeObject:targetWasteStratum];
    targetWasteBlock.blockStratum = tempStratum;
    
    // Step 3 - Delete the stratum from core data
    [context deleteObject:targetWasteStratum];
    
    NSError *error;
    [context save:&error];
    
    if (error) {
        NSLog(@"Error when saving deletion of stratum: %@", error);
    }
}

+(MergeOutcomeCode) mergeWasteBlock:(WasteBlock*)primary_wb WasteBlock:(WasteBlock*)secondary_wb{
    if (primary_wb &&  secondary_wb) {
        
        //comparing Cut Block Fields
        if(primary_wb.location && secondary_wb.location && ([[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.location = [NSString stringWithString:[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.location && ![[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.location = [NSString stringWithString:[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.location && [[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.location = [NSString stringWithString:[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.yearLoggedTo && secondary_wb.yearLoggedTo && [primary_wb.yearLoggedTo integerValue] == [secondary_wb.yearLoggedTo integerValue]){
            primary_wb.yearLoggedTo =  [NSNumber numberWithInteger:[primary_wb.yearLoggedTo integerValue]];
        }
        
        if(primary_wb.yearLoggedFrom && secondary_wb.yearLoggedFrom && [primary_wb.yearLoggedFrom integerValue] == [secondary_wb.yearLoggedFrom integerValue]){
            primary_wb.yearLoggedFrom =  [NSNumber numberWithInteger:[primary_wb.yearLoggedFrom integerValue]];
        }
        
        if(primary_wb.loggingCompleteDate && secondary_wb.loggingCompleteDate && [primary_wb.loggingCompleteDate isEqualToDate:secondary_wb.loggingCompleteDate]){
            primary_wb.loggingCompleteDate =  [[NSDate alloc] initWithTimeInterval:0 sinceDate:primary_wb.loggingCompleteDate] ;
        }
        
        if(primary_wb.surveyDate && secondary_wb.surveyDate && [primary_wb.surveyDate isEqualToDate:secondary_wb.surveyDate]){
            primary_wb.surveyDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:primary_wb.surveyDate];
        }
        
        if(primary_wb.netArea && secondary_wb.netArea && [primary_wb.netArea floatValue] == [secondary_wb.netArea floatValue]){
            primary_wb.netArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.netArea floatValue]];
        }
        
        if(primary_wb.surveyArea && secondary_wb.surveyArea && [primary_wb.surveyArea floatValue] == [secondary_wb.surveyArea floatValue]){
            primary_wb.surveyArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.surveyArea floatValue]];
        }
        
        if(primary_wb.npNFArea && secondary_wb.npNFArea && [primary_wb.npNFArea floatValue] == [secondary_wb.npNFArea floatValue]){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.npNFArea floatValue]];
        }
        if((isnan([primary_wb.npNFArea floatValue])) && (!(isnan([secondary_wb.npNFArea floatValue])))){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [secondary_wb.npNFArea floatValue]];
        }
        if((!(isnan([primary_wb.npNFArea floatValue]))) && (isnan([secondary_wb.npNFArea floatValue]))){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.npNFArea floatValue]];
        }
        
        if(secondary_wb.blockMaturityCode ){
            primary_wb.blockMaturityCode = secondary_wb.blockMaturityCode;
        }
        
        if(secondary_wb.blockSiteCode ){
            primary_wb.blockSiteCode = secondary_wb.blockSiteCode;
        }
        
        if(primary_wb.returnNumber && secondary_wb.returnNumber && [primary_wb.returnNumber integerValue] == [secondary_wb.returnNumber integerValue]){
            primary_wb.returnNumber =  [NSNumber numberWithInteger:[primary_wb.returnNumber integerValue]];
        }
        if([primary_wb.returnNumber integerValue] == 0 && [secondary_wb.returnNumber integerValue] != 0){
            primary_wb.returnNumber =  [NSNumber numberWithInteger:[secondary_wb.returnNumber integerValue]];
        }
        if([secondary_wb.returnNumber integerValue] == 0 && [primary_wb.returnNumber integerValue] != 0){
            primary_wb.returnNumber = [NSNumber numberWithInteger:[primary_wb.returnNumber integerValue]];
        }

        if(primary_wb.surveyorLicence && secondary_wb.surveyorLicence && ([[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.surveyorLicence = [NSString stringWithString:[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.surveyorLicence && ![[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorLicence = [NSString stringWithString:[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.surveyorLicence && [[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorLicence = [NSString stringWithString:[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.surveyorName && secondary_wb.surveyorName && ([[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] )){
            primary_wb.surveyorName = [NSString stringWithString:[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.surveyorName && ![[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorName = [NSString stringWithString:[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.surveyorName && [[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorName = [NSString stringWithString:[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.professional && secondary_wb.professional && ([[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.professional = [NSString stringWithString:[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.professional && ![[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.professional = [NSString stringWithString:[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.professional && [[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.professional = [NSString stringWithString:[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.registrationNumber && secondary_wb.registrationNumber && ([[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] )){
            primary_wb.registrationNumber = [NSString stringWithString:[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.registrationNumber && ![[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.registrationNumber = [NSString stringWithString:[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.registrationNumber && [[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.registrationNumber = [NSString stringWithString:[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.position && secondary_wb.position && ([[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.position = [NSString stringWithString:[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.position && ![[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.position = [NSString stringWithString:[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.position && [[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.position = [NSString stringWithString:[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        //append the note field after another
        if(!primary_wb.notes){
            primary_wb.notes = @"";
        }
        if(secondary_wb.notes){
            if([primary_wb.notes isEqualToString:@""] || primary_wb.notes == nil)
            {
                primary_wb.notes = secondary_wb.notes;
            }
            else
            {
                primary_wb.notes = [NSString stringWithFormat:@"%@, %@", primary_wb.notes, secondary_wb.notes];
            }
        }
        
        //comparing Timber Mark
        Timbermark *ptm = nil;
        Timbermark *stm = nil;
        //NSLog(@"pwb-timbermark: %@", [[primary_wb.blockTimbermark allObjects] objectAtIndex:0].timbermark);
        for (Timbermark *tm in primary_wb.blockTimbermark ){

            if(tm && tm.primaryInd){
                if([tm.primaryInd integerValue] == 1){
                    ptm = tm;
                }else{
                    stm = tm;
                }
            }
        }
        //NSLog(@"swb-timbermark: %@", [[secondary_wb.blockTimbermark allObjects] objectAtIndex:0].timbermark);
        for (Timbermark *tm_swb in secondary_wb.blockTimbermark){
            if(tm_swb && tm_swb.primaryInd){
                if([tm_swb.primaryInd integerValue] == 1){
                Timbermark *ttm = ptm ;
                
                    if(tm_swb.timbermark && [[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
                        ttm.timbermark = [NSString stringWithString:[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    }
                    /*if(tm_swb.coniferWMRF && [tm_swb.coniferWMRF floatValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                    }*/
                    if(ttm.coniferWMRF && tm_swb.coniferWMRF && [ttm.coniferWMRF floatValue] == [tm_swb.coniferWMRF floatValue]){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    if([ttm.coniferWMRF floatValue] == 0 && [tm_swb.coniferWMRF floatValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                    }
                    if([tm_swb.coniferWMRF floatValue] == 0 && [ttm.coniferWMRF integerValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    /*if(tm_swb.deciduousPrice && [tm_swb.deciduousPrice floatValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                    }*/
                    if(ttm.deciduousPrice && tm_swb.deciduousPrice && [ttm.deciduousPrice floatValue] == [tm_swb.deciduousPrice floatValue]){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if([ttm.deciduousPrice floatValue] == 0 && [tm_swb.deciduousPrice floatValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                    }
                    if([tm_swb.deciduousPrice floatValue] == 0 && [ttm.deciduousPrice integerValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if(tm_swb.area && [tm_swb.area floatValue] != 0){
                        ttm.area = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.area floatValue]];
                    }
                    [primary_wb addBlockTimbermarkObject:ttm];
                }
                if([tm_swb.primaryInd integerValue] == 2){
                    Timbermark *ttm = nil;
                    if(stm == nil) {
                        ttm = tm_swb ;
                    }else{
                        ttm = stm ;
                    }
                    if(tm_swb.timbermark && [[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
                        ttm.timbermark = [NSString stringWithString:[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    }
                    if(ttm.coniferWMRF && tm_swb.coniferWMRF && [ttm.coniferWMRF floatValue] == [tm_swb.coniferWMRF floatValue]){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    if([ttm.coniferWMRF floatValue] == 0 && [tm_swb.coniferWMRF floatValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                    }
                    if([tm_swb.coniferWMRF floatValue] == 0 && [ttm.coniferWMRF integerValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    if(ttm.deciduousPrice && tm_swb.deciduousPrice && [ttm.deciduousPrice floatValue] == [tm_swb.deciduousPrice floatValue]){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if([ttm.deciduousPrice floatValue] == 0 && [tm_swb.deciduousPrice floatValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                    }
                    if([tm_swb.deciduousPrice floatValue] == 0 && [ttm.deciduousPrice integerValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if(tm_swb.area && [tm_swb.area floatValue] != 0){
                        ttm.area = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.area floatValue]];
                    }
                    [primary_wb addBlockTimbermarkObject:ttm];
                }
            }
        }
        if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
            // note - this does not filter out any duplicate entries
            primary_wb.ratioSamplingLog = [primary_wb.ratioSamplingLog stringByAppendingString:secondary_wb.ratioSamplingLog];
        }
        // comparing Stratum
        NSMutableArray *stratumsToAdd = [NSMutableArray array];
        BOOL found_matching_st = NO;
        for (WasteStratum *sst_swb in secondary_wb.blockStratum){
            found_matching_st = NO;

            for (WasteStratum *sst_pwb in primary_wb.blockStratum ){
                if([sst_swb.stratum isEqualToString:sst_pwb.stratum]){
                    found_matching_st = YES;
                    
                    // Merge note field
                    if(!sst_pwb.notes) {
                        sst_pwb.notes = @"";
                    }
                    if(sst_swb.notes) {
                        sst_pwb.notes = [NSString stringWithFormat:@"%@, %@", sst_pwb.notes, sst_swb.notes];
                    }

                    // Move the plots from secondary to primary
                    NSMutableSet* secondary_plot_set = [NSMutableSet setWithSet:sst_swb.stratumPlot];
                    NSMutableSet* secondary_pile_set = [NSMutableSet setWithSet:sst_swb.stratumPile];
                    
                    if([sst_swb.stratumBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE]intValue]){
                        if([sst_swb.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:TRUE]intValue]) {
                            for(WastePile *pile in secondary_pile_set){
                                [sst_pwb addStratumPileObject:pile];
                            }
                        } else {
                            for(WastePlot *plot in secondary_plot_set){
                                [sst_pwb addStratumPlotObject:plot];
                            }
                        }
                    }
                    if([sst_swb.stratumBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE]intValue]){
                        for(WastePlot *plot in secondary_plot_set){
                            [sst_pwb addStratumPlotObject:plot];
                        }
                        for(WastePile *pile in secondary_pile_set){
                            [sst_pwb addStratumPileObject:pile];
                        }
                    }
                    break;
                }
            }
            if(!found_matching_st){
                //if stratum not in the primary block, merge whole stratum into primary
                [stratumsToAdd addObject:sst_swb];
            }
        }

        [primary_wb addBlockStratum:[NSSet setWithArray:stratumsToAdd]];

        return MergeSuccessful;
    }else{
        return MergeFailCutBlockNotFound;
    }
}

+(NSNumber *) GetNextAssessmentAreaId{
    
    NSNumber *newAssessmentAreaId = nil;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    request.fetchLimit = 1;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"wasteAssessmentAreaID" ascending:NO]];
    
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result.count > 0){
        WasteBlock *wb = (WasteBlock*)result[0];
        if ([wb.wasteAssessmentAreaID intValue] >= 90000000 ){
            newAssessmentAreaId = [[NSNumber alloc] initWithInt: [wb.wasteAssessmentAreaID intValue] + 1];
        }
    }
    if (!newAssessmentAreaId){
        newAssessmentAreaId = [[NSNumber alloc] initWithInt: 90000000];
    }

    return newAssessmentAreaId;
}

//Returns YES if invalid duplicate and NO otherwise
+(BOOL) checkDuplicateWasteBlockByRU: (NSString *) ru cutBlockId: (NSString *)cutBlockId license:(NSString *)license cutPermit:(NSString *)cutPermit assessmentAreaId:(NSNumber *)assessmentAreaId {
    
    ru = [ru stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cutBlockId = cutBlockId ? [cutBlockId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    license = license ? [license stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    cutPermit = cutPermit ? [cutPermit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    
    //Empty fields determining uniqueness nullify the need to check for a duplicate
    if ([ru isEqualToString:@""] && [cutBlockId isEqualToString:@""] && [license isEqualToString:@""] && [cutPermit isEqualToString:@""]) {
        return NO;
    }
    
    //If wasteblock in managed context (DB) isn't the same as the one created when "New Block" nav button is pressed, it is an invalid duplicate
    WasteBlock *found = [WasteBlockDAO getWasteBlockByRUCheckDuplicate:ru cutBlockId:cutBlockId license:license cutPermit:cutPermit];
    if (found && [[found wasteAssessmentAreaID] intValue] != [assessmentAreaId intValue]){
        return YES;
    } else {
        return NO;
    }
}

+(NSString*)mergeSamples:(NSString*)p_n1 secondary_n1:(NSString*)s_n1{
    NSArray* p_n1_ary = [p_n1 componentsSeparatedByString:@","];
    NSArray* s_n1_ary = [s_n1 componentsSeparatedByString:@","];
    NSMutableArray* result_ary = [[NSMutableArray alloc] init];

    for(NSString* p_pn in p_n1_ary){
        BOOL found_in_sec_ary = NO;
        for(NSString* s_pn in s_n1_ary){
            if([p_pn isEqualToString:s_pn]){
                found_in_sec_ary = YES;
                break;
            }
        }
        if (!found_in_sec_ary){
            [result_ary addObject:p_pn];
        }
        found_in_sec_ary = NO;
    }
    [result_ary addObject:s_n1];
    return [result_ary componentsJoinedByString:@","];
}

+(MergeOutcomeCode) mergeWasteBlockPileStratum:(WasteBlock*)primary_wb WasteBlock:(WasteBlock*)secondary_wb{
    if (primary_wb &&  secondary_wb) {
        
        //comparing Cut Block Fields
        if(primary_wb.location && secondary_wb.location && ([[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.location = [NSString stringWithString:[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.location && ![[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.location = [NSString stringWithString:[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.location && [[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.location = [NSString stringWithString:[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.yearLoggedTo && secondary_wb.yearLoggedTo && [primary_wb.yearLoggedTo integerValue] == [secondary_wb.yearLoggedTo integerValue]){
            primary_wb.yearLoggedTo =  [NSNumber numberWithInteger:[primary_wb.yearLoggedTo integerValue]];
        }
        
        if(primary_wb.yearLoggedFrom && secondary_wb.yearLoggedFrom && [primary_wb.yearLoggedFrom integerValue] == [secondary_wb.yearLoggedFrom integerValue]){
            primary_wb.yearLoggedFrom =  [NSNumber numberWithInteger:[primary_wb.yearLoggedFrom integerValue]];
        }
        
        if(primary_wb.loggingCompleteDate && secondary_wb.loggingCompleteDate && [primary_wb.loggingCompleteDate isEqualToDate:secondary_wb.loggingCompleteDate]){
            primary_wb.loggingCompleteDate =  [[NSDate alloc] initWithTimeInterval:0 sinceDate:primary_wb.loggingCompleteDate] ;
        }
        
        if(primary_wb.surveyDate && secondary_wb.surveyDate && [primary_wb.surveyDate isEqualToDate:secondary_wb.surveyDate]){
            primary_wb.surveyDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:primary_wb.surveyDate];
        }
        
        if(primary_wb.netArea && secondary_wb.netArea && [primary_wb.netArea floatValue] == [secondary_wb.netArea floatValue]){
            primary_wb.netArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.netArea floatValue]];
        }
        
        if(primary_wb.surveyArea && secondary_wb.surveyArea && [primary_wb.surveyArea floatValue] == [secondary_wb.surveyArea floatValue]){
            primary_wb.surveyArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.surveyArea floatValue]];
        }
        
        if(primary_wb.npNFArea && secondary_wb.npNFArea && [primary_wb.npNFArea floatValue] == [secondary_wb.npNFArea floatValue]){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.npNFArea floatValue]];
        }
        if((isnan([primary_wb.npNFArea floatValue])) && (!(isnan([secondary_wb.npNFArea floatValue])))){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [secondary_wb.npNFArea floatValue]];
        }
        if((!(isnan([primary_wb.npNFArea floatValue]))) && (isnan([secondary_wb.npNFArea floatValue]))){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.npNFArea floatValue]];
        }
        
        if(secondary_wb.blockMaturityCode ){
            primary_wb.blockMaturityCode = secondary_wb.blockMaturityCode;
        }
        
        if(secondary_wb.blockSiteCode ){
            primary_wb.blockSiteCode = secondary_wb.blockSiteCode;
        }
        
        if(primary_wb.returnNumber && secondary_wb.returnNumber && [primary_wb.returnNumber integerValue] == [secondary_wb.returnNumber integerValue]){
            primary_wb.returnNumber =  [NSNumber numberWithInteger:[primary_wb.returnNumber integerValue]];
        }
        if([primary_wb.returnNumber integerValue] == 0 && [secondary_wb.returnNumber integerValue] != 0){
            primary_wb.returnNumber =  [NSNumber numberWithInteger:[secondary_wb.returnNumber integerValue]];
        }
        if([secondary_wb.returnNumber integerValue] == 0 && [primary_wb.returnNumber integerValue] != 0){
            primary_wb.returnNumber = [NSNumber numberWithInteger:[primary_wb.returnNumber integerValue]];
        }

        if(primary_wb.surveyorLicence && secondary_wb.surveyorLicence && ([[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.surveyorLicence = [NSString stringWithString:[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.surveyorLicence && ![[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorLicence = [NSString stringWithString:[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.surveyorLicence && [[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorLicence = [NSString stringWithString:[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.surveyorName && secondary_wb.surveyorName && ([[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] )){
            primary_wb.surveyorName = [NSString stringWithString:[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.surveyorName && ![[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorName = [NSString stringWithString:[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.surveyorName && [[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorName = [NSString stringWithString:[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.professional && secondary_wb.professional && ([[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.professional = [NSString stringWithString:[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.professional && ![[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.professional = [NSString stringWithString:[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.professional && [[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.professional = [NSString stringWithString:[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.registrationNumber && secondary_wb.registrationNumber && ([[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] )){
            primary_wb.registrationNumber = [NSString stringWithString:[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.registrationNumber && ![[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.registrationNumber = [NSString stringWithString:[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.registrationNumber && [[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.registrationNumber = [NSString stringWithString:[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.position && secondary_wb.position && ([[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.position = [NSString stringWithString:[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.position && ![[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.position = [NSString stringWithString:[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.position && [[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.position = [NSString stringWithString:[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        //append the note field after another
        if(!primary_wb.notes){
            primary_wb.notes = @"";
        }
        if(secondary_wb.notes){
            if([primary_wb.notes isEqualToString:@""] || primary_wb.notes == nil)
            {
                primary_wb.notes = secondary_wb.notes;
            }
            else
            {
                primary_wb.notes = [NSString stringWithFormat:@"%@, %@", primary_wb.notes, secondary_wb.notes];
            }
        }
        
        //comparing Timber Mark
        Timbermark *ptm = nil;
        Timbermark *stm = nil;
        //NSLog(@"pwb-timbermark: %@", [[primary_wb.blockTimbermark allObjects] objectAtIndex:0].timbermark);
        for (Timbermark *tm in primary_wb.blockTimbermark ){

            if(tm && tm.primaryInd){
                if([tm.primaryInd integerValue] == 1){
                    ptm = tm;
                }else{
                    stm = tm;
                }
            }
        }
        //NSLog(@"swb-timbermark: %@", [[secondary_wb.blockTimbermark allObjects] objectAtIndex:0].timbermark);
        for (Timbermark *tm_swb in secondary_wb.blockTimbermark){
            if(tm_swb && tm_swb.primaryInd){
                if([tm_swb.primaryInd integerValue] == 1){
                Timbermark *ttm = ptm ;
                
                    if(tm_swb.timbermark && [[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
                        ttm.timbermark = [NSString stringWithString:[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    }
                    /*if(tm_swb.coniferWMRF && [tm_swb.coniferWMRF floatValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                    }*/
                    if(ttm.coniferWMRF && tm_swb.coniferWMRF && [ttm.coniferWMRF floatValue] == [tm_swb.coniferWMRF floatValue]){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    if([ttm.coniferWMRF floatValue] == 0 && [tm_swb.coniferWMRF floatValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                    }
                    if([tm_swb.coniferWMRF floatValue] == 0 && [ttm.coniferWMRF integerValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    /*if(tm_swb.deciduousPrice && [tm_swb.deciduousPrice floatValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                    }*/
                    if(ttm.deciduousPrice && tm_swb.deciduousPrice && [ttm.deciduousPrice floatValue] == [tm_swb.deciduousPrice floatValue]){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if([ttm.deciduousPrice floatValue] == 0 && [tm_swb.deciduousPrice floatValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                    }
                    if([tm_swb.deciduousPrice floatValue] == 0 && [ttm.deciduousPrice integerValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if(tm_swb.area && [tm_swb.area floatValue] != 0){
                        ttm.area = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.area floatValue]];
                    }
                    [primary_wb addBlockTimbermarkObject:ttm];
                }
                if([tm_swb.primaryInd integerValue] == 2){
                    Timbermark *ttm = nil;
                    if(stm == nil) {
                        ttm = tm_swb ;
                    }else{
                        ttm = stm ;
                    }
                    if(tm_swb.timbermark && [[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
                        ttm.timbermark = [NSString stringWithString:[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    }
                    if(ttm.coniferWMRF && tm_swb.coniferWMRF && [ttm.coniferWMRF floatValue] == [tm_swb.coniferWMRF floatValue]){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    if([ttm.coniferWMRF floatValue] == 0 && [tm_swb.coniferWMRF floatValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                    }
                    if([tm_swb.coniferWMRF floatValue] == 0 && [ttm.coniferWMRF integerValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    if(ttm.deciduousPrice && tm_swb.deciduousPrice && [ttm.deciduousPrice floatValue] == [tm_swb.deciduousPrice floatValue]){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if([ttm.deciduousPrice floatValue] == 0 && [tm_swb.deciduousPrice floatValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                    }
                    if([tm_swb.deciduousPrice floatValue] == 0 && [ttm.deciduousPrice integerValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if(tm_swb.area && [tm_swb.area floatValue] != 0){
                        ttm.area = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.area floatValue]];
                    }
                    [primary_wb addBlockTimbermarkObject:ttm];
                }
            }
        }
        if([primary_wb.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
            // comparing Stratum
            BOOL found_matching_st = NO;
            NSSet* stra_set = [NSSet setWithSet:secondary_wb.blockStratum];
            for (WasteStratum *sst_swb in stra_set){
               
                for (WasteStratum *sst_pwb in primary_wb.blockStratum ){
                    if([sst_swb.stratum isEqualToString:sst_pwb.stratum]){
                        found_matching_st = YES;
                        //merge note field
                        if(!sst_pwb.notes){
                            sst_pwb.notes = @"";
                        }
                        if(sst_swb.notes){
                            sst_pwb.notes = [NSString stringWithFormat:@"%@, %@", sst_pwb.notes, sst_swb.notes];
                        }
                        //move the pile from secondary to primary. Assuming stratumpile data will be made in master before sharing.So during merge there is no confict in pile number generated.
                        if([sst_swb.stratumBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                            [self mergeSingleBlkPileStratum:sst_pwb.stratumPile swb_pileData:sst_swb.stratumPile];
                            
                            if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                                //merge stratum ratio sampling log and plot selected
                                // note - this does not filter out any duplicate entries
                                sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                            }
                        }else{
                            if([sst_swb.stratumPile count] == 0){
                                
                            }else {
                                NSSet* pile_set = [NSSet setWithSet:sst_swb.stratumPile];
                                for(WastePile *swb_pile in pile_set){
                                    for(WastePile *pwb_pile in sst_pwb.stratumPile){
                                        if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                            if(([pwb_pile.length doubleValue] == 0 && [pwb_pile.width doubleValue] ==0 && [pwb_pile.height doubleValue] ==0 && [pwb_pile.measuredLength doubleValue] == 0 && [pwb_pile.measuredWidth doubleValue] == 0 && [pwb_pile.measuredHeight doubleValue] == 0 && [pwb_pile.measuredPileArea doubleValue] == 0 && [pwb_pile.measuredPileVolume doubleValue] == 0) && ([swb_pile.length doubleValue] == 0 && [swb_pile.width doubleValue] ==0 && [swb_pile.height doubleValue] ==0 && [swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                                                NSLog(@"case 1 in doc: where incoming file and receiving file is 0");
                                            }else if(([pwb_pile.length doubleValue] != 0 && [pwb_pile.width doubleValue] !=0 && [pwb_pile.height doubleValue] !=0 && [pwb_pile.measuredLength doubleValue] != 0 && [pwb_pile.measuredWidth doubleValue] != 0 && [pwb_pile.measuredHeight doubleValue] != 0 && [pwb_pile.measuredPileArea doubleValue] != 0 && [pwb_pile.measuredPileVolume doubleValue] != 0) && ([swb_pile.length doubleValue] != 0 && [swb_pile.width doubleValue] !=0 && [swb_pile.height doubleValue] !=0 && [swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                                                NSLog(@"case 2 in doc: where receiving file is not 0 and incoming file is 0");
                                            }else if([pwb_pile.length doubleValue] == [swb_pile.length doubleValue] && [pwb_pile.width doubleValue] == [swb_pile.width doubleValue] && [pwb_pile.height doubleValue] == [swb_pile.height doubleValue] && [pwb_pile.measuredLength doubleValue] == [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] == [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] == [swb_pile.measuredHeight doubleValue] && [pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode] && [pwb_pile.measuredPileArea doubleValue] == [swb_pile.measuredPileArea doubleValue] && [pwb_pile.measuredPileVolume doubleValue] == [swb_pile.measuredPileVolume doubleValue]){
                                                NSLog(@"case 4 in doc: where incoming file and receiving file data is exact same");
                                            }
                                            break;
                                        }
                                    }
                                }
                            }
                            if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                                //merge stratum ratio sampling log and plot selected
                                sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                            }
                        }
                        break;
                    }
                }
                if(!found_matching_st){
                    //if stratum not in the primary block, merge whole stratum into primary
                    //[secondary_wb removeBlockStratumObject:sst_swb];
                    [primary_wb addBlockStratumObject:sst_swb];
                }
                found_matching_st = NO;
            }
        }else if([primary_wb.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]){
            // comparing Stratum
            BOOL found_matching_st = NO;
            BOOL found_matching_pile = NO;
            NSSet* stra_set = [NSSet setWithSet:secondary_wb.blockStratum];
            for (WasteStratum *sst_swb in stra_set){
               
                for (WasteStratum *sst_pwb in primary_wb.blockStratum ){
                    if([sst_swb.stratum isEqualToString:sst_pwb.stratum]){
                        found_matching_st = YES;
                        //merge note field
                        if(!sst_pwb.notes){
                            sst_pwb.notes = @"";
                        }
                        if(sst_swb.notes){
                            sst_pwb.notes = [NSString stringWithFormat:@"%@, %@", sst_pwb.notes, sst_swb.notes];
                        }
                        
                        for (WastePile *swb_pile in sst_swb.stratumPile){
                            for(WastePile *pwb_pile in sst_pwb.stratumPile){
                                if(pwb_pile.cuttingPermit == swb_pile.cuttingPermit && pwb_pile.block == swb_pile.block && pwb_pile.licence == swb_pile.licence){
                                    found_matching_pile = YES;
                                    if([sst_swb.stratumBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                                       [self mergeSingleBlkPileStratum:sst_pwb.stratumPile swb_pileData:sst_swb.stratumPile];
                                       
                                       if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                                           //merge stratum ratio sampling log and plot selected
                                           sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                                       }
                                    }else{
                                       if([sst_swb.stratumPile count] == 0){
                                           // no piles
                                       }else {
                                           if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                               if(([pwb_pile.length doubleValue] == 0 && [pwb_pile.width doubleValue] ==0 && [pwb_pile.height doubleValue] ==0 && [pwb_pile.measuredLength doubleValue] == 0 && [pwb_pile.measuredWidth doubleValue] == 0 && [pwb_pile.measuredHeight doubleValue] == 0 && [pwb_pile.measuredPileArea doubleValue] == 0 && [pwb_pile.measuredPileVolume doubleValue] == 0) && ([swb_pile.length doubleValue] == 0 && [swb_pile.width doubleValue] ==0 && [swb_pile.height doubleValue] ==0 && [swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                                                   NSLog(@"case 1 in doc: where incoming file and receiving file is 0");
                                               }else if(([pwb_pile.length doubleValue] != 0 && [pwb_pile.width doubleValue] !=0 && [pwb_pile.height doubleValue] !=0 && [pwb_pile.measuredLength doubleValue] != 0 && [pwb_pile.measuredWidth doubleValue] != 0 && [pwb_pile.measuredHeight doubleValue] != 0 && [pwb_pile.measuredPileArea doubleValue] != 0 && [pwb_pile.measuredPileVolume doubleValue] != 0) && ([swb_pile.length doubleValue] != 0 && [swb_pile.width doubleValue] !=0 && [swb_pile.height doubleValue] !=0 && [swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                                                   NSLog(@"case 2 in doc: where receiving file is not 0 and incoming file is 0");
                                               }else if([pwb_pile.length doubleValue] == [swb_pile.length doubleValue] && [pwb_pile.width doubleValue] == [swb_pile.width doubleValue] && [pwb_pile.height doubleValue] == [swb_pile.height doubleValue] && [pwb_pile.measuredLength doubleValue] == [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] == [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] == [swb_pile.measuredHeight doubleValue] && [pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode] && [pwb_pile.measuredPileArea doubleValue] == [swb_pile.measuredPileArea doubleValue] && [pwb_pile.measuredPileVolume doubleValue] == [swb_pile.measuredPileVolume doubleValue]){
                                                   NSLog(@"case 4 in doc: where incoming file and receiving file data is exact same");
                                               }
                                               break;
                                           }
                                       }
                                        if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                                            //merge stratum ratio sampling log and plot selected
                                            sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                                        }
                                    }
                                    break;
                                }
                            }
                            if(!found_matching_pile){
                                [sst_pwb addStratumPileObject:swb_pile];
                            }
                            found_matching_pile = NO;
                        }
                        break;
                    }
                }
                if(!found_matching_st){
                    //if stratum not in the primary block, merge whole stratum into primary
                    //[secondary_wb removeBlockStratumObject:sst_swb];
                    [primary_wb addBlockStratumObject:sst_swb];
                }
                found_matching_st = NO;
            }
        }
        
        return MergeSuccessful;
    }else{
        return MergeFailCutBlockNotFound;
    }
}

+(void)mergeSingleBlkPileStratum:(NSSet*)pwb_pileData swb_pileData:(NSSet*)swb_pileData{
    NSSet* pile_set = [NSSet setWithSet:swb_pileData];
    for(WastePile *swb_pile in pile_set){
        for(WastePile *pwb_pile in pwb_pileData){
            if(pwb_pile.pileNumber == swb_pile.pileNumber){
                if(([pwb_pile.measuredLength doubleValue] == 0 && [pwb_pile.measuredWidth doubleValue] == 0 && [pwb_pile.measuredHeight doubleValue] == 0 && [pwb_pile.measuredPileArea doubleValue] == 0 && [pwb_pile.measuredPileVolume doubleValue] == 0) && ([swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                    NSLog(@"case 1 in doc: where incoming file and receiving file is 0");
                }else if(([pwb_pile.measuredLength doubleValue] != 0 && [pwb_pile.measuredWidth doubleValue] != 0 && [pwb_pile.measuredHeight doubleValue] != 0 && [pwb_pile.measuredPileArea doubleValue] != 0 && [pwb_pile.measuredPileVolume doubleValue] != 0) && ([swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                    NSLog(@"case 2 in doc: where receiving file is not 0 and incoming file is 0");
                }else if(([swb_pile.measuredLength doubleValue] != 0 && [swb_pile.measuredWidth doubleValue] != 0 && [swb_pile.measuredHeight doubleValue] != 0 && [swb_pile.measuredPileArea doubleValue] != 0 && [swb_pile.measuredPileVolume doubleValue] != 0) && ([pwb_pile.measuredLength doubleValue] == 0 && [pwb_pile.measuredWidth doubleValue] == 0 && [pwb_pile.measuredHeight doubleValue] == 0 && [pwb_pile.measuredPileArea doubleValue] == 0 && [pwb_pile.measuredPileVolume doubleValue] == 0)){
                    NSLog(@"Case 3 in doc: where incoming file contain data receiving file is 0");
                    pwb_pile.measuredLength = [[NSDecimalNumber alloc] initWithDouble:[swb_pile.measuredLength doubleValue]];
                    pwb_pile.measuredWidth = [[NSDecimalNumber alloc] initWithDouble:[swb_pile.measuredWidth doubleValue]];
                    pwb_pile.measuredHeight = [[NSDecimalNumber alloc] initWithDouble:[swb_pile.measuredHeight doubleValue]];
                    if(swb_pile.pilePileShapeCode ){
                        pwb_pile.pilePileShapeCode = swb_pile.pilePileShapeCode;
                    }
                    pwb_pile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:[swb_pile.measuredPileArea doubleValue]];
                    pwb_pile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:[swb_pile.measuredPileVolume doubleValue]];
                    if(swb_pile.comment){
                        pwb_pile.comment = swb_pile.comment;
                    }
                }else if([pwb_pile.measuredLength doubleValue] == [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] == [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] == [swb_pile.measuredHeight doubleValue] && [pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode] && [pwb_pile.measuredPileArea doubleValue] == [swb_pile.measuredPileArea doubleValue] && [pwb_pile.measuredPileVolume doubleValue] == [swb_pile.measuredPileVolume doubleValue]){
                    NSLog(@"case 4 in doc: where incoming file and receiving file data is exact same");
                }
                break;
            }
        }
    }
}

+(MergeOutcomeCode) mergeWasteBlockData:(WasteBlock*)primary_wb WasteBlock:(WasteBlock*)secondary_wb{
    if (primary_wb &&  secondary_wb) {
        //comparing Cut Block Fields
        if(primary_wb.location && secondary_wb.location && ([[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.location = [NSString stringWithString:[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.location && ![[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.location = [NSString stringWithString:[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.location && [[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.location = [NSString stringWithString:[primary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.yearLoggedTo && secondary_wb.yearLoggedTo && [primary_wb.yearLoggedTo integerValue] == [secondary_wb.yearLoggedTo integerValue]){
            primary_wb.yearLoggedTo =  [NSNumber numberWithInteger:[primary_wb.yearLoggedTo integerValue]];
        }
        
        if(primary_wb.yearLoggedFrom && secondary_wb.yearLoggedFrom && [primary_wb.yearLoggedFrom integerValue] == [secondary_wb.yearLoggedFrom integerValue]){
            primary_wb.yearLoggedFrom =  [NSNumber numberWithInteger:[primary_wb.yearLoggedFrom integerValue]];
        }
        
        if(primary_wb.loggingCompleteDate && secondary_wb.loggingCompleteDate && [primary_wb.loggingCompleteDate isEqualToDate:secondary_wb.loggingCompleteDate]){
            primary_wb.loggingCompleteDate =  [[NSDate alloc] initWithTimeInterval:0 sinceDate:primary_wb.loggingCompleteDate] ;
        }
        
        if(primary_wb.surveyDate && secondary_wb.surveyDate && [primary_wb.surveyDate isEqualToDate:secondary_wb.surveyDate]){
            primary_wb.surveyDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:primary_wb.surveyDate];
        }
        
        if(primary_wb.netArea && secondary_wb.netArea && [primary_wb.netArea floatValue] == [secondary_wb.netArea floatValue]){
            primary_wb.netArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.netArea floatValue]];
        }
        
        if(primary_wb.surveyArea && secondary_wb.surveyArea && [primary_wb.surveyArea floatValue] == [secondary_wb.surveyArea floatValue]){
            primary_wb.surveyArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.surveyArea floatValue]];
        }
        
        if(primary_wb.npNFArea && secondary_wb.npNFArea && [primary_wb.npNFArea floatValue] == [secondary_wb.npNFArea floatValue]){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.npNFArea floatValue]];
        }
        if((isnan([primary_wb.npNFArea floatValue])) && (!(isnan([secondary_wb.npNFArea floatValue])))){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [secondary_wb.npNFArea floatValue]];
        }
        if((!(isnan([primary_wb.npNFArea floatValue]))) && (isnan([secondary_wb.npNFArea floatValue]))){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [primary_wb.npNFArea floatValue]];
        }
        
        if(secondary_wb.blockMaturityCode ){
            primary_wb.blockMaturityCode = secondary_wb.blockMaturityCode;
        }
        
        if(secondary_wb.blockSiteCode ){
            primary_wb.blockSiteCode = secondary_wb.blockSiteCode;
        }
        
        if(primary_wb.returnNumber && secondary_wb.returnNumber && [primary_wb.returnNumber integerValue] == [secondary_wb.returnNumber integerValue]){
            primary_wb.returnNumber =  [NSNumber numberWithInteger:[primary_wb.returnNumber integerValue]];
        }
        if([primary_wb.returnNumber integerValue] == 0 && [secondary_wb.returnNumber integerValue] != 0){
            primary_wb.returnNumber =  [NSNumber numberWithInteger:[secondary_wb.returnNumber integerValue]];
        }
        if([secondary_wb.returnNumber integerValue] == 0 && [primary_wb.returnNumber integerValue] != 0){
            primary_wb.returnNumber = [NSNumber numberWithInteger:[primary_wb.returnNumber integerValue]];
        }

        if(primary_wb.surveyorLicence && secondary_wb.surveyorLicence && ([[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.surveyorLicence = [NSString stringWithString:[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.surveyorLicence && ![[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorLicence = [NSString stringWithString:[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.surveyorLicence && [[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorLicence = [NSString stringWithString:[primary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.surveyorName && secondary_wb.surveyorName && ([[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] )){
            primary_wb.surveyorName = [NSString stringWithString:[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.surveyorName && ![[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorName = [NSString stringWithString:[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.surveyorName && [[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorName = [NSString stringWithString:[primary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.professional && secondary_wb.professional && ([[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.professional = [NSString stringWithString:[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.professional && ![[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.professional = [NSString stringWithString:[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.professional && [[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.professional = [NSString stringWithString:[primary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.registrationNumber && secondary_wb.registrationNumber && ([[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] )){
            primary_wb.registrationNumber = [NSString stringWithString:[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.registrationNumber && ![[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.registrationNumber = [NSString stringWithString:[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.registrationNumber && [[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.registrationNumber = [NSString stringWithString:[primary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        if(primary_wb.position && secondary_wb.position && ([[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])){
            primary_wb.position = [NSString stringWithString:[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(secondary_wb.position && ![[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && [[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.position = [NSString stringWithString:[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        if(primary_wb.position && [[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.position = [NSString stringWithString:[primary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
        
        //append the note field after another
        if(!primary_wb.notes){
            primary_wb.notes = @"";
        }
        if(secondary_wb.notes){
            if([primary_wb.notes isEqualToString:@""] || primary_wb.notes == nil)
            {
                primary_wb.notes = secondary_wb.notes;
            }
            else
            {
                primary_wb.notes = [NSString stringWithFormat:@"%@, %@", primary_wb.notes, secondary_wb.notes];
            }
        }
        
        //comparing Timber Mark
        Timbermark *ptm = nil;
        Timbermark *stm = nil;
        //NSLog(@"pwb-timbermark: %@", [[primary_wb.blockTimbermark allObjects] objectAtIndex:0].timbermark);
        for (Timbermark *tm in primary_wb.blockTimbermark ){

            if(tm && tm.primaryInd){
                if([tm.primaryInd integerValue] == 1){
                    ptm = tm;
                }else{
                    stm = tm;
                }
            }
        }
        //NSLog(@"swb-timbermark: %@", [[secondary_wb.blockTimbermark allObjects] objectAtIndex:0].timbermark);
        for (Timbermark *tm_swb in secondary_wb.blockTimbermark){
            if(tm_swb && tm_swb.primaryInd){
                if([tm_swb.primaryInd integerValue] == 1){
                Timbermark *ttm = ptm ;
                
                    if(tm_swb.timbermark && [[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
                        ttm.timbermark = [NSString stringWithString:[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    }
                    /*if(tm_swb.coniferWMRF && [tm_swb.coniferWMRF floatValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                    }*/
                    if(ttm.coniferWMRF && tm_swb.coniferWMRF && [ttm.coniferWMRF floatValue] == [tm_swb.coniferWMRF floatValue]){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    if([ttm.coniferWMRF floatValue] == 0 && [tm_swb.coniferWMRF floatValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                    }
                    if([tm_swb.coniferWMRF floatValue] == 0 && [ttm.coniferWMRF integerValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    /*if(tm_swb.deciduousPrice && [tm_swb.deciduousPrice floatValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                    }*/
                    if(ttm.deciduousPrice && tm_swb.deciduousPrice && [ttm.deciduousPrice floatValue] == [tm_swb.deciduousPrice floatValue]){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if([ttm.deciduousPrice floatValue] == 0 && [tm_swb.deciduousPrice floatValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                    }
                    if([tm_swb.deciduousPrice floatValue] == 0 && [ttm.deciduousPrice integerValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if(tm_swb.area && [tm_swb.area floatValue] != 0){
                        ttm.area = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.area floatValue]];
                    }
                    [primary_wb addBlockTimbermarkObject:ttm];
                }
                if([tm_swb.primaryInd integerValue] == 2){
                    Timbermark *ttm = nil;
                    if(stm == nil) {
                        ttm = tm_swb ;
                    }else{
                        ttm = stm ;
                    }
                    if(tm_swb.timbermark && [[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
                        ttm.timbermark = [NSString stringWithString:[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    }
                    if(ttm.coniferWMRF && tm_swb.coniferWMRF && [ttm.coniferWMRF floatValue] == [tm_swb.coniferWMRF floatValue]){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    if([ttm.coniferWMRF floatValue] == 0 && [tm_swb.coniferWMRF floatValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                    }
                    if([tm_swb.coniferWMRF floatValue] == 0 && [ttm.coniferWMRF integerValue] != 0){
                        ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[ttm.coniferWMRF floatValue]];
                    }
                    if(ttm.deciduousPrice && tm_swb.deciduousPrice && [ttm.deciduousPrice floatValue] == [tm_swb.deciduousPrice floatValue]){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if([ttm.deciduousPrice floatValue] == 0 && [tm_swb.deciduousPrice floatValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                    }
                    if([tm_swb.deciduousPrice floatValue] == 0 && [ttm.deciduousPrice integerValue] != 0){
                        ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[ttm.deciduousPrice floatValue]];
                    }
                    if(tm_swb.area && [tm_swb.area floatValue] != 0){
                        ttm.area = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.area floatValue]];
                    }
                    [primary_wb addBlockTimbermarkObject:ttm];
                }
            }
        }
        
        // comparing Stratum
        BOOL found_matching_st = NO;
        NSSet* stra_set = [NSSet setWithSet:secondary_wb.blockStratum];
        for (WasteStratum *sst_swb in stra_set){
           
            for (WasteStratum *sst_pwb in primary_wb.blockStratum ){
                if([sst_swb.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:FALSE]intValue]){
                    if([sst_swb.stratum isEqualToString:sst_pwb.stratum]){
                        found_matching_st = YES;
                        //merge note field
                        if(!sst_pwb.notes){ sst_pwb.notes = @""; }
                        if(sst_swb.notes){
                            sst_pwb.notes = [NSString stringWithFormat:@"%@, %@", sst_pwb.notes, sst_swb.notes];
                        }
                        
                        //move the plots from secondary to primary
                        NSSet* plot_set = [NSSet setWithSet:sst_swb.stratumPlot];
                        if([sst_swb.stratumBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE]intValue]){
                            for(WastePlot *plot1 in plot_set){
                                for(WastePlot *plot2 in sst_pwb.stratumPlot){
                                    if([plot1.plotNumber intValue] == [plot2.plotNumber intValue]){
                                        
                                    }else{
                                        for(WastePlot *plot in plot_set){
                                            //[sst_swb removeStratumPlotObject:plot];
                                            [sst_pwb addStratumPlotObject:plot];
                                        }
                                    }
                                }
                            }
                        }
                        if([sst_swb.stratumBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE]intValue]){
                            for(WastePlot *plot in plot_set){
                                //[sst_swb removeStratumPlotObject:plot];
                                [sst_pwb addStratumPlotObject:plot];
                            }
                        }
                        if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                            //merge stratum ratio sampling log and plot selected
                            sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                        }
                        break;
                    }
                }else{
                    BOOL found_matching_pile = NO;
                    if([primary_wb.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                        if([sst_swb.stratum isEqualToString:sst_pwb.stratum]){
                            found_matching_st = YES;
                            //merge note field
                            if(!sst_pwb.notes){
                                sst_pwb.notes = @"";
                            }
                            if(sst_swb.notes){
                                sst_pwb.notes = [NSString stringWithFormat:@"%@, %@", sst_pwb.notes, sst_swb.notes];
                            }
                            //move the pile from secondary to primary. Assuming stratumpile data will be made in master before sharing.So during merge there is no confict in pile number generated.
                            if([sst_swb.stratumBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                                [self mergeSingleBlkPileStratum:sst_pwb.stratumPile swb_pileData:sst_swb.stratumPile];
                                
                                if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                                    //merge stratum ratio sampling log and plot selected
                                    sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                                }
                            }else{
                                if([sst_swb.stratumPile count] == 0){
                                    
                                }else{
                                    NSSet* pile_set = [NSSet setWithSet:sst_swb.stratumPile];
                                    for(WastePile *swb_pile in pile_set){
                                        for(WastePile *pwb_pile in sst_pwb.stratumPile){
                                            if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                                if(([pwb_pile.length doubleValue] == 0 && [pwb_pile.width doubleValue] ==0 && [pwb_pile.height doubleValue] ==0 && [pwb_pile.measuredLength doubleValue] == 0 && [pwb_pile.measuredWidth doubleValue] == 0 && [pwb_pile.measuredHeight doubleValue] == 0 && [pwb_pile.measuredPileArea doubleValue] == 0 && [pwb_pile.measuredPileVolume doubleValue] == 0) && ([swb_pile.length doubleValue] == 0 && [swb_pile.width doubleValue] ==0 && [swb_pile.height doubleValue] ==0 && [swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                                                    NSLog(@"case 1 in doc: where incoming file and receiving file is 0");
                                                }else if(([pwb_pile.length doubleValue] != 0 && [pwb_pile.width doubleValue] !=0 && [pwb_pile.height doubleValue] !=0 && [pwb_pile.measuredLength doubleValue] != 0 && [pwb_pile.measuredWidth doubleValue] != 0 && [pwb_pile.measuredHeight doubleValue] != 0 && [pwb_pile.measuredPileArea doubleValue] != 0 && [pwb_pile.measuredPileVolume doubleValue] != 0) && ([swb_pile.length doubleValue] != 0 && [swb_pile.width doubleValue] !=0 && [swb_pile.height doubleValue] !=0 && [swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                                                    NSLog(@"case 2 in doc: where receiving file is not 0 and incoming file is 0");
                                                }else if([pwb_pile.length doubleValue] == [swb_pile.length doubleValue] && [pwb_pile.width doubleValue] == [swb_pile.width doubleValue] && [pwb_pile.height doubleValue] == [swb_pile.height doubleValue] && [pwb_pile.measuredLength doubleValue] == [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] == [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] == [swb_pile.measuredHeight doubleValue] && [pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode] && [pwb_pile.measuredPileArea doubleValue] == [swb_pile.measuredPileArea doubleValue] && [pwb_pile.measuredPileVolume doubleValue] == [swb_pile.measuredPileVolume doubleValue]){
                                                    NSLog(@"case 4 in doc: where incoming file and receiving file data is exact same");
                                                }
                                                break;
                                            }
                                        }
                                    }
                                }
                                if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                                    //merge stratum ratio sampling log and plot selected
                                    sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                                }
                            }
                            break;
                        }
                    }else if([primary_wb.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]){
                        if([sst_swb.stratum isEqualToString:sst_pwb.stratum]){
                           found_matching_st = YES;
                           //merge note field
                           if(!sst_pwb.notes){
                               sst_pwb.notes = @"";
                           }
                           if(sst_swb.notes){
                               sst_pwb.notes = [NSString stringWithFormat:@"%@, %@", sst_pwb.notes, sst_swb.notes];
                           }
                           
                            for (WastePile *swb_pile in sst_swb.stratumPile){
                               for(WastePile *pwb_pile in sst_pwb.stratumPile){
                                   if(pwb_pile.cuttingPermit == swb_pile.cuttingPermit && pwb_pile.block == swb_pile.block && pwb_pile.licence == swb_pile.licence){
                                       found_matching_pile = YES;
                                       if([sst_swb.stratumBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                                          [self mergeSingleBlkPileStratum:sst_pwb.stratumPile swb_pileData:sst_swb.stratumPile];
                                          
                                          if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                                              //merge stratum ratio sampling log and plot selected
                                              sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                                          }
                                       }else{
                                          if([sst_swb.stratumPile count] == 0){
                                              // no piles
                                          } else {
                                               if(pwb_pile.pileNumber == swb_pile.pileNumber){
                                                   if(([pwb_pile.length doubleValue] == 0 && [pwb_pile.width doubleValue] ==0 && [pwb_pile.height doubleValue] ==0 && [pwb_pile.measuredLength doubleValue] == 0 && [pwb_pile.measuredWidth doubleValue] == 0 && [pwb_pile.measuredHeight doubleValue] == 0 && [pwb_pile.measuredPileArea doubleValue] == 0 && [pwb_pile.measuredPileVolume doubleValue] == 0) && ([swb_pile.length doubleValue] == 0 && [swb_pile.width doubleValue] ==0 && [swb_pile.height doubleValue] ==0 && [swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                                                       NSLog(@"case 1 in doc: where incoming file and receiving file is 0");
                                                   }else if(([pwb_pile.length doubleValue] != 0 && [pwb_pile.width doubleValue] !=0 && [pwb_pile.height doubleValue] !=0 && [pwb_pile.measuredLength doubleValue] != 0 && [pwb_pile.measuredWidth doubleValue] != 0 && [pwb_pile.measuredHeight doubleValue] != 0 && [pwb_pile.measuredPileArea doubleValue] != 0 && [pwb_pile.measuredPileVolume doubleValue] != 0) && ([swb_pile.length doubleValue] != 0 && [swb_pile.width doubleValue] !=0 && [swb_pile.height doubleValue] !=0 && [swb_pile.measuredLength doubleValue] == 0 && [swb_pile.measuredWidth doubleValue] == 0 && [swb_pile.measuredHeight doubleValue] == 0 && [swb_pile.measuredPileArea doubleValue] == 0 && [swb_pile.measuredPileVolume doubleValue] == 0)){
                                                       NSLog(@"case 2 in doc: where receiving file is not 0 and incoming file is 0");
                                                   }else if([pwb_pile.length doubleValue] == [swb_pile.length doubleValue] && [pwb_pile.width doubleValue] == [swb_pile.width doubleValue] && [pwb_pile.height doubleValue] == [swb_pile.height doubleValue] && [pwb_pile.measuredLength doubleValue] == [swb_pile.measuredLength doubleValue] && [pwb_pile.measuredWidth doubleValue] == [swb_pile.measuredWidth doubleValue] && [pwb_pile.measuredHeight doubleValue] == [swb_pile.measuredHeight doubleValue] && [pwb_pile.pilePileShapeCode.pileShapeCode isEqual:swb_pile.pilePileShapeCode.pileShapeCode] && [pwb_pile.measuredPileArea doubleValue] == [swb_pile.measuredPileArea doubleValue] && [pwb_pile.measuredPileVolume doubleValue] == [swb_pile.measuredPileVolume doubleValue]){
                                                       NSLog(@"case 4 in doc: where incoming file and receiving file data is exact same");
                                                   }
                                                   break;
                                               }
                                          }
                                           if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                                               //merge stratum ratio sampling log and plot selected
                                               sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                                           }
                                       }
                                       break;
                                   }
                               }
                               if(!found_matching_pile){
                                   [sst_pwb addStratumPileObject:swb_pile];
                               }
                               found_matching_pile = NO;
                           }
                           break;
                       }
                    }
                }
            }
            if(!found_matching_st){
                //if stratum not in the primary block, merge whole stratum into primary
                [primary_wb addBlockStratumObject:sst_swb];
            }
            found_matching_st = NO;
        }
        return MergeSuccessful;
    }else{
        return MergeFailCutBlockNotFound;
    }
}
@end
