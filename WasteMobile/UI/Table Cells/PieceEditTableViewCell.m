//
//  PieceEditTableViewCell.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-03.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "PieceEditTableViewCell.h"
#import "UIColor+WasteColor.h"
#import "WastePiece.h"
#import "PieceValueTableViewController.h"
#import "PlotViewController.h"
#import "BorderlineCode.h"
#import "ButtEndCode.h"
#import "CommentCode.h"
#import "DecayTypeCode.h"
#import "MaterialKindCode.h"
#import "ScaleGradeCode.h"
#import "ScaleSpeciesCode.h"
#import "TopEndCode.h"
#import "WasteClassCode.h"
#import "CodeDAO.h"
#import "WasteBlock.h"
#import "Constants.h"

@implementation PieceEditTableViewCell

@synthesize cellWastePiece;
@synthesize displayObjectDictionary;

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


-(void)bindCell:(WastePiece *)wastePiece wasteBlock:(WasteBlock *)wasteBlock assessmentMethodCode:(NSString *)assessmentMethodCode userCreatedBlock:(BOOL)userCreatedBlock {
    
    self.cellWastePiece = wastePiece;
    self.wasteBlock = wasteBlock;
    
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    int locationCounter = 43;
   
    if ([assessmentMethodCode isEqualToString:@"P"]){

        [labelArray addObject:@";pieceNumber;w;43;l;"];
        [labelArray addObject:@";pieceBorderlineCode;w;43;b;1"];
        [labelArray addObject:@";pieceScaleSpeciesCode;w;43;b;2"];
        [labelArray addObject:@";pieceMaterialKindCode;w;43;b;3"];
        [labelArray addObject:@";pieceWasteClassCode;w;43;b;4"];
        [labelArray addObject:@";length;g;43;b;5"];
        [labelArray addObject:@";topDiameter;g;43;b;6"];
        [labelArray addObject:@";pieceTopEndCode;g;43;b;7"];
        [labelArray addObject:@";buttDiameter;g;43;b;8"];
        [labelArray addObject:@";pieceButtEndCode;g;43;b;9"];
        [labelArray addObject:@";pieceScaleGradeCode;w;43;b;10"];
        [labelArray addObject:@";lengthDeduction;b;43;b;11"];
        [labelArray addObject:@";topDeduction;b;43;b;12"];
        [labelArray addObject:@";buttDeduction;b;43;b;13"];
        [labelArray addObject:@";pieceDecayTypeCode;b;43;b;14"];
        [labelArray addObject:@";farEnd;o;43;b;15"];
        [labelArray addObject:@";addLength;o;43;b;16"];
        [labelArray addObject:@";pieceCommentCode;w;43;b;17"];
        [labelArray addObject:@";notes;w;44;b;18"];
        if (userCreatedBlock){
            // show current volume for user created block
            [labelArray addObject:@";pieceVolume;r;130;l;"];
        }else{
            [labelArray addObject:@";;r;65;l;"];
            [labelArray addObject:@";pieceVolume;r;65;l;"];
        }
        
    }else if ([assessmentMethodCode isEqualToString:@"S"]){
        
        locationCounter = 47;
        
        [labelArray addObject:@";pieceNumber;w;50;l"];
        [labelArray addObject:@"HE;pieceScaleSpeciesCode;w;50;b;2"];
        [labelArray addObject:@"S;pieceMaterialKindCode;w;50;b;3"];
        [labelArray addObject:@"U;pieceWasteClassCode;w;50;b;4"];
        [labelArray addObject:@"62;length;g;50;b;5"];
        [labelArray addObject:@"15;topDiameter;g;50;b;6"];
        [labelArray addObject:@"C;pieceTopEndCode;g;50;b;7"];
        [labelArray addObject:@"17;buttDiameter;g;50;b;8"];
        [labelArray addObject:@"N;pieceButtEndCode;g;50;b;9"];
        [labelArray addObject:@"U;pieceScaleGradeCode;w;50;b;10"];
        [labelArray addObject:@"15;lengthDeduction;b;50;b;11"];
        [labelArray addObject:@"16;topDeduction;b;50;b;12"];
        [labelArray addObject:@"17;buttDeduction;b;50;b;13"];
        [labelArray addObject:@"S;pieceDecayTypeCode;b;50;b;14"];
        [labelArray addObject:@"IN;pieceCommentCode;w;50;b;17"];
        [labelArray addObject:@"*;notes;w;50;b;18"];

        if (userCreatedBlock){
            [labelArray addObject:@"0.000;pieceVolume;r;143;l"];
        }else{
            [labelArray addObject:@"9.999;;r;71;l"];
            [labelArray addObject:@"0.000;pieceVolume;r;73;l"];
        }
        
    }else if ([assessmentMethodCode isEqualToString:@"E"]){
        
        [labelArray addObject:@";pieceNumber;w;44;l;"];
        [labelArray addObject:@";pieceScaleSpeciesCode;w;120;b;2"];
        [labelArray addObject:@";pieceMaterialKindCode;w;120;b;3"];
        [labelArray addObject:@";pieceWasteClassCode;w;120;b;4"];
        [labelArray addObject:@";pieceScaleGradeCode;w;120;b;10"];
        [labelArray addObject:@";notes;w;120;b;18"];
        [labelArray addObject:@";estimatedPercent;w;120;b;21"];
        
        if (userCreatedBlock){
            [labelArray addObject:@";pieceVolume;r;180;l;"];
        }else{
            [labelArray addObject:@";;r;90;l;"];
            [labelArray addObject:@";pieceVolume;r;90;l;"];
        }
    }else if ([assessmentMethodCode isEqualToString:@"O"]){
        
        [labelArray addObject:@";pieceNumber;w;44;l;"];
        [labelArray addObject:@";pieceScaleSpeciesCode;w;100;b;2"];
        [labelArray addObject:@";pieceMaterialKindCode;w;100;b;3"];
        [labelArray addObject:@";pieceWasteClassCode;w;100;b;4"];
        [labelArray addObject:@";pieceScaleGradeCode;w;100;b;10"];
        [labelArray addObject:@";notes;w;100;b;18"];
        [labelArray addObject:@";densityEstimate;w;100;b;19"];
        [labelArray addObject:@";estimatedVolume;w;100;b;20"];
        
        if (userCreatedBlock){
            [labelArray addObject:@";pieceVolume;r;200;l;"];
        }else{
            [labelArray addObject:@";;r;100;l;"];
            [labelArray addObject:@";pieceVolume;r;100;l;"];
        }
    }
    
    
    //init the display object dictionary if it is not initialized yet
    if (!self.displayObjectDictionary){
        self.displayObjectDictionary = [[NSMutableDictionary alloc] init];
    }
    
    for (NSString *lbStr in labelArray){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        
        int widthInt = [[lbStrAry objectAtIndex:3] intValue];
        float width = [[NSNumber numberWithInt:widthInt] floatValue];
        
        if ([[lbStrAry objectAtIndex:4] isEqualToString:@"l"]){
            UILabel *lbl = nil;
            if ([self.displayObjectDictionary valueForKey:[lbStrAry objectAtIndex:1]]){
                lbl =[self.displayObjectDictionary valueForKey:[lbStrAry objectAtIndex:1]];
            }else{
                lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter, -1, width, 45)];
                [self.displayObjectDictionary setObject:lbl forKey:[lbStrAry objectAtIndex:1]];
            }
            
            if (![[lbStrAry objectAtIndex:1] isEqualToString: @""]){
                if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSString class]]){
                    lbl.text = [wastePiece valueForKey:[lbStrAry objectAtIndex:1]];
                }else if ([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSNumber class]]){
                    lbl.text =[(NSNumber *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] stringValue];
                }
            }
            
            if ([[lbStrAry objectAtIndex:2] isEqualToString:@"g"]){
                lbl.backgroundColor = [UIColor piecesHeaderGreen];
            }else if([[lbStrAry objectAtIndex:2] isEqualToString:@"b"]){
                lbl.backgroundColor = [UIColor piecesHeaderBlue];
            }else if([[lbStrAry objectAtIndex:2] isEqualToString:@"o"]) {
                lbl.backgroundColor = [UIColor piecesHeaderOrange];
            }else if([[lbStrAry objectAtIndex:2] isEqualToString:@"r"]) {
                lbl.backgroundColor = [UIColor piecesHeaderRed];
            }
            
            lbl.textColor = [UIColor blackColor];
            lbl.highlightedTextColor = [UIColor blackColor];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.layer.borderColor = [UIColor blackColor].CGColor;
            lbl.layer.borderWidth = 1.0;
             [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];
            
            [self addSubview:lbl];
            
        }else if([[lbStrAry objectAtIndex:4] isEqualToString: @"b"]){
            UIButton *btn = nil;
            
            if ([self.displayObjectDictionary valueForKey:[lbStrAry objectAtIndex:1]]){
                btn =[self.displayObjectDictionary valueForKey:[lbStrAry objectAtIndex:1]];
            }else{
                btn = [[UIButton alloc] initWithFrame:CGRectMake(locationCounter, -1, width, 45)];
                [self.displayObjectDictionary setObject:btn forKey:[lbStrAry objectAtIndex:1]];
            }
            
            if (![[lbStrAry objectAtIndex:1] isEqualToString: @""]){
                // for now, it only work when the property is string
                
                if ([[lbStrAry objectAtIndex:1] isEqualToString:@"notes"]){
                    if([wastePiece valueForKey:[lbStrAry objectAtIndex:1]]){
                        [btn setTitle: @"*" forState:UIControlStateNormal];
                    }else{
                        [btn setTitle: @"" forState:UIControlStateNormal];
                    }
                }else{
                    //NSLog(@"property name = %@", [lbStrAry objectAtIndex:1]);
                    if ([wastePiece valueForKey:[lbStrAry objectAtIndex:1]]){
                        
                        if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSDecimalNumber class]]){
                            [btn setTitle:[[NSString alloc] initWithFormat:@"%0.1f", [(NSDecimalNumber *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] floatValue]] forState:UIControlStateNormal];
                        }else if ([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSNumber class]]){
                            [btn setTitle:[(NSNumber *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] stringValue] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSString class]]){
                            [btn setTitle:[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[BorderlineCode class]]){
                            [btn setTitle:[(BorderlineCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] borderlineCode] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[ButtEndCode class]]){
                            [btn setTitle:[(ButtEndCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] buttEndCode] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[CommentCode class]]){
                            [btn setTitle:[(CommentCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] commentCode] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[DecayTypeCode class]]){
                            [btn setTitle:[(DecayTypeCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] decayTypeCode] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[MaterialKindCode class]]){
                            [btn setTitle:[(MaterialKindCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] materialKindCode] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[ScaleGradeCode class]]){
                            [btn setTitle:[(ScaleGradeCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] scaleGradeCode] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[ScaleSpeciesCode class]]){
                            [btn setTitle:[(ScaleSpeciesCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] scaleSpeciesCode] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[TopEndCode class]]){
                            [btn setTitle:[(TopEndCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] topEndCode] forState:UIControlStateNormal];
                        }else if([[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[WasteClassCode class]]){
                            [btn setTitle:[(WasteClassCode *)[wastePiece valueForKey:[lbStrAry objectAtIndex:1]] wasteClassCode] forState:UIControlStateNormal];
                        }else{
                            
                        }
                    }else{
                        [btn setTitle:@" " forState:UIControlStateNormal];
                    }
                }
            
            }
            
            
            if ([[lbStrAry objectAtIndex:2] isEqualToString:@"g"]){
                btn.backgroundColor = [UIColor piecesHeaderGreen];
            }else if([[lbStrAry objectAtIndex:2] isEqualToString:@"b"]){
                btn.backgroundColor = [UIColor piecesHeaderBlue];
            }else if([[lbStrAry objectAtIndex:2] isEqualToString:@"o"]) {
                btn.backgroundColor = [UIColor piecesHeaderOrange];
            }else if([[lbStrAry objectAtIndex:2] isEqualToString:@"r"]) {
                btn.backgroundColor = [UIColor piecesHeaderRed];
            }
            
            //populate the initial value for testing purpose
            /*
            if (![[lbStrAry objectAtIndex:0] isEqualToString:@""]){
                [btn setTitle:[lbStrAry objectAtIndex:0] forState:UIControlStateNormal];
            }
            */
            
            //btn.textColor = [UIColor blackColor];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //btn.textAlignment = NSTextAlignmentCenter;
            btn.layer.borderColor = [UIColor blackColor].CGColor;
            btn.layer.borderWidth = 1.0;
            [[btn titleLabel] setFont:[UIFont fontWithName:@"Helvetica" size:18]];
            //set the tag number to identify what field
            if (![[lbStrAry objectAtIndex:5] isEqualToString: @""]){
                btn.tag = [[lbStrAry objectAtIndex:5] intValue];
            }
            
            [btn addTarget:self action:@selector(editActionClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:btn];
        }
        

        
        locationCounter = locationCounter + widthInt;
        //  alterCounter = alterCounter + 1;
    }
}

