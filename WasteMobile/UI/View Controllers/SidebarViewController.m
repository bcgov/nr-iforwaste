//
//  SidebarViewController.m
//  SidebarDemo
//
//  Created by Salus.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "BlockViewController.h"
#import "WasteBlock.h"
#import "WasteBlockDAO.h"
#import "Constants.h"

@interface SidebarViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic) NewCutBlockOptions currentNewCutBlock;
@property (nonatomic) NSNumber *aggregateNumBlocks;
@property (nonatomic) NSDecimalNumber *aggregateArea;
@property (nonatomic) NSNumber *aggregatePredictionPlots;
@property (nonatomic) NSNumber *aggregateMeasurePlots;


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

    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"iFORWASTE"] ){
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
            }
            else if(self.currentNewCutBlock == InteriorAggregate)
            {
                BlockViewController *bvc = (BlockViewController*)destViewController;
                
                //region and ratio sample should always be the same for this type
                
                BOOL isAggregate = TRUE;
                BOOL ratioSample = TRUE;
                int region = InteriorRegion;
                
                bvc.wasteBlock = [WasteBlockDAO createEmptyCutBlock:region ratioSample:ratioSample isAggregate:isAggregate];
                cell.tag = 0;
            }
            else if(self.currentNewCutBlock == CoastAggregate)
            {
                BlockViewController *bvc = (BlockViewController*)destViewController;
                
                //region and ratio sample should always be the same for this type
                
                BOOL isAggregate = TRUE;
                BOOL ratioSample = TRUE;
                int region = CoastRegion;
                
                bvc.wasteBlock = [WasteBlockDAO createEmptyCutBlock:region ratioSample:ratioSample isAggregate:isAggregate];
                cell.tag = 0;
            }
            else if(self.currentNewCutBlock == InteriorAggregateSRS)
            {
                BlockViewController *bvc = (BlockViewController*)destViewController;
                
                //region and ratio sample should always be the same for this type
                
                BOOL isAggregate = TRUE;
                BOOL ratioSample = FALSE;
                int region = InteriorRegion;
                
                bvc.wasteBlock = [WasteBlockDAO createEmptyCutBlock:region ratioSample:ratioSample isAggregate:isAggregate];
                cell.tag = 0;
            }
            else if(self.currentNewCutBlock == CoastAggregateSRS)
            {
                BlockViewController *bvc = (BlockViewController*)destViewController;
                BOOL isAggregate = TRUE;
                BOOL ratioSample = FALSE;
                int region = CoastRegion;
                
                bvc.wasteBlock = [WasteBlockDAO createEmptyCutBlock:region ratioSample:ratioSample isAggregate:isAggregate];
                cell.tag = 0;
            }
            else if(self.currentNewCutBlock == CoastRatio){
                BlockViewController *bvc = (BlockViewController*)destViewController;
                int region = (int)cell.tag;
                BOOL ratioSample = (self.currentNewCutBlock == CoastRatio);
                BOOL isAggregate = false;
                
                // reset currentNewCutBlock
                self.currentNewCutBlock = NotSelected;
                
                bvc.wasteBlock = [WasteBlockDAO createEmptyCutBlock:region ratioSample:ratioSample isAggregate:isAggregate];
                cell.tag = 0;
            }
            else{
                BlockViewController *bvc = (BlockViewController*)destViewController;
                int region = (int)cell.tag;
                BOOL ratioSample = (self.currentNewCutBlock == InteriorRatio);
                BOOL isAggregate = false;

                // reset currentNewCutBlock
                self.currentNewCutBlock = NotSelected;

                bvc.wasteBlock = [WasteBlockDAO createEmptyCutBlock:region ratioSample:ratioSample isAggregate:isAggregate];
                cell.tag = 0;
            }
            
        }
    }
    
}

