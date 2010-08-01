/*
 *  ZMacros.h
 *  idevlib
 *
 *  Created by Sergey Zenchenko on 27.12.09.
 *  Copyright 2009 JAMG. All rights reserved.
 *
 */

#ifndef ATTR
#define ATTR @property (nonatomic, retain)
#endif

#ifndef READ
#define READ @property (readonly)
#endif

#ifndef NSARRAY
#define NSARRAY(args...) [NSArray arrayWithObjects:args, nil]
#endif

#ifndef EMPTY_ARRAY
#define EMPTY_ARRAY [NSArray array]
#endif

#ifndef NSDICT
#define NSDICT(args...) [NSDictionary dictionaryWithObjectsAndKeys:args, nil]
#endif

#ifndef EMPTY_DICT
#define EMPTY_DICT [NSDictionary dictionary]
#endif

#ifndef SYNTHESIZE_SORTING_DESCRIPTOR_FOR
#define SYNTHESIZE_SORTING_DESCRIPTOR_FOR(SORTING_ARG) \
- (id)localizedCaseInsensitiveCompare:(id)second { \
    return [SORTING_ARG localizedCaseInsensitiveCompare:second]; \
} \
- (id)length { \
    return [SORTING_ARG length]; \
} \
- (id)_fastCharacterContents { \
    return [SORTING_ARG _fastCharacterContents]; \
} \
- (void)getCharacters:(unichar *)charsters range:(NSRange)range { \
    [SORTING_ARG getCharacters:charsters range:range]; \
}

#endif