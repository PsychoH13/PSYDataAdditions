//
//  PSYStreamScanner.h
//  PSYDataAdditions
//
//  Created by Remy Demarest on 13/03/2012.
//  Copyright (c) 2012 NuLayer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSYStreamScannerMessage;

@interface PSYStreamScanner : NSObject

+ (id)scannerWithInputStream:(NSInputStream *)aStream;
- (id)initWithInputStream:(NSInputStream *)aStream;

+ (id)scannerWithInputStream:(NSInputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;
- (id)initWithInputStream:(NSInputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;

// Message used to scan the data when no expectations have been provided
// If nil and if no expectations are available, all the data received by the scanner are ignored
@property(nonatomic, copy) PSYStreamScannerMessage *defaultMessage;

- (PSYStreamScannerMessage *)messageForIdentifier:(NSString *)identifier;
- (void)setMessage:(PSYStreamScannerMessage *)aMessage forIdentifier:(NSString *)identifier;

// Overrides the previous expectation if any,
// Use -expectMessagesWithIdentifiers: if multiple messages can be matched
- (void)expectMessageWithIdentifier:(NSString *)identifier;

// Overrides the previous expectations if any,
// If an expected message is matched all the expectations are removed,
// You need to call this method again if you expect the messages again
- (void)expectMessagesWithIdentifiers:(NSArray *)identifiers;

- (void)cancelExpectations;

// Queue-based alternatives
- (void)tailAppendExpectedMessageWithIdentifier:(NSString *)identifier;
- (void)tailAppendExpectedMessagesWithIdentifiers:(NSArray *)identifiers;

- (void)headInsertExpectedMessageWithIdentifier:(NSString *)identifier;
- (void)headInsertExpectedMessagesWithIdentifiers:(NSArray *)identifiers;

- (void)removeExpectedMessagesWithIdentifiers:(NSArray *)identifiers;
- (void)removeAllExpectations;

@end

@interface PSYStreamScannerMessage : NSObject <NSCopying, NSMutableCopying>
@property(nonatomic, readonly, copy) NSData     *startData;
@property(nonatomic, readonly, copy) NSData     *stopData;
@property(nonatomic, readonly)       NSUInteger  minimumPartialLength;
@property(nonatomic, readonly)       NSUInteger  maximumLength;

@property(nonatomic, readonly, copy) void(^callbackBlock)(PSYStreamScanner *scanner);
@end

@interface PSYMutableStreamScannerMessage : PSYStreamScannerMessage
@property(nonatomic, readwrite, copy) NSData     *startData;
@property(nonatomic, readwrite, copy) NSData     *stopData;
@property(nonatomic, readwrite)       NSUInteger  minimumPartialLength;
@property(nonatomic, readwrite)       NSUInteger  maximumLength;

@property(nonatomic, readwrite, copy) void(^callbackBlock)(PSYStreamScanner *scanner);
@end

@interface PSYStreamScanner (PSYDataScannerAdditions)

- (NSUInteger)dataLength;
- (BOOL)isAtEnd;
- (BOOL)isFinished;

- (BOOL)scanInt8:(uint8_t *)value;

- (BOOL)scanLittleEndianInt16:(uint16_t *)value;
- (BOOL)scanLittleEndianInt32:(uint32_t *)value;
- (BOOL)scanLittleEndianInt64:(uint64_t *)value;

- (BOOL)scanBigEndianInt16:(uint16_t *)value;
- (BOOL)scanBigEndianInt32:(uint32_t *)value;
- (BOOL)scanBigEndianInt64:(uint64_t *)value;

- (BOOL)scanSInt8:(int8_t *)value;

- (BOOL)scanLittleEndianSInt16:(int16_t *)value;
- (BOOL)scanLittleEndianSInt32:(int32_t *)value;
- (BOOL)scanLittleEndianSInt64:(int64_t *)value;

- (BOOL)scanBigEndianSInt16:(int16_t *)value;
- (BOOL)scanBigEndianSInt32:(int32_t *)value;
- (BOOL)scanBigEndianSInt64:(int64_t *)value;

- (BOOL)scanLittleEndianVarint32:(uint32_t *)value;
- (BOOL)scanLittleEndianVarint64:(uint64_t *)value;

- (BOOL)scanBigEndianVarint32:(uint32_t *)value;
- (BOOL)scanBigEndianVarint64:(uint64_t *)value;

- (BOOL)scanLittleEndianSVarint32:(int32_t *)value;
- (BOOL)scanLittleEndianSVarint64:(int64_t *)value;

- (BOOL)scanBigEndianSVarint32:(int32_t *)value;
- (BOOL)scanBigEndianSVarint64:(int64_t *)value;

- (BOOL)scanLittleEndianZigZagVarint32:(int32_t *)value;
- (BOOL)scanLittleEndianZigZagVarint64:(int64_t *)value;

- (BOOL)scanBigEndianZigZagVarint32:(int32_t *)value;
- (BOOL)scanBigEndianZigZagVarint64:(int64_t *)value;

// These methods scan floating point values depending on the architecture of your processor
// they're usually not appropriate for network transmission
- (BOOL)scanFloat:(float *)value;
- (BOOL)scanDouble:(double *)value;

- (BOOL)scanSwappedFloat:(float *)value;
- (BOOL)scanSwappedDouble:(double *)value;

- (BOOL)scanData:(NSData **)data ofLength:(unsigned long long)length;
- (BOOL)scanData:(NSData *)data intoData:(NSData **)dataValue;
- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData **)dataValue;
- (BOOL)scanString:(NSString **)value ofLength:(unsigned long long)length usingEncoding:(NSStringEncoding)encoding;
- (BOOL)scanUpToString:(NSString *)stopString intoString:(NSString **)value usingEncoding:(NSStringEncoding)encoding;
- (BOOL)scanNullTerminatedString:(NSString **)value withEncoding:(NSStringEncoding)encoding;

@end
