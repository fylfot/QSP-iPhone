//
//  GameViewController.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 03.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "GameViewController.h"
#import "Settings.h"

@implementation GameViewController

@synthesize sceneView, inventoryView, descriptionView, actionView, layoutView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    actionView.frame = CGRectMake(0, 264, 320, 216);
    [self.sceneView.superview addSubview:actionView];
    for (id subview in self.sceneView.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;
        }
    }
    [self update];
}

- (void)update {
//    NSLog(@"Main desc: \n%@\n", [[QSPAdapter sharedQSPAdapter] getMainDesc]);
    [sceneView loadHTMLString:[NSString stringWithFormat:@"<div id='__iphone_size_hack' style='font-family:\"%@\";font-size:%@;'>%@</div>", [[Settings sharedSettings] fontFamily], [[Settings sharedSettings] fontWeight], [[QSPAdapter sharedQSPAdapter] getMainDesc]] baseURL:[NSURL URLWithString:nil]];
    [actionView reloadAllComponents];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *output = nil;
    CGFloat result = 0;
//    switch (webView.tag) {
//        case 120: // See XIB
            output = [sceneView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"__iphone_size_hack\").offsetHeight;"];
            result = MAX([output floatValue] + 16, 264);
            
            sceneView.frame = CGRectMake(0, 0, 320, result);
            layoutView.contentSize = CGSizeMake(0, result + 216);
            actionView.frame = CGRectMake(0, sceneView.frame.size.height, 320, 216);
            [layoutView scrollsToTop];
//            break;
//        default:
//            break;
//    }
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    return NO;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [[QSPAdapter sharedQSPAdapter] setSelectedActionIndex:row isRefresh:YES];
    [[QSPAdapter sharedQSPAdapter] executeSelectedActionCode:YES];
    [self performSelector:@selector(update) withObject:nil afterDelay:.5f];
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[[QSPAdapter sharedQSPAdapter] getActionData:row] description];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[QSPAdapter sharedQSPAdapter] getActionsCount];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
