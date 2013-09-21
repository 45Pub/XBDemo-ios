//
//  SettingEditingViewController.h
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "GOBaseViewController.h"

typedef void (^EditingDoneBlock)(UIViewController *vc, NSString *newText, BOOL changed);

@interface SettingEditingViewController : GOBaseViewController <UITextViewDelegate>{
    
}
@property (nonatomic, retain) UITextView *textView;

@property (nonatomic, assign) NSUInteger limitedEditingLength;

@property (nonatomic, assign, getter = isCharNumberIndicatorShowing) BOOL showsCharNumberIndicator;

@property (nonatomic, assign) BOOL showsClearButton;

@property (nonatomic, copy) NSString *doneButtonStr;

@property (nonatomic, copy) NSString *descStr;

// self.title should be set before pushed to this view controller
- (instancetype)initWithTextFieldHeight:(CGFloat)height
                                   text:(NSString *)text
                       editingDoneBlock:(EditingDoneBlock)doneBlock;

@end
