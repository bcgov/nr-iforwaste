//
//  PlotTallyCardViewController.h
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-15.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@class WastePlot;

@interface PlotTallyCardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) IBOutlet UILabel *headerBlock;
@property (weak, nonatomic) IBOutlet UILabel *headerStratum;
@property (weak, nonatomic) IBOutlet UILabel *headerPlotNumber;
@property (weak, nonatomic) IBOutlet UILabel *headerBaseline;
@property (weak, nonatomic) IBOutlet UILabel *headerStrip;
@property (weak, nonatomic) IBOutlet UILabel *headerMeasurePct;
@property (weak, nonatomic) IBOutlet UILabel *headerDate;
@property (weak, nonatomic) IBOutlet UILabel *headerSurveyY;
@property (weak, nonatomic) IBOutlet UILabel *headerSurveyX;
@property (weak, nonatomic) IBOutlet UILabel *headerSurveyNet;
@property (weak, nonatomic) IBOutlet UILabel *headerCheckY;
@property (weak, nonatomic) IBOutlet UILabel *headerCheckX;
@property (weak, nonatomic) IBOutlet UILabel *headerCheckNet;
@property (weak, nonatomic) IBOutlet UILabel *headerDeltaY;
@property (weak, nonatomic) IBOutlet UILabel *headerDeltaX;
@property (weak, nonatomic) IBOutlet UILabel *headerDeltaNet;

@property (strong, nonatomic) IBOutlet UITableView *pieceTableView;

@property (strong, nonatomic) NSMutableArray *plotPiece;

-(NSDecimalNumber *)calculatePlotTallySurveyY;
-(NSDecimalNumber *)calculatePlotTallySurveyX;
-(NSDecimalNumber *)calculatePlotTallySurveyNet;
-(NSDecimalNumber *)calculatePlotTallyCheckY;
-(NSDecimalNumber *)calculatePlotTallyCheckX;
-(NSDecimalNumber *)calculatePlotTallyCheckNet;
-(NSDecimalNumber *)calculatePlotTallyDeltaY;
-(NSDecimalNumber *)calculatePlotTallyDeltaX;
-(NSDecimalNumber *)calculatePlotTallyDeltaNet;

-(void)bindData:(WastePlot *) plot;
@end
