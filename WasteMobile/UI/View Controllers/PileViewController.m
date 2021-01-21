//
//  PileViewController.m
//  iForWaste
//
//  Created by Sweta Kutty on 2019-03-04.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "PileViewController.h"
#import "BlockViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "WasteBlock.h"
#import "WastePile+CoreDataClass.h"
#import "WasteStratum.h"
#import "PileTableViewCell.h"
#import "PileEditTableViewCell.h"
#import "PlotSizeCode.h"
#import "CodeDAO.h"
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
#import "StratumPile+CoreDataClass.h"
#import "AggregateCutblock+CoreDataClass.h"

@class UIAlertView;

@interface PileViewController ()
@property (nonatomic) PileShapeCode* currentpile;
@end

@implementation PileViewController

@synthesize wasteBlock, wasteStratum, wastePiles, strpile, aggregatecutblock;
@synthesize pileSizeArray;
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
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"PlotSizeCode" ascending:YES];
    self.pileSizeArray = [[[CodeDAO sharedInstance] getPlotSizeCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
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
    self.headerView.displayMode = [wasteBlock.ratioSamplingEnabled stringValue];
    
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
    
    // KEYBOARD DISMISSAL
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tap];
    
    // POPULATING
    //
    [self populateFromObject];
    [self.surveyDate setEnabled:YES];
    
    [self.sizeField setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    // Populate version number
    [versionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteVersionNumber"]];
}

// enable multiple gesture recognizers, otherwise same row select wont detect taps
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // enable multiple gesture recognition
    return true;
}

- (void) sortPiles
{

    self.wastePiles = [self.strpile.pileData allObjects];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"pileId" ascending:YES];
    self.wastePiles = [self.wastePiles sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.toolbarHidden = NO;
    [super viewWillAppear:animated];
    
    [[Timer sharedManager] setCurrentVC:self];
    
    if(self.currentEditingPile){
        NSString *nextProperty = [self getNextMissingProperty:self.currentEditingPile currentProperty:self.currentEditingPileElement];
        if(![nextProperty isEqualToString:@""]){
            PileValueTableViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PileLookupPickerViewControllerSID"];
            pvc.wastePile = self.currentEditingPile;
            pvc.wasteBlock = self.wasteBlock;
            pvc.propertyName = nextProperty;
            pvc.pileVC = self;
            pvc.isLoopingProperty = YES;
            [self.navigationController pushViewController:pvc animated:YES];
        }
    }

    if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        [self.addPileButton setHidden:NO];
    }
    [self sortPiles];
    [self.pileTableView reloadData];

    [self calculatePileAreaAndVolume:self.currentEditingPile srsOrRatio:[self.wasteBlock.ratioSamplingEnabled intValue]];
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
            [self.efwFooterView setPileViewValue:self.strpile];
        }else{
            [WasteCalculator calculateEFWStat:self.wasteBlock];
            [self.efwFooterView setPileViewValue:self.aggregatecutblock.aggPile];
        }
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
    
    NSLog(@"SAVE PILE");

    self.strpile.surveyorName = self.residueSurveyor.text;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM-dd-yyyy"];
    self.strpile.surveyDate = [dateFormat dateFromString:self.surveyDate.text];
    self.strpile.notes = self.note.text;
    
    NSError *error;
    
    // save the whole cut block
    NSManagedObjectContext *context = [self managedObjectContext];
    [context save:&error];
    
    if( error != nil){
        NSLog(@" Error when saving waste pile into Core Data: %@", error);
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

    if ( [segue.identifier isEqualToString:@"reportFromPileSegue"]){
        
        // our navigation controller has many segues, or views, but we need our ReportScreen
        ReportGeneratorTableViewController *reportGeneratorTableVC = (ReportGeneratorTableViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        
        reportGeneratorTableVC.wasteBlock = self.wasteBlock;
        
        //reportGeneratorTableVC.tallySwitchEnabled = YES; // plotTallySwitch is not initialized (maybe set an extra switch for reportGen to read)
    }
}

// SCREEN METHODS
//
#pragma mark - IBActions
- (void)savePile:(id)sender{
    
        
    [self saveData];
    
    NSString *title = NSLocalizedString(@"Save Pile", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    alert.tag = SavePileEnum;
    [alert show];
    
    
}

- (IBAction)addPile:(id)sender{
    [self saveData];
    BOOL isValid = YES;
    
    if (isValid){
        [self promptForPileEstimate:sender];
    }
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
        textField.tag                = 9;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Length", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Length", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 8;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Width", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Width", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 8;
        textField.delegate           = self;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Height", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Height", nil);
        textField.clearButtonMode    = UITextFieldViewModeAlways;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.tag                = 8;
        textField.delegate           = self;
    }];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         UIAlertController *alertt = [UIAlertController alertControllerWithTitle:@"Shape Code" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                                                         int i = 0;
                                                         for(PileShapeCode *psc in [[CodeDAO sharedInstance] getPileShapeCodeList]){
                                                             NSString *optionValue = [NSString stringWithFormat:@"%@%@%@", psc.pileShapeCode, @" - ", psc.desc];
                                                             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:optionValue style:UIAlertActionStyleDefault
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

-(void)didSelectRowInAlertController:(NSInteger)row {
    NSArray *text = [[CodeDAO sharedInstance] getPileShapeCodeList];
    self.currentpile = [text objectAtIndex:row ];

}
#pragma mark - UITextField
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    BOOL result = YES;

    return result;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
   
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // INPUT VALIDATION
    //
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str appendString:string];
    NSString *theString = str;
    
    // ALPHABET ONLY
    if( textField==self.residueSurveyor){
        if( ![self validInputAlphabetOnly:theString] ){
            return NO;
        }
        
        // Numbers Only
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *charSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];

    switch (textField.tag) {
        case 1:
            return (newLength > 256) ? NO : YES;
            break;
            
        case 2:
            return (newLength > 100) ? NO : YES;
            break;
            
        case 3:
        case 4:
            for (int i = 0; i < [string length]; i++) {
                unichar c = [string characterAtIndex:i];
                if ([myCharSet characterIsMember:c]) {
                    return (newLength > 3) ? NO : YES;
                }
            }
            return [string isEqualToString:@""];
            break;
        case 5:
            return (newLength > 10) ? NO : YES;
            break;
        case 6:
            //skip
            return YES;
            
        case 7:
            return (newLength > 2) ? NO : YES;
            break;
        case 8:
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
                    }
                    return YES;
                }
            }
            break;
        case 9:
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
    if(textField == self.surveyDate){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM-dd-yyyy"];
        
        textField.text = [formatter stringFromDate:self.datePicker.date];
        [textField resignFirstResponder];
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
    
    else
        return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (pickerView.tag == 1)
        return [NSString stringWithFormat:@"%@ - %@",[self.pileSizeArray[row] valueForKey:@"PlotSizeCode"], [self.pileSizeArray[row] valueForKey:@"desc"]];
    
    else
        return nil;
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (pickerView.tag == 1){
        self.sizeField.text = [NSString stringWithFormat:@"%@ - %@",[self.pileSizeArray[row] valueForKey:@"PlotSizeCode"], [self.pileSizeArray[row] valueForKey:@"desc"]];
        [self.sizeField resignFirstResponder];
        
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
            length = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%.1f",[tf.text floatValue]]];
            length_str =tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Width", nil)]){
            width = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%.1f",[tf.text floatValue]]];
            width_str = tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Height", nil)]){
            height = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%.1f",[tf.text floatValue]]];
            height_str = tf.text;
        }
        if([tf.accessibilityLabel isEqualToString:NSLocalizedString(@"Pile Number", nil)]){
            pn = [[NSDecimalNumber alloc] initWithInt:[tf.text intValue]];
            pn_str = tf.text;
        }
    }
    BOOL duplicatePile = NO;
    if (pn){
        for(WastePile* wp in strpile.pileData){
            if( [wp.pileNumber integerValue] == [pn integerValue]){
                duplicatePile = YES;
                break;
            }
        }
    }
    NSString *warningMsg = @"";
    
    if([pn_str isEqualToString:@""] || [length_str isEqualToString:@""] || [width_str isEqualToString:@""] || [height_str isEqualToString:@""]){
        warningMsg = [warningMsg stringByAppendingString:@"Please enter Pile Number, Length, Width and Height.\n"];
    }
    if(duplicatePile){
        warningMsg = [warningMsg stringByAppendingString:@"Duplicate pile number, Select new pile number before proceeding.\n"];
    }
        if([pn integerValue]<1 || [pn intValue] > ([wasteStratum.totalNumPile intValue]? [wasteStratum.totalNumPile intValue] : [aggregatecutblock.totalNumPile intValue])) {
            warningMsg = [warningMsg stringByAppendingString:[NSString stringWithFormat:@"Pile number should be from 1 to %d\n", ([wasteStratum.totalNumPile intValue]?[wasteStratum.totalNumPile intValue]:[aggregatecutblock.totalNumPile intValue])]];
            }
            if([length floatValue] < 0.1 || [length floatValue] >= 1000) {
                warningMsg = [warningMsg stringByAppendingString:@"Length should be from 0.1 to 999.9\n"];
            }
            if([width floatValue] < 0.1 || [width floatValue] >= 1000) {
                warningMsg = [warningMsg stringByAppendingString:@"Width should be from 0.1 to 999.9\n"];
            }
            if([height floatValue] < 0.1 || [height floatValue] >= 1000) {
                warningMsg = [warningMsg stringByAppendingString:@"Height should be from 0.1 to 999.9\n"];
            }
        if([code isEqualToString:@"CN"] || [code isEqualToString:@"PR"]){
            double x = [length doubleValue] * .15;
            double width_less = [length doubleValue] - x;
            double width_more = [length doubleValue] + x;
            if([width floatValue] < width_less || [width floatValue] > width_more){
                warningMsg = [warningMsg stringByAppendingString:@"Length and width are not within 15% for the cone or paraboloid shape\n"];
            }
        }
         if(![warningMsg isEqualToString:@""])
         {
             UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                      message:warningMsg
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [self presentViewController:alert animated:YES completion:nil];
                                                                 }];
                
                [warningAlert addAction:okAction];
                [self presentViewController:warningAlert animated:YES completion:nil];
         }
        
        UIAlertController* confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Estimation", nil)
                                                                              message:[NSString stringWithFormat:@"Accept volume esimates? \n Length = %.2f \n Width = %.2f \n Height = %.2f \n Shape Code = %@", [length floatValue], [width floatValue], [height floatValue], [code uppercaseString]]
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                            if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
                                                                    self.currentEditingPile = [self addWastePile:self.wasteStratum stratumPile:self.aggregatecutblock.aggPile pileNumber:[pn integerValue] length:length width:width height:height code:code];
                                                                    self.wastePiles = [self.aggregatecutblock.aggPile.pileData allObjects];
                                                                if (self.wastePiles.count == [self.aggregatecutblock.totalNumPile integerValue]){
                                                                    [self.addPileButton setEnabled:NO];
                                                                    [self.warningMsg setHidden:YES];
                                                                }
                                                                else
                                                                {
                                                                    [self.warningMsg setHidden:NO];
                                                                    self.warningMsg.text = [NSString stringWithFormat:@"Number of records entered %ld is not equal to total number of piles %ld\n", (unsigned long)self.wastePiles.count, (long)[self.aggregatecutblock.totalNumPile integerValue]];
                                                                }
                                                            }else{
                                                                self.currentEditingPile = [self addWastePile:self.wasteStratum stratumPile:self.strpile pileNumber:[pn integerValue] length:length width:width height:height code:code];
                                                                self.wastePiles = [self.strpile.pileData allObjects];
                                                                if (self.wastePiles.count == [self.wasteStratum.totalNumPile integerValue]){
                                                                    [self.addPileButton setEnabled:NO];
                                                                    [self.warningMsg setHidden:YES];
                                                                }
                                                                else
                                                                {
                                                                    [self.warningMsg setHidden:NO];
                                                                    self.warningMsg.text = [NSString stringWithFormat:@"Number of records entered %ld is not equal to total number of piles %ld\n", (unsigned long)self.wastePiles.count, (long)[self.wasteStratum.totalNumPile integerValue]];
                                                                }
                                                            }
                                                              [self sampleYesOrNo:self.currentEditingPile];
                                                              [self calculatePileAreaAndVolume:self.currentEditingPile srsOrRatio:[self.wasteBlock.ratioSamplingEnabled intValue]];
                                                              [self sortPiles];
                                                              [self.pileTableView reloadData];
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

