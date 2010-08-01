#import "UIView+Motive.h"

@implementation  UIView (MotiveExtensions)

- (void)centreWithinView:(UIView *)view {
    self.center = CGPointMake(view.center.x, self.bounds.size.height / 2);
}

- (void)moveToTopCentreOfView:(UIView *)view {
    self.center = CGPointMake(view.center.x, self.bounds.size.height / 2);
}

- (BOOL)isReallyHidden {
    if (self.hidden || self.alpha == .0f) {
        return YES;
    }
    return NO;
}

- (BOOL)findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;     
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}

@end
