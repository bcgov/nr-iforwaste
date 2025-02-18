//
//  PileHeaderView.m
//  iForWaste
//
//  Created by Sweta Kutty on 2019-03-04.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "PileHeaderView.h"
#import "UIColor+WasteColor.h"

@implementation PileHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if([self.displayMode isEqualToString: @"0"]){
        [self drawHeaderForPileSRS: [self.userCreatedBlock isEqualToString:@"YES" ]];
    }else if([self.displayMode isEqualToString: @"1"]){
        [self drawHeaderForPileRatio: [self.userCreatedBlock isEqualToString:@"YES" ]];
    }
}

- (void) drawHeaderForPileSRS: (BOOL) userCreated{
    
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    
    [labelArray addObject:@" \n\n\nL;m;n"];
    [labelArray addObject:@" \n\n\nW;m;n"];
    [labelArray addObject:@" \n\n\nH;m;n"];
    [labelArray addObject:@" \n\n\nShape Code;w;n"];
    [labelArray addObject:@" \n\n\nPile Area m2;w;n"];
    [labelArray addObject:@" \n\n\nPile Volume m3;w;n"];
    
    //width for each column is 47
    int locationCounter = -48;
    int locationCounter2 = 44;
    
    //int alterCounter = 0;
    for (NSString *lbStr in labelArray){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        
        
        UILabel *lbl = nil;
        if ([[lbStrAry objectAtIndex:2]  isEqualToString:@"y"]){
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter+44, 88, 140, 45)];
            lbl.transform = CGAffineTransformMakeRotation(-M_PI_2);
            lbl.textAlignment = NSTextAlignmentLeft;
            
            locationCounter = locationCounter + 44;
        }else{
            if ([[lbStrAry objectAtIndex:0] isEqualToString:@" \n\n\nPile Area m2"]){
                lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter2, 41, 140, 140)];
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.numberOfLines = 5;
                lbl.contentMode = UIViewContentModeBottom;
                locationCounter = locationCounter + 140;
                locationCounter2 = locationCounter2 + 140;
                
            }else if([[lbStrAry objectAtIndex:0] isEqualToString:@" \n\n\nPile Volume m3"]){
                lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter2, 41, 140, 140)];
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.numberOfLines = 5;
                lbl.contentMode = UIViewContentModeBottom;
                locationCounter = locationCounter + 140;
                locationCounter2 = locationCounter2 + 140;
            }
            else
            {
                lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter2, 41, 110, 140)];
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.numberOfLines = 5;
                lbl.contentMode = UIViewContentModeBottom;
                locationCounter = locationCounter + 110;
                locationCounter2 = locationCounter2 + 110;
            }
        }
        
        lbl.text = [lbStrAry objectAtIndex:0];
        
        if ([[lbStrAry objectAtIndex:1] isEqualToString:@"g"]){
            lbl.backgroundColor = [UIColor piecesHeaderGreen];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"b"]){
            lbl.backgroundColor = [UIColor piecesHeaderBlue];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"o"]) {
            lbl.backgroundColor = [UIColor piecesHeaderOrange];
        }
        if ([[lbStrAry objectAtIndex:0] isEqualToString:@" \n\n\nPile Area m2"]){
            lbl.backgroundColor = [UIColor grayColor];
        }else if([[lbStrAry objectAtIndex:0] isEqualToString:@" \n\n\nPile Volume m3"]){
            lbl.backgroundColor = [UIColor grayColor];
        }
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lbl];
        
        //  alterCounter = alterCounter + 1;
    }
 
    
    NSMutableArray *labelArray2 = [[NSMutableArray alloc] init];
    
    [labelArray2 addObject:@" Measured Dimensions;m;1;3"];    
    
    for (NSString *lbStr in labelArray2){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        int lbX = [[lbStrAry objectAtIndex:2] intValue] * 45;
        int lbWidth = [[lbStrAry objectAtIndex:3] intValue] * 110 + 110;
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(lbX, 0, lbWidth, 42)];
        lbl.text = [lbStrAry objectAtIndex:0];
        
        
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.lineBreakMode = NSLineBreakByCharWrapping;
        lbl.numberOfLines = 0;
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [self addSubview:lbl];
    }
}

