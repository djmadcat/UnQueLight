//
//  UQLLibrary.m
//  UnQueLight
//
//  Created by Alexey Aleshkov on 19.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLLibrary.h"
#include "unqlite.h"
#import "UQLLog.h"
#import "UQLError.h"


NSString *const UQLLibraryConfigPageSizeKey = @"UQLLibraryConfigPageSizeKey";
NSString *const UQLLibraryConfigStorageEngineKey = @"UQLLibraryConfigStorageEngineKey";
NSString *const UQLLibraryConfigVFSKey = @"UQLLibraryConfigVFSKey";
NSString *const UQLLibraryConfigUserMemoryManagementKey = @"UQLLibraryConfigUserMemoryManagementKey";
NSString *const UQLLibraryConfigMemoryErrorCallbackKey = @"UQLLibraryConfigMemoryErrorCallbackKey";
NSString *const UQLLibraryConfigUserMutexManagementKey = @"UQLLibraryConfigUserMutexManagementKey";
NSString *const UQLLibraryConfigThreadingModeKey = @"UQLLibraryConfigThreadingModeKey";


static BOOL sInitialized = NO;
static void *sMemoryErrorCallback = NULL;


static inline int UQLIsPowerOfTwo(unsigned int x)
{
	return ((x != 0) && ((x & (~x + 1)) == x));
}


@implementation UQLLibrary

+ (void)startup
{
	NSAssert([NSThread isMainThread], @"UnQLite must be initialized in main thread");
	NSAssert(unqlite_lib_is_threadsafe(), @"UnQLite must be compiled with threading support enabled");

	int status = unqlite_lib_init();
	NSAssert(status == UNQLITE_OK, @"UnQLite library can not be initialized");

	sInitialized = (status == UNQLITE_OK);
}

+ (void)shutdown
{
	if (!sInitialized) {
		return;
	}

	int status = unqlite_lib_shutdown();
	NSAssert(status == UNQLITE_OK, @"UnQLite library can not be deinitialized");

	if (status == UNQLITE_OK) {
		sInitialized = NO;
	}

	if (sMemoryErrorCallback) {
		Block_release(sMemoryErrorCallback);
		sMemoryErrorCallback = NULL;
	}
}

+ (BOOL)isInitialized
{
	return sInitialized;
}

static int memoryErrorCallback(void *pUserData)
{
	if (!pUserData) {
		return SXERR_ABORT;
	}
	UQLMemoryErrorCallback value = (__bridge UQLMemoryErrorCallback)pUserData;
	BOOL retry = value();
	return retry ? SXERR_RETRY : SXERR_ABORT;
}

