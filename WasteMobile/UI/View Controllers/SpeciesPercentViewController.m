//
//  SpeciesPercentViewController.m
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-19.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "SpeciesPercentViewController.h"
#import "PileViewController.h"
#import "WasteCalculator.h"
#import "WastePile+CoreDataClass.h"
#import "PileShapeCode+CoreDataClass.h"
#import "WastePlot.h"
#import "WasteStratum.h"
#import "WasteBlock.h"
#import "CodeDAO.h"
#import "WasteTypeCode.h"
#import "Constants.h"
#import "UIColor+WasteColor.h"

@interface SpeciesPercentViewController ()

@end

@implementation SpeciesPercentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initLookup];
    // KEYBOARD DISMISSAL
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    //[self.notes resignFirstResponder];
    [self.view endEditing:YES];
    
}

-(void)initLookup{

    self.alPercent.text =  [self.wastePile valueForKey:@"alPercent"] && [[self.wastePile valueForKey:@"alPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"alPercent"] intValue]] : @"";
    self.arPercent.text =  [self.wastePile valueForKey:@"arPercent"] && [[self.wastePile valueForKey:@"arPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"arPercent"] intValue]] : @"";
    self.asPercent.text =  [self.wastePile valueForKey:@"asPercent"] && [[self.wastePile valueForKey:@"asPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"asPercent"] intValue]] : @"";
    self.baPercent.text =  [self.wastePile valueForKey:@"baPercent"] && [[self.wastePile valueForKey:@"baPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"baPercent"] intValue]] : @"";
    self.biPercent.text =  [self.wastePile valueForKey:@"biPercent"] && [[self.wastePile valueForKey:@"biPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"biPercent"] intValue]] : @"";
    self.cePercent.text =  [self.wastePile valueForKey:@"cePercent"] && [[self.wastePile valueForKey:@"cePercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"cePercent"] intValue]] : @"";
    self.coPercent.text =  [self.wastePile valueForKey:@"coPercent"] && [[self.wastePile valueForKey:@"coPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"coPercent"] intValue]] : @"";
    self.cyPercent.text =  [self.wastePile valueForKey:@"cyPercent"] && [[self.wastePile valueForKey:@"cyPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"cyPercent"] intValue]] : @"";
    self.fiPercent.text =  [self.wastePile valueForKey:@"fiPercent"] && [[self.wastePile valueForKey:@"fiPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"fiPercent"] intValue]] : @"";
    self.hePercent.text =  [self.wastePile valueForKey:@"hePercent"] && [[self.wastePile valueForKey:@"hePercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"hePercent"] intValue]] : @"";
    self.laPercent.text =  [self.wastePile valueForKey:@"laPercent"] && [[self.wastePile valueForKey:@"laPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"laPercent"] intValue]] : @"";
    self.loPercent.text =  [self.wastePile valueForKey:@"loPercent"] && [[self.wastePile valueForKey:@"loPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"loPercent"] intValue]] : @"";
    self.maPercent.text =  [self.wastePile valueForKey:@"maPercent"] && [[self.wastePile valueForKey:@"maPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"maPercent"] intValue]] : @"";
    self.spPercent.text =  [self.wastePile valueForKey:@"spPercent"] && [[self.wastePile valueForKey:@"spPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"spPercent"] intValue]] : @"";
    self.wbPercent.text =  [self.wastePile valueForKey:@"wbPercent"] && [[self.wastePile valueForKey:@"wbPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"wbPercent"] intValue]] : @"";
    self.whPercent.text =  [self.wastePile valueForKey:@"whPercent"] && [[self.wastePile valueForKey:@"whPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"whPercent"] intValue]] : @"";
    self.wiPercent.text =  [self.wastePile valueForKey:@"wiPercent"] && [[self.wastePile valueForKey:@"wiPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"wiPercent"] intValue]] : @"";
    self.uuPercent.text =  [self.wastePile valueForKey:@"uuPercent"] && [[self.wastePile valueForKey:@"uuPercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"uuPercent"] intValue]] : @"";
    self.yePercent.text =  [self.wastePile valueForKey:@"yePercent"] && [[self.wastePile valueForKey:@"yePercent"] intValue] > 0? [[NSString alloc] initWithFormat:@"%d", [[self.wastePile valueForKey:@"yePercent"] intValue]] : @"";

}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if([self.wasteBlock.regionId integerValue] == CoastRegion){
        [self.laPercent setEnabled:NO];
        [self.laPercent setBackgroundColor:[UIColor disabledTextFieldBackgroundColor]];
    }
    
    [self calculateTotal];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveSpecies:(id)sender {
    
    if ([self.alPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"alPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.alPercent.text intValue]] forKey:@"alPercent"];
    }
    if ([self.arPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"arPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.arPercent.text intValue]] forKey:@"arPercent"];
    }
    if ([self.asPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"asPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.asPercent.text intValue]] forKey:@"asPercent"];
    }
    if ([self.baPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"baPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.baPercent.text intValue]] forKey:@"baPercent"];
    }
    if ([self.biPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"biPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.biPercent.text intValue]] forKey:@"biPercent"];
    }
    if ([self.cePercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"cePercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.cePercent.text intValue]] forKey:@"cePercent"];
    }
    if ([self.coPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"coPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.coPercent.text intValue]] forKey:@"coPercent"];
    }
    if ([self.cyPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"cyPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.cyPercent.text intValue]] forKey:@"cyPercent"];
    }
    if ([self.fiPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"fiPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.fiPercent.text intValue]] forKey:@"fiPercent"];
    }
    if ([self.hePercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"hePercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.hePercent.text intValue]] forKey:@"hePercent"];
    }
    if ([self.laPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"laPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.laPercent.text intValue]] forKey:@"laPercent"];
    }
    if ([self.loPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"loPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.loPercent.text intValue]] forKey:@"loPercent"];
    }
    if ([self.maPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"maPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.maPercent.text intValue]]forKey:@"maPercent"];
    }
    if ([self.spPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"spPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.spPercent.text intValue]] forKey:@"spPercent"];
    }
    if ([self.wbPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"wbPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.wbPercent.text intValue]] forKey:@"wbPercent"];
    }
    if ([self.whPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"whPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.whPercent.text intValue]] forKey:@"whPercent"];
    }
    if ([self.wiPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"wiPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.wiPercent.text intValue]] forKey:@"wiPercent"];
    }
    if ([self.uuPercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"uuPercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.uuPercent.text intValue]] forKey:@"uuPercent"];
    }
    if ([self.yePercent.text isEqualToString:@""]){
        [self.wastePile setValue:nil forKey:@"yePercent"];
    }else{
        [self.wastePile setValue:[NSNumber numberWithInt:[self.yePercent.text intValue]] forKey:@"yePercent"];
    }
    [self calculateTotal];
    //calculate the piece stat
    WasteStratum *plot =[self.wastePile valueForKey:@"pileStratum"];
    
    if (self.totalField.text.intValue > 100){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Total percentage value is greater than 100."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    //NSLog(@"plotPile %@", self.wastePile);
    //udpate the current editing piece on plot viewcontroller
   //[self.pileVC updateCurrentPileProperty:(WastePile*)self.wastePile property:self.propertyName];

    //[self.navigationController popViewControllerAnimated:YES];
}

# pragma mark - alertView
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
       [str appendString:string];
       NSString *theString = str;
    
    if( textField == self.alPercent || textField == self.arPercent || textField == self.asPercent || textField == self.baPercent || textField == self.biPercent || textField == self.cePercent || textField == self.coPercent || textField == self.cyPercent || textField == self.fiPercent || textField == self.hePercent || textField == self.laPercent || textField == self.loPercent || textField == self.maPercent || textField == self.spPercent || textField == self.wbPercent || textField == self.whPercent || textField == self.wiPercent || textField == self.uuPercent || textField == self.yePercent ){
        if( ![self validInputNumbersOnly:theString] ){
            return NO;
        }
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    switch (textField.tag) {
        case 1:
            return (newLength > 10) ? NO : YES;
            break;
        case 2:
            return (newLength > 256) ? NO : YES;
            break;
        case 4:
            return (newLength > 3) ? NO : YES;
            break;
        default:
            return NO; // NOT EDITABLE
    }
}
BOOL moved = NO;
double movementDistance = 0;
    -(void)textFieldDidBeginEditing:(UITextField *)textField {
        if(!moved) {
         movementDistance = (textField.frame.origin.y - 75) * -1;
         [self animateViewToPosition:self.view directionUP:YES];
        moved = YES;
      }
    }

    -(void)textFieldDidEndEditing:(UITextField *)textField {
         [textField resignFirstResponder];
        if(moved) {
               [self animateViewToPosition:self.view directionUP:NO];
            movementDistance = 0;
            }
           moved = NO;
     [self saveSpecies:textField];
    }

    -(BOOL)textFieldShouldReturn:(UITextField *)textField {
     [textField resignFirstResponder];
      if(moved) {
         [self animateViewToPosition:self.view directionUP:NO];
          movementDistance = 0;
      }
     moved = NO;
     [self saveSpecies:textField];
     
     return YES;
    }


    -(void)animateViewToPosition:(UIView *)viewToMove directionUP:(BOOL)up {

       const float movementDuration = 0.3f; // tweak as needed

       int movement = (up ? movementDistance : -movementDistance);
       [UIView beginAnimations: @"animateTextField" context: nil];
       [UIView setAnimationBeginsFromCurrentState: YES];
       [UIView setAnimationDuration: movementDuration];
       viewToMove.frame = CGRectOffset(viewToMove.frame, 0, movement);
       [UIView commitAnimations];
    }


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

#pragma mark navigation
-(BOOL) navigationShouldPopOnBackButton{
    
    //clear the current edit pile to stop auto-property looping
    [self.pileVC removeCurrentPile];
    
    return YES;
}

- (void) calculateTotal{
    int total = [self.alPercent.text intValue] + [self.arPercent.text intValue] + [self.asPercent.text intValue] + [self.baPercent.text intValue] + [self.biPercent.text intValue] + [self.cePercent.text intValue] + [self.coPercent.text intValue] + [self.cyPercent.text intValue] + [self.fiPercent.text intValue] + [self.hePercent.text intValue] + [self.laPercent.text intValue] + [self.loPercent.text intValue] + [self.maPercent.text intValue] + [self.spPercent.text intValue] + [self.wbPercent.text intValue] + [self.whPercent.text intValue] + [self.wiPercent.text intValue] + [self.uuPercent.text intValue] + [self.yePercent.text intValue];
    
    self.totalField.text = [NSString stringWithFormat:@"%d", total];
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

@end
