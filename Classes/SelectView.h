//
//  SelectView.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 19.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectView : UIView {
    UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)update;

@end
