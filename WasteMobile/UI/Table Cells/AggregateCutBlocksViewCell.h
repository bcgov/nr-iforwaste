//
//  AggregateCutBlocksViewCell.h
//  EForWasteBC
//
//  Created by Chris Nesmith on 3/11/19.
//  Copyright © 2019 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AggregateCutBlocksViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cutBlockNo;
@property (weak, nonatomic) IBOutlet UILabel *cutBlockId;
@property (weak, nonatomic) IBOutlet UILabel *cutBlockArea;
@property (weak, nonatomic) IBOutlet UILabel *cutBlockLicense;
@property (weak, nonatomic) IBOutlet UILabel *cutBlockPredPlot;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingWheel;

@property (strong, nonatomic) NSNumber *wasteAssessmentAreaID;

@end
