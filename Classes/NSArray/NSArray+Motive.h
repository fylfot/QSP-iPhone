#import <Foundation/Foundation.h>

@interface NSArray (MotiveExtensions)

READ BOOL isEmpty;
READ BOOL isNotEmpty;
+ (NSArray *)repeat:(id)object times:(NSUInteger)times;

- (id)firstObject;
@end
