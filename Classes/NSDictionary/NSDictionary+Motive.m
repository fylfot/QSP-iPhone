#import "NSDictionary+Motive.h"

@implementation NSDictionary (MotiveExtensions)

- (BOOL)isEmpty {
    return [self count] == 0;
}

- (BOOL)isNotEmpty {
    return !self.isEmpty;
}

@end
