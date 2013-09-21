//
//  IMMsg.h
//  iPhoneXMPP
//
//  Created by pengjay on 13-7-8.
//
//

#import <Foundation/Foundation.h>
@class IMUser;

#define MSG_VERSION 1
//Msg Read State
typedef NS_ENUM(NSInteger, IMMsgReadState)
{
	IMMsgReadStateUnRead = 0,
	IMMsgReadStateReaded,
};

//Msg process  State (Download or Upload...)
typedef NS_ENUM(NSInteger, IMMsgProcState)
{
	IMMsgProcStateSuc = 0,
	IMMsgProcStateUnproc,
	IMMsgProcStateProcessing,
	IMMsgProcStateFaied,
};

//Audio Msg Play State
typedef NS_ENUM(NSInteger, IMMsgPlayState)
{
	IMMsgPlayStateUnPlay = 0,
	IMMsgPlayStatePlaying,
	IMMsgPlayStatePause,
	IMMsgPlayStatePlayed,
};

//Msg Type
typedef NS_ENUM(NSInteger, IMMsgType)
{
	IMMsgTypeText = 0,
	IMMsgTypeAudio,
	IMMsgTypePic,
	IMMsgTypeFile,
	IMMsgTypeFriendCenter,
	IMMsgTypeVideo,
	IMMsgTypeNews,
	IMMsgTypePost,
	IMMsgTypeMail,
	IMMsgTypeNotice,
	IMMsgTypeBusiness,
};

typedef NS_ENUM(NSInteger, IMMsgFrom)
{
	IMMsgFromOther = 0,
	IMMsgFromLocalSelf = 1,
	IMMsgFromRemoteSelf = 2,
};

@interface IMMsg : NSObject

@property (nonatomic) NSInteger msgVer;
@property (nonatomic, strong) IMUser *fromUser; //消息来源者
@property (nonatomic, strong) IMUser *msgUser; //消息拥有者
@property (nonatomic, strong) NSString *msgID; //消息ID
@property BOOL isDelayed; //离线消息标记
@property (nonatomic, strong) NSDate *msgTime; //消息时间
@property (nonatomic, strong) NSString *msgBody; //消息body
@property (nonatomic, strong) NSDictionary *msgAttach; // 消息附件
@property IMMsgType msgType;
@property UInt64 msgSize; //大小
@property IMMsgReadState readState;
@property IMMsgProcState procState;
@property IMMsgPlayState playState;
@property IMMsgFrom fromType; //消息发送方
@property float progress;


+ (NSString*)generateMessageID;

- (id)initSendMsg;
@end
