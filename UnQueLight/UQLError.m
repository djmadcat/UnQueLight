//
//  UQLError.m
//  UnQueLight
//
//  Created by Alexey Aleshkov on 14.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import "UQLError.h"
#include "unqlite.h"


NSString *const UQLErrorDomain = @"com.unquelight.error";


NSError *UQLErrorForStatusCode(NSInteger statusCode)
{
	NSError *result = nil;

	NSString *description = nil;
	switch (statusCode) {
		case UNQLITE_OK:
			return nil;
		case UNQLITE_NOMEM:
			description = @"Out of memory";
			break;
		case UNQLITE_ABORT:
			description = @"Another thread have released this instance";
			break;
		case UNQLITE_IOERR:
			description = @"IO error";
			break;
		case UNQLITE_CORRUPT:
			description = @"Corrupt pointer";
			break;
		case UNQLITE_LOCKED:
			description = @"Forbidden operation";
			break;
		case UNQLITE_BUSY:
			description = @"The database file is locked";
			break;
		case UNQLITE_DONE:
			description = @"Operation done";
			break;
		case UNQLITE_PERM:
			description = @"Permission error";
			break;
		case UNQLITE_NOTIMPLEMENTED:
			description = @"Method not implemented by the underlying Key/Value storage engine";
			break;
		case UNQLITE_NOTFOUND:
			description = @"No such record";
			break;
		case UNQLITE_NOOP:
			description = @"No such method";
			break;
		case UNQLITE_INVALID:
			description = @"Invalid parameter";
			break;
		case UNQLITE_EOF:
			description = @"End of input";
			break;
		case UNQLITE_UNKNOWN:
			description = @"Unknown configuration option";
			break;
		case UNQLITE_LIMIT:
			description = @"Database limit reached";
			break;
		case UNQLITE_EXISTS:
			description = @"Record exists";
			break;
		case UNQLITE_EMPTY:
			description = @"Empty record";
			break;
		case UNQLITE_COMPILE_ERR:
			description = @"Compilation error";
			break;
		case UNQLITE_VM_ERR:
			description = @"Virtual machine error";
			break;
		case UNQLITE_FULL:
			description = @"Full database (unlikely)";
			break;
		case UNQLITE_CANTOPEN:
			description = @"Unable to open the database file";
			break;
		case UNQLITE_READ_ONLY:
			description = @"Read only Key/Value storage engine";
			break;
		case UNQLITE_LOCKERR:
			description = @"Locking protocol error";
			break;

		default:
			description = @"Unknown error";
			break;
	}

	NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
	result = [NSError errorWithDomain:UQLErrorDomain code:statusCode userInfo:userInfo];

	return result;
}
