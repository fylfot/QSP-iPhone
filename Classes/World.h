//
//  World.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 02.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <Foundation/Foundation.h>

enum _WorldState {
    WorldStateInvalid = 0,
    WorldStateMissing,
    WorldStateNew,
    WorldStateReady,
    WorldStateNewVersionAvalaible
};

typedef enum _WorldState WorldState;

@interface World : NSObject {
    BOOL isThirdParty;
    WorldState currentState;
    NSString *name;
    NSInteger fileHash;
    NSString *description;
    NSString *relativePath;
}

@property (assign) BOOL isThirdParty;
@property (assign) WorldState currentState;
@property (nonatomic, retain) NSString *name;
@property (assign) NSInteger fileHash;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *relativePath;

+ (NSString *)documentPath;
+ (NSMutableArray *)allObjects;
- (void)registrate;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
+ (void)loadObjects;
+ (void)saveObjects;

+ (World *)selected;
+ (void)setSelected:(World *)newSelected;
- (void)setSelected;
+ (void)setNewObjects:(NSArray *)newObjects;
+ (NSArray *)avalaibleWorlds;

@end
