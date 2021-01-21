//
//  AggregateCutBlocksViewController.m
//  EForWasteBC
//
//  Created by Chris Nesmith on 3/11/19.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import "AggregateCutBlocksViewController.h"
#import "WasteBlockDAO.h"
#import "BlockViewController.h"
#import "WasteBlock.h"
#import "AggregateCutBlocksViewCell.h"


@interface AggregateCutBlocksViewController ()

@property (weak) WasteBlock *targetWasteBlock;

@end

@implementation AggregateCutBlocksViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.blocks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AggregateCutBlocksViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AggregateCutBlocksViewCellID" forIndexPath:indexPath];
    
    WasteBlock *currentBlock = [self.blocks objectAtIndex:indexPath.row];
    
    cell.cutBlockNo.text = [NSString stringWithFormat:@"%@%@", [currentBlock.aggregateCutBlockNumber stringValue], @"."];
    cell.cutBlockId.text = currentBlock.cutBlockId;
    NSLog(@"%@", currentBlock.cutBlockId);
    cell.cutBlockArea.text = currentBlock.surveyArea && [currentBlock.surveyArea floatValue] > 0 ? [NSString stringWithFormat:@"%.2f ",[currentBlock.surveyArea floatValue]] : @"";;
    cell.cutBlockLicense.text = currentBlock.licenceNumber;
    cell.cutBlockPredPlot.text = [currentBlock.aggregateBlockPredictionPlots stringValue];
    cell.wasteAssessmentAreaID = currentBlock.wasteAssessmentAreaID;
    
    return cell;
}

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AggregateCutBlocksViewCell *cell = (AggregateCutBlocksViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    //NSLog(@"assessmentID of Block: %@", [cell.wasteAssessmentAreaID stringValue]);
    self.targetWasteBlock = [WasteBlockDAO getWasteBlockByAssessmentAreaId:[cell.wasteAssessmentAreaID stringValue]];
    [self performSegueWithIdentifier:@"aggregateToBlock" sender:self];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    BlockViewController *blockVC = segue.destinationViewController;
    blockVC.wasteBlock = self.targetWasteBlock;
    
    //clear local waste block pointer
    self.targetWasteBlock = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Aggregate Cut Blocks";
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.navigationItem.leftBarButtonItem = self.sidebarButton;
    
    WasteBlock* firstBlock = (WasteBlock*)(self.blocks[0]);
    NSArray* assessmentIDArray = [firstBlock.aggregateCutBlockList componentsSeparatedByString:@","];
    int numberOfDeleted = 0;
    
    for(NSString* thisID in assessmentIDArray)
    {
        WasteBlock* thisBlock = [WasteBlockDAO getWasteBlockByAssessmentAreaId:thisID];
        if([thisBlock.aggregateDeletedInd intValue] == TRUE)
        {
            numberOfDeleted++;
        }
    }
    
    if(self.blocks.count == (assessmentIDArray.count - numberOfDeleted))
    {
        self.addLabel.text = [NSString stringWithFormat:@"%@%@", [NSString stringWithFormat:@"%lu",assessmentIDArray.count + 1], @"."];
        self.addLabel.hidden = NO;
        self.addButton.hidden = NO;
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //[self loadAggregateBlocks];
    [self.tableView reloadData];
}

- (IBAction) addNewAggregateBlock:(id)sender
{
    Boolean allowAdd = true;
    for(WasteBlock* thisBlock in self.blocks)
    {
        if(thisBlock.blockStratum.count == 0)
        {
            allowAdd = false;
            break;
        }
    }
    if(!allowAdd)
    {
        //WasteBlock already exists
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot Add Aggregate Block"
                                                                       message:@"You can only add an aggregate block if all other blocks in the aggregate list have stratums."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 [self dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        WasteBlock* firstBlock = (WasteBlock*)(self.blocks[0]);
        self.targetWasteBlock = [WasteBlockDAO addAdditionalAggregateCutBlock:firstBlock.aggregateCutBlockList];
        [self performSegueWithIdentifier:@"aggregateToBlock" sender:self];
    }
}

@end

