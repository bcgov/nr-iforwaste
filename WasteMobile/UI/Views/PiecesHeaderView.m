//
//  PiecesHeaderView.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-08-22.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "PiecesHeaderView.h"
#import "UIColor+WasteColor.h"

@implementation PiecesHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    if ([self.displayMode isEqualToString:@""]){
        self.displayMode = @"P";
    }
    
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    if ([self.displayMode isEqualToString:@"P"]){
        
        [self drawHeaderForPlot: [self.userCreatedBlock isEqualToString:@"YES" ]];
        
    }else if([self.displayMode isEqualToString:@"S"]) {
    
        [self drawHeaderForScale: [self.userCreatedBlock isEqualToString:@"YES" ]];

    }else if([self.displayMode isEqualToString:@"O"]) {
     
        [self drawHeaderForVolumeEstimate: [self.userCreatedBlock isEqualToString:@"YES" ]];

    }else if([self.displayMode isEqualToString:@"E"]) {

        [self drawHeaderForPercentEstimate: [self.userCreatedBlock isEqualToString:@"YES" ]];
    }
    
    
}

- (void) drawHeaderForScale: (BOOL) userCreated{
    
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    
    [labelArray addObject:@" Checked;w;50;86"];
    [labelArray addObject:@" Piece No.;w;50;86"];
    [labelArray addObject:@" Species;w;50;86"];
    [labelArray addObject:@" Kind;w;50;86"];
    [labelArray addObject:@" Class;w;50;86"];
    [labelArray addObject:@" Length (dm);g;50;86"];
    [labelArray addObject:@" Top (R);g;50;86"];
    [labelArray addObject:@" Top End;g;50;86"];
    [labelArray addObject:@" Butt (R);g;50;86"];
    [labelArray addObject:@" Butt End;g;50;86"];
    [labelArray addObject:@" Grade;w;50;86"];
    [labelArray addObject:@" Length (dm);b;50;86"];
    [labelArray addObject:@" Top (R);b;50;86"];
    [labelArray addObject:@" Butt (R);b;50;86"];
    [labelArray addObject:@" Decay;b;50;86"];
    [labelArray addObject:@" Comment Code;w;50;86"];
    [labelArray addObject:@" User Code;w;50;86"];       // mchu Mar 12, 2019 - To support Industry collection
    [labelArray addObject:@" Note;w;50;86"];
    
    //width for each column is 47
    int locationCounter = -48;
    //int alterCounter = 0;
    for (NSString *lbStr in labelArray){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter, [[lbStrAry objectAtIndex:3] intValue], 140, [[lbStrAry objectAtIndex:2] intValue])];
        lbl.text = [lbStrAry objectAtIndex:0];
        
        if ([[lbStrAry objectAtIndex:1] isEqualToString:@"g"]){
            lbl.backgroundColor = [UIColor piecesHeaderGreen];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"b"]){
            lbl.backgroundColor = [UIColor piecesHeaderBlue];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"o"]) {
            lbl.backgroundColor = [UIColor piecesHeaderOrange];
        }
        
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        lbl.transform = CGAffineTransformMakeRotation(-M_PI_2);
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lbl];
        
        locationCounter = locationCounter + [[lbStrAry objectAtIndex:2] intValue];

        //  alterCounter = alterCounter + 1;
    }
    if(userCreated){
        // create last two column with width 70
        UILabel *lblSurvey = [[UILabel alloc] initWithFrame:CGRectMake(876, 61, 140, 100)];   
        lblSurvey.text = @" Survey (m\u00B3) ";
        lblSurvey.backgroundColor = [UIColor piecesHeaderRed];
        lblSurvey.textColor = [UIColor blackColor];
        lblSurvey.highlightedTextColor = [UIColor blackColor];
        lblSurvey.textAlignment = NSTextAlignmentLeft;
        lblSurvey.layer.borderColor = [UIColor blackColor].CGColor;
        lblSurvey.numberOfLines = 0;
        lblSurvey.layer.borderWidth = 1.0;
        lblSurvey.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblSurvey setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lblSurvey];
        
    }else{
        // create last two column with width 70
        UILabel *lblSurvey = [[UILabel alloc] initWithFrame:CGRectMake(814, 73, 140, 75)];
        lblSurvey.text = @" Survey (m\u00B3) ";
        lblSurvey.backgroundColor = [UIColor piecesHeaderRed];
        lblSurvey.textColor = [UIColor blackColor];
        lblSurvey.highlightedTextColor = [UIColor blackColor];
        lblSurvey.textAlignment = NSTextAlignmentLeft;
        lblSurvey.layer.borderColor = [UIColor blackColor].CGColor;
        lblSurvey.numberOfLines = 0;
        lblSurvey.layer.borderWidth = 1.0;
        lblSurvey.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblSurvey setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lblSurvey];
        
        UILabel *lblCheck = [[UILabel alloc] initWithFrame:CGRectMake(884, 73, 140, 75)];
        lblCheck.text = @" Check (m\u00B3) ";
        lblCheck.backgroundColor = [UIColor piecesHeaderRed];
        lblCheck.textColor = [UIColor blackColor];
        lblCheck.highlightedTextColor = [UIColor blackColor];
        lblCheck.textAlignment = NSTextAlignmentLeft;
        lblCheck.layer.borderColor = [UIColor blackColor].CGColor;
        lblCheck.numberOfLines = 0;
        lblCheck.layer.borderWidth = 1.0;
        lblCheck.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblCheck setFont:[UIFont systemFontOfSize:20]];
        
        [self addSubview:lblCheck];
    }

    
    
    
    NSMutableArray *labelArray2 = [[NSMutableArray alloc] init];
    
    [labelArray2 addObject:@" Gross Dimensions for\n pieces inside plot ;g;5;5"];
    [labelArray2 addObject:@" Deductions for\n Rot/Holes;b;11;4"];
    
    
    for (NSString *lbStr in labelArray2){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        int lbX = ([[lbStrAry objectAtIndex:2] intValue] * 50 )- 3;
        int lbWidth = [[lbStrAry objectAtIndex:3] intValue] * 50;
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(lbX, 0, lbWidth, 42)];
        lbl.text = [lbStrAry objectAtIndex:0];
        
        if ([[lbStrAry objectAtIndex:1] isEqualToString:@"g"]){
            lbl.backgroundColor = [UIColor piecesHeaderGreen];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"b"]){
            lbl.backgroundColor = [UIColor piecesHeaderBlue];
        }
        
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.lineBreakMode = NSLineBreakByCharWrapping;
        lbl.numberOfLines = 0;
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [self addSubview:lbl];
        
        locationCounter = locationCounter + 50;
    }
    
    
    UILabel *lblPieceVolumn = [[UILabel alloc] initWithFrame:CGRectMake(896, 0, 100, 42)];
    lblPieceVolumn.text = @" Piece Vol ";
    lblPieceVolumn.backgroundColor = [UIColor piecesHeaderRed];
    
    lblPieceVolumn.textColor = [UIColor blackColor];
    lblPieceVolumn.highlightedTextColor = [UIColor blackColor];
    lblPieceVolumn.textAlignment = NSTextAlignmentCenter;
    lblPieceVolumn.lineBreakMode = NSLineBreakByCharWrapping;
    lblPieceVolumn.numberOfLines = 0;
    lblPieceVolumn.layer.borderColor = [UIColor blackColor].CGColor;
    lblPieceVolumn.layer.borderWidth = 1.0;
    [lblPieceVolumn setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    
    [self addSubview:lblPieceVolumn];

}