+ (void)setConfig:(id)config forKey:(NSString *)key
{
	if (sInitialized) {
		UQLLogDebug(@"Can not set configuration for initialized library");
		return;
	}

	if ([key isEqualToString:UQLLibraryConfigPageSizeKey]) {
		NSAssert(config != nil, @"Value for %@ must be not nil", UQLLibraryConfigPageSizeKey);
		NSAssert([config isKindOfClass:[NSNumber class]], @"Value for %@ must be kind of class %@", UQLLibraryConfigPageSizeKey, NSStringFromClass([NSNumber class]));

		NSNumber *value = config;
		int pageSize = [value intValue];
		NSAssert(UQLIsPowerOfTwo(pageSize), @"Value for %@ must be a power of two", UQLLibraryConfigPageSizeKey);
		NSAssert(pageSize >= 512 && pageSize <= 65535, @"Value for %@ must be great or equal to 512 and less than or equal to 65535", UQLLibraryConfigPageSizeKey);

		int status = unqlite_lib_config(UNQLITE_LIB_CONFIG_PAGE_SIZE, pageSize);
		NSError *error = UQLErrorForStatusCode(status);
		if (error) {
			UQLLogWarning(@"unqlite_lib_config can not set UNQLITE_LIB_CONFIG_PAGE_SIZE to value %d", pageSize);
		}
	}

	if ([key isEqualToString:UQLLibraryConfigStorageEngineKey]) {
		UQLLogDebug(@"Switch to another Key/Value storage engine is unimplemented yet");
		//unqlite_kv_methods *pKvEngine
	}

	if ([key isEqualToString:UQLLibraryConfigVFSKey]) {
		NSAssert(config != nil, @"Value for %@ must be not nil", UQLLibraryConfigVFSKey);
		NSAssert([config isKindOfClass:[NSValue class]], @"Value for %@ must be kind of class %@", UQLLibraryConfigVFSKey, NSStringFromClass([NSValue class]));

		NSValue *value = config;
		const unqlite_vfs *pVfs = [value pointerValue];
		NSAssert(pVfs != NULL, @"Value for %@ must be not NULL", UQLLibraryConfigVFSKey);

		int status = unqlite_lib_config(UNQLITE_LIB_CONFIG_VFS, pVfs);
		NSError *error = UQLErrorForStatusCode(status);
		if (error) {
			UQLLogWarning(@"unqlite_lib_config can not set UNQLITE_LIB_CONFIG_VFS to value %p", pVfs);
		}
	}

	if ([key isEqualToString:UQLLibraryConfigUserMemoryManagementKey]) {
		NSAssert(config != nil, @"Value for %@ must be not nil", UQLLibraryConfigUserMemoryManagementKey);
		NSAssert([config isKindOfClass:[NSValue class]], @"Value for %@ must be kind of class %@", UQLLibraryConfigUserMemoryManagementKey, NSStringFromClass([NSValue class]));

		NSValue *value = config;
		const SyMemMethods *pMethods = [value pointerValue];
		NSAssert(pMethods != NULL, @"Value for %@ must be not NULL", UQLLibraryConfigUserMemoryManagementKey);

		int status = unqlite_lib_config(UNQLITE_LIB_CONFIG_USER_MALLOC, pMethods);
		NSError *error = UQLErrorForStatusCode(status);
		if (error) {
			UQLLogWarning(@"unqlite_lib_config can not set UNQLITE_LIB_CONFIG_USER_MALLOC to value %p", pMethods);
		}
	}

	if ([key isEqualToString:UQLLibraryConfigMemoryErrorCallbackKey]) {
		NSAssert(config != nil, @"Value for %@ must be not nil", UQLLibraryConfigMemoryErrorCallbackKey);
		NSAssert([config isKindOfClass:NSClassFromString(@"NSBlock")], @"Value for %@ must be kind of block", UQLLibraryConfigMemoryErrorCallbackKey);

		void *oldMemoryErrorCallback = sMemoryErrorCallback;
		sMemoryErrorCallback = config ? Block_copy((__bridge void *)config) : NULL;
		if (oldMemoryErrorCallback) {
			Block_release(oldMemoryErrorCallback);
		}

		int status = unqlite_lib_config(UNQLITE_LIB_CONFIG_MEM_ERR_CALLBACK, memoryErrorCallback, sMemoryErrorCallback);
		NSError *error = UQLErrorForStatusCode(status);
		if (error) {
			UQLLogWarning(@"unqlite_lib_config can not set UNQLITE_LIB_CONFIG_MEM_ERR_CALLBACK to value %p", sMemoryErrorCallback);
		}
	}

	if ([key isEqualToString:UQLLibraryConfigUserMutexManagementKey]) {
		NSAssert(config != nil, @"Value for %@ must be not nil", UQLLibraryConfigUserMutexManagementKey);
		NSAssert([config isKindOfClass:[NSValue class]], @"Value for %@ must be kind of class %@", UQLLibraryConfigUserMutexManagementKey, NSStringFromClass([NSValue class]));

		NSValue *value = config;
		const SyMutexMethods *pMethods = [value pointerValue];
		NSAssert(pMethods != NULL, @"Value for %@ must be not NULL", UQLLibraryConfigUserMutexManagementKey);

		int status = unqlite_lib_config(UNQLITE_LIB_CONFIG_USER_MUTEX, pMethods);
		NSError *error = UQLErrorForStatusCode(status);
		if (error) {
			UQLLogWarning(@"unqlite_lib_config can not set UNQLITE_LIB_CONFIG_USER_MUTEX to value %p", pMethods);
		}
	}

	if ([key isEqualToString:UQLLibraryConfigThreadingModeKey]) {
		NSAssert(config != nil, @"Value for %@ must be not nil", UQLLibraryConfigThreadingModeKey);
		NSAssert([config isKindOfClass:[NSNumber class]], @"Value for %@ must be kind of class %@", UQLLibraryConfigThreadingModeKey, NSStringFromClass([NSNumber class]));

		NSNumber *value = config;
		UQLLibraryThreadingMode threadingMode = (UQLLibraryThreadingMode)[value intValue];
		NSAssert(threadingMode == UQLLibraryThreadingModeSingle || threadingMode == UQLLibraryThreadingModeMulti, @"Value for %@ must be UQLLibraryThreadingModeSingle or UQLLibraryThreadingModeMulti", UQLLibraryConfigPageSizeKey);

		int status = UNQLITE_OK;
		if (threadingMode == UQLLibraryThreadingModeSingle) {
			status = unqlite_lib_config(UNQLITE_LIB_CONFIG_THREAD_LEVEL_SINGLE);
		} else {
			status = unqlite_lib_config(UNQLITE_LIB_CONFIG_THREAD_LEVEL_MULTI);
		}
		NSError *error = UQLErrorForStatusCode(status);
		if (error) {
			if (threadingMode == UQLLibraryThreadingModeSingle) {
				UQLLogWarning(@"unqlite_lib_config can not set threading mode to UNQLITE_LIB_CONFIG_THREAD_LEVEL_SINGLE");
			} else {
				UQLLogWarning(@"unqlite_lib_config can not set threading mode to UNQLITE_LIB_CONFIG_THREAD_LEVEL_MULTI");
			}
		}
	}
}

+ (NSString *)version
{
	static id _instance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		const char *result = unqlite_lib_version();
		_instance = [[NSString alloc] initWithCString:result encoding:NSUTF8StringEncoding];
	});

	return _instance;
}

+ (NSString *)signature
{
	static id _instance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		const char *result = unqlite_lib_signature();
		_instance = [[NSString alloc] initWithCString:result encoding:NSUTF8StringEncoding];
	});

	return _instance;
}

+ (NSString *)ident
{
	static id _instance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		const char *result = unqlite_lib_ident();
		_instance = [[NSString alloc] initWithCString:result encoding:NSUTF8StringEncoding];
	});

	return _instance;
}

+ (NSString *)copyright
{
	static id _instance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		const char *result = unqlite_lib_copyright();
		_instance = [[NSString alloc] initWithCString:result encoding:NSUTF8StringEncoding];
	});

	return _instance;
}

@end
