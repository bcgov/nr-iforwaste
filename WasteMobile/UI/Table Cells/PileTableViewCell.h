//
//  PileTableViewCell.h
//  iForWaste
//
//  Created by Sweta Kutty on 2019-03-04.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WastePile, WasteBlock;

@interface PileTableViewCell : UITableViewCell

@property (strong, nonatomic) NSMutableDictionary *displayObjectDictionary;

-(void)bindCell:(WastePile *)wastePile wasteBlock:(WasteBlock *)wasteBlock userCreatedBlock:(BOOL)userCreatedBlock;

@end

