// XMPPResourceObject.h
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
#import "XMPPResource.h"
@interface XMPPResourceObject : NSObject <XMPPResource>

@property (nonatomic, strong) XMPPJID *jid;
@property (nonatomic, strong) XMPPPresence *presence;

@property (nonatomic, strong) NSString * bareJidStr;
@property (nonatomic, strong) NSString * presenceStr;

@property (nonatomic, strong) NSString * fullJidStr;

@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * show;
@property (nonatomic, strong) NSString * status;

@property (nonatomic, strong) NSDate * presenceDate;

@property (nonatomic, assign) int prioritynum;
@property (nonatomic, assign) int shownum;

+ (XMPPResourceObject *)resourceWithPresence:(XMPPPresence *)presence;
- (void)updateWithPresence:(XMPPPresence *)presence;
@end
