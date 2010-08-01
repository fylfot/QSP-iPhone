//
//  QSPAppDelegate.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 01.08.10.
//  Copyright JAMG 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QSPViewController;

@interface QSPAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    QSPViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet QSPViewController *viewController;

@end

