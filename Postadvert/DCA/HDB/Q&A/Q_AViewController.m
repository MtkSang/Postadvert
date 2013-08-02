//
//  Q_AViewController.m
//  Stroff
//
//  Created by Ray on 7/11/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "Q_AViewController.h"
#import "Constants.h"
#import "PostadvertControllerV2.h"
#import "MBProgressHUD.h"
#import "UserPAInfo.h"
#import "CredentialInfo.h"
#import "UIImageView+URL.h"
#import "NSData+Base64.h"
#import <QuartzCore/QuartzCore.h>
@interface Q_AViewController ()

@end

@implementation Q_AViewController

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
    
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"start_getLatestAnswert"];
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"max_id_getLatestAnswer"];
    [[NSUserDefaults standardUserDefaults] setValue:@"up" forKey:@"scroll"];
    listLastestAnswers = [[NSMutableArray alloc]init];
    UIImage *image = [UIImage imageNamed:@"titleHDB.png"];
    //image = [image resizedImage:self.lbTitle.frame.size interpolationQuality:0];
    [self.lbTitle setBackgroundColor:[UIColor colorWithPatternImage:image]];
    [self.lbTitle setText:self.itemName];

    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 80);
    _headerView.backgroundColor = [UIColor colorWithRed:57.0/255 green:60.0/255.0 blue:38.0/255 alpha:1];
    _leftButton.frame = CGRectMake(10, 50, 149, 30);
    [_leftButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_leftButton setTitle:@"Lastest Answers" forState:UIControlStateNormal];
    _rightButton.frame = CGRectMake(161, 50, 149, 30);
    [_rightButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton setTitle:@"Most Popular" forState:UIControlStateNormal];
    currentButton = _leftButton;
    
    [self updateButtonSelected];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(20, 50, 280, 30)];
    view.backgroundColor = [UIColor colorWithRed:183.0/255 green:220.0/255 blue:223.0/255 alpha:1];
    [_headerView addSubview:view];
    [_headerView sendSubviewToBack:view];
    
    self.tableView.tableHeaderView = _headerView;
    self.tableView.separatorColor = [UIColor colorWithRed:79.0/255 green:177.0/255 blue:190.0/255 alpha:1];
    
    
    for(UIView *subView in self.searchBar.subviews) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)subView setKeyboardAppearance: UIKeyboardAppearanceAlert];
                [(UITextField *)subView setReturnKeyType:UIReturnKeyDone];
                [(UITextField *)subView setEnablesReturnKeyAutomatically:NO];
            }
            @catch (NSException *exception) {
                
            }
        }
    }
    
    mbpLastest = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:mbpLastest];
    [mbpLastest showWhileExecuting:@selector(getLatestAnswer) onTarget:self withObject:nil animated:YES];
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44)];
    [footerView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    footerView.autoresizesSubviews = YES;
    self.view.frame =[[UIScreen mainScreen] bounds];
    //self.tableView.frame = [[UIScreen mainScreen] bounds];
    [self.tableView setTableFooterView: footerView];
    // = [UIColor colorWithRed:235/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    footerLoading = [[MBProgressHUD alloc]initWithView:self.tableView.tableFooterView];
    footerLoading.hasBackground = NO;
    footerLoading.mode = MBProgressHUDModeIndeterminate;
    footerLoading.autoresizingMask = footerView.autoresizingMask;
    footerLoading.autoresizesSubviews = YES;
    footerView = nil;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLbTitle:nil];
    [self setTableView:nil];
    [self setHeaderView:nil];
    [self setSearchBar:nil];
    [self setLeftButton:nil];
    [self setRightButton:nil];
    [super viewDidUnload];
}
#pragma mark - Action
- (void) btnClicked:(id) sender
{
    if (sender == currentButton) {
        return;
    }else
        currentButton = sender;
    [self performSelectorOnMainThread:@selector(updateButtonSelected) withObject:nil waitUntilDone:NO];
    //Update value for sort by
    
    [self.tableView reloadData];
}


