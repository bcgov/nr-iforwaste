//
//  AppPatch.h
//  WasteMobile
//
//  Created by Jack Wong on 2018-01-31.
//  Copyright © 2018 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppPatch : NSObject

+ (AppPatch *)sharedInstance;

-(void) patch120;

@end
