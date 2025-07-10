//
//  PlotViewController.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

// test
#import "BlockViewController.h"

#import "PlotViewController.h"
#import "WastePlot.h"
#import "WasteBlock.h"
#import "WastePiece.h"
#import "WasteStratum.h"
#import "CheckerStatusCode.h"
#import "PieceTableViewCell.h"
#import "PieceEditTableViewCell.h"
#import "ScaleSpeciesCode.h"
#import "PlotSizeCode.h"
#import "ShapeCode.h"
#import "CodeDAO.h"
#import "ShapeCode.h"
#import "ReportGeneratorTableViewController.h"
#import "Timer.h"
#import "WasteCalculator.h"
#import "WastePlotValidator.h"
#import "AssessmentMethodCode.h"

#import "MaterialKindCode.h"
#import "BorderlineCode.h"
#import "ScaleSpeciesCode.h"
#import "ScaleGradeCode.h"
#import "WasteClassCode.h"
#import "TopEndCode.h"
#import "ButtEndCode.h"
#import "StratumTypeCode.h"
#import "MaturityCode.h"
#import "UIColor+WasteColor.h"
#import "PlotSelectorLog.h"
#import "PieceValueTableViewController.h"
#import "Constants.h"
#import "DataEndorsementViewController.h"
#import "WastePlot.h"

@class UIAlertView;

@interface PlotViewController ()

@end

@implementation PlotViewController

@synthesize wasteBlock, wastePlot;
@synthesize wastePieces;
@synthesize plotSizeArray;
@synthesize plotShapeArray;
@synthesize versionLabel;