#pragma  mark - UItabBarDelegate

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
}

#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listLastestAnswers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (q_aType) {
        case Q_ALastestAnswer:
            return [self loadQ_ACellForTableView:tableView AtIndexPath:indexPath];
            break;
        case Q_APopularQuestion:
            return [self loadQ_AMostPopularCellForTableView:tableView AtIndexPath:indexPath];
        default:
            break;
    }
    
    
    return [[UITableViewCell alloc]init];
}


- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [listLastestAnswers objectAtIndex:indexPath.row];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    float y = 20.0f;
    if (q_aType == Q_ALastestAnswer) {
        NSString *question = @"Q: ";
        question = [question stringByAppendingString:[NSData stringDecodeFromBase64String: [dict objectForKey:@"content"]]];
        
        CGSize constraint = CGSizeMake(220, 20000.0f);
        CGSize size = [question sizeWithFont:[UIFont fontWithName:FONT_NAME size:10.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        y += size.height + CELL_CONTENT_MARGIN_TOP;
        
        NSString *answerBy = [dict objectForKey:@"created"];
        NSString *replies = [dict objectForKey:@"total_answer"];
        NSString *cat_name = [NSData stringDecodeFromBase64String:[dict objectForKey:@"cat_name"]];
        NSString *text = [NSString stringWithFormat:@"Answered by on %@ | %@ Replies \nCategogy: %@", answerBy, replies, cat_name];
        
        size = [text sizeWithFont:[UIFont fontWithName:FONT_NAME size:10.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        y += size.height + CELL_CONTENT_MARGIN_TOP;
        
        NSDictionary *dict_Answer = [dict objectForKey:@"answer"];
        NSString *answer = @"A: ";
        answer = [answer stringByAppendingString: [NSData stringDecodeFromBase64String:[dict_Answer objectForKey:@"content"]]];
        
        size = [answer sizeWithFont:[UIFont fontWithName:FONT_NAME size:10.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        y += size.height + CELL_CONTENT_MARGIN_TOP;
    }
    
    if (q_aType == Q_APopularQuestion) {
        NSString *question = @"Q: ";
        question = [question stringByAppendingString:[NSData stringDecodeFromBase64String: [dict objectForKey:@"content"]]];
        
        CGSize constraint = CGSizeMake(220, 20000.0f);
        CGSize size = [question sizeWithFont:[UIFont fontWithName:FONT_NAME size:10.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        y += size.height + CELL_CONTENT_MARGIN_TOP;
    }

    
    //Claps_commnets
    y += 26;
    if (y < 106) {
        y =106;
    }
    return y;
}


#pragma mark - implement

- (void) updateButtonSelected
{
    if (currentButton == _leftButton) {
        [_leftButton setBackgroundImage:[UIImage imageNamed:@"leftPressed.png"]  forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"rightUnPress.png"] forState:UIControlStateNormal];
        q_aType = Q_ALastestAnswer;
    }else
    {
        //rightButton
        [_leftButton setBackgroundImage:[UIImage imageNamed:@"leftUnPress.png"]  forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"rightPressed.png"] forState:UIControlStateNormal];
        q_aType = Q_APopularQuestion;
    }
//    set For first loading
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"start_getLatestAnswert"];
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"max_id_getLatestAnswer"];
    [[NSUserDefaults standardUserDefaults] setValue:@"up" forKey:@"scroll"];
    [listLastestAnswers removeAllObjects];
    switch (q_aType) {
        case Q_ALastestAnswer:
            [mbpLastest showWhileExecuting:@selector(getLatestAnswer) onTarget:self withObject:nil animated:YES];
            break;
        case Q_APopularQuestion:
            [mbpLastest showWhileExecuting:@selector(getPopularQuestion) onTarget:self withObject:nil animated:YES];
            break;
        default:
            break;
    }
}

- (UITableViewCell*) loadQ_ACellForTableView:(UITableView*)tableView AtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifierQ_ACell = @"Q_ACellListLastestAnswer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierQ_ACell];
    if (cell == nil) {
        NSArray *nib = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            nib = [[NSBundle mainBundle] loadNibNamed:@"Q_ACellList" owner:self options:nil];
        }
        else{
            nib = [[NSBundle mainBundle] loadNibNamed:@"Q_ACellList" owner:self options:nil];
        }
        cell = (UITableViewCell*)[nib objectAtIndex:0];
    }
    NSDictionary *dict = [listLastestAnswers objectAtIndex:indexPath.row];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return cell;
    }
    @try {
        //Background
        UIView *backgroundView = [cell viewWithTag:100];
        backgroundView.layer.cornerRadius = 5.0f;
        
    //    User
        CredentialInfo *author = [[CredentialInfo alloc]initWithDictionary:[dict objectForKey:@"author"]];
        UILabel *userName = (UILabel*)[cell viewWithTag:1];
        userName.text = author.usernamePU;
        UIImageView *avatar = (UIImageView*)[cell viewWithTag:2];
        [avatar setImageWithURL:[NSURL URLWithString:author.avatarUrl] placeholderImage:[UIImage imageNamed:@"user_default_thumb.png" ]];
        UILabel *created = (UILabel*)[cell viewWithTag:4];
        created.text =  [NSData stringDecodeFromBase64String: [dict objectForKey:@"created_on_lapseTime"]];
        
        UILabel *lbQuestion = (UILabel*)[cell viewWithTag:5];
        NSString *question = @"Q: ";
        question = [question stringByAppendingString:[NSData stringDecodeFromBase64String: [dict objectForKey:@"content"]]];
        lbQuestion.text = question;
        
        CGRect frame;
        float y = 20;
        CGSize constraint = CGSizeMake(220, 20000.0f);
        CGSize size = [question sizeWithFont:lbQuestion.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        frame = lbQuestion.frame;
        frame.size = size;
        frame.origin.y = y;
        lbQuestion.frame = frame;
        y += frame.size.height + CELL_CONTENT_MARGIN_TOP;
        UILabel *answerBy_catelogy = (UILabel*)[cell viewWithTag:6];
        NSString *answerBy = [dict objectForKey:@"created"];
        NSString *replies = [dict objectForKey:@"total_answer"];
        NSString *cat_name = [NSData stringDecodeFromBase64String:[dict objectForKey:@"cat_name"]];
        answerBy_catelogy.text = [NSString stringWithFormat:@"Answered by on %@ | %@ Replies \nCategogy: %@", answerBy, replies, cat_name];
        
        size = [answerBy_catelogy.text sizeWithFont:answerBy_catelogy.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        frame = answerBy_catelogy.frame;
        frame.size = size;
        frame.origin.y = y;
        answerBy_catelogy.frame = frame;
        y += frame.size.height + CELL_CONTENT_MARGIN_TOP;
        
        UILabel *lbAnswer = (UILabel*)[cell viewWithTag:7];
        NSDictionary *dict_Answer = [dict objectForKey:@"answer"];
        NSString *answer = @"A: ";
        answer = [answer stringByAppendingString: [NSData stringDecodeFromBase64String:[dict_Answer objectForKey:@"content"]]];
        lbAnswer.text = answer;
        
        size = [lbAnswer.text sizeWithFont:lbAnswer.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        frame = lbAnswer.frame;
        frame.size = size;
        frame.origin.y = y;
        lbAnswer.frame = frame;
        y += frame.size.height + CELL_CONTENT_MARGIN_TOP;
        
        //Claps_commnets
        UIView *aView = [cell viewWithTag:8];
//        frame = aView.frame;
//        frame.origin.y = y;
//        aView.frame = frame;
        [self setClapCommentForCell:[aView viewWithTag:1] withDict:dict];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    @catch (NSException *exception) {
        return cell;
    }
    
    return cell;
}
- (UITableViewCell*) loadQ_AMostPopularCellForTableView:(UITableView*)tableView AtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifierQ_ACell = @"Q_ACellListMostPupolar";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierQ_ACell];
    if (cell == nil) {
        NSArray *nib = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            nib = [[NSBundle mainBundle] loadNibNamed:@"Q_ACellList" owner:self options:nil];
        }
        else{
            nib = [[NSBundle mainBundle] loadNibNamed:@"Q_ACellList" owner:self options:nil];
        }
        cell = (UITableViewCell*)[nib objectAtIndex:0];
    }
    NSDictionary *dict = [listLastestAnswers objectAtIndex:indexPath.row];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return cell;
    }
    @try {
        //Background
        UIView *backgroundView = [cell viewWithTag:100];
        backgroundView.layer.cornerRadius = 3.0f;
        
        //    User
//        CredentialInfo *author = [[CredentialInfo alloc]initWithDictionary:[dict objectForKey:@"author"]];
        UILabel *userName = (UILabel*)[cell viewWithTag:1];
        userName.text = @"Views";
        userName.frame = CGRectMake(0, 35, 80, 21);
        UIImageView *avatar = (UIImageView*)[cell viewWithTag:2];
//        [avatar setImageWithURL:[NSURL URLWithString:author.avatarUrl] placeholderImage:[UIImage imageNamed:@"user_default_thumb.png" ]];
        avatar.hidden = YES;
        
        UILabel *lbTotalView = (UILabel*)[cell viewWithTag:9];
        lbTotalView.hidden = NO;
        lbTotalView.text = @"12345";
        
        UILabel *created = (UILabel*)[cell viewWithTag:4];
        created.text =  [NSData stringDecodeFromBase64String: [dict objectForKey:@"created_on_lapseTime"]];
        
        UILabel *lbQuestion = (UILabel*)[cell viewWithTag:5];
        NSString *question = @"Q: ";
        question = [question stringByAppendingString:[NSData stringDecodeFromBase64String: [dict objectForKey:@"content"]]];
        lbQuestion.text = question;
        
        CGRect frame;
        float y = 20;
        CGSize constraint = CGSizeMake(220, 20000.0f);
        CGSize size = [question sizeWithFont:lbQuestion.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        frame = lbQuestion.frame;
        frame.size = size;
        frame.origin.y = y;
        lbQuestion.frame = frame;
        y += frame.size.height + CELL_CONTENT_MARGIN_TOP;
        UILabel *answerBy_catelogy = (UILabel*)[cell viewWithTag:6];
        NSString *answerBy = [dict objectForKey:@"created"];
        NSString *replies = [dict objectForKey:@"total_answer"];
        NSString *cat_name = [NSData stringDecodeFromBase64String:[dict objectForKey:@"cat_name"]];
        answerBy_catelogy.text = [NSString stringWithFormat:@"Answered by on %@ | %@ Replies \nCategogy: %@", answerBy, replies, cat_name];
        
        size = [answerBy_catelogy.text sizeWithFont:answerBy_catelogy.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        frame = answerBy_catelogy.frame;
        frame.size = size;
        frame.origin.y = y;
        answerBy_catelogy.frame = frame;
        y += frame.size.height + CELL_CONTENT_MARGIN_TOP;
        
        UILabel *lbAnswer = (UILabel*)[cell viewWithTag:7];
        lbAnswer.hidden = YES;
//        
//        NSDictionary *dict_Answer = [dict objectForKey:@"answer"];
//        NSString *answer = @"A: ";
//        answer = [answer stringByAppendingString: [NSData stringDecodeFromBase64String:[dict_Answer objectForKey:@"content"]]];
//        lbAnswer.text = answer;
//        
//        size = [lbAnswer.text sizeWithFont:lbAnswer.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//        frame = lbAnswer.frame;
//        frame.size = size;
//        frame.origin.y = y;
//        lbAnswer.frame = frame;
//        y += frame.size.height + CELL_CONTENT_MARGIN_TOP;
        
        //Claps_commnets
        UIView *aView = [cell viewWithTag:8];
        //        frame = aView.frame;
        //        frame.origin.y = y;
        //        aView.frame = frame;
        [self setClapCommentForCell:[aView viewWithTag:1] withDict:dict];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    @catch (NSException *exception) {
        return cell;
    }
    
    return cell;
}


- (void) setClapCommentForCell:(UIView*)view withDict:(NSDictionary*)dict
{
    UIButton *clapBtn = (UIButton*)[view viewWithTag:8];
    UIButton *_dotBtn = (UIButton*)[view viewWithTag:2];
    UIButton *commentBtn = (UIButton*)[view viewWithTag:3];
    UIImageView *_clapIcon = (UIImageView*)[view viewWithTag:4];
    UILabel *numClap = (UILabel*)[view viewWithTag:5];
    UIImageView *_commentIcon = (UIImageView*)[view viewWithTag:6];
    UILabel *_numComment = (UILabel*)[view viewWithTag:7];
    
    NSInteger totalClap = 0, totalComment = 0;
    BOOL isClap = NO;
    NSString *value = @"";
    //clap_info
    NSDictionary *clap_info = [dict objectForKey:@"clap_info"];
    isClap = [[clap_info objectForKey:@"is_clap"]boolValue];
    //total_claps
    totalClap = [[clap_info objectForKey:@"total_claps"]integerValue];
    //total_comments
    value = [dict objectForKey:@"total_answer"];
    totalComment = [value integerValue];
    //total_views
    //    index = [cellData.paraNames indexOfObject:@"total_views"];
    //    value = [cellData.paraValues objectAtIndex:index];
    //    totalView = [value integerValue];
    
    numClap.text = [NSString stringWithFormat:@"%d", totalClap];
    NSString *clapBtTitle = isClap ? @"Unclap" : @"Clap";
    [clapBtn setTitle:clapBtTitle forState:UIControlStateNormal];
    [clapBtn setTitle:clapBtTitle forState:UIControlStateHighlighted];
    _numComment.text = [NSString stringWithFormat:@"%d", totalComment];
    
    //set action
    [clapBtn addTarget:self action:@selector(insertClap:) forControlEvents:UIControlEventTouchUpInside];
    [commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //Update location
    float y = 3;
    [clapBtn sizeToFit];
    [commentBtn sizeToFit];
    [_dotBtn sizeToFit];
    CGRect frame = clapBtn.frame;
    frame.origin.x = CELL_CONTENT_MARGIN_LEFT;
    frame.origin.y = y;
    clapBtn.frame = frame;
    
    frame = _dotBtn.frame;
    frame.origin.x = clapBtn.frame.origin.x + clapBtn.frame.size.width + 3;
    frame.origin.y = -y;
    _dotBtn.frame = frame;
    
    frame = commentBtn.frame;
    frame.origin.x = _dotBtn.frame.origin.x + _dotBtn.frame.size.width + 3;
    frame.origin.y = y;
    commentBtn.frame = frame;
    
    float width = view.frame.size.width - CELL_CONTENT_MARGIN_RIGHT;
    if (totalComment) {
        [_numComment sizeToFit];
        width -= _numComment.frame.size.width;
        frame = _numComment.frame;
        //width -= frame.size.width;
        frame.origin.x = width;
        frame.origin.y = y;
        _numComment.frame = frame;
        
        //[_commentIcon sizeToFit];
        width -= (_commentIcon.frame.size.width + 3);
        frame =_commentIcon.frame;
        frame.origin.x = width;
        frame.origin.y = y;
        _commentIcon.frame = frame;
        
        _commentIcon.hidden = NO;
        _numComment.hidden = NO;
        width -= 5;
    }else{
        _numComment.hidden = YES;
        _commentIcon.hidden = YES;
    }
    
    if (totalClap) {
        numClap.hidden = NO;
        _clapIcon.hidden = NO;
        
        [numClap sizeToFit];
        width -= numClap.frame.size.width;
        frame = numClap.frame;
        //width -= frame.size.width;
        frame.origin.x = width;
        frame.origin.y = y;
        numClap.frame = frame;
        
        //[_clapIcon sizeToFit];
        width -= (_clapIcon.frame.size.width + 3);
        frame =_clapIcon.frame;
        frame.origin.x = width;
        frame.origin.y = y;
        _clapIcon.frame = frame;
    }else
    {
        numClap.hidden = YES;
        _clapIcon.hidden = YES;
    }
    
}

- (void) insertClap: (id) sender
{
    // hdbClap($user_id, $hdb_id)
    UIView *view = (UIView*)sender;
    UITableViewCell *cell;
    while (view) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell*)view;
            break;
        }
        view = view.superview;
    }
    if (!cell) {
        return;
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell*) view];
    if (! indexPath) {
        return;
    }
//    QAClap($user_id, $type, $id)
    id data;
    NSString *functionName;
    NSString *type = @"hdb";
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"QAClap";
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        type = @"condos";
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        type = @"landed";
    }
    
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        type = @"room";
    }
    
    if (listLastestAnswers.count <= indexPath.row) {
        return;
    }
    NSDictionary *dict = [listLastestAnswers objectAtIndex:indexPath.row];
    
    paraNames = [NSArray arrayWithObjects:@"user_id", @"type", @"id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], type, [dict objectForKey:@"id"], nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];
    
    @try {
        NSInteger isClap = [[data objectForKey:@"clap"] integerValue];
        NSInteger totalClap = [[data objectForKey:@"total_clap"] integerValue];
        //Update clap
        NSDictionary *clap_info = [dict objectForKey:@"clap_info"];
        [clap_info setValue:[NSString stringWithFormat:@"%d", totalClap] forKey:@"total_claps"];
        [clap_info setValue:[NSString stringWithFormat:@"%d", isClap] forKey:@"is_clap"];
        [dict setValue:clap_info forKey:@"clap_info"];
        [listLastestAnswers replaceObjectAtIndex:indexPath.row withObject:dict];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

- (void) commentBtnClicked:(id)sender
{
    UIView *view = (UIView*)sender;
    UITableViewCell *cell;
    while (view) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell*)view;
            break;
        }
        view = view.superview;
    }
    if (!cell) {
        return;
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell*) view];
    if (! indexPath) {
        return;
    }
    //NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"cellData"];
    
