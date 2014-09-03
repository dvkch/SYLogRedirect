//
//  SYLogRedirect.h
//  Syan
//
//  Created by rominet on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


///---------------------------------------------------------------------------------------
/// @name Redirect Macros
///---------------------------------------------------------------------------------------

/** Redirects NSLog to SYLogRedirect. This will mimic the debugger display.*/
#define NSLog(args...) \
NSLog(args),\
[SYLogRedirect writeNSLogToLogAndDebug:[NSString stringWithFormat:args] startingWithDate:YES]

/** Redirects NSLog to SYLogRedirect.
 
 Two lines will be written. The first will contain date, filename, line number and function name,
 the second will mimic the debugger output without filename
 */
#define NSLogFull(args...) \
NSLog(args),\
[SYLogRedirect writeNSLogToLogAndDebug:[NSString stringWithFormat:@"\n%s:%d - %s\t", __FILE__, __LINE__, __PRETTY_FUNCTION__] startingWithDate:YES],\
[SYLogRedirect writeNSLogToLogAndDebug:[NSString stringWithFormat:args] startingWithDate:NO]

/** Once the header file imported every call to NSLog will be duplicated into a call to
 the native NSLog and a call to SYLogRedirect. The log will available in both debugger
 and a file on the device.

 A GCD queue is used to synchronize operations and prevent writing file emptying or
 opening file.
 */
@interface SYLogRedirect : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization
///---------------------------------------------------------------------------------------

/** Class initialization.
 
 Called once on first class method use. Creates the GCD queue for sync and opens the 
 log file in append mode. */
+(void)initialize;

///---------------------------------------------------------------------------------------
/// @name Log file manipulation
///---------------------------------------------------------------------------------------

/** Empties log file and reopens it to continue logging immediately */
+(void)emptyLogFile;

/** Writes a line to the log file 
 
 @param log Object to log. The result of description method is written to the file
 @param prependDate Controls the presence of the date on the beginning of the line to write
 */
+(void)writeNSLogToLogAndDebug:(NSObject*)log startingWithDate:(BOOL)prependDate;

@end
