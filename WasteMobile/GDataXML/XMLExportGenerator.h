//
//  XMLExportGenerator.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-31.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WasteBlock;

typedef enum ExportOutcomeCode{
    ExportSuccessful,
    ExportFailFilenameExist,
    ExportFailUnknown
}ExportOutcomeCode;

typedef enum ExportTypeCode{
    IFW,
    XML,
    EFW
}ExportTypeCode;

@interface XMLExportGenerator : NSObject

-(ExportOutcomeCode) generateCutBlockXMLExport:(WasteBlock*) wasteBlock replace:(BOOL)replace type:(ExportTypeCode)type;

@end
