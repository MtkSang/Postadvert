//
//  HDBPostViewController.m
//  Stroff
//
//  Created by Ray on 3/26/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HDBPostViewController.h"

@interface HDBPostViewController ()

@end

@implementation HDBPostViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLbTitle:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return @"Sort";
    }
    if (section == 3) {
        return @"Filters";
    }
    if (section == 4) {
        return @"Keywords";
    }
    return nil;
}
@end
