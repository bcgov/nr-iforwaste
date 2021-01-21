//
//  WasteBlockDTOAdaptor.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-07.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WasteBlockDTOAdaptor : NSObject

+ (NSArray *)wasteBlockDTOFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
