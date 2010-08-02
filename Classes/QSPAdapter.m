//
//  QSPAdapter.m
//  QSP
//
//  Created by Stanislav Cherednichenko on 01.08.10.
//  Copyright 2010 JAMG. All rights reserved.
//

#import "QSPAdapter.h"
#import "qsp.h"
#import "StateData.h"
#import "ActionData.h"
#import "ObjectData.h"
#include <wchar.h>

#define wideCharStringFromString(XXX) ((QSP_CHAR *)[XXX cStringUsingEncoding:NSUTF32LittleEndianStringEncoding])
#define stringWithWideCharString(XXX) ((XXX != nil) ? ((NSString *)CFStringCreateWithBytes(nil, (const UInt8 *)XXX, wcslen(XXX) * 4, kCFStringEncodingUTF32LE, YES)) : nil)

@implementation QSPAdapter

@synthesize worldLoaded, gameInProgress;

SYNTHESIZE_SINGLETON_FOR_CLASS(QSPAdapter);

- (void)beginGame {
    gameInProgress = YES;
}

/*
 Above we have wrapped C functions calls:
 QSP_EXTERN QSP_BOOL QSPIsInCallBack();
 QSP_EXTERN void QSPEnableDebugMode(QSP_BOOL isDebug);
 QSP_EXTERN void QSPGetCurStateData(QSP_CHAR **loc, int *actIndex, int *line);
 QSP_EXTERN const QSP_CHAR *QSPGetVersion();
 QSP_EXTERN const QSP_CHAR *QSPGetCompiledDateTime();
 QSP_EXTERN int QSPGetFullRefreshCount();
 QSP_EXTERN const QSP_CHAR *QSPGetQstFullPath();
 QSP_EXTERN const QSP_CHAR *QSPGetCurLoc();
 QSP_EXTERN const QSP_CHAR *QSPGetMainDesc();
 QSP_EXTERN QSP_BOOL QSPIsMainDescChanged();
 QSP_EXTERN const QSP_CHAR *QSPGetVarsDesc();
 QSP_EXTERN QSP_BOOL QSPIsVarsDescChanged();
 QSP_EXTERN QSP_BOOL QSPGetExprValue(const QSP_CHAR *str, QSP_BOOL *isString, int *numVal, QSP_CHAR *strVal, int strValBufSize);
 QSP_EXTERN void QSPSetInputStrText(const QSP_CHAR *str);
 QSP_EXTERN int QSPGetActionsCount();
 QSP_EXTERN void QSPGetActionData(int ind, QSP_CHAR **imgPath, QSP_CHAR **desc);
 QSP_EXTERN QSP_BOOL QSPExecuteSelActionCode(QSP_BOOL isRefresh);
 QSP_EXTERN QSP_BOOL QSPSetSelActionIndex(int ind, QSP_BOOL isRefresh);
 QSP_EXTERN int QSPGetSelActionIndex();
 QSP_EXTERN QSP_BOOL QSPIsActionsChanged();
 QSP_EXTERN int QSPGetObjectsCount();
 QSP_EXTERN void QSPGetObjectData(int ind, QSP_CHAR **imgPath, QSP_CHAR **desc);
 QSP_EXTERN QSP_BOOL QSPSetSelObjectIndex(int ind, QSP_BOOL isRefresh);
 QSP_EXTERN int QSPGetSelObjectIndex();
 QSP_EXTERN QSP_BOOL QSPIsObjectsChanged();
 QSP_EXTERN void QSPShowWindow(int type, QSP_BOOL isShow);
 QSP_EXTERN QSP_BOOL QSPGetVarValuesCount(const QSP_CHAR *name, int *count);
 QSP_EXTERN QSP_BOOL QSPGetVarValues(const QSP_CHAR *name, int ind, int *numVal, QSP_CHAR **strVal);
 QSP_EXTERN int QSPGetMaxVarsCount();
 QSP_EXTERN QSP_BOOL QSPGetVarNameByIndex(int ind, QSP_CHAR **name);
 QSP_EXTERN QSP_BOOL QSPExecString(const QSP_CHAR *str, QSP_BOOL isRefresh);
 QSP_EXTERN QSP_BOOL QSPExecCounter(QSP_BOOL isRefresh);
 QSP_EXTERN QSP_BOOL QSPExecUserInput(QSP_BOOL isRefresh);
 QSP_EXTERN QSP_BOOL QSPExecLocationCode(const QSP_CHAR *name, QSP_BOOL isRefresh);
 QSP_EXTERN void QSPGetLastErrorData(int *errorNum, QSP_CHAR **errorLoc, int *errorActIndex, int *errorLine);
 QSP_EXTERN const QSP_CHAR *QSPGetErrorDesc(int errorNum);
 QSP_EXTERN QSP_BOOL QSPLoadGameWorld(const QSP_CHAR *file);
 QSP_EXTERN QSP_BOOL QSPLoadGameWorldFromData(const char *data, int dataSize, const QSP_CHAR *file);
 QSP_EXTERN QSP_BOOL QSPSaveGame(const QSP_CHAR *file, QSP_BOOL isRefresh);
 QSP_EXTERN QSP_BOOL QSPSaveGameAsString(QSP_CHAR *strBuf, int strBufSize, int *realSize, QSP_BOOL isRefresh);
 QSP_EXTERN QSP_BOOL QSPOpenSavedGame(const QSP_CHAR *file, QSP_BOOL isRefresh);
 QSP_EXTERN QSP_BOOL QSPOpenSavedGameFromString(const QSP_CHAR *str, QSP_BOOL isRefresh);
 QSP_EXTERN QSP_BOOL QSPRestartGame(QSP_BOOL isRefresh);
 QSP_EXTERN void QSPSelectMenuItem(int ind);
 QSP_EXTERN void QSPSetCallBack(int type, QSP_CALLBACK func);
 QSP_EXTERN void QSPInit();
 QSP_EXTERN void QSPDeInit();
 */

