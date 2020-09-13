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

- (NSInteger)versionMajor
{
    NSInteger ret;
    return ([self getVersionMajor:&ret versionMinor:nil versionRevision:nil] ? ret : -1);
}

- (NSInteger)versionMinor
{
    NSInteger ret;
    return ([self getVersionMajor:nil versionMinor:&ret versionRevision:nil] ? ret : -1);
}

- (NSInteger)versionRevision
{
    NSInteger ret;
    return ([self getVersionMajor:nil versionMinor:nil versionRevision:&ret] ? ret : -1);
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

- (BOOL)getVersionMajor:(NSInteger *)outVersionMajor
           versionMinor:(NSInteger *)outVersionMinor
        versionRevision:(NSInteger *)outVersionRevision
{
    static BOOL success = NO;
    static NSInteger versionMajor = 0;
    static NSInteger versionMinor = 0;
    static NSInteger versionRevision = 0;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{

        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"([0-9]+)\\.([0-9]+)\\.([0-9]+)" options:0 error:nil];
        NSString *version = self.version;
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:version options:0 range:NSMakeRange(0, version.length)];
        if (matches.count == 0 || matches.firstObject.numberOfRanges != 4)
        {
            return;
        }
        
        versionMajor = [version substringWithRange:[matches.firstObject rangeAtIndex:1]].integerValue;
        versionMinor = [version substringWithRange:[matches.firstObject rangeAtIndex:2]].integerValue;
        versionRevision = [version substringWithRange:[matches.firstObject rangeAtIndex:3]].integerValue;
        success = YES;
        
    });
    
    if (outVersionMajor) { *outVersionMajor = versionMajor; }
    if (outVersionMinor) { *outVersionMinor = versionMinor; }
    if (outVersionRevision) { *outVersionRevision = versionRevision; }
    return success;
}

@end
