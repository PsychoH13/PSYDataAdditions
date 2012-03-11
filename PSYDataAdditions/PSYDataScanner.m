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
#import "PSYDataDataScanner.h"
#import "PSYFileHandleScanner.h"

static void PSYRequestConcreteImplementation(Class cls, SEL sel, BOOL isSubclass)
{
    if(isSubclass) [NSException raise:NSInvalidArgumentException format:@"*** -%@ only defined for abstract class.  Define -[%@ %@]!", NSStringFromSelector(sel), cls, NSStringFromSelector(sel)];
    else           [NSException raise:NSInvalidArgumentException format:@"*** -%@ cannot be sent to an abstract object of class %@: Create a concrete instance!", NSStringFromSelector(sel), cls];
}

@interface PSYPlaceholderDataScanner : PSYDataScanner
@end

@implementation PSYDataScanner

+ (id)allocWithZone:(NSZone *)zone
{
    if(self == [PSYDataScanner class])
        return [[PSYPlaceholderDataScanner alloc] init];
    
    return [super allocWithZone:zone];
}

+ (id)scannerWithData:(NSData *)dataToScan
{
#if __has_feature(objc_arc)
    return [[self alloc] initWithData:dataToScan];
#else
    return [[[self alloc] initWithData:dataToScan] autorelease];
#endif
}

- (id)initWithData:(NSData *)dataToScan
{
#if !__has_feature(objc_arc)
    [self release];
#endif
    return nil;
}

+ (id)scannerWithFileHandle:(NSFileHandle *)fileToScan;
{
#if __has_feature(objc_arc)
    return [[self alloc] initWithFileHandle:fileToScan];
#else
    return [[[self alloc] initWithFileHandle:fileToScan] autorelease];
#endif
}

- (id)initWithFileHandle:(NSFileHandle *)fileToScan;
{
#if !__has_feature(objc_arc)
    [self release];
#endif
    return nil;
}

- (NSData *)data
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYDataScanner class]);
    return nil;
}

- (unsigned long long)dataLength
{
    return [[self data] length];
}

- (unsigned long long)scanLocation
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYDataScanner class]);
    return 0;
}

- (void)setScanLocation:(unsigned long long)value
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYDataScanner class]);
}

- (BOOL)setScanLocation:(NSInteger)relativeLocation relativeTo:(PSYDataScannerLocation)startPoint;
{
    NSInteger computed = NSNotFound;
    
    switch(startPoint)
    {
        case PSYDataScannerLocationCurrent : computed = relativeLocation  + [self scanLocation]; break;
        case PSYDataScannerLocationEnd     : computed = [self dataLength] + relativeLocation;    break;
        case PSYDataScannerLocationBegin   : 
        default                            : computed = relativeLocation;                        break;
    }
    
    if(computed >= 0 && computed <= [self dataLength])
    {
        [self setScanLocation:computed];
        return YES;
    }
    
    return NO;
}

- (BOOL)isAtEnd;
{
    return [self scanLocation] >= [self dataLength];
}

