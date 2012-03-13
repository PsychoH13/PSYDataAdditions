//
//  PSYUtilities.m
//  PSYDataAdditions
//
//  Created by Remy Demarest on 13/03/2012.
//  Copyright (c) 2012 NuLayer Inc. All rights reserved.
//

#import "PSYUtilities.h"

void PSYRequestConcreteImplementation(Class cls, SEL sel, BOOL isSubclass)
{
    if(isSubclass) [NSException raise:NSInvalidArgumentException format:@"*** -%@ only defined for abstract class.  Define -[%@ %@]!", NSStringFromSelector(sel), cls, NSStringFromSelector(sel)];
    else           [NSException raise:NSInvalidArgumentException format:@"*** -%@ cannot be sent to an abstract object of class %@: Create a concrete instance!", NSStringFromSelector(sel), cls];
}
