//
//  BlockViewController.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "BlockViewController.h"
#import "TimbermarkViewController.h"
#import "TimbermarkTableViewCell.h"
#import "StratumTableViewCell.h"
#import "Timbermark.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "CheckSummaryReport.h"
#import "CodeDAO.h"
#import "MaturityCode.h"
#import "SnowCode.h"
#import "SearchResultDTO.h"
#import "WasteStratum.h"
#import "StratumTypeCode.h"
#import "StratumViewController.h"
#import "HarvestMethodCode.h"
#import "WasteTypeCode.h"
#import "WasteLevelCode.h"
#import "WastePlot.h"
#import "PlotSizeCode.h"
#import "ShapeCode.h"
#import "MonetaryReductionFactorCode.h"
#import "ReportGeneratorTableViewController.h"
#import "Timer.h"
#import "WasteCalculator.h"
#import "UIColor+WasteColor.h"
#import "DownloadedTableViewController.h"
#import "LoginViewController.h"
#import "AssessmentMethodCode.h"
#import "WelcomeViewController.h"
#import "SidebarViewController.h"
#import "CreatedTableViewController.h"
#import "XMLExportGenerator.h"
#import "Constants.h"
#import "SiteCode+CoreDataClass.h"
#import "WasteBlockDAO.h"
#import "ExportUserDataDAO.h"
#import "ExportUserData+CoreDataClass.h"
#import "WastePlotValidator.h"
#import "InteriorCedarMaturityCode+CoreDataClass.h"
#import "PlotSampleGenerator.h"
#import "WastePiece.h"
#import "ScaleSpeciesCode.h"
#import "ScaleGradeCode.h"
#import "WasteClassCode.h"
#import "MaterialKindCode.h"
#import "DataEndorsementViewController.h"

@class UIAlertView;

@interface BlockViewController ()

//@property (strong, nonatomic) IBOutlet UIPickerView *surveyReasonPicker;
//@property (strong, nonatomic) IBOutlet UIPickerView *snowPicker;

@property (weak) NSMutableArray *targetBlocks;

@end

@implementation BlockViewController

@synthesize snowCodeArray, maturityCodeArray;
@synthesize loggingCompleteTextField;
@synthesize stratumTableView, timbermarkTableView;
@synthesize wasteBlock;
@synthesize searchResult;
@synthesize versionLabel;


static NSString *const ADD_STRATIM_TITLE = @"Add New Stratum";
static NSString *const STANDING_TREE_TYPE_TITLE = @"Standing Tree";
static NSString *const STANDARD_STRATUM = @"Create Standard Stratum";
static NSString *const STANDING_TREE = @"Create Standing Tree";
static NSString *const STRE = @"(STRE) Percent Estimate";
static NSString *const STRS = @"(STRS) 100% Scale";

NSDate *orignialDate;

UITextField *activeTextField;

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void) setupLists{
    
    NSSortDescriptor *sortSnow = [[NSSortDescriptor alloc ] initWithKey:@"snowCode" ascending:YES];
    NSSortDescriptor *sortMaturity = [[NSSortDescriptor alloc ] initWithKey:@"maturityCode" ascending:YES];
    NSSortDescriptor *sortSite = [[NSSortDescriptor alloc ] initWithKey:@"siteCode" ascending:YES];
    NSSortDescriptor *sortInteriorCedarMaturity = [[NSSortDescriptor alloc ] initWithKey:@"interiorCedarCode" ascending:NO];
    
    self.snowCodeArray = [[[CodeDAO sharedInstance] getSnowCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortSnow]];
    self.maturityCodeArray = [[[CodeDAO sharedInstance] getMaturityCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortMaturity]];
    self.siteCodeArray = [[[CodeDAO sharedInstance] getSiteCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortSite]];
    self.interiorCedarMaturityCodeArray = [[[CodeDAO sharedInstance] getInteriorCedarMaturityList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortInteriorCedarMaturity]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadInitialData {
    //NSManagedObjectContext *context = [self managedObjectContext];
    
   // Timbermark *tm1 = [NSEntityDescription insertNewObjectForEntityForName:@"Timbermark" inManagedObjectContext:context];
}

- (void)viewDidLoad{

    //set up special character label
    [_timbermarkVBenchmarkLabel setText:[NSString stringWithFormat:@"Benchmark (m%@/ha)", @"\u00B3"]];
    
    
    // Set up UIScrollView
    [scrollView setScrollEnabled:YES];
    [scrollView setPagingEnabled:YES];
    [scrollView setContentSize:CGSizeMake(1024, 1200)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    /*
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:nil
                                    repeats:YES];
    */
    // Set up Drop Down Lists for Testing
    [self setupLists];
    
    // Picker View is created off screen
    _pickerViewContainer.frame = CGRectMake(0,1200,1024,260);

    //toggle some UI for different region
    if ([self.wasteBlock.regionId intValue] == InteriorRegion ){
    
        [self.timbermarkVolumeLabel setText:[NSString stringWithFormat:@"Vol/ha (m%@/ha) Avoid Gr 2 or BTR",@"\u00B3"]];
        [self.maturityLabel setText:@"Site Code"];
        [self.checkMaturityLabel setText:@"Check Site Code"];
    
    }else if([self.wasteBlock.regionId intValue] == CoastRegion){

        [self.timbermarkVolumeLabel setText:[NSString stringWithFormat:@"Vol/ha (m%@/ha) Avoid Gr X or BTR",@"\u00B3"]];
        [self.maturityLabel setText:@"Maturity Code"];
        [self.checkMaturityLabel setText:@"Check Maturity Code"];
        [self.interiorCedarMaturityLabel setText:@"Benchmark"];
        [self.interiorCedarMaturity setHidden:YES];
        [self.benchmarkField setHidden:NO];
    }

    
    
    // MATURITY PICKER
    self.checkMaturityPicker = [[UIPickerView alloc] init];
    self.checkMaturityPicker.delegate = self;
    self.checkMaturityPicker.tag = 2;
    self.checkMaturity.inputView = self.checkMaturityPicker;
    
    UITapGestureRecognizer *gr2 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(maturityRecognizer:)];
    [self.checkMaturityPicker addGestureRecognizer:gr2];
    gr2.delegate = self;
    [self.checkMaturity setDelegate:self];
    
    self.maturity.inputView = self.checkMaturityPicker;
    [self.maturity setDelegate:self];
    
    if ([self.wasteBlock.regionId intValue] == InteriorRegion ){
        self.interiorCedarMaturityPicker = [[UIPickerView alloc] init];
        self.interiorCedarMaturityPicker.delegate = self;
        self.interiorCedarMaturityPicker.tag = 3;
        self.interiorCedarMaturity.inputView = self.interiorCedarMaturityPicker;
        
        UITapGestureRecognizer *gr3 = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(interiorCedarMaturityRecognizer:)];
        [self.interiorCedarMaturityPicker addGestureRecognizer:gr3];
        gr3.delegate = self;
        [self.interiorCedarMaturity setDelegate:self];
    }
    // COMPLETE DATE PICKER
    self.datePicker = [[UIDatePicker alloc] init];
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    } else {
        // Fallback on earlier versions
    }
    
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    
    [self.datePicker addTarget:self action:@selector(dateChanged:)
       forControlEvents:UIControlEventValueChanged];

    self.loggingCompleteTextField.inputView = self.datePicker;
    [self.loggingCompleteTextField setDelegate:self];
    
    self.surveyDate.inputView = self.datePicker;
    [self.surveyDate setDelegate:self];
    
    orignialDate = self.datePicker.date;

    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.barTintColor = [UIColor whiteColor];

    // STATIC DATA
    //[self setupStaticData];
    
    //Set the title of the nagivation view controller
    
    NSString *tmp  = [[NSString alloc] initWithFormat:@"(IFOR 202) Cut Block - %@", self.wasteBlock.cutBlockId && ![self.wasteBlock.cutBlockId isEqualToString:@"" ]  ? self.wasteBlock.cutBlockId : @"New Block" ];
    if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        tmp = [tmp stringByAppendingString:@" Aggregate Ratio Survey"];
    }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        tmp = [tmp stringByAppendingString:@" Aggregate SRS Survey"];
    }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        tmp = [tmp stringByAppendingString:@" Single Block SRS Survey"];
    }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        tmp = [tmp stringByAppendingString:@" Single Block Ratio Survey"];
    }
    [[self navigationItem] setTitle:tmp];
    
    // KEYBOARD DISMISALL
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    // Disable the Generate XML Button if a Packing Ratio Stratum is present
    [self updateGenerateXMLButtonEnabledState];
    
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
    {
        self.cuttingPermit.hidden = TRUE;
        self.cutBlock.hidden = TRUE;
        self.cpCutblockLabel.hidden = TRUE;
        self.licence.hidden = TRUE;
        self.licenceLabel.hidden = TRUE;
        self.location.hidden = TRUE;
        self.locationLabel.hidden = TRUE;
        self.loggedFrom.hidden = TRUE;
        self.loggedFromLabel.hidden = TRUE;
        self.loggedTo.hidden = TRUE;
        self.loggedToLabel.hidden = TRUE;
        self.loggingCompleteTextField.hidden = TRUE;
        self.loggingCompleteLabel.hidden = TRUE;
        [self.generateXMLButton setEnabled:NO];
        //self.editTimbermarkButton.hidden = TRUE;
    }
    if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        [self.generateXMLButton setEnabled:NO];
    }
    
    /*if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        if([wasteBlock.blockStratum count] > 0){
            for(WasteStratum *ws in [self.wasteBlock.blockStratum allObjects]){
                if([ws.isPileStratum intValue] == 1){
                    [self.generateXMLButton setEnabled:NO];
                }else{
                    [self.generateXMLButton setEnabled:YES];
                }
            }
        }
    }*/
    // LOAD VIEW WITH OBJECT DATA
    [self populateFromObject];

    //NSLog([NSString stringWithFormat:@"User Created: %@", self.wasteBlock.userCreated]);

    [self toggleUI:self.wasteBlock.userCreated];
    
    // Populate version number
    [versionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteVersionNumber"]];
}

  - (void) dateChanged:(id)sender{
      if([wasteBlock.regionId integerValue] == InteriorRegion)
      {
         NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:@"gregorian"];
         NSDateComponents *comps = [[NSDateComponents alloc]init];
         comps.year = 2020;
         comps.month = 8;
         comps.day = 31;
         NSDate* date = [calendar dateFromComponents:comps];
          int found = 0;
          for(WasteStratum *ws in wasteBlock.blockStratum)
             {
                 for(WastePlot *wpl in ws.stratumPlot)
                 {
                     for(WastePiece *wp in wpl.plotPiece)
                     {
                         if( [wp.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"5"] &&
                            (self.datePicker.date == nil || [self.datePicker.date compare:date] == NSOrderedDescending))
                         {
                             found = 1;
                         }
                     }
                 }
             }
          if(found)
          {
               UIAlertView *alert = nil;
                   alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error - Grade 5 is not allowed for Interior blocks with Survey Dates that are blank or on or after September 1, 2020\n" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
              self.datePicker.date = orignialDate;
          }
          else
          {
              orignialDate = self.datePicker.date;
          }
      }
  }

// SAME ROW SELECT APPLY

- (void)maturityRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.checkMaturityPicker.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.checkMaturityPicker.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        if (activeTextField == self.maturity || activeTextField == self.checkMaturity){
            
            if ([self.wasteBlock.regionId intValue] == InteriorRegion){
                SiteCode *sc = [self.siteCodeArray objectAtIndex:[self.checkMaturityPicker selectedRowInComponent:0]];
                activeTextField.text = [[NSString alloc] initWithFormat:@"%@ - %@", sc.siteCode, sc.desc];
            }else if([self.wasteBlock.regionId intValue] == CoastRegion){
                MaturityCode *mc = [self.maturityCodeArray objectAtIndex:[self.checkMaturityPicker selectedRowInComponent:0]];
                activeTextField.text = [[NSString alloc] initWithFormat:@"%@ - %@", mc.maturityCode, mc.desc];
            }
            
            [activeTextField resignFirstResponder];
        }
    }
}

- (void)interiorCedarMaturityRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    CGRect frame_interior = self.interiorCedarMaturityPicker.frame;
    CGRect selectorFrame_interior = CGRectInset( frame_interior, 0.0, self.interiorCedarMaturityPicker.bounds.size.height * 0.85 / 2.0 );
    if( CGRectContainsPoint( selectorFrame_interior, touchPoint) )
    {
        if (activeTextField == self.interiorCedarMaturity){
            if ([self.wasteBlock.regionId intValue] == InteriorRegion){
                InteriorCedarMaturityCode *icm = [self.interiorCedarMaturityCodeArray objectAtIndex:[self.interiorCedarMaturityPicker selectedRowInComponent:0]];
                activeTextField.text = [[NSString alloc] initWithFormat:@"%@ - %@", icm.interiorCedarCode, icm.desc];
                [activeTextField resignFirstResponder];
            }
        }
    }
}

