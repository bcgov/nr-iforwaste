//
//  FooterStatView.h
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-17.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FooterStatView : UIView

@property (weak, nonatomic) IBOutlet UILabel *checkAvoidXLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkAvoidYLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkNetValLabel;
@property (weak, nonatomic) IBOutlet UILabel *surveyAvoidXLabel;
@property (weak, nonatomic) IBOutlet UILabel *surveyAvoidYLabel;
@property (weak, nonatomic) IBOutlet UILabel *surveyNetValLabel;
@property (weak, nonatomic) IBOutlet UILabel *deltaAvoidXLabel;
@property (weak, nonatomic) IBOutlet UILabel *deltaAvoidYLabel;
@property (weak, nonatomic) IBOutlet UILabel *deltaNetValLabel;

@property (weak, nonatomic) IBOutlet UILabel *billableVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cutControlVolumeLabel;

@property (weak, nonatomic) IBOutlet UILabel *checkLabel;
@property (weak, nonatomic) IBOutlet UILabel *differenceLabel;


-(void) setViewValue:(NSManagedObject *) managedObjet;
-(void) setDisplayFor:(NSString *)assessmentMethodCode screenName:(NSString *)screenName;
-(void) hideCheckStats:(BOOL) hideCheckStats;

@end
