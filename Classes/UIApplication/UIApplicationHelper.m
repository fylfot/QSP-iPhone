//
//  UIApplicationHelper.m
//  Enormego Cocoa Helpers
//
//  Created by Shaun Harrison on 8/25/09.
//  Copyright (c) 2009 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if TARGET_OS_IPHONE
#import "UIApplicationHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIApplication (Helper)

static UIView *warningView = nil;
static UIDatePicker *datePicker = nil;
static UIPickerView *valuePicker = nil;
static UIButton *resetButton = nil;

- (NSString *)documentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)setApplicationStyle:(UIStatusBarStyle)style animated:(BOOL)animated {
	[self setApplicationStyle:style animated:animated defaultBackgroundColor:[UIColor whiteColor]];
}

- (void)setApplicationStyle:(UIStatusBarStyle)style animated:(BOOL)animated defaultBackgroundColor:(UIColor*)defaultBackgroundColor {
	[self setStatusBarStyle:style animated:animated];
	
	UIColor* newBackgroundColor = style == UIStatusBarStyleDefault ? defaultBackgroundColor : [UIColor blackColor];
	UIColor* oldBackgroundColor = style == UIStatusBarStyleDefault ? [UIColor blackColor] : defaultBackgroundColor;
	
	if(animated) {
	    [CATransaction setValue:[NSNumber numberWithFloat:0.3] forKey:kCATransactionAnimationDuration];
		
		CABasicAnimation* fadeAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
		fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		fadeAnimation.fromValue = (id)oldBackgroundColor.CGColor;
		fadeAnimation.toValue = (id)newBackgroundColor.CGColor;
		fadeAnimation.fillMode = kCAFillModeForwards;
		fadeAnimation.removedOnCompletion = NO;
		[self.keyWindow.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
		[CATransaction commit];
	} else {
		self.keyWindow.backgroundColor = newBackgroundColor;
	}
}


- (void)showMessages:(NSArray *)array {
    NSMutableString *message = [NSMutableString stringWithString:@""];
    for (NSString *subMessage in array) {
        [message appendFormat:@"\n%@", subMessage];
    }
    [self showMessage:message];
}

- (void)showMessage:(NSString *)message {
    if (warningView) {
        [warningView removeFromSuperview];
        [warningView release];
        warningView = nil;
    }
    warningView = [[UIView alloc] initWithFrame:[self.keyWindow frame]];
    [warningView setBackgroundColor:[UIColor colorWithWhite:0 alpha:.5f]];
    [warningView setOpaque:YES];
    UITextView *label = [[UITextView alloc] initWithFrame:warningView.frame];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setUserInteractionEnabled:NO];
    [label setEditable:NO];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setFont:[UIFont boldSystemFontOfSize:21]];
    [label setText:[NSString stringWithFormat:@"Warning:\n%@", message]];
    [label sizeToFit];
    [label setCenter:CGPointMake(warningView.frame.size.width / 2.0f, warningView.frame.size.height / 2.0f)];
    
    [warningView addSubview:label];
    [label release];
    [self.keyWindow addSubview:warningView];
    [self performSelector:@selector(dismissMessage) withObject:nil afterDelay:1.0f];
}

- (void)dismissMessage {
    if (warningView) {
        [warningView removeFromSuperview];
        [warningView release];
        warningView = nil;
    }
}

- (void)showDatePickerWithDelegate:(id <UIPickerViewDelegate>)pickerDelegate {
    
    if (!resetButton) {
        resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [self.keyWindow addSubview:resetButton];
        [resetButton addTarget:self action:@selector(hidePicker) forControlEvents:UIControlEventTouchUpInside];
        [resetButton addTarget:self action:@selector(hideDatePicker) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [resetButton setHidden:NO];
    
    if (!datePicker) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 480, 320, 240)];
        [self.keyWindow addSubview:datePicker];
    }
    
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setUserInteractionEnabled:YES];
    
    [datePicker removeTarget:nil action:@selector(datePickerChangedDate:) forControlEvents:UIControlEventValueChanged];
	[datePicker addTarget:pickerDelegate action:@selector(datePickerChangedDate:) forControlEvents:UIControlEventValueChanged];
    
    [UIView beginAnimations:@"com.jamg.animation.datepicker.fadein" context:nil];
    [datePicker setFrame:CGRectMake(0, 264, 320, 240)];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidShowNotification object:nil];
}

- (NSDate *)dateFromDatePicker {
    return [datePicker date];
}

- (void)hideDatePicker {
    [resetButton setEnabled:NO];
    [datePicker setUserInteractionEnabled:NO];
    
    [UIView beginAnimations:@"com.jamg.animation.datepicker.fadeout" context:nil];
    [valuePicker setFrame:CGRectMake(0, 480, 320, 240)];
    [datePicker setFrame:CGRectMake(0, 480, 320, 240)];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [datePicker release];
    datePicker = nil;
    [valuePicker release];
    valuePicker = nil;
    [resetButton release];
    resetButton = nil;
}

- (void)showPickerWithDelegate:(id<UIPickerViewDelegate>)pickerDelegate andDatasource:(id<UIPickerViewDataSource>)datasource {
    
    if (!resetButton) {
        resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [self.keyWindow addSubview:resetButton];
        [resetButton addTarget:self action:@selector(hidePicker) forControlEvents:UIControlEventTouchUpInside];
        [resetButton addTarget:self action:@selector(hideDatePicker) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!datePicker) {
        valuePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 240)];
    }
    [valuePicker setShowsSelectionIndicator:YES];

    [self.keyWindow addSubview:valuePicker];

    [valuePicker reloadAllComponents];
    [resetButton setHidden:NO];

    [valuePicker setDelegate:pickerDelegate];
    [valuePicker setDataSource:datasource];
    [valuePicker setUserInteractionEnabled:YES];
    
    //[valuePicker removeTarget:nil action:@selector(valuePickerChangedValue:) forControlEvents:UIControlEventValueChanged];
	//[valuePicker addTarget:pickerDelegate action:@selector(valuePickerChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    [UIView beginAnimations:@"com.jamg.animation.valuepicker.fadein" context:nil];
    [valuePicker setFrame:CGRectMake(0, 264, 320, 240)];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidShowNotification object:nil];
}

- (void)hidePicker {
    [resetButton setHidden:YES];

    [UIView beginAnimations:@"com.jamg.animation.datepicker.fadeout" context:nil];
    [valuePicker setFrame:CGRectMake(0, 480, 320, 240)];
    [datePicker setFrame:CGRectMake(0, 480, 320, 240)];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification object:nil];
    [datePicker release];
    datePicker = nil;
    [valuePicker release];
    valuePicker = nil;
    [resetButton release];
    resetButton = nil;
}

@end
#endif