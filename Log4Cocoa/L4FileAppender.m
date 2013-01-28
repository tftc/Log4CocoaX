/**
 * For copyright & license, see LICENSE.
 */

#import "L4FileAppender.h"
#import "L4Layout.h"
#import "L4LogLog.h"

@implementation L4FileAppender

- (id) init
{
	return [self initWithLayout:nil fileName:nil append:NO];
}

- (id) initWithProperties:(L4Properties *) initProperties
{    
    self = [super initWithProperties:initProperties];
    
    if ( self != nil ) {
        // Support for appender.File in properties configuration file
        NSString *buf = [initProperties stringForKey:@"File"];
        if ( buf == nil ) {
            [L4LogLog error:@"Invalid filename; L4FileAppender properties require a file be specified."];
            [self release];
            return nil;
        }
        fileName = [[buf stringByExpandingTildeInPath] retain];
        
        // Support for appender.Append in properties configuration file
        append = YES;
        if ( [initProperties stringForKey:@"Append"] != nil ) {
            NSString *buf = [[initProperties stringForKey:@"Append"] lowercaseString];
            append = [buf isEqualToString:@"true"];
        }
		[self setupFile];
    }
    
    return self;
}

- (id) initWithLayout:(L4Layout *) aLayout fileName:(NSString *) aName
{
	return [self initWithLayout:aLayout fileName:aName append:NO];
}

- (id) initWithLayout:(L4Layout *) aLayout fileName:(NSString *) aName append:(BOOL) flag
{
    self = [super init];
	if (self != nil)
	{
		[self setLayout:aLayout];
		fileName = [[aName stringByExpandingTildeInPath] retain];
		append = flag;
		[self setupFile];
	}
	return self;
}

- (void)dealloc
{
	[fileName release];
	fileName = nil;
	
	[super dealloc];
}

#if TARGET_OS_IPHONE
/**
 
 Mod by Deheng.Xu @2013.1.28
 
 Change the path rules for iOS.
 Using relative path like below:
 
 log4cocoa.appender.A2.File=Documents/YourDir/YourFileName
 
 log4cocoa.appender.A2.File=Library/YourDir/YourFileName
 
 log4cocoa.appender.A2.File=tmp/YourDir/YourFileName
 
 //Doesn't support this path, will throw an exception by OS.
 log4cocoa.appender.A2.File=YourDir/YourFileName
 
 */
- (void)setupFile
{
	NSFileManager*	fileManager = nil;
    
    NSString *dir = nil;
    NSRange searchRange = NSMakeRange(NSNotFound, 0);
    if ((searchRange = [fileName rangeOfString:@"Documents"]).location == 0) {
        NSArray * result = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        dir = [result lastObject];
    }else if ((searchRange = [fileName rangeOfString:@"Library"]).location == 0) {
        NSArray * result = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        dir = [result lastObject];
    }else if ((searchRange = [fileName rangeOfString:@"tmp"]).location == 0) {
        dir = NSTemporaryDirectory();
    }else {
        NSArray * result = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
        dir = [result lastObject];
    }
    
    [fileName autorelease];
    fileName = [[NSString stringWithFormat:@"%@%@", dir, [fileName substringFromIndex:searchRange.length]] retain];
        
	@synchronized(self) {
        if (fileName == nil || [fileName length] <= 0) {
            [self closeFile];
            [fileName release];
            fileName = nil;
            [self setFileHandle:nil];
        } else {
            
            fileManager = [NSFileManager defaultManager];
            
            NSMutableArray *components = [[fileName componentsSeparatedByString:@"/"] mutableCopy];
            [components removeLastObject];
            NSString *logDir = [components componentsJoinedByString:@"/"];
            
            if (![fileManager fileExistsAtPath:logDir]) {
                if (![fileManager createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:nil]) {
                    [NSException raise:@"DirectoryNotFoundException" format:@"Could not create a directory at %@", logDir];
                }
            }
            
            // if file doesn't exist, try to create the file
            if (![fileManager fileExistsAtPath:fileName]) {
                // if the we cannot create the file, raise a FileNotFoundException
                if (![fileManager createFileAtPath:fileName contents:nil attributes:nil]) {
                    [NSException raise:@"FileNotFoundException" format:@"Couldn't create a file at %@", fileName];
                }
            }
            
            // if we had a previous file name, close it and release the file handle
            if (fileName != nil) {
                [self closeFile];
            }
            
            // open a file handle to the file
            [self setFileHandle:[NSFileHandle fileHandleForWritingAtPath:fileName]];
            
            // check the append option
            if (append) {
                [fileHandle seekToEndOfFile];
            } else {
                [fileHandle truncateFileAtOffset:0];
            }
        }
    }
}

#else

- (void)setupFile
{
	NSFileManager*	fileManager = nil;

	@synchronized(self) {
        if (fileName == nil || [fileName length] <= 0) {
            [self closeFile];
            [fileName release];
            fileName = nil;
            [self setFileHandle:nil];
        } else {
        
            fileManager = [NSFileManager defaultManager];
        
            // if file doesn't exist, try to create the file
            if (![fileManager fileExistsAtPath:fileName]) {
                // if the we cannot create the file, raise a FileNotFoundException
                if (![fileManager createFileAtPath:fileName contents:nil attributes:nil]) {
                    [NSException raise:@"FileNotFoundException" format:@"Couldn't create a file at %@", fileName];
                }
            }
        
            // if we had a previous file name, close it and release the file handle
            if (fileName != nil) {
               [self closeFile];
            }
        
            // open a file handle to the file
            [self setFileHandle:[NSFileHandle fileHandleForWritingAtPath:fileName]];
        
            // check the append option
            if (append) {
                [fileHandle seekToEndOfFile];
            } else {
                [fileHandle truncateFileAtOffset:0];
            }
        }
    }
}

#endif

- (NSString *) fileName
{
	return fileName;
}

- (BOOL) append
{
	return append;
}

/* ********************************************************************* */
#pragma mark Protected methods
/* ********************************************************************* */
- (void) closeFile
{
    @synchronized(self) {
        [fileHandle closeFile];
        
        // Deallocate the file handle because trying to read from or write to a closed file raises exceptions.  Sending messages to nil objects are no-ops.
        [fileHandle release];
        fileHandle = nil;
    }
}
@end

