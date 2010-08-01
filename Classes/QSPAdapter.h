//
//  QSPAdapter.h
//  QSP
//
//  Created by Stanislav Cherednichenko on 01.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StateData;
@interface QSPAdapter : NSObject {
    
}

// Tested
- (id)init;

- (void)deInit;
- (NSString *)getVersion;
- (NSString *)getMainDesc;
- (NSString *)getQstFullPath;

// Non tested

- (BOOL)isInCallBack;
- (void)enableDebugMode:(BOOL)isDebug;
- (StateData *)getCurrentStateData;
- (NSString *)getCompiledDateTime;
- (NSInteger)getFullRefreshCount;
- (NSString *)getCurLoc;
- (BOOL)isMainDescChanged;
- (NSString *)getVarsDesc;
- (BOOL)isVarsDescChanged;
- (void)setInputStringText:(NSString *)string;//(const QSP_CHAR *str);
- (NSInteger)getActionsCount;
- (BOOL)executeSelectedActionCode:(BOOL)isRefresh;
- (BOOL)setSelActionIndex:(NSInteger)actionIndex isRefresh:(BOOL)isRefresh;
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
- (BOOL)loadGameWorld:(NSString *)file;
- (BOOL)loadGameWorldFromData:(NSData *)data fromFile:(NSString *)file;//(const char *data, int dataSize, const QSP_CHAR *file);
- (BOOL)saveGame:(NSString *)file isRefresh:(BOOL)isRefresh;
- (BOOL)openSavedGame:(NSString *)file isRefresh:(BOOL)isRefresh;
- (BOOL)restartGame:(BOOL)isRefresh;
- (void)selectMenuItem:(NSInteger)index;

- (NSError *)getLastErrorData;

SYNTHESIZE_SINGLETON_HEADER_FOR_CLASS(QSPAdapter);

@end
