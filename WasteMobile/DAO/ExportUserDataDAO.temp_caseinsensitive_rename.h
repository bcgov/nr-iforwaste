//
//  exportUserDataDAO.h
//  WasteMobile
//
//  Created by Denholm Scrimshaw on 2017-02-27.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ExportUserData;

@interface ExportUserDataDAO : NSObject

+(ExportUserData *) getExportUserData;
+(ExportUserData *) createEmptyExportUserData;

@end
