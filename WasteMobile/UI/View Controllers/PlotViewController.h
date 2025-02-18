//
//  PlotViewController.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "SWRevealViewController.h"
#import "CanAutoSave.h"
#import "FooterStatView.h"
#import "PiecesHeaderView.h"
#import "EFWFooterView.h"

@class WasteBlock, WastePlot, WastePiece;

typedef enum PlotAlertTypeCode{
    SavePlotEnum = -1,
    NewPieceEnum = -2,
    ValidationEnum = -3,
}PlotAlertTypeCode;

@interface PlotViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, CanAutoSave>
{
    IBOutlet UIScrollView *scrollView;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITextField *plotNumber;
@property (weak, nonatomic) IBOutlet UITextField *baseline;
@property (weak, nonatomic) IBOutlet UITextField *size;

@property (weak, nonatomic) IBOutlet UITextField *measurePct;
@property (weak, nonatomic) IBOutlet UITextField *shape;
@property (weak, nonatomic) IBOutlet UITextField *returnNumber;

@property (weak, nonatomic) IBOutlet UITextField *checkMeasurePerc;
@property (weak, nonatomic) IBOutlet UITextField *strip;
@property (weak, nonatomic) IBOutlet UITextField *certificationNumber;

@property (weak, nonatomic) IBOutlet UITextField *licence;
@property (weak, nonatomic) IBOutlet UITextField *cuttingPermit;
@property (weak, nonatomic) IBOutlet UITextField *cutBlock;
@property (weak, nonatomic) IBOutlet UILabel *licenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuttingPermitLabel;
@property (weak, nonatomic) IBOutlet UILabel *cutBlockLabel;

@property (weak, nonatomic) IBOutlet UITextField *residueSurveyor;
@property (weak, nonatomic) IBOutlet UITextField *weather;
@property (weak, nonatomic) IBOutlet UITextField *surveyDate;

@property (weak, nonatomic) IBOutlet UILabel *checkedBy;
@property (weak, nonatomic) IBOutlet UITextField *assistant;
@property (weak, nonatomic) IBOutlet UITextField *checkSurveyDate;

@property (weak, nonatomic) IBOutlet UITextView *notes;

@property (weak, nonatomic) IBOutlet FooterStatView *footerStatView;
@property (weak, nonatomic) IBOutlet EFWFooterView *efwFooterView;


@property (weak, nonatomic) IBOutlet UITextField *measurePctUser;
@property (weak, nonatomic) IBOutlet UITextField *plotArea;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *plotEstimatedVolumeLabel;
@property (weak, nonatomic) IBOutlet UITextField *plotEstimatedVolume;

@property (weak, nonatomic) IBOutlet UILabel *totalEstimatedVolumeLabel;
@property (weak, nonatomic) IBOutlet UITextField *totalEstimateVolume;
@property (weak, nonatomic) IBOutlet UILabel *surveyTotalEstimateVolume;
@property (weak, nonatomic) IBOutlet UILabel *checkSurveyDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkMeasureLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkByLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalCheckPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCheckPercent;

@property (weak, nonatomic) IBOutlet UILabel *isMeasurePlotLabel;
@property (weak, nonatomic) IBOutlet UITextField *isMeasurePlot;
@property (weak, nonatomic) IBOutlet UILabel *greenVolumeLabel;
@property (weak, nonatomic) IBOutlet UITextField *greenVolume;
@property (weak, nonatomic) IBOutlet UILabel *dryVolumeLabel;
@property (weak, nonatomic) IBOutlet UITextField *dryVolume;
@property (weak, nonatomic) IBOutlet UILabel *predictionOnlyWarningLabel;

@property (strong, nonatomic) IBOutlet PiecesHeaderView *headerView;

// spinner for fields
@property (strong, nonatomic) IBOutlet UIView *pickerViewContainer;

// pickers
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *shapePicker;

// values for spinner
@property (strong, retain) NSArray *plotSizeArray;
@property (strong, retain) NSArray *plotShapeArray;

// redundant
//@property (weak, nonatomic) IBOutlet UITextView *tiePoint;
//@property (weak, nonatomic) IBOutlet UITextField *location;

// Text field for piece duplication popup
@property (strong, nonatomic) IBOutlet UITextField *numberOfDuplicatePieces;

@property (strong, nonatomic) IBOutlet UITableView *pieceTableView;

@property (strong, nonatomic) WasteBlock *wasteBlock;
@property (strong, nonatomic) WastePlot *wastePlot;
@property (strong, nonatomic) WastePiece *currentEditingPiece;
@property (strong, nonatomic) NSString* currentEditingPieceElement;
@property (strong, nonatomic) NSArray *wastePieces;

@property (weak, nonatomic) UITextField *activeTF;

@property (strong, nonatomic) NSNumber *originalMP;
@property (strong, nonatomic) NSNumber *fromBackButton;


-(IBAction)hideKeyboard:(id)sender;

-(IBAction)savePlot:(id)sender;
-(IBAction)addNewPiece:(id)sender;
-(IBAction)changePieceStatus:(id)sender;

-(void) updateCheckTotalPercent;
-(void) initNewPieceProperty:(NSString*)piece_number;
-(void) removeCurrentPiece;
-(void) updateCurrentPieceProperty:(WastePiece*)wp property:(NSString*)property;


@end

