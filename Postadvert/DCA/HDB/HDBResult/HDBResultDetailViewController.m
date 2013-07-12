//
//  HDBResultDetailViewController.m
//  Stroff
//
//  Created by Ray on 3/6/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "HDBResultDetailViewController.h"
#import "PostadvertControllerV2.h"
#import "NSData+Base64.h"
#import "UIImageView+URL.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "CommentsCellContent.h"
#import "UserPAInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "SupportFunction.h"
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "UploadImagesViewController.h"
#import "NWViewLocationController.h"
#import "LinkPreview.h"
#define linkHeight 72
@interface HDBResultDetailViewController ()

@end
enum viewModeForDCADetail {
    modePreview = 0,
    modeViewDetail = 1,
    modeSubmitAd = 2,
    modeSubmitAdWithImages = 3
    };

@implementation HDBResultDetailViewController

- (id)initWithHDBID:(NSInteger) hdbID_ userID:(NSInteger) userID_
{
    self = [super init];
    if (self) {
        _hdbID = hdbID_;
        _userID = userID_;
        self.viewMode = modeViewDetail;
    }
    return self;
}

- (id)initBySubmitParaNames:(NSArray*)paranames andParavalues:(NSArray*)paravalues withListImages:(NSArray*)listimages
{
    self = [super init];
    if (self) {
        self.viewMode = modeSubmitAd;
        _paraValues = [[NSArray alloc]initWithArray:paravalues];
        _paraNames = [[NSArray alloc]initWithArray:paranames];
        if (listimages.count) {
            _listImages = [[NSArray alloc]initWithArray:listimages];
        }
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
    // Do any additional setup after loading the view from its nib.
    _texbox.layer.cornerRadius = 5.0;
    _texbox.layer.borderWidth = 0.25;
    _texbox.placeholder = @"Write a comment";
    _btnSend.layer.cornerRadius = 5.0;
    _btnSend.layer.borderWidth = 0.20;
    _btnSend.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWilBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    //TapGesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_tableView addGestureRecognizer:tap];
    if (_viewMode == modePreview ) {
        [_texbox setUserInteractionEnabled:NO];
    }
    currentItem = [self.tabBar.items objectAtIndex:0];
    [self.tabBar setSelectedItem:currentItem];
    
    //
    if (! uploadImagesView) {
        uploadImagesView = [[UploadImagesViewController alloc]init];
        uploadImagesView.view.frame = CGRectMake(0, 0, self.view.frame.size.width, cCellHeight);
        uploadImagesView.view.hidden = YES;
        [self.view addSubview:uploadImagesView.view];
    }
    //mbpMap
    mbpMap = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:mbpMap];
    
    // Map
    mapView = [[MyMapViewController alloc]init];
    CGRect frame = _scrollView.frame;
    frame.origin.y = 0;
    //frame.size.height -= _tabBar.frame.size.height;
    [mapView.view setFrame:frame];
    mapView.delegate = self;
    
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBar setSelectedItem:currentItem];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (hud == nil) {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud showWhileExecuting:@selector(loadDataInBackground) onTarget:self withObject:nil animated:YES];
        if (self.showKeyboard) {
            [self.texbox becomeFirstResponder];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (cellData) {
        if ([self.itemName isEqualToString:@"HDB Search"]) {
            return 7;
            // 0-Detail Ad
            // 1-contact Ad Owner
            // 2-Videos
            // 3-Website
            // 4-Feature
            // 5-Hom Interior _ fixting
            // 6-Commments
        }
        if ([self.itemName isEqualToString:@"Condos Search"]) {
            return 8;
        }
        if ([self.itemName isEqualToString:@"Landed Property Search"]) {
            return 8;
        }
        if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
            return 9;
        }

    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        if (section == 0) {
            return 1;
        }
        if (section == 01) {
            return 2;
        }
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return videos.count;
                }
            }
            return 0;
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *websites = [cellData.paraValues objectAtIndex:index];
                if ([websites isKindOfClass:[NSMutableArray class]] && websites.count) {
                    return websites.count;
                }
            }
            return 0;
        }

        if (section == 4) {//spectail Feature
            return cellData.array_other_features.count;
        }
        if (section == 5) {//fixtures_fittings
            return cellData.array_fixtures_fittings.count;
        }
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        if (section == 0) {
            return 1;
        }
        if (section == 01) {
            return 2;
        }
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return videos.count;
                }
            }
            return 0;
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *websites = [cellData.paraValues objectAtIndex:index];
                if ([websites isKindOfClass:[NSMutableArray class]] && websites.count) {
                    return websites.count;
                }
            }
            return 0;
        }

        if (section == 4) {//spectail Feature
            return cellData.array_other_features.count;
        }
        if (section == 5) {
            return cellData.array_amenities.count;
        }
        if (section == 6) {//fixtures_fittings
            return cellData.array_fixtures_fittings.count;
        }

    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        if (section == 0) {
            return 1;
        }
        if (section == 01) {
            return 2;
        }
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return videos.count;
                }
            }
            return 0;
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *websites = [cellData.paraValues objectAtIndex:index];
                if ([websites isKindOfClass:[NSMutableArray class]] && websites.count) {
                    return websites.count;
                }
            }
            return 0;
        }

        if (section == 4) {//spectail Feature
            return cellData.array_other_features.count;
        }
        if (section == 5) {
            return cellData.array_amenities.count;
        }
        if (section == 6) {//fixtures_fittings
            return cellData.array_fixtures_fittings.count;
        }
        
    }
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        if (section == 0) {
            return 1;
        }
        if (section == 01) {
            return 2;
        }
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return videos.count;
                }
            }
            return 0;
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *websites = [cellData.paraValues objectAtIndex:index];
                if ([websites isKindOfClass:[NSMutableArray class]] && websites.count) {
                    return websites.count;
                }
            }
            return 0;
        }

        if (section == 4) {//spectail Feature
            return cellData.array_other_features.count;
        }
        if (section == 5) {//amenities
            return cellData.array_amenities.count;
        }
        if (section == 6) {//home interor
            return cellData.array_fixtures_fittings.count;
        }
        if (section == 7) {//restriction
            return cellData.arry_restrictions.count;
        }
        
    }

    return listComments.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    title = @"Videos";
                }
            }
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    title = @"Website";
                }
            }
        }

        if (section == 4 && cellData.array_other_features.count) {
            title = @"Special Features";
        }
        if (section == 5 && cellData.array_fixtures_fittings.count) {
            title = @"Feature & Fittings";
        }
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    title = @"Videos";
                }
            }
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    title = @"Website";
                }
            }
        }

        if (section == 4 && cellData.array_other_features.count) {
            title = @"Special Features";
        }
        if (section == 5 && cellData.array_amenities.count) {
            title = @"Amenities";
        }
        if (section == 6 && cellData.array_fixtures_fittings.count) {
            title = @"Interior and Fixtures & Fittings";
        }
    }
    
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    title = @"Videos";
                }
            }
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    title = @"Website";
                }
            }
        }

        if (section == 4 && cellData.array_other_features.count) {
            title = @"Special Features";
        }
        if (section == 5 && cellData.array_amenities.count) {
            title = @"Indoor & Outdoors";
        }
        if (section == 6 && cellData.array_fixtures_fittings.count) {
            title = @"Fixtures & Fittings";
        }
    }
    
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    title = @"Videos";
                }
            }
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    title = @"Website";
                }
            }
        }

        if (section == 4 && cellData.array_other_features.count) {
            title = @"Special Features";
        }
        if (section == 5 && cellData.array_amenities.count) {
            title = @"Amenities";
        }
        if (section == 6 && cellData.array_fixtures_fittings.count) {
            title = @"Home Interior";
        }
        if (section == 7 && cellData.arry_restrictions.count) {
            title = @"Restrictions";
        }
    }
    return title;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = nil;
    if (_viewMode == modePreview) {
        return header;
    }
