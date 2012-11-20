//
//  MessageViewController.m
//  Postadvert
//
//  Created by Mtk Ray on 6/28/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageCellContent.h"
#import "Constants.h"
#import "UIMessageCell.h"
#import "UserPAInfo.h"
#import "PostadvertControllerV2.h"
#import "UIImageView+URL.h"

@interface MessageViewController ()
- (void) loadlistMessageCellContent;
@end

@implementation MessageViewController
@synthesize delegate = _delegate;
//@synthesize listMessageCellContent = _listMessageCellContent;
//@synthesize filteredListContent =filteredListContent;
//@synthesize navigationController = _navigationController;
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
    //[self.view setAutoresizesSubviews:YES];
    //self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // Do any additional setup after loading the view from its nib.
    self.tableView.tableFooterView = [[UIView alloc]init];
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.userInteractionEnabled = NO;
    [self.view addSubview:hud];
    [hud showWhileExecuting:@selector(loadlistMessageCellContent) onTarget:self withObject:nil animated:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    MBProgressHUD *thread = [[MBProgressHUD alloc]init];
    [thread showWhileExecuting:@selector(changeIcon) onTarget:self withObject:nil animated:NO];
    [self.tableView setContentOffset:CGPointMake(0, 44) animated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - tableViewDataSource
-(NSInteger)tableView:(UITableView *)ctableView numberOfRowsInSection:(NSInteger)section
{
    if (ctableView == self.searchDisplayController.searchResultsTableView)
    {
        return [filteredListContent count];
    }
    else
    {
        return [listMessageCellContent count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)ctableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"UIMessageCell";        
    // Try to retrieve from the table view a now-unused cell with the given identifier.
    UIMessageCell *cell = [ctableView dequeueReusableCellWithIdentifier:MyIdentifier];        
    // If no cell is available, create a new one using the given identifier.
    if (cell == nil) {
        cell = [[UIMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    MessageCellContent *cellCentent;
    if (ctableView == self.searchDisplayController.searchResultsTableView)
	{
        cellCentent = ((MessageCellContent*)[filteredListContent objectAtIndex:indexPath.row]);
    }
	else
	{
        cellCentent = ((MessageCellContent*)[listMessageCellContent objectAtIndex:indexPath.row]);
    }


    if (cellCentent.is_read) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:cellCentent.messageThumbURL] placeholderImage:[UIImage imageNamed:@"read_message.png"]];
        cell.iconSendView.hidden = YES;
            cell.backgroundColor = [UIColor clearColor];
        //cell.message.textColor = [UIColor lightGrayColor];
    }else
    {
        [cell.imageView setImageWithURL:[NSURL URLWithString:cellCentent.messageThumbURL] placeholderImage:[UIImage imageNamed:@"unread_message.png"]];
        if (!cell.iconSendView.image) {
            cell.iconSendView.image = [UIImage imageNamed:@"unread_icon.png"];
        }
        
        cell.iconSendView.hidden = NO;
        //cell.message.textColor = [UIColor darkGrayColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:225/255.0 green:245/255.0 blue:245/255.0 alpha:0.5];
        
    }
    
    cell.message.text = cellCentent.text;
    cell.userPostName.text = cellCentent.userPostName;
    cell.postTime.text = cellCentent.created;

    cellCentent = nil;

    return cell;   
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma mark - tableViewDelegate
- (void)tableView:(UITableView *)ctableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCellContent *cellContent = nil;
    if (ctableView == self.searchDisplayController.searchResultsTableView)
    {
        cellContent = [filteredListContent objectAtIndex:indexPath.row];
        [self.searchDisplayController.searchBar resignFirstResponder];
    }
    else
    {
        cellContent = [listMessageCellContent objectAtIndex:indexPath.row];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObject:cellContent forKey:@"MessageCellContent"];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"DetailMessageListenner" object:nil userInfo:dict];
    if (self.delegate) {
        [self.delegate messageViewControllerDidSelectedRowWithInfo:dict];
    }
    [ctableView deselectRowAtIndexPath:indexPath animated:YES];
    cellContent = nil;
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)_hud {
	// Remove HUD from screen when the HUD was hidded
	[_hud removeFromSuperview];
    _hud = nil;
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
   //[self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    //navigationController.navigationBarHidden = YES;
    if (self.delegate) {
        [self.delegate searchDisplayControllerDidEnterSearch];
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    
}
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if (self.delegate) {
        [self.delegate  searchDisplayControllerDidGoAwaySearch];
    }
}



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //No sort this time
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    [filteredListContent setArray:[filteredListContent sortedArrayUsingComparator:^(id firstObject, id secondObject)
    {
        if (searchOption == 1) {
            return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch | NSForcedOrderingSearch];
        }
        if (searchOption == 2) {
            NSComparisonResult result= [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch | NSForcedOrderingSearch];
            if (result ==  NSOrderedAscending) {
                return result;
                //return NSOrderedDescending;
                
            } else {
                
                if (result == NSOrderedAscending) {
                   // return NSOrderedAscending;
                    return result;
                }
            }
        }
        return [@"abc" compare:@"abc"];
    }]] ;
    return YES;
}

