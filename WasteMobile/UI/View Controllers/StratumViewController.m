//
//  StratumViewController.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "DataEndorsementViewController.h"
#import "StratumViewController.h"
#import "PlotTableViewCell.h"
#import "AggregatePlotTableViewCell.h"
#import "AggregatePileTableViewCell.h"
#import "AggregatePackingRatioPlotTableViewCell.h"
#import "PackingRatioTableViewCell.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "WastePiece.h"
#import "StratumTypeCode.h"
#import "WasteLevelCode.h"
#import "HarvestMethodCode.h"
#import "CodeDAO.h"
#import "PlotSizeCode.h"
#import "WasteTypeCode.h"
#import "MaterialKindCode.h"
#import "ButtEndCode.h"
#import "WasteCalculator.h"
#import "AssessmentMethodCode.h"
#import "UIColor+WasteColor.h"

#import "BlockViewController.h"
#import "WasteBlock.h"
#import "PlotViewController.h"
#import "PileViewController.h"

#import "ShapeCode.h"
#import "PileShapeCode+CoreDataClass.h"
#import "ReportGeneratorTableViewController.h"
#import "Timer.h"
#import "PlotSampleGenerator.h"
#import "PlotSelectorLog.h"
#import "Constants.h"
#import "WasteBlockDAO.h"
#import "WastePile+CoreDataClass.h"
#import "WastePlotValidator.h"

@class UIAlertView;

@interface StratumViewController ()
@property (nonatomic) PileShapeCode* currentpile;
@end

@implementation StratumViewController


@synthesize versionLabel, downArrowImage;
@synthesize wasteBlock, wasteStratum, plotTableView, packingRatioTableView, aggregatePlotTableView, aggregatePileTableView, aggregatePackingRatioPlotTableView, sortColumn, sortLicense, sortCuttingPermit, sortCutblock, sortLicenseAPR, sortCutblockAPR, sortPlotNumberAPR, sortCuttingPermitAPR;

static NSString *const DEFAULT_DISPERSED_PRED_PLOT = @"18";
static NSString *const DEFAULT_DISPERSED_MEASURE_PLOT = @"6";
static NSString *const DEFAULT_ACCU_PRED_PLOT = @"12";
static NSString *const DEFAULT_ACCU_MEASURE_PLOT = @"4";

