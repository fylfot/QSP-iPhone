#import <Foundation/Foundation.h>

@interface NSDate (MotiveExtensions)

// String format is: yyyy-MM-dd HH:mm:ss
+ (NSDate *)fromString:(NSString *)dateString;

// Create a date from the given string according to the given format.
+ (NSDate *)fromString:(NSString *)dateString withFormat:(NSString *)format;

// This date as a string using |format|.
- (NSString *)stringWithFormat:(NSString *)format;

// This date as a string with number of days in the past/future it is, e.g. Wed 23 Nov, 2009 (+21).
- (NSString *)dateStringWithDaysOffset;

// This date in simple format using NSDateFormatterMediumStyle, e.g. "23 Nov, 1937"
- (NSString *)dateString;

// This date's time in simple format using NSDateFormatterShortStyle, e.g. "3:30pm"
- (NSString *)timeString;

// Returns a date representing the start of today.
- (NSDate *)startOfDay;

// Returns a date representing the end of today.
- (NSDate *)endOfDay;

// Is this date today?
- (BOOL)isToday;

// Is this date later than the |other| date?
- (BOOL)laterThan:(NSDate *)other;

// Is this date earlier than the |other| date?
- (BOOL)earlierThan:(NSDate *)other;

@end
