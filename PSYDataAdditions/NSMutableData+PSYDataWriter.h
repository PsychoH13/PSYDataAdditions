/*
 NSMutableData+PSYDataWriter.h
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

#import <Foundation/Foundation.h>

@interface NSMutableData (PSYDataWriter)

- (void)appendInt8:(uint8_t)value;

- (void)appendLittleEndianInt16:(uint16_t)value;
- (void)appendLittleEndianInt32:(uint32_t)value;
- (void)appendLittleEndianInt64:(uint64_t)value;

- (void)appendBigEndianInt16:(uint16_t)value;
- (void)appendBigEndianInt32:(uint32_t)value;
- (void)appendBigEndianInt64:(uint64_t)value;

// These methods append floating point values depending on the architecture of your processor
// they're usually not appropriate for network transmission
- (void)appendFloat:(float)value;
- (void)appendDouble:(double)value;

- (void)appendSwappedFloat:(float)value;
- (void)appendSwappedDouble:(double)value;

- (void)appendString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;

- (void)replaceBytesInRange:(NSRange)range withData:(NSData *)value;

- (void)replaceBytesInRange:(NSRange)range withInt8:(uint8_t)value;

- (void)replaceBytesInRange:(NSRange)range withLittleEndianInt16:(uint16_t)value;
- (void)replaceBytesInRange:(NSRange)range withLittleEndianInt32:(uint32_t)value;
- (void)replaceBytesInRange:(NSRange)range withLittleEndianInt64:(uint64_t)value;

- (void)replaceBytesInRange:(NSRange)range withBigEndianInt16:(uint16_t)value;
- (void)replaceBytesInRange:(NSRange)range withBigEndianInt32:(uint32_t)value;
- (void)replaceBytesInRange:(NSRange)range withBigEndianInt64:(uint64_t)value;

// These methods append floating point values depending on the architecture of your processor
// they're usually not appropriate for network transmission
- (void)replaceBytesInRange:(NSRange)range withFloat:(float)value;
- (void)replaceBytesInRange:(NSRange)range withDouble:(double)value;

- (void)replaceBytesInRange:(NSRange)range withSwappedFloat:(float)value;
- (void)replaceBytesInRange:(NSRange)range withSwappedDouble:(double)value;

- (void)replaceBytesInRange:(NSRange)range withString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;

@end