NSInteger orignialWasteTypeRow;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void) setupLists
{
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratumTypeCode" ascending:YES];
    self.stratumTypeArray = [[[CodeDAO sharedInstance] getStratumTypeCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    sort = [[NSSortDescriptor alloc ] initWithKey:@"effectiveDate" ascending:YES];
    self.harvestMethodArray = [[[CodeDAO sharedInstance] getHarvestMethodCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    sort = [[NSSortDescriptor alloc ] initWithKey:@"effectiveDate" ascending:YES];
    self.assessmentSizeArray =  [[[CodeDAO sharedInstance] getPlotSizeCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    sort = [[NSSortDescriptor alloc ] initWithKey:@"effectiveDate" ascending:YES];
    self.wasteLevelArray =  [[[CodeDAO sharedInstance] getWasteLevelCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    sort = [[NSSortDescriptor alloc ] initWithKey:@"effectiveDate" ascending:YES];
    
    self.wasteTypeArray =  [[[CodeDAO sharedInstance] getWasteTypeCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.areaHa.delegate = self;
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // pickers values
    [self setupLists];
    
    // SHAPE PICKER
    //
    self.harvestPicker = [[UIPickerView alloc] init];
    self.harvestPicker.dataSource = self;
    self.harvestPicker.delegate = self;
    self.harvestPicker.tag = 2;
    self.harvestMethod.inputView = self.harvestPicker;
    
    UITapGestureRecognizer *gr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(harvestPickerRecognizer:)];
    [self.harvestPicker addGestureRecognizer:gr2];
    gr2.delegate = self;
    
    // ASSESSMENT/SIZE PICKER
    //
    self.sizePicker = [[UIPickerView alloc] init];
    self.sizePicker.dataSource = self;
    self.sizePicker.delegate = self;
    self.sizePicker.tag = 3;
    self.assesmentSize.inputView = self.sizePicker;
    
    UITapGestureRecognizer *gr3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sizePickerRecognizer:)];
    [self.sizePicker addGestureRecognizer:gr3];
    gr3.delegate = self;
    
    // WASTELEVEL PICKER
    //
    self.wasteLevelPicker = [[UIPickerView alloc] init];
    self.wasteLevelPicker.dataSource = self;
    self.wasteLevelPicker.delegate = self;
    self.wasteLevelPicker.tag = 4;
    self.wasteLevel.inputView = self.wasteLevelPicker;
    
    UITapGestureRecognizer *gr4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wasteLevelPickerRecognizer:)];
    [self.wasteLevelPicker addGestureRecognizer:gr4];
    gr4.delegate = self;
    
    self.wasteTypePicker =[[UIPickerView alloc] init];
    self.wasteTypePicker.dataSource = self;
    self.wasteTypePicker.delegate = self;
    self.wasteTypePicker.tag = 5;
    self.wasteType.inputView = self.wasteTypePicker;
    
    UITapGestureRecognizer *gr5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wasteTypePickerRecognizer:)];
    [self.wasteTypePicker addGestureRecognizer:gr5];
    gr5.delegate = self;
    
    // KEYBOARD DISMISALL
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    if ([self.wasteBlock.userCreated intValue] == 1){
        // for user created cut block, change the IU
        
        [self.checkAreaLabel setText:@"Area (ha)"];
        [self.surveyAreaLabel setHidden:YES];
    }
    
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
    {
        if ([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]) {
            self.plotTableView.hidden = TRUE;
            self.packingRatioTableView.hidden = TRUE;
            self.aggregatePlotTableView.hidden = TRUE;
            self.aggregatePackingRatioPlotTableView.hidden = FALSE;
            
        } else {
            self.plotTableView.hidden = TRUE;
            self.packingRatioTableView.hidden = TRUE;
            self.aggregatePlotTableView.hidden = FALSE;
            self.aggregatePackingRatioPlotTableView.hidden = TRUE;
        }
    } else {
        if ([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]) {
            self.plotTableView.hidden = TRUE;
            self.packingRatioTableView.hidden = FALSE;
            self.aggregatePlotTableView.hidden = TRUE;
            self.aggregatePackingRatioPlotTableView.hidden = TRUE;
        } else {
            self.plotTableView.hidden = FALSE;
            self.packingRatioTableView.hidden = TRUE;
            self.aggregatePlotTableView.hidden = TRUE;
            self.aggregatePackingRatioPlotTableView.hidden = TRUE;
        }
    }
    
    // POPULATE FROM OBJECT TO VIEW
    [self populateFromObject];
    int i = 0;
    for(WasteTypeCode *wtc in self.wasteTypeArray)
    {
        if([wtc.wasteTypeCode isEqualToString:wasteStratum.stratumWasteTypeCode.wasteTypeCode])
        {
            orignialWasteTypeRow = i;
            break;
        }
        i++;
    }
    
    // Populate version number
    [versionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteVersionNumber"]];
//    [self.packingRatioTableView setHidden:YES];
}

- (NSInteger)numberOfDecimalPlaces:(NSNumberFormatter *)numberFormatter string:(NSString *)string {
    NSRange range = [string rangeOfString:numberFormatter.decimalSeparator];
    if (range.location != NSNotFound) {
        return string.length - range.location - 1;
    }
    return 0;
}



-(IBAction)sortPlots:(id)sender{
    
    NSString *key = @"";
    if(sender == self.sortLicense){
        key = @"aggregateLicence";
    } else if(sender == self.sortCuttingPermit){
        key = @"aggregateCuttingPermit";
    } else if(sender == self.sortCutblock){
        key = @"aggregateCutblock";
    } else if(sender == self.sortPlotNumber) {
        key = @"plotNumber";
    } else if (sender == self.sortLicenseAPR) {
        key = @"licence";
    } else if (sender == self.sortCuttingPermitAPR) {
        key = @"cuttingPermit";
    } else if (sender == self.sortCutblockAPR) {
        key = @"block";
    } else if (sender == self.sortPlotNumberAPR) {
        key = @"pileNumber";
    }
    
    BOOL orderASC = NO;
    if([sortColumn rangeOfString:key].location == NSNotFound){
        sortColumn = [NSString stringWithFormat:@"%@ ASC", key];
        orderASC = YES;
    }else{
        if([sortColumn rangeOfString:@"ASC"].location == NSNotFound){
            orderASC = YES;
            sortColumn = [NSString stringWithFormat:@"%@ ASC", key];
        }else{
            sortColumn = [NSString stringWithFormat:@"%@ DESC", key];
        }
    }
    NSSortDescriptor *sd = [[NSSortDescriptor alloc ] initWithKey:key ascending:orderASC];
    if (![self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]) {
        self.sortedPlots = [[NSMutableArray alloc] initWithArray:[self.sortedPlots sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    } else {
        self.sortedPiles = [[NSMutableArray alloc] initWithArray:[self.sortedPiles sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    }
    
    [self.aggregatePlotTableView reloadData];
    [self.aggregatePackingRatioPlotTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [[Timer sharedManager] setCurrentVC:self];
    
    // UPDATE PLOTS
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES]; // is key ok ? does it actually sort according to it
    self.sortedPlots = [[[self.wasteStratum stratumPlot] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc ] initWithKey:@"pileNumber" ascending:YES];
    self.sortedPiles = [[[self.wasteStratum stratumPile] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort2]];
    
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
    {
        if ([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]) {
            self.plotTableView.hidden = TRUE;
            self.packingRatioTableView.hidden = TRUE;
            self.aggregatePlotTableView.hidden = TRUE;
            self.aggregatePackingRatioPlotTableView.hidden = FALSE;
            
        } else {
            self.plotTableView.hidden = TRUE;
            self.packingRatioTableView.hidden = TRUE;
            self.aggregatePlotTableView.hidden = FALSE;
            self.aggregatePackingRatioPlotTableView.hidden = TRUE;
        }
    } else {
        if ([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]) {
            self.plotTableView.hidden = TRUE;
            self.packingRatioTableView.hidden = FALSE;
            self.aggregatePlotTableView.hidden = TRUE;
            self.aggregatePackingRatioPlotTableView.hidden = TRUE;
        } else {
            self.plotTableView.hidden = FALSE;
            self.packingRatioTableView.hidden = TRUE;
            self.aggregatePlotTableView.hidden = TRUE;
            self.aggregatePackingRatioPlotTableView.hidden = TRUE;
        }
    }
    
    // UPDATE VIEW
    
    if ([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]) {
        if ([wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]) {
            [self.packingRatioTableView reloadData];
        } else {
            [self.aggregatePackingRatioPlotTableView reloadData];
        }
    } else {
        if ([wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]) {
            [self.plotTableView reloadData];
        } else {
            [self.aggregatePlotTableView reloadData];
        }
    }
    
    int row;
    
    // update harvest method picker selected row
    row = 0;
    for (HarvestMethodCode *hmc in self.harvestMethodArray) {
        if([ [self codeFromText:self.harvestMethod.text] isEqualToString:hmc.harvestMethodCode]){
            
            [self.harvestPicker selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }
    
    // update assessment picker selected row
    row = 0;
    for (PlotSizeCode *psc in self.assessmentSizeArray) {
        if([ [self codeFromText:self.assesmentSize.text] isEqualToString:psc.plotSizeCode]){
            
            [self.sizePicker selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }
    
    // update assessment picker selected row
    row = 0;
    for (WasteLevelCode *wlc in self.wasteLevelArray) {
        if([ [self codeFromText:self.wasteLevel.text] isEqualToString:wlc.wasteLevelCode]){
            
            [self.wasteLevelPicker selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }
    
    row = 0;
    for (WasteTypeCode *wlc in self.wasteTypeArray) {
        if([ [self codeFromText:self.wasteType.text] isEqualToString:wlc.wasteTypeCode]){
            
            [self.wasteTypePicker selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }
    
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        if([self.wasteStratum.stratumPile count] > 0){
            [self.totalPile setEnabled:NO];
            [self.continueButton setEnabled:YES];
            [self.assesmentSize setEnabled:NO];
        }
    }else{
        if([self.wasteStratum.stratumPile count] > 0){
            [self.assesmentSize setEnabled:NO];
        }
        if(![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""]){
            [self.addCutblockButton setEnabled:YES];
        }
    }
    [self updateTitle];
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setStratumViewValue:self.wasteStratum];
    }else{
        [self.footerStatView setViewValue:self.wasteStratum];
    }
    [self populateFromObject];
}

// SAVE FROM VIEW TO OBJECT
- (void)saveData{
    
    NSLog(@"SAVE STRATUM");
    
    self.wasteStratum.stratum = [self.navigationItem.title substringWithRange:NSMakeRange(21, self.navigationItem.title.length-21)];
    WastePlotValidator *wpv = [[WastePlotValidator alloc] init];
    NSString *errorMessage = [wpv validatemultipleStratum:self.wasteStratum.stratum wastestratum:self.wasteBlock.blockStratum];
    
    if (![errorMessage isEqualToString:@""]){
        UIAlertView *validateAlert = nil;
        validateAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        validateAlert.tag = ValidEnum;
        [validateAlert show];
    }else{
        
        for (HarvestMethodCode* hmc in self.harvestMethodArray){
            if ([hmc.harvestMethodCode isEqualToString:[self codeFromText:self.harvestMethod.text]] ){
                self.wasteStratum.stratumHarvestMethodCode = hmc;
                break;
            }
        }
        
        
        for (PlotSizeCode* psc in self.assessmentSizeArray){
            if ([psc.plotSizeCode isEqualToString:[self codeFromText:self.assesmentSize.text]] ){
                self.wasteStratum.stratumPlotSizeCode = psc;
                break;
            }
        }
        
        //try to find out the assessment code for new stratum
        if ([self.wasteStratum.stratumID integerValue] < 0){
            if( [[self codeFromText:self.assesmentSize.text] isEqualToString:@"S"] ||
               [[self codeFromText:self.assesmentSize.text] isEqualToString:@"E"] ||
               [[self codeFromText:self.assesmentSize.text] isEqualToString:@"O"] ){
                self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:[self codeFromText:self.assesmentSize.text]];
            }else if ([self.wasteStratum.stratum isEqualToString:@"STRE"]){
                self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:@"E"];
                // skip if this is a standing tree
            }else if([self.wasteStratum.stratum isEqualToString:@"STRS"]){
                self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:@"S"];
            }else if([[self codeFromText:self.assesmentSize.text] isEqualToString:@"R"] && ! ([self.wasteStratum.stratum isEqualToString:@"STRE"] || [self.wasteStratum.stratum isEqualToString:@"STRS"])){
                self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:[self codeFromText:self.assesmentSize.text]];
            }else{
                self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:@"P"];
            }
        }
        for (WasteLevelCode* wlc in self.wasteLevelArray){
            if ([wlc.wasteLevelCode isEqualToString:[self codeFromText:self.wasteLevel.text]] ){
                self.wasteStratum.stratumWasteLevelCode = wlc;
                break;
            }
        }
        
        for (WasteTypeCode* wtc in self.wasteTypeArray){
            if ([wtc.wasteTypeCode isEqualToString:[self codeFromText:self.wasteType.text]] ){
                self.wasteStratum.stratumWasteTypeCode = wtc;
                break;
            }
        }
        
        if( [self.notes.text isEqualToString:@""]){
            self.wasteStratum.notes = nil;
        }else{
            self.wasteStratum.notes = self.notes.text;
        }
        
        // save the data differently for user created cut block
        if (![self.areaHa.text isEqualToString:@""]){
            if ([self.wasteBlock.userCreated intValue] == 1){
                self.wasteStratum.stratumSurveyArea = [[NSDecimalNumber alloc] initWithString:self.areaHa.text];
            }else{
                self.wasteStratum.stratumArea = [[NSDecimalNumber alloc] initWithString:self.areaHa.text];
            }
        }
        
        if (![self.predictionPlot.text isEqualToString:@""]){
            self.wasteStratum.predictionPlot = [[NSNumber alloc] initWithInt:[self.predictionPlot.text intValue]];
            if(!self.wasteStratum.n1sample || [self.wasteStratum.n1sample isEqualToString:@""]){
                self.wasteStratum.orgPredictionPlot = [[NSNumber alloc] initWithInt:[self.predictionPlot.text intValue]];
            }
        }
        if (![self.measurePlot.text isEqualToString:@""]){
            self.wasteStratum.measurePlot = [[NSNumber alloc] initWithInt:[self.measurePlot.text intValue]];
            if(!self.wasteStratum.n1sample || [self.wasteStratum.n1sample isEqualToString:@""]){
                self.wasteStratum.orgMeasurePlot = [[NSNumber alloc] initWithInt:[self.measurePlot.text intValue]];
            }
        }
        double  totalestimatedvolume = 0.0;
        for(WastePlot *wp in [self.wasteStratum.stratumPlot allObjects]){
            totalestimatedvolume = totalestimatedvolume + [wp.plotEstimatedVolume doubleValue];
        }
        self.wasteStratum.totalEstimatedVolume = [[NSDecimalNumber alloc] initWithDouble:totalestimatedvolume];
        NSLog(@"Total Estimated Volume %@", self.wasteStratum.totalEstimatedVolume);
        //determine strutam type
        if(self.wasteStratum.stratumWasteTypeCode && (!self.wasteStratum.stratumStratumTypeCode || ![self.wasteStratum.stratumStratumTypeCode.stratumTypeCode isEqualToString:@"S"])){
            if([self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"D"] || [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"F"] ||
               [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"G"] || [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"H"] ||
               [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"S"] || [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"T"] ){
                self.wasteStratum.stratumStratumTypeCode = (StratumTypeCode*)[[CodeDAO sharedInstance] getCodeByNameCode:@"stratumTypeCode" code:@"D"];
                
            }else if([self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"L"] || [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"R"] ||
                     [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"W"] || [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"C"] ||
                     [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"P"] || [self.wasteStratum.stratumWasteTypeCode.wasteTypeCode isEqualToString:@"O"]){
                self.wasteStratum.stratumStratumTypeCode = (StratumTypeCode*)[[CodeDAO sharedInstance] getCodeByNameCode:@"stratumTypeCode" code:@"A"];
            }
        }
        if(self.wasteStratum.totalNumPile == nil){
            self.wasteStratum.totalNumPile = @(0);
            self.totalPile.text = [self.wasteStratum.totalNumPile stringValue];
        }else{
            self.totalPile.text = [self.wasteStratum.totalNumPile stringValue];
        }
        if(self.wasteStratum.totalPileCounter == nil) {
            self.wasteStratum.totalPileCounter = @(0);
        }
        
        if([self.wasteBlock.regionId intValue] == InteriorRegion){
            if(![self.grade12Percent.text isEqualToString:@""]){
                if([self.grade12Percent.text doubleValue] >= 0.0 && [self.grade12Percent.text doubleValue] <= 100.0 ){
                    self.wasteStratum.grade12Percent = [[NSDecimalNumber alloc] initWithString:self.grade12Percent.text];
                }else{
                    self.wasteStratum.grade12Percent = [[NSDecimalNumber alloc] initWithString:@""];
                    self.grade12Percent.text = @"";
                }
            } else {
                self.wasteStratum.grade12Percent = [[NSDecimalNumber alloc] initWithString:@"0.0"];
            }
            if(![self.grade4Percent.text isEqualToString:@""]){
                if([self.grade4Percent.text doubleValue] >= 0.0 && [self.grade4Percent.text doubleValue] <= 100.0 ){
                    self.wasteStratum.grade4Percent = [[NSDecimalNumber alloc] initWithString:self.grade4Percent.text];
                }else{
                    self.wasteStratum.grade4Percent = [[NSDecimalNumber alloc] initWithString:@""];
                    self.grade4Percent.text = @"";
                }
            } else {
                self.wasteStratum.grade4Percent = [[NSDecimalNumber alloc] initWithString:@"0.0"];
            }
            if(![self.grade5Percent.text isEqualToString:@""]){
                if([self.grade5Percent.text doubleValue] >= 0.0 && [self.grade5Percent.text doubleValue] <= 100.0 ){
                    self.wasteStratum.grade5Percent = [[NSDecimalNumber alloc] initWithString:self.grade5Percent.text];
                }else{
                    self.wasteStratum.grade5Percent = [[NSDecimalNumber alloc] initWithString:@""];
                    self.grade5Percent.text = @"";
                }
            } else {
                self.wasteStratum.grade5Percent = [[NSDecimalNumber alloc] initWithString:@"0.0"];
            }
        }else if([self.wasteBlock.regionId intValue] == CoastRegion){
            if(![self.grade12Percent.text isEqualToString:@""]){
                if([self.grade12Percent.text doubleValue] >= 0.0 && [self.grade12Percent.text doubleValue] <= 100.0 ){
                    self.wasteStratum.gradeJPercent = [[NSDecimalNumber alloc] initWithString:self.grade12Percent.text];
                }else{
                    self.wasteStratum.gradeJPercent = [[NSDecimalNumber alloc] initWithString:@""];
                    self.grade12Percent.text = @"";
                }
            } else {
                self.wasteStratum.gradeJPercent = [[NSDecimalNumber alloc] initWithString:@"0.0"];
            }
            if(![self.grade5Percent.text isEqualToString:@""]){
                if([self.grade5Percent.text doubleValue] >= 0.0 && [self.grade5Percent.text doubleValue] <= 100.0 ){
                    self.wasteStratum.gradeUPercent = [[NSDecimalNumber alloc] initWithString:self.grade5Percent.text];
                }else{
                    self.wasteStratum.gradeUPercent = [[NSDecimalNumber alloc] initWithString:@""];
                    self.grade5Percent.text = @"";
                }
            } else {
                self.wasteStratum.gradeUPercent = [[NSDecimalNumber alloc] initWithString:@"0.0"];
            }
            if(![self.grade4Percent.text isEqualToString:@""]){
                if([self.grade4Percent.text doubleValue] >= 0.0 && [self.grade4Percent.text doubleValue] <= 100.0 ){
                    self.wasteStratum.gradeWPercent = [[NSDecimalNumber alloc] initWithString:self.grade4Percent.text];
                }else{
                    self.wasteStratum.gradeWPercent = [[NSDecimalNumber alloc] initWithString:@""];
                    self.grade4Percent.text = @"";
                }
            } else {
                self.wasteStratum.gradeWPercent = [[NSDecimalNumber alloc] initWithString:@"0.0"];
            }
        }
        if(![self.gradeXPercent.text isEqualToString:@""]){
            if([self.gradeXPercent.text doubleValue] >= 0.0 && [self.gradeXPercent.text doubleValue] <= 100.0 ){
                self.wasteStratum.gradeXPercent = [[NSDecimalNumber alloc] initWithString:self.gradeXPercent.text];
            }else{
                self.wasteStratum.gradeXPercent = [[NSDecimalNumber alloc] initWithString:@""];
                self.gradeXPercent.text = @"";
            }
        } else {
            self.wasteStratum.gradeXPercent = [[NSDecimalNumber alloc] initWithString:@"0.0"];
        }
        if(![self.gradeYPercent.text isEqualToString:@""]){
            if([self.gradeYPercent.text doubleValue] >= 0.0 && [self.gradeYPercent.text doubleValue] <= 100.0 ){
                self.wasteStratum.gradeYPercent = [[NSDecimalNumber alloc] initWithString:self.gradeYPercent.text];
            }else{
                self.wasteStratum.gradeYPercent = [[NSDecimalNumber alloc] initWithString:@""];
                self.gradeYPercent.text = @"";
            }
        } else {
            self.wasteStratum.gradeYPercent = [[NSDecimalNumber alloc] initWithString:@"0.0"];
        }
        
        // Packing Ratio disable these fields on save if they are filled in
        if ([wasteBlock.ratioSamplingEnabled boolValue] && [self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"] && ![self.predictionPlot.text isEqualToString:@""] && ![self.measurePlot.text isEqualToString:@""]) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            NSNumber *predictionNumber = [numberFormatter numberFromString:self.predictionPlot.text];
            NSNumber *measureNumber = [numberFormatter numberFromString:self.measurePlot.text];

            if (predictionNumber && measureNumber && [predictionNumber doubleValue] >= [measureNumber doubleValue]) {
                if (![predictionNumber isEqualToNumber:@0] && ![measureNumber isEqualToNumber:@0]) {
                    self.wasteStratum.isLocked = @YES;
                    [self.predictionPlot setEnabled:NO];
                    [self.predictionPlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
                    [self.measurePlot setEnabled:NO];
                    [self.measurePlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
                }
            }
        }
        
        NSError *error;
        
        // save the whole cut block
        NSManagedObjectContext *context = [self managedObjectContext];
        [context save:&error];
        
        if( error != nil){
            NSLog(@" Error when saving waste block into Core Data: %@", error);
        }
    }
}


// SCREEN METHODS
//
#pragma mark - IBActions
- (void)saveStratum:(id)sender{
    
    [self saveData];
    
    NSString *title = NSLocalizedString(@"Save Stratum", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    [alert show];
    
}
- (IBAction)generateReport:(id)sender{
    NSString *title = NSLocalizedString(@"Reports", nil);
    NSString *message = NSLocalizedString(@"Please select a report to be generated.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Check Summary Report", nil);
    NSString *otherButtonTitleTwo = NSLocalizedString(@"FS702 Report", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, nil];
    
    [alert show];
}
- (IBAction)deletePlot:(id)sender{
    
    NSString *title = NSLocalizedString(@"Delete Plot Confirmation", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Confirm", nil);
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:otherButtonTitleOne style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        UIButton *button = (UIButton *)sender;
        [self deletePlotFrmCoreData:alert plotNumber:button.tag];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)deletePlotFrmCoreData:(UIAlertController*)alert plotNumber:(int)plotNumber{

    WastePlot *targetPlot = [self.sortedPlots objectAtIndex:plotNumber];
    [PlotSampleGenerator deletePlot2:wasteStratum plotNumber:[targetPlot.plotNumber intValue]];
    [self deletePlot:targetPlot targetWastePlot:wasteStratum];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES]; // is key ok ? does it actually sort according to it
    self.sortedPlots = [[[self.wasteStratum stratumPlot] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
    [WasteCalculator calculateRate:self.wasteBlock ];
    [WasteCalculator calculatePiecesValue:self.wasteBlock];
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setStratumViewValue:self.wasteStratum];
    }else{
        [self.footerStatView setViewValue:self.wasteStratum];
    }
    [self.plotTableView reloadData];
    [self.aggregatePlotTableView reloadData];
}


- (IBAction)addRatioPlot:(id)sender{
    [self saveData];
    BOOL isValid = YES;
    if([wasteStratum.fixedSample isEqualToString:@""] ){
        if([self.measurePlot.text isEqualToString:@""] || [self.predictionPlot.text isEqualToString:@""]){
            isValid = NO;
            
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:@"Missing Required Field"
                                                                           message:@"Please enter Prediction Plot and Measure Plot and try again."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }else if([self.measurePlot.text intValue] > [self.predictionPlot.text intValue]){
            isValid = NO;
            
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:@"Invalid Value"
                                                                                  message:@"Measure Plot can't be greater than Prediction Plot. Please enter valid value and try again."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }else if(!wasteStratum.stratumWasteTypeCode){
            isValid = NO;
        
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:@"Missing Required Field"
                                                                                  message:@"Please select Waste Type and try again."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];

        }else{
            [PlotSampleGenerator generatePlotSample2:self.wasteStratum];
        }
    }

    if (isValid){
        [self promptForGreenDryVolume];
    }
}

-(void)promptForGreenDryVolume{
    if([wasteBlock.regionId integerValue] == InteriorRegion){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ratio Sampling Stratum"
                                                                       message:@"Please enter your estimate for:\n- Predicted Plot Volume (m3)"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder        = NSLocalizedString(@"Plot Number", nil);
            textField.accessibilityLabel = NSLocalizedString(@"Plot Number", nil);
            textField.clearButtonMode    = UITextFieldViewModeAlways;
            textField.keyboardType       = UIKeyboardTypeNumberPad;
            textField.tag                = 3;
            textField.delegate           = self;
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder        = NSLocalizedString(@"Predicted Plot Volume (m3)", nil);
            textField.accessibilityLabel = NSLocalizedString(@"Predicted Plot Volume (m3)", nil);
            textField.clearButtonMode    = UITextFieldViewModeAlways;
            textField.keyboardType       = UIKeyboardTypeNumberPad;
            textField.tag                = 3;
            textField.delegate           = self;
        }];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self promptForConfirmVolume:alert];
                                                              }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              }];
        
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else if([wasteBlock.regionId integerValue] == CoastRegion){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ratio Sampling Stratum"
                                                                       message:@"Please enter your estimate for:\n- Predicted Plot Volume (m3)"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder        = NSLocalizedString(@"Plot Number", nil);
            textField.accessibilityLabel = NSLocalizedString(@"Plot Number", nil);
            textField.clearButtonMode    = UITextFieldViewModeAlways;
            textField.keyboardType       = UIKeyboardTypeNumberPad;
            textField.tag                = 3;
            textField.delegate           = self;
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder        = NSLocalizedString(@"Predicted Plot Volume (m3)", nil);
            textField.accessibilityLabel = NSLocalizedString(@"Predicted Plot Volume (m3)", nil);
            textField.clearButtonMode    = UITextFieldViewModeAlways;
            textField.keyboardType       = UIKeyboardTypeNumberPad;
            textField.tag                = 3;
            textField.delegate           = self;
        }];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self promptForConfirmVolume:alert];
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// TABLE VIEW POPULATION
//
#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == ValidEnum){
        //validateion alertview
        if (alertView.cancelButtonIndex == buttonIndex) {

        }else{
            //if the user click "continue" then let user to back to stratum screen
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (alertView.cancelButtonIndex == buttonIndex) {
        //NSLog(@"Alert view clicked with the cancel button index.");
    }
    else {
        if ([alertView.title isEqualToString:@"Endorsement of Data Changes"] && [alertView.message isEqualToString:@"Delete Plot"]){
            
            WastePlot *targetPlot = [self.sortedPlots objectAtIndex:alertView.tag];
            [PlotSampleGenerator deletePlot2:wasteStratum plotNumber:[targetPlot.plotNumber intValue]];
            [self deletePlot:targetPlot targetWastePlot:wasteStratum];
            
            NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES]; // is key ok ? does it actually sort according to it
            self.sortedPlots = [[[self.wasteStratum stratumPlot] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
            [WasteCalculator calculateRate:self.wasteBlock ];
            [WasteCalculator calculatePiecesValue:self.wasteBlock];
            if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
                [WasteCalculator calculateEFWStat:self.wasteBlock];
                [self.efwFooterView setStratumViewValue:self.wasteStratum];
            }else{
                [self.footerStatView setViewValue:self.wasteStratum];
            }
            [self.plotTableView reloadData];
            [self.aggregatePlotTableView reloadData];
            
            //NSLog(@"Delete new plot at row %ld.", (long)alertView.tag);
        }else if ([alertView.title isEqualToString:@"Endorsement of Data Changes"] && [alertView.message isEqualToString:@"Delete Pile"]) {
            WastePile *targetPile = [self.sortedPiles objectAtIndex:alertView.tag];
            [PlotSampleGenerator deletePlot2:wasteStratum plotNumber:[targetPile.pileNumber intValue]];
            [self deletePile:targetPile targetWastePile:wasteStratum];
            
            NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"pileNumber" ascending:YES];
            self.sortedPiles = [[[self.wasteStratum stratumPile] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            // the footer views need to be set to 0, possibly in these functions
//            [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
//            [WasteCalculator calculateRate:self.wasteBlock ];
//            [WasteCalculator calculatePiecesValue:self.wasteBlock];
//            if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
//                [WasteCalculator calculateEFWStat:self.wasteBlock];
//                [self.efwFooterView setStratumViewValue:self.wasteStratum];
//            }else{
//                [self.footerStatView setViewValue:self.wasteStratum];
//            }
            if ([wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]) {
                [self.packingRatioTableView reloadData];
            } else if ([wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]) {
                [self.aggregatePackingRatioPlotTableView reloadData];
            }
            }else{
            
            NSString *message = nil;
            if ((long)buttonIndex == 1){
                message = @"Check Summary Report is generated";
            }else if((long)buttonIndex ==2) {
                message = @"FS703 Report is generated";
            }
            NSLog(@"Alert view clicked with button at index %ld.", (long)buttonIndex);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        }
    }
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == plotTableView || tableView == aggregatePlotTableView) {
        NSInteger count = [self.wasteStratum.stratumPlot count];
        NSInteger result = (count != NSNotFound) ? count : 0;
        return result;
    } else if (tableView == packingRatioTableView || tableView == aggregatePackingRatioPlotTableView) {
        NSInteger count = [self.wasteStratum.stratumPile count];
        NSInteger result = (count != NSNotFound) ? count : 0;
        return result;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView==aggregatePackingRatioPlotTableView) {
        NSLog(@"aggregatePackingRatioPlotTableView");
        AggregatePackingRatioPlotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AggregatePackingRatioPlotTableCellId"];
        
        if ([self.sortedPiles count] > 0) {
            WastePile *pl = ([self.sortedPiles count] == 1) ? [self.sortedPiles objectAtIndex:0] : [self.sortedPiles objectAtIndex:indexPath.row];
            
            NSString *pileNumber = pl.pileNumber ? [NSString stringWithFormat:@"%@", pl.pileNumber] : @"";
            NSString *block = pl.block ? [NSString stringWithFormat:@"%@", pl.block] : @"";
            NSString *cuttingPermit = pl.cuttingPermit ? [NSString stringWithFormat:@"%@", pl.cuttingPermit] : @"";
            NSString *licence = pl.licence ? [NSString stringWithFormat:@"%@", pl.licence] : @"";
            
            cell.plotNumberAPR.text = pileNumber;
            cell.blockIdAPR.text = block;
            cell.cuttingPermitAPR.text = cuttingPermit;
            cell.licenceAPR.text = licence;
            cell.deleteButtonAPR.tag = indexPath.row;
            if ([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]) {
                cell.plotNumberAPR.textColor = [UIColor whiteColor];
                if (pl.isSample && [pl.isSample intValue] == [[NSNumber numberWithBool:TRUE] intValue]) {
                    cell.plotNumberAPR.backgroundColor = [UIColor greenColor];
                } else {
                    cell.plotNumberAPR.backgroundColor = [UIColor redColor];
                }
            } else {
                cell.plotNumberAPR.backgroundColor = [UIColor whiteColor];
                cell.plotNumberAPR.textColor = [UIColor blackColor];
            }
            return cell;
        }
    } else if (tableView == packingRatioTableView) {
        NSLog(@"packingRatioTableView");
        PackingRatioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PackingRatioTableCellId"];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"pileNumber" ascending:YES];
        self.sortedblocks = [[self.wasteStratum.stratumPile allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        WastePile *pl  = ([self.wasteStratum.stratumPile count] == 1) ? [self.sortedblocks objectAtIndex:0] : [self.sortedblocks objectAtIndex:indexPath.row];
        cell.plotNumberPR.text = pl.pileNumber ? [NSString stringWithFormat:@"%@", pl.pileNumber] : @"";
        cell.deleteButtonPR.tag = indexPath.row;
        if ([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]) {
            cell.plotNumberPR.textColor = [UIColor whiteColor];
            if (pl.isSample && [pl.isSample intValue] == [[NSNumber numberWithBool:TRUE] intValue]) {
                cell.plotNumberPR.backgroundColor = [UIColor greenColor];
            } else {
                cell.plotNumberPR.backgroundColor = [UIColor redColor];
            }
        } else {
            cell.plotNumberPR.backgroundColor = [UIColor whiteColor];
            cell.plotNumberPR.textColor = [UIColor blackColor];
        }
        return cell;
    } else if (tableView == plotTableView) {
        NSLog(@"plotTableView");
        PlotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlotTableCellID"];

        WastePlot *pt = ([self.sortedPlots count] == 1) ? [self.sortedPlots objectAtIndex:0] : [self.sortedPlots objectAtIndex:indexPath.row];
   
        if ([self.sortedPlots count] > 0) {
            cell.plotNumber.text = pt.plotNumber ? [NSString stringWithFormat:@"%@", pt.plotNumber] : @"";
            if(pt.isMeasurePlot){
                cell.plotNumber.textColor = [UIColor whiteColor];
                if([pt.isMeasurePlot intValue] == 1){
                    cell.plotNumber.backgroundColor = [UIColor greenColor];
                }else{
                    cell.plotNumber.backgroundColor = [UIColor redColor];
                }
            }else{
                //reset the color
                cell.plotNumber.backgroundColor = [UIColor whiteColor];
                cell.plotNumber.textColor = [UIColor blackColor];
            }
            cell.baseline.text = pt.baseline ? pt.baseline : @"";
            cell.strip.text = pt.strip ? [NSString stringWithFormat:@"%@", pt.strip] : @"";
            cell.measure.text = pt.surveyedMeasurePercent ? [NSString stringWithFormat:@"%@", pt.surveyedMeasurePercent] : @"";
            cell.shape.text = pt.plotShapeCode ? [NSString stringWithFormat:@"%@", pt.plotShapeCode.shapeCode] : @"";
            
            if ([pt.plotID integerValue] == 0 ){
                // store the row number into the tag
                cell.deleteButton.tag = indexPath.row;
            }else{
                cell.deleteButton.hidden = YES;
            }
            return cell;
        }
    } else if (tableView == aggregatePlotTableView) {
        NSLog(@"aggregatePlotTableView");
        NSLog(@"%@",@(tableView.isHidden));
        AggregatePlotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AggregatePlotTableCellID"];
        
        if ([self.sortedPlots count] > 0) {
            WastePlot *pt = ([self.sortedPlots count] == 1) ? [self.sortedPlots objectAtIndex:0] : [self.sortedPlots objectAtIndex:indexPath.row];
            
            cell.plotNumber.text = pt.plotNumber ? [NSString stringWithFormat:@"%@", pt.plotNumber] : @"";
            if(pt.isMeasurePlot){
                cell.plotNumber.textColor = [UIColor whiteColor];
                if([pt.isMeasurePlot intValue] == 1){
                    cell.plotNumber.backgroundColor = [UIColor greenColor];
                }else{
                    cell.plotNumber.backgroundColor = [UIColor redColor];
                }
            }else{
                //reset the color
                cell.plotNumber.backgroundColor = [UIColor whiteColor];
                cell.plotNumber.textColor = [UIColor blackColor];
            }
            cell.baseline.text = pt.baseline ? pt.baseline : @"";
            cell.strip.text = pt.strip ? [NSString stringWithFormat:@"%@", pt.strip] : @"";
            cell.measure.text = pt.surveyedMeasurePercent ? [NSString stringWithFormat:@"%@", pt.surveyedMeasurePercent] : @"";
            cell.shape.text = pt.plotShapeCode ? [NSString stringWithFormat:@"%@", pt.plotShapeCode.shapeCode] : @"";
            cell.license.text = pt.aggregateLicence ? [NSString stringWithFormat:@"%@", pt.aggregateLicence] : @"";
            cell.blockId.text = pt.aggregateCutblock ? [NSString stringWithFormat:@"%@", pt.aggregateCutblock] : @"";
            cell.cuttingPermit.text = pt.aggregateCuttingPermit ? [NSString stringWithFormat:@"%@", pt.aggregateCuttingPermit] : @"";
            
            if ([pt.plotID integerValue] == 0 ){
                // store the row number into the tag
                cell.deleteButton.tag = indexPath.row;
            }else{
                cell.deleteButton.hidden = YES;
            }
            return cell;
        } else {
            cell.plotNumber.text = @"";
            cell.baseline.text = @"";
            cell.measure.text = @"";
            cell.shape.text = @"";
            cell.license.text = @"";
            cell.blockId.text = @"";
            cell.cuttingPermit = @"";
            cell.deleteButton.hidden = YES;
            return cell;
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    long rowIndex = (long)[[self.plotTableView indexPathForRowAtPoint: CGPointMake(10, y - 1)] row];
    
    if (rowIndex + 1 == [self.wasteStratum.stratumPlot count] || rowIndex == 0){
        [self.downArrowImage setHidden:YES];
    }else{
        [self.downArrowImage setHidden:NO];
    }
}

//KEYBOARD DISMISS
//
// ON RETURN
-(IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

// ON BACKGROUND TAP
-(void)dismissKeyboard {
    //[self.notes resignFirstResponder];
    
    [self.view endEditing:YES];
    
}

- (void)harvestPickerRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.harvestPicker.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.harvestPicker.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        // apply the first row
        HarvestMethodCode *hmc = [self.harvestMethodArray objectAtIndex:[self.harvestPicker selectedRowInComponent:0]];
        self.harvestMethod.text = [[NSString alloc] initWithFormat:@"%@ - %@", hmc.harvestMethodCode, hmc.desc];
        [self.harvestMethod resignFirstResponder];
    }
    
     [self updateTitle];
}

- (void)sizePickerRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.sizePicker.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.sizePicker.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        // apply the first row
        PlotSizeCode *psc = [self.assessmentSizeArray objectAtIndex:[self.sizePicker selectedRowInComponent:0]];
        self.assesmentSize.text = [[NSString alloc] initWithFormat:@"%@ - %@", psc.plotSizeCode, psc.desc];
        [self.assesmentSize resignFirstResponder];
    }
    
     [self updateTitle];
}

- (void)wasteLevelPickerRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.wasteLevelPicker.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.wasteLevelPicker.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        // apply the first row
        WasteLevelCode *wlc = [self.wasteLevelArray objectAtIndex:[self.wasteLevelPicker selectedRowInComponent:0]];
        self.wasteLevel.text = [[NSString alloc] initWithFormat:@"%@ - %@", wlc.wasteLevelCode, wlc.desc];
        [self.wasteLevel resignFirstResponder];
    }
    
    [self updateTitle];
    
    
}

- (void)wasteTypePickerRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.wasteTypePicker.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.wasteTypePicker.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        // apply the first row
        WasteTypeCode *wtc = [self.wasteTypeArray objectAtIndex:[self.wasteTypePicker selectedRowInComponent:0]];
        self.wasteType.text = [[NSString alloc] initWithFormat:@"%@ - %@", wtc.wasteTypeCode, wtc.desc];
        [self.wasteType resignFirstResponder];
    }
    
    [self updateTitle];
    
    
}
// enable multiple gesture recognizers, otherwise same row select wont detect taps
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // enable multiple gesture recognition
    return true;
}

// CHARACTER LIMIT CHECK
/*
 TAG 0 = default NO (not editable)
 
 TAG 1 = 256 char max
 
 TAG 2 = 100 char max
 
 TAG 3 =  10 char max
 */
#pragma mark - UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // INPUT VALIDATION
    //
    
    // add pile alert
    if (textField == self.plotNumberTextField) {
        NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return ([string rangeOfCharacterFromSet:nonDigitCharacterSet].location == NSNotFound);
    } else if (textField == self.lengthTextField || textField == self.widthTextField) {
        NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSCharacterSet *decimalCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        if (updatedText.length == 0) {
            // Allow empty string
            return YES;
        }

        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];

        if ([updatedText rangeOfCharacterFromSet:[decimalCharacterSet invertedSet]].location != NSNotFound) {
            return NO;
        }

        NSArray *components = [updatedText componentsSeparatedByString:@"."];

        if (components.count > 2 || (components.count == 2 && [components[1] length] > 1)) {
            // More than one decimal place
            return NO;
        }

        CGFloat floatValue = [updatedText floatValue];
        if (floatValue >= 10000.0) {
            return NO;
        }

        return YES;
    } else if (textField == self.heightTextField) {
        NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSCharacterSet *decimalCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
        if (updatedText.length == 0) {
            // Allow empty string
            return YES;
        }

        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];

        if ([updatedText rangeOfCharacterFromSet:[decimalCharacterSet invertedSet]].location != NSNotFound) {
            return NO;
        }

        NSArray *components = [updatedText componentsSeparatedByString:@"."];

        if (components.count > 2 || (components.count == 2 && [components[1] length] > 1)) {
            // More than one decimal place
            return NO;
        }

        CGFloat floatValue = [updatedText floatValue];
        if (floatValue >= 100.0) {
            return NO;
        }

        return YES;
    }
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str appendString:string];
    NSString *theString = str;
    // FLOAT VALUE ONLY
    if (textField==self.areaHa) {
        NSString *currentText = textField.text;
        
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
        NSString *newText = [currentText stringByReplacingCharactersInRange:range withString:string];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *number = [numberFormatter numberFromString:newText];
        
        if (number != nil && [numberFormatter numberFromString:newText]) {
            NSInteger decimalPlaces = [self numberOfDecimalPlaces:numberFormatter string:newText];
            if (decimalPlaces <= 2) {
                return YES;
            }
        }
        
        return NO;
    }
    if(textField==self.areaHa ||[textField.accessibilityLabel isEqualToString:NSLocalizedString(@"Green Volume", nil)]
       || [textField.accessibilityLabel isEqualToString:NSLocalizedString(@"Dry Volume", nil)] || [textField.accessibilityLabel isEqualToString:NSLocalizedString(@"Predicted Plot Volume (m3)", nil)] )
    {
        if( ![self validInputNumbersOnlyWithDot:theString] ){
            return NO;
        }
    }
    if( textField == self.predictionPlot || textField == self.measurePlot || [textField.accessibilityLabel isEqualToString:NSLocalizedString(@"Plot Number", nil)]){
        if( ![self validInputNumbersOnly:theString] ){
            return NO;
        }
    }
    if( textField == self.totalPile || textField == self.measureSample){
        if( ![self validInputNumbersOnly:theString] ){
            return NO;
        }
    }
    if (textField == self.grade12Percent || textField == self.grade4Percent || textField == self.grade5Percent || textField == self.gradeXPercent || textField == self.gradeYPercent) {
        NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
        
        // Concatenate the current text and the replacement string
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // Check if the new string contains only valid characters
        if ([newString rangeOfCharacterFromSet:charSet].location != NSNotFound) {
            return NO;
        }
        
        // Split the string into components separated by '.'
        NSArray *arrSep = [newString componentsSeparatedByString:@"."];
        
        if ([arrSep count] > 2) {
            return NO;
        } else if ([arrSep count] == 1) {
            // Check the format for values between 0.0 and 100.0
            NSString *value = [arrSep objectAtIndex:0];
            CGFloat floatValue = [value floatValue];
            
            if (floatValue < 0.0 || floatValue > 100.0) {
                return NO;
            }
            
            // Limit the length of the integer part to 3 characters
            if ([value length] > 3) {
                return NO;
            }
        } else if ([arrSep count] == 2) {
            // Check the format for values between 0.0 and 100.0
            NSString *integerPart = [arrSep objectAtIndex:0];
            NSString *decimalPart = [arrSep objectAtIndex:1];
            CGFloat floatValue = [integerPart floatValue];
            int decimalLength = (int)[decimalPart length];
            
            if (floatValue < 0.0 || floatValue > 100.0 || decimalLength > 1) {
                return NO;
            }
            
            // Limit the length of the integer part to 3 characters
            if ([integerPart length] > 3) {
                return NO;
            }
        }
        
        return YES;
    }
    
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
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
            
        case 4: // no char max limit
            return YES;
            break;

        case 5:
            return (newLength > 2) ? NO : YES;
            break;
            
        case 6:
            return (newLength > 2) ? NO : YES;
            break;
        
        case 7:
            return (newLength > 4) ? NO : YES;
            break;
            
        case 8:
            return (newLength > 3) ? NO : YES;
            break;
        case 9:
            for (int i = 0; i < [string length]; i++) {
                unichar c = [string characterAtIndex:i];
                if ([myCharSet characterIsMember:c]) {
                    return (newLength > 3) ? NO : YES;
                }
            }
            return [string isEqualToString:@""];
            break;
        case 10:
           for (int i = 0; i < [string length]; i++) {
               unichar c = [string characterAtIndex:i];
               if ([myCharSet characterIsMember:c]) {
                   return (newLength > 4) ? NO : YES;
               }
           }
           return [string isEqualToString:@""];
           break;
        default:
            return NO; // NOT EDITABLE
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.areaHa){
        
        //save the change first
        [self saveData];
        
        //update the benchmak and calculate the numbers again
        [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
        [WasteCalculator calculateRate:self.wasteBlock ];
        [WasteCalculator calculatePiecesValue:self.wasteBlock ];
        
        if([self.wasteBlock.userCreated intValue] ==1){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
        }
        
        //save the calculated value
        [self saveData];
        
        //refresh footer
        if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
            [self.efwFooterView setStratumViewValue:self.wasteStratum];
        }else{
            [self.footerStatView setViewValue:self.wasteStratum];
        }
    }else if(textField == self.totalPile){
        if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
            if([self.totalPile.text integerValue] == 0){
                self.measureSample.text = self.totalPile.text;
                //[self.continueButton setEnabled:NO];
            }else if([self.totalPile.text integerValue] <= 10){
                self.measureSample.text = self.totalPile.text;
            }else if([self.totalPile.text intValue] > 10){
                int totalpile = [self.totalPile.text intValue];
                int excess = totalpile - 10;
                int value = excess/5;
                int measure = 10 + value;
                self.measureSample.text = [[NSString alloc ] initWithFormat:@"%d", measure];
            }
        }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
            if([self.totalPile.text integerValue] == 0){
            }else if([self.totalPile.text integerValue] <= 10){
                self.measureSample.text = self.totalPile.text;
            }else{
                self.measureSample.text = [[NSString alloc ] initWithFormat:@"%d", 10];
            }
        }
        if([self.measureSample.text intValue] > 30){
            self.measureSample.text = [[NSString alloc] initWithFormat:@"%d", 30];
        }
        if([wasteBlock.regionId integerValue] == InteriorRegion){
            if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.totalPile.text isEqualToString:@""] && ![self.measureSample.text isEqualToString:@""])){
                //[self.continueButton setEnabled:YES];
            }
            else
            {
                //[self.continueButton setEnabled:NO];
            }
        }else if([wasteBlock.regionId integerValue] == CoastRegion){
            if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""] && ![self.predictionPlot.text isEqualToString:@""] && ![self.measureSample.text isEqualToString:@""])){
                //[self.continueButton setEnabled:YES];
            }
            else
            {
                //[self.continueButton setEnabled:NO];
            }
        }
    }else if(textField == self.grade12Percent || textField == self.grade4Percent || textField == self.grade5Percent || textField == self.gradeXPercent || textField == self.gradeYPercent){
        if([wasteBlock.regionId integerValue] == InteriorRegion){
            if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
                if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""])){
                    //[self.continueButton setEnabled:YES];
                }
                else
                {
                    //[self.continueButton setEnabled:NO];
                }
            }else{
                if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""])){
                    //[self.addCutblockButton setEnabled:YES];
                }
                else
                {
                    //[self.addCutblockButton setEnabled:NO];
                }
            }
        }else if([wasteBlock.regionId integerValue] == CoastRegion){
            if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
                if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""] && ![self.predictionPlot.text isEqualToString:@""] && ![self.measureSample.text isEqualToString:@""])){
                    //[self.continueButton setEnabled:YES];
                }
            }else{
                if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""])){
                    //[self.addCutblockButton setEnabled:YES];
                }
                else
                {
                    //[self.addCutblockButton setEnabled:NO];
                }
            }
        }
    } else if (textField == self.predictionPlot || textField == self.measurePlot) {
        if ([self.predictionPlot.text intValue] > 0 && [self.measurePlot.text intValue] > 0 && [self.predictionPlot.text intValue] >= [self.measurePlot.text intValue]) {
            [self.continueButton setEnabled:YES];
        } else {
            [self.continueButton setEnabled:NO];
        }
    }
}

