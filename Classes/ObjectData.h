//
//  ObjectData.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 01.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ObjectData : NSObject {
    NSInteger index;
    NSString *imagePath;
    NSString *description;
}

@property (nonatomic, retain) NSString *imagePath;
@property (nonatomic, retain) NSString *description;
@property (assign) NSInteger index;

@end
