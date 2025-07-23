//
//  PilePlotViewController.m
//  iForWaste
//
//  Created by Sweta Kutty on 2019-03-04.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "PilePlotViewController.h"
#import "BlockViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "WastePlot.h"
#import "WasteBlock.h"
#import "WastePile+CoreDataClass.h"
#import "WasteStratum.h"
#import "PileTableViewCell.h"
#import "PileEditTableViewCell.h"
#import "PlotSizeCode.h"
#import "ShapeCode.h"
#import "CodeDAO.h"
#import "ShapeCode.h"
#import "ReportGeneratorTableViewController.h"
#import "Timer.h"
#import "WasteCalculator.h"
#import "WastePlotValidator.h"
#import "AssessmentMethodCode.h"
#import "PlotSampleGenerator.h"
#import "UIColor+WasteColor.h"
#import "PileValueTableViewController.h"
#import "PileShapeCode+CoreDataClass.h"
#import "SpeciesPercentViewController.h"

@class UIAlertView;

@interface PilePlotViewController ()
@property (nonatomic) PileShapeCode* currentpile;
@end

@implementation PilePlotViewController

@synthesize wasteBlock, wastePlot, wastePiles;
@synthesize wastePieces;
@synthesize pileSizeArray;
@synthesize pileShapeArray;
@synthesize versionLabel;