#pragma mark - UITextView
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    //[self saveData];
    
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



// PICKER STUFF
//
#pragma mark PickerView DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    switch (pickerView.tag) {
        case 1:
            return self.stratumTypeArray.count;
            break;
            
        case 2:
            return self.harvestMethodArray.count;
            break;
            
        case 3:
            if ([self.wasteStratum.stratumID integerValue] > 0){
                return self.assessmentSizeArray.count - 3;
            }else{
                return self.assessmentSizeArray.count;
            }
            break;
            
        case 4:
            return self.wasteLevelArray.count;
            break;
            
        case 5:
            return self.wasteTypeArray.count;
            break;
        default:
            return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    switch (pickerView.tag) {
        case 1:
            return [[NSString alloc] initWithFormat:@"%@ - %@", [self.stratumTypeArray[row] valueForKey:@"stratumTypeCode"], [self.harvestMethodArray[row] valueForKey:@"desc"] ];
            break;
            
        case 2:
            return [[NSString alloc] initWithFormat:@"%@ - %@", [self.harvestMethodArray[row] valueForKey:@"harvestMethodCode"], [self.harvestMethodArray[row] valueForKey:@"desc"]];
            break;
            
        case 3:
            return [[NSString alloc] initWithFormat:@"%@ - %@", [self.assessmentSizeArray[row] valueForKey:@"plotSizeCode"], [self.assessmentSizeArray[row] valueForKey:@"desc"]]; // BUG??-plotsizecode should be the value for assessmentSizeArea
            break;
            
        case 4:
            return [[NSString alloc] initWithFormat:@"%@ - %@", [self.wasteLevelArray[row] valueForKey:@"wasteLevelCode"], [self.wasteLevelArray[row] valueForKey:@"desc"]];
            break;

        case 5:
            return [[NSString alloc] initWithFormat:@"%@ - %@", [self.wasteTypeArray[row] valueForKey:@"wasteTypeCode"], [self.wasteTypeArray[row] valueForKey:@"desc"]];
            break;

        default:
            return nil;
    }
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    int found = 0;
    switch (pickerView.tag) {
        case 1:
            //self.stratumType.text = [[NSString alloc] initWithFormat:@"%@ - %@", [self.stratumTypeArray[row] valueForKey:@"stratumTypeCode"], [self.harvestMethodArray[row] valueForKey:@"desc"] ];
            //[self.stratumType resignFirstResponder];
            break;
            
        case 2:
            self.harvestMethod.text = [[NSString alloc] initWithFormat:@"%@ - %@", [self.harvestMethodArray[row] valueForKey:@"harvestMethodCode"], [self.harvestMethodArray[row] valueForKey:@"desc"]];
            [self updateTitle];
            [self.harvestMethod resignFirstResponder];
            break;
            
        case 3:
            self.assesmentSize.text = [[NSString alloc] initWithFormat:@"%@ - %@", [self.assessmentSizeArray[row] valueForKey:@"plotSizeCode"], [self.assessmentSizeArray[row] valueForKey:@"desc"]];
            [self updateTitle];
            [self.assesmentSize resignFirstResponder];
            break;
            
        case 4:
            self.wasteLevel.text = [[NSString alloc] initWithFormat:@"%@ - %@", [self.wasteLevelArray[row] valueForKey:@"wasteLevelCode"], [self.wasteLevelArray[row] valueForKey:@"desc"]];
            [self updateTitle];
            [self.wasteLevel resignFirstResponder];
            break;
            
        case 5:
            
            if([[self.wasteTypeArray[row] valueForKey:@"wasteTypeCode"] isEqualToString:@"D"] || [[self.wasteTypeArray[row] valueForKey:@"wasteTypeCode"] isEqualToString:@"F"] || [[self.wasteTypeArray[row] valueForKey:@"wasteTypeCode"] isEqualToString:@"G"] || [[self.wasteTypeArray[row] valueForKey:@"wasteTypeCode"] isEqualToString:@"H"] || [[self.wasteTypeArray[row] valueForKey:@"wasteTypeCode"] isEqualToString:@"S"] || [[self.wasteTypeArray[row] valueForKey:@"wasteTypeCode"] isEqualToString:@"T"] )
            {
                for(WastePlot *wpl in wasteStratum.stratumPlot)
                {
                    for(WastePiece *wp in wpl.plotPiece)
                    {
                        if([wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"W"] && [wp.pieceButtEndCode.buttEndCode isEqualToString:@"B"])
                        {
                            found = 1;
                        }
                    }
                }
            }
            if(found)
            {
                UIAlertView *alert = nil;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error - Kind W, butt code Broken not allowed in a dispersed strata.\n" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                          [alert show];
                if(orignialWasteTypeRow == NAN)
                {
                    orignialWasteTypeRow = 1;
                }
                [self.wasteTypePicker selectRow:orignialWasteTypeRow inComponent:0 animated:NO];
            }
            else
            {
                self.wasteType.text = [[NSString alloc] initWithFormat:@"%@ - %@", [self.wasteTypeArray[row] valueForKey:@"wasteTypeCode"], [self.wasteTypeArray[row] valueForKey:@"desc"]];
                orignialWasteTypeRow = row;
                [self updateTitle];
                [self.wasteType resignFirstResponder];
            }
            break;
        default:
            break;
    }
    
    if (pickerView == self.sizePicker){
        // if user picks S, E or O, system should disable/lock the picker and remove the existing plot since the plot/piece might not be valid for the new assessment method
        if (([[self.assessmentSizeArray[row] valueForKey:@"plotSizeCode"] isEqualToString:@"S"] ||
             [[self.assessmentSizeArray[row] valueForKey:@"plotSizeCode"] isEqualToString:@"E"] ||
             [[self.assessmentSizeArray[row] valueForKey:@"plotSizeCode"] isEqualToString:@"O"] ) ){
            
            self.wasteStratum.isPileStratum = [NSNumber numberWithBool:NO];
            [self.totalPileLabel setHidden:YES];
            [self.totalNumPiles setHidden:YES];
            [self.measureSampleLabel setHidden:YES];
            [self.measureSample setHidden:YES];
            [self.numPlotsLabel setHidden:NO];
            [self.numOfPlots setHidden:NO];
            [self.plotHeaderLabel setHidden:NO];
            [self.plotHeaderLabel setText:@"Plots"];
            [self.addCutblockButton setHidden:YES];
            if([wasteBlock.ratioSamplingEnabled integerValue] == 1){
                [self.predictionPlot setHidden:NO];
                [self.predictionPlotLabel setHidden:NO];
                [self.measurePlot setHidden:NO];
                [self.measurePlotLabel setHidden:NO];
                [self.addPlotButton setHidden:YES];
                [self.addRatioPlotButton setHidden:NO];
            }else{
                [self.predictionPlot setHidden:YES];
                [self.predictionPlotLabel setHidden:YES];
                [self.measurePlot setHidden:YES];
                [self.measurePlotLabel setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
                [self.addPlotButton setHidden:NO];
            }
            if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
            {
                self.plotTableView.hidden = TRUE;
                self.aggregatePlotTableView.hidden = FALSE;
                self.aggregatePileTableView.hidden = TRUE;
                self.aggregatePackingRatioPlotTableView.hidden = TRUE;
                self.packingRatioTableView.hidden = TRUE;
            }else{
                self.plotTableView.hidden = FALSE;
                self.aggregatePlotTableView.hidden = TRUE;
                self.aggregatePileTableView.hidden = TRUE;
                self.aggregatePackingRatioPlotTableView.hidden = TRUE;
                self.packingRatioTableView.hidden = TRUE;
            }
            [self.grade12Label setHidden:YES];
            [self.grade12Percent setHidden:YES];
            [self.grade4Label setHidden:YES];
            [self.grade4Percent setHidden:YES];
            [self.grade5Label setHidden:YES];
            [self.grade5Percent setHidden:YES];
            [self.gradeXLabel setHidden:YES];
            [self.gradeXPercent setHidden:YES];
            [self.gradeYLabel setHidden:YES];
            [self.gradeYPercent setHidden:YES];
            [self.continueButton setHidden:YES];
            
            if(wasteStratum.stratumPlot && [wasteStratum.stratumPlot count] > 0){
                UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"By changing the assessment method code, all existing plot data in this stratum will be removed. Proceed?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *noBtn = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    self.assesmentSize.text = self.wasteStratum.stratumPlotSizeCode.plotSizeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumPlotSizeCode.plotSizeCode, self.wasteStratum.stratumPlotSizeCode.desc] : @"";
                    // update assessment picker selected row
                    int row = 0;
                    for (PlotSizeCode *psc in self.assessmentSizeArray) {
                        if([ [self codeFromText:self.assesmentSize.text] isEqualToString:psc.plotSizeCode]){
                            [self.sizePicker selectRow:row inComponent:0 animated:NO];
                            break;
                        }
                        row++;
                    }
                }];
                UIAlertAction *yesBtn = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    [self changeStratumType];
                }];
                [userAlert addAction:yesBtn];
                [userAlert addAction:noBtn];
                [self presentViewController:userAlert animated:YES completion:nil];
            }else{
                [self changeStratumType];
            }
            
            
        }else if ([[self.assessmentSizeArray[row] valueForKey:@"plotSizeCode"] isEqualToString:@"R"]){
            self.wasteStratum.isPileStratum = [NSNumber numberWithBool:YES];
            NSInteger selectedWasteTypeRow = [self.wasteTypePicker selectedRowInComponent:0];
            WasteTypeCode *selectedWasteTypeObject = [self.wasteTypeArray objectAtIndex:selectedWasteTypeRow];
            NSString *selectedWasteType = selectedWasteTypeObject.wasteTypeCode;
            if (![self.wasteType.text isEqualToString:@""] && ![selectedWasteType isEqualToString:@"P"] && ![selectedWasteType isEqualToString:@"W"] && ![selectedWasteType isEqualToString:@"O"] && ![selectedWasteType isEqualToString:@"L"]) {
                UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Waste Type can only be P, W, O or L when Assessment/Size is R." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    self.assesmentSize.text = self.wasteStratum.stratumPlotSizeCode.plotSizeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumPlotSizeCode.plotSizeCode, self.wasteStratum.stratumPlotSizeCode.desc] : @"";
                    // update assessment picker selected row
                    int row = 0;
                    for (PlotSizeCode *psc in self.assessmentSizeArray) {
                        if([ [self codeFromText:self.assesmentSize.text] isEqualToString:psc.plotSizeCode]){
                            [self.sizePicker selectRow:row inComponent:0 animated:NO];
                            break;
                        }
                        row++;
                    }
                }];
                [userAlert addAction:okBtn];
                [self presentViewController:userAlert animated:YES completion:nil];
            } else if(wasteStratum.stratumPlot && [wasteStratum.stratumPlot count] > 0){
                UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"By changing the assessment method code, all existing plot data in this stratum will be removed. Proceed?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *noBtn = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    self.assesmentSize.text = self.wasteStratum.stratumPlotSizeCode.plotSizeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumPlotSizeCode.plotSizeCode, self.wasteStratum.stratumPlotSizeCode.desc] : @"";
                    // update assessment picker selected row
                    int row = 0;
                    for (PlotSizeCode *psc in self.assessmentSizeArray) {
                        if([ [self codeFromText:self.assesmentSize.text] isEqualToString:psc.plotSizeCode]){
                            [self.sizePicker selectRow:row inComponent:0 animated:NO];
                            break;
                        }
                        row++;
                    }
                    [self.assesmentSize setEnabled:YES];
                    self.wasteStratum.isPileStratum = [NSNumber numberWithBool:NO];
                    [self.totalPileLabel setHidden:YES];
                    [self.totalNumPiles setHidden:YES];
                    [self.measureSampleLabel setHidden:YES];
                    [self.measureSample setHidden:YES];
                    [self.numPlotsLabel setHidden:NO];
                    [self.numOfPlots setHidden:NO];
                    [self.plotHeaderLabel setHidden:NO];
                    [self.plotHeaderLabel setText:@"Plots"];
                    [self.addCutblockButton setHidden:YES];
                    if([self.wasteBlock.ratioSamplingEnabled integerValue] == 1){
                        [self.predictionPlot setHidden:NO];
                        [self.predictionPlotLabel setHidden:NO];
                        [self.measurePlot setHidden:NO];
                        [self.measurePlotLabel setHidden:NO];
                        [self.addPlotButton setHidden:YES];
                        [self.addRatioPlotButton setHidden:NO];
                    }else{
                        [self.predictionPlot setHidden:YES];
                        [self.predictionPlotLabel setHidden:YES];
                        [self.measurePlot setHidden:YES];
                        [self.measurePlotLabel setHidden:YES];
                        [self.addRatioPlotButton setHidden:YES];
                        [self.addPlotButton setHidden:NO];
                    }
                    // show/hide tables
                    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]) {
                        self.plotTableView.hidden = TRUE;
                        self.packingRatioTableView.hidden = TRUE;
                        self.aggregatePlotTableView.hidden = TRUE;
                        self.aggregatePackingRatioPlotTableView.hidden = FALSE;
                    } else {
                        self.plotTableView.hidden = TRUE;
                        self.packingRatioTableView.hidden = FALSE;
                        self.aggregatePlotTableView.hidden = TRUE;
                        self.aggregatePackingRatioPlotTableView.hidden = TRUE;
                    }
                    [self.grade12Label setHidden:YES];
                    [self.grade12Percent setHidden:YES];
                    [self.grade4Label setHidden:YES];
                    [self.grade4Percent setHidden:YES];
                    [self.grade5Label setHidden:YES];
                    [self.grade5Percent setHidden:YES];
                    [self.gradeXLabel setHidden:YES];
                    [self.gradeXPercent setHidden:YES];
                    [self.gradeYLabel setHidden:YES];
                    [self.gradeYPercent setHidden:YES];
                    [self.continueButton setHidden:YES];
                }];
                UIAlertAction *yesBtn = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    for (WastePlot *wp in [self.wasteStratum.stratumPlot allObjects]){
                        [self deletePlot:wp targetWastePlot:self.wasteStratum];
                    }
                    // rebind tableview
                    [self.packingRatioTableView reloadData];
                    [self.aggregatePackingRatioPlotTableView reloadData];
                }];
                [userAlert addAction:yesBtn];
                [userAlert addAction:noBtn];
                [self presentViewController:userAlert animated:YES completion:nil];
            }else{
                // Packing Ratio selected, no alert needed
                if ([[[self.assessmentSizeArray[[self.sizePicker selectedRowInComponent:0]] plotSizeCode] description] isEqualToString:@"R"]) {
                    [self packingRatioStratumPicked];
                }
                // if we somehow get here, reset the UI
                else {
                    [self.assesmentSize setEnabled:YES];
                    self.wasteStratum.isPileStratum = [NSNumber numberWithBool:NO];
                    [self.totalPileLabel setHidden:YES];
                    [self.totalNumPiles setHidden:YES];
                    [self.measureSampleLabel setHidden:YES];
                    [self.measureSample setHidden:YES];
                    [self.numPlotsLabel setHidden:NO];
                    [self.numOfPlots setHidden:NO];
                    [self.plotHeaderLabel setHidden:NO];
                    [self.plotHeaderLabel setText:@"Plots"];
                    [self.addCutblockButton setHidden:YES];
                    if([wasteBlock.ratioSamplingEnabled integerValue] == 1){
                        [self.predictionPlot setHidden:NO];
                        [self.predictionPlotLabel setHidden:NO];
                        [self.measurePlot setHidden:NO];
                        [self.measurePlotLabel setHidden:NO];
                        [self.addPlotButton setHidden:YES];
                        [self.addRatioPlotButton setHidden:NO];
                    }else{
                        [self.predictionPlot setHidden:YES];
                        [self.predictionPlotLabel setHidden:YES];
                        [self.measurePlot setHidden:YES];
                        [self.measurePlotLabel setHidden:YES];
                        [self.addRatioPlotButton setHidden:YES];
                        [self.addPlotButton setHidden:NO];
                    }
                    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
                    {
                        self.plotTableView.hidden = TRUE;
                        self.aggregatePlotTableView.hidden = FALSE;
                        self.aggregatePileTableView.hidden = TRUE;
                        self.aggregatePackingRatioPlotTableView.hidden = TRUE;
                        self.packingRatioTableView.hidden = TRUE;
                    }else{
                        self.plotTableView.hidden = FALSE;
                        self.aggregatePlotTableView.hidden = TRUE;
                        self.aggregatePileTableView.hidden = TRUE;
                        self.aggregatePackingRatioPlotTableView.hidden = TRUE;
                        self.packingRatioTableView.hidden = TRUE;
                    }
                    [self.grade12Label setHidden:YES];
                    [self.grade12Percent setHidden:YES];
                    [self.grade4Label setHidden:YES];
                    [self.grade4Percent setHidden:YES];
                    [self.grade5Label setHidden:YES];
                    [self.grade5Percent setHidden:YES];
                    [self.gradeXLabel setHidden:YES];
                    [self.gradeXPercent setHidden:YES];
                    [self.gradeYLabel setHidden:YES];
                    [self.gradeYPercent setHidden:YES];
                    [self.continueButton setHidden:YES];
                }
            }
        }
    }
}