-(void)sampleYesOrNo:(WastePile *)currentPile{
    if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        NSArray* numberOfRows = [self.aggregatecutblock.n1sample componentsSeparatedByString:@","];
               NSMutableArray* rownumber = [numberOfRows mutableCopy];
               for(int j = 0; j < [numberOfRows count]; j++){
                   if([currentPile.pileNumber isEqual:[rownumber objectAtIndex:j]]){
                       currentPile.isSample = [[NSNumber alloc] initWithBool:YES];
                       break;
                   }
               }
    }else{
        NSArray* numberOfRows = [self.wasteStratum.n1sample componentsSeparatedByString:@","];
        NSMutableArray* rownumber = [numberOfRows mutableCopy];
        for(int j = 0; j < [numberOfRows count]; j++){
            if(currentPile.pileNumber == [rownumber objectAtIndex:j]){
                currentPile.isSample = [[NSNumber alloc] initWithBool:YES];
                break;
            }
        }
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
    //single block SRS
    if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        return [self.wastePiles count];
    }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        return [self.wastePiles count];
    }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        return [self.wastePiles count];
    }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        return [self.wastePiles count];
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellStr = @"";
    WastePile *currentPileCell = [self.wastePiles objectAtIndex:indexPath.row];
    
    /*if(currentPileCell.pileId != nil){
        cellStr = @"NewPileTableCell";
    }else{*/
        cellStr = @"EditPileTableCell";
    //}
    
    
    PileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if( [cell isKindOfClass:[PileEditTableViewCell class]]){
        ((PileEditTableViewCell *) cell).pileView = self;
    }
    //cell.statusButton.tag = indexPath.row;
    
    [cell bindCell:currentPileCell wasteBlock:self.wasteBlock userCreatedBlock:([self.wasteBlock.userCreated intValue] == 1)];

    return cell;
}

