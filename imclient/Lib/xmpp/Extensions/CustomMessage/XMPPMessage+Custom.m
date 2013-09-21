//
//  XMPPMessage+Custom.m
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import "XMPPMessage+Custom.h"

IM_FIX_CATEGORY_BUG(XMPPMesssage_Custom)
@implementation XMPPMessage (Custom)

+ (IMMsgType)getImMsgType:(NSString *)xmppMsgType
{
	IMMsgType type = IMMsgTypeText;
	if ([xmppMsgType isEqualToString:XMPPMessageTypeNormal]) {
		type = IMMsgTypeText;
	}
	else if ([xmppMsgType isEqualToString:XMPPMessageTypeVoiceFileLink]) {
		type = IMMsgTypeAudio;
	}
	else if ([xmppMsgType isEqualToString:XMPPMessageTypePicFileLink]) {
		type = IMMsgTypePic;
	}
	else if ([xmppMsgType isEqualToString:XMPPMessageTypeAction]) {
		type = IMMsgTypeText;
	}
	else if ([xmppMsgType isEqualToString:XMPPMessageTypeFileLink]) {
		type = IMMsgTypeFile;
	}
	else if ([xmppMsgType isEqualToString:XMPPMessageTypeVideoLink]) {
		type = IMMsgTypeVideo;
	}
	
	return type;
}


+ (NSString *)getXMPPMsgTypeStr:(IMMsgType)msgType
{
	NSString *xmppMsgType = XMPPMessageTypeNormal;
	if (msgType == IMMsgTypeAudio) {
		xmppMsgType = XMPPMessageTypeVoiceFileLink;
	}
	else if (msgType == IMMsgTypePic) {
		xmppMsgType = XMPPMessageTypePicFileLink;
	} else if (msgType == IMMsgTypeFile)
		xmppMsgType = XMPPMessageTypeFileLink;
	else if (msgType == IMMsgTypeVideo)
		xmppMsgType = XMPPMessageTypeVideoLink;
	return xmppMsgType;
}
@end
