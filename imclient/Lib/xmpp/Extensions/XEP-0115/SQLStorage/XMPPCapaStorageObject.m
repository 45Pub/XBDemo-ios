//
// Created by 王鹏 on 13-6-23.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "XMPPCapaStorageObject.h"
#import "XMPP.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation XMPPCapaStorageObject

- (NSXMLElement *)capabilities
{
    return [[NSXMLElement alloc] initWithXMLString:[self capabilitiesStr] error:nil];
}

- (void)setCapabilities:(NSXMLElement *)caps
{
    self.capabilitiesStr = [caps compactXMLString];
}
@end