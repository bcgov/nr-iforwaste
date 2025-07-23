//
//  DataEndorsementViewController.m
//  WasteMobile
//
//  Created by chrisnesmith on 2023-03-24.
//  Copyright © 2023 Salus Systems. All rights reserved.
//

#import "WasteStratum.h"
#import "DataEndorsementViewController.h"
#import "SignatureView.h"
#import "WastePlot.h"
#import "StratumViewController.h"
#import "PlotSampleGenerator.h"
#import "WasteCalculator.h"
#import "WasteBlock.h"
#import "PlotSelectorLog.h"
#import "WasteBlockDAO.h"

@interface DataEndorsementViewController ()
{
    NSArray<NSString*> *dataset;
}
@end

@implementation DataEndorsementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataset = @[@"",@"RPF",@"RFT",@"N/A"];
       
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    if([_endorsementType isEqualToString:@"Delete Plot"] || [_endorsementType isEqualToString:@"Delete Pile"] || [_endorsementType isEqualToString:@"Delete Stratum"])
    {
        [_confirmButton setTitle:@"Confirm Deletion" forState:UIControlStateNormal];
    }
    else if([_endorsementType isEqualToString:@"Edit Plot"] || [_endorsementType isEqualToString:@"Edit Plot Back Button"])
    {
        [_confirmButton setTitle:@"Confirm Data Change" forState:UIControlStateNormal];
    }
    [_confirmButton addTarget:self action:@selector(validateAndCofirmChange) forControlEvents:UIControlEventTouchUpInside];
    
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    if([_endorsementType isEqualToString:@"Edit Plot"] || [_endorsementType isEqualToString:@"Edit Plot Back Button"])
    {
        [_cancelButton addTarget:self action:@selector(editCancelDismissView) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [_cancelButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = nil;    
    
    UITextView *myUITextView = _dcRationale;
    myUITextView.delegate = self;
    myUITextView.text = @"Rationale";
    myUITextView.textColor = [UIColor lightGrayColor]; //optional
    
    [myUITextView.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [myUITextView.layer setBorderColor: [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [myUITextView.layer setBorderWidth: 1.0];
    [myUITextView.layer setCornerRadius:8.0f];
    [myUITextView.layer setMasksToBounds:YES];
    
    
    /*
    SignatureView *signView= [[ SignatureView alloc] initWithFrame: CGRectMake(70, 400, self.view.frame.size.width-140, 150)];
    [signView setBackgroundColor:[UIColor whiteColor]];
    signView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    signView.layer.borderWidth = 1.0;
    [self.view addSubview:signView];*/
}

-(void)editCancelDismissView
{
    NSString *test1 = [self.plotVC.originalMP stringValue];
    NSString *test2 = self.plotVC.measurePct.text;
    self.plotVC.measurePct.text = [self.plotVC.originalMP stringValue];
    NSString *test3 = [self.plotVC.originalMP stringValue];
    NSString *test4 = self.plotVC.measurePct.text;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dismissView{
    [self.navigationController popViewControllerAnimated:YES];
    //[self presentViewController:_stratumVC animated:YES completion:nil];
    //[self dismissViewControllerAnimated:true completion:nil];
}

-(void)validateAndCofirmChange{
    NSString* inputSurveyName = _dcSurveyorName.text;
    NSInteger row = [_pickerView selectedRowInComponent:0];
    NSString* inputDesg = _dcDesignation.text = [dataset objectAtIndex:row];
    NSString* inputLicenseNum = _dcLicenseNumber.text;
    NSString* inputRationale = _dcRationale.text;
    
    NSPredicate *licensePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[a-zA-Z0-9]*$"];
    
    if([inputSurveyName isEqualToString:@""]){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                              message:@"Please enter Surveyor Name."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [warningAlert dismissViewControllerAnimated:true completion:nil];
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
            [warningAlert dismissViewControllerAnimated:true completion:nil];
        }];
        
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else if(![inputLicenseNum isEqualToString:@""] && inputLicenseNum.length > 8){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid entry", nil)
                                                                                  message:@"The License Number must be 8 characters or less."             preferredStyle:UIAlertControllerStyleAlert];
                
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
            [warningAlert dismissViewControllerAnimated:true completion:nil];
                                                                  }];
                
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else if (![licensePredicate evaluateWithObject:inputLicenseNum]) {
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid entry", nil)
                                                                                  message:@"The License Number must contain only numbers and letters."             preferredStyle:UIAlertControllerStyleAlert];
                
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
            [warningAlert dismissViewControllerAnimated:true completion:nil];
                                                                  }];
                
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else if([inputRationale isEqualToString:@""] || [inputRationale isEqualToString:@"Rationale"] || inputRationale.length < 5 || inputRationale.length > 100){
        UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Missing Required Field", nil)
                                                                                  message:@"Please enter a Rationale for Deletion between 5 and 100 characters."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
            [warningAlert dismissViewControllerAnimated:true completion:nil];
                                                                  }];
                
        [warningAlert addAction:okAction];
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
    else
    {
        if([_endorsementType isEqualToString:@"Delete Plot"])
        {
            WastePlot *targetPlot = [self.stratumVC.sortedPlots objectAtIndex:[_plotNumber intValue]];
            targetPlot.dcSurveyorName = inputSurveyName;
            targetPlot.dcDesignation = inputDesg;
            targetPlot.dcLicenseNumber = inputLicenseNum;
            targetPlot.dcRationale = inputRationale;
            [PlotSampleGenerator deletePlot2:_wasteStratum plotNumber:[targetPlot.plotNumber intValue]];
            [self deletePlot:targetPlot targetWasteStratum:_wasteStratum];
            
            NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"plotNumber" ascending:YES]; // is key ok ? does it actually sort according to it
            self.stratumVC.sortedPlots = [[[self.wasteStratum stratumPlot] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            [WasteCalculator calculateWMRF:self.stratumVC.wasteBlock updateOriginal:NO];
            [WasteCalculator calculateRate:self.stratumVC.wasteBlock ];
            [WasteCalculator calculatePiecesValue:self.stratumVC.wasteBlock];
            if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
                [WasteCalculator calculateEFWStat:self.stratumVC.wasteBlock];
                [self.stratumVC.efwFooterView setStratumViewValue:self.wasteStratum];
            }else{
                [self.stratumVC.footerStatView setViewValue:self.wasteStratum];
            }
            [self.stratumVC.plotTableView reloadData];
            [self.stratumVC.aggregatePlotTableView reloadData];
            [self dismissView];
        }
        else if ([_endorsementType isEqualToString:@"Delete Pile"]) {
            WastePile *targetPile = [self.stratumVC.sortedPiles objectAtIndex:[_plotNumber intValue]];
            targetPile.dcSurveyorName = inputSurveyName;
            targetPile.dcDesignation = inputDesg;
            targetPile.dcLicenseNumber = inputLicenseNum;
            targetPile.dcRationale = inputRationale;
            [PlotSampleGenerator deletePlot2:_wasteStratum plotNumber:[targetPile.pileNumber intValue]];
            [self deletePile:targetPile targetWasteStratum:_wasteStratum];
            
            NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"pileNumber" ascending:YES]; // is key ok ? does it actually sort according to it
            self.stratumVC.sortedPiles = [[[self.wasteStratum stratumPile] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            // footer should already be set to 0 here
            [WasteCalculator calculateWMRF:self.stratumVC.wasteBlock updateOriginal:NO];
            [WasteCalculator calculateRate:self.stratumVC.wasteBlock ];
            [WasteCalculator calculatePiecesValue:self.stratumVC.wasteBlock];
            if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
                [WasteCalculator calculateEFWStat:self.stratumVC.wasteBlock];
                [self.stratumVC.efwFooterView setStratumViewValue:self.wasteStratum];
            }else{
                [self.stratumVC.footerStatView setViewValue:self.wasteStratum];
            }
            [self.stratumVC.packingRatioTableView reloadData];
            [self.stratumVC.aggregatePackingRatioPlotTableView reloadData];
            [self dismissView];
        }
        else if([_endorsementType isEqualToString:@"Delete Stratum"])
        {
            WasteStratum *targetStratum = [_blockVC.sortedStratums objectAtIndex:[_stratumNumber intValue]];
                        
            targetStratum.dcSurveyorName = inputSurveyName;
            targetStratum.dcDesignation = inputDesg;
            targetStratum.dcLicenseNumber = inputLicenseNum;
            targetStratum.dcRationale = inputRationale;
            
                        [WasteBlockDAO deleteStratum:targetStratum usingWB:_blockVC.wasteBlock];
                        
                        
                        NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"stratum" ascending:YES]; // is key ok ? does it actually sort according to it
                        NSSortDescriptor *sort2 = [[NSSortDescriptor alloc ] initWithKey:@"stratumID" ascending:YES];
                        
                        _blockVC.sortedStratums = [[[self.wasteBlock blockStratum] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, sort2, nil]];
                        
                        [WasteCalculator calculateWMRF:self.wasteBlock updateOriginal:NO];
                        [WasteCalculator calculateRate:self.wasteBlock ];
                        [WasteCalculator calculatePiecesValue:self.wasteBlock];
                        
                        if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
                            [WasteCalculator calculateEFWStat:self.wasteBlock];
                            [_blockVC.efwFooterView setBlockViewValue:self.wasteBlock];
                        }else{
                            [_blockVC.footerStatView setViewValue:self.wasteBlock];
                        }
                        
                        [_blockVC saveData];
                        [_blockVC.stratumTableView reloadData];
                        [_blockVC viewDidLoad];
                       // [_blockVC checkStratum];
            [self dismissView];
            
        }
        else if ([_endorsementType isEqualToString:@"Edit Plot"])
        {
            self.wastePlot.dcSurveyorName = inputSurveyName;
            self.wastePlot.dcDesignation = inputDesg;
            self.wastePlot.dcLicenseNumber = inputLicenseNum;
            self.wastePlot.dcRationale = inputRationale;
            self.wastePlot.plotStratum.ratioSamplingLog = [self.wastePlot.plotStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:self.wastePlot stratum:self.wastePlot.plotStratum actionDec:@"Measure % Changed"]];
            self.wastePlot.plotStratum.stratumBlock.ratioSamplingLog = [self.wastePlot.plotStratum.stratumBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:self.wastePlot stratum:self.wastePlot.plotStratum actionDec:@"Measure % Changed"]];
            self.plotVC.originalMP = self.wastePlot.surveyedMeasurePercent;
            
            [self dismissView];
            /*NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[StratumViewController class]]) {
                    [self.navigationController popToViewController:aViewController animated:NO];
                }
            }*/
        }
        else if ([_endorsementType isEqualToString:@"Edit Plot Back Button"])
        {
            self.wastePlot.dcSurveyorName = inputSurveyName;
            self.wastePlot.dcDesignation = inputDesg;
            self.wastePlot.dcLicenseNumber = inputLicenseNum;
            self.wastePlot.dcRationale = inputRationale;
            self.wastePlot.plotStratum.ratioSamplingLog = [self.wastePlot.plotStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:self.wastePlot stratum:self.wastePlot.plotStratum actionDec:@"Measure % Changed"]];
            self.wastePlot.plotStratum.stratumBlock.ratioSamplingLog = [self.wastePlot.plotStratum.stratumBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:self.wastePlot stratum:self.wastePlot.plotStratum actionDec:@"Measure % Changed"]];
            self.plotVC.originalMP = self.wastePlot.surveyedMeasurePercent;
            
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[StratumViewController class]]) {
                    [self.navigationController popToViewController:aViewController animated:NO];
                }
            }
        }
    }
}

