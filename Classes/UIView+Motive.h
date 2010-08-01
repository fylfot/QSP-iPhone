#import <Foundation/Foundation.h>

@interface UIView (MotiveExtensions)

// Moves this view to the centre (vertically & horizontally) of |view|.
- (void)centreWithinView:(UIView *)view;

// Moves this view to the top (vertically) and centre (horizontally) of |view|.
- (void)moveToTopCentreOfView:(UIView *)view;

- (BOOL)isReallyHidden;
- (BOOL)findAndResignFirstResponder;
@end
