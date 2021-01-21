//
//  TimbermarkViewController.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-06.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanAutoSave.h"


@class WasteBlock;


@interface TimbermarkViewController : UIViewController <UIPickerViewDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, CanAutoSave>
{
   // IBOutlet UIScrollView *scrollView;
}
/*
@property (weak, nonatomic) IBOutlet UITextField *timberMarkTxt;
@property (weak, nonatomic) IBOutlet UITextField *areaTxt;
@property (weak, nonatomic) IBOutlet UIDatePicker *loggingCompleteDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *avoidableValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *establishedValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *wrmfValueLbl;
@property (weak, nonatomic) IBOutlet UITextField *coniferTxt;
@property (weak, nonatomic) IBOutlet UILabel *coniferWMRFLbl;
@property (weak, nonatomic) IBOutlet UITextField *deciduousTxt;
@property (weak, nonatomic) IBOutlet UILabel *deciduousWMRFLbl;
@property (weak, nonatomic) IBOutlet UITextField *hembalTxt;
@property (weak, nonatomic) IBOutlet UILabel *hembalWMRFLbl;
@property (weak, nonatomic) IBOutlet UITextField *xTxt;
@property (weak, nonatomic) IBOutlet UILabel *xWMRFLbl;
@property (weak, nonatomic) IBOutlet UITextField *yTxt;
@property (weak, nonatomic) IBOutlet UILabel *yWMRFLbl;
*/




@property BOOL contentOffset;

// received
@property (strong, nonatomic) NSSet *timbermarks;
@property (strong, nonatomic) WasteBlock *wasteBlock;

@property BOOL primaryTimbermarkExists;
@property BOOL secondTimbermarkExists;


// primary timbermark
@property (weak, nonatomic) IBOutlet UILabel *primaryAvoidableALabel;
@property (weak, nonatomic) IBOutlet UILabel *primaryBenchmarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *primaryWMRFLabel;

@property (weak, nonatomic) IBOutlet UITextField *primaryTimbermark;
@property (weak, nonatomic) IBOutlet UITextField *primaryArea;
@property (weak, nonatomic) IBOutlet UITextField *primaryWasteMonetaryReduction;
@property (weak, nonatomic) IBOutlet UITextField *primaryLoggingDate;
    // stumpage column
@property (weak, nonatomic) IBOutlet UITextField *primaryConifer;
@property (weak, nonatomic) IBOutlet UITextField *primaryDeciduous;
@property (weak, nonatomic) IBOutlet UITextField *primaryHembal;
@property (weak, nonatomic) IBOutlet UITextField *primaryXgrade;
@property (weak, nonatomic) IBOutlet UITextField *primaryYgrade;
    // billing column
@property (weak, nonatomic) IBOutlet UILabel *primaryBillingConifer;
@property (weak, nonatomic) IBOutlet UILabel *primaryBillingDeciduous;
@property (weak, nonatomic) IBOutlet UILabel *primaryBillingHembal;
@property (weak, nonatomic) IBOutlet UILabel *primaryBillingXgrade;
@property (weak, nonatomic) IBOutlet UILabel *primaryBillingYgrade;
    // billing label column
@property (weak, nonatomic) IBOutlet UILabel *primaryLabelConifer;
@property (weak, nonatomic) IBOutlet UILabel *primaryLabelDeciduous;
@property (weak, nonatomic) IBOutlet UILabel *primaryLabelHembal;
@property (weak, nonatomic) IBOutlet UILabel *primaryLabelXgrade;
@property (weak, nonatomic) IBOutlet UILabel *primaryLabelYgrade;

// secondary timbermark
@property (weak, nonatomic) IBOutlet UILabel *secondaryAvoidableALabel;
@property (weak, nonatomic) IBOutlet UILabel *secondaryBenchmarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondaryWMRFLabel;

@property (weak, nonatomic) IBOutlet UITextField *secondaryTimbermark;
@property (weak, nonatomic) IBOutlet UITextField *secondaryArea;
@property (weak, nonatomic) IBOutlet UITextField *secondaryWasteMonetaryReduction;
@property (weak, nonatomic) IBOutlet UITextField *secondaryLoggingDate;
    // stumpage column
@property (weak, nonatomic) IBOutlet UITextField *secondaryConifer;
@property (weak, nonatomic) IBOutlet UITextField *secondaryDeciduous;
@property (weak, nonatomic) IBOutlet UITextField *secondaryHembal;
@property (weak, nonatomic) IBOutlet UITextField *secondaryXgrade;
@property (weak, nonatomic) IBOutlet UITextField *secondaryYgrade;
    // billing column
@property (weak, nonatomic) IBOutlet UILabel *secondaryBillingConifer;
@property (weak, nonatomic) IBOutlet UILabel *secondaryBillingDeciduous;
@property (weak, nonatomic) IBOutlet UILabel *secondaryBillingHembal;
@property (weak, nonatomic) IBOutlet UILabel *secondaryBillingXgrade;
@property (weak, nonatomic) IBOutlet UILabel *secondaryBillingYgrade;
   // billing label column
@property (weak, nonatomic) IBOutlet UILabel *secondaryLabelConifer;
@property (weak, nonatomic) IBOutlet UILabel *secondaryLabelDeciduous;
@property (weak, nonatomic) IBOutlet UILabel *secondaryLabelHembal;
@property (weak, nonatomic) IBOutlet UILabel *secondaryLabelXgrade;
@property (weak, nonatomic) IBOutlet UILabel *secondaryLabelYgrade;

// picker view
@property (strong, nonatomic) IBOutlet UIView *pickerViewContainer;
// pickers
@property (strong, nonatomic) UIPickerView *wasteLevelPicker;
@property (strong, nonatomic) UIPickerView *wasteLevelPicker2;
// picker values
@property (strong, retain) NSArray *wasteMonetaryReductionArray;
@property (strong, retain) NSArray *wasteMonetaryReductionArray2;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

//more label for formated text
@property (strong, nonatomic) IBOutlet UILabel *primaryTMA;
@property (strong, nonatomic) IBOutlet UILabel *primaryTMB;
@property (strong, nonatomic) IBOutlet UILabel *secondaryTMA;
@property (strong, nonatomic) IBOutlet UILabel *secondaryTMB;
@property (strong, nonatomic) IBOutlet UILabel *primaryStumpageRate;
@property (strong, nonatomic) IBOutlet UILabel *secondaryStumpageRate;


-(IBAction)saveTimbermark:(id)sender;



@end
