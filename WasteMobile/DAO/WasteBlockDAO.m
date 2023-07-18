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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @" cutBlockId = %@ AND reportingUnitId = %@ ", cutBlockId, reportUnitId];
    
    [request setPredicate:predicate];
    
   // NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result.count > 0) {
        return result[0];
    }else{
        return nil;
    }
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
    //Don't save before getting a cut block, Save should be done in different place before this method call
    //[context save:&error];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @" reportingUnit = %@ AND cutBlockId = %@ AND licenceNumber = %@ AND cuttingPermitId = %@ ", ru, cutBlockId, license, cutPermit];
    
    [request setPredicate:predicate];
    
    // NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    //NSLog(@"Find Cut Block - result.count = %lu", (unsigned long)result.count);
    WasteBlock *wb = nil;
    if (result.count > 0) {
        wb = result[0];
    }
    return wb;
}

+(WasteBlock *) getWasteBlockByRUButWAID:(NSString *) ru cutBlockId:(NSString *)cutBlockId license:(NSString*)license cutPermit:(NSString*)cutPermit wasteAsseID:(NSString *)wasteAsseID{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error = nil;
    //Don't save before getting a cut block, Save should be done in different place before this method call
    //[context save:&error];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    ru = [ru stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cutBlockId = cutBlockId ? [cutBlockId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    license = license ? [license stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    cutPermit = cutPermit ? [cutPermit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @" reportingUnit = %@ AND cutBlockId = %@ AND licenceNumber = %@ AND cuttingPermitId = %@ AND wasteAssessmentAreaID != %@ ", ru, cutBlockId, license, cutPermit, wasteAsseID];
    
    [request setPredicate:predicate];
    
    NSArray *result = [context executeFetchRequest:request error:&error];

    if (error){
        NSLog(@"getWasteBlockByRUButWAID Error: %@", error);
    }
        
    WasteBlock *wb = nil;
    if (result.count > 0) {
        wb = result[0];
    }
    return wb;
}