//    if (section == 0) {
//        return nil;
//    }
    if (section == 01) {
        // Create view for header
        NSInteger index = 0;
        NSString *value;
        index = [cellData.paraNames indexOfObject:@"clap_info"];
        NSDictionary *clapInfo = [cellData.paraValues objectAtIndex:index];
        NSInteger totalClap = [[clapInfo objectForKey:@"total_claps"] integerValue];
        BOOL isClap = [[clapInfo objectForKey:@"is_clap"] boolValue];
        
        //Comment
        index = [cellData.paraNames indexOfObject:@"total_comments"];
        value = [cellData.paraValues objectAtIndex:index];
        NSInteger totalComment = [value integerValue];
        if (totalClap >= 0) {
            header = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, CELL_COMMENTS_HEADER_HEIGHT)];
            header.backgroundColor = [UIColor clearColor];
            
            //clap btn
            
            UIButton *clapBtn = [[UIButton alloc]init];
            [clapBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE ]];
            if (isClap) {
                [clapBtn setTitle:@"Unclap  " forState:UIControlStateNormal];
            }else
                [clapBtn setTitle:@" Clap    " forState:UIControlStateNormal];
            [clapBtn sizeToFit];
            clapBtn.titleLabel.textColor = [UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1];
            //clapBtn.layer.cornerRadius = 5.0;
            //clapBtn.layer.borderWidth = 0.20;
            //clapBtn.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
            //[clapBtn.layer setMasksToBounds:YES];
            [clapBtn addTarget:self action:@selector(clapBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            float width = self.view.frame.size.width - CELL_CONTENT_MARGIN_RIGHT - 22;
            CGRect frame;
            float y = 7;
            [clapBtn sizeToFit];
            frame = clapBtn.frame;
            frame.origin.x = 15;
            frame.origin.y = y;
            clapBtn.frame =frame;
            [header addSubview:clapBtn];
            if (totalComment) {
                //Commnets
                UIButton *commentBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 120, 7, 100, 15)];
                [commentBtn setTitle:[NSString stringWithFormat:@"%d Comments", totalComment] forState:UIControlStateNormal];
                [commentBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                [commentBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [commentBtn sizeToFit];
                commentBtn.frame = CGRectMake(self.view.frame.size.width - commentBtn.frame.size.width - 20, 7, commentBtn.frame.size.width, commentBtn.frame.size.height);
                commentBtn.titleLabel.textColor = [UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1];
                [commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [commentBtn sizeToFit];
                width -= commentBtn.frame.size.width;
                frame = commentBtn.frame;
                frame.origin.x = width;
                frame.origin.y = y;
                commentBtn.frame = frame;
                [header addSubview:commentBtn];
                
                width -= 7;
            }
            
            if (totalClap) {
                // people clap
                UILabel *lbPeopleClap = [[UILabel alloc]init];
                lbPeopleClap.backgroundColor = [UIColor clearColor];
                [lbPeopleClap setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
                lbPeopleClap.text =  [NSString stringWithFormat:@"%d",totalClap];
                [lbPeopleClap setTextColor:[UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1]];
                [lbPeopleClap sizeToFit];
                width -= lbPeopleClap.frame.size.width;
                frame = lbPeopleClap.frame;
                frame.origin.x = width;
                frame.origin.y = y;
                lbPeopleClap.frame = frame;
                [header addSubview:lbPeopleClap];
                
                //[_clapIcon sizeToFit];
                //icon clap
                UIImageView *clapIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clap_black_white.png"]];
                clapIcon.frame = CGRectMake( 20.0, 7, 20 , 20);
                
                width -= (clapIcon.frame.size.width + 3);
                frame =clapIcon.frame;
                frame.origin.x = width;
                frame.origin.y = y;
                clapIcon.frame = frame;
                [header addSubview:clapIcon];
            }
            
        }
        
        
    }
//    if (section == 2) {
//        //title = @"Special Features";
//        header = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, CELL_COMMENTS_HEADER_HEIGHT)];
//        header.backgroundColor = [UIColor clearColor];
//        UILabel *titleView = [[UILabel alloc] initWithFrame:header.frame];
//        [titleView setText:@"Special Features"];
//        [titleView setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
//        [titleView setTextColor:[UIColor whiteColor]];
//        titleView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//        [header addSubview:titleView];
//    }
//    if (section == 3) {
//        //title = @"Feature & Fittings";
//        header = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, CELL_COMMENTS_HEADER_HEIGHT)];
//        header.backgroundColor = [UIColor clearColor];
//        UILabel *titleView = [[UILabel alloc] initWithFrame:header.frame];
//        [titleView setText:@"Feature & Fittings"];
//        titleView.backgroundColor = [UIColor lightGrayColor];
//        [header addSubview:titleView];
//    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma mark . HDB
    if ([self.itemName isEqualToString:@"HDB Search"]) {
#pragma mark _ . s = 0
        if ((indexPath.section == 0) && (indexPath.row == 0)) {
            static NSString *CellIdentifier1 = @"HDBResultDetailCell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier1 owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                topLevelObjects = nil;
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                cell.backgroundView = [[UIView alloc] init];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            NSInteger index = 0;
            id value ;
            //Property Status
            UILabel *status = (UILabel*)[cell viewWithTag:1];
            index = [cellData.paraNames indexOfObject:@"status"];
            value = [cellData.paraValues objectAtIndex:index];
            _property_status = @"r";
            if ([value isKindOfClass:[NSString class]]) {
                _property_status = value;
            }
            if ([value isKindOfClass:[NSNumber class]]) {
                _property_status = [value stringValue];
            }
            if ([_property_status isEqualToString:@"r"] || [_property_status isEqualToString:@"1"]) {
                [status setText:@"For Rent"];
            }else
            {
                [status setText:@"For Sale"];
            }
            //Create
            UILabel *created = (UILabel*)[cell viewWithTag:2];
            index = [cellData.paraNames indexOfObject:@"created"];
            value = [NSData stringDecodeFromBase64String:[cellData.paraValues objectAtIndex:index]];
            [created setText:value];
            //thumb
            UIImageView *imagView = (UIImageView*)[cell viewWithTag:3];
            index = [cellData.paraNames indexOfObject:@"thumb"];
            value = [cellData.paraValues objectAtIndex:index];
            [imagView setImageWithURL:[NSURL URLWithString:value]];
            //Title
            UILabel *titleHDB = (UILabel*) [cell viewWithTag:4];
            index = [cellData.paraNames indexOfObject:@"block_no"];
            value = [cellData.paraValues objectAtIndex:index];
            
            index = [cellData.paraNames indexOfObject:@"street_name"];
            value = [NSString stringWithFormat:@"%@ %@",value, [cellData.paraValues objectAtIndex:index]];
            [titleHDB setText:value];
            //price
            UILabel *price = (UILabel*) [cell viewWithTag:12];
            if ([_property_status isEqualToString:@"s"] || [_property_status isEqualToString:@"0"]) {
                index = [cellData.paraNames indexOfObject:@"price"];
            }else
            {
                index = [cellData.paraNames indexOfObject:@"monthly_rental"];
            }
            
            value = [cellData.paraValues objectAtIndex:index];
            [price setText:[NSString stringWithFormat:@"S$ %@", value]];
            //psf
            index = [cellData.paraNames indexOfObject:@"psf"];
            value = [cellData.paraValues objectAtIndex:index];
            
            [price setText:[NSString stringWithFormat:@"%@ (S$ %@ psf)",price.text, value]];
            
            
            //lease_term_valuation_price (unit_level)
            UILabel *lease_term_valuation_price = (UILabel*) [cell viewWithTag:5];
            if ([_property_status isEqualToString:@"s"] || [_property_status isEqualToString:@"0"]) {
                index = [cellData.paraNames indexOfObject:@"valuation_price"];
                value = [NSString stringWithFormat:@"S$ %@ valn", [cellData.paraValues objectAtIndex:index]];
            }else
            {
                index = [cellData.paraNames indexOfObject:@"lease_term"];
                value = [cellData.paraValues objectAtIndex:index];
            }
            
            //unit_level
            index = [cellData.paraNames indexOfObject:@"unit_level"];
            NSString *unit_level = [cellData.paraValues objectAtIndex:index];
            if (unit_level.length > 0) {
                value = [NSString stringWithFormat:@"%@ ( %@ )", value, unit_level];
            }
            [lease_term_valuation_price setText:value];
            //hdb_estate
            UILabel *hdb_estate = (UILabel*) [cell viewWithTag:6];
            index = [cellData.paraNames indexOfObject:@"hdb_estate"];
            value = [cellData.paraValues objectAtIndex:index];
            
            //furnishing
            index = [cellData.paraNames indexOfObject:@"furnishing"];
            NSString *furnishing = [cellData.paraValues objectAtIndex:index];
            if (! [furnishing isEqualToString:@""] ) {
                value = [value stringByAppendingFormat:@" ( %@ )", furnishing];
            }
            [hdb_estate setText:value];
            //size
            UILabel *size = (UILabel*) [cell viewWithTag:7];
            index = [cellData.paraNames indexOfObject:@"size"];
            value = [cellData.paraValues objectAtIndex:index];
            [size setText:[NSString stringWithFormat:@"%@ sqft",value]];
            float sqft = [value floatValue];
            float sqm = sqft * 0.092903;
            [size setText:[NSString stringWithFormat:@"%@ sqft / %0.02f sqm",value, sqm]];
            //building_completion
            UILabel *building_completion = (UILabel*) [cell viewWithTag:11];
            index = [cellData.paraNames indexOfObject:@"building_completion"];
            value = [cellData.paraValues objectAtIndex:index];
            [building_completion setText:[NSString stringWithFormat:@"%@ Completed", value]];
            //bedrooms
            UILabel *bedrooms = (UILabel*) [cell viewWithTag:8];
            index = [cellData.paraNames indexOfObject:@"bedrooms"];
            value = [cellData.paraValues objectAtIndex:index];
            [bedrooms setText:value];
            //washroom
            UILabel *washroom = (UILabel*) [cell viewWithTag:9];
            index = [cellData.paraNames indexOfObject:@"washroom"];
            value = [cellData.paraValues objectAtIndex:index];
            [washroom setText:value];
            //totalView
            UILabel *total_views = (UILabel*) [cell viewWithTag:13];
            index = [cellData.paraNames indexOfObject:@"total_views"];
            value = [cellData.paraValues objectAtIndex:index];
            [total_views setText:[NSString stringWithFormat:@"Total Views: %@", value]];
            //HDB Type
            UILabel *HDBType = (UILabel*) [cell viewWithTag:14];
            index = [cellData.paraNames indexOfObject:@"property_type"];
            value = [cellData.paraValues objectAtIndex:index];
            [HDBType setText:value];
            return cell;
            
        }
#pragma mark _ . s = 1
        if ((indexPath.section == 1)) {
            if ( ( indexPath.row == 0) ) {
                static NSString *CellIdentifier2 = @"HDBResultDetailCell2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
                if (cell == nil) {
                    
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier2 owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    topLevelObjects = nil;
                    [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                    cell.backgroundView = [[UIView alloc] init];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                NSInteger index;
                NSString *value;
                //avartar
                UIImageView *avatar = (UIImageView*)[cell viewWithTag:3];
                [avatar setImageWithURL:[NSURL URLWithString:cellData.userInfo.avatarUrl]];
                // posted user
                UILabel *user_posted = (UILabel*)[cell viewWithTag:4];
                [user_posted setText:cellData.userInfo.fullName];
                
                
                //ad_owner
                UILabel *ad_owner = (UILabel*)[cell viewWithTag:5];
                index = [cellData.paraNames indexOfObject:@"ad_owner"];
                value = [cellData.paraValues objectAtIndex:index];
                [ad_owner setText:value];
                
                //[self setClapCommentForCell:cell andData:cellData];
                return cell;
            }
            if (indexPath.row == 1) {
                //descritption
                //HDBResultDetailCell3
                static NSString *CellIdentifier3 = @"HDBResultDetailCell3";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
                if (cell == nil) {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier3 owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    topLevelObjects = nil;
                    [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                    cell.backgroundView = [[UIView alloc] init];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                
                NSInteger index;
                NSString *value;
                index = [cellData.paraNames indexOfObject:@"description"];
                value = [cellData.paraValues objectAtIndex:index];
                value = [NSData stringDecodeFromBase64String:value];
                UILabel *description = (UILabel*)[cell viewWithTag:2];
                [description setText:value];
                
                return cell;
            }
            
        }
#pragma mark _ . s = 2
        if (indexPath.section == 2) {
            static NSString *CellIdentifierVideos = @"CellVideos";
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifierVideos];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierVideos];
                cell.backgroundView = [[UIView alloc]init];
                cell.backgroundColor = tableView.backgroundColor;
                CGRect videoFrame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, 71);
                LinkPreview * linkView = [[LinkPreview alloc]initWithFrame:videoFrame];
                linkView.tag = 1;
                [cell addSubview:linkView];
                linkView.autoresizesSubviews = YES;
            }
            LinkPreview * linkView =  (LinkPreview *)[cell viewWithTag:1];
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (linkView && index != NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                [linkView loadContentWithFrame:linkView.frame LinkInfo:[videos objectAtIndex:indexPath.row] Type:linkPreviewTypeYoutube];
            }
            return cell;
        }
#pragma mark _ . s = 3
        if (indexPath.section == 3) {
            static NSString *CellIdentifierVideos = @"CellWebsites";
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifierVideos];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierVideos];
                cell.backgroundView = [[UIView alloc]init];
                cell.backgroundColor = tableView.backgroundColor;
                CGRect videoFrame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, 71);
                LinkPreview * linkView = [[LinkPreview alloc]initWithFrame:videoFrame];
                linkView.tag = 1;
                [cell addSubview:linkView];
                linkView.autoresizesSubviews = YES;
            }
            LinkPreview * linkView =  (LinkPreview *)[cell viewWithTag:1];
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (linkView && index != NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                [linkView loadContentWithFrame:linkView.frame LinkInfo:[videos objectAtIndex:indexPath.row] Type:linkPreviewTypeWebSite];
            }
            return cell;
        }
#pragma mark _ . s = 4
        if (indexPath.section == 4) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_other_features objectAtIndex:indexPath.row];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
#pragma mark _ . s = 5
        if (indexPath.section == 5) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_fixtures_fittings objectAtIndex:indexPath.row];
            return cell;
        }
#pragma mark _ . s = 6
        if (indexPath.section == 6) {
            static NSString *CellIdentifier = @"UICommentCell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = nil;
                nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
                cell = (UITableViewCell *)[nib objectAtIndex:0];
                
            }
            CommentsCellContent *content = [listComments objectAtIndex:indexPath.row];
            //ImageView
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
            [imageView setImageWithURL:[NSURL URLWithString: content.userAvatarURL]];
            //Username
            UILabel *userName = (UILabel*)[cell viewWithTag:2];
            userName.text = content.userPostName;
            //text
            UILabel *text = (UILabel*)[cell viewWithTag:3];
            text.text = content.text;
            [text setNeedsDisplay];
            CGSize constraint = CGSizeMake(294 - 74, 20000.0f);
            CGSize size = [content.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = text.frame;
            frame.size = size;
            text.frame = frame;
            //    [text setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin ];
            //Create
            UILabel *created = (UILabel*)[cell viewWithTag:4];
            created.text = content.created;
            tableView.scrollEnabled = YES;
            
            cell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
            return cell;
            
        }
    }