// enable multiple gesture recognizers, otherwise same row select wont detect taps
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // enable multiple gesture recognition
    return true;
}


- (void)viewWillAppear:(BOOL)animated{
    // [super viewWillAppear:animated];
    //self.navigationController.toolbarHidden = NO;
    
        [[Timer sharedManager] setCurrentVC:self];
    
    // UPDATE stratums
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc ] initWithKey:@"stratumID" ascending:YES];
    self.sortedStratums = [[[self.wasteBlock blockStratum] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, sort2, nil]];
    
    
    // update the view with new data - for stratum
    [self.stratumTableView reloadData];
    [self.timbermarkTableView reloadData];
    
    [self checkStratum];
    /*if([wasteBlock.blockStratum count] > 0){
        for(WasteStratum *ws in [self.wasteBlock.blockStratum allObjects]){
            if([ws.isPileStratum intValue] == 1){
                [self.generateXMLButton setEnabled:NO];
            }
        }
    }*/
    
    
    // update shape picker selected row
/*
 int row;
    row = 0;
    for (MaturityCode *mc in self.maturityCodeArray) {
        
        if( [mc.maturityCode isEqualToString:[self codeFromText:self.checkMaturity.text]] ){
            [self.checkMaturityPicker selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }
 */
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setBlockViewValue:self.wasteBlock];
    }else{
        [self.footerStatView setViewValue:self.wasteBlock];
    }
    
    // Disable the Generate XML Button if a Packing Ratio Stratum is present
    [self updateGenerateXMLButtonEnabledState];
}

// AUTO-SAVE
- (void)viewWillDisappear:(BOOL)animated{
    //[super viewWillDisappear:animated];
    //self.navigationController.toolbarHidden = YES;
    
    
    [self saveData];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) saveData{
    NSLog(@"SAVE BLOCK");
    
    if (self.wasteBlock) {
    
        self.wasteBlock.cuttingPermitId = [self.cuttingPermit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.wasteBlock.cutBlockId = [self.cutBlock.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.wasteBlock.blockNumber= [self.cutBlock.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.wasteBlock.licenceNumber = [self.licence.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.wasteBlock.location = self.location.text;
        self.wasteBlock.yearLoggedFrom = [[NSDecimalNumber alloc] initWithString:self.loggedFrom.text];
        self.wasteBlock.yearLoggedTo = [[NSDecimalNumber alloc] initWithString:self.loggedTo.text];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM-dd-yyyy"];
        self.wasteBlock.loggingCompleteDate = [dateFormat dateFromString:self.loggingCompleteTextField.text];
        
        self.wasteBlock.surveyDate = [dateFormat dateFromString:self.surveyDate.text];
        if([self.netArea.text isEqualToString:@""]){
            self.netArea.text = @"0";
        }
        self.wasteBlock.netArea = [[NSDecimalNumber alloc] initWithString:self.netArea.text];
        self.wasteBlock.surveyArea = [[NSDecimalNumber alloc] initWithString:self.surveyNetAreaTextField.text];
        self.wasteBlock.npNFArea = [[NSDecimalNumber alloc] initWithString:self.npNfArea.text];
        
        if ([self.wasteBlock.regionId intValue] == InteriorRegion ){
            for (SiteCode* sc in self.siteCodeArray){
                if ([sc.siteCode isEqualToString: [self codeFromText:self.maturity.text]] ){
                    self.wasteBlock.blockSiteCode = sc;
                    break;
                }
            }
            for (SiteCode* sc in self.siteCodeArray){
                if ([sc.siteCode isEqualToString: [self codeFromText:self.checkMaturity.text]] ){
                    self.wasteBlock.blockCheckSiteCode = sc;
                    break;
                }
            }
            for (InteriorCedarMaturityCode* sc in self.interiorCedarMaturityCodeArray){
                if ([sc.interiorCedarCode isEqualToString: [self codeFromText:self.interiorCedarMaturity.text]] ){
                    self.wasteBlock.blockInteriorCedarMaturityCode = sc;
                    break;
                }
            }
        }else if([self.wasteBlock.regionId intValue] == CoastRegion){
            for (MaturityCode* mc in self.maturityCodeArray){
                if ([mc.maturityCode isEqualToString: [self codeFromText:self.maturity.text]] ){
                    self.wasteBlock.blockMaturityCode = mc;
                    break;
                }
            }
            for (MaturityCode* mc in self.maturityCodeArray){
                if ([mc.maturityCode isEqualToString: [self codeFromText:self.checkMaturity.text]] ){
                    self.wasteBlock.blockCheckMaturityCode = mc;
                    break;
                }
            }
        }

        self.wasteBlock.returnNumber = [NSNumber numberWithInt:[self.returnNumber.text intValue]];//[[NSDecimalNumber alloc] initWithString:self.returnNumber.text]; This would hold a value −2,147,483,648 but won't be displayed on screen,when try to merge causes issue
        self.wasteBlock.surveyorLicence = self.surveyorLicence.text;
        self.wasteBlock.professional = self.professionalDesignation.text;
        self.wasteBlock.registrationNumber = self.registrationNumber.text;
        self.wasteBlock.position = self.position.text;
        
        if ([self.notes.text isEqualToString:@""]){
            self.wasteBlock.notes = nil;
        }else{
            self.wasteBlock.notes = self.notes.text;
        }
        
        if([self.wasteBlock.userCreated intValue] == 1){
            //save extra field for user created block
            self.wasteBlock.reportingUnit = [NSNumber numberWithInt:[self.reportingUnitNo.text intValue]];
            self.wasteBlock.surveyorName = self.wasteCheckerName.text;
        }else{
            self.wasteBlock.checkerName = self.wasteCheckerName.text;
        }
        if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]) {
            if([wasteBlock.blockStratum count] == 0 ){
                if( (wasteBlock.ratioSamplingLog == nil || [wasteBlock.ratioSamplingLog isEqualToString:@""])){
                wasteBlock.ratioSamplingLog = @"";
                }
            }else if([wasteBlock.blockStratum count] > 0) {// this is done here so that when old efw files are imported to eforwaste wasteblock.ratiosamplinglog will be blank for ratio survey and wastestratum.ratiosamplinglog contain data. So when they try to generate the plot prediction report blank report comes up.
                if( (wasteBlock.ratioSamplingLog == nil || [wasteBlock.ratioSamplingLog isEqualToString:@""])){
                    wasteBlock.ratioSamplingLog = @"";
                    for (WasteStratum *stm in [wasteBlock.blockStratum allObjects]){
                        wasteBlock.ratioSamplingLog = [wasteBlock.ratioSamplingLog stringByAppendingString:stm.ratioSamplingLog];
                    }
                }
            }
        }
        if([self.wasteBlock.regionId intValue] == InteriorRegion){
            if([wasteBlock.blockTimbermark count] >0 ){
                if(self.wasteBlock.blockSiteCode.siteCode != nil){
                    for (Timbermark *tm in  [wasteBlock.blockTimbermark allObjects]) {
                        if ([wasteBlock.blockCheckSiteCode.siteCode isEqualToString:@"DB"]){
                            tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"4"];
                        }else if ([wasteBlock.blockCheckSiteCode.siteCode isEqualToString:@"TZ"]){
                            tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"10"];
                        }else if ([wasteBlock.blockCheckSiteCode.siteCode isEqualToString:@"WB"]){
                            tm.benchmark = [NSDecimalNumber decimalNumberWithString:@"20"];
                        }
                        [WasteCalculator calculateWMRF:self.wasteBlock  updateOriginal:YES];
                        [WasteCalculator calculateRate:self.wasteBlock];
                        [WasteCalculator calculatePiecesValue:self.wasteBlock];
                        [WasteCalculator calculateEFWStat:self.wasteBlock];
                    }
                }
            }
        }
        //since in coast region benchmark is user entered in cutblock screen. Logic to handle for new and already existing timbermark
        if([self.wasteBlock.regionId intValue] == CoastRegion){
            if(![self.benchmarkField.text isEqualToString:@""]){
            if([self.benchmarkField.text integerValue] >= 0 && [self.benchmarkField.text integerValue] <= 99){
                //to remove value after the decimal point
                CGFloat floatingPointNumber = [self.benchmarkField.text floatValue];
                NSInteger integerNumber = floatingPointNumber;
                self.benchmarkField.text = [[NSString alloc ] initWithFormat:@"%ld", (long)integerNumber];
                
                NSArray *timbermark = [wasteBlock.blockTimbermark allObjects];
                if(timbermark == nil || [timbermark count] == 0){
                    NSManagedObjectContext *context = [self managedObjectContext];
                    Timbermark *tm = [NSEntityDescription insertNewObjectForEntityForName:@"Timbermark" inManagedObjectContext:context];
                    tm.primaryInd = [[NSNumber alloc] initWithInt:1];
                    tm.area = [[NSDecimalNumber alloc] initWithFloat:0.0];
                    tm.surveyArea = [[NSDecimalNumber alloc] initWithFloat:0.0];
                    tm.orgWMRF =[[NSDecimalNumber alloc] initWithFloat:0.0];
                    tm.timbermark = @" ";
                    tm.avoidable = [[NSDecimalNumber alloc] initWithFloat:0.0];
                    tm.timbermarkMonetaryReductionFactorCode = (MonetaryReductionFactorCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"monetaryReductionFactorCode" code:@"A"];;
                    tm.benchmark = [[NSDecimalNumber alloc] initWithString:self.benchmarkField.text];
                    tm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:0.0];
                    tm.xPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
                    tm.yPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
                    tm.hembalPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
                    tm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:1.0];
                    
                    [self.wasteBlock addBlockTimbermarkObject:tm];
                    
                    [WasteCalculator calculateWMRF:self.wasteBlock  updateOriginal:YES];
                    [WasteCalculator calculateRate:self.wasteBlock];
                    [WasteCalculator calculatePiecesValue:self.wasteBlock];
                    [WasteCalculator calculateEFWStat:self.wasteBlock];
                    NSError *error;
                    [context save:&error];
                    
                    if( error != nil){
                        NSLog(@" Error when saving  into Core Data: %@", error);
                    }
                    [self.timbermarkTableView reloadData];
                }else {
                    for (Timbermark *tm in  [wasteBlock.blockTimbermark allObjects]) {
                        if(!(tm.benchmark == [[NSDecimalNumber alloc] initWithString:self.benchmarkField.text])){
                            tm.benchmark = [[NSDecimalNumber alloc] initWithString:self.benchmarkField.text];
                            if([tm.primaryInd intValue] == 2){
                                tm.benchmark = [[NSDecimalNumber alloc] initWithString:self.benchmarkField.text];
                            }
                            [WasteCalculator calculateWMRF:self.wasteBlock  updateOriginal:YES];
                            [WasteCalculator calculateRate:self.wasteBlock];
                            [WasteCalculator calculatePiecesValue:self.wasteBlock];
                            [WasteCalculator calculateEFWStat:self.wasteBlock];
                            
                        }
                    }[self populateFromObject];
                }
            }else{
                UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter benchmark value between 0 and 99" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [userAlert addAction:okBtn];
                [self presentViewController:userAlert animated:YES completion:nil];
            }
        }
        }
        NSError *error;
        
        // save the whole cut block
        NSManagedObjectContext *context = [self managedObjectContext];
        [context save:&error];
        
        // Disable the Generate XML Button if a Packing Ratio Stratum is present
        [self updateGenerateXMLButtonEnabledState];
        
        if( error != nil){
            NSLog(@" Error when saving waste block into Core Data: %@", error);
        }
    }
}

// Enables/Disables the Generate XML Button depending on whether or not a Packing Ratio Stratum is present
- (void)updateGenerateXMLButtonEnabledState {
    // disable the generate xml button if it packing ratio stratum is present
    BOOL hasPackingRatioStratum = NO;
    for (WasteStratum *wasteStratum in self.wasteBlock.blockStratum) {
        PlotSizeCode *plotSizeCode = wasteStratum.stratumPlotSizeCode;
        if ([plotSizeCode.plotSizeCode isEqualToString:@"R"] && ![self.wasteBlock.isAggregate boolValue]) {
            hasPackingRatioStratum = YES;
            break; // Exit the loop since a Packing Ratio Stratum is found
        }
    }
    
    [self.generateXMLButton setEnabled:!hasPackingRatioStratum];
    
    // also disable xml generation for all ratio blocks and all aggregate blocks (everything except single block srs)
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue] || [self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue])
    {
        [self.generateXMLButton setEnabled:NO];
    }
    
}




