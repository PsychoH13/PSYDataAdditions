//
//  PSYConcreteStreamWriter.m
//  PSYDataAdditions
//
//  Created by Remy Demarest on 13/03/2012.
//  Copyright (c) 2012 NuLayer Inc. All rights reserved.
//

#import "PSYConcreteStreamWriter.h"
#import "PSYUtilities.h"

@class PSYStreamWriterHelper, PSYStreamWriterHelperGroup, PSYStreamWriterHelperUnit;

@interface PSYStreamWriterHelper : PSYStreamWriter
- (id)initWithParentStreamWriter:(PSYStreamWriter *)parent;
- (BOOL)writeDataToStream:(NSOutputStream *)aStream;

@property(nonatomic, assign) PSYStreamWriter *parentStreamWriter;
@end

@interface PSYStreamWriterHelperUnit : PSYStreamWriterHelper
@end

@interface PSYStreamWriterHelperInputStream : PSYStreamWriterHelper <NSStreamDelegate>
- (id)initWithParentStreamWriter:(PSYStreamWriter *)parent;
- (id)initWithInputStream:(NSInputStream *)aStream parentStreamWriter:(PSYStreamWriter *)parent completionBlock:(void(^)(void))completion;
@end

@interface PSYStreamWriterHelperGroup : PSYStreamWriterHelper
- (id)initWithParentStreamWriter:(PSYStreamWriter *)parent;
- (id)initWithParentStreamWriter:(PSYStreamWriter *)parent completionBlock:(void(^)(void))completion;
@end

@interface PSYConcreteStreamWriter () <NSStreamDelegate>
{
    NSOutputStream             *outputStream;
    PSYStreamWriterHelperGroup *rootGroup;
    BOOL                        closeOnDealloc;
}
@property(nonatomic, assign) id<PSYStreamWriterDelegate> delegate;
@end

@implementation PSYConcreteStreamWriter
@synthesize delegate;

- (id)initWithOutputStream:(NSOutputStream *)aStream closeOnDealloc:(BOOL)close
{
    if((self = [super init]))
    {
        outputStream = RETAIN(aStream);
        [outputStream setDelegate:self];
        closeOnDealloc = close;
        
        rootGroup = [[PSYStreamWriterHelperGroup alloc] initWithParentStreamWriter:self];
    }
    return self;
}

- (void)dealloc
{
    if(closeOnDealloc) [outputStream close];
    
#if !__has_feature(objc_arc)
    [outputStream release];
    [rootGroup release];
    [super dealloc];
#endif
}

- (void)groupWrites:(void (^)(PSYStreamWriter *))writes completion:(void (^)(void))completion
{
    [rootGroup groupWrites:writes completion:completion];
}

- (void)writeBytes:(const uint8_t *)buffer ofLength:(NSUInteger)length
{
    [rootGroup writeBytes:buffer ofLength:length];
    
    switch([outputStream streamStatus])
    {
        case NSStreamStatusNotOpen :
            [outputStream open];
            break;
        case NSStreamStatusOpening :
            break;
        case NSStreamStatusOpen :
            // The stream is open, attempt to write whatever we have
            if([rootGroup writeDataToStream:outputStream] &&
               [[self delegate] respondsToSelector:@selector(streamWriterDidFinishWriting:)])
                [[self delegate] streamWriterDidFinishWriting:self];
            break;
        case NSStreamStatusReading :
        case NSStreamStatusWriting :
            // Do nothing
            break;
        case NSStreamStatusAtEnd :
            if([[self delegate] respondsToSelector:@selector(streamWriterDidEncounterEnd:)])
                [[self delegate] streamWriterDidEncounterEnd:self];
            break;
        case NSStreamStatusClosed :
            // We should probably do something here
            break;
        case NSStreamStatusError :
            if([[self delegate] respondsToSelector:@selector(streamWriter:didReceiveError:)])
                [[self delegate] streamWriter:self didReceiveError:[outputStream streamError]];
            break;
        default :
            // Gné?!
            break;
    }
}

- (void)writeInputStream:(NSInputStream *)aStream completion:(void(^)(void))completion;
{
    [rootGroup writeInputStream:aStream completion:completion];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if(eventCode & NSStreamEventHasSpaceAvailable)
        [rootGroup writeDataToStream:outputStream];
    
    if(eventCode & NSStreamEventErrorOccurred &&
       [[self delegate] respondsToSelector:@selector(streamWriterDidEncounterEnd:)])
        [[self delegate] streamWriterDidEncounterEnd:self];
    
    if(eventCode & NSStreamEventEndEncountered &&
       [[self delegate] respondsToSelector:@selector(streamWriter:didReceiveError:)])
        [[self delegate] streamWriterDidEncounterEnd:self];
}

@end

@implementation PSYStreamWriterHelper
@synthesize parentStreamWriter;

- (id)init
{
    return [self initWithParentStreamWriter:nil];
}

