//
//  PileEditCheckTableViewCell.h
//  iForWaste
//
//  Created by Sweta Kutty on 2026-03-02.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PileEditTableViewCell.h"
#import "PileTableViewCell.h"

@class WastePile;
@class PileViewController;
@class WasteBlock;
@class WasteStratum;

@interface PileEditCheckTableViewCell : PileTableViewCell
<UIAlertViewDelegate>

@property (weak, nonatomic) PileViewController *pileView;

@property (strong, nonatomic) WastePile *cellWastePile;
@property (strong, nonatomic) WasteBlock *wasteBlock;
@property (strong, nonatomic) WasteStratum *wasteStratum;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@property (strong, nonatomic) NSMutableDictionary *displayObjectDictionary;

-(void)bindCell:(WastePile *)wastePile wasteBlock:(WasteBlock *)wasteBlock wasteStratum:(WasteStratum *)wasteStratum userCreatedBlock:(BOOL)userCreatedBlock;

@end
