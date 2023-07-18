//
//  PlotSelectorLog.h
//  WasteMobile
//
//  Created by Jack Wong on 2017-03-14.
//  Copyright © 2017 Salus Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WastePlot.h"
#import "WasteStratum.h"

@interface PlotSelectorLog : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

+(NSString *) getPlotSelectorLog:(WastePlot*)wp  actionDec:(NSString*)actionDec;

@end
