/*
 PSYStreamScanner.m
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

#import "PSYStreamScanner.h"
#import "PSYUtilities.h"

@implementation PSYStreamScanner

- (NSArray *)defaultMessages;
{
    PSYRequestConcreteImplementation([self class], _cmd, [PSYStreamScanner class] != [self class]);
    return nil;
}

- (void)setDefaultMessages:(NSArray *)value
{
    PSYRequestConcreteImplementation([self class], _cmd, [PSYStreamScanner class] != [self class]);
}

- (PSYStreamScannerMessage *)messageForIdentifier:(NSString *)identifier;
{
    PSYRequestConcreteImplementation([self class], _cmd, [PSYStreamScanner class] != [self class]);
    return nil;
}

- (void)setMessage:(PSYStreamScannerMessage *)aMessage forIdentifier:(NSString *)identifier;
{
    PSYRequestConcreteImplementation([self class], _cmd, [PSYStreamScanner class] != [self class]);
}

- (void)expectMessageWithIdentifier:(NSString *)identifier;
{
    [self expectMessagesWithIdentifiers:[NSArray arrayWithObject:identifier]];
}

- (void)expectMessagesWithIdentifiers:(NSArray *)identifiers;
{
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:[identifiers count]];
    
    for(NSString *ident in identifiers)
    {
        PSYStreamScannerMessage *message = [self messageForIdentifier:ident];
        
        if(message != nil) [messages addObject:message];
    }
    
    [self expectMessagesInArray:messages];
    [messages release];
}

- (void)expectMessage:(PSYStreamScannerMessage *)message;
{
    [self expectMessagesInArray:[NSArray arrayWithObject:message]];
}

- (void)expectMessagesInArray:(NSArray *)messages;
{
    PSYRequestConcreteImplementation([self class], _cmd, [PSYStreamScanner class] != [self class]);
}

- (void)removeExpectations;
{
    PSYRequestConcreteImplementation([self class], _cmd, [PSYStreamScanner class] != [self class]);
}

@end

// PSYStreamScannerMessage classes
@interface PSYStreamScannerMessage ()
{
@protected
    BOOL isMutable;
}

@property(nonatomic, readwrite, copy) NSData         *startData;
@property(nonatomic, readwrite, copy) NSData         *stopData;
@property(nonatomic, readwrite)       NSUInteger      minimumPartialLength;
@property(nonatomic, readwrite)       NSUInteger      maximumLength;

@property(nonatomic, readwrite)       NSTimeInterval  overallTimeoutInterval;
@property(nonatomic, readwrite)       NSTimeInterval  partialTimeoutInterval;

@property(nonatomic, readwrite, copy) void(^callbackBlock)(PSYStreamScanner *scanner);

@end

@implementation PSYStreamScannerMessage
@synthesize startData, stopData, callbackBlock, maximumLength, minimumPartialLength, overallTimeoutInterval, partialTimeoutInterval;

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [startData release];
    [stopData release];
    [callbackBlock release];
    [super dealloc];
}
#endif

- (id)copyWithZone:(NSZone *)zone
{
    if(!isMutable) return RETAIN(self);
    
    PSYStreamScannerMessage *ret = [[PSYStreamScannerMessage alloc] init];
    [ret setStartData:             [self startData]];
    [ret setStopData:              [self stopData]];
    [ret setOverallTimeoutInterval:[self overallTimeoutInterval]];
    [ret setPartialTimeoutInterval:[self partialTimeoutInterval]];
    [ret setMaximumLength:         [self maximumLength]];
    [ret setMinimumPartialLength:  [self minimumPartialLength]];
    [ret setCallbackBlock:         [self callbackBlock]];
    
    return ret;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    PSYMutableStreamScannerMessage *ret = [[PSYMutableStreamScannerMessage alloc] init];
    [ret setStartData:             [self startData]];
    [ret setStopData:              [self stopData]];
    [ret setOverallTimeoutInterval:[self overallTimeoutInterval]];
    [ret setPartialTimeoutInterval:[self partialTimeoutInterval]];
    [ret setMaximumLength:         [self maximumLength]];
    [ret setMinimumPartialLength:  [self minimumPartialLength]];
    [ret setCallbackBlock:         [self callbackBlock]];
    
    return ret;
}

@end

@implementation PSYMutableStreamScannerMessage
@dynamic startData, stopData, callbackBlock, maximumLength, minimumPartialLength, overallTimeoutInterval, partialTimeoutInterval;

- (id)init
{
    if((self = [super init]))
    {
        isMutable = YES;
    }
    return self;
}

@end
