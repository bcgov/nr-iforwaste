//
//  WastePieceDTOAdaptor.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-08.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WastePieceDTOAdaptor : NSObject

+ (NSArray *)wastePieceDTOFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
