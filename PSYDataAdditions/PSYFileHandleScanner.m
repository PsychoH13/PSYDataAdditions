/*
 PSYDataDataScanner.h
 Created by Remy "Psy" Demarest on 11/03/2012.
 
 Copyright (c) 2012 Remy "Psy" Demarest
 
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

#import "PSYFileHandleScanner.h"

#if __has_feature(objc_arc)
#define RETAIN(obj) obj
#define RELEASE(obj) do { obj = nil; } while(NO)
#define AUTORELEASE(obj) obj
#else
#define RETAIN(obj) [obj retain]
#define RELEASE(obj) do { id __obj = obj; obj = nil; [__obj release]; } while(NO)
#define AUTORELEASE(obj) [obj autorelease]
#endif

#if __LP64__
#define CHUNK_SIZE (1024 * 512)
#else
#define CHUNK_SIZE 4096
#endif

typedef struct _PSYRange { unsigned long long location, length; } PSYRange;

static PSYRange PSYRangeMake(unsigned long long loc, unsigned long long len)
{
    return (PSYRange){ loc, len };
}

static unsigned long long PSYRangeMax(PSYRange range)
{
    return range.location + range.length;
}

static BOOL PSYLocationInRange(PSYRange range, unsigned long long loc)
{
    return range.location <= loc && loc < PSYRangeMax(range);
}

@interface PSYFileHandleScanner ()
{
    NSFileHandle       *_fileHandle;
    unsigned long long  _fileLength;
    
    NSMutableData      *_cacheData;
    PSYRange            _cacheRange;
    unsigned long long  _cacheScanLocation;
    
    unsigned int        _useCacheOffset:1;
}

- (BOOL)PSY_cacheIsAtEnd;
- (void)PSY_resetCachedData;

// Reads CHUNK_SIZE and update the cache if length is out of the bounds of the cache
- (void)PSY_readAndCacheDataOfLength:(unsigned long long)length;

@end

@implementation PSYFileHandleScanner

- (id)initWithFileHandle:(NSFileHandle *)fileToScan
{
    if((self = [super init]))
    {
        _fileHandle = RETAIN(fileToScan);
        _cacheData  = [[NSMutableData alloc] init];
        
        unsigned long long loc = [_fileHandle offsetInFile];
        _fileLength = [_fileHandle seekToEndOfFile];
        
        [_fileHandle seekToFileOffset:loc];
    }
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_fileHandle release];
    [_cacheData release];
    [super dealloc];
}
#endif

- (BOOL)PSY_cacheIsAtEnd;
{
    return PSYRangeMax(_cacheRange) >= _fileLength;
}

- (void)PSY_resetCachedData;
{
    [_cacheData setLength:0];
    
    _cacheRange.location = [_fileHandle offsetInFile];
    _cacheRange.length   = 0;
    _cacheScanLocation   = 0;
}

- (void)PSY_readAndCacheDataOfLength:(unsigned long long)length;
{
    length = MIN(length, CHUNK_SIZE);
    
    if(_cacheScanLocation + length <= _cacheRange.length) return;
    
    // We cached the data at the end of the file we can't go further
    if(PSYRangeMax(_cacheRange) >= _fileLength) return;
    
    [_fileHandle seekToFileOffset:PSYRangeMax(_cacheRange)];
    
    [_cacheData replaceBytesInRange:NSMakeRange(0, _cacheScanLocation) withBytes:NULL length:0];
    [_cacheData appendData:[_fileHandle readDataOfLength:CHUNK_SIZE]];
    
    _cacheRange.location += _cacheScanLocation;
    _cacheRange.length    = [_cacheData length];
    _cacheScanLocation    = 0;
}

- (unsigned long long)scanLocation
{
    return _cacheScanLocation + (_useCacheOffset ? 0 : _cacheRange.location);
}

- (void)setScanLocation:(unsigned long long)value
{
    if(_useCacheOffset) _cacheScanLocation = value;
    else if(PSYLocationInRange(_cacheRange, value))
    {
        _cacheScanLocation = value - _cacheRange.location;
    }
    else
    {
        // If the scan location is outside of the cached range, trash the whole cached data
        [_fileHandle seekToFileOffset:value];
        [self PSY_resetCachedData];
    }
}

- (NSData *)data
{
    return _useCacheOffset ? _cacheData : nil;
}

- (BOOL)scanData:(NSData **)data ofLength:(unsigned long long)length
{
    unsigned long long loc = _cacheRange.location + _cacheScanLocation;
    if(loc + length > _fileLength) return NO;
    
    if(data != NULL)
    {
        [_fileHandle seekToFileOffset:loc];
        *data = [_fileHandle readDataOfLength:length];
    }
    
    [self setScanLocation:loc + length];
    
    return YES;
}

- (BOOL)scanData:(NSData *)data intoData:(NSData **)value
{
    PSYRange           cacheRange   = _cacheRange;
    unsigned long long cacheScanLoc = _cacheScanLocation;
    unsigned long long length       = [data length];
    unsigned long long loc          = cacheRange.location + cacheScanLoc;
    if(length == 0 || loc + length > _fileLength) return NO;
    
    const unsigned char *dataBuffer   = [data bytes];
    unsigned long long   dataLoc      = 0;
    unsigned long long   locLimit     = loc + length;
    
    NSData              *cacheData    = [_cacheData copy];
    const unsigned char *cacheBuffer  = [cacheData bytes];
    
    BOOL hasFoundData = YES;
    
    for(unsigned long long scannedLoc = loc; scannedLoc < locLimit; scannedLoc++)
    {
        if(scannedLoc >= PSYRangeMax(cacheRange))
        {
            @autoreleasepool
            {
                RELEASE(cacheData);
                cacheData   = RETAIN([_fileHandle readDataOfLength:CHUNK_SIZE]);
                cacheBuffer = [cacheData bytes];
            }
            
            cacheRange.length   = [cacheData length];
            cacheRange.location = [_fileHandle offsetInFile] - cacheRange.length;
            cacheScanLoc        = 0;
        }
        
        if(cacheBuffer[scannedLoc - cacheRange.location] == dataBuffer[dataLoc])
            dataLoc++;
        else
        {
            hasFoundData = NO;
            break;
        }
    }
    
    if(hasFoundData)
    {
        if(value != NULL) *value = AUTORELEASE([data copy]);
    
        [_cacheData setData:cacheData];
        _cacheRange        = cacheRange;
        _cacheScanLocation = locLimit - _cacheRange.location;
    }
    
    RELEASE(cacheData);
    
    return hasFoundData;
}

- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData **)value
{
    unsigned long long length = [stopData length];
    unsigned long long loc    = [_fileHandle offsetInFile];
    
    if(length == 0 || loc + length > _fileLength)
    {
        if(value != NULL)
        {
            [_fileHandle seekToFileOffset:_cacheRange.location + _cacheScanLocation];
            *value = [_fileHandle readDataToEndOfFile];
        }
        
        [self setScanLocation:_fileLength];
        return YES;
    }
    
    NSData              *cacheData    = [_cacheData copy];
    const unsigned char *cacheBuffer  = [cacheData bytes];
    PSYRange             cacheRange   = _cacheRange;
    unsigned long long   cacheScanLoc = _cacheScanLocation;
    
    const unsigned char *stopBuffer   = [stopData bytes];
    NSMutableData       *retBuffer    = value != NULL ? [[NSMutableData alloc] init] : nil;
    unsigned long long   stopFoundLoc = loc;
    unsigned long long   stopLoc      = 0;
    
    BOOL hasFoundData = NO;
    
    for(unsigned long long scannedLoc = loc; scannedLoc + (length - stopLoc) <= _fileLength; scannedLoc++)
    {
        if(scannedLoc >= PSYRangeMax(cacheRange))
        {
            if(retBuffer != nil)
                [retBuffer appendData:(cacheScanLoc == 0
                                       ? cacheData
                                       : [cacheData subdataWithRange:NSMakeRange(cacheScanLoc, cacheRange.length - cacheScanLoc)])];
            @autoreleasepool
            {
                RELEASE(cacheData);
                cacheData   = RETAIN([_fileHandle readDataOfLength:CHUNK_SIZE]);
                cacheBuffer = [cacheData bytes];
            }
            
            cacheRange.length   = [cacheData length];
            cacheRange.location = [_fileHandle offsetInFile] - cacheRange.length;
            cacheScanLoc        = 0;
        }
        
        // If the current stopBuffer byte is equal to the current scanned byte,
        // increment the stop location to scan check the next bytes in both buffer
        // otherwise, reset the stop location so the next scanned byte is compared with the first stop byte
        if(cacheBuffer[scannedLoc - cacheRange.location] == stopBuffer[stopLoc])
            stopLoc++;
        else
        {
            stopFoundLoc = scannedLoc + 1;
            stopLoc      = 0;
        }
        
        // If the stop location is equal to the length of the stopData
        // it means we fully matched the data, break out of the loop
        if(stopLoc >= length)
        {
            hasFoundData = YES;
            break;
        }
    }
    
    if(hasFoundData)
    {
        // The beginning of the stop data is in the data we already bufferized
        if(stopFoundLoc < cacheRange.location)
        {
            if(value != NULL)
            {
                // We need to truncate the bufferized data before sending it back to the caller
                unsigned long long trashedLength = cacheRange.location - stopFoundLoc;
                [retBuffer replaceBytesInRange:NSMakeRange([retBuffer length] - trashedLength, trashedLength) withBytes:NULL length:0];
                *value = AUTORELEASE(retBuffer);
            }
        }
        // The beginning of the stop data is in the current buffer, append whatever is missing to the returned value
        else
        {
            if(value != NULL)
            {
                [retBuffer appendBytes:cacheBuffer length:stopFoundLoc - cacheRange.location];
                *value = AUTORELEASE(retBuffer);
            }
            
            [_cacheData setData:cacheData];
            _cacheRange        = cacheRange;
            _cacheScanLocation = stopFoundLoc - cacheRange.location;
        }
        
        [self setScanLocation:stopFoundLoc];
    }
    else if(value != NULL)
    {
        // The data was not found, put the whole scanned buffer in the value
        [retBuffer appendData:(cacheScanLoc == 0 ? cacheData
                               : [cacheData subdataWithRange:NSMakeRange(cacheScanLoc, cacheRange.length - cacheScanLoc)])];
        *value = AUTORELEASE(retBuffer);
        
        [self setScanLocation:_fileLength];
    }
    
    RELEASE(cacheData);
    
    return YES;
}

- (BOOL)scanString:(NSString **)value ofLength:(unsigned long long)length usingEncoding:(NSStringEncoding)encoding
{
    unsigned long long loc = _cacheRange.location + _cacheScanLocation;
    if(loc + length > _fileLength) return NO;
    
    if(length > 0 && value != NULL)
    {
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:length];
        
        NSData             *cacheData    = [_cacheData copy];
        PSYRange            cacheRange   = _cacheRange;
        unsigned long long  cacheScanLoc = _cacheScanLocation;
        
        for(unsigned long long read = 0; read < length;)
        {
            if(cacheScanLoc >= cacheRange.length)
            {
                @autoreleasepool
                {
                    RELEASE(cacheData);
                    cacheData = RETAIN([_fileHandle readDataOfLength:CHUNK_SIZE]);
                }
                
                cacheRange.length   = [cacheData length];
                cacheRange.location = [_fileHandle offsetInFile] - cacheRange.length;
                cacheScanLoc        = 0;
            }
            
            unsigned long long availLen = MIN(length - read, cacheRange.length - cacheScanLoc);
            
            const unsigned char *buf = [cacheData bytes];
            [data appendBytes:buf + cacheScanLoc length:availLen];
            
            read         += availLen;
            cacheScanLoc += availLen;
        }
        
        *value = AUTORELEASE([[NSString alloc] initWithData:data encoding:encoding]);
        
        [_cacheData setData:cacheData];
        _cacheRange        = cacheRange;
        _cacheScanLocation = cacheScanLoc;
        
        RELEASE(cacheData);
        RELEASE(data);
    }
    
    [self setScanLocation:loc + length];
    
    return YES;
}

- (BOOL)scanNullTerminatedString:(NSString **)value withEncoding:(NSStringEncoding)encoding
{
    NSData *stopData = PSYNullTerminatorDataForEncoding(encoding);
    
    unsigned long long length = [stopData length];
    unsigned long long loc    = [_fileHandle offsetInFile];
    
    if(length == 0 || loc + length > _fileLength) return NO;
    else
    {
        NSData              *cacheData    = [_cacheData copy];
        const unsigned char *cacheBuffer  = [cacheData bytes];
        PSYRange             cacheRange   = _cacheRange;
        unsigned long long   cacheScanLoc = _cacheScanLocation;
        
        const unsigned char *stopBuffer   = [stopData bytes];
        NSMutableData       *retBuffer    = value != NULL ? [[NSMutableData alloc] init] : nil;
        unsigned long long   stopFoundLoc = loc;
        unsigned long long   stopLoc      = 0;
        
        BOOL hasFoundData = NO;
        
        for(unsigned long long scannedLoc = loc; scannedLoc + length <= _fileLength; scannedLoc++)
        {
            if(scannedLoc >= PSYRangeMax(cacheRange))
            {
                if(retBuffer != nil)
                    [retBuffer appendData:(cacheScanLoc == 0
                                           ? cacheData
                                           : [cacheData subdataWithRange:NSMakeRange(cacheScanLoc, cacheRange.length - cacheScanLoc)])];
                @autoreleasepool
                {
                    RELEASE(cacheData);
                    cacheData   = RETAIN([_fileHandle readDataOfLength:CHUNK_SIZE]);
                    cacheBuffer = [cacheData bytes];
                }
                
                cacheRange.length   = [cacheData length];
                cacheRange.location = [_fileHandle offsetInFile] - cacheRange.length;
                cacheScanLoc        = 0;
            }
            
            // If the current stopBuffer byte is equal to the current scanned byte,
            // increment the stop location to scan check the next bytes in both buffer
            // otherwise, reset the stop location so the next scanned byte is compared with the first stop byte
            if(cacheBuffer[scannedLoc - cacheRange.location] == stopBuffer[stopLoc])
                stopLoc++;
            else
            {
                stopFoundLoc = scannedLoc + 1;
                stopLoc      = 0;
            }
            
            // If the stop location is equal to the length of the stopData
            // it means we fully matched the data, break out of the loop
            if(stopLoc >= length)
            {
                hasFoundData = YES;
                break;
            }
        }
        
        if(hasFoundData)
        {
            // The beginning of the stop data is in the data we already bufferized
            if(stopFoundLoc < cacheRange.location)
            {
                if(value != NULL)
                {
                    // We need to truncate the bufferized data before sending it back to the caller
                    unsigned long long trashedLength = cacheRange.location - stopFoundLoc;
                    [retBuffer replaceBytesInRange:NSMakeRange([retBuffer length] - trashedLength, trashedLength) withBytes:NULL length:0];
                    *value = AUTORELEASE([[NSString alloc] initWithData:retBuffer encoding:encoding]);
                    RELEASE(retBuffer);
                }
            }
            // The beginning of the stop data is in the current buffer, append whatever is missing to the returned value
            else
            {
                if(value != NULL)
                {
                    [retBuffer appendBytes:cacheBuffer length:stopFoundLoc - cacheRange.location];
                    *value = AUTORELEASE([[NSString alloc] initWithData:retBuffer encoding:encoding]);
                    RELEASE(retBuffer);
                }
                
                [_cacheData setData:cacheData];
                _cacheRange        = cacheRange;
                _cacheScanLocation = (stopFoundLoc + length) - cacheRange.location;
            }
            
            [self setScanLocation:stopFoundLoc + length];
        }
        else
        {
            // We didn't find the null terminator so we reset the data to the beginning and return YES
            RELEASE(cacheData);
            RELEASE(retBuffer);
            [self setScanLocation:loc];
            
            return NO;
        }
        
        RELEASE(cacheData);
    }
    
    return YES;
}

#define SCAN_METHOD(sel, type)                  \
- (BOOL)sel:(type *)value                       \
{                                               \
    unsigned long long length = sizeof(*value); \
    [self PSY_readAndCacheDataOfLength:length]; \
                                                \
    _useCacheOffset = YES;                      \
    BOOL success = [super sel:value];           \
    _useCacheOffset = NO;                       \
                                                \
    return success;                             \
}

SCAN_METHOD(scanInt8, uint8_t)
SCAN_METHOD(scanLittleEndianInt16, uint16_t)
SCAN_METHOD(scanLittleEndianInt32, uint32_t)
SCAN_METHOD(scanLittleEndianInt64, uint64_t)
SCAN_METHOD(scanBigEndianInt16, uint16_t)
SCAN_METHOD(scanBigEndianInt32, uint32_t)
SCAN_METHOD(scanBigEndianInt64, uint64_t)

SCAN_METHOD(scanFloat, float)
SCAN_METHOD(scanDouble, double)

SCAN_METHOD(scanSwappedFloat, float)
SCAN_METHOD(scanSwappedDouble, double)

@end
