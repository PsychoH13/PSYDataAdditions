//
//  PSYFileHandleScannerTests.m
//  PSYDataAdditions
//
//  Created by Remy Demarest on 11/03/2012.
//  Copyright (c) 2012 NuLayer Inc. All rights reserved.
//

#import "PSYFileHandleScannerTests.h"
#import "PSYDataScanner.h"

@interface PSYDataFileHandle : NSFileHandle
- (id)initWithData:(NSData *)data;
- (id)initWithData:(NSData *)data maximumReadSize:(unsigned long long)maxSize;
@end

static char testData[] = {
    0x11, 0x00, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF,
    0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 't' , 'h' , 'i' , 's' , ' ' , 'i' , 's' , ' ' , 'a' , ' ' , 's' ,
    'e' , 'n' , 't' , 'e' , 'n' , 'c' , 'e' , ' ' , 'i' , 'n' , ' ' , 't' , 'h' , 'e' , ' ' , 'm' ,
    'i' , 'd' , 'd' , 'l' , 'e' , 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xCC,
    0x55, 0x66, 0x77, 0x88, 0x99, 0xCC, 0x55, 0x66, 0x77, 0x88, 0x99, 0xCC, 0x55, 0x66, 0x77, 0x88,
    0x99, 0xAA, 0xFF, 0xFF, 0xFF,
};

@implementation PSYFileHandleScannerTests

