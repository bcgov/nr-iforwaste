//
//  CreatedTableViewController.m
//  WasteMobile
//
//  Created by Jack Wong on 2016-09-30.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import "CreatedTableViewController.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "CreatedTableViewCell.h"
#import "Timbermark.h"
#import "WasteBlockDAO.h"
#import "BlockViewController.h"

@interface CreatedTableViewController ()

@property (strong) NSMutableArray *blocks;

@property (weak) WasteBlock *targetWasteBlock;

@end

@implementation CreatedTableViewController

@synthesize sortByRUButton, sortByTMButton, sortByNetButton, sortByDateButton, sortByBlockButton, sortColumn;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"(IFOR 601) Created";
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Setup multi-selection
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.navigationItem.rightBarButtonItem = self.editButton;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadNewWasteBlocks];
    [self.tableView reloadData];
    [self updateButtonsToMatchTableState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.blocks count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CreatedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreatedTableViewCellID" forIndexPath:indexPath];
    
    WasteBlock *currentBlock = [self.blocks objectAtIndex:indexPath.row];
    
    cell.unitNumberLabel.text = [currentBlock.reportingUnit stringValue];
    //cell.licenceNoLabel.text = currentBlock.licenceNumber;
    //cell.exemptedLabel.text = currentBlock.exempted;
    //cell.cuttingPermitLabel.text = currentBlock.cuttingPermitId;
    cell.blockLabel.text = currentBlock.blockNumber;
    NSString *timbermark = @"";
    for( Timbermark *tm in [currentBlock.blockTimbermark allObjects]){
        if ([tm.primaryInd intValue] == 1){
            timbermark = tm.timbermark;
            break;
        }
    }
    cell.timberMarkLabel.text = timbermark;
    cell.netAreaLabel.text = currentBlock.surveyArea && [currentBlock.surveyArea floatValue] > 0 ? [NSString stringWithFormat:@"%.2f ",[currentBlock.surveyArea floatValue]] : @"";
    cell.wasteAssessmentAreaID = [NSNumber numberWithInt:[currentBlock.wasteAssessmentAreaID intValue]];
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy"];
    cell.entryDateLabel.text = [df stringFromDate:currentBlock.entryDate];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.tableView.editing) {
        
        CreatedTableViewCell *cell = (CreatedTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        self.targetWasteBlock = [WasteBlockDAO getWasteBlockByAssessmentAreaId:[cell.wasteAssessmentAreaID stringValue]];
        [self performSegueWithIdentifier:@"createdCutBlockSegue" sender:self];
        
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
-(IBAction)sortBlock:(id)sender{

    NSString *key = @"";
    if(sender == self.sortByBlockButton){
        key = @"blockNumber";
    }else if(sender == self.sortByDateButton){
        key = @"entryDate";
    }else if(sender == self.sortByNetButton){
        key = @"surveyArea";
    }else if(sender == self.sortByTMButton){
        key = @"TM";
    }else if(sender == self.sortByRUButton){
        key = @"reportingUnit";
    }

    BOOL orderASC = NO;
    if([sortColumn rangeOfString:key].location == NSNotFound){
        sortColumn = [NSString stringWithFormat:@"%@ ASC", key];
        orderASC = YES;
    }else{
        if([sortColumn rangeOfString:@"ASC"].location == NSNotFound){
            orderASC = YES;
            sortColumn = [NSString stringWithFormat:@"%@ ASC", key];
        }else{
            sortColumn = [NSString stringWithFormat:@"%@ DESC", key];
        }
    }
    if([key isEqualToString:@"TM"]){
        self.blocks = [[NSMutableArray alloc] initWithArray:[self.blocks sortedArrayUsingComparator:^NSComparisonResult(id  wb1, id   wb2) {
            NSString *tm1 = @"";
            NSString *tm2 = @"";
            
            for( Timbermark *tm in [(WasteBlock*)wb1 blockTimbermark ]){
                if ([tm.primaryInd intValue] == 1){
                    tm1 = tm.timbermark;
                    break;
                }
            }
            for( Timbermark *tm in [(WasteBlock*)wb2 blockTimbermark ]){
                if ([tm.primaryInd intValue] == 1){
                    tm2 =  tm.timbermark;
                    break;
                }
            }
            if(orderASC){
                return [tm1 compare:tm2];
            }else{
                return [tm2 compare:tm1];
            }
        }]];
    }else{
        NSSortDescriptor *sd = [[NSSortDescriptor alloc ] initWithKey:key ascending:orderASC];
        self.blocks = [[NSMutableArray alloc] initWithArray:[self.blocks sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    }
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
/*
-(void) sortBlocks{
    NSSortDescriptor *sortBlock = [[NSSortDescriptor alloc ] initWithKey:@"blockNumber" ascending:self.sortBlockAscending];
    NSSortDescriptor *sortNetArea = [[NSSortDescriptor alloc ] initWithKey:@"netArea" ascending:self.sortNetAreaAscending];
    
    self.blocks = [[NSMutableArray alloc] initWithArray:[self.blocks sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortBlock, sortNetArea, nil]]];
    [self.tableView reloadData];
    
}
 */

-(void) loadNewWasteBlocks{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    
    // Test listing all FailedBankInfos from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WasteBlock"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    //this stuff should probably be done in the DAO...refactor later?
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"userCreated = YES"];
    
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    self.blocks = [[NSMutableArray alloc] init];
    for(WasteBlock *wb in fetchedObjects){
        [self.blocks addObject:wb];
    }
    
    self.sortColumn = @"";
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc ] initWithKey:@"blockNumber" ascending:YES];
    
    self.blocks = [[NSMutableArray alloc] initWithArray:[self.blocks sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    
}

// Delete what the user selected
- (void) deleteCutBlocks {
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

@end