//    [self.navigationController pushViewController:detailViewCtr animated:YES];
}

#pragma mark PullTableView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_pullTableViewCtrl scrollViewWillBeginDragging:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [_pullTableViewCtrl scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isLoadData) {
        return;
    }
    
    [self.pullTableViewCtrl scrollViewDidScroll:scrollView];
	if (([scrollView contentOffset].y + scrollView.frame.size.height) + self.tableView.tableFooterView.frame.size.height >= [scrollView contentSize].height - cCellHeight - 100) {
        NSLog(@"scrolled to bottom");
        
        if (! isLoadData) {
            if (! footerLoading.superview) {
                [self.tableView.tableFooterView addSubview:footerLoading];
            }
            [footerLoading showWhileExecuting:@selector(loadMoreData) onTarget:self withObject:nil animated:YES];
        }
        return;
	}
	if ([scrollView contentOffset].y == scrollView.frame.origin.y) {
        NSLog(@"scrolled to top ");
        
	}
    
    
}
- (void) pullToUpdate
{
    if (!loadingHideView) {
        loadingHideView = [[MBProgressHUD alloc]init];
        loadingHideView.hasBackground = NO;
        loadingHideView.mode = MBProgressHUDModeIndeterminate;
    }
    
    isLoadData = YES;
    [loadingHideView showWhileExecuting:@selector(addNewData) onTarget:self withObject:nil animated:YES];
}

