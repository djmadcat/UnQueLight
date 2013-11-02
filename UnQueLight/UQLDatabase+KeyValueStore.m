//
//  UQLDatabase+KeyValueStore.m
//  UnQueLight
//
//  Created by Alexey Aleshkov on 12.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLDatabase+KeyValueStore.h"
#import "UQLException.h"
#import "UQLError.h"
#import "UQLLog.h"


#undef UQLLogComponent
#define UQLLogComponent UQLlcl_cUnQueLightKeyValue


@implementation UQLDatabase (KeyValueStore)

- (NSData *)dataForRawKey:(NSData *)key
{
	if (!key) {
		UQLLogTrace(@"Null key provided for value fetching in database \"%@\"", self.path);
		return nil;
	}
	if (!_db) {
		UQLLogDebug(@"Can not get value from NULL database");
		return nil;
	}

	UQLLogTrace(@"Trying to fetch value in database \"%@\"", self.path);

	unqlite_int64 size = 0;
	int status = unqlite_kv_fetch(_db, [key bytes], (int)[key length], NULL, &size);
	if (status == UNQLITE_NOTFOUND) {
		return nil;
	}
	if (status == UNQLITE_NOMEM) {
		NSException *e = [NSException exceptionWithName:UQLOutOfMemoryException reason:@"Out of memory" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_IOERR) {
		NSException *e = [NSException exceptionWithName:UQLIOException reason:@"OS specific error" userInfo:nil];
		[e raise];
	}
	while (status == UNQLITE_BUSY) {
		[NSThread sleepForTimeInterval:20];
		status = unqlite_kv_fetch(_db, [key bytes], (int)[key length], NULL, &size);
	}
	if (status != UNQLITE_OK) {
		NSError *fetchError = UQLErrorForStatusCode(status);
		UQLLogError(@"Can not fetch value size in database \"%@\". Error returned %@", self.path, fetchError);

		return nil;
	} else {
		UQLLogTrace(@"Successful fetched value size in database \"%@\"", self.path);
	}

	NSMutableData *result = [NSMutableData dataWithLength:(NSUInteger)size];
	status = unqlite_kv_fetch(_db, [key bytes], (int)[key length], [result mutableBytes], &size);
	if (status == UNQLITE_NOTFOUND) {
		return nil;
	}
	if (status == UNQLITE_NOMEM) {
		NSException *e = [NSException exceptionWithName:UQLOutOfMemoryException reason:@"Out of memory" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_IOERR) {
		NSException *e = [NSException exceptionWithName:UQLIOException reason:@"OS specific error" userInfo:nil];
		[e raise];
	}
	while (status == UNQLITE_BUSY) {
		[NSThread sleepForTimeInterval:20];
		status = unqlite_kv_fetch(_db, [key bytes], (int)[key length], [result mutableBytes], &size);
	}
	if (status != UNQLITE_OK) {
		NSError *fetchError = UQLErrorForStatusCode(status);
		UQLLogError(@"Can not fetch value in database \"%@\". Error returned %@", self.path, fetchError);

		return nil;
	} else {
		UQLLogTrace(@"Successful fetched value in database \"%@\"", self.path);
	}

	return result;
}

- (void)storeData:(NSData *)data forRawKey:(NSData *)key
{
	NSAssert(key != nil, @"Attempt to store nil key");
	NSAssert(data != nil, @"Attempt to store nil value");

	if (!_db) {
		UQLLogDebug(@"Can not store value in NULL database");
		return;
	}

	UQLLogTrace(@"Trying to store value in database \"%@\"", self.path);

	int status = unqlite_kv_store(_db, [key bytes], (int)[key length], [data bytes], [data length]);
	while (status == UNQLITE_BUSY) {
		[NSThread sleepForTimeInterval:20];
		status = unqlite_kv_store(_db, [key bytes], (int)[key length], [data bytes], [data length]);
	}

	if (status == UNQLITE_READ_ONLY) {
		NSException *e = [NSException exceptionWithName:UQLReadOnlyException reason:@"You can not write in read-only Key/Value storage engine" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_NOTIMPLEMENTED) {
		NSException *e = [NSException exceptionWithName:UQLNotImplementedException reason:@"The underlying KV storage engine does not implement the xReplace() method" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_PERM) {
		NSException *e = [NSException exceptionWithName:UQLAccessDeniedException reason:@"Permission error" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_LIMIT) {
		NSException *e = [NSException exceptionWithName:UQLOutOfMemoryException reason:@"Journal file record limit reached" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_IOERR) {
		NSException *e = [NSException exceptionWithName:UQLIOException reason:@"OS specific error" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_NOMEM) {
		NSException *e = [NSException exceptionWithName:UQLOutOfMemoryException reason:@"Out of memory" userInfo:nil];
		[e raise];
	}

	if (status != UNQLITE_OK) {
		NSError *fetchError = UQLErrorForStatusCode(status);
		UQLLogError(@"Can not store value in database \"%@\". Error returned %@", self.path, fetchError);
	} else {
		UQLLogTrace(@"Successful stored value in database \"%@\"", self.path);
	}
}

- (void)appendData:(NSData *)data forRawKey:(NSData *)key
{
	NSAssert(key != nil, @"Attempt to append nil key");
	NSAssert(data != nil, @"Attempt to append nil value");

	if (!_db) {
		UQLLogDebug(@"Can not append value in NULL database");
		return;
	}

	UQLLogTrace(@"Trying to append value in database \"%@\"", self.path);

	int status = unqlite_kv_append(_db, [key bytes], (int)[key length], [data bytes], [data length]);
	while (status == UNQLITE_BUSY) {
		[NSThread sleepForTimeInterval:20];
		status = unqlite_kv_append(_db, [key bytes], (int)[key length], [data bytes], [data length]);
	}

	if (status == UNQLITE_READ_ONLY) {
		NSException *e = [NSException exceptionWithName:UQLReadOnlyException reason:@"You can not write in read-only Key/Value storage engine" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_NOTIMPLEMENTED) {
		NSException *e = [NSException exceptionWithName:UQLNotImplementedException reason:@"The underlying KV storage engine does not implement the xReplace() method" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_PERM) {
		NSException *e = [NSException exceptionWithName:UQLAccessDeniedException reason:@"Permission error" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_LIMIT) {
		NSException *e = [NSException exceptionWithName:UQLOutOfMemoryException reason:@"Journal file record limit reached" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_IOERR) {
		NSException *e = [NSException exceptionWithName:UQLIOException reason:@"OS specific error" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_NOMEM) {
		NSException *e = [NSException exceptionWithName:UQLOutOfMemoryException reason:@"Out of memory" userInfo:nil];
		[e raise];
	}

	if (status != UNQLITE_OK) {
		NSError *fetchError = UQLErrorForStatusCode(status);
		UQLLogError(@"Can not append value in database \"%@\". Error returned %@", self.path, fetchError);
	} else {
		UQLLogTrace(@"Successful appended value in database \"%@\"", self.path);
	}
}

- (void)removeDataForRawKey:(NSData *)key
{
	NSAssert(key != nil, @"Attempt to remove nil key");

	if (!_db) {
		UQLLogDebug(@"Can not remove value in NULL database");
		return;
	}

	UQLLogTrace(@"Trying to remove value in database \"%@\"", self.path);

	int status = unqlite_kv_delete(_db, [key bytes], (int)[key length]);
	if (status == UNQLITE_NOTFOUND) {
		return;
	}
	while (status == UNQLITE_BUSY) {
		[NSThread sleepForTimeInterval:20];
		status = unqlite_kv_delete(_db, [key bytes], (int)[key length]);
	}

	if (status == UNQLITE_READ_ONLY) {
		NSException *e = [NSException exceptionWithName:UQLReadOnlyException reason:@"You can not write in read-only Key/Value storage engine" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_NOTIMPLEMENTED) {
		NSException *e = [NSException exceptionWithName:UQLNotImplementedException reason:@"The underlying KV storage engine does not implement the xReplace() method" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_PERM) {
		NSException *e = [NSException exceptionWithName:UQLAccessDeniedException reason:@"Permission error" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_LIMIT) {
		NSException *e = [NSException exceptionWithName:UQLOutOfMemoryException reason:@"Journal file record limit reached" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_IOERR) {
		NSException *e = [NSException exceptionWithName:UQLIOException reason:@"OS specific error" userInfo:nil];
		[e raise];
	} else if (status == UNQLITE_NOMEM) {
		NSException *e = [NSException exceptionWithName:UQLOutOfMemoryException reason:@"Out of memory" userInfo:nil];
		[e raise];
	}

	if (status != UNQLITE_OK) {
		NSError *fetchError = UQLErrorForStatusCode(status);
		UQLLogError(@"Can not remove value in database \"%@\". Error returned %@", self.path, fetchError);
	} else {
		UQLLogTrace(@"Successful removed value in database \"%@\"", self.path);
	}
}

@end
