//
//  Constants.h
//  MineCraft
//
//  Created by L Ryan Crews on 1/19/13.
//  Copyright (c) 2013 Leonard Ryan Crews. All rights reserved.
//

#import <Foundation/Foundation.h>


// LOGGING MACROS
//
#ifdef DEBUG
#   define DebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DebugLog(...)
#endif

#define AlwaysLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


// DEVICE STUFF
//
#define DeviceDetails  ([NSString stringWithFormat:@"%@/%@/%@/app-release(%@)", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]])



@interface Constants : NSObject
@end
