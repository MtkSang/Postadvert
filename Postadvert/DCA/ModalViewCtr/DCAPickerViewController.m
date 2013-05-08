//
//  DCAPickerViewController.m
//  Stroff
//
//  Created by Ray on 1/23/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import "DCAPickerViewController.h"
#import "Constants.h"
#import "SupportFunction.h"

@interface DCAPickerViewController ()

@end

@implementation DCAPickerViewController
- (id) initWithSourceType:(UIDCAPickerControllerSourceType)sourceType_
{
    self = [super init];
    if (self) {
        self.sourceType = sourceType_;
        self.customValue = @"";
        _strartIndex = 0;
        _endIndex = 0;
    }
    return self;
}
- (id) initWithArray:(NSArray*)array andSourceType:(UIDCAPickerControllerSourceType) sourceType_ startIndex:(NSInteger) start endIndex:(NSInteger) endIndex
{
    self = [super init];
    if (self) {
        self.sourceType = sourceType_;
        if (sourceType_ == pickerTypePrice || sourceType_ == pickerTypeBedrooms || sourceType_ == pickerTypeSize || sourceType_ == pickerTypeValnSize || sourceType_ == pickerTypeWashrooms || sourceType_ == pickerTypeConstructed || sourceType_ == pickerTypePSF || sourceType_ == pickerTypeLeaseTerm) {
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

- (id) initWithDictionary:(NSDictionary*)dict andSourceType:(UIDCAPickerControllerSourceType) sourceType_ andValue:(NSString*)selectedValueStr
{
    self = [super init];
    if (self) {
        self.customValue = [selectedValueStr stringByReplacingOccurrencesOfString:@"," withString:@""];
        self.sourceType = sourceType_;
        if (sourceType_ == pickerTypeInputSizeSqft) {
            if ([[dict objectForKey:@"Size"] isKindOfClass:[NSArray class]]) {
                _intSource = [NSArray arrayWithArray:[dict objectForKey:@"Size"]];
            }
        }
        if (sourceType_ == pickerTypeInputSizeSqm) {
            if ([[dict objectForKey:@"SizeSqm"] isKindOfClass:[NSArray class]]) {
                _intSource = [NSArray arrayWithArray:[dict objectForKey:@"SizeSqm"]];
            }
        }
        if (sourceType_ == pickerTypeInputPrice) {
            if ([[dict objectForKey:@"Price"] isKindOfClass:[NSArray class]]) {
                _intSource = [NSArray arrayWithArray:[dict objectForKey:@"Price"]];
            }
        }
        if (sourceType_ == pickerTypeInputValuationPrice) {
            if ([[dict objectForKey:@"Price"] isKindOfClass:[NSArray class]]) {
                _intSource = [NSArray arrayWithArray:[dict objectForKey:@"Price"]];
            }
        }
        if (sourceType_ == pickerTypeInputMonthlyRental) {
            if ([[dict objectForKey:@"Price"] isKindOfClass:[NSArray class]]) {
                _intSource = [NSArray arrayWithArray:[dict objectForKey:@"Price"]];
            }
        }
        NSInteger selectedIndex_ = -1;
        selectedIndex_ = [_intSource indexOfObject:selectedValueStr];
        if (selectedIndex_ == NSIntegerMax) {
            selectedIndex_ = 0;
        }
        self.strartIndex = selectedIndex_;
        self.endIndex = selectedIndex_;
    }
    
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
    if (self.strartIndex>=0) {
        [self.picker selectRow:self.strartIndex inComponent:0 animated:NO];
    }
    if (self.endIndex>=0 && self.picker.numberOfComponents >=3) {
        [self.picker selectRow:self.endIndex inComponent:2 animated:NO];
    }
    
    self.picker.showsSelectionIndicator = YES;
    
    //
    textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 255, 30)];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setClearButtonMode:UITextFieldViewModeAlways];
    [textField addTarget:self
                  action:@selector(onEventEditingChanged:)
        forControlEvents:UIControlEventEditingChanged];
    [textField setDelegate:self];
    UIBarButtonItem *barBtnItemTextField = [[UIBarButtonItem alloc] initWithCustomView:textField];
    [barBtnItemTextField setStyle:UIBarButtonItemStyleBordered];
    btnValidate = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    [btnValidate addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnValidate setImage:[UIImage imageNamed:@"hdb_post_validate_normal.png"] forState:UIControlStateNormal];
    UIBarButtonItem *barBtnItemValidate = [[UIBarButtonItem alloc]initWithCustomView:btnValidate];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    [self.toolbar setItems:[NSArray arrayWithObjects:barBtnItemTextField, spaceItem, barBtnItemValidate, nil] animated:YES];
    
    //Set Show/hide textField
    if (self.sourceType == pickerTypeInputSizeSqft || _sourceType == pickerTypeInputSizeSqm || _sourceType == pickerTypeInputPrice || _sourceType == pickerTypeInputValuationPrice || _sourceType == pickerTypeInputMonthlyRental) {
        showInputText = YES;
        textField.text = self.customValue;
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
    }
    if (showInputText) {
        [textField setHidden:NO];
    }else
    {
        [textField setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDelegate:nil];
    [self setPicker:nil];
    [self setToolbar:nil];
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
    BOOL isFirstReponder = [textField isFirstResponder];
    if (isFirstReponder) {
        [textField resignFirstResponder];
    }
    if (isFirstReponder) {
        self.customValue = textField.text;
        [self.picker selectRow:0 inComponent:0 animated:NO];
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(didPickerCloseWithControll:)]) {
        if (_sourceType == pickerTypeInputSizeSqft || _sourceType == pickerTypeInputSizeSqm) {
            if ([_picker selectedRowInComponent:0] != 0) {
                NSArray *array = [textField.text componentsSeparatedByString:@" "];
                self.customValue = array[0];
            }
        }
        if (_sourceType == pickerTypeInputPrice || _sourceType == pickerTypeInputValuationPrice || _sourceType == pickerTypeInputMonthlyRental) {
            if ([_picker selectedRowInComponent:0] != 0) {
                NSArray *array = [textField.text componentsSeparatedByString:@" "];
                self.customValue = array[1];
            }
        }
		[self.delegate didPickerCloseWithControll:self];
	} else
    {
        // just dismiss the view automatically?
        [self dismissSemiModalViewController:self];
    }
}


