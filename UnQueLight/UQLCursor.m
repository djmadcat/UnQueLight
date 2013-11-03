//
//  UQLCursor.m
//  UnQueLight
//
//  Created by Alexey Aleshkov on 06.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLCursor.h"
#import "UQLError.h"
#import "UQLLog.h"


@interface UQLCursor ()
@property (nonatomic, strong, readwrite) UQLDatabase *database;
@end


@implementation UQLCursor

#pragma mark -
#pragma mark Init / Dealloc

- (id)initWithDatabase:(UQLDatabase *)database error:(NSError **)error
{
	UQLLogTrace(@"Creating cursor for database \"%@\"", database.path);

	if (!database) {
		UQLLogDebug(@"Failed to create cursor for NULL database");
		return nil;
	}

	self = [super init];
	if (!self) {
		return nil;
	}

	self.database = database;

	unqlite *db = [self.database unqliteHandle];
	int status = unqlite_kv_cursor_init(db, &_cursor);
	if (status != UNQLITE_OK) {
		NSError *initError = nil;
		if (status == UNQLITE_CORRUPT) {
			initError = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Corrupted database pointer" }];
		} else if (status == UNQLITE_ABORT) {
			initError = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Another thread have released the database handle" }];
		} else if (status == UNQLITE_NOTIMPLEMENTED) {
			initError = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Storage engine does not support cursors" }];
		} else if (status == UNQLITE_NOMEM) {
			initError = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Out of memory" }];
		}
		NSAssert(initError != nil, @"Unhandled error returned: %d", status);

		UQLLogError(@"Cursor for database \"%@\" can not be created. Error returned %@", self.database.path, initError);
		if (error) {
			*error = initError;
		}

		return nil;
	}

	NSAssert(_cursor != NULL, @"Something going wrong! ivar can not be NULL");

	UQLLogTrace(@"Successful created cursor for database \"%@\"", self.database.path);

	return self;
}

- (void)dealloc
{
	UQLLogTrace(@"Trying to release cursor for database \"%@\"", self.database.path);

	NSAssert(_cursor != NULL, @"Something going wrong! ivar can not be NULL");

	int status = unqlite_kv_cursor_release([self.database unqliteHandle], _cursor);
	if (status != UNQLITE_OK) {
		NSError *deallocError = nil;
		if (status == UNQLITE_CORRUPT) {
			deallocError = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Another thread have released the database or cursor handle" }];
		} else if (status == UNQLITE_ABORT) {
			deallocError = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Corrupted database or cursor pointer" }];
		}
		NSAssert(deallocError != nil, @"Unhandled error returned");

		UQLLogWarning(@"Cursor for database \"%@\" can not be released properly. Error returned %@", self.database.path, deallocError);
	} else {
		UQLLogTrace(@"Successful released cursor for database \"%@\"", self.database.path);
	}

	_cursor = NULL;
}

- (void)reset
{
	int status = unqlite_kv_cursor_reset(_cursor);
	NSAssert(status != UNQLITE_CORRUPT, @"Cursor pointer is corrupted");
}

#pragma mark -
#pragma mark Positioning

- (BOOL)isValid
{
	BOOL result = unqlite_kv_cursor_valid_entry(_cursor);
	return result;
}

- (BOOL)seekForRawKey:(NSData *)key match:(UQLCursorSeekMatch)match
{
	int status = unqlite_kv_cursor_seek(_cursor, [key bytes], (int)[key length], match);
	return status == UNQLITE_OK;
}

- (BOOL)first
{
	int status = unqlite_kv_cursor_first_entry(_cursor);
	return status == UNQLITE_OK;
}

- (BOOL)last
{
	int status = unqlite_kv_cursor_last_entry(_cursor);
	return status == UNQLITE_OK;
}

- (BOOL)next
{
	int status = unqlite_kv_cursor_next_entry(_cursor);
	return status == UNQLITE_OK;
}

- (BOOL)previous
{
	int status = unqlite_kv_cursor_prev_entry(_cursor);
	return status == UNQLITE_OK;
}

#pragma mark -
#pragma mark Deleting records

- (BOOL)remove
{
	int status = unqlite_kv_cursor_delete_entry(_cursor);
	return status == UNQLITE_OK;
}

#pragma mark -
#pragma mark Extracting data

static int fetchCallback(const void *pData, unsigned int iDataLen, void *pUserData)
{
	UQLDataCallback block = (__bridge UQLDataCallback)pUserData;

	NSData *data = [[NSData alloc] initWithBytesNoCopy:(void *)pData length:iDataLen freeWhenDone:NO];
	BOOL success = block(data);

	return success ? UNQLITE_OK : UNQLITE_ABORT;
}

- (NSData *)rawKey
{
	int size = 0;
	int status = unqlite_kv_cursor_key(_cursor, NULL, &size);
	if (status != UNQLITE_OK) {
		return nil;
	}
	NSMutableData *result = [NSMutableData dataWithLength:size];
	status = unqlite_kv_cursor_key(_cursor, [result mutableBytes], &size);
	if (status != UNQLITE_OK) {
		return nil;
	}

	return result;
}

- (void)rawKeyWithCallback:(UQLDataCallback)callback
{
	void *block = Block_copy((__bridge void *)callback);
	unqlite_kv_cursor_key_callback(_cursor, fetchCallback, block);
	Block_release(block);
}

- (NSData *)rawValue
{
	unqlite_int64 size = 0;
	int status = unqlite_kv_cursor_data(_cursor, NULL, &size);
	if (status != UNQLITE_OK) {
		return nil;
	}
	NSMutableData *result = [NSMutableData dataWithLength:size];
	status = unqlite_kv_cursor_data(_cursor, [result mutableBytes], &size);
	if (status != UNQLITE_OK) {
		return nil;
	}

	return result;
}

- (void)rawValueWithCallback:(UQLDataCallback)callback
{
	void *block = Block_copy((__bridge void *)callback);
	unqlite_kv_cursor_data_callback(_cursor, fetchCallback, block);
	Block_release(block);
}

#pragma mark -
#pragma mark Low-level methods

- (unqlite_kv_cursor *)unqliteHandle
{
	return _cursor;
}

@end