-(IBAction)editActionClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    PieceValueTableViewController *pvc = [self.plotView.storyboard instantiateViewControllerWithIdentifier:@"PieceLookupPickerViewControllerSID"];
 
    switch (btn.tag) {
        case 1:
            pvc.propertyName = @"pieceBorderlineCode";
            break;
        case 2:
            pvc.propertyName = @"pieceScaleSpeciesCode";
            break;
        case 3:
            pvc.propertyName = @"pieceMaterialKindCode";
            break;
        case 4:
            pvc.propertyName = @"pieceWasteClassCode";
            break;
        case 5:
            pvc.propertyName = @"length";
            break;
        case 6:
            pvc.propertyName = @"topDiameter";
            break;
        case 7:
            pvc.propertyName = @"pieceTopEndCode";
            break;
        case 8:
            pvc.propertyName = @"buttDiameter";
            break;
        case 9:
            pvc.propertyName = @"pieceButtEndCode";
            break;
        case 10:
            pvc.propertyName = @"pieceScaleGradeCode";
            break;
        case 11:
            pvc.propertyName = @"lengthDeduction";
            break;
        case 12:
            pvc.propertyName = @"topDeduction";
            break;
        case 13:
            pvc.propertyName = @"buttDeduction";
            break;
        case 14:
            pvc.propertyName = @"pieceDecayTypeCode";
            break;
        case 15:
            pvc.propertyName = @"farEnd";
            break;
        case 16:
            pvc.propertyName = @"addLength";
            break;
        case 17:
            pvc.propertyName = @"pieceCommentCode";
            break;
        case 18:
            pvc.propertyName = @"notes";
            break;
        case 19:
            pvc.propertyName = @"densityEstimate";
            break;
        case 20:
            pvc.propertyName = @"estimatedVolume";
            break;
        case 21:
            pvc.propertyName = @"estimatedPercent";
            break;
        default:
            break;
    }
   // pvc.title =[NSString stringWithFormat:@"%@ %@", @"(IFOR 205", pvc.title];
    pvc.wastePiece = self.cellWastePiece;
    pvc.wasteBlock = self.wasteBlock;
    pvc.plotVC = self.plotView;
    //pvc.editPieceViewController = self.superview;
  
    //NSLog(@"cell's super view = %@", self.superview);
    
    [self.plotView.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

}

@end
