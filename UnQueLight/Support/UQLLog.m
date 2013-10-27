//
//  UQLLog.m
//  UnQueLight
//
//  Created by Alexey Aleshkov on 27.10.13.
//  Copyright (c) 2013 Alexey Aleshkov. All rights reserved.
//

//
//  Original code written by Blake Watters in his project RestKit
//
//  RKLog.m
//  RestKit
//
//  Created by Blake Watters on 6/10/11.
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


#import "UQLLog.h"


__attribute__((constructor))
static void UQLLogInitialize()
{
    UQLLogConfigureByName("UnQueLight*", UQLLogLevelDefault);
    UQLLogInfo(@"UnQueLight logging initialized...");
}
