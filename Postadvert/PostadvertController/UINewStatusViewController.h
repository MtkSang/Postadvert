//
//  UINewStatusViewController.h
//  Stroff
//
//  Created by Ray on 12/12/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UINewStatusViewControllerDelegate;

@interface UINewStatusViewController : UIViewController

@property (weak, nonatomic) id <UINewStatusViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotos;
@property (weak, nonatomic) IBOutlet UIButton *btnVideos;
@property (weak, nonatomic) IBOutlet UIButton *btnEvents;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (strong, nonatomic) IBOutlet UIView *statusView;
@property (strong, nonatomic) IBOutlet UIView *PhotosView;
@property (weak, nonatomic) IBOutlet UIView *botView;
- (IBAction)btnStatusClicked:(id)sender;
- (IBAction)btnPhotosClicked:(id)sender;
- (IBAction)btnVideosClicked:(id)sender;
- (IBAction)btnEventsClicked:(id)sender;
- (IBAction)btnChangeValue:(id)sender;

@end

@protocol UINewStatusViewControllerDelegate <NSObject>

- (void) didChageView;

@end