PSYDataAdditions
================

Overview
--------

PSYDataAdditions is a small library written in Objective-C and based on Cocoa Foundation that allows encoding and decoding raw data.

Components
----------

### PSYDataScanner ###

PSYDataScanner is to NSData what NSScanner is to NSString: it allows you to scan an NSData object by extracting different types of data and maintaining the scanning position.

All scan methods:
* return a BOOL indicating whether the scanning worked;
* advance the scanning position by the amount necessary for the their type if the scanning worked;
* store the scanned value in the passed in pointer if a non-NULL pointer is provided.

### NSMutableData+PSYDataWriter ###

NSMutableData+PSYDataWriter is the counterpart for PSYDataScanner. It is implemented as a category of NSMutableData to allow appending bytes to any mutable data object. The methods of the category allows you to append or replace bytes in the object in the same format that is scanned by PSYDataScanner.


Special Thanks
--------------

Thank you to [Beelsebob](https://github.com/beelsebob) for his valuable support and additions to this library.