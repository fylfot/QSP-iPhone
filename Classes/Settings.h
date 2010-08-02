//
//  Settings.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 02.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Settings : NSObject {
    NSString *lastWorldPlayed;
    NSString *fontFamily;
    NSString *fontWeight;
}

@property (nonatomic, retain) NSString *lastWorldPlayed;
@property (nonatomic, retain) NSString *fontFamily;
@property (nonatomic, retain) NSString *fontWeight;

SYNTHESIZE_SINGLETON_HEADER_FOR_CLASS(Settings);

- (id)init;
- (void)deinit;
- (UIFont *)prefferedFont;

@end
