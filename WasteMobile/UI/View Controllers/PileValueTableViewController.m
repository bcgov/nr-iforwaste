//
//  PileValueTableViewController.m
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-14.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "PileValueTableViewController.h"
#import "TextInputTableViewCell.h"
#import "NumberInputTableViewCell.h"
#import "PileViewController.h"
#import "WasteCalculator.h"
#import "WastePile+CoreDataClass.h"
#import "PileShapeCode+CoreDataClass.h"
#import "WastePlot.h"
#import "WasteStratum.h"
#import "WasteBlock.h"
#import "CodeDAO.h"
#import "WasteTypeCode.h"

@interface PileValueTableViewController ()

@property NSInteger selectLookUpIndex;

@end

@implementation PileValueTableViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self initLookup];
    
    //reset the select lookup index to -1
    self.selectLookUpIndex = -1;
}

-(void)initLookup{
    if([self.propertyName isEqualToString:@"measuredLength"]){
        self.title = @"(IFOR 205-1) Length";
        self.displayMode = DecimalNumberMode;
        self.propertyName = @"measuredLength";
        self.existingNumberValue = [self.wastePile valueForKey:self.propertyName];
    }else if([self.propertyName isEqualToString:@"measuredWidth"]){
        self.title = @"(IFOR 205-2) Width";
        self.displayMode = DecimalNumberMode;
        self.propertyName = @"measuredWidth";
        self.existingNumberValue = [self.wastePile valueForKey:self.propertyName];
    }else if([self.propertyName isEqualToString:@"measuredHeight"]){
        self.title = @"(IFOR 205-3) Height";
        self.displayMode = DecimalNumberMode;
        self.propertyName = @"measuredHeight";
        self.existingNumberValue = [self.wastePile valueForKey:self.propertyName];
    }else if([self.propertyName isEqualToString:@"pilePileShapeCode"]){
        self.title = @"(IFOR 205-4) Pile Shape Code";
        self.lookupValues = [[CodeDAO sharedInstance] getPileShapeCodeList];
        self.displayMode = LookupMode;
        self.propertyName = @"pilePileShapeCode";
        self.codeName = @"pileShapeCode";
    }else if([self.propertyName isEqualToString:@"comment"]){
        self.title = @"(IFOR 205-5) Comment";
        self.displayMode= TextMode;
        self.propertyName = @"comment";
        self.originalValue = [[self.wastePile valueForKey:@"comment"] isKindOfClass:[NSNull class]] ? @"" :[self.wastePile valueForKey:@"comment"] ;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = 1;
    
    if(self.displayMode == LookupMode ){
        num = lookupValues.count;
    }
    
    return num;
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

-(void)textUpdated{

    if(self.isLoopingProperty && [self.inputTextField.text length] > 3 && (!self.existingNumberValue || [self.existingNumberValue integerValue] == 0)){
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
        NSManagedObject *code = (NSManagedObject *)[lookupValues objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",[code valueForKey:self.codeName] ,[code valueForKey:@"desc"]];
        
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
        
        if ([tvc.numberField.text isEqualToString:@""]){
            [self.wastePile setValue:nil forKey:self.propertyName];
        }else{
            if (self.displayMode == DecimalNumberMode){
                [self.wastePile setValue:[[NSDecimalNumber alloc] initWithString:tvc.numberField.text] forKey:self.propertyName];
            }else if (self.displayMode == NumberMode){
                [self.wastePile setValue:[NSNumber numberWithInt:[tvc.numberField.text intValue]] forKey:self.propertyName];
            }
        }
        
        inputValue = tvc.numberField.text;
        
    }else if(self.displayMode == TextMode){
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        TextInputTableViewCell *tvc = (TextInputTableViewCell *)[self.inputTableView cellForRowAtIndexPath:indexPath];
        
        if ([tvc.textField.text isEqualToString:@""]){
            [self.wastePile setValue:nil forKey:self.propertyName];
        }else{
            [self.wastePile setValue:tvc.textField.text forKey:self.propertyName];
        }
        
        inputValue =tvc.textField.text;
        
    }else if(self.displayMode == LookupMode){
        
        if (self.selectLookUpIndex >= 0 ){
            [self.wastePile setValue:[self.lookupValues objectAtIndex:self.selectLookUpIndex ] forKey:self.propertyName];
            inputValue =[[self.lookupValues objectAtIndex:self.selectLookUpIndex ] valueForKey:self.codeName];
            self.selectLookUpIndex = -1;
        }
    }
    
    //calculate the piece stat
    WasteStratum *stratum =[self.wastePile valueForKey:@"pileStratum"];
   /* [WasteCalculator calculatePieceStat:(WastePiece *)self.wastePiece wasteStratum:plot.plotStratum];
    
    //NSLog(@"waste block : %@", ((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock);
    [WasteCalculator calculateWMRF:((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock updateOriginal:NO];
    [WasteCalculator calculateRate:((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock ];
    [WasteCalculator calculatePiecesValue:((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock];
    if([((WastePiece *)self.wastePiece ).piecePlot.plotStratum.stratumBlock.userCreated intValue] ==1){
        [WasteCalculator calculateEFWStat:((WastePiece*)self.wastePiece).piecePlot.plotStratum.stratumBlock];
    }*/
     //[WasteCalculator calculateEFWStat:((WastePile*)self.wastePile).pileStratum.stratumBlock];
    //udpate the current editing piece on plot viewcontroller
    [self.pileVC updateCurrentPileProperty:(WastePile*)self.wastePile property:self.propertyName];
    if(self.isLoopingProperty){
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
       [str appendString:string];
       NSString *theString = str;
       // FLOAT VALUE ONLY
       if(self.displayMode == DecimalNumberMode)
       {
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
    
    switch (textField.tag) {
        case 1:
            return (newLength > 4) ? NO : YES;
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
    
    //clear the current edit pile to stop auto-property looping
    [self.pileVC removeCurrentPile];
    
    return YES;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
