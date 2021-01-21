//
//  ChecksCompletedTableViewController.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-08-21.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface ChecksCompletedTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) NSArray *completedBlocks;

@end
