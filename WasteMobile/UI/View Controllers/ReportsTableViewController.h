//
//  ReportsTableViewController.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SWRevealViewController.h"

@interface ReportsTableViewController : UITableViewController <UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIDocumentInteractionController *documentIC;

@end
