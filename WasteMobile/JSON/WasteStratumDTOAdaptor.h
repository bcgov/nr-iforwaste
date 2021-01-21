//
//  WasteStratumDTOAdaptor.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-08.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WasteStratumDTOAdaptor : NSObject

+ (NSArray *)wasteStratumDTOFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
