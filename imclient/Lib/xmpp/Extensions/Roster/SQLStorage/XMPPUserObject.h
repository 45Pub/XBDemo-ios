// XMPPUserObject.h
// 
// Copyright (c) 2013年 pengjay.cn@gmail.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//   http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#endif

#import "XMPPUser.h"
#import "XMPP.h"

typedef NS_ENUM(NSInteger, XMPPUserType) {
	XMPPUserTypeUser = 0,
	XMPPUserTypeDiscussGroup,
};

@class XMPPGroupObject;
@class XMPPResourceObject;

@interface XMPPUserObject : NSObject <XMPPUser>
@property (nonatomic, strong) XMPPJID *jid;
@property (nonatomic, strong) NSString * jidStr;
@property (nonatomic, strong) NSString * streamBareJidStr;

@property (nonatomic, strong) NSString * nickname;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * subscription;
@property (nonatomic, strong) NSString * ask;
@property (nonatomic, strong) XMPPResourceObject *primaryResource;
@property (nonatomic, strong) NSSet * groups;
@property (nonatomic, strong) NSSet * resources;
@property (nonatomic) XMPPUserType usertype;
@property (nonatomic) NSInteger isAdmin;
@property (nonatomic, strong) NSString *pinyin;
@property (nonatomic) unichar firstLetter;


+ (XMPPUserObject *)userWithItem:(NSXMLElement *)item;
+ (XMPPUserType)xmppUserTypeWithJidStr:(NSString *)jidStr;


- (void)updateWithItem:(NSXMLElement *)item;

- (void)recalculatePrimaryResource;
@end
