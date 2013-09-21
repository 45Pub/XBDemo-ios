//
// Created by 王鹏 on 13-6-23.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import "DDXML.h"
#endif

@interface XMPPCapaStorageObject : NSObject
@property (nonatomic, strong) NSXMLElement *capabilities;

@property (nonatomic, strong) NSString * hashStr;
@property (nonatomic, strong) NSString * hashAlgorithm;
@property (nonatomic, strong) NSString * capabilitiesStr;

@property (nonatomic, strong) NSSet * resources;
@end