- (void) drawHeaderForPileRatio: (BOOL) userCreated{
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    
    [labelArray addObject:@" Sample Pile #;w;y"];
    [labelArray addObject:@" L;e;n"];
    [labelArray addObject:@" W;e;n"];
    [labelArray addObject:@" H;e;n"];
    [labelArray addObject:@" Shape Code;e;n"];
    [labelArray addObject:@" Pile Area m2;w;t"];
    [labelArray addObject:@" Pile Volume m3;w;x"];
    [labelArray addObject:@" L;m;n"];
    [labelArray addObject:@" W;m;n"];
    [labelArray addObject:@" H;m;n"];
    [labelArray addObject:@" Shape Code;e;n"];
    [labelArray addObject:@" Pile Area m2;w;t"];
    [labelArray addObject:@" Pile Volume m3;w;x"];
    
  
    //width for each column is 47
    int locationCounter = -48;
    int locationCounter2 = 45;
    
    //int alterCounter = 0;
    for (NSString *lbStr in labelArray){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        
        
        UILabel *lbl = nil;
        if ([[lbStrAry objectAtIndex:2]  isEqualToString:@"y"]){
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter, 88, 140, 45)];
            lbl.transform = CGAffineTransformMakeRotation(-M_PI_2);
            lbl.textAlignment = NSTextAlignmentLeft;
            locationCounter = locationCounter + 44;
        } else if ([[lbStrAry objectAtIndex:2]  isEqualToString:@"t"]) {
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter2, 41, 105, 140)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 5;
            lbl.contentMode = UIViewContentModeBottom;
            locationCounter2 = locationCounter2 + 105;
            locationCounter = locationCounter + 105;
        } else if ([[lbStrAry objectAtIndex:2] isEqualToString:@"x"]) {
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter2, 41, 105, 140)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 5;
            lbl.contentMode = UIViewContentModeBottom;
            locationCounter2 = locationCounter2 + 105;
            locationCounter = locationCounter + 105;
        } else{
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter2, 41, 70, 140)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 5;
            lbl.contentMode = UIViewContentModeBottom;
            locationCounter2 = locationCounter2 + 70;
            locationCounter = locationCounter + 70;
        }
        
        lbl.text = [lbStrAry objectAtIndex:0];
        
        if ([[lbStrAry objectAtIndex:1] isEqualToString:@"g"]){
            lbl.backgroundColor = [UIColor piecesHeaderGreen];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"b"]){
            lbl.backgroundColor = [UIColor piecesHeaderBlue];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"o"]) {
            lbl.backgroundColor = [UIColor piecesHeaderOrange];
        }
        if ([[lbStrAry objectAtIndex:0] isEqualToString:@" Pile Area m2"]){
            lbl.backgroundColor = [UIColor grayColor];
        }else if([[lbStrAry objectAtIndex:0] isEqualToString:@" Pile Volume m3"]){
            lbl.backgroundColor = [UIColor grayColor];
        }
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lbl];
        
        //  alterCounter = alterCounter + 1;
    }
    
    
    NSMutableArray *labelArray2 = [[NSMutableArray alloc] init];
    
    [labelArray2 addObject:@" Estimated Dimensions;m;1;4"];
    [labelArray2 addObject:@" Measured \nDimensions;m;8;4"];
    
    for (NSString *lbStr in labelArray2){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        int lbX;
        int lbWidth = 0;
        if([[lbStrAry objectAtIndex:0] isEqualToString:@" Estimated Dimensions"]){
            lbX = [[lbStrAry objectAtIndex:2] intValue] * 45;
            lbWidth = [[lbStrAry objectAtIndex:3] intValue] * 70;
        }else{
            lbX = [[lbStrAry objectAtIndex:2] intValue] * 58 + 71;
            lbWidth = [[lbStrAry objectAtIndex:3] intValue] * 70;
        }
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(lbX, 0, lbWidth, 42)];
        lbl.text = [lbStrAry objectAtIndex:0];
        
        
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.lineBreakMode = NSLineBreakByCharWrapping;
        lbl.numberOfLines = 0;
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [self addSubview:lbl];
        
        locationCounter = locationCounter + 70;
    }
}

@end
