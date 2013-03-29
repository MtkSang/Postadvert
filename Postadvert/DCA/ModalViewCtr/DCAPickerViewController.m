//
//  DCAPickerViewController.m
//  Stroff
//
//  Created by Ray on 1/23/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "DCAPickerViewController.h"
#import "Constants.h"

@interface DCAPickerViewController ()

@end

@implementation DCAPickerViewController
- (id) initWithSourceType:(UIDCAPickerControllerSourceType)sourceType_
{
    self = [super init];
    if (self) {
        self.sourceType = sourceType_;
    }
    return self;
}
- (id) initWithArray:(NSArray*)array andSourceType:(UIDCAPickerControllerSourceType) sourceType_ startIndex:(NSInteger) start endIndex:(NSInteger) endIndex
{
    self = [super init];
    if (self) {
        self.sourceType = sourceType_;
        if (sourceType_ == pickerTypePrice || sourceType_ == pickerTypeBedrooms || sourceType_ == pickerTypeSize || sourceType_ == pickerTypeValnSize || sourceType_ == pickerTypeWashrooms || sourceType_ == pickerTypeConstructed || sourceType_ == pickerTypePSF) {
            _intSource = [NSArray arrayWithArray:array];
        }
        start += 1;
        if (start < 0) {
            start = 0;
        }
        if (endIndex > _intSource.count || endIndex < 0) {
            endIndex = _intSource.count;
        }
        self.strartIndex = start;
        self.endIndex = endIndex;
    }
    
    return self;
}

- (id) initWithDictionary:(NSDictionary*)dict andSourceType:(UIDCAPickerControllerSourceType) sourceType_ startIndex:(NSInteger) strart endIndex:(NSInteger) endIndex
{
    self = [self initWithDictionary:dict andSourceType:sourceType_];
    if (strart < 0) {
        strart = 0;
    }
    if (endIndex > _intSource.count || endIndex < 0) {
        endIndex = _intSource.count;
    }
    self.strartIndex = strart;
    self.endIndex = endIndex;
    
    return self;
}