- (id)initWithParentStreamWriter:(PSYStreamWriter *)parent
{
    if(parent == nil)
    {
        RELEASE(self);
        return nil;
    }
    
    if((self = [super init]))
    {
        [self setParentStreamWriter:parent];
    }
    
    return self;
}

- (id<PSYStreamWriterDelegate>)delegate                { return [parentStreamWriter delegate];   }
- (void)setDelegate:(id<PSYStreamWriterDelegate>)value { [parentStreamWriter setDelegate:value]; }

- (BOOL)writeDataToStream:(NSOutputStream *)aStream;
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYStreamWriterHelper class]);
    return YES;
}

@end

@implementation PSYStreamWriterHelperUnit
{
    NSMutableData *pendingQueue;
    NSData        *lockedQueue;
    NSUInteger     writeLocation;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [pendingQueue release];
    [lockedQueue release];
    [super dealloc];
}
#endif

- (void)writeInputStream:(NSInputStream *)aStream completion:(void (^)(void))completion;
{
    [[self parentStreamWriter] writeInputStream:aStream completion:completion];
}

- (void)groupWrites:(void (^)(PSYStreamWriter *))writes completion:(void (^)(void))completion
{
    [[self parentStreamWriter] groupWrites:writes completion:completion];
}

- (void)writeBytes:(const uint8_t *)buffer ofLength:(NSUInteger)length
{
    @synchronized(self)
    {
        if(pendingQueue == nil) pendingQueue = [[NSMutableData alloc] initWithCapacity:length];
        
        [pendingQueue appendBytes:buffer length:length];
    }
}

- (BOOL)writeDataToStream:(NSOutputStream *)aStream;
{
    if(![aStream hasSpaceAvailable]) return NO;
    
    @synchronized(self)
    {
        if(lockedQueue == nil)
        {
            writeLocation = 0;
            lockedQueue   = [pendingQueue copy];
            RELEASE(pendingQueue);
        }
    
        NSUInteger length  = [lockedQueue length];
        NSInteger  toWrite = length - writeLocation;
        
        if(toWrite <= 0)
        {
            RELEASE(lockedQueue);
            writeLocation = 0;
            return YES;
        }
        
        const uint8_t *buffer  = [lockedQueue bytes];
        NSInteger      written = [aStream write:buffer + writeLocation maxLength:toWrite];
        
        if(written < 0)
        {
            // TODO: Error handling here!
        }
        else if(written == toWrite)
        {
            RELEASE(lockedQueue);
            writeLocation = 0;
            // This can only be called twice,
            // 1. already lockData has been sent,
            // 2. pendingData has been sent,
            // 3. nothing else to send
            return [self writeDataToStream:aStream];
        }
        else writeLocation += written;
        
        return NO;
    }
}

@end

@implementation PSYStreamWriterHelperGroup
{
    NSMutableArray *helperQueue;
    void (^completionBlock)(void);
}

- (id)initWithParentStreamWriter:(PSYStreamWriter *)parent
{
    return [self initWithParentStreamWriter:parent completionBlock:nil];
}

- (id)initWithParentStreamWriter:(PSYStreamWriter *)parent completionBlock:(void (^)(void))completion
{
    if((self = [super initWithParentStreamWriter:parent]))
    {
        completionBlock = [completion copy];
        helperQueue     = [[NSMutableArray alloc] init];
    }
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [completionBlock release];
    [helperQueue release];
    [super dealloc];
}
#endif

- (BOOL)writeDataToStream:(NSOutputStream *)aStream
{
    BOOL stop = NO;
    do {
        PSYStreamWriterHelper *helper = nil;
        
        @synchronized(self)
        {
            // The queue is empty, nothing left to do
            if([helperQueue count] == 0)
            {
                if(completionBlock != nil) completionBlock();
                return YES;
            }
            helper = RETAIN([helperQueue objectAtIndex:0]);
        }
        
        if([helper writeDataToStream:aStream])
            @synchronized(self) { [helperQueue removeObjectAtIndex:0]; }
        else
            stop = YES;
        
        RELEASE(helper);
    } while(!stop);
    
    return NO;
}

- (void)writeBytes:(const uint8_t *)buffer ofLength:(NSUInteger)length
{
    PSYStreamWriterHelperUnit *writer = nil;
    @synchronized(self)
    {
        PSYStreamWriterHelperUnit *temp = RETAIN([helperQueue lastObject]);
        if(![temp isKindOfClass:[PSYStreamWriterHelperUnit class]])
        {
            RELEASE(temp);
            temp = [[PSYStreamWriterHelperUnit alloc] init];
            [helperQueue addObject:temp];
        }
        
        writer = temp;
    }
    
    [writer writeBytes:buffer ofLength:length];
    RELEASE(writer);
}