#pragma mark . Condos
    if ([self.itemName isEqualToString:@"Condos Search"]) {
#pragma mark _ . s = 0
        if ((indexPath.section == 0) && (indexPath.row == 0)) {
            static NSString *CellIdentifier1 = @"HDBResultDetailCell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier1 owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                topLevelObjects = nil;
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                cell.backgroundView = [[UIView alloc] init];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            NSInteger index = 0;
            id value ;
            //Property Status
            UILabel *status = (UILabel*)[cell viewWithTag:1];
            index = [cellData.paraNames indexOfObject:@"status"];
            value = [cellData.paraValues objectAtIndex:index];
            _property_status = @"r";
            if ([value isKindOfClass:[NSString class]]) {
                _property_status = value;
            }
            if ([value isKindOfClass:[NSNumber class]]) {
                _property_status = [value stringValue];
            }
            if ([_property_status isEqualToString:@"r"] || [_property_status isEqualToString:@"1"]) {
                [status setText:@"For Rent"];
            }else
            {
                [status setText:@"For Sale"];
            }
            //Create
            UILabel *created = (UILabel*)[cell viewWithTag:2];
            index = [cellData.paraNames indexOfObject:@"created"];
            value = [NSData stringDecodeFromBase64String:[cellData.paraValues objectAtIndex:index]];
            [created setText:value];
            //thumb
            UIImageView *imagView = (UIImageView*)[cell viewWithTag:3];
            index = [cellData.paraNames indexOfObject:@"thumb"];
            value = [cellData.paraValues objectAtIndex:index];
            [imagView setImageWithURL:[NSURL URLWithString:value]];
            //Title
            UILabel *titleHDB = (UILabel*) [cell viewWithTag:4];
            index = [cellData.paraNames indexOfObject:@"address"];
            value = [cellData.paraValues objectAtIndex:index];
            [titleHDB setText:value];
            //price
            UILabel *price = (UILabel*) [cell viewWithTag:12];
            if ([_property_status isEqualToString:@"s"] || [_property_status isEqualToString:@"0"]) {
                index = [cellData.paraNames indexOfObject:@"price"];
            }else
            {
                index = [cellData.paraNames indexOfObject:@"monthly_rental"];
            }
            
            value = [cellData.paraValues objectAtIndex:index];
            [price setText:[NSString stringWithFormat:@"S$ %@", value]];
            //psf
            index = [cellData.paraNames indexOfObject:@"psf"];
            value = [cellData.paraValues objectAtIndex:index];
            
            [price setText:[NSString stringWithFormat:@"%@ (S$ %@ psf)",price.text, value]];
            
            
            //lease_term_valuation_price (unit_level)
            UILabel *lease_term_valuation_price = (UILabel*) [cell viewWithTag:5];
            if ([_property_status isEqualToString:@"s"] || [_property_status isEqualToString:@"0"]) {
                index = [cellData.paraNames indexOfObject:@"valuation_price"];
                value = [NSString stringWithFormat:@"S$ %@ valn", [cellData.paraValues objectAtIndex:index]];
            }else
            {
                index = [cellData.paraNames indexOfObject:@"lease_term"];
                value = [cellData.paraValues objectAtIndex:index];
            }
            
            //unit_level
            index = [cellData.paraNames indexOfObject:@"unit_level"];
            NSString *unit_level = [cellData.paraValues objectAtIndex:index];
            if (unit_level.length > 0) {
                value = [NSString stringWithFormat:@"%@ ( %@ )", value, unit_level];
            }
            [lease_term_valuation_price setText:value];
            //hdb_estate
            UILabel *hdb_estate = (UILabel*) [cell viewWithTag:6];
            index = [cellData.paraNames indexOfObject:@"district"];
            value = [cellData.paraValues objectAtIndex:index];
            
            //furnishing
            index = [cellData.paraNames indexOfObject:@"furnishing"];
            NSString *furnishing = [cellData.paraValues objectAtIndex:index];
            if (! [furnishing isEqualToString:@""] ) {
                value = [value stringByAppendingFormat:@" ( %@ )", furnishing];
            }
            [hdb_estate setText:value];
            //size
            UILabel *size = (UILabel*) [cell viewWithTag:7];
            index = [cellData.paraNames indexOfObject:@"size"];
            value = [cellData.paraValues objectAtIndex:index];
            index = [cellData.paraNames indexOfObject:@"size_m"];
            NSString *size_m = [cellData.paraValues objectAtIndex:index];
            [size setText:[NSString stringWithFormat:@"%@ sqft / %@ sqm",value, size_m]];
            //building_completion
            UILabel *building_completion = (UILabel*) [cell viewWithTag:11];
            index = [cellData.paraNames indexOfObject:@"building_completion"];
            value = [cellData.paraValues objectAtIndex:index];
            [building_completion setText:[NSString stringWithFormat:@"%@ Completed", value]];
            //bedrooms
            UILabel *bedrooms = (UILabel*) [cell viewWithTag:8];
            index = [cellData.paraNames indexOfObject:@"bedrooms"];
            value = [cellData.paraValues objectAtIndex:index];
            [bedrooms setText:value];
            //washroom
            UILabel *washroom = (UILabel*) [cell viewWithTag:9];
            index = [cellData.paraNames indexOfObject:@"washroom"];
            value = [cellData.paraValues objectAtIndex:index];
            [washroom setText:value];
            //totalView
            UILabel *total_views = (UILabel*) [cell viewWithTag:13];
            index = [cellData.paraNames indexOfObject:@"total_views"];
            value = [cellData.paraValues objectAtIndex:index];
            [total_views setText:[NSString stringWithFormat:@"Total Views: %@", value]];
            //HDB Type
            UILabel *HDBType = (UILabel*) [cell viewWithTag:14];
            index = [cellData.paraNames indexOfObject:@"project_name"];
            value = [cellData.paraValues objectAtIndex:index];
            [HDBType setText:value];
            return cell;
            
        }
#pragma mark _ . s = 1
        if ((indexPath.section == 1)) {
            if ( ( indexPath.row == 0) ) {
                static NSString *CellIdentifier2 = @"HDBResultDetailCell2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
                if (cell == nil) {
                    
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier2 owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    topLevelObjects = nil;
                    [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                    cell.backgroundView = [[UIView alloc] init];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                NSInteger index;
                NSString *value;
                //avartar
                UIImageView *avatar = (UIImageView*)[cell viewWithTag:3];
                [avatar setImageWithURL:[NSURL URLWithString:cellData.userInfo.avatarUrl]];
                // posted user
                UILabel *user_posted = (UILabel*)[cell viewWithTag:4];
                [user_posted setText:cellData.userInfo.fullName];
                
                
                //ad_owner
                UILabel *ad_owner = (UILabel*)[cell viewWithTag:5];
                index = [cellData.paraNames indexOfObject:@"ad_owner"];
                value = [cellData.paraValues objectAtIndex:index];
                [ad_owner setText:value];
                
                //[self setClapCommentForCell:cell andData:cellData];
                return cell;
            }
            if (indexPath.row == 1) {
                //descritption
                //HDBResultDetailCell3
                static NSString *CellIdentifier3 = @"HDBResultDetailCell3";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
                if (cell == nil) {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier3 owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    topLevelObjects = nil;
                    [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                    cell.backgroundView = [[UIView alloc] init];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                
                NSInteger index;
                NSString *value;
                index = [cellData.paraNames indexOfObject:@"description"];
                value = [cellData.paraValues objectAtIndex:index];
                value = [NSData stringDecodeFromBase64String:value];
                UILabel *description = (UILabel*)[cell viewWithTag:2];
                [description setText:value];
                
                return cell;
            }
            
        }
#pragma mark _ . s = 2
        if (indexPath.section == 2) {
            static NSString *CellIdentifierVideos = @"CellVideos";
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifierVideos];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierVideos];
                cell.backgroundView = [[UIView alloc]init];
                cell.backgroundColor = tableView.backgroundColor;
                CGRect videoFrame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, 71);
                LinkPreview * linkView = [[LinkPreview alloc]initWithFrame:videoFrame];
                linkView.tag = 1;
                [cell addSubview:linkView];
                linkView.autoresizesSubviews = YES;
            }
            LinkPreview * linkView =  (LinkPreview *)[cell viewWithTag:1];
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (linkView && index != NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                [linkView loadContentWithFrame:linkView.frame LinkInfo:[videos objectAtIndex:indexPath.row] Type:linkPreviewTypeYoutube];
            }
            return cell;
        }
#pragma mark _ . s = 3
        if (indexPath.section == 3) {
            static NSString *CellIdentifierVideos = @"CellWebsites";
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifierVideos];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierVideos];
                cell.backgroundView = [[UIView alloc]init];
                cell.backgroundColor = tableView.backgroundColor;
                CGRect videoFrame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, 71);
                LinkPreview * linkView = [[LinkPreview alloc]initWithFrame:videoFrame];
                linkView.tag = 1;
                [cell addSubview:linkView];
                linkView.autoresizesSubviews = YES;
            }
            LinkPreview * linkView =  (LinkPreview *)[cell viewWithTag:1];
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (linkView && index != NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                [linkView loadContentWithFrame:linkView.frame LinkInfo:[videos objectAtIndex:indexPath.row] Type:linkPreviewTypeWebSite];
            }
            return cell;
        }
#pragma mark _ . s = 4
        if (indexPath.section == 4) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_other_features objectAtIndex:indexPath.row];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
        if (indexPath.section == 5) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_amenities objectAtIndex:indexPath.row];
            return cell;
        }
        if (indexPath.section == 6) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_fixtures_fittings objectAtIndex:indexPath.row];
            return cell;
        }
        if (indexPath.section == 7) {
            static NSString *CellIdentifier = @"UICommentCell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = nil;
                nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
                cell = (UITableViewCell *)[nib objectAtIndex:0];
                
            }
            CommentsCellContent *content = [listComments objectAtIndex:indexPath.row];
            //ImageView
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
            [imageView setImageWithURL:[NSURL URLWithString: content.userAvatarURL]];
            //Username
            UILabel *userName = (UILabel*)[cell viewWithTag:2];
            userName.text = content.userPostName;
            //text
            UILabel *text = (UILabel*)[cell viewWithTag:3];
            text.text = content.text;
            [text setNeedsDisplay];
            CGSize constraint = CGSizeMake(294 - 74, 20000.0f);
            CGSize size = [content.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = text.frame;
            frame.size = size;
            text.frame = frame;
            //    [text setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin ];
            //Create
            UILabel *created = (UILabel*)[cell viewWithTag:4];
            created.text = content.created;
            tableView.scrollEnabled = YES;
            
            cell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
            return cell;
            
        }
    }
