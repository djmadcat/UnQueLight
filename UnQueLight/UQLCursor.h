//
//  UQLCursor.h
//  UnQueLight
//
//  Created by Alexey Aleshkov on 06.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import <Foundation/Foundation.h>
#include "unqlite.h"
#import "UQLDatabase+KeyValueStore.h"


typedef NS_ENUM(NSUInteger, UQLCursorSeekMatch) {
	UQLCursorSeekMatchExact				= UNQLITE_CURSOR_MATCH_EXACT,
	UQLCursorSeekMatchLessOrEqual		= UNQLITE_CURSOR_MATCH_LE,
	UQLCursorSeekMatchGreaterOrEqual	= UNQLITE_CURSOR_MATCH_GE
};


@class UQLDatabase;

@interface UQLCursor : NSObject
{
	unqlite_kv_cursor *_cursor;
}

@property (nonatomic, strong, readonly) UQLDatabase *database;

- (id)initWithDatabase:(UQLDatabase *)database error:(NSError **)error;

- (void)reset;

- (BOOL)isValid;
- (BOOL)seekForRawKey:(NSData *)key match:(UQLCursorSeekMatch)match;
- (BOOL)first;
- (BOOL)last;
- (BOOL)next;
- (BOOL)previous;

- (BOOL)remove;

- (NSData *)rawKey;
- (void)rawKeyWithCallback:(UQLDataCallback)callback;
- (NSData *)rawValue;
- (void)rawValueWithCallback:(UQLDataCallback)callback;

// low-level handle
- (unqlite_kv_cursor *)unqliteHandle;

@end