-(void)changeStratumType{
    //[self.sizePicker setUserInteractionEnabled:NO];
    [self.assesmentSize setEnabled:NO];
    
    // delete all existing plot
    for (WastePlot *wp in [self.wasteStratum.stratumPlot allObjects]){
        [self deletePlot:wp targetWastePlot:self.wasteStratum];
    }
    // add one new plot
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePlot *wp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
    wp.assistant = @"";
    wp.baseline = @"";
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
    
    if (self.wasteStratum.stratumBlock.returnNumber && !isnan([self.wasteStratum.stratumBlock.returnNumber intValue])){
        wp.returnNumber = [self.wasteStratum.stratumBlock.returnNumber stringValue];
    }else{
        wp.returnNumber = @"";
    }
    
    wp.certificateNumber = [NSString stringWithString:self.wasteStratum.stratumBlock.surveyorLicence];
    
    if ([self.wasteBlock.userCreated intValue] ==1){
        [wp setIsSurvey:[NSNumber numberWithBool:YES]];
        wp.surveyedMeasurePercent = [[NSNumber alloc] initWithInteger:100];
        wp.checkerMeasurePercent = [[NSNumber alloc] initWithInteger:0];
        wp.surveyorName = self.wasteStratum.stratumBlock.surveyorName;
        
    }else{
        [wp setIsSurvey:[NSNumber numberWithBool:NO]];
        wp.surveyedMeasurePercent = [[NSNumber alloc] initWithInteger:100];
        wp.checkerMeasurePercent = [[NSNumber alloc] initWithInteger:100];
        wp.surveyorName = self.wasteStratum.stratumBlock.checkerName;
    }
    
    [self.wasteStratum addStratumPlotObject:wp];
    
    //reset ratio sampling fields
    self.predictionPlot.text = @"";
    self.measurePlot.text = @"";
    self.wasteStratum.n1sample = @"";
    self.wasteStratum.n2sample = @"";
    
    [self saveData];
    
    // disable the add plot link
    [self.addPlotButton setHidden:YES];
    [self.addRatioPlotButton setHidden:YES];
    
    if([self.wasteStratum.stratumPlotSizeCode.plotSizeCode isEqualToString:@"S"] ||
    [self.wasteStratum.stratumPlotSizeCode.plotSizeCode isEqualToString:@"E"]){
        [self.addPlotButton setHidden:NO];
    }
    
    // refresh sorted plot list
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES];
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc ] initWithKey:@"pileNumber" ascending:YES];
    self.sortedPlots = [[[self.wasteStratum stratumPlot] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    self.sortedPiles = [[[self.wasteStratum stratumPile] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort2]];
    
    // rebind tableview
    [self.plotTableView reloadData];
    [self.aggregatePlotTableView reloadData];
    [self.packingRatioTableView reloadData];
    [self.aggregatePackingRatioPlotTableView reloadData];
    
    // hide ratio sample fields
    [self.predictionPlot setHidden:YES];
    [self.measurePlot setHidden:YES];
    [self.predictionPlotLabel setHidden:YES];
    [self.measurePlotLabel setHidden:YES];
}



// PICKER DISPLAY ANIMATIONS
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

//loc2
-(void)packingRatioStratumPicked{
    NSLog(@"packingRatioStratumPicked");
    NSLog(@"%@", self.wasteStratum.totalNumPile);
    [self.sizePicker setUserInteractionEnabled:NO];
    [self.assesmentSize setEnabled:NO];
    [self.numPlotsLabel setHidden:NO];
    [self.numOfPlots setHidden:YES];
    [self.totalPileLabel setHidden:YES];
    [self.totalNumPiles setHidden:NO];
    NSUInteger pileCount = self.wasteStratum.stratumPile ? [self.wasteStratum.stratumPile count] : 0;
    NSString *countText = [NSString stringWithFormat:@"%lu", (unsigned long)pileCount];
    self.totalNumPiles.text = countText;
    [self.measureSampleLabel setHidden:YES];
    [self.measureSample setHidden:YES];
    
    [self.plotTableView setHidden:YES];
    [self.aggregatePileTableView setHidden:YES];
    [self.aggregatePlotTableView setHidden:YES];
    // SINGLE BLOCK
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]) {
        // RATIO
        //todo
        if ([self.wasteBlock.ratioSamplingEnabled integerValue] == 1){
            // SB-RATIO-COAST
            if ([wasteBlock.regionId integerValue] == CoastRegion) {
                NSLog(@"SINGLE block RATIO COAST - HARVEST METHOD R");
                [self.grade12Label setText:@"Grade J%"];
                [self.grade12Label setHidden:NO];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Label setText:@"Grade U%"];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:YES];
                [self.grade5Percent setHidden:YES];
                [self.gradeXLabel setHidden:NO];
                [self.gradeXPercent setHidden:NO];
                [self.gradeYLabel setHidden:NO];
                [self.gradeYPercent setHidden:NO];
                
                [self.continueButton setHidden:NO];
                if ([self.predictionPlot.text intValue] > 0 && [self.measurePlot.text intValue] > 0 && ([self.wasteStratum.totalNumPile intValue] < [self.wasteStratum.predictionPlot intValue])) {
                    [self.continueButton setEnabled:YES];
                } else {
                    [self.continueButton setEnabled:NO];
                }
                
                [self.addCutblockButton setHidden:YES];
                [self.addPlotButton setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
                
                [self.packingRatioTableView setHidden:NO];
                [self.aggregatePackingRatioPlotTableView setHidden:YES];
            }
            // SB-RATIO-INT
            else {
                NSLog(@"SINGLE block RATIO INTERIOR - HARVEST METHOD R");
                [self.grade12Label setText:@"Grade 1,2%"];
                [self.grade12Label setHidden:NO];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Label setText:@"Grade 4%"];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:YES];
                [self.grade5Percent setHidden:YES];
                [self.gradeXLabel setHidden:YES];
                [self.gradeXPercent setHidden:YES];
                [self.gradeYLabel setHidden:YES];
                [self.gradeYPercent setHidden:YES];
                
                [self.continueButton setHidden:NO];
                if ([self.predictionPlot.text intValue] > 0 && [self.measurePlot.text intValue] > 0 && ([self.wasteStratum.totalNumPile intValue] < [self.wasteStratum.predictionPlot intValue])) {
                    [self.continueButton setEnabled:YES];
                } else {
                    [self.continueButton setEnabled:NO];
                }
                [self.addCutblockButton setHidden:YES];
                [self.addPlotButton setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
                
                [self.packingRatioTableView setHidden:NO];
                [self.aggregatePackingRatioPlotTableView setHidden:YES];
            }
        }
        // SRS
        else{
            // SB-SRS-COAST
            if ([wasteBlock.regionId integerValue] == CoastRegion) {
                NSLog(@"single block SRS COAST - HARVEST METHOD R");
                [self.grade12Label setText:@"Grade J%"];
                [self.grade12Label setHidden:NO];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Label setText:@"Grade U%"];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:YES];
                [self.grade5Percent setHidden:YES];
                [self.gradeXLabel setHidden:NO];
                [self.gradeXPercent setHidden:NO];
                [self.gradeYLabel setHidden:NO];
                [self.gradeYPercent setHidden:NO];
                
                [self.continueButton setHidden:NO];
                [self.continueButton setEnabled:YES];
                [self.addCutblockButton setHidden:YES];
                [self.addPlotButton setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
                
                [self.packingRatioTableView setHidden:NO];
                [self.aggregatePackingRatioPlotTableView setHidden:YES];
            }
            // SB-SRS-INTERIOR
            else {
                NSLog(@"single block SRS INTERIOR - HARVEST METHOD R");
                [self.grade12Label setText:@"Grade 1,2%"];
                [self.grade12Label setHidden:NO];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Label setText:@"Grade 4%"];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:YES];
                [self.grade5Percent setHidden:YES];
                [self.gradeXLabel setHidden:YES];
                [self.gradeXPercent setHidden:YES];
                [self.gradeYLabel setHidden:YES];
                [self.gradeYPercent setHidden:YES];
                
                [self.continueButton setHidden:NO];
                [self.continueButton setEnabled:YES];
                [self.addCutblockButton setHidden:YES];
                [self.addPlotButton setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
                
                [self.packingRatioTableView setHidden:NO];
                [self.aggregatePackingRatioPlotTableView setHidden:YES];
            }
        }
    }
    // AGGREGATE
    else {
        // RATIO
        if ([self.wasteBlock.ratioSamplingEnabled integerValue] == 1){
            // AGG-RATIO-COAST
            if ([wasteBlock.regionId integerValue] == CoastRegion) {
                NSLog(@"aggregate RATIO COAST - HARVEST METHOD R");
                [self.grade12Label setText:@"Grade J%"];
                [self.grade12Label setHidden:NO];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Label setText:@"Grade U%"];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:YES];
                [self.grade5Percent setHidden:YES];
                [self.gradeXLabel setHidden:NO];
                [self.gradeXPercent setHidden:NO];
                [self.gradeYLabel setHidden:NO];
                [self.gradeYPercent setHidden:NO];
                
                [self.continueButton setHidden:NO];
                if ([self.predictionPlot.text intValue] > 0 && [self.measurePlot.text intValue] > 0 && ([self.wasteStratum.totalNumPile intValue] < [self.wasteStratum.predictionPlot intValue])) {
                    [self.continueButton setEnabled:YES];
                } else {
                    [self.continueButton setEnabled:NO];
                }
                [self.addCutblockButton setHidden:YES];
                [self.addPlotButton setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
                
                [self.packingRatioTableView setHidden:YES];
                [self.aggregatePackingRatioPlotTableView setHidden:NO];
            }
            // AGG-RATIO-INT
            else {
                NSLog(@"aggregate RATIO INTERIOR - HARVEST METHOD R");
                [self.grade12Label setText:@"Grade 1,2%"];
                [self.grade12Label setHidden:NO];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Label setText:@"Grade 4%"];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:YES];
                [self.grade5Percent setHidden:YES];
                [self.gradeXLabel setHidden:YES];
                [self.gradeXPercent setHidden:YES];
                [self.gradeYLabel setHidden:YES];
                [self.gradeYPercent setHidden:YES];
                
                [self.continueButton setHidden:NO];
                if ([self.predictionPlot.text intValue] > 0 && [self.measurePlot.text intValue] > 0 && ([self.wasteStratum.totalNumPile intValue] < [self.wasteStratum.predictionPlot intValue])) {
                    [self.continueButton setEnabled:YES];
                } else {
                    [self.continueButton setEnabled:NO];
                }
                [self.addCutblockButton setHidden:YES];
                [self.addPlotButton setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
                
                [self.packingRatioTableView setHidden:YES];
                [self.aggregatePackingRatioPlotTableView setHidden:NO];
            }
        }
        // AGG-SRS
        else{
            // AGG-SRS-COAST
            if ([wasteBlock.regionId integerValue] == CoastRegion) {
                NSLog(@"aggregate SRS COAST - HARVEST METHOD R");
                [self.grade12Label setText:@"Grade J%"];
                [self.grade12Label setHidden:NO];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Label setText:@"Grade U%"];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:YES];
                [self.grade5Percent setHidden:YES];
                [self.gradeXLabel setHidden:NO];
                [self.gradeXPercent setHidden:NO];
                [self.gradeYLabel setHidden:NO];
                [self.gradeYPercent setHidden:NO];
                
                [self.continueButton setHidden:NO];
                [self.continueButton setEnabled:YES];
                [self.addCutblockButton setHidden:YES];
                [self.addPlotButton setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
                
                [self.packingRatioTableView setHidden:YES];
                [self.aggregatePackingRatioPlotTableView setHidden:NO];
            }
            // AGG-SRS-INTERIOR
            if ([wasteBlock.regionId integerValue] == InteriorRegion) {
                NSLog(@"aggregate SRS INTERIOR - HARVEST METHOD R");
                [self.grade12Label setText:@"Grade 1,2%"];
                [self.grade12Label setHidden:NO];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Label setText:@"Grade 4%"];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:YES];
                [self.grade5Percent setHidden:YES];
                [self.gradeXLabel setHidden:YES];
                [self.gradeXPercent setHidden:YES];
                [self.gradeYLabel setHidden:YES];
                [self.gradeYPercent setHidden:YES];
                
                [self.continueButton setHidden:NO];
                [self.continueButton setEnabled:YES];
                [self.addCutblockButton setHidden:YES];
                [self.addPlotButton setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
                
                [self.packingRatioTableView setHidden:YES];
                [self.aggregatePackingRatioPlotTableView setHidden:NO];
            }
        }
    }
}



