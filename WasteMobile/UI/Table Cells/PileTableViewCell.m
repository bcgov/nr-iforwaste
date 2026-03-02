//
//  PileTableViewCell.m
//  iForWaste
//
//  Created by Sweta Kutty on 2019-03-04.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "PileTableViewCell.h"
#import "UIColor+WasteColor.h"
#import "WastePile+CoreDataClass.h"
#import "PileShapeCode+CoreDataClass.h"
#import "WasteBlock.h"
#import "MeasuredPileShapeCode+CoreDataClass.h"

@implementation PileTableViewCell

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

-(void)bindCell:(WastePile *)wastePile wasteBlock:(WasteBlock *)wasteBlock wasteStratum:(WasteStratum *)wasteStratum userCreatedBlock:(BOOL)userCreatedBlock{
    
    if([wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:NO] intValue]){
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];NSDecimalNumberHandler *behaviorD2 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:1 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        int locationCounter = 44;
        
        //[labelArray addObject:@";pileNumber;w;44"];
        [labelArray addObject:@";measuredLength;w;110"];
        [labelArray addObject:@";measuredWidth;w;110"];
        [labelArray addObject:@";measuredHeight;w;110"];
        [labelArray addObject:@";pilePileShapeCode;w;110"];
        [labelArray addObject:@";measuredPileArea;w;140"];
        [labelArray addObject:@";measuredPileVolume;w;140"];
        //[labelArray addObject:@"0.000;;w;110"];
        //[labelArray addObject:@"*;comment;w;110"];
        
        
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
                
                if ([wastePile valueForKey:[lbStrAry objectAtIndex:1]]){
                    if ([[lbStrAry objectAtIndex:1] isEqualToString:@"comment"]){
                        if([wastePile valueForKey:[lbStrAry objectAtIndex:1]]){
                            lbl.text = @"*";
                        }
                    }else{
                        if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSDecimalNumber class]]){
                            lbl.text = [[NSString alloc] initWithFormat:@"%0.1f", [[(NSDecimalNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] decimalNumberByRoundingAccordingToBehavior:behaviorD2] floatValue]];
                        }else if ([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSNumber class]]){
                            lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ?[(NSNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] stringValue] : @"";
                        }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSString class]]){
                            lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ? [wastePile valueForKey:[lbStrAry objectAtIndex:1]]: @"";
                        }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[PileShapeCode class]]){
                            lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ? [(PileShapeCode *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] pileShapeCode] : @"";
                        }else{
                            
                        }
                    }
                }else{
                    lbl.text = @"";
                }
            }
            
            //NSLog(@" column: %@, label text: %@ ",[lbStrAry objectAtIndex:1], lbl.text );
            
            if ([[lbStrAry objectAtIndex:1] isEqualToString:@"pileArea"]){
                lbl.backgroundColor = [UIColor grayColor];
            }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"pileVolume"]){
                lbl.backgroundColor = [UIColor grayColor];
            }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileArea"]) {
                lbl.backgroundColor = [UIColor grayColor];
            }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileVolume"]) {
                lbl.backgroundColor = [UIColor grayColor];
            }else{
                lbl.backgroundColor = [UIColor whiteColor];
            }
            
            lbl.textColor = [UIColor blackColor];
            lbl.highlightedTextColor = [UIColor blackColor];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.layer.borderColor = [UIColor blackColor].CGColor;
            lbl.layer.borderWidth = 1.0;
            
            [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];
            
           
            [self addSubview:lbl];
            
            locationCounter = locationCounter + lbWidthInt;
            //  alterCounter = alterCounter + 1;
        }
    }else if([wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:YES] intValue]){
        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        int locationCounter = 0;
        NSDecimalNumberHandler *behaviorD2 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:1 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        
        [labelArray addObject:@";length;e;70"];
        [labelArray addObject:@";width;e;70"];
        [labelArray addObject:@";height;e;70"];
        [labelArray addObject:@";pilePileShapeCode;e;70"];
        [labelArray addObject:@";pileArea;w;105"];
        [labelArray addObject:@";pileVolume;w;105"];
        [labelArray addObject:@";measuredLength;m;70"];
        [labelArray addObject:@";measuredWidth;m;70"];
        [labelArray addObject:@";measuredHeight;m;70"];
        [labelArray addObject:@";pileMeasuredPileShapeCode;e;70"];
        [labelArray addObject:@";measuredPileArea;w;105"];
        [labelArray addObject:@";measuredPileVolume;w;105"];
        //[labelArray addObject:@"0.000;;w;110"];
        //[labelArray addObject:@"*;comment;w;43"];
        
        
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
                
                if ([wastePile valueForKey:[lbStrAry objectAtIndex:1]]){
                    if ([[lbStrAry objectAtIndex:1] isEqualToString:@"comment"]){
                        if([wastePile valueForKey:[lbStrAry objectAtIndex:1]]){
                            lbl.text = @"*";
                        }
                    }else{
                        if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSDecimalNumber class]]){
                           /* lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ? [[NSString alloc] initWithFormat:@"%0.4f", [(NSDecimalNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] floatValue]] : @"";*/
                            lbl.text = [[NSString alloc] initWithFormat:@"%0.1f", [[(NSDecimalNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] decimalNumberByRoundingAccordingToBehavior:behaviorD2] floatValue]];
                        }else if ([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSNumber class]]){
                            lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ?[(NSNumber *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] stringValue] : @"";
                        }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[NSString class]]){
                            lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ? [wastePile valueForKey:[lbStrAry objectAtIndex:1]]: @"";
                        }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[MeasuredPileShapeCode class]]){
                            lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ? [(MeasuredPileShapeCode *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] measuredPileShapeCode] : @"";
                        }else if([[wastePile valueForKey:[lbStrAry objectAtIndex:1]] isKindOfClass:[PileShapeCode class]]){
                            lbl.text = [wastePile valueForKey:[lbStrAry objectAtIndex:1]] ? [(PileShapeCode *)[wastePile valueForKey:[lbStrAry objectAtIndex:1]] pileShapeCode] : @"";
                        }else{
                            
                        }
                    }
                }else{
                    lbl.text = @"";
                }
            }
            
            //NSLog(@" column: %@, label text: %@ ",[lbStrAry objectAtIndex:1], lbl.text );
            
            if ([[lbStrAry objectAtIndex:1] isEqualToString:@"pileArea"]){
                lbl.backgroundColor = [UIColor grayColor];
            }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"pileVolume"]){
                lbl.backgroundColor = [UIColor grayColor];
            }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileArea"]) {
                lbl.backgroundColor = [UIColor grayColor];
            }else if([[lbStrAry objectAtIndex:1] isEqualToString:@"measuredPileVolume"]) {
                lbl.backgroundColor = [UIColor grayColor];
            }else{
                lbl.backgroundColor = [UIColor whiteColor];
            }
            
            lbl.textColor = [UIColor blackColor];
            lbl.highlightedTextColor = [UIColor blackColor];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.layer.borderColor = [UIColor blackColor].CGColor;
            lbl.layer.borderWidth = 1.0;
            
            [lbl setFont:[UIFont fontWithName:@"Helvetica" size:18]];
            
            
            [self addSubview:lbl];
            
            locationCounter = locationCounter + lbWidthInt;
            //  alterCounter = alterCounter + 1;
        }
    }
}

@end
