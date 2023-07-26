//
//  BlockViewController.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "CanAutoSave.h"
#import "FooterStatView.h"
#import "EFWFooterView.h"


@class WasteBlock,WasteStratum;

@interface BlockViewController : UIViewController
    <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, CanAutoSave>
{
    IBOutlet UIScrollView *scrollView;
}


// PASSED DATA
@property (strong, nonatomic) NSArray *searchResult;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

// fields
@property (weak, nonatomic) IBOutlet UITextField *reporintUnitNo;
@property (weak, nonatomic) IBOutlet UITextField *cuttingPermit;
@property (weak, nonatomic) IBOutlet UITextField *cutBlock;
@property (weak, nonatomic) IBOutlet UITextField *licence;

@property (weak, nonatomic) IBOutlet UITextField *location;
@property (weak, nonatomic) IBOutlet UITextField *loggedFrom;
@property (weak, nonatomic) IBOutlet UITextField *loggedTo;

@property (weak, nonatomic) IBOutlet UITextField *loggingCompleteTextField;
@property (weak, nonatomic) IBOutlet UITextField *surveyDate;
@property (weak, nonatomic) IBOutlet UITextField *netArea;

@property (weak, nonatomic) IBOutlet UITextField *npNfArea;
@property (weak, nonatomic) IBOutlet UILabel *checkNetAreaLabel;
@property (weak, nonatomic) IBOutlet UITextField *surveyNetAreaTextField;

@property (weak, nonatomic) IBOutlet UITextField *maturity;
@property (weak, nonatomic) IBOutlet UILabel *maturityLabel;
@property (weak, nonatomic) IBOutlet UITextField *checkMaturity;
@property (weak, nonatomic) IBOutlet UILabel *checkMaturityLabel;

@property (weak, nonatomic) IBOutlet UITextField *returnNumber;
@property (weak, nonatomic) IBOutlet UITextField *surveyorLicence;

@property (weak, nonatomic) IBOutlet UITextField *scalerLicence;
@property (weak, nonatomic) IBOutlet UITextView *notation;

@property (weak, nonatomic) IBOutlet FooterStatView *footerStatView;
@property (weak, nonatomic) IBOutlet EFWFooterView *efwFooterView;

@property (strong, nonatomic) NSArray *sortedStratums;
@property (weak, nonatomic) IBOutlet UILabel *interiorCedarMaturityLabel;
@property (weak, nonatomic) IBOutlet UITextField *interiorCedarMaturity;


@property (strong, nonatomic) IBOutlet UIView *pickerViewContainer;
// picker
@property (strong, nonatomic) UIPickerView *snowPicker;
@property (strong, nonatomic) UIPickerView *surveyReasonPicker;
@property (strong, nonatomic) UIPickerView *checkMaturityPicker;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *interiorCedarMaturityPicker;

@property (weak, nonatomic) IBOutlet UITextField *surveyReasonCode;

@property (strong, retain) NSArray *snowCodeArray;
@property (strong, retain) NSArray *surveyReasonCodeArray;
@property (strong, retain) NSArray *maturityCodeArray;
@property (strong, retain) NSArray *siteCodeArray;
@property (strong, retain) NSArray *interiorCedarMaturityCodeArray;

@property (strong, nonatomic) IBOutlet UITableView *stratumTableView;
@property (strong, nonatomic) IBOutlet UITableView *timbermarkTableView;

@property (strong, nonatomic) IBOutlet UILabel *warningStratumArea;
@property (strong, nonatomic) IBOutlet UILabel *warningStratumInvalid;
@property (strong, nonatomic) IBOutlet UILabel *checkerLabel;

@property (strong, nonatomic) IBOutlet UILabel *timbermarkVolumeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timbermarkVBenchmarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;


// WASTE CHECKER
@property (weak, nonatomic) IBOutlet UITextField *wasteCheckerName;
@property (weak, nonatomic) IBOutlet UITextField *professionalDesignation;
@property (weak, nonatomic) IBOutlet UITextField *registrationNumber;
@property (weak, nonatomic) IBOutlet UITextField *position;

// NOTES
@property (weak, nonatomic) IBOutlet UITextView *notes;

// Export User Data Prompt Fields
@property (weak, nonatomic) IBOutlet UITextField *telephoneNumber;

@property (strong, nonatomic) IBOutlet UIButton *addStratumButton;
@property (weak, nonatomic) IBOutlet UITextField *benchmarkField;


// Footer Bar Buttons
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteCutBlockButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *generateXMLButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *generateEFWButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reportButton;

@property (strong, nonatomic) UIStoryboardSegue *theSegue;
@property (strong, nonatomic) WasteBlock *wasteBlock;

@property (strong, nonatomic) IBOutlet UILabel *cpCutblockLabel;
@property (strong, nonatomic) IBOutlet UILabel *licenceLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *loggedFromLabel;
@property (strong, nonatomic) IBOutlet UILabel *loggedToLabel;
@property (strong, nonatomic) IBOutlet UILabel *loggingCompleteLabel;

@property (weak, nonatomic) IBOutlet UIButton *editTimbermarkButton;

- (IBAction)doneClicked:(id)sender;
- (IBAction)showPicker:(id)sender;
- (IBAction)saveBlock:(id)sender;
- (IBAction)generateReport:(id)sender;
- (IBAction)deleteBlock:(id)sender;
- (IBAction)addStratum:(id)sender;
- (IBAction)exportCutBlock:(id)sender;
- (IBAction)generateXML:(id)sender;
- (IBAction)generateEFW:(id)sender;

-(NSDecimalNumber *)calculateBlockSurveyY;
-(NSDecimalNumber *)calculateBlockSurveyX;
-(NSDecimalNumber *)calculateBlockSurveyNet;
-(NSDecimalNumber *)calculateBlockCheckY;
-(NSDecimalNumber *)calculateBlockCheckX;
-(NSDecimalNumber *)calculateBlockCheckNet;
-(NSDecimalNumber *)calculateBlockDeltaY;
-(NSDecimalNumber *)calculateBlockDeltaX;
-(NSDecimalNumber *)calculateBlockDeltaNet;

@end
