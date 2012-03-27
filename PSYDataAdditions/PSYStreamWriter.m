/*
 PSYStreamWriter.m
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

#import "PSYStreamWriter.h"
#import "PSYUtilities.h"
#import "PSYConcreteStreamWriter.h"
#import "NSMutableData+PSYDataWriter.h"

@interface PSYPlaceholderStreamWriter : PSYStreamWriter
@end

@implementation PSYStreamWriter

+ (id)allocWithZone:(NSZone *)zone
{
    if(self == [PSYStreamWriter class])
        return [[PSYPlaceholderStreamWriter alloc] init];
    
    return [super allocWithZone:zone];
}

- (void)groupWrites:(void(^)(PSYStreamWriter *writer))writes completion:(void(^)(void))completion;
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYStreamWriter class]);
}

- (void)writeBytes:(const uint8_t *)buffer ofLength:(NSUInteger)length;
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYStreamWriter class]);
}

- (void)writeInputStream:(NSInputStream *)aStream completion:(void(^)(void))completion;
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYStreamWriter class]);
}

- (id<PSYStreamWriterDelegate>)delegate
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYStreamWriter class]);
    return nil;
}

- (void)setDelegate:(id<PSYStreamWriterDelegate>)value
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYStreamWriter class]);
}

@end

@implementation PSYStreamWriter (PSYStreamWriterCreation)

+ (id)writerWithOutputStream:(NSOutputStream *)aStream;
{
    return AUTORELEASE([[self alloc] initWithOutputStream:aStream]);
}

- (id)initWithOutputStream:(NSOutputStream *)aStream;
{
    return [self initWithOutputStream:aStream closeOnDealloc:NO];
}

+ (id)writerWithOutputStream:(NSOutputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;
{
    return AUTORELEASE([[self alloc] initWithOutputStream:aStream closeOnDealloc:closeOnDealloc]);
}

- (id)initWithOutputStream:(NSOutputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;
{
    RELEASE(self);
    return nil;
}

@end

@implementation PSYPlaceholderStreamWriter

+ (id)allocWithZone:(NSZone *)zone
{
    static PSYPlaceholderStreamWriter *sharedPlaceholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlaceholder = [[super allocWithZone:zone] init];
    });
    
    return sharedPlaceholder;
}

- (id)init
{
    return self;
}

- (id)initWithOutputStream:(NSOutputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;
{
    return (id)[[PSYConcreteStreamWriter alloc] initWithOutputStream:aStream closeOnDealloc:closeOnDealloc];
}

@end

@implementation PSYStreamWriter (PSYDataWriterAdditions)

#define WRITE_METHOD(name, type, size)                                   \
- (void)write ## name:(type)value;                                       \
{                                                                        \
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:size]; \
    [data append ## name:value];                                         \
    [self writeData:data];                                               \
    RELEASE(data);                                                       \
}
#define SIMPLE_WRITE_METHOD(name, type) WRITE_METHOD(name, type, sizeof(type))
#define VAR_WRITE_METHOD(name, type)   WRITE_METHOD(name, type, sizeof(type) + 1)

SIMPLE_WRITE_METHOD(Int8, uint8_t)

SIMPLE_WRITE_METHOD(LittleEndianInt16, uint16_t)
SIMPLE_WRITE_METHOD(LittleEndianInt32, uint32_t)
SIMPLE_WRITE_METHOD(LittleEndianInt64, uint64_t)

SIMPLE_WRITE_METHOD(BigEndianInt16, uint16_t)
SIMPLE_WRITE_METHOD(BigEndianInt32, uint32_t)
SIMPLE_WRITE_METHOD(BigEndianInt64, uint64_t)

SIMPLE_WRITE_METHOD(SInt8, int8_t)

SIMPLE_WRITE_METHOD(LittleEndianSInt16, int16_t)
SIMPLE_WRITE_METHOD(LittleEndianSInt32, int32_t)
SIMPLE_WRITE_METHOD(LittleEndianSInt64, int64_t)

SIMPLE_WRITE_METHOD(BigEndianSInt16, int16_t)
SIMPLE_WRITE_METHOD(BigEndianSInt32, int32_t)
SIMPLE_WRITE_METHOD(BigEndianSInt64, int64_t)

VAR_WRITE_METHOD(LittleEndianVarint32, uint32_t)
VAR_WRITE_METHOD(LittleEndianVarint64, uint64_t)

VAR_WRITE_METHOD(BigEndianVarint32, uint32_t)
VAR_WRITE_METHOD(BigEndianVarint64, uint64_t)

VAR_WRITE_METHOD(LittleEndianSVarint32, int32_t)
VAR_WRITE_METHOD(LittleEndianSVarint64, int64_t)

VAR_WRITE_METHOD(BigEndianSVarint32, int32_t)
VAR_WRITE_METHOD(BigEndianSVarint64, int64_t)

VAR_WRITE_METHOD(LittleEndianZigZagVarint32, int32_t)
VAR_WRITE_METHOD(LittleEndianZigZagVarint64, int64_t)

VAR_WRITE_METHOD(BigEndianZigZagVarint32, int32_t)
VAR_WRITE_METHOD(BigEndianZigZagVarint64, int64_t)

SIMPLE_WRITE_METHOD(Float, float)
SIMPLE_WRITE_METHOD(Double, double)

SIMPLE_WRITE_METHOD(SwappedFloat, float)
SIMPLE_WRITE_METHOD(SwappedDouble, double)

#undef WRITE_METHOD
#undef SIMPLE_WRITE_METHOD
#undef VAR_WRITE_METHOD

- (void)writeData:(NSData *)value;
{
    [self writeBytes:[value bytes] ofLength:[value length]];
}

- (void)writeString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;
{
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:[value maximumLengthOfBytesUsingEncoding:encoding]];
    [data appendString:value usingEncoding:encoding];
    [self writeData:data];
    RELEASE(data);
}

- (void)writeNullTerminatedString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;
{
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:[value maximumLengthOfBytesUsingEncoding:encoding] + 4];
    [data appendNullTerminatedString:value usingEncoding:encoding];
    [self writeData:data];
    RELEASE(data);
}

@end