+(WasteBlock *) createEmptyCutBlock:(int) regionId ratioSample:(BOOL)ratioSample{
    
    NSManagedObjectContext *context = [self managedObjectContext];

    // create a new waste cut block
    WasteBlock *wasteBlock = [NSEntityDescription insertNewObjectForEntityForName:@"WasteBlock" inManagedObjectContext:context];
    
    // get the max waste block id in core data
    wasteBlock.wasteAssessmentAreaID = [self GetNextAssessmentAreaId];

    //set the entry date
    wasteBlock.entryDate = [NSDate date];
    wasteBlock.regionId = [[NSNumber alloc] initWithInt:regionId];
    wasteBlock.ratioSamplingEnabled = [NSNumber numberWithBool:ratioSample];
    if([wasteBlock.regionId integerValue] == CoastRegion){
        wasteBlock.blockCoastStat = [self createEFWCoastStat];
    }else if([wasteBlock.regionId integerValue] == InteriorRegion){
        wasteBlock.blockInteriorStat = [self createEFWInteriorStat];
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
    
    // Step 1 - Remove the piece and plot object
    NSMutableSet *tempPlot = [NSMutableSet setWithSet:targetWasteStratum.stratumPlot];
    for (WastePlot *wpl in targetWasteStratum.stratumPlot) {
        
        // Remove each plot piece - cast to superclass NSManagedObject so it can be removed
        for(NSManagedObject *wpi in wpl.plotPiece){
            [context deleteObject:wpi];
        }
        [tempPlot removeObject:wpl];
        [context deleteObject:wpl];
    }
    targetWasteStratum.stratumPlot = tempPlot;
    
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
        if(secondary_wb.location && ![[secondary_wb.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.location = [NSString stringWithString:secondary_wb.location];
        }
        if(secondary_wb.yearLoggedTo && [secondary_wb.yearLoggedTo integerValue] != 0){
            primary_wb.yearLoggedTo = [NSNumber numberWithInteger:[secondary_wb.yearLoggedTo integerValue]];
        }
        if(secondary_wb.yearLoggedFrom && [secondary_wb.yearLoggedFrom integerValue] != 0){
            primary_wb.yearLoggedFrom = [NSNumber numberWithInteger:[secondary_wb.yearLoggedFrom integerValue]];
        }
        if(secondary_wb.loggingCompleteDate){
            primary_wb.loggingCompleteDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:secondary_wb.loggingCompleteDate] ;
        }
        if(secondary_wb.surveyDate){
            primary_wb.surveyDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:secondary_wb.surveyDate];
        }
        if(secondary_wb.netArea && [secondary_wb.netArea floatValue] != 0){
            primary_wb.netArea = [[NSDecimalNumber alloc] initWithFloat: [secondary_wb.netArea floatValue]];
        }
        if(secondary_wb.npNFArea && [secondary_wb.npNFArea floatValue] != 0){
            primary_wb.npNFArea = [[NSDecimalNumber alloc] initWithFloat: [secondary_wb.npNFArea floatValue]];
        }
        if(secondary_wb.blockMaturityCode ){
            primary_wb.blockMaturityCode = secondary_wb.blockMaturityCode;
        }
        if(secondary_wb.blockSiteCode ){
            primary_wb.blockSiteCode = secondary_wb.blockSiteCode;
        }
        if(secondary_wb.returnNumber && [secondary_wb.returnNumber integerValue] != 0){
            primary_wb.returnNumber = [NSNumber numberWithInteger:[secondary_wb.returnNumber integerValue]];
        }

        if(secondary_wb.surveyorLicence && ![[secondary_wb.surveyorLicence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorLicence = [NSString stringWithString:secondary_wb.surveyorLicence];
        }
        if(secondary_wb.surveyorName && ![[secondary_wb.surveyorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.surveyorName = [NSString stringWithString:secondary_wb.surveyorName];
        }
        if(secondary_wb.professional && ![[secondary_wb.professional stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.professional = [NSString stringWithString:secondary_wb.professional];
        }
        if(secondary_wb.registrationNumber && ![[secondary_wb.registrationNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.registrationNumber = [NSString stringWithString:secondary_wb.registrationNumber];
        }
        if(secondary_wb.position && ![[secondary_wb.position stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
            primary_wb.position = [NSString stringWithString:secondary_wb.position];
        }
        //append the note field after another
        if(!primary_wb.notes){
            primary_wb.notes = @"";
        }
        if(secondary_wb.notes){
            primary_wb.notes = [NSString stringWithFormat:@"%@, %@", primary_wb.notes, secondary_wb.notes];
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
                Timbermark *ttm = [tm_swb.primaryInd integerValue] == 1 ? ptm : stm;

                if(tm_swb.timbermark && [[tm_swb.timbermark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
                    ttm.timbermark = [NSString stringWithString:tm_swb.timbermark];
                }
                if(tm_swb.coniferWMRF && [tm_swb.coniferWMRF floatValue] != 0){
                    ttm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.coniferWMRF floatValue]];
                }
                if(tm_swb.deciduousPrice && [tm_swb.deciduousPrice floatValue] != 0){
                    ttm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.deciduousPrice floatValue]];
                }
                if(tm_swb.area && [tm_swb.area floatValue] != 0){
                    ttm.area = [[NSDecimalNumber alloc] initWithFloat:[tm_swb.area floatValue]];
                }
            }
        }
        
        // comparing Stratum
        BOOL found_matching_st = NO;
        NSSet* stra_set = [NSSet setWithSet:secondary_wb.blockStratum];
        for (WasteStratum *sst_swb in stra_set){
           
            for (WasteStratum *sst_pwb in primary_wb.blockStratum ){
                if([sst_swb.stratum isEqualToString:sst_pwb.stratum]){
                    found_matching_st = YES;
                    //merge note field
                    if(!sst_pwb.notes){ sst_pwb.notes = @""; }
                    if(sst_swb.notes){
                        sst_pwb.notes = [NSString stringWithFormat:@"%@, %@", sst_pwb.notes, sst_swb.notes];
                    }
                    
                    //move the plots from secondary to primary
                    NSSet* plot_set = [NSSet setWithSet:sst_swb.stratumPlot];
                    for(WastePlot *plot in plot_set){
                        //[sst_swb removeStratumPlotObject:plot];
                        [sst_pwb addStratumPlotObject:plot];
                    }
                    if(primary_wb.ratioSamplingEnabled && [primary_wb.ratioSamplingEnabled intValue] == 1){
                        //merge stratum ratio sampling log and plot selected
                        sst_pwb.ratioSamplingLog = [sst_pwb.ratioSamplingLog stringByAppendingString:sst_swb.ratioSamplingLog];
                        /* don't want to merge the sampling list and don't refresh the isMearsurePlot flag.
                        sst_pwb.n1sample = [self mergeSamples:sst_pwb.n1sample secondary_n1:sst_swb.n1sample];
                        sst_pwb.n2sample = [sst_pwb.n2sample stringByAppendingString:sst_swb.n2sample];
                        
                        //refresh isMeasurePlot
                        NSArray* pn_ary = [sst_pwb.n1sample componentsSeparatedByString:@","];
                        for(WastePlot* wp in sst_pwb.stratumPlot){
                            BOOL isMeasurePlot = NO;
                            for(NSString* pn in pn_ary){
                                if([pn isEqualToString:[wp.plotNumber stringValue]]){
                                    isMeasurePlot = YES;
                                    break;
                                }
                            }
                            wp.isMeasurePlot = isMeasurePlot? [[NSNumber alloc]  initWithInt:1] : [[NSNumber alloc]  initWithInt:0];
                        }
                         */
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
    WasteBlock *found = [WasteBlockDAO getWasteBlockByRU:ru cutBlockId:cutBlockId license:license cutPermit:cutPermit];
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

@end
