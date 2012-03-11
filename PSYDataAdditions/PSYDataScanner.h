/*
 PSYDataScanner.h
 Created by Remy "Psy" Demarest on 20/07/2010.
 
 Copyright (c) 2010 Remy "Psy" Demarest

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

typedef enum _PSYDataScannerLocation
{
    PSYDataScannerLocationBegin,
    PSYDataScannerLocationCurrent,
    PSYDataScannerLocationEnd,
} PSYDataScannerLocation;

@interface PSYDataScanner : NSObject
{
@private
    NSData     *_scannedData;
    NSUInteger  _dataLength;
    NSUInteger  _scanLocation;
}

+ (id)scannerWithData:(NSData *)dataToScan;
- (id)initWithData:(NSData *)dataToScan;

@property(readonly, copy, nonatomic) NSData *data;

@property(nonatomic) NSUInteger scanLocation;

- (BOOL)isAtEnd;

// Returns NO if the computed range is outside of the range of the data
- (BOOL)setScanLocation:(NSInteger)relativeLocation relativeTo:(PSYDataScannerLocation)startPoint;

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

- (BOOL)scanData:(NSData **)data ofLength:(NSUInteger)length;
- (BOOL)scanData:(NSData *)data intoData:(NSData **)dataValue;
- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData **)dataValue;
- (BOOL)scanString:(NSString **)value ofLength:(NSUInteger)length usingEncoding:(NSStringEncoding)encoding;
- (BOOL)scanNullTerminatedString:(NSString **)value withEncoding:(NSStringEncoding)encoding;

@end

NSData *PSYNullTerminatorDataForEncoding(NSStringEncoding encoding);
