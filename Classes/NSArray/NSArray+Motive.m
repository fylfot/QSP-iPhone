#import "NSArray+Motive.h"

@implementation NSArray (MotiveExtensions)

- (BOOL)isEmpty {
    return [self count] == 0;
}

- (BOOL)isNotEmpty {
    return !self.isEmpty;
}

+ (NSArray *)repeat:(id)object times:(NSUInteger)times {
	NSMutableArray *r = [NSMutableArray arrayWithCapacity:times];
	for (int i = 0; i < times; ++i) {
		[r addObject:object];
	}
	return r;
}

- (id)firstObject {
	return [self objectAtIndex:0];
}
@end
