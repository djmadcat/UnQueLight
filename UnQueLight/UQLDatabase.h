//
//  UQLDatabase.h
//  UnQueLight
//
//  Created by Alexey Aleshkov on 05.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import <Foundation/Foundation.h>
#include "unqlite.h"


typedef NS_OPTIONS(NSUInteger, UQLOpenOptions) {
	UQLOpenNone				= 0,
	UQLOpenReadOnly			= UNQLITE_OPEN_READONLY,
	UQLOpenReadWrite		= UNQLITE_OPEN_READWRITE,
	UQLOpenCreate			= UNQLITE_OPEN_CREATE,
	UQLOpenExclusive		= UNQLITE_OPEN_EXCLUSIVE,
	UQLOpenTemporary		= UNQLITE_OPEN_TEMP_DB,
	UQLOpenNoMutex			= UNQLITE_OPEN_NOMUTEX,
	UQLOpenOmitJournaling	= UNQLITE_OPEN_OMIT_JOURNALING,
	UQLOpenInMemory			= UNQLITE_OPEN_IN_MEMORY,
	UQLOpenMemoryMap		= UNQLITE_OPEN_MMAP
};


@interface UQLDatabase : NSObject
{
	unqlite *_handle;
}

@property (nonatomic, copy, readonly) NSString *path;

+ (instancetype)database;
+ (instancetype)databaseWithPath:(NSString *)path;

// in-memory database
- (id)init;
// if (path == nil) in-memory database will be create
- (id)initWithPath:(NSString *)path;

- (BOOL)openWithOptions:(UQLOpenOptions)options error:(NSError **)error;
- (BOOL)close;

- (BOOL)isOpen;

// low-level handle
- (unqlite *)unqliteHandle;
- (const char *)unqlitePath;

@end
