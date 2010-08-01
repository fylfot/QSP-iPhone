//
//  QSPAdapterBase.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 01.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QSPAdapterBase : NSObject {
    NSError *error;
    BOOL lastReturnedBool;
}

@property (nonatomic, retain) NSError *error;
@property (assign) BOOL lastReturnedBool;

@end