// SELECTED PLOT IN PLOT TABLE
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView");
    if (tableView == plotTableView )
    {
        // get the selected row i.e. stratum - cell contains .stratum, .type, .area, ...
        PlotTableViewCell *cell = (PlotTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        // get all stratums for the selected row
        NSArray *plots = [self.wasteStratum.stratumPlot allObjects];
        
        // pull out the stratum that we are looking for, using the selected rows stratum field
        for (WastePlot* plot in plots) // (weak) stratum, thats why BUG in next screen ?
        {
            if( [[plot.plotNumber stringValue] isEqualToString:cell.plotNumber.text] )  // BUG ? - comparing strings from NSNumber
            {
                PlotViewController *plotVC = self.theSegue.destinationViewController;
                plotVC.originalMP = plot.surveyedMeasurePercent;
                plotVC.wastePlot = plot;
                plotVC.wasteBlock = self.wasteBlock;
                [self saveData];
                break;
            }
        }
    }
    else if (tableView == packingRatioTableView)
    {
        PackingRatioTableViewCell *cell = (PackingRatioTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
        [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
        [WasteCalculator calculateRate:self.wasteBlock ];
        [WasteCalculator calculatePiecesValue:self.wasteBlock ];
        if([self.wasteBlock.userCreated intValue] ==1){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
        }
        
        PileViewController *pileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PileViewControllerSID"];
        pileVC.wasteStratum = self.wasteStratum;
        pileVC.wasteBlock = self.wasteBlock;
        
        // get all piles for the selected row
        NSArray *piles = [self.wasteStratum.stratumPile allObjects];
        pileVC.wastePiles = piles;
        
        // pull out the pile that we are looking for
        for (WastePile* pile in piles)
        {
            if( [[pile.pileNumber stringValue] isEqualToString:cell.plotNumberPR.text] )
            {
                pileVC.wastePile = pile;
                break;
            }
        }

        [self saveData];
        
        [self.navigationController pushViewController:pileVC animated:YES];
    }
    else if (tableView == aggregatePlotTableView )
    {
        // get the selected row i.e. stratum - cell contains .stratum, .type, .area, ...
        AggregatePlotTableViewCell *cell = (AggregatePlotTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        // get all stratums for the selected row
        NSArray *plots = [self.wasteStratum.stratumPlot allObjects];
        
        // pull out the stratum that we are looking for, using the selected rows stratum field
        for (WastePlot* plot in plots) // (weak) stratum, thats why BUG in next screen ?
        {
            if( [[plot.plotNumber stringValue] isEqualToString:cell.plotNumber.text] )  // BUG ? - comparing strings from NSNumber
            {
                PlotViewController *plotVC = self.theSegue.destinationViewController;
                plotVC.originalMP = plot.surveyedMeasurePercent;
                plotVC.wastePlot = plot;
                plotVC.wasteBlock = self.wasteBlock;
                [self saveData];
                break;
            }
        }
    }
    else if (tableView == aggregatePackingRatioPlotTableView)
    {
        AggregatePackingRatioPlotTableViewCell *cell = (AggregatePackingRatioPlotTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
        [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
        [WasteCalculator calculateRate:self.wasteBlock ];
        [WasteCalculator calculatePiecesValue:self.wasteBlock ];
        if([self.wasteBlock.userCreated intValue] ==1){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
        }
        
        PileViewController *pileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PileViewControllerSID"];
        pileVC.wasteStratum = self.wasteStratum;
        pileVC.wasteBlock = self.wasteBlock;
        
        // get all piles for the selected row
        NSArray *piles = [self.wasteStratum.stratumPile allObjects];
        pileVC.wastePiles = piles;
        
        // pull out the pile that we are looking for
        for (WastePile* pile in piles)
        {
            if( [[pile.pileNumber stringValue] isEqualToString:cell.plotNumberAPR.text] )
            {
                pileVC.wastePile = pile;
                break;
            }
        }

        [self saveData];
        
        [self.navigationController pushViewController:pileVC animated:YES];
    }
    
}

#pragma mark - BackButtonHandler protocol
-(BOOL) navigationShouldPopOnBackButton
{
    [self saveData];
    
    WastePlotValidator *wpv = [[WastePlotValidator alloc] init];
    NSString *errorMessage = [wpv validateStratum:wasteStratum];
    BOOL isfatal = NO;
       
    if( [errorMessage rangeOfString:@"Error"].location != NSNotFound){
        isfatal = YES;
    }

       if (![errorMessage isEqualToString:@""]){
           UIAlertView *validateAlert = nil;
           validateAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
           //Let user to bypass the error
           /*if (isfatal){
               validateAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage
                                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
           }else{
               validateAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:errorMessage
                                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Continue", nil];
           }*/
           validateAlert.tag = ValidEnum;
           [validateAlert show];
           return NO;
       }else{
           return YES;
       }
    
    //return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Calculating Survey Check information

// Summarize avoidable pieces with grade Y or better
// Returns a volume value
-(NSDecimalNumber *) calculateStratumSurveyY
{
    NSDecimalNumber *survey = [NSDecimalNumber zero];
    // Sum the calculatePlotSurveyY
    return survey;
}

// Summarize avoidable pieces with grade X or better
// Returns a volume value
-(NSDecimalNumber *) calculateStratumSurveyX
{
    NSDecimalNumber *survey = [NSDecimalNumber zero];
    // Sum the calculatePlotSurveyX
    return survey;
}

// Summarize all avoidable pieces
// Returns a dollar amount
-(NSDecimalNumber *) calculateStratumSurveyNet
{
    NSDecimalNumber *survey = [NSDecimalNumber zero];
    // Sum the calculatePlotSurveyNet
    return survey;
}

// Summarize avoidable pieces with grade Y or better
// Returns a volume value
-(NSDecimalNumber *) calculateStratumCheckY
{
    NSDecimalNumber *check = [NSDecimalNumber zero];
    // Sum the calculatePlotCheckY
    return check;
}

// Summarize avoidable pieces with grade X or better
// Returns a volume value
-(NSDecimalNumber *) calculateStratumCheckX
{
    NSDecimalNumber *check = [NSDecimalNumber zero];
    // Sum the calculatePlotCheckX
    return check;
}

// Summarize all avoidable pieces
// Returns a dollar amount
-(NSDecimalNumber *) calculateStratumCheckNet
{
    NSDecimalNumber *check = [NSDecimalNumber zero];
    // Sum the calculatePlotCheckNet
    return check;
}

// Determine difference between Survey and Check for avoidable pieces with grade Y or better
// Returns a percentage value
-(NSDecimalNumber *) calculateStratumDeltaY
{
    NSDecimalNumber *delta = [NSDecimalNumber zero];
    // Sum the calculatePlotDeltaY
    return delta;
}

// Determine difference between Survey and Check for avoidable pieces with grade X or better
// Returns a percentage value
-(NSDecimalNumber *) calculateStratumDeltaX
{
    NSDecimalNumber *delta = [NSDecimalNumber zero];
    // Sum the calculatePlotDeltaX
    return delta;
}

// Determine difference between Survey and Check for all avoidable pieces
// Returns a percentage amount
-(NSDecimalNumber *) calculateStratumDeltaNet
{
    NSDecimalNumber *delta = [NSDecimalNumber zero];
    // Sum the calculatePlotDeltaNet
    return delta;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    self.theSegue = segue;
    
    NSLog(@"segue %@", segue.identifier);
    
    if ( [segue.identifier isEqualToString:@"addPlotSegue"]){
        
        WastePlot* wp = [self addEmptyPlot];
        [PlotSampleGenerator addPlot2:self.wasteStratum plotNumber:[wp.plotNumber intValue]];
        wp.measurePctEdited = [NSNumber numberWithInt:0];
        
        NSLog(@" stratumPlot count = %lu",(unsigned long)[[self.wasteStratum stratumPlot] count]);
        
        PlotViewController *plotVC = (PlotViewController *)[segue destinationViewController];
        plotVC.wastePlot = wp;
        plotVC.originalMP = wp.surveyedMeasurePercent;
        plotVC.wasteBlock = self.wasteBlock;
        plotVC.originalMP = [NSNumber numberWithInt:100];
        
        
        // update sorted plots
        NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES]; // is key ok ? does it actually sort according to it
        self.sortedPlots = [[[self.wasteStratum stratumPlot] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        //update the benchmak and calculate the numbers again
        [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
        [WasteCalculator calculateRate:self.wasteBlock ];
        [WasteCalculator calculatePiecesValue:self.wasteBlock ];

        if([self.wasteBlock.userCreated intValue] ==1){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
        }

        // save data
        [self saveData];
        
        self.numOfPlots.text = self.wasteStratum.stratumPlot ? [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[self.wasteStratum.stratumPlot count]] : @"";
        
    }
    else if ( [segue.identifier isEqualToString:@"reportFromStratumSegue"]){
        
        ReportGeneratorTableViewController *reportGeneratorTableVC = (ReportGeneratorTableViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        reportGeneratorTableVC.wasteBlock = self.wasteBlock;
        reportGeneratorTableVC.wasteStratum = self.wasteStratum;
        reportGeneratorTableVC.wastePlot = nil;
        
        // save data
        [self saveData];
    }
    
}

- (void) populateFromObject{
    
    // FILL FROM OBJECT TO VIEW
    NSString *tmpTitle = self.wasteStratum.stratum ? [[NSString alloc] initWithFormat:@"(IFOR 203) Stratum - %@", self.wasteStratum.stratum] : @"";
    [[self navigationItem] setTitle:tmpTitle];
    
    
    //self.stratumType.text = self.wasteStratum.stratumStratumTypeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumStratumTypeCode.stratumTypeCode, self.wasteStratum.stratumStratumTypeCode.desc] : @"";
    self.harvestMethod.text = self.wasteStratum.stratumHarvestMethodCode.harvestMethodCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumHarvestMethodCode.harvestMethodCode, self.wasteStratum.stratumHarvestMethodCode.desc] : @"";
    self.assesmentSize.text = self.wasteStratum.stratumPlotSizeCode.plotSizeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumPlotSizeCode.plotSizeCode, self.wasteStratum.stratumPlotSizeCode.desc] : @"";
    
    //disable the assessment size picker
    if ([self.wasteStratum.stratumPlotSizeCode.plotSizeCode isEqualToString:@"S"] ||
        [self.wasteStratum.stratumPlotSizeCode.plotSizeCode isEqualToString:@"E"] ||
        [self.wasteStratum.stratumPlotSizeCode.plotSizeCode isEqualToString:@"O"]){
        //[self.sizePicker setUserInteractionEnabled:NO];
        [self.assesmentSize setEnabled:NO];
        [self.predictionPlot setHidden:YES];
        [self.predictionPlotLabel setHidden:YES];
        [self.measurePlot setHidden:YES];
        [self.measurePlotLabel setHidden:YES];
    }else{
        //[self.sizePicker setUserInteractionEnabled:YES];
        [self.assesmentSize setEnabled:YES];
        
        if([self.wasteBlock.ratioSamplingEnabled integerValue] == 1) {
            [self.predictionPlot setHidden:NO];
            [self.predictionPlot setEnabled:NO];
            [self.predictionPlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            [self.predictionPlotLabel setHidden:NO];
                
            [self.measurePlot setHidden:NO];
            [self.measurePlot setEnabled:NO];
            [self.measurePlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            [self.measurePlotLabel setHidden:NO];
        } else {
            [self.predictionPlot setHidden:YES];
            [self.predictionPlotLabel setHidden:YES];
                
            [self.measurePlot setHidden:YES];
            [self.measurePlotLabel setHidden:YES];
        }
        
    }
    if ([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]){
        [self.assesmentSize setEnabled:NO];
        if([wasteBlock.regionId integerValue] == InteriorRegion){
            self.grade12Percent.text = self.wasteStratum.grade12Percent && [self.wasteStratum.grade12Percent floatValue] >= 0.0 && [self.wasteStratum.grade12Percent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.grade12Percent floatValue]] : @"";
            self.grade4Percent.text = self.wasteStratum.grade4Percent && [self.wasteStratum.grade4Percent floatValue] >= 0.0 && [self.wasteStratum.grade4Percent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.grade4Percent floatValue]] : @"";
            self.grade5Percent.text = self.wasteStratum.grade5Percent && [self.wasteStratum.grade5Percent floatValue] >= 0.0 && [self.wasteStratum.grade5Percent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.grade5Percent floatValue]] : @"";
        }else if([wasteBlock.regionId integerValue] == CoastRegion){
            self.grade12Percent.text = self.wasteStratum.gradeJPercent && [self.wasteStratum.gradeJPercent floatValue] >= 0.0 && [self.wasteStratum.gradeJPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeJPercent floatValue]] : @"";
            self.grade4Percent.text = self.wasteStratum.gradeWPercent && [self.wasteStratum.gradeWPercent floatValue] >= 0.0 && [self.wasteStratum.gradeWPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeWPercent floatValue]] : @"";
            self.grade5Percent.text = self.wasteStratum.gradeUPercent && [self.wasteStratum.gradeUPercent floatValue] >= 0.0 && [self.wasteStratum.gradeUPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeUPercent floatValue]] : @"";
            self.gradeXPercent.text = self.wasteStratum.gradeXPercent && [self.wasteStratum.gradeXPercent floatValue] >= 0.0 && [self.wasteStratum.gradeXPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeXPercent floatValue]] : @"";
            self.gradeYPercent.text = self.wasteStratum.gradeYPercent && [self.wasteStratum.gradeYPercent floatValue] >= 0.0 && [self.wasteStratum.gradeYPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeYPercent floatValue]] : @"";
        }
        
        self.totalPile.text =  self.wasteStratum.totalNumPile && [self.wasteStratum.totalNumPile intValue] > 0 ? [[NSString alloc] initWithFormat:@"%d", [self.wasteStratum.totalNumPile intValue]] : @"";
        //[self.continueButton setEnabled:YES];
        
        if(![self.predictionPlot.text isEqualToString:@""] && ![self.measurePlot.text isEqualToString:@""] && [wasteBlock.ratioSamplingEnabled integerValue] == 1){
            [self.predictionPlot setEnabled:NO];
            [self.predictionPlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            [self.measurePlot setEnabled:NO];
            [self.measurePlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        }
    }
    
    self.wasteLevel.text = self.wasteStratum.stratumWasteLevelCode.wasteLevelCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumWasteLevelCode.wasteLevelCode, self.wasteStratum.stratumWasteLevelCode.desc] : @"";
    self.wasteType.text = self.wasteStratum.stratumWasteTypeCode.wasteTypeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumWasteTypeCode.wasteTypeCode, self.wasteStratum.stratumWasteTypeCode.desc] : @"";
    
    
    self.numOfPlots.text = self.wasteStratum.stratumPlot ? [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[self.wasteStratum.stratumPlot count]] : @"";
    
    self.notes.text = self.wasteStratum.notes ? [[NSString alloc] initWithFormat:@"%@", self.wasteStratum.notes] : @"";
    

    self.predictionPlot.text = self.wasteStratum.predictionPlot ? [[NSString alloc] initWithFormat:@"%d", [self.wasteStratum.predictionPlot intValue]]: @"";
    self.measurePlot.text = self.wasteStratum.measurePlot ?[[NSString alloc] initWithFormat:@"%d", [self.wasteStratum.measurePlot intValue]]: @"";
    
    if([wasteBlock.ratioSamplingEnabled integerValue] == 1 && [self.wasteStratum.isLocked boolValue]){
        [self.predictionPlot setEnabled:NO];
        [self.predictionPlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.measurePlot setEnabled:NO];
        [self.measurePlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    }
    
    if(![self.predictionPlot.text isEqualToString:@""] && ![self.measurePlot.text isEqualToString:@""] && [self.wasteBlock.ratioSamplingEnabled integerValue] == 1 && [self.wasteStratum.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]&& (![self.wasteStratum.n1sample isEqualToString:@""] || ![self.wasteStratum.fixedSample isEqualToString:@""])){
            [self.predictionPlot setEnabled:NO];
            [self.predictionPlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            [self.measurePlot setEnabled:NO];
            [self.measurePlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        }
    
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setStratumViewValue:self.wasteStratum];
    }else{
        [self.footerStatView setViewValue:self.wasteStratum];
    }
    
    //*** for user created cut block
    if ([self.wasteBlock.userCreated intValue] == 1){
        self.areaHa.text = self.wasteStratum.stratumSurveyArea && [self.wasteStratum.stratumSurveyArea floatValue] > 0 ? [[NSString alloc] initWithFormat:@"%.2f", [self.wasteStratum.stratumSurveyArea floatValue]] : @"";
    }else{
        self.surveyAreaLabel.text = [NSString stringWithFormat:@"Survey Area: %.2f ha", [self.wasteStratum.stratumSurveyArea floatValue]];
        self.areaHa.text = self.wasteStratum.stratumArea && [self.wasteStratum.stratumArea floatValue] > 0 ? [[NSString alloc] initWithFormat:@"%.2f", [self.wasteStratum.stratumArea floatValue]] : @"";
    }
    for(WasteStratum *ws in [self.wasteBlock.blockStratum allObjects]){
        double  totalestimatedvolume = 0.0;
        for(WastePlot *wp in [ws.stratumPlot allObjects]){
            totalestimatedvolume = totalestimatedvolume + [wp.plotEstimatedVolume doubleValue];
        }
        ws.totalEstimatedVolume = [[NSDecimalNumber alloc] initWithDouble:totalestimatedvolume];
        NSLog(@"Total Estimated Volume %@", ws.totalEstimatedVolume);
    }

    
    //show the down allow image if more than 5 plots
    if ([self.wasteStratum.stratumPlot count] > 5){
        [self.downArrowImage setHidden:NO];
    }else{
        [self.downArrowImage setHidden:YES];
    }
    
    //for Standing Tree (STRS or STRE)
    if ([self.wasteStratum.stratum isEqualToString:@"STRE"]|| [self.wasteStratum.stratum isEqualToString:@"STRS"]){
        // lock all the picker field
        [self.harvestMethod setEnabled:NO];
        [self.harvestMethod setHidden:YES];
        [self.harvestMethodLabel setText:@"Standing Tree"];
        [self.wasteLevel setEnabled:NO];
        [self.wasteLevel setHidden:YES];
        [self.wasteLevelLabel setHidden:YES];
        [self.wasteType setEnabled:NO];
        [self.wasteType setHidden:YES];
        [self.wasteTypeLabel setHidden:YES];
        [self.assesmentSize setEnabled:NO];
        
        if ([self.wasteStratum.stratum isEqualToString:@"STRE"]){
            self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:@"E"];
            self.wasteStratum.stratumPlotSizeCode = (PlotSizeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"plotSizeCode" code:@"E"];
            self.assesmentSize.text = [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumPlotSizeCode.plotSizeCode, self.wasteStratum.stratumPlotSizeCode.desc];
        }else if ([self.wasteStratum.stratum isEqualToString:@"STRS"]){
            self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:@"S"];
            self.wasteStratum.stratumPlotSizeCode = (PlotSizeCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"plotSizeCode" code:@"S"];
            self.assesmentSize.text = [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumPlotSizeCode.plotSizeCode, self.wasteStratum.stratumPlotSizeCode.desc];
        }
    }

    [self.addPlotButton setHidden:YES];
    [self.addRatioPlotButton setHidden:YES];
    
    if([self.wasteStratum.stratumPlotSizeCode.plotSizeCode isEqualToString:@"S"] ||
       [self.wasteStratum.stratumPlotSizeCode.plotSizeCode isEqualToString:@"E"]){
        [self.addPlotButton setHidden:NO];
    }
    if([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
        if ([self.wasteBlock.ratioSamplingEnabled integerValue] ==1){
            [self.addRatioPlotButton setHidden:NO];
        }else{
            [self.addPlotButton setHidden:NO];
        }
    }
    if ([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]){
        if ([self.wasteBlock.ratioSamplingEnabled integerValue] ==1){
            [self.addRatioPlotButton setHidden:YES];
        }else{
            [self.addPlotButton setHidden:YES];
        }
    }
    
    /**
            Packing ratio stratum page logic
     */
    // loc3
    if ([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]){
        [self packingRatioStratumPicked];
    }

    
    [self.footerStatView setDisplayFor:nil screenName:@"stratum"];

}

- (void) updateTitle{
    
    
    // if the title is not initialized, or the object has blank fields
    self.navigationItem.title = [self.navigationItem.title length] < 22 ? [[NSMutableString alloc] initWithString:@"(IFOR 203) Stratum - ____"] : self.navigationItem.title;
    
    
    NSMutableString *currentTitle = [[NSMutableString alloc] initWithString: self.navigationItem.title];

    
    NSLog(@"currentStratumTitle = %@", currentTitle );
    
    
    // from the begining of the number, starting with second number (the last 3 numbers are made up of stratum.harvestmethod, stratum.assemsize, stratum.wastelevel
    NSMutableString *last4numbers = [[NSMutableString alloc] initWithString: [self.navigationItem.title substringWithRange:NSMakeRange(21, self.navigationItem.title.length-21)] ];

    NSString *tmp = @"";

    if ( self.wasteStratum.stratumStratumTypeCode && [self.wasteStratum.stratumStratumTypeCode.stratumTypeCode isEqualToString:@"S"]){
        
        [last4numbers replaceCharactersInRange:NSMakeRange(0, 3) withString:@"STR"];
        [last4numbers replaceCharactersInRange:NSMakeRange(3, 1) withString:self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode ];
        
    }else{
    
        // replace 1st number of title
        tmp = [[self codeFromText:self.wasteType.text] isEqualToString:@""] ? @"_" : [self codeFromText:self.wasteType.text];
        [last4numbers replaceCharactersInRange:NSMakeRange(0, 1) withString:tmp];
        
        // replace 2nd number of title
        tmp = [[self codeFromText:self.harvestMethod.text] isEqualToString:@""] ? @"_" : [self codeFromText:self.harvestMethod.text];
        [last4numbers replaceCharactersInRange:NSMakeRange(1, 1) withString:tmp];
        
        // replace 3rd number of title
        if (self.wasteStratum.stratumAssessmentMethodCode && ![self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"] ){
            [last4numbers replaceCharactersInRange:NSMakeRange(2, 1) withString:self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode ];
        }else{
            tmp = [ [self codeFromText:self.assesmentSize.text] isEqualToString:@""] ? @"_" : [self codeFromText:self.assesmentSize.text];
            [last4numbers replaceCharactersInRange:NSMakeRange(2, 1) withString:tmp ]; // fixed BUG - if new string is empty it deletes the char
        }
        
        // replace 4th number of title
        tmp = [ [self codeFromText:self.wasteLevel.text] isEqualToString:@""] ? @"_" : [self codeFromText:self.wasteLevel.text];
        [last4numbers replaceCharactersInRange:NSMakeRange(3, 1) withString:tmp ];
        
    }
    
    
    
    // replace the last 3 numbers with the new values
    [currentTitle replaceCharactersInRange:NSMakeRange(21, self.navigationItem.title.length-21) withString:last4numbers];
    
    
    NSString *updatedTitle = [[NSString alloc] initWithFormat:@"%@", currentTitle];
    
    
    [[self navigationItem] setTitle:updatedTitle];
}

// textfield delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


// INPUT VALIDATION
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

- (NSString*) codeFromText:(NSString*)pickerText{
    
    // 1st one is the Code
    // 2nd one is the .desc
    return [[pickerText componentsSeparatedByString:@" - "] objectAtIndex:0];
}

-(void)promptForConfirmVolume:(UIAlertController*)alert{
    NSDecimalNumber* gv = nil;
    NSDecimalNumber* dv = nil;
    NSNumber* pn = nil;
    NSString* gv_str = @"";
    NSString* dv_str = @"";
    NSString* pn_str = @"";
    if([wasteBlock.regionId integerValue] == InteriorRegion){
        for(UITextField* tf in alert.textFields){
            if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Predicted Plot Volume (m3)", nil)]){
                gv = [[NSDecimalNumber alloc] initWithString:tf.text];
                gv_str =tf.text;
            }
            if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Plot Number", nil)]){
                pn = [[NSDecimalNumber alloc] initWithString:tf.text];
                pn_str = tf.text;
            }
        }
        BOOL duplicatePlot = NO;
        if (pn){
            for(WastePlot* wp in wasteStratum.stratumPlot){
                if( [wp.plotNumber integerValue] == [pn integerValue]){
                    duplicatePlot = YES;
                    break;
                }
            }
        }
        
        if([pn_str isEqualToString:@""] || [gv_str isEqualToString:@""]){
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                              message:@"Please enter Plot Number, Predicted Plot Volume."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self presentViewController:alert animated:YES completion:nil];
                                                              }];
            
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }else if(duplicatePlot){
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Duplicate Plot Number", nil)
                                                                                  message:@"Duplicate plot number, Select new plot number before proceeding."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self presentViewController:alert animated:YES completion:nil];
                                                             }];
            
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }else if([pn integerValue] > [wasteStratum.predictionPlot integerValue]){
           UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid Plot Number", nil)
                                                                                    message:@"Plot number cannot be greater than the number of prediction plots, Select new plot number before proceeding."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
              
              UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [self presentViewController:alert animated:YES completion:nil];
                                                               }];
              
              [warningAlert addAction:okAction];
              [self presentViewController:warningAlert animated:YES completion:nil];
        }
        else{
            UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Estimation", nil)
                   message:[NSString stringWithFormat:@"Accept volume estimate? \n Plot Number %d \n Predicted Plot Volume (m3)= %.2f",[pn intValue], [gv floatValue]]
            preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self addRatioPlotAndNavigate:gv dryVolume:dv plotNumber:pn];
                                                              }];
            
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self presentViewController:alert animated:YES completion:nil];
                                                             }];
            [confirmAlert addAction:yesAction];
            [confirmAlert addAction:noAction];
            [self presentViewController:confirmAlert animated:YES completion:nil];
        }
    } else if([wasteBlock.regionId integerValue] == CoastRegion){
        for(UITextField* tf in alert.textFields){
            if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Predicted Plot Volume (m3)", nil)]){
                gv = [[NSDecimalNumber alloc] initWithString:tf.text];
                gv_str =tf.text;
            }
            if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Plot Number", nil)]){
                pn = [[NSDecimalNumber alloc] initWithString:tf.text];
                pn_str = tf.text;
            }
        }
        BOOL duplicatePlot = NO;
        if (pn){
            for(WastePlot* wp in wasteStratum.stratumPlot){
                if( [wp.plotNumber integerValue] == [pn integerValue]){
                    duplicatePlot = YES;
                    break;
                }
            }
        }
        
        
        if([pn_str isEqualToString:@""] || [gv_str isEqualToString:@""]){
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                                  message:@"Please enter Plot Number, Predicted Plot Volume."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self presentViewController:alert animated:YES completion:nil];
                                                             }];
            
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }else if(duplicatePlot){
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Duplicate Plot Number", nil)
                                                                                  message:@"Duplicate plot number, Select new plot number before proceeding."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self presentViewController:alert animated:YES completion:nil];
                                                             }];
            
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }else if([pn integerValue] > [wasteStratum.predictionPlot integerValue]){
           UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid Plot Number", nil)
                                                                                    message:@"Plot number cannot be greater than the number of prediction plots, Select new plot number before proceeding."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
              
              UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [self presentViewController:alert animated:YES completion:nil];
                                                               }];
              
              [warningAlert addAction:okAction];
              [self presentViewController:warningAlert animated:YES completion:nil];
        }
        else{
            UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Estimation", nil)
                                                                                  message:[NSString stringWithFormat:@"Accept volume estimate? \n Plot Number %d \n Predicted Plot Volume (m3)= %.2f",[pn intValue], [gv floatValue]]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self addRatioPlotAndNavigate:gv dryVolume:0 plotNumber:pn];
                                                              }];
            
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self presentViewController:alert animated:YES completion:nil];
                                                             }];
            [confirmAlert addAction:yesAction];
            [confirmAlert addAction:noAction];
            [self presentViewController:confirmAlert animated:YES completion:nil];
        }
    }
}

