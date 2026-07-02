//
//  FilesTableViewController.m
//  WasteMobile
//
//  Created by Jack Wong on 2016-10-14.
//  Copyright © 2016 Salus Systems. All rights reserved.
//

#import "FilesTableViewController.h"
#import "FileDTO.h"
#import "XMLDataImporter.h"
#import "BlockViewController.h"
#import "WasteBlockDAO.h"
#import "WasteBlock.h"
#import "WasteStratum.h"
#import "WastePlot.h"
#import "WastePiece.h"
#import "WasteImportBlockValidator.h"
#import "WasteCalculator.h"
#import "GDataXMLNode.h"

@interface FilesTableViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *spaceItem1;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong) NSMutableArray *files;
@property (strong) NSURL *importFileURL;
@property (strong) NSString *importFilePath;

@property (nonatomic, strong) WasteBlock *targetWasteBlock;

@end

@implementation FilesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"(IFOR 701) Import/Export Files";
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    NSLog(@"LISTING ALL APPLICABLE FILES FOUND");
    self.files = [[NSMutableArray alloc] init];
    self.importFilePath = @"";
    
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"iFORWASTE"] ){
        
        [self addFilesForExtension:@".ifw"];
        [self addFilesForExtension:@".efw"];
        
    } else if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] isEqualToString:@"EForWasteBC"]) {
        
        [self addFilesForExtension:@".xml"];
        [self addFilesForExtension:@".efw"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.files count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileTableCell" forIndexPath:indexPath];

    UILabel *fileName = (UILabel *)[cell viewWithTag:1];

    fileName.text = [[self.files objectAtIndex:indexPath.row] fileName];

    UILabel *createdDate = (UILabel *)[cell viewWithTag:2];

    createdDate.text = [[self.files objectAtIndex:indexPath.row] createdDateStr];
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
    if (!self.tableView.editing){
        FileDTO *file =[self.files objectAtIndex:indexPath.row];
        [self promptImportFile:file.fileName];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
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
        
        if( [alertView.title isEqualToString:@"Email Files"]){
            
            NSString *emailTitle = [NSString stringWithFormat:@"%@ - Export File", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
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
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[[self.files objectAtIndex:selectionIndex.row] fileName]];
                //NSLog(@"report path = %@", filePath);
                
                // Get the resource path and read the file using NSData
                NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                
                // Determine the MIME type
                NSString *mimeType = @"";
                
                if ([[[filePath pathExtension] lowercaseString] isEqualToString:@"efw"]){
                    mimeType = @"application/eforwaste";
                }else if([[[filePath pathExtension] lowercaseString] isEqualToString:@"ifw"] ){
                    mimeType = @"application/iforwaste";
                }else{
                    mimeType = @"application/xml";
                }
                
                // Add attachment
                [mc addAttachmentData:fileData mimeType:mimeType fileName:[[self.files objectAtIndex:selectionIndex.row] fileName]];
            }
            // Determine the file name and extension
            
            
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            
        }else if([alertView.title isEqualToString:@"Delete Files"]){
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
                    FileDTO *f = [self.files objectAtIndex:selectionIndex.row];
                    [self deleteFileByName:f.fileName];

                }
                // Delete the objects from our data model.
                [self.files removeObjectsAtIndexes:indicesOfItemsToDelete];
                
                // Tell the tableView that we deleted the objects
                [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                // Delete everything, delete the objects from our data model.
                [self deleteAllFiles];
                [self.files removeAllObjects];
                
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
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Files" message:actionTitle delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
    
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
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Files" message:actionTitle delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
        
        [alert show];
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
        if (self.files.count > 0)
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
    
    BOOL allItemsAreSelected = selectedRows.count == self.files.count;
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

-(void)promptImportFile:(NSString *) fileName{
    
    //Ignore XML files for import
    if (([fileName rangeOfString:@".efw"].location != NSNotFound) || ([fileName rangeOfString:@".ifw"].location != NSNotFound )){
    
        self.importFilePath = fileName;
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Import File"
                                                                       message:@"Do you want to import the selected file?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   XMLDataImporter *imp = [[XMLDataImporter alloc] init];
                                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                                   WasteBlock *wb = nil;
                                                                   [self importResultPrompt:[imp ImportDataByFileName:fileName wasteBlock:&wb ignoreExisting:NO]];
                                                                   if(wb){
                                                                       self.targetWasteBlock = wb;
                                                                   }
                                                               }];
        
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                            }];
        [alert addAction:yesAction];
        [alert addAction:noAction];
        
        [self presentViewController:alert animated:YES completion:nil];

    }else if([fileName rangeOfString:@".xml"].location != NSNotFound){
        
        self.importFilePath = fileName;
        [self popupForPieceSearch];
    }

}

