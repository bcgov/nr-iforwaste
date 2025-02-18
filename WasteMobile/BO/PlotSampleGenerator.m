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
#import "AssessmentMethodCode.h"


//try to keep n1sample, n2sample, fixedSample modification in this file unless you want to incure my wrath -cnesmith
//P.S. I don't know why n1sample and n2sample are comma seperated values instead of arrays but I'm not refactoring that(I kept fixedSample in the same format for consistency). Too many knock on effects. Good luck if you'd like to try, but be very careful - there are downstream systems consuming EFW files that may be effected.
@implementation PlotSampleGenerator

//terrible string manipulation to avoid refactor of n1sample and n2sample variables and backwords compatibility
+(void)addPlot2:(WasteStratum*)ws plotNumber:(int)plotNumber{
    NSArray *fixedPlots = [ws.fixedSample componentsSeparatedByString:@","];
    for(int i = 0; i < [fixedPlots count]; i++)
    {
        if(plotNumber == [[fixedPlots objectAtIndex:i] intValue])
        {
            if([ws.n1sample isEqualToString:@""])
            {
                ws.n1sample = [NSString stringWithFormat:@"%i", plotNumber];
            } else {
                ws.n1sample = [NSString stringWithFormat:@"%@,%@", ws.n1sample, [NSString stringWithFormat:@"%i", plotNumber]];
            }
            return;//lazy return
        }
    }
    
    float randomFloat = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
    float ratioFloat = [ws.measurePlot floatValue]/[ws.predictionPlot floatValue];
    if(ratioFloat >= randomFloat)
    {
        if([ws.n1sample isEqualToString:@""])
        {
            ws.n1sample = [NSString stringWithFormat:@"%i", plotNumber];
        }
        else
        {
            ws.n1sample = [NSString stringWithFormat:@"%@,%@", ws.n1sample, [NSString stringWithFormat:@"%i", plotNumber]];
        }
    }
    else
    {
        if([ws.n2sample isEqualToString:@""])
        {
            ws.n2sample = [NSString stringWithFormat:@"%i", plotNumber];
        }
        else
        {
            ws.n2sample = [NSString stringWithFormat:@"%@,%@", ws.n2sample, [NSString stringWithFormat:@"%i", plotNumber]];
        }
    }
    
}

+(void)deletePlot2:(WasteStratum*)ws plotNumber:(int)plotNumber{
    NSMutableArray *n1Plots = [[ws.n1sample componentsSeparatedByString:@","] mutableCopy];
    for(int i = 0; i < [n1Plots count]; i++)
    {
        if([[n1Plots objectAtIndex:i] isEqualToString:[NSString stringWithFormat:@"%i", plotNumber]])
        {
            [n1Plots removeObjectAtIndex:i];
            
        }
    }
    ws.n1sample = [n1Plots componentsJoinedByString:@","];
    NSMutableArray *n2Plots = [[ws.n2sample componentsSeparatedByString:@","] mutableCopy];
    for(int i = 0; i < [n2Plots count]; i++)
    {
        if([[n2Plots objectAtIndex:i] isEqualToString:[NSString stringWithFormat:@"%i", plotNumber]])
        {
            [n2Plots removeObjectAtIndex:i];
        }
    }
    ws.n2sample = [n2Plots componentsJoinedByString:@","];
    
}
+(void)generatePlotSample2:(WasteStratum*)ws{
    if([ws.isPileStratum intValue] == 1){
       int pp = [ws.predictionPlot intValue];
       int mp = [ws.measurePlot intValue];

        if(mp == 0){mp = 1;}
        if(pp == 0){pp = 1;}

        if(mp >= 2){mp = 2;}
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

//        NSMutableArray* n2 = [[NSMutableArray alloc] init];
//        BOOL already_in_sample = NO;
//
//        for(int i = 1; i <= pp; i ++){
//            already_in_sample = NO;
//            for(NSNumber* p_num in s1){
//                if([p_num intValue] == i){
//                    already_in_sample = YES;
//                    break;
//                }
//            }
//            if(!already_in_sample){
//                [n2 addObject:[[NSNumber alloc] initWithInt:i]];
//            }
//        }
//
//        // now we have N2 population
//        NSDecimalNumber* level = [[NSDecimalNumber alloc] initWithFloat:(1.0/(pp-mp))];
//        NSString* n2sample =@"";
//
//        for(NSNumber* p_num in n2){
//            NSDecimalNumber* ran_num =[[NSDecimalNumber alloc] initWithFloat: ((double)arc4random() / ARC4RANDOM_MAX)];
//
//            n2sample = [n2sample stringByAppendingString:[NSString stringWithFormat:@"%d:%.3f;", [p_num intValue], [ran_num floatValue]]];
//            if([ran_num floatValue] < [level floatValue]){
//                [s1 addObject:[[NSNumber alloc] initWithInt:[p_num intValue]]];
//            }
//        }
//
//        ws.n1sample = [s1 componentsJoinedByString:@","];
        ws.fixedSample = [s1 componentsJoinedByString:@","];
//        ws.n2sample = n2sample;
    }else {
        int pp = [ws.predictionPlot intValue];
        int mp = [ws.measurePlot intValue] - 1;
        
        if(mp == 0){mp = 1;}
        if(pp == 0){pp = 1;}
        
        //force selection of two measure plots
        if(mp >= 2){mp = 2;}
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
        /*
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
        */
        ws.fixedSample = [s1 componentsJoinedByString:@","];
    }
    //NSLog(@"level = %.4f", [level floatValue]);
    //NSLog(@"n1sample:%@", ws.n1sample);
    //NSLog(@"n2sample:%@", ws.n2sample);
    //[self Testing];
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
