//
//  WasteBlockCellTableViewCell.h
//  WasteMobile
//
//  Created by Salus
//

#import <UIKit/UIKit.h>

@interface WasteBlockCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *unitNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenceNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuttingPermitLabel;
@property (weak, nonatomic) IBOutlet UILabel *blockLabel;
@property (weak, nonatomic) IBOutlet UILabel *timberMarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *exemptedLabel;
@property (weak, nonatomic) IBOutlet UILabel *netAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel *blockStatusLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingWheel;

@property (strong, nonatomic) NSNumber *wasteAssessmentAreaID;

@end
