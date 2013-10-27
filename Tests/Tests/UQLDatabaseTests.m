//
//  UQLDatabaseTests.m
//  UnQueLight Tests
//
//  Created by Alexey Aleshkov on 27.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLTestCase.h"


@interface UQLDatabaseTests : UQLTestCase
@property (nonatomic, copy) NSString *databasePath;
@end


@implementation UQLDatabaseTests

- (void)setUp
{
	[super setUp];

	self.databasePath = [self tempDatabasePathForFileName:@"testDatabase"];
}

- (void)testCreateFileDatabase
{
	UQLDatabase *database = [[UQLDatabase alloc] initWithPath:self.databasePath];
	NSError *error = nil;

	BOOL opened = [database openWithOptions:UQLOpenCreate error:&error];
	STAssertTrue(opened, @"Can not create database at path \"%@\"", self.databasePath);

	BOOL closed = [database close];
	STAssertTrue(closed, @"Can not close database at path \"%@\"", self.databasePath);
}

- (void)testOpenFileDatabase
{
	UQLDatabase *database = [[UQLDatabase alloc] initWithPath:self.databasePath];
	NSError *error = nil;

	BOOL opened = [database openWithOptions:UQLOpenReadWrite error:&error];
	STAssertTrue(opened, @"Can not open database at path \"%@\"", self.databasePath);

	BOOL closed = [database close];
	STAssertTrue(closed, @"Can not close database at path \"%@\"", self.databasePath);
}

- (void)testInMemoryDatabase
{
	UQLDatabase *database = [[UQLDatabase alloc] init];
	NSError *error = nil;

	BOOL opened = [database openWithOptions:UQLOpenReadWrite error:&error];
	STAssertTrue(opened, @"Can not open in-memory database");

	BOOL closed = [database close];
	STAssertTrue(closed, @"Can not close in-memory database");
}

- (void)testOpenTwiceDatabase
{
	UQLDatabase *database = [[UQLDatabase alloc] init];
	NSError *error = nil;

	BOOL opened = [database openWithOptions:UQLOpenReadWrite error:&error];
	STAssertTrue(opened, @"Can not open database");

	BOOL openedTwice = [database openWithOptions:UQLOpenReadWrite error:&error];
	STAssertTrue(openedTwice, @"Can not open database twice");

	BOOL closed = [database close];
	STAssertTrue(closed, @"Can not close database");
}

- (void)testCloseTwiceDatabase
{
	UQLDatabase *database = [[UQLDatabase alloc] init];
	NSError *error = nil;

	BOOL opened = [database openWithOptions:UQLOpenReadWrite error:&error];
	STAssertTrue(opened, @"Can not open database");

	BOOL closed = [database close];
	STAssertTrue(closed, @"Can not close database");

	BOOL closedTwice = [database close];
	STAssertTrue(closedTwice, @"Can not close database twice");
}

@end