- (id) initWithDictionary:(NSDictionary*)dict andSourceType:(UIDCAPickerControllerSourceType) sourceType_
{
    self = [super init];
    if (self) {
        self.sourceType = sourceType_;
        if (sourceType_ == pickerTypePrice) {
            if ([[dict objectForKey:@"Price"] isKindOfClass:[NSArray class]]) {
                _intSource = [NSArray arrayWithArray:[dict objectForKey:@"Price"]];
            }
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
    for (UIView* subview in self.picker.subviews) {
		subview.frame = self.picker.bounds;
	}
    
    [self.picker selectRow:self.strartIndex inComponent:0 animated:NO];
    [self.picker selectRow:self.endIndex inComponent:2 animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDelegate:nil];
    [self setCloseVtn:nil];
    [self setPicker:nil];
    [super viewDidUnload];
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Actions

- (IBAction)closeBtnClicked:(id)sender {
    if([self.delegate respondsToSelector:@selector(didPickerCloseWithControll:)]) {
		[self.delegate didPickerCloseWithControll:self];
	} else
    {
        // just dismiss the view automatically?
        [self dismissSemiModalViewController:self];
    }
}

#pragma mark -
#pragma mark UIPickerViewDataSource Protocol

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (self.sourceType) {
        case pickerTypeUnknow:
            return 0;
            break;
        case pickerTypePSF:
        case pickerTypeConstructed:
        case pickerTypeWashrooms:
        case pickerTypeValnSize:
        case pickerTypeSize:
        case pickerTypeBedrooms:
        case pickerTypePrice:
            return 3;
            break;
        case pickerTypeLeaseTerm:
            return 5;
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (self.sourceType) {

        case pickerTypeUnknow:
            return 0;
            break;
        case pickerTypePSF:
        case pickerTypeConstructed:
        case pickerTypeWashrooms:
        case pickerTypeValnSize:
        case pickerTypeSize:
        case pickerTypeBedrooms:
        case pickerTypePrice:
            if (component == 0 || component == 2) {
                return _intSource.count + 1;
            }
            
            return 1;
            break;
        case pickerTypeLeaseTerm:
            if (component == 0 || component == 3) {
                return 10;
            }
            if (component == 1 || component == 4) {
                return 12;
            }
            return 1;
        default:
            break;
    }
    return 0;
}

#pragma mark -
#pragma mark UIPickerViewDelegate Protocol
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (self.sourceType) {
        case pickerTypePSF:
        case pickerTypeConstructed:
        case pickerTypeWashrooms:
        case pickerTypeValnSize:
        case pickerTypeSize:
        case pickerTypeBedrooms:
        case pickerTypePrice:
            if (component == 1) {
                return 30;
            }
            return (pickerView.frame.size.width - 30) / 2.0;
            break;
        case pickerTypeLeaseTerm:
            if (component == 2) {
                return 30;
            }
            return (pickerView.frame.size.width - 30) / 4.0;
            
        default:
            break;
    }
    return pickerView.frame.size.width / ([pickerView numberOfComponents]);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger otherSelectedRow = 0;
    if (self.sourceType == pickerTypeLeaseTerm) {
        if (component == 0 || component == 3) {
            if (component == 0) {
                otherSelectedRow = [pickerView selectedRowInComponent:3];
            }
            if (component == 3) {
                otherSelectedRow = [pickerView selectedRowInComponent:0];
            }
            switch (component) {
                case 0:
                    self.strartIndex = row;
                    if (row > otherSelectedRow ) {
                        [pickerView selectRow:row inComponent:3 animated:YES];
                        self.endIndex = row;
                    }else
                        self.endIndex = otherSelectedRow;
                    
                    
                    break;
                case 1:
                    
                    break;
                    
                case 2:
                    self.strartIndex = otherSelectedRow;
                    if (otherSelectedRow >  row ) {
                        [pickerView selectRow:otherSelectedRow inComponent:3 animated:YES];
                        self.endIndex = otherSelectedRow ;
                    }else
                        self.endIndex = row;
                    
                    
                    break;
                    
                default:
                    break;
            }
        }
        if (component == 1 || component == 4) {
            NSInteger selectedYear1, selectedYear2;
            selectedYear1 = [pickerView selectedRowInComponent:0];
            selectedYear2 = [pickerView selectedRowInComponent:3];
            if (selectedYear1 == selectedYear2) {
                if ((row > otherSelectedRow) && component == 1) {
                    [pickerView selectRow:row inComponent:4 animated:YES];
                }
                if ((row < otherSelectedRow) && component == 4) {
                    [pickerView selectRow:otherSelectedRow inComponent:4 animated:YES];
                }
            }
        }
        
    }
    else
    {
        if (component == 0) {
            otherSelectedRow = [pickerView selectedRowInComponent:2];
        }
        if (component == 2) {
            otherSelectedRow = [pickerView selectedRowInComponent:0];
        }
        switch (component) {
            case 0:
                self.strartIndex = row;
                if (row > otherSelectedRow + 1) {
                    [pickerView selectRow:row -1 inComponent:2 animated:YES];
                    self.endIndex = row -1;
                }else
                    self.endIndex = otherSelectedRow;
                
                
                break;
            case 1:
                
                break;
                
            case 2:
                self.strartIndex = otherSelectedRow;
                if (otherSelectedRow >  row + 1) {
                    [pickerView selectRow:otherSelectedRow -1 inComponent:2 animated:YES];
                    self.endIndex = otherSelectedRow - 1;
                }else
                    self.endIndex = row;
                
                
                break;
                
            default:
                break;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title;
    NSInteger index = 0;
    switch (self.sourceType) {
        case pickerTypePSF:
        case pickerTypeConstructed:
        case pickerTypeWashrooms:
        case pickerTypeValnSize:
        case pickerTypeSize:
        case pickerTypeBedrooms:
        case pickerTypePrice:
            if (component == 1) {
                return @"to";
            }
            if (component == 0) {
                index = row -1;
            }else
                index = row;
            
            if (index < 0 || index >= _intSource.count) {
                title = @"Any";
            }else
                title = [_intSource objectAtIndex:index];
            break;
            
        default:
            title =@"";
            break;
    }
    
    
    
    return title;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
    if (!retval || ![retval isKindOfClass:[UILabel class]]) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width - 15, [pickerView rowSizeForComponent:component].height)];
        
        if (_sourceType == pickerTypeSize || _sourceType == pickerTypeValnSize)  {
            retval.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL];
        }
        retval.minimumFontSize = FONT_SIZE_SMALL;
        retval.backgroundColor = [UIColor clearColor];
    }
    
    //retval.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL];
    //set Title
    NSString *title;
    NSInteger index = 0;
    switch (self.sourceType) {
        case pickerTypePSF:
        case pickerTypeConstructed:
        case pickerTypeWashrooms:
        case pickerTypeValnSize:
        case pickerTypeSize:
        case pickerTypeBedrooms:
        case pickerTypePrice:
            if (component == 1) {
                title = @"to";
                [retval sizeToFit];
                retval.textAlignment = UITextAlignmentCenter;
                break;
            }
            retval.textAlignment = UITextAlignmentLeft;
            if (component == 0) {
                index = row -1;
            }else
                index = row;
            
            if (index < 0 || index >= _intSource.count) {
                title = @"Any";
            }else
                title = [_intSource objectAtIndex:index];
            break;
        case pickerTypeLeaseTerm:
            if (component == 2) {
                title = @"to";
                [retval sizeToFit];
                retval.textAlignment = UITextAlignmentCenter;
                break;
            }
            retval.textAlignment = UITextAlignmentLeft;
            if (row - 1 <0) {
                title = @"Any";
            }else
                title = [NSString stringWithFormat:@"%d", row -1];
            break;
            
        default:
            title =@"";
            break;
    }
    retval.text = title;
    return retval;
}
@end
