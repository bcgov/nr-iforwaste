//
//  PlotTallyCardViewController.m
//  WasteMobile
//
//  Created by Dan Ebenal on 2014-05-15.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "PlotTallyCardViewController.h"
#import "WastePlot.h"
#import "WasteBlock.h"
#import "WastePiece.h"
#import "CheckerStatusCode.h"
#import "PieceTableViewCell.h"
#import "ScaleSpeciesCode.h"

@interface PlotTallyCardViewController () 

@end

@implementation PlotTallyCardViewController


@synthesize headerBlock = _headerBlock;
@synthesize headerStrip = _headerStrip;
@synthesize headerDate = _headerDate;
@synthesize headerPlotNumber = _headerPlotNumber;
@synthesize headerBaseline = _headerBaseline;
@synthesize headerStratum = _headerStratum;
@synthesize headerCheckX = _headerCheckX;
@synthesize headerCheckY = _headerCheckY;
@synthesize headerCheckNet = _headerCheckNet;
@synthesize headerSurveyX = _headerSurveyX;
@synthesize headerSurveyY = _headerSurveyY;
@synthesize headerSurveyNet = _headerSurveyNet;
@synthesize headerDeltaX = _headerDeltaX;
@synthesize headerDeltaY = _headerDeltaY;
@synthesize headerDeltaNet = _headerDeltaNet;
@synthesize headerMeasurePct = _headerMeasurePct;

@synthesize plotPiece = _plotPiece;



// Grab the managedObjectContext from AppDelegate
- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

//@synthesize pieceTableView = _pieceTableView;
//@synthesize checkedHeaderLabel = _checkedHeaderLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WastePlot *plot = [NSEntityDescription insertNewObjectForEntityForName:@"WastePlot" inManagedObjectContext:context];
    
    //WastePlot *plot = [[WastePlot alloc] init];
    plot.plotNumber = @1;
    plot.baseline = @"A";
    plot.strip = @1;
    plot.checkerMeasurePercent = @100;
    plot.assistant = @"plot assistant";
    plot.notes = @"plot notes";
    plot.returnNumber = @"plot return";
    
    WastePiece *p1 = [NSEntityDescription insertNewObjectForEntityForName:@"WastePiece" inManagedObjectContext:context];
    p1.pieceNumber = @"1";
    p1.length = @12;
    p1.lengthDeduction = @13;
    p1.addLength = @10;
    p1.buttDeduction = @14;
    p1.buttDiameter = @15;
    p1.notes = @"piece comment";

    p1.checkAvoidX = [NSDecimalNumber decimalNumberWithString:@"1.1"];
    p1.checkAvoidY = [NSDecimalNumber decimalNumberWithString:@"1.2"];
    p1.checkNetVal = [NSDecimalNumber decimalNumberWithString:@"1.3"];
    
    p1.deltaAvoidX = [NSDecimalNumber decimalNumberWithString:@"2.1"];
    p1.deltaAvoidY = [NSDecimalNumber decimalNumberWithString:@"2.2"];
    p1.deltaNetVal = [NSDecimalNumber decimalNumberWithString:@"2.3"];
    
    p1.surveyAvoidX = [NSDecimalNumber decimalNumberWithString:@"3.1"];
    p1.surveyAvoidY = [NSDecimalNumber decimalNumberWithString:@"3.2"];
    p1.surveyNetVal = [NSDecimalNumber decimalNumberWithString:@"3.3"];
    
    p1.pieceVolume = [NSDecimalNumber decimalNumberWithString:@"1.0"];
    
    CheckerStatusCode *statusCode = [NSEntityDescription insertNewObjectForEntityForName:@"CheckerStatusCode" inManagedObjectContext:context];
    statusCode.checkerStatusCode = @"2";
    
    p1.pieceCheckerStatusCode = statusCode;
    
    ScaleSpeciesCode *speciesCode = [NSEntityDescription insertNewObjectForEntityForName:@"ScaleSpeciesCode" inManagedObjectContext:context];
    speciesCode.scaleSpeciesCode = @"AL";
    
    p1.pieceScaleSpeciesCode = speciesCode;
    
    plot.plotPiece = [NSSet setWithObjects:p1, nil];
    
    
    
    self.plotPiece = [[NSMutableArray alloc] init];
    [self.plotPiece addObject:p1];
    
    [self.pieceTableView reloadData];
    
    //for (WastePiece *piece in )
                      
    /*
    NSMutableArray *labelArray = [[NSMutableArray alloc] init];
    
    [labelArray addObject:@"Checked;0;90"];
    [labelArray addObject:@"Piece No.;40;90"];
    [labelArray addObject:@"Species;80;90"];
    [labelArray addObject:@"Kind;120;90"];
    [labelArray addObject:@"Class;160;90"];
    [labelArray addObject:@"Length;200;90"];
    [labelArray addObject:@"Top;240;90"];
    [labelArray addObject:@"E;280;90"];
    [labelArray addObject:@"Butt;320;90"];
    [labelArray addObject:@"E;360;90"];
    [labelArray addObject:@"Grade;0;90"];
    [labelArray addObject:@"Leng\n(dm);0;90"];
    [labelArray addObject:@"Top;0;90"];
    [labelArray addObject:@"Butt;0;90"];
    [labelArray addObject:@"D;0;90"];
    [labelArray addObject:@"Far End;0;90"];
    [labelArray addObject:@"Add Length;0;90"];
    [labelArray addObject:@"Comment Code;0;90"];
    [labelArray addObject:@"Pirce Volumn;0;90"];
    [labelArray addObject:@"Add Length;0;90"];

    
    
    int locationCounter = 0;
    int alterCounter = 0;
    for (NSString *lbStr in labelArray){
        NSArray *lbStrAry = [lbStr componentsSeparatedByString:@";"];
        
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(locationCounter, 160, 130, 40)];
        lbl.text = [lbStrAry objectAtIndex:0];

        //if (alterCounter % 2){
        //    lbl.backgroundColor = [UIColor lightGrayColor];
        //}else{
            lbl.backgroundColor = [UIColor clearColor];
        //}
                
        lbl.textColor = [UIColor blackColor];
        lbl.highlightedTextColor = [UIColor blackColor];
        lbl.transform = CGAffineTransformMakeRotation(-M_PI_2);
        
        [self.view addSubview:lbl];
        
        locationCounter = locationCounter +40;
        alterCounter = alterCounter + 1;
    }
        
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(850, 220, 100, 30)];
    lbl.text = @"Survey ";
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor blackColor];
    lbl.highlightedTextColor = [UIColor blackColor];
    //lbl.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self.view addSubview:lbl];
    
    UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(920, 220, 100, 30)];
    lbl2.text = @"Checked";
    lbl2.backgroundColor = [UIColor clearColor];
    lbl2.textColor = [UIColor blackColor];
    lbl2.highlightedTextColor = [UIColor blackColor];
    //lbl2.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self.view addSubview:lbl2];
    
*/
    
    //self.checkedHeaderLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Data Binding
