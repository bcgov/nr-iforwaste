//
//  WasteImportBlockValidator.h
//  WasteMobile
//
//  Created by Jack Wong on 2017-02-08.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WasteBlock;

@interface WasteImportBlockValidator : NSObject

+(NSMutableArray *) compareBlockForImport:(WasteBlock *)wb1 wb2:(WasteBlock *)wb2;
+(NSMutableArray *) compareBlockForImportPileStratum:(WasteBlock *)wb1 wb2:(WasteBlock *)wb2;
+(NSMutableArray *) compareBlockForImportStratum:(WasteBlock *)wb1 wb2:(WasteBlock *)wb2;
@end
