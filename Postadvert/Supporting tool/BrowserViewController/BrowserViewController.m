//
//  BrowserViewController.m
//


#import "BrowserViewController.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
@implementation BrowserViewController

@synthesize webView;
@synthesize url;
@synthesize toolbar;
@synthesize forwardButton;
@synthesize backButton;
@synthesize stopButton;
@synthesize reloadButton;
@synthesize actionButton;
@synthesize linkButton;
@synthesize linkView;
@synthesize toolView, back_button, forward_button, stop_button, reload_button, action_button;

/**********************************************************************************************************************/
#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)uias clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // user pressed "Cancel"
    if(buttonIndex == [uias cancelButtonIndex]) return;
        
    // user pressed "Open in Safari"
    if([[uias buttonTitleAtIndex:buttonIndex] compare:ACTION_OPEN_IN_SAFARI] == NSOrderedSame)
    {
        [(MyApplication*)[UIApplication sharedApplication] openURL:self.webView.request.URL forceOpenInSafari:YES];
    }
    
    if([[uias buttonTitleAtIndex:buttonIndex] compare:@"Copy URL"] == NSOrderedSame)
    {
        //copy URL
        [UIPasteboard generalPasteboard].string = self.linkView.text ;
        NSLog(@"You copied %@ ",[UIPasteboard generalPasteboard].string);
        //[pasteboard release];
        
    }
}


/**********************************************************************************************************************/
#pragma mark - Object lifecycle



- (id)initWithUrls:(NSURL*)u
{
    self = [self initWithNibName:@"BrowserViewController" bundle:nil];
    if(self)
    {
        self.webView.delegate = self;
        self.url = u;
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0 , 0.0, 30, 30)];
        self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:PNG_BUTTON_FORWARD] 
                                                              style:UIBarButtonItemStylePlain 
                                                             target:self 
                                                             action:@selector(forwardButtonPressed:)];
        

        
        self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:PNG_BUTTON_BACK]
                                                           style:UIBarButtonItemStylePlain 
                                                          target:self 
                                                          action:@selector(backButtonPressed:)];
         
        self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
                                                                        target:self 
                                                                        action:@selector(stopReloadButtonPressed:)];
        
        self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                          target:self 
                                                                          action:@selector(stopReloadButtonPressed:)];
        
        self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                          target:self
                                                                          action:@selector(actionButtonPressed:)];
        
        self.linkView.frame = CGRectMake(0.0, (cCellHeight - 30) / 2.0,  CELL_CONTENT_WIDTH * 5 / 9 , 30.0);
        self.linkView.text = [self.url absoluteString];
        self.linkView.layer.borderWidth = 1.0;
        self.linkView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.linkView.layer.cornerRadius = 5.0;
        self.linkView.userInteractionEnabled = NO;
        self.linkView.textColor = [UIColor grayColor];
        //self.linkView.backgroundColor = [UIColor underPageBackgroundColor];
        [self.linkView setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        self.linkButton = [[UIBarButtonItem alloc] initWithCustomView:linkView];
        
        rightBtn.frame = CGRectMake(30, 0, 30, 30);
        rightBtn.layer.cornerRadius = 3.5;
        rightBtn.layer.borderWidth = 0.2;
        rightBtn.layer.masksToBounds = YES;
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**********************************************************************************************************************/
#pragma mark - View lifecycle


- (void)updateToolbar
{
    // toolbar
    self.forwardButton.enabled = [self.webView canGoForward];
    self.backButton.enabled = [self.webView canGoBack];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];        
    NSMutableArray *toolbarButtons = [[NSMutableArray alloc] initWithObjects:self.backButton, flexibleSpace, self.forwardButton, flexibleSpace, self.reloadButton, linkButton , self.actionButton, nil];
    
    if([activityIndicator isAnimating]) [toolbarButtons replaceObjectAtIndex:4 withObject:self.stopButton];
    
    [self.toolbar setItems:toolbarButtons animated:YES];
    
    // page title
    //NSString *pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //if(pageTitle) [[self navigationItem] setTitle:pageTitle];;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"enterWebBrowser" object:nil];
    toolbar.hidden = YES;
    toolbar.backgroundColor = [UIColor grayColor];
    toolbar.alpha = 0.9;
    CGRect frame ;//= toolbar.frame;
    //frame.origin.y = cStatusAndNavBar;
    //toolbar.frame = frame;
    
    frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = toolbar.frame.origin.y + toolbar.frame.size.height;
    webView.frame = frame;
    frame.size.height += toolbar.frame.size.height;
    webView.scrollView.contentSize = frame.size ;
    self.webView.scalesPageToFit = YES;
    //toolbar.frame = CGRectMake(0.0, webView.frame.origin.y + cStatusBarHeight, self.view.frame.size.width, toolbar.frame.size.height);
    //[self.view addSubview:toolbar];
    [self showHideToobar];
    [self showHideToobar];
    [self showHideToobar];
    [self.view addSubview:webView];
    
    [rightBtn addTarget:self action:@selector(showHideToobar) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rightViewButton = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30 * 2, 30)];
    [rightViewButton addSubview:activityIndicator];
    [rightViewButton addSubview:rightBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightViewButton];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    [self updateToolbar];
    NSLog(@"WebView Loaded");
}


