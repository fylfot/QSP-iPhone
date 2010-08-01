//
//  StateData.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 01.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSPAdapterBase.h"

@interface StateData : QSPAdapterBase {
    NSInteger actionIndex;
    NSInteger line;
    NSString *location;
}

@property (nonatomic, retain) NSString *location;
@property (assign) NSInteger actionIndex;
@property (assign) NSInteger line;

@end
