//
//  PieceValueTableViewController.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-04.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlotViewController.h"

@class NumberInputTableViewCell;
@class TextInputTableViewCell;
@class WasteBlock;

typedef enum {
    LookupMode,
    NumberMode,
    DecimalNumberMode,
    TextMode
}DisplayMode;

@interface PieceValueTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *lookupValues;
@property (assign, nonatomic) DisplayMode displayMode;
@property (assign, nonatomic) BOOL isLoopingProperty;

@property (strong, nonatomic) NSString *propertyName;
@property (strong, nonatomic) NSString *originalValue;
@property (strong, nonatomic) NSString *codeName;
@property (strong, nonatomic) NSNumber *existingNumberValue;

@property (strong, nonatomic) NSManagedObject *wastePiece;
@property (strong, nonatomic) WasteBlock *wasteBlock;

@property (weak, nonatomic) PlotViewController *plotVC;

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@property (weak, nonatomic) IBOutlet UITableView *inputTableView;

-(IBAction) doneEdit:(id)sender;

@end
