//
//  AddPieceTableViewController.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-08-14.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPieceTableViewController : UITableViewController
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPieceButton;

- (IBAction) addPiece:(id) sender;

@end
