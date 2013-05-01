//
//  InsertURLViewController.m
//  Stroff
//
//  Created by Ray on 4/18/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "InsertURLViewController.h"
#import "UIPlaceHolderTextView.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "SupportFunction.h"

@interface InsertURLViewController ()

@end

@implementation InsertURLViewController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _listURLs = [[NSMutableArray alloc] init];
        _listCell = [[NSMutableArray alloc] init];
        _keyForTitle = @"Insert URLs";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _phTextbox.layer.cornerRadius = 5.0;
    _phTextbox.layer.borderWidth = 0.25;
    _phTextbox.placeholder = @"Add new URL here";
    _btnSend.layer.cornerRadius = 5.0;
    _btnSend.layer.borderWidth = 0.20;
    _btnSend.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    
    //TapGesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_tableView addGestureRecognizer:tap];
    [_tableView registerNib:[UINib nibWithNibName:@"CellHDBPostControllerURLWithLink" bundle:nil] forCellReuseIdentifier:@"CellHDBPostControllerURLWithLink"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellHDBPostControllerURLWithLink"];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_btnTitle setTitle:_keyForTitle forState:UIControlStateNormal];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_listCell.count != _listCell.count) {
        [_listCell removeAllObjects];
        for (int i = 0; i < _listURLs.count; i++) {
            [_listCell addObject:[NSNull null]];
        }
    }
}
- (void) viewDidDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(InsertURLsDidDisappear)]) {
        [self.delegate InsertURLsDidDisappear];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([text isEqualToString:@""]) {
        _btnSend.enabled = NO;
        _btnSend.titleLabel.textColor = [UIColor lightGrayColor];
    }else {
        _btnSend.enabled = YES;
        _btnSend.titleLabel.textColor = [UIColor blueColor];
    }

}


#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_listURLs.count) {
        if (section == 0) {
            return @"All Links";
        }
        if (section == 01) {
            return @"Preview";
        }
    }
    return nil;
}
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return @"All Links";
//    }
//    return nil;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + _listURLs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _listURLs.count;
            break;
            
        default:
            return 2;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        static NSString *CellIdentifierURL = @"CellHDBPostControllerURL";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierURL];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierURL];
            [cell.textLabel setNumberOfLines:2];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eraseIcon.png"] highlightedImage:[UIImage imageNamed:@"eraseIcon.png"]];
            [imgView setFrame:CGRectMake(0, 0, 30, 30)];
            imgView.tag = indexPath.row;
            imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
            gesture.numberOfTapsRequired = 1;
            [imgView addGestureRecognizer:gesture];
            [cell bringSubviewToFront:imgView];
            [cell setAccessoryView:imgView];
        }
        [cell.textLabel setText:[_listURLs objectAtIndex:indexPath.row]];
        
        return cell;
    }
    if (indexPath.section > 0 && indexPath.row == 0) {
        static NSString *CellIdentifierURL = @"CellHDBPostControllerURL";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierURL];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierURL];
            [cell.textLabel setNumberOfLines:2];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME_BOLD size:FONT_SIZE]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eraseIcon.png"] highlightedImage:[UIImage imageNamed:@"eraseIcon.png"]];
            [imgView setFrame:CGRectMake(0, 0, 30, 30)];
            imgView.tag = indexPath.row;
            imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryClicked:)];;
            gesture.numberOfTapsRequired = 1;
            [imgView addGestureRecognizer:gesture];
            [cell bringSubviewToFront:imgView];
            [cell setAccessoryView:imgView];
        }
        [cell.textLabel setText:[_listURLs objectAtIndex:indexPath.section - 1]];
        
        return cell;
    }
    if (indexPath.section > 0 && indexPath.row > 0) {
        static NSString *CellIdentifierURL2 = @"CellHDBPostControllerURLWithLink";
        cell = [_listCell objectAtIndex:indexPath.section - 1];
        if (!cell || [cell isEqual:[NSNull null]]) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifierURL2 owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            topLevelObjects = nil;
            [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
            cell.backgroundView = [[UIView alloc] init];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        UIWebView *webView = (UIWebView*)[cell viewWithTag:1];
        webView.delegate = self;
        if (webView == nil) {
            webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 300, 225)];
            webView.tag = 1;
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [activityView setBackgroundColor:[UIColor clearColor]];
            [activityView setColor:[UIColor darkGrayColor]];
            [activityView setFrame:webView.frame];
            activityView.tag = 2;
            [cell addSubview:activityView];
            
            [cell addSubview:webView];
        }
        webView.delegate = self;
        NSString *urlStr = [webView.request.URL absoluteString];
        if (urlStr == nil) {
            NSURL *url = [NSURL URLWithString:[_listURLs objectAtIndex:indexPath.section - 1]];
            BOOL isYoutube = [SupportFunction isYoutubeVideoLink:url];
            if (isYoutube) {
                NSString *htmlStr = [self getHTMLFromYoutube:url];
                [webView loadHTMLString:htmlStr baseURL:nil];
                [webView setScalesPageToFit:NO];
                webView.userInteractionEnabled = NO;
            }else{
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [webView loadRequest:request];
            }
        }
        [_listCell replaceObjectAtIndex:indexPath.section - 1 withObject:cell];
        return cell;
    }
    // Configure the cell...
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
- (void) accessoryClicked:(UITapGestureRecognizer*) tapGesture_
{
    NSIndexPath *indexPath;
    UIView *view = tapGesture_.view;
    UITableViewCell *cell = (UITableViewCell*) view.superview;
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:cell];
    }
    
    if (indexPath.section == 0) {
        [_listURLs removeObjectAtIndex:indexPath.row];
        [_listCell removeObjectAtIndex:indexPath.row];
    }
    if (indexPath.section > 0) {
        [_listURLs removeObjectAtIndex:indexPath.section - 1];
        [_listCell removeObjectAtIndex:indexPath.section - 1];
    }
    [_tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return cCellHeight;
    }
    if (indexPath.section > 0 && indexPath.row == 0 ) {
        return cCellHeight;
    }
    if (indexPath.section > 0 && indexPath.row > 0) {
        return 225;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - webviewDelegate

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView*) [[webView superview] viewWithTag:2];
    activityView.hidden = YES;
}
#pragma mark -


- (void)viewDidUnload {
    [self setBtnTitle:nil];
    [self setBtnSend:nil];
    [self setPhTextbox:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}
- (void) tapAction
{
    [_phTextbox resignFirstResponder];
}

- (IBAction)btnSendClicked:(id)sender {
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingAllTypes error:nil];
    NSArray *matches = [detect matchesInString:_phTextbox.text options:0 range:NSMakeRange(0, [_phTextbox.text length])];
    for (NSTextCheckingResult *match in matches) {
        //NSRange matchRange = [match range];
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            NSLog(@"%@", [url absoluteString]);
            [_listURLs addObject:[url absoluteString]];
            [_listCell addObject:[NSNull null]];
            [_phTextbox setText:@""];
            [_phTextbox resignFirstResponder];
        }
    }
    [_tableView reloadData];

}

-(NSString*) getHTMLFromYoutube:(NSURL*)url
{
    NSString *videoID = [SupportFunction getYoutubeIDFromUrl:[url absoluteString]];
    float w = 280;
    float h = 205;
    NSString *embed = [NSString stringWithFormat:@"<html><iframe height=\"%fpx\" width=\"%fpx\" src=\"http://www.youtube.com/embed/%@\"?autoplay=1?enablejsapi=1></iframe></html> ", h, w, videoID];
    return embed;
}
@end
