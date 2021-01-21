//
//  WasteStratumDTO.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-08.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WasteStratumDTO : NSObject

@property  NSString * stratum;
@property  NSDecimalNumber * stratumArea;
@property  NSNumber * stratumID;
@property  NSNumber * totalEstimatedVolume;

@property  NSString *harvestMethodCode;
@property  NSString *plotSizeCode;
@property  NSString *stratumTypeCode;
@property  NSString *wasteLevelCode;
@property  NSString *wasteTypeCode;
@property  NSString *assessmentMethodCode;
@end
