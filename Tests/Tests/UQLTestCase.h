//
//  UQLTestCase.h
//  UnQueLight Tests
//
//  Created by Alexey Aleshkov on 27.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "UnQueLight.h"


@interface UQLTestCase : SenTestCase

- (NSString *)tempDatabasePathForFileName:(NSString *)fileName;

@end