- (BOOL)scanInt8:(uint8_t *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL) [[self data] getBytes:value range:NSMakeRange(loc, length)];
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanLittleEndianInt16:(uint16_t *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL)
    {
        [[self data] getBytes:value range:NSMakeRange(loc, length)];
        *value = CFSwapInt16LittleToHost(*value);
    }
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanLittleEndianInt32:(uint32_t *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL)
    {
        [[self data] getBytes:value range:NSMakeRange(loc, length)];
        *value = CFSwapInt32LittleToHost(*value);
    }
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanLittleEndianInt64:(uint64_t *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL)
    {
        [[self data] getBytes:value range:NSMakeRange(loc, length)];
        *value = CFSwapInt64LittleToHost(*value);
    }
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanBigEndianInt16:(uint16_t *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL)
    {
        [[self data] getBytes:value range:NSMakeRange(loc, length)];
        *value = CFSwapInt16BigToHost(*value);
    }
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanBigEndianInt32:(uint32_t *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL)
    {
        [[self data] getBytes:value range:NSMakeRange(loc, length)];
        *value = CFSwapInt32BigToHost(*value);
    }
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanBigEndianInt64:(uint64_t *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL)
    {
        [[self data] getBytes:value range:NSMakeRange(loc, length)];
        *value = CFSwapInt64BigToHost(*value);
    }
    
    [self setScanLocation:loc + length];
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
    unsigned long long loc = [self scanLocation];
    
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
    unsigned long long loc = [self scanLocation];
    
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
    unsigned long long loc = [self scanLocation];
    
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
    unsigned long long loc = [self scanLocation];
    
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
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL) [[self data] getBytes:value range:NSMakeRange(loc, length)];
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanDouble:(double *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL) [[self data] getBytes:value range:NSMakeRange(loc, length)];
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanSwappedFloat:(float *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL)
    {
        CFSwappedFloat32 scan;
        [[self data] getBytes:&scan range:NSMakeRange(loc, length)];
        *value = CFConvertFloatSwappedToHost(scan);
    }
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanSwappedDouble:(double *)value
{
    unsigned long long length = sizeof(*value);
    unsigned long long loc    = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(value != NULL)
    {
        CFSwappedFloat64 scan;
        [[self data] getBytes:&scan range:NSMakeRange(loc, length)];
        *value = CFConvertDoubleSwappedToHost(scan);
    }
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanData:(NSData **)data ofLength:(unsigned long long)length
{
    unsigned long long loc = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(data != NULL) *data = [[self data] subdataWithRange:NSMakeRange(loc, length)];
    
    [self setScanLocation:loc + length];
    
    return YES;
}

- (BOOL)scanData:(NSData *)data intoData:(NSData **)dataValue
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYDataScanner class]);
    return NO;
}

- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData **)dataValue
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYDataScanner class]);
    return YES;
}

- (BOOL)scanString:(NSString **)value ofLength:(unsigned long long)length usingEncoding:(NSStringEncoding)encoding
{
    unsigned long long loc = [self scanLocation];
    if(loc + length > [self dataLength]) return NO;
    
    if(length > 0 && value != NULL)
    {
        NSData *subdata = [[self data] subdataWithRange:NSMakeRange(loc, length)];
#if __has_feature(objc_arc)
        *value = [[NSString alloc] initWithData:subdata encoding:encoding];
#else
        *value = [[[NSString alloc] initWithData:subdata encoding:encoding] autorelease];
#endif
    }
    
    [self setScanLocation:loc + length];
    return YES;
}

- (BOOL)scanUpToString:(NSString *)stopString intoString:(NSString **)value usingEncoding:(NSStringEncoding)encoding;
{
    NSData *stopData = [stopString dataUsingEncoding:encoding];
    NSData *readData = nil;
    
    BOOL success = [self scanUpToData:stopData intoData:value != NULL ? &readData : NULL];
    if(success)
    {
#if __has_feature(objc_arc)
        if(value != NULL) *value = [[NSString alloc] initWithData:readData encoding:encoding];
#else
        if(value != NULL) *value = [[[NSString alloc] initWithData:readData encoding:encoding] autorelease];
#endif
    }
    
    return success;
}

- (BOOL)scanNullTerminatedString:(NSString **)value withEncoding:(NSStringEncoding)encoding;
{
    PSYRequestConcreteImplementation([self class], _cmd, [self class] != [PSYDataScanner class]);
    return NO;
}

@end

@implementation PSYPlaceholderDataScanner

+ (id)allocWithZone:(NSZone *)zone
{
    static PSYPlaceholderDataScanner *sharedPlaceholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlaceholder = [[super allocWithZone:zone] init];
    });
    
    return sharedPlaceholder;
}

- (id)init
{
    return self;
}

- (id)initWithData:(NSData *)dataToScan
{
    return (id)[[PSYDataDataScanner alloc] initWithData:dataToScan];
}

- (id)initWithFileHandle:(NSFileHandle *)fileToScan
{
    return (id)[[PSYFileHandleScanner alloc] initWithFileHandle:fileToScan];
}

@end

NSData *PSYNullTerminatorDataForEncoding(NSStringEncoding encoding)
{
    NSString *nullTerminatorString = [NSString stringWithCharacters:(unichar[]){ 0 } length:1];
    
    NSUInteger length = [nullTerminatorString lengthOfBytesUsingEncoding:encoding];
    
    static char nullBytes[20] = { 0 };
    
    return [NSData dataWithBytesNoCopy:nullBytes length:length freeWhenDone:NO];
}
