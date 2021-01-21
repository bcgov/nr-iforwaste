//
//  DownloadedTableViewController.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface DownloadedTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (nonatomic, assign) BOOL sortBlockAscending;
@property (nonatomic, assign) BOOL sortNetAreaAscending;

- (IBAction)sortByBlock:(id)sender;
- (IBAction)sortByNetArea:(id)sender;

- (IBAction)editAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)deleteAction:(id)sender;

@end
