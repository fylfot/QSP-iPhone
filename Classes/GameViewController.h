//
//  GameViewController.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 03.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIWebViewDelegate> {
    IBOutlet UIWebView *sceneView;
    IBOutlet UIWebView *inventoryView;
    IBOutlet UIWebView *descriptionView;
    IBOutlet UIPickerView *actionView;
    
    IBOutlet UIScrollView *layoutView;
    
    //IBOutlet UIWebView *actionView;
}

@property (nonatomic, retain) IBOutlet UIWebView *sceneView;
@property (nonatomic, retain) IBOutlet UIWebView *inventoryView;
@property (nonatomic, retain) IBOutlet UIWebView *descriptionView;
@property (nonatomic, retain) IBOutlet UIPickerView *actionView;

@property (nonatomic, retain) IBOutlet UIScrollView *layoutView;

- (void)update;

@end
