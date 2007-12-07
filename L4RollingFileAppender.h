/**
 * For copyright & license, see COPYRIGHT.txt.
 */

#import <Foundation/Foundation.h>
#import "L4FileAppender.h"

@class L4Layout;
@class L4LoggingEvent;

/*!
	@header L4RollingFileAppender
	@updated 2004-04-28
*/

// OK I'M GOING TO CHANGE THE BEHAVIOUR SLIGHTLY BECAUSE I
// WANT TO MAKE THE DATE ROLLING LOG FILE A SUB CLASS OF THIS
// SO THAT YOU CAN HAVE A FILE ROLL ON TIME OR ON SIZE.
// THE DEFAULT WILL MAKE IT BEHAVE JUST LIKE ITS SUPER CLASS

/*!
	@const kL4RollingFileAppenderDefaultMaxFileSize
	@discussion The default maximum file size, which is 10MB
*/
extern const unsigned long long kL4RollingFileAppenderDefaultMaxFileSize;

/*!
	@class L4RollingFileAppender
	@discussion This class allows you to automatically create up to a number of backup log files when the log file reaches a specified size.  This class is a subclass of L4FileAppender.
*/
@interface L4RollingFileAppender : L4FileAppender
{
	unsigned int		_maxBackupIndex; // by default, this is 1
	unsigned long long	_maxFileSize; // by default, this is 10MB
}

/*!
	@method init
	@abstract This method initializes a new instance of the L4RollingFileAppender class.
	@discussion This method calls <code>initWithLayout:fileName:append:</code>, with the default values: nil, nil, and YES respectively.
	@result An initialized instance of this class
*/
- (id) init;

/*!
	@method initWithLayout:fileName:
	@abstract This method initialized a new instance of this class with the specified layout and file path
	@discussion This method calls <code>initWithLayout:fileName:append:</code>, with the values: aLayout, aName, and YES respectively.
	@param aLayout The layout object you want this appender to have.
	@param aName The file path of the initial file you want created.  Backup files have the same name, but with the backup file number appended to it (See the <code>rollOver</code> method). 
	@result An initialized instance of this class
*/
- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName; // throws IOException

/*!
	@method initWithLayout:fileName:append:
	@abstract This method initialized a new instance of this class with the specified layout, file path, and append option
	@discussion This is the class's designated initializer.
	@param aLayout The layout object you want this appender to have.
	@param aName The file path of the initial file you want created.  Backup files have the same name, but with the backup file number appended to it (See the <code>rollOver</code> method).
	@param append YES = log output should be appended to the file.  NO = the file's previous contents should be overwritten.
	@result An initialized instance of this class
*/
- (id) initWithLayout: (L4Layout *) aLayout
             fileName: (NSString *) aName
               append: (BOOL) append; // throws IOException

/*!
	@method maxBackupIndex
	@abstract Returns the maximum number of backup files that will be created when the initial log file rolls over.
	@result The maximum number of backup files that will be created when the initial log file rolls over.
*/
- (unsigned int) maxBackupIndex;

/*!
	@method setMaxBackupIndex:
	@abstract Set the maximum number of backup files to keep around.

		The maxBackupIndex determines how many backup files are kept before the oldest is erased. This method takes a positive integer value. If set to zero, then there will be no backup files and the log file will be truncated when it reaches maxFileSize.
	@param mbi The maximum number of backup files that will be created
*/
- (void)setMaxBackupIndex: (unsigned int)mbi;

/*!
	@method maximumFileSize
	@abstract Returns the maximum file size allowed for log files.  If the file grows larger than this, it will be backed up and any additional logging statements will be written to a new file.
	@result The maximum file size allowed for log files (in bytes)
*/
- (unsigned long long) maximumFileSize;

/*!
	@method setMaximumFileSize:
	@abstract Sets the maximum file size allowed for log files.
	@param mfs The maximum file size allowed for log files (in bytes)
*/
- (void)setMaximumFileSize: (unsigned long long)mfs;

/*!
	@method rollOver
	@abstract Explicitly rolls a file over.
	@discussion If maxBackupIndex is positive, then files {File.1, ..., File.MaxBackupIndex -1} are renamed to {File.2, ..., File.MaxBackupIndex}. Moreover, File is renamed File.1 and closed. A new file is created to receive further log output.

		If maxBackupIndex is equal to zero, then the File is truncated with no backup files created.
*/
- (void)rollOver;

@end

/*!
	@category L4RollingFileAppender (__ProtectedMethods)
	@discussion These methods are "protected" methods and should not be called except by subclasses.
*/
@interface L4RollingFileAppender (__ProtectedMethods)

/*!
	@method subAppend:
	@discussion This method overrides the implementation in L4WriterAppender.  It checks if the maximum file size has been exceeded.  If so, it rolls the file over according to the maxBackupIndex setting.
	@param event An L4LoggingEvent that contains logging specific information
*/
- (void)subAppend: (L4LoggingEvent*)event;

@end