- (void) drawHeaderForPercentEstimate: (BOOL) userCreated{
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    
    [labelArray addObject:@" Checked;w;y"];
    [labelArray addObject:@" Piece No.;w;y"];
    [labelArray addObject:@" \n\n\n\nSpecies;w;n"];
    [labelArray addObject:@" \n\n\n\nKind;w;n"];
    [labelArray addObject:@" \n\n\n\nClass;w;n"];
    [labelArray addObject:@" \n\n\n\nGrade;w;n"];
    [labelArray addObject:@" \n\n\n\nUser Code;w;n"];
    [labelArray addObject:@" \n\n\n\nNote;w;n"];
    [labelArray addObject:@" \n\n\nPercent Estimate;w;n"];
    
    //width for each column is 47
    int locationCounter = -48;
    int locaitonCounter2 = 87;

    //int alterCounter = 0;
    for (NSString *lbStr in labelArray){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        
        
        UILabel *lbl = nil;
        if ([[lbStrAry objectAtIndex:2]  isEqualToString:@"y"]){
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter, 88, 140, 45)];
            lbl.transform = CGAffineTransformMakeRotation(-M_PI_2);
            lbl.textAlignment = NSTextAlignmentLeft;
            
            locationCounter = locationCounter + 43;
        }else{
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locaitonCounter2, 41, 110, 140)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 6;
            lbl.contentMode = UIViewContentModeBottom;
            locaitonCounter2 = locaitonCounter2 + 110;
        }
        
        lbl.text = [lbStrAry objectAtIndex:0];
        
        if ([[lbStrAry objectAtIndex:1] isEqualToString:@"g"]){
            lbl.backgroundColor = [UIColor piecesHeaderGreen];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"b"]){
            lbl.backgroundColor = [UIColor piecesHeaderBlue];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"o"]) {
            lbl.backgroundColor = [UIColor piecesHeaderOrange];
        }
        
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lbl];
        
        //  alterCounter = alterCounter + 1;
    }
    if(userCreated){
        // create last two column with width 70
        UILabel *lblSurvey = [[UILabel alloc] initWithFrame:CGRectMake(856, 41, 140, 140)];
        lblSurvey.text = @" Survey (m\u00B3) ";
        lblSurvey.backgroundColor = [UIColor piecesHeaderRed];
        lblSurvey.textColor = [UIColor blackColor];
        lblSurvey.highlightedTextColor = [UIColor blackColor];
        lblSurvey.textAlignment = NSTextAlignmentLeft;
        lblSurvey.layer.borderColor = [UIColor blackColor].CGColor;
        lblSurvey.numberOfLines = 0;
        lblSurvey.layer.borderWidth = 1.0;
        lblSurvey.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblSurvey setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lblSurvey];
       
    }else{
        // create last two column with width 70
        UILabel *lblSurvey = [[UILabel alloc] initWithFrame:CGRectMake(832, 66, 140, 90)];
        lblSurvey.text = @" Survey (m\u00B3) ";
        lblSurvey.backgroundColor = [UIColor piecesHeaderRed];
        lblSurvey.textColor = [UIColor blackColor];
        lblSurvey.highlightedTextColor = [UIColor blackColor];
        lblSurvey.textAlignment = NSTextAlignmentLeft;
        lblSurvey.layer.borderColor = [UIColor blackColor].CGColor;
        lblSurvey.numberOfLines = 0;
        lblSurvey.layer.borderWidth = 1.0;
        lblSurvey.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblSurvey setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lblSurvey];
        
        UILabel *lblCheck = [[UILabel alloc] initWithFrame:CGRectMake(922, 66, 140, 90)];
        lblCheck.text = @" Check (m\u00B3) ";
        lblCheck.backgroundColor = [UIColor piecesHeaderRed];
        lblCheck.textColor = [UIColor blackColor];
        lblCheck.highlightedTextColor = [UIColor blackColor];
        lblCheck.textAlignment = NSTextAlignmentLeft;
        lblCheck.layer.borderColor = [UIColor blackColor].CGColor;
        lblCheck.numberOfLines = 0;
        lblCheck.layer.borderWidth = 1.0;
        lblCheck.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblCheck setFont:[UIFont systemFontOfSize:20]];
        
        [self addSubview:lblCheck];
    }

    
    
    /*
     NSMutableArray *labelArray2 = [[NSMutableArray alloc] init];
     
     [labelArray2 addObject:@" Gross Dimensions for\n pieces inside plot ;g;6;5"];
     [labelArray2 addObject:@" Deductions for\n Rot/Holes;b;12;4"];
     [labelArray2 addObject:@" Outside\n Measure ;o;16;2"];
     
     
     for (NSString *lbStr in labelArray2){
     NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
     int lbX = [[lbStrAry objectAtIndex:2] intValue] * 43;
     int lbWidth = [[lbStrAry objectAtIndex:3] intValue] * 43;
     
     UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(lbX, 0, lbWidth, 42)];
     lbl.text = [lbStrAry objectAtIndex:0];
     
     if ([[lbStrAry objectAtIndex:1] isEqualToString:@"g"]){
     lbl.backgroundColor = [UIColor piecesHeaderGreen];
     }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"b"]){
     lbl.backgroundColor = [UIColor piecesHeaderBlue];
     }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"o"]) {
     lbl.backgroundColor = [UIColor piecesHeaderOrange];
     }
     
     lbl.textColor = [UIColor blackColor];
     lbl.highlightedTextColor = [UIColor blackColor];
     lbl.textAlignment = NSTextAlignmentCenter;
     lbl.lineBreakMode = NSLineBreakByCharWrapping;
     lbl.numberOfLines = 0;
     lbl.layer.borderColor = [UIColor blackColor].CGColor;
     lbl.layer.borderWidth = 1.0;
     [lbl setFont:[UIFont fontWithName:@"Helvetica" size:16]];
     [self addSubview:lbl];
     
     locationCounter = locationCounter + 43;
     }
     */

    UILabel *lblPieceVolumn = [[UILabel alloc] initWithFrame:CGRectMake(856, 0, 165, 42)];

    lblPieceVolumn.text = @"Estimate Volume";
    lblPieceVolumn.backgroundColor = [UIColor piecesHeaderRed];
    
    lblPieceVolumn.textColor = [UIColor blackColor];
    lblPieceVolumn.highlightedTextColor = [UIColor blackColor];
    lblPieceVolumn.textAlignment = NSTextAlignmentCenter;
    lblPieceVolumn.lineBreakMode = NSLineBreakByCharWrapping;
    lblPieceVolumn.numberOfLines = 0;
    lblPieceVolumn.layer.borderColor = [UIColor blackColor].CGColor;
    lblPieceVolumn.layer.borderWidth = 1.0;
    [lblPieceVolumn setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    
    [self addSubview:lblPieceVolumn];
}

