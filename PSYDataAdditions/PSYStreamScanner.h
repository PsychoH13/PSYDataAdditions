/*
 PSYStreamScanner.h
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

@class PSYStreamScannerMessage;

@interface PSYStreamScanner : NSObject

// Message used to scan the data when no expectations have been provided
// If nil and if no expectations are available, all the data received by the scanner are ignored
@property(nonatomic, copy) NSArray *defaultMessages;

- (PSYStreamScannerMessage *)messageForIdentifier:(NSString *)identifier;
- (void)setMessage:(PSYStreamScannerMessage *)aMessage forIdentifier:(NSString *)identifier;

// Overrides the previous expectation if any,
// Use -expectMessagesWithIdentifiers: if multiple messages can be matched
- (void)expectMessageWithIdentifier:(NSString *)identifier;

// Overrides the previous expectations if any,
// If an expected message is matched all the expectations are removed,
// You need to call this method again if you expect the messages again
- (void)expectMessagesWithIdentifiers:(NSArray *)identifiers;

- (void)expectMessage:(PSYStreamScannerMessage *)message;
- (void)expectMessagesInArray:(NSArray *)messages;

- (void)removeExpectations;

@end

@interface PSYStreamScanner (PSYStreamScannerCreation)

+ (id)scannerWithInputStream:(NSInputStream *)aStream;
- (id)initWithInputStream:(NSInputStream *)aStream;

+ (id)scannerWithInputStream:(NSInputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;
- (id)initWithInputStream:(NSInputStream *)aStream closeOnDealloc:(BOOL)closeOnDealloc;

@end

@interface PSYStreamScannerMessage : NSObject <NSCopying, NSMutableCopying>
@property(nonatomic, readonly, copy) NSData         *startData;
@property(nonatomic, readonly, copy) NSData         *stopData;
@property(nonatomic, readonly)       NSUInteger      minimumPartialLength;
@property(nonatomic, readonly)       NSUInteger      maximumLength;

// Overall Timeout indicates when the request should stop waiting for the data after the scanning started
@property(nonatomic, readonly)       NSTimeInterval  overallTimeoutInterval;
// Partial Timeout indicates when to stop waiting for the "minimumPartialLength" or "stopData" indicators to be reached
@property(nonatomic, readonly)       NSTimeInterval  partialTimeoutInterval;

@property(nonatomic, readonly, copy) void(^callbackBlock)(PSYStreamScanner *scanner);
@end

@interface PSYMutableStreamScannerMessage : PSYStreamScannerMessage
@property(nonatomic, readwrite, copy) NSData         *startData;
@property(nonatomic, readwrite, copy) NSData         *stopData;
@property(nonatomic, readwrite)       NSUInteger      minimumPartialLength;
@property(nonatomic, readwrite)       NSUInteger      maximumLength;

@property(nonatomic, readwrite)       NSTimeInterval  overallTimeoutInterval;
@property(nonatomic, readwrite)       NSTimeInterval  partialTimeoutInterval;

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
