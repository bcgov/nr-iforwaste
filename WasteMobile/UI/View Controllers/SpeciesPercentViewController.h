//
//  SpeciesPercentViewController.h
//  WasteMobile
//
//  Created by Sweta Kutty on 2019-03-19.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WastePile+CoreDataClass.h"
#import "PileViewController.h"

@interface SpeciesPercentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *totalField;
@property (weak, nonatomic) IBOutlet UITextField *alPercent;
@property (weak, nonatomic) IBOutlet UITextField *arPercent;
@property (weak, nonatomic) IBOutlet UITextField *asPercent;
@property (weak, nonatomic) IBOutlet UITextField *baPercent;
@property (weak, nonatomic) IBOutlet UITextField *biPercent;
@property (weak, nonatomic) IBOutlet UITextField *cePercent;
@property (weak, nonatomic) IBOutlet UITextField *coPercent;
@property (weak, nonatomic) IBOutlet UITextField *cyPercent;
@property (weak, nonatomic) IBOutlet UITextField *fiPercent;
@property (weak, nonatomic) IBOutlet UITextField *hePercent;
@property (weak, nonatomic) IBOutlet UITextField *laPercent;
@property (weak, nonatomic) IBOutlet UITextField *loPercent;
@property (weak, nonatomic) IBOutlet UITextField *maPercent;
@property (weak, nonatomic) IBOutlet UITextField *spPercent;
@property (weak, nonatomic) IBOutlet UITextField *wbPercent;
@property (weak, nonatomic) IBOutlet UITextField *whPercent;
@property (weak, nonatomic) IBOutlet UITextField *wiPercent;
@property (weak, nonatomic) IBOutlet UITextField *uuPercent;
@property (weak, nonatomic) IBOutlet UITextField *yePercent;
- (IBAction)saveSpecies:(id)sender;

@property (strong, nonatomic) NSManagedObject *wastePile;
@property (strong, nonatomic) WasteBlock *wasteBlock;
@property (weak, nonatomic) PileViewController *pileVC;


@end

