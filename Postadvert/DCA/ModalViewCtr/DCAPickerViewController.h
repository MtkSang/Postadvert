//
//  DCAPickerViewController.h
//  Stroff
//
//  Created by Ray on 1/23/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSemiModal.h"

enum pickerType {
    pickerTypeUnknow = 0,
    pickerTypePrice = 1,
    pickerTypeSize = 2,
    pickerTypeBedrooms = 3,
    pickerTypeValnSize = 4,
    pickerTypeWashrooms = 5,
    pickerTypeConstructed = 6,
    pickerTypePSF = 7,
    pickerTypeLeaseTerm = 8,
    pickerTypeInputSizeSqft = 9,
    pickerTypeInputSizeSqm = 10,
    pickerTypeInputPrice = 11,
    pickerTypeInputValuationPrice = 12,
    pickerTypeInputMonthlyRental = 13,
    pickerTypeInputLeaseTerm = 14,
    pickerTypeFloorSize = 15
    
};
typedef NSUInteger UIDCAPickerControllerSourceType;

@interface DCAPickerViewController :TDSemiModalViewController < UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    BOOL showInputText;
    UITextField *textField;
    UIButton *btnValidate;
}

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic)                   NSInteger strartIndex;
@property (nonatomic)                   NSInteger endIndex;
@property (nonatomic, strong)           NSArray *intSource;
@property (nonatomic, strong)           NSString *customValue;
@property (nonatomic)                   UIDCAPickerControllerSourceType sourceType;
@property (weak, nonatomic) IBOutlet id delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
- (id) initWithSourceType:(UIDCAPickerControllerSourceType) sourceType_;
- (id) initWithDictionary:(NSDictionary*)dict andSourceType:(UIDCAPickerControllerSourceType) sourceType_ andValue:(NSString*)selectedValueStr;
- (id) initWithDictionary:(NSDictionary*)dict andSourceType:(UIDCAPickerControllerSourceType) sourceType_;
- (id) initWithDictionary:(NSDictionary*)dict andSourceType:(UIDCAPickerControllerSourceType) sourceType_ startIndex:(NSInteger) strart endIndex:(NSInteger) endIndex;
- (id) initWithArray:(NSArray*)array andSourceType:(UIDCAPickerControllerSourceType) sourceType_ startIndex:(NSInteger) start endIndex:(NSInteger) endIndex;
- (IBAction)closeBtnClicked:(id)sender;
@end

@interface NSObject (DCAPickerViewController)
- (void) didPickerCloseWithControll:(DCAPickerViewController*) ctr;
- (void) didPickerCloseWithInfo:(NSDictionary*)dict;
@end