- (void) populateFromObject{
    
    
    NSString *title = [[NSString alloc] initWithFormat:@"(IFOR 206) Packing Ratio "];
    
    [[self navigationItem] setTitle:title];
    
    self.sizeField.text = self.wasteStratum.stratumPlotSizeCode.plotSizeCode ? [[NSString alloc] initWithFormat:@"%@ - %@", self.wasteStratum.stratumPlotSizeCode.plotSizeCode, self.wasteStratum.stratumPlotSizeCode.desc] : @"";
    //NSLog(@"total pile %@, measure samp %@, n1sample %@,n2sample %@", self.wasteStratum.totalNumPile,self.wasteStratum.measureSample, self.wasteStratum.n1sample, self.wasteStratum.n2sample);
    self.wastePiles = [self.strpile.pileData allObjects];
    //NSLog(@"strpile %@", self.strpile);
    if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        self.wastePiles = [self.aggregatecutblock.aggPile.pileData allObjects];
        //NSLog(@"strpile %@", self.aggregatecutblock.aggPile.pileData );
    }
    
    if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        [self.addPileButton setHidden:NO];
        if (self.wastePiles.count == [self.wasteStratum.totalNumPile integerValue]){
            [self.addPileButton setEnabled:NO];
            [self.warningMsg setHidden:YES];
        }else{
            [self.addPileButton setEnabled:YES];
            [self.warningMsg setHidden:NO];
            self.warningMsg.text = [NSString stringWithFormat:@"Number of records entered %ld is not equal to total number of piles %ld\n", (unsigned long)self.wastePiles.count, (long)[self.wasteStratum.totalNumPile integerValue]];
        }
    }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue] && [self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        [self.addPileButton setHidden:NO];
        //NSLog(@"aggregatecutblock %@", self.aggregatecutblock);
        if (self.wastePiles.count == [self.aggregatecutblock.totalNumPile integerValue]){
            [self.addPileButton setEnabled:NO];
            [self.warningMsg setHidden:YES];
        }else{
            [self.addPileButton setEnabled:YES];
            [self.warningMsg setHidden:NO];
            self.warningMsg.text = [NSString stringWithFormat:@"Number of records entered %ld is not equal to total number of piles %ld\n", (unsigned long)self.wastePiles.count, (long)[self.aggregatecutblock.totalNumPile integerValue]];
        }
    }
    //size is pulling from the stratum
    self.residueSurveyor.text = self.strpile.surveyorName ? [[NSString alloc] initWithFormat:@"%@", self.strpile.surveyorName] : @"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM-dd-yyyy"];
    self.surveyDate.text = [[NSString alloc] initWithFormat:@"%@", self.strpile.surveyDate ? [dateFormat stringFromDate:self.strpile.surveyDate] : [dateFormat stringFromDate:[NSDate date]]];
    self.note.text = self.strpile.notes ? [[NSString alloc] initWithFormat:@"%@", self.strpile.notes] : @"";
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        if([self.wasteBlock.isAggregate intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
            [self.efwFooterView setPileViewValue:self.strpile];
        }else{
            [WasteCalculator calculateEFWStat:self.wasteBlock];
            [self.efwFooterView setPileViewValue:self.aggregatecutblock.aggPile];
        }
    }
}

