//
//  Timer.m
//  WasteMobile
//
//  Created by  on 2014-10-15.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "Timer.h"
#import "CanAutoSave.h"

#import "BlockViewController.h"
#import "TimbermarkViewController.h"
#import "StratumViewController.h"
#import "PlotViewController.h"
#import "PileViewController.h"


@implementation Timer


@synthesize someProperty, currentVC;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static Timer *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init]; 
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
        
        [NSTimer scheduledTimerWithTimeInterval:10*60 // 10min = 10 * 60sec
                                         target:self
                                       selector:@selector(timerFireMethod:)
                                       userInfo:nil
                                        repeats:YES];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


- (void)timerFireMethod:(NSTimer *)timer{
    
    
    if( [self.currentVC isKindOfClass:[BlockViewController class]] && [self.currentVC conformsToProtocol:@protocol(CanAutoSave)]){
        BlockViewController *bvc = ((BlockViewController*)self.currentVC);
        [bvc saveData];
    
    }
    else if( [self.currentVC isKindOfClass:[StratumViewController class]]  && [self.currentVC conformsToProtocol:@protocol(CanAutoSave)] ){
        StratumViewController *svc = ((StratumViewController*)self.currentVC);
        [svc saveData];
        
    }
    else if( [self.currentVC isKindOfClass:[PlotViewController class]] && [self.currentVC conformsToProtocol:@protocol(CanAutoSave)] ){
        PlotViewController *pvc = ((PlotViewController*)self.currentVC);
        [pvc saveData];
        
    }
    else if( [self.currentVC isKindOfClass:[TimbermarkViewController class]] && [self.currentVC conformsToProtocol:@protocol(CanAutoSave)] ){
        TimbermarkViewController *tvc = ((TimbermarkViewController*)self.currentVC);
        [tvc saveData];
        
    }
    else if( [self.currentVC isKindOfClass:[PileViewController class]] && [self.currentVC conformsToProtocol:@protocol(CanAutoSave)] ){
        PileViewController *pvc = ((PileViewController*)self.currentVC);
        [pvc saveData];
        
    }
    else{
        NSLog(@"AutoSave didn't work, not supported in current view");
    }
    
    

}

@end
