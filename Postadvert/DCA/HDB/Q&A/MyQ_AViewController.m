//
//  MyQ_AViewController.h
//  Stroff
//
//  Created by Ray on 7/11/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "MyQ_AViewController.h"
#import "Constants.h"
#import "PostadvertControllerV2.h"
#import "MBProgressHUD.h"
#import "UserPAInfo.h"
#import "CredentialInfo.h"
#import "UIImageView+URL.h"
#import "NSData+Base64.h"
#import "UILable_Margin.h"
#import <QuartzCore/QuartzCore.h>
#import "DCAOptionsViewController.h"

#import "UIPlaceHolderTextView.h"
@interface MyQ_AViewController ()

@end


@implementation MyQ_AViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _type = myQ_A;
        listValues = [[NSMutableArray alloc]init];
        
    }
    return self;
}
- (id) initForBrowseWithData:(id)data
{
    self = [super init];
    if (self) {
        _type = browseByCategory;
        listValues = [[NSMutableArray alloc]initWithArray:data];
        
    }
    return self;
}

- (void)viewDidLoad
{
    NSRange rang = [self.itemBarName rangeOfString:@"Ask Qn"];
    if (rang.length) {
        _type = askQ_A;
    }
    rang = [self.itemBarName rangeOfString:@"Browse Q&A"];
    if (rang.length) {
        _type = browse;
        dictBrowse = [[NSDictionary alloc]init];
    }

    if (_type == askQ_A) {
        listValues = [[NSMutableArray alloc]initWithObjects:@"", @"", @"", nil];
    }
    [super viewDidLoad];
    [_placeTextAskQn setPlaceholder:@"What would you like to ask ?"];
    listMyQ_A = [[NSMutableArray alloc]init];
    UIImage *image = [UIImage imageNamed:@"titleHDB.png"];
    //image = [image resizedImage:self.lbTitle.frame.size interpolationQuality:0];
    [self.lbTitle setBackgroundColor:[UIColor colorWithPatternImage:image]];
    NSString *title = [self.itemName stringByReplacingOccurrencesOfString:@" Q&A" withString:@""];
    [self.lbTitle setText:title];
    _lbQ_A.insets = UIEdgeInsetsMake(0, 10, 0, 0);
    _lbQ_A.text = self.itemBarName;
    _lbQ_A.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"BG_My-Q&A.png"]];
//    [UIColor colorWithRed:57.0/255 green:60.0/255.0 blue:38.0/255 alpha:1];
    self.tableView.separatorColor = [UIColor colorWithRed:79.0/255 green:177.0/255 blue:190.0/255 alpha:1];
//    footerView
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
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeKeyboardGoAway:)];
//    [self.view addGestureRecognizer:tapGesture];
//    tapGesture = nil;
    