- (void)bindData:(WastePlot *)plot{
    self.headerPlotNumber.text = [plot.plotNumber stringValue];
    
    
}

// {[(Top Diameter - Top Deduction)^2 + (Butt Diameter - Butt Deduction)^2] / (Length - Length Deduction) / 10} * 0.0001572 * Measure Factor Increase
// Note: If Kind = S, Butt Diameter and Butt Deduction will not be entered -- treat them as 0
-(NSDecimalNumber *)calculatePieceVolume
{
    NSDecimalNumber *volume = [NSDecimalNumber zero];
    
    return volume;
}

// Calculating Survey Check information

// Summarize avoidable pieces with grade Y or better
// Returns a volume value
-(NSDecimalNumber *) calculatePlotTallySurveyY
{
    NSDecimalNumber *survey = [NSDecimalNumber zero];
    
    return survey;
}

// Summarize avoidable pieces with grade X or better
// Returns a volume value
-(NSDecimalNumber *) calculatePlotTallySurveyX
{
    NSDecimalNumber *survey = [NSDecimalNumber zero];
    
    return survey;
}

// Summarize all avoidable pieces
// Returns a dollar amount
-(NSDecimalNumber *) calculatePlotTallySurveyNet
{
    NSDecimalNumber *survey = [NSDecimalNumber zero];
    
    return survey;
}

// Summarize avoidable pieces with grade Y or better
// Returns a volume value
-(NSDecimalNumber *) calculatePlotTallyCheckY
{
    NSDecimalNumber *check = [NSDecimalNumber zero];
    
    return check;
}

// Summarize avoidable pieces with grade X or better
// Returns a volume value
-(NSDecimalNumber *) calculatePlotTallyCheckX
{
    NSDecimalNumber *check = [NSDecimalNumber zero];
    
    return check;
}

// Summarize all avoidable pieces
// Returns a dollar amount
-(NSDecimalNumber *) calculatePlotTallyCheckNet
{
    NSDecimalNumber *check = [NSDecimalNumber zero];
    
    return check;
}

// Determine difference between Survey and Check for avoidable pieces with grade Y or better
// Returns a percentage value
-(NSDecimalNumber *) calculatePlotTallyDeltaY
{
    NSDecimalNumber *delta = [NSDecimalNumber zero];
    
    return delta;
}

// Determine difference between Survey and Check for avoidable pieces with grade X or better
// Returns a percentage value
-(NSDecimalNumber *) calculatePlotTallyDeltaX
{
    NSDecimalNumber *delta = [NSDecimalNumber zero];
    
    return delta;
}

// Determine difference between Survey and Check for all avoidable pieces
// Returns a percentage amount
-(NSDecimalNumber *) calculatePlotTallyDeltaNet
{
    NSDecimalNumber *delta = [NSDecimalNumber zero];
    
    return delta;
}

#pragma mark - TableView funciton


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.plotPiece count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //for static variable name, start with upper case
    //static NSString *ApprovedCellStr = @"ApprovedTableCell";
    //static NSString *NotCheckedCellStr = @"NotCheckedTableCell";
    
    NSString *cellStr = @"";
    WastePiece *currentPiece = [self.plotPiece objectAtIndex:indexPath.row];
    
    //[self.plotPiece objectAtIndex:indexPath.row];
    if ([currentPiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"1"]){
        cellStr = @"NotCheckedTableCell";
    }else if([currentPiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"2"]){
        cellStr = @"ApproveTableCell";
    }else if([currentPiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"3"]){
        cellStr = @"NoTallyTableCell";
    }else if([currentPiece.pieceCheckerStatusCode.checkerStatusCode isEqualToString:@"4"]){
        cellStr = @"EditPieceTableCell";
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    // Configure the cell...
    //cell.pieceNumberLabel.text = currentPiece.pieceNumber;
    //cell.speciesLabel.text = currentPiece.pieceScaleSpeciesCode.scaleSpeciesCode;
    
    return cell;
}
@end