-(void)popupForPieceSearch{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Search Piece by Piece Number"
                                                                   message:@"Please enter the piece number."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder        = NSLocalizedString(@"Piece Number", nil);
        textField.accessibilityLabel = NSLocalizedString(@"Piece Number", nil);
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.delegate           = self;
    }];
    
    UIAlertAction* searchAction = [UIAlertAction actionWithTitle:@"Search" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self searchPieceByPieceNumber:alert.textFields[0]];
                                                         }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:searchAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)searchPieceByPieceNumber:(UITextField*)textField{
    int pieceNumber = [textField.text intValue];
    if(pieceNumber == 0){
        [self popupForPieceSearch];
    }else{
        if(self.importFilePath){
            int counter = pieceNumber;
            NSData *xmlData = nil;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@""];
            NSString *filePath =[NSString stringWithFormat:@"%@/%@", dataPath, self.importFilePath];
            
            xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
            NSError *error;
            GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];

            if(error){
                NSLog(@"Error when loading xml data to GDataXMLDocument : %@", error);
            }else{
                
                NSArray *submission_ary = [doc.rootElement elementsForName:@"esf:submissionContent"];
                GDataXMLElement *submission = submission_ary[0];
                //get children instead of by name.
                NSArray *child = [submission children];
                GDataXMLElement *wasteSub = child[0];
                NSArray *subItem_ary = [wasteSub elementsForName:@"submissionItem"];
                GDataXMLElement *subItem = subItem_ary[0];
                NSArray *waa_ary = [subItem elementsForName:@"WasteAssessmentArea"];
                GDataXMLElement *waa = waa_ary[0];

                NSArray *stratums = [waa elementsForName:@"WasteStratum"];
                NSString *returnMessage = @"";
                
                if (stratums.count > 0){
                    for(int i = 0; i < [stratums count] - 1; i++){
                        GDataXMLElement *stra = stratums[i];
                        NSString *wastTypeCode =[[stra elementsForName:@"wasteTypeCode"][0] stringValue] ;
                        NSString *wasteHarvestMethodCode = [[stra elementsForName:@"wasteHarvestMethodCode"][0] stringValue] ;
                        NSString *wasteAssessmentMethodCode = [[stra elementsForName:@"wasteAssessmentMethodCode"][0] stringValue] ;
                        NSString *wastePlotSizeCode = [[stra elementsForName:@"wastePlotSizeCode"][0] stringValue] ;
                        NSString *wasteLevelCode = [[stra elementsForName:@"wasteLevelCode"][0] stringValue] ;
                        NSString *wasteStratumTypeCode = [[stra elementsForName:@"wasteStratumTypeCode"][0] stringValue] ;

                        NSString *stratum = @"";
                        if([wasteStratumTypeCode isEqualToString:@"STR"]){
                            stratum = [NSString stringWithFormat:@"%@%@", wasteStratumTypeCode, wasteAssessmentMethodCode];
                            NSArray *pieces = [stra elementsForName:@"WastePiece"];
                            if((counter - (int)[pieces count]) <= 0){
                                returnMessage = [NSString stringWithFormat:@"Piece number %d is in Stratum %@, Piece %d", pieceNumber, stratum, counter];
                                break;
                            }else{
                                counter = counter - (int)[pieces count];
                            }
                        }else if([wasteAssessmentMethodCode isEqualToString:@"S"] ||[wasteAssessmentMethodCode isEqualToString:@"E"]||[wasteAssessmentMethodCode isEqualToString:@"O"]){
                            stratum = [NSString stringWithFormat:@"%@%@%@%@", wastTypeCode, wasteHarvestMethodCode, wasteAssessmentMethodCode, wasteLevelCode];
                            NSArray *pieces = [stra elementsForName:@"WastePiece"];
                            if((counter - (int)[pieces count]) <= 0){
                                returnMessage = [NSString stringWithFormat:@"Piece number %d is in Stratum %@, Piece %d", pieceNumber, stratum, counter];
                                break;
                            }else{
                                counter = counter - (int)[pieces count];
                            }
                        }else{
                            stratum = [NSString stringWithFormat:@"%@%@%@%@", wastTypeCode, wasteHarvestMethodCode, wastePlotSizeCode, wasteLevelCode];
                            NSArray *plots = [stra elementsForName:@"WastePlot"];
                            for(GDataXMLElement *plot in plots){
                                NSString *plotNumber = [[plot elementsForName:@"wastePlotNumber"][0] stringValue];
                                NSArray *pieces = [plot elementsForName:@"WastePiece"];
                                
                                if((counter - (int)[pieces count]) <= 0){
                                    returnMessage = [NSString stringWithFormat:@"Piece number %d is in Stratum %@, Plot %@, Piece %d", pieceNumber, stratum, plotNumber, counter];
                                    break;
                                }else{
                                    counter = counter - (int)[pieces count];
                                }
                            }
                            if(![returnMessage isEqualToString:@""]){
                                break;
                            }
                        }
                    }
                }

                if([returnMessage isEqualToString:@""]){
                    returnMessage = [NSString stringWithFormat:@"Piece number %d is not found in the XML file.", pieceNumber ];
                }
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Search Result"
                                                                               message:returnMessage
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okAction];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
    
    //clear the file path
    self.importFilePath = @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    BOOL result = YES;
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str appendString:string];
    NSString *theString = str;

    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    unichar c;
    
    for (int i = 0; i < [theString length]; i++) {
        c = [theString characterAtIndex:i];
        if (![charSet characterIsMember:c]) {
            result = NO;
        }
    }
    return result;
}

