//
//  UQLDatabase.m
//  UnQueLight
//
//  Created by Alexey Aleshkov on 05.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLDatabase.h"
#import "UQLError.h"
#import "UQLLog.h"


@interface UQLDatabase ()
@property (nonatomic, copy, readwrite) NSString *path;
@end


@implementation UQLDatabase

+ (instancetype)database
{
	return [[[self class] alloc] init];
}

+ (instancetype)databaseWithPath:(NSString *)path
{
	return [[[self class] alloc] initWithPath:path];
}

#pragma mark -
#pragma mark Init / Dealloc

- (instancetype)init
{
	self = [super init];
	if (!self) {
		return nil;
	}

	_releaseWhenDone = YES;

	UQLLogTrace(@"Creating database \"%@\"", self.path);

	return self;
}

- (instancetype)initWithPath:(NSString *)path
{
	self = [super init];
	if (!self) {
		return nil;
	}

	self.path = path;
	_releaseWhenDone = YES;

	UQLLogTrace(@"Creating database \"%@\"", self.path);

	return self;
}

- (void)dealloc
{
	if (_releaseWhenDone) {
		[self close];
	}
}

#pragma mark -
#pragma mark Open / Close

- (BOOL)openWithOptions:(UQLOpenOptions)options error:(NSError **)error
{
	if (_handle) {
		return YES;
	}

	UQLLogTrace(@"Trying to open database \"%@\"", self.path);

	const char *path = [self unqlitePath];
	int status = unqlite_open(&_handle, path, options);

	if (status == UNQLITE_NOMEM) {
		NSError *openError = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Out of memory" }];
		UQLLogError(@"Can not open database \"%@\" with options %lu. Error returned %@", self.path, options, openError);
		if (error) {
			*error = openError;
		}
	}
	if (status == UNQLITE_OK) {
		UQLLogTrace(@"Successful opened database \"%@\"", self.path);
	}

	return status == UNQLITE_OK;
}

- (BOOL)close
{
	if (!_handle) {
		return YES;
	}

	UQLLogTrace(@"Trying to close database \"%@\"", self.path);

	int status = unqlite_close(_handle);
	while (status == UNQLITE_BUSY) {
		[NSThread sleepForTimeInterval:20];
		status = unqlite_close(_handle);
	}

	if (status == UNQLITE_ABORT) {
		NSError *error = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Another thread have released the database handle" }];
		UQLLogError(@"Database \"%@\" already closed in another thread. Error returned %@", self.path, error);

		_handle = NULL;

		return YES;
	}
	if (status == UNQLITE_IOERR) {
		NSError *error = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"OS specific error" }];
		UQLLogError(@"Can not close database \"%@\" properly. Error returned %@", self.path, error);

		_handle = NULL;

		return YES;
	}

	if (status == UNQLITE_OK) {
		UQLLogTrace(@"Successful closed database \"%@\"", self.path);

		_handle = NULL;

		return YES;
	}

	return status == UNQLITE_OK;
}

- (BOOL)isOpen
{
	BOOL result = _handle != NULL;
	return result;
}

#pragma mark -
#pragma mark Low-level methods

- (instancetype)initWithHandle:(unqlite *)handle path:(const char *)path releaseWhenDone:(BOOL)releaseWhenDone
{
	if (!handle) {
		return nil;
	}

	self = [super init];
	if (!self) {
		return nil;
	}

	_handle = handle;
	if (path) {
		self.path = [[NSString alloc] initWithUTF8String:path];
	}
	_releaseWhenDone = releaseWhenDone;

	return self;
}

- (unqlite *)unqliteHandle
{
	return _handle;
}

- (const char *)unqlitePath
{
	if (!self.path) {
		return NULL;
	}
	if (![self.path length]) {
		return "";
	}
	if ([self.path isEqualToString:@":mem:"]) {
		return ":mem:";
	}
	const char *result = [self.path fileSystemRepresentation];

	return result;
}

@end