-(void)addRatioPlotAndNavigate:(NSDecimalNumber*)greenVolume dryVolume:(NSDecimalNumber*)dryVolume plotNumber:(NSNumber*)pn{
    
    WastePlot* wp = [self addEmptyPlot];
    wp.dryVolume = dryVolume;
    wp.greenVolume = greenVolume;
    wp.plotNumber = pn;
    wp.measurePctEdited = [NSNumber numberWithInt:0];
    
    BOOL isMeasurePlot = NO;
    NSArray* pn_ary = nil;
    [PlotSampleGenerator addPlot2:self.wasteStratum plotNumber:[wp.plotNumber intValue]];
    pn_ary = [self.wasteStratum.n1sample componentsSeparatedByString:@","];

    for(NSString* pn in pn_ary){
        if([pn isEqualToString:[wp.plotNumber stringValue]]){
            isMeasurePlot = YES;
            break;
        }
    }
    wp.isMeasurePlot = isMeasurePlot? [[NSNumber alloc]  initWithInt:1] : [[NSNumber alloc]  initWithInt:0];
    
    [self saveData];
    
    PlotViewController *plotVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlotViewControllerSID"];
    plotVC.wastePlot = wp;
    plotVC.wasteBlock = self.wasteBlock;
    plotVC.originalMP = [NSNumber numberWithInt:100];
    
    NSString *newEntry = [PlotSelectorLog getPlotSelectorLog:wp stratum:wasteStratum actionDec:@"New Plot Added"];
    wasteStratum.ratioSamplingLog = [wasteStratum.ratioSamplingLog stringByAppendingString:newEntry];
    wasteBlock.ratioSamplingLog = [wasteBlock.ratioSamplingLog stringByAppendingString:newEntry];
    //update the benchmak and calculate the numbers again
    [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
    [WasteCalculator calculateRate:self.wasteBlock];
    [WasteCalculator calculatePiecesValue:self.wasteBlock ];
    if([self.wasteBlock.userCreated intValue] ==1){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
    }
    [self saveData];

    [self.navigationController pushViewController:plotVC animated:YES];
}

-(NSString*)getDefaultPredictionPlot:(NSString*)wasteTypeCode{
    NSString* result = @"";
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue])
    {
        if([wasteTypeCode isEqualToString:@"S"] ||
           [wasteTypeCode isEqualToString:@"D"] ||
           [wasteTypeCode isEqualToString:@"G"]){
            result = DEFAULT_DISPERSED_PRED_PLOT;
        }else if([wasteTypeCode isEqualToString:@"P"] ||
                 [wasteTypeCode isEqualToString:@"O"] ||
                 [wasteTypeCode isEqualToString:@"L"] ||
                 [wasteTypeCode isEqualToString:@"R"]){
            result = DEFAULT_ACCU_PRED_PLOT;
        }
    }
    return result;
}

