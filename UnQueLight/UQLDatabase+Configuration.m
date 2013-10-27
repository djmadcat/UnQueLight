//
//  UQLDatabase+Configuration.m
//  UnQueLight
//
//  Created by Alexey Aleshkov on 14.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLDatabase+Configuration.h"
#import "UQLError.h"
#import "UQLLog.h"


NSString *const UQLConfigKeyValueStorageEngineKey = @"UQLConfigKeyValueStorageEngineKey";
NSString *const UQLConfigDisableAutoCommitKey = @"UQLConfigDisableAutoCommitKey";
NSString *const UQLConfigMaxPageCacheKey = @"UQLConfigMaxPageCacheKey";

NSString *const UQLConfigErrorLogKey = @"UQLConfigErrorLogKey";
NSString *const UQLConfigJx9ErrorLogKey = @"UQLConfigJx9ErrorLogKey";


@implementation UQLDatabase (Configuration)

- (id)configForKey:(NSString *)key
{
	if (!_db) {
		UQLLogDebug(@"Can not get configuration for NULL database", nil);
		return nil;
	}

	if ([key isEqualToString:UQLConfigErrorLogKey]) {
		const char *zPtr = NULL;
		int nLen = 0;

		int status = unqlite_config(_db, UNQLITE_CONFIG_ERR_LOG, &zPtr, &nLen);
		NSAssert(status == UNQLITE_OK, @"unqlite_config with UNQLITE_CONFIG_ERR_LOG command can not return error");

		NSString *result = [[NSString alloc] initWithBytes:zPtr length:nLen encoding:NSUTF8StringEncoding];
		return result;
	}

	if ([key isEqualToString:UQLConfigJx9ErrorLogKey]) {
		const char *zPtr = NULL;
		int nLen = 0;

		int status = unqlite_config(_db, UNQLITE_CONFIG_JX9_ERR_LOG, &zPtr, &nLen);
		NSAssert(status == UNQLITE_OK, @"unqlite_config with UNQLITE_CONFIG_JX9_ERR_LOG command can not return error");

		NSString *result = [[NSString alloc] initWithBytes:zPtr length:nLen encoding:NSUTF8StringEncoding];
		return result;
	}

	if ([key isEqualToString:UQLConfigKeyValueStorageEngineKey]) {
		const char *keyValueStorageEngine = NULL;
		int status = unqlite_config(_db, UNQLITE_CONFIG_GET_KV_NAME, &keyValueStorageEngine);
		NSAssert(status == UNQLITE_OK, @"unqlite_config with UNQLITE_CONFIG_GET_KV_NAME command can not return error");
		
		NSString *result = [[NSString alloc] initWithCString:keyValueStorageEngine encoding:NSUTF8StringEncoding];
		return result;
	}

	return nil;
}

- (void)setConfig:(id)config forKey:(NSString *)key
{
	if (!_db) {
		UQLLogDebug(@"Can not set configuration for NULL database", nil);
		return;
	}

	if ([key isEqualToString:UQLConfigKeyValueStorageEngineKey]) {
		//UNQLITE_CONFIG_KV_ENGINE
		UQLLogDebug(@"Switch to another Key/Value storage engine is unimplemented yet", nil);
	}
	if ([key isEqualToString:UQLConfigDisableAutoCommitKey]) {
		int status = unqlite_config(_db, UNQLITE_CONFIG_DISABLE_AUTO_COMMIT);
		NSAssert(status == UNQLITE_OK, @"unqlite_config with UNQLITE_CONFIG_DISABLE_AUTO_COMMIT command can not return error");
	}
	if ([key isEqualToString:UQLConfigMaxPageCacheKey]) {
		NSAssert([config isKindOfClass:[NSNumber class]], @"Value for %@ must be kind of class %@", UQLConfigMaxPageCacheKey, NSStringFromClass([NSNumber class]));

		NSNumber *value = config;
		int maxPage = [value intValue];
		NSAssert(maxPage > 0, @"Value for %@ must be great or equal to 0", UQLConfigMaxPageCacheKey);

		int status = unqlite_config(_db, UNQLITE_CONFIG_MAX_PAGE_CACHE, maxPage);
		NSError *error = UQLErrorForStatusCode(status);
		if (error) {
			UQLLogWarning(@"unqlite_config can not set UNQLITE_CONFIG_MAX_PAGE_CACHE to value %d for database \"%@\"", maxPage, self.path);
		}
	}
}

@end
