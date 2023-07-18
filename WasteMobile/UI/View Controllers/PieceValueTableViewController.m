//
//  PieceValueTableViewController.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-04.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "PieceValueTableViewController.h"
#import "TextInputTableViewCell.h"
#import "NumberInputTableViewCell.h"
#import "PlotViewController.h"
#import "WasteCalculator.h"
#import "WastePiece.h"
#import "WastePlot.h"
#import "WasteStratum.h"
#import "WasteBlock.h"
#import "PlotSizeCode.h"
#import "MaterialKindCode.h"
#import "BorderlineCode.h"
#import "ScaleSpeciesCode.h"
#import "ScaleGradeCode.h"
#import "WasteClassCode.h"
#import "TopEndCode.h"
#import "ButtEndCode.h"
#import "StratumTypeCode.h"
#import "MaturityCode.h"
#import "AssessmentMethodCode.h"
#import "CommentCode.h"
#import "CodeDAO.h"

@interface PieceValueTableViewController ()

@property NSInteger selectLookUpIndex;

@end

@implementation PieceValueTableViewController

@synthesize lookupValues;
@synthesize inputTableView;
@synthesize originalValue;
@synthesize codeName;

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
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self initLookup];
    
    if (lookupValues){
        if ([self.codeName isEqualToString:@"scaleGradeCode"]){
            NSSortDescriptor *sort1 = [[NSSortDescriptor alloc ] initWithKey:@"areaType" ascending:YES];
            NSSortDescriptor *sort2 = [[NSSortDescriptor alloc ] initWithKey:self.codeName ascending:YES];
            NSArray *sortDes = [NSArray arrayWithObjects:sort1, sort2, nil];
            
            self.lookupValues = [self.lookupValues sortedArrayUsingDescriptors:sortDes];
        }else if ([self.codeName isEqualToString:@"materialKindCode"]){
            NSSortDescriptor *sort1 = [[NSSortDescriptor alloc ] initWithKey:@"effectiveDate" ascending:YES];
            NSArray *sortDes = [NSArray arrayWithObjects:sort1, nil];
            self.lookupValues = [self.lookupValues sortedArrayUsingDescriptors:sortDes];
        }else{
            NSSortDescriptor *sort = [[NSSortDescriptor alloc ] initWithKey:self.codeName ascending:YES];
            self.lookupValues = [self.lookupValues sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        }
    }
    
    //reset the select lookup index to -1
    self.selectLookUpIndex = -1;
}

