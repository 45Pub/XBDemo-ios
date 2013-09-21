//
// Created by 王鹏 on 13-6-23.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface XMPPCapaResourceStorageObject : NSObject
@property (nonatomic, strong) NSString * jidStr;
//@property (nonatomic, strong) NSString * streamBareJidStr;

@property (nonatomic, assign) BOOL haveFailed;

@property (nonatomic, strong) NSString * node;
@property (nonatomic, strong) NSString * ver;
@property (nonatomic, strong) NSString * ext;

@property (nonatomic, strong) NSString * hashStr;
@property (nonatomic, strong) NSString * hashAlgorithm;
@end