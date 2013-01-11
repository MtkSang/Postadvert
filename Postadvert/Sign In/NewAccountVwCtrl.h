//
//  NewAccountVwCtrl.h
//  PalUp
//
//  Created by Elisoft on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostAdvertController;
#import "FlagViewController.h"
@interface NewAccountVwCtrl : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, FlagViewControllerDelegate>
{
    
    UITextField                 *activeField;
    IBOutlet UITableView        *tableVw;
    UIImageView                 *imgUsrNmAvalidChk;
    UILabel                     *lblUsrNmAvalidChk;
    
    NSMutableArray              *listItems;
    CGRect                      keyboardFrame;
    UITableViewCell *cellCountry;
    int                         countryID;
}

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) NSMutableArray                    *listItems;
@property (strong, nonatomic) IBOutlet UIButton *btnCreateAccount;


-(IBAction) touchBackBtn: (id) sender;
-(IBAction) touchCreateAccountBtn: (id) sender;
-(IBAction) didEndOnExitTxt: (id) sender;


//-(unsigned int) tagOffsetFromIndexPath:(NSIndexPath *)indexPath;
-(void) keyboardWilBeShown:(NSNotification*)aNotification;
-(void) keyboardWillBeHidden:(NSNotification*)aNotification;
-(void) initTableView;

@end
