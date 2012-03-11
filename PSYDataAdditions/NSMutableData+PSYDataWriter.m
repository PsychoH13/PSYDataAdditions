/*
 NSMutableData+PSYDataWriter.m
 Created by Remy "Psy" Demarest on 22/01/2012.
 
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

#import "NSMutableData+PSYDataWriter.h"
#import "PSYDataScanner.h"

@implementation NSMutableData (PSYDataWriter)

- (void)appendInt8:(uint8_t)value;
{
    [self appendBytes:&value length:sizeof(value)];
}

#define APPEND_METHOD(endian, size)                                      \
- (void)append ## endian ## EndianInt ## size:(uint ## size ## _t)value \
{                                                                        \
    value = CFSwapInt ## size ## HostTo ## endian(value);                \
    [self appendBytes:&value length:sizeof(value)];                      \
}

APPEND_METHOD(Little, 16)
APPEND_METHOD(Little, 32)
APPEND_METHOD(Little, 64)
APPEND_METHOD(Big, 16)
APPEND_METHOD(Big, 32)
APPEND_METHOD(Big, 64)

#undef APPEND_METHOD

- (void)appendSInt8:(int8_t)value;
{
    [self appendInt8:*(int8_t *)&value];
}

#define APPEND_METHOD(endian, size)                                             \
- (void)append ## endian ## EndianSInt ## size:(int ## size ## _t)value         \
{                                                                               \
    [self append ## endian ## EndianInt ## size:*(uint ## size ## _t *)&value]; \
}

APPEND_METHOD(Little, 16)
APPEND_METHOD(Little, 32)
APPEND_METHOD(Little, 64)
APPEND_METHOD(Big, 16)
APPEND_METHOD(Big, 32)
APPEND_METHOD(Big, 64)

#undef APPEND_METHOD

#define APPEND_VARINT_METHOD(endian, size)                                         \
- (void)append ## endian ## EndianVarint ## size:(uint ## size ## _t)value         \
{                                                                                  \
    uint8_t buff[10];                                                              \
    uint8_t idx = 0;                                                               \
    value = CFSwapInt ## size ## HostTo ## endian(value);                          \
    while(value != 0x0)                                                            \
    {                                                                              \
        buff[idx] = value & 0xffffff80 ? (0x80 | (value & 0x7f)) : (uint8_t)value; \
        idx++;                                                                     \
    }                                                                              \
    [self appendBytes:buff length:idx];                                            \
}

APPEND_VARINT_METHOD(Little, 32)
APPEND_VARINT_METHOD(Little, 64)
APPEND_VARINT_METHOD(Big, 32)
APPEND_VARINT_METHOD(Big, 64)

#undef APPEND_VARINT_METHOD

#define APPEND_VARINT_METHOD(endian, size)                                       \
- (void)append ## endian ## EndianSVarint ## size:(int ## size ## _t)value       \
{                                                                                \
    [self append ##endian ##EndianVarint ## size:*(uint ## size ## _t *)&value]; \
}

APPEND_VARINT_METHOD(Little, 32)
APPEND_VARINT_METHOD(Little, 64)
APPEND_VARINT_METHOD(Big, 32)
APPEND_VARINT_METHOD(Big, 64)

#undef APPEND_VARINT_METHOD

#define APPEND_VARINT_METHOD(endian, size)                                       \
- (void)append ## endian ## EndianZigZagVarint ## size:(int ## size ## _t)value  \
{                                                                                \
    value = (value << 1) ^ (value >> (size - 1));                                 \
    [self append ##endian ##EndianVarint ## size:*(uint ## size ## _t *)&value]; \
}

APPEND_VARINT_METHOD(Little, 32)
APPEND_VARINT_METHOD(Little, 64)
APPEND_VARINT_METHOD(Big, 32)
APPEND_VARINT_METHOD(Big, 64)

#undef APPEND_VARINT_METHOD

- (void)appendFloat:(float)value;
{
    [self appendBytes:&value length:sizeof(value)];
}

- (void)appendDouble:(double)value;
{
    [self appendBytes:&value length:sizeof(value)];
}

- (void)appendSwappedFloat:(float)value;
{
    CFSwappedFloat32 v = CFConvertFloatHostToSwapped(value);
    [self appendBytes:&v length:sizeof(value)];
}

- (void)appendSwappedDouble:(double)value;
{
    CFSwappedFloat64 v = CFConvertDoubleHostToSwapped(value);
    [self appendBytes:&v length:sizeof(value)];
}

- (void)appendString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;
{
    [self appendData:[value dataUsingEncoding:encoding]];
}

- (void)appendNullTerminatedString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;
{
    [self appendData:[value dataUsingEncoding:encoding]];
    [self appendData:PSYNullTerminatorDataForEncoding(encoding)];
}

- (void)replaceBytesInRange:(NSRange)range withData:(NSData *)value;
{
    [self replaceBytesInRange:range withBytes:[value bytes] length:[value length]];
}

- (void)replaceBytesInRange:(NSRange)range withInt8:(uint8_t)value;
{
    [self replaceBytesInRange:range withBytes:&value length:sizeof(value)];
}

#define REPLACE_METHOD(endian, size)                                      \
- (void)replaceBytesInRange:(NSRange)range with ## endian ## EndianInt ## size:(uint ## size ## _t)value; \
{                                                                           \
    value = CFSwapInt ## size ## HostTo ## endian(value);                   \
    [self replaceBytesInRange:range withBytes:&value length:sizeof(value)]; \
}

REPLACE_METHOD(Little, 16)
REPLACE_METHOD(Little, 32)
REPLACE_METHOD(Little, 64)
REPLACE_METHOD(Big, 16)
REPLACE_METHOD(Big, 32)
REPLACE_METHOD(Big, 64)

#undef REPLACE_METHOD

- (void)replaceBytesInRange:(NSRange)range withSInt8:(int8_t)value;
{
    [self replaceBytesInRange:range withInt8:*(uint8_t *)&value];
}

#define REPLACE_METHOD(endian, size)                                      \
- (void)replaceBytesInRange:(NSRange)range with ## endian ## EndianSInt ## size:(int ## size ## _t)value; \
{                                                                           \
    [self replaceBytesInRange:range with ## endian ## EndianInt ## size:*(uint ## size ## _t *)&value]; \
}

REPLACE_METHOD(Little, 16)
REPLACE_METHOD(Little, 32)
REPLACE_METHOD(Little, 64)
REPLACE_METHOD(Big, 16)
REPLACE_METHOD(Big, 32)
REPLACE_METHOD(Big, 64)

#undef REPLACE_METHOD

- (void)replaceBytesInRange:(NSRange)range withFloat:(float)value;
{
    [self replaceBytesInRange:range withBytes:&value length:sizeof(value)];
}

- (void)replaceBytesInRange:(NSRange)range withDouble:(double)value;
{
    [self replaceBytesInRange:range withBytes:&value length:sizeof(value)];
}

- (void)replaceBytesInRange:(NSRange)range withSwappedFloat:(float)value;
{
    CFSwappedFloat32 v = CFConvertFloatHostToSwapped(value);
    [self replaceBytesInRange:range withBytes:&v length:sizeof(value)];
}

- (void)replaceBytesInRange:(NSRange)range withSwappedDouble:(double)value;
{
    CFSwappedFloat64 v = CFConvertDoubleHostToSwapped(value);
    [self replaceBytesInRange:range withBytes:&v length:sizeof(value)];
}

- (void)replaceBytesInRange:(NSRange)range withString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;
{
    [self replaceBytesInRange:range withData:[value dataUsingEncoding:encoding]];
}

- (void)replaceBytesInRange:(NSRange)range withNullTerminatedString:(NSString *)value usingEncoding:(NSStringEncoding)encoding
{
    NSMutableData *data = [PSYNullTerminatorDataForEncoding(encoding) mutableCopy];
    [data replaceBytesInRange:NSMakeRange(0, 0) withData:[value dataUsingEncoding:encoding]];
    
    [self replaceBytesInRange:range withData:data];
}

@end
