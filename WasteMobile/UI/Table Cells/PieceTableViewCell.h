//
//  PieceTableViewCell.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-12.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WastePiece, WasteBlock;

@interface PieceTableViewCell : UITableViewCell
/*
@property (weak, nonatomic) IBOutlet UILabel *checkedLabel;
@property (weak, nonatomic) IBOutlet UILabel *pieceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *borderlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *kindLabel;
@property (weak, nonatomic) IBOutlet UILabel *wasteClassLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthGDLabel;
@property (weak, nonatomic) IBOutlet UILabel *topGDLabel;
@property (weak, nonatomic) IBOutlet UILabel *topEndGDLabel;
@property (weak, nonatomic) IBOutlet UILabel *buttGDLabel;
@property (weak, nonatomic) IBOutlet UILabel *buttEndGDLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthDLabel;
@property (weak, nonatomic) IBOutlet UILabel *topDLabel;
@property (weak, nonatomic) IBOutlet UILabel *buttDLabel;
@property (weak, nonatomic) IBOutlet UILabel *decayDLabel;
@property (weak, nonatomic) IBOutlet UILabel *farEndLabel;
@property (weak, nonatomic) IBOutlet UILabel *addLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *surveyValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkValueLabel;
*/
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@property (strong, nonatomic) NSMutableDictionary *displayObjectDictionary;

-(void)bindCell:(WastePiece *)wastePiece wasteBlock:(WasteBlock *)wasteBlock  assessmentMethodCode:(NSString *)assessmentMethodCode userCreatedBlock:(BOOL)userCreatedBlock;

@end