-(void) calculatePileAreaAndVolume:(WastePile *)wastePile srsOrRatio:(NSInteger)ratio {
    float pi = 3.141592;
    //NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:5 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    if(ratio == 1){
        if([wastePile.pilePileShapeCode.pileShapeCode isEqual:@""]){
            wastePile.pileArea = 0;
            wastePile.pileVolume = 0;
            wastePile.measuredPileArea = 0;
            wastePile.measuredPileVolume = 0;
        }else if([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"CN"]){
            wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:((([wastePile.length doubleValue] / 2) * ([wastePile.length doubleValue] / 2)) * pi)] ;
            wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:((([wastePile.length doubleValue] / 2) * ([wastePile.length doubleValue] / 2)) * pi) * ([wastePile.height doubleValue]/3)] ;
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:((([wastePile.measuredLength doubleValue] / 2) * ([wastePile.measuredLength doubleValue] / 2)) * pi)] ;
            wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:((([wastePile.measuredLength doubleValue] / 2) * ([wastePile.measuredLength doubleValue] / 2)) * pi) * ([wastePile.measuredHeight doubleValue]/3)] ;
        }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"CY"]) {
            wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:[wastePile.length doubleValue] * [wastePile.width doubleValue]] ;
            wastePile.pileVolume =  [[NSDecimalNumber alloc] initWithDouble:((pi * [wastePile.width doubleValue] * [wastePile.length doubleValue] * [wastePile.height doubleValue])/4)] ;
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:[wastePile.measuredLength doubleValue] * [wastePile.measuredWidth doubleValue]] ;
            wastePile.measuredPileVolume =  [[NSDecimalNumber alloc] initWithDouble:((pi * [wastePile.measuredWidth doubleValue] * [wastePile.measuredLength doubleValue] * [wastePile.measuredHeight doubleValue])/4)] ;
        }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"PR"]) {
            wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:((([wastePile.length doubleValue] / 2) * ([wastePile.length doubleValue] / 2)) * pi)] ;
            wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:(([wastePile.length doubleValue] * [wastePile.length doubleValue]) * pi) * ([wastePile.height doubleValue]/8)] ;
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:((([wastePile.measuredLength doubleValue] / 2) * ([wastePile.measuredLength doubleValue] / 2)) * pi)] ;
            wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:(([wastePile.measuredLength doubleValue] * [wastePile.measuredLength doubleValue]) * pi) * ([wastePile.measuredHeight doubleValue]/8)] ;
        }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"EL"]) {
           wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:([wastePile.length doubleValue] / 2) * ([wastePile.width doubleValue] / 2) * pi] ;
           wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:(pi * [wastePile.length doubleValue] * [wastePile.width doubleValue] * ([wastePile.height doubleValue] / 6))] ;
           wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:([wastePile.measuredLength doubleValue] / 2) * ([wastePile.measuredWidth doubleValue] / 2) * pi] ;
           wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:(pi * [wastePile.measuredLength doubleValue] * [wastePile.measuredWidth doubleValue] * ([wastePile.measuredHeight doubleValue] / 6))] ;
        } else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"RT"]) {
            wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:([wastePile.length doubleValue]) * ([wastePile.width doubleValue])] ;
            wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:([wastePile.length doubleValue] * [wastePile.width doubleValue] * [wastePile.height doubleValue])] ;
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:([wastePile.measuredLength doubleValue] * [wastePile.measuredWidth doubleValue])] ;
            wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble: ([wastePile.measuredLength doubleValue] * [wastePile.measuredWidth doubleValue] * [wastePile.measuredHeight doubleValue])] ;
        } else {
            wastePile.pileVolume = [[NSDecimalNumber alloc] initWithDouble:-999];
            wastePile.pileArea = [[NSDecimalNumber alloc] initWithDouble:-999];
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:-999];
            wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:-999];
        }
    }else{
        if([wastePile.pilePileShapeCode.pileShapeCode isEqual:@""]){
            wastePile.measuredPileArea = 0;
            wastePile.measuredPileVolume = 0;
        }else if([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"CN"]){
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:((([wastePile.measuredLength doubleValue] / 2) * ([wastePile.measuredLength doubleValue] / 2)) * pi)] ;
            wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:((([wastePile.measuredLength doubleValue] / 2) * ([wastePile.measuredLength doubleValue] / 2)) * pi) * ([wastePile.measuredHeight doubleValue]/3)] ;
        }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"CY"]) {
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:[wastePile.measuredLength doubleValue] * [wastePile.measuredWidth doubleValue]] ;
            wastePile.measuredPileVolume =  [[NSDecimalNumber alloc] initWithDouble:((pi * [wastePile.measuredWidth doubleValue] * [wastePile.measuredLength doubleValue] * [wastePile.measuredHeight doubleValue])/4)] ;
        }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"PR"]) {
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:((([wastePile.measuredLength doubleValue] / 2) * ([wastePile.measuredLength doubleValue] / 2)) * pi)] ;
            wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:(([wastePile.measuredLength doubleValue] * [wastePile.measuredLength doubleValue]) * pi) * ([wastePile.measuredHeight doubleValue]/8)] ;
        }else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"EL"]) {
           wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:([wastePile.measuredLength doubleValue] / 2) * ([wastePile.measuredWidth doubleValue] / 2) * pi] ;
           wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:(pi * [wastePile.measuredLength doubleValue] * [wastePile.measuredWidth doubleValue] * ([wastePile.measuredHeight doubleValue] / 6))] ;
        } else if ([wastePile.pilePileShapeCode.pileShapeCode isEqual:@"RT"]) {
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:([wastePile.measuredLength doubleValue] * [wastePile.measuredWidth doubleValue])];
            wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble: ([wastePile.measuredLength doubleValue] * [wastePile.measuredWidth doubleValue] * [wastePile.measuredHeight doubleValue])] ;
        } else {
            wastePile.measuredPileVolume = [[NSDecimalNumber alloc] initWithDouble:-999];
            wastePile.measuredPileArea = [[NSDecimalNumber alloc] initWithDouble:-999];
        }
    }
}

