//
//  TalkView.h
//  lty
//
//  Created by Paul Wang on 12-6-27.
//  Copyright (c) 2012年 pjsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum TALKVIEWSTAT
{
    TALKVIEWSTATSTART = 0,
    TALKVIEWSTATTOOSHORT,
    TALKVIEWSTATDELETE,
    TALKVIEWSTATNOMIC,
}TALKVIEWSTAT;


@interface TalkView : UIView
@property (nonatomic) TALKVIEWSTAT tstat;
@end
