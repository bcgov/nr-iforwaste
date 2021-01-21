//
//  CreatedTableViewController.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-09-30.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface CreatedTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIButton *sortByRUButton;
@property (weak, nonatomic) IBOutlet UIButton *sortByNetButton;
@property (weak, nonatomic) IBOutlet UIButton *sortByTMButton;
@property (weak, nonatomic) IBOutlet UIButton *sortByDateButton;
@property (weak, nonatomic) IBOutlet UIButton *sortByBlockButton;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) NSString *sortColumn;

- (IBAction)sortBlock:(id)sender;
- (IBAction)editAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)deleteAction:(id)sender;

@end