#pragma mark . Landed Property
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        if ((indexPath.section == 0) && (indexPath.row == 0)) {
            static NSString *CellIdentifier1 = @"HDBResultDetailCell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier1 owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                topLevelObjects = nil;
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                cell.backgroundView = [[UIView alloc] init];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            NSInteger index = 0;
            id value ;
            //Property Status
            UILabel *status = (UILabel*)[cell viewWithTag:1];
            index = [cellData.paraNames indexOfObject:@"status"];
            value = [cellData.paraValues objectAtIndex:index];
            _property_status = @"r";
            if ([value isKindOfClass:[NSString class]]) {
                _property_status = value;
            }
            if ([value isKindOfClass:[NSNumber class]]) {
                _property_status = [value stringValue];
            }
            if ([_property_status isEqualToString:@"r"] || [_property_status isEqualToString:@"1"]) {
                [status setText:@"For Rent"];
            }else
            {
                [status setText:@"For Sale"];
            }
            //Create
            UILabel *created = (UILabel*)[cell viewWithTag:2];
            index = [cellData.paraNames indexOfObject:@"created"];
            value = [NSData stringDecodeFromBase64String:[cellData.paraValues objectAtIndex:index]];
            [created setText:value];
            //thumb
            UIImageView *imagView = (UIImageView*)[cell viewWithTag:3];
            index = [cellData.paraNames indexOfObject:@"thumb"];
            value = [cellData.paraValues objectAtIndex:index];
            [imagView setImageWithURL:[NSURL URLWithString:value]];
            //Title
            UILabel *titleHDB = (UILabel*) [cell viewWithTag:4];
            index = [cellData.paraNames indexOfObject:@"address"];
            value = [cellData.paraValues objectAtIndex:index];
            [titleHDB setText:value];
            //price
            UILabel *price = (UILabel*) [cell viewWithTag:12];
            if ([_property_status isEqualToString:@"s"] || [_property_status isEqualToString:@"0"]) {
                index = [cellData.paraNames indexOfObject:@"price"];
            }else
            {
                index = [cellData.paraNames indexOfObject:@"monthly_rental"];
            }
            
            value = [cellData.paraValues objectAtIndex:index];
            [price setText:[NSString stringWithFormat:@"S$ %@", value]];
            //psf
            index = [cellData.paraNames indexOfObject:@"psf"];
            value = [cellData.paraValues objectAtIndex:index];
            
            [price setText:[NSString stringWithFormat:@"%@ (S$ %@ psf)",price.text, value]];
            
            
            //lease_term_valuation_price (unit_level)
            UILabel *lease_term_valuation_price = (UILabel*) [cell viewWithTag:5];
            if ([_property_status isEqualToString:@"s"] || [_property_status isEqualToString:@"0"]) {
                index = [cellData.paraNames indexOfObject:@"valuation_price"];
                value = [NSString stringWithFormat:@"S$ %@ valn", [cellData.paraValues objectAtIndex:index]];
            }else
            {
                index = [cellData.paraNames indexOfObject:@"lease_term"];
                value = [cellData.paraValues objectAtIndex:index];
            }
            
            //unit_level
            index = [cellData.paraNames indexOfObject:@"tenure"];
            NSString *unit_level = [cellData.paraValues objectAtIndex:index];
            if (unit_level.length > 0) {
                value = [NSString stringWithFormat:@"%@ ( %@ )", value, unit_level];
            }
            [lease_term_valuation_price setText:value];
            //hdb_estate
            UILabel *hdb_estate = (UILabel*) [cell viewWithTag:6];
            index = [cellData.paraNames indexOfObject:@"district"];
            value = [cellData.paraValues objectAtIndex:index];
            
            //furnishing
            index = [cellData.paraNames indexOfObject:@"furnishing"];
            NSString *furnishing = [cellData.paraValues objectAtIndex:index];
            if (! [furnishing isEqualToString:@""] ) {
                value = [value stringByAppendingFormat:@" ( %@ )", furnishing];
            }
            [hdb_estate setText:value];
            //size
            UILabel *size = (UILabel*) [cell viewWithTag:7];
            index = [cellData.paraNames indexOfObject:@"size"];
            value = [cellData.paraValues objectAtIndex:index];
            index = [cellData.paraNames indexOfObject:@"size_m"];
            NSString *size_m = [cellData.paraValues objectAtIndex:index];
            [size setText:[NSString stringWithFormat:@"%@ sqft / %@ sqm",value, size_m]];
            //building_completion
            UILabel *building_completion = (UILabel*) [cell viewWithTag:11];
            index = [cellData.paraNames indexOfObject:@"building_completion"];
            value = [cellData.paraValues objectAtIndex:index];
            [building_completion setText:[NSString stringWithFormat:@"%@ Completed", value]];
            //bedrooms
            UILabel *bedrooms = (UILabel*) [cell viewWithTag:8];
            index = [cellData.paraNames indexOfObject:@"bedrooms"];
            value = [cellData.paraValues objectAtIndex:index];
            [bedrooms setText:value];
            //washroom
            UILabel *washroom = (UILabel*) [cell viewWithTag:9];
            index = [cellData.paraNames indexOfObject:@"washroom"];
            value = [cellData.paraValues objectAtIndex:index];
            [washroom setText:value];
            //totalView
            UILabel *total_views = (UILabel*) [cell viewWithTag:13];
            index = [cellData.paraNames indexOfObject:@"total_views"];
            value = [cellData.paraValues objectAtIndex:index];
            [total_views setText:[NSString stringWithFormat:@"Total Views: %@", value]];
            //HDB Type
            UILabel *HDBType = (UILabel*) [cell viewWithTag:14];
            value = @"";
            [HDBType setText:value];
            return cell;
            
        }
        
        if ((indexPath.section == 1)) {
            if ( ( indexPath.row == 0) ) {
                static NSString *CellIdentifier2 = @"HDBResultDetailCell2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
                if (cell == nil) {
                    
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier2 owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    topLevelObjects = nil;
                    [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                    cell.backgroundView = [[UIView alloc] init];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                NSInteger index;
                NSString *value;
                //avartar
                UIImageView *avatar = (UIImageView*)[cell viewWithTag:3];
                [avatar setImageWithURL:[NSURL URLWithString:cellData.userInfo.avatarUrl]];
                // posted user
                UILabel *user_posted = (UILabel*)[cell viewWithTag:4];
                [user_posted setText:cellData.userInfo.fullName];
                
                
                //ad_owner
                UILabel *ad_owner = (UILabel*)[cell viewWithTag:5];
                index = [cellData.paraNames indexOfObject:@"ad_owner"];
                value = [cellData.paraValues objectAtIndex:index];
                [ad_owner setText:value];
                
                //[self setClapCommentForCell:cell andData:cellData];
                return cell;
            }
            if (indexPath.row == 1) {
                //descritption
                //HDBResultDetailCell3
                static NSString *CellIdentifier3 = @"HDBResultDetailCell3";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
                if (cell == nil) {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier3 owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    topLevelObjects = nil;
                    [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                    cell.backgroundView = [[UIView alloc] init];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                
                NSInteger index;
                NSString *value;
                index = [cellData.paraNames indexOfObject:@"description"];
                value = [cellData.paraValues objectAtIndex:index];
                value = [NSData stringDecodeFromBase64String:value];
                UILabel *description = (UILabel*)[cell viewWithTag:2];
                [description setText:value];
                
                return cell;
            }
            
        }
#pragma mark _ . s = 2
        if (indexPath.section == 2) {
            static NSString *CellIdentifierVideos = @"CellVideos";
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifierVideos];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierVideos];
                cell.backgroundView = [[UIView alloc]init];
                cell.backgroundColor = tableView.backgroundColor;
                CGRect videoFrame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, 71);
                LinkPreview * linkView = [[LinkPreview alloc]initWithFrame:videoFrame];
                linkView.tag = 1;
                [cell addSubview:linkView];
                linkView.autoresizesSubviews = YES;
            }
            LinkPreview * linkView =  (LinkPreview *)[cell viewWithTag:1];
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (linkView && index != NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                [linkView loadContentWithFrame:linkView.frame LinkInfo:[videos objectAtIndex:indexPath.row] Type:linkPreviewTypeYoutube];
            }
            return cell;
        }
#pragma mark _ . s = 3
        if (indexPath.section == 3) {
            static NSString *CellIdentifierVideos = @"CellWebsites";
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifierVideos];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierVideos];
                cell.backgroundView = [[UIView alloc]init];
                cell.backgroundColor = tableView.backgroundColor;
                CGRect videoFrame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, 71);
                LinkPreview * linkView = [[LinkPreview alloc]initWithFrame:videoFrame];
                linkView.tag = 1;
                [cell addSubview:linkView];
                linkView.autoresizesSubviews = YES;
            }
            LinkPreview * linkView =  (LinkPreview *)[cell viewWithTag:1];
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (linkView && index != NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                [linkView loadContentWithFrame:linkView.frame LinkInfo:[videos objectAtIndex:indexPath.row] Type:linkPreviewTypeWebSite];
            }
            return cell;
        }

        if (indexPath.section == 4) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_other_features objectAtIndex:indexPath.row];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
        if (indexPath.section == 5) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_amenities objectAtIndex:indexPath.row];
            return cell;
        }
        if (indexPath.section == 6) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_fixtures_fittings objectAtIndex:indexPath.row];
            return cell;
        }
        if (indexPath.section == 7) {
            static NSString *CellIdentifier = @"UICommentCell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = nil;
                nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
                cell = (UITableViewCell *)[nib objectAtIndex:0];
                
            }
            CommentsCellContent *content = [listComments objectAtIndex:indexPath.row];
            //ImageView
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
            [imageView setImageWithURL:[NSURL URLWithString: content.userAvatarURL]];
            //Username
            UILabel *userName = (UILabel*)[cell viewWithTag:2];
            userName.text = content.userPostName;
            //text
            UILabel *text = (UILabel*)[cell viewWithTag:3];
            text.text = content.text;
            [text setNeedsDisplay];
            CGSize constraint = CGSizeMake(294 - 74, 20000.0f);
            CGSize size = [content.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = text.frame;
            frame.size = size;
            text.frame = frame;
            //    [text setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin ];
            //Create
            UILabel *created = (UILabel*)[cell viewWithTag:4];
            created.text = content.created;
            tableView.scrollEnabled = YES;
            
            cell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
            return cell;
            
        }
    }
    
#pragma mark . Rooms For Rent
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        if ((indexPath.section == 0) && (indexPath.row == 0)) {
            static NSString *CellIdentifier1 = @"HDBResultDetailCell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier1 owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
                topLevelObjects = nil;
                [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                cell.backgroundView = [[UIView alloc] init];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            NSInteger index = 0;
            NSString *value =@"";
            //Property Status
            UILabel *status = (UILabel*)[cell viewWithTag:1];
            [status setText:@"For Sale"];
            //Create
            UILabel *created = (UILabel*)[cell viewWithTag:2];
            index = [cellData.paraNames indexOfObject:@"created"];
            value = [NSData stringDecodeFromBase64String:[cellData.paraValues objectAtIndex:index]];
            [created setText:value];
            //thumb
            UIImageView *imagView = (UIImageView*)[cell viewWithTag:3];
            index = [cellData.paraNames indexOfObject:@"thumb"];
            value = [cellData.paraValues objectAtIndex:index];
            [imagView setImageWithURL:[NSURL URLWithString:value]];
            //Title
            UILabel *titleHDB = (UILabel*) [cell viewWithTag:4];
            index = [cellData.paraNames indexOfObject:@"address"];
            value = [cellData.paraValues objectAtIndex:index];
            [titleHDB setText:value];
            //price
            UILabel *price = (UILabel*) [cell viewWithTag:12];
            index = [cellData.paraNames indexOfObject:@"monthly_rental"];
            
            value = [cellData.paraValues objectAtIndex:index];
            [price setText:[NSString stringWithFormat:@"S$ %@", value]];
            //psf
            index = [cellData.paraNames indexOfObject:@"psf"];
            value = [cellData.paraValues objectAtIndex:index];
            
            [price setText:[NSString stringWithFormat:@"%@ (S$ %@ psf)",price.text, value]];
            
            
            //lease_term_valuation_price (unit_level)
            UILabel *lease_term_valuation_price = (UILabel*) [cell viewWithTag:5];
            index = [cellData.paraNames indexOfObject:@"lease_term"];
            value = [cellData.paraValues objectAtIndex:index];
            
            //unit_level
            index = [cellData.paraNames indexOfObject:@"unit_level"];
            NSString *unit_level = [cellData.paraValues objectAtIndex:index];
            if (unit_level.length > 0) {
                value = [NSString stringWithFormat:@"%@ ( %@ )", value, unit_level];
            }
            [lease_term_valuation_price setText:value];
            //district
            UILabel *hdb_estate = (UILabel*) [cell viewWithTag:6];
            index = [cellData.paraNames indexOfObject:@"location"];
            value = [cellData.paraValues objectAtIndex:index];
            
            //furnishing
            index = [cellData.paraNames indexOfObject:@"furnishing"];
            NSString *furnishing = [cellData.paraValues objectAtIndex:index];
            if (! [furnishing isEqualToString:@""] ) {
                value = [value stringByAppendingFormat:@" ( %@ )", furnishing];
            }
            [hdb_estate setText:value];
            //size
            UILabel *size = (UILabel*) [cell viewWithTag:7];
            index = [cellData.paraNames indexOfObject:@"size"];
            value = [cellData.paraValues objectAtIndex:index];
            index = [cellData.paraNames indexOfObject:@"size_m"];
            NSString *size_m = [cellData.paraValues objectAtIndex:index];
            [size setText:[NSString stringWithFormat:@"%@ sqft / %@ sqm",value, size_m]];
            //building_completion
            UILabel *building_completion = (UILabel*) [cell viewWithTag:11];
            index = [cellData.paraNames indexOfObject:@"room_type"];
            value = [cellData.paraValues objectAtIndex:index];
            [building_completion setText:[NSString stringWithFormat:@"%@", value]];
            //bathroom icon
            UIImageView *imageViewBedroom = (UIImageView*)[cell viewWithTag:15];
            [imageViewBedroom setImage:[UIImage imageNamed:@"bathroom.png"]];
            imageViewBedroom.hidden = YES;
            //bedrooms
            UILabel *bedrooms = (UILabel*) [cell viewWithTag:8];
            index = [cellData.paraNames indexOfObject:@"attached_bathroom"];
            value = [cellData.paraValues objectAtIndex:index];
            [bedrooms setText:value];
            bedrooms.hidden = YES;
            //            //washroom
            UILabel *washroom = (UILabel*) [cell viewWithTag:9];
            washroom.hidden = YES;
            //            index = [cellData.paraNames indexOfObject:@"washroom"];
            //            value = [cellData.paraValues objectAtIndex:index];
            //            [washroom setText:value];
            UIImageView *imageViewWashroom = (UIImageView*)[cell viewWithTag:16];
            imageViewWashroom.hidden = YES;
            [imageViewWashroom setImage:[UIImage imageNamed:@"bathroom.png"]];
            if ([bedrooms.text isEqualToString:@"Yes"] || [bedrooms.text isEqualToString:@"YES"]) {
                imageViewBedroom.hidden = NO;
            }else
            {
                imageViewBedroom.hidden = YES;
            }
            //property_type
            UILabel *HDBType = (UILabel*) [cell viewWithTag:14];
            index = [cellData.paraNames indexOfObject:@"property_type"];
            value = [cellData.paraValues objectAtIndex:index];
            [HDBType setText:value];

            //totalView
            UILabel *total_views = (UILabel*) [cell viewWithTag:13];
            index = [cellData.paraNames indexOfObject:@"total_views"];
            value = [cellData.paraValues objectAtIndex:index];
            [total_views setText:[NSString stringWithFormat:@"Total Views: %@", value]];
            return cell;
            
        }
        
        if ((indexPath.section == 1)) {
            if ( ( indexPath.row == 0) ) {
                static NSString *CellIdentifier2 = @"HDBResultDetailCell2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
                if (cell == nil) {
                    
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier2 owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    topLevelObjects = nil;
                    [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                    cell.backgroundView = [[UIView alloc] init];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                NSInteger index;
                NSString *value;
                //avartar
                UIImageView *avatar = (UIImageView*)[cell viewWithTag:3];
                [avatar setImageWithURL:[NSURL URLWithString:cellData.userInfo.avatarUrl]];
                // posted user
                UILabel *user_posted = (UILabel*)[cell viewWithTag:4];
                [user_posted setText:cellData.userInfo.fullName];
                
                
                //ad_owner
                UILabel *ad_owner = (UILabel*)[cell viewWithTag:5];
                index = [cellData.paraNames indexOfObject:@"ad_owner"];
                value = [cellData.paraValues objectAtIndex:index];
                [ad_owner setText:value];
                
                //[self setClapCommentForCell:cell andData:cellData];
                return cell;
            }
            if (indexPath.row == 1) {
                //descritption
                //HDBResultDetailCell3
                static NSString *CellIdentifier3 = @"HDBResultDetailCell3";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
                if (cell == nil) {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier3 owner:self options:nil];
                    cell = [topLevelObjects objectAtIndex:0];
                    topLevelObjects = nil;
                    [cell setBackgroundColor:[UIColor colorWithRed:140.0/255 green:204.0/255 blue:211.0/255 alpha:1]];
                    cell.backgroundView = [[UIView alloc] init];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                
                NSInteger index;
                NSString *value;
                index = [cellData.paraNames indexOfObject:@"description"];
                value = [cellData.paraValues objectAtIndex:index];
                value = [NSData stringDecodeFromBase64String:value];
                UILabel *description = (UILabel*)[cell viewWithTag:2];
                [description setText:value];
                
                return cell;
            }
            
        }
#pragma mark _ . s = 2
        if (indexPath.section == 2) {
            static NSString *CellIdentifierVideos = @"CellVideos";
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifierVideos];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierVideos];
                cell.backgroundView = [[UIView alloc]init];
                cell.backgroundColor = tableView.backgroundColor;
                CGRect videoFrame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, 71);
                LinkPreview * linkView = [[LinkPreview alloc]initWithFrame:videoFrame];
                linkView.tag = 1;
                [cell addSubview:linkView];
                linkView.autoresizesSubviews = YES;
            }
            LinkPreview * linkView =  (LinkPreview *)[cell viewWithTag:1];
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (linkView && index != NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                [linkView loadContentWithFrame:linkView.frame LinkInfo:[videos objectAtIndex:indexPath.row] Type:linkPreviewTypeYoutube];
            }
            return cell;
        }
