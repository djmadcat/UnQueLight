//
//  UQLDatabase+Configuration.h
//  UnQueLight
//
//  Created by Alexey Aleshkov on 14.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLDatabase.h"


extern NSString *const UQLConfigKeyValueStorageEngineKey;
extern NSString *const UQLConfigDisableAutoCommitKey;
extern NSString *const UQLConfigMaxPageCacheKey;

extern NSString *const UQLConfigErrorLogKey;
extern NSString *const UQLConfigJx9ErrorLogKey;


@interface UQLDatabase (Configuration)

- (id)configForKey:(NSString *)key;
- (void)setConfig:(id)config forKey:(NSString *)key;

@end