static NSString *const SELECT_SHAPE_CODE = @"Select Shape Code";
static NSString *const DEFAULT_PRED_SAMPLE = @"12";
static NSString *const DEFAULT_MEASURE_SAMPLE = @"4";

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
    self.pileSizeArray = [[[CodeDAO sharedInstance] getPlotSizeCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    sort = [[NSSortDescriptor alloc ] initWithKey:@"shapeCode" ascending:YES];
    self.pileShapeArray = [[[CodeDAO sharedInstance] getShapeCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //set up UIScrollView
    [scrollView setScrollEnabled:YES];
    [scrollView setPagingEnabled:YES];
    [scrollView setContentSize:CGSizeMake(1024, 1100)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    
    self.surveyDate.inputView = self.datePicker;
    self.surveyDate.tag = 6;
    [self.surveyDate setDelegate:self];
    
    // SIZE PICKER - field locked, if field unlocked, this works (without the support for same row select)
    UIPickerView *sizePicker = [[UIPickerView alloc] init];
    sizePicker.dataSource = self;
    sizePicker.delegate = self;
    sizePicker.tag = 1;
    self.sizeField.inputView = sizePicker;
    
    // SHAPE PICKER
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
    [self.measurePercent setDelegate:self];
    
    // POPULATING
    //
    [self populateFromObject];
    
    //if ([self.wasteBlock.userCreated intValue] == 1){
        // toggle some UI for user created cut block
        
    //self.headerView.userCreatedBlock = @"YES";
    [self.measurePercent setEnabled:YES];
    self.strip.enabled = YES;
    self.baseline.enabled = YES;
    self.surveyorLicence.enabled = YES;
    self.returnField.enabled = YES;
    [self.surveyDate setEnabled:YES];
    [self.shape setEnabled:YES];
    [self.strip setEnabled:YES];
    [self.baseline setEnabled:YES];
    [self.surveyorLicence setEnabled:YES];
    [self.returnField setEnabled:YES];
    
    [self.sizeField setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    self.sawlog.text = @"6.5%";
    self.greenGrade.text = @"1.0%";
    self.dryGrade.text = @"0.5%";
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
        ShapeCode *sc = [self.pileShapeArray objectAtIndex:[self.shapePicker selectedRowInComponent:0]];
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

- (void) sortPiles
{
    self.wastePiles = [self.wastePlot.plotPile allObjects];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"pileId" ascending:YES];
    self.wastePiles = [self.wastePiles sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.toolbarHidden = NO;
    [super viewWillAppear:animated];
    
    [[Timer sharedManager] setCurrentVC:self];
    //int total = [self.currentEditingPile.cePercent intValue] + [self.currentEditingPile.hePercent intValue] + [self.currentEditingPile.spPercent intValue] +
    //[self.currentEditingPile.baPercent intValue] + [self.currentEditingPile.coPercent intValue] + [self.currentEditingPile.loPercent intValue] + [self.currentEditingPile.biPercent intValue];
    if(self.currentEditingPile){
        //if (total < 100 ) {
        NSString *nextProperty = [self getNextMissingProperty:self.currentEditingPile currentProperty:self.currentEditingPileElement];
        if(![nextProperty isEqualToString:@""]){
            PileValueTableViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PileLookupPickerViewControllerSID"];
            pvc.wastePile = self.currentEditingPile;
            pvc.wasteBlock = self.wasteBlock;
            pvc.propertyName = nextProperty;
            pvc.pileVC = self;
            pvc.isLoopingProperty = YES;
            [self.navigationController pushViewController:pvc animated:YES];
       // }
        }
    }
    
    int row;
    
    // update shape picker selected row
    row = 0;
    for (ShapeCode *sc in self.pileShapeArray) {
        if([self.shape.text isEqualToString:sc.shapeCode]){
            [self.shapePicker selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }
    
    [self sortPiles];
    [self.pileTableView reloadData];
    [self totalPileValue];
    [self calculatePileAreaAndVolume:self.currentEditingPile];
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        //[WasteCalculator calculateEFWStat:self.wasteBlock];
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

// SAVE FROM VIEW TO OBJECT
- (void)saveData{
    
    NSLog(@"SAVE PILE PLOT");
    
    self.wastePlot.plotNumber = [[NSNumber alloc] initWithInt:[self.plotNumber.text intValue]];
    self.wastePlot.baseline = self.baseline.text;
    
    for (PlotSizeCode* psc in self.pileSizeArray){
        if ([psc.plotSizeCode isEqualToString:[self codeFromText:self.sizeField.text ]] ){
            self.wastePlot.plotSizeCode = psc;
            break;
        }
    }
    
    self.wastePlot.surveyedMeasurePercent = [[NSNumber alloc] initWithFloat:[self.measurePercent.text intValue]];
    
    for (ShapeCode* sc in self.pileShapeArray){
        if ([sc.shapeCode isEqualToString:[self codeFromText:self.shape.text]] ){
            self.wastePlot.plotShapeCode = sc;
            break;
        }
    }
    
    self.wastePlot.returnNumber = self.returnField.text;
    self.wastePlot.strip = [[NSNumber alloc] initWithFloat:[self.strip.text intValue]];
    self.wastePlot.certificateNumber = self.surveyorLicence.text;
    self.wastePlot.surveyorName = self.residueSurveyor.text;
    self.wastePlot.weather = self.weather.text;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM-dd-yyyy"];
    self.wastePlot.surveyDate = [dateFormat dateFromString:self.surveyDate.text];
    self.wastePlot.assistant = self.assistant.text;
    self.wastePlot.notes = self.note.text;
    
    if([self.perdictionSample.text isEqualToString:DEFAULT_PRED_SAMPLE]){
        self.wastePlot.plotStratum.orgPredictionPlot = [[NSNumber alloc] initWithFloat:[self.perdictionSample.text intValue]];
    }else{
        self.wastePlot.plotStratum.predictionPlot = [[NSNumber alloc] initWithFloat:[self.perdictionSample.text intValue]];
    }
    if([self.measureSamples.text isEqualToString:DEFAULT_MEASURE_SAMPLE]){
        self.wastePlot.plotStratum.orgMeasurePlot = [[NSNumber alloc] initWithFloat:[self.measureSamples.text intValue]];
    }else{
        self.wastePlot.plotStratum.measurePlot = [[NSNumber alloc] initWithFloat:[self.measureSamples.text intValue]];
    }
    
    self.wastePlot.sawlogPercent = [NSDecimalNumber decimalNumberWithString:self.sawlog.text];
    self.wastePlot.greenGradePercent = [NSDecimalNumber decimalNumberWithString:self.greenGrade.text];
    self.wastePlot.dryGradePercent = [NSDecimalNumber decimalNumberWithString:self.dryGrade.text];
    
    NSError *error;
    
    // save the whole cut block
    NSManagedObjectContext *context = [self managedObjectContext];
    [context save:&error];
    
    if( error != nil){
        NSLog(@" Error when saving waste plot into Core Data: %@", error);
    }
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
- (void)savePile:(id)sender{
    
    if([self validateCheckMeasure] && [self validatePlotNumberForDuplicate]){
        
        [self saveData];
        
        NSString *title = NSLocalizedString(@"Save Pile", nil);
        NSString *message = NSLocalizedString(@"", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        alert.tag = SavePileEnum;
        [alert show];
    }
    
}

- (IBAction)addPile:(id)sender{
    [self saveData];
    BOOL isValid = YES;
    if(!([self.plotNumber.text isEqualToString:@""] && [self.measurePercent.text isEqualToString:@""] && [self.baseline.text isEqualToString:@""] && [self.shape.text isEqualToString:@""] && [self.strip.text isEqualToString:@""] && [self.sizeField.text isEqualToString:@""] && [self.returnField.text isEqualToString:@""] && [self.surveyorLicence.text isEqualToString:@""] && [self.residueSurveyor.text isEqualToString:@""] && [self.perdictionSample.text isEqualToString:@""] && [self.measureSamples.text isEqualToString:@""] && [self.weather.text isEqualToString:@""] &&[self.surveyDate.text isEqualToString:@""] && [self.assistant.text isEqualToString:@""] && [self.sampleInterval.text isEqualToString:@""] && [self.totalPile.text isEqualToString:@""] && [self.pileArea.text isEqualToString:@""] && [self.estPileVolume.text isEqualToString:@""] && [self.pileShapeVolume.text isEqualToString:@""])){
    if([self.wastePlot.plotStratum.n1sample isEqualToString:@""] ){
        if([self.measureSamples.text isEqualToString:@""] || [self.perdictionSample.text isEqualToString:@""]){
            isValid = NO;
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:@"Missing Required Field"
                                                                                  message:@"Please enter Prediction Sample and Measure Sample and try again."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }else if([self.measureSamples.text intValue] > [self.perdictionSample.text intValue]){
            isValid = NO;
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:@"Invalid Value"
                                                                                  message:@"Measure Sample can't be greater than Prediction Sample. Please enter valid value and try again."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }else{
            // check if the user enter value against the default value
            if(( ![DEFAULT_MEASURE_SAMPLE isEqualToString:@""] && ![self.measureSamples.text isEqualToString:DEFAULT_MEASURE_SAMPLE]) || (![DEFAULT_PRED_SAMPLE isEqualToString:@""] && ![self.perdictionSample.text isEqualToString:DEFAULT_PRED_SAMPLE])){
                isValid = NO;
                UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:@"Non-standard Value"
                                                                                      message:@"Prediction Sample and/or Measure Sample are non-standard values, Accept?"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    //[PlotSampleGenerator generatePlotSample2:self.wastePlot.plotStratum];
                    [self.perdictionSample setEnabled:NO];
                    [self.measureSamples setEnabled:NO];
                    [self.perdictionSample setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
                    [self.measureSamples setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
                    [self promptForPileEstimate:sender];
                }];
                UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
                
                [confirmAlert addAction:yesAction];
                [confirmAlert addAction:noAction];
                [self presentViewController:confirmAlert animated:YES completion:nil];
            }else{
                //generate sample
                //[PlotSampleGenerator generatePlotSample2:self.wastePlot.plotStratum];
                //lock down the prediction plot and measure plot fields
                [self.perdictionSample setEnabled:NO];
                [self.measureSamples setEnabled:NO];
                [self.perdictionSample setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
                [self.measureSamples setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
            }
        }
    }
    
    if (isValid){
        [self promptForPileEstimate:sender];
    }
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Add Pile"
                                                                       message:@"Please complete header information before adding pile."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    /*if(!([self.plotNumber.text isEqualToString:@""] && [self.measurePercent.text isEqualToString:@""] && [self.baseline.text isEqualToString:@""] && [self.shape.text isEqualToString:@""] && [self.strip.text isEqualToString:@""] && [self.sizeField.text isEqualToString:@""] && [self.returnField.text isEqualToString:@""] && [self.surveyorLicence.text isEqualToString:@""] && [self.residueSurveyor.text isEqualToString:@""] && [self.perdictionSample.text isEqualToString:@""] && [self.measureSamples.text isEqualToString:@""] && [self.weather.text isEqualToString:@""] &&[self.surveyDate.text isEqualToString:@""] && [self.assistant.text isEqualToString:@""] && [self.sampleInterval.text isEqualToString:@""] && [self.totalPile.text isEqualToString:@""] && [self.pileArea.text isEqualToString:@""] && [self.estPileVolume.text isEqualToString:@""] && [self.pileShapeVolume.text isEqualToString:@""])){
    
        [self.perdictionSample setEnabled:NO];
        [self.measureSamples setEnabled:NO];
        [self.perdictionSample setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        [self.measureSamples setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
        if([self.wastePlot.plotStratum.n1sample isEqualToString:@""]){
        [PlotSampleGenerator generatePlotSample2:self.wastePlot.plotStratum];
        }
        [self promptForPileEstimate:sender];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Add Pile"
                                                                       message:@"Please complete header information before adding pile."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }*/
}

-(void)promptForPileEstimate:(id)sender{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Pile Estimate"
                                                                   message:@"Please enter your estimate for:\n- Length\n- Width\n- Height"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Pile Number", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Pile Number", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 3;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Length", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Length", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 3;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Width", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Width", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 3;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Height", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Height", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 3;
        textField.delegate           = self;
    }];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         UIAlertController *alertt = [UIAlertController alertControllerWithTitle:SELECT_SHAPE_CODE message:@"" preferredStyle:UIAlertControllerStyleAlert];
                                                         int i = 0;
                                                         for(PileShapeCode *psc in [[CodeDAO sharedInstance] getPileShapeCodeList]){
                                                             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:psc.desc style:UIAlertActionStyleDefault
                                                                                                                   handler:^(UIAlertAction * action) {
                                                                                                                       [self didSelectRowInAlertController:i];
                                                                                                                       [self validatePileEstimate:alert pile:self.currentpile];
                                                                                                                       [self presentViewController:alert animated:YES completion:nil];
                                                                                                                   }];
                                                             [alertt addAction:defaultAction];
                                                             i++;
                                                         }
                                                         UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                                                              handler:^(UIAlertAction * action) {
                                                                                                                  [self presentViewController:alert animated:YES completion:nil];
                                                                                                              }];
                                                         [alertt addAction:cancelAction];
                                                         [self presentViewController:alertt animated:YES completion:nil];
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/*- (IBAction) modifyPile:(id) sender {
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
}*/

-(void)didSelectRowInAlertController:(NSInteger)row {
    NSArray *text = [[CodeDAO sharedInstance] getPileShapeCodeList];
    self.currentpile = [text objectAtIndex:row ];

}
#pragma mark - UITextField
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    BOOL result = YES;
    if (textField == self.measurePercent){
        
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
    
    if (textField == self.measurePercent){
        
        return [self validateCheckMeasure];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
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
    } /*else if (textField == self.numberOfDuplicatePieces) {
        if ( ![self validInputNumbersOnly:theString] ) {
            return NO;
        }
    }*/
    
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
            
        default:
            return NO; // NOT EDITABLE
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.measurePercent){
        
        //save the change first
        [self saveData];
        
        //if esimate volume change, need to re-calculate the check volume
        /*BOOL pieceDidChange = NO;
        if (textField == self.totalEstimateVolume){
            for(WastePiece *wp in self.wastePieces){
                //if ([wp.pieceNumber rangeOfString:@"C"].location != NSNotFound){
                [WasteCalculator calculatePieceStat:wp wasteStratum:self.wastePlot.plotStratum];
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
        }*/
    }else if(textField == self.surveyDate){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM-dd-yyyy"];
        
        textField.text = [formatter stringFromDate:self.datePicker.date];
        [textField resignFirstResponder];
    }else if(textField == self.plotNumber){
        if(self.wastePlot.plotStratum.stratumBlock.ratioSamplingEnabled){
            [self saveData];
        }
    }
    _activeTF = nil;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    
    _activeTF = textField;
    if(textField == self.surveyDate){
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM-dd-yyyy"];
        if(textField == self.surveyDate){
            [self.datePicker setDate:([dateFormat dateFromString:self.surveyDate.text] ? [dateFormat dateFromString:self.surveyDate.text] : [NSDate date])];
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
        return self.pileSizeArray.count;
    
    else if(pickerView.tag == 2)
        return self.pileShapeArray.count;
    
    else
        return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (pickerView.tag == 1)
        return [NSString stringWithFormat:@"%@ - %@",[self.pileSizeArray[row] valueForKey:@"plotSizeCode"], [self.pileSizeArray[row] valueForKey:@"desc"]];
    
    else if(pickerView.tag == 2)
        return [NSString stringWithFormat:@"%@ - %@",[self.pileShapeArray[row] valueForKey:@"shapeCode"],[self.pileShapeArray[row] valueForKey:@"desc"]];
    
    else
        return nil;
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (pickerView.tag == 1){
        self.sizeField.text = [NSString stringWithFormat:@"%@ - %@",[self.pileSizeArray[row] valueForKey:@"plotSizeCode"], [self.pileSizeArray[row] valueForKey:@"desc"]];
        [self.sizeField resignFirstResponder];
        
    }else if(pickerView.tag == 2){
        self.shape.text = [NSString stringWithFormat:@"%@ - %@",[self.pileShapeArray[row] valueForKey:@"shapeCode"],[self.pileShapeArray[row] valueForKey:@"desc"]];
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
        pc_value = self.measurePercent.text;
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
        alert.tag = ValidateEnum;
        [alert show];
        return NO;
    }
}

- (BOOL)validatePileEstimate:(UIAlertController*)alert pile:(PileShapeCode*)currentPile{
    NSDecimalNumber* length = nil;
    NSDecimalNumber* width = nil;
    NSDecimalNumber* height = nil;
    NSNumber* pn = nil;
    NSString* length_str = @"";
    NSString* width_str = @"";
    NSString* height_str = @"";
    NSString* pn_str = @"";
    NSString* code = @"";
    
    code = self.currentpile.pileShapeCode;
    for(UITextField* tf in alert.textFields){
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Length", nil)]){
            length = [[NSDecimalNumber alloc] initWithString:tf.text];
            length_str =tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Width", nil)]){
            width = [[NSDecimalNumber alloc] initWithString:tf.text];
            width_str = tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Height", nil)]){
            height = [[NSDecimalNumber alloc] initWithString:tf.text];
            height_str = tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Pile Number", nil)]){
            pn = [[NSDecimalNumber alloc] initWithString:tf.text];
            pn_str = tf.text;
        }
    }
    BOOL duplicatePile = NO;
    if (pn){
        for(WastePile* wp in wastePlot.plotPile){
            if( [wp.pileNumber integerValue] == [pn integerValue]){
                duplicatePile = YES;
                break;
            }
        }
    }
    
    if([pn_str isEqualToString:@""] || [length_str isEqualToString:@""] || [width_str isEqualToString:@""] || [height_str isEqualToString:@""]){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                              message:@"Please enter Pile Number, Length, Width and Height."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self presentViewController:alert animated:YES completion:nil];
                                                         }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }else if(duplicatePile){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Duplicate Pile Number", nil)
                                                                              message:@"Duplicate pile number, Select new pile number before proceeding."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self presentViewController:alert animated:YES completion:nil];
                                                         }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }/*else if([wastePlot.plotStratum.predictionPlot integerValue] != 0 && [pn integerValue] > [wastePlot.plotStratum.predictionPlot integerValue]){
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Pile Number Invalid", nil)
                                                                                  message:[NSString stringWithFormat:@"Pile number exceeds acceptable range. Please select number between 1 and Prediction Sample (%ld).", [wastePlot.plotStratum.predictionPlot integerValue]]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self presentViewController:alert animated:YES completion:nil];
                                                             }];
            
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
    }else  if([wastePlot.plotStratum.orgPredictionPlot integerValue] != 0 && [pn integerValue] > [wastePlot.plotStratum.orgPredictionPlot integerValue]){
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Pile Number Invalid", nil)
                                                                                  message:[NSString stringWithFormat:@"Pile number exceeds acceptable range. Please select number between 1 and Prediction Sample (%ld).", [wastePlot.plotStratum.orgPredictionPlot integerValue]]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self presentViewController:alert animated:YES completion:nil];
                                                             }];
            
            [warningAlert addAction:okAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
    }*/else{
            if([pn integerValue]<1 || [pn intValue] > 1000) {
                UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                      message:@"Pile number should be from 1 to 999"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [self presentViewController:alert animated:YES completion:nil];
                                                                 }];
                [warningAlert addAction:okAction];
                [self presentViewController:warningAlert animated:YES completion:nil];
            }
            if([length floatValue] < 0.1 || [length floatValue] > 99.9) {
                UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                      message:@"Length should be from 0.1 to 99.9"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [self presentViewController:alert animated:YES completion:nil];
                                                                 }];
                [warningAlert addAction:okAction];
                [self presentViewController:warningAlert animated:YES completion:nil];
            }
            if([width floatValue] < 0.1 || [width floatValue] > 99.9) {
                UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                      message:@"Width should be from 0.1 to 99.9"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [self presentViewController:alert animated:YES completion:nil];
                                                                 }];
                [warningAlert addAction:okAction];
                [self presentViewController:warningAlert animated:YES completion:nil];
            }
            if([height floatValue] < 0.1 || [height floatValue] > 99.9) {
                UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                      message:@"Height should be from 0.1 to 99.9"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [self presentViewController:alert animated:YES completion:nil];
                                                                 }];
                [warningAlert addAction:okAction];
                [self presentViewController:warningAlert animated:YES completion:nil];
            }
        UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Estimation", nil)
                                                                              message:[NSString stringWithFormat:@"Accept volume estimates? \n Pile Number %d \n Length = %.2f \n Width = %.2f \n Height = %.2f \n Shape Code = %@",[pn intValue], [length floatValue], [width floatValue], [height floatValue], [code uppercaseString]]
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //[self addRatioPlotAndNavigate:gv dryVolume:dv plotNumber:pn];
                                                              self.currentEditingPile = [self addWastePileByPlot:self.wastePlot editPileNumber:@"" pileNumber:[pn integerValue] length:length  width:width height:height code:code];
                                                              self.wastePiles = [self.wastePlot.plotPile allObjects];
                                                              [self calculatePileAreaAndVolume:self.currentEditingPile];
                                                              [self sortPiles];
                                                              [self.pileTableView reloadData];
                                                              [self totalPileValue];
                                                              //scroll to the bottom to the newly added piece
                                                              NSIndexPath* ipath = [NSIndexPath indexPathForRow:[self.wastePiles count] - 1 inSection:0];
                                                              [self.pileTableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == ValidateEnum){
        //validateion alertview
        if (alertView.cancelButtonIndex == buttonIndex) {
            
        }else{
            //if the user click "continue" then let user to back to screen
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if(alertView.tag == SavePileEnum){
        //NSLog(@"Save Plot - ok click");
    }else{
        //other alertview
        /*NSString *targetPieceNumber =[(WastePiece *)[self.wastePieces objectAtIndex:alertView.tag] pieceNumber];
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
        }*/
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
    return [self.wastePiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellStr = @"";
    WastePile *currentPileCell = [self.wastePiles objectAtIndex:indexPath.row];
    
    if(currentPileCell.pileId != nil){
        cellStr = @"NewPileTableCell";
    }else{
        cellStr = @"EditPileTableCell";
    }
    
    
    PileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if( [cell isKindOfClass:[PileEditTableViewCell class]]){
        ((PileEditTableViewCell *) cell).pileView = self;
    }
    //cell.statusButton.tag = indexPath.row;
    
    [cell bindCell:currentPileCell wasteBlock:self.wasteBlock userCreatedBlock:([self.wasteBlock.userCreated intValue] == 1)];

    return cell;
}

- (void) populateFromObject{
    
    
    NSString *title = self.wastePlot.plotNumber ? [[NSString alloc] initWithFormat:@"(IFOR 204) Plot - %@", [self.wastePlot.plotNumber stringValue]] : @"";
    
    [[self navigationItem] setTitle:title];
    
    // FILL FROM OBJECT TO VIEW
    self.plotNumber.text = self.wastePlot.plotNumber ? [[NSString alloc] initWithFormat:@"%d", [self.wastePlot.plotNumber intValue]] : @"";
    self.baseline.text = self.wastePlot.baseline ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.baseline] : @"";
    
    //size is pulling from the stratum
    self.sizeField.text = self.wastePlot.plotStratum.stratumPlotSizeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wastePlot.plotStratum.stratumPlotSizeCode.plotSizeCode, self.wastePlot.plotStratum.stratumPlotSizeCode.desc] : @"";
    self.measurePercent.text = self.wastePlot.surveyedMeasurePercent ? [[NSString alloc] initWithFormat:@"%d", [self.wastePlot.surveyedMeasurePercent intValue]] : @"";
    self.shape.text = self.wastePlot.plotShapeCode.shapeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wastePlot.plotShapeCode.shapeCode, self.wastePlot.plotShapeCode.desc] : @"";
    self.returnField.text = self.wastePlot.returnNumber ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.returnNumber] : @"";
    self.strip.text = self.wastePlot.strip ? [[NSString alloc] initWithFormat:@"%d", [self.wastePlot.strip intValue]] : @"";
    self.surveyorLicence.text = self.wastePlot.certificateNumber ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.certificateNumber] : @"";
    self.residueSurveyor.text = self.wastePlot.surveyorName ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.surveyorName] : @"";
    self.weather.text = self.wastePlot.weather ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.weather] : @"";
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM-dd-yyyy"];
    self.surveyDate.text = [[NSString alloc] initWithFormat:@"%@", self.wastePlot.surveyDate ? [dateFormat stringFromDate:self.wastePlot.surveyDate] : [dateFormat stringFromDate:[NSDate date]]];

    self.perdictionSample.text = self.wastePlot.plotStratum.predictionPlot ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.plotStratum.predictionPlot] : DEFAULT_PRED_SAMPLE;
    self.measureSamples.text = self.wastePlot.plotStratum.measurePlot ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.plotStratum.measurePlot] : DEFAULT_MEASURE_SAMPLE;
    self.assistant.text = self.wastePlot.assistant ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.assistant] : @"";
    self.note.text = self.wastePlot.notes ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.notes] : @"";
    self.sawlog.text = self.wastePlot.sawlogPercent ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.sawlogPercent] : @"6.5%";
    self.greenGrade.text = self.wastePlot.greenGradePercent ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.greenGradePercent] : @"1.0%";
    self.dryGrade.text = self.wastePlot.dryGradePercent ? [[NSString alloc] initWithFormat:@"%@", self.wastePlot.dryGradePercent] : @"0.5%";
    // Calculation for sample interval , total pile, pile area , est pilevol, and mesurepile shape vol    [self updateCheckTotalPercent];
    [self totalPileValue];
    self.wastePiles = [self.wastePlot.plotPile allObjects];
    
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        //[WasteCalculator calculateEFWStat:self.wasteBlock];
        [self.efwFooterView setPlotViewValue:self.wastePlot];
    }else{
        [self.footerStatView setViewValue:self.wastePlot];
        [self.footerStatView setDisplayFor:self.wastePlot.plotStratum.stratumAssessmentMethodCode.assessmentMethodCode screenName:@"plot"];
    }
}