#pragma mark _ . s = 3
        if (indexPath.section == 3) {
            static NSString *CellIdentifierVideos = @"CellWebsites";
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifierVideos];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierVideos];
                cell.backgroundView = [[UIView alloc]init];
                cell.backgroundColor = tableView.backgroundColor;
                CGRect videoFrame = CGRectMake(10, 0, self.tableView.frame.size.width - 20, 71);
                LinkPreview * linkView = [[LinkPreview alloc]initWithFrame:videoFrame];
                linkView.tag = 1;
                [cell addSubview:linkView];
                linkView.autoresizesSubviews = YES;
            }
            LinkPreview * linkView =  (LinkPreview *)[cell viewWithTag:1];
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (linkView && index != NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                [linkView loadContentWithFrame:linkView.frame LinkInfo:[videos objectAtIndex:indexPath.row] Type:linkPreviewTypeWebSite];
            }
            return cell;
        }

        if (indexPath.section == 4) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_other_features objectAtIndex:indexPath.row];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
        if (indexPath.section == 5) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_amenities objectAtIndex:indexPath.row];
            return cell;
        }
        if (indexPath.section == 6) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.array_fixtures_fittings objectAtIndex:indexPath.row];
            return cell;
        }

        if (indexPath.section == 7) {
            static NSString *CellIdentifier2 = @"Cell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.imageView setImage:[UIImage imageNamed:@"accessoryView.png"]];
            [cell.textLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL]];
            cell.textLabel.text = [cellData.arry_restrictions objectAtIndex:indexPath.row];
            return cell;
        }

        if (indexPath.section == 8) {
            static NSString *CellIdentifier = @"UICommentCell";
            
            UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = nil;
                nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
                cell = (UITableViewCell *)[nib objectAtIndex:0];
                
            }
            CommentsCellContent *content = [listComments objectAtIndex:indexPath.row];
            //ImageView
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
            [imageView setImageWithURL:[NSURL URLWithString: content.userAvatarURL]];
            //Username
            UILabel *userName = (UILabel*)[cell viewWithTag:2];
            userName.text = content.userPostName;
            //text
            UILabel *text = (UILabel*)[cell viewWithTag:3];
            text.text = content.text;
            [text setNeedsDisplay];
            CGSize constraint = CGSizeMake(294 - 74, 20000.0f);
            CGSize size = [content.text sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = text.frame;
            frame.size = size;
            text.frame = frame;
            //    [text setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin ];
            //Create
            UILabel *created = (UILabel*)[cell viewWithTag:4];
            created.text = content.created;
            tableView.scrollEnabled = YES;
            
            cell.backgroundView = [[UIView alloc]initWithFrame:cell.bounds];
            return cell;
            
        }
    }

    return [[UITableViewCell alloc]init];
}


