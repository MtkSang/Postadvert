//
//  UINewStatusViewController.m
//  Stroff
//
//  Created by Ray on 12/12/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "UINewStatusViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UserPAInfo.h"
#import "CredentialInfo.h"
#import "UIPlaceHolderTextView.h"
#import "Constants.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
#import "LinkPreview.h"


@interface UINewStatusViewController ()

@end

@implementation UINewStatusViewController

- (id)init
{
    self = [self initWithNibName:@"UINewStatusViewController" bundle:nil];
    return self;
}

- (id) initWithTargetID:(NSInteger) userID
{
    self = [self init];
    if (self) {
        self.targetID = userID;
    }
    return self;
}

- (id) initWithUserInfo:(CredentialInfo*) aUserInfo{
    self = [self init];
    if (self) {
        self.targetID = aUserInfo.registrationID;
        userInfo = aUserInfo;
    }
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    
    self.contentSizeForViewInPopover = CGSizeMake(300, 300);
    self.userAvatar.image = [UserPAInfo sharedUserPAInfo].imgAvatar;
    [self.phStatusTextView setPlaceholder:@"What's on your mind?"];
    activeBtn = self.btnStatus;
    activeControll = self.phStatusTextView;
    //setup for permittiontableView
    self.permissionTableView.tableFooterView = [[UIView alloc]init];
    //add tap to select photo when tapping on a UIImageView
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickImage)];
    [self.imgPhoto addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.usernameBtn setTitle:userInfo.fullName];
        [self.phStatusTextView becomeFirstResponder];  
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [activeControll becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [activeControll resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBtnStatus:nil];
    [self setBtnPhotos:nil];
    [self setBtnVideos:nil];
    [self setBtnEvents:nil];
    [self setUserAvatar:nil];
    [self setPhStatusTextView:nil];
    [self setPermissionTableView:nil];
    [self setCancelBtn:nil];
    [self setShareBtn:nil];
    [self setUsernameBtn:nil];
    [self setMiddleView:nil];
    [self setBotView:nil];
    [self setBtnPermittion:nil];
    [self setImgPhoto:nil];
    [self setPhotoView:nil];
    [self setPhPhotoTextView:nil];
    [self setScrollPhotoView:nil];
    [self setVideoTextField:nil];
    [self setBtnAddVideo:nil];
    [self setPhVideoTextViewDescription:nil];
    [self setVideoPreviewView:nil];
    [self setVideoView:nil];
    [super viewDidUnload];
}

#pragma mark - notification

- (void) keyboardWillBeShown:(NSNotification*)notification
{
    [self.permissionTableView removeFromSuperview];
    NSDictionary *info = [notification userInfo];
    CGRect frame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.view convertRect:frame fromView:nil];
    
    CGRect mainFrame = self.view.frame;
    mainFrame = [self.view convertRect:mainFrame fromView:nil];
    
    CGRect middleViewFrame = self.middleView.frame;
    middleViewFrame.origin.x = 52;
    middleViewFrame.origin.y = 44;
    middleViewFrame.size.width = frame.size.width - 52;
    middleViewFrame.size.height = mainFrame.size.height - middleViewFrame.origin.y - frame.size.height - 33;// 44 isquel botview
   
    CGRect botViewFrame = self.botView.frame;
    botViewFrame.origin.x = 0;
    botViewFrame.origin.y = mainFrame.size.height - frame.size.height - 32;
    botViewFrame.size.height = mainFrame.size.height - botViewFrame.origin.y;
    
    if (! self.botView.superview) {
        [self.view addSubview:self.botView];
    }
    
    CGRect phTextViewFrame = self.phStatusTextView.frame;
    phTextViewFrame.size = middleViewFrame.size;
    self.botView.frame = botViewFrame;
    self.phStatusTextView.frame = phTextViewFrame;
    if (activeBtn.tag == 2) {
        middleViewFrame.origin = CGPointZero;
        self.photoView.frame = middleViewFrame;
        float contentHeigh = phTextViewFrame.size.height / 2;
        if (contentHeigh >= self.imgPhoto.frame.size.height) {
            phTextViewFrame.size.height -= self.imgPhoto.frame.size.height;
        }else
            phTextViewFrame.size.height = contentHeigh;
        self.phPhotoTextView.frame = phTextViewFrame;
        CGRect scrollPhotoFrame = self.scrollPhotoView.frame;
        scrollPhotoFrame.origin.y = phTextViewFrame.origin.y + phTextViewFrame.size.height ;
        self.scrollPhotoView.frame = scrollPhotoFrame;
    }
    
    if (activeBtn.tag == 3) {
        middleViewFrame.origin = CGPointZero;
        self.videoView.frame = middleViewFrame;
        if (hasVideo) {
            self.videoPreviewView.hidden = NO;
            CGRect phVideoTextViewDesFrame = self.phVideoTextViewDescription.frame;
            phVideoTextViewDesFrame.origin.y = self.videoPreviewView.frame.origin.y + self.videoPreviewView.frame.size.height ;
            phVideoTextViewDesFrame.size.height = phTextViewFrame.size.height - (self.videoPreviewView.frame.origin.y + self.videoPreviewView.frame.size.height);
            self.phVideoTextViewDescription.frame = phVideoTextViewDesFrame;
        }else
        {
            CGRect phVideoTextViewDesFrame = self.phVideoTextViewDescription.frame;
            phVideoTextViewDesFrame.size.height = phTextViewFrame.size.height - phVideoTextViewDesFrame.origin.y;
            self.phVideoTextViewDescription.frame = phVideoTextViewDesFrame;
            self.videoPreviewView.hidden = YES;
        }
    }

    

}

