//
//  World.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 02.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "World.h"


@implementation World

@synthesize isThirdParty, name, fileHash, description, relativePath, currentState;

static NSString *kNameKey = @"kNameKey";
static NSString *kFileHashKey = @"kFileHashKey";
static NSString *kDescriptionKey = @"kDescriptionKey";
static NSString *kRelativePathKey = @"kRelativePathKey";

static NSMutableArray *objects = nil;
static World *selected = nil;
static NSString *documentPathInstance = nil;

+ (NSArray *)avalaibleWorlds {
    NSMutableArray *worlds = [[NSMutableArray alloc] init];
    for (NSString *world in [[NSBundle mainBundle] pathsForResourcesOfType:@"qsp" inDirectory:nil]) {
        [worlds addObject:[[world stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]] withString:@""] stringByDeletingPathExtension]];
    }
    for (NSString *world in [[NSBundle mainBundle] pathsForResourcesOfType:@"qsp" inDirectory:[self documentPath]]) {
        [worlds addObject:[[world stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]] withString:@""] stringByDeletingPathExtension]];
    }
    return worlds;
}

+ (NSString *)documentPath {
    if (!documentPathInstance) {
        NSArray *dirPaths;
        
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        documentPathInstance = [[dirPaths objectAtIndex:0] retain];
    }
    return documentPathInstance;
}


+ (void)setSelected:(World *)newSelected {
    [selected release];
    selected = [newSelected retain];
}

- (void)select {
    [World setSelected:self];
}

+ (World *)selected {
    return selected;
}

+ (void)setNewObjects:(NSArray *)newObjects {
    [objects release];
    objects = [[NSMutableArray arrayWithArray:newObjects] retain];
    [self saveObjects];
}

+ (NSMutableArray *)allObjects {
    if (!objects) {
        [self loadObjects];
    }
    if (![objects isKindOfClass:[NSMutableArray class]]) {        
        [self setNewObjects:objects];
    }
    return [objects retain];
}

- (void)registrate {
    [[World allObjects] addObject:[self retain]];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [[World alloc] init];
    self.relativePath = (NSString *)[coder decodeObjectForKey:kRelativePathKey];
    self.description = (NSString *)[coder decodeObjectForKey:kDescriptionKey];
    self.name = (NSString *)[coder decodeObjectForKey:kNameKey];
    self.fileHash = (NSInteger)[coder decodeIntForKey:kFileHashKey];
    self.currentState = WorldStateInvalid;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.relativePath forKey:kRelativePathKey];
	[coder encodeObject:self.description forKey:kDescriptionKey];
	[coder encodeObject:self.name forKey:kNameKey];
	[coder encodeInt:(NSInteger)self.fileHash forKey:kFileHashKey];
}

+ (void)loadObjects {
    [objects release];
    NSString *path = [[self documentPath] stringByAppendingFormat:@"/worlds_register.dat"];
    @try {
        objects = [[NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]] retain];
    } @catch (NSException * e) {
        NSLog(@"loadObjects error");
        objects = [[NSMutableArray array] retain];
        [self saveObjects];
    }
    if (!objects) {
        objects = [[NSMutableArray array] retain];
    }
    [self setNewObjects:[[NSSet setWithArray:objects] allObjects]];
    
    // Checking of existing information
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (World *object in [self allObjects]) {
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:[object relativePath]];
        [names addObject:object.name];
        if ([object fileHash] == [file hash]) {
            object.currentState = WorldStateReady;
        } else {
            object.currentState = WorldStateMissing;
        }
    }
    
    // Checking of new worlds
    for (NSString *worldName in [self avalaibleWorlds]) {
        if (![names containsObject:worldName]) {
            BOOL isAThirdParty = YES;
            NSString *fullPath = [[NSBundle mainBundle] pathForResource:worldName ofType:@"qsp" inDirectory:[self documentPath]];
            if (!fullPath) {
                isAThirdParty = NO;
                fullPath = [[NSBundle mainBundle] pathForResource:worldName ofType:@"qsp"];
            }
            [[QSPAdapter sharedQSPAdapter] loadGameWorld:fullPath];
            [[QSPAdapter sharedQSPAdapter] restartGame:YES];
            World *newWorld = [[World alloc] init];
            newWorld.relativePath = fullPath;
            NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:newWorld.relativePath];
            newWorld.name = worldName;
            newWorld.fileHash = [file hash];
            newWorld.description = [[[QSPAdapter sharedQSPAdapter] getMainDesc] stringByRemovinHTMLTags];
            newWorld.isThirdParty = isAThirdParty;
            newWorld.currentState = WorldStateReady;
            [newWorld registrate];
        }
    }
}

+ (void)saveObjects {
    NSString *path = [[self documentPath] stringByAppendingFormat:@"/worlds_register.dat"];
    [NSKeyedArchiver archiveRootObject:[self allObjects] toFile:path];
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

@end
