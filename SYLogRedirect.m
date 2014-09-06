//
//  SYLogRedirect.m
//  Syan
//
//  Created by rominet on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SYLogRedirect.h"

/** Category for private methods of SYLogRedirect */
@interface SYLogRedirect ()

///---------------------------------------------------------------------------------------
/// @name Private methods of SYLogRedirect
///---------------------------------------------------------------------------------------

/** Opens the log file and overwrite it if desired
 @param overwrite Switch to overwrite previous file or not
 */
+(void)openFile:(BOOL)overwrite;

/** Same as `+logFilePath`, excepts it never returns `nil` even if log redirection is disabled
 @return log file path
 */
+(NSString*)logFilePath_private;

@end


/* Static file handle to access log */
static NSFileHandle* _fileHandle;
/* Grand central dispatch queue for sync */
static dispatch_queue_t _queue;
/* Date formatter */
static NSDateFormatter *_dateFormatter;
/* Log enabled */
static BOOL _enabled;

@implementation SYLogRedirect

+(NSString*)logFilePath_private {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/log.txt"];
}

+(void)openFile:(BOOL)overwrite {
    dispatch_sync(_queue, ^{
        NSString *path = [self logFilePath_private];
        
        // Create log file if not here
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:path] || overwrite)
            [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        // creating file handle
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
        
        if(_fileHandle)
            [_fileHandle seekToEndOfFile];
        else
            NSLog(@"Couldn't open log file.");
    });
}

#pragma mark - Initialization

+(void)initialize {
    [super initialize];
    if (self) {
        _queue = dispatch_queue_create([[@"SYLogRedirect" stringByAppendingString:[self description]] UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss.SSS' '"];
    }
}

#pragma mark - Parameters

+(void)setLogRedirectionEnabled:(BOOL)enabled {
    _enabled = enabled;
}

+(NSString *)logFilePath {
    if(!_enabled)
        return nil;
    
    return [self logFilePath_private];
}

#pragma mark - Log file manipulation

+(void)emptyLogFile {
    [_fileHandle closeFile];
    [self openFile:YES];
}

+(void)writeNSLogToLogAndDebug:(NSObject*)log startingWithDate:(BOOL)prependDate {
    
    if(!_enabled)
        return;

    NSString *date = [_dateFormatter stringFromDate:[NSDate date]];
    
    if(!_fileHandle)
        [self openFile:NO];

    dispatch_sync(_queue, ^{
        [_fileHandle writeData:[[(prependDate ? date : @"") stringByAppendingString:[log description]] dataUsingEncoding:NSUTF8StringEncoding]];
        [_fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    });
    
}
    
@end