-(void)importResultPrompt:(ImportOutcomeCode)outcome{
    
    if(outcome == ImportFailCutBlockExist){
        //for existing cut block, ask for merge
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Existing Cut Block"
                                                                       message:@"Existing cut block exists. Cannot Import/Download"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [self performSegueWithIdentifier:@"ImportDownloadSegue" sender:self];
            [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];

    }else{
        
        if (outcome == ImportSuccessful){
            [self showRedirectAlert:@"Import File" message:@"File is imported successfully. Do you want to go to the cut block?"];
        }else if(outcome == ImportFailLoadXML){
            [self showAlert:@"Import File" message:@"Fail to import file - xml error." ];
        }else if (outcome == ImportFailOnSaveWastBlock){
            [self showAlert:@"Import File" message:@"Fail to import file - save error." ];
        }else if (outcome == ImportFailRegionIDExist){
            [self showAlert:@"Import File" message:@"Fail to import file - region different." ];
        }
    }
}

-(void)addFilesForExtension:(NSString *) ext {
    
    int count;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get documents folder
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@""];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy"];
    
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
    
        if ([[directoryContent objectAtIndex:count] rangeOfString:ext].location != NSNotFound){
            
            NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",documentsDirectory, [directoryContent objectAtIndex:count]] error:nil];
            FileDTO * file= [FileDTO alloc];
            [file setFileName:[directoryContent objectAtIndex:count]];
            [file setCreateDate:[fileAttribs objectForKey:NSFileCreationDate]];
            [file setCreatedDateStr:[df stringFromDate:[fileAttribs objectForKey:NSFileCreationDate]]];
            
            [self.files addObject:file];
            //NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        }
    }
}