- (id)init {
//    [NSString stringWithWideCharString:];
    self = [super init];
    if (self) {
        QSPInit();
    }
    return self;
}

- (void)deInit {
    QSPDeInit();
}

- (BOOL)isInCallBack {
    return QSPIsInCallBack();
}

- (void)enableDebugMode:(BOOL)isDebug {
    QSPEnableDebugMode(isDebug);
}

#pragma warning Can be errors;
- (StateData *)getCurrentStateData {
    StateData *stateData = [[StateData alloc] init];
    QSP_CHAR *loc = nil;
    int actIndex = INT_MAX;
    int line = INT_MAX;
    QSPGetCurStateData(&loc, &actIndex, &line);
    
    [stateData setLine:line];
    [stateData setActionIndex:actIndex];
    [stateData setLocation:stringWithWideCharString(loc)];
    
    return [stateData autorelease];
}

- (NSString *)getVersion {
    return stringWithWideCharString(QSPGetVersion());
}

- (NSString *)getCompiledDateTime {
    return stringWithWideCharString(QSPGetCompiledDateTime());
}

- (NSInteger)getFullRefreshCount {
    return QSPGetFullRefreshCount();
}

- (NSString *)getQstFullPath {
    return stringWithWideCharString(QSPGetQstFullPath());
}

- (NSString *)getCurLoc {
    return stringWithWideCharString(QSPGetCurLoc());
}

// 2
- (NSString *)getMainDesc {
    return stringWithWideCharString(QSPGetMainDesc());
}

- (BOOL)isMainDescChanged {
    return QSPIsMainDescChanged();
}

- (NSString *)getVarsDesc {
    return stringWithWideCharString(QSPGetVarsDesc());
}

- (BOOL)isVarsDescChanged {
    return QSPIsVarsDescChanged();
}

- (void)setInputStringText:(NSString *)string {
    QSPSetInputStrText(wideCharStringFromString(string));
}

- (NSInteger)getActionsCount {
    return QSPGetActionsCount();
}

- (BOOL)executeSelectedActionCode:(BOOL)isRefresh {
    return QSPExecuteSelActionCode(isRefresh);
}

