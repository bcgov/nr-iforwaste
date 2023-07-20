//
//  ReportsTableViewController.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-04-30.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "ReportsTableViewController.h"

@interface ReportsTableViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *spaceItem1;

@property (strong) NSMutableArray *reports;

@end

@implementation ReportsTableViewController
@synthesize documentIC;

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
    
    self.title = @"(IFOR 301) Reports";
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Get documents folder
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@""];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:NULL];
    self.reports = [[NSMutableArray alloc] init];
    
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        if ([[directoryContent objectAtIndex:count] rangeOfString:@".rtf"].location != NSNotFound ||
            [[directoryContent objectAtIndex:count] rangeOfString:@".csv"].location != NSNotFound){
            [self.reports addObject:[directoryContent objectAtIndex:count]];
        }
    }
    /*
    if (count > 0){
        [self.reports addObjectsFromArray:directoryContent];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
-(IBAction)changeReportSuffix:(id)sender{
    NSString *title = NSLocalizedString(@"Change Report Suffix", nil);
    NSString *message = NSLocalizedString(@"Please enter suffix", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    //[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    
    [alert show];
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.reports count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportTableCell" forIndexPath:indexPath];
    
    UILabel *reportName = (UILabel *)[cell viewWithTag:1];
    
    reportName.text = [self.reports objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.tableView.editing) {
        //self.selectedReport = indexPath.row;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *reportPath = [documentsDirectory stringByAppendingPathComponent:[self.reports objectAtIndex:indexPath.row]];
        NSLog(@"report path = %@", reportPath);
        
        NSURL *URL = [[NSURL alloc] initFileURLWithPath:reportPath];
        
        //NSLog(@"url path= %@", [URL path]);
        //NSLog(@"url path extension= %@", [URL pathExtension]);
        
        if (URL) {
            // Initialize Document Interaction Controller
            self.documentIC = [UIDocumentInteractionController interactionControllerWithURL:URL];
            
            // Configure Document Interaction Controller
            [self.documentIC setDelegate:self];
            
            // Preview PDF
            [self.documentIC presentPreviewAnimated:YES];

        }else{
            //NSLog(@"file URL is null");
        }
    }else{
        [self updateButtonsToMatchTableState];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if(self.tableView.editing) {
        // Update the delete button's title based on how many items are selected.
        [self updateDeleteButtonTitle];
     }
}
#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
        [self updateDeleteButtonTitle];

        // Show the delete button.
        [self.spaceItem1 setWidth:100.0];
        
        //self.navigationItem.leftBarButtonItem = self.deleteButton;
        self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects:self.deleteButton, self.spaceItem1, self.actionButton, nil];
    }
    else
    {
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (self.reports.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
        //self.navigationItem.leftBarButtonItem= self.sidebarButton;
        self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects:self.sidebarButton, nil];
        
        //prompt for import the selected file
        //[self promptImportFile];
    }
}

- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == self.reports.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

#pragma mark - Action methods

- (IBAction)editAction:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}
#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) {
        //NSLog(@"Alert view clicked with the cancel button index.");
    }else {
        
        if( [alertView.title isEqualToString:@"Email Reports"]){
            //TODO - implement attach to email feature
            NSString *emailTitle = [NSString stringWithFormat:@"%@ - Reports", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
            NSString *messageBody = @"";
            NSArray *toRecipents = [NSArray arrayWithObject:@""];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            
            
            NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[self.reports objectAtIndex:selectionIndex.row] ];
                NSLog(@"report path = %@", filePath);
                
                // Get the resource path and read the file using NSData
                NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                
                // Determine the MIME type
                NSString *mimeType = @"";
                
                if([[[filePath pathExtension] lowercaseString] isEqualToString:@"rtf"]){
                    mimeType = @"application/rtf";
                }else if([[[filePath pathExtension] lowercaseString] isEqualToString:@"csv"]){
                    mimeType = @"application/csv";
                }
                
                // Add attachment
                [mc addAttachmentData:fileData mimeType:mimeType fileName:[self.reports objectAtIndex:selectionIndex.row] ];
            }
            // Determine the file name and extension
            
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];

            
        }else if([alertView.title isEqualToString:@"Delete Reports"]){
            // Delete what the user selected.
            NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
            BOOL deleteSpecificRows = selectedRows.count > 0;
            if (deleteSpecificRows)
            {
                // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
                NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
                for (NSIndexPath *selectionIndex in selectedRows)
                {
                    [indicesOfItemsToDelete addIndex:selectionIndex.row];
                    NSString *reportPath = [self.reports objectAtIndex:selectionIndex.row];
                    [self deleteFileByName:reportPath];
                    
                }
                // Delete the objects from our data model.
                [self.reports removeObjectsAtIndexes:indicesOfItemsToDelete];
                
                // Tell the tableView that we deleted the objects
                [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                // Delete everything, delete the objects from our data model.
                [self deleteAllFiles];
                [self.reports removeAllObjects];
                
                // Tell the tableView that we deleted the objects.
                // Because we are deleting all the rows, just reload the current table section
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // Exit editing mode after the deletion.
            [self.tableView setEditing:NO animated:YES];
            [self updateButtonsToMatchTableState];
            
        }else if([alertView.title isEqualToString:@""]){
            NSLog(@"alert index button = %d", buttonIndex);
        }
    }
}


- (IBAction)deleteAction:(id)sender
{
    // Open a dialog with just an OK button.
    NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove this file?", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove these files?", @"");
    }
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"Yes", @"Yes title for item removal action");
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Reports" message:actionTitle delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
    
    [alert show];
    
}

- (IBAction)attachToEmailAction:(id)sender
{
    if ([[self.tableView indexPathsForSelectedRows] count] > 0 ){
        
        // Open a dialog with just an OK button.
        NSString *actionTitle;
        if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
            actionTitle = NSLocalizedString(@"Are you sure you want to attach this file to an email?", @"");
        }
        else
        {
            actionTitle = NSLocalizedString(@"Are you sure you want to attach these files to an email?", @"");
        }
        
        NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item attach action");
        NSString *okTitle = NSLocalizedString(@"Yes", @"Yes title for item attach action");
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Reports" message:actionTitle delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
        
        [alert show];
    }
}

#pragma mark - delete file

-(void) deleteAllFiles{
    
    for(NSString *filePath in self.reports){
        [self deleteFileByName:filePath];
    }
}

-(void) deleteFileByName:(NSString *) filename{
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@""];
    
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", dataPath, filename] error:&error];
    
    if(error){
        NSLog(@"Error when deleting file - %@", error);
    }
}

#pragma mark - document interaction functions
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self.navigationController;
}
- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self cancelAction:nil];
}
@end
