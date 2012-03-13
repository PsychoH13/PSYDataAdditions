//
//  PSYStreamWriter.h
//  PSYDataAdditions
//
//  Created by Remy Demarest on 13/03/2012.
//  Copyright (c) 2012 NuLayer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSYStreamWriter : NSObject

+ (id)scannerWithInputStream:(NSOutputStream *)aStream;
- (id)initWithInputStream:(NSOutputStream *)aStream;

+ (id)scannerWithInputStream:(NSOutputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;
- (id)initWithInputStream:(NSOutputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;

- (void)groupWrites:(void(^)(PSYStreamWriter *writer))writes completion:(void(^)(void))completion;

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

@interface PSYStreamWriter (PSYDataWriterCompletionBlockAdditions)

- (void)writeInt8:(uint8_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeLittleEndianInt16:(uint16_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeLittleEndianInt32:(uint32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeLittleEndianInt64:(uint64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeBigEndianInt16:(uint16_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeBigEndianInt32:(uint32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeBigEndianInt64:(uint64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeSInt8:(int8_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeLittleEndianSInt16:(int16_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeLittleEndianSInt32:(int32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeLittleEndianSInt64:(int64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeBigEndianSInt16:(int16_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeBigEndianSInt32:(int32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeBigEndianSInt64:(int64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeLittleEndianVarint32:(uint32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeLittleEndianVarint64:(uint64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeBigEndianVarint32:(uint32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeBigEndianVarint64:(uint64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeLittleEndianSVarint32:(int32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeLittleEndianSVarint64:(int64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeBigEndianSVarint32:(int32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeBigEndianSVarint64:(int64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeLittleEndianZigZagVarint32:(int32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeLittleEndianZigZagVarint64:(int64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeBigEndianZigZagVarint32:(int32_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeBigEndianZigZagVarint64:(int64_t)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

// These methods write floating point values depending on the architecture of your processor
// they're usually not appropriate for network transmission
- (void)writeFloat:(float)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeDouble:(double)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeSwappedFloat:(float)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeSwappedDouble:(double)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeData:(NSData *)value withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

- (void)writeString:(NSString *)value usingEncoding:(NSStringEncoding)encoding withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;
- (void)writeNullTerminatedString:(NSString *)value usingEncoding:(NSStringEncoding)encoding withCompletionBlock:(void(^)(PSYStreamWriter *writer))block;

@end
