//
//  SearchResultDTOAdaptor.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-24.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResultDTOAdaptor : NSObject

+ (NSArray *)searchResultDTOFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