#pragma mark - Table view delegate

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 201;
            }
        }
        if (indexPath.section == 01) {
            if (indexPath.row == 0) {
                return 120;
            }
            if (indexPath.row == 1) {//description
                NSInteger index;
                NSString *value;
                index = [cellData.paraNames indexOfObject:@"description"];
                value = [cellData.paraValues objectAtIndex:index];
                value = [NSData stringDecodeFromBase64String:value];
                CGSize constraint = CGSizeMake(320 - 26, 20000.0f);
                CGSize size = [value sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                return size.height + 28;
            }
        }
        if (indexPath.section == 2 || indexPath.section == 3) {
            return linkHeight;
        }
        if (indexPath.section == 4 || indexPath.section == 5) {
            return cHeaderHeight;
        }
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 201;
            }
        }
        if (indexPath.section == 01) {
            if (indexPath.row == 0) {
                return 120;
            }
            if (indexPath.row == 1) {//description
                NSInteger index;
                NSString *value;
                index = [cellData.paraNames indexOfObject:@"description"];
                value = [cellData.paraValues objectAtIndex:index];
                value = [NSData stringDecodeFromBase64String:value];
                CGSize constraint = CGSizeMake(320 - 26, 20000.0f);
                CGSize size = [value sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                return size.height + 28;
            }
        }
        if (indexPath.section == 2 || indexPath.section == 3) {
            return linkHeight;
        }
        if (indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6) {
            return cHeaderHeight;
        }
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 201;
            }
        }
        if (indexPath.section == 01) {
            if (indexPath.row == 0) {
                return 120;
            }
            if (indexPath.row == 1) {//description
                NSInteger index;
                NSString *value;
                index = [cellData.paraNames indexOfObject:@"description"];
                value = [cellData.paraValues objectAtIndex:index];
                value = [NSData stringDecodeFromBase64String:value];
                CGSize constraint = CGSizeMake(320 - 26, 20000.0f);
                CGSize size = [value sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                return size.height + 28;
            }
        }
        if (indexPath.section == 2 || indexPath.section == 3) {
            return linkHeight;
        }
        if (indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6) {
            return cHeaderHeight;
        }
    }
    
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 201;
            }
        }
        if (indexPath.section == 01) {
            if (indexPath.row == 0) {
                return 120;
            }
            if (indexPath.row == 1) {//description
                NSInteger index;
                NSString *value;
                index = [cellData.paraNames indexOfObject:@"description"];
                value = [cellData.paraValues objectAtIndex:index];
                value = [NSData stringDecodeFromBase64String:value];
                CGSize constraint = CGSizeMake(320 - 26, 20000.0f);
                CGSize size = [value sizeWithFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
                return size.height + 28;
            }
        }
        if (indexPath.section == 2 || indexPath.section == 3) {
            return linkHeight;
        }
        if (indexPath.section == 4 || indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 7) {
            return cHeaderHeight;
        }
    }
    
    //commment size
    return [CommentsCellContent getCellHeighWithContent:[listComments objectAtIndex:indexPath.row] withWidth:294 - 74];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        if (section == 1) {
            if (_viewMode == modePreview) {
                return 1.0;
            }
            return CELL_COMMENTS_HEADER_HEIGHT;
        }
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return CELL_COMMENTS_HEADER_HEIGHT;
                }
            }
            return 01;
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return CELL_COMMENTS_HEADER_HEIGHT;
                }
            }
            return 01;
        }
        
        if (section == 4) {
            if (cellData.array_other_features.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
        if (section == 5) {
            if (cellData.array_fixtures_fittings.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        if (section == 1) {
            if (_viewMode == modePreview) {
                return 1.0;
            }
            return CELL_COMMENTS_HEADER_HEIGHT;
        }
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return CELL_COMMENTS_HEADER_HEIGHT;
                }
            }
            return 01;
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return CELL_COMMENTS_HEADER_HEIGHT;
                }
            }
            return 01;
        }
        if (section == 4) {
            if (cellData.array_other_features.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
        if (section == 5) {
            if (cellData.array_amenities.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
        if (section == 6) {
            if (cellData.array_fixtures_fittings.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        if (section == 1) {
            if (_viewMode == modePreview) {
                return 1.0;
            }
            return CELL_COMMENTS_HEADER_HEIGHT;
        }
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return CELL_COMMENTS_HEADER_HEIGHT;
                }
            }
            return 01;
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return CELL_COMMENTS_HEADER_HEIGHT;
                }
            }
            return 01;
        }
        if (section == 4) {
            if (cellData.array_other_features.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
        if (section == 5) {
            if (cellData.array_amenities.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
        if (section == 6) {
            if (cellData.array_fixtures_fittings.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
    }
    
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        if (section == 1) {
            if (_viewMode == modePreview) {
                return 1.0;
            }
            return CELL_COMMENTS_HEADER_HEIGHT;
        }
        if (section == 2) {
            if (cellData.array_other_features.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
        if (section == 2) {
            NSInteger index = [cellData.paraNames indexOfObject:@"videos"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return CELL_COMMENTS_HEADER_HEIGHT;
                }
            }
            return 01;
        }
        if (section == 3) {
            NSInteger index = [cellData.paraNames indexOfObject:@"websites"];
            if (index !=NSIntegerMax) {
                NSMutableArray *videos = [cellData.paraValues objectAtIndex:index];
                if ([videos isKindOfClass:[NSMutableArray class]] && videos.count) {
                    return CELL_COMMENTS_HEADER_HEIGHT;
                }
            }
            return 01;
        }
        if (section == 4) {
            if (cellData.array_other_features.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
        if (section == 5) {
            if (cellData.array_amenities.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
        if (section == 6) {
            if (cellData.array_fixtures_fittings.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
        if (section == 7) {
            if (cellData.arry_restrictions.count) {
                return CELL_COMMENTS_HEADER_HEIGHT;
            }else
                return 1.0;
        }
    }

    
    return 10.0;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 1) {
//        return 10.0;
//    }
//    return 1.0;
//}
#pragma mark - UITabBarDelegate

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item == currentItem) {
        return;
    }
    if ([item.title isEqualToString:@"Photos"]) {
        if (cellData.images.count <= 0) {
            [self.tabBar performSelector:@selector(setSelectedItem:) withObject:currentItem afterDelay:0.2];
            return;
        }
        
        
//        [UIView beginAnimations:@"View Flip" context:nil];
//        [UIView setAnimationDuration:0.80];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        
//        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
//                               forView:_scrollView cache:NO];
        
        SDWebImageDataSource *dataSource_ = [[SDWebImageDataSource alloc]initWithArray:cellData.images];
        KTPhotoScrollViewController *newController = [[KTPhotoScrollViewController alloc]
                                                      initWithDataSource:dataSource_
                                                      andStartWithPhotoAtIndex:0];
        [self.navigationController presentModalViewController:newController animated:YES];
        
//        [UIView commitAnimations];
        
        
    }else
    {
        currentItem = item;
        if ([item.title isEqualToString:@"Detail"]) {
            [UIView beginAnimations:@"View Flip" context:nil];
            [UIView setAnimationDuration:0.80];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                                   forView:_scrollView cache:NO];
            
            if (mapView) {
                [mapView.view removeFromSuperview];
            }
            if (streetView) {
                [streetView.view removeFromSuperview];
            }
            [UIView commitAnimations];
        }
        if ([item.title isEqualToString:@"Map"]) {
            //[hud showWhileExecuting:@selector(act_ShowMap:) onTarget:self withObject:self animated:YES];
            [self act_ShowMap:self];
//            if (streetView) {
//                [streetView.view removeFromSuperview];
//            }
        }
        if ([item.title isEqualToString:@"Street View"]) {
            [self act_ShowStreetView:self];
//            if (mapView) {
//                [mapView.view removeFromSuperview];
//            }
        }
    }
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
#pragma mark - MyMapviewControllerDelegate
- (void) callOutBtn_Clicked:(id)sender
{
    _tabBar.selectedItem = [_tabBar.items objectAtIndex:0];
    [self tabBar:_tabBar didSelectItem:[_tabBar.items objectAtIndex:0]];
}
#pragma mark - Handle Keyboard

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWilBeShown:(NSNotification*)aNotification
{
    NSLog(@"%f %f %f", _tableView.contentOffset.y, _tableView.frame.size.height, _tableView.contentSize.height);
    float v1 = _tableView.contentOffset.y + _tableView.frame.size.height;
    float v2 = _tableView.contentSize.height - cCellHeight;
    
    
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.scrollView convertRect:frame fromView:nil];
    CGPoint pt = CGPointZero;
    ((UIScrollView*)self.scrollView).scrollEnabled = YES;
    pt = CGPointMake(0.0, frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.03];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    frame = self.view.frame;
    frame.size.height -= pt.y;
    self.scrollView.frame = frame;
    
    
    [UIView commitAnimations];
    
    @try {
        if ( v1 >=  v2 ) {
            if (listComments.count > 0) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count -1 inSection:_tableView.numberOfSections - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@ scrollToRowAtIndexPath", [self class]);
    }
    @finally {
        
    }
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    frame = [self.scrollView convertRect:frame fromView:nil];
    CGPoint pt = CGPointZero;
    self.scrollView.scrollEnabled = YES;
    pt = CGPointMake(0.0, frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.03];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    frame = self.view.frame;
    //frame.size.height += pt.y;
    self.scrollView.frame = frame;
    
    
    [UIView commitAnimations];
    
}


#pragma mark - background function

- (void) loadDataInBackground
{
#pragma mark . Mode Preview
    if (_viewMode == modePreview) {
        [self convertDataForModePreviewAd];
        [self.tableView reloadData];
        //[self performSelectorInBackground:@selector(loadCommentsInBackground) withObject:nil];
    }
#pragma mark . Mode View Detail
    if (_viewMode == modeViewDetail) {
        //getHDBDetail($hdb_id, $user_id, $base64_image = false)
        id data;
        NSString *functionName;
        NSArray *paraNames;
        NSArray *paraValues;
        functionName = @"getHDBDetail";
        if ([self.itemName isEqualToString:@"Condos Search"]) {
            functionName = @"getCondosDetail";
        }
        if ([self.itemName isEqualToString:@"Landed Property Search"]) {
            functionName = @"getLandedDetail";
        }
        if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
            functionName = @"getRoomDetail";
        }

        paraNames = [NSArray arrayWithObjects:@"hdb_id", @"user_id", nil];
        paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", _hdbID], [NSString stringWithFormat:@"%d", _userID], nil];
        data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
        
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data];
        
        if (dict) {
            cellData = [[HBBResultCellData alloc]initWithItemName:self.itemName];
            cellData.hdbID = [[dict objectForKey:@"id"] integerValue];
            cellData.timeCreated = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
            //cellData.titleHDB = [dict objectForKey:@"address"];
            //        NSString *title = [dict objectForKey:@"street_name"];
            //        cellData.titleHDB = [cellData.titleHDB stringByAppendingString:title];
            
            //author
            NSDictionary *authorDict = [dict objectForKey:@"author"];
            cellData.userInfo = [[CredentialInfo alloc]init];
            if ([authorDict isKindOfClass:[NSDictionary class]]) {
                cellData.userInfo = [[CredentialInfo alloc]initWithDictionary:authorDict];
            }
            
            for (NSString *key in cellData.paraNames) {
                id object = [dict objectForKey:key];
                if (object != nil) {
                    [cellData.paraValues addObject: object];
                }else
                    [cellData.paraValues addObject:@""];
                
            }
            [cellData parseFixtures_fittingAndFeatures];
        }
        [self.tableView reloadData];
        [self performSelectorInBackground:@selector(loadCommentsInBackground) withObject:nil];
    }
#pragma mark . Mode Submit Ad
    if (_viewMode == modeSubmitAd) {
        id data;
        NSString *functionName;
        functionName = @"createHDB";
        if ([self.itemName isEqualToString:@"HDB Search"]) {
            functionName = @"createHDB";
        }
        
        if ([self.itemName isEqualToString:@"Condos Search"]) {
            functionName = @"createCondos";
        }

        if ([self.itemName isEqualToString:@"Landed Property Search"]) {
            functionName = @"createLanded";
        }
        
        if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
            functionName = @"createRoom";
        }
        
        data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:_paraNames parametterValue:_paraValues];
        
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data];
        if (dict.allKeys.count) {
            cellData = [[HBBResultCellData alloc]initWithItemName:self.itemName];
            cellData.hdbID = [[dict objectForKey:@"id"] integerValue];
            cellData.timeCreated = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
            //cellData.titleHDB = [dict objectForKey:@"address"];
            //        NSString *title = [dict objectForKey:@"street_name"];
            //        cellData.titleHDB = [cellData.titleHDB stringByAppendingString:title];
            
            //author
            NSDictionary *authorDict = [dict objectForKey:@"author"];
            cellData.userInfo = [[CredentialInfo alloc]init];
            if ([authorDict isKindOfClass:[NSDictionary class]]) {
                cellData.userInfo = [[CredentialInfo alloc]initWithDictionary:authorDict];
            }
            
            for (NSString *key in cellData.paraNames) {
                id object = [dict objectForKey:key];
                if (object != nil) {
                    [cellData.paraValues addObject: object];
                }else
                {
                    [cellData.paraValues addObject:@""];
                }
                
            }
            for (NSString *imageStr in _listImages) {
                [cellData.images addObject:[NSArray arrayWithObjects:imageStr, imageStr, nil]];
            }
            
            [cellData parseFixtures_fittingAndFeatures];
            [self performSelectorOnMainThread:@selector(uploadImagesToAd) withObject:nil waitUntilDone:NO];
        }else
        {
            
        }
        
        [self.tableView reloadData];
        [self performSelectorInBackground:@selector(loadCommentsInBackground) withObject:nil];
    }
}
- (void) uploadImagesToAd
{
    if (_listImages.count == 0) {
        return;
    }
    NSString *type = @"hdb";
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        type = @"hdb";
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        type = @"condos";
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        type = @"landed";
    }
    uploadImagesView.view.hidden = NO;
    uploadImagesView.postID = cellData.hdbID;
    uploadImagesView.listImageNeedToPost = [[NSArray alloc]initWithArray:_listImages];
    [uploadImagesView uploadtoAd:cellData.hdbID withListImages:_listImages andType:type];
}

- (void) loadCommentsInBackground
{
    //getHDBComments($hdb_id, $limit = 0, $comment_id = 0, $base64_image = false, $function = 'apps')
    //getCondosComments($condos_id, $limit = 0, $comment_id = 0, $base64_image = false, $function = 'search') 
    NSArray *data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    // actID
    functionName = @"getHDBComments";
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        functionName = @"getCondosComments";
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        functionName = @"getLandedComments";
    }
    
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        functionName = @"getRoomComments";
    }
    
    paraNames = [NSArray arrayWithObjects:@"hdb_id", @"limit", @"comment_id", @"base64_image", @"function", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", self.hdbID], @"0", @"0", @"0", @"iOS", nil];
    
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName: functionName parametterName:paraNames parametterValue:paraValues];
    listComments = [[NSMutableArray alloc] init ];
    for (NSDictionary *dict in data) {
        CommentsCellContent *content = [[CommentsCellContent alloc]init];
        content.commnetID = [[dict objectForKey:@"id"] integerValue];
        content.userAvatarURL = [NSData stringDecodeFromBase64String: [dict objectForKey:@"actor_thumb"]];
        content.userPostName = [dict objectForKey:@"actor_name"];
        content.text = [NSData stringDecodeFromBase64String:[dict objectForKey:@"content"]];
        content.created = [NSData stringDecodeFromBase64String:[dict objectForKey:@"created"]];
        content.userPostID = [[dict objectForKey:@"actor_id"] integerValue];
        [listComments addObject:content];
    }
    //[_tableView reloadData];
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

#pragma mark Mode Preview Ad

//createHDB($property_status, $block, $street_name, $property_type, $hdb_owner, $hdb_estate, $bedrooms, $washrooms, $price, $size, $valuation, $lease_term, $completion, $unit_level, $furnishing, $condition, $description, $other_features, $fixtures_fittings, $picture, $url, $video, $user_id, $limit, $base64_image = false)
- (void) convertDataForModePreviewAd
{
    NSArray *sourceParaNames = [NSArray arrayWithArray: _sourceForPreviewMode[0]];
    NSArray *sourceValues = [NSArray arrayWithArray:_sourceForPreviewMode[1]];
    NSInteger index = 0;
    id objectValue;
#pragma mark . HDB
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        cellData = [[HBBResultCellData alloc]initWithItemName:self.itemName];
        cellData.hdbID = 0;
        cellData.timeCreated = @"N/A";
        //            cellData.titleHDB = [dict objectForKey:@"address"];
        
        //author
        cellData.userInfo = [UserPAInfo sharedUserPAInfo];
        //                      @"id",
        [cellData.paraValues addObject:@"0"];
        //                      @"status",
        index = [sourceParaNames indexOfObject:@"property_status"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"block_no",
        index = [sourceParaNames indexOfObject:@"block"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"street_name",
        index = [sourceParaNames indexOfObject:@"street_name"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"property_type",
        index = [sourceParaNames indexOfObject:@"property_type"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"description",
        index = [sourceParaNames indexOfObject:@"description"];
        objectValue = [sourceValues objectAtIndex:index];
        objectValue = [NSData base64EncodedStringFromplainText:objectValue];
        [cellData.paraValues addObject:objectValue];
        //                      @"unit_level",
        index = [sourceParaNames indexOfObject:@"unit_level"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"hdb_estate",
        index = [sourceParaNames indexOfObject:@"hdb_estate"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"size",
        index = [sourceParaNames indexOfObject:@"size"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"bedrooms",
        index = [sourceParaNames indexOfObject:@"bedrooms"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"washroom",
        index = [sourceParaNames indexOfObject:@"washrooms"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"furnishing",
        index = [sourceParaNames indexOfObject:@"furnishing"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"building_completion",
        index = [sourceParaNames indexOfObject:@"completion"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"created",
        [cellData.paraValues addObject:@""];
        //                      @"price",
        index = [sourceParaNames indexOfObject:@"price"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"valuation_price",
        index = [sourceParaNames indexOfObject:@"valuation"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"monthly_rental",
        index = [sourceParaNames indexOfObject:@"price"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"lease_term",
        index = [sourceParaNames indexOfObject:@"lease_term"];
        objectValue = [SupportFunction stringFromShortYearMonthString:[sourceValues objectAtIndex:index]];
        [cellData.paraValues addObject: objectValue];
        //                      @"thumb",
        [cellData.paraValues addObject:[UserPAInfo sharedUserPAInfo].avatarUrl];
        //                      @"psf",
        index = [sourceParaNames indexOfObject:@"price"];
        objectValue = [sourceValues objectAtIndex:index];
        float price = [objectValue floatValue];
        index = [sourceParaNames indexOfObject:@"size"];
        objectValue = [sourceValues objectAtIndex:index];
        float size = [objectValue floatValue];
        
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *psftStr = [formatter stringFromNumber:[NSNumber numberWithFloat:price/size]];
        [cellData.paraValues addObject:psftStr];
        //                      @"ad_owner",
        index = [sourceParaNames indexOfObject:@"hdb_owner"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //                      @"total_comments",
        [cellData.paraValues addObject:@""];
        //                      @"clap_info",
        [cellData.paraValues addObject:@""];
        //                      @"total_views",
        [cellData.paraValues addObject:@"0"];
        //    @"other_features",
        index = [sourceParaNames indexOfObject:@"other_features"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //    @"fixtures_fittings",
        index = [sourceParaNames indexOfObject:@"fixtures_fittings"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //    @"images",
        [cellData.paraValues addObject:@""];
        //    @"videos",
        [cellData.paraValues addObject:@""];
        //    @"websites",
        [cellData.paraValues addObject:@""];
        
        //
        [cellData parseFixtures_fittingAndFeatures];
        
        //
        for (NSString *imageStr in _listImages) {
            [cellData.images addObject:[NSArray arrayWithObjects:imageStr, imageStr, nil]];
        }
    }
#pragma mark . Condos
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        cellData = [[HBBResultCellData alloc]initWithItemName:self.itemName];
        cellData.hdbID = 0;
        cellData.timeCreated = @"N/A";
        //author
        cellData.userInfo = [UserPAInfo sharedUserPAInfo];
//        @"max_id",
        [cellData.paraValues addObject:@"0"];
//        @"id",
        [cellData.paraValues addObject:@"0"];
//        @"status",
        index = [sourceParaNames indexOfObject:@"property_status"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"address",
        index = [sourceParaNames indexOfObject:@"address"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"description",
        index = [sourceParaNames indexOfObject:@"description"];
        objectValue = [sourceValues objectAtIndex:index];
        objectValue = [NSData base64EncodedStringFromplainText:objectValue];
        [cellData.paraValues addObject:objectValue];
//        @"project_name",
        index = [sourceParaNames indexOfObject:@"project_name"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"ad_owner",
        index = [sourceParaNames indexOfObject:@"ad_owner"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"unit_level",
        index = [sourceParaNames indexOfObject:@"unit_level"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"district",
        index = [sourceParaNames indexOfObject:@"district"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"tenure",
        index = [sourceParaNames indexOfObject:@"tenure"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"size",
        index = [sourceParaNames indexOfObject:@"size"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"size_m",
        index = [sourceParaNames indexOfObject:@"size"];
        objectValue = [sourceValues objectAtIndex:index];
        float size = [objectValue floatValue];
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *size_mStr = [formatter stringFromNumber:[NSNumber numberWithFloat:size * 0.092903]];
        [cellData.paraValues addObject:size_mStr];
//        @"bedrooms",
        index = [sourceParaNames indexOfObject:@"bedrooms"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"washroom",
        index = [sourceParaNames indexOfObject:@"washrooms"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"furnishing",
        index = [sourceParaNames indexOfObject:@"furnishing"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"other_features",
        index = [sourceParaNames indexOfObject:@"other_features"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"fixtures_fittings",
        index = [sourceParaNames indexOfObject:@"fixtures_fittings"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"building_completion",
        index = [sourceParaNames indexOfObject:@"completion"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"created",
        [cellData.paraValues addObject:@""];
//        @"price",
        index = [sourceParaNames indexOfObject:@"price"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"valuation_price",
        index = [sourceParaNames indexOfObject:@"valuation"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"monthly_rental",
        index = [sourceParaNames indexOfObject:@"price"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"psf",
        index = [sourceParaNames indexOfObject:@"price"];
        objectValue = [sourceValues objectAtIndex:index];
        float price = [objectValue floatValue];
        //index = [sourceParaNames indexOfObject:@"size"];
        //objectValue = [sourceValues objectAtIndex:index];
        //size = [objectValue floatValue];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *psftStr = [formatter stringFromNumber:[NSNumber numberWithFloat:price/size]];
        [cellData.paraValues addObject:psftStr];
//        @"lease_term",
        index = [sourceParaNames indexOfObject:@"lease_term"];
        objectValue = [SupportFunction stringFromShortYearMonthString:[sourceValues objectAtIndex:index]];
        [cellData.paraValues addObject: objectValue];
//        @"thumb",
        [cellData.paraValues addObject:[UserPAInfo sharedUserPAInfo].avatarUrl];
//        @"author",
        [cellData.paraValues addObject:[UserPAInfo sharedUserPAInfo]];
//        @"total_comments",
        [cellData.paraValues addObject:@""];
//        @"clap_info",
        [cellData.paraValues addObject:@""];
//        @"total_views",
        [cellData.paraValues addObject:@"0"];
//        @"images",
        [cellData.paraValues addObject:@""];
//        @"videos",
        [cellData.paraValues addObject:@""];
//        @"websites",
        [cellData.paraValues addObject:@""];
//        @"amenities",
        index = [sourceParaNames indexOfObject:@"amenities"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //
        [cellData parseFixtures_fittingAndFeatures];
        
        //
        for (NSString *imageStr in _listImages) {
            [cellData.images addObject:[NSArray arrayWithObjects:imageStr, imageStr, nil]];
        }
    }

#pragma mark . Landed Property
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        cellData = [[HBBResultCellData alloc]initWithItemName:self.itemName];
        cellData.hdbID = 0;
        cellData.timeCreated = @"N/A";
        //author
        cellData.userInfo = [UserPAInfo sharedUserPAInfo];
        //        @"max_id",
        [cellData.paraValues addObject:@"0"];
        //        @"id",
        [cellData.paraValues addObject:@"0"];
        //        @"status",
        index = [sourceParaNames indexOfObject:@"property_status"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"address",
        index = [sourceParaNames indexOfObject:@"address"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"description",
        index = [sourceParaNames indexOfObject:@"description"];
        objectValue = [sourceValues objectAtIndex:index];
        objectValue = [NSData base64EncodedStringFromplainText:objectValue];
        [cellData.paraValues addObject:objectValue];
        //        @"ad_owner",
        index = [sourceParaNames indexOfObject:@"ad_owner"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"district",
        index = [sourceParaNames indexOfObject:@"district"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"tenure",
        index = [sourceParaNames indexOfObject:@"tenure"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"size",
        index = [sourceParaNames indexOfObject:@"size"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"size_m",
        index = [sourceParaNames indexOfObject:@"size"];
        objectValue = [sourceValues objectAtIndex:index];
        float size = [objectValue floatValue];
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *size_mStr = [formatter stringFromNumber:[NSNumber numberWithFloat:size * 0.092903]];
        [cellData.paraValues addObject:size_mStr];
        //        @"bedrooms",
        index = [sourceParaNames indexOfObject:@"bedrooms"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"washroom",
        index = [sourceParaNames indexOfObject:@"washrooms"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"furnishing",
        index = [sourceParaNames indexOfObject:@"furnishing"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"other_features",
        index = [sourceParaNames indexOfObject:@"other_features"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"fixtures_fittings",
        index = [sourceParaNames indexOfObject:@"fixtures_fittings"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"building_completion",
        index = [sourceParaNames indexOfObject:@"completion"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"created",
        [cellData.paraValues addObject:@""];
        //        @"price",
        index = [sourceParaNames indexOfObject:@"price"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"valuation_price",
        index = [sourceParaNames indexOfObject:@"valuation"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"monthly_rental",
        index = [sourceParaNames indexOfObject:@"price"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //        @"psf",
        index = [sourceParaNames indexOfObject:@"price"];
        objectValue = [sourceValues objectAtIndex:index];
        float price = [objectValue floatValue];
        //index = [sourceParaNames indexOfObject:@"size"];
        //objectValue = [sourceValues objectAtIndex:index];
        //size = [objectValue floatValue];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *psftStr = [formatter stringFromNumber:[NSNumber numberWithFloat:price/size]];
        [cellData.paraValues addObject:psftStr];
        //        @"lease_term",
        index = [sourceParaNames indexOfObject:@"lease_term"];
        objectValue = [SupportFunction stringFromShortYearMonthString:[sourceValues objectAtIndex:index]];
        [cellData.paraValues addObject: objectValue];
        //        @"thumb",
        [cellData.paraValues addObject:[UserPAInfo sharedUserPAInfo].avatarUrl];
        //        @"author",
        [cellData.paraValues addObject:[UserPAInfo sharedUserPAInfo]];
        //        @"total_comments",
        [cellData.paraValues addObject:@""];
        //        @"clap_info",
        [cellData.paraValues addObject:@""];
        //        @"total_views",
        [cellData.paraValues addObject:@"0"];
        //        @"images",
        [cellData.paraValues addObject:@""];
        //        @"videos",
        [cellData.paraValues addObject:@""];
        //        @"websites",
        [cellData.paraValues addObject:@""];
        //        @"indoor_outdoors",
        index = [sourceParaNames indexOfObject:@"indoor_outdoors"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
        //
        [cellData parseFixtures_fittingAndFeatures];
        
        //
        for (NSString *imageStr in _listImages) {
            [cellData.images addObject:[NSArray arrayWithObjects:imageStr, imageStr, nil]];
        }
    }
#pragma mark . Rooms For Rent
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        cellData = [[HBBResultCellData alloc]initWithItemName:self.itemName];
        cellData.hdbID = 0;
        cellData.timeCreated = @"N/A";
        //author
        cellData.userInfo = [UserPAInfo sharedUserPAInfo];
//        @"max_id",
        [cellData.paraValues addObject:@"0"];
        //        @"id",
        [cellData.paraValues addObject:@"0"];
//        @"status",
        [cellData.paraValues addObject:@"r"];
//        @"address",
        index = [sourceParaNames indexOfObject:@"address"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"room_type",
        index = [sourceParaNames indexOfObject:@"room_type"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"attached_bathroom",
        index = [sourceParaNames indexOfObject:@"attached_bathroom"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"description",
        index = [sourceParaNames indexOfObject:@"description"];
        objectValue = [sourceValues objectAtIndex:index];
        objectValue = [NSData base64EncodedStringFromplainText:objectValue];
        [cellData.paraValues addObject:objectValue];
//        @"property_type",
        index = [sourceParaNames indexOfObject:@"property_type"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"ad_owner",
        index = [sourceParaNames indexOfObject:@"ad_owner"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"unit_level",
        index = [sourceParaNames indexOfObject:@"unit_level"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"location",
        index = [sourceParaNames indexOfObject:@"location"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"size",
        index = [sourceParaNames indexOfObject:@"size"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"size_m",
        index = [sourceParaNames indexOfObject:@"size"];
        objectValue = [sourceValues objectAtIndex:index];
        float size = [objectValue floatValue];
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *size_mStr = [formatter stringFromNumber:[NSNumber numberWithFloat:size * 0.092903]];
        [cellData.paraValues addObject:size_mStr];
//        @"furnishing",
        index = [sourceParaNames indexOfObject:@"furnishing"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"condition",
        index = [sourceParaNames indexOfObject:@"condition"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"special_features",
        index = [sourceParaNames indexOfObject:@"special_features"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"home_interior",
        index = [sourceParaNames indexOfObject:@"home_interior"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"amenities",
        index = [sourceParaNames indexOfObject:@"amenities"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"restrictions",
        index = [sourceParaNames indexOfObject:@"restrictions"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"created",
        [cellData.paraValues addObject:@""];
//        @"monthly_rental",
        index = [sourceParaNames indexOfObject:@"price"];
        [cellData.paraValues addObject:[sourceValues objectAtIndex:index]];
//        @"psf",
        index = [sourceParaNames indexOfObject:@"price"];
        objectValue = [sourceValues objectAtIndex:index];
        float price = [objectValue floatValue];
        //index = [sourceParaNames indexOfObject:@"size"];
        //objectValue = [sourceValues objectAtIndex:index];
        //size = [objectValue floatValue];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *psftStr = [formatter stringFromNumber:[NSNumber numberWithFloat:price/size]];
        [cellData.paraValues addObject:psftStr];
//        @"lease_term",
        index = [sourceParaNames indexOfObject:@"lease_term"];
        objectValue = [SupportFunction stringFromShortYearMonthString:[sourceValues objectAtIndex:index]];
        [cellData.paraValues addObject: objectValue];
//        @"thumb",
        [cellData.paraValues addObject:[UserPAInfo sharedUserPAInfo].avatarUrl];
        //        @"author",
        [cellData.paraValues addObject:[UserPAInfo sharedUserPAInfo]];
        //        @"total_comments",
        [cellData.paraValues addObject:@""];
        //        @"clap_info",
        [cellData.paraValues addObject:@""];
        //        @"total_views",
        [cellData.paraValues addObject:@"0"];
        //        @"images",
        [cellData.paraValues addObject:@""];
        //        @"videos",
        [cellData.paraValues addObject:@""];
        //        @"websites",
        [cellData.paraValues addObject:@""];
        
        [cellData parseFixtures_fittingAndFeatures];
        
        //
        for (NSString *imageStr in _listImages) {
            [cellData.images addObject:[NSArray arrayWithObjects:imageStr, imageStr, nil]];
        }
    }

}

#pragma mark -
- (void) addCell:(CommentsCellContent *) commentContent
{
    //insertStatusComment($user_id, $target_id, $content, $comment_type, $limit, $base64_image = false)
    
    
    if (listComments == nil) {
        listComments = [[NSMutableArray alloc] init ];
    }
//    actiCell._content.totalComment += 1;
//    [actiCell refreshClapCommentsView];
    [listComments addObject:commentContent];
    ////Comment
    NSInteger index = [cellData.paraNames indexOfObject:@"total_comments"];
    NSString *value = [NSString stringWithFormat:@"%d", listComments.count];
    [cellData.paraValues replaceObjectAtIndex:index withObject:value];
    
    [_tableView reloadData];
    @try {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count - 1 inSection:_tableView.numberOfSections -1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (IBAction)commentBtnClicked:(id)sender {
    if (_viewMode == modePreview) {
        return;
    }
    @try {
        if (listComments.count) {
            NSInteger section = self.tableView.numberOfSections;
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listComments.count - 1 inSection:section - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        [self performSelectorInBackground:@selector(loadCommentsInBackground) withObject:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: Try to scroll to bottom");
    }
    @finally {
        
    }
    
}

- (void)sendCommentWithText:(NSString*)str
{
    //  insertHDBComment($user_id, $hdb_id, $content, $limit, $base64_image = false)
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    functionName = @"insertHDBComment";
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        functionName = @"insertCondosComment";
    }
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        functionName = @"insertLandedComment";
    }
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        functionName = @"insertRoomComment";
    }
    paraNames = [NSArray arrayWithObjects:@"user_id", @"hdb_id", @"content", @"limit", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%d", self.hdbID], str, @"1", nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];
    @try {
        BOOL error_code = [[data objectForKey:@"error_code"] boolValue];
        if (!error_code) {
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        
    }
    
   
}

- (void) tapAction
{
    [_texbox resignFirstResponder];
}

- (void) insertClap
{
    // hdbClap($user_id, $hdb_id)
    
    id data;
    NSString *functionName;
    NSArray *paraNames;
    NSArray *paraValues;
    
    functionName = @"hdbClap";
    if ([self.itemName isEqualToString:@"HDB Search"]) {
        functionName = @"hdbClap";
    }
    if ([self.itemName isEqualToString:@"Condos Search"]) {
        functionName = @"condosClap";
    }
    
    if ([self.itemName isEqualToString:@"Landed Property Search"]) {
        functionName = @"landedClap";
    }
    
    if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
        functionName = @"roomClap";
    }
    paraNames = [NSArray arrayWithObjects:@"user_id", @"hdb_id", nil];
    paraValues = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", [UserPAInfo sharedUserPAInfo].registrationID], [NSString stringWithFormat:@"%d", self.hdbID], nil];
    data = [[PostadvertControllerV2 sharedPostadvertController] jsonObjectFromWebserviceWithFunctionName:functionName parametterName:paraNames parametterValue:paraValues];
    
    @try {
        NSInteger isClap = [[data objectForKey:@"clap"] integerValue];
        NSInteger totalClap = [[data objectForKey:@"total_clap"] integerValue];
        //Update clap
        
        NSInteger index = [cellData.paraNames indexOfObject:@"clap_info"];
        NSDictionary *clapInfo = [cellData.paraValues objectAtIndex:index];
        [clapInfo setValue:[NSString stringWithFormat:@"%d", totalClap] forKey:@"total_claps"];
        [clapInfo setValue:[NSString stringWithFormat:@"%d", isClap] forKey:@"is_clap"];
        [cellData.paraValues replaceObjectAtIndex:index withObject:clapInfo];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    [self.tableView reloadData];
    
}

- (void) clap_UnClapPost:(id)sender
{
    [self insertClap];
    UIButton *btn = (UIButton*)sender;
    btn.userInteractionEnabled = YES;
    [_tableView reloadData];
}

- (IBAction)clapBtnClicked:(id)sender {
    if (_viewMode == modePreview) {
        return;
    }
    UIButton *btn = (UIButton*)sender;
    btn.userInteractionEnabled = NO;
    [self performSelectorInBackground:@selector(clap_UnClapPost:) withObject:sender];
    
    //Update local
    
}

- (IBAction)btnSendClicked:(id)sender {
    CommentsCellContent *newComments = [[CommentsCellContent alloc]init];
    
    newComments.userPostName = [UserPAInfo sharedUserPAInfo].usernamePU;
    newComments.userAvatarURL = [UserPAInfo sharedUserPAInfo].avatarUrl;
    newComments.text = _texbox.text;
    newComments.created = @"Just now";
    newComments.userPostID = [UserPAInfo sharedUserPAInfo].registrationID;
    [self addCell:newComments];
    newComments = nil;
    
    [self performSelector:@selector(sendCommentWithText:) withObject:_texbox.text];
    [_texbox resignFirstResponder];
    _texbox.text = @"";
    
}
#pragma mark . Show Map
- (IBAction)act_ShowMap:(id)sender
{
    if (! listPlacemarks.count) {
        [mbpMap show:YES];
        NSInteger index;
        NSString *value;
        if ([self.itemName isEqualToString:@"HDB Search"]) {
            index = [cellData.paraNames indexOfObject:@"block_no"];
            value = [cellData.paraValues objectAtIndex:index];
            
            index = [cellData.paraNames indexOfObject:@"street_name"];
            value = [NSString stringWithFormat:@"%@ %@",value, [cellData.paraValues objectAtIndex:index]];
        }
        if ([self.itemName isEqualToString:@"Condos Search"]) {
            index = [cellData.paraNames indexOfObject:@"address"];
            value = [cellData.paraValues objectAtIndex:index];
        }
        
        if ([self.itemName isEqualToString:@"Landed Property Search"]) {
            index = [cellData.paraNames indexOfObject:@"address"];
            value = [cellData.paraValues objectAtIndex:index];
        }
        
        if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
            index = [cellData.paraNames indexOfObject:@"address"];
            value = [cellData.paraValues objectAtIndex:index];
        }
        [self getAllPlacemarksWithAddress:value andKey:@"act_ShowMap"];
    }
    else
    {
        
        [UIView beginAnimations:@"View Flip" context:nil];
        [UIView setAnimationDuration:0.80];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:_scrollView cache:NO];
        
        [self.scrollView addSubview:mapView.view];
        
        [UIView commitAnimations];
        if (! mapView.listPlacemarks.count) {
            mapView.listPlacemarks = listPlacemarks;
            [mapView centerMap];
        }
    }
        
}

- (void) getAllPlacemarksWithAddress:(NSString*)addressString andKey:(NSString*)key
{
//    NSMutableArray *_listPlacemarks = [[NSMutableArray alloc]init];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error)
        {
            NSLog(@"Geocode failed with error: %@", error);
//            [_listPlacemarks addObject:[NSNull null]];
            [self displayError:error];
            [mbpMap hide:YES];
            return ;
        }
        
        NSLog(@"Received placemarks: %@", placemarks);
        [self didReceivePlaceMarks:placemarks andKey:key];
    }];
}

- (void) didReceivePlaceMarks:(NSArray*) placemarks andKey:(NSString*)key
{
    listPlacemarks = [[NSMutableArray alloc]initWithArray:placemarks];
    if ([key isEqualToString:@"act_ShowMap"]) {
        mapView.listPlacemarks = listPlacemarks;
        
        [UIView beginAnimations:@"View Flip" context:nil];
        [UIView setAnimationDuration:0.80];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                               forView:_scrollView cache:NO];
        
        [self.scrollView addSubview:mapView.view];
        
        [UIView commitAnimations];
        
        [mbpMap hide:YES];
        [mapView centerMap];
    }
    if ([key isEqualToString:@"act_ShowStreetView"]) {
        streetView = [[NWViewLocationController alloc]initWithPlacemark:[listPlacemarks objectAtIndex:0]];
        CGRect frame = _scrollView.frame;
        frame.origin.y = 0;
        //frame.size.height -= _tabBar.frame.size.height;
        [streetView.view setFrame:frame];
        
        [UIView beginAnimations:@"View Flip" context:nil];
        [UIView setAnimationDuration:0.80];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:_scrollView cache:NO];
        
        [self.scrollView addSubview:streetView.view];
        
        [UIView commitAnimations];
        [mbpMap hide:YES];
    }
}

// display a given NSError in an UIAlertView
- (void)displayError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),^ {
        
        NSString *message;
        switch ([error code])
        {
            case kCLErrorGeocodeFoundNoResult:
                message = @"kCLErrorGeocodeFoundNoResult";
                break;
            case kCLErrorGeocodeCanceled:
                message = @"kCLErrorGeocodeCanceled";
                break;
            case kCLErrorGeocodeFoundPartialResult:
                message = @"kCLErrorGeocodeFoundNoResult";
                break;
            default:
                message = [error description];
                break;
        }
        
        message = @"Address not found";
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];;
        [alert show];
    });
}

#pragma mark . Street View
- (void) act_ShowStreetView:(id) sender
{
    if (! listPlacemarks.count) {
        [mbpMap show:YES];
        NSInteger index;
        NSString *value;
        if ([self.itemName isEqualToString:@"HDB Search"]) {
            index = [cellData.paraNames indexOfObject:@"block_no"];
            value = [cellData.paraValues objectAtIndex:index];
            
            index = [cellData.paraNames indexOfObject:@"street_name"];
            value = [NSString stringWithFormat:@"%@ %@",value, [cellData.paraValues objectAtIndex:index]];
        }
        if ([self.itemName isEqualToString:@"Condos Search"]) {
            index = [cellData.paraNames indexOfObject:@"address"];
            value = [cellData.paraValues objectAtIndex:index];
        }
        
        if ([self.itemName isEqualToString:@"Landed Property Search"]) {
            index = [cellData.paraNames indexOfObject:@"address"];
            value = [cellData.paraValues objectAtIndex:index];
        }
        
        if ([self.itemName isEqualToString:@"Rooms For Rent Search"]) {
            index = [cellData.paraNames indexOfObject:@"address"];
            value = [cellData.paraValues objectAtIndex:index];
        }
        [self getAllPlacemarksWithAddress:value andKey:@"act_ShowStreetView"];
    }
    else
    {
        if (! streetView) {
            streetView = [[NWViewLocationController alloc]initWithPlacemark:[listPlacemarks objectAtIndex:0]];
            CGRect frame = _scrollView.frame;
            frame.origin.y = 0;
            //frame.size.height -= _tabBar.frame.size.height;
            [streetView.view setFrame:frame];
        }
        [UIView beginAnimations:@"View Flip" context:nil];
        [UIView setAnimationDuration:0.80];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:_scrollView cache:NO];
        
        [self.scrollView addSubview:streetView.view];
        
        [UIView commitAnimations];
    }
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBtnSend:nil];
    [self setTexbox:nil];
    [self setScrollView:nil];
    [self setTabBar:nil];
    [super viewDidUnload];
}
@end