- (void)groupWrites:(void (^)(PSYStreamWriter *))writes completion:(void (^)(void))completion
{
    if(writes == nil) return;
    
    PSYStreamWriterHelperGroup *group = [[PSYStreamWriterHelperGroup alloc] initWithParentStreamWriter:self completionBlock:completion];
    
    @synchronized(self) { [helperQueue addObject:group]; }
    
    writes(group);
    RELEASE(group);
}

- (void)writeInputStream:(NSInputStream *)aStream completion:(void(^)(void))completion;
{
    if(aStream == nil) return;
    
    PSYStreamWriterHelperInputStream *writer = [[PSYStreamWriterHelperInputStream alloc] initWithInputStream:aStream parentStreamWriter:self completionBlock:completion];
    
    @synchronized(self) { [helperQueue addObject:writer]; }
    
    RELEASE(writer);
}

@end

@implementation PSYStreamWriterHelperInputStream
{
    NSInputStream             *inputStream;
    PSYStreamWriterHelperUnit *dataHelper;
    void (^completionBlock)(void);
}

- (id)initWithParentStreamWriter:(PSYStreamWriter *)parent;
{
    return [self initWithInputStream:nil parentStreamWriter:parent completionBlock:nil];
}

- (id)initWithInputStream:(NSInputStream *)aStream parentStreamWriter:(PSYStreamWriter *)parent completionBlock:(void(^)(void))completion;
{
    if(aStream == nil)
    {
        RELEASE(self);
        return nil;
    }
    
    if((self = [super initWithParentStreamWriter:parent]))
    {
        completionBlock = [completion copy];
        dataHelper      = [[PSYStreamWriterHelperUnit alloc] initWithParentStreamWriter:self];
        inputStream     = RETAIN(aStream);
        [inputStream setDelegate:self];
    }
    
    return self;
}

- (void)dealloc
{
    [inputStream close];
    
#if !__has_feature(objc_arc)
    [inputStream release];
    [completionBlock release];
    [dataHelper release];
    [super dealloc];
#endif
}

- (void)writeInputStream:(NSInputStream *)aStream completion:(void (^)(void))completion;
{
    [[self parentStreamWriter] writeInputStream:aStream completion:completion];
}

- (void)groupWrites:(void (^)(PSYStreamWriter *))writes completion:(void (^)(void))completion
{
    [[self parentStreamWriter] groupWrites:writes completion:completion];
}

- (void)writeBytes:(const uint8_t *)buffer ofLength:(NSUInteger)length;
{
    [[self parentStreamWriter] writeBytes:buffer ofLength:length];
}

// Returns YES if we can continue to read more data
- (BOOL)PSY_readDataBuffer;
{
    if(![inputStream hasBytesAvailable]) return NO;
    
#define BUFFER_SIZE 1024
    uint8_t buffer[BUFFER_SIZE] = { 0 };
    
    NSUInteger read = [inputStream read:buffer maxLength:BUFFER_SIZE];
    
    [dataHelper writeBytes:buffer ofLength:read];
    
    return read == BUFFER_SIZE;
}

- (BOOL)writeDataToStream:(NSOutputStream *)aStream;
{
    //Write whatever we already accumulated
    BOOL finished = [dataHelper writeDataToStream:aStream];
    
    // The helper couldn't write everything it stored, stop here
    if(!finished) return NO;
    
    BOOL continueReading = YES;
    
    while(continueReading)
    {
        switch([inputStream streamStatus])
        {
            case NSStreamStatusNotOpen : [inputStream open]; break;
            case NSStreamStatusOpening : return NO;
            case NSStreamStatusOpen :
                // We don't have to read anything but we're not at the end of the stream
                // so there are still some data to read, return NO so we stay in the queue
                if(![inputStream hasBytesAvailable]) return NO;
                break;
            case NSStreamStatusReading :
            case NSStreamStatusWriting :
                // Do nothing
                break;
            case NSStreamStatusAtEnd :
            case NSStreamStatusClosed :
                // The stream is closed or finished, there's no more data to read at all
                if(![inputStream hasBytesAvailable])
                {
                    if(completionBlock != nil) completionBlock();
                    return YES;
                }
                
                break;
            case NSStreamStatusError :
                break;
            default :
                // Gné?!
                break;
        }
        
        // Read more data from the buffer
        [self PSY_readDataBuffer];
        
        // Attempt to write the data, if return NO we're done for now
        continueReading = [dataHelper writeDataToStream:aStream];
    }
    
    return NO;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    // Read as much data as we can from the stream
    // It's either going to accumulate in the stream or in our own buffer
    // we're better off getting everything ourselves
    if(eventCode & NSStreamEventHasBytesAvailable)
        while([self PSY_readDataBuffer]);
    
    if(eventCode & NSStreamEventErrorOccurred &&
       [[self delegate] respondsToSelector:@selector(streamWriterDidEncounterEnd:)])
        [[self delegate] streamWriterDidEncounterEnd:self];
}

@end