//    init for load new My Q_A
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"question_id"];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    mbpLoadQ_A = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:mbpLoadQ_A];
    if (_type == myQ_A) {
        [mbpLoadQ_A showWhileExecuting:@selector(getMyQ_A) onTarget:self withObject:nil animated:YES];
    }
    if (_type == browse && ! dictBrowse.allKeys.count) {
        [mbpLoadQ_A showWhileExecuting:@selector(getQABrowserValue) onTarget:self withObject:nil animated:YES];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLbTitle:nil];
    [self setLbQ_A:nil];
    [self setAskQnCell:nil];
    [self setPlaceTextAskQn:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_type == browse) {
        NSArray *headerTitles = [dictBrowse allKeys];
        if (headerTitles.count > section) {
            NSString *title = @"Browse Questions by ";
            title = [title stringByAppendingString:[[headerTitles objectAtIndex:section] capitalizedString]];
            return title;
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfseclection = 0;
    if (_type == myQ_A) {
        numberOfseclection = 1;
    }
    if (_type == askQ_A) {
        numberOfseclection = 2;
    }
    if (_type == browse) {
        numberOfseclection = dictBrowse.count;
    }
    if (_type == browseByCategory) {
        numberOfseclection = 1;
    }
    return numberOfseclection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection =0;
    if (_type == myQ_A) {
        numberOfRowsInSection = listMyQ_A.count;
    }
    if (_type == askQ_A) {
        if (section == 0) {
            numberOfRowsInSection = 3;
        }
        else
            numberOfRowsInSection = 1;

    }
    if (_type == browse) {
        NSString *headerTitle = [[dictBrowse allKeys] objectAtIndex:section];//section
        NSDictionary *aBrowse = [dictBrowse objectForKey:headerTitle];
        NSArray *arrayTypeValue = [aBrowse allKeys];
        NSString *value =@"";
        for (NSString *object in arrayTypeValue) {
            if ([object rangeOfString:@"array"].length) {
                value = object;
                break;
            }
        }
        NSArray *arrayValue = [aBrowse objectForKey:value];
        numberOfRowsInSection = arrayValue.count;
    }
    if (_type == browseByCategory) {
        numberOfRowsInSection = listValues.count;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_type == askQ_A) {
        return [self loadQ_AAskQCellForTableView:tableView AtIndexPath:indexPath];
    }
    if (_type == browse) {
        return [self loadQ_ABrowseCellForTableView:tableView AtIndexPath:indexPath];
    }
    if (_type == browseByCategory) {
        return [self loadQ_ABrowseByCellForTableView:tableView AtIndexPath:indexPath];
    }
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
    NSDictionary *dict = [listMyQ_A objectAtIndex:indexPath.row];
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


- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float heightForRow = 0;
    if (_type == askQ_A) {
        switch (indexPath.row) {
            case 0:
            case 1:
                heightForRow = cCellHeight;
                break;
            case 2:
                heightForRow = 125 + cCellHeight;
                break;
            default:
                break;
        }
        return heightForRow;
    }
    if (_type == browse) {
        return cCellHeight;
    }
    NSDictionary *dict = [listValues objectAtIndex:indexPath.row];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    float y = 20.0f;
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
    
    //Claps_commnets
    y += 26;
    if (y < 106) {
        y =106;
    }
    return y;
}
#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self makeKeyboardGoAway:nil];
    
    if (_type == askQ_A) {
        [self tableViewAskQn:tableView didSelectRowAtIndexPath:indexPath];
    }
    if (_type == browse) {
        [mbpLoadQ_A showWhileExecuting:@selector(tableViewBrowseDidSelectRowAtIndexPath:) onTarget:self withObject:indexPath animated:YES];
//        [self tableViewBrowse:tableView didSelectRowAtIndexPath:indexPath];
    }
}
#pragma mark DCAPOptionViewController Delegate
- (void) didSelectRowOfDCAOptionViewController:(DCAOptionsViewController *)dcaViewCtr
{
    if (dcaViewCtr.sourceType == DCAOptionQAAskQn) {
        [listValues replaceObjectAtIndex:0 withObject:[dcaViewCtr.selectedValues objectAtIndex:0]];
    }
    if (dcaViewCtr.sourceType == DCAOptionsLocation) {
        [listValues replaceObjectAtIndex:1 withObject:[dcaViewCtr.selectedValues objectAtIndex:0]];
    }
    
    [dcaViewCtr.navigationController popViewControllerAnimated:YES];

    [self.tableView reloadData];
}

