//
//  GameViewController.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 03.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectView;
@interface GameViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UIAlertViewDelegate> {
    UIWebView *sceneView;
    UITableView *inventoryView;
    UIWebView *descriptionView;
    SelectView *actionView;
    
    UIButton *descriptionButton;
    UIButton *inventoryButton;
    
    UIScrollView *layoutView;
    NSInteger countOfFastClicking;
    
    NSArray *resultForInventory;
    NSArray *resultForActions;
    
    CGFloat fontRowWeight;
}

@property (nonatomic, retain) IBOutlet UIWebView *sceneView;
@property (nonatomic, retain) IBOutlet UITableView *inventoryView;
@property (nonatomic, retain) IBOutlet UIWebView *descriptionView;
@property (nonatomic, retain) SelectView *actionView;

@property (nonatomic, retain) IBOutlet UIButton *descriptionButton;
@property (nonatomic, retain) IBOutlet UIButton *inventoryButton;

@property (nonatomic, retain) IBOutlet UIScrollView *layoutView;

- (IBAction)descriptionButtonClicked:(id)sender;
- (IBAction)inventoryButtonClicked:(id)sender;

- (void)bindObservers;
- (void)update;

@end
