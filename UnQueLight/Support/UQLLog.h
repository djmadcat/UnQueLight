//
//  UQLLog.h
//  UnQueLight
//
//  Created by Alexey Aleshkov on 27.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//

//
//  Original code written by Blake Watters in his project RestKit
//
//  RKLog.h
//  RestKit
//
//  Created by Blake Watters on 5/3/11.
//  Copyright (c) 2009-2012 RestKit. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


/**
 UnQueLight Logging is based on the LibComponentLogging framework

 @see lcl_config_components_UQL.h
 @see lcl_config_logger_UQL.h
 */
#import "lcl_UQL.h"

/**
 UQLLogComponent defines the active component within any given portion of UnQueLight

 By default, messages will log to the base 'UnQueLight' log component. All other components
 used by UnQueLight are nested under this parent, so this effectively sets the default log
 level for the entire library.

 The component can be undef'd and redefined to change the active logging component.
 */
#define UQLLogComponent UQLlcl_cUnQueLight

/**
 The logging macros. These macros will log to the currently active logging component
 at the log level identified in the name of the macro.

 For example, in the `UQLDatabase` class we would redefine the UQLLogComponent:

 #undef UQLLogComponent
 #define UQLLogComponent UQLlcl_cUnQueLight

 The UQLlcl_c prefix is the LibComponentLogging data structure identifying the logging component
 we want to target within this portion of the codebase. See lcl_config_component_UQL.h for reference.

 Having defined the logging component, invoking the logger via:

 UQLLogInfo(@"This is my log message!");

 Would result in a log message similar to:

 I UnQueLight.KeyValue:UQLLog.h:42 This is my log message!

 The message will only be logged if the log level for the active component is equal to or higher
 than the level the message was logged at (in this case, Info).
 */
#define UQLLogCritical(...)                                                              \
UQLlcl_log(UQLLogComponent, UQLLogLevelCritical, @"" __VA_ARGS__)

#define UQLLogError(...)                                                                 \
UQLlcl_log(UQLLogComponent, UQLLogLevelError, @"" __VA_ARGS__)

#define UQLLogWarning(...)                                                               \
UQLlcl_log(UQLLogComponent, UQLLogLevelWarning, @"" __VA_ARGS__)

#define UQLLogInfo(...)                                                                  \
UQLlcl_log(UQLLogComponent, UQLLogLevelInfo, @"" __VA_ARGS__)

#define UQLLogDebug(...)                                                                 \
UQLlcl_log(UQLLogComponent, UQLLogLevelDebug, @"" __VA_ARGS__)

#define UQLLogTrace(...)                                                                 \
UQLlcl_log(UQLLogComponent, UQLLogLevelTrace, @"" __VA_ARGS__)

/**
 Log Level Aliases

 These aliases simply map the log levels defined within LibComponentLogger to something more friendly
 */
#define UQLLogLevelOff       UQLlcl_vOff
#define UQLLogLevelCritical  UQLlcl_vCritical
#define UQLLogLevelError     UQLlcl_vError
#define UQLLogLevelWarning   UQLlcl_vWarning
#define UQLLogLevelInfo      UQLlcl_vInfo
#define UQLLogLevelDebug     UQLlcl_vDebug
#define UQLLogLevelTrace     UQLlcl_vTrace

/**
 Alias the LibComponentLogger logging configuration method. Also ensures logging
 is initialized for the framework.

 Expects the name of the component and a log level.

 Examples:

 // Log debugging messages from the "Key/Value Store" component
 UQLLogConfigureByName("UnQueLight/KeyValue", UQLLogLevelDebug);

 // Log only critical messages from the "Document Store" component
 UQLLogConfigureByName("UnQueLight/Document", UQLLogLevelCritical);
 */
#define UQLLogConfigureByName(name, level)                                               \
UQLlcl_configure_by_name(name, level);

/**
 Set the Default Log Level

 Based on the presence of the DEBUG flag, we default the logging for the UnQueLight parent component
 to Info or Warning.

 You can override this setting by defining UQLLogLevelDefault as a pre-processor macro.
 */
#ifndef UQLLogLevelDefault
#ifdef DEBUG
#define UQLLogLevelDefault UQLLogLevelInfo
#else
#define UQLLogLevelDefault UQLLogLevelWarning
#endif
#endif