- (void) keyboardWillBeHidden:(NSNotification*)notification
{
    
}

#pragma mark -


- (IBAction)cancelBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareBtnClicked:(id)sender {
    [self performSelectorInBackground:@selector(shareToServer) withObject:nil];    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)btnStatusClicked:(id)sender {
    [self removeAllSubviews:self.middleView];
    if ([self.delegate respondsToSelector:@selector(didChageView)]) {
        [self.delegate didChageView];
    }
    [self.middleView addSubview:self.phStatusTextView];
    [self.phStatusTextView becomeFirstResponder];
    activeControll = self.phStatusTextView;
    [self.phStatusTextView setPlaceholder:@"What's on your mind?"];
}

- (IBAction)btnPhotosClicked:(id)sender {
    [self removeAllSubviews:self.middleView];
    if ([self.delegate respondsToSelector:@selector(didChageView)]) {
        [self.delegate didChageView];
    }
    [self.middleView addSubview:self.photoView];
    [self.phPhotoTextView becomeFirstResponder];
    [self.phPhotoTextView setPlaceholder:@"Say something about this photo"];
    activeControll = self.phPhotoTextView;
}

- (IBAction)btnVideosClicked:(id)sender {
    [self removeAllSubviews:self.middleView];
    self.contentSizeForViewInPopover = CGSizeMake(300, 100);
    if ([self.delegate respondsToSelector:@selector(didChageView)]) {
        [self.delegate didChageView];
    }
    
    [self.middleView addSubview:self.videoView];
    [self.videoTextField becomeFirstResponder];
    [self.phVideoTextViewDescription setPlaceholder:@"Say something about this video"];
    activeControll = self.videoTextField;
}

- (IBAction)btnEventsClicked:(id)sender {
    [self removeAllSubviews:self.middleView];
    self.contentSizeForViewInPopover = CGSizeMake(300, 200);
    if ([self.delegate respondsToSelector:@selector(didChageView)]) {
        [self.delegate didChageView];
    }
}

- (IBAction)btnChangeValue:(id)sender {
    activeBtn = sender;
    UIButton *btnClicked = (UIButton*)sender;
    for (UIButton *btn in self.botView.subviews) {
        if (btn.tag != btnClicked.tag && btn.tag != 5) {
            btn.backgroundColor = [UIColor clearColor];
            btn.userInteractionEnabled = YES;
        }
    }
    btnClicked.userInteractionEnabled = NO;
    btnClicked.layer.cornerRadius = 2.0;
    btnClicked.backgroundColor =[UIColor grayColor];
}

- (IBAction)btnPermittionClicked:(id)sender {
    CGRect frame = self.botView.frame;
    frame.origin = CGPointZero;
    self.permissionTableView.frame = frame;
    [self.botView addSubview:self.permissionTableView];
    [activeControll resignFirstResponder];
}

- (IBAction)btnAddVideoClicked:(id)sender {
//    self.videoTextField.enabled = NO;
//    self.btnAddVideo.enabled = NO;
    [self addNewVideo];
    //[self performSelectorInBackground:@selector(addNewVideo) withObject:nil];
}

- (void) removeAllSubviews:(UIView*) supperView
{
    for (UIView *view in supperView.subviews) {
        [view removeFromSuperview];
    }
}

#pragma mark UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Audience";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellPermition"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellPermition"];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
    }
    
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"icons-privacy-public.png"];
        cell.textLabel.text = @"Public";

    }
    if (indexPath.row == 01) {
        cell.imageView.image = [UIImage imageNamed:@"icons-privacy-site-member.png"];
        cell.textLabel.text = @"Site Members";
        
    }
    if (indexPath.row == 02) {
        cell.imageView.image = [UIImage imageNamed:@"icons-privacy-friend.png"];
        cell.textLabel.text = @"Friends";
        
    }
    if (indexPath.row == 03) {
        cell.imageView.image = [UIImage imageNamed:@"icons-privacy-only-me.png"];
        cell.textLabel.text = @"Only me";
        
    }
    
    if (indexPath.row == permittionIndex) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    permittionIndex = indexPath.row;
    [tableView reloadData];
    [self changePermittionBtnIcon:indexPath.row];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    [UIView beginAnimations:nil context:nil];
    [tableView removeFromSuperview];
    [UIView commitAnimations];
    [activeControll becomeFirstResponder];
}

