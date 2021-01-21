//
//  WasteWebServiceManager.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-25.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "WasteWebServiceManagerDelegate.h"

@class WasteBlock;

@protocol WasteWebServiceManagerDelegate;

@interface WasteWebServiceManager : NSObject

@property (weak, nonatomic) id<WasteWebServiceManagerDelegate> delegate;

-(NSArray *) searchCutBlock:(NSNumber *)reportingUnitNumber;
+(NSString *) getWSURLBASE;

-(void) downloadCutBlock:(NSString *)wasteAssessmentAreaID;

@end
