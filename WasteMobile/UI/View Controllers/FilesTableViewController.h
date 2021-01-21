//
//  FilesTableViewController.h
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-14.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SWRevealViewController.h"

@interface FilesTableViewController : UITableViewController
    <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate>



@property (nonatomic, assign) BOOL sortFileNameAscending;
@property (nonatomic, assign) BOOL sortCreatedDateAscending;

-(IBAction)sortByFileName:(id)sender;
-(IBAction)sortByCreatedDate:(id)sender;

-(void)handleImportFile:(NSURL *)url;
@end
