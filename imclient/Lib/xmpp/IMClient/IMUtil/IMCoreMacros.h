//
//  Header.h
//  IMClient
//
//  Created by pengjay on 13-7-15.
//  Copyright (c) 2013年 pengjay.cn@gmail.com. All rights reserved.
//

#ifndef IMCoreMacros_h
#define IMCoreMacros_h

#define IM_FIX_CATEGORY_BUG(name) @interface IM_FIX_CATEGORY_BUG_##name :NSObject @end \
@implementation IM_FIX_CATEGORY_BUG_##name @end

#endif
