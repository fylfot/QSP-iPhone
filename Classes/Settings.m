//
//  Settings.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 02.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "Settings.h"


@implementation Settings

@synthesize lastWorldPlayed, fontFamily, fontWeight;

SYNTHESIZE_SINGLETON_FOR_CLASS(Settings);

- (id)init {
    self = [super init];
    if (self) {
        self.lastWorldPlayed = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.jamg.qsp.settings.lastWorldPlayed"];
        self.fontFamily = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.jamg.qsp.settings.fontFamily"];
        self.fontWeight = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.jamg.qsp.settings.fontWeight"];
        if (!self.lastWorldPlayed) {
            self.lastWorldPlayed = @"";
        }
        if (!self.fontFamily) {
            self.fontFamily = @"Helvetica";
        }
        if (!self.fontWeight) {
            self.fontWeight = @"17";
        }
    }
    return self;
}

- (UIFont *)prefferedFont {
    return [UIFont fontWithName:self.fontFamily size:[self.fontWeight floatValue]];
}

- (void)deinit {
    [[NSUserDefaults standardUserDefaults] setObject:self.lastWorldPlayed forKey:@"com.jamg.qsp.settings.lastWorldPlayed"];
    [[NSUserDefaults standardUserDefaults] setObject:self.fontFamily forKey:@"com.jamg.qsp.settings.fontFamily"];
    [[NSUserDefaults standardUserDefaults] setObject:self.fontWeight forKey:@"com.jamg.qsp.settings.fontWeight"];
}

@end