- (void) drawHeaderForPlot: (BOOL) userCreated{
    
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    
    [labelArray addObject:@" Checked;w"];
    [labelArray addObject:@" Piece No.;w"];
    [labelArray addObject:@" Border Line;w"];
    [labelArray addObject:@" Species;w"];
    [labelArray addObject:@" Kind;w"];
    [labelArray addObject:@" Class;w"];
    [labelArray addObject:@" Length (dm);g"];
    [labelArray addObject:@" Top (R);g"];
    [labelArray addObject:@" Top End;g"];
    [labelArray addObject:@" Butt (R);g"];
    [labelArray addObject:@" Butt End;g"];
    [labelArray addObject:@" Grade;w"];
    [labelArray addObject:@" Length (dm);b"];
    [labelArray addObject:@" Top (R);b"];
    [labelArray addObject:@" Butt (R);b"];
    [labelArray addObject:@" Decay;b"];
    [labelArray addObject:@" Far End;o"];
    [labelArray addObject:@" Add Length;o"];
    [labelArray addObject:@" Comment Code;w"];
    [labelArray addObject:@" User Code;w"];
    [labelArray addObject:@" Note;w"];
    
    //width for each column is 47
    int locationCounter = -48;
    //int alterCounter = 0;
    for (NSString *lbStr in labelArray){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter, 88, 140, 45)];
        lbl.text = [lbStrAry objectAtIndex:0];
        
        if ([[lbStrAry objectAtIndex:1] isEqualToString:@"g"]){
            lbl.backgroundColor = [UIColor piecesHeaderGreen];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"b"]){
            lbl.backgroundColor = [UIColor piecesHeaderBlue];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"o"]) {
            lbl.backgroundColor = [UIColor piecesHeaderOrange];
        }
        
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        lbl.transform = CGAffineTransformMakeRotation(-M_PI_2);
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lbl];
        
        locationCounter = locationCounter + 43;
        //  alterCounter = alterCounter + 1;
    }
    

    if(userCreated){
        
        // create last two column with width 70
        UILabel *lblSurvey = [[UILabel alloc] initWithFrame:CGRectMake(885, 61, 140, 100)];  
        lblSurvey.text = @" Survey (m\u00B3)";
        lblSurvey.backgroundColor = [UIColor piecesHeaderRed];
        lblSurvey.textColor = [UIColor blackColor];
        lblSurvey.highlightedTextColor = [UIColor blackColor];
        lblSurvey.textAlignment = NSTextAlignmentLeft;
        lblSurvey.layer.borderColor = [UIColor blackColor].CGColor;
        lblSurvey.numberOfLines = 0;
        lblSurvey.layer.borderWidth = 1.0;
        lblSurvey.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblSurvey setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lblSurvey];

    }else{
        // create last two column with width 70
        UILabel *lblSurvey = [[UILabel alloc] initWithFrame:CGRectMake(824, 78, 140, 65)];
        lblSurvey.text = @" Survey (m\u00B3) ";
        lblSurvey.backgroundColor = [UIColor piecesHeaderRed];
        lblSurvey.textColor = [UIColor blackColor];
        lblSurvey.highlightedTextColor = [UIColor blackColor];
        lblSurvey.textAlignment = NSTextAlignmentLeft;
        lblSurvey.layer.borderColor = [UIColor blackColor].CGColor;
        lblSurvey.numberOfLines = 0;
        lblSurvey.layer.borderWidth = 1.0;
        lblSurvey.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblSurvey setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lblSurvey];

        UILabel *lblCheck = [[UILabel alloc] initWithFrame:CGRectMake(889, 78, 140, 65)];
        lblCheck.text = @" Check (m\u00B3) ";
        lblCheck.backgroundColor = [UIColor piecesHeaderRed];
        lblCheck.textColor = [UIColor blackColor];
        lblCheck.highlightedTextColor = [UIColor blackColor];
        lblCheck.textAlignment = NSTextAlignmentLeft;
        lblCheck.layer.borderColor = [UIColor blackColor].CGColor;
        lblCheck.numberOfLines = 0;
        lblCheck.layer.borderWidth = 1.0;
        lblCheck.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblCheck setFont:[UIFont systemFontOfSize:20]];
        
        [self addSubview:lblCheck];
    }
    
    
    
    NSMutableArray *labelArray2 = [[NSMutableArray alloc] init];
    
    [labelArray2 addObject:@" Gross Dimensions for\n pieces inside plot ;g;6;5"];
    [labelArray2 addObject:@" Deductions for\n Rot/Holes;b;12;4"];
    [labelArray2 addObject:@" Outside\n Measure ;o;16;2"];
    
    
    for (NSString *lbStr in labelArray2){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        int lbX = [[lbStrAry objectAtIndex:2] intValue] * 43;
        int lbWidth = [[lbStrAry objectAtIndex:3] intValue] * 43;
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(lbX, 0, lbWidth, 42)];
        lbl.text = [lbStrAry objectAtIndex:0];
        
        if ([[lbStrAry objectAtIndex:1] isEqualToString:@"g"]){
            lbl.backgroundColor = [UIColor piecesHeaderGreen];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"b"]){
            lbl.backgroundColor = [UIColor piecesHeaderBlue];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"o"]) {
            lbl.backgroundColor = [UIColor piecesHeaderOrange];
        }
        
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.lineBreakMode = NSLineBreakByCharWrapping;
        lbl.numberOfLines = 0;
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [self addSubview:lbl];
        
        locationCounter = locationCounter + 43;
    }
    

    
    UILabel *lblPieceVolumn = [[UILabel alloc] initWithFrame:CGRectMake(905, 0, 100, 41)];  //mchu March 12, 2019
    lblPieceVolumn.text = @"Piece Vol ";
    lblPieceVolumn.backgroundColor = [UIColor piecesHeaderRed];
    
    lblPieceVolumn.textColor = [UIColor blackColor];
    lblPieceVolumn.highlightedTextColor = [UIColor blackColor];
    lblPieceVolumn.textAlignment = NSTextAlignmentCenter;
    lblPieceVolumn.lineBreakMode = NSLineBreakByCharWrapping;
    lblPieceVolumn.numberOfLines = 0;
    lblPieceVolumn.layer.borderColor = [UIColor blackColor].CGColor;
    lblPieceVolumn.layer.borderWidth = 1.0;
    [lblPieceVolumn setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    
    [self addSubview:lblPieceVolumn];

}

