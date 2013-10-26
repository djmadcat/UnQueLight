//
//  UQLLog.h
//  UnQueLight
//
//  Created by Alexey Aleshkov on 12.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//


#import <Foundation/Foundation.h>


#define UQLLogCommon(format, ...) NSLog(@"[%@: %p %@] " format, NSStringFromClass([self class]), self, NSStringFromSelector(_cmd), __VA_ARGS__)


#define UQLLogCritical	UQLLogCommon
#define UQLLogError		UQLLogCommon
#define UQLLogWarning	UQLLogCommon
#define UQLLogInfo		UQLLogCommon
#define UQLLogDebug		UQLLogCommon
#define UQLLogTrace		UQLLogCommon
