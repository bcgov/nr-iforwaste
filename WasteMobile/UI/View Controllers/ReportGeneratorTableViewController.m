//
//  ReportGeneratorTableViewController.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-05.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//


#import "ReportGeneratorTableViewController.h"
#import "CheckSummaryReport.h"
#import "FS702Report.h"
#import "PlotTallyReport.h"
#import "BlockTypeSummaryReport.h"
#import "PlotPredictionReport.h"
#import "WastePlot.h"
#import "WastePiece.h"

// test
#import "ButtEndCode.h"
#import "TopEndCode.h"
#import "CommentCode.h"
#import "DecayTypeCode.h"
#import "ScaleGradeCode.h"
#import "WasteClassCode.h"
#import "MaterialKindCode.h"
#import "BorderlineCode.h"
#import "CheckerStatusCode.h"
#import "ScaleSpeciesCode.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "Timbermark.h"
#import "WastePlotValidator.h"

NSString *const FeedbackSuccessful = @" generated successfully.";
NSString *const FeedbackReplaceSuccessful = @" replaced successfully";
NSString *const FeedbackFailFilenameExist = @" failed to be generated - filename exists. ";
NSString *const FeedbackFailUnknown = @" failed to be generated - unknown error.";
NSString *const FeedbackNotAvailable = @" report not available.";

@interface ReportGeneratorTableViewController ()

@end

@implementation ReportGeneratorTableViewController

@synthesize checkSummarySwitch, fs702Switch, plotTallySwitch, blockTypeSummarySwitch;
@synthesize suffix;
@synthesize replaceReports;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loadingWheel.hidesWhenStopped = YES;
    [self.loadingWheel stopAnimating];
    [self.loadingWheel setHidden:YES];
    
    // TEST
    
    //NSLog(@"tally switch = %hhd", self.plotTallySwitch.isEnabled);
    
    // END TEST
    
    //self.plotTallySwitch.enabled = self.tallySwitchEnabled;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if( self.replaceReports == nil){
        self.replaceReports = [[NSMutableArray alloc] init];
    }
    
    if([self.wasteBlock.ratioSamplingEnabled integerValue]== 1){
        [self.plotPredictionTVC setHidden:NO];
    }else{
        [self.plotPredictionTVC setHidden:YES];
    }
    
    //validate plots data first
    WastePlotValidator *wpv = [[WastePlotValidator alloc] init];
    
    
    NSString *error = [wpv validateBlock:self.wasteBlock];
    
    if (![error isEqualToString:@""]){
        NSString *message = NSLocalizedString(error, nil);
        //NSString *okButtonTitle = NSLocalizedString(@"OK", nil);
        //NSString *otherButtonTitleOne = NSLocalizedString(@"Yes", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Plot Data Error, reports cannot be generated" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil ];
        alert.tag = 10;
        [alert show];
    }else{
        error = [wpv validateBlockForPlotPrediction:self.wasteBlock];
        if(![error isEqualToString:@""]){
            UIAlertController* warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Plot Data Missing", nil)
                                                                                  message:[NSString stringWithFormat:@"%@ OK to proceed?",error]
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) { }];
            
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self dismissViewControllerAnimated:YES completion:nil ];
                                                             }];
            [warningAlert addAction:yesAction];
            [warningAlert addAction:noAction];
            [self presentViewController:warningAlert animated:YES completion:nil];
        }
    }
        

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
-(IBAction)goBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil ];
}


// TEMPORARY WHILE WASTEBLOCKS ARE TEMPORARY (delete after done)
//
- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void) sortPiece{
    NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"pieceNumber" ascending:YES];
    self.wastePieces = [self.wastePieces sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
}

- (IBAction)generateReport:(id)sender{
    
    [self.loadingWheel startAnimating];
    [self.loadingWheel setHidden:NO];

    [self generateSelectedReport:NO];
}


- (void)viewWillDisappear:(BOOL)animated{
    
    //[self.plotTallySwitch setEnabled:NO];
    
    // tallySwitchEnabled = NO;
    
}