- (void) totalPileValue{
    NSInteger sInterval = 0;
    NSInteger totalpile = [self.wastePiles count];
    self.totalPile.text = [NSString stringWithFormat:@"%ld", (long)totalpile];
    //int ps = self.perdictionSample.text.intValue;
    sInterval = self.totalPile.text.intValue/self.perdictionSample.text.intValue;
    self.sampleInterval.text = [NSString stringWithFormat:@"%ld", (long)sInterval];
    NSDecimalNumber *sumOfPileArea;
    for(WastePile *wp in self.wastePiles){
        sumOfPileArea = [[NSDecimalNumber alloc] initWithDouble:([sumOfPileArea doubleValue] + [wp.pileArea doubleValue]) ];
    }
    self.pileArea.text = [NSString stringWithFormat:@"%@", [[NSDecimalNumber alloc] initWithDouble:([sumOfPileArea doubleValue] /10000) ]];
    NSDecimalNumber *sumOfPileVolume;
    for(WastePile *wpv in self.wastePiles){
        sumOfPileVolume = [[NSDecimalNumber alloc] initWithDouble:([sumOfPileVolume doubleValue] + [wpv.pileVolume doubleValue]) ];
    }
    self.estPileVolume.text = [NSString stringWithFormat:@"%@", sumOfPileVolume];
}