#pragma mark - Core data related function
-(void) deletePlot:(WastePlot *)targetWastePlot targetWasteStratum:(WasteStratum *)targetWasteStratum{
    
    if([targetWasteStratum.stratumBlock.ratioSamplingEnabled integerValue]== 1)
    {
        _stratumVC.wasteStratum.ratioSamplingLog = [_stratumVC.wasteStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:targetWastePlot stratum:targetWasteStratum actionDec:@"Delete Plot"]];
        _stratumVC.wasteBlock.ratioSamplingLog = [_stratumVC.wasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPlotSelectorLog:targetWastePlot stratum:targetWasteStratum actionDec:@"Delete Plot"]];
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

#pragma mark - Core data related function
-(void) deletePile:(WastePile *)targetWastePile targetWasteStratum:(WasteStratum *)targetWasteStratum {
    if ([targetWasteStratum.stratumBlock.ratioSamplingEnabled integerValue] == 1) {
        _stratumVC.wasteStratum.ratioSamplingLog = [_stratumVC.wasteStratum.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPileSelectorLog:targetWastePile stratum:targetWasteStratum actionDec:@"Delete Plot"]];
        _stratumVC.wasteBlock.ratioSamplingLog = [_stratumVC.wasteBlock.ratioSamplingLog stringByAppendingString:[PlotSelectorLog getPileSelectorLog:targetWastePile stratum:targetWasteStratum actionDec:@"Delete Plot"]];
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

    NSError *error;
    [context save:&error];
    
    if (error){
        NSLog(@"Error when deleting a piece and save :%@", error);
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Rationale"]) {
         textView.text = @"";
         textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Rationale";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

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

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [dataset count];
}

#pragma mark Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [dataset objectAtIndex:row];
}

@end
