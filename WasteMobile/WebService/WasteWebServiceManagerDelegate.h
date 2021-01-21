//
//  WasteWebServiceManagerDelegate.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-25.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WasteBlock;

@protocol WasteWebServiceManagerDelegate <NSObject>

-(void) finishDownloadCutBlock:(WasteBlock *) wasteBlock;
-(void) downloadCutBlockFailed:(NSError *)error;

@end