-(void)mergeCutBlock{
    WasteBlock* import_wb = nil;
    XMLDataImporter *imp = [[XMLDataImporter alloc] init];
    BOOL isOption1 = FALSE;
    BOOL isOption2 = FALSE;
    BOOL isOption3 = FALSE;
    int pileCounter1 = 0; int nonPileStratum1 = 0;int pileCounter2 = 0; int nonPileStratum2 = 0;
    
    NSLog(@"importFilePath=%@, importFileURL=%@", self.importFilePath, self.importFileURL);
    ImportOutcomeCode import_outcome = ImportFailCutBlockExist;
    if(self.importFilePath && ![[self.importFilePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        import_outcome = [imp ImportDataByFileName:self.importFilePath wasteBlock:&import_wb ignoreExisting:YES];
    }else if(self.importFileURL){
        import_outcome = [imp ImportDataByURL:self.importFileURL wasteBlock:&import_wb ignoreExisting:YES];
    }
    
    switch(import_outcome){
        case ImportFailLoadXML:
        case ImportFailOnSaveWastBlock:
        case ImportFailRegionIDExist:
            import_wb = nil;
            break;
    default:
        break;
    }
    
    if (import_wb){
        WasteBlock *db_wb = nil;
        db_wb = [WasteBlockDAO getWasteBlockByRUButWAID:[NSString stringWithFormat:@"%@",import_wb.reportingUnit] cutBlockId:import_wb.cutBlockId  license:import_wb.licenceNumber cutPermit:import_wb.cuttingPermitId wasteAsseID:[NSString stringWithFormat:@"%@", import_wb.wasteAssessmentAreaID]];
        
        if(db_wb){
            
            NSMutableArray *warning = [WasteImportBlockValidator compareBlockForImport:db_wb wb2:import_wb];
            
            if ([warning count] > 0){
                //alert warning
                NSString *warning_msg = [NSString stringWithFormat:@"Data does not match between cut blocks (%d found)\n", [warning count]];
                
                for (NSString *field in warning){
                   warning_msg = [warning_msg stringByAppendingString:[NSString stringWithFormat:@" - %@\n", field]];
                                                        
                }
                [self showAlert:@"Merge Error" message:warning_msg];
                
                //delete imported cut block data
                [WasteBlockDAO deleteCutBlock:import_wb];
            }else{
                //merge cut block
                [WasteBlockDAO mergeWasteBlock:db_wb WasteBlock:import_wb];
                
                [WasteCalculator calculateWMRF:db_wb updateOriginal:NO];
                [WasteCalculator calculateRate:db_wb ];
                [WasteCalculator calculatePiecesValue:db_wb ];
                
                if([db_wb.userCreated intValue] ==1){
                    [WasteCalculator calculateEFWStat:db_wb];
                }
                
                //delete the imported block
                [WasteBlockDAO deleteCutBlock:import_wb];
                
                self.targetWasteBlock = db_wb;
                
                //prompt to go to cut block
                [self showRedirectAlert:@"Merge File" message:@"Cut block data merged successfully. Do you want to go to the cut block?" ];
            }
            
            /* Start 1.5 old code
            for(WasteStratum *ws1 in db_wb.blockStratum){
                if([ws1.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:YES] intValue]){
                    pileCounter1++;
                }else{
                    nonPileStratum1++;
                }
            }
            for(WasteStratum *ws2 in import_wb.blockStratum){
                if([ws2.isPileStratum intValue] == [[[NSNumber alloc] initWithBool:YES] intValue]){
                    pileCounter2++;
                }else{
                    nonPileStratum2++;
                }
            }
            if(pileCounter1 == 0 && pileCounter2 == 0){
                if(nonPileStratum1 > 0 && nonPileStratum2 > 0){
                    isOption1 = TRUE;
                }
            }else if(pileCounter1 > 0 && pileCounter2 > 0){
                if(nonPileStratum1 == 0 && nonPileStratum2 == 0){
                    isOption2 = TRUE;
                }else{
                    isOption3 = TRUE;
                }
            }else{
                isOption3 = TRUE;
            }
            if(isOption1){
                NSMutableArray *warning = [WasteImportBlockValidator compareBlockForImport:db_wb wb2:import_wb];
                if ([warning count] > 0){
                    //alert warning
                    NSString *warning_msg = [NSString stringWithFormat:@"Data does not match between cut blocks (%d found)\n", [warning count]];
                    
                    for (NSString *field in warning){
                       warning_msg = [warning_msg stringByAppendingString:[NSString stringWithFormat:@" - %@\n", field]];
                                                            
                    }
                    [self showAlert:@"Merge Error" message:warning_msg];
                    
                    //delete imported cut block data
                    [WasteBlockDAO deleteCutBlock:import_wb];
                }else{
                    //merge cut block
                    [WasteBlockDAO mergeWasteBlock:db_wb WasteBlock:import_wb];

                    [WasteCalculator calculateWMRF:db_wb updateOriginal:NO];
                    [WasteCalculator calculateRate:db_wb ];
                    [WasteCalculator calculatePiecesValue:db_wb ];

                    if([db_wb.userCreated intValue] ==1){
                        [WasteCalculator calculateEFWStat:db_wb];
                    }

                    //delete the imported block
                    [WasteBlockDAO deleteCutBlock:import_wb];
                    
                    self.targetWasteBlock = db_wb;
                    
                    //prompt to go to cut block
                    [self showRedirectAlert:@"Merge File" message:@"Cut block data merged successfully. Do you want to go to the cut block?" ];
                }
            }else if(isOption2){
                NSMutableArray *warning = [WasteImportBlockValidator compareBlockForImportPileStratum:db_wb wb2:import_wb];
                if ([warning count] > 0){
                    //alert warning
                    NSString *warning_msg = [NSString stringWithFormat:@"Data does not match between cut blocks (%d found)\n", [warning count]];
                    
                    for (NSString *field in warning){
                       warning_msg = [warning_msg stringByAppendingString:[NSString stringWithFormat:@" - %@\n", field]];
                                                            
                    }
                    [self showAlert:@"Merge Error" message:warning_msg];
                    
                    //delete imported cut block data
                    [WasteBlockDAO deleteCutBlock:import_wb];
                }else{
                    //merge cut block
                    [WasteBlockDAO mergeWasteBlockPileStratum:db_wb WasteBlock:import_wb];
                    
                    [WasteCalculator calculateWMRF:db_wb updateOriginal:NO];
                    [WasteCalculator calculateRate:db_wb ];

                    if([db_wb.userCreated intValue] ==1){
                        [WasteCalculator calculateEFWStat:db_wb];
                    }

                    //delete the imported block
                    [WasteBlockDAO deleteCutBlock:import_wb];
                    
                    self.targetWasteBlock = db_wb;
                    
                    //prompt to go to cut block
                    [self showRedirectAlert:@"Merge File" message:@"Cut block data merged successfully. Do you want to go to the cut block?" ];
                }
            }else if(isOption3){
                NSMutableArray *warning = [WasteImportBlockValidator compareBlockForImportStratum:db_wb wb2:import_wb];
                 if ([warning count] > 0){
                     //alert warning
                     NSString *warning_msg = [NSString stringWithFormat:@"Data does not match between cut blocks (%d found)\n", [warning count]];
                     for (NSString *field in warning){
                        warning_msg = [warning_msg stringByAppendingString:[NSString stringWithFormat:@" - %@\n", field]];
                     }
                     [self showAlert:@"Merge Error" message:warning_msg];
                     //delete imported cut block data
                     [WasteBlockDAO deleteCutBlock:import_wb];
                 }else{
                     //merge cut block
                     [WasteBlockDAO mergeWasteBlockData:db_wb WasteBlock:import_wb];
                     [WasteCalculator calculateWMRF:db_wb updateOriginal:NO];
                     [WasteCalculator calculateRate:db_wb ];
                     [WasteCalculator calculatePiecesValue:db_wb ];
                     if([db_wb.userCreated intValue] ==1){
                         [WasteCalculator calculateEFWStat:db_wb];
                     }
                     //delete the imported block
                     [WasteBlockDAO deleteCutBlock:import_wb];
                     self.targetWasteBlock = db_wb;
                     //prompt to go to cut block
                     [self showRedirectAlert:@"Merge File" message:@"Cut block data merged successfully. Do you want to go to the cut block?" ];
                 }
            }
             */
        }else{
            //can't find cut block in databaes to merge
            [self showAlert:@"Merge Error" message:@"Cut Block not found."];
        }
        
    }else{
        //can't import xml file into cut block
        [self showAlert:@"Merge Error" message:@"Error on import xml file."];
    }
    
}

-(void)showAlert:(NSString*)title message:(NSString*)msg {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showRedirectAlert:(NSString*)title message:(NSString*)msg {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* goToAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self performSegueWithIdentifier:@"ImportCutBlockSegue" sender:self];
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    [alert addAction:goToAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - email function
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];

    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

#pragma mark - sorting

-(IBAction)sortByFileName:(id)sender{
    self.sortFileNameAscending = ! self.sortFileNameAscending;
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc ] initWithKey:@"fileName" ascending:self.sortFileNameAscending];
    
    self.files = [[NSMutableArray alloc] initWithArray:[self.files sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    [self.tableView reloadData];
}

-(IBAction)sortByCreatedDate:(id)sender{
    self.sortCreatedDateAscending = ! self.sortCreatedDateAscending;
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc ] initWithKey:@"createdDateStr" ascending:self.sortCreatedDateAscending];
    
    self.files = [[NSMutableArray alloc] initWithArray:[self.files sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    [self.tableView reloadData];
}

#pragma mark - delete file

-(void) deleteAllFiles{

    for(FileDTO * file in self.files){
        [self deleteFileByName:file.fileName];
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

#pragma mark - public
//function to handle import file from outside iForWaste
-(void)handleImportFile:(NSURL *)url{
    
    //get the data from the url and import the data from data
    XMLDataImporter *imp = [[XMLDataImporter alloc] init];
    WasteBlock *wb = nil;
    self.importFileURL = url;
    
    [self importResultPrompt:[imp ImportDataByURL:url wasteBlock:&wb ignoreExisting:NO]];
    if(wb){
        wb.position = nil;
        wb.registrationNumber = nil;
        wb.professional = nil;
        self.targetWasteBlock = wb;
    }
}

#pragma mark - segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if(![@"ImportDownloadSegue" isEqualToString:segue.identifier])
    {
        BlockViewController *blockVC = segue.destinationViewController;
        blockVC.wasteBlock = self.targetWasteBlock;
    }
    
    //clear local waste block pointer
    self.targetWasteBlock = nil;
}

#pragma Core Data functions

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

@end

