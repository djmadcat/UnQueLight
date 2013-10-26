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

- (id)init
{
	self = [super init];
	if (!self) {
		return nil;
	}

	UQLLogTrace(@"Creating database \"%@\"", self.path);

	return self;
}

- (id)initWithPath:(NSString *)path
{
	self = [super init];
	if (!self) {
		return nil;
	}

	self.path = path;

	UQLLogTrace(@"Creating database \"%@\"", self.path);

	return self;
}

- (void)dealloc
{
	[self close];
}

#pragma mark -
#pragma mark Open / Close

- (BOOL)openWithOptions:(UQLOpenOptions)options error:(NSError **)error
{
	UQLLogTrace(@"Trying to open database \"%@\"", self.path);

	const char *path = [self unqlitePath];
	int status = unqlite_open(&_db, path, options);

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
	UQLLogTrace(@"Trying to close database \"%@\"", self.path);

	if (!_db) {
		return YES;
	}

	int status = unqlite_close(_db);
	while (status == UNQLITE_BUSY) {
		[NSThread sleepForTimeInterval:20];
		status = unqlite_close(_db);
	}

	if (status == UNQLITE_ABORT) {
		NSError *error = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"Another thread have released the database handle" }];
		UQLLogError(@"Database \"%@\" already closed in another thread. Error returned %@", self.path, error);

		_db = NULL;

		return YES;
	}
	if (status == UNQLITE_IOERR) {
		NSError *error = [NSError errorWithDomain:UQLErrorDomain code:status userInfo:@{ NSLocalizedDescriptionKey: @"OS specific error" }];
		UQLLogError(@"Can not close database \"%@\" properly. Error returned %@", self.path, error);

		_db = NULL;

		return YES;
	}

	if (status == UNQLITE_OK) {
		UQLLogTrace(@"Successful closed database \"%@\"", self.path);
		return YES;
	}

	return status == UNQLITE_OK;
}

//int unqlite_begin(unqlite *pDb);
//int unqlite_commit(unqlite *pDb);
//int unqlite_rollback(unqlite *pDb);

#pragma mark -
#pragma mark Low-level methods

- (unqlite *)unqliteHandle
{
	return _db;
}

- (const char *)unqlitePath
{
	if (!self.path) {
		return NULL;
	}
	if ([self.path isEqualToString:@":mem:"]) {
		return ":mem:";
	}
	if (![self.path length]) {
		return "";
	}
	const char *result = [self.path fileSystemRepresentation];

	return result;
}

@end