// KEYBOARD DISMISS
// ON RETURN
- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

// ON BACKGROUND TAP
- (void)dismissKeyboard {
     [self.view endEditing:YES];
}




// SCREEN METHODS
//
#pragma mark - BIActions
- (void) saveBlock:(id)sender{
    
    [self checkStratum];
    
    //Verify wasteblock is not a duplicate before attempting to save
    if (![WasteBlockDAO checkDuplicateWasteBlockByRU:self.reportingUnitNo.text cutBlockId:self.cutBlock.text license:self.licence.text cutPermit:self.cuttingPermit.text assessmentAreaId:self.wasteBlock.wasteAssessmentAreaID]) {
        
        [self saveData];
        
        NSString *title = NSLocalizedString(@"Save Block", nil);
        NSString *message = NSLocalizedString(@"", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        
        [alert show];
        
    } else {
        
        //WasteBlock already exists
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Duplicate Waste Block"
                                                                       message:@"A waste block under the same Reporting Unit ID, Cutting Permid ID, Cut Block Number and License Number already exists"
                                                                preferredStyle:UIAlertControllerStyleAlert];
            
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 [self dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction) generateReport:(id)sender{
    NSString *title = NSLocalizedString(@"Reports", nil);
    NSString *message = NSLocalizedString(@"Please select a report to be generated.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Check Summary Report", nil);
    NSString *otherButtonTitleTwo = NSLocalizedString(@"FS702 Report", nil);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, nil];
    
	[alert show];
}

- (IBAction) deleteStratum:(id)sender {
    NSString *title = NSLocalizedString(@"Delete Stratum Confirmation", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Confirm", nil);
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:otherButtonTitleOne style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        UIButton *button = (UIButton *)sender;
        NSLog(@"StratumID: %ld",button.tag);
        
        [self deleteStratumFrmCoreData:alert stratumIndex:button.tag];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) deleteStratumFrmCoreData:(UIAlertController*)alert stratumIndex:(int)stratumIndex {
    
    WasteStratum *targetStratum = [self.sortedStratums objectAtIndex:stratumIndex];
    
    [WasteBlockDAO deleteStratum:targetStratum usingWB:wasteBlock];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc ] initWithKey:@"stratumID" ascending:YES];
    
    self.sortedStratums = [[[self.wasteBlock blockStratum] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, sort2, nil]];
    
    [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
    [WasteCalculator calculateRate:self.wasteBlock ];
    [WasteCalculator calculatePiecesValue:self.wasteBlock];
    
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setBlockViewValue:self.wasteBlock];
    }else{
        [self.footerStatView setViewValue:self.wasteBlock];
    }
    
    [self saveData];
    [self.stratumTableView reloadData];
    [self viewDidLoad];
    [self checkStratum];
}

- (IBAction)deleteBlock:(id)sender{
    
        NSString *title = NSLocalizedString(@"Delete Cut Block", nil);
        NSString *message = nil;
        
        if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"iFORWASTE"] ){
            message = NSLocalizedString(@"Warning - Deleteing a cut block will remove the survey data and the check data in the application. Are you sure to delete?", nil);
        }else if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){

            message = NSLocalizedString(@"Warning - Deleting a block will remove the block from the application. Do you want to delete the block?", nil);

        }
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
        NSString *otherButtonTitleOne = NSLocalizedString(@"Delete", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, nil];
        alert.tag = ((UIButton *)sender).tag;
        //NSLog(@"Passing the tag from button to the alert view, %ld to %ld",(long)((UIButton *)sender).tag, (long)alert.tag );
        [alert show];
}

- (void) confirmPredictionPlots:(UIAlertController*)alert sender:(UIButton*) sender{
    NSString* pp_str = nil;
    NSNumber* pp = nil;
    
    for(UITextField* tf in alert.textFields){
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Prediction Plots", nil)]){
            pp_str = tf.text;
        }
    }
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    pp = [f numberFromString:pp_str];
    if([pp_str isEqualToString:@""]){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                              message:@"Please enter number of Prediction Plots."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self presentViewController:alert animated:YES completion:nil];
                                                         }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else if(pp == nil || [pp doubleValue] < 0)
    {
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid Data", nil)
                                                                              message:@"Number of Prediction Plots must be zero or greater."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self presentViewController:alert animated:YES completion:nil];
                                                         }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
}

- (void) addStratum:(id)sender{
    if([self.wasteBlock.regionId intValue] == CoastRegion && [self.benchmarkField.text isEqualToString:@""]){
        UIAlertView *validateAlert;
        validateAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter benchmark value."
                                                 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [validateAlert show];
    }else if([self.wasteBlock.regionId intValue] == InteriorRegion && self.wasteBlock.blockSiteCode.siteCode == nil){
        UIAlertView *validateAlert;
        validateAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter site code."
                                                  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [validateAlert show];
    } else {
    [self addStratumType:(UIButton *)sender];
    }
}

- (void) addStratumType:(UIButton* )sender{
        NSString *title = NSLocalizedString(ADD_STRATIM_TITLE, nil);
        NSString *message = NSLocalizedString(@"Please select a Stratum Type.", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
        NSString *otherButtonTitleOne = NSLocalizedString(STANDARD_STRATUM, nil);
        NSString *otherButtonTitleTwo = NSLocalizedString(STANDING_TREE, nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, nil];
        alert.tag = sender.tag;
        //NSLog(@"Passing the tag from button to the alert view, %ld to %ld",(long)((UIButton *)sender).tag, (long)alert.tag );
        [alert show];
}

- (IBAction)doneClicked:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    // Move picker view off screen
    _pickerViewContainer.frame = CGRectMake(0, 1200, 1024, 260);
    [UIView commitAnimations];
}

- (IBAction)showPicker:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _pickerViewContainer.frame = CGRectMake(0, 674, 1024, 260);
    [UIView commitAnimations];
}

- (IBAction)exportCutBlock:(id)sender{
    XMLExportGenerator *xmlGen = [[XMLExportGenerator alloc] init];
    
    NSString *title = NSLocalizedString(@"Export Cut Block", nil);
    NSString *message = @"";
    
    switch([xmlGen generateCutBlockXMLExport:self.wasteBlock replace:YES type:IFW] ){
        case ExportSuccessful:
            message = NSLocalizedString(@"Export file has generated successfully for this cut block", nil);
            break;
        default:
            message = NSLocalizedString(@"Export file cannot be generated for this cut block", nil);
            break;
    }
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    alert.tag = ((UIButton *)sender).tag;

    //NSLog(@"Passing the tag from button to the alert view, %ld to %ld",(long)((UIButton *)sender).tag, (long)alert.tag );
    [alert show];
}

- (IBAction)prepareForExport:(id)sender {
    NSMutableString *error = [[NSMutableString alloc] initWithString:@""];
    NSString *okTitle = NSLocalizedString(@"OK", nil);
    NSString *title = NSLocalizedString(@"Entry Error: ", nil);
    
    [self saveData];
    
    // Validate data
    WastePlotValidator *wpv = [[WastePlotValidator alloc] init];
    [error appendString:[wpv validateBlock:self.wasteBlock checkPlot:YES]];
    [error appendString:[self validateCutBlock:sender]];
    [error appendString:[self mandatoryFieldsForXML:sender]];
    
    if (![error isEqualToString:@""]) {
        if ([error rangeOfString:@"Error"].location != NSNotFound || [error rangeOfString:@"mandatory"].location != NSNotFound) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:error preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:error preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([self.wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue] && [self.wasteBlock.cutBlockId isEqualToString:@""]) {
                    UIAlertController *cutBlockIdAlert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Cutblock id missing" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self promptForExportUserData:sender];
                        [cutBlockIdAlert dismissViewControllerAnimated:YES completion:nil];
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                        // Dismiss
                        [cutBlockIdAlert dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [cutBlockIdAlert addAction:ok];
                    [cutBlockIdAlert addAction:cancel];
                    [self presentViewController:cutBlockIdAlert animated:YES completion:nil];
                } else {
                    [self promptForExportUserData:sender];
                }
                
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                // Dismiss
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:ok];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        if ([self.wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue] && [self.wasteBlock.cutBlockId isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Cutblock id missing" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self promptForExportUserData:sender];
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                // Dismiss
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:ok];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [self promptForExportUserData:sender];
        }
    }
}


- (void)generateXML:(id)sender{
    XMLExportGenerator *xmlGen = [[XMLExportGenerator alloc] init];
    
    NSString *title = NSLocalizedString(@"Export Cut Block", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    NSString *message = @"";
    //Quick fix for pre existing efw files with wrong total estimated volume, when xml file is generated to display the correct total estimated volume.
    for(WasteStratum *ws in [self.wasteBlock.blockStratum allObjects]){
        double  totalestimatedvolume = 0.0;
        for(WastePlot *wp in [ws.stratumPlot allObjects]){
            totalestimatedvolume = totalestimatedvolume + [wp.plotEstimatedVolume doubleValue];
        }
        ws.totalEstimatedVolume = [[NSDecimalNumber alloc] initWithDouble:totalestimatedvolume];
        NSLog(@"Total Estimated Volume %@", ws.totalEstimatedVolume);
    }
    switch([xmlGen generateCutBlockXMLExport:self.wasteBlock replace:YES type:XML] ){
        case ExportSuccessful:
            message = NSLocalizedString(@"XML file has generated successfully for this cut block", nil);
            break;
        default:
            message = NSLocalizedString(@"XML file cannot be generated for this cut block", nil);
            break;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)generateEFW:(id)sender {
    NSLog(@"generateEFW");
    XMLExportGenerator *xmlGen = [[XMLExportGenerator alloc] init];
    BOOL present = FALSE;
    if([wasteBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]){
        if([wasteBlock.blockStratum count] > 0){
            for(WasteStratum *ws in [self.wasteBlock.blockStratum allObjects]){
                if([ws.isPileStratum intValue] == 1){
                    present = TRUE;
                    break;
                }else{
                    present = FALSE;
                }
            }
        }
    }
    if(present){
        WastePlotValidator *wpv = [[WastePlotValidator alloc] init];
        NSString *errorMessage = [wpv validPile:self.wasteBlock];
        NSString *errorHeader;
        if ([errorMessage rangeOfString:@"plot"].location != NSNotFound) {
            errorHeader = @"Plot Data Missing";
        } else {
            errorHeader = @"Pile Data Missing";
        }
        if(![errorMessage isEqualToString:@""]){
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(errorHeader, nil)
                                                                                  message:[NSString stringWithFormat:@"%@ OK to proceed?",errorMessage]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {NSString *message = @"";
                                                                  NSString *okTitle = NSLocalizedString(@"OK", nil);
                                                                  
                                                                  switch([xmlGen generateCutBlockXMLExport:self.wasteBlock replace:YES type:EFW]) {
                                                                      case ExportSuccessful:
                                                                          message = NSLocalizedString(@"EFW file has generated successfully for this cut block", nil);
                                                                          break;
                                                                      default:
                                                                          message = NSLocalizedString(@"EFW file cannot be generated for this cut block", nil);
                                                                          break;
                                                                  }
                                                                  
                                                                  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Export Cut Block" message:message preferredStyle:UIAlertControllerStyleAlert];
                                                                  
                                                                  UIAlertAction *ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                                  }];
                                                                  
                                                                  [alert addAction:ok];
                                                                  [self presentViewController:alert animated:YES completion:nil]; }];
            
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self dismissViewControllerAnimated:YES completion:nil ];
                                                             }];
            [warningAlert addAction:yesAction];
            [warningAlert addAction:noAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }else{
            NSString *message = @"";
            NSString *okTitle = NSLocalizedString(@"OK", nil);
            
            switch([xmlGen generateCutBlockXMLExport:self.wasteBlock replace:YES type:EFW]) {
                case ExportSuccessful:
                    message = NSLocalizedString(@"EFW file has generated successfully for this cut block", nil);
                    break;
                default:
                    message = NSLocalizedString(@"EFW file cannot be generated for this cut block", nil);
                    break;
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Export Cut Block" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            }
    }else{
    NSString *message = @"";
    NSString *okTitle = NSLocalizedString(@"OK", nil);
    
    switch([xmlGen generateCutBlockXMLExport:self.wasteBlock replace:YES type:EFW]) {
        case ExportSuccessful:
            message = NSLocalizedString(@"EFW file has generated successfully for this cut block", nil);
            break;
        default:
            message = NSLocalizedString(@"EFW file cannot be generated for this cut block", nil);
            break;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Export Cut Block" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void) promptForExportUserData:(id) sender {
    NSString *districtCode;
    NSString *clientCode;
    NSString *licenseeContact;
    NSString *phoneNumber;
    NSString *email;
    
    ExportUserData *existingData = [ExportUserDataDAO getExportUserData];
    
    if (existingData) {
        districtCode    = existingData.districtCode;
        clientCode      = existingData.clientCode;
        licenseeContact = existingData.licenseeContact;
        phoneNumber     = existingData.telephoneNumber;
        email           = existingData.emailAddress;
        
    } else {
        existingData = [ExportUserDataDAO createEmptyExportUserData];
    }
    
    NSString *title           = NSLocalizedString(@"Export Cut Block", nil);
    NSString *ok              = NSLocalizedString(@"OK", nil);
    NSString *cancel          = NSLocalizedString(@"Cancel", nil);
    NSString *userDataMessage = NSLocalizedString(@"Please enter your client submission data: District Code, Client Code, Licensee Contact, Telephone Number, and Email Address", nil);
    
    
    UIAlertController  *userDataAlert = [UIAlertController alertControllerWithTitle:title message:userDataMessage preferredStyle:UIAlertControllerStyleAlert];
    [userDataAlert addAction:[UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self validateSubmissionFor:userDataAlert  using:userDataAlert.textFields]) {
            [self storeExportUserData:existingData     using:userDataAlert.textFields];
            [self generateXML:sender];
        }
    }]];
    [userDataAlert addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];
    
    [userDataAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"District Code", nil);
        textField.accessibilityLabel = NSLocalizedString(@"District Code", nil);
        textField.text               = (existingData) ? districtCode : @"";
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNamePhonePad;
        textField.tag                = 7;
        textField.delegate           = self;
    }];
    [userDataAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Client Code", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Client Code", nil);
        textField.text               = (existingData) ? clientCode : @"";
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNamePhonePad;
        textField.tag                = 6;
        textField.delegate           = self;
    }];
    [userDataAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Licensee Contact", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Licensee Contact", nil);
        textField.text               = (existingData) ? licenseeContact : @"";
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeAlphabet;
        textField.tag                = 5;
        textField.delegate           = self;
    }];
    [userDataAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Telephone Number", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Telephone Number", nil);
        textField.text               = (existingData) ? phoneNumber : @"";
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        //textField.textContentType    = UITextContentTypeTelephoneNumber;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        
        //Save reference here for input validation in 'shouldChangeCharactersInRange' listener
        self.telephoneNumber = textField;
        textField.tag        = 3;
        textField.delegate   = self;
    }];
    [userDataAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Email Address", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Email Address", nil);
        textField.text               = (existingData) ? email : @"";
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        //textField.textContentType    = UITextContentTypeEmailAddress;
        textField.keyboardType       = UIKeyboardTypeEmailAddress;
        textField.tag                = 1;
        textField.delegate           = self;
    }];
    
    [self presentViewController:userDataAlert animated:YES completion:nil];
}
    
