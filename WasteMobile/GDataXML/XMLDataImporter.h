//
//  XMLDataImporter.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-11-02.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class WasteBlock;

typedef enum ImportOutcomeCode{
    ImportSuccessful,
    ImportFailCutBlockExist,
    ImportFailLoadXML,
    ImportFailOnSaveWastBlock,
    ImportFailRegionIDExist
}ImportOutcomeCode;

@interface XMLDataImporter : NSObject

-(ImportOutcomeCode) ImportDataByFileName:(NSString *)fileName wasteBlock:(WasteBlock **)wb ignoreExisting:(BOOL)igExist;

 -(ImportOutcomeCode) ImportDataByURL:(NSURL *)url wasteBlock:(WasteBlock **)wb ignoreExisting:(BOOL)igExist;

@end
