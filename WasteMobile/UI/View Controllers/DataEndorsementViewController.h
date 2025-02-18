//
//  DataEndorsementViewController.h
//  WasteMobile
//
//  Created by chrisnesmith on 2023-03-24.
//  Copyright © 2023 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WasteStratum.h"
#import "StratumViewController.h"
#import "WasteBlock.h"
#import "BlockViewController.h"
#import "PlotViewController.h"

@interface DataEndorsementViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *dcSurveyorName;
@property (weak, nonatomic) IBOutlet UITextField *dcDesignation;
@property (weak, nonatomic) IBOutlet UITextField *dcLicenseNumber;
@property (weak, nonatomic) IBOutlet UITextView *dcRationale;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) NSString *endorsementType;

@property (strong, nonatomic) WasteStratum *wasteStratum;
@property (weak, nonatomic) NSNumber *plotNumber;
@property (strong, nonatomic) StratumViewController *stratumVC;

@property (strong, nonatomic) WasteBlock *wasteBlock;
@property (weak, nonatomic) NSNumber *stratumNumber;
@property (strong, nonatomic) BlockViewController *blockVC;

@property (strong, nonatomic) WastePlot *wastePlot;
@property (strong, nonatomic) PlotViewController *plotVC;


@end
