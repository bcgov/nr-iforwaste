//
//  PlotSampleGenerator.m
//  WasteMobile
//
//  Created by Jack Wong on 2017-03-16.
//  Copyright © 2017 Salus Systems. All rights reserved.
//
#define ARC4RANDOM_MAX      0x100000000

#import "PlotSampleGenerator.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WasteBlockDAO.h"
#import "AggregateCutblock+CoreDataClass.h"

@implementation PlotSampleGenerator


+(void)generatePlotSample2:(WasteStratum*)ws{
    if([ws.isPileStratum intValue] == 1){
        int pp = [ws.totalNumPile intValue];
        int mp = [ws.measureSample intValue] - 1;
        
        if(mp == 0){mp = 1;}
        if(pp == 0){pp = 1;}
        
        NSMutableArray* s1 = [[NSMutableArray alloc] init];
        
        while( s1.count < mp ){
            if( s1.count == 0){
                [s1 addObject:[[NSNumber alloc] initWithInt:arc4random_uniform(pp) + 1]];
            }else{
                int new_p_num = arc4random_uniform(pp) + 1;
                BOOL already_in_sample = NO;
                for(NSNumber* p_num in s1){
                    if([p_num intValue] == new_p_num){
                        already_in_sample = YES;
                        break;
                    }
                }
                if(!already_in_sample){
                    [s1 addObject:[[NSNumber alloc] initWithInt:new_p_num]];
                }
            }
        }
        //first set of sample should be done now, then other
        
        NSLog(@"n1sample:%@", [s1 componentsJoinedByString:@","]);
        
        NSMutableArray* n2 = [[NSMutableArray alloc] init];
        BOOL already_in_sample = NO;
        
        for(int i = 1; i <= pp; i ++){
            already_in_sample = NO;
            for(NSNumber* p_num in s1){
                if([p_num intValue] == i){
                    already_in_sample = YES;
                    break;
                }
            }
            if(!already_in_sample){
                [n2 addObject:[[NSNumber alloc] initWithInt:i]];
            }
        }
        
        // now we have N2 population
        NSDecimalNumber* level = [[NSDecimalNumber alloc] initWithFloat:(1.0/(pp-mp))];
        NSString* n2sample =@"";
        
        for(NSNumber* p_num in n2){
            NSDecimalNumber* ran_num =[[NSDecimalNumber alloc] initWithFloat: ((double)arc4random() / ARC4RANDOM_MAX)];
            
            n2sample = [n2sample stringByAppendingString:[NSString stringWithFormat:@"%d:%.3f;", [p_num intValue], [ran_num floatValue]]];
            if([ran_num floatValue] < [level floatValue]){
                [s1 addObject:[[NSNumber alloc] initWithInt:[p_num intValue]]];
            }
        }
        
        ws.n1sample = [s1 componentsJoinedByString:@","];
        ws.n2sample = n2sample;
    }else {
        int pp = [ws.predictionPlot intValue];
        int mp = [ws.measurePlot intValue] - 1;
        
        if(mp == 0){mp = 1;}
        if(pp == 0){pp = 1;}
        
        NSMutableArray* s1 = [[NSMutableArray alloc] init];
        
        while( s1.count < mp ){
            if( s1.count == 0){
                [s1 addObject:[[NSNumber alloc] initWithInt:arc4random_uniform(pp) + 1]];
            }else{
                int new_p_num = arc4random_uniform(pp) + 1;
                BOOL already_in_sample = NO;
                for(NSNumber* p_num in s1){
                    if([p_num intValue] == new_p_num){
                        already_in_sample = YES;
                        break;
                    }
                }
                if(!already_in_sample){
                    [s1 addObject:[[NSNumber alloc] initWithInt:new_p_num]];
                }
            }
        }
        //first set of sample should be done now, then other
        
        NSLog(@"n1sample:%@", [s1 componentsJoinedByString:@","]);
        
        NSMutableArray* n2 = [[NSMutableArray alloc] init];
        BOOL already_in_sample = NO;

        for(int i = 1; i <= pp; i ++){
            already_in_sample = NO;
            for(NSNumber* p_num in s1){
                if([p_num intValue] == i){
                    already_in_sample = YES;
                    break;
                }
            }
            if(!already_in_sample){
                [n2 addObject:[[NSNumber alloc] initWithInt:i]];
            }
        }
        
        // now we have N2 population
        NSDecimalNumber* level = [[NSDecimalNumber alloc] initWithFloat:(1.0/(pp-mp))];
        NSString* n2sample =@"";
        
        for(NSNumber* p_num in n2){
            NSDecimalNumber* ran_num =[[NSDecimalNumber alloc] initWithFloat: ((double)arc4random() / ARC4RANDOM_MAX)];
            
            n2sample = [n2sample stringByAppendingString:[NSString stringWithFormat:@"%d:%.3f;", [p_num intValue], [ran_num floatValue]]];
            if([ran_num floatValue] < [level floatValue]){
                [s1 addObject:[[NSNumber alloc] initWithInt:[p_num intValue]]];
            }
        }
        
        ws.n1sample = [s1 componentsJoinedByString:@","];
        ws.n2sample = n2sample;
    }
    //NSLog(@"level = %.4f", [level floatValue]);
    //NSLog(@"n1sample:%@", ws.n1sample);
    //NSLog(@"n2sample:%@", ws.n2sample);
    //[self Testing];
}
+(void)generatePlotSample3:(AggregateCutblock*)aggCB{
    int pp = [aggCB.totalNumPile intValue];
    int mp = [aggCB.measureSample intValue] - 1;
    
    if(mp == 0){mp = 1;}
    if(pp == 0){pp = 1;}
    
    NSMutableArray* s1 = [[NSMutableArray alloc] init];
    
    while( s1.count < mp ){
        if( s1.count == 0){
            [s1 addObject:[[NSNumber alloc] initWithInt:arc4random_uniform(pp) + 1]];
        }else{
            int new_p_num = arc4random_uniform(pp) + 1;
            BOOL already_in_sample = NO;
            for(NSNumber* p_num in s1){
                if([p_num intValue] == new_p_num){
                    already_in_sample = YES;
                    break;
                }
            }
            if(!already_in_sample){
                [s1 addObject:[[NSNumber alloc] initWithInt:new_p_num]];
            }
        }
    }
    //first set of sample should be done now, then other
    
    NSLog(@"n1sample:%@", [s1 componentsJoinedByString:@","]);
    
    NSMutableArray* n2 = [[NSMutableArray alloc] init];
    BOOL already_in_sample = NO;
    
    for(int i = 1; i <= pp; i ++){
        already_in_sample = NO;
        for(NSNumber* p_num in s1){
            if([p_num intValue] == i){
                already_in_sample = YES;
                break;
            }
        }
        if(!already_in_sample){
            [n2 addObject:[[NSNumber alloc] initWithInt:i]];
        }
    }
    
    // now we have N2 population
    NSDecimalNumber* level = [[NSDecimalNumber alloc] initWithFloat:(1.0/(pp-mp))];
    NSString* n2sample =@"";
    
    for(NSNumber* p_num in n2){
        NSDecimalNumber* ran_num =[[NSDecimalNumber alloc] initWithFloat: ((double)arc4random() / ARC4RANDOM_MAX)];
        
        n2sample = [n2sample stringByAppendingString:[NSString stringWithFormat:@"%d:%.3f;", [p_num intValue], [ran_num floatValue]]];
        if([ran_num floatValue] < [level floatValue]){
            [s1 addObject:[[NSNumber alloc] initWithInt:[p_num intValue]]];
        }
    }
    
    aggCB.n1sample = [s1 componentsJoinedByString:@","];
    aggCB.n2sample = n2sample;
}
//Test the randomness of the plot selector

