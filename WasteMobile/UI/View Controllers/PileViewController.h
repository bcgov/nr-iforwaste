//
//  PileViewController.h
//  iForWaste
//
//  Created by Sweta Kutty on 2019-03-04.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "SWRevealViewController.h"
#import "CanAutoSave.h"
#import "FooterStatView.h"
#import "PileHeaderView.h"
#import "EFWFooterView.h"

@class WasteBlock, WasteStratum, WastePile, StratumPile;

typedef enum PileAlertTypeCode{
    SavePileEnum = -1,
    NewPileEnum = -2,
    ValidateEnum = -3,
}PileAlertTypeCode;

@interface PileViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, CanAutoSave>
{
    IBOutlet UIScrollView *scrollView;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITextField *plotNumber;
@property (weak, nonatomic) IBOutlet UITextField *returnNumber;
@property (weak, nonatomic) IBOutlet UITextField *surveyorLicence;
@property (weak, nonatomic) IBOutlet UITextField *licence;
@property (weak, nonatomic) IBOutlet UITextField *cuttingPermit;
@property (weak, nonatomic) IBOutlet UITextField *block;
@property (weak, nonatomic) IBOutlet UITextField *assistant;
@property (weak, nonatomic) IBOutlet UITextField *weather;
@property (weak, nonatomic) IBOutlet UITextField *residueSurveyor;
@property (weak, nonatomic) IBOutlet UITextField *surveyDate;
@property (weak, nonatomic) IBOutlet UILabel *isMeasurePlotLabel;
@property (weak, nonatomic) IBOutlet UILabel *isMeasurePlot;
@property (weak, nonatomic) IBOutlet UITextView *note;
@property (weak, nonatomic) IBOutlet UIButton *addPileButton;

@property (weak, nonatomic) IBOutlet UILabel *licenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuttingPermitLabel;
@property (weak, nonatomic) IBOutlet UILabel *blockLabel;

@property (weak, nonatomic) IBOutlet FooterStatView *footerStatView;
@property (weak, nonatomic) IBOutlet EFWFooterView *efwFooterView;
@property (strong, nonatomic) IBOutlet UIView *pickerViewContainer;
@property (weak, nonatomic) IBOutlet PileHeaderView *headerView;

// pickers
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *shapePicker;
// values for spinner
@property (strong, retain) NSArray *pileSizeArray;

@property (weak, nonatomic) IBOutlet UITableView *pileTableView;

@property (weak, nonatomic) IBOutlet UILabel *warningMsg;


@property (strong, nonatomic) WasteBlock *wasteBlock;
@property (strong, nonatomic) WasteStratum *wasteStratum;
@property (strong, nonatomic) WastePile *currentEditingPile;
@property (strong, nonatomic) NSString* currentEditingPileElement;
@property (strong, nonatomic) NSArray *wastePiles;
@property (strong, nonatomic) WastePile *wastePile;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) UITextField *activeTF;
-(IBAction)hideKeyboard:(id)sender;

-(IBAction)savePile:(id)sender;
-(IBAction)addPile:(id)sender;


-(void) removeCurrentPile;
-(void) updateCurrentPileProperty:(WastePile*)wp property:(NSString*)property;

-(void) calculatePileAreaAndVolume:(WastePile *)wastePile srsOrRatio:(NSInteger)ratio;

@end


