//
//  PileValueTableViewController.h
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-14.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PileViewController.h"

@class NumberInputTableViewCell;
@class TextInputTableViewCell;
@class WasteBlock;

typedef enum {
    LookupMode,
    NumberMode,
    DecimalNumberMode,
    TextMode
}DisplayMode;

@interface PileValueTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *lookupValues;
@property (assign, nonatomic) DisplayMode displayMode;
@property (assign, nonatomic) BOOL isLoopingProperty;

@property (strong, nonatomic) NSString *propertyName;
@property (strong, nonatomic) NSString *originalValue;
@property (strong, nonatomic) NSString *codeName;
@property (strong, nonatomic) NSNumber *existingNumberValue;

@property (strong, nonatomic) NSManagedObject *wastePile;
@property (strong, nonatomic) WasteBlock *wasteBlock;

@property (weak, nonatomic) PileViewController *pileVC;

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@property (weak, nonatomic) IBOutlet UITableView *inputTableView;

-(IBAction)doneEdit:(id)sender;
@end

