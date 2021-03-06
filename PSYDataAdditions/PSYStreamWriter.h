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

#import <Foundation/Foundation.h>

@protocol PSYStreamWriterDelegate;

@interface PSYStreamWriter : NSObject

- (void)groupWrites:(void(^)(PSYStreamWriter *writer))writes completion:(void(^)(void))completion;
- (void)writeBytes:(const uint8_t *)buffer ofLength:(NSUInteger)length;
- (void)writeInputStream:(NSInputStream *)aStream completion:(void(^)(void))completion;

@property(nonatomic, assign) id<PSYStreamWriterDelegate> delegate;

@end

@protocol PSYStreamWriterDelegate <NSObject>
@optional
- (void)streamWriter:(PSYStreamWriter *)sender didReceiveError:(NSError *)error;
- (void)streamWriterDidFinishWriting:(PSYStreamWriter *)sender;
- (void)streamWriterDidEncounterEnd:(PSYStreamWriter *)sender;
@end

@interface PSYStreamWriter (PSYStreamWriterCreation)

+ (id)writerWithOutputStream:(NSOutputStream *)aStream;
+ (id)writerWithOutputStream:(NSOutputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;

- (id)initWithOutputStream:(NSOutputStream *)aStream;
- (id)initWithOutputStream:(NSOutputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;

@end

@interface PSYStreamWriter (PSYDataWriterAdditions)

- (void)writeInt8:(uint8_t)value;

- (void)writeLittleEndianInt16:(uint16_t)value;
- (void)writeLittleEndianInt32:(uint32_t)value;
- (void)writeLittleEndianInt64:(uint64_t)value;

- (void)writeBigEndianInt16:(uint16_t)value;
- (void)writeBigEndianInt32:(uint32_t)value;
- (void)writeBigEndianInt64:(uint64_t)value;

- (void)writeSInt8:(int8_t)value;

- (void)writeLittleEndianSInt16:(int16_t)value;
- (void)writeLittleEndianSInt32:(int32_t)value;
- (void)writeLittleEndianSInt64:(int64_t)value;

- (void)writeBigEndianSInt16:(int16_t)value;
- (void)writeBigEndianSInt32:(int32_t)value;
- (void)writeBigEndianSInt64:(int64_t)value;

- (void)writeLittleEndianVarint32:(uint32_t)value;
- (void)writeLittleEndianVarint64:(uint64_t)value;

- (void)writeBigEndianVarint32:(uint32_t)value;
- (void)writeBigEndianVarint64:(uint64_t)value;

- (void)writeLittleEndianSVarint32:(int32_t)value;
- (void)writeLittleEndianSVarint64:(int64_t)value;

- (void)writeBigEndianSVarint32:(int32_t)value;
- (void)writeBigEndianSVarint64:(int64_t)value;

- (void)writeLittleEndianZigZagVarint32:(int32_t)value;
- (void)writeLittleEndianZigZagVarint64:(int64_t)value;

- (void)writeBigEndianZigZagVarint32:(int32_t)value;
- (void)writeBigEndianZigZagVarint64:(int64_t)value;

// These methods write floating point values depending on the architecture of your processor
// they're usually not appropriate for network transmission
- (void)writeFloat:(float)value;
- (void)writeDouble:(double)value;

- (void)writeSwappedFloat:(float)value;
- (void)writeSwappedDouble:(double)value;

- (void)writeData:(NSData *)value;

- (void)writeString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;
- (void)writeNullTerminatedString:(NSString *)value usingEncoding:(NSStringEncoding)encoding;

@end
