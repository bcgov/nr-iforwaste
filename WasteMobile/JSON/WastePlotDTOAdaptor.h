//
//  WastePlotDTOAdaptor.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-08.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WastePlotDTOAdaptor : NSObject

+ (NSArray *)wastePlotDTOFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
