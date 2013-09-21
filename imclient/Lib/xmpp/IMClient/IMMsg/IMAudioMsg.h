//
//  IMAudioMsg.h
//  IMClient
//
//  Created by pengjay on 13-7-12.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMFileMsg.h"
#import "IMAudioPlayProtocol.h"
#import "IMAudioPlayer.h"
@interface IMAudioMsg : IMFileMsg <IMAudioPlayProtocol, IMAudioPlayerDelegate>
{
	IMAudioPlayer *_audioPlayer;
}

@end