#pragma mark -
#pragma mark - UItextfiled Delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField_
{
    textField.text = self.customValue;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:btnValidate cache:YES];
    [btnValidate setImage:[UIImage imageNamed:@"hdb_post_go_normal.png"] forState:UIControlStateNormal];
    [UIView commitAnimations];
}

- (void) textFieldDidEndEditing:(UITextField *)textField_
{
    [textField_ resignFirstResponder];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:btnValidate cache:YES];
    [btnValidate setImage:[UIImage imageNamed:@"hdb_post_validate_normal.png"] forState:UIControlStateNormal];
    [UIView commitAnimations];
}

- (void)onEventEditingChanged:(id)sender
{

}
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
            return 3;
            break;
        case pickerTypeInputLeaseTerm:
            return 2;
            break;
        case pickerTypeInputSizeSqft:
        case pickerTypeInputSizeSqm:
        case pickerTypeInputPrice:
        case pickerTypeInputValuationPrice:
        case pickerTypeInputMonthlyRental:
            return 1;
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
        case pickerTypeLeaseTerm:
            if (component == 0 || component == 2) {
                return _intSource.count + 1;
            }
            
            return 1;
            break;
        case pickerTypeInputLeaseTerm:
            if (component == 0) {
                return 10;
            }
            if (component == 1) {
                return 12;
            }
            return 1;
            break;
        case pickerTypeInputSizeSqft:
        case pickerTypeInputSizeSqm:
        case pickerTypeInputPrice:
        case pickerTypeInputValuationPrice:
        case pickerTypeInputMonthlyRental:
            return _intSource.count + 1;
            break;
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
        case pickerTypeLeaseTerm:
            if (component == 1) {
                return 30;
            }
            return (pickerView.frame.size.width - 40) / 2.0;
            break;
        case pickerTypeInputLeaseTerm:
            return (pickerView.frame.size.width - 20) / 2.0;
        case pickerTypeInputSizeSqft:
        case pickerTypeInputSizeSqm:
        case pickerTypeInputPrice:
        case pickerTypeInputValuationPrice:
        case pickerTypeInputMonthlyRental:
            return pickerView.frame.size.width - 20;
            break;
        default:
            break;
    }
    return pickerView.frame.size.width / ([pickerView numberOfComponents]);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger otherSelectedRow = 0;
