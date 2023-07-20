//
//  StratumViewController.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "StratumViewController.h"
#import "PlotTableViewCell.h"
#import "AggregatePlotTableViewCell.h"
#import "AggregatePileTableViewCell.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "StratumTypeCode.h"
#import "WasteLevelCode.h"
#import "HarvestMethodCode.h"
#import "CodeDAO.h"
#import "PlotSizeCode.h"
#import "WasteTypeCode.h"
#import "WasteCalculator.h"
#import "AssessmentMethodCode.h"
#import "UIColor+WasteColor.h"

#import "BlockViewController.h"
#import "WasteBlock.h"
#import "PlotViewController.h"
#import "PileViewController.h"

#import "ShapeCode.h"
#import "ReportGeneratorTableViewController.h"
#import "Timer.h"
#import "PlotSampleGenerator.h"
#import "PlotSelectorLog.h"
#import "Constants.h"
#import "WasteBlockDAO.h"
#import "WastePile+CoreDataClass.h"
#import "StratumPile+CoreDataClass.h"
#import "AggregateCutblock+CoreDataClass.h"
#import "WastePlotValidator.h"

@class UIAlertView;

@interface StratumViewController ()

@end

@implementation StratumViewController


@synthesize versionLabel, downArrowImage;
@synthesize wasteBlock, wasteStratum, plotTableView, aggregatePlotTableView, aggregatePileTableView, sortColumn, sortLicense, sortCuttingPermit, sortCutblock;

static NSString *const DEFAULT_DISPERSED_PRED_PLOT = @"18";
static NSString *const DEFAULT_DISPERSED_MEASURE_PLOT = @"6";
static NSString *const DEFAULT_ACCU_PRED_PLOT = @"12";
static NSString *const DEFAULT_ACCU_MEASURE_PLOT = @"4";


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
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    

    
    
     
    // pickers values
    [self setupLists];
    

    // STRATUMTYPE PICKER
    //
    /*
    self.stratumTypePicker = [[UIPickerView alloc] init];
    self.stratumTypePicker.dataSource = self;
    self.stratumTypePicker.delegate = self;
    self.stratumTypePicker.tag = 1;
    self.stratumType.inputView = self.stratumTypePicker;
    
    UITapGestureRecognizer *gr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stratumPickerRecognizer:)];
    [self.stratumTypePicker addGestureRecognizer:gr1];
    gr1.delegate = self;
    */
    
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
        self.plotTableView.hidden = TRUE;
        self.aggregatePlotTableView.hidden = FALSE;
        self.aggregatePileTableView.hidden = FALSE;
    }
    
    // POPULATE FROM OBJECT TO VIEW
    [self populateFromObject];
    
    // Populate version number
    [versionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteVersionNumber"]];
}

-(IBAction)sortPlots:(id)sender{
    
    NSString *key = @"";
    if(sender == self.sortLicense){
        key = @"aggregateLicence";
    }else if(sender == self.sortCuttingPermit){
        key = @"aggregateCuttingPermit";
    }else if(sender == self.sortCutblock){
        key = @"aggregateCutblock";
    }else if(sender == self.sortPlotNumber)
    {
        key = @"plotNumber";
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
    self.sortedPlots = [[NSMutableArray alloc] initWithArray:[self.sortedPlots sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    [self.aggregatePlotTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    /*
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    */
    
    
    
    [[Timer sharedManager] setCurrentVC:self];
    
    
    // UPDATE PLOTS
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES]; // is key ok ? does it actually sort according to it
    self.sortedPlots = [[[self.wasteStratum stratumPlot] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc ] initWithKey:@"aggregateCutblock" ascending:YES];
    self.sortedblocks = [[[self.wasteStratum stratumAgg] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort1]];
    
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue] && ![self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"])
    {
        self.plotTableView.hidden = TRUE;
        self.aggregatePlotTableView.hidden = FALSE;
        self.aggregatePileTableView.hidden = TRUE;
    }else if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"])
    {
        self.plotTableView.hidden = TRUE;
        self.aggregatePlotTableView.hidden = TRUE;
        self.aggregatePileTableView.hidden = FALSE;
    }
    
    // UPDATE VIEW
    [self.plotTableView reloadData];
    [self.aggregatePlotTableView reloadData];
    [self.aggregatePileTableView reloadData];
    
    
    int row;
    
    // update stratum type picker selected row
    /*
    row = 0;
    for (StratumTypeCode *stc in self.stratumTypeArray) {
        
        
        if([ [self codeFromText:self.stratumType.text] isEqualToString:stc.stratumTypeCode]){
            
            [self.stratumTypePicker selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }*/
    
    
    
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
        if(self.wasteStratum.strPile != nil ){
            [self.totalPile setEnabled:NO];
            [self.continueButton setEnabled:YES];
            [self.assesmentSize setEnabled:NO];
        }
    }else{
        if([self.wasteStratum.stratumAgg count] > 0){
            [self.assesmentSize setEnabled:NO];
            if(![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""]){
                    [self.addCutblockButton setEnabled:YES];
            }
        }
    }
    [self updateTitle];
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setStratumViewValue:self.wasteStratum];
    }else{
        [self.footerStatView setViewValue:self.wasteStratum];
    }
    //[self populateFromObject];
}


