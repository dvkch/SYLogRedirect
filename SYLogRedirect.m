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
@end


/* Static file handle to access log */
static NSFileHandle* fileHandle;
/* Grand central dispatch queue for sync */
static dispatch_queue_t queue;
/* Date formatter */
static NSDateFormatter *dateFormatter;

@implementation SYLogRedirect

+(void)openFile:(BOOL)overwrite {
    dispatch_sync(queue, ^{
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/log.txt"];
        
        // Create log file if not here
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:path] || overwrite)
            [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        // creating file handle
        fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
        
        if(fileHandle)
            [fileHandle seekToEndOfFile];
        else
            NSLog(@"Couldn't open log file.");
    });
}

#pragma mark - Initialization

+(void)initialize {
    [super initialize];
    if (self) {
        queue = dispatch_queue_create([[@"SYLogRedirect" stringByAppendingString:[self description]] UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss.SSS' '"];
        
        [self openFile:NO];
    }
}

#pragma mark - Log file manipulation

+(void)emptyLogFile {
    [fileHandle closeFile];
    [self openFile:YES];
}

+(void)writeNSLogToLogAndDebug:(NSObject*)log startingWithDate:(BOOL)prependDate {

    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    if(!fileHandle) 
        [self openFile:NO];

    dispatch_sync(queue, ^{
        [fileHandle writeData:[[(prependDate ? date : @"") stringByAppendingString:[log description]] dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    });
    
}
    
@end