- (BOOL)setSelectedActionIndex:(NSInteger)actionIndex isRefresh:(BOOL)isRefresh {
    return QSPSetSelActionIndex(actionIndex, isRefresh);
}

- (NSInteger)getSelectedActionIndex {
    return QSPGetSelActionIndex();
}

- (BOOL)isActionsChanged {
    return QSPIsActionsChanged();
}

- (NSInteger)getObjectsCount {
    return QSPGetObjectsCount();
}

- (BOOL)setSelectedObjectIndex:(NSInteger)objectIndex isRefresh:(BOOL)isRefresh {
    return QSPSetSelObjectIndex(objectIndex, isRefresh);
}

- (NSInteger)getSelectedObjectIndex {
    return QSPGetSelObjectIndex();
}

- (BOOL)isObjectsChanged {
    return QSPIsObjectsChanged();
}

#pragma warning Don't know how it works;
- (void)showWindow:(NSInteger)type isShow:(BOOL)isShow {
    QSPShowWindow(type, isShow);
}

- (BOOL)getVarValuesCount:(NSString *)name forCount:(NSInteger *)count {
    return QSPGetVarValuesCount(wideCharStringFromString(name), count);
}

- (NSInteger)getMaxVarsCount {
    return QSPGetMaxVarsCount();
}

#pragma warning Can be errors;
- (BOOL)getVarNameByIndex:(NSInteger)index forName:(NSString **)name {
    QSP_CHAR *cName = nil;
    BOOL result = QSPGetVarNameByIndex(index, &cName);
    *name = stringWithWideCharString(cName);
    return result;
}

- (BOOL)execString:(NSString *)string isRefresh:(BOOL)isRefresh {
    return QSPExecString(wideCharStringFromString(string), isRefresh);
}

- (BOOL)execCounter:(BOOL)isRefresh {
    return QSPExecCounter(isRefresh);
}

- (BOOL)execUserInput:(BOOL)isRefresh {
    return QSPExecUserInput(isRefresh);
}

- (BOOL)execLocationCode:(NSString *)name isRefresh:(BOOL)isRefresh {
    return QSPExecLocationCode(wideCharStringFromString(name), isRefresh);
}

- (NSString *)getErrorDesc:(NSInteger)errorNumber {
    return stringWithWideCharString(QSPGetErrorDesc(errorNumber));
}

#pragma warning Can be errors;
- (BOOL)loadGameWorld:(NSString *)file {
    BOOL result = QSPLoadGameWorld(wideCharStringFromString(file));
    worldLoaded = result;
    return result;
}

#pragma warning Can be errors;
- (BOOL)loadGameWorldFromData:(NSData *)data fromFile:(NSString *)file {
    BOOL result = QSPLoadGameWorldFromData([data bytes], [data length], wideCharStringFromString(file));
    worldLoaded = result;
    return result;
}

- (BOOL)saveGame:(NSString *)file isRefresh:(BOOL)isRefresh {
    return QSPSaveGame(wideCharStringFromString(file), isRefresh);
}

- (BOOL)openSavedGame:(NSString *)file isRefresh:(BOOL)isRefresh {
    return QSPOpenSavedGame(wideCharStringFromString(file), isRefresh);
}

- (BOOL)restartGame:(BOOL)isRefresh {
    return QSPRestartGame(isRefresh);
}

- (void)selectMenuItem:(NSInteger)index {
    QSPSelectMenuItem(index);
}

//- (BOOL)getExprValue(const QSP_CHAR *str, QSP_BOOL *isString, int *numVal, QSP_CHAR *strVal, int strValBufSize);

#pragma warning Can be errors;
- (BOOL)getExpressionValue:(NSString *)string isString:(BOOL *)isString forNumberValue:(NSInteger *)numberValue forStringValue:(NSString *)stringValue {
    QSP_CHAR *cString = malloc(sizeof(char) * 1024);
    cString[1023] = 0x00; // For conversation to NSString
    BOOL result = QSPGetExprValue(wideCharStringFromString(string), &isString, &numberValue, cString, 1024);
    stringValue = stringWithWideCharString(cString);
    return result;
}