// AUTO-SAVE
- (void)viewWillDisappear:(BOOL)animated{
    /*
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
    */
   
    
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
    /*
    for (StratumTypeCode* stc in self.stratumTypeArray){
        if ([stc.stratumTypeCode isEqualToString:[self codeFromText:self.stratumType.text] ] ){
            self.wasteStratum.stratumStratumTypeCode = stc;
            break;
        }
    }*/
    
    
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
            self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"AssessmentMethodCode" code:[self codeFromText:self.assesmentSize.text]];
        }else if ([self.wasteStratum.stratum isEqualToString:@"STRE"]){
            self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"AssessmentMethodCode" code:@"E"];
            // skip if this is a standing tree
        }else if([self.wasteStratum.stratum isEqualToString:@"STRS"]){
            self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"AssessmentMethodCode" code:@"S"];
        }else if([[self codeFromText:self.assesmentSize.text] isEqualToString:@"R"] && ! ([self.wasteStratum.stratum isEqualToString:@"STRE"] || [self.wasteStratum.stratum isEqualToString:@"STRS"])){
            self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"AssessmentMethodCode" code:[self codeFromText:self.assesmentSize.text]];
        }else{
            self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"AssessmentMethodCode" code:@"P"];
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
    if([self.totalPile.text intValue] == 0){
        //NSLog(@"self.wasteStratum.totalNumPile %@", self.wasteStratum.totalNumPile);
        self.totalPile.text = @"";self.measureSample.text = @"";
        self.wasteStratum.totalNumPile = [[NSNumber alloc] initWithInt:[self.totalPile.text intValue]];
        self.wasteStratum.measureSample = [[NSNumber alloc] initWithInt:[self.measureSample.text intValue]];
        [self.continueButton setEnabled:NO];
    }else{
        self.wasteStratum.totalNumPile = [[NSNumber alloc] initWithInt:[self.totalPile.text intValue]];
        self.wasteStratum.measureSample = [[NSNumber alloc] initWithInt:[self.measureSample.text intValue]];
    }
    
    if([self.wasteBlock.regionId intValue] == InteriorRegion){
        if(![self.grade12Percent.text isEqualToString:@""]){
            if([self.grade12Percent.text doubleValue] >= 0.0 && [self.grade12Percent.text doubleValue] <= 100.0 ){
                self.wasteStratum.grade12Percent = [[NSDecimalNumber alloc] initWithString:self.grade12Percent.text];
            }else{
                self.wasteStratum.grade12Percent = [[NSDecimalNumber alloc] initWithString:@""];
                self.grade12Percent.text = @"";
            }
        }
        if(![self.grade4Percent.text isEqualToString:@""]){
            if([self.grade4Percent.text doubleValue] >= 0.0 && [self.grade4Percent.text doubleValue] <= 100.0 ){
                self.wasteStratum.grade4Percent = [[NSDecimalNumber alloc] initWithString:self.grade4Percent.text];
            }else{
                self.wasteStratum.grade4Percent = [[NSDecimalNumber alloc] initWithString:@""];
                self.grade4Percent.text = @"";
            }
        }
        if(![self.grade5Percent.text isEqualToString:@""]){
            if([self.grade5Percent.text doubleValue] >= 0.0 && [self.grade5Percent.text doubleValue] <= 100.0 ){
                self.wasteStratum.grade5Percent = [[NSDecimalNumber alloc] initWithString:self.grade5Percent.text];
            }else{
                self.wasteStratum.grade5Percent = [[NSDecimalNumber alloc] initWithString:@""];
                self.grade5Percent.text = @"";
            }
        }
    }else if([self.wasteBlock.regionId intValue] == CoastRegion){
        if(![self.grade12Percent.text isEqualToString:@""]){
            if([self.grade12Percent.text doubleValue] >= 0.0 && [self.grade12Percent.text doubleValue] <= 100.0 ){
                self.wasteStratum.gradeJPercent = [[NSDecimalNumber alloc] initWithString:self.grade12Percent.text];
            }else{
                self.wasteStratum.gradeJPercent = [[NSDecimalNumber alloc] initWithString:@""];
                self.grade12Percent.text = @"";
            }
        }
        if(![self.grade5Percent.text isEqualToString:@""]){
            if([self.grade5Percent.text doubleValue] >= 0.0 && [self.grade5Percent.text doubleValue] <= 100.0 ){
                self.wasteStratum.gradeUPercent = [[NSDecimalNumber alloc] initWithString:self.grade5Percent.text];
            }else{
                self.wasteStratum.gradeUPercent = [[NSDecimalNumber alloc] initWithString:@""];
                self.grade5Percent.text = @"";
            }
        }
        if(![self.grade4Percent.text isEqualToString:@""]){
            if([self.grade4Percent.text doubleValue] >= 0.0 && [self.grade4Percent.text doubleValue] <= 100.0 ){
                self.wasteStratum.gradeWPercent = [[NSDecimalNumber alloc] initWithString:self.grade4Percent.text];
            }else{
                self.wasteStratum.gradeWPercent = [[NSDecimalNumber alloc] initWithString:@""];
                self.grade4Percent.text = @"";
            }
        }
    }
    if(![self.gradeXPercent.text isEqualToString:@""]){
        if([self.gradeXPercent.text doubleValue] >= 0.0 && [self.gradeXPercent.text doubleValue] <= 100.0 ){
            self.wasteStratum.gradeXPercent = [[NSDecimalNumber alloc] initWithString:self.gradeXPercent.text];
        }else{
            self.wasteStratum.gradeXPercent = [[NSDecimalNumber alloc] initWithString:@""];
            self.gradeXPercent.text = @"";
        }
    }
    if(![self.gradeYPercent.text isEqualToString:@""]){
         if([self.gradeYPercent.text doubleValue] >= 0.0 && [self.gradeYPercent.text doubleValue] <= 100.0 ){
             self.wasteStratum.gradeYPercent = [[NSDecimalNumber alloc] initWithString:self.gradeYPercent.text];
         }else{
             self.wasteStratum.gradeYPercent = [[NSDecimalNumber alloc] initWithString:@""];
             self.gradeYPercent.text = @"";
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
    NSString *title = NSLocalizedString(@"Delete New Plot", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Delete", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, nil];
    alert.tag = ((UIButton *)sender).tag;
    NSLog(@"Passing the tag from button to the alert view, %ld to %ld",(long)((UIButton *)sender).tag, (long)alert.tag );
    [alert show];
}
- (IBAction)addRatioPlot:(id)sender{
    [self saveData];
    BOOL isValid = YES;
    if([wasteStratum.n1sample isEqualToString:@""] ){
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
            NSString* def_mp =[self getDefaultMeasurePlot:self.wasteStratum.stratumWasteTypeCode.wasteTypeCode];
            NSString* def_pp =[self getDefaultPredictionPlot:self.wasteStratum.stratumWasteTypeCode.wasteTypeCode];
            // check if the user enter value against the default value - don't check for aggregates
            /*if(( ![def_mp isEqualToString:@""] && ![self.measurePlot.text isEqualToString:def_mp]) || (![def_pp isEqualToString:@""] && ![self.predictionPlot.text isEqualToString:def_pp])){
                isValid = NO;
                UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:@"Non-standard Value"
                                                                                      message:@"Prediction Plot and/or Measure Plot are non-standard values, Accept?"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [PlotSampleGenerator generatePlotSample2:self.wasteStratum];
                    [self promptForGreenDryVolume];
                    }];
                UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
                
                [confirmAlert addAction:yesAction];
                [confirmAlert addAction:noAction];
                [self presentViewController:confirmAlert animated:YES completion:nil];
            }else{*/

                [PlotSampleGenerator generatePlotSample2:self.wasteStratum];
                //lock down the prediction plot and measure plot fields
                /*[self.predictionPlot setEnabled:NO];
                [self.predictionPlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
                [self.measurePlot setEnabled:NO];
                [self.measurePlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];*/
            //}
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
        if ([alertView.title isEqualToString:@"Delete New Plot"]){
            
            WastePlot *targetPlot = [self.sortedPlots objectAtIndex:alertView.tag];

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
        }else if ([alertView.title isEqualToString:@"Delete Aggregate Cutblock"]){
            
            AggregateCutblock *targetblock = [self.sortedblocks objectAtIndex:alertView.tag];

            [self deleteAggregateCB:targetblock targetAggregateCB:wasteStratum];
            
            NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"aggregateCutblock" ascending:YES];
            self.sortedblocks = [[[self.wasteStratum stratumAgg] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
            [WasteCalculator calculateRate:self.wasteBlock ];
            [WasteCalculator calculatePiecesValue:self.wasteBlock];
            if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
                [WasteCalculator calculateEFWStat:self.wasteBlock];
                [self.efwFooterView setStratumViewValue:self.wasteStratum];
            }else{
                [self.footerStatView setViewValue:self.wasteStratum];
            }
           
            [self.aggregatePileTableView reloadData];
            
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
        //NSLog(@" plotCount = %lu ",(unsigned long)[[self.wasteStratum stratumPlot] count]);
    /*if(![self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]){
        NSLog(@"normal plot %lu", (unsigned long)[[self.wasteStratum stratumPlot] count]);
        return [[self.wasteStratum stratumPlot] count];
    }else{
        NSLog(@"agg pile %lu", (unsigned long)[[self.wasteStratum stratumPlot] count]);
        return [[self.wasteStratum stratumAgg] count];
    }*/
    if(tableView == plotTableView || tableView == aggregatePlotTableView){
        NSLog(@"normal plot %lu", (unsigned long)[[self.wasteStratum stratumPlot] count]);
               return [[self.wasteStratum stratumPlot] count];
    }else if(tableView ==aggregatePileTableView){
        NSLog(@"agg pile %lu", (unsigned long)[[self.wasteStratum stratumAgg] count]);
               return [[self.wasteStratum stratumAgg] count];
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
    
    
    //not a pile stratum
    if([self.wasteStratum.isPileStratum intValue] == 0){
        //non-aggregate block
        //Note: it populates both table views regardless if one is hidden
        if(tableView == plotTableView)
        {
            PlotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlotTableCellID"];

            //NSLog(@" plots = %lu ", (unsigned long)[[self.wasteStratum stratumPlot] count]);
            //NSLog(@" sorted plots =  %d", [self.sortedPlots count]);
            //NSLog(@" row = %ld ",(long)indexPath.row);

            WastePlot *pt = ([self.sortedPlots count] == 1) ? [self.sortedPlots objectAtIndex:0] : [self.sortedPlots objectAtIndex:indexPath.row];

            
                /*
                NSLog(@"PLOT_ID %@ - FILL VIEW FROM OBJ", pt.plotID);
                NSLog(@"plotNum = %@",pt.plotNumber);
                NSLog(@"baseline = %@",pt.baseline);
                NSLog(@"strip = %@",pt.strip);
                NSLog(@"measuredPercent = %@",pt.surveyedMeasurePercent);
                NSLog(@"shapeCode = %@",pt.plotShapeCode.shapeCode);
                */
            
            
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
        /*
            UIFont *currentFont = cell.plotNumber.font;
            UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
            cell.plotNumber.font = newFont;
        */
            return cell;
        }/*else if(tableView == aggregatePileTableView){
            
            AggregatePileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AggregatePileTableCellID"];
            NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"aggregateId" ascending:YES];
            AggregateCutblock *aggcb = [[[[self.wasteStratum stratumAgg] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]] objectAtIndex:indexPath.row];
            cell.blockId.text = aggcb.aggregateCutblock ? [NSString stringWithFormat:@"%@", aggcb.aggregateCutblock] : @"";
            cell.cuttingPermit.text = aggcb.aggregateCuttingPermit ? [NSString stringWithFormat:@"%@", aggcb.aggregateCuttingPermit] : @"";
            cell.license.text = aggcb.aggregateLicense ? [NSString stringWithFormat:@"%@", aggcb.aggregateLicense] : @"";
            cell.totalPile.text = aggcb.totalNumPile ? [NSString stringWithFormat:@"%@", aggcb.totalNumPile] : @"";
            cell.measureSample.text = aggcb.measureSample ? [NSString stringWithFormat:@"%@", aggcb.measureSample] : @"";
            cell.viewOrConfirmButton.hidden = NO;
            cell.deleteButton.hidden = NO;
        
            return cell;
        }*/
        //aggregate block
        else
        {
            AggregatePlotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AggregatePlotTableCellID"];
            
            //NSLog(@" plots = %lu ", (unsigned long)[[self.wasteStratum stratumPlot] count]);
            //NSLog(@" sorted plots =  %d", [self.sortedPlots count]);
            //NSLog(@" row = %ld ",(long)indexPath.row);
            
            WastePlot *pt = ([self.sortedPlots count] == 1) ? [self.sortedPlots objectAtIndex:0] : [self.sortedPlots objectAtIndex:indexPath.row];
            
            
            /*
             NSLog(@"PLOT_ID %@ - FILL VIEW FROM OBJ", pt.plotID);
             NSLog(@"plotNum = %@",pt.plotNumber);
             NSLog(@"baseline = %@",pt.baseline);
             NSLog(@"strip = %@",pt.strip);
             NSLog(@"measuredPercent = %@",pt.surveyedMeasurePercent);
             NSLog(@"shapeCode = %@",pt.plotShapeCode.shapeCode);
             */
            
            
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
            /*
             UIFont *currentFont = cell.plotNumber.font;
             UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
             cell.plotNumber.font = newFont;
             */
            return cell;
        }
    } else {
       /* PlotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PileTableCellID"];
        
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
        
        cell.deleteButton.hidden = YES;
        
        return cell;*/
        AggregatePileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AggregatePileTableCellID"];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"aggregateCutblock" ascending:YES];
        self.sortedblocks = [[[self.wasteStratum stratumAgg] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        AggregateCutblock *aggcb  = ([self.wasteStratum.stratumAgg count] == 1) ? [self.sortedblocks objectAtIndex:0] : [self.sortedblocks objectAtIndex:indexPath.row];
        cell.blockId.text = aggcb.aggregateCutblock ? [NSString stringWithFormat:@"%@", aggcb.aggregateCutblock] : @"";
        cell.cuttingPermit.text = aggcb.aggregateCuttingPermit ? [NSString stringWithFormat:@"%@", aggcb.aggregateCuttingPermit] : @"";
        cell.license.text = aggcb.aggregateLicense ? [NSString stringWithFormat:@"%@", aggcb.aggregateLicense] : @"";
        cell.totalPile.text = aggcb.totalNumPile ? [NSString stringWithFormat:@"%@", aggcb.totalNumPile] : @"";
        cell.measureSample.text = aggcb.measureSample ? [NSString stringWithFormat:@"%@", aggcb.measureSample] : @"";
        
        // store the row number into the tag
        cell.deleteButton.tag = indexPath.row;
        
        cell.deleteButton.hidden = NO;
        return cell;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    //CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    //float h = size.height;

    /*
     NSLog(@"offset: %f", offset.y);
     NSLog(@"content.height: %f", size.height);
     NSLog(@"bounds.height: %f", bounds.size.height);
     NSLog(@"inset.top: %f", inset.top);
     NSLog(@"inset.bottom: %f", inset.bottom);
     NSLog(@"pos: %f of %f", y, h);

    
    NSLog(@"index %ld", (long)[[self.plotTableView indexPathForRowAtPoint: CGPointMake(10, y - 1)] row]);
    */
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


// SAME ROW SELECT APPLY
//
/*
- (void)stratumPickerRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.stratumTypePicker.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.stratumTypePicker.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        // apply the first row
        StratumTypeCode *stc = [self.stratumTypeArray objectAtIndex:[self.stratumTypePicker selectedRowInComponent:0]];
        self.stratumType.text = [[NSString alloc] initWithFormat:@"%@ - %@",stc.stratumTypeCode, stc.desc];
        [self.stratumType resignFirstResponder];
    }
    
    [self updateTitle];
    
}*/

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
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str appendString:string];
    NSString *theString = str;
    // FLOAT VALUE ONLY
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
    if( textField == self.grade12Percent || textField == self.grade4Percent || textField == self.grade5Percent || textField == self.gradeXPercent || textField == self.gradeYPercent){
        NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
        if ([string rangeOfCharacterFromSet:charSet].location != NSNotFound)
            return NO;
        else {
            NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            NSArray *arrSep = [newString componentsSeparatedByString:@"."];
            if([arrSep count] > 2)
                return NO;
            else {
                if([arrSep count] == 1) {
                    if([[arrSep objectAtIndex:0] length] > 3)
                        return NO;
                    else
                        return YES;
                }
                if([arrSep count] == 2) {
                    if([[arrSep objectAtIndex:0] length] > 3)
                        return NO;
                    else if([[arrSep objectAtIndex:1] length] > 1)  //Set after dot(.) how many digits you want.I set after dot I want 2 digits.If it goes more than 2 return NO
                        return NO;
                    else {
                        if([[arrSep objectAtIndex:0] length] >= 4) //Again I set the condition here.
                            return NO;
                        else
                            return YES;
                    }
                }
                return YES;
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
                [self.continueButton setEnabled:NO];
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
            if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.totalPile.text isEqualToString:@""] && ![self.measureSample.text isEqualToString:@""])){
                [self.continueButton setEnabled:YES];
            }
        }else if([wasteBlock.regionId integerValue] == CoastRegion){
            if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""] && ![self.totalPile.text isEqualToString:@""] && ![self.measureSample.text isEqualToString:@""])){
                [self.continueButton setEnabled:YES];
            }
        }
    }else if(textField == self.grade12Percent || textField == self.grade4Percent || textField == self.grade5Percent || self.gradeXPercent || self.gradeYPercent){
        if([wasteBlock.regionId integerValue] == InteriorRegion){
            if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
                if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.totalPile.text isEqualToString:@""] && ![self.measureSample.text isEqualToString:@""])){
                    [self.continueButton setEnabled:YES];
                }
            }else{
                if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""])){
                    [self.addCutblockButton setEnabled:YES];
                }
                else
                {
                    [self.addCutblockButton setEnabled:NO];
                }
            }
        }else if([wasteBlock.regionId integerValue] == CoastRegion){
            if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
                if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""] && ![self.totalPile.text isEqualToString:@""] && ![self.measureSample.text isEqualToString:@""])){
                    [self.continueButton setEnabled:YES];
                }
            }else{
                if((![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""])){
                    [self.addCutblockButton setEnabled:YES];
                }
                else
                {
                    [self.addCutblockButton setEnabled:NO];
                }
            }
        }
    }/*else if(textField == self.wasteType){
        if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue])
        {
            if(![textField.text isEqualToString:@""] && [wasteBlock.ratioSamplingEnabled intValue] == 1 && (!wasteStratum.n1sample || [wasteStratum.n1sample isEqualToString:@""])){
                if([[self codeFromText:self.wasteType.text] isEqualToString:@"S"] ||
                   [[self codeFromText:self.wasteType.text] isEqualToString:@"D"] ||
                   [[self codeFromText:self.wasteType.text] isEqualToString:@"G"]){
                    //set default value for measure plot and prediction plot
                    self.measurePlot.text = DEFAULT_DISPERSED_MEASURE_PLOT;
                    self.predictionPlot.text = DEFAULT_DISPERSED_PRED_PLOT;
                    
                }else if([[self codeFromText:self.wasteType.text] isEqualToString:@"P"] ||
                         [[self codeFromText:self.wasteType.text] isEqualToString:@"O"] ||
                         [[self codeFromText:self.wasteType.text] isEqualToString:@"L"] ||
                         [[self codeFromText:self.wasteType.text] isEqualToString:@"R"]){
                    self.measurePlot.text = DEFAULT_ACCU_MEASURE_PLOT;
                    self.predictionPlot.text = DEFAULT_ACCU_PRED_PLOT;
                }
            }
        }
        [self saveData];
    }*/
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
            return [[NSString alloc] initWithFormat:@"%@ - %@", [self.stratumTypeArray[row] valueForKey:@"StratumTypeCode"], [self.harvestMethodArray[row] valueForKey:@"desc"] ];
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

    switch (pickerView.tag) {
        case 1:
            //self.stratumType.text = [[NSString alloc] initWithFormat:@"%@ - %@", [self.stratumTypeArray[row] valueForKey:@"StratumTypeCode"], [self.harvestMethodArray[row] valueForKey:@"desc"] ];
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
            self.wasteType.text = [[NSString alloc] initWithFormat:@"%@ - %@", [self.wasteTypeArray[row] valueForKey:@"wasteTypeCode"], [self.wasteTypeArray[row] valueForKey:@"desc"]];
            [self updateTitle];
            [self.wasteType resignFirstResponder];
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
            [self.totalPile setHidden:YES];
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
            }else{
                self.plotTableView.hidden = FALSE;
                self.aggregatePlotTableView.hidden = TRUE;
                self.aggregatePileTableView.hidden = TRUE;
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
            

        }else if ([[self.assessmentSizeArray[row] valueForKey:@"PlotSizeCode"] isEqualToString:@"R"]){
            self.wasteStratum.isPileStratum = [NSNumber numberWithBool:YES];
            [self.totalPileLabel setHidden:NO];
            [self.totalPile setHidden:NO];
            [self.measureSampleLabel setHidden:NO];
            [self.measureSample setHidden:NO];
            [self.measureSample setEnabled:NO];
            [self.measureSample setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            [self.numPlotsLabel setHidden:YES];
            [self.numOfPlots setHidden:YES];
            [self.plotHeaderLabel setHidden:YES];
            [self.addCutblockButton setHidden:YES];
            if([wasteBlock.ratioSamplingEnabled integerValue] == 1){
                [self.predictionPlot setHidden:YES];
                [self.predictionPlotLabel setHidden:YES];
                [self.measurePlot setHidden:YES];
                [self.measurePlotLabel setHidden:YES];
                [self.addRatioPlotButton setHidden:YES];
            }
            [self.addPlotButton setHidden:YES];
            if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
            {
                [self.plotTableView setHidden:YES];
                [self.aggregatePlotTableView setHidden:YES];
                [self.aggregatePileTableView setHidden:NO];
                [self.plotHeaderLabel setHidden:NO];
                [self.plotHeaderLabel setText:@"CutBlocks"];
                [self.addCutblockButton setHidden:NO];
                [self.addCutblockButton setEnabled:NO];
                [self.totalPileLabel setHidden:YES];
                [self.totalPile setHidden:YES];
                [self.measureSampleLabel setHidden:YES];
                [self.measureSample setHidden:YES];
                [self.numPlotsLabel setHidden:YES];
                [self.numOfPlots setHidden:YES];
            }else{
                [self.plotTableView setHidden:YES];
                [self.aggregatePlotTableView setHidden:YES];
                [self.aggregatePileTableView setHidden:YES];
            }
            if([wasteBlock.regionId integerValue] == InteriorRegion){
                [self.grade12Label setHidden:NO];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:NO];
                [self.grade5Percent setHidden:NO];
                [self.gradeXLabel setHidden:YES];
                [self.gradeXPercent setHidden:YES];
                [self.gradeYLabel setHidden:YES];
                [self.gradeYPercent setHidden:YES];
                if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue])
                {
                    [self.continueButton setHidden:NO];
                    [self.continueButton setEnabled:NO];
                }
            }else if([wasteBlock.regionId integerValue] == CoastRegion){
                [self.grade12Label setHidden:NO];
                [self.grade12Label setText:@"Grade J%"];
                [self.grade12Percent setHidden:NO];
                [self.grade4Label setHidden:NO];
                [self.grade4Label setText:@"Grade W%"];
                [self.grade4Percent setHidden:NO];
                [self.grade5Label setHidden:NO];
                [self.grade5Label setText:@"Grade U%"];
                [self.grade5Percent setHidden:NO];
                [self.gradeXLabel setHidden:NO];
                [self.gradeXPercent setHidden:NO];
                [self.gradeYLabel setHidden:NO];
                [self.gradeYPercent setHidden:NO];
                if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue])
                {
                    [self.continueButton setHidden:NO];
                    [self.continueButton setEnabled:NO];
                    
                }
            }
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
                    [self.assesmentSize setEnabled:YES];
                    self.wasteStratum.isPileStratum = [NSNumber numberWithBool:NO];
                    [self.totalPileLabel setHidden:YES];
                    [self.totalPile setHidden:YES];
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
                    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
                    {
                       self.plotTableView.hidden = TRUE;
                       self.aggregatePlotTableView.hidden = FALSE;
                       self.aggregatePileTableView.hidden = TRUE;
                    }else{
                       self.plotTableView.hidden = FALSE;
                       self.aggregatePlotTableView.hidden = TRUE;
                       self.aggregatePileTableView.hidden = TRUE;
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
                    [self.plotTableView reloadData];
                    [self.aggregatePlotTableView reloadData];
                }];
                [userAlert addAction:yesBtn];
                [userAlert addAction:noBtn];
                [self presentViewController:userAlert animated:YES completion:nil];
            }
        }else{
            //[self.sizePicker setUserInteractionEnabled:YES];
            [self.assesmentSize setEnabled:YES];
            self.wasteStratum.isPileStratum = [NSNumber numberWithBool:NO];
            [self.totalPileLabel setHidden:YES];
            [self.totalPile setHidden:YES];
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
            }else{
                self.plotTableView.hidden = FALSE;
                self.aggregatePlotTableView.hidden = TRUE;
                self.aggregatePileTableView.hidden = TRUE;
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
    self.sortedPlots = [[[self.wasteStratum stratumPlot] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    // rebind tableview
    [self.plotTableView reloadData];
    [self.aggregatePlotTableView reloadData];
    
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



// SELECTED PLOT IN PLOT TABLE
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
                plotVC.wastePlot = plot;
                plotVC.wasteBlock = self.wasteBlock;
                break;
            }
        }
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
                plotVC.wastePlot = plot;
                plotVC.wasteBlock = self.wasteBlock;
                break;
            }
        }
    }else if (tableView == aggregatePileTableView){
        AggregatePileTableViewCell *cell = (AggregatePileTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        NSArray *aggregate = [self.wasteStratum.stratumAgg allObjects];
        for(AggregateCutblock* agg in aggregate){
            if( [agg.aggregateCutblock isEqualToString:cell.blockId.text] )
            {
                PileViewController *pileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PileViewControllerSID"];
                pileVC.wasteStratum = self.wasteStratum;
                pileVC.strpile = agg.aggPile;
                pileVC.aggregatecutblock = agg;
                pileVC.wasteBlock = self.wasteBlock;
                [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
                [WasteCalculator calculateRate:self.wasteBlock ];
                [WasteCalculator calculatePiecesValue:self.wasteBlock ];
                if([self.wasteBlock.userCreated intValue] ==1){
                    [WasteCalculator calculateEFWStat:self.wasteBlock];
                }

                [self saveData];
                
                [self.navigationController pushViewController:pileVC animated:YES];
            }
        }
        
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
        
        NSLog(@" stratumPlot count = %lu",(unsigned long)[[self.wasteStratum stratumPlot] count]);
        
        PlotViewController *plotVC = (PlotViewController *)[segue destinationViewController];
        plotVC.wastePlot = wp;
        plotVC.wasteBlock = self.wasteBlock;
        
        
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
    


    
    // NIL TESTING
    //
    /*
    self.wasteStratum.stratumStratumTypeCode = nil;
    self.wasteStratum.stratumHarvestMethodCode = nil;
    self.wasteStratum.stratumPlotSizeCode = nil;
    
    self.wasteStratum.stratumWasteLevelCode.wasteLevelCode = nil;
    self.wasteStratum.stratumWasteLevelCode = nil;
    self.wasteStratum.stratumArea = nil;
    
    self.wasteStratum.notes = nil;
     */
    //
    // END TESTING
    
    
    
    
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
        
        if([wasteBlock.ratioSamplingEnabled integerValue] == 1){
            [self.predictionPlot setHidden:NO];
            [self.predictionPlotLabel setHidden:NO];
            [self.measurePlot setHidden:NO];
            [self.measurePlotLabel setHidden:NO];
        }else{
            [self.predictionPlot setHidden:YES];
            [self.predictionPlotLabel setHidden:YES];
            [self.measurePlot setHidden:YES];
            [self.measurePlotLabel setHidden:YES];
        }
    }
    if ([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"R"]){
        self.wasteStratum.isPileStratum = [NSNumber numberWithBool:YES];
        [self.totalPileLabel setHidden:NO];
        [self.totalPile setHidden:NO];
        [self.measureSampleLabel setHidden:NO];
        [self.measureSample setHidden:NO];
        [self.numPlotsLabel setHidden:YES];
        [self.numOfPlots setHidden:YES];
        [self.plotHeaderLabel setHidden:YES];
        [self.addCutblockButton setHidden:YES];
        if([wasteBlock.ratioSamplingEnabled integerValue] == 1){
            [self.predictionPlot setHidden:YES];
            [self.predictionPlotLabel setHidden:YES];
            [self.measurePlot setHidden:YES];
            [self.measurePlotLabel setHidden:YES];
        }
        if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
        {
            [self.plotTableView setHidden:YES];
            [self.aggregatePlotTableView setHidden:YES];
            [self.aggregatePileTableView setHidden:NO];
            [self.plotHeaderLabel setHidden:NO];
            [self.plotHeaderLabel setText:@"CutBlocks"];
            [self.addCutblockButton setHidden:NO];
            [self.addCutblockButton setEnabled:NO];
            [self.totalPileLabel setHidden:YES];
            [self.totalPile setHidden:YES];
            [self.measureSampleLabel setHidden:YES];
            [self.measureSample setHidden:YES];
            [self.numPlotsLabel setHidden:YES];
            [self.numOfPlots setHidden:YES];
        }else{
            [self.plotTableView setHidden:YES];
            [self.aggregatePlotTableView setHidden:YES];
            [self.aggregatePileTableView setHidden:YES];
        }
        if([wasteBlock.regionId integerValue] == InteriorRegion){
            [self.grade12Label setHidden:NO];
            [self.grade12Percent setHidden:NO];
            [self.grade4Label setHidden:NO];
            [self.grade4Percent setHidden:NO];
            [self.grade5Label setHidden:NO];
            [self.grade5Percent setHidden:NO];
            [self.gradeXLabel setHidden:YES];
            [self.gradeXPercent setHidden:YES];
            [self.gradeYLabel setHidden:YES];
            [self.gradeYPercent setHidden:YES];
            self.grade12Percent.text = self.wasteStratum.grade12Percent && [self.wasteStratum.grade12Percent floatValue] >= 0.0 && [self.wasteStratum.grade12Percent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.grade12Percent floatValue]] : @"";
            self.grade4Percent.text = self.wasteStratum.grade4Percent && [self.wasteStratum.grade4Percent floatValue] >= 0.0 && [self.wasteStratum.grade4Percent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.grade4Percent floatValue]] : @"";
            self.grade5Percent.text = self.wasteStratum.grade5Percent && [self.wasteStratum.grade5Percent floatValue] >= 0.0 && [self.wasteStratum.grade5Percent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.grade5Percent floatValue]] : @"";
            if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue])
            {
                [self.continueButton setHidden:NO];
                [self.continueButton setEnabled:NO];
            }
        }else if([wasteBlock.regionId integerValue] == CoastRegion){
            [self.grade12Label setHidden:NO];
            [self.grade12Label setText:@"Grade J%"];
            [self.grade12Percent setHidden:NO];
            [self.grade4Label setHidden:NO];
            [self.grade4Label setText:@"Grade W%"];
            [self.grade4Percent setHidden:NO];
            [self.grade5Label setHidden:NO];
            [self.grade5Label setText:@"Grade U%"];
            [self.grade5Percent setHidden:NO];
            [self.gradeXLabel setHidden:NO];
            [self.gradeXPercent setHidden:NO];
            [self.gradeYLabel setHidden:NO];
            [self.gradeYPercent setHidden:NO];
            self.grade12Percent.text = self.wasteStratum.gradeJPercent && [self.wasteStratum.gradeJPercent floatValue] >= 0.0 && [self.wasteStratum.gradeJPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeJPercent floatValue]] : @"";
            self.grade4Percent.text = self.wasteStratum.gradeWPercent && [self.wasteStratum.gradeWPercent floatValue] >= 0.0 && [self.wasteStratum.gradeWPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeWPercent floatValue]] : @"";
            self.grade5Percent.text = self.wasteStratum.gradeUPercent && [self.wasteStratum.gradeUPercent floatValue] >= 0.0 && [self.wasteStratum.gradeUPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeUPercent floatValue]] : @"";
            self.gradeXPercent.text = self.wasteStratum.gradeXPercent && [self.wasteStratum.gradeXPercent floatValue] >= 0.0 && [self.wasteStratum.gradeXPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeXPercent floatValue]] : @"";
            self.gradeYPercent.text = self.wasteStratum.gradeYPercent && [self.wasteStratum.gradeYPercent floatValue] >= 0.0 && [self.wasteStratum.gradeYPercent floatValue] <= 100.0 ? [[NSString alloc] initWithFormat:@"%.1f", [self.wasteStratum.gradeYPercent floatValue]] : @"";
            if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue])
            {
                [self.continueButton setHidden:NO];
                [self.continueButton setEnabled:NO];
            }
        }
        
        self.totalPile.text =  self.wasteStratum.totalNumPile && [self.wasteStratum.totalNumPile intValue] > 0 ? [[NSString alloc] initWithFormat:@"%d", [self.wasteStratum.totalNumPile intValue]] : @"";
        
        self.measureSample.text = self.wasteStratum.measureSample && [self.wasteStratum.measureSample intValue] > 0 ? [[NSString alloc] initWithFormat:@"%d", [self.wasteStratum.measureSample intValue]] : @"";
        [self.measureSample setEnabled:NO];
        [self.measureSample setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        if([wasteBlock.regionId integerValue] == InteriorRegion){
            if([self.wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
                if(![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.totalPile.text isEqualToString:@""] && ![self.measureSample.text isEqualToString:@""]){
                    [self.continueButton setEnabled:YES];
                }
            }else{
                if(![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""]){
                    [self.addCutblockButton setEnabled:YES];
                }
            }
        }else if([wasteBlock.regionId integerValue] == CoastRegion){
            if([self.wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]){
                if(![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""] && ![self.totalPile.text isEqualToString:@""] && ![self.measureSample.text isEqualToString:@""]){
                    [self.continueButton setEnabled:YES];
                }
            }else{
                if(![self.grade12Percent.text isEqualToString:@""] && ![self.grade4Percent.text isEqualToString:@""] && ![self.grade5Percent.text isEqualToString:@""] && ![self.gradeXPercent.text isEqualToString:@""] && ![self.gradeYPercent.text isEqualToString:@""]){
                    [self.addCutblockButton setEnabled:YES];
                }
            }
        }
    }
    
    self.wasteLevel.text = self.wasteStratum.stratumWasteLevelCode.wasteLevelCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumWasteLevelCode.wasteLevelCode, self.wasteStratum.stratumWasteLevelCode.desc] : @"";
    self.wasteType.text = self.wasteStratum.stratumWasteTypeCode.wasteTypeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumWasteTypeCode.wasteTypeCode, self.wasteStratum.stratumWasteTypeCode.desc] : @"";
    
    
    self.numOfPlots.text = self.wasteStratum.stratumPlot ? [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[self.wasteStratum.stratumPlot count]] : @"";
    
    self.notes.text = self.wasteStratum.notes ? [[NSString alloc] initWithFormat:@"%@", self.wasteStratum.notes] : @"";
    

    self.predictionPlot.text = self.wasteStratum.predictionPlot ? [[NSString alloc] initWithFormat:@"%d", [self.wasteStratum.predictionPlot intValue]]: @"";
    self.measurePlot.text = self.wasteStratum.measurePlot ?[[NSString alloc] initWithFormat:@"%d", [self.wasteStratum.measurePlot intValue]]: @"";

    
    if(![self.predictionPlot.text isEqualToString:@""] && ![self.measurePlot.text isEqualToString:@""] && [wasteBlock.ratioSamplingEnabled integerValue] == 1 && ![self.wasteStratum.n1sample isEqualToString:@""]){
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
        //self.surveyAreaLabel.text = [NSString stringWithFormat:@"Survey Area: %.2f ha", [self.wasteStratum.stratumSurveyArea floatValue]];
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
    
    /*
    NSLog(@"STRATUM SCREEN - FILL VIEW FROM OBJ");
    NSLog(@"stratum = %@",self.wasteStratum.stratum);
    NSLog(@"typeCode = %@",self.wasteStratum.stratumStratumTypeCode.stratumTypeCode);
    NSLog(@"harvestCode = %@",self.wasteStratum.stratumHarvestMethodCode.harvestMethodCode);
    NSLog(@"plotSizeCode = %@",self.wasteStratum.stratumPlotSizeCode.plotSizeCode);
    NSLog(@"wasteLevelCode = %@",self.wasteStratum.stratumWasteLevelCode.wasteLevelCode);
    NSLog(@"stratumArea = %@",self.wasteStratum.stratumArea);
    NSLog(@"plotCount = %d",[self.wasteStratum.stratumPlot count]);
    NSLog(@"notes = %@",self.wasteStratum.notes);
    */
    
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
        
        // change the assessment size text to R
        /*[self.assesmentSize setText:@"R"];
        if ([self.wasteStratum.stratum isEqualToString:@"STRE"]){
            [self.wasteLevel setText:@"E"];
        }else if([self.wasteStratum.stratum isEqualToString:@"STRS"]){
            [self.wasteLevel setText:@"S"];
        }*/
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
            /*
            if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Green Volume", nil)]){
                gv = [[NSDecimalNumber alloc] initWithString:tf.text];
                gv_str =tf.text;
            }
            if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Dry Volume", nil)]){
                dv = [[NSDecimalNumber alloc] initWithString:tf.text];
                dv_str = tf.text;
            }
            if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Plot Number", nil)]){
                pn = [[NSDecimalNumber alloc] initWithString:tf.text];
                pn_str = tf.text;
            }*/
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
    
    BOOL isMeasurePlot = NO;
    NSArray* pn_ary = nil;

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
    
    wasteStratum.ratioSamplingLog = [wasteStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:wp stratum:wasteStratum actionDec:@"New Plot Added"]];
    wasteBlock.ratioSamplingLog = [wasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:wp stratum:wasteStratum actionDec:@"New Plot Added"]];
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
-(void) deleteAggregateCB:(AggregateCutblock *)targetblock targetAggregateCB:(WasteStratum *)targetWasteStratum{
    
    if([targetWasteStratum.stratumBlock.ratioSamplingEnabled integerValue]== 1){
        wasteStratum.ratioSamplingLog = [wasteStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog2:targetblock stratum:targetWasteStratum actionDec:@"Delete Pile"]];
        wasteBlock.ratioSamplingLog = [wasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog2:targetblock stratum:targetWasteStratum actionDec:@"Delete Pile"]];
    }
        
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for( NSManagedObject *wpi in targetblock.aggPile.pileData ){
        [context deleteObject:wpi];
    }

    [context deleteObject:targetblock.aggPile];
    NSMutableSet *tempPlot = [NSMutableSet setWithSet:targetWasteStratum.stratumAgg];
    [tempPlot removeObject:targetblock];
    targetWasteStratum.stratumAgg = tempPlot;
    
    [context deleteObject:targetblock];
    
    NSError *error;
    [context save:&error];
    //NSLog(@"remaining blocks %@", targetWasteStratum.stratumAgg);
    if (error){
        NSLog(@"Error when deleting aggregate cutblock and save :%@", error);
    }
}

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
        if([self.totalPile isEnabled]){
        UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Values", nil)
                                                                              message:[NSString stringWithFormat:@"\n Total # Pile = %d \n Measure Samples= %d \n ",[self.totalPile.text intValue], [self.measureSample.text intValue]]
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self.assesmentSize setEnabled:NO];
                                                              [self.totalPile setEnabled:NO];
                                                              //single block SRS
                                                              if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
                                                                  [self singleBlockSRSPileData:[self.totalPile.text intValue] measureSamples:[self.measureSample.text intValue]];
                                                              }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){//single block ratio
                                                                  [self singleBlockRatioPileData:[self.totalPile.text intValue] measureSamples:[self.measureSample.text intValue]];
                                                              }
                                                              [self addPileAndNavigate:[self.totalPile.text intValue] measureSamples:[self.measureSample.text intValue]];
                                                          }];
        
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
        [confirmAlert addAction:yesAction];
        [confirmAlert addAction:noAction];
        [self presentViewController:confirmAlert animated:YES completion:nil];
        }else{
            [self addPileAndNavigate:[self.totalPile.text intValue] measureSamples:[self.measureSample.text intValue]];
        }
    }
}