- (void) drawHeaderForVolumeEstimate: (BOOL) userCreated{
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    
    [labelArray addObject:@" Checked;w;y"];
    [labelArray addObject:@" Piece No.;w;y"];
    [labelArray addObject:@" \n\n\n\nSpecies;w;n"];
    [labelArray addObject:@" \n\n\n\nKind;w;n"];
    [labelArray addObject:@" \n\n\n\nClass;w;n"];
    [labelArray addObject:@" \n\n\n\nGrade;w;n"];
    [labelArray addObject:@" \n\n\n\nNote;w;n"];
    [labelArray addObject:@" \n\n\nEstimate \n(m\u00B3/ha);w;n"];
    [labelArray addObject:@" \n\nEstimate \nVolume \n(m\u00B3);w;n"];
    
    //width for each column is 47
    int locationCounter = -48;
    int locaitonCounter2 = 87;
    //int alterCounter = 0;
    for (NSString *lbStr in labelArray){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        
        
        UILabel *lbl = nil;
        if ([[lbStrAry objectAtIndex:2]  isEqualToString:@"y"]){
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter, 88, 140, 45)];
            lbl.transform = CGAffineTransformMakeRotation(-M_PI_2);
            lbl.textAlignment = NSTextAlignmentLeft;
            
            locationCounter = locationCounter + 43;
        }else{
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locaitonCounter2, 41, 100, 140)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 6;
            lbl.contentMode = UIViewContentModeBottom;
            locaitonCounter2 = locaitonCounter2 + 100;
        }
        
        lbl.text = [lbStrAry objectAtIndex:0];
        
        if ([[lbStrAry objectAtIndex:1] isEqualToString:@"g"]){
            lbl.backgroundColor = [UIColor piecesHeaderGreen];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"b"]){
            lbl.backgroundColor = [UIColor piecesHeaderBlue];
        }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"o"]) {
            lbl.backgroundColor = [UIColor piecesHeaderOrange];
        }
        
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lbl];
        
        //  alterCounter = alterCounter + 1;
    }
    
    // create last two column with width 70
    if(userCreated){
        
        UILabel *lblSurvey = [[UILabel alloc] initWithFrame:CGRectMake(817, 11, 140, 200)];
        lblSurvey.text = @" Survey (m\u00B3) ";
        lblSurvey.backgroundColor = [UIColor piecesHeaderRed];
        lblSurvey.textColor = [UIColor blackColor];
        lblSurvey.highlightedTextColor = [UIColor blackColor];
        lblSurvey.textAlignment = NSTextAlignmentLeft;
        lblSurvey.layer.borderColor = [UIColor blackColor].CGColor;
        lblSurvey.numberOfLines = 0;
        lblSurvey.layer.borderWidth = 1.0;
        lblSurvey.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblSurvey setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lblSurvey];
    }else{
        
        UILabel *lblSurvey = [[UILabel alloc] initWithFrame:CGRectMake(767, 61, 140, 100)];
        lblSurvey.text = @" Survey (m\u00B3) ";
        lblSurvey.backgroundColor = [UIColor piecesHeaderRed];
        lblSurvey.textColor = [UIColor blackColor];
        lblSurvey.highlightedTextColor = [UIColor blackColor];
        lblSurvey.textAlignment = NSTextAlignmentLeft;
        lblSurvey.layer.borderColor = [UIColor blackColor].CGColor;
        lblSurvey.numberOfLines = 0;
        lblSurvey.layer.borderWidth = 1.0;
        lblSurvey.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblSurvey setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [self addSubview:lblSurvey];
        
        UILabel *lblCheck = [[UILabel alloc] initWithFrame:CGRectMake(867, 61, 140, 100)];
        lblCheck.text = @" Check (m\u00B3) ";
        lblCheck.backgroundColor = [UIColor piecesHeaderRed];
        lblCheck.textColor = [UIColor blackColor];
        lblCheck.highlightedTextColor = [UIColor blackColor];
        lblCheck.textAlignment = NSTextAlignmentLeft;
        lblCheck.layer.borderColor = [UIColor blackColor].CGColor;
        lblCheck.numberOfLines = 0;
        lblCheck.layer.borderWidth = 1.0;
        lblCheck.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [lblCheck setFont:[UIFont systemFontOfSize:20]];
        
        [self addSubview:lblCheck];
    }

    
    
   
    UILabel *lblPieceVolumn = [[UILabel alloc] initWithFrame:CGRectMake(787, 0, 200, 42)];
    lblPieceVolumn.text = @" Volume ";
    lblPieceVolumn.backgroundColor = [UIColor piecesHeaderRed];
    
    lblPieceVolumn.textColor = [UIColor blackColor];
    lblPieceVolumn.highlightedTextColor = [UIColor blackColor];
    lblPieceVolumn.textAlignment = NSTextAlignmentCenter;
    lblPieceVolumn.lineBreakMode = NSLineBreakByCharWrapping;
    lblPieceVolumn.numberOfLines = 0;
    lblPieceVolumn.layer.borderColor = [UIColor blackColor].CGColor;
    lblPieceVolumn.layer.borderWidth = 1.0;
    [lblPieceVolumn setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    
    [self addSubview:lblPieceVolumn];
     
     
}

@end
