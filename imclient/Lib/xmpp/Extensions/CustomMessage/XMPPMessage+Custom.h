//
//  XMPPMessage+Custom.h
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import "XMPPMessage.h"
#import "IMMsg.h"
#import "IMCoreMacros.h"

static NSString *const XMPPMessageTypeNormal = @"normal";
static NSString *const XMPPMessageTypeVoiceFileLink = @"vflink";
static NSString *const XMPPMessageTypePicFileLink = @"pflink";
static NSString *const XMPPMessageTypeAction = @"action";
static NSString *const XMPPMessageTypeFileLink = @"filelink";
static NSString *const XMPPMessageTypeVideoLink = @"videolink";


@interface XMPPMessage (Custom)
+ (IMMsgType)getImMsgType:(NSString *)xmppMsgType;
+ (NSString *)getXMPPMsgTypeStr:(IMMsgType)msgType;
@end
