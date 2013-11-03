//
//  UQLDatabase+KeyValueStore.h
//  UnQueLight
//
//  Created by Alexey Aleshkov on 12.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLDatabase.h"


// Processing: YES - continue, NO - abort
typedef BOOL (^UQLDataCallback)(NSData *chunk);


@interface UQLDatabase (KeyValueStore)

- (NSData *)dataForRawKey:(NSData *)key;
- (void)dataForRawKey:(NSData *)key callback:(UQLDataCallback)callback;
- (void)storeData:(NSData *)data forRawKey:(NSData *)key;
- (void)appendData:(NSData *)data forRawKey:(NSData *)key;
- (void)removeDataForRawKey:(NSData *)key;

@end