-(NSString*)getDefaultMeasurePlot:(NSString*)wasteTypeCode{
    NSString* result = @"";
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue])
    {
        if([wasteTypeCode isEqualToString:@"S"] ||
           [wasteTypeCode isEqualToString:@"D"] ||
           [wasteTypeCode isEqualToString:@"G"]){
            result = DEFAULT_DISPERSED_MEASURE_PLOT;
            
        }else if([wasteTypeCode isEqualToString:@"P"] ||
                 [wasteTypeCode isEqualToString:@"O"] ||
                 [wasteTypeCode isEqualToString:@"L"] ||
                 [wasteTypeCode isEqualToString:@"R"]){
            result = DEFAULT_ACCU_MEASURE_PLOT;
        }
    }
    return result;
}

-(WastePlot*)addEmptyPlot{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePlot *wp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
    wp.assistant = @"";
    wp.baseline = @"";
    wp.certificateNumber = @"";
    wp.checkDate = [NSDate date];
    wp.notes = @"";
    wp.plotID = @0;
    wp.returnNumber = @"";
    wp.strip = @0;
    wp.surveyDate = [NSDate date];
    wp.surveyorName = @"";
    wp.weather = @"";
    wp.plotPiece = nil;
    wp.plotShapeCode = nil;
    wp.plotSizeCode = nil;
    wp.plotStratum = nil;
    
    //find the next plot number, it could be out of order
    //get the last sequence number
    int targetNum = 1;
    for(WastePlot *p in self.sortedPlots){
        if( [p.plotNumber intValue] == targetNum){
            targetNum = targetNum + 1;
        }else{
            break;
        }
    }
    wp.plotNumber = [[NSNumber alloc] initWithLong: targetNum];
    
    // for user created cut block
    if ([self.wasteBlock.userCreated intValue] == 1){
        // set check measure percent to 0 and survey measure % to 100
        [wp setIsSurvey:[NSNumber numberWithBool:YES]];
        wp.checkerMeasurePercent = [[NSNumber alloc] initWithInteger:0];
        wp.surveyedMeasurePercent = [[NSNumber alloc] initWithInteger:100];
        
        //populate the surveyor name and return number from cut block
        if(self.wasteBlock.returnNumber && [self.wasteBlock.returnNumber intValue] > 0) {
            wp.returnNumber = [[NSString alloc] initWithString:[self.wasteBlock.returnNumber stringValue]];
        }
        if (self.wasteBlock.surveyorName) {
            wp.surveyorName = [[NSString alloc] initWithString:self.wasteBlock.surveyorName];
        }
        if (self.wasteBlock.surveyorLicence){
            wp.certificateNumber =[[NSString alloc] initWithString:self.wasteBlock.surveyorLicence];
        }
        
        if([wasteBlock.regionId integerValue] == CoastRegion){
            wp.plotCoastStat = [WasteBlockDAO createEFWCoastStat];
        }else if([wasteBlock.regionId integerValue] == InteriorRegion){
            wp.plotInteriorStat = [WasteBlockDAO createEFWInteriorStat];
        }
    }else{
        [wp setIsSurvey:[NSNumber numberWithBool:NO]];
        wp.checkerMeasurePercent = [[NSNumber alloc] initWithInteger:100];
        wp.surveyedMeasurePercent = [[NSNumber alloc] initWithInteger:0];
    }
    
    [self.wasteStratum addStratumPlotObject:wp];

    return wp;
}

#pragma mark - Core data related function
-(void) deletePlot:(WastePlot *)targetWastePlot targetWastePlot:(WasteStratum *)targetWasteStratum{
    
    if([targetWasteStratum.stratumBlock.ratioSamplingEnabled integerValue]== 1){
        wasteStratum.ratioSamplingLog = [wasteStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:targetWastePlot stratum:targetWasteStratum actionDec:@"Delete Plot"]];
        wasteBlock.ratioSamplingLog = [wasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:targetWastePlot stratum:targetWasteStratum actionDec:@"Delete Plot"]];
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    //1 - remove the piece object
    // use NSManagedObject because getting the compile warning ???
    for( NSManagedObject *wpi in targetWastePlot.plotPiece ){
        [context deleteObject:wpi];
    }
    
    //2 - remove the piece from plot
    NSMutableSet *tempPlot = [NSMutableSet setWithSet:targetWasteStratum.stratumPlot];
    [tempPlot removeObject:targetWastePlot];
    targetWasteStratum.stratumPlot = tempPlot;
    
    //3 - delete the piece from core data
    [context deleteObject:targetWastePlot];
    
    NSError *error;
    [context save:&error];
    
    if (error){
        NSLog(@"Error when deleting a piece and save :%@", error);
    }
    
}
-(void) deletePile:(WastePile *)targetWastePile targetWastePile:(WasteStratum *)targetWasteStratum {
    if ([targetWasteStratum.stratumBlock.ratioSamplingEnabled integerValue] == 1) {
        NSString *newEntry = [PlotSelectorLog getPileSelectorLog:targetWastePile stratum:targetWasteStratum actionDec:@"Delete Plot"];
        wasteStratum.ratioSamplingLog = [wasteStratum.ratioSamplingLog stringByAppendingString:newEntry];
        wasteBlock.ratioSamplingLog = [wasteBlock.ratioSamplingLog stringByAppendingString:newEntry];
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // 1 - remove the plot from stratum
    NSMutableSet *tempPile = [NSMutableSet setWithSet:targetWasteStratum.stratumPile];
    [tempPile removeObject:targetWastePile];
    targetWasteStratum.stratumPile = tempPile;
    
    // 2 - delete the plot from core data
    [context deleteObject:targetWastePile];
    
    // 3 - update the total number of piles
    NSLog(@"@(targetWasteStratum.stratumPile.count): %@", @(targetWasteStratum.stratumPile.count));
    targetWasteStratum.totalNumPile = @(targetWasteStratum.stratumPile.count);
    
    // 4 - Update the # Plots field
    NSString *countText = [NSString stringWithFormat:@"%lu", (long)targetWasteStratum.totalNumPile.integerValue];
    NSLog(@"countText: %@", countText);
    self.totalPile.text = countText;

    NSError *error;
    [context save:&error];
    
    if (error){
        NSLog(@"Error when deleting a piece and save :%@", error);
    }
}

// PACKING RATIO CONTINUE BUTTON FUNCTION
- (IBAction)viewandAddPile:(id)sender {

    [self saveData];
    WastePlotValidator *wpv = [[WastePlotValidator alloc] init];
    NSString *errorMessage = [wpv validateStratum:wasteStratum];
        
    if (![errorMessage isEqualToString:@""]){
        UIAlertView *validateAlert = nil;
        validateAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        validateAlert.tag = ValidEnum;
        [validateAlert show];
    }else{
        // Single Block SRS
        if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
            NSLog(@"%@",self.wasteStratum.totalNumPile);
            NSNumber *pileId = [self singleBlockSRSPileData];
            [self addPileAndNavigate:pileId];
        }
        // Single Block Ratio
        else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
            [self promptForPileEstimate];
            [self saveData];
        }
        // Aggregate SRS
        else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
            NSNumber *pileId = [self aggregateSRSPileData];
            [self addPileAndNavigate:pileId];
        }
        // Aggregate Ratio
        else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
            [self promptForPileEstimate];
            [self saveData];
        }
    }
}

- (void)addPileAndNavigate:(NSNumber *)pileId {

    [self saveData];
    
    PileViewController *pileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PileViewControllerSID"];
    pileVC.wasteStratum = self.wasteStratum;
    pileVC.wasteBlock = self.wasteBlock;
    [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
    [WasteCalculator calculateRate:self.wasteBlock ];
    [WasteCalculator calculatePiecesValue:self.wasteBlock ];
    if([self.wasteBlock.userCreated intValue] == 1){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
    }
    
    NSSet<WastePile *> *wastePiles = self.wasteStratum.stratumPile;
    NSArray<WastePile *> *piles;

    if (wastePiles) {
        piles = [wastePiles allObjects];
    } else {
        piles = nil;
    }

    pileVC.wastePiles = piles;
    
    // pull out the pile that we are looking for
    for (WastePile* pile in piles)
    {
        if ([pile.pileId isEqual:pileId])
        {
            pileVC.wastePile = pile;
            break;
        }
    }

    [self saveData];
    
    [self.navigationController pushViewController:pileVC animated:YES];
    
}

-(void)promptForPileEstimate{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Plot Estimate"
                                                                   message:@"Please enter your estimate for:\n- Length\n- Width\n- Height"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Plot Number", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Plot Number", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 9;
        textField.delegate           = self;
        self.plotNumberTextField          = textField;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Length", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Length", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 4;
        textField.delegate           = self;
        self.lengthTextField              = textField;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Width", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Width", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 4;
        textField.delegate           = self;
        self.widthTextField               = textField;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Height", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Height", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 4;
        textField.delegate           = self;
        self.heightTextField              = textField;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                [self handleShapeCodeSelectionWithParentAlert:alert];
            }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {
    }];
    
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handleShapeCodeSelectionWithParentAlert:(UIAlertController *)parentAlert {
    UIAlertController *shapeCodeAlert = [UIAlertController alertControllerWithTitle:@"Shape Code"
                                                                              message:@""
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    int i = 0;
    for (PileShapeCode *psc in [[CodeDAO sharedInstance] getPileShapeCodeList]) {
        NSString *optionValue = [NSString stringWithFormat:@"%@%@%@", psc.pileShapeCode, @" - ", psc.desc];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:optionValue style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                [self didSelectRowInAlertController:i];
                UITextField *plotNumberTextField = parentAlert.textFields[0];
                UITextField *lengthTextField = parentAlert.textFields[1];
                UITextField *widthTextField = parentAlert.textFields[2];
                UITextField *heightTextField = parentAlert.textFields[3];
                
                NSDecimalNumber *length = [NSDecimalNumber decimalNumberWithString:lengthTextField.text];
                NSDecimalNumber *width = [NSDecimalNumber decimalNumberWithString:widthTextField.text];
                NSDecimalNumber *height = [NSDecimalNumber decimalNumberWithString:heightTextField.text];
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *pileNumber = [numberFormatter numberFromString:plotNumberTextField.text];
                NSString *pileShapeCode = psc.pileShapeCode;
                
                [self validatePileEstimate:parentAlert
                                   length:length
                                    width:width
                                   height:height
                               pileNumber:pileNumber
                           pileShapeCode:pileShapeCode];
                
                [self presentViewController:parentAlert animated:YES completion:nil];
            }];
        [shapeCodeAlert addAction:defaultAction];
        i++;
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              //[self presentViewController:parentAlert animated:YES completion:nil];
                                                          }];
    
    [shapeCodeAlert addAction:cancelAction];
    [self presentViewController:shapeCodeAlert animated:YES completion:nil];
}