-(void)initLookup{
    if([self.propertyName isEqualToString:@"pieceBorderlineCode"]){
        self.title = @"(IFOR 205-1) Border Line";
        self.lookupValues = [[CodeDAO sharedInstance] getBorderLineCodeList];
        self.displayMode = LookupMode;
        self.codeName = @"borderlineCode";
    }else if([self.propertyName isEqualToString:@"pieceScaleSpeciesCode"]){
        
        self.title = @"(IFOR 205-2) Species";
        self.lookupValues = [[CodeDAO sharedInstance] getScaleSpeciesCodeList];
        self.displayMode = LookupMode;
        self.propertyName = @"pieceScaleSpeciesCode";
        self.codeName = @"scaleSpeciesCode";
        
    }else if([self.propertyName isEqualToString:@"pieceMaterialKindCode"]){
        self.title = @"(IFOR 205-3) Material Kind";
        self.lookupValues = [[CodeDAO sharedInstance] getMaterialKindCodeList];
        self.displayMode = LookupMode;
        self.propertyName = @"pieceMaterialKindCode";
        self.codeName = @"materialKindCode";
    }else if([self.propertyName isEqualToString:@"pieceWasteClassCode"]){
        self.title = @"(IFOR 205-4) Waste Class";
        self.lookupValues = [[CodeDAO sharedInstance] getWasteClassCodeList];
        self.displayMode = LookupMode;
        self.propertyName = @"pieceWasteClassCode";
        self.codeName = @"wasteClassCode";
    }else if([self.propertyName isEqualToString:@"length"]){
        self.title = @"(IFOR 205-5) Gross Dimensions - Length";
        self.displayMode= NumberMode;
        self.propertyName = @"length";
        self.existingNumberValue = [self.wastePiece valueForKey:self.propertyName];
    }else if([self.propertyName isEqualToString:@"topDiameter"]){
        self.title = @"(IFOR 205-6) Gross Dimensions - Top";
        self.displayMode= NumberMode;
        self.propertyName = @"topDiameter";
        self.existingNumberValue = [self.wastePiece valueForKey:self.propertyName];
    }else if([self.propertyName isEqualToString:@"pieceTopEndCode"]){
        self.title = @"(IFOR 205-7) Gross Dimensions - Top End Code";
        self.lookupValues = [[CodeDAO sharedInstance] getTopEndCodeList];
        self.displayMode = LookupMode;
        self.propertyName = @"pieceTopEndCode";
        self.codeName = @"topEndCode";
    }else if([self.propertyName isEqualToString:@"buttDiameter"]){
        self.title = @"(IFOR 205-8) Gross Dimensions - Butt";
        self.displayMode= NumberMode;
        self.propertyName = @"buttDiameter";
        self.existingNumberValue = [self.wastePiece valueForKey:self.propertyName];
    }else if([self.propertyName isEqualToString:@"pieceButtEndCode"]){
        self.title = @"(IFOR 205-9) Gross Dimensions - Butt End Code";
        self.lookupValues = [[CodeDAO sharedInstance] getButtEndCodeList];
        self.displayMode = LookupMode;
        self.propertyName = @"pieceButtEndCode";
        self.codeName = @"buttEndCode";
    }else if([self.propertyName isEqualToString:@"pieceScaleGradeCode"]){
        self.title = @"(IFOR 205-10) Grade";
        self.lookupValues = [[CodeDAO sharedInstance] getScaleGradeCodeList:[self.wasteBlock.regionId intValue]];
        self.displayMode = LookupMode;
        self.propertyName = @"pieceScaleGradeCode";
        self.codeName = @"scaleGradeCode";
    }else if([self.propertyName isEqualToString:@"lengthDeduction"]){
        self.title = @"(IFOR 205-11) Deduction - Length";
        self.displayMode= NumberMode;
        self.propertyName = @"lengthDeduction";
    }else if([self.propertyName isEqualToString:@"topDeduction"]){
        self.title = @"(IFOR 205-12) Deduction - Top";
        self.displayMode= NumberMode;
        self.propertyName = @"topDeduction";
    }else if([self.propertyName isEqualToString:@"buttDeduction"]){
        self.title = @"(IFOR 205-13) Deduction - Butt";
        self.displayMode= NumberMode;
        self.propertyName = @"buttDeduction";
    }else if([self.propertyName isEqualToString:@"pieceDecayTypeCode"]){
        self.title = @"(IFOR 205-14) Decay Type Code";
        self.lookupValues = [[CodeDAO sharedInstance] getDecayTypeCodeList];
        self.displayMode = LookupMode;
        self.propertyName = @"pieceDecayTypeCode";
        self.codeName = @"decayTypeCode";
    }else if([self.propertyName isEqualToString:@"farEnd"]){
        self.title = @"(IFOR 205-15) Far End";
        self.displayMode= NumberMode;
        self.propertyName = @"farEnd";
    }else if([self.propertyName isEqualToString:@"addLength"]){
        self.title = @"(IFOR 205-16) Add Length";
        self.displayMode= NumberMode;
        self.propertyName = @"addLength";
    }else if([self.propertyName isEqualToString:@"pieceCommentCode"]){
        self.title = @"(IFOR 205-17) Comment Code";
        self.lookupValues = [[CodeDAO sharedInstance] getCommentCodeList];
        self.displayMode = LookupMode;
        self.propertyName = @"pieceCommentCode";
        self.codeName = @"commentCode";
    }else if([self.propertyName isEqualToString:@"notes"]){
        self.title = @"(IFOR 205-18) Note";
        self.displayMode= TextMode;
        self.propertyName = @"notes";
        self.originalValue = [[self.wastePiece valueForKey:@"notes"] isKindOfClass:[NSNull class]] ? @"" :[self.wastePiece valueForKey:@"notes"] ;
    }else if([self.propertyName isEqualToString:@"densityEstimate"]){
        self.title = @"(IFOR 205-19) Estimate (m\u00B3/ha)";
        self.displayMode= DecimalNumberMode;
        self.propertyName = @"densityEstimate";
    }else if([self.propertyName isEqualToString:@"estimatedVolume"]){
        self.title = @"(IFOR 205-20) Estimate Volume (m\u00B3)";
        self.displayMode= DecimalNumberMode;
        self.propertyName = @"estimatedVolume";
    }else if([self.propertyName isEqualToString:@"estimatedPercent"]){
        self.title = @"(IFOR 205-21) Percent Estimate";
        self.displayMode= DecimalNumberMode;
        self.propertyName = @"estimatedPercent";
    }


}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
   
    if (self.displayMode == NumberMode || self.displayMode == DecimalNumberMode){

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NumberInputTableViewCell *tvc = (NumberInputTableViewCell *)[self.inputTableView cellForRowAtIndexPath:indexPath];
        [tvc.numberField becomeFirstResponder];

    }else if(self.displayMode == TextMode){
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        TextInputTableViewCell *tvc = (TextInputTableViewCell *)[self.inputTableView cellForRowAtIndexPath:indexPath];
        tvc.textField.text = originalValue;
        originalValue = @"";
        [tvc.textField becomeFirstResponder];
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 1;

    if(self.displayMode == LookupMode ){
        //if ([self.codeName isEqualToString:@"commentCode"]){
        //    num = lookupValues.count + 1;
        //}else{
            num = lookupValues.count;
        //}
    }
    
    return num;
}

