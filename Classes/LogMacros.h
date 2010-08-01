#define CALL_POINT() [NSString stringWithFormat:@"%@#%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]

#ifdef DEBUG

#define TRACE() NSLog(CALL_POINT(), nil)
#define LOG(args...) NSLog(@"%@", [NSString stringWithFormat:args])
#define LOGV(varname) NSLog(@"%s = %@", #varname, varname)
#define LOGD(varname) NSLog(@"%s = %d", #varname, varname)
#define LOGF(varname) NSLog(@"%s = %2.3f", #varname, varname)

#else

#define TRACE()
#define LOG(args...)
#define LOGV(varname)
#define LOGD(varname)
#define LOGF(varname)

#endif
