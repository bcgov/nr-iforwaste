//
//  AggregatePileTableViewCell.h
//  EForWasteBC
//
//  Created by Sweta Kutty on 2020-02-26.
//  Copyright © 2020 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AggregatePileTableViewCell : UITableViewCell

//@property (weak, nonatomic) IBOutlet UITextField *blockId;
//@property (weak, nonatomic) IBOutlet UITextField *cuttingPermit;
//@property (weak, nonatomic) IBOutlet UITextField *license;
//@property (weak, nonatomic) IBOutlet UITextField *measureSample;
//@property (weak, nonatomic) IBOutlet UITextField *totalPile;
//@property (weak, nonatomic) IBOutlet UIButton *viewOrConfirmButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *blockId;
@property (weak, nonatomic) IBOutlet UILabel *cuttingPermit;
@property (weak, nonatomic) IBOutlet UILabel *license;
@property (weak, nonatomic) IBOutlet UILabel *totalPile;
@property (weak, nonatomic) IBOutlet UILabel *measureSample;

@end
