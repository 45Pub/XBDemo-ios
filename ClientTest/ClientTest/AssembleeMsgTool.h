//
//  AssembleeMsgTool.h
//  DoctorChat
//
//  Created by 王鹏 on 13-2-28.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssembleeMsgTool : NSObject
+ (NSMutableArray *)getAssembleArrayWithStr:(NSString *)msgstr;
+ (BOOL)isFaceStr:(NSString *)str;
+ (NSArray *)getFaceArray;
+ (NSString *)getFaceImageWithStr:(NSString *)str;
@end
