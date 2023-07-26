//
//  SidebarViewController.h
//  WasteMobile
//  Created by Salus//

#import <UIKit/UIKit.h>

@interface SidebarViewController : UITableViewController

typedef enum NewCutBlockOptions{
    InteriorSRS,
    InteriorRatio,
    InteriorAggregate,
    InteriorAggregateSRS,
    CoastSRS,
    CoastRatio,
    CoastAggregate,
    CoastAggregateSRS,
    NotSelected
}NewCutBlockOptions;

- (IBAction)newCutBlock:(id)sender;

@end