-(void) calculatePileAreaAndVolume:(WastePile *)wastePile {
    
    wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:([wastePile.length doubleValue] * [wastePile.width doubleValue])];
    if([wastePile.pilePileShapeCode.pileShapeCode isEqual:@""]){
        wastePile.pileVolume = 0;
    }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"CN"]) {
        wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:(([wastePile.length doubleValue] / 2) * ([wastePile.length doubleValue] / 2) * 3.14159) * ([wastePile.height doubleValue]/3)];
    }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"PAR"]) {
        wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:((3.14159 * [wastePile.height doubleValue] * ([wastePile.width doubleValue] * [wastePile.width doubleValue]))/8)];
    }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"HC"]) {
        wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:((3.14159 * [wastePile.width doubleValue] * [wastePile.length doubleValue] * [wastePile.height doubleValue])/4)];
    } else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"HE"]) {
        wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:((3.14159 * [wastePile.width doubleValue] * [wastePile.length doubleValue] * [wastePile.height doubleValue])/6)];
    } else {
        wastePile.pileVolume = [[NSDecimalNumber alloc] initWithInt:-999];
    }
}

-(WastePile *) addWastePileByPlot:(WastePlot *)targetWastePlot editPileNumber:(NSString *)editiPileNumber pileNumber:(NSInteger)pileNumber length:(NSDecimalNumber*)length width:(NSDecimalNumber*)width height:(NSDecimalNumber*)height code:(NSString*)code{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePile *newWp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePile" inManagedObjectContext:context];
    
    if( [editiPileNumber isEqualToString:@""]){
        // new piece
        // - found the largest number in the piece and plus one for new piece
        int i = 0;
        NSArray *piles =[targetWastePlot.plotPile allObjects];
        for(WastePile *wp in piles){
            if ([wp.pileNumber rangeOfString:@"C"].location == NSNotFound){
                if( [wp.pileNumber integerValue] > i){
                    i = [wp.pileNumber intValue];
                }
            }
        }
        
        newWp.pileNumber = [[NSNumber numberWithInt:(i + 1)] stringValue];
        newWp.pileId = [NSNumber numberWithInt:(i + 1)];
        newWp.length = length;
        newWp.width = width;
        newWp.height = height;
        newWp.pilePileShapeCode = self.currentpile;
        
    }else{
        // edit piece
        // - copy the value from the original piece to the new piece
        NSArray *piles =[targetWastePlot.plotPile allObjects];
        WastePile *originalPile = nil;
        for(WastePile *wp in piles){
            if([wp.pileNumber isEqualToString:editiPileNumber]){
                originalPile = wp;
                break;
            }
        }
        
        unsigned int numberOfProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([originalPile class], &numberOfProperties);
        
        for (NSUInteger i = 0; i < numberOfProperties; i++)
        {
            objc_property_t property = propertyArray[i];
            NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
            
            [newWp setValue:[originalPile valueForKey:name] forKey:name];
            
            //NSLog(@"Transfer property: %@, value: %@", name, [tmDto valueForKey:name]);
        }
        free(propertyArray);
        
        // - add "C" in the piece number
        newWp.pileNumber = [newWp.pileNumber stringByAppendingString:@"C"];
        
        // - plus 1 to the sort number of the original value
        newWp.pileId = [NSNumber numberWithInt:[newWp.pileId intValue]+ 1];
        
    }
    
    [targetWastePlot addPlotPileObject:newWp];
    
    return newWp;
}

