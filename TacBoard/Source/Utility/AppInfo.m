//
//  AppInfo.m
//  TacBoard
//
//  Created by Vig, Christopher on 8/12/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppInfo.h"
#import "Version.h"

@implementation AppInfo

#pragma mark Initialization / Singleton

+ (AppInfo *)sharedInstance
{
    static AppInfo *sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[AppInfo alloc] initPrivate];
    });
    return sharedInstance;
}

- (instancetype)initPrivate
{
    return [super init];
}

#pragma mark Properties

- (NSString *)name
{
    return [self stringForKey:@"CFBundleName"];
}

- (NSString *)version
{
    return [self stringForKey:@"CFBundleShortVersionString"];
}

- (NSString *)build
{
    return [self stringForKey:@"CFBundleVersion"];
}

- (NSDate *)date
{
    return [NSDate dateWithTimeIntervalSince1970:BUILD_DATE];
}

- (NSString *)commit
{
    return GIT_COMMIT;
}

#pragma mark Private Utility

- (NSString *)stringForKey:(NSString *)key
{
    id<NSObject> value = NSBundle.mainBundle.infoDictionary[key];
    return ([value isKindOfClass:NSString.class] ? (NSString *)value : NSString.string);
}

@end