// Grab the managedObjectContext from AppDelegate
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
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"plotSizeCode" ascending:YES];
    self.plotSizeArray = [[[CodeDAO sharedInstance] getPlotSizeCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    sort = [[NSSortDescriptor alloc ] initWithKey:@"shapeCode" ascending:YES];
    self.plotShapeArray = [[[CodeDAO sharedInstance] getShapeCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    if(![[f numberFromString:self.measurePct.text] isEqualToNumber:self.originalMP])
    {
        if((self.wastePlot.measurePctEdited != nil && [self.wastePlot.measurePctEdited intValue] == 1) && ![self.fromBackButton isEqualToNumber:@1])
        {
            DataEndorsementViewController *devc = [self.storyboard instantiateViewControllerWithIdentifier:@"dataEndorsementViewController"];
            devc.wasteStratum = self.wastePlot.plotStratum;
            devc.plotVC = self;
            devc.endorsementType = @"Edit Plot";
            devc.plotNumber = self.wastePlot.plotNumber;
            devc.wastePlot = self.wastePlot;
            self.wastePlot.measurePctEdited = [NSNumber numberWithInt:1];
            [self.navigationController pushViewController:devc animated:YES];
        }
        else if ([self.fromBackButton isEqualToNumber:@1]) //don't reset if coming from back button -- fromBackButton is hacky but I'm in a hurry
        {
            self.fromBackButton = @0;
        }
        else
        {
            self.originalMP = [f numberFromString:self.measurePct.text];
            self.wastePlot.measurePctEdited = @1;
        }
    }
}

- (void)viewDidLoad
{
    //set up UIScrollView
    [scrollView setScrollEnabled:YES];
    [scrollView setPagingEnabled:YES];
    [scrollView setContentSize:CGSizeMake(1024, 1100)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fromBackButton = @0;
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self setupLists];
    
    // Set the plot header display mode according to waste stratum assessment method
    self.headerView.displayMode = self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode;

    
    // DATE PICKER
    //
    self.datePicker = [[UIDatePicker alloc] init];
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    } else {
        // Fallback on earlier versions
    }
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.backgroundColor = [UIColor whiteColor];

    self.surveyDate.inputView = self.datePicker;
    self.surveyDate.tag = 6;
    [self.surveyDate setDelegate:self];
    self.checkSurveyDate.inputView = self.datePicker;
    [self.checkSurveyDate setDelegate:self];
    self.checkSurveyDate.tag = 6;
    
    
    // SIZE PICKER - field locked, if field unlocked, this works (without the support for same row select)
    //
    UIPickerView *sizePicker = [[UIPickerView alloc] init];
    sizePicker.dataSource = self;
    sizePicker.delegate = self;
    sizePicker.tag = 1;
    self.size.inputView = sizePicker;
    
    
    // SHAPE PICKER
    //
    self.shapePicker = [[UIPickerView alloc] init];
    self.shapePicker.dataSource = self;
    self.shapePicker.delegate = self;
    self.shapePicker.tag = 2;
    self.shape.inputView = self.shapePicker;
    
    UITapGestureRecognizer *gr3 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(shapeRecognizer:)];
    [self.shapePicker addGestureRecognizer:gr3];
    gr3.delegate = self;
    
    
    // KEYBOARD DISMISSAL
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tap];
    
    // Other textfield
    [self.plotNumber setDelegate:self];
    [self.measurePct setDelegate:self];
    [self.plotEstimatedVolume setDelegate:self];
    // Hide all ratio sampling fields first
    [self.greenVolumeLabel setHidden:YES];
    [self.dryVolumeLabel setHidden:YES];
    [self.greenVolume setHidden:YES];
    [self.dryVolume setHidden:YES];
    [self.isMeasurePlot setHidden:YES];
    [self.isMeasurePlotLabel setHidden:YES];
    [self.plotEstimatedVolume setHidden:YES];
    [self.plotEstimatedVolumeLabel setHidden:YES];
    [self.totalCheckPercentLabel setHidden:YES];
    [self.totalCheckPercent setHidden:YES];
    [self.totalEstimatedVolumeLabel setHidden:YES];
    [self.totalEstimateVolume setHidden:YES];
    [self.checkVolumeLabel setHidden:YES];
    [self.checkVolume setHidden:YES];
    [self.checkVolume setEnabled:YES];
    
    
    [self.measurePct addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];

    // POPULATING
    //
    [self populateFromObject];
    
    if ([self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"] && [self.wastePlot.checkVolume isEqualToNumber:self.wastePlot.plotEstimatedVolume]) {
        NSDecimalNumberHandler *behaviorD3 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        for (WastePiece *wpiece in [self.wastePlot.plotPiece allObjects]) {
            wpiece.checkPieceVolume =  [wpiece.pieceVolume decimalNumberByRoundingAccordingToBehavior:behaviorD3];
        }
    }
    
    if ([self.wasteBlock.userCreated intValue] == 1){
        // toggle some UI for user created cut block
        
        self.headerView.userCreatedBlock = @"YES";
        
        [self.measurePct setEnabled:YES];
        self.strip.enabled = YES;
        self.baseline.enabled = YES;
        self.certificationNumber.enabled = YES;
        self.returnNumber.enabled = YES;
        
        [self.checkSurveyDate setHidden:YES];
        [self.checkSurveyDateLabel setHidden:YES];
        [self.checkMeasureLabel setHidden:YES];
        [self.checkMeasurePerc setHidden:YES];
        [self.checkByLabel setHidden:YES];
        [self.checkedBy setHidden:YES];
        
        [self.surveyDate setEnabled:YES];
        [self.measurePct setEnabled:YES];

    }else{
        
        if ([self.wastePlot.plotID intValue] ==0 ){
            //if plot is not pulling from the database, we enable more field
            self.strip.enabled = YES;
            self.baseline.enabled = YES;
            self.certificationNumber.enabled = YES;
        }else{
            [self.strip setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            [self.baseline setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            [self.certificationNumber setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            [self.returnNumber setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        }
        
        self.returnNumber.enabled = YES;
        [self.measurePct setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.surveyDate setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.plotNumber setEnabled:NO];
        [self.plotNumber setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    }
    
    if(![self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"P"]){
        //disable plot number for non-standard stratum plot
        //[self.plotNumber setEnabled:NO];
        //[self.plotNumber setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.checkMeasurePerc setEnabled:NO];
        [self.checkMeasurePerc setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.measurePct setEnabled:NO];
        [self.measurePct setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    }else{
        if([wasteBlock.ratioSamplingEnabled integerValue] ==1){
            
            [self.isMeasurePlot setHidden:NO];
            [self.isMeasurePlotLabel setHidden:NO];
            [self.plotNumber setEnabled:NO];
            [self.plotNumber setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            //[self.plotEstimatedVolume setHidden:NO];
            //[self.plotEstimatedVolume setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
           // [self.plotEstimatedVolumeLabel setHidden:NO];
            if([self.wastePlot.isMeasurePlot integerValue] == 1){
                [self.measurePct setEnabled:YES];
                [self.isMeasurePlot setText:@"YES"];
                [self.isMeasurePlot setBackgroundColor:[UIColor systemGreenColor]];
            }else{
                [self.measurePct setEnabled:NO];
                [self.measurePct setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            }
        }
    }

    [self.size setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    
    if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue])
    {
        [self.licence setHidden:NO];
        [self.licence setEnabled:NO];
        [self.licence setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        self.licence.tag = 8;
        [self.licenceLabel setHidden:NO];
        [self.cuttingPermit setHidden:NO];
        [self.cuttingPermit setEnabled:NO];
        [self.cuttingPermit setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        self.cuttingPermit.tag = 9;
        [self.cuttingPermitLabel setHidden:NO];
        [self.cutBlock setHidden:NO];
        [self.cutBlock setEnabled:NO];
        [self.cutBlock setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        self.cutBlock.tag = 10;
        [self.cutBlockLabel setHidden:NO];
    }

    // Populate version number
    [versionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteVersionNumber"]];
}

// SAME ROW SELECT APPLY
- (void)shapeRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.shapePicker.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.shapePicker.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        
        // apply the first row
        ShapeCode *sc = [self.plotShapeArray objectAtIndex:[self.shapePicker selectedRowInComponent:0]];
        self.shape.text = sc.shapeCode;
        
        [self.shape resignFirstResponder];
    }
}
// enable multiple gesture recognizers, otherwise same row select wont detect taps
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // enable multiple gesture recognition
    return true;
}

- (void) sortPiece
{
    self.wastePieces = [self.wastePlot.plotPiece allObjects];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"sortNumber" ascending:YES];
    self.wastePieces = [self.wastePieces sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.toolbarHidden = NO;
    [super viewWillAppear:animated];
    
    [[Timer sharedManager] setCurrentVC:self];
    
    if(self.currentEditingPiece){
        NSString *nextProperty = [self getNextMissingProperty:self.currentEditingPiece currentProperty:self.currentEditingPieceElement];
        if(![nextProperty isEqualToString:@""]){
            PieceValueTableViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PieceLookupPickerViewControllerSID"];
            pvc.wastePiece = self.currentEditingPiece;
            pvc.wasteBlock = self.wasteBlock;
            pvc.propertyName = nextProperty;
            pvc.plotVC = self;
            pvc.isLoopingProperty = YES;
            [self.navigationController pushViewController:pvc animated:YES];
        }
    }
    
    int row;
    
    // update shape picker selected row
    row = 0;
    for (ShapeCode *sc in self.plotShapeArray) {
        if([self.shape.text isEqualToString:sc.shapeCode]){
            [self.shapePicker selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }
    
    [self sortPiece];
    [self.pieceTableView reloadData];
    
    [self updateCheckTotalPercent];
    
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setPlotViewValue:self.wastePlot];
    }else{
        [self.footerStatView setViewValue:self.wastePlot];
    }
}


- (void)viewWillDisappear:(BOOL)animated{
   // [super viewWillDisappear:animated];
   // self.navigationController.toolbarHidden = YES;
    
    [super viewWillDisappear:animated];
    
    [self saveData];
}

-(void)checkIsMeasurePlot{
    BOOL isMeasurePlot = NO;
    NSArray* pn_ary = nil;

    pn_ary = [self.wastePlot.plotStratum.n1sample componentsSeparatedByString:@","];

    for(NSString* pn in pn_ary){
        if([pn isEqualToString:self.plotNumber.text]){
            isMeasurePlot = YES;
            break;
        }
    }
    self.wastePlot.isMeasurePlot = isMeasurePlot? [[NSNumber alloc]  initWithInt:1] : [[NSNumber alloc]  initWithInt:0];
}


// SAVE FROM VIEW TO OBJECT
- (void)saveData{
    
    NSLog(@"SAVE PLOT");
    
    // strip the title, get the number string, get integer value of it, save it
    //self.wastePlot.plotID = [[NSNumber alloc] initWithInt:[[self.navigationItem.title substringWithRange:NSMakeRange(7, self.navigationItem.title.length-7)] integerValue]];
    
 
    if([self.wastePlot.plotStratum.stratumBlock.ratioSamplingEnabled intValue] == 1 && [self.wastePlot.plotNumber integerValue] != [self.plotNumber.text intValue] && !([self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"] || [self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"S"] || [self.wastePlot.plotStratum.stratum isEqualToString:@"STRE"]|| [self.wastePlot.plotStratum.stratum isEqualToString:@"STRS"])){
        [self checkIsMeasurePlot];
    }
    
    self.wastePlot.plotNumber = [[NSNumber alloc] initWithInt:[self.plotNumber.text intValue]];
    self.wastePlot.baseline = self.baseline.text;
    
    for (PlotSizeCode* psc in self.plotSizeArray){
        if ([psc.plotSizeCode isEqualToString:[self codeFromText:self.size.text ]] ){
            self.wastePlot.plotSizeCode = psc;
            break;
        }
    }
    
    self.wastePlot.surveyedMeasurePercent = [[NSNumber alloc] initWithFloat:[self.measurePct.text intValue]];
    
    /*
    NSLog(@"shape label = %@", self.shape.text);
    NSLog(@"shape obj = %@", self.wastePlot.plotShapeCode.shapeCode);
    */
    
    for (ShapeCode* sc in self.plotShapeArray){
        if ([sc.shapeCode isEqualToString:[self codeFromText:self.shape.text]] ){
            self.wastePlot.plotShapeCode = sc;
            break;
        }
    }
    
    /*
    NSLog(@"SAVE measurePercObj = %@", self.wastePlot.surveyedMeasurePercent);
    NSLog(@"SAVE shapeObj = %@", self.wastePlot.plotShapeCode.shapeCode);
    
    NSLog(@"SAVE measurePercField = %@", self.measurePct.text);
    NSLog(@"SAVE shapeField = %@", self.shape.text);
    */
    
    self.wastePlot.returnNumber = self.returnNumber.text;
    
    self.wastePlot.checkerMeasurePercent = [[NSNumber alloc] initWithInt:[self.checkMeasurePerc.text intValue]];
    self.wastePlot.strip = [[NSNumber alloc] initWithFloat:[self.strip.text intValue]];
    self.wastePlot.certificateNumber = self.certificationNumber.text;
    
    self.wastePlot.surveyorName = self.residueSurveyor.text;
    self.wastePlot.weather = self.weather.text;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM-dd-yyyy"];
    self.wastePlot.surveyDate = [dateFormat dateFromString:self.surveyDate.text];
    
    self.wasteBlock.checkerName = self.checkedBy.text;
    self.wastePlot.assistant = self.assistant.text;
    self.wastePlot.checkDate = [dateFormat dateFromString:self.checkSurveyDate.text];
    self.wastePlot.checkVolume = [NSDecimalNumber decimalNumberWithString:self.checkVolume.text];
    
    for (WasteStratum *ws in [self.wasteBlock.blockStratum allObjects]) {
        double  totalestimatedvolume = 0.0;
        for (WastePlot *wp in [ws.stratumPlot allObjects]) {
            totalestimatedvolume = totalestimatedvolume + [wp.plotEstimatedVolume doubleValue];
            
            if ([ws.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"] && ![wp.checkVolume isEqualToNumber:wp.plotEstimatedVolume]) {
                for (WastePiece *wpiece in [wp.plotPiece allObjects]) {
                    
                    double estimatedPercent = [wpiece.estimatedPercent floatValue] / 100.0;
                    NSDecimalNumber *percentEstimate = [[NSDecimalNumber alloc] initWithDouble:estimatedPercent];
                    NSDecimalNumber *checkVolume = [NSDecimalNumber decimalNumberWithDecimal:[wp.checkVolume decimalValue]];
                    
                    wpiece.checkPieceVolume = [percentEstimate decimalNumberByMultiplyingBy:checkVolume];
                }
            }
        }
        ws.totalEstimatedVolume = [[NSDecimalNumber alloc] initWithDouble:totalestimatedvolume];
        NSLog(@"Total Estimated Volume %@", ws.totalEstimatedVolume);
    }
    
    self.wastePlot.notes = self.notes.text;
    if ([self.wasteBlock.userCreated intValue] == 1){
        double plotEstimatedVolumeValue = [self.plotEstimatedVolume.text doubleValue];
        if (plotEstimatedVolumeValue > 0 && plotEstimatedVolumeValue < 1) {
            self.wastePlot.plotEstimatedVolume = [NSDecimalNumber decimalNumberWithString:@"1"];
        } else {
            self.wastePlot.plotEstimatedVolume = [NSDecimalNumber decimalNumberWithString:self.plotEstimatedVolume.text];
        }
    }else{
        self.wastePlot.plotStratum.checkTotalEstimatedVolume = [NSDecimalNumber decimalNumberWithString:self.totalEstimateVolume.text];
    }
    
    self.wastePlot.aggregateLicence = self.licence.text;
    self.wastePlot.aggregateCuttingPermit = self.cuttingPermit.text;
    self.wastePlot.aggregateCutblock = self.cutBlock.text;

    NSError *error;
    
    // save the whole cut block
    NSManagedObjectContext *context = [self managedObjectContext];
    [context save:&error];
    
    if( error != nil){
        NSLog(@" Error when saving waste plot into Core Data: %@", error);
    }
    
    [self.pieceTableView reloadData];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//KEYBOARD DISMISS
// ON RETURN
- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

// ON BACKGROUND TAP
- (void)dismissKeyboard {
    //[self.notes resignFirstResponder];
    
   [self.view endEditing:YES];
    
}

- (void) updateCheckTotalPercent{
    double percent = 0.0;
    for(WastePiece *wp in [self.wastePlot.plotPiece allObjects]){
        if(([wp.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"4"] && [wp.pieceNumber rangeOfString:@"C"].location != NSNotFound)||
           [wp.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"1"] ||
           [wp.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"2"] ||
           [wp.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"3"] ||
           wp.pieceCheckerStatusCode == nil){
            
            percent= percent + [wp.estimatedPercent doubleValue];
        }
    }
    self.totalCheckPercent.text = [[NSString alloc] initWithFormat:@"%0.1f", percent];
    if ([self.totalCheckPercent.text doubleValue] != 100.0){
        [self.totalCheckPercent setTextColor:[UIColor redColor]];
    }else{
        [self.totalCheckPercent setTextColor:[UIColor blackColor]];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSLog(@"segue %@", segue.identifier);
    
    if ( [segue.identifier isEqualToString:@"reportFromPlotSegue"]){
        
        // our navigation controller has many segues, or views, but we need our ReportScreen
        ReportGeneratorTableViewController *reportGeneratorTableVC = (ReportGeneratorTableViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        
        reportGeneratorTableVC.wasteBlock = self.wasteBlock;
        reportGeneratorTableVC.wastePlot = self.wastePlot;
        
        //reportGeneratorTableVC.tallySwitchEnabled = YES; // plotTallySwitch is not initialized (maybe set an extra switch for reportGen to read)
    }
}

// SCREEN METHODS
//
#pragma mark - IBActions
- (void)savePlot:(id)sender{
    
    if([self validateCheckMeasure] && [self validatePlotNumberForDuplicate]){
        
        [self saveData];
        
        NSString *title = NSLocalizedString(@"Save Plot", nil);
        NSString *message = NSLocalizedString(@"", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        alert.tag = SavePlotEnum;
        [alert show];
    }

}

-(void) changePieceStatusByType:(NSString *) type {
    for (WastePiece *wpiece in [self.wastePlot.plotPiece allObjects]) {
        NSLog(@"piece status code %@", wpiece.pieceCheckerStatusCode.checkerStatusCode);
        if ([type isEqualToString:@"approved"] ) {
            if ([wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"1"] || [wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"3"])
                wpiece.pieceCheckerStatusCode = (CheckerStatusCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"checkerStatusCode" code:@"2"];
        } else {
            if ([wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"2"] || [wpiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"3"])
                wpiece.pieceCheckerStatusCode = (CheckerStatusCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"checkerStatusCode" code:@"1"];
        }
    }
    
    self.wastePieces = [self.wastePlot.plotPiece allObjects];
    [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
    [WasteCalculator calculateRate:self.wasteBlock ];
    [WasteCalculator calculatePiecesValue:self.wasteBlock];
    [WasteCalculator calculateEFWStat:self.wasteBlock];
    
    [self.footerStatView setViewValue:self.wastePlot];
    [self updateCheckTotalPercent];
    [self sortPiece];
    [self.pieceTableView reloadData];
}

- (IBAction) changeStatus:(id)sender {
    NSString *title = NSLocalizedString(@"Piece Status Change ", nil);
    NSString *message = NSLocalizedString(@"Please select a status.", nil);
    NSString *cancelBtn = NSLocalizedString(@"Cancel", nil);
    NSString *approveBtn = NSLocalizedString(@"Approve All", nil);
    NSString *notCheckedAllBtn = NSLocalizedString(@"Not Checked All", nil);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *approve = [UIAlertAction actionWithTitle:approveBtn style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self changePieceStatusByType:@"approved"];
    }];
    UIAlertAction *notChecked = [UIAlertAction actionWithTitle:notCheckedAllBtn style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self changePieceStatusByType:@"notChecked"];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelBtn style:UIAlertActionStyleCancel handler:nil];
   
    [alert addAction:cancel];
    [alert addAction:notChecked];
    [alert addAction:approve];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)addNewPiece:(id)sender{
    
    self.currentEditingPiece = [self addWastePieceByPlot:self.wastePlot editPieceNumber:@"" statusCode:@"1"];
    
    self.wastePieces = [self.wastePlot.plotPiece allObjects];
    
    [self sortPiece];
    
    [self.pieceTableView reloadData];
    //scroll to the bottom to the newly added piece
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:[self.wastePieces count] - 1 inSection:0];
    [self.pieceTableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)changePieceStatus:(id)sender{
    NSString *title = NSLocalizedString(@"Piece Status Change", nil);
    NSString *message = NSLocalizedString(@"Please select a status.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Not Checked", nil);
    NSString *otherButtonTitleTwo = NSLocalizedString(@"Approved", nil);
    NSString *otherButtonTitleThree = NSLocalizedString(@"No Tally", nil);
    NSString *otherButtonTitleFour = NSLocalizedString(@"Edit", nil);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, otherButtonTitleTwo, otherButtonTitleThree, otherButtonTitleFour, nil];
    alert.tag = ((UIButton *)sender).tag;
    NSLog(@"Passing the tag from button to the alert view, %ld to %ld",(long)((UIButton *)sender).tag, (long)alert.tag );
	[alert show];
}

- (IBAction) modifyPiece:(id) sender {
    NSString *title         = NSLocalizedString(@"Modify Piece", nil);
    NSString *message       = NSLocalizedString(@"", nil);
    NSString *cancelTitle   = NSLocalizedString(@"Cancel", nil);
    NSString *deleteTitle   = NSLocalizedString(@"Delete", nil);
    NSString *dupTitle      = NSLocalizedString(@"Duplicate", nil);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel      handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:deleteTitle style:UIAlertActionStyleDestructive handler:^ (UIAlertAction *action) {
        [self deleteNewPiece:sender];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:dupTitle    style:UIAlertActionStyleDefault     handler:^ (UIAlertAction *action) {
        [self promptNumberOfDuplicates:sender from:alert];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)deleteNewPiece:(id)sender{
    NSString *title = NSLocalizedString(@"Delete New Piece", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Delete", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, nil];
    alert.tag = ((UIButton *)sender).tag;
    //NSLog(@"Passing the tag from button to the alert view, %ld to %ld",(long)((UIButton *)sender).tag, (long)alert.tag );
    [alert show];
}

#pragma mark - User Prompts

- (void) promptNumberOfDuplicates:(id) sender from:(UIAlertController *) parentAlert {
    NSString *title         = NSLocalizedString(@"Number of Copies", nil);
    NSString *message       = NSLocalizedString(@"Please enter the number of desired copies", nil);
    NSString *okTitle       = NSLocalizedString(@"OK", nil);
    NSString *cancelTitle   = NSLocalizedString(@"Cancel", nil);
    NSInteger sourceTag    = [(UIButton *)sender tag];
    
    //Determine which piece to duplicate
    NSString *targetPieceNum = [(WastePiece *)[self.wastePieces objectAtIndex:sourceTag] pieceNumber];
    targetPieceNum = [targetPieceNum stringByReplacingOccurrencesOfString:@"C" withString:@""];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder        = NSLocalizedString(@"1 - 99", nil);
        textField.accessibilityLabel = NSLocalizedString(@"1 - 99", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 7;
        textField.delegate           = self;
        self.numberOfDuplicatePieces = textField;
    }];
    
    [alert addAction: [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel  handler:nil]];
    [alert addAction: [UIAlertAction actionWithTitle:okTitle     style:UIAlertActionStyleDefault handler:^ (UIAlertAction *action) {
        
        // Add data
        for (int i = 0; i < [alert.textFields[0].text intValue]; i++) {
            [self duplicateWastePieceByPlot:self.wastePlot pieceNumber:targetPieceNum];
        }
        
        // Update UI
        self.wastePieces = [self.wastePlot.plotPiece allObjects];
        [self sortPiece];
        [self.pieceTableView reloadData];
        
        // Scroll
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:[self.wastePieces count] - 1 inSection:0];
        [self.pieceTableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


// CHARACTER LIMIT CHECK
/*
 TAG 0 = default NO (not editable)
 
 TAG 1 = 256 char max
    
 TAG 2 = 100 char max
 
 TAG 3 =  10 char max
*/
#pragma mark - UITextField
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    BOOL result = YES;
    if (textField == self.checkMeasurePerc || textField == self.measurePct){
        
        result = [self validateCheckMeasure];
    }else if(textField == self.plotNumber){
        //check if the plot number already exits
        result = [self validatePlotNumberForDuplicate ];
        if(!result){
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Plot number already exists in stratum. Please correct the plot number."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }];
            
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
    return result;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.checkMeasurePerc || textField == self.measurePct){
        
        return [self validateCheckMeasure];
    }
    
    return YES;
}

- (BOOL):(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // INPUT VALIDATION
    //
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str appendString:string];
    NSString *theString = str;
    
    // ALPHABET ONLY
    if(textField==self.weather || textField==self.assistant || textField==self.residueSurveyor){
        if( ![self validInputAlphabetOnly:theString] ){
            return NO;
        }
        
    // Numbers Only
    } else if (textField == self.numberOfDuplicatePieces) {
        if ( ![self validInputNumbersOnly:theString] ) {
            return NO;
        }
    }else if(textField == self.totalEstimateVolume || textField == self.plotEstimatedVolume || textField == self.checkVolume){
        
        if ( ![self validInputNumbersOnlyWithDot:theString] ) {
            return NO;
        }
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
        case 5:
            return (newLength > 10) ? NO : YES;
            break;

        case 4:
            for (int i = 0; i < [string length]; i++) {
                unichar c = [string characterAtIndex:i];
                if ([myCharSet characterIsMember:c]) {
                    return (newLength > 3) ? NO : YES;
                }
            }
            return [string isEqualToString:@""];
            break;
        case 6:
            //skip
            return YES;
            
        case 7:
            return (newLength > 2) ? NO : YES;
            break;
        case 8:
            return (newLength > 10) ? NO : YES;
            break;
        case 9:
            return (newLength > 10) ? NO : YES;
            break;
        case 10:
            return (newLength > 10) ? NO : YES;
            break;
        default:
            return NO; // NOT EDITABLE
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.checkMeasurePerc || textField == self.totalEstimateVolume || textField == self.measurePct || textField == self.plotEstimatedVolume){
        
        //save the change first
        [self saveData];
        
        //if esimate volume change, need to re-calculate the check volume
        BOOL pieceDidChange = NO;
        if (textField == self.totalEstimateVolume || textField == self.plotEstimatedVolume){
            for(WastePiece *wp in self.wastePieces){
                //if ([wp.pieceNumber rangeOfString:@"C"].location != NSNotFound){
                [WasteCalculator calculatePieceStat:wp wastePlot:self.wastePlot wasteStratum:self.wastePlot.plotStratum];
                    pieceDidChange = YES;
                //}
            }
        }
        
        //update the benchmak and calculate the numbers again
        [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
        [WasteCalculator calculateRate:self.wasteBlock ];
        [WasteCalculator calculatePiecesValue:self.wasteBlock ];
        if([self.wasteBlock.userCreated intValue] ==1){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
        }

        //save the calculated value
        [self saveData];

        if (pieceDidChange){
            [self.pieceTableView reloadData];
        }
        
        //refresh footer
        if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
            [self.efwFooterView setPlotViewValue:self.wastePlot];
        }else{
            [self.footerStatView setViewValue:self.wastePlot];
        }
    }else if(textField == self.surveyDate || textField == self.checkSurveyDate){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM-dd-yyyy"];

        textField.text = [formatter stringFromDate:self.datePicker.date];
        [textField resignFirstResponder];
    }else if(textField == self.plotNumber){
        if(self.wastePlot.plotStratum.stratumBlock.ratioSamplingEnabled){
            [self saveData];
            //refresh isMeasurePlot field
            /* no long able to change the plot number
            if (self.wastePlot.isMeasurePlot){
                if ( [self.wastePlot.isMeasurePlot integerValue] == 1 ){
                    self.isMeasurePlot.text =  @"YES";
                    self.isMeasurePlot.textColor = [UIColor greenColor];
                    [self.predictionOnlyWarningLabel setHidden:YES];
                }else{
                    self.isMeasurePlot.text =  @"NO";
                    self.isMeasurePlot.textColor = [UIColor redColor];
                    [self.predictionOnlyWarningLabel setHidden:NO];
                }
            }
             */
        }
    }
    _activeTF = nil;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    
    _activeTF = textField;
    
    if(textField == self.surveyDate || textField == self.checkSurveyDate){
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM-dd-yyyy"];
        if(textField == self.surveyDate){
            [self.datePicker setDate:([dateFormat dateFromString:self.surveyDate.text] ? [dateFormat dateFromString:self.surveyDate.text] : [NSDate date])];
        }else if(textField == self.checkSurveyDate){
            [self.datePicker setDate:([dateFormat dateFromString:self.checkSurveyDate.text] ? [dateFormat dateFromString:self.checkSurveyDate.text] : [NSDate date])];
        }
    }
}

#pragma mark - UITextView
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    
   // NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
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
            
        case 4:
            //check measure %
            return (newLength > 3) ? NO : YES;
            break;
            
        default:
            return NO; // NOT EDITABLE
    }
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

// PICKER STUFF
//
#pragma mark PickerView DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerView.tag == 1)
        return self.plotSizeArray.count;
    
    else if(pickerView.tag == 2)
        return self.plotShapeArray.count;
    
    else
        return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (pickerView.tag == 1)
        return [NSString stringWithFormat:@"%@ - %@",[self.plotSizeArray[row] valueForKey:@"plotSizeCode"], [self.plotSizeArray[row] valueForKey:@"desc"]];
    
    else if(pickerView.tag == 2)
        return [NSString stringWithFormat:@"%@ - %@",[self.plotShapeArray[row] valueForKey:@"shapeCode"],[self.plotShapeArray[row] valueForKey:@"desc"]];
    
    else
        return nil;
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (pickerView.tag == 1){
        self.size.text = [NSString stringWithFormat:@"%@ - %@",[self.plotSizeArray[row] valueForKey:@"plotSizeCode"], [self.plotSizeArray[row] valueForKey:@"desc"]];
        [self.size resignFirstResponder];
        
    }else if(pickerView.tag == 2){
        self.shape.text = [NSString stringWithFormat:@"%@ - %@",[self.plotShapeArray[row] valueForKey:@"shapeCode"],[self.plotShapeArray[row] valueForKey:@"desc"]];
        [self.shapePicker selectRow:row inComponent:0 animated:NO];
        [self.shape resignFirstResponder];
    }
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

- (BOOL)validateCheckMeasure{
    NSString *pc_label = @"";
    NSString *pc_value = @"";
    NSString *error = @"";
    
     if ([self.wasteBlock.userCreated intValue] == 1){
         pc_label = @"Measure Percentage";
         pc_value = self.measurePct.text;
     }else{
         pc_label = @"Check Measure Percentage";
         pc_value = self.checkMeasurePerc.text;
     }
    
    pc_value = [[NSNumber numberWithInt:[pc_value intValue]] stringValue];
    
    if( [pc_value intValue ]> 100 ){
        error =[NSString stringWithFormat:@"%@ cannot be greater than 100%%.", pc_label];
    }else if( [pc_value intValue ] == 0 ){
        error =[NSString stringWithFormat:@"%@ cannot be 0%%.", pc_label];
    }

    if ([error isEqualToString:@""]){
        return YES;
    }else{
        NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
        NSString *title = NSLocalizedString(@"Error", nil);
        NSString *message = NSLocalizedString(error, nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        alert.tag = ValidationEnum;
        [alert show];
        return NO;
    }
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == ValidationEnum){
        //validateion alertview
        if (alertView.cancelButtonIndex == buttonIndex) {

        }else{
            //if the user click "continue" then let user to back to stratum screen
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if(alertView.tag == SavePlotEnum){
        //NSLog(@"Save Plot - ok click");
    }else{
        //other alertview
        NSString *targetPieceNumber =[(WastePiece *)[self.wastePieces objectAtIndex:alertView.tag] pieceNumber];
        //get the original piece number
        targetPieceNumber = [targetPieceNumber stringByReplacingOccurrencesOfString:@"C" withString:@""];

        if (alertView.cancelButtonIndex == buttonIndex) {
            //NSLog(@"Alert view clicked with the cancel button index.");
        }else {
            //check if it is "Delete" first
            if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString: @"Delete"]){
                WastePiece *p;
                
                for (WastePiece *wp in self.wastePieces){
                    if ([wp.pieceNumber isEqualToString:targetPieceNumber]){
                        p = wp;
                        [self deletePieceFromPlot:wp targetWastePlot:self.wastePlot];
                    }
                }
                
                self.wastePieces = [self.wastePlot.plotPiece allObjects];
                
                [self sortPiece];
                
                [self.pieceTableView reloadData];
                
                [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
                [WasteCalculator calculateRate:self.wasteBlock ];
                [WasteCalculator calculatePiecesValue:self.wasteBlock];
                
                if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
                    [WasteCalculator calculateEFWStat:self.wasteBlock];
                    [self.efwFooterView setPlotViewValue:self.wastePlot];
                }else{
                    [self.footerStatView setViewValue:self.wastePlot];
                }
                [self updateCheckTotalPercent];
            }else if((long)buttonIndex ==4){
                
                //1 - check if the edit piece record exit, if not, create a edit record with "C" append to the original piece number
                BOOL isEditRecordCreated = NO;
                WastePiece *orgPiece = nil;
                for (WastePiece *wp in self.wastePieces){
                    if ([wp.pieceNumber isEqualToString:[targetPieceNumber stringByAppendingString:@"C"]]){
                        isEditRecordCreated = YES;
                        
                    }
                    if ([wp.pieceNumber isEqualToString:targetPieceNumber]){
                        orgPiece = wp;
                    }
                }
                if (!isEditRecordCreated){
                    [self addWastePieceByPlot:self.wastePlot editPieceNumber:targetPieceNumber statusCode:@"4"];
                    orgPiece.pieceCheckerStatusCode =(CheckerStatusCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"checkerStatusCode" code:@"4"];
                }

                //2 - refresh the local piece array
                self.wastePieces = [self.wastePlot.plotPiece allObjects];

                [self sortPiece];
                
                [self.pieceTableView reloadData];
                [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
                [WasteCalculator calculateRate:self.wasteBlock ];
                [WasteCalculator calculatePiecesValue:self.wasteBlock];
                [WasteCalculator calculateEFWStat:self.wasteBlock];
                if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
                    [WasteCalculator calculateEFWStat:self.wasteBlock];
                    [self.efwFooterView setPlotViewValue:self.wastePlot];
                }else{
                    [self.footerStatView setViewValue:self.wastePlot];
                }
            } else {
                
                // 1 - check if a edit piece with "C" exit, delete it if exists
                WastePiece *p;
                
                for (WastePiece *wp in self.wastePieces){
                    if ([wp.pieceNumber isEqualToString:targetPieceNumber]){
                        p = wp;
                    }
                    if ([wp.pieceNumber isEqualToString:[targetPieceNumber stringByAppendingString:@"C"]]){
                        [self deletePieceFromPlot:wp targetWastePlot:self.wastePlot];
                    }
                }

                // 2 - change the status to the new status
                if ((long)buttonIndex == 1){
                    //not checked
                    p.pieceCheckerStatusCode = (CheckerStatusCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"checkerStatusCode" code:@"1"];
                }else if((long)buttonIndex ==2) {
                    //approved
                    p.pieceCheckerStatusCode = (CheckerStatusCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"checkerStatusCode" code:@"2"];
                }else if((long)buttonIndex ==3) {
                    //no tally
                    p.pieceCheckerStatusCode = (CheckerStatusCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"checkerStatusCode" code:@"3"];
                }
                
                //NSLog(@" plot size %d", self.wastePieces.count);
                
                self.wastePieces = [self.wastePlot.plotPiece allObjects];

                //NSLog(@" plot size %d", self.wastePieces.count);

                [self sortPiece];
                
                [self.pieceTableView reloadData];
                
                [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
                [WasteCalculator calculateRate:self.wasteBlock ];
                [WasteCalculator calculatePiecesValue:self.wasteBlock];
                [WasteCalculator calculateEFWStat:self.wasteBlock];
                if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
                    [WasteCalculator calculateEFWStat:self.wasteBlock];
                    [self.efwFooterView setPlotViewValue:self.wastePlot];
                }else{
                    [self.footerStatView setViewValue:self.wastePlot];
                }
                [self updateCheckTotalPercent];
            }
        }
    }
}


// TABLE POPULATION
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.wastePieces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //for static variable name, start with upper case
    //static NSString *ApprovedCellStr = @"ApprovedTableCell";
    //static NSString *NotCheckedCellStr = @"NotCheckedTableCell";
    
    NSString *cellStr = @"";
    WastePiece *currentPiece = [self.wastePieces objectAtIndex:indexPath.row];
    
    //[self.plotPiece objectAtIndex:indexPath.row];
    if ([currentPiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"1"]){
        cellStr = @"NotCheckedTableCell";
    }else if([currentPiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"2"]){
        cellStr = @"ApproveTableCell";
    }else if([currentPiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"3"]){
        cellStr = @"NoTallyTableCell";
    }else if([currentPiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"4"]){
        if([currentPiece.pieceNumber rangeOfString:@"C"].location != NSNotFound){
            cellStr = @"EditChangedPieceTableCell";
        }else{
            cellStr = @"EditOriginalPieceTableCell";
        }
    }else{
        cellStr = @"NewPieceTableCell";
    }
    
    
    PieceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if( [cell isKindOfClass:[PieceEditTableViewCell class]]){
        ((PieceEditTableViewCell *) cell).plotView = self;
    }

    cell.statusButton.tag = indexPath.row;
    
    //NSLog(@"piece number: %@ , tag: %ld ", currentPiece.pieceNumber, (long)cell.statusButton.tag);
    //NSLog(@"assessment method code: %@", self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode);
    

    //[cell bindCell:currentPiece wasteBlock:self.wasteBlock assessmentMethodCode:self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode userCreatedBlock:([self.wasteBlock.userCreated intValue] == 1)];
    
    [cell bindCell:currentPiece wasteBlock:self.wasteBlock wastePlot:self.wastePlot userCreatedBlock:([self.wasteBlock.userCreated intValue] == 1)];

    return cell;
}

- (void) populateFromObject{
    
    NSString *title = self.wastePlot.plotNumber ? [[NSString alloc] initWithFormat:@"(IFOR 204) Plot - %@", [self.wastePlot.plotNumber stringValue]] : @"";
    
    [[self navigationItem] setTitle:title];
    
    // FILL FROM OBJECT TO VIEW
    self.plotNumber.text = self.wastePlot.plotNumber ? [[NSString alloc] initWithFormat:@"%d", [self.wastePlot.plotNumber intValue]] : @"";
    self.baseline.text = self.wastePlot.baseline ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.baseline] : @"";
    
    //size is pulling from the stratum
    self.size.text = self.wastePlot.plotStratum.stratumPlotSizeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wastePlot.plotStratum.stratumPlotSizeCode.plotSizeCode, self.wastePlot.plotStratum.stratumPlotSizeCode.desc] : @"";
    self.measurePct.text = self.wastePlot.surveyedMeasurePercent ? [[NSString alloc] initWithFormat:@"%d", [self.wastePlot.surveyedMeasurePercent intValue]] : @"";
    self.shape.text = self.wastePlot.plotShapeCode.shapeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wastePlot.plotShapeCode.shapeCode, self.wastePlot.plotShapeCode.desc] : @"";
    self.returnNumber.text = self.wastePlot.returnNumber ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.returnNumber] : @"";
    self.checkMeasurePerc.text = self.wastePlot.checkerMeasurePercent ? [[NSString alloc] initWithFormat:@"%d", [self.wastePlot.checkerMeasurePercent intValue]] : @"";
    self.strip.text = self.wastePlot.strip ? [[NSString alloc] initWithFormat:@"%d", [self.wastePlot.strip intValue]] : @"";
    self.certificationNumber.text = self.wastePlot.certificateNumber ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.certificateNumber] : @"";
    self.residueSurveyor.text = self.wastePlot.surveyorName ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.surveyorName] : @"";
    self.weather.text = self.wastePlot.weather ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.weather] : @"";
    self.plotEstimatedVolume.text = self.wastePlot.plotEstimatedVolume ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.plotEstimatedVolume] : @"";
    NSLog(@"Check VOL.: %@", self.wastePlot.checkVolume);
    self.checkVolume.text = [self.wastePlot.checkVolume isEqualToNumber:@0] ? [[NSString alloc] initWithFormat:@"%d", [self.wastePlot.plotEstimatedVolume intValue]] : [[NSString alloc] initWithFormat:@"%d", [self.wastePlot.checkVolume intValue]];
    self.wastePlot.checkVolume = [self.wastePlot.checkVolume isEqualToNumber:@0] ? self.wastePlot.plotEstimatedVolume : self.wastePlot.checkVolume;
    self.greenVolume.text = self.wastePlot.greenVolume && [self.wastePlot.greenVolume floatValue] > 0 ?  [[NSString alloc] initWithFormat:@"%.2f", [self.wastePlot.greenVolume floatValue]] : @"";
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM-dd-yyyy"];
    self.surveyDate.text = [[NSString alloc] initWithFormat:@"%@", self.wastePlot.surveyDate ? [dateFormat stringFromDate:self.wastePlot.surveyDate] : [dateFormat stringFromDate:[NSDate date]]];
    
    self.checkedBy.text = self.wasteBlock.checkerName ? [[NSString alloc] initWithFormat:@"%@", self.wasteBlock.checkerName] : @"";
    self.assistant.text = self.wastePlot.assistant ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.assistant] : @"";
    self.checkSurveyDate.text = [[NSString alloc] initWithFormat:@"%@", self.wastePlot.checkDate ? [dateFormat stringFromDate:self.wastePlot.checkDate] : [dateFormat stringFromDate:[NSDate date]]];
    self.notes.text = self.wastePlot.notes ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.notes] : @"";
    
    NSLog(@"Assessment method code: %@", self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode);
    // Check stratum to show the total estimated volume
    if ([self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"]){
        //Note: plotEstimatedVolume is mapped to Survey Volume
        [self.plotEstimatedVolumeLabel setHidden:NO];
        [self.plotEstimatedVolume setEnabled:NO];
        [self.plotEstimatedVolume setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.plotEstimatedVolume setHidden:NO];
        
        [self.checkVolumeLabel setHidden:NO];
        [self.checkVolume setHidden:NO];
        
        [self.totalCheckPercent setHidden:NO];
        [self.totalCheckPercentLabel setHidden:NO];
        
        [self updateCheckTotalPercent];
    }
    
    if (![self.wastePlot.plotSizeCode.plotSizeCode isEqualToString:@"S"] &&
        ![self.wastePlot.plotSizeCode.plotSizeCode isEqualToString:@"E"] &&
        ![self.wastePlot.plotSizeCode.plotSizeCode isEqualToString:@"O"] &&
        [self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]) {
        
        //Note: GreenVolume is mapped to Predicted Volume
        [self.greenVolume setHidden:NO];
        [self.greenVolumeLabel setHidden:NO];
        [self.greenVolume setEnabled:NO];
        [self.greenVolume setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        
        if ([self.wastePlot.isMeasurePlot integerValue] == 1 ) {
            self.isMeasurePlot.text =  @"YES";
            self.isMeasurePlot.textColor = [UIColor whiteColor];
            self.isMeasurePlot.backgroundColor = [UIColor greenColor];
            [self.predictionOnlyWarningLabel setHidden:YES];
        } else {
            self.isMeasurePlot.text =  @"NO";
            self.isMeasurePlot.textColor = [UIColor whiteColor];
            self.isMeasurePlot.backgroundColor = [UIColor redColor];
            [self.isMeasurePlot setHidden:NO];
            [self.isMeasurePlotLabel setHidden:NO];
            [self.predictionOnlyWarningLabel setHidden:NO];
            [self.checkMeasurePerc setEnabled:NO];
            [self.checkMeasurePerc setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        }
    }
    
    self.wastePieces = [self.wastePlot.plotPiece allObjects];
    
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        [WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setPlotViewValue:self.wastePlot];
    }else{
        [self.footerStatView setViewValue:self.wastePlot];
        [self.footerStatView setDisplayFor:self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode screenName:@"plot"];
    }
    
    self.licence.text = self.wastePlot.aggregateLicence;
    self.cuttingPermit.text = self.wastePlot.aggregateCuttingPermit;
    self.cutBlock.text = self.wastePlot.aggregateCutblock;
    
    if (self.wastePlot.plotPiece.count > 10)
        [self.downArrow setHidden:NO];
    else
        [self.downArrow setHidden:YES];
}

- (void) scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    long rowIndex = (long)[[self.pieceTableView indexPathForRowAtPoint: CGPointMake(10, y - 1)] row];
    
    if (rowIndex + 1 == [self.wastePlot.plotPiece count] || rowIndex == 0)
        [self.downArrow setHidden:YES];
    else
        [self.downArrow setHidden:NO];
}

#pragma mark - Core Data functions

-(WastePiece *) duplicateWastePieceByPlot:(WastePlot *)targetWastePlot pieceNumber:(NSString *)pieceNumber {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    WastePiece *newWp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePiece" inManagedObjectContext:context];
    WastePiece *originalPiece = nil;
    
    // Find largest piece number and add one for new piece
    int i = 0;
    NSArray *pieces =[targetWastePlot.plotPiece allObjects];
    
    for (WastePiece *wp in pieces){
        if ([wp.pieceNumber isEqualToString:pieceNumber]) {
            originalPiece = wp;
        }
        if ([wp.pieceNumber rangeOfString:@"C"].location == NSNotFound && [wp.pieceNumber integerValue] > i){
            i = [wp.pieceNumber intValue];
        }
    }
    
    // Copy existing properties
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([originalPiece class], &numberOfProperties);
    
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        
        [newWp setValue:[originalPiece valueForKey:name] forKey:name];
    }
    free(propertyArray);

    // Make new piece unique
    newWp.pieceNumber       = [[NSNumber numberWithInt:(i + 1)] stringValue];
    newWp.sortNumber        = [NSNumber numberWithInt:((i + 1) * 10)];
    newWp.piece = nil;
    
    if ([self.wasteBlock.userCreated intValue] == 1){
        [newWp setIsSurvey:[NSNumber numberWithBool:YES]];
        
    } else {
        [newWp setIsSurvey:[NSNumber numberWithBool:NO]];
    }
    
    [targetWastePlot addPlotPieceObject:newWp];
    return newWp;
}

-(WastePiece *) addWastePieceByPlot:(WastePlot *)targetWastePlot editPieceNumber:(NSString *)editiPieceNumber statusCode:(NSString *)statusCode{

    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePiece *newWp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePiece" inManagedObjectContext:context];

    if( [editiPieceNumber isEqualToString:@""]){
        // new piece
        // - found the largest number in the piece and plus one for new piece
        int i = 0;
        NSArray *pieces =[targetWastePlot.plotPiece allObjects];
        for(WastePiece *wp in pieces){
            if ([wp.pieceNumber rangeOfString:@"C"].location == NSNotFound){
                if( [wp.pieceNumber integerValue] > i){
                    i = [wp.pieceNumber intValue];
                }
            }
        }
        
        newWp.pieceNumber = [[NSNumber numberWithInt:(i + 1)] stringValue];
        newWp.sortNumber =[NSNumber numberWithInt:((i + 1) * 10)];
        newWp.buttDiameter = nil;
        newWp.lengthDeduction = nil;
        newWp.topDeduction = nil;
        newWp.buttDeduction = nil;
        if ([self.wasteBlock.userCreated intValue] ==1){
            [newWp setIsSurvey:[NSNumber numberWithBool:YES]];
        }else{
            [newWp setIsSurvey:[NSNumber numberWithBool:NO]];
        }

    }else{
        // edit piece
        // - copy the value from the original piece to the new piece
        NSArray *pieces =[targetWastePlot.plotPiece allObjects];
        WastePiece *originalPiece = nil;
        for(WastePiece *wp in pieces){
            if([wp.pieceNumber isEqualToString:editiPieceNumber]){
                originalPiece = wp;
                break;
            }
        }
        
        unsigned int numberOfProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([originalPiece class], &numberOfProperties);
        
        for (NSUInteger i = 0; i < numberOfProperties; i++)
        {
            objc_property_t property = propertyArray[i];
            NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
            
            [newWp setValue:[originalPiece valueForKey:name] forKey:name];
            
            //NSLog(@"Transfer property: %@, value: %@", name, [tmDto valueForKey:name]);
        }
        free(propertyArray);
        
        // - add "C" in the piece number
        newWp.pieceNumber = [newWp.pieceNumber stringByAppendingString:@"C"];
        
        // - clear the "piece" as ID field
        newWp.piece = nil;
        
        // - status edit (4)
        newWp.pieceCheckerStatusCode = (CheckerStatusCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"checkerStatusCode" code:@"4"];
        
        // - plus 1 to the sort number of the original value
        newWp.sortNumber = [NSNumber numberWithInt:[newWp.sortNumber intValue]+ 1];
        
    }
    
    [targetWastePlot addPlotPieceObject:newWp];
    
    return newWp;
}

-(void) deletePieceFromPlot:(WastePiece *)targetWastePiece targetWastePlot:(WastePlot *)targetWastePlot{

    //1 - remove the piece from plot
    NSMutableSet *tempPieces = [NSMutableSet setWithSet:targetWastePlot.plotPiece];
    [tempPieces removeObject:targetWastePiece];
    targetWastePlot.plotPiece = tempPieces;
    
    // 2 - delete the piece from core data
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:targetWastePiece];
    
    NSError *error;
    [context save:&error];

    if (error){
        NSLog(@"Error when deleting a piece and save :%@", error);
    }

}

#pragma mark - BackButtonHandler protocol
-(BOOL) navigationShouldPopOnBackButton
{
    [self saveData];

    WastePlotValidator *wpv = [[WastePlotValidator alloc] init];
    NSString *errorMessage = [wpv validatePlot:wastePlot showDetail:YES];
    BOOL isfatal = NO;
    
    if( [errorMessage rangeOfString:@"Error"].location != NSNotFound){
        isfatal = YES;
    }
    
    //check measurement precentage, it needs to be between 1 to 100
    NSString *pc_label = @"";
    NSString *pc_value = @"";
    
    if ([self.wasteBlock.userCreated intValue] == 1){
        pc_label = @"Measure Percentage";
        pc_value = self.measurePct.text;
    }else{
        pc_label = @"Check Measure Percentage";
        pc_value = self.checkMeasurePerc.text;
    }
 
    if( [pc_value intValue ]> 100 ){
        errorMessage =[NSString stringWithFormat:@"%@ %@ cannot be greater than 100%%.", errorMessage, pc_label];
        isfatal = YES;
    }else if( [pc_value intValue ] == 0 ){
        errorMessage =[NSString stringWithFormat:@"%@ %@ cannot be 0%%.", errorMessage, pc_label];
        isfatal = YES;
    }
    
    if([wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode isEqualToString:@"E"]){
        //check if the estimate percentage, it needs to be 100%
       
         if([self.totalCheckPercent.text floatValue] != 100.0){
            errorMessage =[NSString stringWithFormat:@"%@ Species and Grade percent estimates do not equal 100%%, please adjust values.", errorMessage];
            isfatal = YES;
        }
        /*if([self.totalEstimateVolume.text floatValue] == 0.0){
            errorMessage =[NSString stringWithFormat:@"%@ Total Estimate Volume is 0.", errorMessage];
            isfatal = YES;
        }*/
        if([self.plotEstimatedVolume.text floatValue] == 0.0){
            errorMessage =[NSString stringWithFormat:@"%@ Plot Estimate Volume is 0.", errorMessage];
            isfatal = YES;
        }
    }
    //for aggregate licence, cp and cb must be entered before navigating back
    if([wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        if([self.wastePlot.aggregateLicence isEqualToString:@""]){
            isfatal = YES;
            errorMessage = [NSString stringWithFormat:@"%@ Missing Licence field.", errorMessage];
        }
        if([self.wastePlot.aggregateCutblock isEqualToString:@""]){
            isfatal = isfatal || NO;
            errorMessage = [NSString stringWithFormat:@"%@ Missing Block field.", errorMessage];
        }
        /*if([self.wastePlot.aggregateCuttingPermit isEqualToString:@""]){
            isfatal = YES;
            errorMessage = [NSString stringWithFormat:@"%@ Missing CP field.",errorMessage];
        }*/
    }
    
    if(![self validatePlotNumberForDuplicate]){
        isfatal = YES;
        errorMessage =[NSString stringWithFormat:@"%@ Plot number already exists in stratum. Please correct the plot number.", errorMessage];
    }

    if (![errorMessage isEqualToString:@""]){
        UIAlertView *validateAlert = nil;

        //Let user to bypass the error
        if (isfatal){
            validateAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage
                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }else{
            validateAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:errorMessage
                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Continue", nil];
        }
        //set tag so we can tell what alertview in the delegate function

            //validateAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage
             //                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Continue", nil];

        validateAlert.tag = ValidationEnum;
        [validateAlert show];
        return NO;
    }
    else
    {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        if(![[f numberFromString:self.measurePct.text] isEqualToNumber:self.originalMP])
        {
            if((self.wastePlot.measurePctEdited != nil && [self.wastePlot.measurePctEdited intValue] == 1) && ![self.fromBackButton isEqualToNumber:@1])
            {
                DataEndorsementViewController *devc = [self.storyboard instantiateViewControllerWithIdentifier:@"dataEndorsementViewController"];
                devc.wasteStratum = self.wastePlot.plotStratum;
                devc.plotVC = self;
                devc.endorsementType = @"Edit Plot Back Button";
                devc.plotNumber = self.wastePlot.plotNumber;
                devc.wastePlot = self.wastePlot;
                self.wastePlot.measurePctEdited = [NSNumber numberWithInt:1];
                self.fromBackButton = @1;
                [self.navigationController pushViewController:devc animated:YES];
            }
            else
            {
                self.originalMP = [f numberFromString:self.measurePct.text];
                self.wastePlot.measurePctEdited = @1;
            }
            return NO;
        }
        /*
        if(self.originalMP != nil && [self.originalMP intValue] != [self.wastePlot.surveyedMeasurePercent intValue])
        {
            DataEndorsementViewController *devc = [self.storyboard instantiateViewControllerWithIdentifier:@"dataEndorsementViewController"];
            devc.wasteStratum = self.wastePlot.plotStratum;
            devc.plotVC = self;
            devc.endorsementType = @"Edit Plot Back Button";
            devc.plotNumber = self.wastePlot.plotNumber;
            devc.wastePlot = self.wastePlot;
            self.fromBackButton = @1;
            [self.navigationController pushViewController:devc animated:YES];
            return NO;
        }*/
        else
        {
            return YES;
        }
    }
}
/*
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}
*/

- (NSString*) codeFromText:(NSString*)pickerText{
    
    // 1st one is the Code
    // 2nd one is the .desc
    return [[pickerText componentsSeparatedByString:@" - "] objectAtIndex:0];
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

- (BOOL) validInputAlphabetOnly:(NSString*)theString{
    theString = [theString uppercaseString];
    NSCharacterSet *characterSet = [NSCharacterSet uppercaseLetterCharacterSet];
    NSMutableCharacterSet *space = [NSMutableCharacterSet characterSetWithCharactersInString:@" "];
    
    [space formUnionWithCharacterSet:characterSet];
    
    characterSet = space;
    
    
    
    for (int i = 0; i < [theString length]; i++) {
        unichar c = [theString characterAtIndex:i];
        if ( ![characterSet characterIsMember:c] ){
            return NO;
        }
    }
    
    return YES;
}
- (BOOL) validatePlotNumberForDuplicate{
    BOOL result = YES;
    for(WastePlot *p in self.wastePlot.plotStratum.stratumPlot){
        if(p != self.wastePlot){
            if([[p.plotNumber stringValue] isEqualToString:self.plotNumber.text]){
                result = NO;
            }
        }
    }
    return result;
}
-(NSString*) getFirstPieceProperty:(NSString*) stratumTypeCode{
    if([stratumTypeCode isEqualToString:@"P"]){
        return @"pieceBorderlineCode";
    }else if([stratumTypeCode isEqualToString:@"O"]){
        return @"pieceScaleSpeciesCode";
    }else if([stratumTypeCode isEqualToString:@"S"]){
        return @"pieceScaleSpeciesCode";
    }else if([stratumTypeCode isEqualToString:@"E"]){
        return @"pieceScaleSpeciesCode" ;
    }
    return @"";
}
-(NSMutableArray*) getNewPieceProperties:(NSString*) stratumTypeCode piece:(WastePiece*)piece{
    NSMutableArray *properties = [[NSMutableArray alloc] init];
    
    if([stratumTypeCode isEqualToString:@"P"]){
        [properties addObject:@"pieceBorderlineCode"];
        [properties addObject:@"pieceScaleSpeciesCode"];
        [properties addObject:@"pieceMaterialKindCode"];
        [properties addObject:@"pieceWasteClassCode"];
        [properties addObject:@"length"];
        [properties addObject:@"topDiameter"];
        [properties addObject:@"pieceTopEndCode"];
        if(!piece.pieceMaterialKindCode || ![piece.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"]){
            [properties addObject:@"buttDiameter"];
            [properties addObject:@"pieceButtEndCode"];
        }
        [properties addObject:@"pieceScaleGradeCode"];
    }else if([stratumTypeCode isEqualToString:@"O"]){
        /*
        [properties addObject:@"pieceScaleSpeciesCode"];
        [properties addObject:@"pieceMaterialKindCode"];
        [properties addObject:@"pieceWasteClassCode"];
        [properties addObject:@"pieceScaleGradeCode"];
        [properties addObject:@"densityEstimate"];
        [properties addObject:@"estimatedVolume"];
         */
    }else if([stratumTypeCode isEqualToString:@"S"]){
        [properties addObject:@"pieceScaleSpeciesCode"];
        [properties addObject:@"pieceMaterialKindCode"];
        [properties addObject:@"pieceWasteClassCode"];
        [properties addObject:@"length"];
        [properties addObject:@"topDiameter"];
        [properties addObject:@"pieceTopEndCode"];
        if(!piece.pieceMaterialKindCode || ![piece.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"]){
            [properties addObject:@"buttDiameter"];
            [properties addObject:@"pieceButtEndCode"];
        }
        [properties addObject:@"pieceScaleGradeCode"];
    }else if([stratumTypeCode isEqualToString:@"E"]){
        
        [properties addObject:@"pieceScaleSpeciesCode"];
        [properties addObject:@"pieceMaterialKindCode"];
        [properties addObject:@"pieceWasteClassCode"];
        [properties addObject:@"pieceScaleGradeCode"];
        [properties addObject:@"estimatedPercent"];
         
    }
    return properties;
}

-(void) removeCurrentPiece{
    self.currentEditingPieceElement = @"";
    self.currentEditingPiece = nil;
}

-(void) updateCurrentPieceProperty:(WastePiece*)wp property:(NSString*)property{
    self.currentEditingPiece = wp;
    self.currentEditingPieceElement = property;
}

-(NSString*)getNextMissingProperty:(WastePiece*)wp currentProperty:(NSString*)currentProperty{
    NSMutableArray *properties = [self getNewPieceProperties:wp.piecePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode piece:wp];
    //first locate the index of property
    int currentPropertyIndex = -1;
    for(NSString *p in properties){
        currentPropertyIndex = currentPropertyIndex + 1;
        if([p isEqualToString:currentProperty]){
            break;
        }
    }
    int counter = (int)properties.count ;
    NSString *missingProptery = @"";
    if(currentProperty >=0){
        
        for(;counter > 0; counter-- ){
            //get the next property index
            currentPropertyIndex = currentPropertyIndex + 1;
            if(currentPropertyIndex == properties.count ){
                //reset next index
                currentPropertyIndex = 0;
            }
            
            NSManagedObject *val = [wp valueForKey:properties[currentPropertyIndex]];
            BOOL filled = NO;
            if(val){
                if([val isKindOfClass:[NSDecimalNumber class]]){
                    NSDecimalNumber *val_dnum = (NSDecimalNumber*)val;
                    if([val_dnum floatValue] > 0){
                        filled = YES;
                    }
                }else if([val isKindOfClass:[NSNumber class]]){
                    NSNumber *val_num = (NSNumber*)val;
                    if([val_num integerValue] > 0){
                        filled = YES;
                    }
                }else{
                    filled = YES;
                }
                
            }
            if(!filled){
                missingProptery =properties[currentPropertyIndex];
                break;
            }
        }
    }
    return missingProptery;
}


@end