// CHARACTER LIMIT CHECK
/*
 TAG 0 = default NO (not editable)
 
 TAG 1 = 256 char max
 
 TAG 2 = 100 char max
 
 TAG 3 = 10 char max
 
 TAG 4 = No max limit
 
 TAG 5 = 50 char max
 
 TAG 6 = 8 char max
 
 TAG 7 = 3 char max
 */
#pragma mark - UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    

    
    // INPUT VALIDATION
    //
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str appendString:string];
    NSString *theString = str;
    // FLOAT VALUE ONLY
    if(textField==self.netArea)
    {
        if( ![self validInputNumbersOnlyWithDot:theString] ){
            return NO;
        }
    } else if (textField == self.telephoneNumber || [textField.accessibilityLabel isEqualToString:NSLocalizedString(@"Prediction Plot", nil)]
               ||[textField.accessibilityLabel isEqualToString:NSLocalizedString(@"Measure Plot", nil)] || textField == self.benchmarkField ) {
        if (![self validInputNumbersOnly:theString]) {
            return NO;
        }
    }
    // ALPHABET ONLY
    if(textField==self.wasteCheckerName){
        if( ![self validInputAlphabetOnly:theString] ){
            return NO;
        }
    }

    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    switch (textField.tag) {
        case 1:
            return (newLength > 256) ? NO : YES;
            break;
            
        case 2:
            return (newLength > 100) ? NO : YES;
            break;
            
        case 3:
            return (newLength > 10) ? NO : YES;
            break;
            
        case 4: // no max limit
            return YES;
            break;
            
        case 5:
            return (newLength > 50) ? NO : YES;
            break;
            
        case 6:
            return (newLength > 8) ? NO : YES;
            break;
            
        case 7:
            return (newLength > 3) ? NO : YES;
            break;
            
        case 8:
            return (newLength > 2) ? NO : YES;
            break;

        default:
            return NO; // NOT EDITABLE
    }
    
    
}