-(void)addPileAndNavigate:(int)totalPile measureSamples:(int)measureSample {
    
    [self saveData];
    
    PileViewController *pileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PileViewControllerSID"];
    pileVC.wasteStratum = self.wasteStratum;
    pileVC.strpile = self.wasteStratum.strPile;
    pileVC.wasteBlock = self.wasteBlock;
    [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
    [WasteCalculator calculateRate:self.wasteBlock ];
    [WasteCalculator calculatePiecesValue:self.wasteBlock ];
    if([self.wasteBlock.userCreated intValue] ==1){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
    }

    [self saveData];
    
    [self.navigationController pushViewController:pileVC animated:YES];
    
}

-(void)singleBlockSRSPileData:(int)totalPile measureSamples:(int)measureSample{
    
    [PlotSampleGenerator generatePlotSample2:self.wasteStratum];
    //NSLog(@"total pile %@, measure samp %@, n1sample %@,n2sample %@", self.wasteStratum.totalNumPile,self.wasteStratum.measureSample, self.wasteStratum.n1sample, self.wasteStratum.n2sample);
    NSManagedObjectContext *context = [self managedObjectContext];
    int i = 0;
    StratumPile *pile = [NSEntityDescription insertNewObjectForEntityForName:@"StratumPile" inManagedObjectContext:context];
    pile.stratumPileId = [self.wasteStratum.stratumID stringValue];
    
    self.wasteStratum.strPile = pile;
    
    //NSLog(@"stratumpileid %@", self.wasteStratum.strPile);
    if([wasteBlock.regionId integerValue] == CoastRegion){
        pile.pileCoastStat = [WasteBlockDAO createEFWCoastStat];
    }else if([wasteBlock.regionId integerValue] == InteriorRegion){
        pile.pileInteriorStat = [WasteBlockDAO createEFWInteriorStat];
    }
    NSArray* numberOfRows = [self.wasteStratum.n1sample componentsSeparatedByString:@","];
    NSMutableArray* rownumber = [numberOfRows mutableCopy];
    
    for(int j = 0; j < [numberOfRows count]; j++){
        WastePile *newWp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePile" inManagedObjectContext:context];
        
        newWp.pileNumber = [rownumber objectAtIndex:0];
        newWp.pileId = [NSNumber numberWithInt:[newWp.pileNumber intValue]];
        newWp.measuredLength = nil;
        newWp.measuredWidth = nil;
        newWp.measuredHeight = nil;
        newWp.isSample = [[NSNumber alloc] initWithBool:YES];
        [rownumber removeObjectAtIndex:0];
        i++;
        [self.wasteStratum.strPile addPileDataObject:newWp];
    }
    
}

-(void)singleBlockRatioPileData:(int)totalPile measureSamples:(int)measureSample{
    
    [PlotSampleGenerator generatePlotSample2:self.wasteStratum];
    //NSLog(@"total pile %@, measure samp %@, n1sample %@,n2sample %@", self.wasteStratum.totalNumPile,self.wasteStratum.measureSample, self.wasteStratum.n1sample, self.wasteStratum.n2sample);
    
    NSManagedObjectContext *context = [self managedObjectContext];

    StratumPile *pile = [NSEntityDescription insertNewObjectForEntityForName:@"StratumPile" inManagedObjectContext:context];
    pile.stratumPileId = [self.wasteStratum.stratumID stringValue];
    self.wasteStratum.strPile = pile;
    wasteStratum.ratioSamplingLog = [wasteStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:wasteStratum actionDec:@"New Pile Added"]];
    wasteBlock.ratioSamplingLog = [wasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:wasteStratum actionDec:@"New Pile Added"]];
    if([wasteBlock.regionId integerValue] == CoastRegion){
        pile.pileCoastStat = [WasteBlockDAO createEFWCoastStat];
    }else if([wasteBlock.regionId integerValue] == InteriorRegion){
        pile.pileInteriorStat = [WasteBlockDAO createEFWInteriorStat];
    }
    
}
- (IBAction)addCutblock:(id)sender {
    [self saveData];
    WastePlotValidator *wpv = [[WastePlotValidator alloc] init];
    NSString *errorMessage = [wpv validateStratum:wasteStratum];
    
    if (![errorMessage isEqualToString:@""]){
        UIAlertView *validateAlert = nil;
        validateAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        validateAlert.tag = ValidEnum;
        [validateAlert show];
    }else{
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Aggregate Cutblock Details"
                                                                       message:@"Please enter:\n- Block\n- CP \n- License \n- Total # Pile"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder        = NSLocalizedString(@"Block", nil);
            textField.accessibilityLabel = NSLocalizedString(@"Block", nil);
            textField.clearButtonMode    = UITextFieldViewModeAlways;
            textField.keyboardType       = UIKeyboardTypeAlphabet;
            textField.tag                = 3;
            textField.delegate           = self;
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder        = NSLocalizedString(@"CP", nil);
            textField.accessibilityLabel = NSLocalizedString(@"CP", nil);
            textField.clearButtonMode    = UITextFieldViewModeAlways;
            textField.keyboardType       = UIKeyboardTypeAlphabet;
            textField.tag                = 3;
            textField.delegate           = self;
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder        = NSLocalizedString(@"License", nil);
            textField.accessibilityLabel = NSLocalizedString(@"License", nil);
            textField.clearButtonMode    = UITextFieldViewModeAlways;
            textField.keyboardType       = UIKeyboardTypeAlphabet;
            textField.tag                = 3;
            textField.delegate           = self;
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder        = NSLocalizedString(@"Total # Pile", nil);
            textField.accessibilityLabel = NSLocalizedString(@"Total # Pile", nil);
            textField.clearButtonMode    = UITextFieldViewModeAlways;
            textField.keyboardType       = UIKeyboardTypeNumberPad;
            textField.tag                = 9;
            textField.delegate           = self;
        }];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                           [self validateEstimate:alert];
                                                           [self presentViewController:alert animated:YES completion:nil];
                                                         }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (BOOL)validateEstimate:(UIAlertController*)alert{
    NSString* block = nil;
    NSString* cp = nil;
    NSString* license = nil;
    NSNumber* totalpile = nil;
    NSString* block_str = @"";
    NSString* cp_str = @"";
    NSString* license_str = @"";
    NSString* totalpile_str = @"";
    
    for(UITextField* tf in alert.textFields){
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Block", nil)]){
            block = tf.text;
            block_str =tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"CP", nil)]){
            cp = tf.text;
            cp_str = tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"License", nil)]){
            license = tf.text;
            license_str = tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Total # Pile", nil)]){
            totalpile = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%d",[tf.text intValue]]];
            totalpile_str = tf.text;
        }
    }
    BOOL duplicateCutblock = NO;
    if (block){
        for(AggregateCutblock* ac in self.wasteStratum.stratumAgg){
            if( [ac.aggregateCutblock caseInsensitiveCompare:block] == NSOrderedSame&& [ac.aggregateCuttingPermit caseInsensitiveCompare:cp] == NSOrderedSame && [ac.aggregateLicense caseInsensitiveCompare:license] == NSOrderedSame){
                duplicateCutblock = YES;
                break;
            }
        }
    }
    
    if([block_str isEqualToString:@""] || [license_str isEqualToString:@""] || [totalpile_str isEqualToString:@""] /*|| [measuresample_str isEqualToString:@""]*/){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                              message:@"Please enter Cutblock, License, Total # Pile."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self presentViewController:alert animated:YES completion:nil];
                                                         }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }else if(duplicateCutblock){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Duplicate Cutblock", nil)
                                                                              message:@"Duplicate Cutblock."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self presentViewController:alert animated:YES completion:nil];
                                                         }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }else{
            if([totalpile integerValue] < 1 || [totalpile integerValue] > 9999) {
                UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                      message:@"Total Pile should be from 1 to 9999"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [self presentViewController:alert animated:YES completion:nil];
                                                                 }];
                [warningAlert addAction:okAction];
                [self presentViewController:warningAlert animated:YES completion:nil];
            }
        NSInteger measuresample = 0;
        if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
            if([totalpile integerValue] <= 10){
                measuresample = [totalpile integerValue];
            }else if([totalpile integerValue] > 10){
                     int totpile = [totalpile intValue] ;
                     int excess = totpile - 10;
                     int value = excess/5;
                     int measure = 10 + value;
                     measuresample = measure;
            }
         if(measuresample > 30){
            measuresample = 30;
         }
        }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
            if([totalpile integerValue] < 10){
                measuresample = [totalpile integerValue];
            }else{
                measuresample = 10;
            }
        }
        UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Estimation", nil)
                                                                              message:[NSString stringWithFormat:@"Accept value? \n Cutblock = %@ \n CP = %@ \n Total # Pile = %ld \n Measure Samples = %ld", block, cp, (long)[totalpile integerValue], (long)measuresample]
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
            /*NSInteger measuresample = 0;
            if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
                if([totalpile integerValue] <= 10){
                    measuresample = [totalpile integerValue];
                }else if([totalpile integerValue] > 10){
                         int totpile = (int)totalpile ;
                         int excess = totpile - 10;
                         int value = excess/5;
                         int measure = 10 + value;
                         measuresample = measure;
                }
             if(measuresample > 30){
                measuresample = 30;
             }
            }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
                if([totalpile integerValue] < 10){
                    measuresample = [totalpile integerValue];
                }else{
                    measuresample = 10;
                }
            }*/
            self.currentAggCutblock = [self addAggregateCutblock:self.wasteStratum cutblock:block cp:cp license:license totalpile:[totalpile integerValue] measuresample:measuresample ];
            [self.assesmentSize setEnabled:NO];
            if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
                  [self aggregateSRSPileData:[totalpile intValue] measureSamples:(int)measuresample];
            }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
                [PlotSampleGenerator generatePlotSample3:self.currentAggCutblock];
                 //NSLog(@"total pile %@, measure samp %@, n1sample %@,n2sample %@", self.currentAggCutblock.totalNumPile,self.currentAggCutblock.measureSample, self.currentAggCutblock.n1sample, self.currentAggCutblock.n2sample);
                 
                 NSManagedObjectContext *context = [self managedObjectContext];

                 StratumPile *pile = [NSEntityDescription insertNewObjectForEntityForName:@"StratumPile" inManagedObjectContext:context];
                 pile.stratumPileId = [self.wasteStratum.stratumID stringValue];
                 self.currentAggCutblock.aggPile = pile;
                self.wasteStratum.ratioSamplingLog = [self.wasteStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog2:self.currentAggCutblock stratum:self.wasteStratum actionDec:@"New Pile Added"]];
                self.wasteBlock.ratioSamplingLog = [self.wasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog2:self.currentAggCutblock stratum:self.wasteStratum actionDec:@"New Pile Added"]];
                if([self.wasteBlock.regionId integerValue] == CoastRegion){
                    pile.pileCoastStat = [WasteBlockDAO createEFWCoastStat];
                }else if([self.wasteBlock.regionId integerValue] == InteriorRegion){
                    pile.pileInteriorStat = [WasteBlockDAO createEFWInteriorStat];
                }
            }
            NSSortDescriptor *sort1 = [[NSSortDescriptor alloc ] initWithKey:@"aggregateCutblock" ascending:YES];
            self.sortedblocks = [[[self.wasteStratum stratumAgg] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort1]];
            [self.aggregatePileTableView reloadData];
            NSIndexPath* ipath = [NSIndexPath indexPathForRow:[self.wasteStratum.stratumAgg count] - 1 inSection:0];
            [self.aggregatePileTableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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


-(AggregateCutblock *) addAggregateCutblock:(WasteStratum *)targetWasteStratum cutblock:(NSString *)cutblock cp:(NSString*)cp license:(NSString*)license totalpile:(NSInteger)totalpile measuresample:(NSInteger)measuresample{

    NSManagedObjectContext *context = [self managedObjectContext];
       
    AggregateCutblock *newAggCutblock = [NSEntityDescription insertNewObjectForEntityForName:@"AggregateCutblock" inManagedObjectContext:context];
    
    int i = 0;
    NSArray *aggregate = [self.wasteStratum.stratumAgg allObjects];
    for(AggregateCutblock *aggcb in aggregate){
        if( [aggcb.aggregateID integerValue] > i){
            i = [aggcb.aggregateID intValue];
        }
    }
    
    newAggCutblock.aggregateID = [NSNumber numberWithInt:(i+1)];
    newAggCutblock.aggregateCutblock = cutblock;
    newAggCutblock.aggregateCuttingPermit = cp ? [NSString stringWithFormat:@"%@", cp] : @"";
    newAggCutblock.aggregateLicense = license;
    newAggCutblock.totalNumPile = [[NSNumber alloc] initWithInteger:totalpile];
    newAggCutblock.measureSample = [[NSNumber alloc] initWithInteger:measuresample];
       
    [self.wasteStratum addStratumAggObject:newAggCutblock];
    return newAggCutblock;
}

-(void)aggregateSRSPileData:(int)totalPile measureSamples:(int)measureSample{
    
    [PlotSampleGenerator generatePlotSample3:self.currentAggCutblock];
    //NSLog(@"total pile %@, measure samp %@, n1sample %@,n2sample %@", self.currentAggCutblock.totalNumPile,self.currentAggCutblock.measureSample, self.currentAggCutblock.n1sample, self.currentAggCutblock.n2sample);
    NSManagedObjectContext *context = [self managedObjectContext];
    int i = 0;
    StratumPile *pile = [NSEntityDescription insertNewObjectForEntityForName:@"StratumPile" inManagedObjectContext:context];
    pile.stratumPileId = [[self.wasteStratum.stratumID stringValue] stringByAppendingFormat:@"CB%@", self.currentAggCutblock.aggregateCutblock];
    
    self.currentAggCutblock.aggPile = pile;
    if([wasteBlock.regionId integerValue] == CoastRegion){
        pile.pileCoastStat = [WasteBlockDAO createEFWCoastStat];
    }else if([wasteBlock.regionId integerValue] == InteriorRegion){
        pile.pileInteriorStat = [WasteBlockDAO createEFWInteriorStat];
    }
    //NSLog(@"stratumpileid %@", self.currentAggCutblock.aggPile);
    NSArray* numberOfRows = [self.currentAggCutblock.n1sample componentsSeparatedByString:@","];
    NSMutableArray* rownumber = [numberOfRows mutableCopy];
    
    for(int j = 0; j < [numberOfRows count]; j++){
        WastePile *newWp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePile" inManagedObjectContext:context];
        
        newWp.pileNumber = [rownumber objectAtIndex:0];
        newWp.pileId = [NSNumber numberWithInt:[newWp.pileNumber intValue]];
        newWp.measuredLength = nil;
        newWp.measuredWidth = nil;
        newWp.measuredHeight = nil;
        newWp.isSample = [[NSNumber alloc] initWithBool:YES];
        [rownumber removeObjectAtIndex:0];
        i++;
        [self.currentAggCutblock.aggPile addPileDataObject:newWp];
    }

}

- (IBAction)deletePile:(id)sender {
    
    NSString *title = NSLocalizedString(@"Delete Aggregate Cutblock", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Delete", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, nil];
    alert.tag = ((UIButton *)sender).tag;
    NSLog(@"Passing the tag from button to the alert view, %ld to %ld",(long)((UIButton *)sender).tag, (long)alert.tag );
    [alert show];
}

@end
