//
//  Timer.h
//  WasteMobile
//
//  Created by  on 2014-10-15.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject {
    NSString *someProperty;
}

@property (nonatomic, retain) NSString *someProperty;
@property (nonatomic, retain) UIViewController *currentVC;


+ (id)sharedManager;

- (void)timerFireMethod:(NSTimer *)timer;

@end