// NOTES AREA LIMIT CHECK
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    
    
    switch (textView.tag) {
        case 1:
            return (newLength > 256) ? NO : YES;
            break;
            
        case 2:
            return (newLength > 100) ? NO : YES;
            break;
            
        case 3:
            return (newLength > 10) ? NO : YES;
            break;

        default:
            return NO; // NOT EDITABLE
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.maturity || textField == self.surveyNetAreaTextField || textField == self.checkMaturity || textField == self.netArea){
        
        //save the change first
        [self saveData];
        
        if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
            [self.efwFooterView setBlockViewValue:self.wasteBlock];
        }else{
            [self.footerStatView setViewValue:self.wasteBlock];
        }
        
        //save the calculated value
        [self saveData];
        
        //refresh other section
        [self.timbermarkTableView reloadData];
        
        //validate stratum area
        [self checkStratum];
    }else if(textField == self.benchmarkField){
        //save the change first
        [self saveData];
        [WasteCalculator calculateWMRF:self.wasteBlock  updateOriginal:YES];
        [WasteCalculator calculateRate:self.wasteBlock];
        [WasteCalculator calculatePiecesValue:self.wasteBlock];
        
        if([self.wasteBlock.userCreated intValue] ==1){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
        }
        
        //save the calculated value
        [self saveData];
        
        //refresh other section
        [self.timbermarkTableView reloadData];
        
        //validate stratum area
        [self checkStratum];
    }else if(textField == self.loggingCompleteTextField || textField == self.surveyDate){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM-dd-yyyy"];
        
        if(activeTextField){
            activeTextField.text = [formatter stringFromDate:self.datePicker.date];
            [activeTextField resignFirstResponder];
        }else{
            self.loggingCompleteTextField.text = [formatter stringFromDate:self.datePicker.date];
            [self.loggingCompleteTextField resignFirstResponder];
        }
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    //if textField is date field, try to populate the date to the date picker
    NSString *date = @"";
    if (textField == self.loggingCompleteTextField){
        date = self.loggingCompleteTextField.text;
    }else if(textField == self.surveyDate){
        date = self.surveyDate.text;
    }else if(textField == self.checkMaturity || textField == self.maturity){
        int row = 0;
        if([self.wasteBlock.regionId intValue] == InteriorRegion) {
            for (SiteCode *sc in self.siteCodeArray) {
                if( [sc.siteCode isEqualToString:[self codeFromText:textField.text]] ){
                    [self.checkMaturityPicker selectRow:row inComponent:0 animated:NO];
                    break;
                }
                row++;
            }
        }else if([self.wasteBlock.regionId intValue] == CoastRegion){
            for (MaturityCode *mc in self.maturityCodeArray) {
                if( [mc.maturityCode isEqualToString:[self codeFromText:textField.text]] ){
                    [self.checkMaturityPicker selectRow:row inComponent:0 animated:NO];
                    break;
                }
                row++;
            }
        }
    }else if(textField == self.interiorCedarMaturity){
        int row = 0;
        for (InteriorCedarMaturityCode *sc in self.interiorCedarMaturityCodeArray) {
            if( [sc.interiorCedarCode isEqualToString:[self codeFromText:textField.text]] ){
                [self.interiorCedarMaturityPicker selectRow:row inComponent:0 animated:NO];
                break;
            }
            row++;
        }
    }
    
    if (![date isEqualToString:@""]){
        NSDateFormatter *df= [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM-dd-yyyy"];
        [self.datePicker setDate:[df dateFromString:date]];
    }
    //save the active text field pointer and reuse it after a date is selected
    activeTextField = textField;
}

// INPUT VALIDATION

-(BOOL) validInputNumbersOnly:(NSString *)theString {
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    unichar c;
    
    for (int i = 0; i < [theString length]; i++) {
        c = [theString characterAtIndex:i];
        if (![charSet characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) validInputNumbersOnlyWithDot:(NSString*)theString{
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int dots=0;
    
    
    for (int i = 0; i < [theString length]; i++)
    {
        unichar c = [theString characterAtIndex:i];
        
        
        if (c == '.'){
            dots++;
        }
        if(dots > 1){
            return NO; // we dont allow multiple dots
        }
        if ( ![myCharSet characterIsMember:c] ){
            return NO;
        }
    }
    
    return YES;
}

- (BOOL) validInputAlphabetOnly:(NSString*)theString{
    theString = [theString uppercaseString];
    NSCharacterSet *characterSet = [NSCharacterSet uppercaseLetterCharacterSet];
    NSMutableCharacterSet *space = [NSMutableCharacterSet characterSetWithCharactersInString:@" "];
    
    [space formUnionWithCharacterSet:characterSet];
    
    characterSet = space;
    NSMutableCharacterSet *period = [NSMutableCharacterSet characterSetWithCharactersInString:@"."];
    
    [period formUnionWithCharacterSet:characterSet];
    
    characterSet = period;
    
    
    for (int i = 0; i < [theString length]; i++) {
        unichar c = [theString characterAtIndex:i];
        if ( ![characterSet characterIsMember:c] ){
            return NO;
        }
    }
    
    return YES;
}

- (NSString*) codeFromText:(NSString*)pickerText{
    
    // 1st one is the Code
    // 2nd one is the .desc
    return [[pickerText componentsSeparatedByString:@" - "] objectAtIndex:0];
}

#pragma mark User Prompts
                              
- (BOOL) validateSubmissionFor:(UIViewController *) parentAlert using:(NSArray <UITextField *> *) textfields {
    BOOL valid = YES;
    NSString *title = NSLocalizedString(@"Error: Invalid Entry", nil);
    NSString *ok = NSLocalizedString(@"OK", nil);
    NSMutableString *message = [[NSMutableString alloc] initWithString:@""];
    
    for (UITextField *field in textfields) {
        if ([field.text length] == 0) {
            [message appendString:[NSString stringWithFormat:@"Empty field: %@\n", field.placeholder]];
            valid = NO;
        }
    }
    
    //Enforce 10 digit phone number for ESF submission criteria
    if ([textfields[3].text length] != 10) {
        [message appendString:[NSString stringWithFormat:@"Phone number must be 10 digits\n"]];
        valid = NO;
    }
    
    if (!valid) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^ (UIAlertAction *action){
            
            //Return to parent alert for necessary editing changes
            [self presentViewController:parentAlert animated:YES completion:nil];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    return valid;
}

- (NSString *) validateCutBlock:(id)sender {
    NSMutableString *error = [[NSMutableString alloc] initWithString:@""];
    
    NSArray *mandatoryFields;
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
    {
        mandatoryFields = [NSArray arrayWithObjects: @[@"Reporting Unit No", self.wasteBlock.reportingUnit], nil];
    }
    else
    {
        mandatoryFields = [NSArray arrayWithObjects:   @[@"Reporting Unit No", self.wasteBlock.reportingUnit],
                           @[@"Licence", self.wasteBlock.licenceNumber], nil];
    }
    
    for (NSArray *elem in mandatoryFields) {
        if ([elem[1] isKindOfClass:[NSString class]] && [elem[1] length] == 0) {
            [error appendString:[NSString stringWithFormat:@"Missing mandatory field: %@\n", elem[0] ]];
        } else if ([elem[1] isKindOfClass:[NSNumber class]] && [elem[1] intValue] < 1) {
            [error appendString:[NSString stringWithFormat:@"Missing mandatory field: %@\n", elem[0] ]];
        } else if (elem[1] == nil) {
            [error appendString:[NSString stringWithFormat:@"Missing mandatory field: %@\n", elem[0] ]];
        }
    }
    return error;
}
-(NSString *) mandatoryFieldsForXML:(id)sender{

    NSString * errorMessage = @"";
    
    if([self.wasteBlock.regionId intValue] == InteriorRegion && self.wasteBlock.blockSiteCode.siteCode == nil){
        errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Site Code \n"];
    }
    if([self.wasteBlock.regionId intValue] == CoastRegion && self.wasteBlock.blockMaturityCode.maturityCode == nil){
        errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Maturity Code \n"];
    }
    if([self.wasteBlock.surveyorLicence isEqualToString:@""] || self.wasteBlock.surveyorLicence == nil){
        errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Surveyor Licence \n"];
    }
    if(self.wasteBlock.surveyDate == nil){
        errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Survey Date \n"];
    }
    if([self.wasteBlock.blockTimbermark count] == 0 ){
        errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Timber Mark \n"];
    }else if([self.wasteBlock.blockTimbermark count] > 0){
        for (Timbermark *tm in self.wasteBlock.blockTimbermark){
            if(tm.timbermark == nil || [tm.timbermark isEqualToString:@""]){
                errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Timber Mark \n"];
            }
        }
    }
    if([self.wasteBlock.blockStratum count] == 0){
        errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Stratum data\n"];
    }else if([self.wasteBlock.blockStratum count] > 0){
        for(WasteStratum *ws in self.wasteBlock.blockStratum){
            if(ws.stratumStratumTypeCode.stratumTypeCode == nil){
                errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Stratum Type\n"];
            }
            if(ws.stratumAssessmentMethodCode.assessmentMethodCode == nil){
                errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Assessment/Size\n"];
            }
            if(ws.stratumSurveyArea == nil || [ws.stratumSurveyArea doubleValue] == 0){
                errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Stratum Area \n"];
            }
            if([ws.stratumPlot count] == 0 && [ws.stratumPile count] == 0 ) {
                errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Plot data\n"];
            }else if([ws.stratumPlot count] > 0) {
                for (WastePlot *wp in ws.stratumPlot){
                    if(wp.plotNumber == nil){
                        errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Plot Number\n"];
                    }
                    if(wp.surveyedMeasurePercent == nil || [wp.surveyedMeasurePercent doubleValue] == 0){
                        errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Measure Factor\n"];
                    }
                    if([wp.plotPiece count] > 0){
                        for(WastePiece* piece in wp.plotPiece){
                            if(piece.pieceScaleSpeciesCode.scaleSpeciesCode == nil){
                                errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Species Code\n"];
                            }
                            if(piece.pieceMaterialKindCode.materialKindCode == nil){
                                errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Kind Code\n"];
                            }
                            if(piece.pieceWasteClassCode.wasteClassCode == nil){
                                errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Class Code\n"];
                            }
                            if(piece.pieceScaleGradeCode.scaleGradeCode == nil){
                                errorMessage = [errorMessage stringByAppendingString:@" Missing mandatory field: Grade\n"];
                            }
                        }
                    }
                }
            }
        }
    }

    return errorMessage;
}

#pragma mark PickerView DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if(pickerView == self.checkMaturityPicker){
        if([self.wasteBlock.regionId intValue] == InteriorRegion) {
            return [self.siteCodeArray count];
        }else if([self.wasteBlock.regionId intValue] == CoastRegion){
            return [self.maturityCodeArray count];
        }
    }else if(pickerView == self.interiorCedarMaturityPicker){
        return [self.interiorCedarMaturityCodeArray count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == self.checkMaturityPicker){

        if([self.wasteBlock.regionId intValue] == InteriorRegion) {
            return [[NSString alloc] initWithFormat:@"%@ - %@",[self.siteCodeArray[row] valueForKey:@"siteCode"] , [self.siteCodeArray[row] valueForKey:@"desc"]] ;
        }else if([self.wasteBlock.regionId intValue] == CoastRegion){
            return [[NSString alloc] initWithFormat:@"%@ - %@",[self.maturityCodeArray[row] valueForKey:@"maturityCode"] , [self.maturityCodeArray[row] valueForKey:@"desc"]] ;
        }
    }else if(pickerView == self.interiorCedarMaturityPicker){
        return [[NSString alloc] initWithFormat:@"%@ - %@",[self.interiorCedarMaturityCodeArray[row] valueForKey:@"interiorCedarCode"] , [self.interiorCedarMaturityCodeArray[row] valueForKey:@"desc"]] ;
    }
    return nil;
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == self.checkMaturityPicker){
        
        UITextField *targetTxt = nil;
        if ([self.wasteBlock.userCreated intValue] == 1){
            targetTxt = self.maturity;
        }else{
            targetTxt = self.checkMaturity;
        }
        
        if([self.wasteBlock.regionId intValue] == InteriorRegion) {
            targetTxt.text = [[NSString alloc] initWithFormat:@"%@ - %@",[self.siteCodeArray[row] valueForKey:@"siteCode"], [self.siteCodeArray[row] valueForKey:@"desc"] ];
            NSLog(@" site code : %@", self.checkMaturity.text);
            
        }else if([self.wasteBlock.regionId intValue] == CoastRegion){
            targetTxt.text = [[NSString alloc] initWithFormat:@"%@ - %@",[self.maturityCodeArray[row] valueForKey:@"maturityCode"], [self.maturityCodeArray[row] valueForKey:@"desc"] ];
            
            //self.checkMaturityLabel.text = [ [self codeFromText:self.checkMaturity.text] isEqualToString:@"M"] ? @"less than 8R" : @"Top Greater than 5R, top less than 5R";
        }
        
        [targetTxt resignFirstResponder];
    }
    if(pickerView == self.interiorCedarMaturityPicker){
        
        UITextField *targetTxt = nil;
       /* if ([self.wasteBlock.userCreated intValue] == 1){
            targetTxt = self.maturity;
        }else{
            targetTxt = self.checkMaturity;
        }*/
        targetTxt = self.interiorCedarMaturity;
        if([self.wasteBlock.regionId intValue] == InteriorRegion) {
            targetTxt.text = [[NSString alloc] initWithFormat:@"%@ - %@",[self.interiorCedarMaturityCodeArray[row] valueForKey:@"interiorCedarCode"], [self.interiorCedarMaturityCodeArray[row] valueForKey:@"desc"] ];
            NSLog(@" interior cedar maturity code : %@", self.interiorCedarMaturity.text);
        }
        
        [targetTxt resignFirstResponder];
    }
}

// Calculating Survey Check information

// Summarize avoidable pieces with grade Y or better
// Returns a volume value

-(NSDecimalNumber *) calculateBlockSurveyY
{
    NSDecimalNumber *survey = [NSDecimalNumber zero];
    // Sum the calculateStratumSurveyY
    return survey;
}

// Summarize avoidable pieces with grade X or better
// Returns a volume value
-(NSDecimalNumber *) calculateBlockSurveyX
{
    NSDecimalNumber *survey = [NSDecimalNumber zero];
    // Sum the calculateStratumSurveyX
    return survey;
}

// Summarize all avoidable pieces
// Returns a dollar amount
-(NSDecimalNumber *) calculateBlockSurveyNet
{
    NSDecimalNumber *survey = [NSDecimalNumber zero];
    // Sum the calculateStratumSurveyNet
    return survey;
}

// Summarize avoidable pieces with grade Y or better
// Returns a volume value
-(NSDecimalNumber *) calculateBlockCheckY
{
    NSDecimalNumber *check = [NSDecimalNumber zero];
    // Sum the calculateStratumCheckY
    return check;
}

// Summarize avoidable pieces with grade X or better
// Returns a volume value
-(NSDecimalNumber *) calculateBlockCheckX
{
    NSDecimalNumber *check = [NSDecimalNumber zero];
    // Sum the calculateStratumCheckX
    return check;
}

// Summarize all avoidable pieces
// Returns a dollar amount
-(NSDecimalNumber *) calculateBlockCheckNet
{
    NSDecimalNumber *check = [NSDecimalNumber zero];
    // Sum the calculateStratumCheckNet
    return check;
}

// Determine difference between Survey and Check for avoidable pieces with grade Y or better
// Returns a percentage value
-(NSDecimalNumber *) calculateBlockDeltaY
{
    NSDecimalNumber *delta = [NSDecimalNumber zero];
    // Sum the calculateStratumDeltaY
    return delta;
}

// Determine difference between Survey and Check for avoidable pieces with grade X or better
// Returns a percentage value
-(NSDecimalNumber *) calculateBlockDeltaX
{
    NSDecimalNumber *delta = [NSDecimalNumber zero];
    // Sum the calculateStratumDeltaX
    return delta;
}

// Determine difference between Survey and Check for all avoidable pieces
// Returns a percentage amount
-(NSDecimalNumber *) calculateBlockDeltaNet
{
    NSDecimalNumber *delta = [NSDecimalNumber zero];
    // Sum the calculateStratumDeltaY
    return delta;
}



#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) {
        //NSLog(@"Alert view clicked with the cancel button index.");
    }else {
        if([alertView.title isEqualToString:@"Delete Cut Block"]){
            
            [WasteBlockDAO deleteCutBlock:self.wasteBlock];
            
            //reload the downloaded cut block screen
            NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
            //this navigation VIA number of view controllers is....really weird and not a good idea imo - I would not copy this implementation for future work. Maybe this was the only way to implement earlier in Objective-C/XCode days? -Chris Nesmith
            if (numberOfViewControllers == 1) {
                //delete cut block from "create new"
                UIStoryboard* sb = [UIStoryboard storyboardWithName:@"EForWasteBC" bundle:nil];
                
                //SidebarViewController *svc = [sb instantiateViewControllerWithIdentifier:@"SidebarController"];
                CreatedTableViewController *svc =[sb instantiateViewControllerWithIdentifier:@"CreatedTVCSBID"];
                
                [self.navigationController pushViewController:svc animated:YES];
                //[svc performSegueWithIdentifier:@"createdSBSID" sender:self];
                
            }else if (numberOfViewControllers == 2 ){
                
                DownloadedTableViewController *downloadVC =  [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
                [downloadVC.tableView reloadData];
            
                //navigate back to the downloaded cut block screen
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else if (numberOfViewControllers == 3 ){
                // this handle: create cut block, delete cut block, select a created cut block and delete a cut block
                CreatedTableViewController *cVC =  [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
                [cVC.tableView reloadData];
                
                //navigate back to the downloaded cut block screen
                [self.navigationController popViewControllerAnimated:YES];

            }else if( numberOfViewControllers == 4){

                DownloadedTableViewController *downloadVC =  [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
                [downloadVC.tableView reloadData];
                
                //navigate back to the downloaded cut block screen
                [self.navigationController popViewControllerAnimated:YES];
            }
            self.wasteBlock = nil;
            
        }else if([alertView.title isEqualToString:@"Delete New Stratum"]){
            //NSLog(@"Delete new Stratum at row %ld.", (long)alertView.tag);
            WasteStratum *targetStratum = [self.sortedStratums objectAtIndex:alertView.tag];
            
            [WasteBlockDAO deleteStratum:targetStratum usingWB:wasteBlock];
            
            
            NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
            NSSortDescriptor *sort2 = [[NSSortDescriptor alloc ] initWithKey:@"stratumID" ascending:YES];
            
            self.sortedStratums = [[[self.wasteBlock blockStratum] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, sort2, nil]];
            
            [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
            [WasteCalculator calculateRate:self.wasteBlock ];
            [WasteCalculator calculatePiecesValue:self.wasteBlock];
            
            if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
                [WasteCalculator calculateEFWStat:self.wasteBlock];
                [self.efwFooterView setBlockViewValue:self.wasteBlock];
            }else{
                [self.footerStatView setViewValue:self.wasteBlock];
            }
            
            [self saveData];
            [self.stratumTableView reloadData];
            [self viewDidLoad];
            [self checkStratum];
            
        }else if([alertView.title isEqualToString:ADD_STRATIM_TITLE]){
            
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:STANDING_TREE]){
                
                NSString *title = NSLocalizedString(STANDING_TREE_TYPE_TITLE, nil);
                NSString *message = NSLocalizedString(@"Please Select a Assessment Type.", nil);
                NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
                NSString *otherButtonTitleOne = NSLocalizedString(STRE, nil);
                NSString *otherButtonTitleTwo = NSLocalizedString(STRS, nil);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, nil];

                [alert show];
            }else{
                [self saveData];
                [self createStratumAndNavigate:@"" predictionPlot:nil measurePlot:nil];
            }
            
        }else if([alertView.title isEqualToString:STANDING_TREE_TYPE_TITLE]){

            [self saveData];
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:STRS]){
                [self createStratumAndNavigate:@"STRS" predictionPlot:nil measurePlot:nil];
            }else if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:STRE]){
                [self createStratumAndNavigate:@"STRE" predictionPlot:nil measurePlot:nil];
            }

        }else{
            NSString *message = nil;
            if ((long)buttonIndex == 1){
                message = @"Check Summary Report is generated";
                
                CheckSummaryReport *rpt = [CheckSummaryReport alloc];
                [rpt generateReportByBlock: nil];
                
            }else if((long)buttonIndex ==2) {
                message = @"FS703 Report is generated";
                
                CheckSummaryReport *rpt = [CheckSummaryReport alloc];
                [rpt generateReportByStratum: nil];
            }
            NSLog(@"Alert view clicked with button at index %ld.", (long)buttonIndex);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
        
    }
}


