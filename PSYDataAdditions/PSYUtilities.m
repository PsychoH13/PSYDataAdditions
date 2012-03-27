/*
 PSYUtilities.m
 Created by Remy "Psy" Demarest on 13/03/2012.
 
 Copyright (c) 2012. Remy "Psy" Demarest

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "PSYUtilities.h"

void PSYRequestConcreteImplementation(Class cls, SEL sel, BOOL isSubclass)
{
    if(isSubclass) [NSException raise:NSInvalidArgumentException format:@"*** -%@ only defined for abstract class.  Define -[%@ %@]!", NSStringFromSelector(sel), cls, NSStringFromSelector(sel)];
    else           [NSException raise:NSInvalidArgumentException format:@"*** -%@ cannot be sent to an abstract object of class %@: Create a concrete instance!", NSStringFromSelector(sel), cls];
}
