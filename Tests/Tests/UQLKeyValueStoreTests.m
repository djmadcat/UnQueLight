//
//  UQLKeyValueStoreTests.m
//  UnQueLight Tests
//
//  Created by Alexey Aleshkov on 28.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLTestCase.h"


@interface UQLKeyValueStoreTests : UQLTestCase
@property (nonatomic, strong) UQLDatabase *database;
@end


@implementation UQLKeyValueStoreTests

- (void)setUp
{
    [super setUp];

	self.database = [UQLDatabase database];
	NSError *error = nil;
	[self.database openWithOptions:UQLOpenCreate error:&error];
	STAssertNil(error, @"Can not create database. Error %@", error);
}

- (void)testStoreFetchValue
{
	NSData *key = [@"test key" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *value = [@"test value" dataUsingEncoding:NSUTF8StringEncoding];
	
	[self.database storeData:value forRawKey:key];
	NSData *data = [self.database dataForRawKey:key];
	STAssertNotNil(data, @"Can not fetch value for key");
	STAssertTrue([data isEqualToData:value], @"Fetched data is not equals to stored");
}

- (void)testAppendValue
{
	NSData *key = [@"test key" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *value1 = [@"test value1" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *value2 = [@" value2" dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *value = [NSMutableData dataWithData:value1];
	[value appendData:value2];

	[self.database storeData:value1 forRawKey:key];
	NSData *data1 = [self.database dataForRawKey:key];
	STAssertNotNil(data1, @"Can not fetch value for key");
	STAssertTrue([data1 isEqualToData:value1], @"Fetched data is not equals to stored");

	[self.database appendData:value2 forRawKey:key];
	NSData *data2 = [self.database dataForRawKey:key];
	STAssertNotNil(data2, @"Can not fetch value for key");
	STAssertTrue([data2 isEqualToData:value], @"Fetched data is not equals to stored");
}

- (void)testDeleteValue
{
	NSData *key = [@"test key" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *value = [@"test value" dataUsingEncoding:NSUTF8StringEncoding];

	[self.database storeData:value forRawKey:key];
	NSData *data = [self.database dataForRawKey:key];
	STAssertNotNil(data, @"Can not fetch value for key");

	[self.database removeDataForRawKey:key];
	NSData *nilData = [self.database dataForRawKey:key];
	STAssertNil(nilData, @"Fetched removed value for key");
}

- (void)testFetchValueCallback
{
	NSData *key = [@"test fetch callback key" dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *value = [[NSMutableData alloc] initWithLength:1024 * 1024 * 10];
	NSMutableData *data = [[NSMutableData alloc] init];

	[self.database storeData:value forRawKey:key];
	[self.database dataForRawKey:key callback:^BOOL(NSData *chunk) {
		[data appendData:chunk];
		return YES;
	}];
	STAssertTrue([data isEqualToData:value], @"Fetched data is not equals to stored");
}

@end
