/*
 PSYDataDataScanner.m
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

#import "PSYDataDataScanner.h"
#import "PSYUtilities.h"

@implementation PSYDataDataScanner
@synthesize data = _scannedData, scanLocation = _scanLocation, dataLength = _dataLength;

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

- (unsigned long long)scanLocation { return _scanLocation; }
- (void)setScanLocation:(unsigned long long)value
{
    if(value > [_scannedData length])
        [NSException raise:NSRangeException format:@"*** -[PSYDataScanner setScanLocation:]: Range or index out of bounds"];
    
    _scanLocation = value;
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
    unsigned long long length = [data length];
    if(_scanLocation + length > _dataLength) return NO;
    
    if(length > 0)
    {
        NSData *subdata = [_scannedData subdataWithRange:NSMakeRange(_scanLocation, length)];
        
        if([subdata isEqualToData:data])
        {
            if(dataValue != NULL) *dataValue = subdata;
            
            [self setScanLocation:_scanLocation + length];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData **)dataValue
{
    return [self scanUpToData:stopData intoData:dataValue options:0];
}

- (BOOL)scanUpToData:(NSData *)stopData intoData:(NSData **)dataValue options:(PSYDataScannerOptions)options;
{
    unsigned long long length = [stopData length];
    
    NSRange dataLocation = NSMakeRange(_scanLocation, 0);
    
    if(length == 0 || _scanLocation + length > _dataLength)
        dataLocation.location = _dataLength;
    else
    {
        const unsigned char *scannedBuffer = [_scannedData bytes];
        const unsigned char *stopBuffer    = [stopData bytes];
        unsigned long long   stopLoc       = 0;
        
        for(unsigned long long scannedLoc = _scanLocation; scannedLoc + (length - stopLoc) <= _dataLength; scannedLoc++)
        {
            // If the current stopBuffer byte is equal to the current scanned byte,
            // increment the stop location to scan check the next bytes in both buffer
            // otherwise, reset the stop location so the next scanned byte is compared with the first stop byte
            if(scannedBuffer[scannedLoc] == stopBuffer[stopLoc])
                stopLoc++;
            else
            {
                dataLocation.location = scannedLoc + 1;
                stopLoc = 0;
            }
            
            // If the stop location is equal to the length of the stopData
            // it means we fully matched the data, break out of the loop
            if(stopLoc >= length)
            {
                dataLocation.length = length;
                break;
            }
        }
        
        if(stopLoc < length) dataLocation.location = _dataLength;
    }
    
    if((options & PSYDataScannerRequireStopData) && dataLocation.length != length) return NO;
    else if(!(options & PSYDataScannerRequireStopData) && dataLocation.location == _scanLocation) return NO;
    
    if(dataValue != NULL) *dataValue = [[self data] subdataWithRange:NSMakeRange(_scanLocation, dataLocation.location - _scanLocation)];
    
    _scanLocation = (options & PSYDataScannerMoveAfterStopData ? NSMaxRange(dataLocation) : dataLocation.location);
    
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
            *value = AUTORELEASE([[NSString alloc] initWithData:subData encoding:encoding]);
        }
        
        _scanLocation = NSMaxRange(termRange);
        return YES;
    }
    
    return NO;
}

@end