// TABLE POPULATION
//
#pragma mark - TableView
// SELECTED STRATUM IN STRATUM TABLE
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    
    if (tableView == stratumTableView )
    {
        // get the selected row i.e. stratum - cell contains .stratum, .type, .area, ...
        StratumTableViewCell *cell = (StratumTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        // get all stratums for the selected row
        NSArray *stratums = [self.wasteBlock.blockStratum allObjects];
        
        // pull out the stratum that we are looking for, using the selected rows stratum field
        for (WasteStratum* stratum in stratums) // (weak) stratum, thats why BUG in next screen ?
        {
            
            //NSLog(@"cell stratum ID = %@, stratum.stratumID = %@, cell.stratum = %@, stratum.stratum = %@", cell.stratumID.text, stratum.stratumID, cell.stratum.text, stratum.stratum);
            NSString *test =  cell.stratum.text;
            NSString *test2 = cell.stratumID.text;
            if(((stratum.stratum == nil && cell.stratum.text == nil) || [stratum.stratum isEqualToString:cell.stratum.text]) && [[stratum.stratumID stringValue] isEqualToString: cell.stratumID.text])
            {
                
                if([self.theSegue.identifier isEqualToString:@"selectStratumSegue"])
                {
                    StratumViewController *stratumVC = self.theSegue.destinationViewController;
                    stratumVC.wasteStratum = stratum;
                    stratumVC.wasteBlock = self.wasteBlock;
                    [self saveData];
                    break;
                }
                
            }
        }
    }
    else if (tableView == timbermarkTableView )
    {
        if([self.theSegue.identifier isEqualToString:@"selectTimbermarkSegue"])
        {
            TimbermarkViewController *timbermarkVC = self.theSegue.destinationViewController;
            timbermarkVC.timbermarks = self.wasteBlock.blockTimbermark;
            timbermarkVC.wasteBlock = self.wasteBlock;
        }
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == stratumTableView){
        return [[self.wasteBlock blockStratum] count];
    }
    else if (tableView == timbermarkTableView){
        
        NSLog(@" timbermarkCount = %lu", (unsigned long)[[self.wasteBlock blockTimbermark] count]);
        
        return [[self.wasteBlock blockTimbermark] count];
    }
    else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
     if (!cell) {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
     }
     cell.textLabel.text = [NSString stringWithFormat:@"Row %d", indexPath.row];
     
     return cell;
     */
    
    
    
    if (tableView == timbermarkTableView)
    {
        TimbermarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimbermarkTableCellID"];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"primaryInd" ascending:YES];
        Timbermark *tm = [[[[self.wasteBlock blockTimbermark] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]] objectAtIndex:indexPath.row];
        
        
        
        if( [tm.primaryInd isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            cell.primary.text =  @"Primary";
        }else{
            cell.primary.text =  @"Secondary";
        }
        cell.timbermark.text = tm.timbermark ? tm.timbermark : @"";
        if(tm.timbermarkMonetaryReductionFactorCode.monetaryReductionFactorCode){
            if([tm.timbermarkMonetaryReductionFactorCode.monetaryReductionFactorCode isEqualToString:@"A"]){
                cell.reductionFactor.text = @"Applied";
            }else if([tm.timbermarkMonetaryReductionFactorCode.monetaryReductionFactorCode isEqualToString:@"B"]){
                cell.reductionFactor.text = @"Not Applied";
            }
        }else{
            cell.reductionFactor.text = @"";
        }
        cell.aValue.text = tm.avoidable && !isnan([tm.avoidable doubleValue]) ? [[NSString alloc] initWithFormat:@"%0.2f",[tm.avoidable floatValue]] : @"";
        cell.bValue.text = tm.benchmark && !isnan([tm.benchmark doubleValue]) ? [[NSString alloc] initWithFormat:@"%0.2f",[tm.benchmark floatValue]] : @"";
        cell.wmrf.text =  tm.wmrf && !isnan([tm.wmrf doubleValue]) ? [[NSString alloc] initWithFormat:@"%0.4f",[tm.wmrf floatValue]] : @"";
        cell.area.text = tm.area && !isnan([tm.area doubleValue]) ? [NSString stringWithFormat:@"%0.2f", [tm.area floatValue] ] : @"";
        
        /*
        NSLog(@"TIMBERMARK = %@", cell.primary.text);
        NSLog(@" A = %@ ", tm.avoidable);
        NSLog(@" B = %@ ", tm.benchmark);
        NSLog(@" redFactor = %@", cell.reductionFactor.text);
        NSLog(@" wmrf = %@ ", tm.wmrf);
        NSLog(@" area = %@ ", tm.area);
        */
        
        return cell;
    }
    else if (tableView == stratumTableView )
    {
        StratumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StratumTableCellID"];
        WasteStratum *stm =[self.sortedStratums objectAtIndex:indexPath.row];
        
        // labels
        cell.stratumType.text = stm.stratumStratumTypeCode.stratumTypeCode ? stm.stratumStratumTypeCode.stratumTypeCode : @"";
        
        if (stm.stratumStratumTypeCode.stratumTypeCode && [stm.stratumStratumTypeCode.stratumTypeCode isEqualToString:@"S"]){
            cell.wasteType.text = @"S";
            cell.wasteLevel.text = stm.stratumAssessmentMethodCode ? stm.stratumAssessmentMethodCode.assessmentMethodCode : @"";
            cell.harvestMethod.text = @"T";
            cell.plotSize.text = @"R";
        }else{
            cell.wasteType.text = stm.stratumWasteTypeCode ? stm.stratumWasteTypeCode.wasteTypeCode : @"";
            cell.wasteLevel.text = stm.stratumWasteLevelCode ? [NSString stringWithFormat:@"%@", stm.stratumWasteLevelCode.wasteLevelCode] : @"";
            cell.harvestMethod.text = stm.stratumHarvestMethodCode.harvestMethodCode ? stm.stratumHarvestMethodCode.harvestMethodCode : @"";
            cell.plotSize.text = stm.stratumPlotSizeCode ? stm.stratumPlotSizeCode.plotSizeCode : @"";
        }
        
        if([self.wasteBlock.userCreated intValue] == 1){
            cell.area.text = stm.stratumSurveyArea && [stm.stratumSurveyArea floatValue] > 0? [NSString stringWithFormat:@"%.2f", [stm.stratumSurveyArea floatValue]] : @"0";
        }else{
            cell.area.text = stm.stratumArea && [stm.stratumArea floatValue] > 0 ? [NSString stringWithFormat:@"%.2f", [stm.stratumArea floatValue]] : @"0";
        }
        
        
        // hidden label
        cell.stratum.text = stm.stratum;

        cell.stratumID.text = [stm.stratumID stringValue];
        
        //NSLog(@" Stratum ID %@ ", stm.stratumID);
        //NSLog(@" Stratum %@ ", stm.stratum);
        
        
        if ([stm.stratumID integerValue] < 0){
            // store the row number into the tag
            cell.deleteButton.tag = indexPath.row;
            cell.deleteButton.hidden = NO;
        }else{
            cell.deleteButton.tag = 0;
            cell.deleteButton.hidden = YES;
        }
     
        return cell;
    }
    else{
        return nil;
    }
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    self.theSegue = segue;
    
    NSLog(@"%@", segue.identifier);
    
    
    if ( [segue.identifier isEqualToString:@"reportFromBlockSegue"]){
        
        ReportGeneratorTableViewController *reportGeneratorTableVC = (ReportGeneratorTableViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        reportGeneratorTableVC.wasteBlock = self.wasteBlock;
        reportGeneratorTableVC.wasteStratum = nil;
        reportGeneratorTableVC.wastePlot = nil;
        
        
        // save data
        [self saveData];
    }
    else if ( [segue.identifier isEqualToString:@"selectTimbermarkSegue"] ){
        
        TimbermarkViewController *timbermarkVC = (TimbermarkViewController *)[segue destinationViewController];
        timbermarkVC.wasteBlock = self.wasteBlock;
        timbermarkVC.timbermarks = [self.wasteBlock blockTimbermark];
        
        // save data
        [self saveData];
    }
    else if ( [segue.identifier isEqualToString:@"editTimbermarkSegue"]){
        
        TimbermarkViewController *timbermarkVC = (TimbermarkViewController *)[segue destinationViewController];
        timbermarkVC.wasteBlock = self.wasteBlock;
        timbermarkVC.timbermarks = [self.wasteBlock blockTimbermark];
        
        // save data
        [self saveData];
    }
    
}

- (void) populateFromObject{
    
    // POPULATING FROM THE OBJECT
    //
    self.reportingUnitNo.text = wasteBlock.reportingUnit && [wasteBlock.reportingUnit intValue] > 0? [wasteBlock.reportingUnit stringValue] : @"";
    self.cutBlock.text = wasteBlock.cutBlockId ? wasteBlock.cutBlockId : @"";
    self.cuttingPermit.text = wasteBlock.cuttingPermitId ? wasteBlock.cuttingPermitId : @"";
    
    self.licence.text = wasteBlock.licenceNumber ? wasteBlock.licenceNumber : @"";
    self.location.text = wasteBlock.location ? wasteBlock.location  : @""; // BPRD - not pre-populated
    
    self.loggedFrom.text = wasteBlock.yearLoggedFrom && [wasteBlock.yearLoggedFrom intValue] > 0 ? [wasteBlock.yearLoggedFrom stringValue] : @"";
    self.loggedTo.text = wasteBlock.yearLoggedTo && [ wasteBlock.yearLoggedTo intValue] > 0 ? [wasteBlock.yearLoggedTo stringValue] : @"";
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM-dd-yyyy"];
    self.loggingCompleteTextField.text = wasteBlock.loggingCompleteDate ? [dateFormat stringFromDate:wasteBlock.loggingCompleteDate] : @"";
    
    self.surveyDate.text = wasteBlock.surveyDate ? [[NSString alloc] initWithFormat:@"%@", [dateFormat stringFromDate:wasteBlock.surveyDate]] : @"";
    self.netArea.text = wasteBlock.netArea && [wasteBlock.netArea floatValue] > 0.0 ? [[NSString alloc] initWithFormat:@"%.02f", wasteBlock.netArea.floatValue] : @"";
    self.surveyNetAreaTextField.text = wasteBlock.surveyArea && [wasteBlock.surveyArea floatValue] > 0 ? [[NSString alloc] initWithFormat:@"%.02f", wasteBlock.surveyArea.floatValue] : @"";
    
    self.npNfArea.text = wasteBlock.npNFArea && [wasteBlock.npNFArea floatValue] > 0.0? [[NSString alloc] initWithFormat:@"%0.2f", wasteBlock.npNFArea.floatValue] : @"";
    
    self.maturity.text = wasteBlock.blockMaturityCode ? [[NSString alloc] initWithFormat:@"%@ - %@", wasteBlock.blockMaturityCode.maturityCode, wasteBlock.blockMaturityCode.desc] : @"";
    self.checkMaturity.text = wasteBlock.blockCheckMaturityCode ? [[NSString alloc] initWithFormat:@"%@ - %@", wasteBlock.blockCheckMaturityCode.maturityCode, wasteBlock.blockCheckMaturityCode.desc] : @"";
    
    if ([self.wasteBlock.regionId intValue] == InteriorRegion ){
        self.maturity.text = wasteBlock.blockSiteCode ? [[NSString alloc] initWithFormat:@"%@ - %@", wasteBlock.blockSiteCode.siteCode, wasteBlock.blockSiteCode.desc] : @"";
        self.checkMaturity.text = wasteBlock.blockCheckSiteCode ? [[NSString alloc] initWithFormat:@"%@ - %@", wasteBlock.blockCheckSiteCode.siteCode, wasteBlock.blockCheckSiteCode.desc] : @"";
        InteriorCedarMaturityCode *icm = [self.interiorCedarMaturityCodeArray objectAtIndex:[self.interiorCedarMaturityPicker selectedRowInComponent:0]];
        self.interiorCedarMaturity.text = [[NSString alloc] initWithFormat:@"%@ - %@", icm.interiorCedarCode, icm.desc];
        self.interiorCedarMaturity.text = wasteBlock.blockInteriorCedarMaturityCode ? [[NSString alloc] initWithFormat:@"%@ - %@", wasteBlock.blockInteriorCedarMaturityCode.interiorCedarCode, wasteBlock.blockInteriorCedarMaturityCode.desc] : self.interiorCedarMaturity.text;
    }else if([self.wasteBlock.regionId intValue] == CoastRegion){
        self.maturity.text = wasteBlock.blockMaturityCode ? [[NSString alloc] initWithFormat:@"%@ - %@", wasteBlock.blockMaturityCode.maturityCode, wasteBlock.blockMaturityCode.desc] : @"";
        self.checkMaturity.text = wasteBlock.blockCheckMaturityCode ? [[NSString alloc] initWithFormat:@"%@ - %@", wasteBlock.blockCheckMaturityCode.maturityCode, wasteBlock.blockCheckMaturityCode.desc] : @"";
         for (Timbermark *tm in [wasteBlock.blockTimbermark allObjects]){
             self.benchmarkField.text = tm.benchmark && [tm.benchmark floatValue] >= 0 && [tm.benchmark floatValue] <= 99 ? [[NSString alloc ] initWithFormat:@"%ld",(long)[tm.benchmark floatValue]] : @"";
         }
    }

    //self.checkMaturityLabel.text = [ [self codeFromText:self.checkMaturity.text] isEqualToString:@"M"] ? @"Greater than 8R" : @"Top greater than 5R";
    self.returnNumber.text = wasteBlock.returnNumber && [wasteBlock.returnNumber intValue] > 0 ? [wasteBlock.returnNumber stringValue] : @"";
    self.surveyorLicence.text = wasteBlock.surveyorLicence ? [[NSString alloc] initWithFormat:@"%@", wasteBlock.surveyorLicence] : @"";
    
    self.wasteCheckerName.text = wasteBlock.checkerName ? [[NSString alloc] initWithFormat:@"%@", wasteBlock.checkerName] : @"";
    self.professionalDesignation.text = wasteBlock.professional ? [[NSString alloc] initWithFormat:@"%@", wasteBlock.professional] : @"";
    self.registrationNumber.text = wasteBlock.registrationNumber ? [[NSString alloc] initWithFormat:@"%@", wasteBlock.registrationNumber] : @"";
    self.position.text = wasteBlock.position ? [[NSString alloc] initWithFormat:@"%@", wasteBlock.position] : @"";

    
    self.notes.text = wasteBlock.notes ? [[NSString alloc] initWithFormat:@"%@", wasteBlock.notes] : @"";
    
    if ([self.wasteBlock.userCreated intValue] == 1){
        self.wasteCheckerName.text = wasteBlock.surveyorName ? [[NSString alloc] initWithFormat:@"%@", wasteBlock.surveyorName] : @"";
    }else{
        self.wasteCheckerName.text = wasteBlock.checkerName ? [[NSString alloc] initWithFormat:@"%@", wasteBlock.checkerName] : @"";
    }
    
    [self updateGenerateXMLButtonEnabledState];
    
    //check if the total area of the stratum added up to the block net area
    [self checkStratum];
    
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setBlockViewValue:self.wasteBlock];
    }else{
        [self.footerStatView setViewValue:self.wasteBlock];
    }
    
    [self.footerStatView setDisplayFor:nil screenName:@"block"];

}