-(void)didSelectRowInAlertController:(NSInteger)row {
    NSArray *text = [[CodeDAO sharedInstance] getPileShapeCodeList];
    self.currentpile = [text objectAtIndex:row ];
}

- (BOOL)validatePileEstimate:(UIAlertController *)alert
                      length:(NSDecimalNumber *)length
                       width:(NSDecimalNumber *)width
                      height:(NSDecimalNumber *)height
                  pileNumber:(NSNumber *)pileNumber
              pileShapeCode:(NSString *)pileShapeCode {
    NSString *length_str = [length stringValue];
    NSString *width_str = [width stringValue];
    NSString *height_str = [height stringValue];
    NSString *pileNumber_str = [pileNumber stringValue];
    //NSString *pileShapeCode_str = pileShapeCode;

    BOOL duplicatePile = NO;
    if (pileNumber_str){
        for(WastePile* wp in wasteStratum.stratumPile){
            if( [wp.pileNumber integerValue] == [pileNumber_str integerValue]){
                duplicatePile = YES;
                break;
            }
        }
    }

    NSString *warningMsg = @"";
    
    if([pileNumber_str isEqualToString:@""] || [length_str isEqualToString:@""] || [width_str isEqualToString:@""] || [height_str isEqualToString:@""]){
        warningMsg = [warningMsg stringByAppendingString:@"Please enter Pile Number, Length, Width and Height.\n"];
    } else if ([[pileNumber_str lowercaseString] isEqualToString:@"nan"] || [[length_str lowercaseString] isEqualToString:@"nan"] || [[width_str lowercaseString] isEqualToString:@"nan"] || [[height_str lowercaseString] isEqualToString:@"nan"]) {
        warningMsg = [warningMsg stringByAppendingString:@"Please enter Pile Number, Length, Width and Height.\n"];
    } if(duplicatePile){
        warningMsg = [warningMsg stringByAppendingString:@"Duplicate pile number, Select new pile number before proceeding.\n"];
    }
    if([pileNumber_str integerValue]<1 || [pileNumber_str intValue] > ([wasteStratum.predictionPlot intValue])) {
        warningMsg = [warningMsg stringByAppendingString:[NSString stringWithFormat:@"Pile number should be from 1 to %d\n", ([wasteStratum.predictionPlot intValue])]];
        }
        if([length floatValue] < 0.1 || [length floatValue] >= 10000) {
            warningMsg = [warningMsg stringByAppendingString:@"Length should be from 0.1 to 9999.9\n"];
        }
        if([width floatValue] < 0.1 || [width floatValue] >= 10000) {
            warningMsg = [warningMsg stringByAppendingString:@"Width should be from 0.1 to 9999.9\n"];
        }
        if([height floatValue] < 0.1 || [height floatValue] >= 100) {
            warningMsg = [warningMsg stringByAppendingString:@"Height should be from 0.1 to 99.9\n"];
        }

    if(![warningMsg isEqualToString:@""])
    {
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
        message:warningMsg
        preferredStyle:UIAlertControllerStyleAlert
        ];

        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {
         [self presentViewController:alert animated:YES completion:nil];
        }];

        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }

    UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Estimation", nil)
                      message:[NSString stringWithFormat:@"Accept volume estimates? \n Length = %.1f \n Width = %.1f \n Height = %.1f \n Shape Code = %@",
                       [length floatValue], [width floatValue], [height floatValue], [pileShapeCode uppercaseString]]
                       preferredStyle:UIAlertControllerStyleAlert
    ];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {
        [self addPackingratioRatioPileAndNavigate:length width:width height:height pileNumber:pileNumber pileShapeCode:pileShapeCode];
    }];
        
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault
         handler:^(UIAlertAction * action) {}];
    [confirmAlert addAction:yesAction];
    [confirmAlert addAction:noAction];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

// The purpose of this is to generate a pileVolume for Packing Ratio Stratums in Ratio Blocks
// the pileVolume is added to the PlotSelectorLogs when a plot/pile is created
-(void) calculatePileAreaAndVolume:(WastePile *)wastePile srsOrRatio:(NSInteger)ratio {
    float pi = 3.141592;
    if(ratio == 1){
        if([wastePile.pilePileShapeCode.pileShapeCode isEqual:@""]){
            wastePile.pileArea = 0;
            wastePile.pileVolume = 0;
        }else if([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"CN"]){
            wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:(pow((([wastePile.width doubleValue] + [wastePile.length doubleValue]) / 2) / 2, 2)  * pi)] ;
            wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:(pow((([wastePile.width doubleValue] + [wastePile.length doubleValue]) / 2) / 2, 2)  * pi) * ([wastePile.height doubleValue]/3)] ;
        }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"CY"]) {
            wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:[wastePile.length doubleValue] * [wastePile.width doubleValue]] ;
            wastePile.pileVolume =  [[NSDecimalNumber alloc] initWithDouble:((pi * [wastePile.width doubleValue] * [wastePile.length doubleValue] * [wastePile.height doubleValue])/4)] ;
        }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"PR"]) {
            wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:(pow((([wastePile.width doubleValue] + [wastePile.length doubleValue]) / 2) / 2, 2) * pi)] ;
            wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:(pow((([wastePile.width doubleValue] + [wastePile.length doubleValue]) / 2), 2) * pi) * ([wastePile.height doubleValue]/8)] ;
        } else {
            wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:0];
            wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:0];
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:0];
            wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:0];
        }
    }
}

-(void)addPackingratioRatioPileAndNavigate:(NSDecimalNumber*)length width:(NSDecimalNumber*)width height:(NSDecimalNumber*)height pileNumber:(NSNumber*)pileNumber pileShapeCode:(NSString*)pileShapeCode {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if ([wasteStratum.fixedSample isEqualToString:@""]) {
        [PlotSampleGenerator generatePlotSample2:self.wasteStratum];
    }
    
    WastePile* wp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePile" inManagedObjectContext:context];
    wp.length = length;
    wp.width = width;
    wp.height = height;
    wp.measuredLength = nil;
    wp.measuredWidth = nil;
    wp.measuredHeight = nil;
    wp.pileNumber = pileNumber;
    wp.pileId = [NSNumber numberWithInt:[pileNumber intValue]];
    wp.pilePileShapeCode = nil;
    wp.pileMeasuredPileShapeCode = nil;
    for (PileShapeCode *psc in [[CodeDAO sharedInstance] getPileShapeCodeList]) {
        if ([psc.pileShapeCode isEqualToString:pileShapeCode]) {
            wp.pilePileShapeCode = psc;
        }
    }
    wp.surveyorName = self.wasteBlock.surveyorName;
    wp.surveyorLicence = self.wasteBlock.surveyorLicence;
    wp.returnNumber = [self.wasteBlock.returnNumber stringValue];
    BOOL isSample = NO;
    NSArray* pn_ary = nil;
    [PlotSampleGenerator addPlot2:self.wasteStratum plotNumber:[wp.pileNumber intValue]];
    pn_ary = [self.wasteStratum.n1sample componentsSeparatedByString:@","];
    
//    NSLog(@"fixedplots");
//    NSLog(@"%@", self.wasteStratum.fixedSample);
    for(NSString* pn in pn_ary){
        if([pn isEqualToString:[wp.pileNumber stringValue]]){
            isSample = YES;
            break;
        }
    }
    wp.isSample = isSample ? [[NSNumber alloc]  initWithInt:1] : [[NSNumber alloc]  initWithInt:0];
    
    NSMutableSet<WastePile *> *mutableSet = [NSMutableSet setWithSet:self.wasteStratum.stratumPile];
    [mutableSet addObject:wp];
    self.wasteStratum.stratumPile = [NSSet setWithSet:mutableSet];
    self.wasteStratum.totalNumPile = @(self.wasteStratum.totalNumPile.integerValue+1);
    
    [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
    [WasteCalculator calculateRate:self.wasteBlock ];
    [WasteCalculator calculatePiecesValue:self.wasteBlock ];
    if([self.wasteBlock.userCreated intValue] == 1){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
    }

    [self calculatePileAreaAndVolume:wp srsOrRatio:[self.wasteBlock.ratioSamplingEnabled intValue]];
    if ([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]) {
        NSString *newEntry = [PlotSelectorLog getPileSelectorLog:wp stratum:wasteStratum actionDec:@"New Plot Added"];
        wasteStratum.ratioSamplingLog = [wasteStratum.ratioSamplingLog stringByAppendingString:newEntry];
        wasteBlock.ratioSamplingLog = [wasteBlock.ratioSamplingLog stringByAppendingString:newEntry];
    }

    
    [self saveData];
    
    PileViewController *pileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PileViewControllerSID"];
    pileVC.wastePile = wp;
    pileVC.wasteBlock = self.wasteBlock;
    pileVC.wasteStratum = self.wasteStratum;
    NSArray *piles = [self.wasteStratum.stratumPile allObjects];
    pileVC.wastePiles = piles;

    
    
    [self.navigationController pushViewController:pileVC animated:YES];
}

-(NSNumber*)getUniquePileId{
    NSSet<WastePile*> *wastePiles = self.wasteStratum.stratumPile;
    NSMutableSet<NSNumber *> *existingPileIds = [NSMutableSet set];
    for (WastePile *p in wastePiles) {
        if (p.pileId != nil) {
            [existingPileIds addObject:p.pileId];
        }
    }
    NSNumber *newPileId;
    do {
        newPileId = @(arc4random_uniform(UINT32_MAX)); // You can use a different method to generate a unique ID if needed
    } while ([existingPileIds containsObject:newPileId]);
    return newPileId;
}

-(NSNumber*)singleBlockSRSPileData{
    NSManagedObjectContext *context = [self managedObjectContext];

    WastePile *newWp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePile" inManagedObjectContext:context];
    
    newWp.pileNumber = nil;
    newWp.pileId = [self getUniquePileId];
    newWp.measuredLength = nil;
    newWp.measuredWidth = nil;
    newWp.measuredHeight = nil;
    newWp.isSample = [[NSNumber alloc] initWithBool:YES];
    newWp.surveyorName = self.wasteBlock.surveyorName;
    newWp.surveyorLicence = self.wasteBlock.surveyorLicence;
    newWp.returnNumber = [self.wasteBlock.returnNumber stringValue];
    NSMutableSet<WastePile *> *mutableSet = [NSMutableSet setWithSet:self.wasteStratum.stratumPile];
    [mutableSet addObject:newWp];
    self.wasteStratum.stratumPile = [NSSet setWithSet:mutableSet];
    self.wasteStratum.totalNumPile = @(self.wasteStratum.totalNumPile.integerValue+1);
    self.wasteStratum.totalPileCounter = @(self.wasteStratum.totalPileCounter.integerValue+1);
    return newWp.pileId;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSNumber*)aggregateSRSPileData{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePile *newWp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePile" inManagedObjectContext:context];
        
    newWp.pileNumber = nil;
    newWp.pileId = [self getUniquePileId];
    newWp.measuredLength = nil;
    newWp.measuredWidth = nil;
    newWp.measuredHeight = nil;
    newWp.isSample = [[NSNumber alloc] initWithBool:YES];
    newWp.surveyorName = self.wasteBlock.surveyorName;
    newWp.surveyorLicence = self.wasteBlock.surveyorLicence;
    newWp.returnNumber = [self.wasteBlock.returnNumber stringValue];
    NSMutableSet<WastePile *> *mutableSet = [NSMutableSet setWithSet:self.wasteStratum.stratumPile];
    [mutableSet addObject:newWp];
    self.wasteStratum.stratumPile = [NSSet setWithSet:mutableSet];
    self.wasteStratum.totalNumPile = @(self.wasteStratum.totalNumPile.integerValue+1);
    self.wasteStratum.totalPileCounter = @(self.wasteStratum.totalPileCounter.integerValue+1);
    return newWp.pileId;
}

- (IBAction)deletePileShow:(id)sender{
    NSString *title = NSLocalizedString(@"Endorsement of Data Changes", nil);
    NSString *message = NSLocalizedString(@"Delete Pile", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Confirm Deletion", nil);
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Surveyor Name", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Surveyor Name", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 3;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Designation", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Designation", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 3;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"License Number", nil);
        textField.accessibilityLabel = NSLocalizedString(@"License Number", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 3;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Rationale for Deletion", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Rationale for Deletion", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 3;
        textField.delegate           = self;
    }];
    
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:otherButtonTitleOne style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        UIButton *button = (UIButton *)sender;
        [self validateAndDeletePile:alert pileNumber:button.tag];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
    }];
    
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];

    DataEndorsementViewController *devc = [self.storyboard instantiateViewControllerWithIdentifier:@"dataEndorsementViewController"];
    devc.wasteStratum = self.wasteStratum;
    devc.stratumVC = self;
    devc.endorsementType = @"Delete Pile";
    UIButton *button = (UIButton *)sender;
    devc.plotNumber = [NSNumber numberWithInt:button.tag];
    [self.navigationController pushViewController:devc animated:YES];
}

-(void)validateAndDeletePile:(UIAlertController*)alert pileNumber:(int)pileNumber{
    NSString* inputSurveyName = @"";
    NSString* inputDesg = @"";
    NSString* inputLicenseNum = @"";
    NSString* inputRationale = @"";	
    for(UITextField* tf in alert.textFields){
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Surveyor Name", nil)]){
            inputSurveyName =tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Designation", nil)]){
            inputDesg = tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"License Number", nil)]){
            inputLicenseNum = tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Rationale for Deletion", nil)]){
            inputRationale =tf.text;
        }
    }
    
    if([inputSurveyName isEqualToString:@""]){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                              message:@"Please enter Surveyor Name."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [self presentViewController:alert animated:YES completion:nil];
        }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else if([inputDesg isEqualToString:@""]){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                              message:@"Please enter a Designation."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [self presentViewController:alert animated:YES completion:nil];
        }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else if(![inputLicenseNum isEqualToString:@""] && inputLicenseNum.length > 8){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid entry", nil)
                                                                                  message:@"The License Number must be 8 characters or less."             preferredStyle:UIAlertControllerStyleAlert];
                
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self presentViewController:alert animated:YES completion:nil];
                                                                  }];
                
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else if (!([inputLicenseNum rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location == NSNotFound)) {
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid entry", nil)
                                                                                  message:@"The License Number must contain only numbers and letters."             preferredStyle:UIAlertControllerStyleAlert];
                
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self presentViewController:alert animated:YES completion:nil];
                                                                  }];
                
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else if([inputRationale isEqualToString:@""] || inputRationale.length < 5 || inputRationale.length > 100){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                                  message:@"Please enter a Rationale for Deletion between 5 and 100 characters."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self presentViewController:alert animated:YES completion:nil];
                                                                  }];
                
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else
    {
        WastePile *targetPile = [self.sortedPiles objectAtIndex:pileNumber];
        targetPile.dcSurveyorName = inputSurveyName;
        targetPile.dcDesignation = inputDesg;
        targetPile.dcLicenseNumber = inputLicenseNum;
        targetPile.dcRationale = inputRationale;
        [PlotSampleGenerator deletePlot2:wasteStratum plotNumber:[targetPile.pileNumber intValue]]; // this function works with piles as well
        [self deletePile:targetPile targetWastePile:wasteStratum];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"pileNumber" ascending:YES];
        self.sortedPiles = [[[self.wasteStratum stratumPile] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        // may want to skip calculations / set to 0
        [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
        [WasteCalculator calculateRate:self.wasteBlock ];
        [WasteCalculator calculatePiecesValue:self.wasteBlock];
        if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
            [self.efwFooterView setStratumViewValue:self.wasteStratum];
        }else{
            [self.footerStatView setViewValue:self.wasteStratum];
        }
        
        [self.packingRatioTableView reloadData];
        [self.aggregatePackingRatioPlotTableView reloadData];
    }
}


@end
