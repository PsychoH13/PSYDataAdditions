/*
 PSYDataAdditionsTests.m
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

#import "PSYDataAdditionsTests.h"
#import "PSYDataScanner.h"
#import "NSMutableData+PSYDataWriter.h"

@implementation PSYDataAdditionsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testNilData
{
    STAssertNil([PSYDataScanner scannerWithData:nil], @"When nil is provided as data object, the returned scanner should be nil.");
}

- (void)testEmptyData
{
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:[NSData data]];
    
    STAssertNotNil(scanner, @"Even if the data is empty, the scanner should not be nil.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location of the scanner should start at zero.");
    
    STAssertTrue([scanner isAtEnd], @"When the data is empty, the scanner is at end from the beginning.");
}

- (void)testSetScanLocation
{
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:[NSMutableData dataWithLength:10]];
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location of the scanner should start at zero.");
    STAssertFalse([scanner isAtEnd], @"When the data is not empty, the scanner should not be at end.");
    
    STAssertNoThrow([scanner setScanLocation:5], @"Setting a scan location in the data bounds should not throw an exception.");
    STAssertFalse([scanner isAtEnd], @"When the data is not empty, the scanner should not be at end.");
    
    STAssertNoThrow([scanner setScanLocation:10], @"Setting a scan location of the length of the data should not throw an exception.");
    STAssertTrue([scanner isAtEnd], @"When the scan location is set to the length of the data, the scanner is considered at the end.");
    
    STAssertThrowsSpecificNamed([scanner setScanLocation:11], NSException, NSRangeException, @"When the scan location is set beyond the length of the data, an NSRangeException exception is thrown.");
}

- (void)testScanLocationZeroRelativeTo
{
    NSData *data = [NSMutableData dataWithLength:10];
    
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    
    [scanner setScanLocation:5];
    
    STAssertTrueNoThrow([scanner setScanLocation:0 relativeTo:PSYDataScannerLocationCurrent], @"Setting the location to the current should work and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)5, @"The scan location should have remained the same.");
    
    STAssertTrueNoThrow([scanner setScanLocation:0 relativeTo:PSYDataScannerLocationBegin], @"Setting the location to the beginning should work and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should have been set to 0.");
    
    STAssertTrueNoThrow([scanner setScanLocation:0 relativeTo:PSYDataScannerLocationEnd], @"Setting the location to the end should work and not throw an exception");
    
    STAssertEquals([scanner scanLocation], [data length], @"The scan location should have been set to the length of the scanned data.");
}

- (void)testScanLocationRelativeTo
{
    NSData *data = [NSMutableData dataWithLength:10];
    
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    
    // Set positive value
    [scanner setScanLocation:5];
    STAssertTrueNoThrow([scanner setScanLocation:1 relativeTo:PSYDataScannerLocationCurrent], @"Setting the location to the current location plus 1 should work and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)6, @"The scan location should have been set to current + 1.");
    STAssertTrueNoThrow([scanner setScanLocation:1 relativeTo:PSYDataScannerLocationBegin], @"Setting the location to the beginning plus 1 should work and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)1, @"The scan location should have been set to 1.");
    STAssertFalseNoThrow([scanner setScanLocation:1 relativeTo:PSYDataScannerLocationEnd], @"Setting the location to the end should not work and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)1, @"The scan location should have remained at the location where it was before.");
    
    // Negative value
    [scanner setScanLocation:5];
    STAssertTrueNoThrow([scanner setScanLocation:-1 relativeTo:PSYDataScannerLocationCurrent], @"Setting the location to the current location minus 1 should work and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)4, @"The scan location should have been set to current - 1.");
    STAssertFalseNoThrow([scanner setScanLocation:-1 relativeTo:PSYDataScannerLocationBegin], @"Setting the location to the beginning minus 1 should work and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)4, @"The scan location should have remained at the location where it was before.");
    STAssertTrueNoThrow([scanner setScanLocation:-1 relativeTo:PSYDataScannerLocationEnd], @"Setting the location to the end minus 1 should work and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)9, @"The scan location should have been set to the length - 1.");
}

- (void)testScanEmptyData
{
    NSData         *data    = [NSData data];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    uint8_t         value8  = 0;
    uint16_t        value16 = 0;
    uint32_t        value32 = 0;
    uint64_t        value64 = 0;
    
    STAssertFalseNoThrow([scanner scanInt8:&value8], @"The scanning of one byte should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    STAssertEquals(value8, (uint8_t)0, @"The scanned value should have not changed.");
    
    STAssertFalseNoThrow([scanner scanLittleEndianInt16:&value16], @"The scanning of little endian uint16_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    STAssertEquals(value16, (uint16_t)0, @"The scanned value should have not changed.");
    
    STAssertFalseNoThrow([scanner scanBigEndianInt16:&value16], @"The scanning of big endian uint16_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    STAssertEquals(value16, (uint16_t)0, @"The scanned value should have not changed.");
    
    STAssertFalseNoThrow([scanner scanLittleEndianInt32:&value32], @"The scanning of little endian uint32_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    STAssertEquals(value32, (uint32_t)0, @"The scanned value should have not changed.");
    
    STAssertFalseNoThrow([scanner scanBigEndianInt32:&value32], @"The scanning of big endian uint32_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    STAssertEquals(value32, (uint32_t)0, @"The scanned value should have not changed.");
    
    STAssertFalseNoThrow([scanner scanLittleEndianInt64:&value64], @"The scanning of little endian uint64_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    STAssertEquals(value64, (uint64_t)0, @"The scanned value should have not changed.");
    
    STAssertFalseNoThrow([scanner scanBigEndianInt64:&value64], @"The scanning of big endian uint64_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    STAssertEquals(value64, (uint64_t)0, @"The scanned value should have not changed.");
}

- (void)testScanDataLittleEndian
{
    NSData         *data    = [NSData dataWithBytes:(uint8_t[8]){ 0xFF, 0xCC, 0x99, 0x66, 0xEF, 0xBE, 0xAD, 0xDE } length:8];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    uint8_t         value8  = 0;
    uint16_t        value16 = 0;
    uint32_t        value32 = 0;
    uint64_t        value64 = 0;
    
    [scanner setScanLocation:7];
    STAssertTrueNoThrow([scanner scanInt8:&value8], @"The scanning of one byte should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)8, @"The scan location should have been advanced by 1.");
    STAssertEquals(value8, (uint8_t)0xDE, @"The scanned value should be equal to the first byte in the data.");
    
    [scanner setScanLocation:6];
    STAssertTrueNoThrow([scanner scanLittleEndianInt16:&value16], @"The scanning of little endian uint16_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)8, @"The scan location should have been advanced by 2.");
    STAssertEquals(value16, (uint16_t)0xDEAD, @"The scanned value should be equal to the first 2 bytes in the data.");
    
    [scanner setScanLocation:4];
    STAssertTrueNoThrow([scanner scanLittleEndianInt32:&value32], @"The scanning of little endian uint32_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)8, @"The scan location should have been advanced by 4.");
    STAssertEquals(value32, (uint32_t)0xDEADBEEF, @"The scanned value should be equal to the first 4 bytes in the data.");
    
    [scanner setScanLocation:0];
    STAssertTrueNoThrow([scanner scanLittleEndianInt64:&value64], @"The scanning of little endian uint64_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)8, @"The scan location should have been advanced by 8.");
    STAssertEquals(value64, (uint64_t)0xDEADBEEF6699CCFF, @"The scanned value should be equal to the first 8 bytes in the data.");
}

- (void)testScanDataBigEndian
{
    NSData         *data    = [NSData dataWithBytes:(uint8_t[8]){ 0xDE, 0xAD, 0xBE, 0xEF, 0x66, 0x99, 0xCC, 0xFF } length:8];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    uint16_t        value16 = 0;
    uint32_t        value32 = 0;
    uint64_t        value64 = 0;
    
    [scanner setScanLocation:0];
    STAssertTrueNoThrow([scanner scanBigEndianInt16:&value16], @"The scanning of little endian uint16_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)2, @"The scan location should have been advanced by 2.");
    STAssertEquals(value16, (uint16_t)0xDEAD, @"The scanned value should be equal to the first 2 bytes in the data.");
    
    [scanner setScanLocation:0];
    STAssertTrueNoThrow([scanner scanBigEndianInt32:&value32], @"The scanning of little endian uint32_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)4, @"The scan location should have been advanced by 4.");
    STAssertEquals(value32, (uint32_t)0xDEADBEEF, @"The scanned value should be equal to the first 4 bytes in the data.");
    
    [scanner setScanLocation:0];
    STAssertTrueNoThrow([scanner scanBigEndianInt64:&value64], @"The scanning of big endian uint64_t should succeed and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)8, @"The scan location should have been advanced by 8.");
    STAssertEquals(value64, (uint64_t)0xDEADBEEF6699CCFF, @"The scanned value should be equal to the first 8 bytes in the data.");
}

- (void)testScanSmallData
{
    NSData         *data    = [NSData dataWithBytes:(uint8_t[7]){ 0xDE, 0xAD, 0xBE, 0xEF, 0x66, 0x99, 0xCC } length:7];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    uint16_t        value16 = 0;
    uint32_t        value32 = 0;
    uint64_t        value64 = 0;
    
    [scanner setScanLocation:6];
    STAssertFalseNoThrow([scanner scanBigEndianInt16:&value16], @"The scanning of big endian uint16_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)6, @"The scan location should not have changed.");
    STAssertEquals(value16, (uint16_t)0, @"The scanned value should have not changed.");
    
    [scanner setScanLocation:6];
    STAssertFalseNoThrow([scanner scanLittleEndianInt16:&value16], @"The scanning of little endian uint16_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)6, @"The scan location should not have changed.");
    STAssertEquals(value16, (uint16_t)0, @"The scanned value should have not changed.");
    
    [scanner setScanLocation:4];
    STAssertFalseNoThrow([scanner scanBigEndianInt32:&value32], @"The scanning of big endian uint32_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)4, @"The scan location should not have changed.");
    STAssertEquals(value32, (uint32_t)0, @"The scanned value should have not changed.");
    
    [scanner setScanLocation:4];
    STAssertFalseNoThrow([scanner scanLittleEndianInt32:&value32], @"The scanning of little endian uint32_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)4, @"The scan location should not have changed.");
    STAssertEquals(value32, (uint32_t)0, @"The scanned value should have not changed.");
    
    [scanner setScanLocation:0];
    STAssertFalseNoThrow([scanner scanBigEndianInt64:&value64], @"The scanning of little endian uint64_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    STAssertEquals(value64, (uint64_t)0, @"The scanned value should have not changed.");
    
    [scanner setScanLocation:0];
    STAssertFalseNoThrow([scanner scanLittleEndianInt64:&value64], @"The scanning of little endian uint64_t should fail and not throw an exception");
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    STAssertEquals(value64, (uint64_t)0, @"The scanned value should have not changed.");
}

- (void)testScanLittleEndianVarint32
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[2]){0x96, 0x01} length:2];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    uint32_t        valueVar32 = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:2];
    [writtenData appendLittleEndianVarint32:150];
    
    STAssertTrueNoThrow([scanner scanLittleEndianVarint32:&valueVar32], @"The scanning of little endian varint 32 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)2, @"The scan location should have been advanced by 2.");
    
    STAssertEquals(valueVar32, (uint32_t)150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanLittleEndianVarint64
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[2]){0x96, 0x01} length:2];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    uint64_t        valueVar64 = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:2];
    [writtenData appendLittleEndianVarint64:150];
    
    STAssertTrueNoThrow([scanner scanLittleEndianVarint64:&valueVar64], @"The scanning of little endian varint 64 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)2, @"The scan location should have been advanced by 2.");
    
    STAssertEquals(valueVar64, (uint64_t)150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanBigEndianVarint32
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[5]){0x80, 0x80, 0x80, 0xB0, 0x09} length:5];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    uint32_t        valueVar64 = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:5];
    [writtenData appendBigEndianVarint32:150];
    
    STAssertTrueNoThrow([scanner scanBigEndianVarint32:&valueVar64], @"The scanning of big endian varint 32 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)5, @"The scan location should have been advanced by 5.");
    
    STAssertEquals(valueVar64, (uint32_t)150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanBigEndianVarint64
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[10]){0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x96, 0x01} length:10];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    uint64_t        valueVar64 = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:10];
    [writtenData appendBigEndianVarint64:150];
    
    STAssertTrueNoThrow([scanner scanBigEndianVarint64:&valueVar64], @"The scanning of big endian varint 64 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)10, @"The scan location should have been advanced by 10.");
    
    STAssertEquals(valueVar64, (uint64_t)150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanLittleEndianSVarint32
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[5]){0xEA, 0xFE, 0xFF, 0xFF, 0x0F} length:5];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    int32_t         valueSVar32 = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:5];
    [writtenData appendLittleEndianSVarint32:-150];
    
    STAssertTrueNoThrow([scanner scanLittleEndianSVarint32:&valueSVar32], @"The scanning of little endian signed varint 32 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)5, @"The scan location should have been advanced by 5");
    
    STAssertEquals(valueSVar32, (int32_t)-150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanLittleEndianSVarint64
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[10]){0xEA, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01} length:10];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    int64_t         valueSVar64 = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:10];
    [writtenData appendLittleEndianSVarint64:-150];
    
    STAssertTrueNoThrow([scanner scanLittleEndianSVarint64:&valueSVar64], @"The scanning of little endian signed varint 64 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)10, @"The scan location should have been advanced by 10.");
    
    STAssertEquals(valueSVar64, (int64_t)-150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanBigEndianSVarint32
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[5]){0xFF, 0xFF, 0xFF, 0xD7, 0x06} length:5];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    int32_t         scannedValue = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:5];
    [writtenData appendBigEndianSVarint32:-150];
    
    STAssertTrueNoThrow([scanner scanBigEndianSVarint32:&scannedValue], @"The scanning of big endian signed varint 32 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)5, @"The scan location should have been advanced by 5");
    
    STAssertEquals(scannedValue, (int32_t)-150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanBigEndianSVarint64
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[10]){0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x6A} length:9];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    int64_t         scannedValue = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:9];
    [writtenData appendBigEndianSVarint64:-150];
    
    STAssertTrueNoThrow([scanner scanBigEndianSVarint64:&scannedValue], @"The scanning of big endian signed varint 64 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)9, @"The scan location should have been advanced by 9.");
    
    STAssertEquals(scannedValue, (int64_t)-150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanLittleEndianZigZagVarint32
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[2]){0xAB, 0x02} length:2];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    int32_t         scannedValue = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:2];
    [writtenData appendLittleEndianZigZagVarint32:-150];
    
    STAssertTrueNoThrow([scanner scanLittleEndianZigZagVarint32:&scannedValue], @"The scanning of little endian zig zag varint 32 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)2, @"The scan location should have been advanced by 2.");
    
    STAssertEquals(scannedValue, (int32_t)-150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanLittleEndianZigZagVarint64
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[2]){0xAB, 0x02} length:2];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    int64_t         scannedValue = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:2];
    [writtenData appendLittleEndianZigZagVarint64:-150];
    
    STAssertTrueNoThrow([scanner scanLittleEndianZigZagVarint64:&scannedValue], @"The scanning of little endian zig zag varint 64 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)2, @"The scan location should have been advanced by 2.");
    
    STAssertEquals(scannedValue, (int64_t)-150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanBigEndianZigZagVarint32
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[5]){0x80, 0x80, 0x84, 0xD8, 0x02} length:5];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    int32_t         scannedValue = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:5];
    [writtenData appendBigEndianZigZagVarint32:-150];
    
    STAssertTrueNoThrow([scanner scanBigEndianZigZagVarint32:&scannedValue], @"The scanning of big endian zig zag varint 32 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)5, @"The scan location should have been advanced by 5");
    
    STAssertEquals(scannedValue, (int32_t)-150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanBigEndianZigZagVarint64
{
    NSData         *data = [NSData dataWithBytes:(uint8_t[10]){0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0xC0, 0x80, 0x2B} length:9];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    int64_t         scannedValue = 0;
    
    NSMutableData *writtenData = [NSMutableData dataWithCapacity:9];
    [writtenData appendBigEndianZigZagVarint64:-150];
    
    STAssertTrueNoThrow([scanner scanBigEndianZigZagVarint64:&scannedValue], @"The scanning of big endian zig zag varint 64 should succeed and not throw an exception.");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)9, @"The scan location should have been advanced by 9.");
    
    STAssertEquals(scannedValue, (int64_t)-150, @"The scanned value should be equal to the varint encoded integer in the data.");
    
    STAssertEqualObjects(data, writtenData, @"The written data should be equal to the hand encoded data.");
}

- (void)testScanFloatEmptyData
{
    NSData         *data    = [NSData data];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    float           byte    = 0;
    
    STAssertFalseNoThrow([scanner scanFloat:&byte], @"The scanning of one float should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEquals(byte, (float)0, @"The scanned value should have not changed.");
}

- (void)testScanFloatSmallData
{
    NSData         *data    = [NSData dataWithBytes:(uint8_t[3]){ 0xDE, 0xAD, 0xBE } length:3];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    float           byte    = 0;
    
    STAssertFalseNoThrow([scanner scanFloat:&byte], @"The scanning of one float should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEquals(byte, (float)0, @"The scanned value should have not changed.");
}

- (void)testScanFloat
{
    NSData         *data    = [NSData dataWithBytes:(float[]){ 150000.0f } length:sizeof(float)];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    float           byte    = 0;
    
    STAssertTrueNoThrow([scanner scanFloat:&byte], @"The scanning of one float should succeed and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)4, @"The scan location should have been advanced by 4.");
    
    STAssertEquals(byte, (float)150000.0f, @"The scanned value should be equal to the first 4 bytes in the data.");
}

- (void)testScanDoubleEmptyData
{
    NSData         *data    = [NSData data];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    double          byte    = 0;
    
    STAssertFalseNoThrow([scanner scanDouble:&byte], @"The scanning of one double should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEquals(byte, (double)0, @"The scanned value should have not changed.");
}

- (void)testScanDoubleSmallData
{
    NSData         *data    = [NSData dataWithBytes:(uint8_t[7]){ 0xDE, 0xAD, 0xBE, 0xEF, 0x66, 0x99, 0xCC } length:7];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    double          byte    = 0;
    
    STAssertFalseNoThrow([scanner scanDouble:&byte], @"The scanning of one double should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEquals(byte, (double)0, @"The scanned value should have not changed.");
}

- (void)testScanDouble
{
    NSData         *data    = [NSData dataWithBytes:(double[]){ 150000.0 } length:sizeof(double)];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    double          byte    = 0;
    
    STAssertTrueNoThrow([scanner scanDouble:&byte], @"The scanning of one double should succeed and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)8, @"The scan location should have been advanced by 8.");
    
    STAssertEquals(byte, (double)150000.0f, @"The scanned value should be equal to the first 8 bytes in the data.");
}

- (void)testScanSwappedFloatEmptyData
{
    NSData         *data    = [NSData data];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    float           byte    = 0;
    
    STAssertFalseNoThrow([scanner scanSwappedFloat:&byte], @"The scanning of one swapped float should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEquals(byte, (float)0, @"The scanned value should have not changed.");
}

- (void)testScanSwappedFloatSmallData
{
    NSData         *data    = [NSData dataWithBytes:(uint8_t[3]){ 0xDE, 0xAD, 0xBE } length:3];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    float           byte    = 0;
    
    STAssertFalseNoThrow([scanner scanSwappedFloat:&byte], @"The scanning of one swapped float should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEquals(byte, (float)0, @"The scanned value should have not changed.");
}

- (void)testScanSwappedFloat
{
    NSData         *data    = [NSData dataWithBytes:(CFSwappedFloat32[]){ CFConvertFloatHostToSwapped(150000.0f) } length:sizeof(CFSwappedFloat32)];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    float           byte    = 0;
    
    STAssertTrueNoThrow([scanner scanSwappedFloat:&byte], @"The scanning of one swapped float should succeed and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)4, @"The scan location should have been advanced by 4.");
    
    STAssertEquals(byte, (float)150000.0f, @"The scanned value should be equal to the first 4 bytes in the data.");
}

- (void)testScanSwappedDoubleEmptyData
{
    NSData         *data    = [NSData data];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    double          byte    = 0;
    
    STAssertFalseNoThrow([scanner scanSwappedDouble:&byte], @"The scanning of one swapped double should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEquals(byte, (double)0, @"The scanned value should have not changed.");
}

- (void)testScanSwappedDoubleSmallData
{
    NSData         *data    = [NSData dataWithBytes:(uint8_t[7]){ 0xDE, 0xAD, 0xBE, 0xEF, 0x66, 0x99, 0xCC } length:7];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    double          byte    = 0;
    
    STAssertFalseNoThrow([scanner scanSwappedDouble:&byte], @"The scanning of one swapped double should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEquals(byte, (double)0, @"The scanned value should have not changed.");
}

- (void)testScanSwappedDouble
{
    NSData         *data    = [NSData dataWithBytes:(CFSwappedFloat64[]){ CFConvertDoubleHostToSwapped(150000.0) } length:sizeof(CFSwappedFloat64)];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    double          byte    = 0;
    
    STAssertTrueNoThrow([scanner scanSwappedDouble:&byte], @"The scanning of one swapped double should succeed and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)8, @"The scan location should have been advanced by 8.");
    
    STAssertEquals(byte, (double)150000.0f, @"The scanned value should be equal to the first 8 bytes in the data.");
}

- (void)testScanDataOfLengthEmpty
{
    NSData         *data    = [NSData data];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    NSData         *read    = nil;
    
    STAssertFalseNoThrow([scanner scanData:&read ofLength:4], @"The scanning of four bytes in NSData should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEqualObjects(read, nil, @"The scanned value should not have changed.");
}

- (void)testScanDataOfLengthSmallData
{
    NSData         *data    = [NSData dataWithBytes:(uint8_t[2]){ 0x00, 0x33 } length:2];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    NSData         *read    = 0;
    
    STAssertFalseNoThrow([scanner scanData:&read ofLength:4], @"The scanning of four bytes in NSData should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEqualObjects(read, nil, @"The scanned value should not have changed.");
}

- (void)testScanDataOfLength
{
    NSData         *expected = [NSData dataWithBytes:(uint8_t[4]){ 0x00, 0x33, 0x66, 0x99 } length:4];
    NSData         *data     = [NSData dataWithBytes:(uint8_t[6]){ 0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF } length:6];
    PSYDataScanner *scanner  = [PSYDataScanner scannerWithData:data];
    NSData         *read     = 0;
    
    STAssertTrueNoThrow([scanner scanData:&read ofLength:4], @"The scanning of four bytes in NSData should succeed and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)4, @"The scan location should been advanced by the length read.");
    
    STAssertEqualObjects(read, expected, @"The scanned value should be equal to the four first bytes.");
}

- (void)testScanDataIntoDataEmpty
{
    NSData         *search  = [NSData dataWithBytes:(uint8_t[2]){ 0x00, 0x33 } length:2];
    NSData         *data    = [NSData data];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    NSData         *read    = nil;
    
    STAssertFalseNoThrow([scanner scanData:search intoData:&read], @"The scanning of two bytes of NSData should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEqualObjects(read, nil, @"The scanned value should not have changed.");
}

- (void)testScanDataIntoDataThatDoesNotContainIt
{
    NSData         *search  = [NSData dataWithBytes:(uint8_t[2]){ 0x00, 0x33 } length:2];
    NSData         *data    = [NSData dataWithBytes:(uint8_t[2]){ 0x66, 0x33 } length:2];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    NSData         *read    = 0;
    
    STAssertFalseNoThrow([scanner scanData:search intoData:&read], @"The scanning of two bytes of NSData should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEqualObjects(read, nil, @"The scanned value should not have changed.");
}

- (void)testScanDataIntoDataThatDoesContainItButNotAtThePointOfSearch
{
    NSData         *search  = [NSData dataWithBytes:(uint8_t[2]){ 0x00, 0x33 } length:2];
    NSData         *data    = [NSData dataWithBytes:(uint8_t[4]){ 0xFF, 0x00, 0x33, 0xCC } length:4];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    NSData         *read    = 0;
    
    STAssertFalseNoThrow([scanner scanData:search intoData:&read], @"The scanning of two bytes of NSData should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEqualObjects(read, nil, @"The scanned value should not have changed.");
}

- (void)testScanDataIntoDataThatDoesContainItAtThePointOfSearch
{
    NSData         *search   = [NSData dataWithBytes:(uint8_t[2]){ 0x00, 0x33 } length:2];
    NSData         *expected = [NSData dataWithBytes:(uint8_t[4]){ 0x00, 0x33 } length:2];
    NSData         *data     = [NSData dataWithBytes:(uint8_t[6]){ 0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF } length:6];
    PSYDataScanner *scanner  = [PSYDataScanner scannerWithData:data];
    NSData         *read     = 0;
    
    STAssertTrueNoThrow([scanner scanData:search intoData:&read], @"The scanning of two bytes of NSData should succeed and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)2, @"The scan location should been advanced by the length read.");
    
    STAssertEqualObjects(read, expected, @"The scanned value should be equal to the two first bytes.");
}

- (void)testScanUpToDataIntoDataEmpty
{
    NSData         *search  = [NSData dataWithBytes:(uint8_t[2]){ 0x00, 0x33 } length:2];
    NSData         *data    = [NSData data];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    NSData         *read    = nil;
    
    STAssertFalseNoThrow([scanner scanUpToData:search intoData:&read], @"The scanning of bytes up to NSData should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should not have changed.");
    
    STAssertEqualObjects(read, nil, @"The scanned value should not have changed.");
}

- (void)testScanUpToDataIntoDataThatDoesNotContainIt
{
    NSData         *search  = [NSData dataWithBytes:(uint8_t[2]){ 0x00, 0x33 } length:2];
    NSData         *data    = [NSData dataWithBytes:(uint8_t[2]){ 0x66, 0x33 } length:2];
    PSYDataScanner *scanner = [PSYDataScanner scannerWithData:data];
    NSData         *read    = nil;
    
    STAssertTrueNoThrow([scanner scanUpToData:search intoData:&read], @"The scanning of bytes up to NSData should succeed and not throw an exception");
    
    STAssertTrue([scanner isAtEnd], @"The scan location should have been moved to the end of the scanner.");
    
    STAssertEqualObjects(read, data, @"The scanned value should not have changed.");
}

- (void)testScanDataOfLengthThatDoesContainItAtThePointOfSearch
{
    NSData         *search   = [NSData dataWithBytes:(uint8_t[2]){ 0x00, 0x33 } length:2];
    NSData         *data     = [NSData dataWithBytes:(uint8_t[6]){ 0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF } length:6];
    PSYDataScanner *scanner  = [PSYDataScanner scannerWithData:data];
    NSData         *read     = 0;
    
    STAssertFalseNoThrow([scanner scanUpToData:search intoData:&read], @"The scanning of bytes up to NSData should fail and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)0, @"The scan location should have not been advanced.");
    
    STAssertEqualObjects(read, nil, @"The scanned value should not have changed.");
}

- (void)testScanDataOfLengthThatDoesContainItButNotAtThePointOfSearch
{
    NSData         *search   = [NSData dataWithBytes:(uint8_t[2]){ 0x00, 0x33 } length:2];
    NSData         *expected = [NSData dataWithBytes:(uint8_t[1]){ 0xFF } length:1];
    NSData         *data     = [NSData dataWithBytes:(uint8_t[4]){ 0xFF, 0x00, 0x33, 0xCC } length:4];
    PSYDataScanner *scanner  = [PSYDataScanner scannerWithData:data];
    NSData         *read     = 0;
    
    STAssertTrueNoThrow([scanner scanUpToData:search intoData:&read], @"The scanning of bytes up to NSData should succeed and not throw an exception");
    
    STAssertEquals([scanner scanLocation], (unsigned long long)1, @"The scan location should been advanced at the beginning of the searched data.");
    
    STAssertEqualObjects(read, expected, @"The scanned data should be equal to the data before the searched data.");
}

@end
