//
//  IMJHConfigurator.m
//  IMLite
//
//  Created by pengjay on 13-7-23.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import "IMJHConfigurator.h"
#import "AppDelegate.h"

@implementation IMJHConfigurator
- (NSURL *)fileUploadURL
{
    
	return [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@", API_PREFIX, @"&a=index&m=Postfile"] stringByAppendingString:[del apiString]]];
}

- (NSString *)msgPostType:(IMMsgType)msgType isp2p:(BOOL)isp2p thumbnail:(BOOL)isThumbmail {
    //0私聊语音,1私聊图片,2私聊视频以及视频缩略图，3群聊语音,4群聊图片,5群聊视频及缩略图 6个人头像 7 其他文件
    NSInteger type = 0;
    if (msgType == IMMsgTypeAudio) {
        type = 0;
    } else if (msgType == IMMsgTypePic) {
        type = 1;
    } else if (msgType == IMMsgTypeVideo || isThumbmail) {
        type = 2;
    } else {
        type = 7;
    }
    if (!isp2p && type != 7 && type != 6) {
        type += 3;
    }

    return [NSString stringWithFormat:@"%d", type];
}
@end
