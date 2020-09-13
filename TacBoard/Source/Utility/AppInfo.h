//
//  AppInfo.h
//  TacBoard
//
//  Created by Vig, Christopher on 8/12/20.
//  Copyright © 2020 Christopher Vig. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Class containing information about the current build of the application.
 */
@interface AppInfo : NSObject

#pragma mark Initialization / Singleton

/** The shared instance of this class. */
@property (class, nonatomic, readonly) AppInfo *sharedInstance
NS_SWIFT_NAME(shared);

- (instancetype)init NS_UNAVAILABLE;

#pragma mark Properties

/** The display name of the application. */
@property (nonatomic, readonly) NSString *name;

/** The version string of the application. */
@property (nonatomic, readonly) NSString *version;

/** The major version number of the application. */
@property (nonatomic, readonly) NSInteger versionMajor;

/** The minor version number of the application. */
@property (nonatomic, readonly) NSInteger versionMinor;

/** The revision version number of the application. */
@property (nonatomic, readonly) NSInteger versionRevision;

/** The build number of the application. */
@property (nonatomic, readonly) NSString *build;

/** The build date of the application. */
@property (nonatomic, readonly) NSDate *date;

/** The Git commit hash of the application. */
@property (nonatomic, readonly) NSString *commit;

@end

NS_ASSUME_NONNULL_END
