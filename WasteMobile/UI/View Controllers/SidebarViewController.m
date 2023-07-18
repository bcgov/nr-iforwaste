//
//  SidebarViewController.m
//  SidebarDemo
//
//  Created by Salus.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "BlockViewController.h"
#import "WasteBlockDAO.h"
#import "Constants.h"

@interface SidebarViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic) NewCutBlockOptions currentNewCutBlock;

@end

@implementation SidebarViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"iFORWASTE"] ){
        _menuItems = @[@"title", @"Search", @"Downloaded", @"Reports", @"Files"];
    }else if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        _menuItems = @[@"title", @"newblock", @"created", @"Reports", @"Files"];
    }
    self.currentNewCutBlock = NotSelected;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"iForWaste"] ){
        // do nothing
    }else if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        if(indexPath.row == 1){
            [self newCutBlock:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [self.menuItems count];
    /*
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"iFORWASTE"] ){
        return 7;
    }else if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]){
        return 5;
    }*/
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[_menuItems objectAtIndex:indexPath.row] capitalizedString];
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
        if ([destViewController isKindOfClass:[BlockViewController class]]){
            UITableViewCell *cell = (UITableViewCell *) sender;
            if(cell.tag == 0 ){
                [self newCutBlock: sender];
            }else{
                BlockViewController *bvc = (BlockViewController*)destViewController;
                int region = (int)cell.tag;
                BOOL ratioSample = (self.currentNewCutBlock == InteriorRatio);

                // reset currentNewCutBlock
                self.currentNewCutBlock = NotSelected;

                bvc.wasteBlock = [WasteBlockDAO createEmptyCutBlock:region ratioSample:ratioSample];
                cell.tag = 0;
            }
        }
    }
    
}

- (IBAction)newCutBlock:(id)sender{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"New Cut Block"
                                                                   message:@"Please select a region."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* interiorSRSAction = [UIAlertAction actionWithTitle:@"Interior Block (SRS Survey)" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               UITableViewCell *cell = (UITableViewCell *) sender;
                                                               //pass some data through the cell object to segue
                                                               cell.tag = InteriorRegion;
                                                               self.currentNewCutBlock = InteriorSRS;
                                                               [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];

    UIAlertAction* interiorRatioAction = [UIAlertAction actionWithTitle:@"Interior Block (Ratio Sampling)" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               UITableViewCell *cell = (UITableViewCell *) sender;
                                                               //pass some data through the cell object to segue
                                                               cell.tag = InteriorRegion;
                                                               self.currentNewCutBlock = InteriorRatio;
                                                               [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
    
    UIAlertAction* coastAction = [UIAlertAction actionWithTitle:@"Coast Block" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                        
                                                            UITableViewCell *cell = (UITableViewCell *) sender;
                                                            cell.tag = CoastRegion;
                                                            self.currentNewCutBlock = CoastSRS;
                                                            [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             [self dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:interiorSRSAction];
    [alert addAction:interiorRatioAction];
    [alert addAction:coastAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
