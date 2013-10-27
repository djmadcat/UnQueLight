//
//
// LCLNSLog_UQL.h
//
//
// Copyright (c) 2008-2012 Arne Harren <ah@0xc0.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


//
// UQLLCLNSLog
//
// This file provides a simple LibComponentLogging logger implementation which
// redirects logging to NSLog.
//
// The logger uses the following format
//
//   <NSLog Prefix> <Level> <Component>:<File>:<Line>:<Function> <Message>
//
// where <NSLog Prefix> is
//
//   <Date> <Time> <Application>[<PID>:<TID>]
//
// Examples:
//
//   2009-02-01 12:38:32.796 Example[4964:10b] D c1:main.m:28:-[Class method] M1
//   2009-02-01 12:38:32.798 Example[4964:10b] D c2:main.m:32:-[Class method] M2
//   2009-02-01 12:38:32.799 Example[4964:10b] D c3:main.m:36:-[Class method] M3
//


//
// Integration with LibComponentLogging Core.
//


// ARC/non-ARC autorelease pool
#define _UQLlcl_logger_autoreleasepool_arc 0
#if defined(__has_feature)
#   if __has_feature(objc_arc)
#   undef  _UQLlcl_logger_autoreleasepool_arc
#   define _UQLlcl_logger_autoreleasepool_arc 1
#   endif
#endif
#if _UQLlcl_logger_autoreleasepool_arc
#   define _UQLlcl_logger_autoreleasepool_begin                                   \
        @autoreleasepool {
#   define _UQLlcl_logger_autoreleasepool_end                                     \
        }
#else
#   define _UQLlcl_logger_autoreleasepool_begin                                   \
        NSAutoreleasePool *_UQLlcl_logger_autoreleasepool = [[NSAutoreleasePool alloc] init];
#   define _UQLlcl_logger_autoreleasepool_end                                     \
        [_UQLlcl_logger_autoreleasepool release];
#endif

#ifndef _UQLLCL_NO_IGNORE_WARNINGS
#   ifdef __clang__
    // Ignore some warnings about variadic macros when using '-Weverything'.
#   pragma clang diagnostic push
#   pragma clang diagnostic ignored "-Wunknown-pragmas"
#   pragma clang diagnostic ignored "-Wvariadic-macros"
#   pragma clang diagnostic ignored "-Wpedantic"
#   endif
#endif

// A very simple logger, which redirects to NSLog().
#define _UQLlcl_logger(_component, _level, _format, ...) {                        \
    _UQLlcl_logger_autoreleasepool_begin                                          \
    NSLog(@"%s %s:%@:%d:%s " _format,                                          \
          _UQLlcl_level_header_1[_level],                                         \
          _UQLlcl_component_header[_component],                                   \
          [@__FILE__ lastPathComponent],                                       \
          __LINE__,                                                            \
          __PRETTY_FUNCTION__,                                                 \
          ## __VA_ARGS__);                                                     \
    _UQLlcl_logger_autoreleasepool_end                                            \
}

#ifndef _UQLLCL_NO_IGNORE_WARNINGS
#   ifdef __clang__
#   pragma clang diagnostic pop
#   endif
#endif
