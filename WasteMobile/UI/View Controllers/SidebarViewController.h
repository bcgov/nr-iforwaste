//
//  SidebarViewController.h
//  WasteMobile
//  Created by Salus//

#import <UIKit/UIKit.h>

@interface SidebarViewController : UITableViewController

typedef enum NewCutBlockOptions{
    InteriorSRS,
    InteriorRatio,
    CoastSRS,
    NotSelected
}NewCutBlockOptions;

- (IBAction)newCutBlock:(id)sender;

@end
