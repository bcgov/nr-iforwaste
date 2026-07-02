//
//  SearchResultsTableViewController.m
//  WasteMobile
//
//  Created by Salus
//

#import "SearchResultsTableViewController.h"
#import "WasteBlock.h"
#import "WasteBlockCellTableViewCell.h"
#import "Timbermark.h"
#import "WasteStratum.h"
#import "WastePiece.h"
#import "WastePlot.h"
#import "SearchResultDTO.h"
#import "WasteBlockDAO.h"
#import "BlockViewController.h"
#import "WasteWebServiceManager.h"

@interface SearchResultsTableViewController () <WasteWebServiceManagerDelegate>

@property (strong) NSMutableArray *wasteBlocks;

@property (weak) WasteBlock *targetWasteBlock;

//use this reference to reset the loading wheel
@property (weak) WasteBlockCellTableViewCell *resultCutBlockTableViewCell;

@end

@implementation SearchResultsTableViewController

@synthesize searchResult, reportingUnitNumber, cutBlockId, searchResultTableView;

// Grab the managedObjectContext from AppDelegate
- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

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
    
    self.title = @"(IFOR 103) Cut Block List";
    
    self.wasteBlocks = [[NSMutableArray alloc] init];
    // Do this so the Waste Status label is able to use multiple lines
    self.tableView.rowHeight = 60.f;
    
    // Change button color
    _sideBarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sideBarButton.target = self.revealViewController;
    _sideBarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //go through the list again to disable the cell for download block
    [self.searchResultTableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.searchResult count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"wasteCell";
    
    // Fill in the Waste Block
    SearchResultDTO *block = [self.searchResult objectAtIndex:indexPath.row];
    //NSLog(@" indexPath.row = %ld ", (long)indexPath.row);
    
    WasteBlockCellTableViewCell *cell = (WasteBlockCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];

    if ([WasteBlockDAO getWasteBlockByAssessmentAreaId:block.wasteAssessmentAreaID]){
        //NSLog(@" set color for block %@, RU %@ ", block.blockID, block.reportingUnit);
        [cell setBackgroundColor:[UIColor lightGrayColor]];
    }else{
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    if (cell == nil)
    {
        // Create new Waste Block Cell
        cell = [[WasteBlockCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        //NSLog(@" create new cell for this");
    }
    
    // Fill the View with blockData
    cell.licenceNoLabel.text = block.licenceNumber;
    cell.cuttingPermitLabel.text = block.cuttingPermitId;
    cell.blockLabel.text = block.blockNumber;
    cell.exemptedLabel.text = block.exempted;
    cell.netAreaLabel.text = block.netArea;
    cell.blockStatusLabel.text = block.blockStatus;
    cell.timberMarkLabel.text = block.timbermark;
    cell.unitNumberLabel.text = block.reportingUnit;
    cell.wasteAssessmentAreaID = [NSNumber numberWithInt:[block.wasteAssessmentAreaID intValue]];
    
    cell.loadingWheel.hidesWhenStopped = YES;
    [cell.loadingWheel stopAnimating];
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    // here we know which row was selected
    
    // get wasteblock and create it
    
    //WasteBlock *wb =
    WasteBlockCellTableViewCell *cell = (WasteBlockCellTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.backgroundColor != [UIColor lightGrayColor]){
        self.cutBlockId = cell.blockLabel.text;
        
        WasteWebServiceManager *ws = [[WasteWebServiceManager alloc] init];
        ws.delegate = self;
        
        //clear local waste block pointer
        self.targetWasteBlock = nil;
        
        //show loading wheel
        [cell.loadingWheel startAnimating];
        
        //save the reference for later
        self.resultCutBlockTableViewCell = cell;
        
        //downloading the block data
        [ws downloadCutBlock:[cell.wasteAssessmentAreaID stringValue]];
        
        //don't let user do anything from this point
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];       
    }

}
#pragma mark - segue functions
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqual: @"selectBlockSegue"]){
        if (self.targetWasteBlock ){
            return YES;
        }
    }
    return NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //NSLog(@"Segue.id = %@\nSender = %@", segue.identifier, sender);
    
    if ( [segue.identifier isEqualToString:@"selectBlockSegue"]){
        
        BlockViewController *blockVC = segue.destinationViewController;
        blockVC.wasteBlock = self.targetWasteBlock;
        blockVC.navigationItem.leftItemsSupplementBackButton = YES;

        //clear local waste block pointer
        self.targetWasteBlock = nil;
    }
}

#pragma  mark - web service delegate
-(void) finishDownloadCutBlock:(WasteBlock *) wasteBlock{
    //resume the interaction
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

    [self.resultCutBlockTableViewCell.loadingWheel stopAnimating];

    self.targetWasteBlock = wasteBlock;
    
    //after save a reference to the download waste block, fire the segue and let it handle the transition
    [self performSegueWithIdentifier:@"selectBlockSegue" sender:self];
}

-(void) downloadCutBlockFailed:(NSError *)error{
    //resume the interaction
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    [self.resultCutBlockTableViewCell.loadingWheel stopAnimating];

    NSString *title = NSLocalizedString(@"Warning", nil);
    NSString *message = NSLocalizedString(@"Insufficient data exists to permit download, please confirm data exists before download is attempted.",nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
	[alert show];
}

#pragma mark - core data functions
-(BOOL) isCutBlockDownloaded:(NSString *)blockId reportingUnitId:(NSString *)reportingUnit{
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @" cutBlockId = %@ AND reportingUnitId = %@ ", blockId, reportingUnit];
    
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (result.count > 0) {
        return YES;
    }else{
        return NO;
    }
}

@end
