#import <Foundation/Foundation.h>

@interface NSData (XMPP)

- (NSData *)md5Digest;

- (NSData *)sha1Digest;

- (NSString *)hexStringValue;

- (NSString *)base64Encoded;
- (NSData *)base64Decoded;

- (NSString*)md5HashStr;

- (NSString*)sha1HashStr;
@end