//    if (self.sourceType == pickerTypeLeaseTerm) {
//        if (component == 0 || component == 3) {
//            if (component == 0) {
//                otherSelectedRow = [pickerView selectedRowInComponent:3];
//            }
//            if (component == 3) {
//                otherSelectedRow = [pickerView selectedRowInComponent:0];
//            }
//            switch (component) {
//                case 0:
//                    self.strartIndex = row;
//                    if (row > otherSelectedRow ) {
//                        [pickerView selectRow:row inComponent:3 animated:YES];
//                        self.endIndex = row;
//                    }else
//                        self.endIndex = otherSelectedRow;
//                    
//                    
//                    break;
//                case 1:
//                    
//                    break;
//                    
//                case 2:
//                    self.strartIndex = otherSelectedRow;
//                    if (otherSelectedRow >  row ) {
//                        [pickerView selectRow:otherSelectedRow inComponent:3 animated:YES];
//                        self.endIndex = otherSelectedRow ;
//                    }else
//                        self.endIndex = row;
//                    
//                    
//                    break;
//                    
//                default:
//                    break;
//            }
//        }
//        if (component == 1 || component == 4) {
//            NSInteger selectedYear1, selectedYear2;
//            selectedYear1 = [pickerView selectedRowInComponent:0];
//            selectedYear2 = [pickerView selectedRowInComponent:3];
//            if (selectedYear1 == selectedYear2) {
//                if ((row > otherSelectedRow) && component == 1) {
//                    [pickerView selectRow:row inComponent:4 animated:YES];
//                }
//                if ((row < otherSelectedRow) && component == 4) {
//                    [pickerView selectRow:otherSelectedRow inComponent:4 animated:YES];
//                }
//            }
//        }
//        
//    }
 //   else
    if (_sourceType == pickerTypeInputLeaseTerm) {
        _customValue = [SupportFunction stringFromYears:[pickerView selectedRowInComponent:0] andMonths:[pickerView selectedRowInComponent:1]];
        return;
    }
    if (pickerView.numberOfComponents == 1) {
        _endIndex = [pickerView selectedRowInComponent:0];
        if (_endIndex < 1) {
            [textField setText:self.customValue];
            [textField becomeFirstResponder];
        }else
        {
            textField.text = [_intSource objectAtIndex:_endIndex - 1];
        }
        
        return;
    }
    
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

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSString *title;
//    NSInteger index = 0;
//    switch (self.sourceType) {
//        case pickerTypePSF:
//        case pickerTypeConstructed:
//        case pickerTypeWashrooms:
//        case pickerTypeValnSize:
//        case pickerTypeSize:
//        case pickerTypeBedrooms:
//        case pickerTypePrice:
//            if (component == 1) {
//                return @"to";
//            }
//            if (component == 0) {
//                index = row -1;
//            }else
//                index = row;
//            
//            if (index < 0 || index >= _intSource.count) {
//                title = @"Any";
//            }else
//                title = [_intSource objectAtIndex:index];
//            break;
//        case pickerTypeInputSizeSqft:
//            if (row < 0 || row >= _intSource.count) {
//                title = @"Any";
//            }else
//                title = [_intSource objectAtIndex:row];
//            break;
//        default:
//            title =@"";
//            break;
//    }
//    
//    
//    
//    return title;
//}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
    if (!retval || ![retval isKindOfClass:[UILabel class]]) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width - 15, [pickerView rowSizeForComponent:component].height)];
        
        if (_sourceType == pickerTypeSize || _sourceType == pickerTypeValnSize)  {
            retval.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_SMALL];
        }
        retval.minimumFontSize = FONT_SIZE_SMALL - 2;
        retval.backgroundColor = [UIColor clearColor];
    }
    [retval setTextColor:[UIColor blackColor]];
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
        case pickerTypeLeaseTerm:
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
                [retval setTextColor:[UIColor blueColor]];
            }else
                title = [_intSource objectAtIndex:index];
            break;
        case pickerTypeInputLeaseTerm:
            if (component == 0) {
                if (row == 0) {
                    title = @"";
                }
                if (row == 1) {
                    title = @"1 Year";
                }
                if (row > 1) {
                    title = [NSString stringWithFormat:@"%d Years", row];
                }
                retval.textAlignment = UITextAlignmentCenter;
                break;
            }
            if (component == 1) {
                if (row == 0) {
                    title = @"";
                }
                if (row == 1) {
                    title = @"1 Month";
                }
                if (row > 1) {
                    title = [NSString stringWithFormat:@"%d Months", row];
                }
                retval.textAlignment = UITextAlignmentCenter;
                break;
            }
            //retval.textAlignment = UITextAlignmentLeft;
            [retval sizeToFit];
            break;

        case pickerTypeInputSizeSqft:
        case pickerTypeInputSizeSqm:
        case pickerTypeInputPrice:
        case pickerTypeInputValuationPrice:
        case pickerTypeInputMonthlyRental:
            retval.textAlignment = UITextAlignmentLeft;
            if (component == 0) {
                index = row -1;
            }else
                index = row;
            
            if (index < 0 || index >= _intSource.count) {
                title = @"Custom";
                [retval setTextColor:[UIColor blueColor]];
            }else
                title = [_intSource objectAtIndex:index];
            break;
        default:
            title =@"";
            break;
    }
    retval.text = title;
    return retval;
}
@end
