//
//  IMVideoTool.h
//  GoComIM
//
//  Created by 王鹏 on 13-6-29.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^VideoCompleteHander) (BOOL suc);
@interface IMVideoTool : NSObject
+ (void)encodeVideoOrientation:(NSURL *)orginFileURL outputFile:(NSURL *)outputURL hander:(VideoCompleteHander)hander;
@end
