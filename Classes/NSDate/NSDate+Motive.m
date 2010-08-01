#import "NSDate+Motive.h"

@implementation NSDate (MotiveExtensions)

+ (NSDate *)fromString:(NSString *)dateString {
    return [self fromString:dateString withFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSDate *)fromString:(NSString *)dateString withFormat:(NSString *)format {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:dateString];
    [formatter release];
    return date;
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *string = [formatter stringFromDate:self];
    [formatter release];
    return string;
}

- (NSString *)dateStringWithDaysOffset {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval thisDate = self.timeIntervalSince1970;
    int days = (int) ceil((thisDate - now) / 60.0 / 60.0 / 24.0);
    NSString *offset = days == 0 ? @" (Today)" : [NSString stringWithFormat:@" (%@%d)", days > 0 ? @"+" : @"", days];
    return [NSString stringWithFormat:@"%@%@", [self stringWithFormat:@"EEE MMMM d, yyyy"], offset];
}

- (NSString *)dateString {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *string = [formatter stringFromDate:self];
    [formatter release];
    return string;
}

- (NSString *)timeString {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *string = [formatter stringFromDate:self];
    [formatter release];
    return string;    
}

- (NSDate *)startOfDay {
    return [NSDate fromString:[NSString stringWithFormat:@"%@ 00:00:01", [self stringWithFormat:@"yyyy-MM-dd"]]];
}

- (NSDate *)endOfDay {
    return [NSDate fromString:[NSString stringWithFormat:@"%@ 11:59:59", [self stringWithFormat:@"yyyy-MM-dd"]]];
}

- (BOOL)isToday {
    return [[self startOfDay] isEqual:[[NSDate date] startOfDay]];
}

- (BOOL)laterThan:(NSDate *)other {
    return [self compare:other] == NSOrderedDescending;
}

- (BOOL)earlierThan:(NSDate *)other {
    return [self compare:other] == NSOrderedAscending;
}
@end
