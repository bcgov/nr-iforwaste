//
//  DownloadedTableViewController.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "DownloadedTableViewController.h"
#import "WasteBlock.h"
#import "WasteBlockCellTableViewCell.h"
#import "Timbermark.h"
#import "WasteBlockDAO.h"
#import "BlockViewController.h"

@interface DownloadedTableViewController ()

@property (strong) NSMutableArray *blocks;

@property (weak) WasteBlock *targetWasteBlock;

@end

@implementation DownloadedTableViewController

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
    
    self.title = @"(IFOR 201) Downloaded";
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Setup multi-selection
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.navigationItem.rightBarButtonItem = self.editButton;

    //[self.tableView reloadData];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self loadWasteBlocks];
    [self.tableView reloadData];

    // Ensures edit will be greyed out for an empty table
    [self updateButtonsToMatchTableState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.blocks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WasteBlockCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadedCutBlockCellID" forIndexPath:indexPath];
    WasteBlock *currentBlock = [self.blocks objectAtIndex:indexPath.row];

    cell.unitNumberLabel.text = [currentBlock.reportingUnit stringValue];
    cell.blockLabel.text = currentBlock.blockNumber;
    NSString *timbermark = @"";
    
    for( Timbermark *tm in [currentBlock.blockTimbermark allObjects]){
        
        if ([tm.primaryInd intValue] == 1){
            timbermark = [[NSString stringWithFormat:@"P:%@ ", tm.timbermark] stringByAppendingString:timbermark] ;
            
        } else {
            
            timbermark = [timbermark stringByAppendingString: [NSString stringWithFormat:@"S:%@ ", tm.timbermark]];
        }
    }
    cell.timberMarkLabel.text = timbermark;
    cell.netAreaLabel.text = [currentBlock.surveyArea stringValue];
    cell.blockStatusLabel.text = currentBlock.blockStatus;
    cell.wasteAssessmentAreaID = [NSNumber numberWithInt:[currentBlock.wasteAssessmentAreaID intValue]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.tableView.editing) {
        WasteBlockCellTableViewCell *cell = (WasteBlockCellTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        self.targetWasteBlock = [WasteBlockDAO getWasteBlockByAssessmentAreaId:[cell.wasteAssessmentAreaID stringValue]];
        [self performSegueWithIdentifier:@"downloadCutBlockSegue" sender:self];
        
    } else {
        
        [self updateButtonsToMatchTableState];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.tableView.editing) {
        [self updateButtonsToMatchTableState];
    }
}

#pragma mark - segue function
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.targetWasteBlock){
        return YES;
    }
    return NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
        BlockViewController *blockVC = segue.destinationViewController;
        blockVC.wasteBlock = self.targetWasteBlock;
        
        //clear local waste block pointer
        self.targetWasteBlock = nil;
}

#pragma mark - Updating Button State

- (void)updateButtonsToMatchTableState {
    
    if (self.tableView.editing) {
        
        // Show the option to cancel the edit state
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
        // Show the delete button
        self.navigationItem.leftBarButtonItem = self.deleteButton;
        [self updateDeleteButtonTitle];
        
    } else {
        
        //Show the edit button if there's something to edit
        if (self.blocks.count > 0) {
            self.editButton.enabled = YES;
        } else {
            self.editButton.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
        self.navigationItem.leftBarButtonItem = self.sidebarButton;
    }
}

- (void) updateDeleteButtonTitle {

    // Update based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    BOOL allItemsSelected = selectedRows.count == self.blocks.count;
    BOOL noItemsSelected = selectedRows.count == 0;
    
    if (allItemsSelected || noItemsSelected) {
        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    } else {
        NSString *titleFormatString = NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat: titleFormatString, selectedRows.count];
    }
}

#pragma mark - IBAction

-(IBAction)sortByBlock:(id)sender{
    self.sortBlockAscending = !self.sortBlockAscending;
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc ] initWithKey:@"blockNumber" ascending:self.sortBlockAscending];
    
    self.blocks = [[NSMutableArray alloc] initWithArray:[self.blocks sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    [self.tableView reloadData];
}

-(IBAction)sortByNetArea:(id)sender{
    self.sortNetAreaAscending = ! self.sortNetAreaAscending;
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc ] initWithKey:@"netArea" ascending:self.sortNetAreaAscending];

    self.blocks = [[NSMutableArray alloc] initWithArray:[self.blocks sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    [self.tableView reloadData];
}

- (IBAction)editAction:(id)sender {
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender {
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)deleteAction:(id)sender {
    
    //Open dialog with 'ok' & 'cancel' button
    NSString *actionTitle;
    
    if ([[self.tableView indexPathsForSelectedRows] count] == 1) {
        
        actionTitle = NSLocalizedString(@"Are you sure you want to remove this item?", @"");
        
    } else {
        
        actionTitle = NSLocalizedString(@"Are you sure you want to remove these items?", @"");
    }
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"Yes", @"Yes title for item removal action");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Cut Block" message:actionTitle preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Delete
        [self deleteCutBlocks];
        
        //Exit editing mode after deletion
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        //Dismiss
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - private functions

-(void) sortBlocks{
    NSSortDescriptor *sortBlock = [[NSSortDescriptor alloc ] initWithKey:@"blockNumber" ascending:self.sortBlockAscending];
    NSSortDescriptor *sortNetArea = [[NSSortDescriptor alloc ] initWithKey:@"netArea" ascending:self.sortNetAreaAscending];
    
    self.blocks = [[NSMutableArray alloc] initWithArray:[self.blocks sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortBlock, sortNetArea, nil]]];
    [self.tableView reloadData];
    
}

-(void) loadWasteBlocks{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    
    // Test listing all FailedBankInfos from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"userCreated = NO"];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    self.blocks = [[NSMutableArray alloc] init];
    for(WasteBlock *wb in fetchedObjects){
        [self.blocks addObject:wb];
    }
    
    self.sortBlockAscending = NO;
    self.sortNetAreaAscending = NO;
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc ] initWithKey:@"blockNumber" ascending:YES];
    
    self.blocks = [[NSMutableArray alloc] initWithArray:[self.blocks sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
}

- (void) deleteCutBlocks {
    
    // Delete what the user selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    // Deleting specific rows
    if (selectedRows.count > 0) {
        
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once
        NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
        
        for (NSIndexPath *selectionIndex in selectedRows) {
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
            WasteBlock *targetBlock = [self.blocks objectAtIndex:selectionIndex.row];
            [WasteBlockDAO deleteCutBlock:targetBlock];
        }
        
        // Delete objects from data model
        [self.blocks removeObjectsAtIndexes:indicesOfItemsToDelete];
        
        // Tell tableview we deleted objects
        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else {
        
        [self deleteAllBlocks];
        [self.blocks removeAllObjects];
        
        //Tell tableview we deleted objects (reload current table section since all rows deleted)
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

// Removes all cut blocks and subsections
-(void) deleteAllBlocks {
    for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row++) {
        [WasteBlockDAO deleteCutBlock: [self.blocks objectAtIndex:row]];
    }
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

@end