#pragma mark - implement
- (void) tableViewAskQn:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSRange rang = [cell.textLabel.text rangeOfString:@"Category"];
    if (rang.length) {
        if (!listCategoriesAskQ_A || listCategoriesAskQ_A.count < 1) {
            [self AskQnLoadCategory];
        }
        if (listCategoriesAskQ_A.count < 1) {
            return;
        }
        NSInteger selectedIndex = -1;
        NSString *Category = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
        NSMutableArray *listArray = [self simplDataFromArray:listCategoriesAskQ_A];
        if (![Category isEqualToString:@"Any"]) {
            selectedIndex = [listArray indexOfObject:Category];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:listArray DCAOptionType:DCAOptionQAAskQn selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
    rang = [cell.textLabel.text rangeOfString:@"Location"];
    if (rang.length) {
        
        if (!listLocationsAskQ_A) {
            [self AskQnLoadLocation];
        }
        if (listLocationsAskQ_A.count < 1) {
            return;
        }
        NSInteger selectedIndex = -1;
        NSString *Category = [(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath] detailTextLabel].text;
        NSMutableArray *listArray = [self simplDataFromArray:listLocationsAskQ_A];
        if (![Category isEqualToString:@"Any"]) {
            selectedIndex = [listArray indexOfObject:Category];
        }
        DCAOptionsViewController *dcaOptionViewCtr = [[DCAOptionsViewController alloc]initWithArray:listArray DCAOptionType:DCAOptionsLocation selectedIndex:selectedIndex];
        dcaOptionViewCtr.delegate = self;
        [self.navigationController pushViewController:dcaOptionViewCtr animated:YES];
        return;
    }
}
- (void) tableViewBrowseDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = @"";
    NSString *headerTitle = [[dictBrowse allKeys] objectAtIndex:indexPath.section];//section
    NSDictionary *aBrowse = [dictBrowse objectForKey:headerTitle];
    NSArray *arrayTypeValue = [aBrowse allKeys];
    NSString *value =@"";
    for (NSString *object in arrayTypeValue) {
        if ([object rangeOfString:@"value"].length) {
            value = object;
            break;
        }
    }
    NSArray *arrayValue = [aBrowse objectForKey:value];
    text = [arrayValue objectAtIndex:indexPath.row];
    NSRange rang = [headerTitle rangeOfString:@"category"];
    if (rang.length) {
        [self getCategoryQuestionsWithId:text];
    }
    rang = [headerTitle rangeOfString:@"location"];
    if (rang.length) {
        
    }
}


