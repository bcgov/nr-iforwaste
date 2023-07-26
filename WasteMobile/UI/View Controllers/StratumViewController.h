//
//  StratumViewController.h
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


@class WasteStratum,WasteBlock, AggregateCutblock;

typedef enum StratumAlertTypeCode{
    ValidEnum = -3,
}StratumAlertTypeCode;

@interface StratumViewController : UIViewController
<UIPickerViewDelegate, UIPickerViewDataSource ,UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, CanAutoSave>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITextField *stratumArea;

@property (weak, nonatomic) IBOutlet UITextField *wasteType;
@property (weak, nonatomic) IBOutlet UITextField *harvestMethod;
@property (weak, nonatomic) IBOutlet UITextField *assesmentSize;
@property (weak, nonatomic) IBOutlet UITextField *wasteLevel;
@property (weak, nonatomic) IBOutlet UITextField *predictionPlot;
@property (weak, nonatomic) IBOutlet UITextField *measurePlot;
@property (weak, nonatomic) IBOutlet UITextField *totalPile;
@property (weak, nonatomic) IBOutlet UITextField *measureSample;
@property (weak, nonatomic) IBOutlet UITextField *grade12Percent;
@property (weak, nonatomic) IBOutlet UITextField *grade4Percent;
@property (weak, nonatomic) IBOutlet UITextField *grade5Percent;
@property (weak, nonatomic) IBOutlet UITextField *gradeXPercent;
@property (weak, nonatomic) IBOutlet UITextField *gradeYPercent;
@property (weak, nonatomic) IBOutlet UILabel *wasteTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *harvestMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *wasteLevelLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalPileLabel;
@property (weak, nonatomic) IBOutlet UITextField *areaHa;
@property (weak, nonatomic) IBOutlet UILabel *numOfPlots;
@property (weak, nonatomic) IBOutlet UITextView *notes;
@property (weak, nonatomic) IBOutlet UILabel *surveyAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel *predictionPlotLabel;
@property (weak, nonatomic) IBOutlet UILabel *measurePlotLabel;
@property (weak, nonatomic) IBOutlet UILabel *measureSampleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPlotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *plotHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *grade12Label;
@property (weak, nonatomic) IBOutlet UILabel *grade5Label;
@property (weak, nonatomic) IBOutlet UILabel *grade4Label;
@property (weak, nonatomic) IBOutlet UILabel *gradeXLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradeYLabel;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *downArrowImage;

@property (weak, nonatomic) IBOutlet FooterStatView *footerStatView;
@property (weak, nonatomic) IBOutlet EFWFooterView *efwFooterView;


@property (weak, nonatomic) IBOutlet UIButton *addPlotButton;
@property (weak, nonatomic) IBOutlet UIButton *addRatioPlotButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *addCutblockButton;

@property (strong, nonatomic) UIStoryboardSegue *theSegue;


@property (strong, nonatomic) WasteBlock *wasteBlock;
@property (strong, nonatomic) WasteStratum *wasteStratum;


@property (strong, nonatomic) IBOutlet UITableView *plotTableView;
@property (strong, nonatomic) IBOutlet UITableView *aggregatePlotTableView;
@property (strong, nonatomic) IBOutlet UITableView *aggregatePileTableView;

@property (weak, nonatomic) IBOutlet UIButton *sortPlotNumber;
@property (weak, nonatomic) IBOutlet UIButton *sortLicense;
@property (weak, nonatomic) IBOutlet UIButton *sortCuttingPermit;
@property (weak, nonatomic) IBOutlet UIButton *sortCutblock;

@property (strong, nonatomic) NSString *sortColumn;

// the picker
@property (strong, nonatomic) IBOutlet UIView *pickerViewContainer;


//@property (strong, nonatomic) UIPickerView *stratumTypePicker;
@property (strong, nonatomic) UIPickerView *harvestPicker;
@property (strong, nonatomic) UIPickerView *sizePicker;
@property (strong, nonatomic) UIPickerView *wasteLevelPicker;
@property (strong, nonatomic) UIPickerView *wasteTypePicker;


@property (strong, nonatomic) NSArray *sortedPlots;
@property (strong, nonatomic) NSArray *sortedblocks;

@property (strong, nonatomic) AggregateCutblock *currentAggCutblock;

// pickers values
@property (strong, retain) NSArray *stratumTypeArray;
@property (strong, retain) NSArray *harvestMethodArray;
@property (strong, retain) NSArray *assessmentSizeArray;
@property (strong, retain) NSArray *wasteLevelArray;
@property (strong, retain) NSArray *wasteTypeArray;

-(NSDecimalNumber *)calculateStratumSurveyY;
-(NSDecimalNumber *)calculateStratumSurveyX;
-(NSDecimalNumber *)calculateStratumSurveyNet;
-(NSDecimalNumber *)calculateStratumCheckY;
-(NSDecimalNumber *)calculateStratumCheckX;
-(NSDecimalNumber *)calculateStratumCheckNet;
-(NSDecimalNumber *)calculateStratumDeltaY;
-(NSDecimalNumber *)calculateStratumDeltaX;
-(NSDecimalNumber *)calculateStratumDeltaNet;

-(IBAction)saveStratum:(id)sender;
-(IBAction)generateReport:(id)sender;

@end
