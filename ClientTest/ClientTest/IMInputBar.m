//
//  IMInputBar.m
//  IMCommon
//
//  Created by 王鹏 on 13-1-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMInputBar.h"
#import "PPCore.h"
#import "UIView+PPCategory.h"
#import "AssembleeMsgTool.h"
static inline UIViewAnimationOptions AnimationOptionsForCurve(UIViewAnimationCurve curve)
{
	switch (curve) {
		case UIViewAnimationCurveEaseInOut:
			return UIViewAnimationOptionCurveEaseInOut;
			break;
		case UIViewAnimationCurveEaseIn:
			return UIViewAnimationOptionCurveEaseIn;
			break;
		case UIViewAnimationCurveEaseOut:
			return UIViewAnimationOptionCurveEaseOut;
			break;
		case UIViewAnimationCurveLinear:
			return UIViewAnimationOptionCurveLinear;
			break;
			
		default:
			return UIViewAnimationOptionCurveEaseInOut;
			break;
	}
}
@interface IMInputBar()
@property (nonatomic, copy) NSString *lastStr;
@property (nonatomic) BOOL isCancel;
@end

@implementation IMInputBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		UIImage *rawBackground = [UIImage imageNamed:@"msg_bar_bg.png"];
        UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:4 topCapHeight:22];
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:background] autorelease];
        imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
		
		_textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(50, 5, 193, 30)];
        _textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _textView.minNumberOfLines = 1;
        _textView.maxNumberOfLines = 6;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.font = [UIFont systemFontOfSize:15.0f];
        _textView.delegate = self;
        _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_textView];
		
		UIImage *rawEntryBackground = [UIImage imageNamed:@"msg_bar_input.png"];
        UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:12 topCapHeight:22];
        UIImageView *entryImageView = [[[UIImageView alloc] initWithImage:entryBackground] autorelease];
        entryImageView.frame = CGRectMake(48, 0, 195, 44);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:entryImageView];
		
		_atSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[_atSwitchBtn setImage:[UIImage imageNamed:@"msg_bar_text.png"] forState:UIControlStateNormal];
        _atSwitchBtn.frame = CGRectMake(0, 0, 48, 44);
        [_atSwitchBtn addTarget:self action:@selector(atSwitchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_atSwitchBtn];
        _atSwitchBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		
		
		_audioBtn = [TalkButton  buttonWithType:UIButtonTypeCustom];
        _audioBtn.adjustsImageWhenDisabled = NO;
        [_audioBtn  setBackgroundImage:[UIImage imageNamed:@"msg_bar_talking.png"] forState:UIControlStateNormal];
//        [_audioBtn setImage:[UIImage imageNamed:@"inputAudiobtnDisable.png"] forState:UIControlStateDisabled];
        _audioBtn.frame = CGRectMake(48, 0, 195, 44);
        _audioBtn.hidden = NO;
        //        [audioBtn setTitle:@"录音" forState:UIControlStateNormal];
        [_audioBtn addTarget:self action:@selector(audioBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_audioBtn addTarget:self action:@selector(audioBtnTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [_audioBtn addTarget:self action:@selector(audioBtnTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [_audioBtn addTarget:self action:@selector(audioBtnTouchUp:) forControlEvents:UIControlEventTouchCancel];
        [self addSubview:_audioBtn];
		
		
		_faceBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        _faceBtn.frame = CGRectMake(245, 0, 40, 44);
        [_faceBtn setImage:[UIImage imageNamed:@"msg_bar_emotion.png"] forState:UIControlStateNormal];
        _faceBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_faceBtn addTarget:self action:@selector(faceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_faceBtn];
		
		_menuBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        _menuBtn.frame = CGRectMake(_faceBtn.right, 0, 35, 44);
        [_menuBtn setImage:[UIImage imageNamed:@"msg_bar_more.png"] forState:UIControlStateNormal];
        _menuBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_menuBtn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_menuBtn];
		
		
		self.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		_barType = IMInputTypeAudio;
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
     
		[nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//		[nc addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//		[nc addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
		self.limitWordsNum = 0;
		
    }
    return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_textView release];
	[_lastStr release];
	[super dealloc];
}

- (void)changeToAudioType
{
	if(_barType == IMInputTypeAudio)
	{
		return;
	}
	else
	{
		self.lastStr = _textView.text;
		_textView.text = nil;
		
		if(_barType == IMInputTypeText)
		{
			_barType = IMInputTypeAudio;
			[_textView resignFirstResponder];
			[_atSwitchBtn setImage:[UIImage imageNamed:@"msg_bar_text.png"] forState:UIControlStateNormal];
			_audioBtn.hidden = NO;
			if([_delegate respondsToSelector:@selector(iminputBarHideFaceViewAndMenuView)])
			{
				[_delegate iminputBarHideFaceViewAndMenuView];
			}
		}
		else
		{
			_barType = IMInputTypeAudio;
			[_atSwitchBtn setImage:[UIImage imageNamed:@"msg_bar_text.png"] forState:UIControlStateNormal];
			_audioBtn.hidden = NO;
			if([_delegate respondsToSelector:@selector(iminputBarHideFaceViewAndMenuView)])
			{
				[_delegate iminputBarHideFaceViewAndMenuView];
			}
		}
	}
}

- (void)changeToTextType
{
	_barType = IMInputTypeText;
	if([_delegate respondsToSelector:@selector(iminputBarHideFaceViewAndMenuView)])
	{
		[_delegate iminputBarHideFaceViewAndMenuView];
	}
	[_textView resignFirstResponder];
	[self showTextEdit];
}

- (void)atSwitchBtnClick:(id)sender
{
	if(_barType == IMInputTypeAudio)
	{
		_barType = IMInputTypeText;
		_textView.text = self.lastStr;
		[_textView becomeFirstResponder];
	}
	else
	{
		self.lastStr = _textView.text;
		_textView.text = nil;
		
		if(_barType == IMInputTypeText)
		{
			_barType = IMInputTypeAudio;
			[_textView resignFirstResponder];
			[_atSwitchBtn setImage:[UIImage imageNamed:@"msg_bar_text.png"] forState:UIControlStateNormal];
			_audioBtn.hidden = NO;
			if([_delegate respondsToSelector:@selector(iminputBarHideFaceViewAndMenuView)])
			{
				[_delegate iminputBarHideFaceViewAndMenuView];
			}
		}
		else
		{
			_barType = IMInputTypeAudio;
			[_atSwitchBtn setImage:[UIImage imageNamed:@"msg_bar_text.png"] forState:UIControlStateNormal];
			_audioBtn.hidden = NO;
			if([_delegate respondsToSelector:@selector(iminputBarHideFaceViewAndMenuView)])
			{
				[_delegate iminputBarHideFaceViewAndMenuView];
			}
		}
	}
}

- (void)showTextEdit
{
//	_textView.text = self.lastStr;
	
	[_atSwitchBtn setImage:[UIImage imageNamed:@"msg_bar_voice.png"] forState:UIControlStateNormal];
	_audioBtn.hidden = YES;
}

- (void)faceBtnClick:(id)sender
{
	if(_barType == IMInputTypeFace)
	{
		_barType = IMInputTypeText;
		[_textView becomeFirstResponder];
		return;
	}

	
	if(_barType == IMInputTypeText)
	{
		_barType = IMInputTypeFace;
		[_textView resignFirstResponder];
		if([_delegate respondsToSelector:@selector(iminputBarShowFaceView)])
		{
			[_delegate iminputBarShowFaceView];
		}
	}
	else if(_barType == IMInputTypeMenu)
	{
		[self showTextEdit];
		_barType = IMInputTypeFace;
		if([_delegate respondsToSelector:@selector(iminputBarShowFaceView)])
		{
			[_delegate iminputBarShowFaceView];
		}
	}
	else if(_barType == IMInputTypeAudio)
	{
		[self showTextEdit];

		_barType = IMInputTypeFace;
		if([_delegate respondsToSelector:@selector(iminputBarShowFaceView)])
		{
			[_delegate iminputBarShowFaceView];
		}
	}
}

- (void)menuBtnClick:(id)sender
{
	if(_barType == IMInputTypeMenu)
	{
		_barType = IMInputTypeText;
		[_textView becomeFirstResponder];
		return;
	}
	
	
	if(_barType == IMInputTypeText)
	{
		_barType = IMInputTypeMenu;
		[_textView resignFirstResponder];
		if([_delegate respondsToSelector:@selector(iminputBarHideFaceViewAndShowMenuView)])
		{
			[_delegate iminputBarHideFaceViewAndShowMenuView];
		}
	}
	else if(_barType == IMInputTypeFace)
	{
		[self showTextEdit];

		_barType = IMInputTypeMenu;
		if([_delegate respondsToSelector:@selector(iminputBarHideFaceViewAndShowMenuView)])
		{
			[_delegate iminputBarHideFaceViewAndShowMenuView];
		}
	}
	else if(_barType == IMInputTypeAudio)
	{
		[self showTextEdit];

		_barType = IMInputTypeMenu;
		if([_delegate respondsToSelector:@selector(iminputBarHideFaceViewAndShowMenuView)])
		{
			[_delegate iminputBarHideFaceViewAndShowMenuView];
		}
	}
}

- (void)keyboardWillShow:(NSNotification *)note
{
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
	double keyboardTransitionDuration;
    [[note.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[note.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    
    
	// Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    
	if(_barType == IMInputTypeText)
	{
		[UIView animateWithDuration:keyboardTransitionDuration
							  delay:0.0f
							options:AnimationOptionsForCurve(keyboardTransitionAnimationCurve) | UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 self.top = self.superview.height - keyboardBounds.size.height - self.height;
							 if([_delegate respondsToSelector:@selector(iminputBarKeyBoardDidShow:)])
							 {
								 [_delegate iminputBarKeyBoardDidShow:keyboardBounds.size.height];
							 }
						 }
						 completion:^(BOOL finished){
							 
						 }];
		
		[_atSwitchBtn setImage:[UIImage imageNamed:@"msg_bar_voice.png"] forState:UIControlStateNormal];
		_audioBtn.hidden = YES;
	}
}

- (void)keyboardWillHide:(NSNotification *)note
{
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
	double keyboardTransitionDuration;
    [[note.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[note.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    
    
	// Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    
	if(_barType == IMInputTypeAudio)
	{
		[UIView animateWithDuration:keyboardTransitionDuration
							  delay:0.0f
							options:AnimationOptionsForCurve(keyboardTransitionAnimationCurve) | UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 self.top = self.superview.height - self.height;
							 if([_delegate respondsToSelector:@selector(iminputBarKeyBoardDidHide)])
							 {
								 [_delegate iminputBarKeyBoardDidHide];
							 }
						 }
						 completion:^(BOOL finished){
							 
						 }];
		[_atSwitchBtn setImage:[UIImage imageNamed:@"msg_bar_text.png"] forState:UIControlStateNormal];
		_audioBtn.hidden = NO;
	}

}

- (void)audioBtnTouchDown:(id)sender
{
	self.isCancel = NO;
	if([_delegate respondsToSelector:@selector(iminputBarBeginRecord)])
	{
		[_delegate iminputBarBeginRecord];
	}
}

- (void)audioBtnTouchUp:(id)sender
{
	if(self.isCancel == YES)
	{
		if([_delegate respondsToSelector:@selector(iminputBarRecordCancel:)])
		{
			[_delegate iminputBarRecordCancel:self];
		}
	}
	else
	{
		if([_delegate respondsToSelector:@selector(iminputEndRecord)])
		{
			[_delegate iminputEndRecord];
		}
	}
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
	_barType = IMInputTypeText;
	return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.frame = r;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
	BOOL flag = NO;
    if([_delegate respondsToSelector:@selector(iminputBarSendText:)])
    {
        NSString *message = [growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([message length] > 0)
        {
            flag = [_delegate iminputBarSendText:message];
            if(flag == YES)
			{
                _textView.text = nil;
				self.lastStr = nil;
			}
        }
    }
    return NO;
}
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if(self.limitWordsNum != 0 &&[growingTextView.text length] >= self.limitWordsNum && [text length] != 0 && ![text isEqualToString:@"\n"])
		return NO;
	if([text length] == 0 && range.length == 1)
	{
		return [self textviewDeleteLastCharOrFace];
	}
	else if([text isEqualToString:@"\n"])
	{
		[self growingTextViewShouldReturn:_textView];
		return NO;
	}
	return YES;
}
#pragma mark -
- (void)appendFaceText:(NSString *)faceText
{
	if(self.limitWordsNum != 0 && ([_textView.text length] + [faceText length]) >= self.limitWordsNum)
		return;
	_textView.text = [NSString stringWithFormat:@"%@%@", _textView.text, faceText];
}

- (void)sendInputText
{
	BOOL flag = NO;
	NSString *message = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if([message length] > 0)
	{
		flag = [_delegate iminputBarSendText:message];
		if(flag == YES)
		{
			_textView.text = nil;
			self.lastStr = nil;
		}
	}
}

- (BOOL)textviewDeleteLastCharOrFace
{
	NSMutableArray *array = [AssembleeMsgTool getAssembleArrayWithStr:_textView.text];
	NSString *str = [array lastObject];
	if([AssembleeMsgTool isFaceStr:str])
	{
		[array removeLastObject];
		NSString *str1 = [NSString stringWithFormat:@"%@ ", [array componentsJoinedByString:@""]];
		_textView.text = str1;
	}
	return YES;
}

- (void)deleteLastCharOrFace
{
	NSMutableArray *array = [AssembleeMsgTool getAssembleArrayWithStr:_textView.text];
	if(array == nil || [array count] <= 0)
		return;
	NSString *str = [array lastObject];
	if([AssembleeMsgTool isFaceStr:str])
	{
		[array removeLastObject];
		_textView.text = [array componentsJoinedByString:@""];
	}
	else
	{
		NSMutableString *mutStr = [NSMutableString stringWithString:str];
		[mutStr deleteCharactersInRange:NSMakeRange([mutStr length] - 1, 1)];
		[array removeLastObject];
		NSString *str1 = [NSString stringWithFormat:@"%@%@", [array componentsJoinedByString:@""], mutStr];
		_textView.text = str1;
	}
}



#pragma mark -
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *tch = [touches anyObject];
    CGPoint p = [tch locationInView:self];
	CGPoint p1 = [self convertPoint:p toView:self.superview];
//	NSLog(@"%@:%@", NSStringFromCGPoint(p), NSStringFromCGPoint(p1));
    if(CGRectContainsPoint(CGRectMake(100, (self.superview.height - 120)/2, 120, 120), p1))
    {
        if(_isCancel == NO)
        {
            _isCancel = YES;
            if([_delegate respondsToSelector:@selector(iminputBarCancelUpdate:)])
            {
                [_delegate iminputBarCancelUpdate:_isCancel];
            }
        }
    }
    else {
        if(_isCancel == YES)
        {
            _isCancel = NO;
            if([_delegate respondsToSelector:@selector(iminputBarCancelUpdate:)])
            {
                [_delegate iminputBarCancelUpdate:_isCancel];
            }
        }
    }
}

- (void)closeInputBar
{
	if(_barType == IMInputTypeAudio)
	{
		[self changeToAudioType];
	}
	else
	{
		[self changeToTextType];
	}
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
