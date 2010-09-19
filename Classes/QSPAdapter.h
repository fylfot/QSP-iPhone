//
//  QSPAdapter.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 01.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StateData;
@class ActionData;
@class ObjectData;
@interface QSPAdapter : NSObject {
    BOOL worldLoaded;
    BOOL gameInProgress;

    CGFloat updateTime;
    NSInteger msecsFromLastCount;
    NSTimer *timer;
    BOOL isSleep;
}

@property (assign, readonly, getter=isWorldLoaded) BOOL worldLoaded;
@property (assign, readonly, getter=isGameInProgress) BOOL gameInProgress;
@property (assign) CGFloat updateTime;
@property (assign) BOOL isSleep;
@property (assign) NSInteger msecsFromLastCount;

- (void)beginGame;

// Tested

// SYSTEM
- (id)init;
- (void)updateTickTimerDelay:(NSNotification *)notification;
- (void)tickTimer;

- (void)deInit;

// ADAPTED
- (NSString *)getVersion;
- (NSString *)getMainDesc;
- (NSString *)getQstFullPath;

- (NSString *)getCurLoc;
- (BOOL)loadGameWorld:(NSString *)file;
- (BOOL)isMainDescChanged;
- (NSString *)getVarsDesc;
- (ActionData *)getActionData:(NSInteger)actionIndex;
- (ObjectData *)getObjectData:(NSInteger)actionIndex;
// Non tested

- (BOOL)isInCallBack;
- (void)enableDebugMode:(BOOL)isDebug;
- (StateData *)getCurrentStateData;
- (NSString *)getCompiledDateTime;
- (NSInteger)getFullRefreshCount;
- (BOOL)isVarsDescChanged;
- (void)setInputStringText:(NSString *)string;//(const QSP_CHAR *str);
- (NSInteger)getActionsCount;
- (BOOL)executeSelectedActionCode:(BOOL)isRefresh;
- (BOOL)setSelectedActionIndex:(NSInteger)actionIndex isRefresh:(BOOL)isRefresh;
- (NSInteger)getSelectedActionIndex;
- (BOOL)isActionsChanged;
- (NSInteger)getObjectsCount;
- (BOOL)setSelectedObjectIndex:(NSInteger)objectIndex isRefresh:(BOOL)isRefresh;
- (NSInteger)getSelectedObjectIndex;
- (BOOL)isObjectsChanged;
- (void)showWindow:(NSInteger)type isShow:(BOOL)isShow;
- (BOOL)getVarValuesCount:(NSString *)name forCount:(NSInteger *)count;
- (NSInteger)getMaxVarsCount;
- (BOOL)getVarNameByIndex:(NSInteger)index forName:(NSString **)name;
- (BOOL)execString:(NSString *)string isRefresh:(BOOL)isRefresh;
- (BOOL)execCounter:(BOOL)isRefresh;
- (BOOL)execUserInput:(BOOL)isRefresh;
- (BOOL)execLocationCode:(NSString *)name isRefresh:(BOOL)isRefresh;
- (NSString *)getErrorDesc:(NSInteger)errorNumber;
- (BOOL)loadGameWorldFromData:(NSData *)data fromFile:(NSString *)file;//(const char *data, int dataSize, const QSP_CHAR *file);
- (BOOL)saveGame:(NSString *)file isRefresh:(BOOL)isRefresh;
- (BOOL)openSavedGame:(NSString *)file isRefresh:(BOOL)isRefresh;
- (BOOL)restartGame:(BOOL)isRefresh;
- (void)selectMenuItem:(NSInteger)index;

- (NSError *)getLastErrorData;

SYNTHESIZE_SINGLETON_HEADER_FOR_CLASS(QSPAdapter);


/*
 BCOLOR // Background color (int32)
 FCOLOR // Fontcolor (int32)
 LCOLOR // Links color (int32)
 FSIZE  // Font size
 $FNAME // Font name
 USEHTML
 DISABLESCROLL // (not null, adding new line (no autoscroll))
 NOSAVE (not null, save accessed)
 $BACKIMAGE // Background image
 
 Replacement of 0x10 & 0x13 to <br />
 */

@end