#pragma mark - Sycn Server


- (void) getPopularQuestion
{
//    getPopularQuestion($user_id, $type = "hdb", $start = 0, $limit = 0, $max_id, $base64_image = false) 
    
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    NSString *type = @"hdb";
    NSString *start = @"0";
    NSString *maxID =@"0";
    functionName = @"getPopularQuestion";
    start = [[NSUserDefaults standardUserDefaults] objectForKey:@"start_getLatestAnswert"];
    maxID =[[NSUserDefaults standardUserDefaults] objectForKey:@"max_id_getLatestAnswer"];
    paraNames = [NSArray arrayWithObjects:@"user_id", @"type", @"start", @"limit", @"max_id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], type, start, @"5", maxID, nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    if (data.count) {
        NSString *scroll = [[NSUserDefaults standardUserDefaults] objectForKey:@"scroll"];
        if ([scroll isEqualToString:@"down"]) {
            [listLastestAnswers addObjectsFromArray:data];
        }else
        {
//            NSIndexSet *indexSets = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, data.count)];
//            [listLastestAnswers insertObjects:data atIndexes:indexSets];
            listLastestAnswers = [[NSMutableArray alloc]initWithArray:data];
        }
        NSDictionary *dict = [data objectAtIndex:0];
        maxID = [dict objectForKey:@"max_id"];
        [[NSUserDefaults standardUserDefaults] setValue:maxID forKey:@"max_id_getLatestAnswer"];
    }
    
    isLoadData = NO;
    [_tableView reloadData];
}
- (void) getLatestAnswer
{
    //    getLatestAnswer($user_id, $type = "hdb", $start = 0, $limit = 0, $max_id = 0, $base64_image = false)
    
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    NSString *type = @"hdb";
    NSString *start = @"0";
    NSString *maxID =@"0";
    functionName = @"getLatestAnswer";
    start = [[NSUserDefaults standardUserDefaults] objectForKey:@"start_getLatestAnswert"];
    maxID =[[NSUserDefaults standardUserDefaults] objectForKey:@"max_id_getLatestAnswer"];
    paraNames = [NSArray arrayWithObjects:@"user_id", @"type", @"start", @"limit", @"max_id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], type, start, @"5", maxID, nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    if (data.count) {
        NSString *scroll = [[NSUserDefaults standardUserDefaults] objectForKey:@"scroll"];
        if ([scroll isEqualToString:@"down"]) {
            [listLastestAnswers addObjectsFromArray:data];
        }else
        {
            //            NSIndexSet *indexSets = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, data.count)];
            //            [listLastestAnswers insertObjects:data atIndexes:indexSets];
            listLastestAnswers = [[NSMutableArray alloc]initWithArray:data];
        }
        NSDictionary *dict = [data objectAtIndex:0];
        maxID = [dict objectForKey:@"max_id"];
        [[NSUserDefaults standardUserDefaults] setValue:maxID forKey:@"max_id_getLatestAnswer"];
    }
    
    isLoadData = NO;
    [_tableView reloadData];
}
- (void) addNewData
{
    isLoadData = YES;
    NSUserDefaults *database = [NSUserDefaults standardUserDefaults];
    NSString *start = [NSString stringWithFormat:@"%d", 0];
    [database setValue:start forKey:@"start_getLatestAnswert"];
    [database setValue:@"up" forKey:@"scroll"];
    [self getLatestAnswer];
//    [self.tableView reloadData];
    [self.pullTableViewCtrl performSelector:@selector(stopLoading)];
}


- (void) loadMoreData
{
    isLoadData = YES;
    NSUserDefaults *database = [NSUserDefaults standardUserDefaults];
    NSString *start = [NSString stringWithFormat:@"%d", listLastestAnswers.count];
    [database setValue:start forKey:@"start_getLatestAnswert"];
    [database setValue:@"down" forKey:@"scroll"];
    [self getLatestAnswer];
//    [self.tableView reloadData];
}

@end