-(void)textUpdated{
    if(self.isLoopingProperty && [self.inputTextField.text length] > 1 && (!self.existingNumberValue || [self.existingNumberValue integerValue] == 0)){
        [self doneEdit:self.inputTextField];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    if (self.displayMode == NumberMode || self.displayMode == DecimalNumberMode){
        NumberInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NumberValueCellID" forIndexPath:indexPath];
        cell.numberField.text = self.originalValue;
        cell.numberField.tag = 1;
        [cell.numberField setDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textUpdated)
                                                     name: UITextFieldTextDidChangeNotification
                                                   object:cell.numberField];
        self.inputTextField = cell.numberField;
        
        return cell;
        
    }else if(self.displayMode == TextMode){
        TextInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextValueCellID" forIndexPath:indexPath];
        cell.textField.text = self.originalValue;
        cell.textField.tag = 2;
        [cell.textField setDelegate:self];
        return cell;
        
    }else if(self.displayMode == LookupMode){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LookupValueCellID" forIndexPath:indexPath];
         //if ([self.codeName isEqualToString:@"commentCode"]){
         //    if( indexPath.row == 0){
         //        cell.textLabel.text = @"[Empty]";
         //    }else {
         //        NSManagedObject *code = (NSManagedObject *)[lookupValues objectAtIndex:indexPath.row - 1];
         //        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",[code valueForKey:self.codeName] ,[code valueForKey:@"desc"]];
         //    }
         //}else{
             NSManagedObject *code = (NSManagedObject *)[lookupValues objectAtIndex:indexPath.row];
             cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",[code valueForKey:self.codeName] ,[code valueForKey:@"desc"]];
         //}
        return cell;
        
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectLookUpIndex = indexPath.row;
    
    if(self.displayMode == LookupMode){
        [self doneEdit:tableView];
    }
}

# pragma mark - alertView
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

# pragma IBAction
-(IBAction) doneEdit:(id)sender{
   
    NSString *inputValue = @"";
    
    if (self.displayMode == NumberMode || self.displayMode == DecimalNumberMode){
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NumberInputTableViewCell *tvc = (NumberInputTableViewCell *)[self.inputTableView cellForRowAtIndexPath:indexPath];
        //NSLog(@"old value: %@ for property: %@", [self.wastePiece valueForKey:self.propertyName] , self.propertyName );
        
        if ([tvc.numberField.text isEqualToString:@""]){
            [self.wastePiece setValue:nil forKey:self.propertyName];
        }else{
            if (self.displayMode == DecimalNumberMode){
                [self.wastePiece setValue:[[NSDecimalNumber alloc] initWithString:tvc.numberField.text] forKey:self.propertyName];
            }else if (self.displayMode == NumberMode){
                [self.wastePiece setValue:[NSNumber numberWithInt:[tvc.numberField.text intValue]] forKey:self.propertyName];
            }
        }
        //NSLog(@"new value: %@ for property: %@", tvc.numberField.text , self.propertyName );
        //NSLog(@" object for property: %@ - %@", self.propertyName, self.wastePiece);
        
        inputValue = tvc.numberField.text;
        
    }else if(self.displayMode == TextMode){
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        TextInputTableViewCell *tvc = (TextInputTableViewCell *)[self.inputTableView cellForRowAtIndexPath:indexPath];

        if ([tvc.textField.text isEqualToString:@""]){
            [self.wastePiece setValue:nil forKey:self.propertyName];
        }else{
            [self.wastePiece setValue:tvc.textField.text forKey:self.propertyName];
        }
        
        inputValue =tvc.textField.text;
        
    }else if(self.displayMode == LookupMode){
        
        if (self.selectLookUpIndex >= 0 ){
            //if ([self.codeName isEqualToString:@"commentCode"]){
            //    if (self.selectLookUpIndex == 0){
            //        [self.wastePiece setValue:nil forKey:self.propertyName];
            //        inputValue = @"[Empty]";
            //    }else{
            //        [self.wastePiece setValue:[self.lookupValues objectAtIndex:self.selectLookUpIndex - 1] forKey:self.propertyName];
            //        inputValue =[[self.lookupValues objectAtIndex:self.selectLookUpIndex - 1] valueForKey:self.codeName];
            //    }
            //}else{
                [self.wastePiece setValue:[self.lookupValues objectAtIndex:self.selectLookUpIndex ] forKey:self.propertyName];
                inputValue =[[self.lookupValues objectAtIndex:self.selectLookUpIndex ] valueForKey:self.codeName];
            //}
            
            self.selectLookUpIndex = -1;
        }
    }
    
    //calculate the piece stat
    WastePlot *plot =[self.wastePiece valueForKey:@"piecePlot"];
    [WasteCalculator calculatePieceStat:(WastePiece *)self.wastePiece wasteStratum:plot.plotStratum];
    
    //NSLog(@"waste block : %@", ((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock);
    [WasteCalculator calculateWMRF:((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock updateOriginal:NO];
    [WasteCalculator calculateRate:((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock ];
    [WasteCalculator calculatePiecesValue:((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock];
    if([((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock.userCreated intValue] ==1){
        [WasteCalculator calculateEFWStat:((WastePiece*)self.wastePiece).piecePlot.plotStratum.stratumBlock];
    }

    //udpate the current editing piece on plot viewcontroller
    [self.plotVC updateCurrentPieceProperty:(WastePiece*)self.wastePiece property:self.propertyName];
    if(self.isLoopingProperty){
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


//validation - this will return one error message at a time
- (NSString *) validateInputFieldByName:(NSString *)fieldName wastePiece:(WastePiece *)wp inputValue:(NSString *)inputValue {
    
    //check for "If Stratum Type is Dispersed (D?) and Material Kind = 'W' then Butt End Code cannot be 'B'"
    if ([fieldName isEqualToString:@"pieceMaterialKindCode"] || [fieldName isEqualToString:@"pieceButtEndCode"]){
        if ([wp.piecePlot.plotStratum.stratumStratumTypeCode.stratumTypeCode isEqualToString:@"D"] && [wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"W"]
            && [wp.pieceButtEndCode.buttEndCode isEqualToString:@"B"]){
            return @"Error - Stratum Type 'D' and Kind 'W', Butt End Code can't be 'B'.";
        }
    }
    
    //check for "If 'Material Kind' = 'S' grade cannot be 'Y'"
    if ([fieldName isEqualToString:@"pieceMaterialKindCode"] || [fieldName isEqualToString:@"pieceScaleGradeCode"]){
        if ([wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"S"] && [wp.pieceScaleGradeCode.scaleGradeCode isEqualToString:@"Y"]){
            return @"Error - Kind 'S', Grade can't be 'Y'.";
        }
    }
    
    //check for "If 'Material Kind' = 'L', Length must be greater than or equal to 3.0 m (30 dm) unless Borderline = 'B'"
    if ([fieldName isEqualToString:@"pieceMaterialKindCode"] || [fieldName isEqualToString:@"length"]){
        if (![wp.pieceBorderlineCode.borderlineCode isEqualToString:@"B"] && [wp.pieceMaterialKindCode.materialKindCode isEqualToString:@"L"] && [wp.length intValue] < 30){
            return @"Error - When Kind is 'L', length must be >= 30.";
        }
    }
    
    
    if ([fieldName isEqualToString:@"topDiameter"] || [fieldName isEqualToString:@"buttDiameter"]){
        //check against minimum radius
        int minR = 0;
        
        if ([wp.piecePlot.plotStratum.stratumBlock.blockCheckMaturityCode.maturityCode isEqualToString:@"M"]){
            minR = 5;
        }else if([wp.piecePlot.plotStratum.stratumBlock.blockCheckMaturityCode.maturityCode isEqualToString:@"I"]){
            minR = 8;
        }
        
        if([fieldName isEqualToString:@"topDiameter"]){
            // top < minimum radius
            if ([wp.topDiameter intValue] < minR ){
                return [NSString stringWithFormat:@"Error - Top cannot be less than %d", minR];
            }
        }

        if( [fieldName isEqualToString:@"topDiameter"] || [fieldName isEqualToString:@"buttDiameter"]){
            
            if( [wp.topDiameter intValue] >= [wp.buttDiameter intValue]){
                return @"Error - Top dimenstion must be less than Butt dimension.";
            }
        }
    }

    if ([fieldName isEqualToString:@"length"] || [fieldName isEqualToString:@"lengthDeduction"]){
        
        if( [wp.length intValue] < [wp.lengthDeduction intValue]){
            return @"Error - Deduction length cannot exceed log length.";
        }
    }
    
    
    // Warning
    
    if ([fieldName isEqualToString:@"length"]){
        
        if( [wp.length intValue] > 220){
            return @"Warning - Length should not exceed 22m";
        }
    }
    
    if ([fieldName isEqualToString:@"topDiameter"] || [fieldName isEqualToString:@"buttDiameter"] || [fieldName isEqualToString:@"length"]){

        if( [wp.topDiameter intValue] >= [wp.buttDiameter intValue] - [wp.length intValue]){
            return @"Warning - Top should be less then (Butt - Length * 1.0).";
        }

        if( [wp.buttDiameter intValue] < [wp.topDiameter intValue] + [wp.length intValue]){
            return @"Warning - Butt should not be less then (Top + Length * 1.0).";
        }
    }
    
    return @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    switch (textField.tag) {
        case 1:
            return (newLength > 10) ? NO : YES;
            break;
        case 2:
            return (newLength > 256) ? NO : YES;
            break;
            
        default:
            return NO; // NOT EDITABLE
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    [self doneEdit:textField];
    
    return YES;
}
#pragma mark navigation
-(BOOL) navigationShouldPopOnBackButton{
    
    //clear the current edit piece to stop auto-property looping
    [self.plotVC removeCurrentPiece];
    
    return YES;
}

@end
