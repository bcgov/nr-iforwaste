//
//  PileEditTableViewCell.m
//  iForWaste
//
//  Created by Sweta Kutty on 2019-03-04.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "PileEditTableViewCell.h"
#import "UIColor+WasteColor.h"
#import "WastePile+CoreDataClass.h"
#import "PileValueTableViewController.h"
#import "PileViewController.h"
#import "PileShapeCode+CoreDataClass.h"
#import "CodeDAO.h"
#import "WasteBlock.h"
#import "Constants.h"
#import "SpeciesPercentViewController.h"

@implementation PileEditTableViewCell

@synthesize cellWastePile;
@synthesize displayObjectDictionary;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindCell:(WastePile *)wastePile wasteBlock:(WasteBlock *)wasteBlock userCreatedBlock:(BOOL)userCreatedBlock {
    
    if([wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:NO] intValue]){
        self.cellWastePile = wastePile;
        self.wasteBlock = wasteBlock;
        NSDecimalNumberHandler *behaviorD2 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:1 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        int locationCounter = 0;
        int total = 0;
        [labelArray addObject:@";pileNumber;w;44;l;1"];
        [labelArray addObject:@";measuredLength;m;111;b;2"];
        [labelArray addObject:@";measuredWidth;m;110;b;3"];
        [labelArray addObject:@";measuredHeight;m;110;b;4"];
        [labelArray addObject:@";pilePileShapeCode;w;110;b;5"];
        [labelArray addObject:@";measuredPileArea;w;110;l;6"];
        [labelArray addObject:@";measuredPileVolume;w;110;l;7"];
        [labelArray addObject:@";;w;110;b;8"];
        [labelArray addObject:@";comment;w;110;b;9"];
        
        
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
                    if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSDecimalNumber class]]){
                        lbl.text = [[NSString alloc] initWithFormat:@"%0.1f", [[(NSDecimalNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] decimalNumberByRoundingAccordingToBehavior:behaviorD2] floatValue]];
                        //[btn setTitle:[[NSString alloc] initWithFormat:@"%0.1f", [(NSDecimalNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] floatValue]] forState:UIControlStateNormal];
                    }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSString class]]){
                        lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]];
                    }else if ([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSNumber class]]){
                        lbl.text =[(NSNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] stringValue];
                    }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[PileShapeCode class]]){
                        lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ? [(PileShapeCode *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] pileShapeCode] : @"";
                    }
                }
                
                if ([[lbStrAry objectAtIndex:1] isEqualToString:@"pileArea"]){
                    lbl.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"pileVolume"]){
                    lbl.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileArea"]) {
                    lbl.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileVolume"]) {
                    lbl.backgroundColor = [UIColor grayColor];
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
                    
                    if ([[lbStrAry objectAtIndex:1] isEqualToString:@"comment"]){
                        if([wastePile valueForKey:[lbStrAry objectAtIndex:1]]){
                            [btn setTitle: @"*" forState:UIControlStateNormal];
                        }else{
                            [btn setTitle: @"" forState:UIControlStateNormal];
                        }
                    }else{
                        //NSLog(@"property name = %@", [lbStrAry objectAtIndex:1]);
                        if ([wastePile valueForKey:[lbStrAry objectAtIndex:1]]){
                            
                            if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSDecimalNumber class]]){
                                [btn setTitle:[[NSString alloc] initWithFormat:@"%0.1f", [(NSDecimalNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] floatValue]] forState:UIControlStateNormal];
                            }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[PileShapeCode class]]){
                                [btn setTitle:[(PileShapeCode *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] pileShapeCode] forState:UIControlStateNormal];
                            }else if ([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSNumber class]]){
                                [btn setTitle:[(NSNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] stringValue] forState:UIControlStateNormal];
                                total += [(NSNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] integerValue];
                            }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSString class]]){
                                [btn setTitle:[wastePile valueForKey:[lbStrAry objectAtIndex:1]] forState:UIControlStateNormal];
                            }else{
                                
                            }
                        }else{
                            [btn setTitle:@" " forState:UIControlStateNormal];
                        }
                    }
                    
                }
                
                if ([[lbStrAry objectAtIndex:1] isEqualToString:@"pileArea"]){
                    btn.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"pileVolume"]){
                    btn.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileArea"]) {
                    btn.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileVolume"]) {
                    btn.backgroundColor = [UIColor grayColor];
                }
                
                if([[lbStrAry objectAtIndex:1] isEqualToString:@""]){
                    total += [wastePile.alPercent intValue] + [wastePile.arPercent intValue] + [wastePile.asPercent intValue] + [wastePile.baPercent intValue] + [wastePile.biPercent intValue] + [wastePile.cePercent intValue] + [wastePile.coPercent intValue] + [wastePile.cyPercent intValue] + [wastePile.fiPercent intValue] + [wastePile.hePercent intValue] + [wastePile.laPercent intValue] + [wastePile.loPercent intValue] + [wastePile.maPercent intValue] + [wastePile.spPercent intValue] + [wastePile.wbPercent intValue] +
                    [wastePile.whPercent intValue] + [wastePile.wiPercent intValue] + [wastePile.uuPercent intValue] + [wastePile.yePercent intValue];
                    
                    [btn setTitle:[NSString stringWithFormat:@"%d", total] forState:UIControlStateNormal];
                     if(total >0 && total != 100){
                        btn.backgroundColor = [UIColor redColor];
                     }else if(total == 100){
                         btn.backgroundColor = [UIColor whiteColor];
                     }
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
                if (btn.tag == 8) {
                    [btn addTarget:self action:@selector(editActionClick1:) forControlEvents:UIControlEventTouchUpInside];
                } else {
                    [btn addTarget:self action:@selector(editActionClick:) forControlEvents:UIControlEventTouchUpInside];
                }
                [self addSubview:btn];
            }
            
            
            locationCounter = locationCounter + widthInt;
            //  alterCounter = alterCounter + 1;
        }
    }else if([wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:YES] intValue]){
        self.cellWastePile = wastePile;
        self.wasteBlock = wasteBlock;
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        int locationCounter = 0;
        int total = 0;
        NSDecimalNumberHandler *behaviorD2 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:1 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        [labelArray addObject:@";pileNumber;w;44;l;1"];
        [labelArray addObject:@";length;e;70;l;2"];
        [labelArray addObject:@";width;e;70;l;3"];
        [labelArray addObject:@";height;e;70;l;4"];
        [labelArray addObject:@";pilePileShapeCode;e;70;l;5"];
        [labelArray addObject:@";pileArea;w;70;l;6"];
        [labelArray addObject:@";pileVolume;w;70;l;7"];
        [labelArray addObject:@";isSample;e;70;l;8"];
        [labelArray addObject:@";measuredLength;m;70;b;9"];
        [labelArray addObject:@";measuredWidth;m;70;b;10"];
        [labelArray addObject:@";measuredHeight;m;70;b;11"];
        [labelArray addObject:@";measuredPileArea;w;70;l;12"];
        [labelArray addObject:@";measuredPileVolume;w;70;l;13"];
        [labelArray addObject:@";;w;70;b;14"];
        [labelArray addObject:@";comment;w;70;b;15"];

        
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
                    if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSDecimalNumber class]]){
                        lbl.text = [[NSString alloc] initWithFormat:@"%0.1f", [[(NSDecimalNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] decimalNumberByRoundingAccordingToBehavior:behaviorD2] floatValue]];
                        //[btn setTitle:[[NSString alloc] initWithFormat:@"%0.1f", [(NSDecimalNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] floatValue]] forState:UIControlStateNormal];
                    }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSString class]]){
                        lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]];
                    }else if ([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSNumber class]]){
                        lbl.text =[(NSNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] stringValue];
                    }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[PileShapeCode class]]){
                        lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ? [(PileShapeCode *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] pileShapeCode] : @"";
                    }
                }
                
                if ([[lbStrAry objectAtIndex:1] isEqualToString:@"pileArea"]){
                    lbl.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"pileVolume"]){
                    lbl.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileArea"]) {
                    lbl.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileVolume"]) {
                    lbl.backgroundColor = [UIColor grayColor];
                }
                if ([[lbStrAry objectAtIndex:1] isEqualToString:@"isSample"]){
                    if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] integerValue] == 1){
                        lbl.text = @"Yes";
                    }else {
                        lbl.text = @"No";
                    }
                    if([lbl.text isEqualToString:@"Yes"]){
                        lbl.backgroundColor = [UIColor colorWithRed:5/255.0 green:180/255.0 blue:66/255.0 alpha:1];
                    }else{
                        lbl.backgroundColor = [UIColor whiteColor];
                    }
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
                    
                    if ([[lbStrAry objectAtIndex:1] isEqualToString:@"comment"]){
                        if([wastePile valueForKey:[lbStrAry objectAtIndex:1]]){
                            [btn setTitle: @"*" forState:UIControlStateNormal];
                        }else{
                            [btn setTitle: @"" forState:UIControlStateNormal];
                        }
                    }else{
                        //NSLog(@"property name = %@", [lbStrAry objectAtIndex:1]);
                        if ([wastePile valueForKey:[lbStrAry objectAtIndex:1]]){
                            
                            if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSDecimalNumber class]]){
                                [btn setTitle:[[NSString alloc] initWithFormat:@"%0.1f", [(NSDecimalNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] floatValue]] forState:UIControlStateNormal];
                            }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[PileShapeCode class]]){
                                [btn setTitle:[(PileShapeCode *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] pileShapeCode] forState:UIControlStateNormal];
                            }else if ([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSNumber class]]){
                                [btn setTitle:[(NSNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] stringValue] forState:UIControlStateNormal];
                                total += [(NSNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] integerValue];
                            }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSString class]]){
                                [btn setTitle:[wastePile valueForKey:[lbStrAry objectAtIndex:1]] forState:UIControlStateNormal];
                            }else{
                                
                            }
                        }else{
                            [btn setTitle:@" " forState:UIControlStateNormal];
                        }
                    }
                    
                }
                
                if ([[lbStrAry objectAtIndex:1] isEqualToString:@"pileArea"]){
                    btn.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"pileVolume"]){
                    btn.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileArea"]) {
                    btn.backgroundColor = [UIColor grayColor];
                }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileVolume"]) {
                    btn.backgroundColor = [UIColor grayColor];
                }
                
                if([[lbStrAry objectAtIndex:1] isEqualToString:@""]){
                    total += [wastePile.alPercent intValue] + [wastePile.arPercent intValue] + [wastePile.asPercent intValue] + [wastePile.baPercent intValue] + [wastePile.biPercent intValue] + [wastePile.cePercent intValue] + [wastePile.coPercent intValue] + [wastePile.cyPercent intValue] + [wastePile.fiPercent intValue] + [wastePile.hePercent intValue] + [wastePile.laPercent intValue] + [wastePile.loPercent intValue] + [wastePile.maPercent intValue] + [wastePile.spPercent intValue] + [wastePile.wbPercent intValue] +
                    [wastePile.whPercent intValue] + [wastePile.wiPercent intValue] + [wastePile.uuPercent intValue] + [wastePile.yePercent intValue];
                    
                     [btn setTitle:[NSString stringWithFormat:@"%d", total] forState:UIControlStateNormal];
                    if(total >0 && total != 100){
                        btn.backgroundColor = [UIColor redColor];
                    }else if (total == 100){
                        btn.backgroundColor = [UIColor whiteColor];
                    }
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
                if([self.cellWastePile.isSample intValue] == 1){
                if (btn.tag == 14) {
                    [btn addTarget:self action:@selector(editActionClick1:) forControlEvents:UIControlEventTouchUpInside];
                    /*NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", total]];
                    [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
                    [btn setAttributedTitle: titleString forState:UIControlStateNormal];*/
                } else if(btn.tag == 9 || btn.tag == 10 || btn.tag == 11)
                {
                    [btn addTarget:self action:@selector(editActionClick3:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    [btn addTarget:self action:@selector(editActionClick2:) forControlEvents:UIControlEventTouchUpInside];
                    if(btn.tag == 9){
                        //NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[self.cellWastePile.measuredLength stringValue]];
                        //[titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
                        //[btn setAttributedTitle: titleString forState:UIControlStateNormal];
                    }
                    if(btn.tag == 10){
                        //NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[self.cellWastePile.measuredWidth stringValue]];
                        //[titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
                        //[btn setAttributedTitle: titleString forState:UIControlStateNormal];
                    }
                    if(btn.tag == 11){
                        //NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[self.cellWastePile.measuredHeight stringValue]];
                        //[titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
                        //[btn setAttributedTitle: titleString forState:UIControlStateNormal];
                    }
                }
                }
                [self addSubview:btn];
            }
            
            
            locationCounter = locationCounter + widthInt;
            //  alterCounter = alterCounter + 1;
        }
    }
}

