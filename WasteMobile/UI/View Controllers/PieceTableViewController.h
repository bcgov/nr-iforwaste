//
//  PieceTableViewController.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-08-12.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieceTableViewController : UITableViewController
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *approveBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *noTallyBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveChangeBarButton;

- (IBAction) changePieceCheck:(id)sender;

@end
