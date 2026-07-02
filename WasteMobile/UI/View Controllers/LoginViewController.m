//
//  LoginViewController.m
//  WasteMobile
//
//  Created by Salus
//

#import "LoginViewController.h"
#import "SWRevealViewController.h"
#import "SearchViewController.h"
#import "WelcomeViewController.h"
#import "WasteWebServiceManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize webView;
@synthesize loadingLabel;
@synthesize loadingWheel;
@synthesize versionLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Check to see if we're already authenicated
    // If we are then go directly to SearchViewController

    self.title = @"(IFOR 101) Login";
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@cutBlockByReportingUnit/0", [WasteWebServiceManager getWSURLBASE]]];
    //NSURL *url = [NSURL URLWithString:@"https://carpool.ca"];
    //NSURL *url = [NSURL URLWithString:@"https://testapps.nrs.gov.bc.ca/ext/lexis"];
    NSLog(@"Web Service URL: %@", url.absoluteString);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    self.loadingWheel.hidesWhenStopped = YES;
    [self.loadingWheel stopAnimating];
    
    // Populate version number
    [versionLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"iForWasteVersionNumber"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier  isEqual: @"pushLogin"]){
        // Send credentials to Web Service
        
        // Consume Web Service data
        
        // Not Authenicated, display message
        // return NO;
        
        // Authenticated, continue with the segue
        return YES;
    }
    return NO;
}


- (IBAction)handleLoginAction:(id)sender {

    SearchViewController *search = [[SearchViewController alloc] initWithNibName:nil bundle:nil];
    //SearchViewController *search = [UIStoryboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self presentViewController:search animated:YES completion:NULL];
}

- (void) webViewDidStartLoad:(UIWebView *)loginWebView{

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [self.loadingLabel setHidden:NO];
    [self.loadingWheel startAnimating];

    
    timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(cancelLoading) userInfo:nil repeats:NO];
    
}

- (void) webViewDidFinishLoad:(UIWebView *)loginWebView{
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    [self.loadingLabel setHidden:YES];
    [self.loadingWheel stopAnimating];

    [timer invalidate];
    
    NSString *content =[loginWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    //NSLog(@"content: %@",content);
    
    // check for form tag
    // if there is a close form tag, stay on this screen and let user to do the authenitication process
    // if no close form tag tag, go to search screen
    if ([content rangeOfString:@"</form>"].location == NSNotFound && [content rangeOfString:@"</script>"].location == NSNotFound){

        [loginWebView stopLoading];
        
        SearchViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewControllerSID"];
        [self.navigationController pushViewController:svc animated:YES];
    }
    
    
}

-(void) cancelLoading{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    NSLog(@"Cancel the loading deal to timeout (20 seconds)");

    [self.loadingLabel setHidden:YES];
    [self.loadingWheel stopAnimating];
    
    [self.webView stopLoading];
    
    NSString *title = NSLocalizedString(@"Error", nil);
    NSString *message = NSLocalizedString(@"The web service is not available. Please try again later.",nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
	[alert show];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.cancelButtonIndex == buttonIndex) {
        // this is not working
/*
        NSLog(@"storyboard : %@", self.storyboard);
        
        WelcomeViewController *vc = [[WelcomeViewController alloc] init];
        
        [self presentViewController:vc animated:YES completion:nil];
 */
    }
}


@end