-(IBAction)editActionClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    PileValueTableViewController *pvc = [self.pileView.storyboard instantiateViewControllerWithIdentifier:@"PileLookupPickerViewControllerSID"];
    
    switch (btn.tag) {
        case 2:
            pvc.propertyName = @"measuredLength";
            break;
        case 3:
            pvc.propertyName = @"measuredWidth";
            break;
        case 4:
            pvc.propertyName = @"measuredHeight";
            break;
        case 5:
            pvc.propertyName = @"pilePileShapeCode";
            break;
        case 9:
            pvc.propertyName = @"comment";
            break;
        default:
            break;
    }
    // pvc.title =[NSString stringWithFormat:@"%@ %@", @"(IFOR 205", pvc.title];
    pvc.wastePile = self.cellWastePile;
    pvc.wasteBlock = self.wasteBlock;
    pvc.pileVC = self.pileView;
    //pvc.editPieceViewController = self.superview;
    
    //NSLog(@"cell's super view = %@", self.superview);
    
    [self.pileView.navigationController pushViewController:pvc animated:YES];
}

-(IBAction)editActionClick2:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if([self.cellWastePile.isSample integerValue] == 1){
        PileValueTableViewController *pvc = [self.pileView.storyboard instantiateViewControllerWithIdentifier:@"PileLookupPickerViewControllerSID"];

        switch (btn.tag) {
            case 9:
                pvc.propertyName = @"measuredLength";
                break;
            case 10:
                pvc.propertyName = @"measuredWidth";
                break;
            case 11:
                pvc.propertyName = @"measuredHeight";
                break;
            case 15:
                pvc.propertyName = @"comment";
                break;
            default:
                break;
        }
        // pvc.title =[NSString stringWithFormat:@"%@ %@", @"(IFOR 205", pvc.title];
        pvc.wastePile = self.cellWastePile;
        pvc.wasteBlock = self.wasteBlock;
        pvc.pileVC = self.pileView;
        //pvc.editPieceViewController = self.superview;
        
        [self.pileView.navigationController pushViewController:pvc animated:YES];
    }
}

