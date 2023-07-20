//
//  StratumViewController.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "StratumViewController.h"
#import "PlotTableViewCell.h"
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

#import "ShapeCode.h"
#import "ReportGeneratorTableViewController.h"
#import "Timer.h"
#import "PlotSampleGenerator.h"
#import "PlotSelectorLog.h"
#import "Constants.h"
#import "WasteBlockDAO.h"

@class UIAlertView;

@interface StratumViewController ()

@end

@implementation StratumViewController


@synthesize versionLabel, downArrowImage;

@synthesize wasteBlock, wasteStratum, plotTableView;

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
    
    // POPULATE FROM OBJECT TO VIEW
    [self populateFromObject];
    
    
    // Populate version number
    [versionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteVersionNumber"]];
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
    
    
    // UPDATE VIEW
    [self.plotTableView reloadData];
    
    
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
    
    [self saveData];
    
}


// SAVE FROM VIEW TO OBJECT
- (void)saveData{
    
    NSLog(@"SAVE STRATUM");
    
    self.wasteStratum.stratum = [self.navigationItem.title substringWithRange:NSMakeRange(21, self.navigationItem.title.length-21)];
    
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
           [[self codeFromText:self.assesmentSize.text] isEqualToString:@"O"]){
            self.wasteStratum.stratumAssessmentMethodCode = (AssessmentMethodCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"assessmentMethodCode" code:[self codeFromText:self.assesmentSize.text]];
        }else if ([self.assesmentSize.text isEqualToString:@"R"]){
            // skip if this is a standing tree
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
    
    
    NSError *error;
    
    // save the whole cut block
    NSManagedObjectContext *context = [self managedObjectContext];
    [context save:&error];
    
    if( error != nil){
        NSLog(@" Error when saving waste block into Core Data: %@", error);
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
    //NSLog(@"Passing the tag from button to the alert view, %ld to %ld",(long)((UIButton *)sender).tag, (long)alert.tag );
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
            // check if the user enter value against the default value
            if(( ![def_mp isEqualToString:@""] && ![self.measurePlot.text isEqualToString:def_mp]) || (![def_pp isEqualToString:@""] && ![self.predictionPlot.text isEqualToString:def_pp])){
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
            }else{
                //generate sample
                [PlotSampleGenerator generatePlotSample2:self.wasteStratum];
                //lock down the prediction plot and measure plot fields
                [self.predictionPlot setEnabled:NO];
                [self.predictionPlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
                [self.measurePlot setEnabled:NO];
                [self.measurePlot setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            }
        }
    }

    if (isValid){
        [self promptForGreenDryVolume];
    }
}

-(void)promptForGreenDryVolume{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ratio Sampling Stratum"
                                                                   message:@"Please enter your estimate for:\n- Green Volume\n- Dry Volume"
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
        textField.placeholder        = NSLocalizedString(@"Green Volume", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Green Volume", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 3;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Dry Volume", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Dry Volume", nil);
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

// TABLE VIEW POPULATION
//
#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) {
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
            
            //NSLog(@"Delete new plot at row %ld.", (long)alertView.tag);
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
        return [[self.wasteStratum stratumPlot] count];
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
    
    if ([pt.plotID integerValue] == 0 && [self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
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
       || [textField.accessibilityLabel isEqualToString:NSLocalizedString(@"Dry Volume", nil)] )
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
            
        case 4: // no char max limit
            return YES;
            break;

        case 5:
            return (newLength > 2) ? NO : YES;
            break;
            
        case 6:
            return (newLength > 2) ? NO : YES;
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
    }else if(textField == self.wasteType){
        
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
        [self saveData];
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
                UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"By changing the assessment method code, all existing plot data in this stratum will be removed. proceed?" preferredStyle:UIAlertControllerStyleAlert];
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
            

        }else{
            //[self.sizePicker setUserInteractionEnabled:YES];
            [self.assesmentSize setEnabled:YES];
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
    
    // refresh sorted plot list
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES];
    self.sortedPlots = [[[self.wasteStratum stratumPlot] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    // rebind tableview
    [self.plotTableView reloadData];
    
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
        [self.wasteLevel setEnabled:NO];
        [self.wasteType setEnabled:NO];
        
        // change the assessment size text to R
        [self.assesmentSize setText:@"R"];
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
    
    if([self.wasteStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
        if ([self.wasteBlock.ratioSamplingEnabled integerValue] ==1){
            [self.addRatioPlotButton setHidden:NO];
        }else{
            [self.addPlotButton setHidden:NO];
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

    for(UITextField* tf in alert.textFields){
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
    
    if([pn_str isEqualToString:@""] || [gv_str isEqualToString:@""] || [dv_str isEqualToString:@""]){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                              message:@"Please enter Plot Number, Green Volume and Dry Volume."
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
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Plot Number Invalid", nil)
                                                                              message:[NSString stringWithFormat:@"Plot number exceeds acceptable range. Please select number between 1 and Prediction Plot (%ld).", [wasteStratum.predictionPlot integerValue]]
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self presentViewController:alert animated:YES completion:nil];
                                                         }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }else{
        UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Estimation", nil)
                                                                              message:[NSString stringWithFormat:@"Accept volume esimates? \n Plot Number %d \n Green Volume = %.2f \n Dry Volume = %.2f",[pn intValue], [gv floatValue], [dv floatValue]]
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
}

-(void)addRatioPlotAndNavigate:(NSDecimalNumber*)greenVolume dryVolume:(NSDecimalNumber*)dryVolume plotNumber:(NSNumber*)pn{
    
    WastePlot* wp = [self addEmptyPlot];
    wp.dryVolume = dryVolume;
    wp.greenVolume = greenVolume;
    wp.plotNumber = pn;
    
    BOOL isMeasurePlot = NO;
    NSArray* pn_ary = [self.wasteStratum.n1sample componentsSeparatedByString:@","];
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
    
    wasteStratum.ratioSamplingLog = [wasteStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:wp actionDec:@"New Plot Added"]];
    
    //update the benchmak and calculate the numbers again
    [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
    [WasteCalculator calculateRate:self.wasteBlock ];
    [WasteCalculator calculatePiecesValue:self.wasteBlock ];
    if([self.wasteBlock.userCreated intValue] ==1){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
    }

    [self saveData];

    [self.navigationController pushViewController:plotVC animated:YES];
}

-(NSString*)getDefaultPredictionPlot:(NSString*)wasteTypeCode{
    NSString* result = @"";

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
    return result;
}

-(NSString*)getDefaultMeasurePlot:(NSString*)wasteTypeCode{
    NSString* result = @"";
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
        wasteStratum.ratioSamplingLog = [wasteStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:targetWastePlot actionDec:@"Delete Plot"]];
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

@end
