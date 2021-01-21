//
//  FooterStatView.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-10-17.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "FooterStatView.h"

@implementation FooterStatView

@synthesize checkAvoidXLabel, checkAvoidYLabel, checkNetValLabel;
@synthesize surveyAvoidXLabel, surveyAvoidYLabel, surveyNetValLabel;
@synthesize deltaAvoidYLabel, deltaNetValLabel, deltaAvoidXLabel;
@synthesize billableVolumeLabel, cutControlVolumeLabel, checkLabel, differenceLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setViewValue:(NSManagedObject *) managedObject{
    self.checkAvoidXLabel.text = [managedObject valueForKey:@"checkAvoidX"] && [(NSDecimalNumber *)[managedObject valueForKey:@"checkAvoidX"] floatValue] > 0 ? [NSString stringWithFormat:@"%.4f",[(NSDecimalNumber *)[managedObject valueForKey:@"checkAvoidX"] floatValue]]: @"0.0000";
    self.checkAvoidYLabel.text = [managedObject valueForKey:@"checkAvoidY"] && [(NSDecimalNumber *)[managedObject valueForKey:@"checkAvoidY"] floatValue] > 0 ? [NSString stringWithFormat:@"%.4f",[(NSDecimalNumber *)[managedObject valueForKey:@"checkAvoidY"] floatValue]]: @"0.0000";
    self.checkNetValLabel.text = [managedObject valueForKey:@"checkNetVal"] && [(NSDecimalNumber *)[managedObject valueForKey:@"checkNetVal"] floatValue] > 0 ? [NSString stringWithFormat:@"$%.2f",[(NSDecimalNumber *)[managedObject valueForKey:@"checkNetVal"] floatValue]]: @"$0.00";
    self.surveyAvoidXLabel.text = [managedObject valueForKey:@"surveyAvoidX"] && [(NSDecimalNumber *)[managedObject valueForKey:@"surveyAvoidX"] floatValue] > 0 ? [NSString stringWithFormat:@"%.4f",[(NSDecimalNumber *)[managedObject valueForKey:@"surveyAvoidX"] floatValue]]: @"0.0000";
    self.surveyAvoidYLabel.text = [managedObject valueForKey:@"surveyAvoidY"] && [(NSDecimalNumber *)[managedObject valueForKey:@"surveyAvoidY"] floatValue] > 0 ? [NSString stringWithFormat:@"%.4f",[(NSDecimalNumber *)[managedObject valueForKey:@"surveyAvoidY"] floatValue]]: @"0.0000";
    self.surveyNetValLabel.text = [managedObject valueForKey:@"surveyNetVal"] && [(NSDecimalNumber *)[managedObject valueForKey:@"surveyNetVal"] floatValue] > 0 ? [NSString stringWithFormat:@"$%.2f",[(NSDecimalNumber *)[managedObject valueForKey:@"surveyNetVal"] floatValue]]: @"$0.00";
    self.deltaAvoidYLabel.text = [managedObject valueForKey:@"deltaAvoidY"] && [(NSDecimalNumber *)[managedObject valueForKey:@"deltaAvoidY"] floatValue] > 0 ? [NSString stringWithFormat:@"%.1f",[(NSDecimalNumber *)[managedObject valueForKey:@"deltaAvoidY"] floatValue]]: @"0.0";
    self.deltaAvoidXLabel.text = [managedObject valueForKey:@"deltaAvoidX"] && [(NSDecimalNumber *)[managedObject valueForKey:@"deltaAvoidX"] floatValue] > 0 ? [NSString stringWithFormat:@"%.1f",[(NSDecimalNumber *)[managedObject valueForKey:@"deltaAvoidX"] floatValue]]: @"0.0";
    self.deltaNetValLabel.text = [managedObject valueForKey:@"deltaNetVal"] && [(NSDecimalNumber *)[managedObject valueForKey:@"deltaNetVal"] floatValue] > 0 ? [NSString stringWithFormat:@"%.1f",[(NSDecimalNumber *)[managedObject valueForKey:@"deltaNetVal"] floatValue]]: @"0.0";
}

-(void) setDisplayFor:(NSString *)assessmentMethodCode screenName:(NSString *)screenName{
    if ([screenName isEqualToString:@"plot"]){
        
        if(![assessmentMethodCode isEqualToString:@"P"]){
            billableVolumeLabel.text = @"Total Billable Volume (m\u00B3)";
            cutControlVolumeLabel.text = @"Total Cut Control Volume (m\u00B3)";
        }else{
            billableVolumeLabel.text = @"Total Billable Volume (m\u00B3/ha)";
            cutControlVolumeLabel.text = @"Total Cut Control Volume (m\u00B3/ha)";
        }
    }else if ([screenName isEqualToString:@"stratum"]){
        billableVolumeLabel.text = @"Billable Volume (m\u00B3/ha)";
        cutControlVolumeLabel.text = @"Cut Control Volume (m\u00B3/ha)";
        
    }else if( [screenName isEqualToString:@"block"]){
        billableVolumeLabel.text = @"Billable Volume (m\u00B3/ha)";
        cutControlVolumeLabel.text = @"Cut Control Volume (m\u00B3/ha)";
        
    }
}

-(void) hideCheckStats:(BOOL) hideCheckStats{
    if (hideCheckStats){
        [checkAvoidXLabel setHidden:YES];
        [checkAvoidYLabel setHidden:YES];
        [checkNetValLabel setHidden:YES];
        [deltaAvoidXLabel setHidden:YES];
        [deltaAvoidYLabel setHidden:YES];
        [deltaNetValLabel setHidden:YES];
        [checkLabel setHidden:YES];
        [differenceLabel setHidden:YES];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
