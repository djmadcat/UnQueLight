//
//  UQLTestCase.m
//  UnQueLight Tests
//
//  Created by Alexey Aleshkov on 27.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLTestCase.h"
#import "UQLLog.h"


@implementation UQLTestCase

- (void)setUp
{
	[super setUp];

	UQLLogConfigureByName("UnQueLight*", UQLLogLevelTrace);
}

- (NSString *)tempDatabasePathForFileName:(NSString *)fileName
{
	NSString *result = [[NSTemporaryDirectory() stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"db"];
	return result;
}

@end
