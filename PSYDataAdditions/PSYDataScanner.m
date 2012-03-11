/*
 PSYDataScanner.m
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

#import "PSYDataScanner.h"


@implementation PSYDataScanner
@synthesize data = _scannedData, scanLocation = _scanLocation;

+ (id)scannerWithData:(NSData *)dataToScan
{
#if __has_feature(objc_arc)
    return [[self alloc] initWithData:dataToScan];
#else
    return [[[self alloc] initWithData:dataToScan] autorelease];
#endif
}

- (id)init
{
    return [self initWithData:nil];
}

- (id)initWithData:(NSData *)dataToScan
{
    if(dataToScan == nil)
    {
#if !__has_feature(objc_arc)
        [self release];
#endif
        return nil;
    }
    
    if((self = [super init]))
    {
        _scannedData = [dataToScan copy];
        _dataLength  = [_scannedData length];
    }
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_scannedData release];
    [super dealloc];
}
#endif

- (void)setScanLocation:(NSUInteger)value
{
    if(value > [_scannedData length])
        [NSException raise:NSRangeException format:@"*** -[PSYDataScanner setScanLocation:]: Range or index out of bounds"];
    
    _scanLocation = value;
}

- (BOOL)setScanLocation:(NSInteger)relativeLocation relativeTo:(PSYDataScannerLocation)startPoint;
{
    NSInteger computed = NSNotFound;
    
    switch(startPoint)
    {
        case PSYDataScannerLocationCurrent : computed = relativeLocation + [self scanLocation]; break;
        case PSYDataScannerLocationEnd     : computed = _dataLength      + relativeLocation;    break;
        case PSYDataScannerLocationBegin   : 
        default                            : computed = relativeLocation;                       break;
    }
    
    if(computed >= 0 && computed <= _dataLength)
    {
        [self setScanLocation:computed];
        return YES;
    }
    
    return NO;
}

- (BOOL)isAtEnd;
{
    return _scanLocation >= _dataLength;
}

- (BOOL)scanInt8:(uint8_t *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL) [_scannedData getBytes:value range:NSMakeRange(_scanLocation, length)];
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanLittleEndianInt16:(uint16_t *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL)
    {
        [_scannedData getBytes:value range:NSMakeRange(_scanLocation, length)];
        *value = CFSwapInt16LittleToHost(*value);
    }
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanLittleEndianInt32:(uint32_t *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL)
    {
        [_scannedData getBytes:value range:NSMakeRange(_scanLocation, length)];
        *value = CFSwapInt32LittleToHost(*value);
    }
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanLittleEndianInt64:(uint64_t *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL)
    {
        [_scannedData getBytes:value range:NSMakeRange(_scanLocation, length)];
        *value = CFSwapInt64LittleToHost(*value);
    }
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanBigEndianInt16:(uint16_t *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL)
    {
        [_scannedData getBytes:value range:NSMakeRange(_scanLocation, length)];
        *value = CFSwapInt16BigToHost(*value);
    }
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanBigEndianInt32:(uint32_t *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL)
    {
        [_scannedData getBytes:value range:NSMakeRange(_scanLocation, length)];
        *value = CFSwapInt32BigToHost(*value);
    }
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanBigEndianInt64:(uint64_t *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL)
    {
        [_scannedData getBytes:value range:NSMakeRange(_scanLocation, length)];
        *value = CFSwapInt64BigToHost(*value);
    }
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanSInt8:(int8_t *)value;
{
    return [self scanInt8:(uint8_t *)value];
}

- (BOOL)scanLittleEndianSInt16:(int16_t *)value;
{
    return [self scanLittleEndianInt16:(uint16_t *)value];
}

- (BOOL)scanLittleEndianSInt32:(int32_t *)value;
{
    return [self scanLittleEndianInt32:(uint32_t *)value];
}

- (BOOL)scanLittleEndianSInt64:(int64_t *)value;
{
    return [self scanLittleEndianInt64:(uint64_t *)value];
}

- (BOOL)scanBigEndianSInt16:(int16_t *)value;
{
    return [self scanBigEndianInt16:(uint16_t *)value];
}

- (BOOL)scanBigEndianSInt32:(int32_t *)value;
{
    return [self scanBigEndianInt32:(uint32_t *)value];
}

- (BOOL)scanBigEndianSInt64:(int64_t *)value;
{
    return [self scanBigEndianInt64:(uint64_t *)value];
}

- (BOOL)scanLittleEndianVarint32:(uint32_t *)value
{
    NSUInteger loc = [self scanLocation];
    
    uint32_t result = 0;
    
    for(uint8_t shift = 0; shift < 32; shift += 7)
    {
        uint8_t currentByte;
        BOOL success = [self scanInt8:&currentByte];
        if(!success) break;
        
        result |= (((uint32_t)(currentByte & 0x7f)) << shift);
        if((currentByte & 0x80) == 0)
        {
            if(value != NULL) *value = CFSwapInt32LittleToHost(result);
            return YES;
        }
    }
    
    // If we're here that means scanning failed
    // reset the scan location to what it was before scanning
    [self setScanLocation:loc];
    
    return NO;
}

- (BOOL)scanLittleEndianVarint64:(uint64_t *)value
{
    NSUInteger loc = [self scanLocation];
    
    uint64_t result = 0;

    for(uint8_t shift = 0; shift < 64; shift += 7)
    {
        uint8_t currentByte;
        BOOL success = [self scanInt8:&currentByte];
        if(!success) break;
        
        result |= (((uint64_t)(currentByte & 0x7f)) << shift);
        if((currentByte & 0x80) == 0)
        {
            if(value != NULL) *value = CFSwapInt64LittleToHost(result);
            return YES;
        }
    }
    
    // If we're here that means scanning failed
    // reset the scan location to what it was before scanning
    [self setScanLocation:loc];
    
    return NO;
}

- (BOOL)scanBigEndianVarint32:(uint32_t *)value
{
    NSUInteger loc = [self scanLocation];
    
    uint32_t result = 0;
    
    for(uint8_t shift = 0; shift < 32; shift += 7)
    {
        uint8_t currentByte;
        BOOL success = [self scanInt8:&currentByte];
        if(!success) break;
        
        result |= (((uint32_t)(currentByte & 0x7f)) << shift);
        if((currentByte & 0x80) == 0)
        {
            if(value != NULL) *value = CFSwapInt32BigToHost(result);
            return YES;
        }
    }
    
    // If we're here that means scanning failed
    // reset the scan location to what it was before scanning
    [self setScanLocation:loc];
    
    return NO;
}

- (BOOL)scanBigEndianVarint64:(uint64_t *)value
{
    NSUInteger loc = [self scanLocation];
    
    uint64_t result = 0;
    
    for(uint8_t shift = 0; shift < 64; shift += 7)
    {
        uint8_t currentByte;
        BOOL success = [self scanInt8:&currentByte];
        if(!success) break;
        
        result |= (((uint64_t)(currentByte & 0x7f)) << shift);
        if((currentByte & 0x80) == 0)
        {
            if(value != NULL) *value = CFSwapInt64BigToHost(result);
            return YES;
        }
    }
    
    // If we're here that means scanning failed
    // reset the scan location to what it was before scanning
    [self setScanLocation:loc];
    
    return NO;
}

- (BOOL)scanLittleEndianSVarint32:(int32_t *)value
{
    return [self scanLittleEndianVarint32:(uint32_t *)value];
}

- (BOOL)scanLittleEndianSVarint64:(int64_t *)value
{
    return [self scanLittleEndianVarint64:(uint64_t *)value];
}

- (BOOL)scanBigEndianSVarint32:(int32_t *)value
{
    return [self scanBigEndianVarint32:(uint32_t *)value];
}

- (BOOL)scanBigEndianSVarint64:(int64_t *)value
{
    return [self scanBigEndianVarint64:(uint64_t *)value];
}

- (BOOL)scanLittleEndianZigZagVarint32:(int32_t *)value
{
    uint32_t zzEnc;
    BOOL success = [self scanLittleEndianVarint32:&zzEnc];
    if(!success) return NO;
    
    if(value != NULL)
    {
        if(zzEnc & 0x1)
        {
            uint32_t r = (zzEnc >> 1) ^ 0xFFFFFFFF;
            *value = *(int32_t *)&r;
        }
        else *value = (int32_t)zzEnc >> 1;
    }
    
    return YES;
}

- (BOOL)scanLittleEndianZigZagVarint64:(int64_t *)value
{
    uint64_t zzEnc;
    BOOL success = [self scanLittleEndianVarint64:&zzEnc];
    if(!success) return NO;
    
    if(value != NULL)
    {
        if(zzEnc & 0x1)
        {
            uint64_t r = (zzEnc >> 1) ^ 0xFFFFFFFFFFFFFFFF;
            *value = *(int64_t *)&r;
        }
        else *value = (int64_t)zzEnc >> 1;
    }
    
    return YES;
}

- (BOOL)scanBigEndianZigZagVarint32:(int32_t *)value
{
    uint32_t zzEnc;
    BOOL success = [self scanBigEndianVarint32:&zzEnc];
    if(!success) return NO;
    
    if(value != NULL)
    {
        if (zzEnc & 0x1)
        {
            uint32_t r = (zzEnc >> 1) ^ 0xFFFFFFFF;
            *value = *(int32_t *)&r;
        }
        else *value = (int32_t)zzEnc >> 1;
    }
    
    return YES;
}

- (BOOL)scanBigEndianZigZagVarint64:(int64_t *)value
{
    uint64_t zzEnc;
    BOOL success = [self scanBigEndianVarint64:&zzEnc];
    if(!success) return NO;
    
    if(value != NULL)
    {
        if(zzEnc & 0x1)
        {
            uint64_t r = (zzEnc >> 1) ^ 0xFFFFFFFFFFFFFFFF;
            *value = *(int64_t *)&r;
        }
        else *value = (int64_t)zzEnc >> 1;
    }
    
    return YES;
}

- (BOOL)scanFloat:(float *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL) [_scannedData getBytes:value range:NSMakeRange(_scanLocation, length)];
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanDouble:(double *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL) [_scannedData getBytes:value range:NSMakeRange(_scanLocation, length)];
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanSwappedFloat:(float *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL)
    {
        CFSwappedFloat32 scan;
        [_scannedData getBytes:&scan range:NSMakeRange(_scanLocation, length)];
        *value = CFConvertFloatSwappedToHost(scan);
    }
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanSwappedDouble:(double *)value
{
    NSUInteger length = sizeof(*value);
    if(_scanLocation + length > _dataLength) return NO;
    
    if(value != NULL)
    {
        CFSwappedFloat64 scan;
        [_scannedData getBytes:&scan range:NSMakeRange(_scanLocation, length)];
        *value = CFConvertDoubleSwappedToHost(scan);
    }
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanData:(NSData **)data ofLength:(NSUInteger)length
{
    if(_scanLocation + length > _dataLength) return NO;
    
    if(data != NULL) *data = [_scannedData subdataWithRange:NSMakeRange(_scanLocation, length)];
    
    _scanLocation += length;
    
    return YES;
}

- (BOOL)scanData:(NSData *)data intoData:(NSData **)dataValue
{
    NSUInteger length = [data length];
    if(_scanLocation + length > _dataLength) return NO;
    
    if(length > 0)
    {
        NSData *subdata = [_scannedData subdataWithRange:NSMakeRange(_scanLocation, length)];
        
        if([subdata isEqualToData:data])
        {
            if(dataValue != NULL) *dataValue = subdata;
            
            _scanLocation += length;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData **)dataValue
{
    NSUInteger length = [stopData length];
    
    NSRange scannedRange = NSMakeRange(_scanLocation, 0);
    
    if(length == 0 || _scanLocation + length > _dataLength)
        scannedRange.length = _dataLength - _scanLocation;
    else
    {
        const unsigned char *scannedBuffer = [_scannedData bytes];
        const unsigned char *stopBuffer    = [stopData bytes];
        
        BOOL hasFoundData = NO;
        
        for(NSUInteger scannedLoc = _scanLocation; scannedLoc + length <= _dataLength; scannedLoc++)
        {
            hasFoundData = YES;
            for(NSUInteger stopLoc = 0; stopLoc < length; stopLoc++)
                if(scannedBuffer[scannedLoc + stopLoc] != stopBuffer[stopLoc])
                {
                    hasFoundData = NO;
                    break;
                }
            
            if(hasFoundData)
            {
                scannedRange.length = scannedLoc - _scanLocation;
                break;
            }
        }
        
        if(!hasFoundData) scannedRange.length = _dataLength - _scanLocation;
    }
    
    if(scannedRange.length == 0 ||
       (scannedRange.location == _scanLocation && scannedRange.length == 0))
        return NO;
    
    if(dataValue != NULL) *dataValue = [_scannedData subdataWithRange:scannedRange];
    
    _scanLocation = NSMaxRange(scannedRange);
    
    return YES;
}

- (BOOL)scanString:(NSString **)value ofLength:(NSUInteger)length usingEncoding:(NSStringEncoding)encoding
{
    if(_scanLocation + length > _dataLength) return NO;
    
    if(length > 0 && value != NULL)
    {
        NSData *subdata = [_scannedData subdataWithRange:NSMakeRange(_scanLocation, length)];
#if __has_feature(objc_arc)
        *value = [[NSString alloc] initWithData:subdata encoding:encoding];
#else
        *value = [[[NSString alloc] initWithData:subdata encoding:encoding] autorelease];
#endif
    }
    
    _scanLocation += length;
    return YES;
}

- (BOOL)scanNullTerminatedString:(NSString **)value withEncoding:(NSStringEncoding)encoding;
{
    NSData *terminator = PSYNullTerminatorDataForEncoding(encoding);
    
    NSRange termRange = [_scannedData rangeOfData:terminator options:0 range:NSMakeRange(_scanLocation, [_scannedData length] - _scanLocation)];
    
    if(termRange.location != NSNotFound)
    {
        if(value != NULL)
        {
            NSData *subData = [_scannedData subdataWithRange:NSMakeRange(_scanLocation, termRange.location - _scanLocation)];
#if __has_feature(objc_arc)
            *value = [[NSString alloc] initWithData:subData encoding:encoding];
#else
            *value = [[[NSString alloc] initWithData:subData encoding:encoding] autorelease];
#endif
        }
        
        _scanLocation = NSMaxRange(termRange);
        return YES;
    }
    
    return NO;
}

@end

NSData *PSYNullTerminatorDataForEncoding(NSStringEncoding encoding)
{
    NSString *nullTerminatorString = [NSString stringWithCharacters:(unichar[]){ 0 } length:1];
    
    NSUInteger length = [nullTerminatorString lengthOfBytesUsingEncoding:encoding];
    
    static char nullBytes[20] = { 0 };
    
    return [NSData dataWithBytesNoCopy:nullBytes length:length freeWhenDone:NO];
}
