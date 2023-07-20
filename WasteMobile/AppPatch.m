//
//  AppPatch.m
//  WasteMobile
//
//  Created by Jack Wong on 2018-01-31.
//  Copyright © 2018 Salus Systems. All rights reserved.
//

#import "AppPatch.h"
#import "CodeDAO.h"
#import "WastePiece.h"
#import "BorderlineCode.h"
#import "TopEndCode.h"
#import "ButtEndCode.h"
#import "MaterialKindCode.h"
#import "WasteLevelCode.h"
#import "PlotSizeCode.h"
#import "HarvestMethodCode.h"
#import "WasteTypeCode.h"

@implementation AppPatch

+(AppPatch *)sharedInstance{
    static AppPatch *singletonOjb = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        singletonOjb = [[super alloc] init];
    });
    
    return singletonOjb;
}

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

/*
  patch for v1.2.0
  1) change butt end code P for existing piece to nothing
  2) remove butt end code P in code table
  3) change top end code P for existing piece to nothing
  4) remove top end code P in code table
  5) change borderline code X for existing piece to nothing
  6) remove borderline code X in code table
  7) change the effective date of material kind code, waste type code, harvest method code, plot size code and waste level code for ordering
 */
-(void) patch120{
    
    BOOL patchApplied = YES;
    for(ButtEndCode *bc in [[CodeDAO sharedInstance] getButtEndCodeList]){
        if([bc.buttEndCode isEqualToString:@"P"]){
            patchApplied = NO;
            NSMutableArray *targetPieces = [[NSMutableArray alloc] init];
            for(WastePiece *wp in bc.buttEndCodePiece){
                [targetPieces addObject:wp];
            }
            for(WastePiece *wp in targetPieces){
                wp.pieceButtEndCode = (ButtEndCode*)[[CodeDAO sharedInstance] getCodeByNameCode:@"ButtEndCode" code:@" "];
            }
            NSError *error;
            [[self managedObjectContext] save:&error];
            if (error) {
                NSLog(@"patch 120 : Error when saving deletion of TopEndCode: %@", error);
            }
            [[self managedObjectContext] deleteObject:bc];
            break;
        }
    }
    
    if(!patchApplied){
        for(TopEndCode *tc in [[CodeDAO sharedInstance] getTopEndCodeList]){
            if([tc.topEndCode isEqualToString:@"P"]){
                NSMutableArray *targetPieces = [[NSMutableArray alloc] init];
                for(WastePiece *wp in tc.topEndCodePiece){
                    [targetPieces addObject:wp];
                }
                for(WastePiece *wp in targetPieces){
                    wp.pieceTopEndCode = (TopEndCode*)[[CodeDAO sharedInstance] getCodeByNameCode:@"TopEndCode" code:@" "];
                }
                NSError *error;
                [[self managedObjectContext] save:&error];
                if (error) {
                    NSLog(@"patch 120 : Error when saving deletion of TopEndCode: %@", error);
                }
                [[self managedObjectContext] deleteObject:tc];
                break;
            }
        }
        
        for(BorderlineCode *bc in [[CodeDAO sharedInstance] getBorderLineCodeList]){
            if([bc.borderlineCode isEqualToString:@"X"]){
                NSMutableArray *targetPieces = [[NSMutableArray alloc] init];
                for(WastePiece *wp in bc.borderlineCodePiece){
                    [targetPieces addObject:wp];
                }
                for(WastePiece *wp in targetPieces){
                    wp.pieceBorderlineCode = (BorderlineCode*)[[CodeDAO sharedInstance] getCodeByNameCode:@"BorderlineCode" code:@" "];
                }
                NSError *error;
                [[self managedObjectContext] save:&error];
                if (error) {
                    NSLog(@"patch 120 : Error when saving deletion of BorderlineCode: %@", error);
                }
                [[self managedObjectContext] deleteObject:bc];
            }
        }
        //order material kind code
        for(MaterialKindCode *code in [[CodeDAO sharedInstance] getMaterialKindCodeList]){
            
            NSDateComponents* comps = [[NSDateComponents alloc]init];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            if([code.materialKindCode isEqualToString:@"L"]){
                comps.day = 1;
            }else if([code.materialKindCode isEqualToString:@"W"]){
                comps.day = 2;
            }else if([code.materialKindCode isEqualToString:@"S"]){
                comps.day = 3;
            }else if([code.materialKindCode isEqualToString:@"T"]){
                comps.day = 4;
            }else if([code.materialKindCode isEqualToString:@"X"]){
                comps.day = 5;
            }else if([code.materialKindCode isEqualToString:@"B"]){
                comps.day = 6;
            }else if([code.materialKindCode isEqualToString:@"D"]){
                comps.day = 7;
            }else if([code.materialKindCode isEqualToString:@"U"]){
                comps.day = 8;
            }
            code.effectiveDate  = [calendar dateByAddingComponents:comps toDate:code.effectiveDate options:0];
        }
        //order waste level code
        for(WasteLevelCode *code in [[CodeDAO sharedInstance] getWasteLevelCodeList]){
            
            NSDateComponents* comps = [[NSDateComponents alloc]init];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            if([code.wasteLevelCode isEqualToString:@"X"]){
                comps.day = 1;
            }else if([code.wasteLevelCode isEqualToString:@"H"]){
                comps.day = 2;
            }else if([code.wasteLevelCode isEqualToString:@"L"]){
                comps.day = 3;
            }else if([code.wasteLevelCode isEqualToString:@"M"]){
                comps.day = 4;
            }
            code.effectiveDate  = [calendar dateByAddingComponents:comps toDate:code.effectiveDate options:0];
        }
        //order plot size code
        for(PlotSizeCode *code in [[CodeDAO sharedInstance] getPlotSizeCodeList]){
            
            NSDateComponents* comps = [[NSDateComponents alloc]init];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            if([code.plotSizeCode isEqualToString:@"2"]){
                comps.day = 1;
            }else if([code.plotSizeCode isEqualToString:@"0"]){
                comps.day = 2;
            }else if([code.plotSizeCode isEqualToString:@"4"]){
                comps.day = 3;
            }else if([code.plotSizeCode isEqualToString:@"E"]){
                comps.day = 4;
            }else if([code.plotSizeCode isEqualToString:@"S"]){
                comps.day = 5;
            }else if([code.plotSizeCode isEqualToString:@"O"]){
                comps.day = 6;
            }else if([code.plotSizeCode isEqualToString:@"1"]){
                comps.day = 7;
            }else if([code.plotSizeCode isEqualToString:@"3"]){
                comps.day = 8;
            }else if([code.plotSizeCode isEqualToString:@"5"]){
                comps.day = 9;
            }else if([code.plotSizeCode isEqualToString:@"6"]){
                comps.day = 10;
            }else if([code.plotSizeCode isEqualToString:@"7"]){
                comps.day = 11;
            }else if([code.plotSizeCode isEqualToString:@"8"]){
                comps.day = 12;
            }else if([code.plotSizeCode isEqualToString:@"9"]){
                comps.day = 13;
            }
            code.effectiveDate  = [calendar dateByAddingComponents:comps toDate:code.effectiveDate options:0];
        }
        //order harvest method code
        for(HarvestMethodCode *code in [[CodeDAO sharedInstance] getHarvestMethodCodeList]){
            
            NSDateComponents* comps = [[NSDateComponents alloc]init];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            if([code.harvestMethodCode isEqualToString:@"B"]){
                comps.day = 1;
            }else if([code.harvestMethodCode isEqualToString:@"R"]){
                comps.day = 2;
            }else if([code.harvestMethodCode isEqualToString:@"T"]){
                comps.day = 3;
            }else if([code.harvestMethodCode isEqualToString:@"G"]){
                comps.day = 4;
            }else if([code.harvestMethodCode isEqualToString:@"S"]){
                comps.day = 5;
            }else if([code.harvestMethodCode isEqualToString:@"C"]){
                comps.day = 6;
            }else if([code.harvestMethodCode isEqualToString:@"H"]){
                comps.day = 7;
            }else if([code.harvestMethodCode isEqualToString:@"P"]){
                comps.day = 8;
            }else if([code.harvestMethodCode isEqualToString:@"M"]){
                comps.day = 9;
            }else if([code.harvestMethodCode isEqualToString:@"W"]){
                comps.day = 10;
            }else if([code.harvestMethodCode isEqualToString:@"O"]){
                comps.day = 11;
            }
            code.effectiveDate  = [calendar dateByAddingComponents:comps toDate:code.effectiveDate options:0];
        }
        //order waste type code
        for(WasteTypeCode *code in [[CodeDAO sharedInstance] getWasteTypeCodeList]){
            
            NSDateComponents* comps = [[NSDateComponents alloc]init];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            if([code.wasteTypeCode isEqualToString:@"S"]){
                comps.day = 1;
            }else if([code.wasteTypeCode isEqualToString:@"P"]){
                comps.day = 2;
            }else if([code.wasteTypeCode isEqualToString:@"C"]){
                comps.day = 3;
            }else if([code.wasteTypeCode isEqualToString:@"R"]){
                comps.day = 4;
            }else if([code.wasteTypeCode isEqualToString:@"T"]){
                comps.day = 5;
            }else if([code.wasteTypeCode isEqualToString:@"W"]){
                comps.day = 6;
            }else if([code.wasteTypeCode isEqualToString:@"O"]){
                comps.day = 7;
            }else if([code.wasteTypeCode isEqualToString:@"L"]){
                comps.day = 8;
            }else if([code.wasteTypeCode isEqualToString:@"F"]){
                comps.day = 9;
            }else if([code.wasteTypeCode isEqualToString:@"G"]){
                comps.day = 10;
            }else if([code.wasteTypeCode isEqualToString:@"D"]){
                comps.day = 11;
            }
            code.effectiveDate  = [calendar dateByAddingComponents:comps toDate:code.effectiveDate options:0];
        }
        
    }
    
    [[CodeDAO sharedInstance] refreshCodeTable];
}

@end
