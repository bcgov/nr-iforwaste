//
//  TimbermarkViewController.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-06.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "TimbermarkViewController.h"
#import "CodeDAO.h"
#import "WasteBlock.h"
#import "Timbermark.h"
#import "MonetaryReductionFactorCode.h"
#import "Timer.h"
#import "WasteCalculator.h"
#import "MaturityCode.h"
#import "UIColor+WasteColor.h"
#import "Constants.h"

@interface TimbermarkViewController ()

@end

@implementation TimbermarkViewController

@synthesize versionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void) setupLists{
    
   NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:@"monetaryReductionFactorCode" ascending:YES];
   self.wasteMonetaryReductionArray = [[[CodeDAO sharedInstance] getMonetaryReductionFactorCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
   self.wasteMonetaryReductionArray2 = [[[CodeDAO sharedInstance] getMonetaryReductionFactorCodeList] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set up the label text with special character
    self.primaryTMB.text = @"B = Established Benchmark (m\u00B3/ha)";
    self.primaryStumpageRate.text = @"Stumpage Rate ($/m\u00B3)";
    self.secondaryTMB.text = @"B = Established Benchmark (m\u00B3/ha)";
    self.secondaryStumpageRate.text = @"Stumpage Rate ($/m\u00B3)";
    
    if([self.wasteBlock.regionId intValue] == InteriorRegion){
        [self setUpViewInterior];
    }else if([self.wasteBlock.regionId intValue] == CoastRegion){
        [self setUpViewCoast];
    }
    
    self.contentOffset = NO;
    
    // Set up Drop Down Lists for Testing
    [self setupLists];
    
    // Picker View is created off screen
    _pickerViewContainer.frame = CGRectMake(0,1200,1024,260);
    
    
    
    self.wasteLevelPicker = [[UIPickerView alloc] init];
    self.wasteLevelPicker.dataSource = self;
    self.wasteLevelPicker.delegate = self;
    self.wasteLevelPicker.tag = 1;    self.primaryWasteMonetaryReduction.inputView = self.wasteLevelPicker;
    UITapGestureRecognizer *gr1 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(monetaryFactorRecognizer:)];
    [self.wasteLevelPicker addGestureRecognizer:gr1];
    gr1.delegate = self;
    
    
    self.wasteLevelPicker2 = [[UIPickerView alloc] init];
    self.wasteLevelPicker2.dataSource = self;
    self.wasteLevelPicker2.delegate = self;
    self.wasteLevelPicker2.tag = 2;
    self.secondaryWasteMonetaryReduction.inputView = self.wasteLevelPicker2;
    UITapGestureRecognizer *gr2 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(monetaryFactorRecognizer2:)];
    [self.wasteLevelPicker2 addGestureRecognizer:gr2];
    gr2.delegate = self;
    
    
    
    // KEYBOARD DISMISALL
    [self registerForKeyboardNotifications];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    
    self.secondTimbermarkExists = NO;
    
    [self populateFromObject];
    
    
    // disable the swipe ability at the left edge of screen
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    //set the background color for disabled field
    [self.primaryLoggingDate setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    [self.secondaryLoggingDate setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    [self.primaryHembal   setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    [self.primaryXgrade setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    [self.primaryYgrade setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    [self.secondaryHembal setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    [self.secondaryXgrade setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    [self.secondaryYgrade setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    
    // Populate version number
    [versionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteVersionNumber"]];
}



- (void)timerFireMethod:(NSTimer *)timer{
    
    [self saveData];
    
}

- (void)setUpViewInterior{
    self.primaryTMA.text = @"A = Avoidable (Gr 2 or better) (m\u00B3/ha)";
    self.secondaryTMA.text = @"A = Avoidable (Gr 2 or better) (m\u00B3/ha)";
    
    [self.primaryHembal setHidden:YES];
    [self.primaryBillingHembal setHidden:YES];
    [self.primaryLabelHembal setHidden:YES];
    [self.primaryXgrade setHidden:YES];
    [self.primaryBillingXgrade setHidden:YES];
    [self.primaryLabelXgrade setHidden:YES];
    
    self.primaryLabelYgrade.text = @"Grade 4(5)";
    [self setFrameY:(UIControl *)self.primaryLabelYgrade y:275];
    [self setFrameY:(UIControl *)self.primaryBillingYgrade y:275];
    [self setFrameY:(UIControl *)self.primaryYgrade y:275];

    [self.secondaryHembal setHidden:YES];
    [self.secondaryBillingHembal setHidden:YES];
    [self.secondaryLabelHembal setHidden:YES];
    [self.secondaryXgrade setHidden:YES];
    [self.secondaryBillingXgrade setHidden:YES];
    [self.secondaryLabelXgrade setHidden:YES];
    
    self.secondaryLabelYgrade.text = @"Grade 4(5)";
    [self setFrameY:(UIControl *)self.secondaryLabelYgrade y:670];
    [self setFrameY:(UIControl *)self.secondaryBillingYgrade y:670];
    [self setFrameY:(UIControl *)self.secondaryYgrade y:670];
    
    [self.primaryDeciduous setEnabled:YES];
    [self.primaryDeciduous setBackgroundColor:[UIColor whiteColor]];
    [self.secondaryDeciduous setEnabled:YES];
    [self.secondaryDeciduous setBackgroundColor:[UIColor whiteColor]];
    
    if([self.primaryDeciduous.text isEqualToString:@""]){
        self.primaryDeciduous.text = @"0.50";
    }
    if([self.secondaryDeciduous.text isEqualToString:@""]){
        self.secondaryDeciduous.text = @"0.50";
    }
}

- (void)setUpViewCoast{
    self.primaryTMA.text = @"A = Avoidable (x or better) (m\u00B3/ha)";
    self.secondaryTMA.text = @"A = Avoidable (x or better) (m\u00B3/ha)";
    
    [self.primaryHembal setHidden:NO];
    [self.primaryBillingHembal setHidden:NO];
    [self.primaryLabelHembal setHidden:NO];
    [self.primaryXgrade setHidden:NO];
    [self.primaryBillingXgrade setHidden:NO];
    [self.primaryLabelXgrade setHidden:NO];

    self.primaryLabelYgrade.text = @"Y Grade ($/m )";
    [self setFrameY:(UIControl *)self.primaryLabelYgrade y:348];
    [self setFrameY:(UIControl *)self.primaryBillingYgrade y:348];
    [self setFrameY:(UIControl *)self.primaryYgrade y:348];

    [self.secondaryHembal setHidden:NO];
    [self.secondaryBillingHembal setHidden:NO];
    [self.secondaryLabelHembal setHidden:NO];
    [self.secondaryXgrade setHidden:NO];
    [self.secondaryBillingXgrade setHidden:NO];
    [self.secondaryLabelXgrade setHidden:NO];
    
    self.secondaryLabelYgrade.text = @"Y Grade ($/m )";
    [self setFrameY:(UIControl *)self.secondaryLabelYgrade y:743];
    [self setFrameY:(UIControl *)self.secondaryBillingYgrade y:743];
    [self setFrameY:(UIControl *)self.secondaryYgrade y:743];

    [self.primaryDeciduous setEnabled:NO];
    [self.primaryDeciduous setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    [self.secondaryDeciduous setEnabled:NO];
    [self.secondaryDeciduous setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];


    if([self.primaryDeciduous.text isEqualToString:@""]){
        self.primaryDeciduous.text = @"1.00";
    }
    if([self.secondaryDeciduous.text isEqualToString:@""]){
        self.secondaryDeciduous.text = @"1.00";
    }
}

- (void) setFrameY:(UIControl *)ui y:(int)y{
    CGRect frame = ui.frame;
    frame.origin.y = y;
    ui.frame = frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}


// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}







// Called when the UIKeyboardDidShowNotification is sent.

- (void) keyboardWillBeHidden{
    
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    
    if ( ([self.secondaryWasteMonetaryReduction isFirstResponder] || [self.secondaryConifer isFirstResponder]) && !self.contentOffset ){
        
        
        UIScrollView *tmpScrollView = (UIScrollView*)[self.view.subviews objectAtIndex:0]; // original
        //UIScrollView *tmpScrollView = (UIScrollView*)self.view; // changed
        
        
        self.contentOffset = YES;
        
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height/2, 0.0); // keyboardsize move
        //UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0,0.0,44.0,0.0); // hardcode move
        
        
        
        //[tmpScrollView setContentOffset:CGPointMake(0.0, self.secondaryWasteMonetaryReduction.frame.origin.y) animated:YES]; // test

        
        
        tmpScrollView.contentInset = contentInsets;
        tmpScrollView.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        
 
        // CGRect aRect = tmpScrollView.frame;  //self.view.frame
        // aRect.size.height -= kbSize.height;
        // if ( !CGRectContainsPoint(aRect, self.secondaryConifer.frame.origin) ) {
        //    [tmpScrollView scrollRectToVisible:self.secondaryConifer.frame animated:YES];
        // }
 
    }
}







// ON BACKGROUND TAP
-(void)dismissKeyboard {
    //[self.notes resignFirstResponder];
    
    [self.view endEditing:YES];
    
    // [self.view resignFirstResponder];
}


/*
- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    if(!self.contentOffset){
        
        UIScrollView *tmpScrollView = (UIScrollView*)self.view;
        
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        if([self.secondaryWasteMonetaryReduction isFirstResponder]){
            CGRect bkgndRect = self.secondaryWasteMonetaryReduction.superview.frame;
            bkgndRect.size.height += kbSize.height;
            [self.secondaryWasteMonetaryReduction.superview setFrame:bkgndRect];
            [tmpScrollView setContentOffset:CGPointMake(0.0, self.secondaryWasteMonetaryReduction.frame.origin.y) animated:YES];
             self.contentOffset = YES;
        }
        else if([self.secondaryConifer isFirstResponder]){
            CGRect bkgndRect = self.secondaryConifer.superview.frame;
            bkgndRect.size.height += kbSize.height;
            [self.secondaryConifer.superview setFrame:bkgndRect];
            [tmpScrollView setContentOffset:CGPointMake(0.0, self.secondaryConifer.frame.origin.y) animated:YES];
             self.contentOffset = YES;
        }

    }
    
}
*/


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    /*
    int i=0;
    for (UIView *view in self.view.subviews) {
        NSLog(@" %d. Subview = %@",i,view);
        i++;
    }
     */
    //UIView *view = [self.view.subviews objectAtIndex:0];
    //NSLog(@" Subviews count = %d",[view.subviews count]);
    
    
    UIScrollView *tmpScrollView = [[(UIScrollView*)self.view subviews]objectAtIndex:0];
    //UIScrollView *tmpScrollView = (UIScrollView*)self.view;  // sometimes self.view is scrollView, othertimes, the self.view is UIView
    
    
    
    self.contentOffset = NO;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    tmpScrollView.contentInset = contentInsets;
    tmpScrollView.scrollIndicatorInsets = contentInsets;
    
}



// SAME ROW SELECT APPLY

- (void)monetaryFactorRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.wasteLevelPicker.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.wasteLevelPicker.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        // apply the first row
        MonetaryReductionFactorCode *mrfc = [self.wasteMonetaryReductionArray objectAtIndex:[self.wasteLevelPicker selectedRowInComponent:0]];
        self.primaryWasteMonetaryReduction.text = mrfc.desc;
        [self.primaryWasteMonetaryReduction resignFirstResponder];
    }
}

- (void)monetaryFactorRecognizer2:(UITapGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.wasteLevelPicker2.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.wasteLevelPicker2.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        // apply the first row
        MonetaryReductionFactorCode *mrfc = [self.wasteMonetaryReductionArray objectAtIndex:[self.wasteLevelPicker2 selectedRowInComponent:0]];
        self.secondaryWasteMonetaryReduction.text = mrfc.desc;
        [self.secondaryWasteMonetaryReduction resignFirstResponder];
    }
}
// enable multiple gesture recognizers, otherwise same row select wont detect taps
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // enable multiple gesture recognition
    return true;
}




// AUTO-SAVE
- (void)viewWillDisappear:(BOOL)animated{

    
    [self saveData];
    
    
    
    
}

// UPDATE VIEW
- (void)viewWillAppear:(BOOL)animated{
    //[super viewWillAppear:animated];
    //self.navigationController.toolbarHidden = NO;
    
    
    // populate data with new stuff
    // [self populateFromObject];
    
    [[Timer sharedManager] setCurrentVC:self];
    
    int row;
    
    // update monetaryFactor1 type picker selected row
    row = 0;
    for (MonetaryReductionFactorCode *mrfc in self.wasteMonetaryReductionArray) {
        
        
        
        if([self.primaryWasteMonetaryReduction.text isEqualToString:mrfc.desc]){
            [self.wasteLevelPicker selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }
    
    // update monetaryFactor2 type picker selected row
    row = 0;
    for (MonetaryReductionFactorCode *mrfc in self.wasteMonetaryReductionArray) {
        if([self.secondaryWasteMonetaryReduction.text isEqualToString:mrfc.desc]){
            [self.wasteLevelPicker2 selectRow:row inComponent:0 animated:NO];
            break;
        }
        row++;
    }

    // POPULATE FROM OBJECT TO VIEW
    [self populateFromObject];
    
}




// SAVE FROM VIEW TO OBJECT
- (void)saveData{
    
    NSLog(@"SAVE TIMBERMARK");

    //if the primary timber mark is not downloaded and user entered something for primary timbermark
    //create a empty timber mark object and the object will be updated at the end of this funciton
    
    
    if( ![self.primaryTimbermark.text isEqualToString:@""] && !self.primaryTimbermarkExists){
        NSManagedObjectContext *context = [self managedObjectContext];
        Timbermark *tm = [NSEntityDescription insertNewObjectForEntityForName:@"Timbermark" inManagedObjectContext:context];
        tm.primaryInd = [[NSNumber alloc] initWithInt:1];
        tm.area = [self.primaryArea.text isEqualToString:@""] ? [[NSDecimalNumber alloc] initWithFloat:0.0] : [[NSDecimalNumber alloc] initWithString:self.primaryArea.text];
        tm.surveyArea = [[NSDecimalNumber alloc] initWithFloat:0.0];
        tm.orgWMRF =[[NSDecimalNumber alloc] initWithFloat:0.0];
        tm.timbermark = @"";

        tm.timbermarkMonetaryReductionFactorCode = (MonetaryReductionFactorCode *)[[CodeDAO sharedInstance] getCodeByNameCode:@"monetaryReductionFactorCode" code:@"A"];
        
        //set benchmark based on cut block maturity
        if ([self.wasteBlock.blockMaturityCode.maturityCode isEqualToString:@"I"]){
            //for immature
            tm.benchmark = [[NSDecimalNumber alloc] initWithFloat:10.0];
        }else{
            // for mature
            tm.benchmark = [[NSDecimalNumber alloc] initWithFloat:35.0];
        }
        
        //default the master rate to zero
        tm.coniferWMRF = [[NSDecimalNumber alloc] initWithFloat:0.0];
        
        tm.xPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
        tm.yPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
        tm.hembalPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
        if ([_wasteBlock.regionId integerValue] == InteriorRegion){
            tm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:0.5];
        }else{
            tm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:1.0];
        }

        [self.wasteBlock addBlockTimbermarkObject:tm];

        [WasteCalculator calculateWMRF:self.wasteBlock  updateOriginal:YES];
        [WasteCalculator calculateRate:self.wasteBlock];

        self.primaryTimbermarkExists = YES;
    }

    
    if( ![self.secondaryTimbermark.text isEqualToString:@""] && !self.secondTimbermarkExists ){
        
        
        // TEST
        /*
        NSLog(@" SECONDARY FIELDS ");
        NSLog(@"timbermark = %@", self.secondaryTimbermark);
        NSLog(@"area = %@", self.secondaryArea);
        NSLog(@"monetaryFactorCode = %@", self.secondaryWasteMonetaryReduction);
        NSLog(@"coniferWMRF = %@", self.secondaryConifer);
        */
        // END TEST
        
        
        
        // create timbermark
        NSManagedObjectContext *context = [self managedObjectContext];
        Timbermark *tm = [NSEntityDescription insertNewObjectForEntityForName:@"Timbermark" inManagedObjectContext:context];
        tm.timbermark = self.secondaryTimbermark.text;
        tm.area = [self.secondaryArea.text isEqualToString:@""] ? [[NSDecimalNumber alloc] initWithFloat:0.0] : [[NSDecimalNumber alloc] initWithString:self.secondaryArea.text];
        tm.primaryInd = [[NSNumber alloc] initWithInt:2];
        
        //copy data from primary timbermark
        Timbermark *ptm =[[self.wasteBlock.blockTimbermark allObjects] objectAtIndex:0];
        tm.wmrf =ptm.wmrf;
        tm.benchmark = ptm.benchmark;
        tm.avoidable = ptm.avoidable;
        
        //default value for display
        tm.xPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
        tm.yPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
        tm.hembalPrice = [[NSDecimalNumber alloc] initWithFloat:0.25];
        if ([_wasteBlock.regionId integerValue] == InteriorRegion){
            tm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:0.5];
        }else{
            tm.deciduousPrice = [[NSDecimalNumber alloc] initWithFloat:1.0];
        }
        for (MonetaryReductionFactorCode* mrfc in self.wasteMonetaryReductionArray2){
            if ([mrfc.desc isEqualToString:self.secondaryWasteMonetaryReduction.text] ){
                tm.timbermarkMonetaryReductionFactorCode = mrfc;
                break;
            }
        }
        
        if( [tm.timbermarkMonetaryReductionFactorCode isKindOfClass:[NSNull class]]){
            tm.timbermarkMonetaryReductionFactorCode = ptm.timbermarkMonetaryReductionFactorCode;
        }
        
        tm.coniferWMRF = [self.secondaryConifer.text isEqualToString:@""] ? [[NSDecimalNumber alloc] initWithFloat:0.0] : [[NSDecimalNumber alloc] initWithString:self.secondaryConifer.text];
        
        
        
        
        
        // TEST
        /*
        NSLog(@" SECONDARY TIMBERMARK ");
        NSLog(@"timbermark = %@", tm.timbermark);
        NSLog(@"area = %@", tm.area);
        NSLog(@"monetaryFactorCode = %@", tm.timbermarkMonetaryReductionFactorCode);
        NSLog(@"coniferWMRF = %@", tm.coniferWMRF);
        */
        // END TEST
        
       // NSLog(@" CREATED SECONDARY TIMBERMARK \n\n");
        
        
        
        [self.wasteBlock addBlockTimbermarkObject:tm];
        
        self.secondTimbermarkExists = YES;
        
        //try to populate the value to the UI for new secondary TM
        [self populateFromObject];
    }
    
    
    //NSLog(@" FOR IN TIMBERMARKS");
    
    for (Timbermark* tm in self.timbermarks){
        
        // PRIMARY TIMBERMARK
        if( [tm.primaryInd intValue] == 1 ){
            tm.timbermark = self.primaryTimbermark.text;
            NSLog(@"primary timber mark name = %@", self.primaryTimbermark.text);
            tm.area = [self.primaryArea.text isEqualToString:@""] ? [[NSDecimalNumber alloc] initWithFloat:0.0] : [[NSDecimalNumber alloc] initWithString:self.primaryArea.text];
            
            for (MonetaryReductionFactorCode* mrfc in self.wasteMonetaryReductionArray){
                
                
                NSLog(@"primary label = %@", self.primaryWasteMonetaryReduction.text);
                if ([mrfc.desc isEqualToString:self.primaryWasteMonetaryReduction.text] ){
                    
                    tm.timbermarkMonetaryReductionFactorCode = mrfc;
                    break;
                }
            }
            
            tm.coniferWMRF = [self.primaryConifer.text isEqualToString:@""] ? [[NSDecimalNumber alloc] initWithFloat:0.0] : [[NSDecimalNumber alloc] initWithString:self.primaryConifer.text];
            tm.deciduousPrice = [self.primaryDeciduous.text isEqualToString:@""] ? [[NSDecimalNumber alloc] initWithFloat:0.0] : [[NSDecimalNumber alloc] initWithString:self.primaryDeciduous.text];
        }
        
        // SECONDARY TIMBERMARK
        else if( [tm.primaryInd intValue]== 2 ){
            
            tm.timbermark = self.secondaryTimbermark.text;
            NSLog(@"secondary timber mark name = %@", self.secondaryTimbermark.text);
            tm.area = [self.secondaryArea.text isEqualToString:@""] ? [[NSDecimalNumber alloc] initWithFloat:0.0] : [[NSDecimalNumber alloc] initWithString:self.secondaryArea.text];
            tm.primaryInd = [[NSNumber alloc] initWithInt:2];
            
            for (MonetaryReductionFactorCode* mrfc in self.wasteMonetaryReductionArray2){
                if ([mrfc.desc isEqualToString:self.secondaryWasteMonetaryReduction.text] ){
                    tm.timbermarkMonetaryReductionFactorCode = mrfc;
                    break;
                }
            }
            
            tm.coniferWMRF = [self.secondaryConifer.text isEqualToString:@""] ? [[NSDecimalNumber alloc] initWithFloat:0.0] : [[NSDecimalNumber alloc] initWithString:self.secondaryConifer.text];
            tm.deciduousPrice = [self.secondaryDeciduous.text isEqualToString:@""] ? [[NSDecimalNumber alloc] initWithFloat:0.0] : [[NSDecimalNumber alloc] initWithString:self.secondaryDeciduous.text];
            
            // TEST
            /*
            NSLog(@" SECONDARY TIMBERMARK ");
            NSLog(@"timbermark = %@", tm.timbermark);
            NSLog(@"area = %@", tm.area);
            NSLog(@"monetaryFactorCode = %@", tm.timbermarkMonetaryReductionFactorCode);
            NSLog(@"coniferWMRF = %@", tm.coniferWMRF);
            */
            // END TEST
            
            
            
        }
    }
    

    
    NSError *error;
    
    // save the whole cut block
    NSManagedObjectContext *context = [self managedObjectContext];
    [context save:&error];
    
    
    if( error != nil){
        NSLog(@" Error when saving waste block into Core Data: %@", error);
    }
    
    
    // TEST
    /*
    for (Timbermark *tm in self.timbermarks) {
        if([tm.primaryInd intValue] == 2){
            NSLog(@" SECONDARY TIMBERMARK ");
            NSLog(@"timbermark = %@", tm.timbermark);
            NSLog(@"area = %@", tm.area);
            NSLog(@"monetaryFactorCode = %@", tm.timbermarkMonetaryReductionFactorCode);
            NSLog(@"coniferWMRF = %@", tm.coniferWMRF);
            break;
        }
    }
    
    
    NSLog(@" SAVED TIMBERMARKS ");
    */
    // END TEST
    
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
        case 2:
            return self.wasteMonetaryReductionArray.count;
            break;
            
            
        default:
            return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    switch (pickerView.tag) {
        case 1:
        case 2:
            return [self.wasteMonetaryReductionArray[row] valueForKey:@"desc"];
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
            self.primaryWasteMonetaryReduction.text = [self.wasteMonetaryReductionArray[row] valueForKey:@"desc"];
            [self.primaryWasteMonetaryReduction resignFirstResponder];
            break;
            
        case 2:
            self.secondaryWasteMonetaryReduction.text = [self.wasteMonetaryReductionArray[row] valueForKey:@"desc"];
            [self.secondaryWasteMonetaryReduction resignFirstResponder];
            break;
            
        default:
            break;
    }
    
    
}



// TEXT EDITABLE - VALIDATE DOUBLE NAME ENTRIES
- (BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    
    
    [self.navigationController.navigationBar setUserInteractionEnabled:YES]; // test
    
    if (textField == self.primaryConifer || textField == self.secondaryConifer || textField == self.primaryArea || textField == self.secondaryArea ||
            textField == self.primaryWasteMonetaryReduction || textField == self.secondaryWasteMonetaryReduction || textField == self.primaryDeciduous || textField == self.secondaryDeciduous){
        
        [self saveData];

        [WasteCalculator calculateWMRF:self.wasteBlock  updateOriginal:YES];
        [WasteCalculator calculateRate:self.wasteBlock];
        [WasteCalculator calculatePiecesValue:self.wasteBlock];

        if([self.wasteBlock.userCreated intValue] ==1){
            [WasteCalculator calculateEFWStat:self.wasteBlock];
        }
        
        //save the changes again
        [self saveData];
        
        [self populateFromObject];

        return YES;
    }else{
        
        if( ! [self validTimbermarkEntry] ){
            NSString *title = NSLocalizedString(@"Invalid entry", nil);
            NSString *message = NSLocalizedString(@"Timbermark field cannot be a duplicate.", nil);
            NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
            
            [alert show];
            
            return NO;
        }
        
        return YES;
    }
    
}
- (BOOL) validTimbermarkEntry{

    // 2 empty
    if( [self.primaryTimbermark.text isEqualToString:@""] && [self.secondaryTimbermark.text isEqualToString:@""] )
    {
       
        //[self.view setUserInteractionEnabled:NO]; // test
        
        return YES;
    }
    else{
        
        NSString *t1 = self.primaryTimbermark.text;
        NSArray* words = [t1 componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
        t1 = [words componentsJoinedByString:@""];
        t1 = [t1 uppercaseString];
        
        
        NSString *t2 = self.secondaryTimbermark.text;
        NSArray* words2 = [t2 componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
        t2 = [words2 componentsJoinedByString:@""];
        t2 = [t2 uppercaseString];
        
        
        
        if( ![t1 isEqualToString:t2] ){
            [self.navigationController.navigationBar setUserInteractionEnabled:YES]; // test
        }
        else{
            [self.navigationController.navigationBar setUserInteractionEnabled:NO]; // test
        }
        
        return ![t1 isEqualToString:t2];
    }

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
    
    
    [self validTimbermarkEntry];
    
    // INPUT VALIDATION
    //
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str appendString:string];
    NSString *theString = str;
    // FLOAT VALUE ONLY
    if(textField==self.primaryArea || textField==self.secondaryArea ||
       textField==self.primaryConifer || textField==self.secondaryConifer ||
       textField == self.primaryDeciduous || textField == self.secondaryDeciduous)
    {
        if( ![self validInputNumbersOnlyWithDot:theString] ){
            return NO;
        }
    }
    
    //[self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
   // [self saveData];
    

    
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
            
        default:
            return NO; // NOT EDITABLE
    }
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
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

#pragma mark - IBActions

- (void)saveTimbermark:(id)sender{
    
    [self saveData];
    
    [self populateFromObject];
    
    
    NSString *title = NSLocalizedString(@"Save Timbermark", nil);
    NSString *message = NSLocalizedString(@"", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
	[alert show];
}

- (void) populateFromObject{
    
    // NIL TESTING
    //
    /*
    for (Timbermark* tm in self.timbermarks){
        
        // NSLog(@"timbermark id = %@",tm.primaryInd);
        
        if( tm.primaryInd == [[NSNumber alloc] initWithInt:1] ){
            tm.timbermark = nil;
            tm.area = nil;
            
            tm.timbermarkMonetaryReductionFactorCode = nil;
            
            tm.coniferWMRF = nil;
        }
        
        if( tm.primaryInd == [[NSNumber alloc] initWithInt:2] ){
            tm.timbermark = nil;
            tm.area = nil;
            
            tm.timbermarkMonetaryReductionFactorCode = nil;
            
            tm.coniferWMRF = nil;
        }
    }
    */
    //
    // END TESTING
    
    NSLog(@"POPULATE FROM OBJ");
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM-dd-yyyy"];

    self.primaryLoggingDate.text = [dateFormat stringFromDate:self.wasteBlock.loggingCompleteDate];

    for (Timbermark* tm in self.timbermarks){
        NSLog(@"timbermark primary ind %@", [tm.primaryInd stringValue]);
        
        // PRIMARY
        if ( [tm.primaryInd intValue] == 1  ){
            
            self.primaryTimbermarkExists = YES;
            if(tm.timbermark == nil){
                self.primaryTimbermark.text = @"";
            }else{
                self.primaryTimbermark.text = tm.timbermark;
            }
            self.primaryArea.text = tm.area && [tm.area floatValue] > 0 ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.area floatValue]] : @"";
            
            int row;
            // update monetaryFactor1 type picker selected row
            row = 0;
            for (MonetaryReductionFactorCode *mrfc in self.wasteMonetaryReductionArray) {
                
                if(tm.timbermarkMonetaryReductionFactorCode == mrfc){
                    [self.wasteLevelPicker selectRow:row inComponent:0 animated:NO];
                    self.primaryWasteMonetaryReduction.text = tm.timbermarkMonetaryReductionFactorCode ? tm.timbermarkMonetaryReductionFactorCode.desc : @"";
                    
                    break;
                }
                row++;
            }
            
            self.primaryAvoidableALabel.text = tm.avoidable ? [NSString stringWithFormat:@"%.4f", [tm.avoidable floatValue]] : @"";
            self.primaryBenchmarkLabel.text = tm.benchmark ? [NSString stringWithFormat:@"%.4f", [tm.benchmark floatValue]] : @"";
            self.primaryWMRFLabel.text = tm.wmrf ? [NSString stringWithFormat:@"%.4f", [tm.wmrf floatValue]] : @"";
            
            // stumpage rate column
            self.primaryConifer.text = tm.coniferWMRF && [tm.coniferWMRF floatValue] > 0 ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.coniferWMRF floatValue]] : @"";
            self.primaryBillingDeciduous.text = [[NSString alloc ] initWithFormat:@"%0.2f", [tm.deciduousWMRF floatValue]];
            self.primaryBillingHembal.text = [[NSString alloc ] initWithFormat:@"%0.2f", [tm.hembalWMRF floatValue]];
            self.primaryBillingXgrade.text = [[NSString alloc ] initWithFormat:@"%0.2f", [tm.xWMRF floatValue]];
            self.primaryBillingYgrade.text = [[NSString alloc ] initWithFormat:@"%0.2f", [tm.yWMRF floatValue]];
            
            // billing rate column
            self.primaryBillingConifer.text = tm.allSppJWMRF ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.allSppJWMRF floatValue]] : @"0.00";
            self.primaryDeciduous.text = tm.deciduousPrice ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.deciduousPrice floatValue]] : @"0.00";
            self.primaryHembal.text = tm.hembalPrice ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.hembalPrice floatValue]] : @"0.00";
            self.primaryXgrade.text = tm.xPrice ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.xPrice floatValue]] : @"0.00";
            self.primaryYgrade.text = tm.yPrice ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.yPrice floatValue]] : @"0.00";
            
        }
        
        // SECONDARY
        if ( [tm.primaryInd intValue] == 2 ){
            
            self.secondTimbermarkExists = YES;
            
            self.secondaryTimbermark.text = tm.timbermark ? tm.timbermark : @"";
            
            self.secondaryArea.text = tm.area && [tm.area floatValue] >0 ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.area floatValue]] : @"";
            
            
            //self.secondaryLoggingDate.text = [dateFormat stringFromDate:self.wasteBlock.loggingCompleteDate];
            
            
            
            /*
            NSLog(@" SECONDARY TIMBERMARK ");
            NSLog(@"timbermark = %@", tm.timbermark);
            NSLog(@"area = %@", tm.area);
            NSLog(@"benchmark = %@", tm.benchmark);
            NSLog(@"monetaryFactorCode = %@", tm.timbermarkMonetaryReductionFactorCode);
            NSLog(@"coniferWMRF = %@", tm.coniferWMRF);
            */
            
            
            int row;
            // update monetaryFactor1 type picker selected row
            row = 0;
            for (MonetaryReductionFactorCode *mrfc in self.wasteMonetaryReductionArray) {
                
                
                
                if(tm.timbermarkMonetaryReductionFactorCode == mrfc){
                    [self.wasteLevelPicker2 selectRow:row inComponent:0 animated:NO];
                    self.secondaryWasteMonetaryReduction.text = tm.timbermarkMonetaryReductionFactorCode ? tm.timbermarkMonetaryReductionFactorCode.desc : @"";
                    
                    break;
                }
                row++;
            }
            
            self.secondaryAvoidableALabel.text = tm.avoidable ? [NSString stringWithFormat:@"%.4f", [tm.avoidable floatValue]] : @"";
            self.secondaryBenchmarkLabel.text = tm.benchmark ? [NSString stringWithFormat:@"%.4f", [tm.benchmark floatValue]] : @"";
            self.secondaryWMRFLabel.text = tm.wmrf ? [NSString stringWithFormat:@"%.4f", [tm.wmrf floatValue]] : @"";
            
            // stumpage rate column
            self.secondaryConifer.text = tm.coniferWMRF && [tm.coniferWMRF floatValue] > 0 ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.coniferWMRF floatValue]] : @"";
            self.secondaryBillingDeciduous.text = [[NSString alloc ] initWithFormat:@"%0.2f", [tm.deciduousWMRF floatValue]];
            self.secondaryBillingHembal.text = [[NSString alloc ] initWithFormat:@"%0.2f", [tm.hembalWMRF floatValue]];
            self.secondaryBillingXgrade.text = [[NSString alloc ] initWithFormat:@"%0.2f", [tm.xWMRF floatValue]];
            self.secondaryBillingYgrade.text = [[NSString alloc ] initWithFormat:@"%0.2f", [tm.yWMRF floatValue]];
            
            // billing rate column
            self.secondaryBillingConifer.text = tm.coniferPrice ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.allSppJWMRF floatValue]] : @"";
            self.secondaryDeciduous.text = tm.deciduousPrice ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.deciduousPrice floatValue]] : @"";
            self.secondaryHembal.text = tm.hembalPrice ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.hembalPrice floatValue]] : @"";
            self.secondaryXgrade.text = tm.xPrice ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.xPrice floatValue]] : @"";
            self.secondaryYgrade.text = tm.yPrice ? [[NSString alloc ] initWithFormat:@"%0.2f",[tm.yPrice floatValue]] : @"";

        }
    }
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

- (BOOL) validInputAlphanumericOnly:(NSString*)theString{
    
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    
    return [[theString stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    
    
}

-(BOOL) validateArea{
    BOOL result = YES;
    NSDecimalNumber *total_tm_area = [[NSDecimalNumber alloc] initWithInt:0];
    for(Timbermark *tm in self.timbermarks){
        if(tm && tm.area){
            total_tm_area = [total_tm_area decimalNumberByAdding:tm.area];
        }
    }
    if([total_tm_area floatValue]!= [self.wasteBlock.surveyArea floatValue]){
        result = NO;
    }

    return result;
}

#pragma mark - Navigation
-(BOOL) navigationShouldPopOnBackButton
{
    [self saveData];
    if([self validateArea]){
        return YES;
    }else{
        UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Timbermark area does not equal Block Net Area." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *conBtn = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [userAlert addAction:okBtn];
        [userAlert addAction:conBtn];
        [self presentViewController:userAlert animated:YES completion:nil];
        return NO;
    }
}


@end