- (void)viewDidUnload
{
    [[self navigationItem] setRightBarButtonItem:nil];
    [activityIndicator removeFromSuperview];
    [super viewDidUnload];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"enterWebBrowser" object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


/**********************************************************************************************************************/
#pragma mark - User Interaction
- (void) hideToolbarAfterDidLoad:(NSString*) u
{
    if ([u isEqualToString:[self.webView.request.URL absoluteString]]) {
        if (!toolbar.hidden) {
            [self showHideToobar];
        }
    }
}

- (void) showHideToobar
{
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
    [UIView beginAnimations:@"showHideToolbar" context:( void *)self.view];
    if (toolbar.hidden) {// to do: Show toolbar
        toolbar.frame = CGRectMake(0.0, webView.frame.origin.y, self.view.frame.size.width, toolbar.frame.size.height);
        CGRect frame = webView.frame;
        frame.origin.y = toolbar.frame.size.height;
        webView.frame= frame;
    }else {
        toolbar.frame = CGRectMake(0.0, 0, self.view.frame.size.width, toolbar.frame.size.height);
        CGRect frame = webView.frame;
        frame.origin.y = frame.origin.y - toolbar.frame.size.height;
        webView.frame = frame;
    }
    [UIView commitAnimations];
    toolbar.hidden = ! toolbar.hidden;
    //update image for rightbutton
    if (toolbar.hidden) {
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"hide_toolbar.png"] forState:UIControlStateNormal];
    }else {
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"show_toolbar.png"] forState:UIControlStateNormal];
    }
}

- (void)backButtonPressed:(id)sender
{
    if([self.webView canGoBack]) [self.webView goBack];
}


- (void)forwardButtonPressed:(id)sender
{
    if([self.webView canGoForward]) [self.webView goForward];
}


- (void)stopReloadButtonPressed:(id)sender
{
    if([activityIndicator isAnimating])
    {
        [self.webView stopLoading];
        [activityIndicator stopAnimating];
    }
    else
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
    }
    
    [self updateToolbar];
}


- (void)actionButtonPressed:(id)sender
{    
    UIActionSheet *uias = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self 
                                             cancelButtonTitle:ACTION_CANCEL 
                                        destructiveButtonTitle:nil 
                                             otherButtonTitles:ACTION_OPEN_IN_SAFARI, @"Copy URL", nil];
    
    [uias showInView:self.view];
}


/**********************************************************************************************************************/
#pragma mark - WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.linkView.text = [request.URL absoluteString];
    [self.linkView setNeedsDisplay];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)nwebView
{
    if (toolbar.hidden) {
        [self showHideToobar];
    }
    [activityIndicator startAnimating];
    self.linkView.text = [nwebView.request.URL absoluteString];
    [self.linkView setNeedsDisplay];
    NSLog(@"URL %@",[nwebView.request.URL absoluteString]);
    [self updateToolbar];
}


- (void)webViewDidFinishLoad:(UIWebView *)nwebView
{

    [self performSelector:@selector(hideToolbarAfterDidLoad:) withObject:[nwebView.request.URL absoluteString] afterDelay:2.5];
    if(activityIndicator) [activityIndicator stopAnimating];
    self.linkView.text = [nwebView.request.URL absoluteString];
    [self.linkView setNeedsDisplay];
    [self updateToolbar];
    NSLog(@"WebView DidLoad");
}


- (void)webView:(UIWebView *)nwebView didFailLoadWithError:(NSError *)error
{   
    self.linkView.text = [nwebView.request.URL absoluteString];
    [self.linkView setNeedsDisplay];
    [self updateToolbar];
}


@end