//- (void)getActionData(int ind, QSP_CHAR **imgPath, QSP_CHAR **desc);

#pragma warning Can be errors;
- (ActionData *)getActionData:(NSInteger)actionIndex {
    ActionData *actionData = [[ActionData alloc] init];
    QSP_CHAR *imgPath = nil;
    QSP_CHAR *desc = nil;
    
    QSPGetActionData(actionIndex, &imgPath, &desc);
    
    [actionData setIndex:actionIndex];
    [actionData setDescription:stringWithWideCharString(desc)];
    [actionData setImagePath:stringWithWideCharString(imgPath)];
    
    return [actionData autorelease];
    
}

//- (void)getObjectData:(NSInteger)objectIndex forPath:(NSString **)imgPath forDescription:(NSString **)desc;

#pragma warning Can be errors;
- (ObjectData *)getObjectData:(NSInteger)actionIndex {
    ObjectData *objectData = [[ObjectData alloc] init];
    QSP_CHAR *imgPath = nil;
    QSP_CHAR *desc = nil;
    
    QSPGetObjectData(actionIndex, &imgPath, &desc);
    
    [objectData setIndex:actionIndex];
    [objectData setDescription:stringWithWideCharString(desc)];
    [objectData setImagePath:stringWithWideCharString(imgPath)];
    
    return [objectData autorelease];
}

//- (BOOL)getVarValues(const QSP_CHAR *name, int ind, int *numVal, QSP_CHAR **strVal);
/*
#pragma warning Can be errors;
- (BOOL)getVariableValues:(NSString *)name withIndex:(NSString)index withNumberValue:(NSInteger *)numberValue forString:(NSString **)string {
    QSP_CHAR *cStrValue = nil;
    BOOL result = QSPGetVarValues(wideCharStringFromString(name), index, &numberValue, &cStrValue);
    &string = stringWithWideCharString(cStrValue);
    return result;
}
 */

#pragma warning Can be errors;
//- (void)getLastErrorData(int *errorNum, QSP_CHAR **errorLoc, int *errorActIndex, int *errorLine);
- (NSError *)getLastErrorData {
    NSInteger errorNum;
    QSP_CHAR *errorLoc = nil;
    NSInteger errorActIndex;
    NSInteger errorLine;
    
    
    // ERROR Enum 1st arg
    QSPGetLastErrorData(&errorNum, &errorLoc, &errorActIndex, &errorLine);
    
    NSError *result = [[NSError alloc] initWithDomain:@"com.jamg.opensource.qsp" code:errorNum userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:errorActIndex], @"ErrorActionIndex", [NSNumber numberWithInt:errorLine], @"ErrorLine", stringWithWideCharString(errorLoc), @"errorLocation"]];
    return [result autorelease];
}

//- (BOOL)saveGameAsString(QSP_CHAR *strBuf, int strBufSize, int *realSize, QSP_BOOL isRefresh);

/*
#pragma warning Can be errors;
- (BOOL)saveGameAsString:(NSString **)string isRefresh:(BOOL)isRefresh {
    char *cString = malloc(sizeof(char) * 1024);
    cString[1023] = 0x00; // For conversation to NSString
    NSInteger realSize = 0;
    BOOL result = QSPSaveGameAsString(cString, 1024, &realSize, isRefresh);
    &string = stringWithWideCharString(cString);
#pragma warning Unused variable;
    
    return result;
}
 */

//- (BOOL)openSavedGameFromString(const QSP_CHAR *str, QSP_BOOL isRefresh);
#pragma warning Can be errors;
- (BOOL)openSavedGameFromString:(NSString *)string isRefresh:(BOOL)isRefresh {
    return QSPOpenSavedGame(wideCharStringFromString(string), isRefresh);
}

//- (void)setCallBack:(QSP_CALL_ENUM)callbackType forSelector(SEL)callback;

#pragma warning Can be errors;
//- (void)setCallBack:(QSP_CALL_ENUM)callbackType forSelector(SEL)callback {
//#pragma warning TODO;
//}

@end