- (void) getCategoryQuestionsWithId:(NSString*)cate_id
{
    
    //getCategoryQuestions($user_id, $cate_id, $limit = 0, $question_id = 0, $base64_image = false)
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"getCategoryQuestions";
    paraNames = [NSArray arrayWithObjects:@"user_id",@"cate_id", @"limit",@"question_id", nil];
    paraValues = [NSArray arrayWithObjects:[[UserPAInfo sharedUserPAInfo] getRegistrationIDString],cate_id, @"10",@"0",nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    if (data.count) {
        
        [self performSelectorOnMainThread:@selector(showBrowseByCategoryWithData:) withObject:data waitUntilDone:NO];
    }
    
}

- (void) getLocationQuestionsWithId:(NSString*)location_id
{
    
    //getLocationQuestions($user_id, $location_id, $limit = 0, $question_id = 0, $base64_image = false) 
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    functionName = @"getLocationQuestions";
    paraNames = [NSArray arrayWithObjects:@"user_id",@"cate_id", @"limit",@"question_id", nil];
    paraValues = [NSArray arrayWithObjects:[[UserPAInfo sharedUserPAInfo] getRegistrationIDString],location_id, @"10",@"0",nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    if (data.count) {
        [self performSelectorOnMainThread:@selector(showBrowseByCategoryWithData:) withObject:data waitUntilDone:NO];
    }
    
}

- (void)showBrowseByCategoryWithData:(id)data
{
    browseView = [[MyQ_AViewController alloc]initForBrowseWithData:data];
    browseView.navigationController = self.navigationController;
    [_navigationController pushViewController:browseView animated:YES];
}
- (IBAction)makeKeyboardGoAway:(id)sender
{
    if ([_placeTextAskQn isFirstResponder]) {
            [_placeTextAskQn resignFirstResponder];
        [listValues replaceObjectAtIndex:2 withObject:_placeTextAskQn.text];
    }

}

- (NSMutableArray*) AskQnLoadCategory
{
    listCategoriesAskQ_A = [[NSMutableArray alloc]init];
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
//    getQACategories($dca_type, $from = "app")
    NSString *type = @"hdb";
    functionName = @"getQACategories";
    paraNames = [NSArray arrayWithObjects:@"dca_type", nil];
    paraValues = [NSArray arrayWithObjects:type, nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    if (data.count) {
        listCategoriesAskQ_A = nil;
        listCategoriesAskQ_A = [[NSMutableArray alloc]initWithArray:data];
    }

    return listCategoriesAskQ_A;
}
- (NSMutableArray*) simplDataFromArray:(NSArray*)inputArray
{
    NSMutableArray *mutiArray = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in inputArray) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSString *value = [dict objectForKey:@"title"];
            if (!value) {
                value = @"";
            }
            value = [NSData stringDecodeFromBase64String:value];
            [mutiArray addObject:value];
        }
    }
    return mutiArray;
}
- (NSString*) getIDFromArray:(NSArray*)array WithValue:(NSString*)value
{
    NSString *strID = @"0";
    for (NSDictionary *dict in array) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSString *str = [dict objectForKey:@"title"];
            if (!str) {
                str = @"";
            }
            str = [NSData stringDecodeFromBase64String:str];
            if ([str isEqualToString:value]) {
                strID = [dict objectForKey:@"id"];
                break;
            }
        }
    }
    return strID;
}
- (NSMutableArray*) AskQnLoadLocation
{
    listLocationsAskQ_A = [[NSMutableArray alloc]init];
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    //    getQALocations($dca_type, $from = "app")
    NSString *type = @"hdb";
    functionName = @"getQALocations";
    paraNames = [NSArray arrayWithObjects:@"dca_type", nil];
    paraValues = [NSArray arrayWithObjects:type, nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    if (data.count) {
        listLocationsAskQ_A = nil;
        listLocationsAskQ_A = [[NSMutableArray alloc]initWithArray:data];
    }
    
    return listLocationsAskQ_A;
}

- (UITableViewCell*) loadQ_AAskQCellForTableView:(UITableView*)tableView AtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 1) {
//        return BtnSubmit
        static NSString *postQuestionBtn = @"CellPostQuestionBtn";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:postQuestionBtn];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:postQuestionBtn];
            UIView *backgroundView = [[UIView alloc]init];
            //[backgroundView setBackgroundColor:[UIColor colorWithRed:90.0/255 green:80.0/255 blue:65.5/255 alpha:1]];
            [cell setBackgroundView:backgroundView];
            
            UIButton *btnSubmit = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 300, cCellHeight)];
            btnSubmit.tag = 1;
            [btnSubmit setBackgroundImage:[UIImage imageNamed:@"btnHDBUnormal.png"] forState:UIControlStateNormal];
            [btnSubmit addTarget:self action:@selector(submitQuestion:) forControlEvents:UIControlEventTouchUpInside];
            [btnSubmit setTitle:@"Post Question" forState:UIControlStateNormal];
            [cell addSubview:btnSubmit];
        }
        return cell;
    }
    
    if (indexPath.row <= 1) {
        static NSString *CellIdentifier1 = @"CellStartUpJobsWithOption";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setNumberOfLines:2];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryView.png"] highlightedImage:[UIImage imageNamed:@"accessoryViewSelected.png"]];
            imgView.tag = indexPath.row;
            imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
            gesture.numberOfTapsRequired = 1;
            [imgView addGestureRecognizer:gesture];
            [cell bringSubviewToFront:imgView];
            [cell setAccessoryView:imgView];
        }
        NSString *text = @"";
        switch (indexPath.row) {
            case 0:
                text = @"Select Category *";
                break;
            case 1:
                text = @"Select Location";
                break;
            case 2:
                text = @"Enter Your Question *";
                break;
            default:
                text = @"";
                break;
        }
        
        cell.textLabel.text = text;
        
        NSString *textDetail = @"";
        NSRange rang = [text rangeOfString:@"Category"];
        if (rang.length) {
            textDetail = [[NSUserDefaults standardUserDefaults] objectForKey:@"Category"];
            if (!textDetail) {
                textDetail = @"";
            }
        }
        rang = [text rangeOfString:@"Location"];
        if (rang.length) {
            textDetail = [[NSUserDefaults standardUserDefaults] objectForKey:@"Location"];
            if (!textDetail) {
                textDetail = @"";
            }
        }
        textDetail = [listValues objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = textDetail;
        [cell.detailTextLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
        if ([cell.detailTextLabel.text isEqualToString:@"Any"] || [cell.detailTextLabel.text isEqualToString:@"Select One"] || [cell.detailTextLabel.text isEqualToString:@""]) {
            UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
            if (accessoryView) {
                accessoryView.image = [UIImage imageNamed:@"accessoryView.png"];
                accessoryView.highlightedImage = [UIImage imageNamed:@"accessoryView.png"];
                [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
            }
            //cell.detailTextLabel.text = @"Any";
        }
        else
        {
            UIImageView *accessoryView = (UIImageView*)[cell accessoryView];
            if (accessoryView) {
                accessoryView.image = [UIImage imageNamed:@"eraseIcon.png"];
                accessoryView.highlightedImage = [UIImage imageNamed:@"eraseIcon.png"];
                [accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
                [cell bringSubviewToFront:accessoryView];
            }
        }
        return cell;
    }
    
    if (indexPath.row > 1) {
        return _askQnCell;
    }
    return [[UITableViewCell alloc]init];
}
- (UITableViewCell*) loadQ_ABrowseCellForTableView:(UITableView*)tableView AtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellForBrowseQA = @"CellForBrowseQA";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellForBrowseQA];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellForBrowseQA];
        [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        [cell.detailTextLabel setNumberOfLines:2];
        [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryView.png"] highlightedImage:[UIImage imageNamed:@"accessoryViewSelected.png"]];
        imgView.tag = indexPath.row;
        imgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
        gesture.numberOfTapsRequired = 1;
        [imgView addGestureRecognizer:gesture];
        [cell bringSubviewToFront:imgView];
        [cell setAccessoryView:imgView];
    }
    NSString *text = @"";
    NSString *headerTitle = [[dictBrowse allKeys] objectAtIndex:indexPath.section];//section
    NSDictionary *aBrowse = [dictBrowse objectForKey:headerTitle];
    NSArray *arrayTypeValue = [aBrowse allKeys];
    NSString *value =@"";
    for (NSString *object in arrayTypeValue) {
        if ([object rangeOfString:@"array"].length) {
            value = object;
            break;
        }
    }
    NSArray *arrayValue = [aBrowse objectForKey:value];
    text = [arrayValue objectAtIndex:indexPath.row];
    text = [NSData stringDecodeFromBase64String:text];
    cell.textLabel.text = text;
    
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
    NSDictionary *dict = [listMyQ_A objectAtIndex:indexPath.row];
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

- (UITableViewCell*) loadQ_ABrowseByCellForTableView:(UITableView*)tableView AtIndexPath:(NSIndexPath*)indexPath
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
    NSDictionary *dict = [listValues objectAtIndex:indexPath.row];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return cell;
    }
    @try {
        //Background
        UIView *backgroundView = [cell viewWithTag:100];
        backgroundView.layer.cornerRadius = 3.0f;
        
        //    User
        CredentialInfo *author = [[CredentialInfo alloc]initWithDictionary:[dict objectForKey:@"author"]];
        UILabel *userName = (UILabel*)[cell viewWithTag:1];
        userName.text = author.usernamePU;
        userName.frame = CGRectMake(0, 70, 80, 21);
        UIImageView *avatar = (UIImageView*)[cell viewWithTag:2];
        [avatar setImageWithURL:[NSURL URLWithString:author.avatarUrl] placeholderImage:[UIImage imageNamed:@"user_default_thumb.png" ]];
        avatar.hidden = NO;
        
        UILabel *lbTotalView = (UILabel*)[cell viewWithTag:9];
        lbTotalView.hidden = YES;
        
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
    
    if (listMyQ_A.count <= indexPath.row) {
        return;
    }
    NSDictionary *dict = [listMyQ_A objectAtIndex:indexPath.row];
    
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
        [listMyQ_A replaceObjectAtIndex:indexPath.row withObject:dict];
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

- (void) submitQuestion:(id) sender
{
//    createQuestion($user_id, $cat_id, $location_id, $content, $base64_image = false)
    if ([listValues[0] isEqualToString:@""] || listValues[0] == nil) {
        [[PostadvertControllerV2 sharedPostadvertController]showAlertWithMessage:@"Please select Category" andTitle:@"Post Question"];
        return;
    }
    NSString *content = listValues[2];
    content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([content isEqualToString:@""] || content == nil) {
        [[PostadvertControllerV2 sharedPostadvertController]showAlertWithMessage:@"Please enter your Question" andTitle:@"Post Question"];
        return;
    }
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    NSString *cat_id;
    NSString *location_id;
    cat_id = [self getIDFromArray:listCategoriesAskQ_A WithValue:listValues[0]];
    location_id = [self getIDFromArray:listLocationsAskQ_A WithValue:listValues[1]];
    functionName = @"createQuestion";
    paraNames = [NSArray arrayWithObjects:@"user_id", @"cat_id", @"location_id", @"content", nil];
    paraValues = [NSArray arrayWithObjects:[[UserPAInfo sharedUserPAInfo]getRegistrationIDString], cat_id, location_id, listValues[2], nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];
    
    
}
- (void) tapAction
{
    [self.placeTextAskQn resignFirstResponder];
}
#pragma mark PullTableView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_type == askQ_A) {
        return;
    }
    [_pullTableViewCtrl scrollViewWillBeginDragging:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_type == askQ_A) {
        return;
    }
    [_pullTableViewCtrl scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_type == askQ_A) {
        return;
    }
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
    if (_type == askQ_A) {
        return;
    }
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
            [listMyQ_A addObjectsFromArray:data];
        }else
        {
//            NSIndexSet *indexSets = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, data.count)];
//            [listLastestAnswers insertObjects:data atIndexes:indexSets];
            listMyQ_A = [[NSMutableArray alloc]initWithArray:data];
        }
        NSDictionary *dict = [data objectAtIndex:0];
        maxID = [dict objectForKey:@"max_id"];
        [[NSUserDefaults standardUserDefaults] setValue:maxID forKey:@"max_id_getLatestAnswer"];
    }
    
    isLoadData = NO;
    [_tableView reloadData];
}
- (void) getMyQ_A
{
//   myQA($user_id, $type, $limit = 0, $question_id = 0, $base64_image = false) 
    
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    NSString *type = @"hdb";
    NSString *question_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"question_id"];
    functionName = @"myQA";
    if (! question_id) {
        question_id = @"0";
    }
    paraNames = [NSArray arrayWithObjects:@"user_id", @"type", @"limit", @"question_id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], type, @"5", question_id, nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    if (data.count) {
        if (listMyQ_A.count) {
            [listMyQ_A addObjectsFromArray:data];
        }else
        {
            listMyQ_A = [[NSMutableArray alloc]initWithArray:data];
        }
        NSDictionary *dict = [data lastObject];
        question_id = [dict objectForKey:@"id"];
        [[NSUserDefaults standardUserDefaults] setValue:question_id forKey:@"question_id"];
    }
    
    isLoadData = NO;
    [_tableView reloadData];
}
- (void) getQABrowserValue
{
//    getQABrowserValue($dca_type)
    
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    NSString *type = @"hdb";
    NSString *question_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"question_id"];
    functionName = @"getQABrowserValue";
    if (! question_id) {
        question_id = @"0";
    }
    paraNames = [NSArray arrayWithObjects:@"dca_type", nil];
    paraValues = [NSArray arrayWithObjects:type, nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    if ([data isKindOfClass:[NSDictionary class]]) {
        dictBrowse = nil;
        dictBrowse = [[NSDictionary alloc]initWithDictionary:data];
    }
    
    isLoadData = NO;
    [_tableView reloadData];
}
- (void) addNewData
{
    isLoadData = YES;
//    [listMyQ_A removeAllObjects];
    [self getMyQ_A];
//    [self.tableView reloadData];
    [self.pullTableViewCtrl performSelector:@selector(stopLoading)];
}


- (void) loadMoreData
{
    isLoadData = YES;
    [self getMyQ_A];
//    [self.tableView reloadData];
}

@end
