//
//  UINewStatusViewController.m
//  Stroff
//
//  Created by Ray on 12/12/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "UINewStatusViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface UINewStatusViewController ()

@end

@implementation UINewStatusViewController

- (id)init
{
    self = [self initWithNibName:@"UINewStatusViewController" bundle:nil];
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentSizeForViewInPopover = CGSizeMake(300, 300);
    [self.view addSubview:self.topView];
    self.topView.userInteractionEnabled = YES;
    self.btnStatus.userInteractionEnabled = YES;
    [self becomeFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.topView removeFromSuperview];
    [self.view addSubview:self.topView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTopView:nil];
    [self setBtnStatus:nil];
    [self setBtnPhotos:nil];
    [self setBtnVideos:nil];
    [self setBtnEvents:nil];
    [self setMiddleView:nil];
    [self setStatusView:nil];
    [self setPhotosView:nil];
    [self setBotView:nil];
    [super viewDidUnload];
}


- (IBAction)btnStatusClicked:(id)sender {
    [self removeAllSubviews:self.middleView];
    self.middleView.frame = CGRectMake(0, self.topView.frame.size.height, 300, self.statusView.frame.size.height);
    [self.middleView addSubview:self.statusView];
    self.contentSizeForViewInPopover = CGSizeMake(300,self.statusView.frame.size.height + self.topView.frame.size.height);
    if ([self.delegate respondsToSelector:@selector(didChageView)]) {
        [self.delegate didChageView];
    }
}

- (IBAction)btnPhotosClicked:(id)sender {
    [self removeAllSubviews:self.middleView];
    [self.middleView addSubview:self.PhotosView];
    self.contentSizeForViewInPopover = CGSizeMake(300, 300);
    if ([self.delegate respondsToSelector:@selector(didChageView)]) {
        [self.delegate didChageView];
    }
}

- (IBAction)btnVideosClicked:(id)sender {
    [self removeAllSubviews:self.middleView];
    self.contentSizeForViewInPopover = CGSizeMake(300, 100);
    if ([self.delegate respondsToSelector:@selector(didChageView)]) {
        [self.delegate didChageView];
    }
}

- (IBAction)btnEventsClicked:(id)sender {
    [self removeAllSubviews:self.middleView];
    self.contentSizeForViewInPopover = CGSizeMake(300, 200);
    if ([self.delegate respondsToSelector:@selector(didChageView)]) {
        [self.delegate didChageView];
    }
}

- (IBAction)btnChangeValue:(id)sender {
    UIButton *btnClicked = (UIButton*)sender;
    for (UIButton *btn in self.topView.subviews) {
        if (btn.tag != btnClicked.tag && btn.tag != 5) {
            btn.backgroundColor = [UIColor clearColor];
            btn.userInteractionEnabled = YES;
        }
    }
    btnClicked.userInteractionEnabled = NO;
    btnClicked.layer.cornerRadius = 2.0;
    btnClicked.backgroundColor =[UIColor grayColor];
}

- (void) removeAllSubviews:(UIView*) supperView
{
    for (UIView *view in supperView.subviews) {
        [view removeFromSuperview];
    }
}
@end
