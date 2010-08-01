#import "NSString+Motive.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MotiveExtension)

static NSUInteger MVChunkSize = 1024;

+ (NSString *)stringWithData:(NSData *)data {
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (BOOL)isEmpty {
    return [self length] == 0;
}

- (BOOL)isNotEmpty {
    return !self.isEmpty;
}

- (BOOL)contains:(NSString *)other {
    return [self rangeOfString:other].length > 0;
}

- (NSData *)asData {
    return [self dataUsingEncoding:NSStringEncodingConversionAllowLossy];
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)trimNewLines {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)touchFileAtPath {
    return [[NSFileManager defaultManager] createFileAtPath:self contents:nil attributes:nil];
}

- (BOOL)fileExistsAtPath {
    return [[NSFileManager defaultManager] fileExistsAtPath:self];
}

- (NSNumber *)fileSizeAtPath {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:self traverseLink:YES];
    if (fileAttributes == nil) {
        return [NSNumber numberWithInt:-1];
    } else {
        NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
        return fileSize == nil ? [NSNumber numberWithInt:-1] : fileSize;
    }
}

- (NSString *)md5ForFileAtPath {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self];
	if (handle == nil) {
        return nil;
    } else {
        CC_MD5_CTX md5;        
        CC_MD5_Init(&md5);
        
        BOOL done = NO;
        while (!done) {
            NSData* fileData = [handle readDataOfLength:MVChunkSize];
            CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
            if ([fileData length] == 0) done = YES;
        }

        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &md5);
        return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                       digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7], digest[8], digest[9], digest[10], 
                       digest[11], digest[12], digest[13], digest[14], digest[15]];
    }
}

- (BOOL)isBlank {
    
    if ([self length] == 0 || [self isEqualToString:@""] || [[self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] length] == 0) {
        return YES;
    }
    return NO;
}

@end