-(WastePile *) addWastePile:(WasteStratum *)targetWasteStratum stratumPile:(StratumPile *)strPile pileNumber:(NSInteger)pileNumber length:(NSDecimalNumber*)length width:(NSDecimalNumber*)width height:(NSDecimalNumber*)height code:(NSString*)code{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePile *newWp = [NSEntityDescription insertNewObjectForEntityForName:@"WastePile" inManagedObjectContext:context];
    
    
        int i = 0;
        NSArray *piles = [strPile.pileData allObjects];
        for(WastePile *wp in piles){
            if( [wp.pileNumber integerValue] > i){
                i = [wp.pileNumber intValue];
            }
        }
        
        newWp.pileNumber = [[NSNumber numberWithInteger:pileNumber] stringValue];
        newWp.pileId = [NSNumber numberWithInt:[newWp.pileNumber intValue]];
        newWp.length = length;
        newWp.width = width;
        newWp.height = height;
        newWp.pilePileShapeCode = self.currentpile;
    
    [strPile addPileDataObject:newWp];
    return newWp;
}

#pragma mark - BackButtonHandler protocol
-(BOOL) navigationShouldPopOnBackButton
{
    [self saveData];
    
    WastePlotValidator *wpv = [[WastePlotValidator alloc] init];
    NSString *errorMessage = [wpv validatePile:wastePiles wasteBlock:wasteBlock wasteStratum:wasteStratum aggregatecutblock:aggregatecutblock];
    BOOL isfatal = NO;
      
    if( [errorMessage rangeOfString:@"Error"].location != NSNotFound){
       isfatal = YES;
    }
    
    /*if([wasteBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue] && [wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:FALSE] intValue]){
        if( [wastePiles count] != [wasteStratum.totalNumPile intValue]){
            errorMessage = [NSString stringWithFormat:@"%@ Number of records entered %lu is not equal to total number of piles %d", errorMessage, (unsigned long)[wastePiles count], [wasteStratum.totalNumPile intValue]];
        }
    }else if([wasteBlock.ratioSamplingEnabled intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue] && [wasteBlock.isAggregate intValue] == [[[NSNumber alloc] initWithBool:TRUE] intValue]){
        if([wastePiles count] != [aggregatecutblock.totalNumPile intValue]){
            errorMessage = [NSString stringWithFormat:@"%@ Number of records entered %lu is not equal to total number of piles %d", errorMessage, (unsigned long)[wastePiles count], [aggregatecutblock.totalNumPile intValue]];
        }
    }*/

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

-(NSMutableArray*) getNewPileProperties:(NSString*) stratumTypeCode pile:(WastePile*)pile{
    NSMutableArray *properties = [[NSMutableArray alloc] init];
    if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:FALSE] intValue]){
        [properties addObject:@"measuredLength"];
        [properties addObject:@"measuredWidth"];
        [properties addObject:@"measuredHeight"];
        [properties addObject:@"pilePileShapeCode"];
    }else if([self.wasteBlock.ratioSamplingEnabled intValue] == [[NSNumber numberWithBool:TRUE] intValue]){
        [properties addObject:@"measuredLength"];
        [properties addObject:@"measuredWidth"];
        [properties addObject:@"measuredHeight"];
    }
    
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
