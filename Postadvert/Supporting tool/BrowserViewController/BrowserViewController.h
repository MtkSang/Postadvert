//
//  BrowserViewController.h
//


#import <UIKit/UIKit.h>
#import "MyApplication.h"

// The names of the images for the 'back' and 'forward' buttons in the toolbar.
#define PNG_BUTTON_FORWARD @"right.png"
#define PNG_BUTTON_BACK @"left.png"

// List of all strings used
#define ACTION_CANCEL           @"Cancel"
#define ACTION_OPEN_IN_SAFARI   @"Open in Safari"

@interface BrowserViewController : UIViewController < UIWebViewDelegate, UIActionSheetDelegate >
{
    // the current URL of the UIWebView
    NSURL *url;
    
    // the UIWebView where we render the contents of the URL
    IBOutlet UIWebView *webView;
    
    // the UIToolbar with the "back" "forward" "reload" and "action" buttons
    IBOutlet UIToolbar *toolbar;
    UIView *toolView;
    // used to indicate that we are downloading content from the web
    UIActivityIndicatorView *activityIndicator;
    
    // pointers to the buttons on the toolbar
    UIBarButtonItem *backButton;
    UIButton *back_button;
    UIBarButtonItem *forwardButton;
    UIButton *forward_button;
    UIBarButtonItem *stopButton;
    UIButton *stop_button;
    UIBarButtonItem *reloadButton;
    UIButton *reload_button;
    UIBarButtonItem *actionButton;
    UIButton *action_button;
    UIBarButtonItem *linkButton;
    UITextView *linkView;
    UIButton *rightBtn;
}

@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) UIToolbar *toolbar;
@property(nonatomic, strong) UIView *toolView;
@property(nonatomic, strong) UIBarButtonItem *backButton;
@property(nonatomic, strong) UIBarButtonItem *forwardButton;
@property(nonatomic, strong) UIBarButtonItem *stopButton;
@property(nonatomic, strong) UIBarButtonItem *reloadButton;
@property(nonatomic, strong) UIBarButtonItem *actionButton;
@property(nonatomic, strong) UIBarButtonItem *linkButton;
@property(nonatomic, strong) UIButton *back_button;
@property(nonatomic, strong) UIButton *forward_button;
@property(nonatomic, strong) UIButton *stop_button;
@property(nonatomic, strong) UIButton *reload_button;
@property(nonatomic, strong) UIButton *action_button;
@property(nonatomic, strong) UITextView *linkView;

// Initializes the BrowserViewController with a specific URL 
- (id)initWithUrls:(NSURL*)u;
- (void) showHideToobar;

@end
