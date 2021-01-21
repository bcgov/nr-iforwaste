//
//  SearchViewController.m
//  WasteMobile
//
//  Created by Administrator on 2014-03-25.
//

#import "SearchViewController.h"
#import "SWRevealViewController.h"
#import "WasteWebServiceManager.h"
#import "SearchResultsTableViewController.h"

@interface SearchViewController ()

@property (nonatomic, assign) BOOL searching;

@end

@implementation SearchViewController

@synthesize searchResult;
@synthesize reportingUnitId;
@synthesize versionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"(IFOR 102) Search";
    self.searching = NO;
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Populate version number
    [versionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteVersionNumber"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier  isEqual: @"pushSearch"]){
        // Send RU Id Stuff to Web Service
        
        // Consume Web Service data
        
        // Error getting/parsing data, display message
        // return NO;
        
        // Have the data, continue with the segue
        return YES;
    }
    return NO;
}

-(IBAction)searchCutBlock:(id)sender{
    if (! self.searching){
        self.searching = YES;

        [self.reportingUnitId resignFirstResponder];
        
        if (![self.reportingUnitId.text isEqualToString:@""]) {
            WasteWebServiceManager *wsm = [[WasteWebServiceManager alloc] init];
            self.searchResult = [wsm searchCutBlock: [NSNumber numberWithInteger:[self.reportingUnitId.text integerValue]]];
            [self performSegueWithIdentifier:@"pushSearchSegue" sender:self];
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSLog(@"Segue.id = %@\nSender = %@", segue.identifier, sender);
    
    if ( [segue.identifier isEqualToString:@"pushSearchSegue"]){
        SearchResultsTableViewController *searchResultVC = segue.destinationViewController;
        
        searchResultVC.searchResult = [[NSMutableArray alloc] initWithArray:self.searchResult];
        searchResultVC.reportingUnitNumber = [NSNumber numberWithInteger:[self.reportingUnitId.text integerValue]];
        
        NSLog(@"Transfer the search result DTO from search view to search result view, count = %lu", (unsigned long)searchResultVC.searchResult.count);
    }
}

@end