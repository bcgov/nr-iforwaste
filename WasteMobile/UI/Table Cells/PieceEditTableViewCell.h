//
//  PieceEditTableViewCell.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-03.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieceTableViewCell.h"

@class WastePiece;
@class PlotViewController;
@class WasteBlock;

@interface PieceEditTableViewCell : PieceTableViewCell
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) PlotViewController *plotView;

@property (strong, nonatomic) WastePiece *cellWastePiece;
@property (strong, nonatomic) WasteBlock *wasteBlock;

@property (strong, nonatomic) NSMutableDictionary *displayObjectDictionary;

-(void)bindCell:(WastePiece *)wastePiece wasteBlock:(WasteBlock *)wasteBlock assessmentMethodCode:(NSString *)assessmentMethodCode userCreatedBlock:(BOOL)userCreatedBlock;

@end
