//
//  SearchResultsTableViewController.h
//  WasteMobile
//
//  Created by Salus
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"


@interface SearchResultsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;

@property (strong, nonatomic) NSArray *searchResult;
@property (strong, nonatomic) NSNumber *reportingUnitNumber;
@property (strong, nonatomic) NSString *cutBlockId;

@end