#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) {
        //NSLog(@"Alert view clicked with the cancel button index.");
        
        //clear the replaceReports array
        [self.replaceReports removeAllObjects];
        
        [self resetControls];
    }
    else {
        if (alertView.tag == 10){
            [self dismissViewControllerAnimated:YES completion:nil ];
        }else{
            //NSString *feedback = @"";
            if ((long)buttonIndex == 1){
                //yes - to replace the file with existing name
                
                //Dev: other way to run a function in different thread without waiting for it to be finished
                [self performSelectorOnMainThread:@selector(replacingSelectedReport) withObject:nil waitUntilDone:NO];
                
                //don't let user do anything from this point
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            }
        }
    }
}

//use this function be called by performSelectorOnMainThread
- (void) replacingSelectedReport{
    
    [self generateSelectedReport:YES];
    
    //resume the interaction
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void) generateSelectedReport:(BOOL)replace{

        NSString *feedback = @"";
        if (replace){
            for( int i = 0; i < (int)[ self.replaceReports count]; i++) {
                if ([[self.replaceReports objectAtIndex:i] rangeOfString:@"Check Summary Report"].location != NSNotFound){
                    CheckSummaryReport *rg = [[CheckSummaryReport alloc] init];
                    feedback = [feedback stringByAppendingString:@"Check Summary Report : "];
                    switch ([rg generateReport:self.wasteBlock suffix:self.suffix.text replace:replace]){
                        case Successful:
                            feedback = [feedback stringByAppendingString:FeedbackReplaceSuccessful];
                            break;
                        default:
                            //if it is not successful, just show failure feedback here
                            feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                            break;
                    }
                    feedback = [feedback stringByAppendingString:@"\n"];
                }
                if ([[self.replaceReports objectAtIndex:i] rangeOfString:@"Plot Prediction Report"].location != NSNotFound){
                    PlotPredictionReport *rg = [[PlotPredictionReport alloc] init];
                    feedback = [feedback stringByAppendingString:@"Plot Prediction Report : "];
                    switch ([rg generateReport:self.wasteBlock suffix:self.suffix.text replace:replace]){
                        case Successful:
                            feedback = [feedback stringByAppendingString:FeedbackReplaceSuccessful];
                            break;
                        default:
                            //if it is not successful, just show failure feedback here
                            feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                            break;
                    }
                    feedback = [feedback stringByAppendingString:@"\n"];
                }
                if ([[self.replaceReports objectAtIndex:i] rangeOfString:@"Block Type Summary Report"].location != NSNotFound){
                    BlockTypeSummaryReport *rg = [[BlockTypeSummaryReport alloc] init];
                    feedback = [feedback stringByAppendingString:@"Block Type Summary Report : "];
                    switch ([rg generateReport:self.wasteBlock suffix:self.suffix.text replace:replace]){
                        case Successful:
                            feedback = [feedback stringByAppendingString:FeedbackReplaceSuccessful];
                            break;
                        default:
                            //if it is not successful, just show failure feedback here
                            feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                            break;
                    }
                    feedback = [feedback stringByAppendingString:@"\n"];
                }
                if ([[self.replaceReports objectAtIndex:i] rangeOfString:@"FS 702 Report"].location != NSNotFound){
                    FS702Report *rg = [[FS702Report alloc] init];
                    for (Timbermark *tm in [self.wasteBlock.blockTimbermark allObjects])
                    {
                        if([[self.replaceReports objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"FS 702 Report - %@", tm.timbermark]].location != NSNotFound){

                            feedback = [feedback stringByAppendingString:[NSString stringWithFormat:@"FS 702 Report - %@ : ", tm.timbermark]];
                            
                            switch ([rg generateReport:self.wasteBlock withTimbermark:tm suffix:self.suffix.text replace:replace]){
                                case Successful:
                                    feedback = [feedback stringByAppendingString:FeedbackReplaceSuccessful];
                                    break;
                                default:
                                    //if it is not successful, just show failure feedback here
                                    feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                                    break;
                            }
                            feedback = [feedback stringByAppendingString:@"\n"];
                            break;
                        }
                    }
                }
                if ([[self.replaceReports objectAtIndex:i] rangeOfString:@"Plot Tally Report"].location != NSNotFound){
                    PlotTallyReport *rg = [[PlotTallyReport alloc] init];
                    
                    
                    // check if self.wastePlot is set, meaning it is from Plot VC
                    if (self.wastePlot){
                        if([[self.replaceReports objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"Plot Tally Report - %@ - %@", self.wastePlot.plotStratum.stratum, self.wastePlot.plotNumber]].location != NSNotFound){
                            feedback = [feedback stringByAppendingString:@"Plot Tally Report : "];
                            switch ([rg generateReport:self.wasteBlock withPlot:self.wastePlot suffix:self.suffix.text replace:replace]){
                                case Successful:
                                    feedback = [feedback stringByAppendingString:FeedbackReplaceSuccessful];
                                    break;
                                default:
                                    //if it is not successful, just show failure feedback here
                                    feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                                    break;
                            }
                            feedback = [feedback stringByAppendingString:@"\n"];
                        }
                    }else if(self.wasteStratum){
                        BOOL rpt_success = YES;
                        BOOL rpt_gen = NO;
                        for( WastePlot* p in self.wasteStratum.stratumPlot){
                            if([[self.replaceReports objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"Plot Tally Report - %@ - %@", self.wastePlot.plotStratum.stratum, self.wastePlot.plotNumber]].location != NSNotFound){
                                rpt_gen = YES;
                                switch ([rg generateReport:self.wasteBlock withPlot:p suffix:self.suffix.text replace:replace]){
                                    case Successful:
                                        
                                        break;
                                    default:
                                        rpt_success = NO;
                                        //if it is not successful, just show failure feedback here
                                        break;
                                }
                            }
                        }
                        if(rpt_gen){
                            feedback = [feedback stringByAppendingString:@"Plot Tally Report(s) : "];
                            if(rpt_success == YES){
                                feedback = [feedback stringByAppendingString:FeedbackReplaceSuccessful];
                            }else{
                                feedback = [[feedback stringByAppendingString:@" at least one report "] stringByAppendingString:FeedbackFailUnknown];
                            }
                            feedback = [feedback stringByAppendingString:@"\n"];
                        }
                    }else{
                        BOOL rpt_success = YES;
                        BOOL rpt_gen = NO;
                        
                        for( WasteStratum* s in self.wasteBlock.blockStratum)
                        {
                            for( WastePlot* p in s.stratumPlot){
                                if([[self.replaceReports objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"Plot Tally Report - %@ - %@", self.wastePlot.plotStratum.stratum, self.wastePlot.plotNumber]].location != NSNotFound){
                                    rpt_gen = YES;
                                    switch ([rg generateReport:self.wasteBlock withPlot:p suffix:self.suffix.text replace:replace]){
                                        case Successful:
                                            break;
                                        default:
                                            rpt_success = NO;
                                            //if it is not successful, just show failure feedback here
                                            break;
                                    }
                                }
                            }
                        }
                        if(rpt_gen){
                            feedback = [feedback stringByAppendingString:@"Plot Tally Report(s) : "];
                            if(rpt_success == YES){
                                feedback = [feedback stringByAppendingString:FeedbackReplaceSuccessful];
                            }else{
                                feedback = [[feedback stringByAppendingString:@" at least one report "] stringByAppendingString:FeedbackFailUnknown];
                            }
                            feedback = [feedback stringByAppendingString:@"\n"];
                        }
                    }
                }
            }
        }else{
            if([checkSummarySwitch isOn]){
                CheckSummaryReport *rg = [[CheckSummaryReport alloc] init];
                feedback = [feedback stringByAppendingString:@"Check Summary Report : "];
                switch ([rg generateReport:self.wasteBlock suffix:self.suffix.text replace:NO]){
                    case Successful:
                        feedback = [feedback stringByAppendingString:FeedbackSuccessful];
                        break;
                    case Fail_Unknown:
                        feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                        break;
                    case Fail_Filename_Exist:
                        [self.replaceReports addObject:@"Check Summary Report"];
                        feedback = [feedback stringByAppendingString:FeedbackFailFilenameExist];
                        break;
                }
                feedback = [feedback stringByAppendingString:@"\n"];
            }
            
            if([fs702Switch isOn]){
                FS702Report *rg = [[FS702Report alloc] init];
                NSDecimalNumber *timbermark_total = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                BOOL validationErrorExist = NO;
                for (Timbermark *tm in [self.wasteBlock.blockTimbermark allObjects])
                {
                    if([tm.primaryInd intValue] == 1){
                        timbermark_total = [timbermark_total decimalNumberByAdding:tm.area];
                    }
                    if([tm.primaryInd intValue] == 2){
                        timbermark_total = [timbermark_total decimalNumberByAdding:tm.area];
                    }
                }
                if([timbermark_total doubleValue] != 0 && ![timbermark_total isEqual:self.wasteBlock.surveyArea]){
                    feedback = [feedback stringByAppendingString:@"Sum of all Timber Mark areas must be equal to Net Area of the CB\n"];
                    validationErrorExist = YES;
                }
                if([self.wasteBlock.blockTimbermark count] == 0){
                    feedback = [feedback stringByAppendingString:@"Sum of all Timber Mark areas must be equal to Net Area of the CB\n"];
                    validationErrorExist = YES;
                }
                for (Timbermark *tm in [self.wasteBlock.blockTimbermark allObjects])
                {
                    NSDecimalNumber *stratum_total = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                    //validation for net area and stratum area to be greater than 0.00ha
                    if([self.wasteBlock.surveyArea doubleValue]  == 0 || isnan([self.wasteBlock.surveyArea doubleValue])){
                        feedback = [feedback stringByAppendingString:@"CB Net Area must be > 0.00 ha\n"];
                        validationErrorExist = YES;
                        break;
                    }
                    for(WasteStratum *ws in self.wasteBlock.blockStratum){
                        if([ws.stratumSurveyArea doubleValue] == 0){
                            feedback = [feedback stringByAppendingString:@"Stratum Area must be >0.00 ha\n"];
                            validationErrorExist = YES;
                            break;
                        }
                        if(ws.stratumSurveyArea){
                            stratum_total = [stratum_total decimalNumberByAdding:ws.stratumSurveyArea];
                        }
                    }
                    if([stratum_total doubleValue] != 0 && ![stratum_total isEqual:self.wasteBlock.surveyArea]){
                        feedback = [feedback stringByAppendingString:@"Sum of all stratum areas must be equal to Net Area of the CB\n"];
                        validationErrorExist = YES;
                        break;
                    }
                    if([self.wasteBlock.blockStratum count] == 0){
                        feedback = [feedback stringByAppendingString:@"Sum of all stratum areas must be equal to Net Area of the CB\n"];
                        validationErrorExist = YES;
                        break;
                    }
                    if(!validationErrorExist){
                    feedback = [feedback stringByAppendingString:[NSString stringWithFormat:@"FS 702 Report - %@ : ", tm.timbermark]];
                    switch ([rg generateReport:self.wasteBlock withTimbermark:tm suffix:self.suffix.text replace:NO]){
                        case Successful:
                            feedback = [feedback stringByAppendingString:FeedbackSuccessful];
                            break;
                        case Fail_Unknown:
                            feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                            break;
                        case Fail_Filename_Exist:
                            [self.replaceReports addObject:[NSString stringWithFormat:@"FS 702 Report - %@", tm.timbermark]];
                            feedback = [feedback stringByAppendingString:FeedbackFailFilenameExist];
                            break;
                    }
                    feedback = [feedback stringByAppendingString:@"\n"];
                    }
                }
            }
            
            if([blockTypeSummarySwitch isOn]){
                NSDecimalNumber *stratum_total = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                NSDecimalNumber *timbermark_total = [NSDecimalNumber decimalNumberWithString:@"0.0"];
                BOOL validationErrorExist = NO;
                //validation for net area and stratum area to be greater than 0.00ha
                if([self.wasteBlock.surveyArea doubleValue]  == 0 || isnan([self.wasteBlock.surveyArea doubleValue])){
                    feedback = [feedback stringByAppendingString:@"CB Net Area must be > 0.00 ha\n"];
                    validationErrorExist = YES;
                }
                for(WasteStratum *ws in self.wasteBlock.blockStratum){
                    if([ws.stratumSurveyArea doubleValue] == 0){
                        feedback = [feedback stringByAppendingString:@"Stratum Area must be >0.00 ha\n"];
                        validationErrorExist = YES;
                        break;
                    }
                    if(ws.stratumSurveyArea){
                        stratum_total = [stratum_total decimalNumberByAdding:ws.stratumSurveyArea];
                    }
                }
                if([self.wasteBlock.blockStratum count] == 0){
                    feedback = [feedback stringByAppendingString:@"Sum of all stratum areas must be equal to Net Area of the CB\n"];
                    validationErrorExist = YES;
                }
                if([stratum_total doubleValue] != 0){
                    if(![stratum_total isEqual:self.wasteBlock.surveyArea]){
                        feedback = [feedback stringByAppendingString:@"Sum of all stratum areas must be equal to Net Area of the CB\n"];
                        validationErrorExist = YES;
                    }
                }
                for (Timbermark *tm in [self.wasteBlock.blockTimbermark allObjects])
                {
                    if([tm.primaryInd intValue] == 1){
                        timbermark_total = [timbermark_total decimalNumberByAdding:tm.area];
                    }
                    if([tm.primaryInd intValue] == 2){
                        timbermark_total = [timbermark_total decimalNumberByAdding:tm.area];
                    }
                }
                if([timbermark_total doubleValue] != 0 && ![timbermark_total isEqual:self.wasteBlock.surveyArea]){
                    feedback = [feedback stringByAppendingString:@"Sum of all Timber Mark areas must be equal to Net Area of the CB\n"];
                    validationErrorExist = YES;
                }
                if([self.wasteBlock.blockTimbermark count] == 0){
                    feedback = [feedback stringByAppendingString:@"Sum of all Timber Mark areas must be equal to Net Area of the CB\n"];
                    validationErrorExist = YES;
                }
                if(!validationErrorExist){
                BlockTypeSummaryReport *rg = [[BlockTypeSummaryReport alloc] init];
                feedback = [feedback stringByAppendingString:@"Block Type Summary Report : "];
                switch ([rg generateReport:self.wasteBlock suffix:self.suffix.text replace:NO]){
                    case Successful:
                        feedback = [feedback stringByAppendingString:FeedbackSuccessful];
                        break;
                    case Fail_Unknown:
                        feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                        break;
                    case Fail_Filename_Exist:
                        [self.replaceReports addObject:@"Block Type Summary Report"];
                        feedback = [feedback stringByAppendingString:FeedbackFailFilenameExist];
                        break;
                }
                feedback = [feedback stringByAppendingString:@"\n"];
                }
            }

            if([self.plotPredictionSwitch isOn]){
                PlotPredictionReport *rg = [[PlotPredictionReport alloc] init];
                feedback = [feedback stringByAppendingString:@"Plot Prediction Report : "];
                switch ([rg generateReport:self.wasteBlock suffix:self.suffix.text replace:NO]){
                    case Successful:
                        feedback = [feedback stringByAppendingString:FeedbackSuccessful];
                        break;
                    case Fail_Unknown:
                        feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                        break;
                    case Fail_Filename_Exist:
                        [self.replaceReports addObject:@"Plot Prediction Report"];
                        feedback = [feedback stringByAppendingString:FeedbackFailFilenameExist];
                        break;
                }
                feedback = [feedback stringByAppendingString:@"\n"];
            }
            
            if([plotTallySwitch isOn]){
                PlotTallyReport *rg = [[PlotTallyReport alloc] init];
                
                if (self.wastePlot){
                    feedback = [feedback stringByAppendingString:@"Plot Tally Report : "];
                    switch ([rg generateReport:self.wasteBlock withPlot:self.wastePlot suffix:self.suffix.text replace:NO]){
                        case Successful:
                            feedback = [feedback stringByAppendingString:FeedbackSuccessful];
                            break;
                        case Fail_Unknown:
                            feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                            break;
                        case Fail_Filename_Exist:
                            [self.replaceReports addObject:[NSString stringWithFormat:@"Plot Tally Report - %@ - %@", self.wastePlot.plotStratum.stratum, self.wastePlot.plotNumber]];
                            feedback = [feedback stringByAppendingString:FeedbackFailFilenameExist];
                            break;
                    }
                    feedback = [feedback stringByAppendingString:@"\n"];
                }else if(self.wasteStratum){
                    feedback = [feedback stringByAppendingString:@"Plot Tally Report(s) : "];
                    BOOL rpt_success = YES;
                    BOOL rpt_replace = NO;
                    for( WastePlot* p in self.wasteStratum.stratumPlot){
                        switch ([rg generateReport:self.wasteBlock withPlot:p suffix:self.suffix.text replace:NO]){
                            case Successful:
                                //feedback = [feedback stringByAppendingString:FeedbackSuccessful];
                                break;
                            case Fail_Unknown:
                                //feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                                rpt_success = NO;
                                break;
                            case Fail_Filename_Exist:
                                rpt_success = NO;
                                rpt_replace = YES;
                                [self.replaceReports addObject:[NSString stringWithFormat:@"Plot Tally Report - %@ - %@", self.wastePlot.plotStratum.stratum, self.wastePlot.plotNumber]];
                                //feedback = [feedback stringByAppendingString:FeedbackFailFilenameExist];
                                break;
                        }
                    }
                    if(rpt_success == YES){
                        feedback = [feedback stringByAppendingString:FeedbackSuccessful];
                    }else{
                        if( rpt_replace){
                            feedback = [[feedback stringByAppendingString:@" at least one report "] stringByAppendingString:FeedbackFailFilenameExist];
                        }else{
                            feedback = [[feedback stringByAppendingString:@" at least one report "] stringByAppendingString:FeedbackFailUnknown];
                        }
                    }
                    feedback = [feedback stringByAppendingString:@"\n"];
                }else{
                    feedback = [feedback stringByAppendingString:@"Plot Tally Report(s) : "];
                    BOOL rpt_success = YES;
                    BOOL rpt_replace = NO;
                    for( WasteStratum* s in self.wasteBlock.blockStratum){
                        for( WastePlot* p in s.stratumPlot){
                            switch ([rg generateReport:self.wasteBlock withPlot:p suffix:self.suffix.text replace:NO]){
                                case Successful:
                                    //feedback = [feedback stringByAppendingString:FeedbackSuccessful];
                                    break;
                                case Fail_Unknown:
                                    //feedback = [feedback stringByAppendingString:FeedbackFailUnknown];
                                    rpt_success = NO;
                                    break;
                                case Fail_Filename_Exist:
                                    rpt_success = NO;
                                    rpt_replace = YES;
                                    [self.replaceReports addObject:[NSString stringWithFormat:@"Plot Tally Report - %@ - %@", self.wastePlot.plotStratum.stratum, self.wastePlot.plotNumber]];
                                    //feedback = [feedback stringByAppendingString:FeedbackFailFilenameExist];
                                    break;
                            }
                        }
                    }
                    if(rpt_success == YES){
                        feedback = [feedback stringByAppendingString:FeedbackSuccessful];
                    }else{
                        if( rpt_replace){
                            feedback = [[feedback stringByAppendingString:@" at least one report "] stringByAppendingString:FeedbackFailFilenameExist];
                        }else{
                            feedback = [[feedback stringByAppendingString:@" at least one report "] stringByAppendingString:FeedbackFailUnknown];
                        }
                    }
                    feedback = [feedback stringByAppendingString:@"\n"];
                }
            }

        }
        
    
                [self finishReportGeneration:feedback replace:replace];
}

