//
//  UQLError.h
//  UnQueLight
//
//  Created by Alexey Aleshkov on 14.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import <Foundation/Foundation.h>


extern NSString *const UQLErrorDomain;


// Not all API methods defines their status codes.
// This method check status code and create (or not if UNQLITE_OK) NSError with common description for status code.
extern NSError *UQLErrorForStatusCode(NSInteger statusCode);