- (IBAction)newCutBlock:(id)sender{
    /*UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"New Cut Block"
                                                                   message:@"Please select a region."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* interiorSRSAction = [UIAlertAction actionWithTitle:@"Interior Block (Single Block SRS Survey)" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               UITableViewCell *cell = (UITableViewCell *) sender;
                                                               //pass some data through the cell object to segue
                                                               cell.tag = InteriorRegion;
                                                               self.currentNewCutBlock = InteriorSRS;
                                                               [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
    UIAlertAction* interiorRatioAction = [UIAlertAction actionWithTitle:@"Interior Block (Single Block Ratio Sampling)" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               UITableViewCell *cell = (UITableViewCell *) sender;
                                                               //pass some data through the cell object to segue
                                                               cell.tag = InteriorRegion;
                                                               self.currentNewCutBlock = InteriorRatio;
                                                               [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
    UIAlertAction* interiorAggregateSRSAction = [UIAlertAction actionWithTitle:@"Interior Block (Aggregate SRS Survey)" style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * action) {
                                                                        UITableViewCell *cell = (UITableViewCell *) sender;
                                                                        //pass some data through the cell object to segue
                                                                        cell.tag = InteriorRegion;
                                                                        self.currentNewCutBlock = InteriorAggregateSRS;
                                                                        [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    }];
    UIAlertAction* interiorAggregateAction = [UIAlertAction actionWithTitle:@"Interior Block (Aggregate Ratio Sampling)" style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                    UITableViewCell *cell = (UITableViewCell *) sender;
                                                                    //pass some data through the cell object to segue
                                                                    cell.tag = InteriorRegion;
                                                                    self.currentNewCutBlock = InteriorAggregate;
                                                                    [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                }];
    UIAlertAction* coastAction = [UIAlertAction actionWithTitle:@"Coast Block(Single Block SRS Survey)" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                        
                                                            UITableViewCell *cell = (UITableViewCell *) sender;
                                                            cell.tag = CoastRegion;
                                                            self.currentNewCutBlock = CoastSRS;
                                                            [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    UIAlertAction* coastRatioAction = [UIAlertAction actionWithTitle:@"Coast Block(Single Block Ratio Sampling)" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            
                                                            UITableViewCell *cell = (UITableViewCell *) sender;
                                                            cell.tag = CoastRegion;
                                                            self.currentNewCutBlock = CoastRegion;
                                                            [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    UIAlertAction* coastAggregateSRSAction = [UIAlertAction actionWithTitle:@"Coast Block(Aggregate SRS Survey)" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 
                                                                 UITableViewCell *cell = (UITableViewCell *) sender;
                                                                 cell.tag = CoastRegion;
                                                                 self.currentNewCutBlock = CoastAggregateSRS;
                                                                 [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
    UIAlertAction* coastAggregateAction = [UIAlertAction actionWithTitle:@"Coast Block(Aggregate Ratio Sampling)" style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * action) {
                                                                        
                                                                        UITableViewCell *cell = (UITableViewCell *) sender;
                                                                        cell.tag = CoastRegion;
                                                                        self.currentNewCutBlock = CoastAggregate;
                                                                        [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             [self dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:interiorSRSAction];
    [alert addAction:interiorRatioAction];
    [alert addAction:interiorAggregateSRSAction];
    [alert addAction:interiorAggregateAction];
    [alert addAction:coastAction];
    [alert addAction:coastRatioAction];
    [alert addAction:coastAggregateSRSAction];
    [alert addAction:coastAggregateAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];*/
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Please select a region."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* interiorAction = [UIAlertAction actionWithTitle:@"Interior" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  UITableViewCell *cell = (UITableViewCell *) sender;
                                                                  //pass some data through the cell object to segue
                                                                  cell.tag = InteriorRegion;
                                                                  int region = InteriorRegion;
                                                                  [self promptForSurveyMethod:sender region:region];
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                              }];
    
    UIAlertAction* coastAction = [UIAlertAction actionWithTitle:@"Coast" style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                    UITableViewCell *cell = (UITableViewCell *) sender;
                                                                    //pass some data through the cell object to segue
                                                                    cell.tag = CoastRegion;
                                                                    int region = CoastRegion;
                                                                    [self promptForSurveyMethod:sender region:region];
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                            }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                   handler:^(UIAlertAction * action) {
                           [self dismissViewControllerAnimated:YES completion:nil];
                   }];
    
    [alert addAction:interiorAction];
    [alert addAction:coastAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)promptForSurveyMethod:(id)sender region:(int)region{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Please select a survey method."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    if(region == 2){
        UIAlertAction* interiorSRSAction = [UIAlertAction actionWithTitle:@"Single Block SRS Survey" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      UITableViewCell *cell = (UITableViewCell *) sender;
                                                                      //pass some data through the cell object to segue
                                                                      cell.tag = InteriorRegion;
                                                                      self.currentNewCutBlock = InteriorSRS;
                                                                      [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                                  }];
        
        UIAlertAction* interiorRatioAction = [UIAlertAction actionWithTitle:@"Single Block Ratio Sampling" style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * action) {
                                                                        UITableViewCell *cell = (UITableViewCell *) sender;
                                                                        //pass some data through the cell object to segue
                                                                        cell.tag = InteriorRegion;
                                                                        self.currentNewCutBlock = InteriorRatio;
                                                                        [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    }];
        
        UIAlertAction* interiorAggregateSRSAction = [UIAlertAction actionWithTitle:@"Aggregate SRS Survey" style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * action) {
                                                                               UITableViewCell *cell = (UITableViewCell *) sender;
                                                                               //pass some data through the cell object to segue
                                                                               cell.tag = InteriorRegion;
                                                                               self.currentNewCutBlock = InteriorAggregateSRS;
                                                                               [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                                           }];
        
        UIAlertAction* interiorAggregateAction = [UIAlertAction actionWithTitle:@"Aggregate Ratio Sampling" style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) {
                                                                            UITableViewCell *cell = (UITableViewCell *) sender;
                                                                            //pass some data through the cell object to segue
                                                                            cell.tag = InteriorRegion;
                                                                            self.currentNewCutBlock = InteriorAggregate;
                                                                            [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                                        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 UITableViewCell *cell = (UITableViewCell *) sender;
                                                                 cell.tag = 0;
                                                                 [self dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        
        [alert addAction:interiorSRSAction];
        [alert addAction:interiorRatioAction];
        [alert addAction:interiorAggregateSRSAction];
        [alert addAction:interiorAggregateAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }else if(region == 1) {
        UIAlertAction* coastAction = [UIAlertAction actionWithTitle:@"Single Block SRS Survey" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                
                                                                UITableViewCell *cell = (UITableViewCell *) sender;
                                                                cell.tag = CoastRegion;
                                                                self.currentNewCutBlock = CoastSRS;
                                                                [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                            }];
        
        UIAlertAction* coastRatioAction = [UIAlertAction actionWithTitle:@"Single Block Ratio Sampling" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     
                                                                     UITableViewCell *cell = (UITableViewCell *) sender;
                                                                     cell.tag = CoastRegion;
                                                                     self.currentNewCutBlock = CoastRegion;
                                                                     [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
        
        UIAlertAction* coastAggregateSRSAction = [UIAlertAction actionWithTitle:@"Aggregate SRS Survey" style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) {
                                                                            
                                                                            UITableViewCell *cell = (UITableViewCell *) sender;
                                                                            cell.tag = CoastRegion;
                                                                            self.currentNewCutBlock = CoastAggregateSRS;
                                                                            [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                                        }];
        
        UIAlertAction* coastAggregateAction = [UIAlertAction actionWithTitle:@"Aggregate Ratio Sampling" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         
                                                                         UITableViewCell *cell = (UITableViewCell *) sender;
                                                                         cell.tag = CoastRegion;
                                                                         self.currentNewCutBlock = CoastAggregate;
                                                                         [self performSegueWithIdentifier:@"newCutBlockSegue" sender:sender];
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 UITableViewCell *cell = (UITableViewCell *) sender;
                                                                 cell.tag = 0;
                                                                 [self dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        
        [alert addAction:coastAction];
        [alert addAction:coastRatioAction];
        [alert addAction:coastAggregateSRSAction];
        [alert addAction:coastAggregateAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
