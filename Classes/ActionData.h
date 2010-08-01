//
//  ActionData.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 01.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionData : NSObject {
    NSInteger index;
    NSString *imagePath;
    NSString *description;
}

@property (nonatomic, retain) NSString *imagePath;
@property (nonatomic, retain) NSString *description;
@property (assign) NSInteger index;

//- (void)getActionData(int ind, QSP_CHAR **imgPath, QSP_CHAR **desc);
@end