- (void) checkStratum{
    // two checks here
    // 1 check the area of stratum sum up to cut block
    // 2 check if cut block contains any non-plot tally card stratum
    
    NSDecimalNumber *stratum_total = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    BOOL containsOcular = NO;
    
    for( WasteStratum *st in [self.wasteBlock.blockStratum allObjects]){
        if([self.wasteBlock.userCreated intValue] == 1){
            if(st.stratumSurveyArea){
                stratum_total = [stratum_total decimalNumberByAdding:st.stratumSurveyArea];
            }
        }else{
            if(st.stratumArea){
                stratum_total = [stratum_total decimalNumberByAdding:st.stratumArea];
            }
        }
        if ([st.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"O"]){
            containsOcular = YES;
        }
    }
    
    NSDecimalNumber *blockArea = [[NSDecimalNumber alloc] initWithInt:0];
    if ([self.wasteBlock.userCreated intValue] == 1){
        if(self.wasteBlock.surveyArea){
            blockArea =  [[NSDecimalNumber alloc] initWithDecimal: [self.wasteBlock.surveyArea decimalValue]];
        }
    }else{
        if(self.wasteBlock.netArea){
            blockArea =  [[NSDecimalNumber alloc] initWithDecimal:[self.wasteBlock.netArea decimalValue]];
        }
    }
    
    if ([stratum_total compare:blockArea] != NSOrderedSame){
        [self.warningStratumArea setHidden:NO];
    }else{
        [self.warningStratumArea setHidden:YES];
    }
    
    if (containsOcular){
        [self.warningStratumInvalid setHidden:NO];
    }else{
        [self.warningStratumInvalid setHidden:YES];
    }
}

- (void) setupStaticData{

    
    /*
     NSManagedObjectContext *context = [self managedObjectContext];
     
     // the object containing data from the CoreData
     self.wasteBlock = [NSEntityDescription insertNewObjectForEntityForName:@"WasteBlock" inManagedObjectContext:context];
     
     [self.wasteBlock  setValue:@"permitID" forKey:@"cuttingPermitId" ];
     //[self.wasteBlock  setValue:@"cutBlockID" forKey:@"cutBlockId"];
     [self.wasteBlock  setValue:@"A19208" forKey:@"licenceNumber"];
     
     [self.wasteBlock  setValue:@"locationTMP" forKey:@"location"];
     [self.wasteBlock  setValue:@2013 forKey:@"yearLoggedFrom"];
     [self.wasteBlock  setValue:@2014 forKey:@"yearLoggedTo"];
     
     NSDate *today = [NSDate date];
     [self.wasteBlock  setValue:today forKey:@"loggingCompleteDate"];
     [self.wasteBlock  setValue:today forKey:@"surveyDate"];
     [self.wasteBlock  setValue:@173.30 forKey:@"netArea"];
     
     [self.wasteBlock  setValue:@173.30 forKey:@"npNFArea"];
     [self.wasteBlock  setValue:@173.30 forKey:@"cruiseArea"];
     
     [self.wasteBlock  setValue:@1 forKey:@"returnNumber"];
     [self.wasteBlock  setValue:@"surveyorLicence" forKey:@"surveyorLicence"];
     [self.wasteBlock  setValue:@"asdfdas" forKey:@"notes"];
     
     self.wasteBlock.checkerName = @"JACK";
     self.wasteBlock.loggingCompleteDate = today;
     self.wasteBlock.surveyDate = today;
     
     
     Timbermark *tm3 = [NSEntityDescription insertNewObjectForEntityForName:@"Timbermark" inManagedObjectContext:context];
     [tm3 setValue:@"TM123" forKey:@"timbermark"];
     [tm3 setValue:@true forKey:@"primaryInd"];
     
     MonetaryReductionFactorCode *mrfc = [NSEntityDescription insertNewObjectForEntityForName:@"MonetaryReductionFactorCode" inManagedObjectContext:context];
     mrfc.monetaryReductionFactorCode = @"monetaryreductionfactorcode";
     tm3.timbermarkMonetaryReductionFactorCode = mrfc;
     
     [self.wasteBlock addBlockTimbermarkObject:tm3];
     
     
     WasteStratum *stm = [NSEntityDescription insertNewObjectForEntityForName:@"WasteStratum" inManagedObjectContext:context];
     [stm setValue:@"ABC123" forKey:@"stratum"];
     [stm setValue:@1.2 forKey:@"stratumArea"];
     
     
     
     StratumTypeCode *stc = [NSEntityDescription insertNewObjectForEntityForName:@"StratumTypeCode" inManagedObjectContext:context];
     stc.stratumTypeCode = @"strmTypeCode";
     stm.stratumStratumTypeCode = stc;
     
     HarvestMethodCode *hmc = [NSEntityDescription insertNewObjectForEntityForName:@"HarvestMethodCode" inManagedObjectContext:context];
     hmc.harvestMethodCode = @"hrvstMethodCode";
     stm.stratumHarvestMethodCode = hmc;
     
     WasteLevelCode *wlc = [NSEntityDescription insertNewObjectForEntityForName:@"WasteLevelCode" inManagedObjectContext:context];
     wlc.wasteLevelCode = @"wstLVLcode";
     stm.stratumWasteLevelCode = wlc;
     
     PlotSizeCode *stratumPSC = [NSEntityDescription insertNewObjectForEntityForName:@"PlotSizeCode" inManagedObjectContext:context];
     stratumPSC.plotSizeCode = @"pltSizeCode";
     stm.stratumPlotSizeCode = stratumPSC;
     
     
     
     WastePlot *wp1 = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
     wp1.plotID = @123;
     
     wp1.plotNumber = @1;
     wp1.baseline = @"A";
     PlotSizeCode *psc = [NSEntityDescription insertNewObjectForEntityForName:@"PlotSizeCode" inManagedObjectContext:context];
     psc.plotSizeCode = @"plotsizecode";
     wp1.plotSizeCode = psc;
     
     wp1.surveyedMeasurePercent = @100;
     ShapeCode *sc = [NSEntityDescription insertNewObjectForEntityForName:@"ShapeCode" inManagedObjectContext:context];
     sc.shapeCode = @"sc";
     wp1.plotShapeCode = sc;
     wp1.returnNumber = @"plot return";
     
     wp1.checkerMeasurePercent = @100;
     wp1.strip = @1;
     wp1.certificateNumber = @"1";
     
     wp1.surveyorName = @"name1";
     wp1.weather = @"weather1";
     wp1.surveyDate = [NSDate date];
     
     
     wp1.assistant = @"plot assistant";
     wp1.checkDate = [NSDate date];
     
     wp1.notes = @"plot notes";
     
     [stm addStratumPlotObject:wp1];
     
     
     
     WastePlot *wp2 = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
     wp2.plotID = @234;
     
     wp2.plotNumber = @2;
     wp2.baseline = @"B";
     PlotSizeCode *psc2 = [NSEntityDescription insertNewObjectForEntityForName:@"PlotSizeCode" inManagedObjectContext:context];
     psc2.plotSizeCode = @"plotsizecode2";
     wp2.plotSizeCode = psc2;
     
     wp2.surveyedMeasurePercent = @100;
     ShapeCode *sc2 = [NSEntityDescription insertNewObjectForEntityForName:@"ShapeCode" inManagedObjectContext:context];
     sc2.shapeCode = @"sc2";
     wp2.plotShapeCode = sc2;
     wp2.returnNumber = @"returnNumber2";
     
     wp2.checkerMeasurePercent = @100;
     wp2.strip = @2;
     wp2.certificateNumber = @"2";
     
     wp2.surveyorName = @"name1";
     wp2.weather = @"weather2";
     wp2.surveyDate = [NSDate date];
     
     
     wp2.assistant = @"assistant2";
     wp2.checkDate = [NSDate date];
     
     wp2.notes = @"notes2";
     
     [stm addStratumPlotObject:wp2];
     
     
     
     WastePlot *wp3 = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
     wp3.plotID = @345;
     
     wp3.plotNumber = @3;
     wp3.baseline = @"C";
     PlotSizeCode *psc3 = [NSEntityDescription insertNewObjectForEntityForName:@"PlotSizeCode" inManagedObjectContext:context];
     psc3.plotSizeCode = @"plotsizecode3";
     wp3.plotSizeCode = psc3;
     
     wp3.surveyedMeasurePercent = @100;
     ShapeCode *sc3 = [NSEntityDescription insertNewObjectForEntityForName:@"ShapeCode" inManagedObjectContext:context];
     sc3.shapeCode = @"sc3";
     wp3.plotShapeCode = sc3;
     wp3.returnNumber = @"plot return3";
     
     wp3.checkerMeasurePercent = @100;
     wp3.strip = @3;
     wp3.certificateNumber = @"3";
     
     wp3.surveyorName = @"name3";
     wp3.weather = @"weather3";
     wp3.surveyDate = [NSDate date];
     
     
     wp3.assistant = @"plot assistant3";
     wp3.checkDate = [NSDate date];
     
     wp3.notes = @"plot notes3";
     
     [stm addStratumPlotObject:wp3];
     
     
     
     
     WastePlot *wp4 = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
     wp4.plotID = @456;
     
     wp4.plotNumber = @4;
     wp4.baseline = @"D";
     PlotSizeCode *psc4 = [NSEntityDescription insertNewObjectForEntityForName:@"PlotSizeCode" inManagedObjectContext:context];
     psc4.plotSizeCode = @"plotsizecode4";
     wp4.plotSizeCode = psc4;
     
     wp4.surveyedMeasurePercent = @100;
     ShapeCode *sc4 = [NSEntityDescription insertNewObjectForEntityForName:@"ShapeCode" inManagedObjectContext:context];
     sc4.shapeCode = @"sc4";
     wp4.plotShapeCode = sc4;
     wp4.returnNumber = @"plot return4";
     
     wp4.checkerMeasurePercent = @100;
     wp4.strip = @4;
     wp4.certificateNumber = @"4";
     
     wp4.surveyorName = @"name4";
     wp4.weather = @"weather4";
     wp4.surveyDate = [NSDate date];
     
     
     wp4.assistant = @"plot assistant4";
     wp4.checkDate = [NSDate date];
     
     wp4.notes = @"plot notes4";
     
     [stm addStratumPlotObject:wp4];
     
     [self.wasteBlock addBlockStratumObject:stm];
     
     
     
     
     
     SnowCode *snowc = [NSEntityDescription insertNewObjectForEntityForName:@"SnowCode" inManagedObjectContext:context];
     snowc.snowCode = @"snowCode";
     self.wasteBlock.blockSnowCode = snowc;
     
     
     MaturityCode *mc = [NSEntityDescription insertNewObjectForEntityForName:@"MaturityCode" inManagedObjectContext:context];
     MaturityCode *mc2 = [NSEntityDescription insertNewObjectForEntityForName:@"MaturityCode" inManagedObjectContext:context];
     mc.maturityCode = @"maturityCode";
     mc2.maturityCode = @"checkMaturityCode";
     self.wasteBlock.blockMaturityCode = mc;
     self.wasteBlock.blockCheckMaturityCode = mc2;
     */


}

