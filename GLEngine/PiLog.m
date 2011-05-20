//
//  Indent.m
//  GLEngine
//
//  Created by Pi on 17/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "PiLog.h"

int indent=0;

@implementation PiLog

+ (void) initialize
{
    indent=0;
}

+ (void) indent
{
    indent++;
}

+ (void) outdent
{
    indent--;
}

+ (void) zero
{
    indent=0;
}

+ (NSString*) margin
{
    return [[NSString string] stringByPaddingToLength: 3*indent
                                           withString: @" "
                                      startingAtIndex: 0 ];
}

+ (void) log: (NSString*) S
{
    NSString* T = [ NSString stringWithFormat: @"%@%@", [PiLog margin], S ];
    
    printf("%s \n", [ T UTF8String ] );
}

@end
