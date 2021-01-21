//
//  SearchViewController.h
//  WasteMobile
//
//  Created by Administrator on 2014-03-25.

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITextField *reportingUnitId;
@property (weak, nonatomic) IBOutlet UIButton *searchButtonAction;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (strong, nonatomic) NSArray *searchResult;

-(IBAction)searchCutBlock:(id)sender;

@end

