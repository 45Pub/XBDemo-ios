//
//  SettingEditingViewController.m
//  GoComIM
//
//  Created by Zhang Studyro on 13-4-26.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "SettingEditingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PPCore.h"
#import "UIButton+PPCategory.h"
#import "AppDelegate.h"
#import "UIHelper.h"
#define INDICATOR_WIDTH 30.0
#define INDICATOR_HEIGHT 20.0

@interface SettingEditingViewController ()
{
    CGFloat _fieldHeight;
}

//@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UILabel *numberIndicator;
@property (nonatomic, retain) UIButton *clearButton;
@property (nonatomic, copy) NSString *text;

@property (nonatomic, copy) EditingDoneBlock doneBlock;


@end

@implementation SettingEditingViewController

- (void)dealloc
{
	NSLog(@"dealloc");
    Block_release(_doneBlock);
    PP_RELEASE(_textView);
    PP_RELEASE(_numberIndicator);
    PP_RELEASE(_text);
    PP_RELEASE(_clearButton);
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)initWithTextFieldHeight:(CGFloat)height
                                   text:(NSString *)text
                       editingDoneBlock:(EditingDoneBlock)doneBlock
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _fieldHeight = height;
        _limitedEditingLength = 0;
        
        self.doneBlock = doneBlock;
        self.text = text;
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 20.0, 300.0, _fieldHeight)];
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
	
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.delegate = self;
    _textView.font = [UIFont systemFontOfSize:14.0];
    _textView.layer.masksToBounds = YES;
    _textView.layer.cornerRadius = 6.0;
    _textView.layer.borderWidth = 1.0;
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textView.text = self.text;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:self.textView];
    [self.textView becomeFirstResponder];
    
	//Add a lable show description
	if (self.descStr.length > 0)
	{
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont systemFontOfSize:10.f];
		label.textColor = [UIColor grayColor];
		label.text = self.descStr;
		
		CGSize size = [self.descStr sizeWithFont:label.font constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
		label.frame = CGRectMake((self.view.width - size.width)/2, _textView.bottom + 8, size.width, size.height);
		[self.view addSubview:label];
		[label release];
	}
	
	if (self.doneButtonStr.length > 0)
	{
		self.navigationItem.rightBarButtonItem = [UIHelper navBarButtonWithTitle:self.doneButtonStr target:self action:@selector(doneButtonClick:)];
		
	}
	
	
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    [self.view insertSubview:backgroundView atIndex:0];
    [backgroundView release];
    
    //self.navigationItem.leftBarButtonItem = [UIHelper navBackBarBtn:@"后退" target:self action:@selector(navigationBack:)];
}

- (void)doneButtonClick:(id)sender
{
	BOOL changed = YES;
	if ([self.text isEqualToString:self.textView.text])
	{
		changed = NO;
	}
	else
		[self.view endEditing:YES];

	if (self.doneBlock) {
		self.doneBlock(self, self.textView.text, changed);
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.textView removeFromSuperview];
    self.textView = nil;
    [self.clearButton removeFromSuperview];
    self.clearButton = nil;
    [self.numberIndicator removeFromSuperview];
    self.numberIndicator = nil;
    self.text = nil;
    self.doneBlock = nil;
}

- (void)setShowsCharNumberIndicator:(BOOL)showsCharNumberIndicator
{
    _showsCharNumberIndicator = showsCharNumberIndicator;
    
    [self view]; // make sure view is loaded.
    if (showsCharNumberIndicator && self.numberIndicator == nil) {
        _numberIndicator = [[UILabel alloc] initWithFrame:CGRectMake(300.0 - INDICATOR_WIDTH - 4.0, _fieldHeight - INDICATOR_HEIGHT, INDICATOR_WIDTH, INDICATOR_HEIGHT)];
        _numberIndicator.textAlignment = NSTextAlignmentRight;
        _numberIndicator.backgroundColor = [UIColor clearColor];
        _numberIndicator.font = [UIFont systemFontOfSize:14.5];
        [self.textView addSubview:self.numberIndicator];
        [self notifyNumberIndicatorWithNumber:self.limitedEditingLength - self.textView.text.length];
    }
    else {
        [self.numberIndicator removeFromSuperview];
        self.numberIndicator = nil;
    }
}

- (void)setShowsClearButton:(BOOL)showsClearButton
{
    _showsClearButton = showsClearButton;
    [self view]; // make sure view is loaded.
    
    if (showsClearButton && self.clearButton == nil) {
        self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.clearButton setImage:[UIImage imageNamed:@"search_clear"] forState:UIControlStateNormal];
        [self.clearButton addTarget:self action:@selector(clearButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.clearButton.center = CGPointMake(self.textView.width - 20.0, self.textView.height - 17.5);
        self.clearButton.bounds = CGRectMake(0.0, 0.0, 20.0, 20.0);
        
        [self.textView addSubview:self.clearButton];
    }
}

- (void)notifyNumberIndicatorWithNumber:(NSInteger)number
{
    self.numberIndicator.text = [NSString stringWithFormat:@"%d", number];
    
    if (number > 0) {
        self.numberIndicator.textColor = [UIColor darkGrayColor];
    }
    else {
        self.numberIndicator.textColor = [UIColor redColor];
    }
}

- (void)clearButtonTapped:(UIButton *)btn
{
    self.textView.text = @"";
    
    if (self.numberIndicator) {
        self.numberIndicator.text = [NSString stringWithFormat:@"%d", self.limitedEditingLength];
    }
    btn.hidden = YES;
}

#pragma mark - UITextFieldDelegate Methods

//- (BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
//    if (textView.text.length > self.limitedEditingLength && self.limitedEditingLength != 0) {
//        return NO;
//    }
//    
//    return YES;
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // receive ENTER
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
		BOOL changed = YES;
		if ([self.text isEqualToString:self.textView.text])
		{
			changed = NO;
		}
        if (self.doneBlock) {
            self.doneBlock(self, self.textView.text, changed);
        }
//        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
	else if(textView.text.length >= self.limitedEditingLength && self.limitedEditingLength != 0 && text.length != 0)
	{
		return NO;
	}
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self notifyNumberIndicatorWithNumber:self.limitedEditingLength - textView.text.length];
    
    if (textView.text.length > 0 && self.showsClearButton)
        self.clearButton.hidden = NO;
}

@end