-(IBAction)editActionClick1:(id)sender{
    if([self.cellWastePile.isSample integerValue] == 1){
        SpeciesPercentViewController *spv = [self.pileView.storyboard instantiateViewControllerWithIdentifier:@"SpeciesPercentViewControllerSID"];
        
        spv.wastePile = self.cellWastePile;
        spv.wasteBlock = self.wasteBlock;
        spv.pileVC = self.pileView;
        
        [self.pileView.navigationController pushViewController:spv animated:YES];
    }
}

   -(IBAction)editActionClick3:(id)sender{
       if([self.cellWastePile.isSample integerValue] == 1){
           UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Pile Measure"
                                                                          message:@"Please enter your measure for:\n- Length\n- Width\n- Height"
                                                                   preferredStyle:UIAlertControllerStyleAlert];
           
           [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
               textField.placeholder        = NSLocalizedString(@"Length", nil);
               textField.accessibilityLabel = NSLocalizedString(@"Length", nil);
               textField.clearButtonMode    = UITextFieldViewModeAlways;
               textField.keyboardType       = UIKeyboardTypeNumberPad;
               textField.tag                = 8;
               textField.delegate           = self;
           }];
           
           [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
               textField.placeholder        = NSLocalizedString(@"Width", nil);
               textField.accessibilityLabel = NSLocalizedString(@"Width", nil);
               textField.clearButtonMode    = UITextFieldViewModeAlways;
               textField.keyboardType       = UIKeyboardTypeNumberPad;
               textField.tag                = 8;
               textField.delegate           = self;
           }];
           
           [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
               textField.placeholder        = NSLocalizedString(@"Height", nil);
               textField.accessibilityLabel = NSLocalizedString(@"Height", nil);
               textField.clearButtonMode    = UITextFieldViewModeAlways;
               textField.keyboardType       = UIKeyboardTypeNumberPad;
               textField.tag                = 8;
               textField.delegate           = self;
           }];
           UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
               self.cellWastePile.measuredLength = [NSDecimalNumber decimalNumberWithString:alert.textFields[0].text];
               self.cellWastePile.measuredWidth = [NSDecimalNumber decimalNumberWithString:alert.textFields[1].text];
               self.cellWastePile.measuredHeight = [NSDecimalNumber decimalNumberWithString:alert.textFields[2].text];
               [self bindCell:self.cellWastePile wasteBlock:self.wasteBlock userCreatedBlock:self.wasteBlock.userCreated];
                                                            }];
           UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                }];
           
           
           [alert addAction:okAction];
           [alert addAction:cancelAction];
           [self.pileView presentViewController:alert animated:YES completion:nil];
       }
   }

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
          
          // INPUT VALIDATION
          //
          NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
          [str appendString:string];
          NSString *theString = str;
          
          
          NSUInteger newLength = [textField.text length] + [string length] - range.length;
          NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
          NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];

          switch (textField.tag) {
              case 1:
                  return (newLength > 256) ? NO : YES;
                  break;
                  
              case 2:
                  return (newLength > 100) ? NO : YES;
                  break;
                  
              case 3:
              case 5:
                  return (newLength > 10) ? NO : YES;
                  break;
                  
              case 4:
                  for (int i = 0; i < [string length]; i++) {
                      unichar c = [string characterAtIndex:i];
                      if ([myCharSet characterIsMember:c]) {
                          return (newLength > 3) ? NO : YES;
                      }
                  }
                  return [string isEqualToString:@""];
                  break;
              case 6:
                  //skip
                  return YES;
                  
              case 7:
                  return (newLength > 2) ? NO : YES;
                  break;
              case 8:
                  if ([string rangeOfCharacterFromSet:charSet].location != NSNotFound)
                      return NO;
                  else {
                      NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
                      NSArray *arrSep = [newString componentsSeparatedByString:@"."];
                      if([arrSep count] > 2)
                          return NO;
                      else {
                          if([arrSep count] == 1) {
                              if([[arrSep objectAtIndex:0] length] > 3)
                                  return NO;
                              else
                                  return YES;
                          }
                          if([arrSep count] == 2) {
                              if([[arrSep objectAtIndex:0] length] > 3)
                                  return NO;
                              else if([[arrSep objectAtIndex:1] length] > 1)  //Set after dot(.) how many digits you want.I set after dot I want 2 digits.If it goes more than 2 return NO
                                  return NO;
                          }
                          return YES;
                      }
                  }
                  break;
              default:
                  return NO; // NOT EDITABLE
          }
      }

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}


@end