#pragma mark - Core data related function

- (void) storeExportUserData:(ExportUserData *)existingData using:(NSArray<UITextField *> *) textfields {
    existingData.districtCode = textfields[0].text;
    existingData.clientCode = textfields[1].text;
    existingData.licenseeContact = textfields[2].text;
    existingData.telephoneNumber = textfields[3].text;
    existingData.emailAddress = textfields[4].text;
    
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    [context save:&error];
    
    if( error != nil){
        NSLog(@" Error when saving export/submission user data into Core Data: %@", error);
    }
}

- (void) createStratumAndNavigate:(NSString *)stratumType predictionPlot:(NSNumber*)predPlot measurePlot:(NSNumber*)mp{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WasteStratum *stm = [NSEntityDescription insertNewObjectForEntityForName:@"WasteStratum" inManagedObjectContext:context];
    
    // find the smallest stratum ID in the cut block
    int new_id = 0;
    
    for ( WasteStratum *stra in [wasteBlock.blockStratum allObjects]){
        if ([stra.stratumID intValue] < new_id){
            new_id = [stra.stratumID intValue];
        }
    }
    
    stm.notes = nil;
    stm.stratumArea = [[NSDecimalNumber alloc] initWithFloat:0.0];
    stm.stratumID = [NSNumber numberWithInt:new_id - 1];
    stm.totalEstimatedVolume = @0;
    stm.stratumBlock = nil;
    stm.predictionPlot = predPlot;
    stm.orgPredictionPlot = predPlot;
    stm.measurePlot = mp;
    stm.orgMeasurePlot = mp;
    stm.n1sample = @"";
    stm.n2sample = @"";
    stm.fixedSample = @"";
    stm.ratioSamplingLog = @"";
    stm.stratumWasteLevelCode = nil;
    if ([self.wasteBlock.userCreated intValue] ==1){
        [stm setIsSurvey:[NSNumber numberWithBool:YES]];
        [stm setStratumArea:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
        [stm setStratumSurveyArea:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
        
        if([wasteBlock.regionId integerValue] == CoastRegion){
            stm.stratumCoastStat = [WasteBlockDAO createEFWCoastStat];
        }else if([wasteBlock.regionId integerValue] == InteriorRegion){
            stm.stratumInteriorStat = [WasteBlockDAO createEFWInteriorStat];
        }
    }else{
        [stm setIsSurvey:[NSNumber numberWithBool:NO]];
        [stm setStratumArea:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
        [stm setStratumSurveyArea:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
    }

    if ([stratumType isEqualToString:@"STRS"]){
        stm.stratum = @"STRS";
        stm.stratumStratumTypeCode = (StratumTypeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"stratumTypeCode" code:@"S"];
        stm.stratumHarvestMethodCode = (HarvestMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"harvestMethodCode" code:@"T"];
        stm.stratumPlotSizeCode = (PlotSizeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"plotSizeCode" code:@"S"];
        stm.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:@"S"];
        stm.stratumWasteTypeCode = (WasteTypeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"wasteTypeCode" code:@"S"];
        
        [stm addStratumPlotObject:[self createEmptyPlot:self.wasteBlock]];
        
    }else if([stratumType isEqualToString:@"STRE"]){
        stm.stratum = @"STRE";
        stm.stratumStratumTypeCode = (StratumTypeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"stratumTypeCode" code:@"S"];;
        stm.stratumHarvestMethodCode = (HarvestMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"harvestMethodCode" code:@"T"];
        stm.stratumPlotSizeCode = (PlotSizeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"plotSizeCode" code:@"E"];
        stm.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:@"E"];
        stm.stratumWasteTypeCode = (WasteTypeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"wasteTypeCode" code:@"S"];

        [stm addStratumPlotObject:[self createEmptyPlot:self.wasteBlock]];
    }else{
        stm.stratum = @"";
        stm.stratumStratumTypeCode = nil;
        stm.stratumHarvestMethodCode = nil;
        stm.stratumPlotSizeCode = (PlotSizeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"plotSizeCode" code:@"0"];
        stm.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:@"P"];
    }
    
    [self.wasteBlock addBlockStratumObject:stm];
    
    
    
    StratumViewController *stratumVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stratumViewController"];
    stratumVC.wasteStratum = stm;
    stratumVC.wasteBlock = self.wasteBlock;
    
    // UPDATE stratums
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc ] initWithKey:@"stratumID" ascending:YES];
    
    self.sortedStratums = [[[self.wasteBlock blockStratum] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, sort2, nil]];
    
    if(stm.predictionPlot){
        // assume this is ratio sampling stratum, generate the sample here.
        [self generateSample:stm];
    }
    
    // save data
    [self saveData];
    [self viewDidLoad];
    
    [self.navigationController pushViewController:stratumVC animated:YES];
}

-(void)generateSample:(WasteStratum*)ws{

    //TODO : do the random pick to set n1sample and n2sample here
    ws.n1sample = @"1,2,3,4,5,6,7";
    ws.n2sample = @"6:0.2222;";
    
}
/*
-(void) promptForPredictionPlot{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ratio Sampling Stratum"
                                                                   message:@"Please enter :\n prediction plot number\n "
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Prediction Plot", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Prediction Plot", nil);
        textField.text               = @"18";
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 8;
        textField.delegate           = self;
    }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Measure Plot", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Measure Plot", nil);
        textField.text               = @"6";
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 8;
        textField.delegate           = self;
    }];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self validatePromptPredictionPlot:alert];
                                                              }];
    

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) validatePromptPredictionPlot:(UIAlertController*) alert{
    BOOL isValid = YES;
    NSNumber* pp = nil;
    NSNumber* mp = nil;
    
    for(UITextField* tf in alert.textFields){
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Prediction Plot", nil)]){
            pp = [[NSNumber alloc] initWithInteger:[tf.text integerValue]];
            if ([pp integerValue] > 20 || [pp integerValue] < 16){
                isValid = NO;
            }
        }
         Not using mp for now
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Measure Plot", nil)]){
            mp = [[NSNumber alloc] initWithInteger:[tf.text integerValue]];
            if ([pp integerValue] > 20 || [pp integerValue] < 16){
                isValid = NO;
            }
        }
 
    }

    if (isValid){
        [self saveData];
        [self createStratumAndNavigate:@"" predictionPlot:pp measurePlot:mp];
    }else{
        
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil)
                                                                              message:@"Number of estimation plots is outside recommended range, are you sure?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self presentViewController:alert animated:YES completion:nil];
                                                         }];
        UIAlertAction* continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil) style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [self saveData];
                                                                   [self createStratumAndNavigate:@"" predictionPlot:pp measurePlot:mp];
                                                               }];
        [warningAlert addAction:okAction];
        [warningAlert addAction:continueAction];
        
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
}
 */

-(WastePlot *) createEmptyPlot:(WasteBlock *)wb{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePlot *wp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
    wp.assistant = @"";
    wp.baseline = @"";
    wp.certificateNumber = @"";
    wp.checkDate = [NSDate date];
    wp.notes = @"";
    wp.plotID = @0;
    wp.plotNumber = [[NSNumber alloc] initWithLong: 1];
    wp.strip = @0;
    wp.surveyDate = [NSDate date];
    wp.weather = @"";
    wp.plotPiece = nil;
    wp.plotShapeCode = nil;
    wp.plotSizeCode = nil;
    wp.plotStratum = nil;
    
    if (wb.returnNumber && !isnan([wb.returnNumber intValue])){
        wp.returnNumber = [wb.returnNumber stringValue];
    }else{
        wp.returnNumber = @"";
    }
    wp.certificateNumber = [NSString stringWithString:wb.surveyorLicence];
    
    if ([self.wasteBlock.userCreated intValue] ==1){
        [wp setIsSurvey:[NSNumber numberWithBool:YES]];
        wp.surveyedMeasurePercent = [[NSNumber alloc] initWithInteger:100];
        wp.checkerMeasurePercent = [[NSNumber alloc] initWithInteger:0];
        wp.surveyorName = wb.surveyorName;
        if([wasteBlock.regionId integerValue] == CoastRegion){
            wp.plotCoastStat = [WasteBlockDAO createEFWCoastStat];
        }else if([wasteBlock.regionId integerValue] == InteriorRegion){
            wp.plotInteriorStat = [WasteBlockDAO createEFWInteriorStat];
        }
    }else{
        [wp setIsSurvey:[NSNumber numberWithBool:NO]];
        wp.surveyedMeasurePercent = [[NSNumber alloc] initWithInteger:100];
        wp.checkerMeasurePercent = [[NSNumber alloc] initWithInteger:100];
        wp.surveyorName = wb.checkerName;
    }
    
    return wp;
}

#pragma mark - other private functions
- (void)toggleUI:(NSNumber *)userCreatedCutBlock{
    // since the application is designed for downloaded cut block, only modify the UI for user created cut block
    if ([self.wasteBlock.userCreated intValue] == 1){
        //for user created cut block
        
        //enable the disabled field
        [self.cuttingPermit setEnabled:YES];
        [self.cutBlock setEnabled:YES];
        [self.licence setEnabled:YES];
        [self.location setEnabled:YES];
        [self.loggedTo setEnabled:YES];
        [self.loggedFrom setEnabled:YES];
        [self.loggingCompleteTextField setEnabled:YES];
        [self.surveyDate setEnabled:YES];
        [self.npNfArea setEnabled:YES];
        [self.maturity setEnabled:YES];
        [self.returnNumber setEnabled:YES];
        [self.surveyorLicence setEnabled:YES];
        [self.surveyNetAreaTextField setEnabled:YES];
        [self.reportingUnitNo setEnabled:YES];

        [self.checkMaturityLabel setHidden:YES];
        [self.checkMaturity setHidden:YES];
        [self.checkNetAreaLabel setHidden:YES];
        [self.netArea setHidden:YES];
        
        self.checkerLabel.text = @"WASTE Surveyor";
        
    }else{
        //Because there is no way to set the disable background color, we change the background color for disabled field
        [self.cuttingPermit setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.cutBlock setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.licence setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.location setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.loggedTo setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.loggedFrom setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.loggingCompleteTextField setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.surveyDate setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.npNfArea setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.maturity setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.returnNumber setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.surveyorLicence setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.surveyNetAreaTextField setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.reportingUnitNo setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    }
}

@end