#pragma mark -

- (void)changePermittionBtnIcon:(NSInteger) index
{
    permittionIndex = index;
    NSString *imagename = @"icons-privacy-public.png";
    switch (index) {
        case 01:
            imagename = @"icons-privacy-site-member.png";
            break;
        case 02:
            imagename = @"icons-privacy-friend.png";
            break;
        case 03:
            imagename = @"icons-privacy-only-me.png";
            break;
            
        default:
            imagename = @"icons-privacy-public.png";
            break;
    }
    [self.btnPermittion setImage:[UIImage imageNamed:imagename] forState:UIControlStateNormal];
}

- (void) shareToServer
{
    NSString *acess =@"";
    switch (permittionIndex) {
        case 01:
            acess = @"20";
            break;
        case 02:
            acess = @"30";
            break;
        case 03:
            acess = @"40";
            break;
            
        default:
            acess = @"0";
            break;
    }
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    if (activeBtn.tag == 1) {
        //createStatusUpdate($actor, $target, $content, $limit = 5, $access = 0, $base64_image = false)
        functionName = @"createStatusUpdate";
        paraNames = [NSArray arrayWithObjects:@"actor", @"target", @"content", @"limit", @"access", nil];
        paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%ld", userInfo.registrationID], self.phStatusTextView.text, @"1", acess, nil];
    }
    
    if (activeBtn.tag == 2) {
        //createImageUpdate($user_id, $image_string, $description, $access = 0, $limit = 5, $base64_image = false, $album_id = null
        functionName = @"createImageUpdate";
        NSData *imageData = UIImageJPEGRepresentation(self.imgPhoto.image, 1.0f);
        NSString *encodedImage = [imageData base64EncodedString];
        paraNames = [NSArray arrayWithObjects:@"user_id", @"image_string", @"description", @"access", @"limit", nil];
        paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], encodedImage, self.phPhotoTextView.text, acess, @"1", nil];
        
        [PostadvertControllerV2 sharedPostadvertController].timeOut_in_minute = 10;
    }
    
    if (activeBtn.tag == 3) {
        //createVideoUpdate($user_id, $video_url, $description, $access = 0, $limit = 5, $category = 1, $base64_image = false)
        functionName = @"createVideoUpdate";
        paraNames = [NSArray arrayWithObjects:@"user_id", @"video_url", @"description", @"access", @"limit", @"category", nil];
        paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], self.videoTextField.text, self.phVideoTextViewDescription.text, acess, @"1", @"1", nil];
    }
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    [PostadvertControllerV2 sharedPostadvertController].timeOut_in_minute = 0;
}

- (void) pickImage
{
 
    UIActionSheet *actionView = [[UIActionSheet alloc]initWithTitle:@"Select photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    
    [actionView showFromRect:self.imgPhoto.frame inView:self.photoView animated:YES];
    
}

- (void) addNewVideo
{
    //getVideoInfoWhileCreating($video_url, $base64_image = false)
    //checkEmail($email, $from_where = 'app')
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"getVideoInfoWhileCreating";
    paraNames = [NSArray arrayWithObjects:@"video_url", nil];
    
    
    paraValues = [NSArray arrayWithObjects: [NSData base64EncodedStringFromplainText:self.videoTextField.text]  , nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    
    self.videoTextField.enabled = YES;
    self.btnAddVideo.enabled = YES;
    
    @try {
        NSInteger errorCode = [[data objectForKey:@"error_code"] integerValue];
        if (errorCode > 0) {
            [self.btnAddVideo setTitle:@"Change" forState:UIControlStateNormal];
            hasVideo = YES;
            [activeControll resignFirstResponder];
            [self.phVideoTextViewDescription becomeFirstResponder];
            activeControll = self.phVideoTextViewDescription;
            NSDictionary *dict = [data objectForKey:@"data"] ;
            
            [self.videoPreviewView loadContentWithFrame:self.videoPreviewView.frame LinkInfo:dict Type:linkPreviewTypeYoutube];
        }else
        {
            
        }
    }
    @catch (NSException *exception) {
        
    }
    
    
    
    
}

#pragma mark UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    [activeControll resignFirstResponder];
    MyUIImagePickerViewController *newPicker = [[MyUIImagePickerViewController alloc]initWithRoot:self];
    newPicker.delegate = self;
    
    if (buttonIndex == 0) {
        newPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    if (buttonIndex == 1) {
        newPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:newPicker animated:YES completion:^(void){
        NSLog(@"presented");
    }];
}


#pragma mark MyUIImagePickerViewControllerDelegate

- (void) didCancelPickingMedia
{
    
}

- (void) didFinishPickingMediaWithImage:(UIImage *)image
{
    hasPhoto = YES;
    self.imgPhoto.image = image;
}
@end
