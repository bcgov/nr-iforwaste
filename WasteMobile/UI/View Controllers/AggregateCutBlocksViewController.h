//
//  AggregateCutBlocksViewController.h
//  EForWasteBC
//
//  Created by Chris Nesmith on 3/11/19.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface AggregateCutBlocksViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UILabel *addLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong) NSArray *blocks;

- (IBAction) addNewAggregateBlock:(id)sender;

@end