- (void) finishReportGeneration:(NSString *)feedback replace:(BOOL)replace{
    [self.loadingWheel stopAnimating];
    [self.loadingWheel setHidden:YES];

    if(replace){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report Generation" message:feedback delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }else{
        NSString *msgTitle = NSLocalizedString(@"Report Generation", nil);
        
        if([feedback rangeOfString:@"filename exists"].location != NSNotFound ){
            feedback = [feedback stringByAppendingString:@" Click Yes to replace the file? "];
            NSString *message = NSLocalizedString(feedback, nil);
            NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
            NSString *otherButtonTitleOne = NSLocalizedString(@"Yes", nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msgTitle message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitleOne, nil];
            
            [alert show];
            
        }else{

            NSString *message = NSLocalizedString(feedback, nil);
            NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msgTitle message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
            
            [alert show];
        }

    }
}

- (void) resetControls{

    [self.checkSummarySwitch setOn:NO];
    [self.fs702Switch setOn:NO];
    [self.plotTallySwitch setOn:NO];
    [self.blockTypeSummarySwitch setOn:NO];
    [self.plotPredictionSwitch setOn:NO];
    
    [self.suffix setText:@""];
    
    [self.loadingWheel stopAnimating];
    [self.loadingWheel setHidden:YES];
    
}

// CHARACTER LIMIT CHECK
/*
 TAG 0 = default NO (not editable)
 
 TAG 1 = 256 char max
 
 TAG 2 = 100 char max
 
 TAG 3 =  10 char max
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    
    switch (textField.tag) {
        case 1:
            return (newLength > 256) ? NO : YES;
            break;
            
        case 2:
            return (newLength > 100) ? NO : YES;
            break;
            
        case 3:
            return (newLength > 20) ? NO : YES;
            break;
            
        default:
            return NO; // NOT EDITABLE
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    //NSLog(@"");
}


@end
