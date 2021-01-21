//
//  CreatedTableViewCell.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-03.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreatedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *unitNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenceNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuttingPermitLabel;
@property (weak, nonatomic) IBOutlet UILabel *blockLabel;
@property (weak, nonatomic) IBOutlet UILabel *timberMarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *exemptedLabel;
@property (weak, nonatomic) IBOutlet UILabel *netAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel *entryDateLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingWheel;

@property (strong, nonatomic) NSNumber *wasteAssessmentAreaID;

@end