+(void)TestingRandomess:(int)sampleSize predictionPlot:(int)predictionPlot measurePlot:(int)measurePlot{
    // Set the parameter here:

    NSLog(@"Prediction Plot = %d, Measure Plot = %d, Sample Size = %d ", predictionPlot, measurePlot, sampleSize);

    measurePlot = measurePlot - 1;
    
    NSInteger result[predictionPlot];
    NSInteger plot_num_population[predictionPlot];

    for(int i = 0; i < predictionPlot ; i++){
        result[i] = 0;
        plot_num_population[i] = 0;
    }
    
    
    for(int i = 0; i < sampleSize ; i++){
            
        
        NSMutableArray* s1 = [[NSMutableArray alloc] init];
        
        //********** arc4random method **************
        while( s1.count < measurePlot ){
            if( s1.count == 0){
                [s1 addObject:[[NSNumber alloc] initWithInt:arc4random_uniform(predictionPlot) + 1]];
            }else{
                int new_p_num = arc4random_uniform(predictionPlot) + 1;
                BOOL already_in_sample = NO;
                for(NSNumber* p_num in s1){
                    if([p_num intValue] == new_p_num){
                        already_in_sample = YES;
                        break;
                    }
                }
                if(!already_in_sample){
                    [s1 addObject:[[NSNumber alloc] initWithInt:new_p_num]];
                }
            }
        }
        //first set of sample should be done now, then other
        
        NSMutableArray* n2 = [[NSMutableArray alloc] init];
        BOOL already_in_sample = NO;
        
        for(int i = 1; i <= predictionPlot; i ++){
            already_in_sample = NO;
            for(NSNumber* p_num in s1){
                if([p_num intValue] == i){
                    already_in_sample = YES;
                    break;
                }
            }
            if(!already_in_sample){
                [n2 addObject:[[NSNumber alloc] initWithInt:i]];
            }
        }
        
        // now we have N2 population
        NSDecimalNumber* level = [[NSDecimalNumber alloc] initWithFloat:(1.0/(predictionPlot-measurePlot))];
        NSString* n2sample =@"";
        
        for(NSNumber* p_num in n2){
            NSDecimalNumber* ran_num =[[NSDecimalNumber alloc] initWithFloat: ((double)arc4random() / ARC4RANDOM_MAX)];
            
            n2sample = [n2sample stringByAppendingString:[NSString stringWithFormat:@"%d:%.3f;", [p_num intValue], [ran_num floatValue]]];
            if([ran_num floatValue] < [level floatValue]){
                [s1 addObject:[[NSNumber alloc] initWithInt:[p_num intValue]]];
            }
        }
        //**********************************
        
        //**************** srand method *******************
        /* did not use this one
        while( s1.count < mp ){
            if( s1.count == 0){
                srand([[NSDate date] timeIntervalSince1970]);
                [s1 addObject:[[NSNumber alloc] initWithInt:(rand()%pp + 1)]];
            }else{
                srand([[NSDate date] timeIntervalSince1970]);
                int new_p_num = rand()%pp + 1;
                BOOL already_in_sample = NO;
                for(NSNumber* p_num in s1){
                    if([p_num intValue] == new_p_num){
                        already_in_sample = YES;
                        break;
                    }
                }
                if(!already_in_sample){
                    [s1 addObject:[[NSNumber alloc] initWithInt:new_p_num]];
                }
            }
        }
        //first set of sample should be done now, then other
        
        NSMutableArray* n2 = [[NSMutableArray alloc] init];
        BOOL already_in_sample = NO;
        
        for(int i = 1; i <= pp; i ++){
            already_in_sample = NO;
            for(NSNumber* p_num in s1){
                if([p_num intValue] == i){
                    already_in_sample = YES;
                    break;
                }
            }
            if(!already_in_sample){
                [n2 addObject:[[NSNumber alloc] initWithInt:i]];
            }
        }
        
        // now we have N2 population
        NSDecimalNumber* level = [[NSDecimalNumber alloc] initWithFloat:(1.0/(pp-mp))];
        NSString* n2sample =@"";
        
        for(NSNumber* p_num in n2){
            srand([[NSDate date] timeIntervalSince1970]);
            NSDecimalNumber* ran_num =[[NSDecimalNumber alloc] initWithFloat: ((double) (rand()%100000) / 100000)];
            
            n2sample = [n2sample stringByAppendingString:[NSString stringWithFormat:@"%d:%.3f;", [p_num intValue], [ran_num floatValue]]];
            if([ran_num floatValue] < [level floatValue]){
                [s1 addObject:[[NSNumber alloc] initWithInt:[p_num intValue]]];
            }
        }
         */
        //**********************************************
        
        //NSLog(@"size:%d", s1.count);
        
        result[s1.count-1] = result[s1.count-1] + 1;
        for(NSNumber *p_num in s1){
            plot_num_population[[p_num integerValue] - 1]++;
        }
            
    }
    
    for(int i = 0; i < predictionPlot; i++){
        if (result[i] > 0){
            NSLog(@"size %d has %ld hit(s)", i+1, (long)result[i]);
        }
    }
    NSLog(@"plot number population");
    for(int i=0; i< predictionPlot; i++){
        if(plot_num_population[i] > 0){
            NSLog(@"Plot Number %d hit %ld number of times", i+1, plot_num_population[i]);
        }else{
            NSLog(@"Plot Number %d hit 0 number of times", i+1);
        }
    }

    
}


@end