#pragma mark - implement

- (void) loadlistMessageCellContent
{
    @try {
        if(listMessageCellContent == nil)
        listMessageCellContent = [[NSMutableArray alloc] init];
        [listMessageCellContent removeAllObjects];
        
        id data;
        NSString *functionName;
        NSArray *paraNames;
        NSArray *paraValues;
        functionName = @"getAllMessages";
        paraNames = [NSArray arrayWithObjects:@"user_id", @"msg_id", @"limit", nil];
        paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], @"0", @"0", nil];
        
        data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
        
        for (NSDictionary *dict  in data) {
            MessageCellContent *message = [[MessageCellContent alloc]initWithDictionary:dict withOption:1];
            [listMessageCellContent addObject:message];
        }
        
        [self.tableView reloadData];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }

}

-(void) changeIcon
{
    return;
    NSInteger count = 0;
    UIImage *img = [UIImage imageNamed:@"unread_icon.png"];
    while (self) {
        if (count % 2) {
            img = [UIImage imageNamed:@"unread_icon.png"];
        }else
            img = [UIImage imageNamed:@"unread_message.png"];
        for (MessageCellContent *message in listMessageCellContent) {
            if (!message.is_read) {
                //change
                int index = [listMessageCellContent indexOfObject:message];
                NSIndexPath * indecPath =  [NSIndexPath indexPathForRow:index inSection:0];
                NSArray *data = [NSArray arrayWithObjects:indecPath, img, nil];
                [self performSelectorOnMainThread:@selector(updateMessageWithIndexPath:) withObject:data waitUntilDone:NO];
                
            }
        }
        
        sleep(3);
        count ++;
        if (count > 100000) {
            count = 0;
        }
NSLog(@"%d", count);
    }
}

- (void) updateMessageWithIndexPath:(NSArray*)data
{
    return;
    @try {
        NSIndexPath *indexPath = [data objectAtIndex:0];
        UIMessageCell *cell = (UIMessageCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.iconSendView.image = [data objectAtIndex:1];
        cell.backgroundColor = [UIColor redColor];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{
    if (filteredListContent == nil) {
        filteredListContent = [[NSMutableArray alloc] init];
    }
	[filteredListContent removeAllObjects]; // First clear the filtered array.
	for (int i = 0; i< listMessageCellContent.count; i++)
	{
		/*
         //EX: "vendor" vs "vendor 123" => OK , but "123" vs  "vendor 123" => Fail
         NSComparisonResult result = [vendor compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
         if (result == NSOrderedSame)
         {
         [self.filteredListContent addObject:vendor];
         }
         */
        //EX: "vendor" vs "vendor 123" => OK , "123" vs  "vendor 123" => OK
        MessageCellContent *content = [listMessageCellContent objectAtIndex:i];
        NSLog(@"Search text %@, text: %@",content.text  ,searchText);
        
        if([content.text rangeOfString:searchText options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound)
        {
            [filteredListContent addObject:content];
        }
		
	}
    if (filteredListContent.count == 0) {
        //Search message sender
        for (int i = 0; i< listMessageCellContent.count; i++)
        {
            MessageCellContent *content = [listMessageCellContent objectAtIndex:i];
            
            NSArray *arrayName = [content.userPostName componentsSeparatedByString:@" "];
            NSArray *arraySearchText = [searchText componentsSeparatedByString:@" "];
            //maxindex = smallest count
            NSInteger maxIndex = (arrayName.count > arraySearchText.count)? arraySearchText.count : arrayName.count;
            maxIndex = maxIndex - 1;
            NSInteger numLoop = arrayName.count - arraySearchText.count;
            if (numLoop > maxIndex) {
                numLoop = maxIndex;
            }
    
            for (int i = 0; i <= numLoop; i++) {
                int indexOftextName = 0;
                int j = i;
                NSString *textName = [arrayName objectAtIndex:indexOftextName];
                NSString *textSearch = [arraySearchText objectAtIndex:i];
                
                while ([textName compare:textSearch options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [textName length])] == NSOrderedSame)
                {
                    NSLog(@"Search text %@, text: %@",textSearch, textName);
                    if (indexOftextName == maxIndex) {
                        //All is same
                        [filteredListContent addObject:content];
                        break;
                    }
                    j++;
                    indexOftextName++;
                    textName = [arrayName objectAtIndex:indexOftextName];
                    textSearch = [arraySearchText objectAtIndex:j];
                }
            }
        }
    }
    
    NSLog(@"Search Count %d", filteredListContent.count);
    
}
@end