-(void) deletePileFromPlot:(WastePile *)targetWastePile targetWastePlot:(WastePlot *)targetWastePlot{
    
    //1 - remove the piles from plot
    NSMutableSet *tempPiles = [NSMutableSet setWithSet:targetWastePlot.plotPile];
    [tempPiles removeObject:targetWastePile];
    targetWastePlot.plotPile= tempPiles;
    
    // 2 - delete the piece from core data
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:targetWastePile];
    
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
        pc_value = self.measurePercent.text;
    }
    
    if( [pc_value intValue ]> 100 ){
        errorMessage =[NSString stringWithFormat:@"%@ %@ cannot be greater than 100%%.", errorMessage, pc_label];
        isfatal = YES;
    }else if( [pc_value intValue ] == 0 ){
        errorMessage =[NSString stringWithFormat:@"%@ %@ cannot be 0%%.", errorMessage, pc_label];
        isfatal = YES;
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
        
        validateAlert.tag = ValidateEnum;
        [validateAlert show];
        return NO;
    }else{
        return YES;
    }
}

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

-(NSMutableArray*) getNewPileProperties:(NSString*) stratumTypeCode pile:(WastePile*)pile{
    NSMutableArray *properties = [[NSMutableArray alloc] init];
    
        [properties addObject:@"measuredLength"];
        [properties addObject:@"measuredWidth"];
        [properties addObject:@"measuredHeight"];
        //[properties addObject:@"cePercent"];
        //[properties addObject:@"hePercent"];
        //[properties addObject:@"spPercent"];
        //[properties addObject:@"baPercent"];
        //[properties addObject:@"coPercent"];
        //[properties addObject:@"loPercent"];
        //[properties addObject:@"biPercent"];
    
    return properties;
}

-(void) removeCurrentPile{
    self.currentEditingPileElement = @"";
    self.currentEditingPile = nil;
}

-(void) updateCurrentPileProperty:(WastePile*)wp property:(NSString*)property{
    self.currentEditingPile = wp;
    self.currentEditingPileElement = property;
}

-(NSString*)getNextMissingProperty:(WastePile*)wp currentProperty:(NSString*)currentProperty{
    NSMutableArray *properties = [self getNewPileProperties:nil pile:wp];
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
