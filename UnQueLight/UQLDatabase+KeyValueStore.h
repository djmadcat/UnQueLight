//
//  UQLDatabase+KeyValueStore.h
//  UnQueLight
//
//  Created by Alexey Aleshkov on 12.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLDatabase.h"


@interface UQLDatabase (KeyValueStore)

- (NSData *)dataForRawKey:(NSData *)key;
- (void)storeData:(NSData *)data forRawKey:(NSData *)key;
- (void)appendData:(NSData *)data forRawKey:(NSData *)key;
- (void)removeDataForRawKey:(NSData *)key;

@end