- (void)testScanUpToData;
{
    NSData         *data    = [NSData dataWithBytes:testData length:sizeof(testData)];
    NSFileHandle   *handle  = [[[PSYDataFileHandle alloc] initWithData:data] autorelease];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithFileHandle:handle];
    
    uint16_t scan1 = 0;
    STAssertTrueNoThrow([scanner scanBigEndianInt16:&scan1], @"The scanning of big endian uint16_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)2, @"The scan location should have been advanced by 2.");
    STAssertEquals(scan1, (uint16_t)0x1100, @"The scanned value should be equal to the first 4 bytes in the data.");
    
    uint8_t  scan2 = 0;
    STAssertTrueNoThrow([scanner scanInt8:&scan2], @"The scanning of big endian uint8_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)3, @"The scan location should have been advanced by 2.");
    STAssertEquals(scan2, (uint8_t)0x22, @"The scanned value should be equal to the next byte in the data.");
    
    uint32_t scan3 = 0;
    STAssertTrueNoThrow([scanner scanBigEndianInt32:&scan3], @"The scanning of big endian uint32_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)7, @"The scan location should have been advanced by 2.");
    STAssertEquals(scan3, (uint32_t)0x33445566, @"The scanned value should be equal to the next 4 bytes in the data.");
    
    uint64_t scan4 = 0;
    STAssertTrueNoThrow([scanner scanBigEndianInt64:&scan4], @"The scanning of big endian uint64_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)15, @"The scan location should have been advanced by 2.");
    STAssertEquals(scan4, (uint64_t)0x778899aabbccddee, @"The scanned value should be equal to the next 8 bytes in the data.");
    
    uint32_t scan5 = 0;
    STAssertTrueNoThrow([scanner scanBigEndianInt32:&scan5], @"The scanning of big endian uint32_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)19, @"The scan location should have been advanced by 2.");
    STAssertEquals(scan5, (uint32_t)0xffbbccdd, @"The scanned value should be equal to the next 4 bytes in the data.");
    
    uint16_t scan6 = 0;
    STAssertTrueNoThrow([scanner scanBigEndianInt16:&scan6], @"The scanning of big endian uint16_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)21, @"The scan location should have been advanced by 2.");
    STAssertEquals(scan6, (uint16_t)0xeeff, @"The scanned value should be equal to the next 2 bytes in the data.");
    
    NSString *scan8 = nil;
    STAssertTrueNoThrow([scanner scanNullTerminatedString:&scan8 withEncoding:NSUTF8StringEncoding], @"The scanning of null-terminated string should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)54, @"The scan location should have been advanced right after the null terminator.");
    STAssertEqualObjects(scan8, @"this is a sentence in the middle", @"The scanned value should be equal to the next bytes until the null terminator.");
    
    static char exp[] = {
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xCC, 0x55, 0x66, 0x77, 0x88,
        0x99, 0xCC, 0x55, 0x66, 0x77, 0x88, 0x99, 0xCC, 0x55, 0x66, 0x77, 0x88, 0x99
    };
    NSData *expected = [NSData dataWithBytes:exp length:sizeof(exp)];
    NSData *stopData = [NSData dataWithBytes:(char[]){ 0xAA, 0xFF, 0xFF, 0xFF } length:4];
    
    NSData *scan9    = nil;
    STAssertTrueNoThrow([scanner scanUpToData:stopData intoData:&scan9], @"The scanning of data up to a specific data should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)81, @"The scan location should have been advanced before the stop location.");
    STAssertEqualObjects(scan9, expected, @"The scanned value should be equal to the next bytes until the stop data.");
    
    NSData *scan10   = nil;
    STAssertTrueNoThrow([scanner scanData:stopData intoData:&scan10], @"The scanning of the stop data should succeed and not throw an exception");
    STAssertTrueNoThrow([scanner isAtEnd], @"The scanner should be at the end of the stream.");
    STAssertEqualObjects(scan10, stopData, @"The scanned value should be equal to the stop marker.");
    
    [scanner setScanLocation:21];
    NSString *scan11 = nil;
    STAssertTrueNoThrow([scanner scanString:&scan11 ofLength:32 usingEncoding:NSUTF8StringEncoding], @"The scanning of length-supplied string should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)53, @"The scan location should have been advanced right after the end of the string.");
    STAssertEqualObjects(scan11, @"this is a sentence in the middle", @"The scanned value should be equal to the next bytes until the null terminator.");
}

@end

@implementation PSYDataFileHandle
{
    NSData             *_data;
    unsigned long long  _length;
    unsigned long long  _maxReadSize;
    unsigned long long  _offsetInData;
}

- (id)initWithData:(NSData *)data
{
    return [self initWithData:data maximumReadSize:9];
}

- (id)initWithData:(NSData *)data maximumReadSize:(unsigned long long)maxSize;
{
    if((self = [super init]))
    {
        _data        = [data copy];
        _length      = [_data length];
        _maxReadSize = maxSize;
    }
    return self;
}

- (void)dealloc
{
    [_data release];
    [super dealloc];
}

- (int)fileDescriptor;
{
    return -1;
}

- (NSData *)availableData;
{
    return _data;
}

- (NSData *)readDataToEndOfFile;
{
    NSData *ret = [_data subdataWithRange:NSMakeRange(_offsetInData, _length - _offsetInData)];
    _offsetInData = _length;
    return ret;
}

- (NSData *)readDataOfLength:(NSUInteger)length;
{
    length = MIN(MIN(_maxReadSize, length), _length - _offsetInData);
    NSData *ret = [_data subdataWithRange:NSMakeRange(_offsetInData, length)];
    _offsetInData += length;
    return ret;
}

- (void)writeData:(NSData *)data;
{
    // No need to support this one for tests
}

- (unsigned long long)offsetInFile;
{
    return _offsetInData;
}

- (unsigned long long)seekToEndOfFile;
{
    _offsetInData = _length;
    return _offsetInData;
}

- (void)seekToFileOffset:(unsigned long long)offset;
{
    if(offset > _length) [NSException raise:NSRangeException format:@"Trying to go to far in the range"];
    
    _offsetInData = offset;
}

- (void)truncateFileAtOffset:(unsigned long long)offset;
{
    // No need to support this one for tests
}

- (void)synchronizeFile;
{
    // No need to support this one for tests
}

- (void)closeFile;
{
    // No need to support this one for tests
}

@end
