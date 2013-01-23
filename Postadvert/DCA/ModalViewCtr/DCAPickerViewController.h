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
    pickerTypeSize = 2
};
typedef NSUInteger UIDCAPickerControllerSourceType;

@interface DCAPickerViewController :TDSemiModalViewController < UIPickerViewDataSource, UIPickerViewDelegate>
{
    
}

@property (nonatomic)                   NSInteger strartIndex;
@property (nonatomic)                   NSInteger endIndex;
@property (nonatomic, strong)           NSArray *intSource;
@property (nonatomic)                   UIDCAPickerControllerSourceType sourceType;
@property (weak, nonatomic) IBOutlet id delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeVtn;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

- (id) initWithDictionary:(NSDictionary*)dict andSourceType:(UIDCAPickerControllerSourceType) sourceType_;
- (id) initWithDictionary:(NSDictionary*)dict andSourceType:(UIDCAPickerControllerSourceType) sourceType_ startIndex:(NSInteger) strart endIndex:(NSInteger) endIndex;
- (id) initWithArray:(NSArray*)array andSourceType:(UIDCAPickerControllerSourceType) sourceType_ startIndex:(NSInteger) start endIndex:(NSInteger) endIndex;
- (IBAction)closeBtnClicked:(id)sender;
@end

@interface NSObject (DCAPickerViewController)
- (void) didPickerCloseWithControll:(DCAPickerViewController*) ctr;
- (void) didPickerCloseWithInfo:(NSDictionary*)dict;
@end