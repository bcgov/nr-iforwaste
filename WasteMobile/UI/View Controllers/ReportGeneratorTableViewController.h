//
//  ReportGeneratorTableViewController.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-05.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
@protocol ReportGenerationProtocol <NSObject>
@optional
-(void) finishReportGeneration:(NSString *)feedback replace:(BOOL)replace;
@end
*/

// test
@class WastePlot;
@class WasteBlock;
@class WasteStratum;

extern NSString *const FeedbackSuccessful;
extern NSString *const FeedbackFailFilenameExist;
extern NSString *const FeedbackFailUnknown;

@interface ReportGeneratorTableViewController : UITableViewController
<UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *checkSummarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fs702Switch;
@property (weak, nonatomic) IBOutlet UISwitch *plotTallySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *blockTypeSummarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *plotPredictionSwitch;
@property (weak, nonatomic) IBOutlet UITextField *suffix;

@property (weak, nonatomic) IBOutlet UITableViewCell *plotPredictionTVC;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingWheel;

@property (strong, nonatomic) NSMutableArray *replaceReports;

@property BOOL tallySwitchEnabled;

@property (strong, nonatomic) WasteBlock *wasteBlock;
@property (strong, nonatomic) WasteStratum *wasteStratum;
@property (strong, nonatomic) WastePlot *wastePlot;


@property (strong, nonatomic) NSArray *wastePieces;


-(IBAction)goBack:(id)sender;
-(IBAction)generateReport:(id)sender;
@end
