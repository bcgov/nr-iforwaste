//
//  LoginController.h
//  WasteMobile
//
//  Created by Salus

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface LoginViewController : UIViewController
<UIWebViewDelegate, UIAlertViewDelegate>
{
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingWheel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end
