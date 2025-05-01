//
//  PieceTableViewCell.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-12.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "PieceTableViewCell.h"
#import "UIColor+WasteColor.h"
#import "WastePiece.h"
#import "BorderlineCode.h"
#import "ButtEndCode.h"
#import "CommentCode.h"
#import "DecayTypeCode.h"
#import "MaterialKindCode.h"
#import "ScaleGradeCode.h"
#import "ScaleSpeciesCode.h"
#import "TopEndCode.h"
#import "WasteClassCode.h"
#import "CheckerStatusCode.h"
#import "WasteBlock.h"
#import "WastePlot.h"
#import "WasteStratum.h"
#import "AssessmentMethodCode.h"

@implementation PieceTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(void)bindCell:(WastePiece *)wastePiece wasteBlock:(WasteBlock *)wasteBlock assessmentMethodCode:(NSString *)assessmentMethodCode userCreatedBlock:(BOOL)userCreatedBlock{
-(void)bindCell:(WastePiece *)wastePiece wasteBlock:(WasteBlock *)wasteBlock wastePlot:(WastePlot *)wastePlot userCreatedBlock:(BOOL)userCreatedBlock{
    
    NSDecimalNumberHandler *behaviorD3 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];

    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    int locationCounter = 43;
    
    NSString *assessmentMethodCode =  wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode;
    if ([assessmentMethodCode isEqualToString:@"P"]){
        
        [labelArray addObject:@";pieceNumber;w;43"];
        [labelArray addObject:@"B;pieceBorderlineCode;w;43"];
        [labelArray addObject:@"HE;pieceScaleSpeciesCode;w;43"];
        [labelArray addObject:@"S;pieceMaterialKindCode;w;43"];
        [labelArray addObject:@"U;pieceWasteClassCode;w;43"];
        [labelArray addObject:@"62;length;g;43"];
        [labelArray addObject:@"15;topDiameter;g;43"];
        [labelArray addObject:@"C;pieceTopEndCode;g;43"];
        [labelArray addObject:@"17;buttDiameter;g;43"];
        [labelArray addObject:@"N;pieceButtEndCode;g;43"];
        [labelArray addObject:@"U;pieceScaleGradeCode;w;43"];
        [labelArray addObject:@"15;lengthDeduction;b;43"];
        [labelArray addObject:@"16;topDeduction;b;43"];
        [labelArray addObject:@"17;buttDeduction;b;43"];
        [labelArray addObject:@"S;pieceDecayTypeCode;b;43"];
        [labelArray addObject:@"11;farEnd;o;43"];
        [labelArray addObject:@"20;addLength;o;43"];
        [labelArray addObject:@"IN;pieceCommentCode;w;43"];
        [labelArray addObject:@"*;notes;w;44"];
        [labelArray addObject:@"9.999;pieceVolume;r;65"];
        [labelArray addObject:@"0.000;;r;65"];
 
    }else if ([assessmentMethodCode isEqualToString:@"S"]){
        locationCounter = 47;
    
        [labelArray addObject:@";pieceNumber;w;50"];
        [labelArray addObject:@"HE;pieceScaleSpeciesCode;w;50"];
        [labelArray addObject:@"S;pieceMaterialKindCode;w;50"];
        [labelArray addObject:@"U;pieceWasteClassCode;w;50"];
        [labelArray addObject:@"62;length;g;50"];
        [labelArray addObject:@"15;topDiameter;g;50"];
        [labelArray addObject:@"C;pieceTopEndCode;g;50"];
        [labelArray addObject:@"17;buttDiameter;g;50"];
        [labelArray addObject:@"N;pieceButtEndCode;g;50"];
        [labelArray addObject:@"U;pieceScaleGradeCode;w;50"];
        [labelArray addObject:@"15;lengthDeduction;b;50"];
        [labelArray addObject:@"16;topDeduction;b;50"];
        [labelArray addObject:@"17;buttDeduction;b;50"];
        [labelArray addObject:@"S;pieceDecayTypeCode;b;50"];
        [labelArray addObject:@"IN;pieceCommentCode;w;50"];
        [labelArray addObject:@"*;notes;w;50"];
        [labelArray addObject:@"9.999;pieceVolume;r;71"];
        [labelArray addObject:@"0.000;;r;73"];
        
    }else if ([assessmentMethodCode isEqualToString:@"E"]){
    
        [labelArray addObject:@";pieceNumber;w;44;l;"];
        [labelArray addObject:@";pieceScaleSpeciesCode;w;120;b;2"];
        [labelArray addObject:@";pieceMaterialKindCode;w;120;b;3"];
        [labelArray addObject:@";pieceWasteClassCode;w;120;b;4"];
        [labelArray addObject:@";pieceScaleGradeCode;w;120;b;10"];
        [labelArray addObject:@";notes;w;120;b;18"];
        [labelArray addObject:@";estimatedPercent;w;120;b;21"];
        [labelArray addObject:@";pieceVolume;r;90;l;"];
        [labelArray addObject:@";checkPieceVolume;r;90;l;"];
        
    }else if ([assessmentMethodCode isEqualToString:@"O"]){

        [labelArray addObject:@";pieceNumber;w;44;l;"];
        [labelArray addObject:@";pieceScaleSpeciesCode;w;100;b;2"];
        [labelArray addObject:@";pieceMaterialKindCode;w;100;b;3"];
        [labelArray addObject:@";pieceWasteClassCode;w;100;b;4"];
        [labelArray addObject:@";pieceScaleGradeCode;w;100;b;10"];
        [labelArray addObject:@";notes;w;100;b;18"];
        [labelArray addObject:@";densityEstimate;w;100;b;19"];
        [labelArray addObject:@";estimatedVolume;w;100;b;20"];
        [labelArray addObject:@";pieceVolume;r;100;l;"];
        [labelArray addObject:@";;r;100;l;"];

    }
    
    if (!self.displayObjectDictionary){
        self.displayObjectDictionary = [[NSMutableDictionary alloc] init];
    }

    for (NSString *lbStr in labelArray){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        
        int lbWidthInt = [[lbStrAry objectAtIndex:3] intValue];
        float lbWidth = [[NSNumber numberWithInt:lbWidthInt] floatValue];
        
        //UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter, -1, lbWidth, 45)];
        UILabel *lbl = nil;
        if ([self.displayObjectDictionary valueForKey:[lbStrAry objectAtIndex:1]]){
            lbl =[self.displayObjectDictionary valueForKey:[lbStrAry objectAtIndex:1]];
        }else{
            lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter, -1, lbWidth, 45)];
            [self.displayObjectDictionary setObject:lbl forKey:[lbStrAry objectAtIndex:1]];
        }
        
        if (![[lbStrAry objectAtIndex:1] isEqualToString: @""]){
            // for now, it only work when the property is string

            if ([wastePiece valueForKey:[lbStrAry objectAtIndex:1]]){
                if ([[lbStrAry objectAtIndex:1] isEqualToString:@"notes"]){
                    if([wastePiece valueForKey:[lbStrAry objectAtIndex:1]]){
                        lbl.text = @"*";
                    }
                }else
                
                // Insert placeholder of "*" if something exists in UserCode column
                if ([[lbStrAry objectAtIndex:1] isEqualToString:@"usercode"]){
                    if([wastePiece valueForKey:[lbStrAry objectAtIndex:1]]){
                        lbl.text = @"*";
                    }
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"checkPieceVolume"]){
                    NSLog(@"checkStatusCode: %@", ((CheckerStatusCode *)[wastePiece valueForKey:@"pieceCheckerStatusCode"]).checkerStatusCode);
                    
                    //for non-changed piece, show blank in the check piece valume
                    if([((CheckerStatusCode *)[wastePiece valueForKey:@"pieceCheckerStatusCode"]).checkerStatusCode isEqualToString:@"4"]){
                        lbl.text = @"";
                    }else{
                        if(![wastePlot.checkVolume isEqualToNumber:wastePlot.plotEstimatedVolume]) {
                            double estimatedPercent = [[wastePiece valueForKey: @"estimatedPercent"] floatValue] / 100.0;
                            NSDecimalNumber *percentEstimate = [[NSDecimalNumber alloc] initWithDouble:estimatedPercent];
                            NSDecimalNumber *checkVolume = [NSDecimalNumber decimalNumberWithDecimal:[wastePlot.checkVolume decimalValue]];
                            lbl.text = [[[percentEstimate decimalNumberByMultiplyingBy:checkVolume] decimalNumberByRoundingAccordingToBehavior:behaviorD3] stringValue];
                        } else {
                            lbl.text = [[wastePiece valueForKey:@"pieceVolume"] stringValue] ;
                        }
                    }
                }else{
                    if ([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSNumber class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ?[(NSNumber *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] stringValue] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSString class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [wastePiece valueForKey:[lbStrAry objectAtIndex:1]]: @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSDecimalNumber class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [[NSString alloc] initWithFormat:@"%0.4f", [(NSDecimalNumber *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] floatValue]] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[BorderlineCode class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [(BorderlineCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] borderlineCode] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[ButtEndCode class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [(ButtEndCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] buttEndCode] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[CommentCode class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [(CommentCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] commentCode] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[DecayTypeCode class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [(DecayTypeCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] decayTypeCode] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[MaterialKindCode class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [(MaterialKindCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] materialKindCode] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[ScaleGradeCode class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [(ScaleGradeCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] scaleGradeCode] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[ScaleSpeciesCode class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [(ScaleSpeciesCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] scaleSpeciesCode] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[TopEndCode class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [(TopEndCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] topEndCode] : @"";
                    }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[WasteClassCode class]]){
                        lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]] ? [(WasteClassCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] wasteClassCode] : @"";
                    }else{
                        
                    }
                }
            }else{
                lbl.text = @"";
            }
        }
        
        //NSLog(@" column: %@, object value: %@, label text: %@ ",[lbStrAry objectAtIndex:1], [wastePiece valueForKey:[lbStrAry objectAtIndex:1]], lbl.text );
        
        if ([[lbStrAry objectAtIndex:2] isEqualToString:@"g"]){
            lbl.backgroundColor = [UIColor piecesHeaderGreen];
        }else if([[lbStrAry objectAtIndex:2] isEqualToString:@"b"]){
            lbl.backgroundColor = [UIColor piecesHeaderBlue];
        }else if([[lbStrAry objectAtIndex:2] isEqualToString:@"o"]) {
            lbl.backgroundColor = [UIColor piecesHeaderOrange];
        }else if([[lbStrAry objectAtIndex:2] isEqualToString:@"r"]) {
            lbl.backgroundColor = [UIColor piecesHeaderRed];
        }else{
            lbl.backgroundColor = [UIColor whiteColor];
        }
        
        //populate the initial value for testing purpose
        /*
        if (![[lbStrAry objectAtIndex:0] isEqualToString:@""]){
            if (![wastePiece.pieceNumber isEqualToString:@"5"]){
                lbl.text = [lbStrAry objectAtIndex:0];
            }
        }
         */
        
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.layer.borderColor = [UIColor blackColor].CGColor;
        lbl.layer.borderWidth = 1.0;
        
        [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];

        //DO NOT use mark, it makes scrolling lag for some reason
       // UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lbl.frame.size.width , 45)];
       // mask.backgroundColor = [UIColor blackColor];
       // lbl.layer.mask = mask.layer;

        
        [self addSubview:lbl];
        
        locationCounter = locationCounter + lbWidthInt;
        //  alterCounter = alterCounter + 1;
    }
}

@end
