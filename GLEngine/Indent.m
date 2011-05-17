//
//  Indent.m
//  GLEngine
//
//  Created by Pi on 17/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "Indent.h"

int indent=0;
@implementation Indent

+(void)initialize
{
    indent=0;
}

+(void) inc
{
    indent++;
}

+(void) dec
{
    indent--;
}

+(void) zero
{
    indent=0;
}

+(NSString*) margin
{
    return [[NSString string] stringByPaddingToLength: 3*indent
                                           withString: @" "
                                      startingAtIndex: 0 ];
}

//+(void) print
//{
//    for (int i=0; i<indent; i++)
//        printf("..");
//}

+(void) log: (NSString*) S
{
    NSLog(@"%@%@", [Indent margin], S);
}

@end
