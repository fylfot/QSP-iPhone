// Note. Copied from http://www.cocoadev.com/index.pl?NSArrayCategory

#import "NSArray+CocoaDevUsersAdditions.h"

@implementation NSArray(CocoaDevUsersAdditions)

+ (NSArray *)arrayWithObjectsFromArrays:(NSArray *)arrays
{
    NSEnumerator * arrayEnumerator = [arrays objectEnumerator];
    NSMutableArray * resultArray = [NSMutableArray new];
	NSArray * current;
    while(current = [arrayEnumerator nextObject])
    {
        [resultArray addObjectsFromArray:current];
    }
    return [NSArray arrayWithArray:resultArray];
}

+(NSArray *)arrayWithClonesOf:(id)object count:(unsigned)count
{
    NSMutableArray * cloneArray = [NSMutableArray arrayWithCapacity:count];
    while([cloneArray count] < count)
    {
        [cloneArray addObject:object];
    }
    return [NSArray arrayWithArray:cloneArray];
}

+ (NSArray *)arrayWithCRLFLinesOfFile:(NSString *)filePath; // assumes CRLF
{
	return [NSArray arrayWithLinesOfFile:filePath lineEnding:@"\r\n"];
}

+ (NSArray *)arrayWithLinesOfFile:(NSString *)filePath lineEnding:(NSString *)lineEnding
{
	NSArray * result = nil;
    NSData *data = [NSData dataWithContentsOfFile:filePath];
	NSString * theFile = [NSString stringWithData:data];
	if (theFile == nil) // no string
		return result; // no result.
    
	NSArray * linesArray = [theFile componentsSeparatedByString:lineEnding];
	if ([linesArray count] > 0)
        result = [NSArray arrayWithArray:linesArray];
	return result;
}


-(BOOL)isEmpty
{
    return [self count] == 0;
}

-(BOOL)isNotEmpty
{
    return [self count] != 0;
}

-(id)firstObject
{
    return [self objectAtIndex:0];
}

- (BOOL)containsObjectIdenticalTo:(id)anObject
{
    return (NSNotFound != [self indexOfObjectIdenticalTo:anObject]);
}

- (NSArray *)arrayByRemovingFirstObject;
{
    if ([self count] == 0) return [[self copy] autorelease]; // self might have shorter lifetime than the autorelease pool; self might be mutable
    return [self subarrayWithRange:NSMakeRange(1, [self count] - 1)];
}

- (NSArray *)arrayByRemovingLastObject; 
{
    if ([self count] == 0) return [[self copy] autorelease];
    return [self subarrayWithRange:NSMakeRange(0, [self count] - 1)];
}

-(NSArray *)arrayByRemovingObjectAtIndex:(unsigned)aindex
{
    NSMutableArray * newArray = [NSMutableArray arrayWithArray:self];
    [newArray removeObjectAtIndex:aindex];
    return [NSArray arrayWithArray:newArray];
}

-(NSArray *)arrayByRemovingObjectsInRange:(NSRange)range
{
    NSMutableArray * newArray = [NSMutableArray arrayWithArray:self];
    [newArray removeObjectsInRange:range];
    return [NSArray arrayWithArray:newArray];
}

-(NSArray *)arrayByRemovingObject:(id)anObject
{
    if(anObject == nil) { return [[self copy] autorelease]; } //dodge an exception
    NSMutableArray * newArray = [NSMutableArray arrayWithArray:self];
    [newArray removeObject:anObject];
    return [NSArray arrayWithArray:newArray];
}

- (NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)unwanted
{
    NSMutableArray * newArray = [NSMutableArray arrayWithArray:self];
    [newArray removeObjectsInArray:unwanted];
    return [NSArray arrayWithArray:newArray];
}

- (NSArray *)choppedAtCount:(unsigned)count
{
    return [self subarrayWithRange:NSMakeRange(0, count)];
}

-(NSArray *)reversedArray
{
    return [[self reverseObjectEnumerator] allObjects];
}

- (NSArray *)resultsOfMakeObjectsPerformSelector:(SEL)aSelector
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *objectEnumerator;
    id obj;
    id objResult;
    
    if (aSelector == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"aSelector cannot be NULL."];
    }
    
    objectEnumerator = [self objectEnumerator];
    while ((obj = [objectEnumerator nextObject]))
    {
        objResult = [obj performSelector:aSelector];
        if (objResult == nil)
            objResult = [NSNull null];
        [result addObject:objResult];
    }
    
    return result;
}

- (NSArray *)resultsOfMakeObjectsPerformSelector:(SEL)aSelector withObject:(id)anObject
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *objectEnumerator;
    id obj;
    id objResult;
    
    if (aSelector == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"aSelector cannot be NULL."];
    }
    
    objectEnumerator = [self objectEnumerator];
    while ((obj = [objectEnumerator nextObject]))
    {
        objResult = [obj performSelector:aSelector withObject:anObject];
        if (objResult == nil)
            objResult = [NSNull null];
        [result addObject:objResult];
    }
    
    return result;
}

- (void)makeObjectsPerformSelector:(SEL)aSelector
         withRespectiveObjectsFrom:(id)collection
{
    NSEnumerator *targetEnumerator = [self objectEnumerator];
    NSEnumerator *argumentEnumerator = [collection objectEnumerator];
    id target;
    
    while ((target = [targetEnumerator nextObject]))
    {
        [target performSelector:aSelector withObject:[argumentEnumerator nextObject]];
    }
}

- (NSArray *)resultsOfMakeObjectsPerformSelector:(SEL)aSelector
                       withRespectiveObjectsFrom:(id)collection
{
    NSEnumerator *targetEnumerator = [self objectEnumerator];
    NSEnumerator *argumentEnumerator = [collection objectEnumerator];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[self count]];
    id target;
    id result;
    
    while (target = [targetEnumerator nextObject])
    {
        result = [target performSelector:aSelector withObject:[argumentEnumerator nextObject]];
        if (result == nil)
            result = [NSNull null];
        [results addObject:result];
    }
    
    return results;
}
@end
