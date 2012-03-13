//
//  PSYUtilities.h
//  PSYDataAdditions
//
//  Created by Remy Demarest on 13/03/2012.
//  Copyright (c) 2012 NuLayer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(objc_arc)
#define RETAIN(obj) obj
#define RELEASE(obj) do { obj = nil; } while(NO)
#define AUTORELEASE(obj) obj
#else
#define RETAIN(obj) [obj retain]
#define RELEASE(obj) do { id __obj = obj; obj = nil; [__obj release]; } while(NO)
#define AUTORELEASE(obj) [obj autorelease]
#endif
