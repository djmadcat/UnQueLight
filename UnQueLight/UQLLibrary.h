//
//  UQLLibrary.h
//  UnQueLight
//
//  Created by Alexey Aleshkov on 19.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import <Foundation/Foundation.h>


extern NSString *const UQLLibraryConfigPageSizeKey;
extern NSString *const UQLLibraryConfigStorageEngineKey;
extern NSString *const UQLLibraryConfigVFSKey;
extern NSString *const UQLLibraryConfigUserMemoryManagementKey;
extern NSString *const UQLLibraryConfigMemoryErrorCallbackKey;
extern NSString *const UQLLibraryConfigUserMutexManagementKey;
extern NSString *const UQLLibraryConfigThreadingModeKey;


typedef NS_ENUM(NSInteger, UQLLibraryThreadingMode) {
	UQLLibraryThreadingModeSingle = 0,
	UQLLibraryThreadingModeMulti = 1
};


typedef BOOL (^UQLMemoryErrorCallback)();


@interface UQLLibrary : NSObject

+ (void)startup;
+ (void)shutdown;
+ (BOOL)isInitialized;

+ (void)setConfig:(id)config forKey:(NSString *)key;

+ (NSString *)version;
+ (NSString *)signature;
+ (NSString *)ident;
+ (NSString *)copyright;

@end
