//
//  TDLogAppender.m
//  TaduLibrary
//
//  Created by Deheng.Xu on 13-2-19.
//
//

#import "CustomFileAppenderSample.h"
#import "L4Logging.h"

@implementation CustomFileAppenderSample

/**
 YourFileName rule:
 Buildin tags supported are belows.
 
 <date:format>, Replace date time string with current place by 'format' style.
 <version>, Replace app build version with current place.
 <bundleIdentifier>,    Replace app bundle identifier with current place.

 */
- (NSString *)parseTag:(NSString *)fileTag
{
    //Todo:do you own tag parsing.
    if (NO/*you condition*/) {
        
    }
    return [super parseTag:fileTag];
}

@end
