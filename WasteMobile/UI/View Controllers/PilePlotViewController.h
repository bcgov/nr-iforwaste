//
//  PilePlotViewController.h
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

@class WasteBlock, WastePlot, WastePiece, WastePile;

typedef enum PileAlertTypeCode{
    SavePileEnum = -1,
    NewPileEnum = -2,
    ValidateEnum = -3,
}PileAlertTypeCode;

@interface PilePlotViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, CanAutoSave>
{
    IBOutlet UIScrollView *scrollView;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITextField *plotNumber;
@property (weak, nonatomic) IBOutlet UITextField *measurePercent;
@property (weak, nonatomic) IBOutlet UITextField *baseline;
@property (weak, nonatomic) IBOutlet UITextField *shape;
@property (weak, nonatomic) IBOutlet UITextField *strip;
@property (weak, nonatomic) IBOutlet UITextField *sizeField;
@property (weak, nonatomic) IBOutlet UITextField *returnField;
@property (weak, nonatomic) IBOutlet UITextField *surveyorLicence;
@property (weak, nonatomic) IBOutlet UITextField *residueSurveyor;
@property (weak, nonatomic) IBOutlet UITextField *perdictionSample;
@property (weak, nonatomic) IBOutlet UITextField *measureSamples;
@property (weak, nonatomic) IBOutlet UITextField *weather;
@property (weak, nonatomic) IBOutlet UILabel *sampleInterval;
@property (weak, nonatomic) IBOutlet UITextField *surveyDate;
@property (weak, nonatomic) IBOutlet UITextField *assistant;
@property (weak, nonatomic) IBOutlet UILabel *totalPile;
@property (weak, nonatomic) IBOutlet UILabel *pileArea;
@property (weak, nonatomic) IBOutlet UILabel *estPileVolume;
@property (weak, nonatomic) IBOutlet UILabel *pileShapeVolume;
@property (weak, nonatomic) IBOutlet UILabel *sawlog;
@property (weak, nonatomic) IBOutlet UILabel *greenGrade;
@property (weak, nonatomic) IBOutlet UILabel *dryGrade;
@property (weak, nonatomic) IBOutlet UITextView *note;

@property (weak, nonatomic) IBOutlet FooterStatView *footerStatView;
@property (weak, nonatomic) IBOutlet EFWFooterView *efwFooterView;
@property (strong, nonatomic) IBOutlet UIView *pickerViewContainer;
@property (weak, nonatomic) IBOutlet PileHeaderView *headerView;

// pickers
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *shapePicker;
// values for spinner
@property (strong, retain) NSArray *pileSizeArray;
@property (strong, retain) NSArray *pileShapeArray;

@property (weak, nonatomic) IBOutlet UITableView *pileTableView;


@property (strong, nonatomic) WasteBlock *wasteBlock;
@property (strong, nonatomic) WastePlot *wastePlot;
@property (strong, nonatomic) WastePiece *currentEditingPiece;
@property (strong, nonatomic) NSString* currentEditingPieceElement;
@property (strong, nonatomic) NSArray *wastePieces;
@property (strong, nonatomic) WastePile *currentEditingPile;
@property (strong, nonatomic) NSString* currentEditingPileElement;
@property (strong, nonatomic) NSArray *wastePiles;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) UITextField *activeTF;
-(IBAction)hideKeyboard:(id)sender;

-(IBAction)savePile:(id)sender;
-(IBAction)addPile:(id)sender;

/*-(void) initNewPieceProperty:(NSString*)piece_number;*/
-(void) removeCurrentPile;
-(void) updateCurrentPileProperty:(WastePile*)wp property:(NSString*)property;

@end


