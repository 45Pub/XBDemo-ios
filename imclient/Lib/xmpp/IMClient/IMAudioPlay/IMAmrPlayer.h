//
//  IMAmrPlayer.h
//  IMCommon
//
//  Created by 王鹏 on 13-1-17.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMAudioPlayer.h"
#import "PPAmrPlayer.h"

@interface IMAmrPlayer : IMAudioPlayer <PPAmrPlayerDelegate>
@property (nonatomic, strong) PPAmrPlayer *player;
- (id)initWithPath:(NSString *)path;

@end
